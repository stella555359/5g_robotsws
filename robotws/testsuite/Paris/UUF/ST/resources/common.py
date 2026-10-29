import datetime
import difflib
import json
import os.path
import random
import re
import shutil
import subprocess
import tarfile
import time
from itertools import cycle
from copy import deepcopy

import jumpssh
import paramiko
import psutil
import requests
import six
import taf.ul.alarms_watchdog.alarm
import ute_syslog
from mock import Mock
from robot.libraries.BuiltIn import BuiltIn
from taf.config.scf import scf
from taf.config.testline.gnb.gnb import ClassicalBts
from taf.sbts.oam.coam.admin import admin
from taf.ul.alarms_watchdog import alarms_watchdog

from uuf_rfrl_exceptions import MissingDeltaPlan, WrongBtsState
from uuf_rfrl_utilities import robot_logger, robot_kw, \
    wait_until_kw_succeeds, robot_var, set_robot_test_variable, set_robot_suite_variable, robot_variable_exist
from uuf_rfrl_variables import *

syslog = ute_syslog.ute_syslog()
scf = scf()
ssh = paramiko.SSHClient()
admin = admin()
watchdog = alarms_watchdog()

local = " local connection"
remote_connection = " remote connection"


def get_parameter_value_from_scf(parameter_dist_name, parameter_abbreviation, path):
    """
    Retrieve value of specified parameter from scf file.
    :param parameter_dist_name: distName of required parameter, e.g. 'MRBTS-40821/LNBTS-40821'
    :param parameter_abbreviation: parameter shortcut, e.g. 'actProhibitCaSpecCellDepl'
    :param path: path to scf file directory
    :return: parameter value
    """
    scf.load_scf(file_path=path)
    value = scf.get_value_from_scf(dist_name=parameter_dist_name, p_name=parameter_abbreviation)
    return value


def get_random_nrcell_distname(cells):
    """Return distName of random NR cell from given cells dictionary."""
    return cells["cells"]["nr"][0]["id"]["configuration"]


@robot_kw
def check_hw_state(hw_type, hw_list, connection):
    """
    Return state of hardware specified in hardware list.
    :param hw_type: type of hardware to be checked, eg. 'SMOD', 'BBMOD', 'RMOD' etc.
    :param hw_list: list of types of hardware to be checked, eg. ['ABIL', 'ASIA']
    :param connection: setup admin connection
    :return: list with state info of specified hardware
    """
    expected_statuses = {"operationalState": RFRL_STATUSES["operationalState"]["enabled"],
                         "availabilityStatus": RFRL_STATUSES["availabilityStatus"]["online"],
                         "administrativeState": RFRL_STATUSES["administrativeState"]["unlocked"], }
    result = []
    for hw in hw_list:
        hw_name = re.findall("{}.*".format(hw_type), hw)[0]
        try:
            hw_status = admin.get_parameters(hw, connection=connection)["stateInfo"]
        except KeyError:
            hw_status = admin.get_parameters(hw, connection=connection)
        for status in expected_statuses:
            if status in hw_status:
                if not hw_status[status] in expected_statuses[status]:
                    result.append(("{0} {1} should be {2}. Current object {1} is {3}".format(hw_name, status,
                                                                                             expected_statuses[status],
                                                                                             hw_status[status], )))
    return result


@robot_kw
def verify_all_hw_state(connection):
    """Verify state of all hardware based on setup admin connection."""
    hw_types = ["SMOD", "BBMOD", "RMOD", "NRCEL", "ALD", "LNCEL", "WNCEL", "GNCEL"]
    verification_result = []
    for hw in hw_types:
        hw_list = admin.get_ids_for_all(class_name=hw, connection=connection)
        if hw_list:
            hw_state_check_result = check_hw_state(hw, hw_list, connection)
            if hw_state_check_result:
                verification_result.append("\n".join(hw_state_check_result))
    if verification_result:
        raise AssertionError("\n".join(verification_result))
    return True


def verify_iteration(loop, *args):
    """Check if all iterations have passed; return failure info otherwise."""
    result = [False for x in args if x == "FAIL" or not x]
    if False in result:
        robot_logger("Iteration {} failed".format(loop), "error")
        return False
    return True


def verify_recovery(result):
    """Check if recovery process has passed."""
    if result == "FAIL":
        raise Exception("Recovery failed")
    return True


@robot_kw
def check_syslog_for_crashes(test_phase, remote=False):
    """Check if crashes occurred in syslog file and return them if any are present."""
    if remote:
        syslog_file = robot_var("remote_syslog")
    else:
        syslog_file = robot_var("local_syslog")
    try:
        crashes = str(subprocess.check_output("grep '{0}' {1}".format(RFRL_CRASH_PRINTS, syslog_file), shell=True,
                                              universal_newlines=True))
        if crashes:
            robot_logger(
                "Syslog Crash verification failed for {} :\n Crash has been found in {}: \n{}".format(test_phase,
                                                                                                      syslog_file,
                                                                                                      crashes), "error")
            return "Fail"
        return True
    except subprocess.CalledProcessError as e:
        if e.returncode == 1:
            return True
        raise RuntimeError("Error occurred during executing {0}".format(e.cmd))
    except Exception as e:
        robot_logger(e, "error")
    raise


def get_competence_area(force_tags):
    """Return competence area name based on force tags provided; return "UUF4ALL" if no tags provided."""
    if [tag for tag in force_tags if "CA_" in tag]:
        return [tag[3::] for tag in force_tags if "CA_" in tag][0]
    return "UUF4ALL"


@robot_kw
def verify_hw_state_before_x2_link_is_up(connection):
    """Check state info of all hardware based on setup admin connection."""
    hw_types = ["SMOD", "BBMOD", "RMOD", "ALD"]
    verification_result = []
    for hw in hw_types:
        hw_list = admin.get_ids_for_all(class_name=hw, connection=connection)
        if hw_list:
            hw_state_check_result = check_hw_state(hw, hw_list, connection)
            if hw_state_check_result:
                verification_result.append("\n".join(hw_state_check_result))
    if verification_result:
        raise AssertionError("\n".join(verification_result))
    return True


def get_swconfig(filename, swconfig_dir):
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    if not os.path.exists(swconfig_dir):
        os.makedirs(swconfig_dir)
    swconfig_file = "{}/{}.txt".format(swconfig_dir, filename)
    sftp.get("/ffs/run/swconfig.txt", swconfig_file)
    ssh.close()
    return swconfig_file


def add_flag_to_swconfig(new_flag, swconfig_dir):
    """
    Add new flag to software configuration file.
    :param new_flag: name of new flag to be added
    :param swconfig_dir: path to swconfig file directory
    :return: None
    """
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    swconfig_backup_local = get_swconfig("swconfig_original", swconfig_dir)
    modified_swconfig_local = "{}/swconfig.txt".format(swconfig_dir)
    sftp.get("/ffs/run/swconfig.txt", swconfig_backup_local)
    with open(swconfig_backup_local, "r") as swconfig_bk, open(modified_swconfig_local, "w") as new_swconfig:
        for line in swconfig_bk:
            if RFRL_TRUNK_HWF_FLAG in line or RFRL_BRANCH_HWF_FLAG in line:
                continue
            new_swconfig.write(line)
        new_swconfig.write("\n{} #UUF4ALL Site Reset Test flag".format(new_flag))
    sftp.put(modified_swconfig_local, "/ffs/run/swconfig.txt")
    ssh.close()


def get_hwf_flag(connection):
    active_sw = admin.get_sw_version(connection=connection)
    if active_sw.split("_")[2] in ["9999", "9990"]:
        return RFRL_TRUNK_HWF_FLAG
    return RFRL_BRANCH_HWF_FLAG


def restore_original_swconfig(swconfig_dir):
    """Restore original software configuration file."""
    swconfig_backup_local = "{}/swconfig_original.txt".format(swconfig_dir)
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    sftp.put(swconfig_backup_local, "/ffs/run/swconfig.txt")
    ssh.close()


@robot_kw
def verify_x2_link_is_available(connection):
    """Check if X2 connection to all eNBs is available; if not - return eNB ID for unavailable ones."""
    lteenb_objects = admin.get_managed_objects(class_name="LTEENB_R", connection=connection)
    for _ in range(20):
        for lteenb in lteenb_objects:
            if str(lteenb["parameters"]["eNodeBId"]) != "None":
                break
            time.sleep(5)
    if not lteenb_objects:
        raise AssertionError("Waiting for LTEENB_R object to be available")
    for lteenb in lteenb_objects:
        link_status = lteenb["parameters"]["x2LinkStatus"]
        if "unavailable" in link_status:
            raise AssertionError("X2 link unavailable to {}".format(lteenb["parameters"]["eNodeBId"]))
        return True


def evaluate_test_run_results(*results):
    # Evaluates given list of results and return passed or failed value.
    if any("FAIL" in result.upper() for result in results):
        return "failed"
    return "passed"


def get_blackbox_file(blackbox_dir, test_phase, remote=False):
    return get_blackbox_file_remotely(blackbox_dir, test_phase) if remote else get_blackbox_file_locally(blackbox_dir,
                                                                                                         test_phase)


@robot_kw
def get_blackbox_file_locally(blackbox_dir, test_phase):
    # Downloads Blackbox file from BTS
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    if not os.path.isdir(blackbox_dir):
        os.makedirs(blackbox_dir)
    blackbox_file = "{}/blackbox_{}.txt".format(blackbox_dir, test_phase)
    sftp.get("/ffs/run/config/lifedata/blackbox", blackbox_file)
    ssh.close()
    return blackbox_file


