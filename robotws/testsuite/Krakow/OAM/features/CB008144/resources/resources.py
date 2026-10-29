import os
import re

from moler.device import DeviceFactory
from moler.exceptions import MolerException
from moler.util.moler_test import MolerTest
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.procedures.resources.python.admin_info_model.admin_info_model import get_bbmods_distnames
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, PmCounterOutputGetter
from taf.rfrl.bts.parsers.snapshot_analyzer import extract_from_snapshot_files_with_regex

admin_connection = admin()
tl = BuiltIn().get_variable_value('${tl}')
oam_ip = tl.gnbs[0].dus[0].oam_ip.v4.split('/')[0]
counter_getter = PmCounterOutputGetter()
gnb_pm_counter = GnbPmCounter()

# /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
_re_bbmod_runtime_id = re.compile(r'BBMOD_R-(?P<ID>\d+)')

current_release = str(BuiltIn().get_variable_value('${ENB_BRANCH}'))
tx_msg = "AvgTxPowerPerPath" if "24R2" in current_release else "AvgTxPower"


def get_bbmod_runtime_id(bbmod_id):
    """
    Get runtime id of BBMOD.

    :param bbmod_id: BBMOD configuration id
    :return: dict, values of counters
    """
    admin_connection.connect_to(bts_host=oam_ip, name="admin")
    try:
        bbmods_info = get_bbmods_distnames(connection="admin")
    finally:
        admin_connection.teardown(connection="admin")
    m = _re_bbmod_runtime_id.search(bbmods_info[int(bbmod_id)]["runtime"])
    return m.group("ID")


@MolerTest.raise_background_exceptions()
def get_pm_counters(counter_dict, counter_key=-1, cell_type='nr'):
    """
    Get values of pm counters.

    :param counter_dict: counters dict, e.g. "NRCELL-18001": {"NCAV": ['M55601C00003','M55601C00004','M55601C00005']}
    :param counter_key: counter key, -1 is first
    :param cell_type: cell type: nr or lte
    :return: dict, values of counters
    """
    cell_types = ['nr', 'lte']
    if cell_type not in cell_types:
        MolerTest.error("Wrong cell type: {}, correct types: {}".format(cell_type, cell_types), raise_exception=True)
        return dict()
    admin_connection.connect_to(bts_host=oam_ip)
    try:
        counter_values = dict()
        for cell in counter_dict:
            counter_values[cell] = dict()
            if cell_type == 'nr':
                counter_values = _get_nrcell_pm_counters(counter_values, cell, counter_dict, counter_key)
            elif cell_type == 'lte':
                counter_values = _get_ltecell_pm_counters(counter_values, cell, counter_dict, counter_key)
    finally:
        admin_connection.teardown()
    return counter_values


def _get_nrcell_pm_counters(counter_values, nrcell, counter_dict, counter_key):
    for nrcell_object in counter_dict[nrcell]:
        counter_str = ','.join(counter_dict[nrcell][nrcell_object])
        pm_counters = gnb_pm_counter.get_counter(counter_str)
        counters = counter_getter.get_cells_counters(pm_counters)
        for counter in counter_dict[nrcell][nrcell_object]:
            key = sorted(list(counters[nrcell][nrcell_object][counter].keys()))[counter_key]
            counter_values[nrcell][counter] = counters[nrcell][nrcell_object][counter][key]
    return counter_values


def _get_ltecell_pm_counters(counter_values, ltecell, counter_dict, counter_key):
    for code in counter_values[ltecell]:
        counter_values[ltecell][code] = dict()
        for nrcell_object in counter_dict[ltecell][code]:
            counter_str = ','.join(counter_dict[ltecell][code][nrcell_object])
            counters = admin_connection.get_pm_counters(counter_str, timeout=300)
            for counter in counter_dict[ltecell][code][nrcell_object]:
                key = sorted(list(counters['BTS']['CELLS'][ltecell][code][nrcell_object][counter].keys()))[counter_key]
                counter_values[ltecell][counter] = counters['BTS']['CELLS'][ltecell][nrcell_object][counter][key]
    return counter_values


def verify_pm_counters_incremented(counter_dict, cell_type='nr'):
    """
    Verify pm counters incremented.

    :param counter_dict: dict with counter values
    :param cell_type: cell type: nr or lte
    :return: None
    """
    counters = get_pm_counters(counter_dict, cell_type=cell_type)
    error_list = list()
    for nrcell in counters:
        for counter in counters[nrcell]:
            if counters[nrcell][counter] == 0:
                error_list.append("Counter {}/{} is not incremented".format(nrcell, counter))
    if error_list:
        MolerTest.info("Unexpected counter values", dump=error_list)
        raise CounterException


