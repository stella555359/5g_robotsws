# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Mateusz Adamek, Adrianna Pienkowska
:contact: mateusz.adamek@nokia.com, adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
import itertools
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from ta5g_ue_mobility import ta5g_ue_mobility
from ta5g_interface_tools import ta5g_interface_tools
from taf.config.wts import wts
from ute_common_store.exception import NameIsProtected
from math import floor
import netifaces as ni
import subprocess as sp
import psutil
import time
import sys
import os
import io
import re
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import (
    add_ip_addr_on_vm, reset_units_and_wait_for_radio_head_online, get_mrbts_nrbts_ids,
    load_scf_from_site_and_get_taf_scf_instance, wait_for_requested_bts_state, RadioHeadTimeoutException,
    get_capability_unit_name, reset_airphone
)
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_console, logger_console_info, logger_debug
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_vdu import vDU

_REGISTER_UE_REGEXP = "Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID"


class WtsEnvironmentPreparationFailure(Exception):
    pass


class WrongUeThupValue(Exception):
    pass


def run_egate_cmd(cmd, pass_regexp=None, fail_regexp=None, timeout=30):
    """Runs given Egate command.

    :param cmd: command to run
    :param pass_regexp: regexp, which says that command was executed properly
    :param fail_regexp: regexp, which says that command was ended with failure
    :param timeout: defaults to 30
    """
    egate = BuiltIn().get_library_instance("ta5g_egate")
    logger_console("Running cmd: {} ...".format(cmd))
    egate._ute_wtssim_instance.execute_egate_command(cmd=cmd,
                                                     pass_regexp=pass_regexp,
                                                     fail_regexp=fail_regexp,
                                                     timeout=timeout)


def run_egate_cmd_and_wait_for_data(cmd, return_output=True, pass_regexp=None, timeout=30):
    """Runs given Egate command and waits for response until pass_regex apears in output.

    :param cmd: command to run
    :param pass_regexp: regexp, which says that command was executed properly
    :param return_output: boolen, set to True returns output
    :param timeout: defaults to 30
    """
    egate = BuiltIn().get_library_instance("ta5g_egate")
    logger_console("Running cmd: {} ...".format(cmd))
    output = egate._ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd=cmd,
                                                                                return_output=return_output,
                                                                                pass_regexp=pass_regexp,
                                                                                timeout=timeout)
    logger_console("Comand {} output:\n".format(cmd, output))
    return output


def select_plmn(gnb_id, selected_plmn, serving_plmn):
    CMD = 'enb_endc_param id={} selected_plmn={} serving_plmn={}'.format(gnb_id, selected_plmn, serving_plmn)
    run_egate_cmd(CMD)


def check_bearer_stats(bearer_id, ue_id):
    return run_egate_cmd_and_wait_for_data('bearer_stats id={} ue={}'.format(bearer_id, ue_id))


def check_uec_stats(enb_id=1):
    return run_egate_cmd_and_wait_for_data('uec_stats enb={}'.format(enb_id))


def check_thuput_from_bearer(bearer_id, ue_id):
    raw_output = check_bearer_stats(bearer_id, ue_id)
    _re_thput = r'\d+\s\((?P<THPUT>.*)\sM\)'
    output = raw_output.split('\r\n')[0]
    for line in output.split('\n'):
        if 'Average data rate' in line:
            traffic = re.split(r'\s\s+', line)[1]
    thput_search = re.search(_re_thput, traffic)
    thuput = float(thput_search.group('THPUT'))
    return thuput


def check_thuput_in_range(thup, range, expected_value):
    if not (abs(float(thup)-float(expected_value)) < float(range)):
        raise WrongUeThupValue('Expected value {} in range {}, but recived {}'.format(expected_value, range, thup))


def validate_thuput_from_bearer_stats_for_ue(bearer_id, ue_id, range, expected_value):
    thup = check_thuput_from_bearer(bearer_id, ue_id)
    check_thuput_in_range(thup, range, expected_value)


def check_ue_egate_stats_and_validate_av_thput(ues_ids, range, expected_value, scell=None, type=None):
    stats = check_ue_thput_stats(ues_ids, scell, type)
    logger_console(stats)
    ue_dict = _parse_ue_stats(stats)
    logger_console(ue_dict)
    validate_average_ue_egate_thput_in_range(ue_dict, range, expected_value)


def check_ue_thput_stats(ues_ids=1, scell=None, type=None, **kwargs):
    CMD = 'ue_stats_nr id='
    if isinstance(ues_ids, list):
        ues_ids = ','.join(ues_ids)
    CMD = '{}{}'.format(CMD, ues_ids)
    if scell:
        CMD = '{} scell={}'.format(CMD, scell)
    if type:
        CMD = '{} type={}'.format(CMD, type)
    return run_egate_cmd_and_wait_for_data(CMD, **kwargs)


def check_ue_thput_stats_and_return_parse_output(ues_ids, scell=None, type=None):
    stats = check_ue_thput_stats(ues_ids, scell, type)
    logger_console(stats)
    ue_dict = _parse_ue_stats(stats)
    logger_console(ue_dict)
    return ue_dict


def _parse_ue_stats(data):
    """
    Convert output from ue_stats_nr WTS command into list of throughput statistics per cell

    :param data: (str) ue_stats_nr WTS command output
    :return: list of dicts e.g. [{'CellIndex': 'CellIndex-0', 'Current': '68.6 Mbps',
             'Minimum': '66.1 Mbps', 'Maximum': '72.8 Mbps', 'Average': '69.3 Mbps'}, {...}, ...]
    """

    def validate_output():
        if not ue_stats:
            raise WrongUeThupValue('Could not retrieve UE throughput statistics')
        try:
            for item_dict in ue_stats:
                if not all(keys in ['CellIndex', 'Current', 'Minimum', 'Maximum', 'Average']
                           for keys in item_dict.keys()):
                    raise ValueError('Missing key in ue_stats')
        except ValueError as validation_failue:
            logger_debug(f'Parser output data: {ue_stats}')
            logger_debug(f'Parser input data: {[data]}')
            raise WrongUeThupValue('Failure during parsing UE throughput statistics') from validation_failue

    ue_stats = []
    tput_stats = [line for line in data.split('\r\n') if 'cellindex' in line.lower() and 'inf' not in line.lower()]
    key_tuple = tuple(tput_stats[0].split())
    for line in tput_stats[1:]:
        cell_tput_stats_dict = {}
        value_tuple = tuple([tput_val.strip() for tput_val in line.split('  ') if tput_val != ''])
        for key, value in zip(key_tuple, value_tuple):
            cell_tput_stats_dict.update({key: value})
        ue_stats.append(cell_tput_stats_dict)
    validate_output()
    return ue_stats


def validate_average_ue_egate_thput_in_range(ue_dict, range, expected_value):
    for ue in ue_dict:
        try:
            throughput, unit = ue['Average'].split()
            check_thuput_in_range(throughput, range, expected_value)
        except ValueError:
            check_thuput_in_range(ue['Average'], range, expected_value)
        except KeyError:
            raise WrongUeThupValue('No throughput value')


def wait_for_information_block_reception(sib_reception_dict=None, timeout=360,
                                         info_block_type='SystemInformationBlockType1'):
    """Waits for sib reception.

    :param sib_reception_dict: dict, where key is gNB number, and item is list with cells, defaults to {2: [1]}
    :param timeout: timeout for sib1_reception waiting
    :param info_block_type: Type of InfoBlock e.g. 'MasterInformationBlock', 'SystemInformationBlockType1'
    """
    if sib_reception_dict is None:
        sib_reception_dict = {2: [1]}
    egate = BuiltIn().get_library_instance("ta5g_egate")
    logger_console("Waiting for BTS ready state (waiting for SIB reception) ...")
    egate.wait_for_information_block_reception_for_given_cells(
        cells=sib_reception_dict, infoblocktype=info_block_type, timeout=timeout)


def start_wts_wait_for_ready_state_nsa_sa(wts_config_filename='/opt/wts/latest/basic_setup.cfg',
                                          wts_dir_path='/opt/wts/latest', edaemon_port='22222', egate_port='20000',
                                          sib_reception_dict=None, timeout=360, type='sa', x2_reception_dict=None):
    """Starts WTS and waits for ready state. Starts edaemon, egate,
    loads config wts file and then waits for sib reception.

    :param wts_config_filename: path to basic_wts.cfg
    :param wts_dir_path: path to wts executables, defaults to /opt/wts/latest
    :param edaemon_port: port, at which edaemon will start, defaults to 22222
    :param egate_port: port, at which egate will start, defaults to 20000
    :param sib_reception_dict: dict, where key is cell number, and item is list with sibs, defaults to {2: [1]}
    :param timeout: timeout for sib1_reception waiting
    :param sa: str, expected values: [sa, nsa, sa+nsa], default sa
    :param x2_reception_dict: dict, where key is cell number, and item is list with x2, defaults to {2: [2]}
    """
    if type == "sa":
        start_wts_and_wait_for_ready_state(wts_config_filename, wts_dir_path, edaemon_port,
                                           egate_port, sib_reception_dict, timeout)
    elif type == "nsa":
        start_wts_and_wait_for_ready_state_nsa(wts_config_filename, wts_dir_path, edaemon_port,
                                               egate_port, sib_reception_dict, timeout)
    else:
        start_wts_and_wait_for_ready_state(wts_config_filename, wts_dir_path, edaemon_port,
                                           egate_port, sib_reception_dict, timeout)
        setup_x2_link()
        if not x2_reception_dict:
            x2_reception_dict = {2: [2]}
        wait_for_information_block_reception(x2_reception_dict, "MaterInformationBlock")


