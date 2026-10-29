import json
import math
import time
from datetime import datetime
from taf.sbts.oam.coam.admin import admin as coam
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword

api = coam()


@logged_keyword
def get_counters(counter_ids):
    counters_dict = {}
    connection = api.connect_to(name='counter_gathering')
    try:
        counters_dict = api.get_pm_counters(counter_ids=counter_ids, connection=connection, timeout=300)
    except AdminApiProcedureFailureException as e:
        blog(e, level='ERROR')
    finally:
        api.teardown(connection=connection)
    return counters_dict


@logged_keyword
def find_pm_counters_by_timestamp(dates, pm_counters_dict, cell_list, bts_id,
                                  bts_counter_group, output_file_type='json', counter_type='NRRIP',
                                  bts_counter=False, calculate_dbm=False):
    counters_dict = {}
    dates = remove_whitespaces_from_list(dates)

    if not bts_counter:
        for cell_id in cell_list:
            counters_for_cell = get_pm_counters_for_cell(dates, pm_counters_dict, "NRCELL-" + str(cell_id),
                                                         counter_type, calculate_dbm)
            counters_dict.update({"NRCELL-" + str(cell_id): counters_for_cell})
    else:
        counters_dict = get_pm_counters_for_bts(dates, pm_counters_dict, bts_id,
                                                bts_counter_group, counter_type, calculate_dbm)

    save_counter_dict_to_file(dates, counters_dict, output_file_type)


@logged_keyword
def save_counter_dict_to_file(dates, counters_dict, output_file_type='json'):
    if output_file_type == 'json':
        blog("Saving counters to pm_counters_{}.json file.".format(dates), level='INFO')
        with open('pm_counters_{}.json'.format(dates), 'w') as file:
            json.dump(counters_dict, file, indent=4)
    else:
        try:
            blog("Saving counters to pm_counters_{}.xlsx file.".format(dates), level='INFO')
            import pandas as pd
            df = pd.DataFrame.from_dict({(i, j): counters_dict[i][j]
                                         for i in counters_dict.keys()
                                         for j in counters_dict[i].keys()},
                                        orient='index')
            df.to_excel('pm_counters_{}.xlsx'.format(dates))
        except ImportError:
            blog("Install pandas before using .xlsx format! Command: pip install pandas", level='ERROR')


@logged_keyword
def get_pm_counters_for_cell(dates, raw_pm_counters, cell_id, counter_type='NRRIP', calculate_dbm=False):
    try:
        if '/' in counter_type:
            pm_counters = raw_pm_counters['BTS']['CELLS'][cell_id][counter_type.split('/')[0]][
                counter_type.split('/')[1]]
        else:
            pm_counters = raw_pm_counters['BTS']['CELLS'][cell_id][counter_type]
    except KeyError as e:
        blog("Cannot find counters in {} group!".format(e), level='ERROR')
        raise

    return generate_output_dictionary(pm_counters, calculate_dbm, dates)


@logged_keyword
def get_pm_counters_for_bts(dates, raw_pm_counters, bts_id, bts_counter_group='NRDU-1',
                            counter_type='NF1CD', calculate_dbm=False):
    try:
        if bts_counter_group == '':
            if '/' in counter_type:
                pm_counters = raw_pm_counters['BTS']['BTS']['NRBTS-{}'.format(bts_id)][
                    counter_type.split('/')[0]][counter_type.split('/')[1]]
            else:
                pm_counters = raw_pm_counters['BTS']['BTS']['NRBTS-{}'.format(bts_id)][counter_type]
        else:
            if '/' in counter_type:
                pm_counters = raw_pm_counters['BTS']['BTS']['NRBTS-{}'.format(bts_id)][
                    bts_counter_group][counter_type.split('/')[0]][counter_type.split('/')[1]]
            else:
                pm_counters = raw_pm_counters['BTS']['BTS']['NRBTS-{}'.format(bts_id)][bts_counter_group][counter_type]
    except KeyError as e:
        blog("Cannot find counters in {} group!".format(e), level='ERROR')
        raise
    return generate_output_dictionary(pm_counters, calculate_dbm, dates)


