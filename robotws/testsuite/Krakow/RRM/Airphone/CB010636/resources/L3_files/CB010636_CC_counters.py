"""
:copyright: Nokia Networks
:author: Mateusz Matusik
:maintainer:  Mateusz Matusik
:contact: mateusz.matusik@nokia.com
"""

from testsuite.Krakow.RRM.Airphone.CB010636.resources.L3_files.CB010636_resources_new import *
import collections
import math

from testsuite.Krakow.RRM.Airphone.resources.Python.utilities import (
    logger_console_info
)


def get_all_unique_values_from_column(csv_data, column_name):
    """
    Reads a CSV file and returns a list of unique values from selected column.

    :param csv_data: The path to the CSV file to be parsed.
    :param column_name: The name of the column from which we take unique values
    :return: List of unique values from the selected column from the CSV file.
    """
    return list(set([item[column_name] for item in csv_data]))


def calculate_new_state_after_burst_stop_action(current_action, current_state, time, next_time):
    """
    Removes burst from active state, lowers current state rate and decreases cc count

    :param current_action: Dictionary with a changes to apply to previous burst state.
    :param current_state: Dictionary with current state of active bursts
    :param time: Start of next time period
    :param next_time: Stop of next time period
    :return: Dictionary with next state of active bursts.
    """
    cc = current_state['cc'] - 1
    burst_list = current_state['burst_id']
    burst_list.remove(current_action['burst_id'])
    pci_list = current_state['pci']
    pci_list.remove(current_action['pci'])
    burst_amount = current_state['burst_amount'] - current_action['burst_amount'] if cc else 0
    burst_rate = current_state['burst_rate'] - current_action['burst_rate'] if cc else 0
    new_state = {'t_start': time,
                 't_stop': next_time,
                 'burst_id': burst_list,
                 'pci': pci_list,
                 'burst_amount': burst_amount,
                 'burst_rate': burst_rate,
                 'cc': cc}
    return new_state


def calculate_new_state_after_burst_start_action(current_action, current_state, time, next_time):
    """
    Adds burst to active state, increases current state rate and increases cc count

    :param current_action: Dictionary with a changes to apply to previous burst state.
    :param current_state: Dictionary with current state of active bursts
    :param time: Start of next time period
    :param next_time: Stop of next time period
    :return: Dictionary with next state of active bursts.
    """
    # print(current_state)
    cc = current_state['cc'] + 1
    burst_list = current_state['burst_id']
    burst_list.append(current_action['burst_id'])
    pci_list = current_state['pci']
    pci_list.append(current_action['pci'])
    burst_amount = current_state['burst_amount'] + current_action['burst_amount']
    burst_rate = current_state['burst_rate'] + current_action['burst_rate']
    new_state = {'t_start': time,
                 't_stop': next_time,
                 'burst_id': burst_list,
                 'pci': pci_list,
                 'burst_amount': burst_amount,
                 'burst_rate': burst_rate,
                 'cc': cc}
    return new_state


def get_bursts_timeline_from_merged_bursts(merged_bursts_dict, cell_type):
    """
        Creates dictionary with a timestamp as a key and parameters of started or stopped burst in that time as a
        value. It counts only burst that are not discarded due to threshold limit in gNB.

        :param merged_bursts_dict: Dictionary with a list of bursts from applicable merged bursts
        :param cell_type: Dictionary with phycellId as a key and cell type as a value
        :return: Dictionary with data about each burst start and end for all gNB cells
        """
    burst_for_cc = collections.defaultdict(dict)
    for merged_burst_id in merged_bursts_dict:
        for single_burst in merged_bursts_dict[merged_burst_id]['aggregated_bursts_list']:
            t_start = round_down_to_slot(single_burst['start'], mode=cell_type[str(single_burst['pci'])])
            t_stop = round_up_to_slot(single_burst['stop'], mode=cell_type[str(single_burst['pci'])])
            burst_duration_tsatmp = round_to_0_5(t_stop - t_start)
            burst_id = int(single_burst['burst_id'])
            burst_amount = single_burst['burst_volume']
            burst_rate = burst_amount / burst_duration_tsatmp if burst_duration_tsatmp else 0
            cell = single_burst['pci']

            burst_cc_start = {'action': 'start', 'pci': cell, 'burst_id': burst_id, 'burst_amount': burst_amount,
                              'burst_rate': burst_rate}
            burst_cc_stop = {'action': 'stop', 'pci': cell, 'burst_id': burst_id, 'burst_amount': burst_amount,
                             'burst_rate': burst_rate}
            if t_start != t_stop:
                if t_start in burst_for_cc.keys():
                    if not isinstance(burst_for_cc[t_start], list):
                        burst_for_cc[t_start] = [burst_for_cc[t_start]]
                    burst_for_cc[t_start].append(burst_cc_start)
                else:
                    burst_for_cc[t_start] = burst_cc_start
                if t_stop in burst_for_cc.keys():
                    if not isinstance(burst_for_cc[t_stop], list):
                        burst_for_cc[t_stop] = [burst_for_cc[t_stop]]
                    burst_for_cc[t_stop].append(burst_cc_stop)
                else:
                    burst_for_cc[t_stop] = burst_cc_stop

    return burst_for_cc