def compare_blackboxes(base_blackbox, after_test_blackbox):
    # Compare two given blackbox files and return difference between them.
    compare_results = "/".join([base_blackbox.rsplit("/", 1)[0], "compare_results.txt"])

    with open(base_blackbox) as base_file, open(after_test_blackbox) as new_file, open(compare_results, "w") as results:
        results.writelines("Results of blackbox comparison: \n")
        for x in difflib.ndiff(base_file.readlines(), new_file.readlines()):
            if x.startswith("+"):
                results.write(x)
    return results.name


@robot_kw
def verify_no_new_unexpected_prints(test_phase):
    # Check if there is no new unexpected print i.e. "spurious reset" in blackbox file after test.
    base_blackbox = robot_var("blackbox_before")
    after_test_blackbox = robot_var("blackbox_after")
    results = compare_blackboxes(base_blackbox, after_test_blackbox)
    try:
        crashes = str(subprocess.check_output("grep '{}' {}".format(RFRL_BLACKBOX_PRINTS, results), shell=True,
                                              universal_newlines=True))
        if crashes:
            robot_logger("Blackbox verification failed {}:\n Crash has been found : \n{}".format(test_phase, crashes),
                         "error", )
            return "Fail"
        return True
    except subprocess.CalledProcessError as e:
        if e.returncode == 1:
            return True
        elif e.returncode == 2:
            raise RuntimeError("Error occurred during executing {0}".format(e.cmd))
    except Exception as e:
        robot_logger(e, "error")
    raise


def setup_bts_watchdog(btsconfig):
    # Check if proper port is set in __init__.py file for running alarms watchdog, if not it will set it to 443.
    if btsconfig.cu.oam_http_connection_details.port != 443:
        btsconfig.cu.oam_http_connection_details.port = 443
    return btsconfig


def add_custom_allowed_alarms(base_alarms, list_of_allowed_alarms=None):
    # Add list of custom alarms to base allowed alarms
    if not isinstance(list_of_allowed_alarms, list):
        list_of_allowed_alarms = [alarm for alarm in list_of_allowed_alarms.split(",")]
    if list_of_allowed_alarms:
        base_alarms.extend(
            alarm if isinstance(alarm, taf.ul.alarms_watchdog.alarm.Alarm) else taf.ul.alarms_watchdog.alarm.Alarm(
                fault_id=str(alarm)) for alarm in list_of_allowed_alarms if alarm not in base_alarms)
    return base_alarms


def get_vm_ip(test_pc):
    # Extract virtual machine IP address
    return test_pc.default_ssh_connection_details.addr


def get_enb_vm_ip(enb):
    # Extract Virtual Machine Address for ENB.
    for test_pc in robot_var("tl.test_pcs"):
        if test_pc.connections[0] == enb:
            return get_vm_ip(test_pc)


def get_enb_vm():
    # Return Virtual Machine IP address for ENB if it possible else return False
    try:
        enb_vm = get_enb_vm_ip(robot_var("tl.enbs")[0])
        return six.ensure_text(enb_vm)
    except Exception as e:
        print(e)
    return None


def remove_logs_from_remote(remote, log_dir):
    # Remove logs from ENB Virtual Machine through SSH connection
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname=str(remote), username="ute")
    try:
        ssh.exec_command("rm -r {}".format(log_dir))
    except Exception as e:
        print(e)
    ssh.close()


def tar_logs_and_remove(logs_directory):
    # Tar gathered logs and remove files
    list_of_files = os.listdir(logs_directory)
    tar_file_name = "{}.tar.gz".format(logs_directory.rsplit("/", 1)[1])
    with tarfile.open("{}/{}".format(logs_directory, tar_file_name), "w:gz") as tar_logs:
        tar_logs.add(logs_directory, arcname=os.path.basename(logs_directory))
    if tar_file_name in list_of_files:
        list_of_files.remove(tar_file_name)
    for log_file in list_of_files:
        if os.path.isdir(os.path.join(logs_directory, log_file)):
            shutil.rmtree(os.path.join(logs_directory, log_file))
        else:
            os.remove(os.path.join(logs_directory, log_file))


def check_free_space():
    # Verify if there is enough free space to continue test
    robot_logger("Checking Free space on disk before iteration", "info")
    free_space_home = float(psutil.disk_usage("/home/ute").free) / (1024 ** 3)
    free_space_tmp = float(psutil.disk_usage("/tmp").free) / (1024 ** 3)
    robot_logger("There is {} GB of free space in /home/ute ".format(round(free_space_home, 2)), "info")
    robot_logger("There is {} GB of free space in /tmp".format(round(free_space_tmp, 2)), "info")

    if free_space_home < 1 or free_space_tmp < 1:
        robot_logger(
            "Not enough free space for test to start. Available space in: \n/home/ute {} GB\n/tmp {} GB".format(
                round(free_space_home, 2), round(free_space_tmp, 2)), "error", )
        raise Exception("Not enough free space for test to start. Available space in: \n/home/ute {} GB"
                        "\n/tmp {} GB".format(round(free_space_home, 2), round(free_space_tmp, 2)))
    return True


@robot_kw
def get_reset_counter(blackbox_file):
    counter = str(subprocess.check_output("grep -i 'RESET COUNTER:' {}".format(blackbox_file), shell=True,
                                          universal_newlines=True)).split()[2]
    return int(counter)


@robot_kw
def check_reset_counter_incrementation(should_be_incremented):
    blackbox_before_test = robot_var("blackbox_before")
    blackbox_after_test = robot_var("blackbox_after")
    try:
        counter_incrementation = get_reset_counter(blackbox_after_test) - get_reset_counter(blackbox_before_test)
    except Exception as e:
        robot_logger(e, "error")
        raise
    if str(should_be_incremented).lower() == "true":
        if counter_incrementation != 1:
            robot_logger("Counter Error, reset counter incremented by {}".format(counter_incrementation), "ERROR")
            return False
    elif str(should_be_incremented).lower() == "false":
        if counter_incrementation != 0:
            robot_logger("Counter Error, reset counter incremented by {}".format(counter_incrementation), "ERROR")
            return False
    return True


def get_reporting_build(connection):
    active_sw_version = admin.get_sw_version(connection=connection)
    if active_sw_version.split("_")[2] in ["9999", "9990"]:
        active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
    if "5G" in active_sw_version.split("_", 1)[0]:
        release = active_sw_version.split("_", 1)[0]
        build_number = ".".join([_.lstrip("0") for _ in active_sw_version.split("_")[2::]])
        active_sw_version = "_".join([release, build_number])
    return active_sw_version


def create_mocked_bts_config(mplane_ip):
    connection = Mock()
    connection.addr = mplane_ip
    connection.username = 'Nemuadmin'
    connection.password = 'nemuuser'
    connection.port = 443
    cu = Mock()
    cu.oam_http_connection_details = connection
    remote_bts = Mock(spec=ClassicalBts)
    remote_bts.cu = cu
    return remote_bts


def clear_admin_api_logs():
    cmd = r"find {} -maxdepth 1 -type f \( ! -name '*std*' -and -name 'admin_api*' -or -name '*.ims2' \) -delete"
    try:
        subprocess.call(cmd.format(robot_var("EXEC_DIR")), shell=True)
    except Exception as e:
        robot_logger(e, "error")
        raise e


@robot_kw
def check_if_critical_fault_occurred(alarms, remote):
    list_of_faults = robot_var("CRITICAL_FAULTS")
    if list_of_faults and alarms:
        robot_logger("Checking if any of these faults occurred {}".format(list_of_faults), "info")
        for fault in list_of_faults:
            if "fault_id: {}".format(fault) in alarms:
                robot_logger("Fault {} in detected faults, Test will be aborted without recovery".format(fault),
                             "error")
                set_robot_suite_variable("CRITICAL_FAULT_STATUS_{}".format("REMOTE" if remote else "LOCAL"), False)
                return False
    set_robot_suite_variable("CRITICAL_FAULT_STATUS_{}".format("REMOTE" if remote else "LOCAL"), True)

    return True


def get_hw_id(bts_info):
    rus = get_rmods(bts_info)
    smods = get_smods(bts_info)
    bbmods = get_bbmods(bts_info)
    return "+".join([smods, bbmods, rus])


@robot_kw
def get_remote_hw_id():
    remote_admin = get_admin_connection(True)
    remote_bts_info = admin.get_bts_info(connection=remote_admin)
    return get_hw_id(remote_bts_info)


@robot_kw
def set_remote_hw_id():
    set_robot_test_variable("REMOTE_HW_ID", get_remote_hw_id())


@robot_kw
def get_rmods(bts_info):
    rus_list = sorted([str(ru["productName"]) for ru in bts_info["radioModules"]["rmod"]])
    return get_hw_count(rus_list)


@robot_kw
def get_smods(bts_info):
    smods_list = [str(smod["productName"]).split()[0] for smod in bts_info["systemModules"]]
    return get_hw_count(smods_list)


@robot_kw
def get_bbmods(bts_info):
    bbmods_list = [str(bbmod["productName"].split()[0]) for bbmod in bts_info["basebandModules"]]
    return get_hw_count(bbmods_list)


@robot_kw
def get_hw_count(hw_list):
    counted_hw = ["{}{}".format(hw_list.count(hw), hw) for hw in set(hw_list)]
    return "+".join(counted_hw)


@robot_kw
def get_technology_variant(bts_info):
    cells_technology = list(
        {str(cell["technology"]) for tech in bts_info["cells"].keys() for cell in bts_info["cells"][tech] if
         "technology" in cell.keys()})
    return cells_technology[0] if len(cells_technology) == 1 else "FDD+TDD"


