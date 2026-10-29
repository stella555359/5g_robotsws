import os
import glob
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
import datetime


def get_latest_pm_file(pm_files_path):
    """ This function takes the PM_Files Path and returns the latest PM XML file.
    """
    pm_files_path_actual = os.path.join(pm_files_path,
                                        "pm_files/")
    assert os.path.isdir(pm_files_path_actual), "PM Folder not present in directory"
    pm_files = glob.glob('{pm_path}*.xml'.format(pm_path=pm_files_path_actual))
    # return os.path.join(pm_files_path_actual, sorted(pm_files, key=sort_by_date_time)[-1])
    try:
        return os.path.join(pm_files_path_actual, sorted(pm_files, key=sort_by_date_time)[-1])
    except IndexError as e:
        return ""
    raise AssertionError('No PM xml found in {} '.format(pm_files_path))


def sort_by_date_time(pm_file_name):
    """ The PM file name is in the format /PM.BTS-72.20191017.120000.ANY.xml
    We are splitting by "." and returning the date and time fields which are index
    This will be used by the key function to sort the
    input file list.
    """
    pm_file_fields = pm_file_name.split(".")
    return pm_file_fields[-4], pm_file_fields[-3]


def get_log_path():
    log_path = get_builtin_value('LOG_PATH')
    if log_path is None:
        log_path = os.path.join(get_builtin_value('OUTPUT_DIR'), 'Logs/{}'.format(datetime.datetime.now().
                                                                                  strftime("%Y%m%d%H%M%S%f")))
    if not os.path.exists(log_path):
        os.makedirs(log_path)
    temp_log_path = os.path.join(log_path, 'tmp')
    if not os.path.exists(temp_log_path):
        os.makedirs(temp_log_path)
    return log_path


def get_temp_log_path():
    temp_log_path = get_builtin_value('TEMP_PATH')
    if temp_log_path is None:
        temp_log_path = '/tmp'
        if not os.path.exists(temp_log_path):
            os.makedirs(temp_log_path)
    return temp_log_path


def get_difference_between_lists(first_list, second_list):
    """
           Returns the list of items that are not present in first_list
           :param first_list: The list with which the comparison is going to be made against
           :param second_list: The new items in this list which are not present in first_list needs to be found
           :return: List of items that are not present in first_list
           contact : gopalakrishnan.n@nokia.com
           """
    return list(set(second_list).difference(set(first_list)))
