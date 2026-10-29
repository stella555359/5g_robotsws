"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from robot.utils.robottime import timestr_to_secs
from robot.api import logger

from ta5g_testline_management import ta5g_testline_management
from ta5g_interface_tools import ta5g_interface_tools

from ute_common_admin.exception import (
    AdminApiConnectionClosedException,
    AdminApiProcedureFailureException,
    AdminApiProcedureTimeoutException
)

from taf.gnb.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.config.scf import scf
from ta5g_scfc_analysis import ta5g_scfc_analysis
from string import Template
from functools import wraps
import xml.dom.minidom
import shutil
import glob
import time
import json
import sys
import os
import io
import re

from file_management import load_json_file, save_json_file
from utilities import logger_console, logger_console_info


class RadioHeadTimeoutException(Exception):
    """Custom exception raised if Radio Head persistently fails to go online
    """

    def __init__(self, msg, status):
        self.msg = msg
        self.status = status

    def __str__(self):
        return repr("{} {}".format(self.msg, self.status))


class NotKnownCellIdException(Exception):
    """Custom exception raised, if Physical Cell ID cannot be retrieved from SCF file.
    """
    pass


def handle_admin(func):
    """Wrapper function handling setting up and teardown of admin connection. Meant to be used as a decorator.
    Usage: when used in a function, in arguments **kwargs need to be specified.
    Then connection object to Admin API can be obtained using kwargs["connection"] syntax.

    Wrapper takes bts hostname, username and password from robot variables (GNB_IP, WEBEM_USERNAME, WEBEM_PASSWORD).
    When no such variables are recognised, connection to Admin API is established using default values of
    admin.connect_to() method.

    Wrapper also handles Admin exceptions, mainly AdminApiProcedureFailureException
    and AdminApiConnectionClosedException.
    For recognised AdminApiProcedureFailureException function handles the exceptions accordingly. I.e. for
    error_code==27 (BTS is not ready due to ongoing RNW Plan File activation) function will wait 1min and retry the
    operation until the function succeeds or results in another exception.
    Uses functools.wraps because of https://github.com/sphinx-doc/sphinx/issues/3783

    :param func: function on which the wrapper is used
    :return: result of taf.gnb.oam.coam.admin function
    """
    @wraps(func)
    def inner(*args, **kwargs):
        admin_instance = admin()
        bts_host = BuiltIn().get_variable_value("${GNB_IP}")
        username = BuiltIn().get_variable_value("${WEBEM_USERNAME}")
        password = BuiltIn().get_variable_value("${WEBEM_PASSWORD}")
        if all(var is not None for var in [bts_host, username, password]):
            connection = admin_instance.connect_to(
                bts_host=bts_host,
                username=username,
                password=password
            )
        else:
            connection = admin_instance.connect_to()
        result = None
        timeoutRetry = True
        rnw_retries = 30
        while True:
            try:
                result = func(connection=connection, *args, **kwargs)
                break
            except AdminApiProcedureFailureException as e:
                error_code = re.search(r'ErrorCode.\s*(\d+)', e.args[0])
                if error_code:
                    if int(error_code.group(1)) == 27 and rnw_retries > 0:
                        logger_console("BTS is not ready due to ongoing RNW Plan File activation. "
                                       "Will retry after 60s")
                        for _ in range(60):
                            logger.console('.', newline=False)
                            time.sleep(1)
                        rnw_retries -= 1
                        continue
                    if int(error_code.group(1)) == 7:
                        logger_console("Counters not yet available")
                        time.sleep(60)
                        continue
                logger_console(
                    "AdminApiProcedureFailureException caught: {}".format(e.args[0]))
                raise
            except AdminApiProcedureTimeoutException as e:
                if timeoutRetry is True:
                    timeoutRetry = False
                    logger_console(
                        "AdminApiProcedureTimeoutException occurred, retrying the operation one more time..."
                    )
                    time.sleep(30)
                    continue
                else:
                    raise
            except AdminApiConnectionClosedException as e:
                admin_instance.teardown_admin()
                logger_console(
                    "AdminApiConnectionClosedException occurred. Probably port is closed.")
                raise
            except Exception as e:
                logger_console(
                    "Unexpected exception occurred: {}".format(e.args))
                raise
        admin_instance.teardown_admin()
        return result
    return inner


def wait_till_admin_is_online(retry=30, retry_interval=30):
    """Function waits until the Admin Api is available for the user. Sometimes after bts reboot AdminApi is unavailable
    for a long time, resulting in an error AdminApiConnectionClosedException.
    This function aims to resolve this problem.
    :param retry: count of retries
    :param retry_interval: interval between retries, in seconds
    """
    admin_instance = admin()
    bts_host = BuiltIn().get_variable_value("${GNB_IP}")
    username = BuiltIn().get_variable_value("${WEBEM_USERNAME}")
    password = BuiltIn().get_variable_value("${WEBEM_PASSWORD}")
    logger_console("Waiting for ADMIN API to be available")
    while retry > 0:
        try:
            if all(var is not None for var in [bts_host, username, password]):
                connection = admin_instance.connect_to(
                    bts_host=bts_host,
                    username=username,
                    password=password
                )
            else:
                connection = admin_instance.connect_to()
            break
        except AdminApiConnectionClosedException as e:
            logger.info(
                "AdminApiConnectionClosedException: AdminApi is still offline")
        except Exception as e:
            logger.info("EXCEPTION: {} {}".format(e.args, e.message))
            raise
        time.sleep(retry_interval)
        retry -= 1
    admin_instance.teardown_admin()
    if retry == 0:
        raise AdminApiConnectionClosedException(
            "Could not connect to AdminApi.")