def calculate_cc_counters(burst_for_cc, ue_cells, last_slot):
    """
    Calculates burt duration and volume in regard to currently active number of CC's

    :param burst_for_cc: Dictionary with a timestamp as a key and parameters of started or stopped burst in that time
    as a value.
    :param ue_cells: List with cells from which we calculate bursts
    :param last_slot: Dictionary with sum of merged bursts last slot volume and duration
    :return: Tuple containing dictionaries with volume and duration for each CC count
    """
    total_burst_duration_cc = {}
    total_burst_volume_cc = {}
    for i in range(len(ue_cells)+1):
        total_burst_duration_cc[i] = 0.0
        total_burst_volume_cc[i] = 0.0
    current_state = {'t_start': 0,
                     't_stop': 0,
                     'burst_id': [],
                     'pci': [],
                     'burst_amount': 0.0,
                     'burst_rate': 0.0,
                     'cc': 0}
    for time in sorted(burst_for_cc.keys())[:-1]:
        index = sorted(burst_for_cc.keys()).index(time)
        next_time = sorted(burst_for_cc.keys())[index + 1]
        if isinstance(burst_for_cc[time], list):
            for action in burst_for_cc[time]:
                if action['action'] == 'stop':
                    current_state = calculate_new_state_after_burst_stop_action(action, current_state, time, next_time)
                elif action['action'] == 'start':
                    current_state = calculate_new_state_after_burst_start_action(action, current_state, time,
                                                                                 next_time)
                else:
                    current_state = 'Error for index: {} time: {}'.format(index, time)

            slice_time = round_to_0_5(next_time - float(time))
            slice_rate = current_state['burst_rate']
            slice_volume = round(slice_time * slice_rate)

            total_burst_duration_cc[current_state['cc']] += slice_time
            total_burst_volume_cc[current_state['cc']] += slice_volume
        else:
            if index == 0:
                current_state = {'t_start': time,
                                 't_stop': next_time,
                                 'burst_id': [burst_for_cc[time]['burst_id']],
                                 'pci': [burst_for_cc[time]['pci']],
                                 'burst_amount': float(burst_for_cc[time]['burst_amount']),
                                 'burst_rate': float(burst_for_cc[time]['burst_rate']),
                                 'cc': 1}
            else:
                if burst_for_cc[time]['action'] == 'stop':
                    current_state = calculate_new_state_after_burst_stop_action(burst_for_cc[time], current_state,
                                                                                time, next_time)
                elif burst_for_cc[time]['action'] == 'start':
                    current_state = calculate_new_state_after_burst_start_action(burst_for_cc[time], current_state,
                                                                                 time, next_time)
                else:
                    current_state = 'Error for index: {} time: {}'.format(index, time)

            slice_time = round_to_0_5(next_time - float(time))
            slice_rate = current_state['burst_rate']
            slice_volume = round(slice_time * slice_rate)

            total_burst_duration_cc[current_state['cc']] += slice_time
            total_burst_volume_cc[current_state['cc']] += slice_volume

    # total_burst_duration_cc[1] -= last_slot['duration']
    # total_burst_volume_cc[1] = round(total_burst_volume_cc[1] - last_slot['volume'])

    return total_burst_duration_cc, total_burst_volume_cc


