from collections import OrderedDict

import numpy as np
import pandas as pd

import qxdm_parsers


def __extract_raw_values_from_qxdm_log(filepath, msg_name_list=None):
    messages = __get_messages_from_qxdm_log(filepath, msg_name_list)
    for message in messages:
        message_name = qxdm_parsers.extract_message_name_from_message_header(message[0])
        parser = qxdm_parsers.get_parser(message_name)
        parser = parser(message)
        yield parser.type, parser.values


def __get_messages_from_qxdm_log(filepath, name_list=None):
    with open(filepath) as ue_log:
        start_flag = False
        message_buffer = []
        for line in ue_log:
            if __is_message_indicator(line):
                if not start_flag:
                    start_flag = True
                else:
                    yield message_buffer
                message_buffer = [line]
                if name_list is not None and not any([name in line for name in name_list]):
                    start_flag = False
            message_buffer.append(line.strip())


def __is_message_indicator(line):
    parts = line.split('  ')
    if len(parts) < 5 or not line[0].isdigit():
        return False
    if len(parts[1]) == 1 and parts[1].isdigit():
        del parts[1]
    if ':' not in parts[1] or '[' not in parts[2] or ']' not in parts[2] or '0x' not in parts[3]:
        return False
    return True


def analyze_qxdm_log(filepath, msg_name_list, param_names, filters=None, ratios=False):
    """
        :param filepath: string holding path to .txt log from qcat
        :param msg_name_list: list of message names
        :param param_names:   list of parameter names to analyze
        :param filters: optional list of tuple elements with structure: (param, comparison, value)
                        where: param -> string with parameter name
                               comparison -> string with proper sign, such as '==', '<', '>=' etc.
                               value -> float value to compare to
                        example:  ('BLER', '>=', 0.4)
        :param ratios: optional; True saves ratios of values to .csv
        :return: dataframes with all values from log and statistics saved as multiple .csv files
        """
    analysis = {}
    filters = filters if filters is not None else []
    raw_data = __extract_raw_values_from_qxdm_log(filepath, msg_name_list)
    for message_type, message_values in raw_data:
        for parameter in param_names:
            msg_values_for_param = message_values.get(parameter, None)
            if msg_values_for_param is not None:
                if analysis.get(message_type, None) is None:
                    analysis[message_type] = OrderedDict()
                if analysis[message_type].get(parameter, None) is None:
                    analysis[message_type][parameter] = OrderedDict()
                __update_results_dictionary(analysis[message_type][parameter], parameter, msg_values_for_param)
    result_dataframes = __convert_to_dataframes(analysis, filters)
    if ratios:
        for df in result_dataframes:
            for col in df.columns:
                ratio_tuples = __count_ratios(df, col)
                __save_ratios(col, ratio_tuples)
    stats_dataframes = __create_statistics_dataframe(result_dataframes)
    __save_output(stats_dataframes, analysis.keys())
    return stats_dataframes


def __convert_to_dataframes(data_dict, filters):
    dataframes_list = []
    for key in data_dict.keys():
        df_list = []
        params = data_dict[key].keys()
        for param_name in params:
            __check_for_equal_length(data_dict[key][param_name].values())
            datatype = __check_for_dtype(data_dict[key][param_name])
            df = pd.DataFrame.from_dict(data_dict[key][param_name], dtype=datatype)
            if filters is not None:
                for filter_param in filters:
                    if filter_param[0] == param_name:
                        filter_type = filter_param[1]
                        filter_cmp_value = filter_param[2]
                        df = __filter_single_param(df, filter_type, filter_cmp_value)
            df_list.append(df)
        dataframe = pd.concat(df_list, axis=1)
        dataframes_list.append(dataframe)
    return dataframes_list


def __check_for_equal_length(values_list):
    all_lengths = [len(elem) for elem in values_list]
    max_length = max(all_lengths)
    for index, elements in enumerate(values_list):
        if len(elements) != max_length:
            elements[:0] = [np.nan for _ in range(max_length - len(elements))]


def __check_for_dtype(dataset):
    for column in dataset:
        if type(dataset[column][0]) is not float:
            return object
        else:
            return float