@logged_keyword
def generate_output_dictionary(pm_counters, calculate_dbm, dates):
    timestamps = generate_timestamps_dictionary(dates)
    sorted_counter_names = sorted(list(pm_counters.keys()))
    output_counters_dictionary = {}
    for counter_name in sorted_counter_names:
        counter_values = pm_counters[counter_name]
        counter_content_dict = {}
        for counter_timestamp, counter_value in counter_values.items():
            if int(counter_timestamp) in timestamps.keys():
                if calculate_dbm:
                    if counter_value == 0:
                        dict_template = {timestamps[int(counter_timestamp)]: counter_value,
                                         "{}_dBm".format(timestamps[int(counter_timestamp)]): counter_value}
                        if not counter_content_dict:
                            counter_content_dict.update(dict_template)
                        else:
                            counter_content_dict = merge_dictionaries(counter_content_dict, dict_template)
                    else:
                        dbm_value = average_in_dbm(int(counter_value))
                        dict_template = {timestamps[int(counter_timestamp)]: counter_value,
                                         "{}_dBm".format(timestamps[int(counter_timestamp)]): dbm_value}
                        if not counter_content_dict:
                            counter_content_dict.update(dict_template)

                        else:
                            counter_content_dict = merge_dictionaries(counter_content_dict, dict_template)
                else:
                    dict_template = {timestamps[int(counter_timestamp)]: counter_value}
                    if not counter_content_dict:
                        counter_content_dict.update(dict_template)

                    else:
                        counter_content_dict = merge_dictionaries(counter_content_dict, dict_template)
        output_counters_dictionary.update({counter_name: counter_content_dict})

    if not output_counters_dictionary:
        blog("There are no counters for provided timestamp!"
             " Did you set correct timestamp?", level='ERROR')

    return output_counters_dictionary


@logged_keyword
def generate_names_of_counters(first_counter, last_counter, cb008021_feature=True):
    if cb008021_feature:
        blog("Generating counter names for CB008021...")
        return generate_CB008021_counter_list()
    else:
        blog("Generating counter names for custom counters set...")
        return generate_counters_string(first_counter, last_counter)


@logged_keyword
def generate_CB008021_counter_list():
    first_counter_set_1 = 'M55360C00000'
    last_counter_set_1 = 'M55360C00272'
    first_counter_set_2 = 'M55360C01000'
    last_counter_set_2 = 'M55360C01272'

    first_set_of_counters = generate_counters_string(first_counter_set_1, last_counter_set_1)
    second_set_of_counters = generate_counters_string(first_counter_set_2, last_counter_set_2)

    counter_id_string = first_set_of_counters + ',' + second_set_of_counters

    return counter_id_string


@logged_keyword
def generate_counters_string(first_counter, last_counter):
    prefix_counter_length = 7
    postfix_counter_length = 5
    prefix = first_counter[:prefix_counter_length]
    first_counter_postfix = int(first_counter[prefix_counter_length:])
    last_counter_postfix = int(last_counter[prefix_counter_length:])

    counter_list = []

    if not prefix == last_counter[:prefix_counter_length]:
        blog("Prefix from first counter: {0} is not equal to prefix from second counter: {1}"
             .format(prefix, last_counter[:prefix_counter_length]), level='ERROR')
        raise UserWarning

    for counter_iterator in range((last_counter_postfix - first_counter_postfix) + 1):
        counter_value = str(first_counter_postfix + counter_iterator).zfill(postfix_counter_length)
        counter_list.append(prefix + counter_value)
    counters_string = ",".join(counter_list)
    return counters_string


@logged_keyword
def merge_dictionaries(first_dict, second_dict):
    return dict(list(first_dict.items()) + list(second_dict.items()))


@logged_keyword
def remove_whitespaces_from_list(list_with_whitespaces):
    new_list = []
    for entry in list_with_whitespaces:
        new_list.append(entry.replace(" ", "_"))
    return new_list


@logged_keyword
def generate_timestamps_dictionary(dates):
    output_dictionary = {}
    for date in dates:
        date_format = datetime.strptime(date, "%Y-%m-%d_%H:%M:%S")
        unix_time = int(time.mktime(date_format.timetuple()))
        output_dictionary.update({unix_time: date})
    return output_dictionary


@logged_keyword
def average_in_dbm(aw):
    return 10 * math.log10(1000 * aw * pow(10, -18))