def execute_command_on_the_remote(cmd, hostname, username, password):
    """Wrapper for taf ssh library remote command execution.

    :param cmd: string of command to execute
    :param hostname: hostname of the remote
    :param username: username of the remote
    :param password: password of the remote
    :return: Tuple(exit_code, output)
    """
    ssh_instance = ssh()
    ssh_instance.connect_to(
        hostname=hostname, username=username, password=password)
    output = ssh_instance.execute(cmd)
    rc = ssh_instance.get_exit_status()
    ssh_instance.disconnect()
    return rc, output


def run_on_gnb(cmd, hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"):
    """Execute command on gNB
    :param cmd: command
    :param hostname: bts hostname
    :param username: bts username
    :param password: bts password
    :return: Tuple(exit_code, output)
    """
    return execute_command_on_the_remote(cmd, hostname, username, password)


def run_on_ap(cmd, hostname="192.168.200.1", username="toor4nsn", password="oZPS0POrRieRtu"):
    """Execute command on AirPhone
    :param cmd: command
    :param hostname: AP hostname
    :param username: AP username
    :param password: AP password
    :return: Tuple(exit_code, output)
    """
    return execute_command_on_the_remote(cmd, hostname, username, password)


@handle_admin
def reset_site_via_admin(*args, **kwargs):
    """Reset bts via AdminApi
    """
    kwargs["connection"].reset_site()


def reset_units():
    """Perform safe system module reboot on AirPhone and reset of bts via AdminApi.
    """
    run_on_ap(cmd="system-module-reboot")
    reset_site_via_admin()


def add_ip_addr_on_vm(ip_addr, interface):
    """Add IP address on the virtual machine.

    :param ip_addr: IP address to be added
    :param interface: name of interface on which the IP should be added
    :return:
    """
    OperatingSystem().run('sudo ip addr add {} dev {}'.format(ip_addr, interface))


def delete_ip_addr_on_vm(ip_addr, interface):
    """Delete IP address on the virtual machine.

    :param ip_addr: IP address to be deleted
    :param interface: name of interface on which the IP should be deleted
    :return:
    """
    OperatingSystem().run('sudo ip addr del {} dev {}'.format(ip_addr, interface))


@handle_admin
def get_radio_module_status(*args, **kwargs):
    """Get radio module status. Available statuses: offline, online, notinstalled

    :return: radio module availability status
    """
    bts_hw_info = kwargs["connection"].get_bts_info()
    availability_status = bts_hw_info['radioModules']['rmod'][0]['status'].setdefault(
        'availabilityStatus', "online")
    logger_console("Radio state: {}".format(availability_status))
    return availability_status


def wait_for_radio_module_to_be_online(retry=15, retry_interval=30):
    """Waits until radio module is online, repeatedly

    :param retry: max number of retries
    :param retry_interval: interval between the retries
    """
    status = ""
    while retry > 0:
        retry -= 1
        status = get_radio_module_status()
        if status.lower() == "online":
            break
        time.sleep(retry_interval)
    if retry == 0:
        raise RadioHeadTimeoutException(
            'Radio module could not go online!', "Radio module status: {}".format(status))


def reset_units_and_wait_for_radio_head_online():
    """Function handy while setting up an environment. Resets units, waits for icmp echo replies (ping answering),
    ADMIN API availability and radio module to go online.
    """
    ta5g_tm_instance = ta5g_testline_management()
    logger_console("Resetting units")
    reset_units()
    logger_console("Waiting till testline LMP interfaces become pingable")
    ta5g_tm_instance.wait_for_testline_icmp_echo_replies_and_ssh_services()
    wait_till_admin_is_online()
    wait_for_radio_module_to_be_online()


@handle_admin
def load_scf_from_site_and_get_taf_scf_instance(*args, **kwargs):
    """Function loads and returns taf scf file instance.

    :param args:
    :param kwargs:
    :return: taf scf file instance
    """
    taf_scf_lib_instance = scf()
    configuration = kwargs["connection"].get_scf()
    python3 = sys.version_info > (3,)
    if python3:
        file_obj = io.BytesIO(bytes(configuration, encoding='utf8'))
    else:
        file_obj = io.BytesIO(bytes(configuration.encode('utf8')))
    taf_scf_lib_instance.load_scf(file_obj)
    return taf_scf_lib_instance


def get_parameter_value_from_scf(dist_name, parameter=None, list_name=None, index=None):
    """Get parameter value from scf. Function is a wrapper of functionality of an scf taf library.

    :param dist_name: dist_name
    :type dist_name: string
    :param parameter: parameter name
    :param list_name: name of the list in which the parameter resides
    :type list_name: string, optional
    :param index: index of the element in a list
    :type index: integer, optional
    :return: value of parameter
    """
    value = load_scf_from_site_and_get_taf_scf_instance().get_value_from_scf(dist_name=dist_name,
                                                                             p_name=parameter,
                                                                             list_name=list_name,
                                                                             index=index)
    return value


def get_values_of_parameters_from_scf(dist_name, parameter_list, *args, **kwargs):
    """Get values of specified parameters from current configuration in SCF.
        | Parameter parameter_list syntax should be as follows: [ {"parameter": "gNbId"}, {"parameter": "lcrId"} ]
        | For parameters in lists: [ {"parameter": "mcc", "list_name": gnbPlmn}, ]
        | If there is more than 1 match expected: [ {"parameter": "mcc", "list_name": gnbPlmn, "index": 0}, ]

    :param dist_name: dist_name
    :type dist_name: string
    :param parameter_list: list of dictionaries with parameters
    :return: dictionary with parameters names as keys and their values as dictionary values
    """
    taf_scf_lib_instance = load_scf_from_site_and_get_taf_scf_instance()
    values_list = []
    for elem in parameter_list:
        parameter = elem["parameter"] if "parameter" in elem.keys() else None
        list_name = elem["list_name"] if "list_name" in elem.keys() else None
        index = elem["index"] if "index" in elem.keys() else None
        value = taf_scf_lib_instance.get_value_from_scf(dist_name=dist_name, p_name=parameter,
                                                        list_name=list_name, index=index)
        param_dict = {"value": value}
        if parameter is not None:
            param_dict["parameter"] = parameter
        if list_name is not None:
            param_dict["list_name"] = list_name
        if index is not None:
            param_dict["index"] = index
        values_list.append(param_dict)
    return values_list


@handle_admin
def update_parameter_value(parameter, value=None, operation="update", dist_name="MRBTS-1/NRBTS-1", *args, **kwargs):
    """Update value of a parameter in SCF.

    :param parameter: parameter name
    :param value: desired value of the parameter
    :param operation: operation to perform; defaults to "update"
    :param dist_name: dist_name
    :type dist_name: string
    :param args:
    :param kwargs:
    """
    kwargs["connection"].perform_parameter_recommissioning(dist_name=dist_name,
                                                           parameter=parameter,
                                                           operation=operation,
                                                           value=value,
                                                           skip_parameter_relation_errors=True)


def assert_parameter_value(dist_name, parameter, value, list_name=None, index=None):
    """Asserts the value of a parameter in SCF.

    :param dist_name: dist_name
    :type dist_name: string
    :param parameter: parameter name
    :param value: required value of the parameter
    :param list_name: name of the list in which the parameter resides
    :type list_name: string, optional
    :param index: index of the element in a list
    :type index: integer, optional
    :return:
    """
    real_value = get_parameter_value_from_scf(dist_name=dist_name, parameter=parameter,
                                              list_name=list_name, index=index)
    assert str(real_value) == str(value), "Parameter {} in {} is not equal to {}; real value = {}".format(
        parameter, dist_name, value, real_value)


@handle_admin
def get_bts_state(*args, **kwargs):
    """Get current bts state info.

    :return: string with bts state with lowered characters
    """
    bts_info = kwargs["connection"].get_mrbts_state().lower().replace(" ", "")
    logger_console('Current BTS state: {}'.format(bts_info))
    return bts_info


def assert_bts_in_state(bts_state):
    """Assert that bts is in the specified state.

    :param bts_state: desired bts state
    """
    bts_info = get_bts_state()
    assert bts_info == bts_state.lower().replace(" ", ""), "BTS state other than excepted: {} vs {}".format(
        bts_info, bts_state)


def assert_gnb_in_either_of_the_following_states(list_of_states):
    """Assert bts state matches with one specified in list_of_states.
    Example states are: "notcommissioned", "commissioned", "configured", "onair".

    :param list_of_states: list with acceptable bts states
    :return: string with bts state with lowered characters
    """
    state = get_bts_state()
    list_of_states = [elem.lower().replace(" ", "") for elem in list_of_states]
    assert state.lower() in list_of_states, "gNB is in unexpected state: {}".format(state)
    return state


def assert_gnb_did_not_drop_to_lower_state(original_state):
    """Check if bts did not drop to lower state.
    Normal bts state progress goes from commissioned -> configured -> onair.
    This function compares the original_state value with the current bts state and checks that the current
    state is not below the original_state.

    :param original_state: The previous state used for comparison
    """
    list_of_states = ["notcommissioned", "commissioned", "configured", "onair"]
    idx_orig_state = list_of_states.index(
        original_state.lower().replace(" ", ""))
    idx_current_state = list_of_states.index(get_bts_state())
    assert idx_current_state >= idx_orig_state


@handle_admin
def get_critical_or_major_alarms(*args, **kwargs):
    """Get info pertaining critical or major bts alarms.

    :return: Tuple(num_of_critical_or_major_alarms, python set with the observed alarms)
    """
    alarms = kwargs["connection"].get_active_alarms()
    num_of_critical_or_major_alarms = 0
    alarms_set = set()
    for alarm in alarms:
        if alarm["severity"] == "Critical" or alarm["severity"] == "Major":
            num_of_critical_or_major_alarms += 1
            logger.info(alarm)
            alarms_set.add(alarm['faultId'])
    return num_of_critical_or_major_alarms, alarms_set


def assert_no_new_major_or_critical_alarms_appeared(previous_num_of_alarms=0, previous_alarms_set=None):
    """Check if no new major or critical alarms appeared. Works with get_critical_or_major_alarms method.

    :param previous_num_of_alarms: number of alarms to compare against
    :param previous_alarms_set: set of alarms to compare against
    """
    current_num, current_alarms_set = get_critical_or_major_alarms()
    new_alarms = current_alarms_set.difference(previous_alarms_set)
    if new_alarms:
        for fault_id in new_alarms:
            for alarm in current_alarms_set:
                if int(alarm) == int(fault_id):
                    logger_console(
                        "New alarm failing execution: {}".format(alarm))
        raise Exception("New alarm(s) occurred: {}".format(new_alarms))
    assert int(
        previous_num_of_alarms) >= current_num, "New major or critical fault appeared! Check info logs."


@handle_admin
def get_counter_values(counter_id, timeout=100, *args, **kwargs):
    """Wrapper function of admins get_pm_counters.

    :param counter_id: id of the counter, in a string
    :param timeout: timeout
    :return: dictionary with parameter values and corresponding timestamps in epoch
    """
    counters = kwargs["connection"].get_pm_counters(
        couter_ids=counter_id, timeout=timeout)
    logger.info(counters)
    return counters


@handle_admin
def get_dist_names_matching_given_class(class_pattern, *args, **kwargs):
    configuration = kwargs["connection"].get_scf(export_type="configuration")
    xmldom = xml.dom.minidom.parseString(configuration)
    itemlist = xmldom.getElementsByTagName('managedObject')

    dist_names = [item.attributes['distName'].value for item in itemlist
                  if item.attributes['class'].value.endswith(class_pattern)]
    return dist_names


@handle_admin
def get_all_dist_names(*args, **kwargs):
    """Get list of all dist_names in an SCF.

    :return: list of all dist_names
    """
    configuration = kwargs["connection"].get_scf(export_type="configuration")
    xmldom = xml.dom.minidom.parseString(configuration)
    itemlist = xmldom.getElementsByTagName('managedObject')

    dist_names = [item.attributes['distName'].value for item in itemlist]
    return dist_names


def assert_existence_of_dist_name(dist_name):
    """Assert existence of a specified dist_name in SCF configuration.
    Functionality is replaced by assert_existence_of_an_object method!
    :param dist_name: dist_name
    :type dist_name: string
    """
    all_dist_names = get_all_dist_names()
    assert dist_name in all_dist_names


def is_object_in_scf(dist_name):
    """Check for existence in SCF configuration.

    :param dist_name: dist_name
    :type dist_name: string
    :return: True if dist_name found, False otherwise
    """
    return load_scf_from_site_and_get_taf_scf_instance().is_object_in_scf(dist_name=dist_name)


def assert_existence_of_an_object(dist_name):
    """Assert existence of a specified dist_name in SCF configuration.

    :param dist_name: dist_name
    :type dist_name: string
    """
    assert is_object_in_scf(
        dist_name=dist_name) is True, "{} is not present in SCF".format(dist_name)
    logger_console("{} is present in SCF".format(dist_name))


def assert_absence_of_an_object(dist_name):
    """Assert absence of a specified dist_name in SCF configuration.

    :param dist_name: dist_name
    :type dist_name: string
    """
    assert is_object_in_scf(dist_name=dist_name) is False, "{} is present in SCF, while it should not be.".format(
        dist_name)
    logger_console(
        "{} is not present in SCF - this is expected".format(dist_name))


def assert_existence_of_objects_in_scf(list_of_present_objects=None, list_of_absent_objects=None):
    """Assert existence (or lack thereof) of multiple objects in SCF.

    :param list_of_present_objects: optional: list of objects desired to be present
    :type list_of_present_objects: list, optional
    :param list_of_absent_objects: optional: list of objects desired to be absent
    :type list_of_absent_objects: list, optional
    """
    scf_instance = load_scf_from_site_and_get_taf_scf_instance()
    error_msg = "{} is{} present in SCF. This is unexpected!"
    if list_of_present_objects:
        for elem in list_of_present_objects:
            assert scf_instance.is_object_in_scf(
                elem) is True, error_msg.format(elem, " not")
    if list_of_absent_objects:
        for elem in list_of_absent_objects:
            assert scf_instance.is_object_in_scf(
                elem) is False, error_msg.format(elem, "")


@handle_admin
def delete_object(dist_name, timeout=180, *args, **kwargs):
    """Deletes a dist_name from the SCF configuration.

    :param dist_name: dist_name
    :type dist_name: string
    :param timeout: timeout in seconds
    """
    return kwargs["connection"].perform_object_recommissioning(dist_name=dist_name,
                                                               parameter=[],
                                                               operation="delete",
                                                               skip_parameter_relation_errors=True,
                                                               should_activate=True,
                                                               timeout=timeout)


@handle_admin
def delete_objects(dist_name_list, timeout=600, *args, **kwargs):
    delta = [{"distName": dist_name, "operation": "delete", "parameters": []}
             for dist_name in dist_name_list]
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(delta),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=timeout)


