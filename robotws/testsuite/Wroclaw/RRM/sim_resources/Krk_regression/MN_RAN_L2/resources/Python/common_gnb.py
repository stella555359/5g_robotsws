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
    AdminApiException,
    AdminApiConnectionClosedException,
    AdminApiProcedureFailureException,
    AdminApiProcedureTimeoutException
)

from taf.transport.ssh.exceptions import ConnectFailedError
from taf.sbts.oam.coam.admin.facade import admin_interface_context
from taf.sbts.oam.coam.admin import admin
import xml.etree.ElementTree as ET
from taf.hw.pdu.interface import pdu
from taf.transport.ssh import ssh
from taf.config.scf import scf
from ta5g_scfc_analysis import ta5g_scfc_analysis
from datetime import datetime
from shutil import rmtree
from string import Template
from functools import wraps
from time import sleep
import xml.dom.minidom
import shutil
import glob
import time
import json
import sys
import os
import io
import re

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import (
    download_artifactory_file,
    load_json_file,
    unzip_file,
    save_json_file
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.swconfig import (
    GnbSwconfigManager,
    GnbFileManager
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import (
    logger_console,
    logger_console_info,
    logger_info,
    logger_warning,
    logger_debug
)


class RadioHeadTimeoutException(Exception):
    """Custom exception raised if Radio Head persistently fails to go online
    """
    pass


class NotKnownCellIdException(Exception):
    """Custom exception raised, if Physical Cell ID cannot be retrieved from SCF file.
    """
    pass


class MibSibAcquisitionFailed(Exception):
    """Custom exception indicating failure of MIB-SIB acquisition
    """
    pass


class XnLinkStatusCheckFailed(Exception):
    """Custom exception indicating failure of xnlink setup
    """
    pass


def _get_admin_connection_kwargs(**kwargs):
    connection_kwargs = {}
    bts_host_ip = kwargs.get('bts_host_ip', None)
    connection_kwargs["bts_host"] = bts_host_ip if bts_host_ip is not None else \
        BuiltIn().get_variable_value("${GNB_IP}")
    connection_kwargs["username"] = BuiltIn().get_variable_value("${WEBEM_USERNAME}")
    connection_kwargs["password"] = BuiltIn().get_variable_value("${WEBEM_PASSWORD}")
    connection_kwargs = {key: value for key, value in connection_kwargs.items() if value is not None}
    logger_debug("admin connection_kwargs: {}".format(connection_kwargs))
    return connection_kwargs


def handle_admin(func):
    """Wrapper function handling setting up and teardown of admin connection. Meant to be used as a decorator.
    Usage: when used in a function, in arguments **kwargs need to be specified.
    Then connection object to Admin API can be obtained using kwargs["connection"] syntax.

    Wrapper takes bts hostname, username and password from robot variables (GNB_IP, WEBEM_USERNAME, WEBEM_PASSWORD).
    When no such variables are recognised, connection to Admin API is established using default values of
    admin.connect_to() method.
    A custom gNB IP can be defined in keyword argument 'bts_host_ip'.

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
    def inner(*args, rnw_retries=5, **kwargs):
        def _wait(seconds=60):
            for _ in range(seconds):
                logger.console('.', newline=False)
                time.sleep(1)

        result = None
        timeoutRetry = True
        connection_error = True
        unexpected_err_retries = 3
        connection_args = _get_admin_connection_kwargs(**kwargs)

        while True:
            try:
                with admin_interface_context(**connection_args) as connection:
                    result = func(connection=connection, *args, **kwargs)
                break
            except AdminApiProcedureFailureException as e:
                error_code = re.search(r'ErrorCode.\s*(\d+)', e.args[0])
                if error_code:
                    rc = int(error_code.group(1))
                    if rc == 27 and rnw_retries > 0:
                        logger_warning("BTS DOWNLOAD_PLAN procedure failed - Configuration data validation is rejected "
                                       "because CPlane is busy. Will retry after 60s")
                        _wait(60)
                        rnw_retries -= 1
                        continue
                    if rc == 7 and unexpected_err_retries > 0:
                        logger_warning("AdminApiProcedureFailureException: ErrorCode: 7 - UNEXPECTED_ERROR. "
                                       "Will retry after 60s")
                        _wait(60)
                        unexpected_err_retries -= 1
                        continue
                logger_warning("AdminApiProcedureFailureException caught: {}".format(e.args[0]))
                raise
            except AdminApiProcedureTimeoutException as e:
                if timeoutRetry is True:
                    timeoutRetry = False
                    logger_warning(
                        "AdminApiProcedureTimeoutException occurred, retrying the operation one more time..."
                    )
                    time.sleep(30)
                    continue
                else:
                    raise
            except AdminApiConnectionClosedException as e:
                logger_warning("AdminApiConnectionClosedException occurred. Probably port is closed.")
                raise
            except UnboundLocalError as e:
                if connection_error is True:
                    connection_error = False
                    logger_warning(
                        "UnboundLocalError occurred(context manager failed to get admin connection), "
                        "waiting until the connection is back..."
                    )
                    wait_till_admin_is_online(retry=10, **kwargs)
                    time.sleep(30)
                    continue
                else:
                    raise
            except Exception as e:
                logger_warning("Unexpected exception occurred: {}".format(e.args))
                raise
        return result
    return inner


def wait_till_admin_is_online(retry=30, retry_interval=30, **kwargs):
    """Function waits until the Admin Api is available for the user. Sometimes after bts reboot AdminApi is unavailable
    for a long time, resulting in an error AdminApiConnectionClosedException.
    This function aims to resolve this problem.

    :param retry: count of retries
    :param retry_interval: interval between retries, in seconds
    """
    admin_instance = admin()
    connection_args = _get_admin_connection_kwargs(**kwargs)
    logger_console("Waiting for ADMIN API to be available")
    while retry > 0:
        try:
            connection = admin_instance.connect_to(**connection_args)
            break
        except AdminApiConnectionClosedException as e:
            logger.info("AdminApiConnectionClosedException: AdminApi is still offline")
        except Exception as e:
            logger.info("EXCEPTION: {}".format(repr(e)))
            raise
        time.sleep(retry_interval)
        retry -= 1
    admin_instance.teardown_all_aliases_for_admin()
    if retry == 0:
        raise AdminApiConnectionClosedException("Could not connect to AdminApi.")


def execute_command_on_the_remote(cmd, hostname, username, password):
    """Wrapper for taf ssh library remote command execution.

    :param cmd: string of command to execute
    :param hostname: hostname of the remote
    :param username: username of the remote
    :param password: password of the remote
    :return: Tuple(exit_code, output)
    """
    ssh_instance = ssh()
    ssh_instance.connect_to(hostname=hostname, username=username, password=password)
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
def reset_site_via_admin(timeout=300, *args, **kwargs):
    """Reset bts via AdminApi
    """
    kwargs["connection"].reset_site(timeout=timeout)


def reset_units(secondary_gnb_ip=None, timeout=300, trigger_forced_AP_reset=False):
    """Perform safe system module reboot on AirPhone and reset of bts via AdminApi.

    :param secondary_gnb_ip: (str) If this parameter is given, also the second gNB will be reset
    :param timeout: timeout for admin reset site operation in seconds
    :param trigger_forced_AP_reset: specifies if system-module-reboot should be run on AirPhone before gNB site reset
    """

    if trigger_forced_AP_reset:
        logger_console_info("Running system-module-reboot on the AirPhone")
        run_on_ap(cmd="system-module-reboot")
    try:
        logger_console_info("Resetting gNB site via AdminApi")
        reset_site_via_admin(timeout=timeout)
        if secondary_gnb_ip:
            logger_console_info("Resetting gNB-2 site via AdminApi")
            reset_site_via_admin(bts_host_ip=secondary_gnb_ip, timeout=timeout)

    except AdminApiConnectionClosedException as e:
        logger_warning("Cannot connect to Admin API, will try to reboot via ssh")
        logger_console_info("Running system-module-reboot on the gNB")
        run_on_gnb(cmd="system-module-reboot")
        if secondary_gnb_ip:
            logger_console_info("Running system-module-reboot on the gNB-2")
            run_on_gnb(hostname=secondary_gnb_ip, cmd="system-module-reboot")


def reset_airphone(reset_timeout=300, recover_if_stuck=False, pdu_port=None):
    """
    :param int reset_timeout: timeout in seconds
    :param bool recover_if_stuck: try to recover AP if it gets stuck after reboot by performing power-reset
    :param PduPort pdu_port: pdu port from TL's __init__.py, e.g. tl.ues[0].l1.common_units[0].pdu_port
    """
    run_on_ap(cmd="reboot")
    err_msg_end = "Airphone unreachable after running reboot command! Try power-reset or set flag recover_if_stuck=True"
    if _wait_until_ap_reachable(reset_timeout):
        return
    if recover_if_stuck:
        logger_console_info("Airphone unreachable after reboot command, attempting to recover by power-reset")
        if not pdu_port:
            value_err_msg = "pdu_port must be set if recover_if_stuck set to True!"
            logger_warning(value_err_msg)
            raise ValueError(value_err_msg)
        power_reset_unit(pdu_port)
        err_msg_end = "Airphone unreachable after running reboot command and power-reset"
        if _wait_until_ap_reachable(reset_timeout):
            return
    raise ConnectFailedError(err_msg_end)


def _wait_until_ap_reachable(reset_timeout=300, sleep_for_seconds=30):
    logger_console("Waiting for up to {}s for airphone to restart".format(reset_timeout))
    while reset_timeout > 0:
        time.sleep(sleep_for_seconds)
        reset_timeout -= sleep_for_seconds
        try:
            run_on_ap(cmd="uptime")
            logger_console_info("Airphone rebooted successfully")
            return True
        except ConnectFailedError:
            pass
    return False


def power_reset_unit(pdu_port):
    """
    Power-cycle unit connected to specific PDU port

    :param PduPort pdu_port: pdu port from TL's __init__.py, e.g. tl.ues[0].l1.common_units[0].pdu_port
    """
    pdu().setup_pdu(model=pdu_port.pdu.vendor, host=pdu_port.pdu.addr)
    pdu().reset_ports(ports=[pdu_port.port_no], time_interval=5)


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


def get_current_time_on_gnb(return_epoch=False, return_datetime=False, universal_time_zone=False):
    if return_epoch:
        cmd = 'date -u +"%s"'
    elif universal_time_zone:
        cmd = 'date -u +"%Y %m %d %X %Z"'
    else:
        cmd = 'date +"%X"'
    status, gnb_time = run_on_gnb(cmd=cmd)
    if return_epoch is False and return_datetime:
        if universal_time_zone:
            gnb_time = datetime.strptime(gnb_time, '%Y %m %d %X %Z')
        else:
            gnb_time = datetime.strptime(gnb_time, '%H:%M:%S')
    return gnb_time


@handle_admin
def get_radio_module_status(ru_id=0, *args, **kwargs):
    """Get radio module status. Available statuses: offline, online, notinstalled

    :return: radio module availability status
    """
    bts_hw_info = kwargs["connection"].get_bts_info()
    availability_status = bts_hw_info['radioModules']['rmod'][ru_id]['status'].setdefault('availabilityStatus',
                                                                                          "online")
    logger_console("Radio state: {}".format(availability_status))
    return availability_status


@handle_admin
def send_new_vendor_file(vendor_file, *args, **kwargs):
    """Set vendor file.

    :param str vendor_file: xml file or path to xml file.
    """
    kwargs["connection"].set_vendor_file(vendor_file)


def wait_for_radio_module_to_be_online(retry=15, retry_interval=30, ru_id=0):
    """Waits until radio module is online, repeatedly

    :param ru_id: id of radio unit
    :param retry: max number of retries
    :param retry_interval: interval between the retries
    """
    status = ""
    while retry > 0:
        retry -= 1
        status = get_radio_module_status(ru_id=ru_id)
        if status.lower() == "online":
            break
        time.sleep(retry_interval)
    if retry == 0:
        raise RadioHeadTimeoutException('Radio module could not go online!', "Radio module status: {}".format(status))


@handle_admin
def wait_for_all_radio_modules_to_be_online(retry=15, retry_interval=30,  *args, **kwargs):
    """Waits until radio module is online, repeatedly

    :param retry: max number of retries
    :param retry_interval: interval between the retries
    """
    retry = int(retry)
    statuses = {}
    while retry > 0:
        retry -= 1

        bts_hw_info = kwargs["connection"].get_bts_info()
        radio_modules_list = bts_hw_info['radioModules']['rmod']
        for idx, radio_module in enumerate(radio_modules_list):
            availability_status = radio_module['status'].setdefault('availabilityStatus', "online")
            logger_console("Radio module {} state: {}".format(idx, availability_status))
            statuses[idx] = availability_status
        if all([status.lower() == "online" for status in statuses.values()]):
            break
        time.sleep(int(retry_interval))
    if retry == 0:
        raise RadioHeadTimeoutException(
            'Radio module could not go online!', "Radio module status: {}".format(statuses))


def reset_units_and_wait_for_radio_head_online(retry=30, retry_interval=30, timeout=300, ru_id=None,
                                               recovery_reboot_retires=None, skip_reset=False, secondary_gnb_ip=None):
    """Function handy while setting up an environment. Resets units, waits for icmp echo replies (ping answering),
    ADMIN API availability and radio module to go online. If waiting for radio module to go online will fail recovery
    reboot will be triggered according to the value in recovery_reboot_retires argument.

    :param retry: max number of retries
    :param retry_interval: interval between the retries
    :param timeout: timeout for admin reset site operation
    :param ru_id: id of radio unit
    :param recovery_reboot_retires: number of recovery reboot retries
    :param skip_reset: indicate if reset of units should be skipped
    :param secondary_gnb_ip: IP address of second gNB that will be reset
    """
    ta5g_tm_instance = ta5g_testline_management()
    if skip_reset is False:
        logger_console("Resetting units")
        reset_units(secondary_gnb_ip=secondary_gnb_ip, timeout=timeout)
    logger_console("Waiting till testline LMP interfaces become pingable")
    ta5g_tm_instance.wait_for_testline_icmp_echo_replies_and_ssh_services()
    wait_till_admin_is_online(retry=retry, retry_interval=retry_interval)
    try:
        if ru_id is None:
            wait_for_all_radio_modules_to_be_online(retry=retry, retry_interval=retry_interval)
        else:
            wait_for_radio_module_to_be_online(retry=retry, retry_interval=retry_interval, ru_id=ru_id)
    except RadioHeadTimeoutException:
        if recovery_reboot_retires:
            reset_units_and_wait_for_radio_head_online(retry=retry, retry_interval=retry_interval, ru_id=ru_id,
                                                       recovery_reboot_retires=recovery_reboot_retires-1)
        else:
            raise


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


def assert_bts_in_state(bts_state, **kwargs):
    """Assert that bts is in the specified state.

    :param bts_state: desired bts state
    """
    bts_info = get_bts_state(**kwargs)
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
    idx_orig_state = list_of_states.index(original_state.lower().replace(" ", ""))
    idx_current_state = list_of_states.index(get_bts_state())
    assert idx_current_state >= idx_orig_state


def wait_for_requested_bts_state(bts_state, retry=20, retry_interval=30, **kwargs):
    """
    Wait for gNB to reach requested state.
    Example states are: "notcommissioned", "commissioned", "configured", "onair".

    :param bts_state:
    :param retry:
    :param retry_interval:
    :return:
    """
    correct_state = False
    for _ in range(0, retry):
        sleep(retry_interval)
        try:
            assert_bts_in_state(bts_state=bts_state, **kwargs)
            correct_state = True
            break
        except (AssertionError, AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                AdminApiProcedureTimeoutException) as exception:
            logger.info('Raised exception {}'.format(type(exception)))
    if not correct_state:
        raise AssertionError('BTS is not in {} state.'.format(bts_state))


@handle_admin
def get_counter_values(counter_id, timeout=100, *args, **kwargs):
    """Wrapper function of admins get_pm_counters.

    :param counter_id: id of the counter, in a string
    :param timeout: timeout
    :return: dictionary with parameter values and corresponding timestamps in epoch
    """
    counters = kwargs["connection"].get_pm_counters(counter_ids=counter_id, timeout=timeout)
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
    DEPRECIATED: Use safer method: assert_existence_of_an_object

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
    assert is_object_in_scf(dist_name=dist_name) is True, "{} is not present in SCF".format(dist_name)
    logger_console("{} is present in SCF".format(dist_name))


def assert_absence_of_an_object(dist_name):
    """Assert absence of a specified dist_name in SCF configuration.

    :param dist_name: dist_name
    :type dist_name: string
    """
    assert is_object_in_scf(dist_name=dist_name) is False, "{} is present in SCF, while it should not be.".format(
        dist_name)
    logger_console("{} is not present in SCF - this is expected".format(dist_name))


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
            assert scf_instance.is_object_in_scf(elem) is True, error_msg.format(elem, " not")
    if list_of_absent_objects:
        for elem in list_of_absent_objects:
            assert scf_instance.is_object_in_scf(elem) is False, error_msg.format(elem, "")


@handle_admin
def delete_object(dist_name, timeout=180, *args, **kwargs):
    """Deletes a dist_name from the SCF configuration.

    :param dist_name: dist_name
    :type dist_name: string
    :param timeout: timeout in seconds
    """
    logger_console_info("Deleting object {}".format(dist_name))
    return kwargs["connection"].perform_object_recommissioning(dist_name=dist_name,
                                                               parameter=[],
                                                               operation="delete",
                                                               skip_parameter_relation_errors=True,
                                                               should_activate=True,
                                                               timeout=timeout)


@handle_admin
def delete_objects(dist_name_list, timeout=600, *args, **kwargs):
    delta = [{"distName": dist_name, "operation": "delete", "parameters": []} for dist_name in dist_name_list]
    logger_console_info("Deleting objects: {}".format(dist_name_list))
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(delta),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=timeout)


def delete_object_if_it_exists(dist_name, timeout=180):
    """Checks if dist_name exists. If it does, it is deleted, otherwise no action is taken and the test proceeds.

    :param dist_name: dist_name
    :type dist_name: string
    :param timeout: timeout for the delete operation
    :type timeout: int
    """
    if is_object_in_scf(dist_name):
        delete_object(dist_name=dist_name, timeout=timeout)


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
    physCellId = get_values_of_parameters_from_scf(dist_name=cell_distname, parameter_list=cell_phy_id_param)
    logger_console("Retrieved value from SCF: {}".format(physCellId))

    try:
        physCellId = physCellId[0]["value"]
    except (IndexError, KeyError):
        raise NotKnownCellIdException("IndexError during physCellId retrieval")

    if not physCellId:
        raise NotKnownCellIdException("physCellId is NoneType, could not be retrieved")

    logger_console("Current physCellId on SCF: {}".format(physCellId))
    return physCellId


@handle_admin
def send_vendor_file_and_perform_gnb_commissioning(scf_file, vendor_file, *args, **kwargs):
    """Wrapper for sending vendor file and performing commissioning using ADMIN API.

    :param scf_file: path to SCF file
    """
    logger_console_info('Sending vendor file: {}'.format(vendor_file))
    kwargs["connection"].set_vendor_file(vendor_file)
    logger_console_info('Commission with scf: {}'.format(scf_file))
    kwargs["connection"].perform_commissioning(scf_file=scf_file,
                                               skip_parameter_relation_errors=True,
                                               should_activate=True)

    logger_console_info('Wait for commissioning for 5 min')
    sleep(300)


@handle_admin
def download_vendor_file(vendor_file, *args, **kwargs):
    """Download vendor file to a given path.

    :param str vendor_file: xml file or path to xml file.
    """
    kwargs["connection"].download_vendor_file(vendor_file)


@handle_admin
def collect_scf_file(prefix="", name="", subdir="scfs", scf_type="configurationAndRuntimeObjects", final_path="",
                     set_variable=False, *args, **kwargs):
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
        final_path = os.path.join(output_dir, subdir, "{}{}_scf.xml".format(prefix, name))

    logger_console("Collect SCF file at: {}".format(final_path))
    kwargs["connection"].get_current_scf_file(local_dir_path=os.path.dirname(final_path),
                                              file_name=os.path.basename(final_path),
                                              export_type=scf_type)
    if set_variable:
        BuiltIn().set_suite_variable("${COLLECTED_SCF_FILE}", final_path)
    return final_path


def set_mrbts_nrbts_ids_on_delta(delta_file):
    """Keyword, which modifies MRBTS-$mrbtsID and NRBTS-$nrBtsId at delta json file.
    As those IDs can be different in some SCF files, method allows delta to be dynamic
    and set IDs accordingly to currently loaded SCF.

    :param delta_file: path to delta, which shall be modified
    """
    mrbts_id, nrbts_id = get_mrbts_nrbts_ids()
    with open(delta_file, 'r+') as delta_to_modify:
        delta = Template(delta_to_modify.read())
        new_delta = delta.safe_substitute(mrbtsID=mrbts_id, nrBtsId=nrbts_id)
        delta_to_modify.seek(0)
        delta_to_modify.write(new_delta)
        delta_to_modify.truncate()
    return mrbts_id, nrbts_id


@handle_admin
def get_mrbts_nrbts_ids(*args, **kwargs):
    """
    Get MRBTS and NRBTS ids using admin connection.

    :return mrbts_id, nrbts_id: (str, str)
    """
    bts_info = kwargs["connection"].get_bts_info()
    mrbts_id = bts_info['mrbtsID']
    nrbts_id = bts_info['nrBtsId']
    return mrbts_id, nrbts_id


def __get_actual_object_update_state_in_scf(scf_instance, dist_name, actual_operation):
    if 'delete' in actual_operation:
        return 'delete'
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

    def add_indents():
        with open(delta_file, 'r+') as delta:
            delta_raw = json.load(delta)
            delta_modified = json.dumps(delta_raw, indent=4)
            delta.seek(0)
            delta.write(delta_modified)

    delta_json = load_json_file(path=delta_file)

    scf_instance = scf()
    scf_instance.load_scf(scf_path)

    for i in range(len(delta_json)):
        dist_name = delta_json[i]["distName"]
        state = __get_actual_object_update_state_in_scf(scf_instance=scf_instance, dist_name=dist_name,
                                                        actual_operation=delta_json[i]["operation"])
        msg = "Checking object state: {}\nUpdating state from {} to {}".format(dist_name,
                                                                               delta_json[i]["operation"],
                                                                               state)
        logger_console(msg)
        delta_json[i]["operation"] = state

    save_json_file(path=delta_file, json_content=delta_json)
    add_indents()


@handle_admin
def perform_recomissioning_with_delta(path_to_delta, timeout=300, *args, **kwargs):
    """Wrapper for performing delta recommissioning using ADMIN API.

    :param path_to_delta: path to delta file; file should be in json format; optionally delta can
                          also be passed as a python list of dictionary objects mapped as from json file
    "param timeout: timeout of recommissioning operation
    """
    if isinstance(path_to_delta, list):
        delta = path_to_delta
        objects = [operation["distName"] for operation in delta]
        logger_console_info("DistNames changed by delta recommissioning: {}".format(objects))
    kwargs["connection"].perform_delta_recommissioning(delta_file=path_to_delta,
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=timeout)


@handle_admin
def perform_gnb_commissioning(scf_file, *args, **kwargs):
    """Wrapper for performing commissioning using ADMIN API.

    :param scf_file: path to SCF file
    """
    kwargs["connection"].perform_commissioning(scf_file=scf_file,
                                               skip_parameter_relation_errors=True,
                                               should_activate=True)


@handle_admin
def check_if_delta_is_already_uploaded(path_to_delta, path_to_scf=None, *args, **kwargs):
    """
    Wrapper for function perform_delta_recommissioning with usage of ADMIN API.
    Check if the delta parameters have already been uploaded; if so, do not upload the delta again.

    :param path_to_delta: (str) path to delta file; file should be in json format; optionally delta can
                          also be passed as a python list of dictionary objects mapped as from json file
    :param path_to_scf: (str) absolute path to scf (optional)
    """
    if not path_to_scf:
        scfc_analysis = ta5g_scfc_analysis()
        path_to_scf = scfc_analysis.get_latest_scfc()
    current_scf = scf()
    current_scf.load_scf(path_to_scf)
    path_to_delta = os.path.join(str(os.path.abspath(__file__).split('testsuite')[0]), path_to_delta)
    errors = list()
    with open(path_to_delta) as delta_json:
        delta = json.load(delta_json)
    errors = _validate_delta_parameters(current_scf, delta, errors)
    if len(errors) == 0:
        logger.info('Delta has already been uploaded and recommissioning with delta will not be performed.',
                    also_console=True)
    else:
        perform_recomissioning_with_delta(path_to_delta)


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


def get_gnb_build(convert_to_trunk=False, **kwargs):
    """Get gNB build version.

    Get sw version info from admin-api. As a fallback mechanism parse the filename at gNB CU /rom/TargetDB*.

    :param convert_to_trunk: if output should be converted to SBTS00 if applicabble, defaults to False
    :type convert_to_trunk: bool, optional
    :return: gNb build in format like: SBTS21A_ENB_0000_210310_000661 or SBTS00_ENB_9999_210213_004070
    :rtype: str
    """
    try:
        with admin_interface_context(**_get_admin_connection_kwargs(**kwargs)) as connection:
            build = connection.get_sw_version()
    except (UnboundLocalError, AdminApiException) as e:
        logger_warning("Exception: {}: '{}' occurrred. Establishing gnb build from /rom/TargetBD file...".format(
            e.__class__.__name__, e)
        )
        rc, output_gnb = run_on_gnb(cmd="ls /rom/TargetBD* | head -n 1")
        logger_debug("Output from 'ls /rom/TargetBD* | head -n 1': {}".format(output_gnb))
        if str(rc) != "0":
            raise ValueError("Command 'ls /rom/TargetBD* | head -n 1' exited with rc={}".format(rc))
        build = output_gnb.split("BD_")[1][:-6]
        if "SBTS" not in build:
            raise ValueError("gNB build wrong format: {}".format(build))

    if convert_to_trunk and re.match('SBTS.+_ENB_9{4}', build):
        return re.sub('SBTS.+_ENB', 'SBTS00_ENB', build)
    else:
        return build


def is_gnb_build_trunk_release(**kwargs):
    """Checks if gNB build is trunk.

    :return: True, if gNB build release is Trunk, False otherwise
    :rtype: bool
    """
    return True if 'SBTS00' in get_gnb_build(convert_to_trunk=True, **kwargs) else False


@handle_admin
def get_gnb_build_release(convert_to_trunk=False, **kwargs):
    """Returns gNB build release.

    :param convert_to_trunk: bool determining whether output should be converted to SBTS00 if applicabble
    :return: gNB build release in format like: SBTS21A or SBTS00
    """
    release_name = kwargs['connection'].get_sw_release_name()
    if convert_to_trunk and is_gnb_build_trunk_release(**kwargs):
        return re.sub('SBTS.+', 'SBTS00', release_name)
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


def delete_flags_from_swconfig(flags):
    GnbSwconfigManager().delete_flags_from_swconfig(flags=flags)


def ensure_flags_existence_in_swconfig(flags):
    GnbSwconfigManager().ensure_flags_existence_in_swconfig(flags=flags)


def add_syslog_payload_flag_to_swconfig():
    """Enables payload flag to swconfig.
    """
    flag = ['0x580111=1000']
    ensure_flags_existence_in_swconfig(flags=flag)


def ensure_syslog_flags_existence_in_swconfig():
    """Ensure swconfig has syslog flags enabled.
    """
    flags = ['0x10040=1', '0x10041=5', '0x10043=0xC739', '0x10042=0xC0A8FF7E', '0x1003F=1']
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_short_pmstats_flag_existence_in_swconfig():
    """Ensure short pm stats flag (reducing by the factor of 5) is set in swconfig.txt at gNB.
    This flag should not be used!
    """
    flags = ['0x340000=5']
    # BuiltIn().set_test_variable("${PM_COUNTERS_PERIOD_TIME}", 60)
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_short_pmstats_new_flag_existence_in_swconfig(value=5):
    """Ensure short pm stats flag (dividing by the factor of `value`) is set in swconfig.txt at gNB.
    This is new flag to short pmstats period.
    :param value: Value is the divisor for pm_period
    """
    flags = ['0x9D0000={}'.format(value)]
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_cplane_flags_existence_in_swconfig():
    """Ensure CPlane specific flags are set in swconfig.
    """
    flags = ['0x590072=1', '0x41001b=1', '0x66001b=1', '0x890003=1', '0x890004=1']
    ensure_flags_existence_in_swconfig(flags=flags)


def ensure_debug_mctrl_flags_existence_in_swconfig():
    """Ensure debug MCTRL (debug for OAM/admin api related issues) are set in swconfig
    """
    flags = ['0x300000=1', '0x300001=1', '0x30001C=1']
    ensure_flags_existence_in_swconfig(flags=flags)


def get_gnb_swconfig_contents():
    _, swconfig_contents = run_on_gnb("cat /rom/swconfig.txt")
    return swconfig_contents


def get_ap_swconfig_contents():
    _, swconfig_contents = run_on_ap("cat /rom/swconfig.txt")
    return swconfig_contents


def ensure_cp_runtime_ini_has_LoggingSeverity_set_on_trace():
    if not GnbFileManager().is_string_in_file('LoggingSeverity=trace', '/ffs/run/cp_runtime.ini'):
        GnbFileManager().append_line_to_file("[control]\nLoggingSeverity=trace", '/ffs/run/cp_runtime.ini')


def collect_gnb_snapshot(prefix=None, output_filepath=None):
    if prefix is None:
        prefix = ta5g_interface_tools().get_robot_test_name()
    if output_filepath is None:
        output_dir = ta5g_interface_tools().get_robot_output_dir()
        output_filepath = os.path.join(output_dir, "snapshot_gNB", "snapshot_{}.zip".format(prefix))
    logger_console("Collecting gNB snapshot to: {}".format(output_filepath))
    from ta5g_enb import ta5g_enb
    ta5g_enb().get_bts_snapshot(output_filepath=output_filepath)


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
        logger.info("Move {} to {}".format(file, dest_dir_full_path))
        shutil.move(file, dest_dir_full_path)
    for file in glob.glob(r'disconnect*ims2'):
        logger.info("Move {} to {}".format(file, dest_dir_full_path))
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
    logger.warn("Band for cell {}, type {} not found!".format(global_cell_id, cell_type))


@handle_admin
def get_cells_info(cell_type='nr', *args, **kwargs):
    """
    :param cell_type: str, Cell type of given RAT: 'lte', 'gsm', 'nr'. Default: 'nr'
    :return: list with cells info
    """
    cells_info = kwargs['connection'].get_cells_info(cell_type=cell_type)
    return cells_info


def check_if_recommissioning_is_possible(timeout='3min'):
    """
    Check if gNB is ready to perform recommissioning

    :param timeout:
    :return:
    """
    admin_instance = admin()
    timeout = timestr_to_secs(timeout)
    start = time.time()
    t = start
    while t - start < timeout:
        connected = False
        try:
            conn = admin_instance.connect_to()
            connected = True
            out = conn.get_bts_info()
            if out['basebandModules'][0]['status']['operationalState'].lower() == 'enabled':
                return True
        except IndexError:  # for ASOE
            if out['systemModules'][0]['status']['operationalState'].lower() == 'enabled':
                return True
        except Exception as e:
            logger.debug('Admin API failure: Unable to connect to gNB: {}'.format(repr(e)))
        finally:
            if connected:
                admin_instance.teardown_admin()
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
    user_paths = ['/home/ute/robotws5g', '/home/ute/auto/robotws5g', '/home/ute/Auto5G']
    for path in user_paths:
        try:
            with open(os.path.join(path, config_dir, "templates", delta_filename)) as delta_template:
                delta_input = delta_template.read().replace("{MRBTS_NRBTS}", mrbts_nrbts)
        except IOError:
            logger.info("File {} not found".format(os.path.join(path, config_dir, "templates", delta_filename)))
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
    current_scf = scf()
    current_scf.load_scf(path_to_scf)
    path_to_delta = os.path.join(str(os.path.abspath(__file__).split('testsuite')[0]), path_to_delta)
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
                errors.append('Object {} should not be configured in scf'.format(obj['distName']))
        else:
            for parameter in obj['parameters']:
                if parameter['operation'] == 'delete':
                    errors = _parameter_should_not_be_configured(parameter, obj, current_scf, errors)
                else:
                    if type(parameter['value']) is list:
                        if type(parameter['value'][0]) is dict:
                            errors = _parameter_dict_should_be_configured(parameter, obj, current_scf, errors)
                        else:
                            errors = _parameter_list_should_be_configured(parameter, obj, current_scf, errors)
                    else:
                        errors = _parameter_string_should_be_configured(parameter, obj, current_scf, errors)
    return errors


def _parameter_should_not_be_configured(parameter, obj, current_scf, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    if 'value' in parameter:
        try:
            if isinstance(parameter['value'], list):
                assert (current_scf.is_list_in_object(
                    dist_name=obj['distName'],
                    list_name=parameter['parameterName']) is False)
            else:
                assert (current_scf.is_element_in_object(
                    dist_name=obj['distName'],
                    p_name=parameter['parameterName']) is False)
        except AssertionError:
            errors.append('Parameter {}/{} should not be configured'
                          .format(obj['distName'], parameter['parameterName']))
    else:
        logger_console_info('Key "value" not found in parameter dictionary')
    return errors


def _parameter_dict_should_be_configured(parameter, obj, current_scf, errors):
    """
    Helper for function validate_scf_with_delta.
    """
    for parameter_name, parameter_value in parameter['value'][0].items():
        try:
            actual_value = current_scf.get_value_from_scf(dist_name=obj['distName'],
                                                          list_name=parameter['parameterName'],
                                                          p_name=str(parameter_name))
            if not actual_value:
                logger_console_info(f"Key not found: {obj['distName']}/{parameter_name}")
                continue
            assert actual_value.lower() in parameter_value
        except Exception as e:
            if "No match found! Query might be not valid." in str(e):
                logger_console_info(f"Key not found: {obj['distName']}/{parameter_name}")
                continue
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
            errors.append('Wrong value for {}/{}'.format(obj['distName'], parameter['parameterName']))
        except KeyError:
            errors.append('Could not found {}/{}'.format(obj['distName'], parameter['parameterName']))
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
        errors.append('Wrong value for {}/{}'.format(obj['distName'], parameter['parameterName']))
    except KeyError:
        errors.append('Could not found {}/{}'.format(obj['distName'], parameter['parameterName']))
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


def get_setup_information():
    """
    Get gNB information (only for first cell)

    :return: (dict) e.g.
        {'unit_name': u'ASIB', 'cell_type': u'SANSA', 'technology': u'FDD', 'fbb_info': u'ABIO', 'band': u'n71'}
    """

    setup_info = {
        'unit_name': get_capability_unit_name(),
        'fbb_info': get_fbb_info(),
        'technology': get_duplex(),
        'cell_type': get_gnb_net_arch(),
        'band': get_gnb_band()
    }
    if 'ASOE' in setup_info['unit_name']:
        setup_info.update({'fbb_info': 'ASOE'})
    logger.info('setup info: {}'.format(setup_info))
    return setup_info


@handle_admin
def get_capability_unit_name(*args, **kwargs):
    """
    :return: (str) e.g. 'ASIK', 'ASIB' depending on the configuration
    """

    out = kwargs["connection"].get_detected_hw_info(timeout=60)
    out_system_modules = out['systemModules']
    dict_out_system_modules = dict(out_system_modules[0])
    unit_name_tmp = dict_out_system_modules['productName']
    unit_name = unit_name_tmp[:4:]
    return unit_name


@handle_admin
def get_fbb_info(*args, **kwargs):
    """
    :return: (str) e.g. 'ABIL', 'ABIO' depending on the configuration
    """
    try:
        out = kwargs["connection"].get_fbb_info()
        fbb_info_out = out[0]['productName']
        fbb_info = fbb_info_out[:4:]
        return fbb_info
    except (IndexError, KeyError):
        fbb_info = get_capability_unit_name()
        return fbb_info


@handle_admin
def get_duplex(nrcell=None, *args, **kwargs):
    """
    Get duplex of specified NRCELL, if not specified duplex of NRCELL with lowest number is returned
    :return: (str) 'TDD' or 'FDD' depending on the configuration
    """

    cells_info = kwargs["connection"].get_cells_info()
    cells_info_sorted = sorted(cells_info, key=lambda x: x['id']['internal'])
    nrcells = [item['id']['configuration'].split('NRCELL-')[1] for item in cells_info_sorted]
    if nrcell:
        try:
            assert str(nrcell) in nrcells, 'Specified NRCELL: {} not present in scf'.format(str(nrcell))
        except AssertionError as cell_not_found:
            raise RuntimeError(cell_not_found)
        duplex = cells_info_sorted[nrcells.index(str(nrcell))]['technology']
    else:
        duplex = cells_info_sorted[0]['technology']
    return duplex


@handle_admin
def get_gnb_net_arch(*args, **kwargs):
    """
    :return: (str) gNB network architecture e.g. 'SA', 'NSA' or 'SANSA' depending on the configuration
    """

    out = kwargs["connection"].get_cells_info()
    type = out[0]['cellDepType']
    type = type.replace("+", "")
    return type


@handle_admin
def get_gnb_band(*args, **kwargs):
    """
    :return: (str) e.g. 'n78', 'n71' depending on the band configuration on first cell
    """

    result = kwargs["connection"].get_cells_info()
    return result[0]["band"]


def get_implementation(gnb_ip, nokia_login, nokia_pass):
    """
    :return: str 'l1b' or 'fs' depending on the configuration
    """

    cmd = 'cat /tmp/rat_psconfig.xml | grep L1BypassMap'
    output = run_on_gnb(hostname=gnb_ip, username=nokia_login, password=nokia_pass, cmd=cmd)
    if len(output[1]):
        return 'l1b'
    else:
        return 'fs'


def delete_parameter_from_delta(delta_filepath, parameters, dist_names, target_delta_filepath=None):
    """
    Modify json delta file by deleting specified parameters.

    :param delta_filepath: (str)
    :param parameters: (list) e.g. [{"parameterName": "idleMMEnDcSteeringPercentageOfUes",
                                    "operation": "update", "value": "100"}]
    :param dist_names: (list) e.g. ['MRBTS-1/NRBTS-1/NRMOPR_SA-1/NRMOIMP_SA-1']
    :param target_delta_filepath: (str) On default overwrites source delta file path
    :return target_delta_filepath:
    """

    target_delta_filepath = target_delta_filepath if target_delta_filepath is not None else delta_filepath
    with open(delta_filepath, 'r') as delta:
        parsed = json.load(delta)
        for obj in parsed:
            if obj['distName'] in dist_names:
                for param_cfg in parameters:
                    try:
                        obj['parameters'].remove(param_cfg)
                    except ValueError:
                        logger.debug('{} not found in {}'.format(param_cfg, delta_filepath))
        form = json.dumps(parsed, indent=4)
    with open(target_delta_filepath, 'w') as delta:
        delta.write(form)
    return target_delta_filepath


@handle_admin
def check_xnlink_status(status="available", *args, **kwargs):
    configuration = kwargs["connection"].get_scf(export_type="configurationAndRuntimeObjects")
    tree = ET.ElementTree(ET.fromstring(configuration))
    results = tree.findall(".//{raml21.xsd}managedObject")
    mo_elem = None
    xnlink_status = None
    for mo in results:
        if mo.attrib["distName"] == "MRBTS-1/NRBTS-1/XNLINK-1":
            print(mo.attrib["distName"])
            mo_elem = mo
            break
    else:
        raise KeyError("MRBTS-1/NRBTS-1/XNLINK-1 was not found in SCF")
    parameters = mo_elem.findall(".//{raml21.xsd}p")
    for param in parameters:
        if param.attrib.get("name", None) == "xnLinkStatus":
            xnlink_status = param.text
            break
    else:
        raise KeyError("Param xnLinkStatus was not found in MRBTS-1/NRBTS-1/XNLINK-1")
    assert xnlink_status == status, "xnLinkStatus is not available! Current status: {}".format(xnlink_status)


@handle_admin
def change_bts_rad_parameters(component, params, timeout=10, *args, **kwargs):
    result = kwargs['connection'].change_bts_rad_parameters(
        component=component,
        params=params,
        timeout=timeout
    )
    assert result['resultNode']['parameters']['status'] == 'Succeeded', "R&D parameter configuration has failed"
    logger_console("R&D parameter configuration success")


@handle_admin
def download_and_upload_bsr_package(artifactory_url, bsr_artifactory_filename, bsr_package_to_upload,
                                    bts_state='configured', logs_dir=None, **kwargs):
    """
    Download BSR package from artifactory, unzip and and load to gNB designated inner package.
    Note: Additionally scf reconfiguration is needed for BSR package to be used.

    :param bsr_artifactory_filename: (str) Package name to be downloaded from Artifactory
    :param bsr_package_to_upload: (str) Filename of the BSR zip package that should be uploaded to gNB
    :param artifactory_url: (str) Artifactory URL
    :param bts_state: (str) Requested BTS state before BSR package upload
    :param logs_dir: (str) Destination where package will be downloaded
    """

    def create_dir_and_unzip_file():
        try:
            os.mkdir(bsr_package_uzip_path)
        except OSError:
            rmtree(bsr_package_uzip_path)
            os.mkdir(bsr_package_uzip_path)
        unzip_file(file_path=bsr_package_path, destination=bsr_package_uzip_path)
        logger_info('{} unzipped into {}'.format(bsr_package_path, bsr_package_uzip_path))

    logs_dir = logs_dir if logs_dir is not None else BuiltIn().get_variable_value('${OUTPUT_DIR}')
    wait_for_requested_bts_state(bts_state=bts_state)
    logger_console_info('Downloading BSR package')
    bsr_package_path = download_artifactory_file(
        artifactory_url=artifactory_url,
        filename=bsr_artifactory_filename,
        target_dir=logs_dir
    )
    bsr_package_uzip_path = os.path.join(logs_dir, 'BSR_package')
    create_dir_and_unzip_file()
    logger_console_info('Uploading BSR package')
    bsr_package_to_upload_path = os.path.join(bsr_package_uzip_path, bsr_package_to_upload)
    kwargs['connection'].update_software(sw_package=bsr_package_to_upload_path)
    logger_console_info('BSR package successfully downloaded and loaded into gNB')


@handle_admin
def remove_bsr_package(bsr_package_name, **kwargs):
    """
    Remove uploaded BSR package.

    Note: Package cannot be in use while deleting, in other case admin will fail with error code: 7.
          Before deleting BSR package perform scf reconfiguration.

    :param bsr_package_name: (str) Filename of the BSR package that should be deleted
                            e.g. BSR_AQQA_6_H6_ALN45_ARP45_N01_COVERAGE_00391_00001
    """

    kwargs['connection'].delete_bsr_file(bsr_files=bsr_package_name)
    logger_console_info('{} removed from gNB'.format(bsr_package_name))


@handle_admin
def amf_block_ng_link(**kwargs):
    """
    Lock AMF NG Link
    :param kwargs:
    """
    logger_console("Lock AMF NG Link")
    dist_name = kwargs.get("dist_name", "MRBTS-1/NRBTS-1/SERVEDAMF-1")
    amf_block = kwargs['connection'].lock_ng_link(dist_name)
    assert "completed" in amf_block, f"Failed to block NG link: {amf_block}"


@handle_admin
def amf_unblock_ng_link(**kwargs):
    """
    Unlock AMF NG Link
    :param kwargs:
    """
    logger_console("Unlock AMF NG Link")
    dist_name = kwargs.get("dist_name", "MRBTS-1/NRBTS-1/SERVEDAMF-1")
    amf_unlock = kwargs['connection'].unlock_ng_link(dist_name)
    assert "completed" in amf_unlock, f"Failed to unblock NG link: {amf_unlock}"


@handle_admin
def start_ip_capture_file(**kwargs):
    """
    Start ip capture pcap file
    :param kwargs:
    """
    logger_console("Starting ip capture pcap file")
    pcap_ip_start = kwargs['connection'].\
        start_ip_capture_file(measurement_point=kwargs.get("measurement_point",
                                                           "Transport_Interface"),
                              uplane_capturing=kwargs.get("uplane_capturing", False))
    assert "Succeeded" in pcap_ip_start, f"Failed to start IP capture: {pcap_ip_start}"


@handle_admin
def stop_ip_capture_file(**kwargs):
    """
    Stop ip capture pcap file
    :param kwargs:
    :return: pcap_ip_stop success messages
    """
    logger_console("Stopping ip capture pcap file")
    pcap_ip_stop = kwargs['connection'].stop_ip_capture_file()
    assert "Succeeded" in pcap_ip_stop, f"Failed to stop IP capture: {pcap_ip_stop}"


@handle_admin
def generate_ip_capture_file(**kwargs):
    """
    Generate ip capture pcap file
    :param kwargs:
    :return: pcap_ip_generate success messages
    """
    pcap_ip_generate = kwargs['connection'].generate_ip_capture_file()
    assert "Succeeded" in pcap_ip_generate, f"Failed to generate IP capture: {pcap_ip_generate}"


@handle_admin
def download_ip_capture_file(**kwargs):
    """
    Download ip capture pcap file
    :param kwargs:
    :return: pcap_ip_download, output_tsc first element is success messages, second is the path to the
     file in output directory
    """
    logger_console("Downloading ip capture pcap file")
    file_name = kwargs.get("target_file_name", "bts_ip_capture_file.pcap")
    pcap_ip_download = \
        kwargs['connection'].download_ip_capture_file(target_file_name=file_name)
    assert "succeeded" in pcap_ip_download, f"Failed to download IP capture: {pcap_ip_download}"
    curdir_file = os.path.join(os.getcwd(), file_name)
    output_tsc = os.path.join(BuiltIn().get_variable_value('${OUTPUT_DIR}'), file_name)
    logger_console(f"mv {curdir_file} {output_tsc}")
    OperatingSystem().run(f"mv {curdir_file} {output_tsc}")
    return output_tsc


@handle_admin
def get_managed_objects_parameters(**kwargs):
    """
    Get all managed objects and their parameters from gNB
    :return: list of dictionaries with managed objects and their parameters
    """
    class_name = kwargs.get("class_name", "NRBTS_A")
    return kwargs['connection'].get_managed_objects(class_name=class_name, timeout=30)


@handle_admin
def get_parameter_by_distname_parameters(**kwargs):
    dist_name = kwargs.get("dist_name", "MRBTS-1/NRBTS-1/SERVEDAMF-1/NRPLMN_SUPPORT-1")
    return kwargs['connection'].get_parameter_by_distname(dist_name)
