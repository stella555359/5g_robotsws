"""
:copyright: Nokia Networks
:author: Kamil Bucki
:maintainer: Kamil Bucki
:contact: kamil.bucki@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>

"""

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.file_management import (
    create_dir, save_json_file, load_json_file, list_all_files_in_directory
)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import (get_current_date, logger_console)
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.pm_counters import get_pm_counters_values
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb import get_current_time_on_gnb
from robot.libraries.BuiltIn import BuiltIn
import time
import os
import re


class MissingKeyInDictionaryException(Exception):
    pass


class UnsupportedParamsInKeysToGetValueOfCounterException(Exception):
    pass


class NotExistCommonTimestampForCounters(Exception):
    pass


def wait_for_next_pm_period(interval=15, delay=30):
    """Sleeps until interval starts

    :param interval: time of the interval, in minutes
    :param delay: delay in seconds after interval ends
    """
    next_pm_period = int(interval) * 60 - time.time() % (int(interval) * 60)
    logger.debug("Interval is: {}".format(interval))
    logger_console_info("Next PM Period will start after: {}".format(next_pm_period))
    time.sleep(next_pm_period + delay)
    return time.time()


def create_counter_list(*args):
    """
    This function create main list of counter based on lists added as args.
    Then the list is saved to COUNTER LIST variable.

    :author: Kamil Bucki
    :param *args: Lists with counters
    :return: list of counters
    """

    main_counter_list = BuiltIn().get_variable_value("${COUNTER_LIST}")

    if main_counter_list is None:
        main_counter_list = []

    for counter_list in args:
        for counter in counter_list:
            if counter not in main_counter_list:
                main_counter_list.append(counter)
    logger_console("Saving {} list to COUNTER_LIST variable.".format(main_counter_list))
    BuiltIn().set_test_variable("${COUNTER_LIST}", main_counter_list)

    return main_counter_list


def collect_counters_values(print_dicts=False,
                            save_to_file=True,
                            outputdir=None,
                            timstamp_directory=True,
                            counter_list=None,
                            test_phase=None,
                            timeout=60,
                            parallel=True):
    """
    This function set variable (<counter>_DICT) with value of each counter from list.

    :author: Kamil Bucki
    :param print_dicts: printing value if True
    :param save_to_file: saving value to file if True
    :param outputdir: a path to counter files. OUTPUT_DIR in case of None
    :param timstamp_directory: separate directory with timestamp if true
    :param counter_list: a list with counters. COUNTER_LIST in case of None
    :param test_phase: a name of test phase
    :return: list of counters
    """
    timeout = int(timeout)
    counter_dir = None
    if counter_list is None:
        counter_list = BuiltIn().get_variable_value("${COUNTER_LIST}")
    if save_to_file:
        if outputdir is None:
            outputdir = BuiltIn().get_variable_value("${OUTPUT_DIR}")

        counter_dir = create_dir(dir_name='counters', path=outputdir)

        if timstamp_directory:
            counter_dir = create_dir(dir_name=get_current_date(), path=counter_dir)
    add_timestamp_to_file_name = not timstamp_directory

    if parallel:
        _set_counter_variables_and_print_if_needed(counter_list,
                                                   print_dicts,
                                                   outputdir=counter_dir,
                                                   add_timestamp=add_timestamp_to_file_name,
                                                   timeout=timeout
                                                   )
    else:
        for counter in counter_list:
            _set_counter_variables_and_print_if_needed([counter],
                                                       print_dicts,
                                                       outputdir=counter_dir,
                                                       add_timestamp=add_timestamp_to_file_name,
                                                       timeout=timeout
                                                       )

    dir_list = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_LIST}", [])
    dir_list.append(counter_dir)
    BuiltIn().set_test_variable("${COUNTER_DIRECTORY_LIST}", dir_list)
    if test_phase is not None:
        dir_dict = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_DICT}", {})
        dir_dict[test_phase] = counter_dir
        BuiltIn().set_test_variable("${COUNTER_DIRECTORY_DICT}", dir_dict)

    return counter_dir