def start_wts(wts_config_filename, wts_dir_path='/opt/wts/latest',
              edaemon_port='22222', egate_port='20000'):
    """Starts WTS and waits for ready state. Starts edaemon, egate, loads config wts file.

    :param wts_config_filename: path to basic_wts.cfg
    :param wts_dir_path: path to wts executables, defaults to /opt/wts/latest
    :param edaemon_port: port, at which edaemon will start, defaults to 22222
    :param egate_port: port, at which egate will start, defaults to 20000
    """
    egate = BuiltIn().get_library_instance("ta5g_egate")
    logger_console("Starting WTS applications... Using config Path: {}".format(wts_config_filename))
    egate._ute_wtssim_instance.start_wts_applications(
        edaemon_ports=edaemon_port,
        egate_port=egate_port,
        cfg_file=wts_config_filename,
        tool_dir=wts_dir_path,
        timeout="5minutes"
    )


def wait_for_until_amf_goes_up():
    """Waits until AMF goes up.
    """
    egate = BuiltIn().get_library_instance("ta5g_egate")
    logger_console("Waiting for AMF...")
    for _ in range(12):
        try:
            egate.verify_egate_content("AMF-1: Established NG links to real gNBs:")
            return
        except AssertionError:
            time.sleep(30)
    else:
        raise WtsEnvironmentPreparationFailure("AMF has not gone up!")


def start_wts_and_wait_for_ready_state(wts_config_filename='/opt/wts/latest/basic_setup.cfg',
                                       wts_dir_path='/opt/wts/latest', edaemon_port='22222', egate_port='20000',
                                       sib_reception_dict=None, timeout=360):
    """Starts WTS and waits for ready state. Starts edaemon, egate,
    loads config wts file and then waits for sib reception.

    :param wts_config_filename: path to basic_wts.cfg
    :param wts_dir_path: path to wts executables, defaults to /opt/wts/latest
    :param edaemon_port: port, at which edaemon will start, defaults to 22222
    :param egate_port: port, at which egate will start, defaults to 20000
    :param sib_reception_dict: dict, where key is cell number, and item is list with sibs, defaults to {2: [1]}
    :param timeout: timeout for sib1_reception waiting
    """
    if sib_reception_dict is None:
        sib_reception_dict = {2: [1]}
    start_wts(wts_config_filename=wts_config_filename,
              wts_dir_path=wts_dir_path,
              edaemon_port=edaemon_port,
              egate_port=egate_port)
    wait_for_information_block_reception(sib_reception_dict=sib_reception_dict,
                                         timeout=timeout)


def start_wts_and_wait_for_ready_state_nsa(wts_config_filename='/opt/wts/latest/basic_setup.cfg',
                                           wts_dir_path='/opt/wts/latest', edaemon_port='22222', egate_port='20000',
                                           sib_reception_dict=None, timeout=360):
    """Starts WTS and waits for ready state. Starts edaemon, egate,
    loads config wts file and then waits for sib reception.

    :param wts_config_filename: path to basic_wts.cfg
    :param wts_dir_path: path to wts executables, defaults to /opt/wts/latest
    :param edaemon_port: port, at which edaemon will start, defaults to 22222
    :param egate_port: port, at which egate will start, defaults to 20000
    :param sib_reception_dict: dict, where key is cell number, and item is list with sibs, defaults to {2: [1]}
    :param timeout: timeout for sib1_reception waiting
    """
    if sib_reception_dict is None:
        sib_reception_dict = {2: [1]}
    start_wts(wts_config_filename=wts_config_filename,
              wts_dir_path=wts_dir_path,
              edaemon_port=edaemon_port,
              egate_port=egate_port)
    wait_for_until_amf_goes_up()
    setup_x2_link()
    wait_for_information_block_reception(sib_reception_dict=sib_reception_dict,
                                         timeout=timeout)


def wait_for_environment_prepared_for_wts_ready_state(
            retry=3, retry_interval=15,
            wts_config_filename='/opt/wts/latest/basic_setup.cfg',
            wts_dir_path='/opt/wts/latest',
            edaemon_port='22222',
            egate_port='20000',
            validate_mib_sib=True,
            allow_first_reboot=True,
            sib_reception_dict=None,
            secondary_gnb_ip=None,
            info_block_type='SystemInformationBlockType1',
            timeout=360,
            reboot_fun=reset_units_and_wait_for_radio_head_online):

    def exception_wts_fun(exception_during_call):
        status_wts_teardown = None
        try:
            stop_wts_and_clear()
            status_wts_teardown = "FINE"
        except Exception as e:
            status_wts_teardown = e
        msg = "Unknown Exception: {}\nWTS Teardown status: {}".format(exception_during_call, status_wts_teardown)
        logger_console(msg, prefix=" [Console, WTS Ready Check] ")
        return msg

    if sib_reception_dict is None:
        sib_reception_dict = {2: [1]}
    stats = []
    is_env_prepared = False
    logger_console("Waiting for Environment prepared for WTS ready state...")
    while retry > 0:
        retry -= 1

        try:
            if allow_first_reboot:
                logger_console("Resetting Units...", prefix=" [Console, WTS Ready Check] ")
                reboot_fun(secondary_gnb_ip=secondary_gnb_ip)
            logger_console("Starting WTS...", prefix=" [Console, WTS Ready Check] ")
            start_wts(wts_config_filename=wts_config_filename,
                      wts_dir_path=wts_dir_path,
                      edaemon_port=edaemon_port,
                      egate_port=egate_port)
            if validate_mib_sib:
                logger_console("Validating MIB & SIB...", prefix=" [Console, WTS Ready Check] ")
                wait_for_information_block_reception(sib_reception_dict=sib_reception_dict,
                                                     info_block_type=info_block_type,
                                                     timeout=timeout)
            is_env_prepared = True
        except RadioHeadTimeoutException as e:
            msg = 'RU could not get online: {}'.format(e)
            logger_console(msg, prefix=" [Console, WTS Ready Check] ")
            stats.append(msg)
        except NameIsProtected as e:
            stats.append(exception_wts_fun(e))
        except Exception as e:
            stats.append(exception_wts_fun(e))
        finally:
            allow_first_reboot = True

        if is_env_prepared:
            break
        time.sleep(retry_interval)
    else:
        raise WtsEnvironmentPreparationFailure('Cannot prepare WTS Environment: {}'.format(stats))


def reboot_ap_and_vdu_and_wait_for_radio_online(**kwargs):
    reset_airphone()
    vDU().reboot_vdu()
    vDU().wait_until_radio_units_are_online()


def copy_egate_console_log_to_specified_dir(subdirectory="wts", prefix=""):
    """Copy egate console log to specified directory in output_dir directory.

    :param subdirectory: subdirectory to be created in output directory of logs
    :param prefix: prefix for the file name
    """
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    if not prefix:
        if not test_name:
            prefix = BuiltIn().get_variable_value('${SUITE_NAME}')
        else:
            prefix = test_name
    dest_file_path = os.path.join(output_dir, subdirectory, 'egate_console_{}.log'.format(prefix))
    OperatingSystem().copy_files('/opt/wts/latest/*console.log.*', dest_file_path)


def copy_wts_files_to_epcsim_dir_path(wts_config_filename=None, ap_config_filename=None, ap_config_path=None,
                                      wts_config_dir_path=None, epcsim_dir_path=None, output_subdir='wts'):
    """Copy wts configuration files to WTS bin path.

    :param wts_config_filename: filename of WTS config
    :param ap_config_filename: filename of AirPhone.xml config file
    :type ap_config_filename: optional
    :param ap_config_path: path of AirPhone.xml config file
    :type ap_config_path: optional
    :param wts_config_dir_path: absolute path to the directory with the wts_config_filename
    :param epcsim_dir_path: directory with wts binaries
    :param output_subdir: if set, will copy wts config to output_subdir location
    """

    def get_var_value_from_args_or_robot(value, robot_name, skip_warning=False):
        var_value = BuiltIn().get_variable_value(robot_name) if value is None else value
        if not var_value and not skip_warning:
            logger.warn("Value of {} is empty.".format(robot_name))
        return var_value

    wts_config_filename = get_var_value_from_args_or_robot(wts_config_filename, "${WTS_CONFIG_FILENAME}")
    wts_config_dir_path = get_var_value_from_args_or_robot(wts_config_dir_path, "${RESOURCES_WTS_CFGS_DIR}")
    epcsim_dir_path = get_var_value_from_args_or_robot(epcsim_dir_path, "${EPCSIM_DIR_PATH}")
    ap_config_filename = get_var_value_from_args_or_robot(ap_config_filename, "${AIRPHONE_CONFIG_FILENAME}",
                                                          skip_warning=True)
    ap_config_path = get_var_value_from_args_or_robot(ap_config_path, "${AIRPHONE_CONFIG_PATH}", skip_warning=True)
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    wts_config_path = os.path.join(wts_config_dir_path, wts_config_filename)
    if not ap_config_path and ap_config_filename:
        airphone_config_path = os.path.join(wts_config_dir_path, ap_config_filename)

    if ap_config_path:
        OperatingSystem().copy_file(source=ap_config_path, destination=epcsim_dir_path)
    OperatingSystem().copy_file(source=wts_config_path, destination=epcsim_dir_path)
    if output_subdir:
        OperatingSystem().copy_file(source=wts_config_path, destination="{}/{}/".format(output_dir, output_subdir))