@robot_kw
def get_time_now():
    time_now = datetime.datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')
    return str(time_now).replace("-", "") + ".000"


@robot_kw
def get_blackbox_file_remotely(blackbox_dir, test_phase):
    # Downloads Blackbox file from remote bts
    remote_vm = robot_var("REMOTE_VM_IP")
    enb_session = jumpssh.SSHSession(str(remote_vm), missing_host_key_policy=paramiko.AutoAddPolicy(),
                                     username="ute").open()
    remote_lmp = enb_session.get_remote_session("192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    if not os.path.isdir(blackbox_dir):
        os.makedirs(blackbox_dir)
    blackbox_file = "{}/remote_blackbox_{}.txt".format(blackbox_dir, test_phase)
    remote_lmp.get("/ffs/run/config/lifedata/blackbox", blackbox_file)
    remote_lmp.close()
    enb_session.close()
    return blackbox_file


@robot_kw
def verify_hw(how_many_hw_checks=5, test_phase="", remote=False):
    try:
        return wait_until_kw_succeeds("{} times".format(how_many_hw_checks), 10, verify_bts_state, remote, True)
    except AssertionError as e:
        robot_logger("Verify HW failed {} -{}".format(test_phase, get_last_error(e)), "error")
        return get_last_error(e)


@robot_kw
def verify_hw_before_x2_is_up(how_many_hw_checks=5, test_phase="", remote=False):
    try:
        return wait_until_kw_succeeds("{} times".format(how_many_hw_checks), 10, verify_bts_state,
                                      remote, False)
    except AssertionError as e:
        robot_logger("HW check failed {}:\n{}".format(test_phase, get_last_error(e)), "error")
        return get_last_error(e)


@robot_kw
def get_bts_type(admin_connection):
    if "nr" in get_bts_rat(admin_connection):
        return str(admin.get_bts_info(connection=admin_connection)["gNbCuType"])
    return ""


@robot_kw
def wait_for_x2(admin_connection):
    try:
        return wait_until_kw_succeeds(900, 5, verify_x2_link_is_available, admin_connection)
    except AssertionError as e:
        return get_last_error(e)


@robot_kw
def check_bts_state(how_many_checks, test_phase, remote=False):
    admin_connection = get_admin_connection(remote)
    how_many_checks = int(how_many_checks)
    bts_type = str(robot_var("REMOTE_BTS_TYPE")) if remote else str(robot_var("LOCAL_BTS_TYPE"))
    check_results = {}
    if bts_type != "":
        robot_logger(
            "Checking if HW is in proper state before X2 is up{}".format(remote_connection if remote else local),
            "info")
        check_results["Verify HW Before X2 Link Is Up"] = verify_hw_before_x2_is_up(how_many_checks, test_phase,
                                                                                    remote)
        if bts_type == "SA+NSA":
            robot_logger("Waiting until X2 Link is up.{}".format(remote_connection if remote else local), "info")
            check_results["X2 Link Is Up"] = wait_for_x2(admin_connection)
    robot_logger("Checking if HW is in proper state{}".format(remote_connection if remote else local), "info")
    check_results["Verify HW"] = verify_hw(how_many_checks, test_phase, remote)
    if remote:
        watchdog_object = robot_var("REMOTE_WATCHDOG")
    else:
        watchdog_object = robot_var("LOCAL_WATCHDOG")
    robot_logger("Waiting 3 minutes for unexpected alarm{}".format(remote_connection if remote else local), "info")
    time.sleep(180)
    check_results["Check Alarms"] = check_alarms(watchdog_object, remote)
    if not all(check_result is True for check_result in check_results.values()):
        robot_logger("BTS State check failed{} \n{}\n{}".format(remote_connection if remote else local, test_phase,
                                                                json.dumps(check_results, indent=4)), "error")
        raise Exception("BTS State check failed{} ".format(remote_connection if remote else local))


@robot_kw
def check_alarms(watchdog_object, remote):
    try:
        set_robot_suite_variable("CRITICAL_FAULT_STATUS_{}".format("REMOTE" if remote else "LOCAL"), "True")
        watchdog_object.check_detected_alarms()
        return True
    except Exception as e:
        robot_logger("Alarms found on{}\n{}".format(remote_connection if remote else local, e), "error")
        check_if_critical_fault_occurred(str(e), remote)
        return False
    finally:
        watchdog_object.stop_watching_alarms()


@robot_kw
def create_watchdog():
    return alarms_watchdog()


@robot_kw
def start_watching_alarms(allowed_alarms, remote=False):
    if remote:
        bts_config = robot_var("REMOTE_CONFIG")
        watchdog_object = robot_var("REMOTE_WATCHDOG")
    else:
        bts_config = robot_var("LOCAL_CONFIG")
        watchdog_object = robot_var("LOCAL_WATCHDOG")
    watchdog_object.watch_alarms(allowed_alarms=allowed_alarms, bts_config=bts_config)


@robot_kw
def stop_watchdog(remote=False):
    if remote:
        watchdog_object = robot_var("REMOTE_WATCHDOG")
    else:
        watchdog_object = robot_var("LOCAL_WATCHDOG")
    watchdog_object.stop_watching_alarms()


@robot_kw
def check_logs_for_crashes(test_phase, reset_check=True, remote=False, should_be_incremented=True):
    BuiltIn().log("Checking Logs for Crashes", "info", console=True)
    logs_results = {"Syslog Verification": check_syslog_for_crashes(test_phase, remote),
                    "Blackbox Verification": verify_no_new_unexpected_prints(test_phase)}
    if reset_check and not remote:
        logs_results["Reset Incrementation"] = check_reset_counter_incrementation(should_be_incremented)
    if not all(logs_result is True for logs_result in logs_results.values()):
        robot_logger("Logs check failed \n{}\n{}".format(test_phase, json.dumps(logs_results, indent=4)), "error")
        raise Exception("Logs check failed - {}".format(test_phase))


@robot_kw
def get_admin_connection(remote=False):
    if remote:
        admin_connection = robot_var("REMOTE_ADMIN")
    else:
        admin_connection = robot_var("LOCAL_ADMIN")
    try:
        admin.get_bts_info(connection=admin_connection)
    except AttributeError:
        admin_connection = setup_new_admin_connection(remote)
    return admin_connection


def update_sw(target_sw, sw_package, remote=False):
    admin_connection = get_admin_connection(remote)
    sw_package_path = sw_package.strip()
    active_sw = get_active_sw_version(admin_connection)

    try:
        robot_logger("Active SW on bts : {}\nStarting SW update to {}".format(active_sw, target_sw), "info")
        return admin.update_software(sw_package=sw_package_path, connection=admin_connection, timeout=3600)

    except Exception as e:
        robot_logger("Exception occurred during update SW {}".format(e), "error")
        raise
    finally:
        admin.teardown_admin(connection=admin_connection)


def rollback_sw(remote=False):
    admin_connection = get_admin_connection(remote)
    active_sw = get_active_sw_version(admin_connection)

    try:
        robot_logger("Active SW on BTS : {}\nStarting SW Rollback".format(active_sw), "info")
        return admin.rollback_software(timeout=2400, connection=admin_connection)

    except Exception as e:
        robot_logger("Exception occurred during SW Rollback {}".format(e), "error")
        raise
    finally:
        admin.teardown_admin(connection=admin_connection)


def setup_new_admin_connection(remote=False):
    if remote:
        remote_vm = robot_var("REMOTE_VM_IP")
        admin_connection = admin.setup_admin(remote_host=remote_vm, alias="remote_admin")
        BuiltIn().set_test_variable("${REMOTE_ADMIN}", admin_connection)
    else:
        admin_connection = admin.setup_admin(alias="local_admin")
        BuiltIn().set_test_variable("${LOCAL_ADMIN}", admin_connection)
    return admin_connection


def check_webem_is_down(remote=False):
    if remote:
        ip_address = robot_var("REMOTE_MPLANE")
    else:
        ip_address = "192.168.255.1"
    try:
        r = requests.get("https://{}".format(ip_address), verify=False, timeout=3)
        if r.status_code == 200:
            raise Exception("Waiting for WebEm to be reloaded")
    except (requests.exceptions.ConnectTimeout, requests.exceptions.ConnectionError):
        return True


def verify_sw_change(sw, remote=False):
    admin_connection = wait_until_kw_succeeds(900, 10, setup_new_admin_connection, remote)
    active_sw = wait_until_kw_succeeds(600, 10, get_active_sw_version, admin_connection)
    if not str(active_sw) == str(sw):
        raise AssertionError("SW didn't changed. Active Sw: {}\nTarget SW: {}".format(active_sw, sw))
    return True


@robot_kw
def get_active_sw_version(connection):
    active_sw_version = admin.get_software_info(alias=connection)["Active SW version"]
    if active_sw_version.split("_", 3)[2] == "9999" or active_sw_version.split("_", 3)[2] == "9990":
        active_sw_version = "_".join(["SBTS00", active_sw_version.split("_", 1)[1]])
    if "5G" in active_sw_version.split("_", 1)[0]:
        release = active_sw_version.split("_", 1)[0]
        build_number = ".".join([_.lstrip("0") for _ in active_sw_version.split("_")[2::]])
        active_sw_version = "_".join([release, build_number])
    return active_sw_version


def get_bts_for_operation(remote=False):
    return "local_node" if not remote else "remote_node"


def get_last_error(error_print):
    return str(error_print).split(":", 1)[1]


def check_if_enb_in_tl():
    tl = robot_var("tl")
    if hasattr(tl, 'enbs') and tl.enbs:
        return True
    return False


def get_object_distname(object_type, object_id, objects_list):
    pattern = "{}_R-{}".format(object_type, object_id)
    for distname in objects_list:
        if pattern in distname:
            return distname
    raise KeyError("No {} with given id {} found".format(object_type, object_id))


def check_locked_object_parameter(locked_object_distname, locked_object_type, connection):
    expected_statuses_locked_module = {"operationalState": RFRL_STATUSES['operationalState']['enabled'],
                                       "availabilityStatus": RFRL_STATUSES['availabilityStatus']['online'],
                                       "administrativeState": RFRL_STATUSES['administrativeState']['locked'], }

    expected_statuses_locked_nrcell = {"operationalState": RFRL_STATUSES['operationalState']['disabled'],
                                       "availabilityStatus": RFRL_STATUSES['availabilityStatus']['offline'],
                                       "administrativeState": RFRL_STATUSES['administrativeState']['locked'], }
    result = []
    hw_name = re.findall("{}.*".format(locked_object_type), locked_object_distname)[0]
    try:
        hw_status = admin.get_parameters(locked_object_distname, connection=connection)['stateInfo']
    except KeyError:
        hw_status = admin.get_parameters(locked_object_distname, connection=connection)
    if "BBMOD" in locked_object_type or "RMOD" in locked_object_type:
        for status in expected_statuses_locked_module:
            if not hw_status[status] in expected_statuses_locked_module[status]:
                result.append(("Locked {0} {1} should be {2}. Current object {1} is {3}".
                               format(hw_name, status, expected_statuses_locked_module[status], hw_status[status])))
    else:
        for status in expected_statuses_locked_nrcell:
            if not hw_status[status] in expected_statuses_locked_nrcell[status]:
                result.append(("Locked {0} {1} should be {2}. Current object {1} is {3}".
                               format(hw_name, status, expected_statuses_locked_nrcell[status], hw_status[status])))
    return result


def verify_all_hw_state_during_block_test(blocked_object_distname, connection):
    hw_types = ["SMOD", "BBMOD", "RMOD", "NRCEL", "ALD", "LNCEL", "WNCEL", "GNCEL"]
    verification_result = []
    blocked_object_type = []
    for hw in hw_types:
        hw_list = admin.get_ids_for_all(class_name=hw, connection=connection)
        if blocked_object_distname in hw_list:
            hw_list.remove(blocked_object_distname)
            blocked_object_type.append(hw)
        hw_state_check_result = check_hw_state(hw, hw_list, connection)
        if hw_state_check_result:
            verification_result.append("\n".join(hw_state_check_result))
        check_object_state("blockingState", "blocked", blocked_object_distname)
    if verification_result:
        raise Exception("\n".join(verification_result))
    return True


def get_rmods_connected_to_bbmod(bts_info, bbmod_distname):
    rmods = []
    for cable in bts_info["cables"]:
        if bbmod_distname in cable["firstEndPointId"]["internal"]:
            rmods.extend(re.findall(r".*RMOD_R-\d+", cable["secondEndPointId"]["internal"]))
    rmods = list(set(rmods))
    return rmods


def get_cells_on_rmod(bts_info, rmod_distname):
    cells = {CELL_TYPES[rat]: [cell["id"]["internal"]
                               for cell in bts_info["cells"][rat.lower()]
                               for antennaLine in cell["carrierList"]
                               if rmod_distname in antennaLine["antennaLineId"]["internal"]]
             for rat in CELL_TYPES.keys()}
    return cells


def removes_affected_objects_from_list(affected_objects, all_objects):
    for affected_object in affected_objects:
        all_objects.remove(affected_object)
    unaffected_object = all_objects
    return unaffected_object


@robot_kw
def get_dependent_cells(bts_info, object_distname):
    cells = {cell_type: [] for cell_type in CELL_TYPES.values()}
    if "RMOD_R-" in object_distname:
        cells = get_cells_on_rmod(bts_info, object_distname)
    elif "BBMOD_R-" in object_distname:
        rmods = get_rmods_connected_to_bbmod(bts_info, object_distname)
        for rmod in rmods:
            cells_from_rmod = get_cells_on_rmod(bts_info, rmod)
            for cell_type in cells_from_rmod.keys():
                cells[cell_type].extend(cells_from_rmod[cell_type])
    for cell_type, cells_list in cells.items():
        cells[cell_type] = list(set(cells_list))
    return cells


def remove_dependent_cell(all_cells, test_dependent_nrcells):
    not_affected_cells = all_cells
    for cell in test_dependent_nrcells:
        not_affected_cells.remove(cell)
    return not_affected_cells


def check_dependent_object_status(object_status):
    expected_statuses = {"operationalState": RFRL_STATUSES['operationalState']['disabled'],
                         "availabilityStatus": RFRL_STATUSES['availabilityStatus']['dependency'],
                         "administrativeState": RFRL_STATUSES['administrativeState']['unlocked'], }
    try:
        verification_results = [True if object_status["stateInfo"][key] in expected_statuses[key] else False for key in
                                expected_statuses.keys()]
        if not all(verification_results):
            raise Exception("Object Status is not as expected. Current object status : ", object_status["stateInfo"])
    except KeyError:
        verification_results = [True if object_status[key] in expected_statuses[key] else False for key in
                                expected_statuses.keys()]
        if not all(verification_results):
            raise Exception("Object Status is not as expected. Current object status : ", object_status)
    return True


@robot_kw
def verify_hw_during_cell_lock_test(cell_type, locked_cells, how_many_hw_checks=5, test_phase="",
                                    admin_connection=None):
    try:
        return wait_until_kw_succeeds("{} times".format(how_many_hw_checks), 10,
                                      verify_all_hw_state_during_cells_lock_test, cell_type, locked_cells,
                                      admin_connection)
    except AssertionError as e:
        robot_logger("Verify HW failed {} -{}".format(test_phase, get_last_error(e)), "error")
        return get_last_error(e)


@robot_kw
def verify_hw_during_object_block_test(blocked_object_distname, how_many_hw_checks=5, test_phase="",
                                       admin_connection=None):
    try:
        return wait_until_kw_succeeds("{} times".format(how_many_hw_checks), 10, verify_all_hw_state_during_block_test,
                                      blocked_object_distname, admin_connection)
    except AssertionError as e:
        robot_logger("Verify HW failed {} -{}".format(test_phase, get_last_error(e)), "error")
        return get_last_error(e)


def load_list_as_iterator(objects_list):
    return cycle(objects_list)


def get_object_for_operation(objects_list):
    return next(objects_list)


def get_cells_distnames(cell_type, admin_connection):
    for tech, cell in CELL_TYPES:
        if cell_type == cell:
            cell_tech = tech
    cells = [cell["id"]["configuration"] for cell in
             admin.get_cell_list(connection=admin_connection)["cells"][cell_tech]]
    return cells


@robot_kw
def create_cell_lock_delta(cells_list, delta_id="lock"):
    delta_dir = "/".join([robot_var("LOG_PATH"), robot_var("TEST_NAME")])
    admin.create_delta(delta_id=delta_id)
    for cell in cells_list:
        if "LNCEL" in cell:
            state = "locked"
        else:
            state = "Locked"
        admin.append_parameter_update_to_delta(dist_name=cell, parameter="administrativeState", value=state,
                                               delta_id=delta_id)
    admin.save_delta(target_file_name="{}/{}.json".format(delta_dir, delta_id), delta_id=delta_id)
    return admin.get_delta(delta_id)


@robot_kw
def create_cell_unlock_delta(cells_list, delta_id="unlock"):
    delta_dir = "/".join([robot_var("LOG_PATH"), robot_var("TEST_NAME")])
    admin.create_delta(delta_id=delta_id)
    for cell in cells_list:
        if "LNCEL" in cell:
            state = "unlocked"
        else:
            state = "Unlocked"
        admin.append_parameter_update_to_delta(dist_name=cell, parameter="administrativeState", value=state,
                                               delta_id=delta_id)
    admin.save_delta(target_file_name="{}/{}.json".format(delta_dir, delta_id), delta_id=delta_id)
    return admin.get_delta(delta_id)


def verify_all_hw_state_during_cells_lock_test(cell_type, locked_cells, connection):
    """Verify state of all hardware based on setup admin connection."""
    hw_types = ["SMOD", "BBMOD", "RMOD", "NRCEL", "ALD", "LNCEL", "WNCEL", "GNCEL"]
    cell_type = CELL_TYPES[cell_type.upper()]
    verification_result = []
    for hw in hw_types:
        hw_list = admin.get_ids_for_all(class_name=hw, connection=connection)
        if hw_list:
            if hw == cell_type:
                hw_list = [cell for cell in hw_list if cell not in locked_cells]
            hw_state_check_result = check_hw_state(hw, hw_list, connection)
            if hw_state_check_result:
                verification_result.append("\n".join(hw_state_check_result))
    for cell in locked_cells:
        cell_check_result = check_locked_object_parameter(cell, cell_type.upper(), connection)
        if cell_check_result:
            verification_result.append("\n".join(cell_check_result))
    assert not verification_result, "\n".join(verification_result)
    return True


@robot_kw
def check_bts_state_during_cells_lock(cell_type, locked_cells, how_many_checks, test_phase, remote=False):
    admin_connection = get_admin_connection(remote)
    how_many_checks = int(how_many_checks)
    check_results = {}
    robot_logger("Checking if HW is in proper state", "info")
    check_results["Verify HW"] = verify_hw_during_cell_lock_test(cell_type, locked_cells, how_many_checks, test_phase,
                                                                 admin_connection)
    if remote:
        watchdog_object = robot_var("REMOTE_WATCHDOG")
    else:
        watchdog_object = robot_var("LOCAL_WATCHDOG")
    robot_logger("Waiting 3 minutes for unexpected alarm.", "info")
    time.sleep(180)
    check_results["Check Alarms"] = check_alarms(watchdog_object, remote)
    if not all(check_result is True for check_result in check_results.values()):
        robot_logger("BTS State check failed \n{}\n{}".format(test_phase, json.dumps(check_results, indent=4)), "error")
        raise Exception("BTS State check failed {}".format(test_phase))


def try_reset_unit(distname, reset_type, timeout, admin_connection):
    try:
        robot_logger("Starting reset of {}".format(distname.split("/")[-1]), "info")
        admin.reset_unit(dist_name=distname, reset_type=reset_type, timeout=timeout, connection=admin_connection)
    except Exception as e:
        robot_logger("Reset of {} Failed due to - {}".format(distname.split("/")[-1], e), "error")
        raise e


def get_rmods_with_cells(admin_connection):
    cells = admin.get_bts_info(connection=admin_connection)["cells"]
    rmods = {carrier["antennaLineId"]["internal"] for cellTech in cells.keys() for cell in cells[cellTech] for carrier
             in cell["carrierList"]}
    rmods_with_cells = list({re.findall(r".*RMOD_R-\d+", rmod)[0] for rmod in rmods})
    return rmods_with_cells


def get_shared_rmods(admin_connection):
    cables = admin.get_bts_info(connection=admin_connection)["cables"]
    shared_rmods = [re.findall(r".*RMOD_R-\d+", cable["secondEndPointId"]["internal"])[0] for cable in cables if
                    "RF_EXT" in cable["firstEndPointId"]["internal"]]
    if shared_rmods:
        return True
    return False


def store_first_passed_logs(logs_directory):
    tar_file_name = "{}.tar.gz".format(logs_directory.rsplit("/", 1)[1])
    passed_logs_dir = os.path.join(logs_directory.rsplit("/", 1)[0], "passed_iteration")
    print(tar_file_name, passed_logs_dir, logs_directory)
    if not os.path.exists(passed_logs_dir):
        os.makedirs(passed_logs_dir)
        shutil.copy(os.path.join(logs_directory, tar_file_name), os.path.join(passed_logs_dir, tar_file_name))
    return True


def remove_old_logs(logs_directory):
    if os.path.exists(logs_directory):
        paths = os.listdir(logs_directory)
        for path in paths:
            if os.path.isdir(os.path.join(logs_directory, path)):
                shutil.rmtree(os.path.join(logs_directory, path))
            else:
                os.remove(os.path.join(logs_directory, path))


def get_ims_from_session(test_phase, file_name):
    connection = get_admin_connection()

    ims_path = "/".join([robot_var("LOG_PATH"), robot_var("TEST_NAME"), test_phase, file_name])
    admin.collect_infomodel_log_from_current_session(target_file_name=ims_path, timeout=240, connection=connection)
    admin.teardown_admin(connection=connection)
    wait_until_kw_succeeds(900, 10, setup_new_admin_connection)
    return ims_path


def validate_scf_file(scf_path=None):
    admin_connection = get_admin_connection()
    iteration_counter = robot_var("ITERATION_COUNTER")
    if not scf_path:
        scf_path = admin.get_current_scf_file(local_dir_path=get_log_path(), file_name="after_update.xml",
                                              connection=admin_connection, timeout=120)
    if iteration_counter == 0:
        robot_logger("Validating SCF", "info")
        print(admin.validate_scf_online(scf_file=scf_path, connection=admin_connection, timeout=240))
        iteration_counter += 1
        BuiltIn().set_test_variable("${ITERATION_COUNTER}", iteration_counter)


def get_log_path():
    return "/".join([robot_var("LOG_PATH"), robot_var("TEST_NAME")])


@robot_kw
def get_cells_per_band(cell_type, band_no=None):
    admin_connection = get_admin_connection()
    cells = admin.get_cell_list(connection=admin_connection)["cells"][cell_type.lower()]
    if cell_type.lower() == "lte":
        cells = [cell for cell in cells if "iot" not in cell['technology'].lower()]
    band_key = "band" if cell_type.lower() == "nr" else "bandNumber"
    if not band_no:
        list_of_bands = {cell[band_key] for cell in cells}
        cells_dict = {band: [cell["id"] for cell in cells if cell[band_key] == band] for band in list_of_bands}
    else:
        cells_dict = {band_no: [cell["id"] for cell in cells if cell[band_key] == band_no]}
    return cells_dict


@robot_kw
def unpack_deltas_list(delta_dict):
    return list(delta_dict.items())[0]


def prepare_cell_lock_deltas(cell_tech, band_no=None):
    cell_dictionary = get_cells_per_band(cell_tech, band_no)
    deltas_per_band = [{band: {"Cells": get_cells_ids("internal", cell_dictionary[band]),
                               "Lock": create_cell_lock_delta(get_cells_ids("configuration", cell_dictionary[band]),
                                                              "lock_{}".format(band)),
                               "Unlock": create_cell_unlock_delta(get_cells_ids("configuration", cell_dictionary[band]),
                                                                  "unlock_{}".format(band))}} for band in
                       cell_dictionary.keys()]

    if cell_tech.lower() == "lte":
        lte_cells = admin.get_parameters_for_all("LNCEL", connection=get_admin_connection())
        for delta in deltas_per_band:
            band, values = delta.items()[0]
            nbiot_cells = [get_nbiot_cells_per_host(cell, lte_cells) for cell in delta[band]["Cells"] if
                           get_nbiot_cells_per_host(cell, lte_cells) is not None]
            if nbiot_cells:
                delta[band]["Cells"].extend(nbiot_cells)
    return cycle(deltas_per_band)


def get_nbiot_cells_per_host(cell_distname, lte_cells):
    for cell in lte_cells:
        if cell_distname == cell["id"]:
            if cell["nbIoTCell"]:
                return cell["nbIoTCell"]["distName"]


def get_cells_ids(id_type, cells):
    return [cell[id_type] for cell in cells]


def check_object_state(state_to_check, state_value, object_distname):
    try:
        object_state = admin.get_parameters(object_distname, connection=get_admin_connection())["stateInfo"]
    except KeyError:
        object_state = admin.get_parameters(object_distname, connection=get_admin_connection())

    if object_state[state_to_check] in RFRL_STATUSES[state_to_check][state_value.lower()]:
        return True
    return False


def get_delta(list_of_deltas):
    band, deltas = unpack_deltas_list(next(list_of_deltas))
    lock_delta, unlock_delta = deltas["Lock"], deltas["Unlock"]
    cells = deltas["Cells"]
    print(lock_delta, unlock_delta, band, deltas)
    return band, cells, lock_delta, unlock_delta


def try_block_cell(distname):
    if check_object_state("blockingState", "unblocked", distname):
        try:
            robot_logger("Starting block of {}".format(distname.split("/")[-1]), "info")
            admin.block_cell(dist_name=distname, timeout=240, connection=get_admin_connection())
        except Exception as e:
            robot_logger("Block of {} Failed due to - {}".format(distname.split("/")[-1], e), "error")
            raise e
    else:
        robot_logger("Cell {} should be unblocked. Cannot start blocking process.".format(distname), "error")
        raise Exception("Cell Block is impossible due to Cell State")


def try_unblock_cell(distname, teardown=False):
    if check_object_state("blockingState", "blocked", distname):
        try:
            robot_logger("Starting unblock of {}".format(distname.split("/")[-1]), "info")
            admin.unblock_cell(dist_name=distname, timeout=240, connection=get_admin_connection())
        except Exception as e:
            robot_logger("Unblock of {} Failed due to - {}".format(distname.split("/")[-1], e), "error")
            raise e
    else:
        if teardown:
            return True
        robot_logger("Cell {} is already unblocked.".format(distname), "info")


@robot_kw
def check_bts_state_during_object_block(blocked_object_distname, how_many_checks, test_phase, remote=False):
    admin_connection = get_admin_connection(remote)
    how_many_checks = int(how_many_checks)
    check_results = {}
    robot_logger("Checking if HW is in proper state", "info")
    check_results["Verify HW"] = verify_hw_during_object_block_test(blocked_object_distname, how_many_checks,
                                                                    test_phase, admin_connection)
    if remote:
        watchdog_object = robot_var("REMOTE_WATCHDOG")
    else:
        watchdog_object = robot_var("LOCAL_WATCHDOG")
    robot_logger("Waiting 3 minutes for unexpected alarm.", "info")
    time.sleep(180)
    check_results["Check Alarms"] = check_alarms(watchdog_object, remote)
    if not all(check_result is True for check_result in check_results.values()):
        robot_logger("BTS State check failed \n{}\n{}".format(test_phase, json.dumps(check_results, indent=4)), "error")
        raise Exception("BTS State check failed - {}".format(test_phase))


def add_allowed_alarm(**allowed_alarm):
    """ allowed_alarm_args should be provided according to method "allow alarm" from taf.ul.alarms.watchdog library
    i.e. :
    alarm_id (str or None)  -used during comparison with alarm ID of active alarms; defaults to None (not used)
    fault_id (str or None)  -used during comparison with fault ID of active alarms; defaults to None (not used)
    fault_name (str or None) - used during comparison with fault name of active alarms; defaults to None (not used)"""
    watchdog_object = robot_var("LOCAL_WATCHDOG")
    watchdog_object.allow_alarm(**allowed_alarm)


def get_bts_rat(admin_connection):
    bts_info = admin.get_bts_info(connection=admin_connection)
    return [rat for rat in bts_info["cells"] if bts_info["cells"][rat]]


def get_local_vm_ip():
    return six.ensure_str(subprocess.check_output(["hostname", "-I"])).split(" ")[0]


def get_local_hostname():
    return six.ensure_str(subprocess.check_output(["hostname"]))


def get_vm_for_bts(bts):
    for test_pc in robot_var("tl.test_pcs"):
        if test_pc.connections[0] == bts:
            return get_vm_ip(test_pc)


@robot_kw
def get_bts_mplane_from_init(bts):
    if bts.oam_ip:
        return bts.oam_ip.v4
    else:
        robot_logger("Please define 'oam_ip' attribute in bts definition", "warn")
        return bts.x2_link_addr.v4


def check_if_local_bts(bts):
    test_pcs = robot_var("tl.test_pcs")
    for test_pc in test_pcs:
        if test_pc.connections[0] == bts:
            if get_local_vm_ip() == get_vm_ip(test_pc) or get_local_hostname() in get_vm_ip(test_pc):
                return True
    return False


def get_remote_object_details():
    testline = robot_var("tl")
    enb = testline.enbs[0] if hasattr(testline, "enbs") and testline.enbs else None
    gnb = testline.gnbs[0] if hasattr(testline, "gnbs") and testline.gnbs else None
    if enb and check_if_local_bts(enb):
        if gnb:
            return get_vm_for_bts(gnb), get_bts_mplane_from_init(gnb)
    elif gnb and check_if_local_bts(gnb):
        if enb:
            return get_vm_for_bts(enb), get_bts_mplane_from_init(enb)
    return None, None


@robot_kw
def get_proper_sw(bts_type):
    sw = {}
    if check_4g_sw_available() and not check_5g_sw_available():
        source_sw = robot_var("4G_SOURCE_SW")
        target_sw = robot_var("4G_TARGET_SW")
        target_sw_path = robot_var("4G_TARGET_SW_PATH").strip()
    elif check_5g_sw_available() and not check_4g_sw_available():
        source_sw = robot_var("5G_SOURCE_SW")
        target_sw = robot_var("5G_TARGET_SW")
        target_sw_path = robot_var("5G_TARGET_SW_PATH").strip()
    else:
        source_sw = robot_var("4G_SOURCE_SW") if bts_type == "" else robot_var("5G_SOURCE_SW")
        target_sw = robot_var("4G_TARGET_SW") if bts_type == "" else robot_var("5G_TARGET_SW")
        target_sw_path = robot_var("4G_TARGET_SW_PATH").strip() if bts_type == "" else robot_var(
            "5G_TARGET_SW_PATH").strip()
    sw["source_sw"] = source_sw
    sw["target_sw"] = target_sw
    sw["target_sw_path"] = target_sw_path
    return sw


def check_4g_sw_available():
    return True if robot_var("4G_TARGET_SW") is not None else False


def check_5g_sw_available():
    return True if robot_var("5G_TARGET_SW") is not None else False


def get_update_variables():
    update_details = {}
    local_node = get_proper_sw(robot_var("LOCAL_BTS_TYPE"))
    local_node["remote_node"] = False
    update_details["1st_bts"] = local_node
    if robot_var("REMOTE_NODE_UPDATE") and robot_var("REMOTE_VM_IP") is not None:
        remote_bts_type = robot_var("REMOTE_BTS_TYPE")
        remote_node = get_proper_sw(remote_bts_type)
        remote_node["remote_node"] = True
        if remote_bts_type == "":
            update_details["2nd_bts"] = update_details.pop("1st_bts")
            update_details["1st_bts"] = remote_node
        else:
            update_details["2nd_bts"] = remote_node
    set_robot_test_variable("INITIAL_UPDATE_VARIABLES", deepcopy(update_details))
    return update_details


def get_cells_per_rmod(rmod_distname, bts_info):
    node_cells = bts_info["cells"]
    cell_per_rmod = {cell["id"]["internal"] for rat in node_cells for cell in node_cells[rat] for antennaLine in
                     cell["carrierList"] if rmod_distname in antennaLine["antennaLineId"]["internal"]}
    return list(cell_per_rmod)


def get_cells_per_rat(rat, bts_info):
    return [cell["id"]["internal"] for cell in bts_info["cells"][rat]]


def get_bbmod_eligible_for_reset(admin_connection):
    bbmods = admin.get_ids_for_all("BBMOD", connection=admin_connection)
    bbmod_eligible_for_reset = [bbmod for bbmod in bbmods if
                                not admin.get_parameters(bbmod, connection=admin_connection)["geranSupport"] and not
                                admin.get_parameters(bbmod, connection=admin_connection)["utranSupport"]]
    return bbmod_eligible_for_reset


def verify_correct_source_sw_before_test(source_sw, remote=False):
    admin_connection = get_admin_connection(remote)
    active_sw = wait_until_kw_succeeds(600, 10, get_active_sw_version, admin_connection)
    if not str(active_sw) == str(source_sw):
        raise AssertionError("Source SW is different than given one on {}.\n"
                             "Active Sw: {}\nGiven Sw: {}".format(remote_connection if remote else local, active_sw,
                                                                  source_sw))
    return True


def _fix_customers_name(customers):
    return [valid_customer for customer in customers for valid_customer in RFRL_CUSTOMERS_LIST if
            customer.strip().lower() == valid_customer.lower()]


@robot_kw
def validate_customers_list(customers):
    error_msg = "Validation failed. Please define variable 'customers_list' correctly.\
    \nYour customers list: {}".format(customers)
    if customers:
        valid_customers = _fix_customers_name(customers)
        if len(customers) == 1:
            assert len(customers) == len(valid_customers), error_msg
        else:
            assert len(customers) == len(valid_customers) and 'Generic' not in valid_customers, error_msg
    else:
        raise ValueError(error_msg)
    return valid_customers


def update_results(result, operation):
    update_results_dictionary = robot_var("UPDATE_RESULTS")
    iteration = robot_var("test_phase")
    remote_node = "Remote Node" if robot_var("remote") else "Local Node"
    global node_qty
    node_qty = len(robot_var("UPDATE_TEST_VARIABLES"))
    if iteration not in update_results_dictionary and node_qty == 2:
        update_results_dictionary[iteration] = {"Remote Node": {"Rollback": "Not Executed", "Upgrade": "Not Executed"},
                                                "Local Node": {"Rollback": "Not Executed", "Upgrade": "Not Executed"}}
    if iteration not in update_results_dictionary and node_qty == 1:
        update_results_dictionary[iteration] = {"Local Node": {"Rollback": "Not Executed", "Upgrade": "Not Executed"}}
    if operation == "Rollback":
        update_results_dictionary[iteration][remote_node]["Rollback"] = "Pass" if result else "Fail"
    else:
        update_results_dictionary[iteration][remote_node] = {"Rollback": "Not Executed",
                                                             "Upgrade": "Pass" if result else "Fail"}
    BuiltIn().set_test_variable("${UPDATE_RESULTS}", update_results_dictionary)


def log_update_results():
    update_results_dictionary = robot_var("UPDATE_RESULTS")
    log_summary_result_for_node("Local Node", update_results_dictionary)
    if node_qty == 2:
        log_summary_result_for_node("Remote Node", update_results_dictionary)
    passed_iterations = list(
        {iteration for iteration, nodes in update_results_dictionary.items() for node, operations in nodes.items() if
         not any(result == "Fail" for result in operations.values())})
    for iteration in passed_iterations:
        del update_results_dictionary[iteration]
    formatted_results = re.sub(r"[{}\",]", "", json.dumps(update_results_dictionary, indent=2), flags=re.MULTILINE)
    formatted_results = re.sub(r"\n\s*\n", "\n", formatted_results, flags=re.MULTILINE)
    robot_logger(
        "Upgrade Failed Test Results:{}".format(formatted_results) if update_results_dictionary else "All Test Passed",
        "info", log_to_console=False)


def get_summary_results_for_node(operation, node, results_dictionary):
    return [results[node][operation] for results in results_dictionary.values() if
            node in results and operation in results[node]]


def get_failed_iteration_for_node(operation, node, results_dictionary):
    failed_iterations = [str(iteration).strip("Loop_") for iteration, results in results_dictionary.items() if
                         node in results and operation in results[node] and results[node][operation] == "Fail"]
    return failed_iterations if failed_iterations else None


def log_summary_result_for_node(node, update_results_dictionary):
    robot_logger("{node} Result\n"
                 "Passed Upgrades {passed_upgrade_qty}/{iteration_sum}"
                 "\nFailed Upgrades {failed_upgrade_qty}/{iteration_sum} - {failed_upgrade_iteration}"
                 "\nPassed Rollbacks {passed_rollback_qty}/{iteration_sum}"
                 "\nFailed Rollbacks {failed_rollback_qty}/{iteration_sum} - {failed_rollback_iteration}"
                 .format(node=node,
                         passed_upgrade_qty=get_summary_results_for_node("Upgrade", node,
                                                                         update_results_dictionary).count("Pass"),
                         failed_upgrade_qty=get_summary_results_for_node("Upgrade", node,
                                                                         update_results_dictionary).count("Fail"),
                         iteration_sum=len(update_results_dictionary),
                         failed_upgrade_iteration=get_failed_iteration_for_node("Upgrade", node,
                                                                                update_results_dictionary),
                         passed_rollback_qty=get_summary_results_for_node("Rollback", node,
                                                                          update_results_dictionary).count("Pass"),
                         failed_rollback_qty=get_summary_results_for_node("Rollback", node,
                                                                          update_results_dictionary).count("Fail"),
                         failed_rollback_iteration=get_failed_iteration_for_node("Rollback", node,
                                                                                 update_results_dictionary)), "info")


def set_delta(delta, bts_reset, rat_to_reset):
    if delta is not None:
        return delta
    admin_connection = get_admin_connection()
    scf.load_scf(robot_var("BACKUP_SCF_DIR"))
    admin.create_delta("delta")
    delta_dir = "/".join([robot_var("LOG_PATH"), robot_var("TEST_NAME")])
    bts_id = admin.get_bts_info(connection=admin_connection)["mrbtsID"]
    if not bts_reset and rat_to_reset is None:
        robot_logger("Delta was not provided. Test will be executed with changing btsName parameter", "warn")
        btsname = scf.get_value_from_scf(dist_name="MRBTS-{}".format(bts_id), p_name="btsName")
        admin.append_parameter_update_to_delta(dist_name="MRBTS-{}".format(bts_id), parameter="btsName",
                                               value="[UUF]_{}".format(btsname), delta_id="delta")
    elif bts_reset and rat_to_reset is None:
        acteapmode_values = ["EAP disabled", "Authenticator initiated mode",
                             "Combined Authenticator initiated mode and Supplicant initiated mode"]
        robot_logger("Delta was not provided. Test will be executed with changing actEAPmode parameter", "warn")
        bts_id = admin.get_bts_info(connection=admin_connection)["mrbtsID"]
        current_acteap_value = scf.get_value_from_scf(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id),
                                                      p_name="actEAPMode")
        acteapmode_values.remove(current_acteap_value)
        admin.append_parameter_update_to_delta(dist_name="MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1".format(bts_id),
                                               parameter="actEAPMode",
                                               value="{}".format(random.choice(acteapmode_values)), delta_id="delta")
    elif rat_to_reset == "NR":
        prepare_nr_rat_delta()
    else:
        raise MissingDeltaPlan("Delta Plan wasn't provided")
    admin.save_delta(target_file_name="{}/delta.json".format(delta_dir), delta_id="delta")
    return admin.get_delta("delta")