def aggregate_bursts_into_merged_one_for_ue(filter_with_basic, cell_type, ue_cells, threshold_vol=0, threshold_time=0,
                                            rnti=0):
    """
    Detects periods with constant burst duration across all active cells. Counts periods without any active burst.
    Creates dictionary with last slot volume and duration for each burst. Calculates sum of merged bursts volume and
    duration

    :param filter_with_basic: Dictionary with a list of bursts from all gNB cells
    :param cell_type: Dictionary with phycellId as a key and cell type as a value
    :param ue_cells: List with cells from which we calculate bursts
    :param threshold: Threshold of amount of bytes in burst to discard burst from counting
    :return: Tuple containing dictionary with merged bursts calculated volume and duration and dictionary with sum
    of merged bursts last slot volume and duration
    """

    log_dir = '/home/ute/'
    output_dir = os.path.dirname(log_dir)
    hour = int(round(float(datetime.now().strftime("%H.%M"))))
    if len(str(hour)) < 2:
        hour = '0' + str(hour)
    minute = round(5 * math.floor(int(datetime.now().strftime("%M")) / 5), 0)
    if len(str(minute)) < 2:
        minute = '0' + str(minute)
    date_str = datetime.now().strftime("%y%m%d") + "_" + str(hour) + str(minute) + "30"
    output_file_name = date_str + "_" + "CB010636_merge_burst.txt"
    burst_file_name = date_str + "_" + "CB010636_burst.txt"
    output_file = os.path.join(output_dir, output_file_name)
    burst_file = os.path.join(output_dir, burst_file_name)
    f = open(output_file, 'a')
    g = open(burst_file, 'a')

    bursts_tsatmp = {}
    burst_dict = {}
    bursts_volume = {}
    burst_last_slot = collections.defaultdict(dict)
    for cell in ue_cells:
        filtered_cell = remove_wrong_lines_and_filter_data(filter_with_basic, physCellId=int(cell))
        channel_burst_map_dict = group_by_keys(filtered_cell, 'burstId')
        for single_burst in channel_burst_map_dict:
            burst_duration, burst_duration_tsatmp = get_time_per_burst(channel_burst_map_dict[single_burst],
                                                                       cell_type[str(cell)])
            t_start = channel_burst_map_dict[single_burst][0]['timestamp'] * 1000
            t_stop = t_start + burst_duration
            volume = get_amount_bytes_per_burst(channel_burst_map_dict[single_burst])
            bursts_volume[t_start] = volume
            bursts_tsatmp[t_start] = t_stop
            burst_last_slot_volume = get_amount_bytes_per_burst(channel_burst_map_dict[single_burst][-1:])
            burst_last_slot_duration, tmp = get_time_per_burst(channel_burst_map_dict[single_burst][-1:],
                                                               cell_type[str(cell)])
            burst_last_slot[t_start]['volume'] = burst_last_slot_volume
            burst_last_slot[t_start]['duration'] = burst_last_slot_duration
            burst_dict[t_start] = {'start': t_start,
                                   'stop': t_stop,
                                   'pci': cell,
                                   'burst_id': int(float(channel_burst_map_dict[single_burst][0]['burstId'])),
                                   'burst_volume': round(volume),
                                   'last_slot_volume': burst_last_slot_volume,
                                   'last_slot_duration': burst_last_slot_duration}
            tmp = round_up_to_slot(t_stop, mode=cell_type[str(cell)]) - round_down_to_slot(t_start,
                                                                                           mode=cell_type[str(cell)])
            print(f'UE {rnti} pci {cell} burst volume and duration: {volume} {tmp}', file=g)

    burst_start = round_down_to_slot(sorted(bursts_tsatmp.keys())[0],
                                     mode=cell_type[str(burst_dict[sorted(bursts_tsatmp.keys())[0]]['pci'])])
    burst_stop = round_up_to_slot(bursts_tsatmp[sorted(bursts_tsatmp.keys())[0]],
                                  mode=cell_type[str(burst_dict[sorted(bursts_tsatmp.keys())[0]]['pci'])])
    aggregated_burst_volume = 0
    aggregated_burst_duration = round_to_0_5(burst_stop - burst_start)
    merged_burst_dict = {}
    merged_burst_id = 1
    burst_tmp = []
    last_time = bursts_tsatmp[sorted(bursts_tsatmp.keys())[0]]
    last_volume = 0
    last_duration = 0
    for start, stop in sorted(bursts_tsatmp.items()):
        slot_start = round_down_to_slot(start, mode=cell_type[str(burst_dict[start]['pci'])])
        slot_stop = round_up_to_slot(stop, mode=cell_type[str(burst_dict[start]['pci'])])
        if slot_start <= burst_stop < slot_stop:
            aggregated_burst_volume += round(bursts_volume[start])
            # print(aggregated_burst_volume)
            aggregated_burst_duration += round_to_0_5(slot_stop - burst_stop)
            burst_tmp.append(burst_dict[start])
            burst_stop = slot_stop
            last_time = stop
        elif slot_start <= burst_stop and slot_stop <= burst_stop:
            aggregated_burst_volume += round(bursts_volume[start])
            burst_tmp.append(burst_dict[start])
        elif slot_start > burst_stop:
            tmp_time = burst_stop - burst_start
            print(f'UE {rnti} merged burst volume and duration: {aggregated_burst_volume} {tmp_time}', file=f)
            if aggregated_burst_volume < threshold_vol or burst_stop - burst_start < threshold_time:
                print('Burst lower than threshold, volume:  {}, duration: {}'.format(aggregated_burst_volume,
                                                                                     aggregated_burst_duration))
                burst_stop = slot_stop
                burst_start = slot_start
                burst_tmp = [burst_dict[start]]
                aggregated_burst_volume = bursts_volume[start]
                aggregated_burst_duration = slot_stop - slot_start
            else:
                last_burst_start_time = list(bursts_tsatmp.keys())[list(bursts_tsatmp.values()).index(last_time)]
                for burst in burst_tmp:
                    if round_up_to_slot(burst['stop'], mode=cell_type[str(burst['pci'])]) == burst_stop:
                        burst_tmp.pop(burst_tmp.index(burst))
                        burst['stop'] = burst['stop'] - burst['last_slot_duration']
                        burst['burst_volume'] = round(burst['burst_volume'] - burst['last_slot_volume'])
                        last_volume += burst['last_slot_volume']
                        last_duration += burst['last_slot_duration']
                        if not burst['burst_volume'] <= 0 or not round_to_0_5(burst['stop'] - burst['start']) <= 0:
                            burst_tmp.append(burst)
                if len(burst_tmp) > 0:
                    burst_stop = max(int(x['stop']) for x in burst_tmp)
                    aggregated_burst_volume = round(sum(x['burst_volume'] for x in burst_tmp))
                    aggregated_burst_duration = round_to_0_5(burst_stop - burst_start)
                    merged_burst_dict[merged_burst_id] = {'start': burst_start,
                                                          'stop': burst_stop,
                                                          'burst_id': merged_burst_id,
                                                          'burst_volume': round(aggregated_burst_volume),
                                                          'burst_duration': aggregated_burst_duration,
                                                          'last_slot_volume':
                                                              round(burst_last_slot[last_burst_start_time]['volume']),
                                                          'last_slot_duration': round_to_0_5(burst_last_slot
                                                                                             [last_burst_start_time]
                                                                                             ['duration']),
                                                          'aggregated_bursts_list': burst_tmp}
                aggregated_burst_volume = round(bursts_volume[start])
                aggregated_burst_duration = round_to_0_5(slot_stop - slot_start)
                burst_stop = slot_stop
                burst_start = slot_start
                last_time = stop
                burst_tmp = [burst_dict[start]]
                merged_burst_id += 1

    tmp_time = burst_stop - burst_start
    print(f'UE {rnti} merged burst volume and duration: {aggregated_burst_volume} {tmp_time}', file=f)
    if aggregated_burst_volume >= threshold_vol and burst_stop - burst_start >= threshold_time:
        last_burst_start_time = list(bursts_tsatmp.keys())[list(bursts_tsatmp.values()).index(last_time)]

        for burst in burst_tmp:
            if round_up_to_slot(burst['stop'], mode=cell_type[str(burst['pci'])]) == burst_stop:
                burst_tmp.pop(burst_tmp.index(burst))
                burst['stop'] = burst['stop'] - burst['last_slot_duration']
                burst['burst_volume'] = round(burst['burst_volume'] - burst['last_slot_volume'])
                last_volume += burst['last_slot_volume']
                last_duration += burst['last_slot_duration']
                if not burst['burst_volume'] <= 0 or not round_to_0_5(burst['stop'] - burst['start']) <= 0:
                    burst_tmp.append(burst)
        if len(burst_tmp) > 0:
            burst_stop = max(int(x['stop']) for x in burst_tmp)
            aggregated_burst_volume = round(sum(x['burst_volume'] for x in burst_tmp))
            aggregated_burst_duration = round_to_0_5(burst_stop - burst_start)
            merged_burst_dict[merged_burst_id] = {'start': burst_start,
                                                  'stop': burst_stop,
                                                  'burst_id': merged_burst_id,
                                                  'burst_volume': round(aggregated_burst_volume),
                                                  'burst_duration': aggregated_burst_duration,
                                                  'last_slot_volume':
                                                      round(burst_last_slot[last_burst_start_time]['volume']),
                                                  'last_slot_duration':
                                                      round_to_0_5(burst_last_slot[last_burst_start_time]['duration']),
                                                  'aggregated_bursts_list': burst_tmp}
    else:
        print('Burst lower than threshold, volume:  {}, duration: {}'.format(aggregated_burst_volume,
                                                                             aggregated_burst_duration))

    return merged_burst_dict, {'volume': round(sum(x['last_slot_volume'] for x in merged_burst_dict.values())),
                               'duration': round_to_0_5(sum(x['last_slot_duration'] for x in
                                                            merged_burst_dict.values()))}