def stop_wts_and_collect_its_logs(subdirectory="wts", unzip=None):
    """Stop WTS and collects its logs.
    """
    BuiltIn().get_library_instance("ta5g_egate")._ute_wtssim_instance.stop_and_collect_wts_logs(
        subdirectory=subdirectory, unzip=unzip)


def stop_wts_and_clear(subdirectory="wts", unzip=None):
    """Stops WTS, collects all WTS logs and teardown all aliases for egate and WTS.
    """
    logger_console("Stopping WTS...")
    egate = BuiltIn().get_library_instance("ta5g_egate")
    egate._ute_wtssim_instance.stop_and_collect_wts_logs(subdirectory=subdirectory, unzip=unzip)
    egate._ute_wtssim_instance.teardown_all_aliases_for_egate()
    egate._ute_wtssim_instance.teardown_all_aliases_for_wts()


def collect_sos_report_log(prefix=None, log_output_dir=None):
    """Collect SOS Report log; keep in mind that this method runs `sosReport.sh -nr -c -s` which results in
    collection of full SOS Report, including BTS and AirPhone snapshots

    :param prefix: string that will be added to the sos_report compressed file directory name
    :param log_output_dir: dir where sos_report should be saved
    :return:
    """
    if log_output_dir is None:
        if prefix is None:
            prefix = ta5g_interface_tools().get_robot_test_name()
        output_dir = ta5g_interface_tools().get_robot_output_dir()
        log_output_dir = os.path.join(output_dir, "sos_report", "sos_report_{}".format(prefix))
    else:
        if prefix is not None:
            log_output_dir = os.path.join(log_output_dir, "sos_report_{}".format(prefix))
    if not os.path.exists(log_output_dir):
        OperatingSystem().create_directory(log_output_dir)
    logger_console("Collecting SOS report")
    ta5g_setups_and_teardowns = BuiltIn().get_library_instance('ta5g_setups_and_teardowns')
    ta5g_setups_and_teardowns.collect_sos_report(output_dirpath=log_output_dir)


def register_nsa_ue(ue_id='1', cell_id='1', enb_id='2'):
    """Calls ue_register on Egate.

    :param ue_id: defaults to 1
    :param cell_id: defaults to 1
    :param enb_id: defaults to 2
    """
    global _REGISTER_UE_REGEXP

    logger_console("Attaching UE {} to cell {} at gNB {}...".format(ue_id, cell_id, enb_id))
    ta5g_ue_mobility().attach_ue(
        ue_id=ue_id,
        cell=cell_id,
        enb=enb_id,
        timeout=60,
        pass_regexp=_REGISTER_UE_REGEXP
    )

    logger_console("Waiting for UE ready state...")
    time.sleep(4)


def register_ue(ue_id='1', enb_id='2', cell_id=None):
    """Calls ue_register on Egate.

    :param ue_id: defaults to 1
    :param cell_id: defaults to 1
    :param enb_id: defaults to 2
    """
    global _REGISTER_UE_REGEXP

    logger_console("Attaching UE {} to cell {} at gNB {}...".format(ue_id, cell_id, enb_id))
    ta5g_ue_mobility().attach_ue(
        ue_id=ue_id,
        cell=cell_id,
        enb=enb_id,
        timeout=60,
        pass_regexp=_REGISTER_UE_REGEXP
    )

    logger_console("Waiting for UE ready state...")
    time.sleep(4)


def establish_pdu_session(ue_id='1', pdu_id='1', nwslice='1', gw_id='1', timeout=60):
    """Calls ue_pdu_session_setup pdu=1 ue=<ue_id> nwslice=1 gw=1

    :param ue_id: defaults to 1
    :param timeout: defaults to 60
    """
    msg = "Establishing PDU session {} for UE {} with nwslice {} and gw {}...".format(pdu_id, ue_id, nwslice, gw_id)
    logger_console(msg)
    ta5g_ue_mobility().establish_pdu_session(ue_id=ue_id, pdu_id=pdu_id, nwslice=nwslice, gw_id=gw_id,
                                             timeout=timeout)

    logger_console("Waiting for PDU session ready state...")
    time.sleep(4)


def modify_pdu_session(ue_id=1, pdu_id=1, qos_to_add=None, qos_to_del=None, by='amf', timeout=10):
    logger_console("Modyfing PDU {} session by {} with UE {}, QoS Add: {}, QoS Del: {}".format(
        pdu_id, by, ue_id, qos_to_add, qos_to_del
    ))
    ta5g_ue_mobility().modify_pdu_session(ue_id=ue_id, pdu_id=pdu_id, qos_to_add=qos_to_add, qos_to_del=qos_to_del,
                                          by=by, timeout=timeout)
    logger_console("Waiting for PDU session ready state...")
    time.sleep(2)


def deregister_ue(ue_id='1', pass_regexp=None):
    logger_console('Detaching UE {} ...'.format(ue_id))
    ta5g_ue_mobility().deregister_ue(ue_id=ue_id, pass_regexp=pass_regexp)

    logger_console("Waiting for WTS ready state...")
    time.sleep(2)


def release_pdu_session(ue_id='1', pdu_id='1'):
    logger_console("Releasing PDU session {} for UE {}...".format(pdu_id, ue_id))
    ta5g_ue_mobility().release_pdu_session(ue_id=ue_id, pdu_id=pdu_id)

    logger_console("Waiting for WTS ready state...")
    time.sleep(2)


def __ensure_bh_on_eth_is_ok(eth, bh_ip_addr):
    """
    Retrieves all addresses at given eth interface and checks if IPs exists in given
    bh_ip_addr list. If not, IP address is added to given eth.

    :param eth: str should be eth3 or eth4 (checking BH)
    :param bh_ip_addr: list(str) expected IP addresses of BH IPs
    """
    addresses = ni.ifaddresses(eth)[ni.AF_INET]
    addresses_list = []
    for addr in addresses:
        addresses_list.append(addr['addr'])

    for ip_addr in bh_ip_addr:
        if ip_addr in addresses_list:
            continue
        else:
            logger_console("{} BH address {} is not configured! Adding...".format(eth, ip_addr))
            add_ip_addr_on_vm(ip_addr=ip_addr, interface=eth)

    logger_console("{} BH addresses are OK!".format(eth))


def ensure_eth3_bh_is_ok(bh3_addr_list):
    """Ensures, that all addresses on ETH3 are fine. If they are not, they are added.

    :param bh3_addr_list: list of IP addresses, that should be found on eth3
    """
    __ensure_bh_on_eth_is_ok("eth3", bh3_addr_list)


def ensure_eth4_bh_is_ok(bh4_addr_list):
    """Ensures, that all addresses on ETH4 are fine. If they are not, they are added.

    :param bh4_addr_list: list of IP addresses, that should be found on eth4
    """
    __ensure_bh_on_eth_is_ok("eth4", bh4_addr_list)


def ensure_eth8_bh_is_ok(bh8_addr_list):
    """Ensures, that all addresses on ETH8 are fine. If they are not, they are added.

    :param bh8_addr_list: list of IP addresses, that should be found on eth8
    """
    __ensure_bh_on_eth_is_ok("eth8", bh8_addr_list)


def __check_if_process_running(process_name):
    """Looks for process running (like ps aux) and returns result.
    :param proccess_name: str process name, used specially for edaemon and egate process names.
    :return: is_running bool True if process is running
    """

    logger_console("Looking for {} process running...".format(process_name))
    for proc in psutil.process_iter():
        try:
            if process_name.lower() in proc.name().lower():
                logger_console("Found {} equal to {}".format(process_name, proc.name()))
                return True
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            return True

    logger_console("Cannot find {} process running...".format(process_name))
    return False


def __ensure_script_is_not_running(process_name):
    """Ensures that given process_name is not running. If it is, then process is going to be killed.

    :param process_name: str with process name, ex. edaemon, egate
    """
    if __check_if_process_running(process_name):
        logger_console("Need to kill {} ...".format(process_name))
        stop_wts_script = "sudo pkill {}".format(process_name)
        logger_console("Executing {} ...".format(stop_wts_script))
        OperatingSystem().run(stop_wts_script)


def ensure_wts_is_not_running():
    """Checks, if edaemon or egate processes are running and closes them if needed.
    """
    __ensure_script_is_not_running("edaemon")
    __ensure_script_is_not_running("egate")