def create_counter_list_and_get_counters_varaibles(print_dicts=False,
                                                   save_to_file=True,
                                                   outputdir=None,
                                                   timstamp_directory=True,
                                                   timeout=60,
                                                   *args
                                                   ):
    """
    This function create main list of counter based on lists added as args.
    Then function set variable (<counter>_DICT) with value of each counter from list.

    :author: Kamil Bucki
    :param print_dicts: printing value if True
    :param save_to_file: saving value to file if True
    :param outputdir: a path to counter files. OUTPUT_DIR in case of None
    :param timstamp_directory: separate directory with timestamp if true
    :param counter_list: a list with counters. COUNTER_LIST in case of None
    :param *args: Lists with counters
    :return: nothing
    """
    create_counter_list(*args)
    collect_counters_values(print_dicts=print_dicts,
                            save_to_file=save_to_file,
                            outputdir=outputdir,
                            timstamp_directory=timstamp_directory,
                            timeout=timeout
                            )


def load_counters_from_files(counter_dir, counter_list=None):
    """
    This function loads conters value from files in counter direcotry to <counter>_DICTvariable.

    :author: Kamil Bucki
    :param counter_dir: a path to direcotry with counters files
    :param counter_list: a lits with counters
    :return nothing
    """
    files = list_all_files_in_directory(directory=counter_dir)
    for file in files:
        counter_name = os.path.splitext(file)[0]
        if counter_list is None or counter_name in counter_list:
            value = load_json_file(os.path.join(counter_dir, file))
            BuiltIn().set_suite_variable("${}_DICT".format(counter_name), value)


def get_counter_value_for_timestamp(counter, timestamp, **params_to_get_value):
    """
    This function get counter value for specific time.

    :author: Kamil Bucki
    :param counter: counter name
    :param timestamp: timestamp of value
    :param **params_to_get_value: all needed parameters to get counter value
                                  e.g mnc, mcc, cell_num, bts_num, du_num, sst, sd
    :return value of counter
    """
    values = __get_counter_values(counter=counter, **params_to_get_value)
    value = values[timestamp]
    logger_console("Counters {} value for timestam {} is equal: {}".format(counter, timestamp, value))
    return value


def get_value_of_counters_for_timestamp(counters_list, timestamp, **params_to_get_value):
    """
    This function get values of counters from list for specific time.

    :author: Kamil Bucki
    :param counters_list: list of counters
    :param timestamp: timestamp of value
    :param **params_to_get_value: all needed parameters to get counter value
                                  e.g mnc, mcc, cell_num, bts_num, du_num, sst, sd
    :return dictionary with counters values
    """
    values = {}
    for counter in counters_list:
        values[counter] = get_counter_value_for_timestamp(counter=counter, timestamp=timestamp, **params_to_get_value)
    return values


def get_latest_counter_value(counter, **params_to_get_value):
    """
    This function get latest value of counter.

    :author: Kamil Bucki
    :param counter: counter name
    :param **params_to_get_value: all needed parameters to get counter value
                                  e.g mnc, mcc, cell_num, bts_num, du_num, sst, sd
    :return value of counter
    """
    values = __get_counter_values(counter=counter, **params_to_get_value)
    latest_val = values[sorted(values)[-1]]
    logger_console("Latest value of counter {} is equal: {}".format(counter, latest_val))
    return latest_val


def get_latest_value_for_counters(counters_list=None, common_timestamp=True, **params_to_get_value):
    """
    This function get latest values of counters from list.

    :author: Kamil Bucki
    :param counters_list: a list with counters. COUNTER_LIST in case of None
    :param common_timestamp: if True the values are collected from the same time
    :param **params_to_get_value: all needed parameters to get counter value
                                  e.g mnc, mcc, cell_num, bts_num, du_num, sst, sd
    :return dictionary with counters values
    """
    values = {}
    if counters_list is None:
        counters_list = BuiltIn().get_variable_value("${COUNTER_LIST}")

    if common_timestamp:
        common_counters = get_common_timestamps_for_counters(counters_list=counters_list, **params_to_get_value)
        common_counters.sort(reverse=True)
        latest_common_timestam = common_counters[0]
        msg = "Latest common timestamps: {}".format(latest_common_timestam)
        logger_console(msg)
        values = get_value_of_counters_for_timestamp(counters_list=counters_list,
                                                     timestamp=latest_common_timestam,
                                                     **params_to_get_value
                                                     )
    else:
        for counter in counters_list:
            values[counter] = get_latest_counter_value(counter=counter, **params_to_get_value)
    return values