def delete_object_if_it_exists(dist_name):
    """Checks if dist_name exists. If it does, it is deleted, otherwise no action is taken and the test proceeds.

    :param dist_name: dist_name
    :type dist_name: string
    """
    if is_object_in_scf(dist_name):
        delete_object(dist_name=dist_name)


def delete_objects_if_they_exist(dist_name_list):
    scf_instance = load_scf_from_site_and_get_taf_scf_instance()
    present_dist_name_list = []
    for dist_name in dist_name_list:
        if scf_instance.is_object_in_scf(dist_name) is True:
            present_dist_name_list.append(dist_name)
    delete_objects(present_dist_name_list)


def get_nrrel_list():
    """Returns list of all NRREL objects present in SCF

    :return: list of all NRREL objects present in SCF
    """
    nrrels = get_dist_names_matching_given_class(class_pattern="NRREL")
    if nrrels:
        logger.info("Present NRRELs objects in SCF:")
        for nrrel in nrrels:
            logger.info("\t{}".format(nrrel))
    else:
        logger.info("No NRREL object present in SCF")
    return nrrels


def get_xnlinks_list():
    """Returns list of all XNLINK objects present in SCF

    :return: list of all XNLINK objects present in SCF
    """
    xnlinks = get_dist_names_matching_given_class(class_pattern="XNLINK")
    if xnlinks:
        logger.info("Present XNLINK objects in SCF:")
        for xnlink in xnlinks:
            logger.info("\t{}".format(xnlink))
    else:
        logger.info("No XNLINK object present in SCF")
    return xnlinks


