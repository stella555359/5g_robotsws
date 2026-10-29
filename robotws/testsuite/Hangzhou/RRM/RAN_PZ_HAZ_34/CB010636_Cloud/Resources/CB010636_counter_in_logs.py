import csv
import pkgutil
import importlib
import subprocess
import os
import re
import json


def install_package(package):
    try:
        subprocess.call(['pip', 'install', '-U', 'numpy', package])
    except Exception as e:
        raise (AssertionError("Error installing package " + str(e)))


def install_and_import_pandas():
    if not bool(pkgutil.find_loader('pandas')):
        install_package('pandas')
    return importlib.import_module('pandas')


# 5CC
BTS_config = {
    '82': {'cellid': '613400578', 'NRCELL_id': 'NRCELL-2', 'Cell_type': 'FR1_FDD', 'chbw': 10},
    '182': {'cellid': '613400588', 'NRCELL_id': 'NRCELL-12', 'Cell_type': 'FR1_FDD', 'chbw': 20},
    '83': {'cellid': '613400579', 'NRCELL_id': 'NRCELL-3', 'Cell_type': 'FR1_FDD', 'chbw': 20},
    '84': {'cellid': '613400580', 'NRCELL_id': 'NRCELL-4', 'Cell_type': 'FR1_TDD', 'chbw': 60},
    '85': {'cellid': '613400581', 'NRCELL_id': 'NRCELL-5', 'Cell_type': 'FR1_TDD', 'chbw': 100},
    '185': {'cellid': '613400591', 'NRCELL_id': 'NRCELL-15', 'Cell_type': 'FR1_TDD', 'chbw': 100},
    '184': {'cellid': '613400590', 'NRCELL_id': 'NRCELL-14', 'Cell_type': 'FR1_TDD', 'chbw': 60},
    '86': {'cellid': '613400582', 'NRCELL_id': 'NRCELL-6', 'Cell_type': 'FR1_TDD', 'chbw': 60}
}

column_name_list = ['days', 'hours', 'minutes', 'seconds', 'microSeconds',
                    'physCellId', 'sfn', 'slot', 'rnti', 'burstId', 'tbSize',
                    'amountBytes', 'logicalChannelId', 'requestType', 'sduNum', 'mcs']

RLC_merger_id = 0


def counter_into_csv(web_counter_dict, output_file, num=30):
    new_dict = {}
    time_set = set()
    for nrcell, counters in web_counter_dict.items():
        new_dict[nrcell] = new_dict.setdefault(nrcell, {})
        for counter_name, value_list in counters.items():
            new_dict[nrcell][counter_name] = new_dict[nrcell].setdefault(counter_name, {})
            if len(value_list) > num:
                value_list = value_list[-num:]
            for i in range(len(value_list)):
                time = value_list[i]['start_time']
                time_set.add(time)
                value = value_list[i]['value']
                new_dict[nrcell][counter_name][time] = value
    title = sorted(list(time_set), reverse=True)
    title.insert(0, 'Counter')
    title.insert(0, 'NRCELL')
    f = open(output_file, 'w')
    f.write(','.join(title) + '\n')
    for nrcell, counters in new_dict.items():
        line_list = [''] * len(title)
        line_list[0] = nrcell
        for counter_name, value_list in counters.items():
            line_list[1] = counter_name
            for time in sorted(list(time_set)):
                if time in value_list:
                    line_list[title.index(time)] = value_list[time]
            f.write(','.join(line_list) + '\n')
    f.close()
    print(new_dict)


def get_pid(output):
    pid_pattern = r'\d+'
    pids = re.findall(pid_pattern, output)
    return pids