def get_burst_amount_and_time_per_cc_from_all_cells_for_ue(csv_file_path, rnti, cell_info, threshold_vol=0,
                                                           threshold_time=0,
                                                           log_year=datetime.now().year,
                                                           log_month=datetime.now().month,
                                                           log_day=datetime.now().day):
    """
    Calculates the total amount of bytes and burst duration per CC for UE based on the provided CSV file.

    :param csv_file_path: The path to the CSV file containing the data.
    :param rnti: The radio network temporary identifier (RNTI).
    :param cell_type: Dictionary with phycellId as a key and cell type as a value
    :param threshold: Threshold of amount of bytes in burst to discard burst from counting
    :param log_year: (optional) The year for timestamp calculation (default: current year).
    :param log_month: (optional) The month for timestamp calculation (default: current month).
    :param log_day: (optional) The day for timestamp calculation (default: current day).
    :return: Tuple containing dictionaries with total amount of bursts volume (in kbit) and burst duration (in ms) per
    CC based on the provided CSV file.
    """
    cell_type = {}
    for item in cell_info:
        cell_type[item['pci']] = item['type']

    csv_data = get_csv_list_of_dicts(csv_file_path)
    csv_data = calculate_and_add_timestamp_column(csv_data, log_year, log_month, log_day)
    csv_data = calculate_and_add_padding_column(csv_data)

    filter_with_basic = remove_wrong_lines_and_filter_data(csv_data, rnti=rnti)
    ue_cells = get_all_unique_values_from_column(csv_data, 'physCellId')

    merged_bursts, last_slot = aggregate_bursts_into_merged_one_for_ue(filter_with_basic, cell_type, ue_cells,
                                                                       threshold_vol, threshold_time, rnti)

    print(last_slot)
    merged_burst_volume = round(sum(x['burst_volume'] for x in merged_bursts.values()))
    merged_burst_duration = round_to_0_5(sum(x['burst_duration'] for x in merged_bursts.values()))

    # burst_for_cc = get_bursts_timeline_from_all_cells_for_ue(filter_with_basic, cell_type, ue_cells)
    burst_for_cc = get_bursts_timeline_from_merged_bursts(merged_bursts, cell_type)
    total_burst_duration_cc, total_burst_volume_cc = calculate_cc_counters(burst_for_cc, ue_cells, last_slot)
    # burst_per_cc = collections.defaultdict(dict)
    burst_per_cc = {}
    for cc in total_burst_duration_cc.keys():
        burst_per_cc[cc] = {'volume': total_burst_volume_cc[cc],
                            'duration': total_burst_duration_cc[cc]}
        print(burst_per_cc[cc])

    return merged_burst_volume, merged_burst_duration, burst_per_cc