def verify_given_rat_reset(rat):
    cell_type = CELL_TYPES[rat.upper()]
    cell_types = ["NRCEL", "LNCEL", "WNCEL", "GNCEL"]
    cell_types.remove(cell_type)
    connection = get_admin_connection()
    verification_result = []
    check_given_rat_cells_disabled(rat, connection)
    robot_logger("Checking if cells not affected by commissioning are enabled", "info")
    for cell_type in cell_types:
        cells_list = admin.get_ids_for_all(class_name=cell_type, connection=connection)
        if cells_list:
            hw_state_check_result = check_hw_state(cell_type, cells_list, connection)
            if hw_state_check_result:
                verification_result.append("\n".join(hw_state_check_result))
    if verification_result:
        raise AssertionError("\n".join(verification_result))
    return True


@robot_kw
def check_given_rat_cells_disabled(rat, connection):
    expected_statuses = {"operationalState": RFRL_STATUSES["operationalState"]["disabled"],
                         "availabilityStatus": RFRL_STATUSES["availabilityStatus"]["offline"]}
    cell_type = CELL_TYPES[rat.upper()]
    cells_list = admin.get_ids_for_all(class_name=cell_type, connection=connection)
    result = []
    robot_logger("Checking if cells for given rat: {} are disabled".format(rat), "info")
    for cell in cells_list:
        cell_name = re.findall("{}.*".format(cell_type), cell)[0]
        try:
            cell_status = admin.get_parameters(cell, connection=connection)["stateInfo"]
        except KeyError:
            cell_status = admin.get_parameters(cell, connection=connection)
        for status in expected_statuses:
            if status in cell_status:
                if not cell_status[status] in expected_statuses[status]:
                    result.append(("{0} {1} should be {2}. Current object {1} is {3}".format(cell_name, status,
                                                                                             expected_statuses[status],
                                                                                             cell_status[status], )))
    return result