def get_dl_tput_from_syslog(path):
    dl_list = [('Time', 'nrCellId', 'TBS', 'MacCe', 'StatusPdu', 'DataPdu')]
    data_start = False
    with open(path, 'r') as file:
        for line in file:
            match = re.findall(r'<(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d+)Z>[\s\S]+L2Lo[\s\S]+nrCellId (\d+) '
                               r'\[TBS\|MacCe\|StatusPdu\|DataPdu: (\d+)\|(\d+)\|(\d+)\|(\d+)\]', line)
            if match:
                match_result = match[0]
                datapdu = int(match_result[5])
                if datapdu > 0 or data_start:
                    data_start = True
                    dl_list.append(match[0])
                    print(match[0])
                    # print(line)
    if dl_list:
        output_path = os.path.dirname(path) + '/dl_syslog_tput.csv'
        with open(output_path, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerows(dl_list)


def get_ul_tput_from_syslog(path):
    ul_list = [('Time', 'Bytes received', 'rlcPduBytes', 'nrCellIdentity')]
    data_start = False
    with open(path, 'r') as file:
        for line in file:
            match = re.findall(r'<(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d+)Z>[\s\S]+L2Lo[\s\S]'
                               r'+UlCounterUpdate[\s\S]+ (\d+) Bytes received\. \((\d+) '
                               r'rlcPduBytes[\s\S]+nrCellIdentity (\d+)', line)
            if match:
                match_result = match[0]
                byteRecieved = int(match_result[1])
                if byteRecieved > 0 or data_start:
                    data_start = True
                    ul_list.append(match[0])
                    print(match[0])
                    # print(line)
    if ul_list:
        output_path = os.path.dirname(path) + '/ul_syslog_tput.csv'
        with open(output_path, 'w', newline='') as csvfile:
            writer = csv.writer(csvfile)
            writer.writerows(ul_list)


def dict_to_csv(data, output_path):
    if output_path:
        f = open(output_path, 'w')
        title = ['NRCELL', 'Counter', 'WebUI', 'Actual', 'Ratio', 'Diff', 'Result']
        f.write(','.join(title) + '\n')
        for k, v in data.items():
            for k1, v1 in v.items():
                if isinstance(v1, dict):
                    webui = v1['Expected']
                    actual = v1['Actual']
                    ratio = v1['Ratio']
                    diff = v1['Diff']
                    result = v1['Result']
                    f.write(f'{k}, {k1}, {webui}, {actual}, {ratio}, {diff}, {result}\n')
                    print(f'{k}, {ratio}, {k1}, {webui}, {actual}, {diff}, {result}')
                else:
                    f.write(f'{k}, {k1}, {v1}, , , ,\n')
        f.close()


def time_to_json(time_dict, output_file):
    with open(output_file, 'w') as f:
        json.dump(time_dict, f)


def json_to_dict(json_file):
    with open(json_file, 'r') as f:
        data = json.load(f)
    return data


def get_counter_sum_value_after_dedicate_time(before_counter_time, after_counter_dict):
    counter_result = {}
    for cell, data in after_counter_dict.items():
        counter_result[cell] = {}
        for counter_name, value in data.items():
            counter_sum = 0
            if before_counter_time['start_time'] == 'now':
                counter_result[cell][counter_name] = 0
                for i in range(len(value)-1, -1, -1):
                    counter_value = value[i]['value']
                    counter_sum += float(counter_value)
                counter_result[cell][counter_name] = counter_sum
            else:
                for i in range(len(value)-1, -1, -1):
                    start_time = value[i]['start_time']
                    counter_value = value[i]['value']
                    if before_counter_time['start_time'] == start_time:
                        counter_result[cell][counter_name] = counter_sum
                        break
                    else:
                        counter_sum += float(counter_value)
    return counter_result


def get_first_pm_data_tmp(counter_dict):
    result_dict = {}
    row_value_list = []
    for counter_id, value_list in counter_dict.items():
        for i in range(len(value_list)-1, -1, -1):
            value = value_list[i]
            if value != 0:
                row_value_list.append(i)
                break
    if row_value_list:
        choice_index = max(row_value_list)
        for counter_id, value_list in counter_dict.items():
            result_dict[counter_id] = value_list[choice_index]
    else:
        for counter_id, value_list in counter_dict.items():
            result_dict[counter_id] = 0
    return result_dict


def get_rnti_and_ca_info(txt_file_path):
    output_path = os.path.dirname(txt_file_path) + '/cainfo.json'
    with open(txt_file_path, "r") as f:
        lines = f.readlines()
    startLogo = 'Frame '
    lines.append(startLogo)
    i = 0
    waitForStartLine, waitForEndLine = True, False
    ue_ca_info_dict = {}
    rnti_message_num_dict = {}
    message_list = []
    NSA_ue = []
    while (i < len(lines)):
        if lines[i].startswith(startLogo):
            if waitForStartLine:
                startLine = i
                waitForStartLine, waitForEndLine = False, True
                i += 1
                continue
            if waitForEndLine:
                endLine = i
                waitForStartLine, waitForEndLine = True, False
                message_str = ''.join(lines[startLine:endLine])
                message_list.append(message_str.lower())
                startLine = i
                waitForStartLine, waitForEndLine = False, True
        i += 1
    if message_list:
        pcell_pci_re = re.compile(r'spcellconfig\s[\s\S]+?physcellid: (\d+)')
        scell_pci_re = re.compile(r'scellconfig\s[\s\S]+?physcellid: (\d+)')
        rnti_re = re.compile(r'newue-identity: (\d+)')
        ul_scell_pci_re = re.compile(r'physcellid: (\d+)[\s\S]+?uplinkconfigcommon')
        for message in message_list:
            pcell_pci_list = pcell_pci_re.findall(message, re.IGNORECASE)
            scell_pci_list = scell_pci_re.findall(message, re.IGNORECASE)
            rnti_list = rnti_re.findall(message, re.IGNORECASE)
            ul_scell_pci_list = ul_scell_pci_re.findall(message, re.IGNORECASE)
            if rnti_list and pcell_pci_list:
                if 'sgnbadditionrequestacknowledge' in message:
                    NSA_ue.append(rnti_list[0])
                rnti = rnti_list[0]
                pcell_pci = int(pcell_pci_list[0])
                ue_ca_info_dict[rnti] = {'pcell': pcell_pci,
                                         'dl_scell': [],
                                         'ul_scell': [],
                                         'nsa_or_sa': '',
                                         'DL_CA_UE': '',
                                         'UL_CA_UE': ''}
                rnti_message_num_dict[rnti] = rnti_message_num_dict.get(rnti, 0) + 1
                for scell_pci in scell_pci_list:
                    if scell_pci not in ue_ca_info_dict[rnti]['dl_scell']:
                        ue_ca_info_dict[rnti]['dl_scell'].append(int(scell_pci))
                if len(ul_scell_pci_list) > 0:
                    del (ul_scell_pci_list[0])
                for scell_pci in ul_scell_pci_list:
                    if scell_pci not in ue_ca_info_dict[rnti]['ul_scell']:
                        ue_ca_info_dict[rnti]['ul_scell'].append(int(scell_pci))
        if ue_ca_info_dict and rnti_message_num_dict:
            for rnti, cainfo_dcit in ue_ca_info_dict.items():
                cainfo_dcit['nsa_or_sa'] = 'NSA' if rnti_message_num_dict[rnti] == 1 else 'SA'
                if rnti in NSA_ue:
                    cainfo_dcit['nsa_or_sa'] = 'NSA'
                else:
                    cainfo_dcit['nsa_or_sa'] = 'SA'
                cainfo_dcit['DL_CA_UE'] = True if len(cainfo_dcit['dl_scell']) > 0 else False
                cainfo_dcit['UL_CA_UE'] = True if len(cainfo_dcit['ul_scell']) > 0 else False
    time_to_json(ue_ca_info_dict, output_path)
    return ue_ca_info_dict


def get_sfn_cycle_times(df_burst_without_last):
    if not df_burst_without_last.empty:
        df_1023 = df_burst_without_last[(df_burst_without_last['sfn'] == 1023)]
        slot_list = list(df_1023["slot"].tolist())
        sfn_cycle_times = 0
        if len(df_1023) > 0 and len(df_1023) != len(df_burst_without_last):
            sfn_cycle_times = 1
            for i, slot in enumerate(slot_list):
                if slot < slot_list[i-1] and i != 0:
                    sfn_cycle_times += 1
            if df_burst_without_last.iloc[-1]['sfn'] == 1023:
                sfn_cycle_times = sfn_cycle_times - 1
        if (df_burst_without_last.iloc[-1]['sfn'] < df_burst_without_last.iloc[0]['sfn'] and sfn_cycle_times == 0):
            sfn_list = sorted(list(set(df_burst_without_last['sfn'].tolist())))
            df_sfn_max = df_burst_without_last[(df_burst_without_last['sfn'] == sfn_list[-1])]
            slot_list = list(df_sfn_max["slot"].tolist())
            sfn_cycle_times = 1
            for i, slot in enumerate(slot_list):
                if slot < slot_list[i-1] and i != 0:
                    sfn_cycle_times += 1
    else:
        sfn_cycle_times = 0
    return sfn_cycle_times


def is_CA_UE(df, rnti):
    CA_UE = False
    df_rnti = df[(df['rnti'] == rnti)]
    physCellId_list = list(set(df_rnti['physCellId'].tolist()))
    if len(physCellId_list) > 1:
        CA_UE = True
    return CA_UE


def get_CA_set_FR1(df_ca_rnti, mypath):
    pd = install_and_import_pandas()
    physCellId_list = list(set(df_ca_rnti['physCellId'].tolist()))
    df_burst_all_cell = pd.DataFrame()
    for i_physCellId in physCellId_list:
        df_physCellId = df_ca_rnti[(df_ca_rnti['physCellId'] == i_physCellId)]
        cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
        for i_burst in cell_burst_list:
            df_cell_burst = df_physCellId[(df_physCellId['burstId'] == i_burst)]
            begin_line = df_cell_burst.index[0]
            end_line = df_cell_burst.index[-1]
            new_data = {'physCellId': i_physCellId, 'burstId': i_burst,
                        'begin_line': begin_line, 'end_line': end_line}
            new_df = pd.DataFrame(new_data, index=[len(df_burst_all_cell)])
            df_burst_all_cell = pd.concat([df_burst_all_cell, new_df])
    df_burst_all_cell.columns = ['physCellId', 'burstId', 'begin_line', 'end_line']
    df_burst_all_cell.sort_values(["begin_line"], inplace=True, ascending=True)
    df_burst_all_cell = df_burst_all_cell.reset_index(drop=True)
    df_burst_all_cell.to_csv(f'{mypath}df_burst_all_cell.csv')
    set_list = []
    set_burst_dic_list = []
    for index, row in df_burst_all_cell.iterrows():
        # print(f'index:{index}, ')
        df_data = df_ca_rnti[(df_ca_rnti['physCellId'] == row['physCellId']) &
                             (df_ca_rnti['burstId'] == row['burstId'])]
        if index == 0:
            set_burst_dic = {}
            start_line = row['begin_line']
            end_line = row['end_line']
            df_ca_set = df_data
        elif index == len(df_burst_all_cell)-1:
            df_ca_set = pd.concat([df_ca_set, df_data])
            set_list.append(df_ca_set.sort_index())
            for i_physCellId in physCellId_list:
                df_physCellId = df_ca_set[(df_ca_set['physCellId'] == i_physCellId)]
                cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
                set_burst_dic[i_physCellId] = cell_burst_list
            set_burst_dic_list.append(set_burst_dic)
        else:
            if (row['begin_line'] < start_line and start_line < row['end_line'] < end_line):
                start_line = row['begin_line']
                df_ca_set = pd.concat([df_ca_set, df_data])
            elif row['begin_line'] >= start_line and row['end_line'] <= end_line:
                df_ca_set = pd.concat([df_ca_set, df_data])
            elif row['begin_line'] < end_line and row['end_line'] > end_line:
                end_line = row['end_line']
                df_ca_set = pd.concat([df_ca_set, df_data])
            else:
                set_list.append(df_ca_set.sort_index())
                for i_physCellId in physCellId_list:
                    df_physCellId = df_ca_set[(df_ca_set['physCellId'] == i_physCellId)]
                    cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
                    set_burst_dic[i_physCellId] = cell_burst_list
                # print(set_burst_dic)
                # print(f'start_line: {start_line}, end_line:{end_line}')
                set_burst_dic_list.append(set_burst_dic)
                start_line = row['begin_line']
                end_line = row['end_line']
                df_ca_set = df_data
                set_burst_dic = {}
    return set_list, set_burst_dic_list


def get_CA_set_FR1_2(df_ca_rnti, mypath):
    global RLC_merger_id
    pd = install_and_import_pandas()
    physCellId_list = list(set(df_ca_rnti['physCellId'].tolist()))
    df_burst_all_cell = pd.DataFrame()
    for i_physCellId in physCellId_list:
        df_physCellId = df_ca_rnti[(df_ca_rnti['physCellId'] == i_physCellId)]
        cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
        for i_burst in cell_burst_list:
            df_cell_burst = df_physCellId[(df_physCellId['burstId'] == i_burst)]
            begin_line = df_cell_burst.index[0]
            end_line = df_cell_burst.index[-1]
            new_data = {'physCellId': i_physCellId, 'burstId': i_burst,
                        'begin_line': begin_line, 'end_line': end_line}
            new_df = pd.DataFrame(new_data, index=[len(df_burst_all_cell)])
            df_burst_all_cell = pd.concat([df_burst_all_cell, new_df])
    df_burst_all_cell.columns = ['physCellId', 'burstId', 'begin_line', 'end_line']
    df_burst_all_cell.sort_values(["begin_line"], inplace=True, ascending=True)
    df_burst_all_cell = df_burst_all_cell.reset_index(drop=True)
    df_burst_all_cell.to_csv(f'{mypath}df_burst_all_cell.csv')
    set_list = []
    set_burst_dic_list = []
    # merger_id = 0
    for index, row in df_burst_all_cell.iterrows():
        df_data = df_ca_rnti[(df_ca_rnti['physCellId'] == row['physCellId']) &
                             (df_ca_rnti['burstId'] == row['burstId'])]
        if index == 0:
            set_burst_dic = {}
            start_line = row['begin_line']
            end_line = row['end_line']
            df_ca_set = df_data
        elif index == len(df_burst_all_cell) - 1:
            df_ca_set = pd.concat([df_ca_set, df_data])
            df_ca_set = df_ca_set.copy()
            df_ca_set['merged_id'] = [RLC_merger_id] * len(df_ca_set)
            RLC_merger_id += 1
            set_list.append(df_ca_set.sort_index())
            for i_physCellId in physCellId_list:
                df_physCellId = df_ca_set[(df_ca_set['physCellId'] == i_physCellId)]
                cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
                set_burst_dic[i_physCellId] = cell_burst_list

            set_burst_dic_list.append(set_burst_dic)
        else:
            if (row['begin_line'] < start_line and start_line < row['end_line'] < end_line):
                start_line = row['begin_line']
                df_ca_set = pd.concat([df_ca_set, df_data])
            elif row['begin_line'] >= start_line and row['end_line'] <= end_line:
                df_ca_set = pd.concat([df_ca_set, df_data])
            elif row['begin_line'] < end_line and row['end_line'] > end_line:
                end_line = row['end_line']
                df_ca_set = pd.concat([df_ca_set, df_data])
            else:
                df_ca_set = df_ca_set.copy()
                df_ca_set['merged_id'] = [RLC_merger_id] * len(df_ca_set)
                RLC_merger_id += 1
                set_list.append(df_ca_set.sort_index())
                for i_physCellId in physCellId_list:
                    df_physCellId = df_ca_set[(df_ca_set['physCellId'] == i_physCellId)]
                    cell_burst_list = sorted(list(set(df_physCellId["burstId"].tolist())))
                    set_burst_dic[i_physCellId] = cell_burst_list
                set_burst_dic_list.append(set_burst_dic)
                start_line = row['begin_line']
                end_line = row['end_line']
                df_ca_set = df_data
                set_burst_dic = {}
    return set_list, set_burst_dic_list


def get_amountBytes_and_time_per_burst2(df_burst_without_last, cell_type,
                                        volThresDiscardDlMacSdu=None, durationThresDiscardDlMacSdu=None):
    amountBytes = 0
    duration = 0
    if not df_burst_without_last.empty:
        if cell_type == 'FR1_FDD':
            if len(df_burst_without_last) == 1:
                duration = 1
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                    df_burst_without_last.iloc[-1]['slot'] + 1) -\
                    (df_burst_without_last.iloc[0]['sfn'] * 10 + df_burst_without_last.iloc[0]['slot'])
        elif cell_type == 'FR1_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1 / 2
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                    (df_burst_without_last.iloc[-1]['slot'] + 1) / 2) -\
                    (df_burst_without_last.iloc[0]['sfn'] * 10 + df_burst_without_last.iloc[0]['slot'] / 2)
        elif cell_type == 'FR2_TDD':
            if len(df_burst_without_last) == 1:
                duration = 1 / 8
            else:
                sfn_cycle_times = get_sfn_cycle_times(df_burst_without_last)
                duration = (
                    df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +
                    (df_burst_without_last.iloc[-1]['slot'] + 1) / 8) -\
                    (df_burst_without_last.iloc[0]['sfn'] * 10 + df_burst_without_last.iloc[0]['slot'] / 8)
        df_burst_without_last = df_burst_without_last.copy()
        df_burst_without_last['padding'] = df_burst_without_last['tbSize'] - df_burst_without_last['amountBytes']
        padding_sdu_num = (df_burst_without_last['padding'] != 0).sum()
        amountBytes = (df_burst_without_last['amountBytes'].sum()
                       - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) * 8 / 1000
        amount_kB = (df_burst_without_last['amountBytes'].sum()
                     - 2.9 * (df_burst_without_last['sduNum'].sum() - padding_sdu_num)) / 1000
        if (volThresDiscardDlMacSdu is not None) and (durationThresDiscardDlMacSdu is not None):
            if (amount_kB < volThresDiscardDlMacSdu) or (duration < durationThresDiscardDlMacSdu):
                amountBytes = 0
                duration = 0
    return amountBytes, duration