def round_down_to_slot(x, prec=1, mode='FR1_TDD'):
    if mode == 'FR2_TDD':
        base = 0.125
    elif mode == 'FR1_TDD':
        base = 0.5
    else:
        base = 1

    return round(base * math.floor(float(x) / base), prec)


def round_up_to_slot(x, prec=1, mode='FR1_TDD'):
    if mode == 'FR2_TDD':
        base = 0.125
    elif mode == 'FR1_TDD':
        base = 0.5
    else:
        base = 1

    return round(base * math.ceil(float(x-base) / base), prec)


def calculate_time_for_each_cell_from_merged_burst_for_ue(merged_bursts, cell_type):
    rlc_times = {}
    for cell_pci in cell_type.keys():
        rlc_times[str(cell_pci)] = 0
    for merged_id in merged_bursts:
        for burst in merged_bursts[merged_id]['aggregated_bursts_list']:
            rlc_times[str(burst['pci'])] += burst['stop'] - burst['start']

    return rlc_times


def get_rlc_times_from_merged_burst_from_all_cells_for_ue(csv_file_path, rnti, cell_info, threshold_vol=0,
                                                          threshold_time=0, bearer=0, log_year=datetime.now().year,
                                                          log_month=datetime.now().month, log_day=datetime.now().day):

    cell_type = {}
    for item in cell_info:
        cell_type[item['pci']] = item['type']

    csv_data = get_csv_list_of_dicts(csv_file_path)
    csv_data = calculate_and_add_timestamp_column(csv_data, log_year, log_month, log_day)
    csv_data = calculate_and_add_padding_column(csv_data)
    if not bearer:
        filter_with_basic = remove_wrong_lines_and_filter_data(csv_data, rnti=rnti)
    else:
        filter_with_basic = remove_wrong_lines_and_filter_data(csv_data, rnti=rnti, logicalChannelId=bearer)
    ue_cells = get_all_unique_values_from_column(csv_data, 'physCellId')
    merged_bursts, last_slot = aggregate_bursts_into_merged_one_for_ue(filter_with_basic, cell_type, ue_cells,
                                                                       threshold_vol, threshold_time, rnti)

    rlc_times = calculate_time_for_each_cell_from_merged_burst_for_ue(merged_bursts, cell_type)

    return rlc_times


