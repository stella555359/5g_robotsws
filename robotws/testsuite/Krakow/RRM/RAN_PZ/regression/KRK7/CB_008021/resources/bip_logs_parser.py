import datetime
import math
import os
import warnings

timestamp_format = "%Y-%m-%d %H:%M:%S"
log_timestamp_format_cest = "%b  %d, %Y %H:%M:%S.%f000 CEST"
log_timestamp_format_UTC = "%b  %d, %Y %H:%M:%S.%f000 UTC"
log_timestamp_format_cet = "%b  %d, %Y %H:%M:%S.%f000 CET"


def average_in_dBm(aW):
    return 10 * math.log10(1000 * aW * pow(10, -18))


def find_max_for_same_msg(PUCCH_file, PUSCH_file, counter_id_list):
    """ find_max_for_same_msg is a function to average max values per PRB
        if PUCCH and PUSCH messages where in the same slot
        pandas and numpy are imported in runtime, as they are not normally installed on VM,
        you need to install them in preconditions first to use this method
        :PUCCH_file:  Handle to .csv file containing PUCCH messages
        :PUSCH_file: Handle to .csv file containing PUSCH messages
        :counter_id_list: list of counters which will be used for averaging

        :return: Dictionary with max candidates per PRB name and value of max noise
    """
    import pandas as pd
    import numpy as np
    f_merge = pd.merge(PUCCH_file, PUSCH_file, on=['asfn', 'sfn', 'slot'], how='inner')
    df_array = []
    for name in counter_id_list:
        f_merge['tag'] = np.where((f_merge[name + '_x'] != 10) & (f_merge[name + '_y'] != 10) &
                                  (pd.notna(f_merge[name + '_x'])) &
                                  (pd.notna(f_merge[name + '_y'])),
                                  name, False)
        df_array.append(f_merge.loc[f_merge['tag'] != 'False'])
    max_candidate = pd.concat(df_array)
    which_prbs = max_candidate["tag"].values.tolist()
    which_prbs = list(set(which_prbs))
    output_dict = {}
    for prb_id in which_prbs:
        pucch_prbs = max_candidate[prb_id + "_x"].values.tolist()
        pusch_prbs = max_candidate[prb_id + "_y"].values.tolist()
        averages_list = []
        for i in range(len(pucch_prbs)):
            averages_list.append((pucch_prbs[i] + pusch_prbs[i]) / 2)
        output_dict.update({prb_id: max(averages_list)})
    return output_dict, max_candidate


def trim_messages(csv_file, start_time, end_time, file_name):
    csv_file = csv_file.sort_values(["time"], inplace=False)
    if "prach" in file_name or "pusch":
        csv_file = csv_file.drop_duplicates(subset="time", inplace=False)
        if "pusch" in file_name:
            print("removing fakeUE")
            print(len(csv_file))
            csv_file.drop(csv_file[csv_file['rnti'] == 65521].index, inplace=True)
            print(len(csv_file))
    start_time = datetime.datetime.strptime(start_time, timestamp_format)
    end_time = datetime.datetime.strptime(end_time, timestamp_format)
    if csv_file.shape[0] > 0:
        try:
            datetime.datetime.strptime(csv_file.iloc[-1, 0], log_timestamp_format_cest)
            log_timestamp_format = log_timestamp_format_cest
        except ValueError:
            try:
                datetime.datetime.strptime(csv_file.iloc[-1, 0], log_timestamp_format_UTC)
                log_timestamp_format = log_timestamp_format_UTC
            except ValueError:
                log_timestamp_format = log_timestamp_format_cet
    else:
        log_timestamp_format = log_timestamp_format_UTC
    for i in range(csv_file.shape[0]):
        time_stamp = datetime.datetime.strptime(csv_file.iloc[i, 0], log_timestamp_format)
        if time_stamp >= start_time:
            csv_file = csv_file.iloc[i:, ]
            break
    for i in reversed(range(csv_file.shape[0])):
        time_stamp = datetime.datetime.strptime(csv_file.iloc[i, 0], log_timestamp_format)
        if time_stamp <= end_time:
            csv_file = csv_file.iloc[:i + 1, ]
            break
    return csv_file