def get_list_of_counter_values(counter, set_variable=False, **params_to_get_value):
    """
    This function get list of counter values.

    :author: Kamil Bucki
    :param counter: counter name
    :param set_variable: if True set <COUNTER>_LIST variable.
    :param **params_to_get_value: all needed parameters to get counter value
                                  e.g mnc, mcc, cell_num, bts_num, du_num, sst, sd
    :return counter value lis
    """
    values_dict = __get_counter_values(counter=counter, **params_to_get_value)
    values_list = values_dict.values()
    if set_variable:
        BuiltIn().set_suite_variable("${}_VALUES_LIST".format(counter), values_list)
    logger_console("The counters {} values list: {}".format(counter, values_list))
    return values_list


def get_list_of_values_for_counters(counters_list, set_variable=False, **params_to_get_value):
    """
    This function get list of values for each counters.

    :author: Kamil Bucki
    :param counter: counter name
    :param **params_to_get_value: all needed parameters to get counter value
                                  e.g mnc, mcc, cell_num, bts_num, du_num, sst, sd
    :return counter value lis
    """
    counters_values_dicrionary = {}
    for counter in counters_list:
        counters_values_dicrionary[counter] = get_list_of_counter_values(counter=counter,
                                                                         set_variable=set_variable,
                                                                         **params_to_get_value
                                                                         )
    return counters_values_dicrionary


def get_timestamp_on_gNB(test_phase_name=None):
    logger_console("Getting timestamp on GNB...")
    time = get_current_time_on_gnb(return_epoch=True)
    time = time.strip('\n')
    time = time.strip('\r')
    time = int(time)
    if test_phase_name is None:
        msg = "Collected timestamp: {}".format(time)
    else:
        msg = "Collected timestamp for {} phase: {}".format(test_phase_name, time)
    logger_console(msg)
    timestam_list = BuiltIn().get_variable_value("${COUNTER_TIMESTAMP_LIST}", [])
    timestam_list.append(time)
    BuiltIn().set_test_variable("${TEST_TIMESTAMP_LIST}", timestam_list)
    BuiltIn().set_test_variable("${LATEST_TEST_TIMESTAMP}", time)
    logger_console("Counter timestamp list: {}".format(timestam_list))
    logger_console("Latest counter timestamp: {}".format(time))
    if test_phase_name is not None:
        timestam_dict = BuiltIn().get_variable_value("${COUNTER_TIMESTAMP_DICT}", {})
        timestam_dict[test_phase_name] = time
        BuiltIn().set_test_variable("${TEST_TIMESTAMP_DICT}", timestam_dict)
        logger_console("Counter timestamp dictionary: {}".format(timestam_dict))
    return time


def _set_counter_variables_and_print_if_needed(counters_list,
                                               print_dict,
                                               outputdir=None,
                                               add_timestamp=False,
                                               timeout=60):
    logger_console("Collecting {} counter...".format(counters_list))
    all_counter_values = __get_pm_counters_values(counters_list=counters_list, timeout=timeout)
    counters_dict = __convert_counters_dict_to_seperate_dict(all_counter_values)
    if len(counters_list) > 1:
        counters_dict['ALL_COUNTERS'] = all_counter_values

    for counter, values in counters_dict.items():
        BuiltIn().set_suite_variable("${}_DICT".format(counter), values)

        if print_dict:
            __print_counter_dicts(counter, '{}_DICT'.format(counter))

        if outputdir:
            if add_timestamp:
                filename = os.path.join(outputdir, "{}_{}.json".format(counter, get_current_date()))
            else:
                filename = os.path.join(outputdir, "{}.json".format(counter))

            content = BuiltIn().get_variable_value("${}_DICT".format(counter))
            logger_console("Saving {} to file {}...".format(counter, filename))
            save_json_file(filename, content)


def __print_counter_dicts(counter, counter_dict):
    logger_console("\n{}\n{}\n".format(BuiltIn().get_variable_value("${}".format(counter)),
                                       BuiltIn().get_variable_value("${}".format(counter_dict))))


def __get_counter_values(counter, **params_to_get_value):
    logger_console("Getting counter {} values....".format(counter))
    counter_dict = BuiltIn().get_variable_value('${}_DICT'.format(counter))
    keys = __prepare_dictinary_keys_to_get_values(counter=counter, **params_to_get_value)
    values = __retrieve_counter_values_iterating_over_keys(counter_dict=counter_dict, keys=keys)
    return values


def __get_pm_counters_values(counters_list, timeout):
    values = get_pm_counters_values(counter_ids_list=counters_list, timeout=timeout)
    return values


