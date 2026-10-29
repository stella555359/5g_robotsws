from robot.api import logger
from taf.sw.scout import scout
from taf.sbts.oam.coam.admin import admin
from taf.sw.scout.exceptions import ScoutApiException
from taf.rfrl.ue.logs.tput_logs_collecting import collect_logs_during_data_transfer, download_logs_from_gnb
from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
from typing import Union
from time import sleep as py_sleep
from robot.libraries.BuiltIn import BuiltIn
import functools
import socket
import re
import os
import json
import math
import paramiko

ssh = paramiko.SSHClient()


def check_if_no_unexpected_alarms(alarms_list):
    formatted_logs = ', '.join(['{}: {}'.format(alarm['alarmDetail'], alarm['severity']) for alarm in alarms_list])
    logger.console('Found alarms: {}'.format(formatted_logs))
    assert all([alarm['severity'] == 'Minor' or alarm['severity'] == 'Warning' for alarm in alarms_list]) is True, \
        'Alarm of severity major/critical has been found'


def configure_gnbmirroring_script(file_path, time, size, num_of_files, filtering, filter, bb_slot_1, bb_slot_2,
                                  bb_slot_3, bb_slot_4, bb_slot_5, bb_slot_6, bb_slot_7):
    """
    Used in KW Start L1L2 Logs Gathering
    """
    file = open(str(file_path), 'r')
    file_res = open(str(file_path[:-21] + 'tmp.sh'), 'w')
    r_1 = r'(^CAPTURING_TIME_SECONDS=)(\d*)(\s)'
    r_2 = r'(^FILE_SIZE_MBYTES=)(\d*)(\s)'
    r_3 = r'(^NUMBER_OF_FILES=)(\d*)(\s)'
    r_4 = r"(^FILTERING=)'([a-z]{2,3})'"
    r_5 = r"(^FILTER=)'(.{150})'"
    r_6 = r"(^BB_SLOT_1=)'([a-z]{4,5})'"
    r_7 = r"(^BB_SLOT_2=)'([a-z]{4,5})'"
    r_8 = r"(^BB_SLOT_3=)'([a-z]{4,5})'"
    r_9 = r"(^BB_SLOT_4=)'([a-z]{4,5})'"
    r_10 = r"(^BB_SLOT_5=)'([a-z]{4,5})'"
    r_11 = r"(^BB_SLOT_6=)'([a-z]{4,5})'"
    r_12 = r"(^BB_SLOT_7=)'([a-z]{4,5})'"
    for line in file:
        if re.match(r_1, line):
            t = re.match(r_1, line)
            temp = line.replace(t.group(2), str(time))
            file_res.write(temp)
            continue
        if re.match(r_2, line):
            t = re.match(r_2, line)
            temp = line.replace(t.group(2), str(size))
            file_res.write(temp)
            continue
        if re.match(r_3, line):
            t = re.match(r_3, line)
            temp = line.replace(t.group(2), str(num_of_files))
            file_res.write(temp)
            continue
        if re.match(r_4, line):
            t = re.match(r_4, line)
            temp = line.replace(t.group(2), str(filtering))
            file_res.write(temp)
            continue
        if re.match(r_5, line):
            t = re.match(r_5, line)
            temp = line.replace(t.group(2), str(filter))
            file_res.write(temp)
            continue
        if re.match(r_6, line):
            t = re.match(r_6, line)
            temp = line.replace(t.group(2), str(bb_slot_1))
            file_res.write(temp)
            continue
        if re.match(r_7, line):
            t = re.match(r_7, line)
            temp = line.replace(t.group(2), str(bb_slot_2))
            file_res.write(temp)
            continue
        if re.match(r_8, line):
            t = re.match(r_8, line)
            temp = line.replace(t.group(2), str(bb_slot_3))
            file_res.write(temp)
            continue
        if re.match(r_9, line):
            t = re.match(r_9, line)
            temp = line.replace(t.group(2), str(bb_slot_4))
            file_res.write(temp)
            continue
        if re.match(r_10, line):
            t = re.match(r_10, line)
            temp = line.replace(t.group(2), str(bb_slot_5))
            file_res.write(temp)
            continue
        if re.match(r_11, line):
            t = re.match(r_11, line)
            temp = line.replace(t.group(2), str(bb_slot_6))
            file_res.write(temp)
            continue
        if re.match(r_12, line):
            t = re.match(r_12, line)
            temp = line.replace(t.group(2), str(bb_slot_7))
            file_res.write(temp)
            continue
        file_res.write(line)
    os.remove(file_path)
    os.rename(str(file_path[:-21] + 'tmp.sh'), file_path)