def verify_pm_counters_are_zero(counter_dict, cell_type='nr'):
    """
    Verify pm counters are zero.

    :param counter_dict: dict with counter values
    :param cell_type: cell type: nr or lte
    :return: None
    """
    counters = get_pm_counters(counter_dict, cell_type=cell_type)
    error_list = list()
    for nrcell in counters:
        for counter in counters[nrcell]:
            if counters[nrcell][counter] != 0:
                error_list.append("Counter {}/{} value is not 0. Current value: {}"
                                  .format(nrcell, counter, counters[nrcell][counter]))
    if error_list:
        MolerTest.info("Unexpected counter values", dump=error_list)
        raise CounterException


def verify_one_of_pm_counters_incremented(counter_dict):
    """
    Verify pm counter incremented.

    :param counter_dict: dict with counter values
    :return: None
    """
    counters = get_pm_counters(counter_dict)
    for nrcell in counters:
        for counter in counters[nrcell]:
            if counters[nrcell][counter] == 1:
                return
    MolerTest.info("Expected one incremented counter", dump=counters)
    raise CounterException


def verify_pm_counters_incremented_over_two_periods(counter_dict):
    """
    Verify pm counter incremented over two periods.

    :param counter_dict: dict with counter values
    :return: None
    """
    counters = get_pm_counters(counter_dict)
    previous_counters = get_pm_counters(counter_dict, -2)
    error_list = list()
    for nrcell in counters:
        for counter in counters[nrcell]:
            if counters[nrcell][counter] == 0 and previous_counters[nrcell][counter] == 0:
                error_list.append("Counter {}/{} is not incremented".format(nrcell, counter))
    if error_list:
        MolerTest.info("Unexpected counter values", dump=error_list)
        raise CounterException


def verify_one_of_pm_counters_incremented_over_two_periods(counter_dict):
    """
    Verify pm counter incremented over two periods.

    :param counter_dict: dict with counter values
    :return: None
    """
    counters = get_pm_counters(counter_dict)
    for nrcell in counters:
        for counter in counters[nrcell]:
            if counters[nrcell][counter] == 1:
                return
    previous_counters = dict()
    try:
        previous_counters = get_pm_counters(counter_dict, -2)
        for nrcell in previous_counters:
            for counter in previous_counters[nrcell]:
                if previous_counters[nrcell][counter] == 1:
                    return
    except KeyError:
        MolerTest.info("Only one counter period available")
    MolerTest.info("Expected one incremented counter", dump=[counters, previous_counters])
    raise CounterException


def verify_pm_counters_not_incremented(counter_dict):
    """
    Verify pm counters not incremented.

    :param counter_dict: dict with counter values
    :return: None
    """
    counters = get_pm_counters(counter_dict)
    error_list = list()
    for nrcell in counters:
        for counter in counters[nrcell]:
            if counters[nrcell][counter] != 0:
                error_list.append("Counter {}/{} not incremented".format(nrcell, counter))
    if error_list:
        MolerTest.info("Unexpected counter values", dump=error_list)
        raise CounterException


def verify_object_in_alarm_list(fault_name, objects, alarms_list, raise_exception=True):
    error_list = objects.copy()
    builtin = BuiltIn()
    for object_name in objects:
        for alarm in alarms_list:
            if alarm["faultName"] == fault_name and object_name in alarm["configObjectName"]:
                error_list.remove(object_name)
                break
    if error_list and raise_exception:
        MolerTest.info("Alarm {} is not active on:".format(fault_name), dump=error_list)
        raise AlarmException


def verify_object_not_in_alarm_list(fault_name, objects, alarms_list):
    error_list = list()
    for object_name in objects:
        for alarm in alarms_list:
            if alarm["faultName"] == fault_name and object_name in alarm["configObjectName"]:
                error_list.append(object_name)
                break
    if error_list:
        MolerTest.info("Alarm {} is active on:".format(fault_name), dump=error_list)
        raise AlarmException


def verify_alarm_is_active_on_configuration_objects(fault_name, objects, raise_exception=True):
    admin_connection.connect_to(bts_host=oam_ip)
    try:
        active_alarms_list = admin_connection.get_active_alarms()
    finally:
        admin_connection.teardown()
    verify_object_in_alarm_list(fault_name, objects, active_alarms_list, raise_exception=raise_exception)