def get_amountBytes_and_time_per_burst(df_burst_without_last):
    amountBytes = 0
    duration = 0
    if not df_burst_without_last.empty:
        df_burst_without_last = df_burst_without_last.copy()
        amountBytes = df_burst_without_last['sdu_vol'].sum()
        duration = df_burst_without_last.iloc[-1]['time'] - df_burst_without_last.iloc[0]['time']
    return amountBytes, duration


def get_time_per_burst_for_RLC(df_burst_without_last, sfn_cycle_times):
    duration = 0
    pci_start = df_burst_without_last.iloc[0]['physCellId']
    pci_end = df_burst_without_last.iloc[-1]['physCellId']
    start_pci_cell_type = BTS_config[str(pci_start)]['Cell_type']
    end_pci_cell_type = BTS_config[str(pci_end)]['Cell_type']
    if len(df_burst_without_last) == 1:
        if start_pci_cell_type == 'FR1_FDD':
            duration = 1
        elif start_pci_cell_type == 'FR1_TDD':
            duration = 1 / 2
    else:
        if start_pci_cell_type == 'FR1_FDD':
            first_line_time = df_burst_without_last.iloc[0]['sfn'] * 10 + df_burst_without_last.iloc[0]['slot']
        elif start_pci_cell_type == 'FR1_TDD':
            first_line_time = df_burst_without_last.iloc[0]['sfn'] * 10 + df_burst_without_last.iloc[0]['slot'] / 2

        if end_pci_cell_type == 'FR1_FDD':
            last_line_time = df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +\
                                df_burst_without_last.iloc[-1]['slot'] + 1
        elif end_pci_cell_type == 'FR1_TDD':
            last_line_time = df_burst_without_last.iloc[-1]['sfn'] * 10 + 1023 * 10 * sfn_cycle_times +\
                                (df_burst_without_last.iloc[-1]['slot'] + 1) / 2
        duration = last_line_time - first_line_time
    return duration


def calculate_cc_data(df_data, time_range_list):
    time_list = df_data["time"].tolist()
    cc_label_list = []
    for time in time_list:
        cc_label = []
        for index, time_range in enumerate(time_range_list):
            time_start, time_end = time_range[0], time_range[1]
            if time >= time_start and time <= time_end:
                cc_label.append(index)
        cc_label_list.append(len(cc_label))
    return cc_label_list


def deal_time(df_data):
    pci_list = df_data['physCellId'].tolist()
    time_list = df_data["time"].tolist()
    for i in range(len(time_list)):
        pci = pci_list[i]
        time = time_list[i]
        cell_type = BTS_config[str(pci)]['Cell_type']
        if cell_type == 'FR1_TDD':
            time = float(str(time)[:-2])
        elif cell_type == 'FR1_FDD':
            time = int(time) + 0.0
        time_list[i] = time
    return time_list


def deal_time_per_slot(df_data):
    pci_list = df_data['physCellId'].tolist()
    time_per_slot_list = [0] * len(pci_list)
    for i in range(len(pci_list)):
        pci = pci_list[i]
        cell_type = BTS_config[str(pci)]['Cell_type']
        if cell_type == 'FR1_TDD':
            time_per_slot_list[i] = 0.5
        elif cell_type == 'FR1_FDD':
            time_per_slot_list[i] = 1
    return time_per_slot_list


def get_merge_data_vol_and_duration_per_cc(merged_df_data):
    cc_list = merged_df_data["cc"].tolist()
    vol_list = merged_df_data["sdu_vol"].tolist()
    time_list = merged_df_data["time"].tolist()
    # pci_list = merged_df_data["physCellId"].tolist()
    time_per_slot_list = merged_df_data["per_slot"].tolist()
    result_dict = {}
    if cc_list:
        start_cc = cc_list[0]
        first_time_slot = time_per_slot_list[0]
        wait_for_end = True
        if len(cc_list) == 1:
            result_dict[start_cc] = result_dict.setdefault(start_cc, {'duration': 0, 'vol': 0})
            result_dict[start_cc]['duration'] = time_per_slot_list[0]
            result_dict[start_cc]['vol'] = vol_list[0]
        else:
            startLine = 0
            i = 1
            while (i < len(cc_list)):
                current_cc = cc_list[i]
                if wait_for_end and current_cc != start_cc:
                    endLine = i - 1
                    result_dict[start_cc] = result_dict.setdefault(start_cc, {'duration': 0, 'vol': 0})
                    result_dict[start_cc]['duration'] = \
                        (result_dict[start_cc]['duration'] + time_list[endLine] - time_list[startLine]
                         + first_time_slot)
                    result_dict[start_cc]['vol'] = \
                        (result_dict[start_cc]['vol'] + sum([vol_list[x] for x in range(startLine, endLine + 1)]))
                    startLine = i
                    wait_for_end = True
                    start_cc = cc_list[startLine]
                    first_time_slot = time_per_slot_list[startLine]
                if wait_for_end and i == len(cc_list) - 1:
                    result_dict[start_cc] = result_dict.setdefault(start_cc, {'duration': 0, 'vol': 0})
                    result_dict[start_cc]['duration'] = \
                        (result_dict[start_cc]['duration'] + time_list[i] - time_list[startLine] + first_time_slot)
                    result_dict[start_cc]['vol'] = \
                        (result_dict[start_cc]['vol'] + sum([vol_list[x] for x in range(startLine, i + 1)]))
                i += 1
    return result_dict