def get_dir_from_path(path):
    path = re.findall(r'^[\w*/]*/', path)[0]
    return path


def get_file_from_path(path):
    filename = re.findall(r'\w*[.]\w*$', path)[0]
    return filename


def get_file_without_ext(path):
    filename = get_file_from_path(path)
    f = re.findall(r'^\w*', filename)[0]
    return f


# Keywords returns path to SCF stored in 'custom-config/RRM_WRO7' with given parameters for testline
# SCF should be stored in 'custom-config/RRM_WRO7/[testline]'
# SCF name should be like this: [testline]_[cofnig_type]_[architecture]_[cipri]_[branch]
# example SCF path: 'custom-config/RRM_WRO7/7_16_UTE5GCLOUDT151/7_16_UTE5GCLOUDT151_FDD_NSA_CPRI_21A.xml'
# arguments:  config_type = TFF/FDD, architecture = NSA/SA, cpri = CPRI/ECIPRI, branch = 20B/21A/SBTS21B/SBTS00
# example of use: get_test_line_scf_path  FDD  NSA  CPRI  21A


def get_test_line_scf_path(config_type=None):
    tl_name = socket.gethostname().replace('-', '_')
    scf_path = ''
    if config_type:
        scf_path = 'custom-config/RRM_WRO7/{}/{}_{}.xml'. \
            format(tl_name, tl_name, config_type)
    else:
        scf_path = 'custom-config/RRM_WRO7/{}/{}.xml'.format(tl_name, tl_name)
    return scf_path


def get_interface_name():
    api = admin()
    conn = api.connect_to()

    sysmod_info = conn.get_fsm_info()
    sysmod_name = sysmod_info[0]['productName']

    if not sysmod_name:
        assert False, 'There is no sysmod !'

    names = {
        'ASIK': 'fp0',
        'ASIB': 'br1',
        'ASIL': 'br0'
    }

    sysmod_version = sysmod_name.replace(' AirScale Common', '')
    api.teardown()
    return names[sysmod_version]


def check_fault_id(alarms_list, fault_id):
    alarms = [alarm for alarm in alarms_list if alarm['faultId'] == int(fault_id)]
    if alarms:
        return True
    return False


def verify_cells_statuses(cells_info):
    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'availabilityStatus': 'Online',
                           'administrativeState': 'Unlocked', 'usageState': 'Active',
                           'barringStatus': 'unbarred'}
    for cell in cells_info:
        if cell['energySavingState'] == 'energySaving':
            continue
        for key, val in cell['status'].items():
            exp_val = expected_cell_state[key]
            if not re.search(exp_val, val, flags=re.I):
                raise Exception("The cell status is not as expected. Current cell status: {} "
                                "and Expected Cell Status: {}".format(cell['status'], expected_cell_state))


def get_sw_from_ute_reservation():
    json_path = "/opt/ute/reservation.json"
    with open(json_path, 'r') as file_h:
        data = json.load(file_h)
        return data["enb_build"]


# For Max tput PowerBi reporting
def start_max_tput_kpi_logs():
    collect_logs_during_data_transfer()


def stop_max_tput_kpi_logs():
    download_logs_from_gnb()


def check_tput_drops(logs, direction):
    values = list(logs)
    percentage_factor = 0.10
    percentage_up_deviation = 1.25
    percentage_down_deviation = 0.75
    to_cut = int(math.ceil(len(values) * percentage_factor))
    max_repetition = 5
    drops = []
    avg = sum(values[to_cut + 1:-to_cut]) / len(values[to_cut + 1:-to_cut])
    print("AVG: ", avg)
    for value_dt in values[to_cut + 1:-to_cut]:
        if value_dt < (avg * percentage_down_deviation) or value_dt > (avg * percentage_up_deviation):
            drops.append(value_dt)
            if len(drops) >= max_repetition:
                raise Exception("Drops detected", drops)
    print(drops)