def calculate_prb_sum_and_len(csv_file,
                              file_name,
                              transmission_technology,
                              counter_id_list,
                              msg1FrequencyStart,
                              rach_avg):
    """ calculate_prb_sum_and_len is a function to sum noise values per PRB for the whole 5 min interval.
        pandas is imported in runtime, as it is not normally installed on VM,
        you need to install it in preconditions first to use this method
        :csv_file:  Handle to .csv file containing RACH, PUCCH or PUSCH messages
        :file_name: File name
        :transmission_technology: TDD or FDD
        :counter_id_list: list of counters which will be summed
        :msg1_frequency_start: PRACH message position in PRB
        :rach_avg: True if PRACH average power should be calculated in the common average power

        :return: Dictionary with summed value per PRB and number of samples
    """
    import pandas as pd
    output_dict = {}
    prbs_id = counter_id_list
    if "pusch" in file_name or "pucch" in file_name:
        for prb_id in prbs_id:
            col_length = len(csv_file.loc[(csv_file[prb_id] != -140.0) & (pd.notna(csv_file[prb_id])), prb_id])
            total = csv_file.loc[(csv_file[prb_id] != -140.0) & (pd.notna(csv_file[prb_id])), prb_id].sum()
            output_dict.update({prb_id: {'sum': float(total), 'len': col_length}})
    elif "prach" in file_name and rach_avg:
        noise = "noisePower"
        col_length = len(csv_file.loc[(csv_file[noise] != -140.0) & (pd.notna(csv_file[noise])), noise])
        total = float(csv_file.loc[(csv_file[noise] != -140.0) & (pd.notna(csv_file[noise])), noise].sum())
        if transmission_technology == "FDD":
            total = total / 6
            for i in range(len(prbs_id)):
                if msg1FrequencyStart <= i < msg1FrequencyStart + 6:
                    output_dict.update({prbs_id[i]: {'sum': total, 'len': col_length}})
                else:
                    output_dict.update({prbs_id[i]: {'sum': 0.0, 'len': 0, 'max': 0.0}})
        if transmission_technology == "TDD":
            total = total / 12
            for i in range(len(prbs_id)):
                if msg1FrequencyStart <= i < msg1FrequencyStart + 12:
                    output_dict.update({prbs_id[i]: {'sum': total, 'len': col_length}})
                else:
                    output_dict.update({prbs_id[i]: {'sum': 0.0, 'len': 0, 'max': 0.0}})
    return output_dict


def calculate_max(files_list, counters_id_list, transmission_technology, msg1FrequencyStart, rach_avg):
    """ calculate_max is a function to find max value per PRB for the whole 5 min interval.
        pandas and numpy are imported in runtime, as they are not normally installed on VM,
        you need to install them in preconditions first to use this method
        :files_list: .csv file list to search
        :counters_id_list: list of counters names
        :transmission_technology: TDD or FDD
        :msg1_frequency_start: PRACH message position in PRB
        :rach_avg: True if PRACH average power should be calculated in the common average power

        :return: Dictionary with max values per PRB and number of samples
    """
    import pandas as pd
    import numpy as np
    noise_col = "noisePower"
    max_dict = {}
    for counter_id in counters_id_list:
        max_list = []
        for csv_file in files_list:
            if "prach" in csv_file.name and transmission_technology == "TDD" \
                    and msg1FrequencyStart <= counters_id_list.index(counter_id) < msg1FrequencyStart + 12 and rach_avg:
                rach_max = csv_file.loc[(csv_file[noise_col] != -140.0) & (pd.notna(csv_file[noise_col])),
                                        noise_col].max()
                max_list.append(rach_max / 12)
            if "prach" in csv_file.name and transmission_technology == "FDD" \
                    and msg1FrequencyStart <= counters_id_list.index(counter_id) < msg1FrequencyStart + 6 and rach_avg:
                rach_max = csv_file.loc[(csv_file[noise_col] != -140.0) & (pd.notna(csv_file[noise_col])),
                                        noise_col].max()
                max_list.append(rach_max / 6)
            if "pusch" in csv_file.name or "pucch" in csv_file.name:
                max_list.append(csv_file.loc[(csv_file[counter_id] != -140.0) & (pd.notna(csv_file[counter_id])),
                                             counter_id].max())
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", category=RuntimeWarning)
            aW_max = np.nanmax(max_list)
            if aW_max > 0:
                dBm_max = average_in_dBm(aW_max)
            else:
                dBm_max = aW_max
            if pd.isna(dBm_max):
                max_dict.update({counter_id: 0})
            else:
                max_dict.update({counter_id: dBm_max})
    return max_dict


def remove_unused_prbs(file_to_trim, pucch_mode):
    if pucch_mode != "short":
        return file_to_trim
    else:
        print(file_to_trim.shape[1])
        print("shaving")
        if 'noisePerPrb_item_66' in file_to_trim.columns:
            shaved_file = file_to_trim.drop(
                file_to_trim.columns[file_to_trim.columns.get_loc('noisePerPrb_item_66'):], axis=1)
            print(shaved_file.shape[1])
            return shaved_file
        else:
            return file_to_trim


def remove_unnecessary_rows(PUCCH_file, PUSCH_file, max_dict, max_candidate):
    for index, row in max_candidate.iterrows():
        tag = row['tag']
        PUCCH_file.loc[(PUCCH_file['asfn'] == row['asfn']) &
                       (PUCCH_file['sfn'] == row['sfn']) &
                       (PUCCH_file['slot'] == row['slot']) &
                       (PUCCH_file[tag] == row[tag + '_x']), tag] = [max_dict[tag]]
        PUSCH_file.loc[(PUSCH_file['asfn'] == row['asfn']) &
                       (PUSCH_file['sfn'] == row['sfn']) &
                       (PUSCH_file['slot'] == row['slot']) &
                       (PUSCH_file[tag] == row[tag + '_y']), tag] = [max_dict[tag]]

    return PUCCH_file, PUSCH_file