def get_common_timestamps_for_counters(counters_list=None, **params_to_get_value):
    common_timestamps = None
    msg = "Searching common timestamps for counter: {}".format(counters_list)
    logger_console(msg)
    if counters_list is None:
        counters_list = BuiltIn().get_variable_value("${COUNTER_LIST}")
    for counter in counters_list:
        counter_timestamps = __get_counter_values(counter=counter, **params_to_get_value).keys()
        if common_timestamps is None:
            common_timestamps = counter_timestamps
        else:
            common_timestamps = [timestamp for timestamp in counter_timestamps if timestamp in common_timestamps]
    if len(common_timestamps) == 0:
        msg = "Cannot find common timestamp for counters: {}".format(counters_list)
        raise NotExistCommonTimestampForCounters(msg)
    msg = "Common timestamps: {}".format(common_timestamps)
    logger_console(msg)
    return common_timestamps


def __prepare_dictinary_keys_to_get_values(counter, **params_to_get_value):
    keys = __get_counter_dictionary_key(counter=counter)
    keys_to_get_value = []
    for key in keys:
        keys_to_get_value.append(__prepare_single_dictionary_key(key=key, **params_to_get_value))
    if None in keys_to_get_value:
        index_of_none = [index for index, value in enumerate(keys_to_get_value) if value is None]
        unsupported_parms_msg = ''
        for index in index_of_none:
            single_param_msg = '\nKey number {} should be similar to {}'.format(index, keys[index])
            unsupported_parms_msg = unsupported_parms_msg + single_param_msg

        msg = "Unsupported params in keys to get value of counter. \nAll needed keys: {}".format(keys_to_get_value)
        msg = msg + unsupported_parms_msg
        raise UnsupportedParamsInKeysToGetValueOfCounterException(msg)
    return keys_to_get_value


def __prepare_single_dictionary_key(key, **params_to_get_value):
    key_to_return = None
    if key in ['BTS', 'CELLS', 'NL1SL', 'NPSL', 'NCELA', 'NCUPL', 'NHRLC', 'PDCP1', 'RACDU', 'RSADU', 'ENDSS',
               'NRASU', 'NCUPNRG', 'NCAV', 'NDLSQ', 'RSACU', 'MRBTS']:
        key_to_return = key
    elif __check_if_counter_in_key(key):
        key_to_return = key
    elif 'NRCELL-' in key:
        key_to_return = __fill_nrcell_param(**params_to_get_value)
    elif 'MRBTS-' in key:
        key_to_return = __fill_mrbts_param(**params_to_get_value)
    elif 'NRBTS-' in key:
        key_to_return = __fill_nrbts_param(**params_to_get_value)
    elif 'NRDU-' in key:
        key_to_return = __fill_nrdu_param(**params_to_get_value)
    elif 'MCC-' in key:
        key_to_return = __fill_mcc_params(**params_to_get_value)
    elif 'MNC-' in key:
        key_to_return = __fill_mnc_params(**params_to_get_value)
    elif 'SST-' in key and 'SD-' in key:
        key_to_return = __fill_sst_and_sd_params(**params_to_get_value)
    elif 'NRRESOURCEGROUP-' in key:
        key_to_return = __fill_nrresgrp_param(**params_to_get_value)
    elif 'NRPMQAP-' in key:
        key_to_return = __fill_nrpmqap_param(**params_to_get_value)
    return key_to_return