def get_parameters_for_wts_configuration(cell_id='1'):
    """
    Download current SCF and read basic parameters relevant for WTS configuration.
    :param cell_id: (str)  Cell to get configuration from
    return: dict of parameters
    """
    parameters = dict()
    current_scf = load_scf_from_site_and_get_taf_scf_instance()
    mrbts_id, nrbts_id = get_mrbts_nrbts_ids()
    mrbts_nrbts = 'MRBTS-{}/NRBTS-{}'.format(mrbts_id, nrbts_id)
    ngc_dist_name = current_scf.get_value_from_scf(
        dist_name='{}/'.format(mrbts_nrbts), list_name='ngCplane', index='0')
    parameters['ngc_ip'] = current_scf.get_value_from_scf(
        dist_name=ngc_dist_name, p_name='localIpAddr')
    parameters['amf_ip'] = current_scf.get_value_from_scf(
        dist_name='{}/SERVEDAMF-1'.format(mrbts_nrbts), p_name='amfIPAddress')
    mcc = current_scf.get_value_from_scf(
        dist_name='{}/NRPLMN-1'.format(mrbts_nrbts), p_name='mcc')
    mnc = current_scf.get_value_from_scf(
        dist_name='{}/NRPLMN-1'.format(mrbts_nrbts), p_name='mnc')
    mnc = '0' + mnc if len(mnc) == 1 else mnc
    parameters['plmn'] = str(mcc) + ':' + str(mnc)
    pci = current_scf.get_value_from_scf(
        dist_name='{}/NRCELL-{}'.format(mrbts_nrbts, cell_id),
        p_name='physCellId')
    parameters['pci'] = str(int(floor(int(pci) / 3))) + ':' + str(int(pci) % 3)
    cell_tech = current_scf.get_value_from_scf(
        dist_name='{}/NRCELL-{}'.format(mrbts_nrbts, cell_id),
        p_name='cellTechnology')
    if cell_tech == 'TDD':
        parameters['cell_tech'] = 'on'
        nrarfcn = current_scf.get_value_from_scf(
            dist_name='{}/NRCELL-{}'.format(mrbts_nrbts, cell_id), p_name='nrarfcn')
        parameters['nrarfcn'] = str(nrarfcn) + ':' + str(nrarfcn)
    else:
        parameters['cell_tech'] = 'off'
        nrarfcn_dl = current_scf.get_value_from_scf(
            dist_name='{}/NRCELL-{}/NRCELL_FDD-1'.format(mrbts_nrbts, cell_id), p_name='nrarfcnDl')
        nrarfcn_ul = current_scf.get_value_from_scf(
            dist_name='{}/NRCELL-{}/NRCELL_FDD-1'.format(mrbts_nrbts, cell_id), p_name='nrarfcnUl')
        parameters['nrarfcn'] = str(nrarfcn_ul) + ':' + str(nrarfcn_dl)
    return parameters


def modify_suci_for_ue(old_suci, plmn):
    """
    Update PLMN in SUCI.

    :param old_suci: SUCI code
    :param plmn: e.g. 510:93
    :return: new SUCI code
    """
    mcc, mnc = plmn.split(":")
    old_suci_len = len(old_suci)
    old_suci = old_suci.split(":", 3)
    new_suci = "0:{}:{}:{}".format(mcc, mnc, old_suci[-1])
    if old_suci_len > len(new_suci):
        for i in range(0, old_suci_len - len(new_suci)):
            new_suci = new_suci + "0"
    elif old_suci_len < len(new_suci):
        for i in range(0, len(new_suci) - old_suci_len):
            new_suci = new_suci[0:-1]
    return new_suci


def get_next_suci(first_suci, eu_id):
    """
    Generates next suci code based on first ur suci and next eu id

    :param first_suci: SUCI code of first ue
    :param id of next ue
    :return: Next suci code
    """
    suci_list = first_suci.split(":")
    string_number = suci_list[-1]
    suci_len = len(string_number)
    number = int(string_number)
    next_suci = number + eu_id - 1
    next_suci_string = str(next_suci)
    while len(next_suci_string) < suci_len:
        next_suci_string = '0' + next_suci_string
    suci_list[-1] = next_suci_string
    output_suci = ':'.join(suci_list)
    return output_suci


def get_next_imsi(imsi, increment=1):
    """
    Generates IMSI incremented by defined value. Example: 311:489:21645501 -> 311:489:21645502

    :param imsi: (str)
    :param increment: (int)
    """
    mcc, mnc, number = imsi.split(':')
    return '{}:{}:{}'.format(mcc, mnc, int(number)+increment)


def get_next_ipv4_address(addr, step=1):
    """
    Get next ipv4 address. e.g. If addr='192.168.0.1' and step=1 returned next_addr will be '192.168.0.2'
    Only for /24 mask

    :param addr: ipv4 address
    :param step: How much the last octet will be incremented
    :return: ipv4 address
    """
    next_addr = [int(i) for i in addr.split('.') if i.isdigit()]
    if next_addr[3] == 255:
        raise ValueError('No more ip addresses in this subnet')
    next_addr[3] = next_addr[3] + step
    next_addr = '.'.join(map(str, next_addr))
    return next_addr


def check_if_ipv4(addr):
    """
    Checks if string is in a format of ipv4 address. Only for a mask equal to /24.

    :param addr: ipv4 address
    :return: True or False
    """
    flag = False
    if "." in addr:
        elements_array = addr.strip().split(".")
        if len(elements_array) == 4:
            for i in elements_array:
                if i.isnumeric() and 0 <= int(i) <= 255:
                    flag = True
                else:
                    flag = False
                    break
    if flag:
        return True
    else:
        return False


def get_value_from_cfg_variables(filepath, variable):
    """
    Recursively searches cfg file for value of variable.
    Call it after taf.config.wts get_parameter()

    :param filepath: Path to WTS cfg file
    :param variable: output from get_parameter()
    """
    while True:
        if variable[0] != "$":
            if variable[0] == '"' and variable[-1] == '"':
                return variable[1:-1]
            return variable
        else:
            with open(filepath, 'rt') as f:
                data = f.readlines()
            for line in data:
                if line.__contains__("set" + " " + variable[1:]):
                    line = line.replace('=', ' ')
                    l_split = line.split()
                    index = l_split.index(variable[1:])
                    variable = l_split[index + 1]
                    break


def configure_ips_on_vm_interfaces(cfg_filepath='/opt/wts/latest/basic_setup.cfg', amf_ip='', addresses=None,
                                   sim_gnb=True, netmask=24, ip_version=4, server_addresses=['CONTAINER_IP']):
    """
    Add Egate server ip and AMF ip on VM interfaces.
    Add IP addresses for NSA and SANSA support.

    :param cfg_filepath: Path to WTS cfg file
    :param addresses: List of WTS addresses to configure, if not set configure all addresses
    :param sim_gnb: (bool) If set to True (and addresses=None) simulated gNB IPs are configured on VM
    :param netmask: (int) Network Mask. Default values: IPv4: 24, IPv6: 64
    :param ip_version: (int) Determine IPv4 or IPv6
    :param server_addresses: (list) Define custom list of server IP addresses
    :param amf_ip: DEPRECATED!
    """
    if not addresses:
        addresses = ['ENB1_S1_ADDR', 'ENB1_X2_ADDR', 'MME1_S1_ADDR', 'SERVER_ADDR', 'SGW_S1U_ADDR',
                     'SGW_S11_ADDR', 'ENB_X2U_ADDR', 'AMF_NG_ADDR', 'AMF2_NG_ADDR', 'AMF3_NG_ADDR',
                     'AMF4_NG_ADDR', 'AMF5_NG_ADDR', 'AMF6_NG_ADDR']
        if sim_gnb:
            addresses = addresses + ['GNB2_NG_ADDR', 'GNB2_XN_ADDR']
    cfg = wts()
    cfg.load_wts_cfg(cfg_filepath)
    for addr in addresses:
        try:
            ip = cfg.get_parameter('set', addr)
            if ip:
                cmd = 'sudo ip -{} addr add {}/{} dev eth3'.format("4" if int(ip_version) == 4 else "6", ip, netmask)
                sp.call([cmd], shell=True)
                logger.debug(cmd)
        except IndexError:
            pass
    try:
        for server_address in server_addresses:
            server_ip = cfg.get_parameter('set', server_address)
            sp.call(['sudo ip addr add {}/24 dev eth4'.format(server_ip)], shell=True)
            logger.debug('sudo ip addr add {}/24 dev eth4'.format(server_ip))
    except IndexError:
        server_ip = cfg.get_parameter('set', 'SERVER_IP')
        sp.call(['sudo ip addr add {}/24 dev eth4'.format(server_ip)], shell=True)
        logger.debug('sudo ip addr add {}/24 dev eth4'.format(server_ip))