def calculate_avg(list_of_outputs, counter_id_list):
    out_put_dir = {}
    noise_sum = 0
    len_sum = 0

    for counter_id in counter_id_list:
        for i in range(len(list_of_outputs)):
            if bool(list_of_outputs[i]):
                noise_sum += list_of_outputs[i][counter_id]['sum']
                len_sum += list_of_outputs[i][counter_id]['len']
        try:
            avg_result = noise_sum / len_sum
        except ZeroDivisionError:
            out_put_dir.update({counter_id: 0})
            noise_sum = 0
            len_sum = 0
            continue
        if avg_result > 0:
            avg_result = average_in_dBm(avg_result)
        out_put_dir.update({counter_id: avg_result})
        noise_sum = 0
        len_sum = 0
    return out_put_dir


def generate_counters_id_for_biplog(last_counter):
    prefix = "noisePerPrb_item_"
    first_counter = 0
    counter_id_list = []
    for i in range(first_counter, last_counter + 1):
        counter_id_list.append(prefix + str(i))
    return counter_id_list


def save_dict_to_csv(output_dic, result_dir, start_time):
    import pandas as pd
    df = pd.DataFrame.from_dict({(i, j): output_dic[i][j]
                                 for i in output_dic.keys()
                                 for j in output_dic[i].keys()},
                                orient='index')
    mod_time = str(start_time)
    mod_time = str.replace(mod_time, ':', '-')
    mod_time = str.replace(mod_time, ' ', '_')
    out_path = result_dir + "avg_max_result_" + mod_time + ".xlsx"
    df.to_excel(out_path)
    return out_path


def parse_bip_logs(path_to_dir,
                   puch_mode,
                   start_time,
                   end_time,
                   transmission_technology,
                   msg1_frequency_start,
                   rach_avg,
                   result_dir):
    """ parse_bip_logs is a function to transform processed bip log from convert_pcap_to_one_csv.py to human and machine
        readable excel file with avg and max noise values per PRB during 5 minute interval.

        :path_to_dir: Absolute path to processed by convert_pcap_to_one_csv.py directory containing excel files with
                      PRACH, PUCCH, PUSCH messages
        :puch_mode: PUCCH mode (short or long)
        :start_time: start of counter measurement timestamp
        :end_time: end of counter measurement timestamp
        :transmission_technology: TDD or FDD
        :msg1_frequency_start: PRACH message position in PRB
        :rach_avg: True if PRACH average power should be calculated in the common average power
        :result_dir: Absolute path to directory where output should be saved

        :return: Path to excel with calculated avg and max values per PRB for comparison with gNB counters
    """
    import pandas as pd
    msg1_frequency_start = int(msg1_frequency_start)
    outputs_list = []
    opened_files = []
    if puch_mode == 'short':
        counters = 65
    else:
        counters = 272
    counter_id_list = generate_counters_id_for_biplog(counters)
    log_files_name_list = os.listdir(path_to_dir)
    log_files_name_list = [fname for fname in log_files_name_list if "_merged_asfn" in fname]
    for file_name in log_files_name_list:
        csv_file = pd.read_csv(path_to_dir + '/' + file_name, sep=',')
        trimmed_file = trim_messages(csv_file, start_time, end_time, file_name)
        shaved_file = remove_unused_prbs(trimmed_file, puch_mode)
        opened_files.append(shaved_file)
        opened_files[-1].name = file_name
    for trimmed_file in opened_files:
        avg_dict = calculate_prb_sum_and_len(trimmed_file,
                                             trimmed_file.name,
                                             transmission_technology,
                                             counter_id_list,
                                             msg1_frequency_start,
                                             rach_avg)
        outputs_list.append(avg_dict)
    avg_output = calculate_avg(outputs_list, counter_id_list)
    if puch_mode == "short" and len(opened_files) == 3:
        pucch_file = [s for s in opened_files if "pucch" in s.name]
        pusch_file = [s for s in opened_files if "pusch" in s.name]
        max_dict, max_candidate = find_max_for_same_msg(pucch_file[0], pusch_file[0], counter_id_list)
        remove_unnecessary_rows(pucch_file[0], pusch_file[0], max_dict, max_candidate)
    max_output = calculate_max(opened_files, counter_id_list, transmission_technology, msg1_frequency_start, rach_avg)
    avg_and_max_dict = {"avg": avg_output, "max": max_output}
    out_path = save_dict_to_csv(avg_and_max_dict, result_dir, start_time)
    return out_path