def prepare_nr_rat_delta():
    admin_connection = get_admin_connection()
    nrbts_id = admin.get_id_for_current("NRBTS", connection=admin_connection).rsplit("-", 1)[1]
    mrbts_id = admin.get_bts_info(connection=admin_connection)["mrbtsID"]
    actipthpt = ["true", "false"]
    robot_logger("Delta was not provided. Test will be executed with changing actIpThpt parameter", "warn")
    current_actipthpt_value = scf.get_value_from_scf(dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
                                                     p_name="actIpThpt")
    actipthpt.remove(current_actipthpt_value.lower())
    admin.append_parameter_update_to_delta(dist_name="MRBTS-{}/NRBTS-{}".format(mrbts_id, nrbts_id),
                                           parameter="actIpThpt", value=actipthpt[0], delta_id="delta")


def get_rmods_eligible_for_reset():
    admin_connection = get_admin_connection()
    list_of_rmods = admin.get_bts_info(connection=admin_connection)["radioModules"]["rmod"]
    rmods_eligible_for_reset = [rmod["id"]["internal"] for rmod in list_of_rmods if
                                not check_if_rmod_shared_and_on_slave(rmod["id"]["configuration"])]
    if not rmods_eligible_for_reset:
        robot_logger("No RMOD eligible for reset can be found.", "error")
        BuiltIn().fatal_error("No RMOD eligible for reset can be found.\nTest will be stopped")
    return rmods_eligible_for_reset