def get_scf_phys_cell_id(cell_distname, cell_phy_id_param):
    physCellId = get_values_of_parameters_from_scf(
        dist_name=cell_distname, parameter_list=cell_phy_id_param)
    logger_console("Retrieved value from SCF: {}".format(physCellId))

    try:
        physCellId = physCellId[0]["value"]
    except (IndexError, KeyError):
        raise NotKnownCellIdException("IndexError during physCellId retrieval")

    if not physCellId:
        raise NotKnownCellIdException(
            "physCellId is NoneType, could not be retrieved")

    logger_console("Current physCellId on SCF: {}".format(physCellId))
    return physCellId


@handle_admin
def collect_scf_file(prefix="", name="", subdir="scfs", scf_type="configurationAndRuntimeObjects", final_path="",
                     *args, **kwargs):
    """Wrapper for collecting SCF file to logs subdirectory

    :param prefix: prefix for the scf file name
    :param name: name of the scf file
    :param subdir: subdirectory where to put file
    :param scf_type: type of the scf file to be downloaded
    :param final_path: absolute path with scf filename, where SCF should be stored
    """
    if not final_path:
        output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
        subdir_full_path = os.path.join(output_dir, subdir)
        if prefix:
            prefix = prefix + "_"
        if not name:
            name = BuiltIn().get_variable_value("${TEST_NAME}")
        final_path = os.path.join(
            output_dir, subdir, "{}{}_scf.xml".format(prefix, name))

    logger_console_info("Collect SCF file at: {}".format(final_path))
    kwargs["connection"].collect_scf(
        target_file_name=final_path, export_type=scf_type)