def verify_alarm_is_not_active_on_configuration_objects(fault_name, objects):
    admin_connection.connect_to(bts_host=oam_ip)
    try:
        active_alarms_list = admin_connection.get_active_alarms()
    finally:
        admin_connection.teardown()
    verify_object_not_in_alarm_list(fault_name, objects, active_alarms_list)


def wait_until_alarm_is_active_on_configuration_objects(fault_name, objects, interval=15, iterations=10):
    builtin = BuiltIn()
    for i in range(iterations):
        try:
            verify_alarm_is_active_on_configuration_objects(fault_name, objects, raise_exception=True)
            return
        except AlarmException:
            MolerTest.sleep(interval)
            continue
    MolerTest.info("Fault {} is not active on all of objects: {}".format(fault_name, objects))
    raise AlarmException


def verify_alarm_is_in_alarm_history(fault_name, objects):
    admin_connection.connect_to(bts_host=oam_ip)
    try:
        historic_alarms_list = admin_connection.get_historic_alarms()
    finally:
        admin_connection.teardown()
    verify_object_in_alarm_list(fault_name, objects, historic_alarms_list)


def verify_alarm_is_not_in_alarm_history(fault_name, objects):
    admin_connection.connect_to(bts_host=oam_ip)
    try:
        historic_alarms_list = admin_connection.get_active_alarms()
    finally:
        admin_connection.teardown()
    verify_object_not_in_alarm_list(fault_name, objects, historic_alarms_list)


def check_time_for_counter_change(start_time, elapsed_time, interval=15):
    """
    Check time for counter change.

    :param interval: measurement interval
    :param elapsed_time: float, elapsed time from KW affecting counter e.g. 5.0
    :param start_time: string, start time of  from KW affecting counter min:sec e.g. "05.00"
    :return: True if pm interval time has not elapsed, else False
    """
    if elapsed_time < 0:
        return False
    start_time = start_time[:start_time.rfind(".")].split(':')
    start_time = float(start_time[0]) + float(start_time[1]) / 60
    elapsed_time = elapsed_time / 60
    if start_time % interval >= interval - elapsed_time:
        return False
    return True


def get_sw_release():
    """
    Get sw release.

    :return: None
    """
    admin_connection.connect_to(bts_host=oam_ip)
    try:
        sw_version = admin_connection.get_sw_version()
    finally:
        admin_connection.teardown()
    sw_version = sw_version.split("_")[0]
    return sw_version


@load_moler_configuration_from_tl()
def unpack_syslog_file(syslog_dir_path, gnb_id=0, du_id=0):
    syslog_tgz_name = "syslog_files.tgz"
    syslog_tgz_path = "{}{}".format(syslog_dir_path, syslog_tgz_name)
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format("GNB", gnb_id, du_id), initial_state="UNIX_LOCAL")
    vm.get_cmd(cmd_name="tar", cmd_params={"file": syslog_tgz_path,
                                           "options": "-C {} -xvzf".format(syslog_dir_path)})()
    vm.goto_state("FCT")


def check_syslog(gnb_id=0, du_id=0):
    rest_alias = device_aliases.rest_bts_du.format("GNB", gnb_id, du_id)
    syslog_dir = "btslog_{}_{}_{}".format(rest_alias, tl.gnbs[gnb_id].instance_id, tl.gnbs[gnb_id].global_bts_id)
    syslog_dir_path = "{}/{}/".format(BuiltIn().get_variable_value("${LOG_PATH}"), syslog_dir)
    unpack_syslog_file(syslog_dir_path)
    avg_tx_power_per_path_flg, etp_value_flg, txpower_error_list, etp_value_error_list = \
        _check_avg_tx_power_per_path_and_etp_value_in_syslog(syslog_dir_path)
    error_list = _prepare_error_list(avg_tx_power_per_path_flg, etp_value_flg, txpower_error_list,
                                     etp_value_error_list)
    if error_list:
        MolerTest.info("Errors detected in syslog:", dump=error_list)
        raise SyslogException