def check_if_rmod_shared_and_on_slave(rmod_distname):
    scf.load_scf(robot_var("BACKUP_SCF_DIR"))
    try:
        radiomasterdn_value = scf.get_value_from_scf(dist_name=rmod_distname, p_name="radioMasterDN")
    except KeyError:
        return False
    return True if "SMOD_EXT" in radiomasterdn_value else False


def extend_critical_faults_list(custom_critical_faults):
    critical_faults = ["10", "1806", "4341", "4352", "4383"]
    if not isinstance(custom_critical_faults, list):
        custom_critical_faults = [alarm for alarm in custom_critical_faults.split(",")]
    for fault in custom_critical_faults:
        if str(fault) not in critical_faults:
            critical_faults.append(str(fault))
    set_robot_test_variable("CRITICAL_FAULTS", critical_faults)


def stop_and_fix_procedure():
    cm_execution_id = os.environ.get("CM_EXECUTION_ID")
    if cm_execution_id is not None:
        if "stop_fix_reported" not in globals():
            send_ute_stop_fix_cmd()
            BuiltIn().sleep("24 hours", reason="Stop and Fix error detected. Waiting for manual logs gathering")
    BuiltIn().fatal_error("Stop and Fix procedure triggered! Aborting test execution.")


@robot_kw
def send_ute_stop_fix_cmd():
    robot_logger("Stop and Fix error detected. Triggering 24 Hours sleep for manual log collection", "error")
    command = 'echo "put /opt/ute/execution.context.json ${CM_EXECUTION_ID}.json" |' \
              ' cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
    subprocess.call(command, shell=True)
    global stop_fix_reported
    stop_fix_reported = True
    time.sleep(10)


