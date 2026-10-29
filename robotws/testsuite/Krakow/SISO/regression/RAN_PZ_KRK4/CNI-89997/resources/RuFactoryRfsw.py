from taf.internal.sbts.admin.exceptions import AdminApiConnectionClosedException, AdminApiProcedureFailureException
from taf.rfrl.bts.connections.device_aliases import ssh_bts_du, ssh_bts_du_ru, ssh_cu_unit
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory, SbtsSwVersion
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.utilities.transfer_files import upload_files
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.settings import WFT_ACCESS_KEY
from taf.ul.sc.perf.wft.wft_downloader import WFTDownloader
from taf.ul.moler.converter.moler_converter import MolerConverter
from taf.ul.moler.converter.interface import add_device_to_already_loaded_configuration
from moler.util.moler_test import MolerTest
from moler.exceptions import WrongUsage
from moler.device import DeviceFactory
from robot.libraries.BuiltIn import BuiltIn
import os
import re


class RuFactoryRfsw(object):
    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.log_path = get_builtin_value('LOG_PATH')
        self.gnb_alarm = GnbAlarmVerification()
        self.gnb_du = GnbDuOperations()
        self.current_ru_ipaddr = None

    def _get_ru_object(self, gnb_id=0, du_id=0, ru_id=0, common_unit_id=0, capacity_unit_id=0):
        ru = self.tl.gnbs[gnb_id].dus[du_id].airscale.common_units[common_unit_id].capacity_units[
            capacity_unit_id].rus[ru_id]
        return ru

    def _get_ru_ipaddr(self, gnb_id=0, du_id=0, ru_id=0, common_unit_id=0, capacity_unit_id=0):
        ru_ipaddr = None
        ru_object = self._get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id, common_unit_id=common_unit_id,
                                        capacity_unit_id=capacity_unit_id)
        ru_name = ru_object.radio_type
        ru_serial = ru_object.serial_number
        pattern_ru_addr = re.compile(r'(\d+\.\d+\.\d+\.\d+);{};{}'.format(ru_serial, ru_name))
        device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", gnb_id, du_id), initial_state='FCT')
        rus_info = device.get_cmd(cmd_name='cat',
                                  cmd_params={"path": "/rom/config/FRIps.txt"})()['LINES']
        for ru_info in rus_info:
            match_ipaddr = re.search(pattern_ru_addr, ru_info)
            if match_ipaddr:
                ru_ipaddr = match_ipaddr.group(1)
                MolerTest.info("Found ip address of '{}' RU with serial number '{}': '{}'"
                               "".format(ru_name, ru_serial, ru_ipaddr))
                self.current_ru_ipaddr = ru_ipaddr
                return ru_ipaddr
        if not ru_ipaddr:
            MolerTest.error("Not found ip address of '{}' RU with serial number '{}' in '/rom/config/FRIps.txt'"
                            "".format(ru_name, ru_serial), raise_exception=True)

    @load_moler_configuration_from_tl()
    def load_ru_device(self, factory_device=True, gnb_id=0, du_id=0, ru_id=0, common_unit_id=0, capacity_unit_id=0):
        if factory_device:
            factory_rfsw_credentials = get_builtin_value("factory_rfsw_credentials")
        else:
            factory_rfsw_credentials = None
        ru_address = self._get_ru_ipaddr(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id, common_unit_id=common_unit_id,
                                         capacity_unit_id=capacity_unit_id)
        ru_object = self._get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id, common_unit_id=common_unit_id,
                                        capacity_unit_id=capacity_unit_id)
        mc = MolerConverter()
        all_devices = mc.moler_devices.get_moler_device_config()['DEVICES']
        mc.moler_devices. \
            add_ru_configuration(device_name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                                                  "{}_{}".format(ru_id,
                                                                                 "FACTORY" if factory_device else
                                                                                 "DEFAULT")),
                                 host=ru_address,
                                 login=factory_rfsw_credentials['username'] if factory_device else
                                 ru_object.default_ssh_connection_details.username,
                                 password=factory_rfsw_credentials['password'] if factory_device else
                                 ru_object.default_ssh_connection_details.password,
                                 proxy_pc_host=self.tl.test_pc.default_ssh_connection_details.addr,
                                 proxy_pc_login=self.tl.test_pc.default_ssh_connection_details.username,
                                 proxy_pc_password=self.tl.test_pc.default_ssh_connection_details.password,
                                 bts_host=self.tl.gnbs[gnb_id].cu.oam_ssh_connection_details.addr,
                                 bts_login=self.tl.gnbs[gnb_id].cu.oam_ssh_connection_details.username,
                                 bts_password=self.tl.gnbs[gnb_id].cu.oam_ssh_connection_details.password)
        try:
            add_device_to_already_loaded_configuration(config=all_devices)
        except WrongUsage:
            device = DeviceFactory.get_device(
                name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                          "{}_{}".format(ru_id, "FACTORY" if factory_device else "DEFAULT")))
            device.ru_ip_address = ru_address

    @staticmethod
    def remove_ssh_known_hosts(gnb_id=0, du_id=0, cu_id=0):
        device = DeviceFactory.get_device(name=ssh_cu_unit.format("GNB", gnb_id, du_id, cu_id), initial_state="FHNET")
        cmd_rm_hosts = device.get_cmd(cmd_name='rm',
                                      cmd_params={"file": "/user/toor4nsn/.ssh/known_hosts",
                                                  "options": "--force"})
        cmd_rm_hosts()

    @load_moler_configuration_from_tl()
    def download_factory_rfws_from_svne1(self, path_rfsw, http_proxy="http://proxy-lab.krk-lab.nsn-rdnet.net:8080",
                                         gnb_id=0, du_id=0, timeout=90):
        device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", gnb_id, du_id), initial_state='PROXY_PC')
        cmd_wget_rfsw = device.get_cmd(
            cmd_name="wget",
            cmd_params={"options": f"-e use_proxy=yes "
                                   f"-e http_proxy={http_proxy} "
                                   f"--user ca_ute_test "
                                   f"--password utetest "
                                   f"--directory-prefix {self.log_path} "
                                   f"http://svne1.ext.net.nokia.com/isource/svnroot/{path_rfsw}"})
        cmd_wget_rfsw(timeout=timeout)

    def upload_factory_rfsw_package_to_ru(self, factory_file_name, gnb_id=0, du_id=0, ru_id=0, timeout=180,
                                          run_on_factory_rfsw=False, common_unit_id=0, capacity_unit_id=0):
        active_sw = self.gnb_du.get_bts_sw_release_name(bts_id=gnb_id, du_id=du_id)
        factory_rfsw_credentials = get_builtin_value("factory_rfsw_credentials")
        ru_object = self._get_ru_object(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id, common_unit_id=common_unit_id,
                                        capacity_unit_id=capacity_unit_id)
        self.load_ru_device(factory_device=run_on_factory_rfsw, gnb_id=gnb_id, du_id=du_id, ru_id=ru_id,
                            common_unit_id=common_unit_id, capacity_unit_id=capacity_unit_id)
        device_type = "FACTORY" if run_on_factory_rfsw else "DEFAULT"
        upload_device_name = ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}_RFSW_UPLOAD".format(ru_id, device_type))
        DeviceFactory.get_cloned_device(
            ssh_bts_du_ru.format("GNB", gnb_id, du_id, "{}_{}".format(ru_id, device_type)), upload_device_name,
            initial_state="PROXY_PC")
        if active_sw == 'SBTS23R3':
            upload_files(local_dir=self.log_path, local_file=factory_file_name,
                         device_name=upload_device_name, remote_dir="/tmp", to_state="RU", timeout=timeout,
                         remove_source_file=False, log_level='error', new_file_name=None)
        else:
            upload_files(local_dir=self.log_path, local_file=factory_file_name,
                         device_name=upload_device_name, remote_dir="~", to_state="BTS", timeout=timeout,
                         remove_source_file=False, log_level='error', new_file_name=None)
            upload_device = DeviceFactory.get_device(name=upload_device_name)
            upload_device.goto_state('FHNET', rerun=3)
            cmd_scp = upload_device.get_cmd(
                cmd_name="scp",
                cmd_params={
                    "options": "-O -oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa",
                    "source": "~/{}".format(factory_file_name),
                    "dest": "{}@{}:/tmp".format(factory_rfsw_credentials['username'] if run_on_factory_rfsw else
                                                ru_object.default_ssh_connection_details.username,
                                                self.current_ru_ipaddr),
                    "password": factory_rfsw_credentials['password'] if run_on_factory_rfsw else
                    ru_object.default_ssh_connection_details.password})
            cmd_scp(timeout=timeout)

    def swman_inventory_request(self, gnb_id=0, du_id=0, ru_id=0, run_on_factory_rfsw=False, run_as_superuser=True,
                                common_unit_id=0, capacity_unit_id=0):
        self.load_ru_device(factory_device=run_on_factory_rfsw, gnb_id=gnb_id, du_id=du_id, ru_id=ru_id,
                            common_unit_id=common_unit_id, capacity_unit_id=capacity_unit_id)
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")),
            initial_state="RU")
        cmd_inventory_request = device.get_cmd(cmd_name="swman_shell_command",
                                               cmd_params={"options": "-i"})
        if run_as_superuser:
            cmd_inventory_request = device.get_cmd(cmd_name="sudo",
                                                   cmd_params={"cmd_object": cmd_inventory_request})
        inventory_request = cmd_inventory_request()
        return inventory_request

    @staticmethod
    def swman_save_sw(cmd_params, gnb_id=0, du_id=0, ru_id=0, timeout=720, run_on_factory_rfsw=False,
                      run_as_superuser=True):
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")),
            initial_state="RU")
        cmd_save_sw = device.get_cmd(
            cmd_name="swman_shell_command",
            cmd_params={
                "options": "-s /tmp/{} {} {} {}".format(cmd_params['file_name'], cmd_params['checksum'],
                                                        cmd_params['file_version'],
                                                        cmd_params['file_name'].split(".")[-1])})
        if run_as_superuser:
            cmd_save_sw = device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": cmd_save_sw})
        save_sw = cmd_save_sw(timeout=timeout)
        log_info_to_console("Factory RFSW saved: {}".format(save_sw))

    @staticmethod
    def swman_activate_sw(cmd_params, gnb_id=0, du_id=0, ru_id=0, timeout=720, run_on_factory_rfsw=False,
                          run_as_superuser=True):
        device = DeviceFactory.get_device(
            name=ssh_bts_du_ru.format("GNB", gnb_id, du_id,
                                      "{}_{}".format(ru_id, "FACTORY" if run_on_factory_rfsw else "DEFAULT")),
            initial_state="RU")
        cmd_activate_sw = device.get_cmd(
            cmd_name="swman_shell_command",
            cmd_params={
                "options": "-a {} {} {} {}".format(cmd_params['build_name'], cmd_params['build_version'],
                                                   cmd_params['file_name'], cmd_params['file_version'])})
        if run_as_superuser:
            cmd_activate_sw = device.get_cmd(cmd_name="sudo", cmd_params={"cmd_object": cmd_activate_sw})
        activate_sw = cmd_activate_sw(timeout=timeout)
        log_info_to_console("Factory RFSW activated: {}".format(activate_sw))

    @staticmethod
    def check_gnb_uptime(gnb_id=0, du_id=0):
        device = DeviceFactory.get_device(name=ssh_bts_du.format("GNB", gnb_id, du_id), initial_state='FCT')
        uptime = device.get_cmd(cmd_name='uptime')()["UPTIME_SECONDS"]
        return uptime

    def reboot_gnb_and_verify_uptime(self, gnb_id=0, du_id=0):
        uptime_before_reboot = self.check_gnb_uptime()
        GnbDuOperations().reset_bts(bts_id=gnb_id, wait_for_reconnection=True, du_id=du_id)
        log_info_to_console("gNB reset finished")
        uptime_after_reboot = self.check_gnb_uptime()
        if uptime_after_reboot > uptime_before_reboot:
            raise GnbRebootFailedException("gNB uptime value after reboot: '{}' should be less than gNB uptime before "
                                           "reboot, but it's greater: '{}'".format(uptime_after_reboot,
                                                                                   uptime_before_reboot))

    def verify_if_factory_rfsw_is_active(self, factory_build_name, run_as_superuser=False, gnb_id=0, du_id=0, ru_id=0,
                                         common_unit_id=0, capacity_unit_id=0):
        rfsw_status = self.swman_inventory_request(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id,
                                                   run_on_factory_rfsw=True, run_as_superuser=run_as_superuser,
                                                   common_unit_id=common_unit_id, capacity_unit_id=capacity_unit_id)
        MolerTest.info(rfsw_status)
        active_build = rfsw_status["activeBuildName"]
        if active_build == factory_build_name:
            log_info_to_console("Factory build: '{}' is active.".format(factory_build_name))
        else:
            raise FactoryRFSWNotActiveException("Factory build is not active. Current active build: '{}', "
                                                "expected build: '{}'".format(active_build, factory_build_name))

    def wait_for_sw_incompatible_alarm(self, gnb_id=0, du_id=0, timeout=900):
        self.gnb_alarm.check_if_sw_incompatible_alarm_occurred(awaiting_time=timeout, bts_id=gnb_id, du_id=du_id)

    @MolerTest.raise_background_exceptions()
    def verify_if_factory_rfsw_is_active_on_both_partitions(self, factory_file_name, run_as_superuser=False,
                                                            gnb_id=0, du_id=0, ru_id=0, common_unit_id=0,
                                                            capacity_unit_id=0):
        partitions_status = self.swman_inventory_request(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id,
                                                         run_on_factory_rfsw=True,
                                                         run_as_superuser=run_as_superuser,
                                                         common_unit_id=common_unit_id,
                                                         capacity_unit_id=capacity_unit_id)['File']
        for _id, info in partitions_status.items():
            if info["name"] == factory_file_name:
                log_info_to_console("Successful verification of RFSW file loaded on partition '{}': '{}'. "
                                    "Usage status: '{}'".format(_id, info['name'], info['usage']))
            else:
                MolerTest.error("Failed. Incorrect RFSW file on partition '{}': '{}', expected: '{}'. "
                                "Usage status: '{}'".format(_id, info['name'], factory_file_name, info['usage']),
                                raise_exception=True)

    def get_active_gnb_sw_version(self):
        gnb_sw = self.gnb_du.get_bts_sw_version()
        sw = SwVersionFactory.create_sw_version(gnb_sw)
        if isinstance(sw, SbtsSwVersion):
            return sw.raw_with_release
        else:
            raise NotSupportedGnbSWVersion("SBTS SW version supported only. Active SW version: '{}'".format(gnb_sw))

    def get_gnb_sw_package_name(self, variant=None):
        gnb_sw = self.gnb_du.get_bts_sw_version()
        sw = SwVersionFactory.create_sw_version(gnb_sw)
        if isinstance(sw, SbtsSwVersion):
            return sw.get_package(package_variant=variant if variant else "")
        else:
            raise NotSupportedGnbSWVersion("SBTS SW version supported only. Active SW version: '{}'".format(gnb_sw))

    def find_sbts_package_in_cache(self, ):
        gnb_sw = self.get_active_gnb_sw_version()
        sw_package_name = self.get_gnb_sw_package_name()
        ute_cache_dir = "/home/ute/.ute-ca/cache/bts/{}".format(gnb_sw)
        try:
            if sw_package_name in os.listdir(ute_cache_dir):
                MolerTest.info("Found software package '{}' in '{}'".format(sw_package_name, ute_cache_dir))
                return os.path.join(ute_cache_dir, sw_package_name)
            else:
                MolerTest.info("Not found software package '{}' in '{}'".format(sw_package_name, ute_cache_dir))
        except OSError:
            return None

    def perform_gnb_software_update(self, gnb_id=0, du_id=0, download_dir="/tmp", timeout=1200):
        sw_updater = GnbSwUpdate()
        active_gnb_sw = self.gnb_du.get_bts_sw_version()
        try:
            sw_dir = self.find_sbts_package_in_cache()
            if not sw_dir:
                sw_dir = sw_updater.download_sw_package(sw_version=active_gnb_sw, target_dir=download_dir)
            MolerTest.info('gNB software update procedure started')
            sw_updater.update_software(sw_package_dir=sw_dir, timeout=timeout, bts_id=gnb_id, du_id=du_id)
            log_info_to_console('gNB software update procedure finished: {}'.format(sw_dir.split('/')[-1]))
        except (AdminApiConnectionClosedException, AdminApiProcedureFailureException):
            raise GnbSoftwareUpdateFailedException

    def verify_sw_incompatible_alarm_not_exist(self, gnb_id=0, du_id=0):
        self.gnb_alarm.verify_alarm_is_not_active(fault_name="Incompatible SW version detected", bts_id=gnb_id,
                                                  du_id=du_id)

    @MolerTest.raise_background_exceptions()
    def verify_active_rfsw_after_gnb_sw_update(self, run_as_superuser=True, gnb_id=0, du_id=0, ru_id=0,
                                               common_unit_id=0, capacity_unit_id=0):
        active_gnb_sw = self.get_active_gnb_sw_version()
        sbts_build_info = WFTDownloader(access_key=WFT_ACCESS_KEY).get_build_info("{}".format(active_gnb_sw))
        sbts_rf_builds = [build.split("version: ")[-1].strip() for build in
                          sbts_build_info['custom_config_spec'].strip().split("\n") if "RF." in build]

        MolerTest.info("'{} RF builds: '{}'".format(active_gnb_sw, sbts_rf_builds))
        rfsw_status = self.swman_inventory_request(gnb_id=gnb_id, du_id=du_id, ru_id=ru_id,
                                                   run_on_factory_rfsw=False, run_as_superuser=run_as_superuser,
                                                   common_unit_id=common_unit_id, capacity_unit_id=capacity_unit_id)
        MolerTest.info(rfsw_status)
        active_rfsw_build = rfsw_status["activeBuildName"]
        if active_rfsw_build in sbts_rf_builds:
            MolerTest.info("Active RFSW build '{}' derives from current gNB SW '{}': '{}'."
                           "".format(active_rfsw_build, active_gnb_sw, sbts_rf_builds))
        else:
            MolerTest.error("Failed. Active RFSW build '{}' not derives from current gNB SW '{}': '{}'."
                            "".format(active_rfsw_build, active_gnb_sw, sbts_rf_builds), raise_exception=True)


class GnbRebootFailedException(Exception):
    pass


class NoConnectionToRUException(Exception):
    pass


class FactoryRFSWNotActiveException(Exception):
    pass


class NotSupportedGnbSWVersion(Exception):
    pass


class GnbSoftwareUpdateFailedException(Exception):
    pass