def get_time_range_per_merge_burst(df_rnti, merge_id_list):
    time_range_list = []
    for merge_id in merge_id_list:
        df_merge = df_rnti[(df_rnti['merged_id'] == merge_id)][:-1]
        pci_list = list(set(df_merge["physCellId"].tolist()))
        for pci in pci_list:
            df_pci = df_merge[(df_merge['physCellId'] == pci)]
            burst_list = list(set(df_pci["burstId"].tolist()))
            for burst in burst_list:
                df_burst = df_pci[(df_pci['burstId'] == burst)]
                start_time = df_burst.iloc[0]['time']
                end_time = df_burst.iloc[-1]['time']
                first_pci = df_burst.iloc[0]['physCellId']
                cell_type = BTS_config[str(first_pci)]['Cell_type']
                if cell_type == 'FR1_TDD':
                    first_time_slot = 0.5
                elif cell_type == 'FR1_FDD':
                    first_time_slot = 1
                duration = end_time - start_time + first_time_slot
                time_range_list.append((start_time, end_time, merge_id, pci, duration, burst))
                # print((start_time, end_time, merge_id, pci, duration, burst))
    return time_range_list


def compare_percc_counter_with_legacy(web_counter_dict, dlul='ul', nsa_ul_cell=None, burst_id_length=0):
    PerCC_DL_TIME_counter_list = ['DL_RLC_TIM_UE_TPUT_FR1_NSA_1CC', 'DL_RLC_TIM_UE_TPUT_FR1_NSA_2CC',
                                  'DL_RLC_TIM_UE_TPUT_FR1_SA_1CC', 'DL_RLC_TIM_UE_TPUT_FR1_SA_2CC',
                                  'DL_RLC_TIM_UE_TPUT_FR1_SA_3CC', 'DL_RLC_TIM_UE_TPUT_FR1_SA_4CC',
                                  'DL_RLC_TIM_UE_TPUT_FR1_SA_5CC']
    PerCC_DL_VOL_counter_list = ['DL_RLC_VOL_UE_TPUT_FR1_NSA_1CC', 'DL_RLC_VOL_UE_TPUT_FR1_NSA_2CC',
                                 'DL_RLC_VOL_UE_TPUT_FR1_SA_1CC', 'DL_RLC_VOL_UE_TPUT_FR1_SA_2CC',
                                 'DL_RLC_VOL_UE_TPUT_FR1_SA_3CC', 'DL_RLC_VOL_UE_TPUT_FR1_SA_4CC',
                                 'DL_RLC_VOL_UE_TPUT_FR1_SA_5CC']
    PerCC_UL_TIME_counter_list = ['UL_RLC_TIME_UE_TPUT_FR1_SA_1CC', 'UL_RLC_TIME_UE_TPUT_FR1_SA_2CC']
    PerCC_UL_VOL_counter_list = ['UL_RLC_VOL_UE_TPUT_FR1_SA_1CC', 'UL_RLC_VOL_UE_TPUT_FR1_SA_2CC']

    if dlul == 'dl':
        PerCC_TIME_counter_list = PerCC_DL_TIME_counter_list
        PerCC_VOL_counter_list = PerCC_DL_VOL_counter_list
        Total_VOL_counter = 'DL_RLC_PDU_VOL_UE_TPUT'
        Total_TIM_counter = 'DL_RLC_PDU_TIME_UE_TPUT'
    if dlul == 'ul':
        PerCC_TIME_counter_list = PerCC_UL_TIME_counter_list
        PerCC_VOL_counter_list = PerCC_UL_VOL_counter_list
        Total_VOL_counter = 'UL_RLC_VOL_UE_TPUT_TOT'
        Total_TIM_counter = 'UL_RLC_TIME_UE_TPUT'

    check_result = True
    for nrcell, values in web_counter_dict.items():
        if dlul == 'dl' or (dlul == 'ul' and nsa_ul_cell != nrcell):
            if isinstance(values, dict):
                total_time = values[Total_TIM_counter]
                total_vol = values[Total_VOL_counter]
                sum_time = sum([values[x] for x in PerCC_TIME_counter_list])
                sum_vol = sum([values[x] for x in PerCC_VOL_counter_list])
                if total_vol != 0:
                    vol_ratio = sum_vol / total_vol
                else:
                    vol_ratio = 1 if sum_vol == 0 else 0
                if total_time != 0:
                    time_ratio = sum_time / total_time
                else:
                    time_ratio = 1 if sum_time == 0 else 0
                # There will not check time counter due to PR775644 if burst length>24
                time_tmp_result, vol_tmp_result = True, True
                if int(burst_id_length) > 24:
                    time_ratio = 1
                if 0.98 < time_ratio < 1.02:
                    time_tmp_result = True
                else:
                    time_tmp_result = False
                if 0.98 < vol_ratio < 1.02:
                    vol_tmp_result = True
                else:
                    vol_tmp_result = False
                tmp_result = time_tmp_result and vol_tmp_result
        else:
            tmp_result = True
            time_ratio = 1
            vol_ratio = 1
        print(f'{nrcell}, time_ratio:{time_ratio}, vol_ratio:{vol_ratio}, result:{tmp_result}')
        check_result = check_result and tmp_result
    return check_result


def Calculate_average_max_min(input_list):
    sum_value = 0
    if len(input_list) == 0:
        input_list = [0]
    for j in input_list:
        sum_value = sum_value + float(j)
    average_value = sum_value/len(input_list)
    max_vlaue = max(input_list)
    min_value = min(input_list)
    value_list = [average_value, max_vlaue, min_value, len(input_list)]
    return value_list


def Get_UE_TP_Bler_From_spark_log(file_path, row_list):
    DL_tp = []
    DL_bler = []
    with open(file_path, 'r', encoding='gbk') as csvfile:
        data = csv.DictReader(csvfile)
        for row in data:
            DL_tp.append(row[row_list[0]])
            DL_bler.append(row[row_list[1]])
    DL_tp_list_tmp = [i for i in DL_tp if i != '']
    DL_bler_list_tmp = [i for i in DL_bler if i != '']
    index_list = [i for i in range(0, len(DL_tp_list_tmp)) if float(DL_tp_list_tmp[i]) > 1100]
    cover_DL_tp_list = [float(DL_tp_list_tmp[i]) for i in index_list]
    cover_DL_bler_list = [float(DL_bler_list_tmp[i]) for i in index_list]
    message_dict = {
        'DL_tp': Calculate_average_max_min(cover_DL_tp_list),
        'DL_bler': Calculate_average_max_min(cover_DL_bler_list)}
    print(message_dict)
    DL_avg_tp = message_dict['DL_tp'][0]
    DL_avg_bler = message_dict['DL_bler'][0]
    return DL_avg_tp, DL_avg_bler