def get_local_mplane_from_scf_and_set_as_test_variable():
    scf.load_scf(robot_var("BACKUP_SCF_DIR"))
    mplane_distname = scf.get_all_values_from_scf_by_pattern(p_name="mPlaneIpv4AddressDN")
    if not mplane_distname:
        mplane_distname = scf.get_all_values_from_scf_by_pattern(p_name="mPlaneIpv6AddressDN")
    mplane = scf.get_value_from_scf(dist_name=mplane_distname[0], p_name="localIpAddr")
    set_robot_test_variable("LOCAL_MPLANE", mplane)


@robot_kw
def check_if_lmp_is_pingable(remote=False):
    if remote:
        enb_session = jumpssh.SSHSession(robot_var("REMOTE_VM_IP"), missing_host_key_policy=paramiko.AutoAddPolicy(),
                                         username="ute").open()
        ping_output = enb_session.get_cmd_output("ping -c 10 192.168.255.1")
        enb_session.close()
    else:
        ping_output = six.ensure_text(subprocess.check_output("ping -c 10 192.168.255.1", shell=True))
    if "10 received" in ping_output:
        return True
    robot_logger("LMP Address for {} Node is not pingable".format("Local" if not remote else "Remote"), "error")
    return False


@robot_kw
def check_if_mplane_pingable(remote=False):
    ping_output = six.ensure_text(
        subprocess.check_output("ping -c 10 {}".format(robot_var("LOCAL_MPLANE" if not remote else "REMOTE_MPLANE")),
                                shell=True))
    if "10 received" in ping_output:
        return True
    robot_logger("Mplane {} is not pingable".format(robot_var("LOCAL_MPLANE" if not remote else "REMOTE_MPLANE")),
                 "error")
    return False


@robot_kw
def check_if_any_critical_fault_active(remote=False):
    admin_connection = get_admin_connection(remote)
    active_alarms_list = admin.get_active_alarms(connection=admin_connection)
    critical_faults = robot_var("CRITICAL_FAULTS")
    detected_critical_faults = [fault_id for alarm in active_alarms_list for fault_id in critical_faults if
                                str(fault_id) == str(alarm["faultId"])]
    if detected_critical_faults:
        robot_logger("Detected Active Critical Fault on {} node!"
                     " Detected Faults : {}".format("Local" if not remote else "Remote", detected_critical_faults),
                     "error")
        return False

    return True


@robot_kw
def verify_stop_fix_post_test_checks(remote=False):
    results = {"Critical Fault Check": "Passed" if check_if_any_critical_fault_active(remote) else "Failed",
               "Modules Status Check": "Passed" if verify_modules_status(remote) else "Failed",
               "LMP is pingable Check": "Passed" if check_if_lmp_is_pingable(remote) else "Failed",
               "Mplane Admin Connection": "Passed" if check_admin_connection_via_mplane(remote) else "Failed",
               "Critical Fault Check During Test": "Passed" if check_critical_alarms_during_test(remote) else "Failed"}
    return results


