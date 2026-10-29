import os
import glob
import re
from taf.analyzer.pmcounter import PMCounterLogReader


def get_cell_counter_value_from_pm_file(pm_file, counter_name, cell_id=1, index=0):
    return get_counter_value_from_pm_file_for_object(pm_file, "NRCELL", counter_name, cell_id, index)


def get_all_cell_counters_from_pm_file(pm_file, cell_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = get_cell_counter_value_from_pm_file(pm_file, counter_name, cell_id, index)
    return counter_values


def get_counter_value_from_pm_file_for_object(pm_file, object_name, counter_name, object_id=1, index=0):
    pm_xpath = "//{object_name}[@id='{object_id}']//@{counter_name}".format(object_name=object_name,
                                                                            object_id=object_id,
                                                                            counter_name=counter_name)
    with open(pm_file) as file_obj:
        for log_entry in PMCounterLogReader(file_obj_iterator=[file_obj]):
            if len(log_entry.pm_setup.xpath(pm_xpath)) != 0:
                counter = log_entry.pm_setup.xpath(pm_xpath)[index]
        try:
            return counter
        except NameError:
            raise Exception("Counter value not found in file %s" % (pm_file))


def get_all_counters_from_pm_file_for_object(pm_file, object_name, object_id, index, counters):
    counter_values = {}
    for counter_name in counters:
        counter_values[counter_name] = get_counter_value_from_pm_file_for_object(pm_file,
                                                                                 object_name,
                                                                                 counter_name,
                                                                                 object_id,
                                                                                 index)
    return counter_values


def get_latest_pm_file(pm_files_path):
    """ This function takes the PM_Files Path and returns the latest PM XML file.
    """
    pm_files_path_actual = os.path.join(pm_files_path, "gnb_pm_counters/")
    assert os.path.isdir(pm_files_path_actual), "PM Folder not present in directory"
    pm_files = glob.glob('{pm_path}*.xml'.format(pm_path=pm_files_path_actual))
    return os.path.join(pm_files_path_actual, sorted(pm_files, key=sort_by_date_time)[-1])


def sort_by_date_time(pm_file_name):
    """ The PM file name is in the format /PM.BTS-72.20191017.120000.ANY.xml
    We are splitting by "." and returning the date and time fields which are index
    2 and 3 respectively. This will be used by the key function to sort the
    input file list.
    """
    pm_file_fields = pm_file_name.split(".")
    return pm_file_fields[2], pm_file_fields[3]


# example line: {b'2021-01-15 16:35:00+01:00': {'M55324C00000': {b'MRBTS-50050/NRBTS-50050/NRCELL-1': b'3000',
# b'MRBTS-50050/NRBTS-50050/NRCELL-2': b'0', b'MRBTS-50050/NRBTS-50050/NRCELL-3': b'0'}}},
# example output: {'M55324C00000': {'1': 3000, '2': 0, '3': 0}}


def get_latest_counters_values(counter_file):
    counter_list = []
    ret_counters_dict = {}
    counter_file.reverse()

    for elem in counter_file:
        line = elem.values()[0]  # get line without datetime
        counter = line.keys()[0]  # get M55324C00000
        counter_values = line.values()[0]  # get values of counter

        if counter_values != {}:
            if counter not in counter_list:
                counter_list.append(counter)
                symbols = {}
                counter_paths = counter_values.keys()
                counter_paths.sort()

                for path in counter_paths:
                    cell_path = counter_values.keys()[0]
                    nr_cell = re.findall(r"[\d]*$", path)[0]
                    symbols[nr_cell] = int(counter_values[path])
                ret_counters_dict[counter] = symbols
    return ret_counters_dict


def resolve_oam_type_name(name):
    name = str(name)
    if 'mz' in name.lower() or 'mega' in name.lower():
        return 'mzoam'
    elif 'coam' in name.lower() or 'common' in name.lower():
        return 'coam'
    return None