def configure_sa_ues_in_wts_cfg_file(cells=[1], num_of_ues=2, ue_caps=None,
                                     path_to_basic_cfg='/opt/wts/latest/basic_setup.cfg',
                                     target_path='/opt/wts/latest/new_basic_setup.cfg'):
    """
    Author: Anna Bien
    Contact: anna.bien@nokia.com
    Configure WTS default basic configuration file. Function adds SA UEs to default configuration file.

    :param cells: List of number of cells
    :param num_of_ues: Target number of SA UEs
    :param ue_caps: special UE capabilities if required
    :param path_to_basic_cfg: Path to default configuration file.
    :param target_path: Path to new configuration file
    :return target_path:
    """

    wts_instance = wts()
    wts_instance.load_wts_cfg(path_to_basic_cfg)
    default_num_of_sa_ues = _check_number_of_ues_in_default_config(wts_instance, configuration_type='SA')
    if ue_caps:
        _set_ue_caps_for_all_ues(wts_instance, ue_caps, default_num_of_sa_ues)
    if num_of_ues <= default_num_of_sa_ues:
        _split_ues_between_cells(wts_instance, cells, num_of_ues)
        wts_instance.save_wts_cfg(target_path)
        return target_path
    old_suci = wts_instance.get_parameter(command='set_ue id=1', parameter='suci')
    wts_instance.modify(command='set_nwslice id=1', modification='ue=all')
    for i in range(1, abs(num_of_ues - default_num_of_sa_ues) + 1):
        new_ue_id = default_num_of_sa_ues + i
        new_suci = get_next_suci(old_suci, new_ue_id)
        old_nat_ip = wts_instance.get_parameter(command='set_pdu_gateway id={}'.format(new_ue_id - 1),
                                                parameter='ue_nat_ip')
        new_nat_ip = get_next_ipv4_address(old_nat_ip)
        wts_instance.clone_and_modify(command='set_ue id=1', modification='id={} suci={}'.format(new_ue_id, new_suci))
        wts_instance.clone_and_modify(command='ue_param id=1', modification='id={}'.format(new_ue_id))
        wts_instance.clone_and_modify(command='set_pdu_gateway id=1',
                                      modification='id={} ue_nat_ip={}'.format(new_ue_id, new_nat_ip))
    _split_ues_between_cells(wts_instance, cells, num_of_ues)
    wts_instance.save_wts_cfg(target_path)
    return target_path


def enable_debug_logging_in_wts_cfg(path_to_basic_cfg='/opt/wts/latest/basic_setup.cfg',
                                    target_path='/opt/wts/latest/new_basic_setup.cfg'):
    PY3 = sys.version_info[0] >= 3
    global unicode
    wts_conf_instance = wts()
    wts_conf_instance.load_wts_cfg(path_to_basic_cfg)

    def fix_smf_upf_mapping():
        cmd = wts_conf_instance.get(command="smf_upf_mapping")
        if cmd:
            wts_conf_instance.delete(command="smf_upf_mapping")
            params = cmd.split("smf_upf_mapping")[1].split()
            ids = [param for param in params if 'id' in param]
            upfs = [param for param in params if 'upf' in param]
            for id_, upf in zip(ids, upfs):
                cmd = "smf_upf_mapping {} {}".format(id_, upf)
                if not PY3:
                    cmd = unicode(cmd)
                wts_conf_instance.insert(command=cmd, location="AFTER",
                                         reference="set_upf id={}".format(len(ids)))

    def ensure_cmd_in_file(ref, modification, full_cmd):
        if wts_conf_instance.get(ref):
            wts_conf_instance.modify(command=ref, modification=modification)
        else:
            if not PY3:
                full_cmd = unicode(full_cmd)
            wts_conf_instance.insert(command=full_cmd, location="BEFORE", reference="cfg_end")

    fix_smf_upf_mapping()
    ensure_cmd_in_file(ref="sim_debug_log level=0", modification="level=0", full_cmd="sim_debug_log level=0")
    ensure_cmd_in_file(ref="debug_log", modification="level=0", full_cmd="debug_log level=0")
    ensure_cmd_in_file(ref="sim_debug_log mme=1", modification="level=0", full_cmd="sim_debug_log level=0 mme=1")
    ensure_cmd_in_file(ref="sim_debug_log pgw=1", modification="level=0", full_cmd="sim_debug_log level=0 pgw=1")
    ensure_cmd_in_file(ref="sim_debug_log uec=1", modification="level=0", full_cmd="sim_debug_log level=0 uec=1")
    ensure_cmd_in_file(ref="sim_debug_log sgw=1", modification="level=0", full_cmd="sim_debug_log level=0 sgw=1")

    wts_conf_instance.save_wts_cfg(target_path)


def _split_ues_between_cells(wts_instance, cells=[1], num_of_ues=2):
    """
    Splits UEs between cells

    :param: wts_instance
    :param cells: List of number of cells
    :param num_of_ues: Target number of SA UEs
    """
    ues_list = [ue_id for ue_id in range(1, num_of_ues + 1)]
    for (ue_id, cell_id) in zip(ues_list, itertools.cycle(cells)):
        wts_instance.modify(command='set_ue id={}'.format(ue_id), modification='cell={}'.format(cell_id))


def _check_number_of_ues_in_default_config(wts_instance, configuration_type='SA', max_num_of_nsa_ues=20):
    """
    Count SA or NSA UEs in default cfg.

    ID convention: Ids from range 1-10 belongs to SA UEs, Ids above 10 belongs to NSA UEs.
    :param configuration_type: 'SA', 'NSA' or 'both'
    :param max_num_of_nsa_ues: (int) Maximum count number of NSA UEs
    """
    num_of_ues = 0
    if configuration_type in ['SA', 'both']:
        for i in range(1, 11):
            num_of_ues = num_of_ues + 1 if wts_instance.get('set_ue id={}'.format(i)) is not None else num_of_ues
    elif configuration_type in ['NSA', 'both']:
        for i in range(11, max_num_of_nsa_ues):
            num_of_ues = num_of_ues + 1 if wts_instance.get('set_ue id={}'.format(i)) is not None else num_of_ues
    return num_of_ues


def _set_ue_caps_for_all_ues(wts_instance, ue_caps, num_of_ues):
    """
    Sets UE Capabilities to all UEs in loaded WTS config

    :param wts_instance: (wts) instance of wts object with loaded WTS config
    :param ue_caps: (str) UE capabilities in WTS config format
    :param num_of_ues: (int) number of ues to iterate over
    """
    for ue in range(1, num_of_ues + 1):
        wts_instance.modify(command='ue_param id={}'.format(ue), modification='ue_nr_capabilities={}'.format(ue_caps))


def perform_attachment_and_pdu_session_establishment_of_multiple_sa_ues(number_of_ues, pdu=1, cell_id=1, enb_id=2,
                                                                        first_ue_number=1):
    """
    Attach multiple SA UEs, establish PDU session and prepare for executing data traffic in egate.

    :param number_of_ues: (int) Number of UEs to which data traffic is started
    :param pdu: (int) PDU id
    :param cell_id: (int or list) Single cell's number or list of cells ids
    :param enb_id: (int)
    :param first_ue_number: (int) First UE number to which data traffic is started
    """
    global _REGISTER_UE_REGEXP
    ues_list = [ue_id for ue_id in range(first_ue_number, int(number_of_ues) + first_ue_number)]
    cells_list = cell_id if type(cell_id) is list else [cell_id]
    for ue_id, cell in zip(ues_list, itertools.cycle(cells_list)):
        attach_ue_and_establish_pdu_session(ue_id=ue_id, cell_id=cell, pdu=pdu, enb_id=enb_id)


def attach_ue_and_establish_pdu_session(ue_id=1, cell_id=1, pdu=1, enb_id=2, pdu_regexp=None, nwslice=1,
                                        optional_parameters=''):
    """
    Attach single SA UE, establish PDU session and prepare for executing data traffic in egate.

    :param ue_id: (int)
    :param pdu: (int) PDU id
    :param cell_id: (int or list) Single cell's number or list of cells ids
    :param enb_id: (int)
    :param pdu_regexp: (str) Pass regexp for PDU session establishment
                             For single UE can be defined as: 'QoS Routing Table'
    :param optional_parameters: (str) Additional attach parameters e.g. 'selected_plmn=540:01'
    """
    global _REGISTER_UE_REGEXP
    command = "set_pdu_param ue={} pdu={} trf_type=internal".format(ue_id, pdu)
    run_egate_cmd(cmd=command)
    ta5g_ue_mobility().attach_ue(ue_id=ue_id, cell=cell_id, enb=enb_id, timeout=60,
                                 pass_regexp=_REGISTER_UE_REGEXP, optional_parameters=optional_parameters)
    ta5g_ue_mobility().establish_pdu_session(ue_id=ue_id, pdu_id=pdu, gw_id=ue_id, timeout=60, pass_regexp=pdu_regexp,
                                             nwslice=nwslice)


def attach_with_sgnb_addition_of_multiple_nsa_ues(number_of_ues=1, bearer=2, cell_id=None, enb_id=2):
    """
    Attach multiple NSA UEs with ids starting from 11.

    :param number_of_ues: (str, int)
    :param bearer: (int)
    :param cell_id: (dict, int) eg. {11:1, 12:2}. If this parameter will be None, all UEs will be assigned to cell
                    id=1
    :param enb_id: (int)
    """
    number_of_ues = int(number_of_ues)
    if cell_id is None:
        ue_id_list = list(range(11, 11 + number_of_ues))
        cell_id = dict.fromkeys(ue_id_list, 1)
    elif type(cell_id) in [str, int]:
        ue_id_list = list(range(11, 11 + number_of_ues))
        cell_id = dict.fromkeys(ue_id_list, int(cell_id))

    ta5g_ue_mobility().setup_x2_link()
    wait_for_requested_bts_state("onair")
    for ue_id in range(11, 11 + number_of_ues):
        attach_ue_and_perform_sgnb_addition(ue_id=ue_id, bearer=bearer, cell_id=cell_id[ue_id], enb_id=enb_id)