@robot_kw
def check_critical_alarms_during_test(remote):
    return robot_var("CRITICAL_FAULT_STATUS_{}".format("REMOTE" if remote else "LOCAL"))


@robot_kw
def check_stop_fix_trigger():
    remote_node_check = True if robot_var("REMOTE_NODE_VM_IP") and robot_var("USE_REMOTE_NODE") else False
    stop_fix_results = {"Local Node Results": verify_stop_fix_post_test_checks(remote=False)}
    if remote_node_check:
        stop_fix_results["Remote Node Results"] = verify_stop_fix_post_test_checks(remote=True)
    for node, check_result in stop_fix_results.items():
        if not all(result == "Passed" for result in check_result.values()):
            set_robot_suite_variable("STOP_FIX", True)
    if robot_var("STOP_FIX"):
        robot_logger("Stop and Fix Verification FAILED!"
                     "\nVerification Results : {}".format(json.dumps(stop_fix_results, indent=4)), "error")


@robot_kw
def check_admin_connection_via_mplane(remote=False):
    try:
        admin.setup_admin(bts_host=robot_var("LOCAL_MPLANE" if not remote else "REMOTE_MPLANE"),
                          alias="{}_mplane".format("local" if not remote else "remote"), timeout=60)
        admin.teardown_admin(alias="{}_mplane".format("local" if not remote else "remote"))
        return True
    except Exception as admin_exception:
        robot_logger("Admin Session Setup failed for Mplane: {}".format(
            robot_var("LOCAL_MPLANE" if not remote else "REMOTE_MPLANE")), "error")
        robot_logger(admin_exception, "debug")
        return False


@robot_kw
def get_bts_modules(admin_connection):
    info = admin.get_bts_info(connection=admin_connection)
    modules = {module_type: get_modules_info_per_id(modules) for module_type, modules in info.items()
               if module_type in HARDWARE_TO_CHECK}
    modules["radioModules"] = get_modules_info_per_id(get_radio_modules_list(info))
    return modules


@robot_kw
def get_modules_info_per_id(modules_list):
    modules_info_per_id = {
        module["id"]["configuration"]: {"Serial Number": module.get("serialNumber", "N/A"), "Status": module["status"]}
        for module in modules_list}
    return modules_info_per_id


@robot_kw
def get_radio_modules_list(bts_info):
    rmods_list = bts_info["radioModules"].get("rmod", [])
    asirmod_list = bts_info["radioModules"].get("asirmod", [])
    return rmods_list + asirmod_list


@robot_kw
def check_single_object_state(module_info):
    expected_statuses = {"operationalState": RFRL_STATUSES["operationalState"]["enabled"],
                         "availabilityStatus": RFRL_STATUSES["availabilityStatus"]["online"],
                         "proceduralStatus": RFRL_STATUSES["proceduralStatus"]["configured"], }
    status_check = {status: bool(module_info["Status"][status] in expected_statuses[status]) for status in
                    expected_statuses.keys() if status in module_info["Status"].keys()}
    return status_check


@robot_kw
def check_bts_objects_state(object_dict):
    modules_state_check = {
        module_type: {module: check_single_object_state(module_info) for module, module_info in modules.items()} for
        module_type, modules in object_dict.items()}
    failed_objects = []
    for modules in modules_state_check.values():
        for module, check_result in modules.items():
            if any(not result for result in check_result.values()):
                failed_objects.append("{} State not as expected.\nCurrent state\n{}\n".
                                      format(module, json.dumps(get_object_state(object_dict, module), indent=4)))

    return failed_objects


@robot_kw
def check_missing_module(initial_modules, after_test_modules_dict):
    missing_modules = [{module: module_info} for module_type in initial_modules.keys() for module, module_info in
                       initial_modules[module_type].items() if
                       module not in after_test_modules_dict[module_type].keys()]
    missing_modules_list = []
    if missing_modules:
        for module in missing_modules:
            module_id = list(module.keys())[0]
            missing_modules_list.append(
                "Missing Module {} with Serial Number : {}\n".format(module_id, module[module_id]["Serial Number"]))
    return missing_modules_list


@robot_kw
def get_object_state(objects_dict, object_distname):
    for objects in objects_dict.values():
        if object_distname in objects.keys():
            return objects[object_distname]["Status"]


@robot_kw
def verify_modules_status(remote=False):
    admin_connection = get_admin_connection(remote)
    modules = get_bts_modules(admin_connection)
    missing_module_check = check_missing_module(
        robot_var("INITIAL_{}_MODULES".format("LOCAL" if not remote else "REMOTE")), modules)
    if missing_module_check:
        robot_logger("\n".join(missing_module_check), "error")
    failed_modules_state_check = check_bts_objects_state(modules)
    if failed_modules_state_check:
        robot_logger("\n".join(failed_modules_state_check), "error")
    return bool(not missing_module_check and not failed_modules_state_check)


def set_initial_modules_variable(remote=False):
    initial_bts_modules = get_bts_modules(get_admin_connection(remote))
    set_robot_test_variable("INITIAL_{}_MODULES".format("LOCAL" if not remote else "REMOTE"), initial_bts_modules)
    return initial_bts_modules


@robot_kw
def verify_missing_modules(remote=False):
    admin_connection = get_admin_connection(remote)
    modules = get_bts_modules(admin_connection)
    missing_module_check = check_missing_module(
        robot_var("INITIAL_{}_MODULES".format("LOCAL" if not remote else "REMOTE")), modules)
    return missing_module_check


def get_cells_per_config_id(admin_connection):
    cells = {
        rat: {cell_info["id"].get("configuration", cell_info["id"].get("internal")): {"Status": cell_info.get("status")}
              for cell_info in cells} for rat, cells in
        admin.get_bts_info(connection=admin_connection).get("cells", {}).items()}
    return cells


@robot_kw
def verify_bts_state(remote=False, cells_check=False):
    admin_connection = get_admin_connection(remote)
    wait_until_all_initial_modules_detected(admin_connection, remote)
    objects_to_check = get_bts_modules(admin_connection)
    if cells_check:
        objects_to_check.update(get_cells_per_config_id(admin_connection))
    failed_objects = check_bts_objects_state(objects_to_check)
    if failed_objects:
        raise WrongBtsState("\n".join(failed_objects))
    return True


@robot_kw
def wait_until_all_initial_modules_detected(admin_connection, remote):
    modules = get_bts_modules(admin_connection)
    missing_module_check = check_missing_module(
        robot_var("INITIAL_{}_MODULES".format("LOCAL" if not remote else "REMOTE")), modules)
    if missing_module_check:
        raise WrongBtsState("\n".join(missing_module_check))
    return True


def get_cells(admin_connection):
    cells = [cell for rat, cells_list in admin.get_cell_list(connection=admin_connection)["cells"].items() for cell in
             cells_list]
    return cells


@robot_kw
def verify_cells_status(remote=False):
    admin_connection = get_admin_connection(remote)
    cells = get_cells(admin_connection)
    verification_result = ["\n".join(check_cell_status(cell)) for cell in cells if check_cell_status(cell)]
    if verification_result:
        raise Exception(verification_result)


def check_cell_status(cell_info):
    expected_statuses = {"operationalState": RFRL_STATUSES["operationalState"]["enabled"],
                         "availabilityStatus": RFRL_STATUSES["availabilityStatus"]["online"],
                         "administrativeState": RFRL_STATUSES["administrativeState"]["unlocked"], }
    check_result = []
    for status in expected_statuses.keys():
        if status in cell_info["status"]:
            if cell_info["status"][status] not in expected_statuses[status]:
                check_result.append(("{0} {1} should be {2}. Current object {1} is {3}".format(
                    cell_info["id"]["configuration"], status, expected_statuses[status], cell_info["status"][status])))
    return check_result


@robot_kw
def verify_cells_before_attach_test(remote=False):
    wait_until_kw_succeeds("120 times", 10, verify_cells_status, remote)


def evaluate_if_attach_in_scope():
    local_attach_test = robot_var("ATTACH_TEST_KEYWORD")
    if local_attach_test is not None:
        return True
    return False


@robot_kw
def get_dependent_cells_for_attach_test(object_used_in_test):
    admin_connection = get_admin_connection()
    bts_info = admin.get_bts_info(connection=admin_connection)
    cells = get_dependent_cells(bts_info, object_used_in_test)
    return cells


def change_target_sw_for_rat(rat):
    iterator = robot_var("{}_SW_ITERATOR".format(rat))
    initial_sw = robot_var("{}_TARGET_SW".format(rat))
    next_sw_details = next(iterator)
    update_dict = robot_var("UPDATE_TEST_VARIABLES")
    for bts_dict in update_dict.values():
        if initial_sw in bts_dict["target_sw"]:
            bts_dict["target_sw"] = next_sw_details[0]
            bts_dict["target_sw_path"] = next_sw_details[1]


def update_target_sw_variable():
    if robot_variable_exist("5G_SW_ITERATOR"):
        change_target_sw_for_rat("5G")
    if robot_variable_exist("4G_SW_ITERATOR"):
        change_target_sw_for_rat("4G")


def set_report_sw():
    if robot_var("4G_TARGET_SW") is not None and robot_var("5G_TARGET_SW") is None:
        set_robot_test_variable("REPORT_SW", robot_var("4G_TARGET_SW"))
    else:
        set_robot_test_variable("REPORT_SW", robot_var("5G_TARGET_SW"))
