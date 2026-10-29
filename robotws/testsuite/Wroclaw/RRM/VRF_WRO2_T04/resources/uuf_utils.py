import re
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.rrm_fixture import classical_asik_ip_address
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.update_helpers import download_sw_package
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import assign_sw_version
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.timeouts import Timeouts
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl as TL_CONFIG
from taf.fdsw.rc import rc
from datetime import datetime, timedelta


class Testline:
    def __init__(self, tl):
        self.tl = tl

    def update_sw(self, sw_version):
        sw_path = download_sw_package(sw_version)
        self._update_sw_using_fdsw(sw_path)

    def _update_sw_using_admin(self, sw_version):
        sw_path = download_sw_package(sw_version)
        with AdminSession(remote_host=get_vm_ip(self.tl.test_pc)) as admin:
            admin_output = admin.update_software(sw_package=sw_path, timeout=Timeouts.sw_update)
        return admin_output

    @wait_until_function_succeeds(retry_time_in_seconds=3600, retry_interval_in_seconds=10)
    def _update_sw_using_fdsw(self, sw_path):
        self._fdsw(sw_path, remote_host=None)

    @staticmethod
    def _fdsw(sw_path, remote_host=None):
        rescue_console = rc()
        connection = 'default'
        if remote_host:
            connection = rescue_console.setup_remote(ssh_host=remote_host,
                                                     ssh_port=22,
                                                     ssh_username='ute',
                                                     ssh_password='ute')
        rescue_console.connect_to(ip_address=classical_asik_ip_address,
                                  port=443,
                                  username='Nemuadmin',
                                  password='nemuuser',
                                  name=connection)
        logger.info("Connected to FDSW")
        rescue_console.enable_ssh_service(connection=connection)
        rescue_console.disable_ethernet_port_security(connection=connection)
        slot = rescue_console.get_active_sw_partition(connection=connection)
        logger.info(rescue_console.get_all_software_inventory(connection=connection))
        logger.info("Updating software..")
        rescue_console.software_update(sw_slot_id=slot, sw_pkg_path=sw_path, timeout=3600, connection=connection,
                                       activate=True)

    def configuration_reset(self):
        logger.info("Performing configuration reset..", also_console=True)
        self._config_reset()

    def _config_reset(self):
        with AdminSession(remote_host=get_vm_ip(self.tl.test_pc)) as admin:
            admin_output = admin.reset_configuration(reset_type='ConfigurationWithDiagnosticAndRecoverySw')
        return admin_output

    @wait_until_function_succeeds(retry_time_in_seconds=1500, retry_interval_in_seconds=10)
    def wait_for_devices(self):
        logger.info("Waiting for devices", also_console=True)
        self._wait_for_devices()

    def _wait_for_devices(self):
        with AdminSession(remote_host=get_vm_ip(self.tl.test_pc)) as admin:
            self._assert_all_modules_are_enabled(admin)

    def get_software_version(self):
        with AdminSession(remote_host=get_vm_ip(self.tl.test_pc)) as admin:
            sw_version = admin.get_sw_version()
        if self.is_trunk_sw(sw_version):
            return re.sub("SBTS[A-Z0-9]+", 'SBTS00', sw_version)
        return sw_version

    def enable_ssh(self):
        with AdminSession(remote_host=get_vm_ip(self.tl.test_pc)) as admin:
            admin.enable_ssh_access()
            admin.disable_ethernet_port_security()

    @staticmethod
    def is_trunk_sw(sw_version):
        return '9999' in sw_version

    @staticmethod
    def _assert_all_modules_are_enabled(admin):
        smods = admin.get_parameters_for_all('SMOD')
        bbmods = admin.get_parameters_for_all('BBMOD')
        smods_states = [smod['operationalState'] == 'enabled' for smod in smods]
        bbmod_states = [bbmod['operationalState'] == 'enabled' for bbmod in bbmods]
        logger.info("Waiting for SMOD devices: {}".format(smods_states), also_console=True)
        logger.info("Waiting for BBMOD devices: {}".format(bbmod_states), also_console=True)
        assert all(smods_states), 'Not all SMODS are enabled!'
        assert all(bbmod_states), 'Not all BBMODS are enabled!'

    def update_incompatible_sw_on_radio(self, sw_version):
        with AdminSession(remote_host=get_vm_ip(self.tl.test_pc[0])) as admin:
            alarms = admin.get_active_alarms()

        for alarm in alarms:
            if alarm['alarmId'] == 7111 and alarm['faultId'] == 23:
                logger.info("Incompatible sw on radio detected, starting update procedure...")
                update_sw_using_admin(sw_version)
        self.wait_for_devices()