def __create_statistics_dataframe(df_list):
    """Create dataframe containing min, max, mean values and sum of all values for each parameter."""
    statistics_list = []
    for df in df_list:
        stats_df = pd.DataFrame(
            index=['min', 'max', 'mean', 'sum'],
            columns=df.columns,
            data=[[np.min(df[col]) if df[col].dtypes == 'float64' else "NA" for col in df.columns],
                  [np.max(df[col]) if df[col].dtypes == 'float64' else "NA" for col in df.columns],
                  [np.mean(df[col]) if df[col].dtypes == 'float64' else "NA" for col in df.columns],
                  [np.sum(df[col]) if df[col].dtypes == 'float64' else "NA" for col in df.columns]]
        )
        df = pd.concat([stats_df, df], axis=0)
        statistics_list.append(df)
    return statistics_list


def __count_ratios(results_df, param_name):
    """Return set of unique values of a parameter and their ratios within all values present in the log."""
    all_values = results_df[param_name].tolist()
    nulls_filtered = [v for v in all_values if pd.notnull(v)]
    len_all = len(all_values)
    null_ratio = (len_all - len(nulls_filtered)) / float(len_all)
    if null_ratio == 1.0:
        return None
    else:
        values_set = np.unique(nulls_filtered).tolist()
        ratios_list = [("NaN", null_ratio)]
        for value in values_set:
            new_df = [v for v in nulls_filtered if v == value]
            len_new_df = len(new_df)
            ratio = len_new_df / float(len_all)
            ratios_list.append((value, ratio))
        return ratios_list


def __update_results_dictionary(param_dict, param_name, param_values):
    values = __prepare_data_for_insertion(param_values)
    if not param_dict:
        for i in range(len(values)):
            param_dict['{} {}'.format(param_name, i)] = []
    if len(param_dict.keys()) < len(values):
        for j in range(len(param_dict.keys()), len(values)):
            param_dict['{} {}'.format(param_name, j)] = []
    if len(param_dict) > len(values):
        for k in range(len(param_dict.keys()) - len(values)):
            values.append(np.nan)
    __append_values_to_dict(param_dict, values)
    return param_dict


def __prepare_data_for_insertion(data):
    if isinstance(data, list):
        if len(data[0]) > 1:
            tmp_values = [[v] for v in data[0]]
            values = [item[0] for item in tmp_values]
        else:
            values = [item[0] for item in data]
    else:
        values = [data]
    values = [np.nan if value == '' or value == 'NA' else value for value in values]
    try:
        values = [float(value) for value in values]
    except ValueError:
        pass
    return values


def __append_values_to_dict(param_dict, values_list):
    for position, key in enumerate(param_dict.keys()):
        param_dict[key].append(values_list[position])


def __filter_single_param(dataframe, filter_type, filter_compare_value):
    """Filter single dataframe and allocate it as new one."""
    filtered_dataframe = __get_filter_type(dataframe, filter_type, filter_compare_value)
    return filtered_dataframe


def __get_filter_type(data, f_argument, f_cmp_value):
    """Return proper filter type based on string input in the filter tuple."""
    switcher = {
        '==': __equals(data, f_cmp_value),
        '<': __less(data, f_cmp_value),
        '<=': __less_or_equal(data, f_cmp_value),
        '>': __greater(data, f_cmp_value),
        '>=': __greater_or_equal(data, f_cmp_value)
    }
    return switcher.get(f_argument, 'invalid entry')


def __equals(dataframe, cmp_value):
    return dataframe.where(dataframe == cmp_value)


def __less(dataframe, cmp_value):
    return dataframe.where(dataframe < cmp_value)


def __less_or_equal(dataframe, cmp_value):
    return dataframe.where(dataframe <= cmp_value)


def __greater(dataframe, cmp_value):
    return dataframe.where(dataframe > cmp_value)


def __greater_or_equal(dataframe, cmp_value):
    return dataframe.where(dataframe >= cmp_value)


def __save_ratios(parameter, data):
    if data is not None:
        filename = parameter + '_ratios.csv'
        ratios_dataframe = pd.DataFrame(data, columns=['value', 'ratio'])
        ratios_dataframe.to_csv(filename, index=False)


def __save_output(df_list, keys_list):
    for i in range(len(df_list)):
        df_list[i].to_csv('df_{}.csv'.format(keys_list[i]), na_rep='-', index=True)