def __fill_nrcell_param(**params_to_get_value):
    cell_number_key = 'cell_num'
    if cell_number_key in params_to_get_value.keys():
        cell_num = params_to_get_value.get(cell_number_key, None)
        return 'NRCELL-{}'.format(cell_num)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=cell_number_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_nrbts_param(**params_to_get_value):
    bts_number_key = 'bts_num'
    if bts_number_key in params_to_get_value.keys():
        bts_num = params_to_get_value.get(bts_number_key, None)
        return 'NRBTS-{}'.format(bts_num)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=bts_number_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_mrbts_param(**params_to_get_value):
    bts_number_key = 'mrbts_num'
    if bts_number_key in params_to_get_value.keys():
        bts_num = params_to_get_value.get(bts_number_key, None)
        return 'MRBTS-{}'.format(bts_num)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=bts_number_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_nrdu_param(**params_to_get_value):
    du_number_key = 'du_num'
    if du_number_key in params_to_get_value.keys():
        du_num = params_to_get_value.get(du_number_key, None)
        return 'NRDU-{}'.format(du_num)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=du_number_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_mcc_params(**params_to_get_value):
    mcc_key = 'mcc'
    if mcc_key in params_to_get_value.keys():
        mcc = params_to_get_value.get(mcc_key, None)
        return 'MCC-{}'.format(mcc)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=mcc_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_mnc_params(**params_to_get_value):
    mnc_key = 'mnc'
    if mnc_key in params_to_get_value.keys():
        mnc = params_to_get_value.get(mnc_key, None)
        return 'MNC-{}'.format(mnc)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=mnc_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_sst_and_sd_params(**params_to_get_value):
    sst_key = 'sst'
    sd_key = 'sd'
    if sst_key in params_to_get_value.keys() and sd_key in params_to_get_value.keys():
        sst = params_to_get_value.get(sst_key, None)
        sd = params_to_get_value.get(sd_key, None)
        return 'SST-{}_SD-{}'.format(sst, sd)
    else:
        missing = []
        if sst_key not in params_to_get_value.keys():
            missing.append(sst_key)
        if sd_key not in params_to_get_value.keys():
            missing.append(sd_key)

        missing_keys = ' and '.join(missing)
        msg = __create_msg_with_missing_param_in_kwargs(param_name=missing_keys,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_nrpmqap_param(**params_to_get_value):
    cell_number_key = 'nrpmqap'
    if cell_number_key in params_to_get_value.keys():
        cell_num = params_to_get_value.get(cell_number_key, None)
        return 'NRPMQAP-{}'.format(cell_num)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=cell_number_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __fill_nrresgrp_param(**params_to_get_value):
    cell_number_key = 'nrresgrp_id'
    if cell_number_key in params_to_get_value.keys():
        cell_num = params_to_get_value.get(cell_number_key, None)
        return 'NRRESOURCEGROUP-{}'.format(cell_num)
    else:
        msg = __create_msg_with_missing_param_in_kwargs(param_name=cell_number_key,
                                                        kwargs_name='params_to_get_value',
                                                        params_in_kwargs=params_to_get_value
                                                        )
        raise MissingKeyInDictionaryException(msg)


def __create_msg_with_missing_param_in_kwargs(param_name, kwargs_name, params_in_kwargs):
    msg = 'Cannot find {} key in **{} (**kwargs). Current params: {}'
    msg = msg.format(param_name, kwargs_name, params_in_kwargs)
    return msg


def __check_if_counter_in_key(key):
    m = re.search(r'^\w\d+\w\d+$', key)
    if m:
        return True
    else:
        return False


def __get_counter_dictionary_key(counter):
    counter_dict = BuiltIn().get_variable_value('${}_DICT'.format(counter))
    logger_console(counter_dict)
    matched, keys = __find_key_in_dictionary(dictionary=counter_dict, key_to_find=counter, keys_list=[])
    return keys


def __find_key_in_dictionary(dictionary, key_to_find, keys_list):
    matched = False
    dictionary_key = __get_first_key_of_dictionary(dictionary)
    if key_to_find == dictionary_key:
        keys_list.append(dictionary_key)
        matched = True

    else:
        keys_list.append(dictionary_key)
        matched, keys_list = __find_key_in_dictionary(dictionary=dictionary[dictionary_key],
                                                      keys_list=keys_list,
                                                      key_to_find=key_to_find
                                                      )
    return matched, keys_list


def __get_first_key_of_dictionary(dictionary):
    return list(dictionary.keys())[0]


def __retrieve_counter_values_iterating_over_keys(counter_dict, keys):
    rtn = counter_dict
    for k in keys:
        rtn = rtn[k]
    return rtn


def __convert_counters_dict_to_seperate_dict(counters_dict):
    counters = __find_counter_in_dictionary(dictionary=counters_dict, actual_keys="")
    dictionary_to_return = __create_dictorary_with_counter_as_key(path_values_dictionary=counters)
    return dictionary_to_return


def __find_counter_in_dictionary(dictionary, actual_keys):
    counters_dict = {}
    for key, value in dictionary.items():
        if __check_if_counter_in_key(key):
            counter_key = "{}{}".format(key, actual_keys)
            counters_dict[counter_key] = value
        else:
            new_key = "{}->{}".format(actual_keys, key)
            new_counter = __find_counter_in_dictionary(dictionary=value, actual_keys=new_key)
            counters_dict.update(new_counter)

    return counters_dict


def __create_dictorary_with_counter_as_key(path_values_dictionary):
    dictionary_to_return = {}
    for path, value in path_values_dictionary.items():
        path_list = path.split("->")
        dictionary_to_return = __add_value_to_dictionary(dictionary=dictionary_to_return,
                                                         path_list=path_list,
                                                         value=value
                                                         )
    return dictionary_to_return


def __add_value_to_dictionary(dictionary, path_list, value, add_conter_name_before_timestamp=True, counter_name=None):
    if len(path_list) == 1:
        if add_conter_name_before_timestamp and counter_name is not None:
            dictionary[path_list[0]] = {}
            dictionary[path_list[0]][counter_name] = value
        else:
            dictionary[path_list[0]] = value
    else:
        first_key = path_list[0]
        next_keys = path_list[1::]
        if __check_if_counter_in_key(first_key):
            counter_name = first_key
        if first_key not in dictionary:
            dictionary[first_key] = {}
        dictionary[first_key] = __add_value_to_dictionary(dictionary=dictionary[first_key],
                                                          path_list=next_keys,
                                                          value=value,
                                                          counter_name=counter_name
                                                          )

    return dictionary


def get_counter_timestamp_contain_test_timestamp(test_timestamp, counter_timestamp_list):
    after_timestam_list = get_timestamps_by_time_frame(min_time=test_timestamp,
                                                       max_time=999999999999,
                                                       timestamps_list=counter_timestamp_list
                                                       )
    after_timestam_list.sort()
    timestamp = after_timestam_list[0]
    return timestamp


def split_counters_timestamps(counters_timestamp_list, test_timestamp_list=None, counters_list=None):
    dictionary_to_return = {}
    if test_timestamp_list is None:
        test_timestamp_list = BuiltIn().get_variable_value("${TEST_TIMESTAMP_LIST}")
    test_timestamp_list.sort()
    timestamp_list_len = len(test_timestamp_list)
    max_index = timestamp_list_len - 1
    for timestamp in test_timestamp_list:
        timestam_index = test_timestamp_list.index(timestamp)
        if timestam_index == 0:
            min_time = 0
            key = ''
        else:
            min_time = timestamp
            key = str(min_time)
        if test_timestamp_list.index(timestamp) < max_index:
            max_time = test_timestamp_list[timestam_index + 1]
            key = "{}:{}".format(key, max_time)
        else:
            max_time = 999999999999999999999
            key = "{}:".format(key)

        dictionary_to_return[key] = get_timestamps_by_time_frame(min_time=min_time,
                                                                 max_time=max_time,
                                                                 timestamps_list=counters_timestamp_list
                                                                 )

    msg = "Counters timestamps splited by test timestamps: {}".format(dictionary_to_return)
    logger_console(msg)
    return dictionary_to_return


def get_timestamps_by_time_frame(min_time, max_time, timestamps_list):
    list_to_return = []
    for timestamp in timestamps_list:
        timestamp = int(timestamp)
        if min_time < timestamp < max_time:
            list_to_return.append(timestamp)

    return list_to_return


def counter_test():

    counters = BuiltIn().get_variable_value("${COUNTER_LIST}")
    # counters = ['M55139C02501', 'M55139C02502']
    # for counter in counters:
    #     logger_console(counter)
    params_to_get_counter_value = {
        'mcc': 311,
        'mnc': 489,
        'cell_num': 1,
        'bts_num': 1,
        'du_num': 1,
        'sst': 1,
        'sd': 13714341
    }

    test_timestamps = [1658838038, 1658838099, 1658838219, 1658838239, 1658838299, 1658838359]
    # collect_counters_values()
    load_counters_from_files(counter_dir='/home/ute/logi/timestamp_counter/counters/26072022_142559/')
    common_timestamps = get_common_timestamps_for_counters(**params_to_get_counter_value)
    podzielone = split_counters_timestamps(test_timestamp_list=test_timestamps,
                                           counters_timestamp_list=common_timestamps
                                           )
    logger_console("22")
    logger_console(common_timestamps)
    logger_console(podzielone)

    timmm = get_counter_timestamp_contain_test_timestamp(test_timestamp=1658838099,
                                                         counter_timestamp_list=common_timestamps
                                                         )
    logger_console(timmm)
    # for key, value in converted.items():
    #     logger_console("______________")
    #     logger_console(key)
    #     logger_console(value)

    # logger_console("returned {}".format(converted))