class FullrackTestline(Testline):
    def __init__(self, tl):
        super().__init__(tl)

    def _update_sw_using_admin(self, sw_version):
        sw_path = download_sw_package(sw_version)
        for test_pc in self.tl.test_pcs[0:2]:
            with AdminSession(remote_host=get_vm_ip(test_pc)) as admin:
                admin_output = admin.update_software(sw_package=sw_path, timeout=Timeouts.sw_update)
        return admin_output

    @wait_until_function_succeeds(retry_time_in_seconds=7200, retry_interval_in_seconds=10)
    def _update_sw_using_fdsw(self, sw_path):
        for index, test_pc in enumerate(self.tl.test_pcs[0:2]):
            self._fdsw(sw_path, remote_host=test_pc if index == 1 else None)

    def _config_reset(self):
        for test_pc in self.tl.test_pcs[0:2]:
            with AdminSession(remote_host=get_vm_ip(test_pc)) as admin:
                admin_output = admin.reset_configuration()
            return admin_output

    @wait_until_function_succeeds(retry_time_in_seconds=1500, retry_interval_in_seconds=10)
    def wait_for_devices(self):
        self._wait_for_devices()

    def _wait_for_devices(self):
        for test_pc in self.tl.test_pcs[0:2]:
            with AdminSession(remote_host=get_vm_ip(test_pc)) as admin:
                self._assert_all_modules_are_enabled(admin)


def get_vm_ip(test_pc):
    return test_pc.default_ssh_connection_details.addr


def prepare_source_sw(sw_version='SBTS23R1_ENB_0000_000777_000006'):
    testline = Testline(TL_CONFIG) if "FULLRACK" not in TL_CONFIG.tl_cloud_topology else FullrackTestline(TL_CONFIG)
    logger.info(type(testline), also_console=True)
    testline.configuration_reset()
    testline.update_sw(sw_version)
    testline.wait_for_devices()
    testline.enable_ssh()
    assign_sw_version()


def get_current_sw():
    return Testline(TL_CONFIG).get_software_version()


def get_day_name(date):
    return date.strftime("%A")


def set_end_date(start_time):
    WEEKEND_DAYS = ['Friday', 'Saturday', 'Sunday']
    NORMAL_DAYS = ['Monday', 'Tuesday', 'Wednesday', 'Thursday']
    END_HOUR = 6
    start_date = datetime.strptime(start_time, '%d-%m-%Y %H:%M')
    end_date = None
    print(f'Start date: {start_date}')
    print(f'Day: {get_day_name(start_date)}')
    day_shift = (0 - start_date.weekday()) % 7
    if 'UTC' in datetime.now().astimezone().tzname():
        END_HOUR -= 3
    if (get_day_name(start_date) in (NORMAL_DAYS + ['Friday'])) and (0 <= start_date.hour < END_HOUR):
        end_date = start_date.replace(hour=END_HOUR, minute=0)
    elif get_day_name(start_date) in WEEKEND_DAYS:
        end_date = (start_date + timedelta(days=day_shift)).replace(hour=END_HOUR, minute=0)
    elif get_day_name(start_date) in NORMAL_DAYS:
        end_date = (start_date + timedelta(days=1)).replace(hour=END_HOUR, minute=0)
    print(f'End date: {end_date}')
    print(f'Day: {get_day_name(end_date)}')
    return end_date.strftime('%d-%m-%Y %H:%M')


def is_time_finished(current_date, end_date):
    return datetime.strptime(current_date, '%d-%m-%Y %H:%M') >= datetime.strptime(end_date, '%d-%m-%Y %H:%M')