@handle_admin
def set_mrbts_nrbts_ids_on_delta(delta_file, *args, **kwargs):
    """Keyword, which modifies MRBTS-$mrbtsID and NRBTS-$nrBtsId at delta json file.
    As those IDs can be different in some SCF files, method allows delta to be dynamic
    and set IDs accordingly to currently loaded SCF.

    :param delta_file: path to delta, which shall be modified
    """
    bts_info = kwargs["connection"].get_bts_info()
    mrbtsID = bts_info['mrbtsID']
    nrBtsId = bts_info['nrBtsId']
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(mrbtsID=mrbtsID, nrBtsId=nrBtsId)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()


def __get_actual_object_update_state_in_scf(scf_instance, dist_name):
    if scf_instance.is_object_in_scf(dist_name=dist_name):
        return "update"
    else:
        return "create"


def modify_object_operation_state_if_needed(delta_file, scf_path):
    """Checks every existing object in delta and updates its operation parameter.
    Sets operation to update, if object already exists, or sets it to create, if it does not exist.
    Keywords loads json file, loads current scf file and updates objects accordingly. Then saves
    json file.

    :param delta_file: path pointing to delta file
    :param scf_path: path pointing to scf file
    """
    delta_json = load_json_file(path=delta_file)

    scf_instance = scf()
    scf_instance.load_scf(scf_path)

    for i in range(len(delta_json)):
        dist_name = delta_json[i]["distName"]
        state = __get_actual_object_update_state_in_scf(
            scf_instance=scf_instance, dist_name=dist_name)
        msg = "Checking object state: {}\nUpdating state from {} to {}".format(dist_name,
                                                                               delta_json[i]["operation"],
                                                                               state)
        logger_console(msg)
        delta_json[i]["operation"] = state

    save_json_file(path=delta_file, json_content=delta_json)


@handle_admin
def perform_recomissioning_with_delta(path_to_delta, *args, **kwargs):
    """Wrapper for performing delta recommissioning using ADMIN API.

    :param path_to_delta: path to delta file; file should be in json format
    """
    kwargs["connection"].perform_delta_recommissioning(delta_file=path_to_delta,
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True)


@handle_admin
def perform_gnb_commissioning(scf_file, *args, **kwargs):
    """Wrapper for performing commissioning using ADMIN API.

    :param scf_file: path to SCF file
    """
    kwargs["connection"].perform_commissioning(scf_file=scf_file,
                                               skip_parameter_relation_errors=True,
                                               should_activate=True)


def check_if_gnb_changed_state(bts_state):
    """Function asserts that after 15s bts did not change from the required state.

    :param bts_state: bts state
    """
    time.sleep(15)
    assert_bts_in_state(bts_state)


