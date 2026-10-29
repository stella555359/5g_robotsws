import os
import math
import datetime
import warnings

from robot.api import logger


timestamp_format = "%Y-%m-%d %H:%M:%S"
log_timestamp_format = "%b  %d, %Y %H:%M:%S.%f000 UTC"


def average_in_dBm(aW):
    return 10 * math.log10(1000 * aW * pow(10, -18))


def find_max_for_same_msg(PUCCH_file, PUSCH_file, counter_id_list):
    import pandas as pd
    import numpy as np
    f_merge = pd.merge(PUCCH_file, PUSCH_file, on=['asfn', 'sfn', 'slot'], how='inner')
    holder = None
    max_candidate = None
    for name in counter_id_list:
        f_merge['tag'] = np.where((f_merge[name+'_x'] != 10) & (f_merge[name+'_y'] != 10) &
                                  (pd.isna(f_merge[name+'_x']) is False) &
                                  (pd.isna(f_merge[name+'_y']) is False),
                                  name, "False")
        max_candidate = pd.concat([holder, f_merge.loc[f_merge['tag'] != 'False']])
        holder = max_candidate
    which_prbs = max_candidate["tag"].values.tolist()
    which_prbs = list(set(which_prbs))
    output_dict = {}
    for prb_id in which_prbs:
        PUCCH_prbs = max_candidate[prb_id+"_x"].values.tolist()
        PUSCH_prbs = max_candidate[prb_id+"_y"].values.tolist()
        averages_list = []
        for i in range(len(PUCCH_prbs)):
            averages_list.append((PUCCH_prbs[i]+PUSCH_prbs[i])/2)
        output_dict.update({prb_id: max(averages_list)})
    return output_dict, max_candidate


def trim_messages(csv_file, start_time, end_time, file_name):
    csv_file = csv_file.sort_values(["time"], inplace=False)
    if "prach" in file_name or "pusch":
        logger.console(f"{file_name} duplikaty przed= {csv_file.shape[0]}")
        csv_file = csv_file.drop_duplicates(subset="time", inplace=False)
        logger.console(f"{file_name} duplikaty po= {csv_file.shape[0]}")
    start_time = datetime.datetime.strptime(start_time, timestamp_format)
    end_time = datetime.datetime.strptime(end_time, timestamp_format)
    logger.console(f"{file_name} trim przed= {csv_file.shape[0]}")
    for i in range(csv_file.shape[0]):
        time_stamp = datetime.datetime.strptime(csv_file.iloc[i, 0], log_timestamp_format)
        if time_stamp >= start_time:
            csv_file = csv_file.iloc[i:,]
            break
    for i in reversed(range(csv_file.shape[0])):
        time_stamp = datetime.datetime.strptime(csv_file.iloc[i, 0], log_timestamp_format)
        if time_stamp <= end_time:
            csv_file = csv_file.iloc[:i+1,]
            break
    logger.console(f"{file_name} trim po= {csv_file.shape[0]}")
    return csv_file


def calculate_prb_sum_and_len(csv_file,
                              file_name,
                              transmission_technology,
                              counter_id_list,
                              msg1FrequencyStart,
                              rach_avg):
    import pandas as pd
    output_dict = {}
    prbs_id = counter_id_list
    if "pusch" in file_name or "pucch" in file_name:
        for id in prbs_id:
            col_length = len(csv_file.loc[(csv_file[id] != 10.0) & (pd.isna(csv_file[id]) is False), id])
            total = csv_file.loc[(csv_file[id] != 10.0) & (pd.isna(csv_file[id]) is False), id].sum()
            output_dict.update({id: {'sum': float(total), 'len': col_length}})
    elif "prach" in file_name and rach_avg:
        noise = "noisePowerLinear"
        col_length = len(csv_file.loc[(csv_file[noise] != 10.0) & (pd.isna(csv_file[noise]) is False), noise])
        total = float(csv_file.loc[(csv_file[noise] != 10.0) & (pd.isna(csv_file[noise]) is False), noise].sum())
        if transmission_technology == "FDD":
            total = total/6
            for i in range(len(prbs_id)):
                if i >= msg1FrequencyStart and i < msg1FrequencyStart+6:
                    output_dict.update({prbs_id[i]: {'sum': total, 'len': col_length}})
                else:
                    output_dict.update({prbs_id[i]: {'sum': 0.0, 'len': 0, 'max': 0.0}})
        if transmission_technology == "TDD":
            total = total/12
            for i in range(len(prbs_id)):
                if i >= msg1FrequencyStart and i < msg1FrequencyStart+12:
                    output_dict.update({prbs_id[i]: {'sum': total, 'len': col_length}})
                else:
                    output_dict.update({prbs_id[i]: {'sum': 0.0, 'len': 0, 'max': 0.0}})
    return output_dict


