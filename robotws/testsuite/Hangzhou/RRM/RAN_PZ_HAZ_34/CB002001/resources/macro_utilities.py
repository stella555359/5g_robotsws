import os
import glob
from taf.rfrl.utilities.robot.general import get_builtin_instance, get_builtin_value
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem


def get_latest_pm_file(pm_files_path):
    """ This function takes the PM_Files Path and returns the latest PM XML file.
    """
    pm_files_path_actual = os.path.join(pm_files_path,
                                        "pm_files/")
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


def is_cloud_bts(test_line='tl'):
    """
    Check Test line cloud BTS or not,
    :param test_line: Test line name, default value is tl
    :return: True if cloud else False
    """
    return get_builtin_instance('testlineInfo').has_cloudBts(get_builtin_value(test_line))


def is_coam(host_ip, port=3600):
    """
    Check Test line is cOAM,
    :param host_ip: Testline ip
    :param port: cOAM port, default 3600
    :return: True if Testline cOAM else False
    """
    cmd_output = OperatingSystem().run('nc -zv {} {}'.format(host_ip, port))
    if 'open' in cmd_output or 'succeeded' in cmd_output:
        return True
    elif 'No route to host' in cmd_output:
        BuiltIn().log('nc output: {}'.format(cmd_output), 'DEBUG')
        raise Exception('No route to {} host or host not reachable'.format(host_ip))
    else:
        return False


def get_temp_log_path():
    temp_log_path = util.get_builtin_value('TEMP_PATH')
    if temp_log_path is None:
        temp_log_path = '/tmp'
        if not os.path.exists(temp_log_path):
            os.makedirs(temp_log_path)
    return temp_log_path