def is_file_on_gnb(remote_path=None):
    """Checks, if file on gNB is existing and returns result in a True/False manner.

    :param remote_path: path at gNB
    :return: True, if file on gNB exists, False otherwise
    """
    if remote_path is None:
        return False

    rc, output = run_on_gnb(cmd="[ -e {} ]".format(remote_path))

    if rc != 0:
        logger_console("Could not find {} on GNB!".format(remote_path))
        return False

    return True


def give_executable_permissions_on_gnb(remote_path):
    """Calls chmod +x remote_path.

    :param remote_path: path, which should be made executable
    """
    return run_on_gnb(cmd='chmod {} {}'.format('+x', remote_path))


def give_reading_permissions_on_gnb(remote_path):
    """Calls chmod +r remote_path.

    :param remote_path: path, which should have reading permissions.
    """
    return run_on_gnb(cmd="chmod {} {}".format("+r", remote_path))


def get_gnb_build(convert_to_trunk=False):
    """Get gNB build version; function parses the file at gNB ASIKs /rom/TargetDB*

    :param convert_to_trunk: bool determining whether output should be converted to SBTS00 if applicabble
    :return: gNb build in format like: SBTS21A_ENB_0000_210310_000661 or SBTS00_ENB_9999_210213_004070
    """
    _, output_gnb = run_on_gnb(cmd="ls /rom/TargetBD* | head -n 1")
    build = output_gnb.split("BD_")[1][:-6]
    if convert_to_trunk and re.match('SBTS.+_ENB_9{4}', build):
        return re.sub('SBTS.+_ENB', 'SBTS00_ENB', build)
    else:
        return build


def is_gnb_build_trunk_release():
    """Checks, if gNB build is trunk and returns result in a True/False manner.

    :return: True, if gNB build release is Trunk, False otherwise
    """
    return True if 'SBTS00' in get_gnb_build(convert_to_trunk=True) else False


@handle_admin
def get_gnb_build_release(convert_to_trunk=False, *args, **kwargs):
    """Returns gNB build release.

    :param convert_to_trunk: bool determining whether output should be converted to SBTS00 if applicabble
    :return: gNB build release in format like: SBTS21A or SBTS00
    """
    release_name = kwargs['connection'].get_sw_release_name()
    if convert_to_trunk and is_gnb_build_trunk_release():
        return re.sub('SBTS.+', 'SBTS00', release_name)
    else:
        return release_name


def log_gnb_build():
    """Logs gNB build to the info logger and console.
    """
    build_gnb = get_gnb_build()
    logger_console_info("Build gNB: {}".format(build_gnb))


def delete_localhost_ssh_key_from_known_hosts():
    OperatingSystem().run('ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "127.0.0.1"')


def delete_gnb_lmp_ssh_key_from_known_hosts():
    OperatingSystem().run('ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.1"')


def _append_line_to_file_on_gnb(line, file_path):
    cmd = 'echo -e "\n{}" >> {}'.format(line, file_path)
    rc, output = run_on_gnb(cmd)
    return rc, output


def _is_string_in_file_on_gnb(string, file_path):
    cmd = 'grep -i "{}" {}'.format(string, file_path)
    rc, output = run_on_gnb(cmd)
    return True if rc == 0 else False


def _is_flag_in_swconfig(flag):
    return _is_string_in_file_on_gnb(flag, '/ffs/run/swconfig.txt')


def _add_flag_to_swconfig(flag):
    _append_line_to_file_on_gnb(flag, '/ffs/run/swconfig.txt')


def _ensure_swconfig_flag_exists(flag):
    if not _is_flag_in_swconfig(flag):
        _add_flag_to_swconfig(flag)


def ensure_flags_existence_in_swconfig(flags):
    """Provided a list of flags and their values, ensure that in gNB swconfig.txt file the flag is set.
    If flag is already set, no action is taken. If flag is not set, it will be added to the swconfig file.
    For flags to take effect, gNB needs to be rebooted.

    :param flags: list of flags with their values, all in string, like so:
        ['0x10040=1', '0x10043=0xC739', '0x10042=0xC0A8FF7E']
    :type flags: list of strings
    """
    for flag in flags:
        _ensure_swconfig_flag_exists(flag)


def ensure_syslog_flags_existence_in_swconfig():
    """Ensure swconfig has syslog flags enabled.
    """
    flags = ['0x10040=1', '0x10043=0xC739', '0x10042=0xC0A8FF7E']
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_short_pmstats_flag_existence_in_swconfig():
    """Ensure short pm stats flag (reducing by the factor of 5) is set in swconfig.txt at gNB.
    """
    flags = ['0x340000=5']
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_cplane_flags_existence_in_swconfig():
    """Ensure CPlane specific flags are set in swconfig.
    """
    flags = ['0x590072=1', '0x41001b=1']
    ensure_flags_existence_in_swconfig(flags=flags)


def log_gnb_swconfig_contents():
    _, swconfig_contents = run_on_gnb("cat /rom/swconfig.txt")
    logger.info("gNB /rom/swconfig/txt contents:\n{}".format(swconfig_contents))


def log_ap_swconfig_contents():
    _, swconfig_contents = run_on_ap("cat /rom/swconfig.txt")
    logger.info("gNB /rom/swconfig/txt contents:\n{}".format(swconfig_contents))