def calculate_max(files_list, counters_id_list, transmission_technology, msg1FrequencyStart, rach_avg):
    import pandas as pd
    import numpy as np
    noise_col = "noisePowerLinear"
    max_dict = {}
    for id in counters_id_list:
        max_list = []
        for csv_file in files_list:
            if "prach" in csv_file.name and transmission_technology == "TDD" \
                  and counters_id_list.index(id) >= msg1FrequencyStart \
                  and counters_id_list.index(id) < msg1FrequencyStart+12 and rach_avg:
                rach_max = csv_file.loc[(csv_file[noise_col] != 10.0) & (pd.isna(csv_file[noise_col]) is False),
                                        noise_col].max()
                max_list.append(rach_max/12)
            if "prach" in csv_file.name and transmission_technology == "FDD" \
                    and counters_id_list.index(id) >= msg1FrequencyStart \
                    and counters_id_list.index(id) < msg1FrequencyStart+6 and rach_avg:
                rach_max = csv_file.loc[(csv_file[noise_col] != 10.0) & (pd.isna(csv_file[noise_col]) is False),
                                        noise_col].max()
                max_list.append(rach_max/6)
            if "pusch" in csv_file.name or "pucch" in csv_file.name:
                max_list.append(csv_file.loc[(csv_file[id] != 10.0) & (pd.isna(csv_file[id]) is False), id].max())
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", category=RuntimeWarning)
            aW_max = np.nanmax(max_list)
            dBm_max = average_in_dBm(aW_max)
            if pd.isna(dBm_max):
                max_dict.update({id: {'val': 0, 'len': 1}})
            else:
                max_dict.update({id: {'val': dBm_max, 'len': 1}})
    return max_dict


def remove_unnecessary_rows(PUCCH_file, PUSCH_file, max_dict, max_candidate):
    for index, row in max_candidate.iterrows():
        tag = row['tag']
        PUCCH_file.loc[(PUCCH_file['asfn'] == row['asfn']) &
                       (PUCCH_file['sfn'] == row['sfn']) &
                       (PUCCH_file['slot'] == row['slot']) &
                       (PUCCH_file[tag] == row[tag+'_x']), tag] = [max_dict[tag]]
        PUSCH_file.loc[(PUSCH_file['asfn'] == row['asfn']) &
                       (PUSCH_file['sfn'] == row['sfn']) &
                       (PUSCH_file['slot'] == row['slot']) &
                       (PUSCH_file[tag] == row[tag+'_y']), tag] = [max_dict[tag]]
    return PUCCH_file, PUSCH_file


def calculate_avg(list_of_outputs, counter_id_list):
    out_put_dir = {}
    noise_sum = 0
    len_sum = 0
    for id in counter_id_list:
        for i in range(len(list_of_outputs)):
            if bool(list_of_outputs[i]):
                noise_sum += list_of_outputs[i][id]['sum']
                len_sum += list_of_outputs[i][id]['len']
        try:
            avg_result = noise_sum / len_sum
        except ZeroDivisionError:
            out_put_dir.update({id: {"val": 0, "len": len_sum}})
            noise_sum = 0
            len_sum = 0
            continue
        avg_result = average_in_dBm(avg_result)
        out_put_dir.update({id: {'val': avg_result, 'len': len_sum}})
        noise_sum = 0
        len_sum = 0
    return out_put_dir


def generate_counters_id_for_biplog():
    prefix = "noisePerPrb_item_"
    first_counter = 0
    last_counter = 272
    counter_id_list = []
    for i in range(first_counter, last_counter+1):
        counter_id_list.append(prefix + str(i))
    return counter_id_list


def save_dict_to_csv(output_dic, result_dir, file_name, subcellid):
    import pandas as pd
    df = pd.DataFrame.from_dict({(i, j): output_dic[i][j]
                                 for i in output_dic.keys()
                                 for j in output_dic[i].keys()},
                                orient='index')
    df.to_excel(f"{result_dir}/{file_name}_avg_max_result_{subcellid}.xlsx")


def parse_bip_logs(path_to_dir,
                   puch_mode,
                   start_time,
                   end_time,
                   transmission_technology,
                   msg1FrequencyStart,
                   rach_avg,
                   result_dir,
                   subcellid):
    '''
    puch_mode - longPucch lub shortPucch
    start_time - Pierwsza data która będzie wzięta pod uwagę
    end_time - Pierwsza która nie będzie juz brana pod uwage
    '''
    import pandas as pd
    msg1FrequencyStart = int(msg1FrequencyStart)
    outputs_list = []
    opened_files = []
    counter_id_list = generate_counters_id_for_biplog()
    log_files_name_list = os.listdir(path_to_dir)
    log_files_name_list = [fname for fname in log_files_name_list if subcellid in fname]
    for file_name in log_files_name_list:
        csv_file = pd.read_csv(path_to_dir+'/'+file_name)
        trimed_file = trim_messages(csv_file, start_time, end_time, file_name)
        opened_files.append(trimed_file)
        opened_files[-1].name = file_name
    for trimed_file in opened_files:
        avg_dict = calculate_prb_sum_and_len(trimed_file,
                                             trimed_file.name,
                                             transmission_technology,
                                             counter_id_list,
                                             msg1FrequencyStart,
                                             rach_avg)
        outputs_list.append(avg_dict)
    avg_output = calculate_avg(outputs_list, counter_id_list)
    if puch_mode == "short" and len(opened_files) == 3:
        pucch_file = [s for s in opened_files if "pucch" in s.name]
        pusch_file = [s for s in opened_files if "pusch" in s.name]
        max_dict, max_candidate = find_max_for_same_msg(pucch_file[0], pusch_file[0], counter_id_list)
        remove_unnecessary_rows(pucch_file[0], pusch_file[0], max_dict, max_candidate)
    max_outpu = calculate_max(opened_files, counter_id_list, transmission_technology, msg1FrequencyStart, rach_avg)
    avg_and_max_dict = {"avg": avg_output, "max": max_outpu}
    save_dict_to_csv(avg_and_max_dict, result_dir, start_time, subcellid)
    return avg_and_max_dict