# webem connection decorator
def webem_connection(callback):
    @functools.wraps(callback)
    def inner(*args, **kwargs):
        api = admin()
        try:
            rel_conn = admin().connect_to()
            release = rel_conn.get_sw_release_name()
            api.teardown(connection=rel_conn)
            conn = api.connect_to(release=release)
            return callback(*args, api_conn=conn, **kwargs)
        finally:
            api.teardown(connection=conn)

    return inner


@webem_connection
def check_fhs_exist(api_conn=None):
    fhx_reg = "MRBTS-[0-9]*/EQM_R-[0-9]/APEQM_R-[0-9]/FHS_R-[0-9]"
    ret = api_conn.get_detected_hw_info(timeout=180)
    for item in ret['cables']:
        cable_conn = item['secondEndPointId']['runtime']
        out = re.findall(fhx_reg, cable_conn)
        if out:
            return out[0]
    return None


@webem_connection
def findall_and_reset_fhs(api_conn=None):
    fhx_reg = "MRBTS-[0-9]*/EQM_R-[0-9]/APEQM_R-[0-9]/FHS_R-[0-9]"
    ret = api_conn.get_detected_hw_info(timeout=180)
    fhs_debug_dict = {}
    fhs_debug_count = 1
    for item in ret['cables']:
        cable_conn = item['secondEndPointId']['runtime']
        out = re.findall(fhx_reg, cable_conn)
        if out:
            fhs_debug_dict[fhs_debug_count] = out[0]
            fhs_debug_count += 1
            api_conn.reset_unit(dist_name=out[0], timeout=600, reset_type='Soft')
    if not fhs_debug_dict:
        raise Exception("Can't find FHS unit path!")
    print(f"Founded FHS: {fhs_debug_dict}")


@webem_connection
def get_allowed_alarms_and_check(alarm_list, api_conn=None):
    for alarm in alarm_list:
        api_conn.add_allowed_alarm(faultId=alarm)
    api_conn.assert_no_unexpected_active_alarms()


def fetch_scout_id(testline_name, execution=False):
    scout_obj = scout()

    try:
        scout_obj.setup_scout(scout_testline_name=testline_name)
        scout_id = scout_obj.request_scf(use_scout_internal_id=execution)
        return scout_id

    except ScoutApiException as scout_err:
        logger.console("Error occurred while fetching for scout ID: {}".format(scout_err))

    finally:
        scout_obj.teardown_scout_api()


def get_swconfig(filename, swconfig_dir, mplane):
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=mplane, username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    if not os.path.exists(swconfig_dir):
        os.makedirs(swconfig_dir)
    swconfig_file = "{}/{}.txt".format(swconfig_dir, filename)
    sftp.get("/ffs/run/swconfig.txt", swconfig_file)
    ssh.close()
    return swconfig_file


def add_flags_to_swconfig(swconfig_dir, mplane, flags):
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=mplane, username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    swconfig_backup_local = get_swconfig("swconfig_original", swconfig_dir, mplane)
    modified_swconfig_local = "{}/swconfig.txt".format(swconfig_dir)
    sftp.get("/ffs/run/swconfig.txt", swconfig_backup_local)
    with open(swconfig_backup_local, "r") as swconfig_bk, open(modified_swconfig_local, "w") as new_swconfig:
        for line in swconfig_bk:
            new_swconfig.write(line)
        new_swconfig.write("\n#extra flags added:{}".format(flags))
    sftp.put(modified_swconfig_local, "/ffs/run/swconfig.txt")
    ssh.close()


def restore_original_swconfig(swconfig_dir, mplane):
    swconfig_backup_local = "{}/swconfig_original.txt".format(swconfig_dir)
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=mplane, username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    sftp.put(swconfig_backup_local, "/ffs/run/swconfig.txt")
    ssh.close()


