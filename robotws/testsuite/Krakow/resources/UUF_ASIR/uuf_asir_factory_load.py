"""
:Author: Jakub Siluch
:maintainer: Jakub Siluch
:Contact: jakub.siluch@nokia.com
"""

from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from moler.device import DeviceFactory
from robot.libraries.BuiltIn import BuiltIn
import taf.ul.sc.tl_config as tl_config
from taf.ul.moler.converter.moler_converter import MolerConverter
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration, get_devices_from_regex
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.transfer_files import upload_files
import time
from taf.ul.sc.perf.wft.wft_downloader import WFTDownloader
import re


class uuf_asir_factory_load(object):

    def __init__(self, hubs_prefix="HUB", dest_bts_path="/ffs/run/"):
        self.smod_devices = [device for device in get_devices_from_regex(pattern=r'GNB0_DU0_CU\d+$')]
        self.hubs_prefix = hubs_prefix
        self.dest_bts_path = dest_bts_path
        self.hub_devices = []

    def set_hub_prefix(self, prefix):
        self.hubs_prefix = prefix

    def get_hub_devices_from_prefix(self):
        self.hub_devices = [device for device in get_devices_from_regex(pattern=r'{}\d+$'.format(self.hubs_prefix))]

    def create_devices_if_not_defined(self):
        self.get_hub_devices_from_prefix()
        if not self.hub_devices:
            hubs_info = BuiltIn().run_keyword("create_hub_devices")
        else:
            hubs_info = self.get_hubs_info()
            hubs_info = {j: hubs_info[i][j] for i in list(hubs_info) for j in list(hubs_info[i])}
        return hubs_info

    @load_moler_configuration_from_tl()
    def create_hub_devices(self):
        mc = MolerConverter()
        all_devices = mc.moler_devices.get_moler_device_config()['DEVICES']
        hub_number = 0
        hubs_info = self.get_hubs_info()
        for ip in list(hubs_info["master"]):
            hub_device_name = "{}{}".format(self.hubs_prefix, hub_number)
            mc.moler_devices. \
                add_ru_configuration(hub_device_name, ip, "toor4nsn", "oZPS0POrRieRtu",
                                     proxy_pc_host=tl_config.tl.test_pc.default_ssh_connection_details.addr,
                                     proxy_pc_login=tl_config.tl.test_pc.default_ssh_connection_details.username,
                                     proxy_pc_password=tl_config.tl.test_pc.default_ssh_connection_details.password,
                                     bts_host="192.168.255.129", bts_login="toor4nsn", bts_password="oZPS0POrRieRtu")
            self.hub_devices.append(hub_device_name)
            hub_number += 1
        if len(list(hubs_info)) > 1:
            secondary_smod_ip = tl_config.tl.gnbs[0].dus[0].airscale.common_units[1].lmp_connection.addr
            if secondary_smod_ip == "192.168.253.16":
                secondary_smod_prompt = "root@fct-0a"
                bts_prompt = "root@fct-4a"
            else:
                secondary_smod_prompt = "root@fct-4a"
                bts_prompt = "root@fct-0a"
            for ip in list(hubs_info["secondary"]):
                hub_device_name = "{}{}".format(self.hubs_prefix, hub_number)
                mc.moler_devices. \
                    add_ru_configuration(hub_device_name, ip, "toor4nsn", "oZPS0POrRieRtu",
                                         proxy_pc_host=tl_config.tl.test_pc.default_ssh_connection_details.addr,
                                         proxy_pc_login=tl_config.tl.test_pc.default_ssh_connection_details.username,
                                         proxy_pc_password=tl_config.tl.test_pc.default_ssh_connection_details.password,
                                         bts_host="192.168.255.129", bts_login="toor4nsn",
                                         bts_password="oZPS0POrRieRtu",
                                         secondary_smod_host=secondary_smod_ip, secondary_smod_login="toor4nsn",
                                         secondary_smod_password="oZPS0POrRieRtu", bts_prompt=bts_prompt,
                                         secondary_smod_prompt=secondary_smod_prompt)
                self.hub_devices.append(hub_device_name)
                hub_number += 1
        add_device_to_already_loaded_configuration(config=all_devices)
        return {j: hubs_info[i][j] for i in list(hubs_info) for j in list(hubs_info[i])}

    def scp_builds_to_smods(self, builds_dir, builds_path="/home/ute/UUF_SW/"):
        for smod_device_name in self.smod_devices:
            for hub_type in list(builds_dir):
                upload_files(builds_path, builds_dir[hub_type], smod_device_name, self.dest_bts_path, timeout=300)

    def scp_builds_to_hubs(self, builds_dir, hubs_info):
        operations = []
        for hub_device_name in self.hub_devices:
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="FHNET")
            hub_build_file_name = builds_dir[hubs_info[device.ru_ip_address]]
            arguments = {"source": "{}{}".format(self.dest_bts_path, hub_build_file_name),
                         "dest": "toor4nsn@{}:/tmp/".format(device.ru_ip_address), "password": "oZPS0POrRieRtu"}
            cmd = device.get_cmd(cmd_name='scp', cmd_params=arguments, check_state=False)
            cmd.start(timeout=300)
            operations.append(cmd)
        for operation in operations:
            operation.await_done(timeout=300)

    def delete_hub_builds_files(self, builds_dir):
        for smod_device_name in self.smod_devices:
            device = DeviceFactory.get_device(name=smod_device_name, initial_state="FCT")
            for build in list(builds_dir):
                device.get_cmd(cmd_name='rm', cmd_params={"file": self.dest_bts_path + builds_dir[build]})()

    def delete_ssh_known_file(self):
        for smod_device_name in self.smod_devices:
            device = DeviceFactory.get_device(name=smod_device_name, initial_state="FHNET")
            device.get_cmd(cmd_name='rm', cmd_params={"file": "/user/toor4nsn/.ssh/known_hosts"})()

    def run_factory_load(self, builds_dict, hubs_number_from_hw=None):
        hubs_info = self.create_devices_if_not_defined()
        if hubs_number_from_hw:
            if int(hubs_number_from_hw) != len(self.hub_devices):
                raise Exception("BAD HUB NUMBER")
        BuiltIn().run_keyword_and_ignore_error("delete_ssh_known_file")
        log_info_to_console("Copying builds to HUBs")
        BuiltIn().run_keyword("scp_builds_to_hubs", builds_dict, hubs_info)
        log_info_to_console("Factory Load HUBs")
        BuiltIn().run_keyword("execute_swman_on_all_hubs", builds_dict, hubs_info, "build_save")
        BuiltIn().run_keyword("execute_swman_on_all_hubs", builds_dict, hubs_info, "build_activate")
        log_info_to_console("Reboot HUBs")
        uptime_dict = BuiltIn().run_keyword("reboot_all_hubs")
        log_info_to_console("Waiting for HUBs are available")
        BuiltIn().run_keyword("wait_until_all_hubs_available")
        BuiltIn().run_keyword("check_if_all_hubs_rebooted", uptime_dict)
        log_info_to_console("Verify build change on HUBs")
        BuiltIn().run_keyword("verify_build_change_after_factory_load", builds_dict, hubs_info)

    def verify_build_change_after_factory_load(self, builds_dir, hubs_info):
        for hub_device_name in self.hub_devices:
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="RU")
            build_info = device.get_cmd(cmd_name="swman_shell_command", cmd_params={"options": "-i"})()
            hub_build_file_name = builds_dir[hubs_info[device.ru_ip_address]]
            self.check_factory_load_build(build_info, file_name=hub_build_file_name)

    def verify_build_hub_change_after_bts_upgrade(self, enb_build):
        self.create_devices_if_not_defined()
        build_info = WFTDownloader().get_build_info(enb_build)
        builds = [build.split("version: ")[-1].strip() for build in
                  build_info['custom_config_spec'].strip().split("\n") if "version:" in build]
        active_builds = []
        for hub_device_name in self.hub_devices:
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="RU")
            active_build = device.get_cmd(cmd_name="swman_shell_command", cmd_params={"options": "-i"})()
            active_builds.append(active_build["Current runningBuildName"])
        if all(build in builds for build in set(active_builds)) is False:
            raise Exception("Bad build on HUB")

    def reboot_all_hubs(self):
        commands = []
        uptime_dict = {}
        for hub_device_name in self.hub_devices:
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="RU")
            cmd = device.get_cmd(cmd_name="reboot", check_state=False)
            commands.append(cmd)
            uptime_dict[device.ru_ip_address] = device.get_cmd(cmd_name='uptime')()["UPTIME_SECONDS"]
        for cmd in commands:
            cmd.start()
        time.sleep(13)
        return uptime_dict

    def wait_until_all_hubs_available(self, wait_until_proper_state=15):
        time.sleep(wait_until_proper_state)
        for hub_device_name in self.hub_devices:
            start_time = time.time()
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="FHNET")
            while time.time() - start_time < 600:
                packets = device.get_cmd(cmd_name="ping", cmd_params={'destination': device.ru_ip_address,
                                                                      'options': '-w {}'.format(1)})()
                if int(packets["packet_loss"]) == 0:
                    break
                else:
                    time.sleep(10)
            else:
                raise Exception("HUB {} OFFLINE".format(device.ru_ip_address))

    def check_if_all_hubs_rebooted(self, uptime_dict):
        for hub_device_name in self.hub_devices:
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="RU")
            if device.get_cmd(cmd_name='uptime')()["UPTIME_SECONDS"] > uptime_dict[device.ru_ip_address]:
                device.get_cmd(cmd_name="reboot")()
                time.sleep(13)
                self.wait_until_all_hubs_available()

    def execute_swman_on_all_hubs(self, builds_dir, hubs_info, params_index):
        operations = []
        for hub_device_name in self.hub_devices:
            device = DeviceFactory.get_device(name=hub_device_name, initial_state="RU")
            hub_build_file_name = builds_dir[hubs_info[device.ru_ip_address]]
            params = self.prepare_param_for_factory_load(hub_build_file_name)
            operation = device.get_cmd(cmd_name="swman_shell_command", cmd_params={"options": params[params_index]},
                                       check_state=False)
            operation.start(timeout=720)
            operations.append(operation)
        for operation in operations:
            operation.await_done(timeout=720)

    def get_hubs_info(self):
        hubs_devices = {}
        master_smod = DeviceFactory.get_device(name=self.smod_devices[0])
        hubs_devices["master"] = self.get_hubs_type_and_ips(master_smod)
        if len(self.smod_devices) > 1:
            secondary_smod = DeviceFactory.get_device(name=self.smod_devices[1])
            hubs_devices["secondary"] = self.get_hubs_type_and_ips(secondary_smod)
        return hubs_devices

    @staticmethod
    def check_factory_load_build(build_info, build_version=None, file_name=None):
        if build_version:
            if build_version != build_info["activeBuildVersion"]:
                raise Exception("Bad build version")
        elif file_name:
            for i in range(1, 3):
                if "active" in str(build_info["File"][str(i)]["usage"]):
                    if file_name != build_info["File"][str(i)]["name"]:
                        raise Exception("Bad build version")
                    else:
                        return
            else:
                raise Exception("No active build")

    @staticmethod
    def prepare_param_for_factory_load(hub_factory_load):
        file_version = hub_factory_load.replace('.tgz', '').split('_')[-1]
        build_version = 'LTX_APHG' if hub_factory_load.split('-')[0] == 'fzhub2' else 'LTX_APHA'
        param_list = {"build_save": "-s /tmp/{} {}".format(hub_factory_load, file_version),
                      "build_activate": "-a {} {} {} {}".format(build_version, hub_factory_load.split(".")[0],
                                                                hub_factory_load, file_version)}
        return param_list

    @staticmethod
    def get_hubs_type_and_ips(connection, wanted_state="FHNET"):
        hubs = {}
        connection.goto_state(state=wanted_state, rerun=3)
        cat = connection.get_cmd(cmd_name='cat', cmd_params={'path': "/rom/config/FRIps.txt"})
        for line in cat()['LINES']:
            ip = re.findall(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}', line)[0]
            hub_type = line.split(";")[-1]
            if ip == "0.0.0.0" or "ping" in line:
                continue
            packets = connection.get_cmd(cmd_name="ping", cmd_params={'destination': ip, 'options': '-w 1'})()
            if int(packets["packet_loss"]) != 0:
                continue
            hubs[ip] = hub_type
        return hubs