class DealCounter():
    def __init__(self):
        pass

    def setCsvPath(self, csv_path):
        pd = install_and_import_pandas()
        self.df_data = pd.read_csv(csv_path, low_memory=False)
        init_csv_name = os.path.basename(csv_path)
        self.csv_name = init_csv_name.split('_')[-1]
        self.getValidData()

    def getValidData(self):
        pd = install_and_import_pandas()
        if self.csv_name == 'MacSubPduRxAm18.csv' or self.csv_name == 'MacSubPduTxAm18.csv':
            df = self.df_data[['physCellId', 'rnti', 'lcId', 'rlcAmDc', 'macLength']]
            self.df_data = df[df['rlcAmDc'] == 'DATA']
        elif self.csv_name == 'MacPduMuxReq.csv':
            df_col_all = self.df_data.loc[:, column_name_list]
            self.df_data = df_col_all[(df_col_all['requestType'] == 'EBUILDREQUEST') & (df_col_all['sduNum'] > 1)
                                      & (df_col_all['burstId'] != 65535) & df_col_all['burstId'].notnull()]
        self.new_data = pd.DataFrame()
        pci_list = list(set(self.df_data["physCellId"].tolist()))
        self.new_data['physCellId'] = pci_list
        self.new_data['NRCELL'] = [BTS_config[str(x)]['NRCELL_id'] for x in pci_list]
        self.burst_length = 0

    def getMacSubPduAm18_dl(self, merge_data):
        # merge_data.to_csv('output.csv')
        self.new_data = merge_data.copy()
        self.new_data = self.new_data.groupby(['physCellId', 'NRCELL'])['macLength'].sum()
        self.new_data = self.new_data.reset_index()
        del (self.new_data['macLength'])

        # #RLC_PDU_VOL_TX_PRI_SA_CA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='SA',
                        ca='YES',
                        counter='RLC_PDU_VOL_TX_PRI_SA_CA')

        # #RLC_PDU_VOL_TX_SCELL_SA_CA
        self.filterData(df_data=merge_data,
                        isPcell='scell',
                        nsa_sa='SA',
                        ca='YES',
                        counter='RLC_PDU_VOL_TX_SCELL_SA_CA')

        # #RLC_PDU_VOL_TX_PRI_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='NSA',
                        ca='YES',
                        counter='RLC_PDU_VOL_TX_PRI_NSA_CA')

        # #RLC_PDU_VOL_TX_SCELL_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='scell',
                        nsa_sa='NSA',
                        ca='YES',
                        counter='RLC_PDU_VOL_TX_SCELL_NSA_CA')

        # RLC_PDU_VOL_TX_NON_CA_SA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='SA',
                        ca='NO',
                        counter='RLC_PDU_VOL_TX_NON_CA_SA')

        # RLC_PDU_VOL_TX_NON_CA_NSA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='NSA',
                        ca='NO',
                        counter='RLC_PDU_VOL_TX_NON_CA_NSA')

        # NR_RLC_PDU_DL_VOL_CA_PCELL   CA and NSA PCELL   RLC_PDU_VOL_TX_PRI_SA_CA+RLC_PDU_VOL_TX_PRI_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='NSAandSA',
                        ca='YES',
                        counter='NR_RLC_PDU_DL_VOL_CA_PCELL')

        # NR_RLC_PDU_DL_VOL_CA_SCELL   CA and NSA SCELL   RLC_PDU_VOL_TX_SCELL_SA_CA+RLC_PDU_VOL_TX_SCELL_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='scell',
                        nsa_sa='NSAandSA',
                        ca='YES',
                        counter='NR_RLC_PDU_DL_VOL_CA_SCELL')
        # print(self.new_data)
        # self.new_data.to_csv('output.csv', index=False)

    def getMacSubPduAm18_ul(self, merge_data):
        self.new_data = merge_data.copy()
        self.new_data = self.new_data.groupby(['physCellId', 'NRCELL'])['macLength'].sum()
        self.new_data = self.new_data.reset_index()
        del (self.new_data['macLength'])

        # #RLC_PDU_VOL_RX_PRI_SA_CA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='SA',
                        ca='YES',
                        counter='RLC_PDU_VOL_RX_PRI_SA_CA',
                        dlul='ul')

        # #RLC_PDU_VOL_RX_SCELL_SA_CA
        self.filterData(df_data=merge_data,
                        isPcell='scell',
                        nsa_sa='SA',
                        ca='YES',
                        counter='RLC_PDU_VOL_RX_SCELL_SA_CA',
                        dlul='ul')

        # #RLC_PDU_VOL_RX_PRI_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='NSA',
                        ca='YES',
                        counter='RLC_PDU_VOL_RX_PRI_NSA_CA',
                        dlul='ul')

        # #RLC_PDU_VOL_RX_SCELL_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='scell',
                        nsa_sa='NSA',
                        ca='YES',
                        counter='RLC_PDU_VOL_RX_SCELL_NSA_CA',
                        dlul='ul')

        # RLC_PDU_VOL_RX_NON_CA_SA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='SA',
                        ca='NO',
                        counter='RLC_PDU_VOL_RX_NON_CA_SA',
                        dlul='ul')

        # RLC_PDU_VOL_RX_NON_CA_NSA
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='NSA',
                        ca='NO',
                        counter='RLC_PDU_VOL_RX_NON_CA_NSA',
                        dlul='ul')

        # UL_RLC_PDU_VOL_RX_PRI_PATH   CA and NSA PCELL
        self.filterData(df_data=merge_data,
                        isPcell='pcell',
                        nsa_sa='NSAandSA',
                        ca='YES',
                        counter='UL_RLC_PDU_VOL_RX_PRI_PATH',
                        dlul='ul')

        # UL_RLC_PDU_VOL_RX_SEC_PATH   CA and NSA SCELL   RLC_PDU_VOL_RX_SCELL_SA_CA+RLC_PDU_VOL_RX_SCELL_NSA_CA
        self.filterData(df_data=merge_data,
                        isPcell='scell',
                        nsa_sa='NSAandSA',
                        ca='YES',
                        counter='UL_RLC_PDU_VOL_RX_SEC_PATH',
                        dlul='ul')
        # print(self.new_data)

    def getScellTotalVol(self, merge_data, sansa='SA', dlul='dl'):
        # RLC_PDU_VOL_TX_SEC_SA_CA_FR1
        # RLC_PDU_VOL_TX_SEC_NSA_CA_FR1
        # RLC_PDU_VOL_RX_SEC_SA_CA_FR1
        everyCellTotalVolList = []
        scell_list = 'dl_scell_list' if dlul == 'dl' else 'ul_scell_list'
        ca = 'dl_ca' if dlul == 'dl' else 'ul_ca'
        for index, row_data in merge_data.iterrows():
            if row_data[scell_list]:
                rnti = row_data['rnti']
                pcell = merge_data[(merge_data['rnti'] == rnti) & (merge_data['isPcell'] == 'pcell')]['physCellId']
                pcell_pci = pcell.tolist()[0]
                df_data = merge_data[(merge_data['rnti'] == rnti) &
                                     (merge_data['isPcell'] == 'scell') &
                                     (merge_data[ca] == 'YES') &
                                     (merge_data['nsa_sa'] == sansa)]
                totalVol = df_data['macLength'].sum()
                isExists = False
                for ev in everyCellTotalVolList:
                    if pcell_pci == ev['pci'] and sansa == ev['sansa']:
                        ev['vol'] = totalVol + ev['vol']
                        isExists = True
                        break
                if not isExists:
                    everyCellTotalVolList.append({'pci': pcell_pci, 'sansa': sansa, 'vol': totalVol, 'dlul': dlul})

        pci_list = self.new_data['physCellId'].tolist()
        column = self.new_data.columns.tolist()
        # Add new column and set default value as 0
        if dlul == 'dl':
            if 'RLC_PDU_VOL_TX_SEC_SA_CA_FR1' not in column:
                self.new_data['RLC_PDU_VOL_TX_SEC_SA_CA_FR1'] = [0] * len(pci_list)
                self.new_data['RLC_PDU_VOL_TX_SEC_NSA_CA_FR1'] = [0] * len(pci_list)
        else:
            if 'RLC_PDU_VOL_RX_SEC_SA_CA_FR1' not in column:
                self.new_data['RLC_PDU_VOL_RX_SEC_SA_CA_FR1'] = [0] * len(pci_list)

        for ev in everyCellTotalVolList:
            pci, sansa, vol, dlul = ev['pci'], ev['sansa'], ev['vol'], ev['dlul']
            print(pci, sansa, vol, dlul)
            if dlul == 'dl' and sansa == 'SA':
                counter_name = 'RLC_PDU_VOL_TX_SEC_SA_CA_FR1'
            if dlul == 'dl' and sansa == 'NSA':
                counter_name = 'RLC_PDU_VOL_TX_SEC_NSA_CA_FR1'
            if dlul == 'ul' and sansa == 'SA':
                counter_name = 'RLC_PDU_VOL_RX_SEC_SA_CA_FR1'
            cur_data = self.new_data[counter_name].tolist()
            for p_index, p in enumerate(pci_list):
                if pci == pci_list[p_index] and cur_data[p_index] == 0:
                    cur_data[p_index] = vol
            self.new_data[counter_name] = cur_data

    def getMacSubPduAm18(self, caInfo=None, channelInfo={100: 'NonCA'}, isDefaultCA=True):
        pd = install_and_import_pandas()
        self.getValidData()
        df1 = self.df_data
        # Not FR1 CA eligible
        # channelInfo = {'7': 'NonCA'}
        channel_id_list = list(set(df1['lcId'].tolist()))
        print('channel_id_list:', channel_id_list)
        df1['rnti'] = df1['rnti'].astype(str)
        for channel in channel_id_list:
            if not isDefaultCA:
                df1.loc[df1['lcId'] == channel, 'rnti'] = [str(i) + '_NonCA' for i in
                                                           df1.loc[df1['lcId'] == channel, 'rnti']]
                non_ca_rnti_list = list(set(df1.loc[df1['lcId'] == channel, 'rnti'].tolist()))
                print('non_ca_rnti_list, ', non_ca_rnti_list)
                for rnti in non_ca_rnti_list:
                    origen_rnti = rnti.replace('_NonCA', '')
                    caInfo[rnti] = {'pcell': caInfo[origen_rnti]['pcell'],
                                    'dl_scell': [],
                                    'ul_scell': [],
                                    'nsa_or_sa': caInfo[origen_rnti]['nsa_or_sa'],
                                    'DL_CA_UE': False,
                                    'UL_CA_UE': False}
                print(caInfo)
        ue_data_list = []
        for rnti, cainfo in caInfo.items():
            everUeData = df1[df1['rnti'] == rnti].groupby(['physCellId', 'rlcAmDc'])['macLength'].sum()
            everUeData = everUeData.reset_index()
            pci_list = everUeData['physCellId'].tolist()
            everUeData['rnti'] = [rnti] * len(pci_list)
            everUeData['isPcell'] = ['pcell' if p == caInfo[rnti]['pcell'] else 'scell' for p in pci_list]
            everUeData['dl_ca'] = ['YES' if caInfo[rnti]['DL_CA_UE'] else 'NO'] * len(pci_list)
            everUeData['ul_ca'] = ['YES' if caInfo[rnti]['UL_CA_UE'] else 'NO'] * len(pci_list)
            everUeData['nsa_sa'] = [caInfo[rnti]['nsa_or_sa']] * len(pci_list)
            everUeData['dl_scell_list'] = [caInfo[rnti]['dl_scell'] if p == caInfo[rnti]['pcell']
                                           else [] for p in pci_list]
            everUeData['ul_scell_list'] = [caInfo[rnti]['ul_scell'] if p == caInfo[rnti]['pcell']
                                           else [] for p in pci_list]
            everUeData['NRCELL'] = [BTS_config[str(p)]['NRCELL_id'] for p in pci_list]
            ue_data_list.append(everUeData)
        merge_data = pd.concat(ue_data_list, axis=0)
        print('merge_data:\n', merge_data)

        if self.csv_name == 'MacSubPduTxAm18.csv':
            self.getMacSubPduAm18_dl(merge_data)
            self.getScellTotalVol(sansa='SA', merge_data=merge_data, dlul='dl')
            self.getScellTotalVol(sansa='NSA', merge_data=merge_data, dlul='dl')
        elif self.csv_name == 'MacSubPduRxAm18.csv':
            self.getMacSubPduAm18_ul(merge_data)
            self.getScellTotalVol(sansa='SA', merge_data=merge_data, dlul='ul')
        # print(self.new_data)

    def filterData(self, df_data, isPcell, nsa_sa, ca, counter, dlul='dl'):
        pd = install_and_import_pandas()
        if dlul == 'dl':
            if nsa_sa == 'NSAandSA':
                filtered_data = df_data[(df_data['isPcell'] == isPcell) &
                                        (df_data['dl_ca'] == ca)].groupby('physCellId')['macLength'].sum()
            else:
                filtered_data = df_data[(df_data['isPcell'] == isPcell) &
                                        (df_data['nsa_sa'] == nsa_sa) &
                                        (df_data['dl_ca'] == ca)].groupby('physCellId')['macLength'].sum()
        elif dlul == 'ul':
            if nsa_sa == 'NSAandSA':
                filtered_data = df_data[(df_data['isPcell'] == isPcell) &
                                        (df_data['ul_ca'] == ca)].groupby('physCellId')['macLength'].sum()
            else:
                filtered_data = df_data[(df_data['isPcell'] == isPcell) &
                                        (df_data['nsa_sa'] == nsa_sa) &
                                        (df_data['ul_ca'] == ca)].groupby('physCellId')['macLength'].sum()
        filtered_data = filtered_data.reset_index()
        self.new_data = pd.merge(self.new_data, filtered_data, how='outer', on=['physCellId'])
        self.new_data = self.new_data.rename(columns={'macLength': counter})
        self.new_data = self.new_data.fillna(0)

    def checkCounters(self, OamCounterData, outputpath=None, gap=500, subfeature='A'):
        check_result_dict = {}
        result_list = []
        if not self.new_data.empty:
            for index, row_data in self.new_data.iterrows():
                ncellid = row_data['NRCELL']
                print(f'ncellid: {ncellid}')
                check_result_dict[ncellid] = {}
                if OamCounterData[ncellid]:
                    for counter_name, counter_value in OamCounterData[ncellid].items():
                        csv_counter_value = row_data.get(counter_name, 0)
                        web_counter_value = counter_value
                        diff = csv_counter_value - web_counter_value
                        if web_counter_value != 0:
                            ratio = csv_counter_value / web_counter_value
                        else:
                            if web_counter_value == 0 and csv_counter_value == 0:
                                ratio = 1
                            else:
                                ratio = 0
                        check_result_dict[ncellid][counter_name] = {'Expected': web_counter_value,
                                                                    'Actual': csv_counter_value,
                                                                    'Ratio': round(ratio, 3),
                                                                    'Diff': diff,
                                                                    'Result': ''}
                        if (ratio > 0.85 and ratio < 1.2) or abs(diff) < int(gap):
                            check_result_dict[ncellid][counter_name]['Result'] = 'OK'
                            result_list.append(True)
                        elif ('VOL' in counter_name) and web_counter_value < 15000:
                            check_result_dict[ncellid][counter_name]['Result'] = 'OK'
                            result_list.append(True)
                        elif ('TIM' in counter_name) and (web_counter_value < 1000 or self.burst_length > 24):
                            check_result_dict[ncellid][counter_name]['Result'] = 'OK'
                            result_list.append(True)
                        else:
                            check_result_dict[ncellid][counter_name]['Result'] = 'Fail'
                            print(f'{ncellid}, {counter_name}, web:{web_counter_value}, log:{csv_counter_value}, '
                                  f'{ratio}, {diff}')
                            result_list.append(False)

            if self.csv_name == 'MacSubPduTxAm18.csv':
                out_file_name = 'CB010636_A_dl_counter_check_result.csv'
            elif self.csv_name == 'MacSubPduRxAm18.csv':
                out_file_name = 'CB010636_A_ul_counter_check_result.csv'
            elif subfeature == 'C':
                out_file_name = 'CB010636_C_dl_counter_check_result.csv'
            elif subfeature == 'D':
                out_file_name = 'CB010636_D_dl_counter_check_result.csv'
            output_file_name = os.path.join(outputpath, out_file_name)
            if outputpath:
                dict_to_csv(data=check_result_dict, output_path=output_file_name)
            if result_list:
                if False in result_list:
                    result = False
                else:
                    result = True
            else:
                result = False
        else:
            print('no data in csv file.')
            result = True
        return result

    def get_mac_sdu_value_from_L2LO_ttitrace_log(self):
        df = self.df_data.copy()
        pci_list = list(set(df["physCellId"].tolist()))
        df['padding'] = 1 * ((df['tbSize'] - df['amountBytes']) != 0)
        df['sdu_vol'] = (df['amountBytes'] - 2.9 * (df['sduNum'] - df['padding'])) * 8 / 1000
        df['time'] = (df['days'] * 24 * 60 * 60 * 1000 +
                      df['hours'] * 60 * 60 * 1000 +
                      df['minutes'] * 60 * 1000 +
                      df['seconds'] * 1000 +
                      df['microSeconds'] / 1000)
        df['time'] = deal_time(df)
        # df['per_slot'] = deal_time_per_slot(df)
        mac_result_dict = {}
        for physCellId in pci_list:
            df_physCellId = df[(df['physCellId'] == physCellId)]
            rnti_list = list(set(df_physCellId["rnti"].tolist()))
            sum_amountBytes, sum_Duration = 0, 0
            for rnti in rnti_list:
                df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
                burst_list = list(set(df_rnti["burstId"].tolist()))
                for burst in burst_list:
                    df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
                    amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_burst_without_last)
                    sum_amountBytes = sum_amountBytes + amountBytes_burst
                    sum_Duration = sum_Duration + Duration
            mac_result_dict[physCellId] = (sum_amountBytes, sum_Duration)

        # DL_MAC_SDU_VOL_UE_TPUT=M55309C00002
        self.new_data['DL_MAC_SDU_VOL_UE_TPUT'] = [mac_result_dict[x][0] for x in pci_list]
        # DL_MAC_SDU_TIME_UE_TPUT=M55309C00003
        self.new_data['DL_MAC_SDU_TIME_UE_TPUT'] = [mac_result_dict[x][1] for x in pci_list]

    def get_mac_sdu_value_from_L2LO_ttitrace_log2(self, volThresDiscardDlMacSdu=None,
                                                  durationThresDiscardDlMacSdu=None):
        df = self.df_data.copy()
        pci_list = list(set(df["physCellId"].tolist()))
        mac_result_dict = {}
        for physCellId in pci_list:
            df_physCellId = df[(df['physCellId'] == physCellId)]
            rnti_list = list(set(df_physCellId["rnti"].tolist()))
            chbw = BTS_config[str(physCellId)]['chbw']
            cell_type = BTS_config[str(physCellId)]['Cell_type']
            sum_amountBytes, sum_Duration = 0, 0
            for rnti in rnti_list:
                df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
                burst_list = list(set(df_rnti["burstId"].tolist()))
                for burst in burst_list:
                    df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
                    amountBytes_burst, Duration = get_amountBytes_and_time_per_burst2(df_burst_without_last, cell_type,
                                                                                      volThresDiscardDlMacSdu,
                                                                                      durationThresDiscardDlMacSdu)
                    sum_amountBytes = sum_amountBytes + amountBytes_burst
                    sum_Duration = sum_Duration + Duration
            mac_result_dict[physCellId] = (sum_amountBytes, sum_Duration)

        # DL_MAC_SDU_VOL_UE_TPUT=M55309C00002
        self.new_data['DL_MAC_SDU_VOL_UE_TPUT'] = [mac_result_dict[x][0] for x in pci_list]
        # DL_MAC_SDU_TIME_UE_TPUT=M55309C00003
        self.new_data['DL_MAC_SDU_TIME_UE_TPUT'] = [mac_result_dict[x][1] for x in pci_list]

    def get_RLC_merged_burst2(self, path, ca_info=None):
        pd = install_and_import_pandas()
        df = self.df_data.copy()
        pci_list = list(set(df["physCellId"].tolist()))
        rlc_result_dict = {}
        df_merge_burst = pd.DataFrame()
        for physCellId in pci_list:
            rlc_result_dict[physCellId] = []
            df_physCellId = df[(df['physCellId'] == physCellId)]
            rnti_list = list(set(df_physCellId["rnti"].tolist()))
            for rnti in rnti_list:
                is_pcell = True if ca_info[str(rnti)]['pcell'] == int(physCellId) else False
                if not is_CA_UE(df, rnti):
                    df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
                    burst_list = list(set(df_rnti["burstId"].tolist()))
                    if len(burst_list) < 1:
                        pass
                    else:
                        for burst in burst_list:
                            df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)]
                            df_burst_without_last = df_burst_without_last.copy()
                            df_burst_without_last['merged_id'] = [burst] * len(df_burst_without_last)
                            df_merge_burst = pd.concat([df_merge_burst, df_burst_without_last])
                elif is_CA_UE(df, rnti) and is_pcell:
                    df_ca_rnti = df[(df['rnti'] == rnti)]
                    set_list, set_burst_dic_list = get_CA_set_FR1_2(df_ca_rnti, path)
                    for df_ca, set_burst_dic in zip(set_list, set_burst_dic_list):
                        df_ca_without_last = df_ca.sort_index()
                        if not df_ca_without_last.empty:
                            df_merge_burst = pd.concat([df_merge_burst, df_ca_without_last])
        return df_merge_burst

    def get_RLC_merged_burst(self, path, ca_info=None):
        pd = install_and_import_pandas()
        global RLC_merger_id
        df = self.df_data.copy()
        df_merge_burst = pd.DataFrame()
        rlc_result_dict = {}
        logicalChannelId_list = list(set(df["logicalChannelId"].tolist()))
        for lcid in logicalChannelId_list:
            df_lcid = df[(df['logicalChannelId'] == lcid)]
            pci_list = list(set(df_lcid["physCellId"].tolist()))
            for physCellId in pci_list:
                rlc_result_dict[physCellId] = []
                df_physCellId = df_lcid[(df_lcid['physCellId'] == physCellId)]
                rnti_list = list(set(df_physCellId["rnti"].tolist()))
                for rnti in rnti_list:
                    is_pcell = True if ca_info[str(rnti)]['pcell'] == int(physCellId) else False
                    if not is_CA_UE(df_lcid, rnti):
                        df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
                        burst_list = list(set(df_rnti["burstId"].tolist()))
                        if len(burst_list) < 1:
                            pass
                        else:
                            for burst in burst_list:
                                RLC_merger_id += 1
                                df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)]
                                df_burst_without_last = df_burst_without_last.copy()
                                df_burst_without_last['merged_id'] = [RLC_merger_id] * len(df_burst_without_last)
                                df_merge_burst = pd.concat([df_merge_burst, df_burst_without_last])
                    elif is_CA_UE(df_lcid, rnti) and is_pcell:
                        df_ca_rnti = df_lcid[(df_lcid['rnti'] == rnti)]
                        set_list, set_burst_dic_list = get_CA_set_FR1_2(df_ca_rnti, path)
                        for df_ca, set_burst_dic in zip(set_list, set_burst_dic_list):
                            df_ca_without_last = df_ca.sort_index()
                            if not df_ca_without_last.empty:
                                df_merge_burst = pd.concat([df_merge_burst, df_ca_without_last])
        return df_merge_burst

    def get_RLC_value_from_L2LO_ttitrace_log(self, path, ca_info=None):
        """Caculate DL_RLC_PDU_VOL_UE_TPUT and DL_RLC_PDU_TIME_UE_TPUT from L2LO ttitrace log
        """
        df_data = self.df_data.copy()
        if not df_data.empty:
            pci_list = list(set(df_data["physCellId"].tolist()))
            df_data = self.get_RLC_merged_burst(path=path, ca_info=ca_info)
            rlc_result_dict = {}
            df_data['padding'] = 1 * ((df_data['tbSize'] - df_data['amountBytes']) != 0)
            df_data['sdu_vol'] = (df_data['amountBytes'] - 2.9 * (df_data['sduNum'] - df_data['padding'])) * 8 / 1000
            df_data['time'] = (df_data['days'] * 24 * 60 * 60 * 1000 +
                               df_data['hours'] * 60 * 60 * 1000 +
                               df_data['minutes'] * 60 * 1000 +
                               df_data['seconds'] * 1000 +
                               df_data['microSeconds'] / 1000)
            df_data['time'] = deal_time(df_data)
            df_data['per_slot'] = deal_time_per_slot(df_data)
            rnti_list = list(set(df_data["rnti"].tolist()))
            for rnti in rnti_list:
                pcell_pci = ca_info[str(rnti)]['pcell']
                rlc_result_dict[pcell_pci] = rlc_result_dict.setdefault(pcell_pci, {'vol': 0, 'duration': 0})
                df_rnti = df_data[(df_data['rnti'] == rnti)]
                merge_id_list = list(set(df_rnti["merged_id"].tolist()))
                print(f'rnti: {rnti}\n merge_list:{merge_id_list}')
                sum_duration, sum_vol = 0, 0
                for merge_id in merge_id_list:
                    df_merge = df_rnti[(df_rnti['merged_id'] == merge_id)][:-1]
                    if not df_merge.empty:
                        start_time, end_time = df_merge.iloc[0]['time'], df_merge.iloc[-1]['time']
                        first_slot_time = df_merge.iloc[0]['per_slot']
                        duration = end_time - start_time + first_slot_time
                        sum_duration += duration
                        sum_vol += df_merge['sdu_vol'].sum()
                rlc_result_dict[pcell_pci]['vol'] += sum_vol
                rlc_result_dict[pcell_pci]['duration'] += sum_duration
            # print(f'***************Data for sum:********************\n{data_result_dict}', file=f)
            # DL_RLC_PDU_VOL_UE_TPUT=M55349C03002
            for pci in pci_list:
                if pci not in rlc_result_dict.keys():
                    rlc_result_dict[pci] = {'vol': 0, 'duration': 0}
            self.new_data['DL_RLC_PDU_VOL_UE_TPUT'] = [rlc_result_dict[x]['vol'] for x in pci_list]
            # DL_RLC_PDU_TIME_UE_TPUT=M55349C04002
            self.new_data['DL_RLC_PDU_TIME_UE_TPUT'] = [rlc_result_dict[x]['duration'] for x in pci_list]
            # Only NRPMQAP-7 Regression Testing, so DL_RLC_PDU_VOL_UE_TPUT = DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-7
            self.new_data['DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-7'] = [rlc_result_dict[x]['vol'] for x in pci_list]
            self.new_data['DL_RLC_PDU_TIME_UE_TPUT_NRPMQAP-7'] = [rlc_result_dict[x]['duration'] for x in pci_list]

    def get_RLC_value_from_L2LO_ttitrace_log2(self, path, ca_info=None):
        """Caculate DL_RLC_PDU_VOL_UE_TPUT and DL_RLC_PDU_TIME_UE_TPUT from L2LO ttitrace log
        """
        df = self.df_data.copy()
        df['time'] = (df['days'] * 24 * 60 * 60 * 1000 +
                      df['hours'] * 60 * 60 * 1000 +
                      df['minutes'] * 60 * 1000 +
                      df['seconds'] * 1000 +
                      df['microSeconds'] / 1000)
        df['time'] = deal_time(df)
        pci_list = list(set(df["physCellId"].tolist()))
        rlc_result_dict = {}
        for physCellId in pci_list:
            rlc_result_dict[physCellId] = []
            cell_type = BTS_config[str(physCellId)]['Cell_type']
            df_physCellId = df[(df['physCellId'] == physCellId)]
            rnti_list = list(set(df_physCellId["rnti"].tolist()))
            sum_amountBytes, sum_Duration = 0, 0
            for rnti in rnti_list:
                is_pcell = True if ca_info[str(rnti)]['pcell'] == int(physCellId) else False
                if not is_CA_UE(df, rnti):
                    df_rnti = df_physCellId[(df_physCellId['rnti'] == rnti)]
                    burst_list = list(set(df_rnti["burstId"].tolist()))
                    if len(burst_list) < 1:
                        pass
                    else:
                        for burst in burst_list:
                            df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
                            amountBytes_burst, Duration = get_amountBytes_and_time_per_burst2(df_burst_without_last,
                                                                                              cell_type)
                            sum_amountBytes = sum_amountBytes + amountBytes_burst
                            sum_Duration = sum_Duration + Duration
                elif is_CA_UE(df, rnti) and is_pcell:
                    df_ca_rnti = df[(df['rnti'] == rnti)]
                    set_list, set_burst_dic_list = get_CA_set_FR1_2(df_ca_rnti, path)
                    for df_ca, set_burst_dic in zip(set_list, set_burst_dic_list):
                        df_ca_without_last = df_ca.sort_index()
                        last_sfn = df_ca_without_last.iloc[-1]['sfn']
                        last_slot = df_ca_without_last.iloc[-1]['slot']
                        df_last_10 = df_ca.sort_index().tail(10)
                        df_last_slot = df_last_10[(df_last_10['sfn'] == last_sfn) &
                                                  (df_last_10['slot'] == last_slot)]
                        df_ca_without_last.drop(df_last_slot.index, inplace=True)
                        if not df_ca_without_last.empty:
                            physCellId_last_slot = df_ca_without_last.iloc[-1]['physCellId']
                            df_sfn_cycle = df_ca_without_last[
                                (df_ca_without_last['physCellId'] == int(physCellId_last_slot))]
                            if not df_ca_without_last.empty:
                                amountBytes_burst, useless = get_amountBytes_and_time_per_burst2(df_ca_without_last,
                                                                                                 cell_type)
                                sfn_cycle_times = get_sfn_cycle_times(df_sfn_cycle)
                                Duration = get_time_per_burst_for_RLC(df_ca_without_last, sfn_cycle_times)
                            else:
                                amountBytes_burst = 0
                                Duration = 0
                            sum_amountBytes = sum_amountBytes + amountBytes_burst
                            sum_Duration = sum_Duration + Duration
                elif is_CA_UE(df, rnti) and not is_pcell:
                    sum_amountBytes = sum_amountBytes + 0
                    sum_Duration = sum_Duration + 0

            rlc_result_dict[physCellId] = (sum_amountBytes, sum_Duration)

        # DL_RLC_PDU_VOL_UE_TPUT=M55349C03002
        self.new_data['DL_RLC_PDU_VOL_UE_TPUT'] = [rlc_result_dict[x][0] for x in pci_list]
        # DL_RLC_PDU_TIME_UE_TPUT=M55349C04002
        self.new_data['DL_RLC_PDU_TIME_UE_TPUT'] = [rlc_result_dict[x][1] for x in pci_list]
        # Only NRPMQAP-7 Regression Testing, so DL_RLC_PDU_VOL_UE_TPUT = DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-7
        self.new_data['DL_RLC_PDU_VOL_UE_TPUT_NRPMQAP-7'] = [rlc_result_dict[x][0] for x in pci_list]
        self.new_data['DL_RLC_PDU_TIME_UE_TPUT_NRPMQAP-7'] = [rlc_result_dict[x][1] for x in pci_list]

    def get_RLC_time_DENOM_from_L2LO_tti(self, ca_info=None):
        df_data = self.df_data.copy()
        df_data['padding'] = 1 * ((df_data['tbSize'] - df_data['amountBytes']) != 0)
        df_data['sdu_vol'] = (df_data['amountBytes'] - 2.9 * (df_data['sduNum'] - df_data['padding'])) * 8 / 1000
        df_data['time'] = (df_data['days'] * 24 * 60 * 60 * 1000 +
                           df_data['hours'] * 60 * 60 * 1000 +
                           df_data['minutes'] * 60 * 1000 +
                           df_data['seconds'] * 1000 +
                           df_data['microSeconds'] / 1000)
        df_data['time'] = deal_time(df_data)
        df_data['per_slot'] = deal_time_per_slot(df_data)
        if not df_data.empty:
            pci_list = list(set(df_data["physCellId"].tolist()))
            denom_result_dict = {}
            mac_result_dict = {}
            rnti_list = list(set(df_data["rnti"].tolist()))
            for rnti in rnti_list:
                df_rnti = df_data[(df_data['rnti'] == rnti)]
                burst_list = list(set(df_rnti["burstId"].tolist()))
                pcell_pci = ca_info[str(rnti)]['pcell']
                denom_result_dict[pcell_pci] = denom_result_dict.setdefault(pcell_pci, {})
                for burst in burst_list:
                    df_burst_without_last = df_rnti[(df_rnti['burstId'] == burst)][:-1]
                    pci_list_every_burst = list(set(df_burst_without_last["physCellId"].tolist()))
                    for pci in pci_list_every_burst:
                        df_pci = df_burst_without_last[(df_burst_without_last['physCellId'] == pci)]
                        chbw = BTS_config[str(pci)]['chbw']
                        cell_type = BTS_config[str(pci)]['Cell_type']
                        amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_pci)
                        # amountBytes_burst, Duration = get_amountBytes_and_time_per_burst(df_pci, cell_type)
                        print(f'rnti: {rnti}, burst: {burst}, pci: {pci}, chbw: {chbw}M, duration: {Duration}')
                        denom_result_dict[pcell_pci][rnti] = (denom_result_dict[pcell_pci].get(rnti, 0) +
                                                              chbw * Duration)
                        mac_result_dict[pci] = mac_result_dict.get(pci, 0) + Duration
            for p, value in denom_result_dict.items():
                denom_result_dict[p] = sum(value.values())
            # DL_RLC_PDU_UE_TPUT_DENOM_FR1
            self.new_data['DL_RLC_PDU_UE_TPUT_DENOM_FR1'] = [denom_result_dict.get(x, 0) for x in pci_list]

    def get_RLC_per_CC_DL_counters(self, path, ca_info=None, output_path=None):
        pd = install_and_import_pandas()
        df_data = self.df_data.copy()
        if not df_data.empty:
            pci_list_org = list(set(df_data["physCellId"].tolist()))
            df_data = self.get_RLC_merged_burst(path=path, ca_info=ca_info)
            data_result_dict = {}
            df_merge_cc_data = pd.DataFrame()
            # f = open(f'{output_path}/CB010636_C_DL_debug.txt', 'w')
            df_data['padding'] = 1 * ((df_data['tbSize'] - df_data['amountBytes']) != 0)
            df_data['sdu_vol'] = (df_data['amountBytes'] - 2.9 * (df_data['sduNum'] - df_data['padding'])) * 8 / 1000
            df_data['time'] = (df_data['days'] * 24 * 60 * 60 * 1000 +
                               df_data['hours'] * 60 * 60 * 1000 +
                               df_data['minutes'] * 60 * 1000 +
                               df_data['seconds'] * 1000 +
                               df_data['microSeconds'] / 1000)
            df_data['time'] = deal_time(df_data)
            df_data['per_slot'] = deal_time_per_slot(df_data)
            rnti_list = list(set(df_data["rnti"].tolist()))
            for rnti in rnti_list:
                pcell_pci = ca_info[str(rnti)]['pcell']
                nsasa = ca_info[str(rnti)]['nsa_or_sa']
                data_result_dict[nsasa] = data_result_dict.setdefault(nsasa, {pcell_pci: {}})
                df_rnti = df_data[(df_data['rnti'] == rnti)]
                merge_id_list = list(set(df_rnti["merged_id"].tolist()))
                time_range_list = get_time_range_per_merge_burst(df_rnti, merge_id_list)
                for merge_id in merge_id_list:
                    df_merge = df_rnti[(df_rnti['merged_id'] == merge_id)][:-1]
                    df_merge['cc'] = calculate_cc_data(df_merge, time_range_list)
                    df_merge_cc_data = pd.concat([df_merge_cc_data, df_merge])
                    df_merge_sorted = df_merge.sort_values(by='time', ascending=True)
                    merger_per_cc = get_merge_data_vol_and_duration_per_cc(df_merge_sorted)
                    for cc, values in merger_per_cc.items():
                        data_result_dict[nsasa][pcell_pci][cc] = (
                            data_result_dict[nsasa][pcell_pci].setdefault(cc, {'vol': 0, 'duration': 0}))
                        data_result_dict[nsasa][pcell_pci][cc]['vol'] = data_result_dict[nsasa][pcell_pci][cc][
                                                                            'vol'] + values['vol']
                        data_result_dict[nsasa][pcell_pci][cc]['duration'] = (
                                data_result_dict[nsasa][pcell_pci][cc]['duration'] + values['duration'])
                        # print(f'merge_id: {merge_id}, cc: {cc}, vol: {sum_vol}, duration: {duration}')
            # print(f'***************Data for sum:********************\n{data_result_dict}', file=f)
            print(data_result_dict)
            for nsasa, all_values in data_result_dict.items():
                for cell_pci, values in all_values.items():
                    for cc, value in values.items():
                        vol_counter_name = f'DL_RLC_VOL_UE_TPUT_FR1_{nsasa}_{cc}CC'
                        duration_counter_name = f'DL_RLC_TIM_UE_TPUT_FR1_{nsasa}_{cc}CC'
                        vol = value['vol']
                        duration = value['duration']
                        self.new_data[vol_counter_name] = [vol if x == cell_pci else 0 for x in pci_list_org]
                        self.new_data[duration_counter_name] = [duration if x == cell_pci else 0 for x in
                                                                pci_list_org]
            self.burst_length = len(list(set(df_merge_cc_data["burstId"].tolist())))
            print('Burst_id_length = ', self.burst_length)
            # debug
            df_merge_cc_data.to_csv(f'{output_path}/df_merge_cc_data.csv', index=True)
            # f.close()

    def getBurstLength(self):
        return self.burst_length


if __name__ == '__main__':
    deal = DealCounter()
    deal.setCsvPath('MacPduMuxReq.csv')
    deal.get_mac_sdu_value_from_L2LO_ttitrace_log()
    print(deal.new_data)