def ensure_cp_runtime_ini_has_LoggingSeverity_set_on_trace():
    if not _is_string_in_file_on_gnb('LoggingSeverity=trace', '/ffs/run/cp_runtime.ini'):
        _append_line_to_file_on_gnb(
            "[control]\nLoggingSeverity=trace", '/ffs/run/cp_runtime.ini')


def collect_gnb_snapshot(prefix=None, output_filepath=None):
    if prefix is None:
        prefix = ta5g_interface_tools().get_robot_test_name()
    if output_filepath is None:
        output_dir = ta5g_interface_tools().get_robot_output_dir()
        output_filepath = os.path.join(
            output_dir, "snapshot_gNB", "snapshot_{}.zip".format(prefix))
    logger_console("Collecting gNB snapshot to: {}".format(output_filepath))
    ta5g_enb_instance = BuiltIn().get_library_instance('ta5g_enb')
    ta5g_enb_instance.get_bts_snapshot(output_filepath=output_filepath)


def collect_admin_api_logs(dest_dir_full_path=None, subdir="admin_api_logs", dir_name=""):
    """Collect admin_api_default* and disconnect*.ims2 logs to specified directory

    :param dest_dir_full_path: Specifies full path to the destination directory, where files will be copied
    :param subdir: if dest_dir_full_path is omitted, specifies the subdirectory name of destination directory
    :param dir_name: if dest_dir_full_path is omitted, specifies the destination directory name
    :return: full path to the destination directory
    """
    if dest_dir_full_path is None:
        output_dir = ta5g_interface_tools().get_robot_output_dir()
        dest_dir_full_path = os.path.join(output_dir, subdir, dir_name)
    if not os.path.isdir(dest_dir_full_path):
        try:
            os.makedirs(dest_dir_full_path)
        except OSError:
            if not os.path.isdir(dest_dir_full_path):
                raise
    for file in glob.glob(r'admin_api_default*'):
        logger.info("Copy {} to {}".format(file, dest_dir_full_path))
        shutil.move(file, dest_dir_full_path)
    for file in glob.glob(r'disconnect*ims2'):
        logger.info("Copy {} to {}".format(file, dest_dir_full_path))
        shutil.move(file, dest_dir_full_path)
    return dest_dir_full_path


@handle_admin
def get_cell_band(cell_type='nr', global_cell_id=1, *args, **kwargs):
    """
    :param cell_type: str, Cell type of given RAT: 'lte', 'gsm', 'nr'. Default: 'nr'
    :param global_cell_id: int,
    :return: str 'n78' or 'n71', etc. depending on the band configuration on given cell
    """

    band_label = {
        'nr': 'band',
        'lte': 'bandNumber',
        'gsm': 'gsmBand'
    }
    cells = kwargs['connection'].get_cells_info(cell_type=cell_type)
    for cell in cells:
        if str(cell.get('globalCellId')) == str(global_cell_id):
            return cell[band_label[cell_type]]
    logger.warn("Band for cell {}, type {} not found!".format(
        global_cell_id, cell_type))


def check_if_recommissioning_is_possible(timeout='3min'):
    """
    Check if gNB is ready to perform recommissioning
    :param timeout:
    :return:
    """
    timeout = timestr_to_secs(timeout)
    start = time.time()
    t = start
    while t - start < timeout:
        connected = False
        try:
            conn = admin().connect_to()
            connected = True
            out = conn.get_bts_info()
            if out['basebandModules'][0]['status']['operationalState'].lower() == 'enabled':
                return True
        except IndexError:  # for ASOE
            if out['systemModules'][0]['status']['operationalState'].lower() == 'enabled':
                return True
        except Exception as e:
            logger.debug(
                'Admin API failure: Unable to connect to gNB: ' + e.message)
        finally:
            if connected:
                conn.teardown_admin()
        t = time.time()
    raise ConnectionNotAvailable


def configure_delta(delta_filename, path_to_scf, config_dir):
    """
    Function configures delta file from template according to id of NRBTS object from SCF.
    Template should have the same filename as delta and contain {MRBTS_NRBTS} to be replaced.
    :param delta_filename: Filename of delta to be configured
    :param path_to_scf: Path to downloaded current SCF
    :param config_dir: Path to directory with templates e.g. "testsuite/RRM/Krakow/FGCR-10143/config"
    """
    mrbts_nrbts = get_mrbts_nrbts(path_to_scf)
    release = get_gnb_build_release()
    user_paths = ['/home/ute/robotws5g',
                  '/home/ute/auto/robotws5g', '/home/ute/Auto5G']
    for path in user_paths:
        try:
            with open(os.path.join(path, config_dir, "templates", delta_filename)) as delta_template:
                delta_input = delta_template.read().replace(
                    "{MRBTS_NRBTS}", mrbts_nrbts)
        except IOError:
            logger.info("File {} not found".format(os.path.join(
                path, config_dir, "templates", delta_filename)))
            continue
        if not os.path.isdir(os.path.join(path, config_dir, release)):
            os.mkdir(os.path.join(path, config_dir, release))
        try:
            with open(os.path.join(path, config_dir, release, delta_filename), "w") as delta_file:
                delta_file.write(delta_input)
            logger.info("Delta {} configured in {}/{} directory".format(delta_filename, config_dir, release),
                        also_console=True)
            return os.path.join(path, config_dir, release, delta_filename)
        except IOError:
            logger.info("Could not write {}".format(os.path.join(path, config_dir, release, delta_filename)),
                        also_console=True)