def _prepare_error_list(avg_tx_power_per_path_flg, etp_value_flg, txpower_error_list, etp_value_error_list):
    error_list = list()
    if not avg_tx_power_per_path_flg:
        error_list.append("{} not in syslog".format(tx_msg))
    # if not etp_value_flg:
    #     error_list.append("etpValue not in syslog")
    if txpower_error_list:
        error_list.append({"Unexpected {} in lines: (expected: < 0)".format(tx_msg): txpower_error_list})
    # if etp_value_error_list:
    #     error_list.append({"Unexpected etpValue in lines: (expected: < 1)": etp_value_error_list})
    return error_list


def _check_avg_tx_power_per_path_and_etp_value_in_syslog(syslog_dir_path, gnb_id=0, du_id=0):
    avg_tx_power_per_path_flg = False
    etp_value_flg = False
    txpower_error_list = list()
    etp_value_error_list = list()
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format("GNB", gnb_id, du_id), initial_state="UNIX_LOCAL")
    for filename in os.listdir(syslog_dir_path):
        if "SYSLOG" in filename:
            grep_cmd = vm.get_cmd(cmd_name="grep", cmd_params={"options": "-i -e etpValue -e {} {}/{}"
                                  .format(tx_msg, syslog_dir_path, filename)})
            syslog_lines = grep_cmd()["LINES"]
            for line in syslog_lines:
                avg_tx_power = _find_avg_tx_power_in_syslog(line)
                if avg_tx_power:
                    avg_tx_power_per_path_flg = True
                    if avg_tx_power >= 0:
                        txpower_error_list.append(line)
                etp_value = _find_etp_value_in_syslog(line)
                if etp_value:
                    etp_value_flg = True
                    if etp_value >= 1:
                        etp_value_error_list.append(line)
    vm.goto_state("FCT")
    return avg_tx_power_per_path_flg, etp_value_flg, txpower_error_list, etp_value_error_list


_etp_value_regex = re.compile(r'etpValue: (?P<ETP>-?[\d\.]+)')


def _find_etp_value_in_syslog(line):
    m = re.search(_etp_value_regex, line)
    if m:
        etp_value = m.group("ETP")
        MolerTest.info("etpValue:", dump=etp_value)
        return float(etp_value)
    return None


_avg_tx_power_regex = re.compile(r'"(A|a)vgTxPower(PerPath)?":(?P<POWER>-?\d+)')


def _find_avg_tx_power_in_syslog(line):
    m = re.search(_avg_tx_power_regex, line)
    if m:
        avg_tx_power = m.group("POWER")
        MolerTest.info("{}:".format(tx_msg), dump=avg_tx_power)
        return float(avg_tx_power)
    return None


def verify_etpValue_in_snapshot(snapshot_path):
    extract_dir = f'{BuiltIn().get_variable_value("${OUTPUTDIR}")}/snap'
    archives = extract_from_snapshot_files_with_regex(snapshot_path=snapshot_path, pattern=r"\.bro\.xz",
                                                      extract_dir=extract_dir, extract_dst=True)

    found_etp = False
    found_cnt = False
    found_msr = False
    err_msg = ""
    re_etp = re.compile(
        r"MRBTS-\d+/RAT-\d+/NRTS-\d+/NRBTS_L-\d+/NRCELL_L-\d+ is sleeping, etpValue:\s*(?P<ETP_VALUE>\d+\.\d+|\d+)")
    re_cnt = re.compile(r"Received counters:\s+NRCELL-\d+")
    re_msr = re.compile(r"Measurements update for CELL_M-\d+")
    for archive in archives:
        file_name = archive[:-3]
        path = os.path.join(extract_dir, file_name)
        with open(path, "rb") as file:
            bytes = file.read()
            content = bytes.decode(errors="replace")
            matched = re.search(re_etp, content)
            if matched:
                found_etp = True
                etp_value = float(matched.group('ETP_VALUE'))
                if etp_value >= 1.0:
                    err_msg += f"\netpValue is {etp_value}. Expected < 1.0. Path to file: {path}"
            if re.search(re_cnt, content):
                found_cnt = True
            if re.search(re_msr, content):
                found_msr = True
    if not found_etp:
        err_msg += "\nNot found 'etpValue' iny any bro file."
    if not found_cnt:
        err_msg += "\nNot found 'Received counters' in any bro files."
    if not found_msr:
        err_msg += "\nNot found 'Measurements update' in any bro files."
    if err_msg:
        raise Exception(err_msg)


def go_to_state_fct(gnb_id=0, du_id=0):
    vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format("GNB", gnb_id, du_id))
    vm.goto_state("FCT")


class CounterException(Exception):
    pass


class AlarmException(Exception):
    pass


class SyslogException(Exception):
    pass
