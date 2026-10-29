import os
import re
import glob
import datetime
import logging
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from robot.api import TestSuiteBuilder
from moler.device import DeviceFactory


def get_latest_pm_file(pm_files_path):
    """ This function takes the PM_Files Path and returns the
    latest PM XML file.
    """
    pm_files_path_actual = os.path.join(pm_files_path,
                                        "pm_files/")
    assert os.path.isdir(pm_files_path_actual), \
        "PM Folder not present in directory"
    pm_files = glob.glob('{pm_path}*.xml'.
                         format(pm_path=pm_files_path_actual))
    return os.path.join(pm_files_path_actual, sorted(
        pm_files, key=sort_by_date_time)[-1])


def sort_by_date_time(pm_file_name):
    """ The PM file name is in the format /PM.BTS-72.20191017.120000.ANY.xml
    We are splitting by "." and returning the date and time fields
    which are index
    2 and 3 respectively. This will be used by the key function to sort the
    input file list.
    """
    pm_file_fields = pm_file_name.split(".")
    return pm_file_fields[2], pm_file_fields[3]


def get_builtin_value(param_name, default=None):
    """
    Get robot builtin  variable value, default will return if variable
    not found
    :param param_name: variable name
    :param default: default value to return if variable not available
    """
    return BuiltIn().get_variable_value('${{{}}}'.format(param_name), default)


def set_robot_suite_variable(param_name, param_value):
    """
    Set Robot Builtin variable.
    :param param_name: variable name
    :param param_value: value
    """
    BuiltIn().set_suite_variable('${{{}}}'.format(param_name), param_value)


def set_robot_test_variable(param_name, param_value):
    """
    Set Robot Builtin variable.
    :param param_name: variable name
    :param param_value: value
    """
    BuiltIn().set_test_variable('${{{}}}'.format(param_name), param_value)


def get_builtin_instance(instance_name, default=None):
    """
    Get Robot Builtin library instance
    :param instance_name:  library instance name
    :param default: return default instance if not available
    """
    return BuiltIn().get_library_instance('{}'.format(instance_name), default)


def is_cloud_bts(test_line='tl'):
    """
    Check Test line cloud BTS or not,
    :param test_line: Test line name, default value is tl
    :return: True if cloud else False
    """
    return get_builtin_instance('testlineInfo').\
        has_cloudBts(get_builtin_value(test_line))


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
        raise Exception('No route to {} host or host not reachable'.
                        format(host_ip))
    else:
        return False