def get_mrbts_nrbts(path_to_scf):
    """
    Get MRBTS and NRBTS objects with ids
    :param path_to_scf: path to downloaded SCF
    :return: e.g. MRBTS-1/NRBTS-1
    """
    regexp_mrbts_nrbts = re.compile("(MRBTS-\\d+/NRBTS-\\d+)")
    with open(path_to_scf) as scf:
        data = scf.read()
    mrbts_nrbts = regexp_mrbts_nrbts.search(data).group()
    return mrbts_nrbts


def validate_scf_with_delta(path_to_delta, path_to_scf=None):
    """
    Check if all parameters from delta are properly configured in scf.
    :param path_to_delta: Path to delta file starting from 'testsuite'. e.g. 'testsuite/RRM/Krakow/feature/delta.json'
    :param path_to_scf: Absolute path to scf (optional)
    """
    if not path_to_scf:
        scfc_analysis = ta5g_scfc_analysis()
        path_to_scf = scfc_analysis.get_latest_scfc()
    current_scf = scf.scf()
    current_scf.load_scf(path_to_scf)
    path_to_delta = os.path.join(
        str(os.path.abspath(__file__).split('testsuite')[0]), path_to_delta)
    errors = list()
    with open(path_to_delta) as delta_json:
        delta = json.load(delta_json)
    errors = _validate_delta_parameters(current_scf, delta, errors)
    if len(errors) == 0:
        logger.info('SCF validation finished successfully!', also_console=True)
    else:
        print(errors)
        logger.info('SCF validation finished with errors!', also_console=True)
        raise SCFValidationError(errors, also_console=False)


def _validate_delta_parameters(current_scf, delta, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    for obj in delta:
        if obj['operation'] == 'delete':
            try:
                assert (current_scf.is_object_in_scf(obj['distName']) is False)
            except AssertionError:
                errors.append(
                    'Object {} should not be configured in scf'.format(obj['distName']))
        else:
            for parameter in obj['parameters']:
                if parameter['operation'] == 'delete':
                    errors = _parameter_should_not_be_configured(
                        parameter, obj, current_scf, errors)
                else:
                    if type(parameter['value']) is list:
                        if type(parameter['value'][0]) is dict:
                            errors = _parameter_dict_should_be_configured(
                                parameter, obj, current_scf, errors)
                        else:
                            errors = _parameter_list_should_be_configured(
                                parameter, obj, current_scf, errors)
                    else:
                        errors = _parameter_string_should_be_configured(
                            parameter, obj, current_scf, errors)
    return errors


def _parameter_should_not_be_configured(parameter, obj, current_scf, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    if type(parameter['value']) is list:
        try:
            assert (current_scf.is_list_in_object(
                dist_name=obj['distName'],
                list_name=parameter['parameterName']) is False)
        except AssertionError:
            errors.append('Parameter {}/{} should not be configured'
                          .format(obj['distName'], parameter['parameterName']))
    else:
        try:
            assert (current_scf.is_element_in_object(
                dist_name=obj['distName'],
                p_name=parameter['parameterName']) is False)
        except AssertionError:
            errors.append('Parameter {}/{} should not be configured'
                          .format(obj['distName'], parameter['parameterName']))
    return errors


def _parameter_dict_should_be_configured(parameter, obj, current_scf, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    for i in range(0, len(parameter['value'][0])):
        try:
            assert (current_scf.get_value_from_scf(dist_name=obj['distName'], list_name=parameter['parameterName'],
                                                   index=i).lower() in list(parameter['value'][0].values()))
        except AssertionError:
            errors.append(
                'Wrong value for {}/{}'.format(obj['distName'], parameter['parameterName']))
        except KeyError:
            errors.append(
                'Could not found {}/{}'.format(obj['distName'], parameter['parameterName']))
    return errors


def _parameter_list_should_be_configured(parameter, obj, current_scf, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    for i in range(0, len(parameter['value'])):
        try:
            assert (current_scf.get_value_from_scf(dist_name=obj['distName'], list_name=parameter['parameterName'],
                                                   index=i).lower() in [item.lower() for item in parameter['value']])
        except AssertionError:
            errors.append(
                'Wrong value for {}/{}'.format(obj['distName'], parameter['parameterName']))
        except KeyError:
            errors.append(
                'Could not found {}/{}'.format(obj['distName'], parameter['parameterName']))
    return errors


def _parameter_string_should_be_configured(parameter, obj, current_scf, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    try:
        assert (current_scf.get_value_from_scf(
            dist_name=obj['distName'],
            p_name=parameter['parameterName']).lower() == str(parameter['value'].lower()))
    except AssertionError:
        errors.append(
            'Wrong value for {}/{}'.format(obj['distName'], parameter['parameterName']))
    except KeyError:
        errors.append(
            'Could not found {}/{}'.format(obj['distName'], parameter['parameterName']))
    return errors


class SCFValidationError(Exception):
    def __init__(self, message=['SCF Validation failed'], also_console=True):
        """
        :param message: list of strings
        """
        logger.info('Validation errors:\n', also_console=also_console)
        for msg in message:
            logger.info(msg, also_console=also_console)


class ConnectionNotAvailable(Exception):
    def __init__(self):
        pass
