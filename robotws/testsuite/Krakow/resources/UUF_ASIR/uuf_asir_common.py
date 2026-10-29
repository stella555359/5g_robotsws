"""
:Author: Jakub Siluch
:maintainer: Jakub Siluch
:Contact: jakub.siluch@nokia.com
"""

from taf.rfrl.uuf4all.resources.python.uuf_rfrl_common import *
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_update import uuf_rfrl_update
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.ul.sc.perf.wft.interface import wft
from robot.libraries.BuiltIn import BuiltIn
from moler.device import DeviceFactory
import time
import os
import logging


def get_rmods_and_hubs(bts_info):
    rus_list = [str(ru["productName"]) for ru in bts_info["radioModules"]["rmod"]]
    if not rus_list:
        rus_list = [str(ru["productName"]) for ru in bts_info["radioModules"]["asirmod"]]
    else:
        asir_list = [str(ru["productName"]) for ru in bts_info["radioModules"]["asirmod"]]
        rus_list.extend(asir_list)
    return get_hw_count(rus_list)


def get_number_of_hubs_from_hw_conf(hw_conf):
    hub_number = 0
    hw_conf_split = hw_conf.split("+")
    for sub_conf in hw_conf_split:
        hub_number += int(sub_conf[0])
    return hub_number


def check_number_of_fault_23_on_hubs(active_alarms, expected_number):
    alarms = []
    for alarm in active_alarms:
        if int(alarm["faultId"]) == 23:
            alarms.append(alarm["configObjectName"])
    if len(set(alarms)) != int(expected_number):
        raise Exception("Fault 23 number: {}, should be {}".format(len(set(alarms)), expected_number))


def check_if_alarm_exists_in_alarm_history(historical_alarms):
    for alarm in historical_alarms:
        if int(alarm["faultId"]) == 23:
            return
    else:
        raise Exception("There is no faultId 23 in alarm history")


def download_hub_build(hub_build_version, dest_build_path, proxy):
    wft_object = wft()
    wft_object.set_proxies({'https': str(proxy)})
    hub_build_filename = wft_object.download_hub_build_from_wft(hub_build_version, destination_path=dest_build_path)
    return hub_build_filename


def prepare_hub_builds(builds_dict, proxy, dest_build_path="/home/ute/UUF_SW/"):
    for hub_type in list(builds_dict):
        hub_build_filename = download_hub_build(builds_dict[hub_type], dest_build_path, proxy)
        builds_dict[hub_type] = hub_build_filename


def download_all_needed_builds(source_builds, target_build, builds_dict, proxy, dest_builds_path="/home/ute/UUF_SW/"):
    enb_builds = list(source_builds)
    enb_builds.append(target_build)
    hub_builds = [builds_dict[version] for version in list(builds_dict)]
    build_filenames = {}
    for build in enb_builds:
        build_filename = uuf_rfrl_update().download_package(sw_version=build, use_builds_storage=False).strip()
        build_filenames[build_filename] = os.stat(build_filename).st_size
    for build in hub_builds:
        build_filename = dest_builds_path + download_hub_build(build, dest_builds_path, proxy)
        build_filenames[build_filename] = os.stat(build_filename).st_size
    check_if_build_if_properly_downloaded(build_filenames)


def check_if_build_if_properly_downloaded(build_filenames, download_timeout=3600):
    start_time = time.time()
    while time.time() - start_time < download_timeout:
        for file in list(build_filenames):
            actual_file_size = os.stat(file).st_size
            if build_filenames[file] < actual_file_size:
                build_filenames[file] = actual_file_size
                break
        else:
            break
        time.sleep(15)
    verify_builds_size(build_filenames)


def verify_builds_size(buld_filenames, hub_build_min_size_mb=100, enb_build_min_siz_mb=4000):
    for file in list(buld_filenames):
        if "fzhub" in file:
            if int(os.stat(file).st_size) < 1000000 * hub_build_min_size_mb:
                os.remove(file)
        else:
            if int(os.stat(file).st_size) < 1000000 * enb_build_min_siz_mb:
                os.remove(file)


def mount_disk_with_autofs(disk_path, password):
    device = DeviceFactory.get_device(name='UnixLocal')
    device.goto_state("UNIX_LOCAL_ROOT")
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "apt-get -y install ute-config-repo"})()
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "apt-get update"})()
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "apt-get -y install autofs"})()
    file_content = device.get_cmd(cmd_name='cat', cmd_params={'path': "/etc/auto.master"})()
    if "/- /etc/auto.server --timeout=60 browse" not in file_content["LINES"]:
        device.get_cmd(cmd_name='run_script',
                       cmd_params={"script_command": "echo ''/- /etc/auto.server        --timeout=60    browse'' "
                                                     ">>/etc/auto.master"})()
    device.get_cmd(cmd_name='run_script',
                   cmd_params={"script_command": "echo ''{}   -fstype=cifs,user=factory-builds,password={},"
                                                 "uid=1000,forceuid,gid=1000,forcegid  "
                                                 "://10.83.200.250/projectVol2/factory-builds'' "
                                                 "> /etc/auto.server".format(disk_path, password)})()
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "systemctl restart autofs"})()
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "systemctl enable autofs"})()
    device.goto_state("UNIX_LOCAL")


def disable_autofs():
    device = DeviceFactory.get_device(name='UnixLocal')
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "sudo systemctl disable autofs --now"})()


def mount_disk_without_autofs(disk_path, password):
    device = DeviceFactory.get_device(name='UnixLocal')
    if os.path.exists(disk_path) is False:
        os.mkdir(disk_path)
    device.get_cmd(cmd_name='run_script',
                   cmd_params={"script_command": "sudo mount -t cifs -o user=factory-builds,password={},uid=$UID,"
                                                 "gid=$(id -g) //10.83.200.250/projectVol2/factory-builds "
                                                 "{}".format(password, disk_path)})()


def unmount_disk_without_autofs(disk_path):
    device = DeviceFactory.get_device(name='UnixLocal')
    device.get_cmd(cmd_name='run_script', cmd_params={"script_command": "sudo umount {}".format(disk_path)})()


def check_if_disk_properly_mounted(path):
    if os.path.exists(path) is True:
        if len(os.listdir(path)) != 0:
            return True
    return False


def prepare_build_disk(password, disk_path):
    mount_disk_with_autofs(disk_path, password)
    if check_if_disk_properly_mounted(disk_path) is False:
        mount_disk_without_autofs(disk_path, password)
        if check_if_disk_properly_mounted(disk_path) is False:
            logging.warn("DISK NOT MOUNTED")


def change_string_to_list(string, separator="__", variable_name="@{SOURCE_ENB_BUILDS}"):
    if type(string) == str:
        converted_string = string.split(separator)
        BuiltIn().set_suite_variable("{}".format(variable_name), *converted_string)


def change_string_to_dict(string, separator="__", variable_name="&{HUBS_BUILDS}"):
    if type(string) == str:
        converted_string = string.split(separator)
        BuiltIn().set_suite_variable("{}".format(variable_name), *converted_string)


def known_issue_fix(current_build, correction_build, critical_faults, cna_fault):
    if not (SbtsSwVersion(str(current_build)) >= SbtsSwVersion(str(correction_build))):
        if str(cna_fault) in critical_faults:
            critical_faults.remove(str(cna_fault))
    elif str(cna_fault) not in critical_faults:
        critical_faults.append(str(cna_fault))
    return critical_faults