def inter_gnb_ca_rlc_times(csv_file_path_gnb1, csv_file_path_gnb2, rnti, cell_info, threshold_vol=0, threshold_time=0,
                           bearer=0, log_year=datetime.now().year, log_month=datetime.now().month,
                           log_day=datetime.now().day):

    cell_type = {}
    for item in cell_info:
        cell_type[item['pci']] = item['type']

    csv_data_gnb1 = get_csv_list_of_dicts(csv_file_path_gnb1)
    csv_data_gnb2 = get_csv_list_of_dicts(csv_file_path_gnb2)
    for row in csv_data_gnb2:
        csv_data_gnb1.append(row)

    csv_data_gnb1 = calculate_and_add_timestamp_column(csv_data_gnb1, log_year, log_month, log_day)
    csv_data_gnb1 = calculate_and_add_padding_column(csv_data_gnb1)
    if not bearer:
        filter_with_basic = remove_wrong_lines_and_filter_data(csv_data_gnb1, rnti=rnti)
    else:
        filter_with_basic = remove_wrong_lines_and_filter_data(csv_data_gnb1, rnti=rnti, logicalChannelId=bearer)
    ue_cells = get_all_unique_values_from_column(csv_data_gnb1, 'physCellId')

    merged_bursts, last_slot = aggregate_bursts_into_merged_one_for_ue(filter_with_basic, cell_type, ue_cells,
                                                                       threshold_vol, threshold_time, rnti)

    rlc_times = calculate_time_for_each_cell_from_merged_burst_for_ue(merged_bursts, cell_type)

    return rlc_times