def setup_x2_link(initiator_device=1, complementary_device=2, timeout=5, pass_regexp=None):
    """
    runs egate command: enb_x2_link_up enb=initiator_device target=complementary_device and waits for
    pass_regexp until timeout
    default pass_regexp = ENB-{}: X2AP Link with [EG]NB-{} .*

    :param initiator_device:
    :param complementary_device:
    :param timeout:
    :param pass_regexp:

    """
    ta5g_ue_mobility().setup_x2_link(initiator_device, complementary_device, timeout, pass_regexp)


def attach_ue_to_plmn_and_perform_sgnb_addition(ue_id=11, bearer=2, cell_id=1, enb_id=2,
                                                plmn_enb=1, selected_plmn='312:490', serving_plmn='312:490'):
    """
    Attach single NSA UE.

    :param ue_id: (str, int)
    :param bearer: (int)
    :param cell_id: (int)
    :param enb_id: (int)
    :param plmn_enb: (int)
    :param selected_plmn: (str)
    :param serving_plmn: (str)
    """
    ta5g_ue_mobility().attach_ue_to_enb(
        ue_id=ue_id,
        pass_regexp='UE{}: === UE IS ACTIVE'.format(ue_id)
    )
    select_plmn(plmn_enb, selected_plmn, serving_plmn)
    ta5g_ue_mobility().start_gnb_addition_procedure(
        ue=ue_id,
        target_gnb=enb_id,
        target_cells=cell_id,
        bearer=bearer,
        dc_type='split_scg',
        pass_regexp=r'UE{}: Proxy [(]eNB \d+ cell \d+[)] reported successful RA'.format(ue_id)
    )


def attach_ue_and_perform_sgnb_addition(ue_id=11, bearer=2, cell_id=1, enb_id=2, profile=None, timeout=5):
    """
    Attach single NSA UE.

    :param ue_id: (str, int)
    :param bearer: (int)
    :param cell_id: (int)
    :param enb_id: (int)
    """
    if profile is not None:
        ta5g_ue_mobility().attach_ue_to_enb(
            ue_id=ue_id,
            pass_regexp='UE{}: === UE IS ACTIVE'.format(ue_id),
            optional_parameters="profile={}".format(profile)
        )
    else:
        ta5g_ue_mobility().attach_ue_to_enb(
            ue_id=ue_id,
            pass_regexp='UE{}: === UE IS ACTIVE'.format(ue_id)
        )
    time.sleep(2)
    ta5g_ue_mobility().start_gnb_addition_procedure(
        ue=ue_id,
        target_gnb=enb_id,
        target_cells=cell_id,
        bearer=bearer,
        dc_type='split_scg',
        pass_regexp=r'UE{}: Proxy [(]eNB \d+ cell \d+[)] reported successful RA'.format(ue_id),
        timeout=timeout
    )


def detach_ue(ue_id='1'):
    logger_console('Detaching UE {} ...'.format(ue_id))
    ta5g_ue_mobility().detach_ue(ue_id=ue_id)

    logger_console("Waiting for WTS ready state...")
    time.sleep(2)


def handle_traffic_for_multiple_ues(num_of_sa_ues=None, num_of_nsa_ues=None, traffic_direction='bi',
                                    first_sa_ue_id=1, first_nsa_ue_id=11, ul_mbps=2, dl_mbps=50, traffic_duration=5,
                                    console_info=True, **kwargs):
    """
    Handle ping for multiple SA and NSA UEs at the same time

    :param num_of_sa_ues: (str) Number of SA UEs to which the ping is sent
    :param num_of_nsa_ues: (str) Number of NSA UEs to which the ping is sent
    :param traffic_direction: (str) Traffic direction (ul, dl or bi)
    :param traffic_duration: (str) Traffic duration in seconds
    :param first_sa_ue_id: (int) ID of the first SA UE for which data traffic is handled
    :param first_nsa_ue_id: (int) ID of the first NSA UE for which data traffic is handled
    :param dl_mbps: (int) Downlink traffic speed
    :param ul_mbps: (int) Uplink traffic speed
    :param console_info: (bool)
    """
    if num_of_sa_ues:
        start_traffic_for_multiple_ues(number_of_ues=num_of_sa_ues, traffic_direction=traffic_direction,
                                       first_ue_id=first_sa_ue_id, net_arch='sa', dl_mbps=dl_mbps,
                                       ul_mbps=ul_mbps, **kwargs)
    if num_of_nsa_ues:
        start_traffic_for_multiple_ues(number_of_ues=num_of_nsa_ues, traffic_direction=traffic_direction,
                                       first_ue_id=first_nsa_ue_id, net_arch='nsa', dl_mbps=dl_mbps,
                                       ul_mbps=ul_mbps, **kwargs)
    logger.info("Data traffic started.", also_console=console_info)
    time.sleep(int(traffic_duration))
    if num_of_sa_ues:
        stop_data_traffic_for_multiple_ues(number_of_ues=num_of_sa_ues, traffic_direction=traffic_direction,
                                           first_ue_id=first_sa_ue_id, net_arch='sa', **kwargs)
    if num_of_nsa_ues:
        stop_data_traffic_for_multiple_ues(number_of_ues=num_of_nsa_ues, traffic_direction=traffic_direction,
                                           first_ue_id=first_nsa_ue_id, net_arch='nsa', **kwargs)
    logger.info("Data traffic stopped.", also_console=console_info)


def start_traffic_for_multiple_ues(number_of_ues, traffic_direction, first_ue_id=1, net_arch='sa',
                                   ul_mbps=2, dl_mbps=50, first_trf_id=1, **kwargs):
    """
    Start data traffic for multiple UEs at the same time

    :param number_of_ues: (int or list) Number of UEs or list with UEs id's to which data traffic is started
    :param traffic_direction: (str) Traffic direction (ul, dl or bi)
    :param first_ue_id: (int) ID of the first UE for which data traffic is triggered
    :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
    :param dl_mbps: (int or list) Downlink traffic speed or list with traffic speed per UE
    :param ul_mbps: (int or list) Uplink traffic speed or list with traffic speed per UE
    :param first_trf_id: (int) ID of the traffic to start with
    """
    def __create_traffic_list(traffic):
        if type(traffic) is not list:
            return [int(traffic)] * len(number_of_ues)
        else:
            return traffic

    def __run_traffic(direction, index):
        traffic_mbps_list = dl_mbps_list if direction == 'dl' else ul_mbps_list
        traffic_instances_nr = traffic_mbps_list[index] // 175
        trf_id = first_trf_id
        traffic_value = traffic_mbps_list[index]

        while traffic_instances_nr:
            start_data_traffic_in_egate(trf_id=trf_id, ue_id=ue_id, direction=direction, mbps=175,
                                        net_arch=net_arch, **kwargs)
            traffic_value -= 175
            traffic_instances_nr -= 1
            trf_id += 1
        if traffic_value:
            start_data_traffic_in_egate(trf_id=trf_id, ue_id=ue_id, direction=direction, mbps=traffic_value,
                                        net_arch=net_arch, **kwargs)

    if not isinstance(number_of_ues, list):
        number_of_ues = int(number_of_ues)
        if first_ue_id:
            first_ue_id = int(first_ue_id)
            number_of_ues = list(range(first_ue_id, first_ue_id + number_of_ues))
        elif net_arch == 'sa':
            number_of_ues = list(range(1, number_of_ues + 1))
        elif net_arch == 'nsa':
            number_of_ues = list(range(11, 11 + number_of_ues))

    dl_mbps_list = __create_traffic_list(dl_mbps)
    ul_mbps_list = __create_traffic_list(ul_mbps)
    for index, ue_id in enumerate(number_of_ues):
        if traffic_direction in ['bi', 'ul']:
            __run_traffic('ul', index)
        if traffic_direction in ['bi', 'dl']:
            __run_traffic('dl', index)