def wait_for_bts_reset(interval=5, max_retry=60):
    """Function waits for BTS reset. It was made as a sleep replacement for speed up some tests. In that case when BTS
       goes into a reset state a connection is broken - this is expected behaviour. Using default parameters funtion
       waits 5 minutes

       :param interval: delay between connection tries
       :param max_retry: number of max retires - combine it with interval param you can estimate a time to finish
       :return : returns when reset is detected"""

    for _ in range(0, max_retry):
        try:
            admin().connect_to()
            py_sleep(interval)
            admin().teardown()
        except AdminApiProcedureFailureException:
            return
    raise Exception(f"BTS didn't reset after it has reached max_retry={max_retry}")


def check_5G_amia_devices_enabled():
    status = []
    data = admin().connect_to().get_bts_info()
    status.append(data['systemModules'][0]['status']['operationalState'])
    for i in data['basebandModules']:
        status.append(i['status']['operationalState'])
    status_set = set(status)
    return status_set == {'enabled'}


@webem_connection
def check_release_is_higher_than(to_compare, api_conn=None):
    """ The function compares releases as numbers. Please provide release name in a same format as SBTS23R2.
       The function compare provided release with active one so WEBEM connection is needed.
       :param api_conn: injected by decorator to handle proper WEBEM connection
       :param to_compare: release name, for ex SBTS24R1
       :return bool: returns True if current release if higher than provided one. """

    current_release = api_conn.get_sw_release_name(timeout=60)

    current_major = int(current_release[4:6])
    current_minor = int(current_release[7:8])
    to_compare_major = int(to_compare[4:6])
    to_compare_minor = int(to_compare[7:8])

    if current_major > to_compare_major:
        return True
    if current_major == to_compare_major:
        if current_minor > to_compare_minor:
            return True
    return False


@webem_connection
def check_release_is_equal_to(to_compare, api_conn=None):
    """ The function compares releases as numbers to check if they are equal.
        Please provide release name in the same format as SBTS23R2.
        The function compares the provided release with the active one, so WEBEM connection is needed.
        :param api_conn: injected by decorator to handle proper WEBEM connection
        :param to_compare: release name, for example SBTS24R1
        :return bool: returns True if the current release is equal to the provided one. """

    current_release = api_conn.get_sw_release_name(timeout=60)

    current_major = int(current_release[4:6])
    current_minor = int(current_release[7:8])
    to_compare_major = int(to_compare[4:6])
    to_compare_minor = int(to_compare[7:8])

    return current_major == to_compare_major and current_minor == to_compare_minor


def set_uuf_customers_as_list(customer: Union[list, str]) -> list:
    """ The function is used to parse customer passed in a command line varaible. Robotframework doesn't support
        list like cmd args so it helps to set proper variable type
        :param customer:  Usually str param. Default value has to be declared in Variables section,
                          inside robot file.
        :return list: Customer as list """

    if isinstance(customer, list):
        return customer
    return [customer]


def set_uuf_custom_alarms_as_list(custom_alarms: Union[list, str]) -> list:
    """ The function takes fault id string. IDs are provided one by one with whitrespaces as separator. For ex.
    "123 123 1 233 12  ". Returned result is a list contains only numbers as elements.
    :param custom_alarms: string where alarms(fault) id are separeted by whitespaces
    :return: custom_alarms as lsit
    """
    if not isinstance(custom_alarms, list):
        return custom_alarms.split()
    return custom_alarms


@webem_connection
def get_sw_name(api_conn=None):
    """ The function gets and returns sw name installed on BTS
       :param api_conn: injected by decorator to handle proper WEBEM connection
    """
    return api_conn.get_sw_release_name(timeout=60)


def convert_percentages_to_number(percentages: str) -> float:
    return float(percentages.strip('%'))


def check_energy_efficiency_results(results: dict) -> None:
    skip = 'M40002C0'

    for key in results:
        if key == skip:
            continue
        perc = convert_percentages_to_number(results['percentage gain'])
        assert perc > 0, "No drop in power consumption!."


def run_keyword_and_allow_retest(keyword, max_attempts=3):
    """
    Runs the given keyword multiple times until it passes or the maximum number of attempts is reached.

    :param keyword: The keyword to run.
    :param max_attempts: The maximum number of attempts to run the keyword.
    :return: True if the keyword passes at least once, False otherwise.
    """
    for _ in range(max_attempts):
        status = BuiltIn().run_keyword_and_return_status(keyword)
        if status:
            return True
    raise Exception(f"Test failed after {max_attempts} attempts.")