def get_log_path():
    log_path = get_builtin_value('LOG_PATH')
    if log_path is None:
        log_path = os.path.join(
            get_builtin_value('OUTPUT_DIR'),
            'Logs/{}'.format(datetime.datetime.now().
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


def set_test_case_log_path():
    _log_path = os.path.join(get_builtin_value('OUTPUT_DIR'),
                             get_builtin_value('SUITE NAME'),
                             get_builtin_value('TEST NAME'))

    log_path = re.sub(r'\s+', '_', _log_path)
    set_robot_suite_variable(param_name='LOG_PATH', param_value=log_path)
    return log_path


def load_moler_configuration_from_tl():
    """
    Loading moler configuration before run function which needs moler
    configuration.
    Sample usage:
    from utilities import load_moler_configuration_from_tl

    @load_moler_configuration_from_tl()
    def some_method_which_use_moler_device(self):
        pass

    :return: wrapped function.
    """
    from taf.ul.moler.converter import load_moler_configuration

    tl = get_builtin_value(param_name="tl")
    log_dir = os.path.join(get_builtin_value(param_name="OUTPUT DIR"), "moler")

    logger_params = {
        'PATH': log_dir,
        'DEBUG_LEVEL': "INFO"
    }

    return load_moler_configuration(tl,
                                    create_at_startup=False,
                                    logger_params=logger_params)


@load_moler_configuration_from_tl()
def modify_moler_logging_directory(mode='suite'):
    """
    Change moler logs directory to current suite name/test case name -
    it's dependant on mode parameter

    :param mode:    Could be: 'suite'/'test case' -
    """
    from moler.config import reconfigure_logging_path
    if mode == 'test case':
        _dir_name = get_builtin_value(param_name="TEST NAME")
    else:
        _dir_name = get_builtin_value(param_name="SUITE NAME")
    dir_name = _dir_name.split(".")[-1]
    log_dir = os.path.join(get_builtin_value(param_name="OUTPUT DIR"),
                           "moler", dir_name)
    reconfigure_logging_path(logging_path=log_dir)


def close_all_moler_connections():
    """
    Close all moler device connections
    """
    from taf.ul.moler.converter import close_all_moler_connections
    close_all_moler_connections()


def get_difference_between_lists(first_list, second_list):
    """
           Returns the list of items that are not present in first_list
           :param first_list: The list with which the comparison is going
           to be made against
           :param second_list: The new items in this list which are not
           present in first_list needs to be found
           :return: List of items that are not present in first_list
           contact : gopalakrishnan.n@nokia.com
           """
    return list(set(second_list).difference(set(first_list)))


def get_timestamp():
    return "[{}]".format(datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'))


def get_commissioning_dir():
    location, testline_name = get_configuration()
    branch = get_commissioning_branch()
    if location and testline_name and branch:
        repository_path = get_repository_path()
        commissioning_dir = os.path.join(
            repository_path, 'commissionings', location, testline_name, branch)

        return commissioning_dir


def get_configuration():
    configuration = get_builtin_value('CONFIGURATION')
    if configuration:
        location, testline_name = configuration.split('.')
        return location, testline_name
    else:
        logging.warning("CONFIGURATION not defined. "
                        "Please run your test with CONFIGURATION variable eg: "
                        "-v CONFIGURATION:Krakow.7_7CLOUDT459")


def get_commissioning_branch():
    build_tag = get_builtin_value('ENB_BUILD')
    if build_tag:
        branch_tag = build_tag.split("_")[0]
        if branch_tag == "5G":
            run_tag = "TRUNK"
        else:
            run_tag = branch_tag
        return run_tag
    else:
        logging.warning("ENB_BUILD not defined. Please run "
                        "your test with ENB_BUILD variable eg: "
                        "-v ENB_BUILD:5G20A_9.1800.1313")


def get_sw_package_dir():
    build_tag = get_builtin_value('ENB_BUILD').split("_")[-1]
    return "/tmp/AirScale-{}.zip".format(build_tag)


def get_repository_path():
    current_dir = os.path.dirname(os.path.abspath(__file__))
    repository_path = os.path.abspath(
        os.path.join(current_dir, '..', '..', '..'))
    return repository_path


def return_all_key_paths_and_values_from_iterable(iterable, path_to_value=''):
    """
    author:         Grzegorz Kaczor, grzegorz.kaczor@nokia.com
    maintainer:     Grzegorz Kaczor, grzegorz.kaczor@nokia.com
    """
    all_values = []
    sub_elements = [iterable]
    while sub_elements:
        element = sub_elements.pop()
        if isinstance(element, list):
            sub_elements.extend(element)
        if isinstance(element, dict):
            for found_key, value in element.items():
                if isinstance(value, list) or isinstance(value, dict):
                    all_values.extend(
                        return_all_key_paths_and_values_from_iterable(
                            value,
                            path_to_value + ": {} ".format(found_key)))
                else:
                    all_values.append((path_to_value + ": {} ".
                                       format(found_key), value))
    return all_values


@load_moler_configuration_from_tl()
def dump_current_disk_space_usage_on_ute_vm():
    unix_local = DeviceFactory.get_device(name='UnixLocal')
    unix_local.get_cmd(cmd_name="df")()
    unix_local.get_cmd(
        cmd_name="du",
        cmd_params={"options": '-Sh /home/ute | sort -rh | head -10'})()
    unix_local.get_cmd(
        cmd_name="du",
        cmd_params={"options": '-Sh /tmp | sort -rh | head -10'})()


def get_custom_config_yaml_path():
    _re_yaml_path = r"(?P<prefix>.*)" \
                    r"(?P<config>CONFIGS_(?P<path>[\w|\/|-]+\.(yaml|yml)))" \
                    r"(?P<suffix>.*)"
    path = get_builtin_value('SUITE_SOURCE')
    build = get_builtin_value('ENB_BUILD')
    test_tags = get_builtin_value("TEST_TAGS")
    tags = test_tags if test_tags else _get_suite_tags_variable(path=path)
    config_tags = [re.search(_re_yaml_path, tag).string
                   for tag in tags if re.search(_re_yaml_path, tag)]
    custom_config_path = ""
    if len(config_tags) > 1:
        for ct in config_tags:
            suffix = re.search(_re_yaml_path, ct).group('suffix')
            prefix = re.search(_re_yaml_path, ct).group('prefix')
            branch_stream = _select_branch_stream(build=build)
            if branch_stream in suffix or branch_stream in prefix:
                custom_config_path = ct
                break
    elif config_tags:
        custom_config_path = config_tags[0]
    else:
        logging.warning('CONFIGS tags not defined in the testsuite. '
                        'Please add '
                        'CONFIGS tag with yaml path as a value,'
                        'eg: CONFIGS_Krakow/CLOUD_5G_ASIKR_ABILB4_AEUD/TRUNK/'
                        'config.yaml'
                        ' OR select another SCF selection method')
    custom_config_path = re.search(_re_yaml_path, custom_config_path).\
        group('path')
    repository_path = get_repository_path()
    custom_config_yaml = os.path.join(repository_path,
                                      'custom-config',
                                      custom_config_path)
    return custom_config_yaml


def _select_branch_stream(build):
    branch_stream_dictionary = {
        "master_pDU": "5G_0.400",
        "21B_pDU": "5G21B_12.400",
        "SBTS21B": "SBTS21B_ENB_0000",
        "SBTS00": "SBTS00_ENB_9999",
        "21A_classicalbts": "5G21A_11.800"
    }
    for k, v in branch_stream_dictionary.items():
        if v in build:
            return k


def _get_suite_tags_variable(path):
    suite = TestSuiteBuilder().build(path)
    tests = [test for test in suite.tests]
    tags = []
    for test in tests:
        tags += test.tags
    tags = list(set(tags))
    return tags