def stop_data_traffic_for_multiple_ues(number_of_ues, traffic_direction, first_ue_id=1,
                                       net_arch='sa', dl_mbps=None, first_trf_id=1, **kwargs):
    """
    Stop data traffic for multiple UEs at the same time

    :param number_of_ues: (int) Number of UEs to which data traffic is stopped
    :param traffic_direction: (str) Traffic direction (ul, dl or bi)
    :param first_ue_id: (int) ID of the first UE for which data traffic is stopped
    :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
    :param dl_mbps: Throughput in DL
    :param first_trf_id: (int) Number of first trf_id to be stopped
    """

    if dl_mbps is not None and type(dl_mbps) is not list:
        dl_mbps = [int(dl_mbps)] * int(number_of_ues)
    for ue_id in range(first_ue_id, first_ue_id + int(number_of_ues)):
        if traffic_direction in ['bi', 'ul']:
            stop_data_traffic_in_egate(ue_id=ue_id, direction='ul', net_arch=net_arch, **kwargs)
        if traffic_direction in ['bi', 'dl']:
            if dl_mbps is None:
                stop_data_traffic_in_egate(ue_id=ue_id, direction='dl', net_arch=net_arch, **kwargs)
            else:
                tput = dl_mbps[ue_id - first_ue_id]
                trf_id = first_trf_id
                for i in range(dl_mbps[ue_id - first_ue_id] // 175):
                    stop_data_traffic_in_egate(trf_id=trf_id, ue_id=ue_id, direction='dl', net_arch=net_arch,
                                               **kwargs)
                    tput -= 175
                    trf_id += 1
                if tput:
                    stop_data_traffic_in_egate(trf_id=trf_id, ue_id=ue_id, direction='dl', net_arch=net_arch,
                                               **kwargs)


def start_data_traffic_in_egate(ue_id, direction, mbps=None, bps=None, pdu=1, qfi=1, trf_id=1, protocol="udp",
                                cl_trf_stats='on', timeout=30, net_arch='sa', bearer=2, **kwargs):
    """
    Start data traffic in egate for single UE

    :param ue_id: (int) UE id for which data traffic is started
    :param direction: (str) Traffic direction (ul, dl or bi)
    :param mbps: (int) Traffic rate in megabytes per second
    :param bps: (int) Traffic rate in bytes per second
    :param pdu: (int) PDU id
    :param qfi: (int) QoS flow id
    :param trf_id: (int) Traffic id
    :param protocol: (str) Traffic protocol
    :param timeout: (int) Operation timeout
    :param cl_trf_stats: (str) Toggle for clear L3 statistics for the traffic instance (on, off)
    :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
    :param bearer: (int) Bearer id
    **kwargs: Additional parameters for egate command
    """
    traffic_dict = dict()
    if mbps:
        traffic_dict.update({'type': 'mbps', 'rate': mbps})
    elif bps:
        traffic_dict.update({'type': 'bps', 'rate': bps})
    else:
        raise Exception('No rate given')

    command_args = ''
    dir_dict = {'dl': 'Downlink', 'ul': 'Uplink'}
    for key, value in kwargs.items():
        command_args += ' ' + str(key) + '=' + str(value)
    if net_arch == 'sa':
        cmd = 'trf_data_start ue={} dir={} {}={} pdu={} qfi={} trf_id={} protocol={} cl_trf_stats={} '.format(
            ue_id, direction, traffic_dict['type'], traffic_dict['rate'], pdu, qfi, trf_id, protocol, cl_trf_stats)
        cmd = cmd + command_args
        pass_regexp = 'Started {} Internal traffic over {} on Ue:{}'.format(dir_dict[direction],
                                                                            protocol.upper(), ue_id)
    else:
        cmd = 'trf_data_start ue={} dir={} {}={} id={} trf_id={} protocol={} cl_trf_stats={} '.format(
            ue_id, direction, traffic_dict['type'], traffic_dict['rate'], bearer, trf_id, protocol, cl_trf_stats)
        cmd = cmd + command_args
        pass_regexp = "UE {}: {} {} TRF".format(ue_id, protocol.upper(), direction.upper())
    BuiltIn().get_library_instance("ta5g_egate")._ute_wtssim_instance. \
        execute_egate_command_and_wait_for_data(cmd=cmd, pass_regexp=pass_regexp, timeout=timeout)
    BuiltIn().log('{} {} data for UE {} is started'.format(direction.upper(), protocol, ue_id), console=False)


def stop_data_traffic_in_egate(ue_id, direction, trf_id=1, pdu=1, qfi=1, net_arch='sa', bearer=2, **kwargs):
    """
    Stop data traffic in egate for single UE

    :param ue_id: (int) UE id for which data traffic is stopped
    :param direction: (str) Traffic direction (ul, dl or bi)
    :param trf_id: (int) Traffic id (If set to None all traffics will be stopped)
    :param pdu: (int) PDU id
    :param qfi: (int) QoS flow id
    :param net_arch: (str) Type of 5G architecture: 'sa' or 'nsa'
    :param bearer: (int) Bearer id
    **kwargs: Additional parameters for egate command
    """
    command_args = ''
    for key, value in kwargs.items():
        command_args += ' ' + str(key) + '=' + str(value)
    if net_arch == 'sa':
        if trf_id:
            cmd = 'trf_data_stop ue={} dir={} trf_id={} pdu={} qfi={} '.format(ue_id, direction, trf_id, pdu, qfi) + \
                command_args
        else:
            cmd = 'trf_data_stop ue={} dir={} pdu={} qfi={} '.format(ue_id, direction, pdu, qfi) + command_args
    else:
        cmd = 'trf_data_stop ue={} id={} dir={} trf_id={} '.format(ue_id, bearer, direction, trf_id) + command_args
    pass_regexp = 'UE {}: {} Traffic was stopped||Stopping .* traffic'.format(ue_id, direction.upper())
    BuiltIn().get_library_instance("ta5g_egate")._ute_wtssim_instance. \
        execute_egate_command_and_wait_for_data(cmd=cmd, pass_regexp=pass_regexp)
    BuiltIn().log('{} data for UE {} is stopped'.format(direction.upper(), str(ue_id)), console=False)


def ue_detach(ue_id):
    """
    Executes egate command ue_detach
    :param ue_id:
    """
    run_egate_cmd(cmd='ue_detach id={}'.format(ue_id))


def ue_deregister(ue_id, ue_deregister_type='switch_off'):
    """
    Executes egate command ue_deregister
    :param ue_id: str
    :param ue_deregister_type: str
    """
    run_egate_cmd(cmd='ue_deregister id={} ue_deregister_type={}'.format(ue_id, ue_deregister_type))


def ue_pdu_session_release(ue_id, pdu_id='1'):
    """
    Executes egate command ue_deregister
    :param ue_id: str
    :param pdu_id: str
    """
    run_egate_cmd(cmd='ue_pdu_session_release ue={} pdu={}'.format(ue_id, pdu_id))


def trigger_inter_gnb_handover_with_cfra(ue_id=1, phycell_id=50, meas_id=1, pass_regexp=None):
    """
    :param ue_id: (str, int)
    :param meas_id: (str, int)
    :param phycell_id: (str, int)
    :param pass_regexp: (str)
    """
    pass_regexp = pass_regexp if pass_regexp is not None else 'UE{}: PATH_SWITCH_REQUEST_ACK Received'.format(ue_id)
    message = 'ue_measurement_send_nr id={} meas_id={} event=A3 srsrp_nr=20 srsrq_nr=40 phycell_id={} ' \
              'nrsrp_nr=100 nrsrq_nr=50 rs_type=ssb index=0 nrs_result=100:50:59'.format(ue_id, meas_id, phycell_id)
    run_egate_cmd(message, pass_regexp=pass_regexp, timeout=60)


def complete_inter_gnb_handover_history(ue_id=1, real_gnb_id=2, sim_gnb_id=3, plmn='311:489', real_cell=1, sim_cell=1,
                                        list_id=1):
    """
    Fill UE inter gNB handover history

    :param ue_id: (str, int)              UE whose history is to be updated
    :param real_gnb_id: (str, int)        ID of the real gNB in UE history
    :param sim_gnb_id: (str, int)         ID of the simulated gNB in UE history
    :param plmn: (str)                    PLMN of the UE
    :param real_cell (str, int)           ID of the real cell in UE history
    :param sim_cell (str, int)            ID of the simulated cell in UE history
    :param list_id (str, int)             ID of the UE history list
    """
    ue_id = int(ue_id)
    run_egate_cmd(cmd='ue_history_information_list_add_ngran id={} gnb_id={} cell_type=large '
                      'nrcgi={}|0x0{} time_ue_stayed_in_cell=97'.format(list_id, real_gnb_id, plmn, real_cell))
    run_egate_cmd(cmd='ue_history_information_list_add_ngran id={} gnb_id={} cell_type=large '
                      'nrcgi={}|0x{} time_ue_stayed_in_cell=98'.format(list_id, sim_gnb_id, plmn, sim_cell))
    run_egate_cmd(cmd='ue_history_information_list_add_ngran id={} gnb_id={} cell_type=large '
                      'nrcgi={}|0x0{} time_ue_stayed_in_cell=99'.format(list_id, real_gnb_id, plmn, real_cell))
    run_egate_cmd(cmd='ue_history_information_list id={} action=commit'.format(list_id))
    run_egate_cmd(cmd='ue_enb_param id={} ue_history_list={}'.format(ue_id, list_id))


def add_simulated_gnb(gscn, sim_gnb_id=3, sim_gnb_ng_ip='10.0.1.50', sim_gnb_xn_ip='10.0.1.51',
                      sim_gnb_hex_id='0x7d4:22', sim_gnb_pci='16:1', cfg_filepath='/opt/wts/latest/basic_setup.cfg',
                      target_path='/opt/wts/latest/new_basic_setup.cfg', real_cell_id='1'):
    """
    Adds a simulated gNB to WTS config

    :param gscn: (str) gscn of simulated cell
    :param sim_gnb_id: (str) Simulated gnb decimal id
    :param sim_gnb_ng_ip: (str) Simulated gnb NG IP (should be added to VM's eth3 interface)
    :param sim_gnb_xn_ip: (str) Simulated gnb XN IP (should be added to VM's eth3 interface)
    :param sim_gnb_hex_id: (str) Simulated gnb hexadecimal id e.g. '0x7d4:22'
    :param sim_gnb_pci: (str) Simulated gnb's cell physical id
    :param cfg_filepath: (str) path to WTS config to modify, config provided with VM is default
    :param target_path: (str) path to output file
    :param real_cell_id (str) real cell to copy configuration from
    :return target_path
    """
    wts_instance = wts()
    wts_instance.load_wts_cfg(cfg_filepath)

    parameters = get_parameters_for_wts_configuration(real_cell_id)
    if not wts_instance.get_parameter('set', 'GNB_XN_ADDR'):
        ip = wts_instance.get_parameter('set', 'GNB_NG_ADDR')
        wts_instance.insert(['set GNB_XN_ADDR="{}"'.format(ip)],
                            'after', 'set GNB_NG_ADDR="{}"'.format(parameters['ngc_ip']))
    wts_instance.modify(command='set_gnb id=2', modification='xn=$GNB_XN_ADDR')
    wts_instance.insert(
        [
            'set GNB2_NG_ADDR="{}"'.format(sim_gnb_ng_ip),
            'set GNB2_XN_ADDR="{}"'.format(sim_gnb_xn_ip),
            'set GNB2_HEX="{}"'.format(sim_gnb_hex_id)
        ],
        'after', 'set UPF_ADDR="1.2.4.1"'
    )
    wts_instance.insert(
        [
            'set_gnb id={} type=simulated plmn={} gnb_id=$GNB2_HEX ng=$GNB2_NG_ADDR x2_peers=none xn=$GNB2_XN_ADDR '
            'nssai=0x1:0xd143a5 daemon=$SERVER_IP:$DAEMON_PORT amf=1'.format(sim_gnb_id, parameters['plmn']),
            'gnb_param id={} xn_listening_socket=1 send_xn_setup=off'.format(sim_gnb_id),
            'set_cell id=1 gnb={} tac=0 nrci=0x01 pci={} tdd_cell={} proxy=$SERVER_IP:$DAEMON_PORT nr_arfcn={} '
            'gscn={}'.format(sim_gnb_id, sim_gnb_pci, parameters['cell_tech'], parameters['nrarfcn'], gscn)
        ],
        'after', 'set_cell id=1 gnb=2')
    wts_instance.save_wts_cfg(target_path)
    configure_ips_on_vm_interfaces(cfg_filepath=target_path, addresses=['GNB2_NG_ADDR', 'GNB2_XN_ADDR'])
    return target_path


def start_collecting_ueapp_sosreport(ueapp_script_path='/opt/wts/latest', ue_app_script_name='startTest.sh',
                                     stdout_file_path=None):
    """
    Start collecting of UEAPP Sosreport using startTest.sh script. This function works on every HW with APoABIO.
    The only exception is ASOE HW, gNB BIP logs will not be collected on ASOE.

    :param ueapp_script_path:  (str) Path to location of UEAPP sosreport start script
    :param ue_app_script_name: (str) Name of the UEAPP sosreport start script
    :param stdout_file_path:   (str) Path to file. If provided output log will be saved in a file
    """
    stdout = open(stdout_file_path, 'w') if stdout_file_path else open(os.devnull, 'w')
    logger_console('Start UEAPP Sosreport collection')
    try:
        sp.call('{}/{}'.format(ueapp_script_path, ue_app_script_name), stdout=stdout, stderr=sp.STDOUT)
    except sp.CalledProcessError:
        logger_console('Starting UEAPP Sosreport collection failed')
    except OSError:
        logger_console('UEAPP Sosreport script not found')


def stop_collecting_ueapp_sosreport(destination_path_for_sosreport, ueapp_script_path='/opt/wts/latest',
                                    ue_app_script_name='stopTest.sh', ue_app_options='', stdout_file_path=None):
    """
    Stop collection of UEAPP Sosreport and save it to desired location.

    :param destination_path_for_sosreport: (str) Desired location for Sosreport to be saved
    :param ueapp_script_path:              (str) Path to location of UEAPP sosreport stop script
    :param ue_app_script_name:             (str) Name of the UEAPP sosreport stop script
    :param ue_app_options:                 (str) options for sosreport. E.g.: '-o' for stop without collecting logs
    :param stdout_file_path:               (str) Path to file. If provided output log will be saved in a file
    """

    smod = get_capability_unit_name()
    if smod == 'ASIL' or smod == 'ASOE':
        ueapp_script_path = '/opt/wts/latest/sosReport_ASIL'
        ue_app_script_name = 'stopTest_ASIL.sh'
        os.chmod('/opt/wts/latest/sosReport_ASIL/stopTest_ASIL.sh', 0o777)

    stdout = open(stdout_file_path, 'w') if stdout_file_path else open(os.devnull, 'w')
    logger_console('Stop UEAPP Sosreport collection')
    try:
        sp.call(['{}/{}'.format(ueapp_script_path, ue_app_script_name), ue_app_options],
                stdout=stdout, stderr=sp.STDOUT, cwd=destination_path_for_sosreport)
    except sp.CalledProcessError:
        logger_console('Stopping UEAPP Sosreport collection failed')
    except OSError as err:
        logger_console('UEAPP Sosreport script not found')
        logger_console(err)


def activate_sinr_testmode(number_of_ues, sinr_target_srs=300, sinr_target_pusch=200, sinr_target_pucch=-300):
    """
    Activate SINR testmode to reduce the noise level of PUCCH at the AirPhone side. This function is used as a
    workaround to avoid incrementing F3 DTXs until FPB-803438 and FPB-803439 are complete.

    :param number_of_ues: (int) Number of UEs to which SINR testmode is applicable
    :sinr_target_srs: (int) SRS transmit power value
    :sinr_target_pusch: (int) SINR value for PUSCH
    :sinr_target_pucch: (int) SINR value for PUCCH
    """
    run_egate_cmd(cmd='ul_sinr_testmode_nr profile_id=1 sinr_target_srs={} sinr_target_pusch={} sinr_target_pucch={}'
                  .format(sinr_target_srs, sinr_target_pusch, sinr_target_pucch))
    for ue_id in range(1, int(number_of_ues) + 1):
        run_egate_cmd(cmd='ue_testmode_set_nr id={} testmode=ul_sinr profile_id=1 action=activate'.format(ue_id))


def perform_ue_context_release(ue_id=1):
    """
    :param ue_id: (str, int)
    """

    run_egate_cmd(cmd='ue_ng_ctx_release id={} cause=NAS_normal_release'.format(ue_id))


def get_ue_rnti_from_wts(ue_id):
    egate = BuiltIn().get_library_instance('ta5g_egate')
    output = egate._ute_wtssim_instance.execute_egate_command_and_wait_for_data(
        cmd='ue_disp id={}'.format(str(ue_id)), return_output=True, pass_regexp=r'=*', timeout=30
    )
    for line in output.split('\n'):
        if 'RNTI' in line:
            return line.split()[-1]
    raise ValueError('RNTI not found for UE{}! Please check if UE is attached.'.format(ue_id))


def start_rtp_traffic(ue_id=1, pdu_id=1, qfi=3, traffic_direction='dl', trf_id=1, rtp_codec='amr_wb_23_85'):
    """
    Starts RTP traffic for a specified UE.

    Args:
        ue_id (int): The UE ID. Default is 1.
        pdu_id (int): The PDU ID. Default is 1.
        qfi (int): The QFI (QoS Flow Identifier). Default is 3.
        traffic_direction (str): The traffic direction. 'dl' for downlink, 'ul' for uplink. Default is 'dl'.
        trf_id (int): The traffic ID. Default is 1.
        rtp_codec (str): The RTP codec. Default is 'amr_wb_23_85'.
    """
    traffic_direction_for_regex = 'Downlink' if traffic_direction == 'dl' else 'Uplink'
    pass_regexp = fr'Started {traffic_direction_for_regex} Internal traffic Receiver.*'
    run_egate_cmd(
        cmd=f'trf_data_start ue={str(ue_id)} pdu={str(pdu_id)} qfi={str(qfi)} dir={traffic_direction} '
            f'trf_id={str(trf_id)} rtp_codec={rtp_codec}',
        pass_regexp=pass_regexp)


def calculate_ue_sum_throughput(ue_id, cells, tput_type='Average', traffic_type='pdsch'):
    """
    Calculate sum of throughput from all cells for CA UE.
    :param ue_id: (int) ID of UE
    :param cells: (str) Range of cell IDs
    :param tput_type: (str) Column from output of ue_stats_nr command that should be used to calculate throughput.
                         Possible values: 'Current', 'Minimum', 'Maximum' or 'Average'
    :param traffic_type: (str) Traffic type
    """

    cmd = f'ue_stats_nr id={ue_id} scell={cells} type={traffic_type}'
    stats = run_egate_cmd_and_wait_for_data(cmd, pass_regexp=f'NR {traffic_type.upper()}')
    logger_console(stats)
    ue_stats = _parse_ue_stats(stats)
    tput_values = [cell[tput_type] for cell in ue_stats]
    for index, value in enumerate(tput_values):
        if 'Mbps' in value:
            tput_values[index] = float(value.split()[0])
        else:
            tput_values[index] = float(value.split()[0]) * 0.000125
    logger_console_info(f'{tput_type} {traffic_type} throughput for UE {ue_id}: {sum(tput_values)} Mbps')
    return sum(tput_values)
