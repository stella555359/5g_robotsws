import os
import sys
from subprocess import check_output, CalledProcessError, TimeoutExpired
from taf.sbts.oam.coam.admin import admin
from enum import Enum
from time import sleep, time
from taf.internal.sbts.admin.exceptions.exception import (AdminApiProcedureTimeoutException,
                                                          AdminApiProcedureFailureException)
from retrying import retry
import logging

SW_UPDATE_SUCCESSFUL_START_TIMEOUT = 45 * 60
SSH_TO_THE_BTS = "sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 "
SCP_TO_THE_BTS = "sshpass -p oZPS0POrRieRtu scp -q {source} toor4nsn@192.168.255.129:{target}"
FORMATTER = logging.Formatter(fmt='%(asctime)s NCO_%(levelname)s:ConfigResetScript: %(message)s',
                              datefmt='%Y-%m-%d %H:%M:%S')


def get_console_handler():
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(FORMATTER)
    return console_handler


def get_logger(logger_name):
    logger_ = logging.getLogger(logger_name)
    logger_.setLevel(logging.DEBUG)
    logger_.addHandler(get_console_handler())
    logger_.propagate = False
    return logger_


logger = get_logger("RemoteResetScript")

NO_CONNECTION_TO_UNIT = 10
COMMUNICATION_FAILURE = 1806
FSP_SUBUNIT_LOST_LINK = 4341
NO_CONNECTION_BETWEEN_PRIMARY_AND_BTS_EXTENSION_SYSTEM_MODULE = 4352
VIRTUAL_NODE_NOT_RESPONDING = 4383
FORBIDDEN_TASK_FORCE_FAULTS = [NO_CONNECTION_TO_UNIT, COMMUNICATION_FAILURE, FSP_SUBUNIT_LOST_LINK,
                               NO_CONNECTION_BETWEEN_PRIMARY_AND_BTS_EXTENSION_SYSTEM_MODULE,
                               VIRTUAL_NODE_NOT_RESPONDING]
SOFTWARE_ACTIVATION_TIMEOUT_STATUS_MSG = "Status reached: Activation timeout occurred. ErrorCode: 17"
SUCCESSFUL_REMOTE_PROCEDURE_MSG = "DONE"
TRUCK_ROLL_STOP_AND_FIX_MSG = "STOP_AND_FIX_NEEDED"
OPERATION_TIMEOUT = 15 * 60
WAIT_FOR_RADIOS_TIMEOUT = 10 * 60
SW_UPDATE_TIMEOUT = 40 * 60  # SW update may take more than 30m, 40m in seconds to be sure
BTS_SSH_COMMAND_TIMEOUT = 10
RETRY_INTERVAL = 15
SNAPSHOT_BB_CARD = "Snapshot_BB_card_not_available_on_remote_bts.zip"
PROCEDURE_SNAPSHOT_NAMES = [SNAPSHOT_BB_CARD]
MANUAL_INFO_MSG = """
Script must be executed with operation name as first argument!
Possible script usage:
- python ConfigurationResetScript.py SaveCurrentSCF
- python ConfigurationResetScript.py ConfigReset
- python ConfigurationResetScript.py CollectSnapshot $SNAPSHOT_NAME
- python ConfigurationResetScript.py SwUpdate $BTS_BUILD_PATH
- python ConfigurationResetScript.py CommissionBts $SCF_PATH
- python ConfigurationResetScript.py WaitForOnAir $BTS_BUILD_PATH (for possible RF update)
- python ConfigurationResetScript.py AllUpdateSteps $SCF_PATH $BTS_BUILD_PATH $STOP_AND_FIX_FAULTS_TO_SKIP
  (faults must be separated with coma, without spaces)
"""


class BbCardNotAvailableError(Exception):
    pass


class AdminConnectionError(Exception):
    pass


class BtsResetException(Exception):
    pass


class BtsUpdater(object):

    def __init__(self):
        self._rat_cell = None

    def configuration_reset(self, admin_version):
        try:
            self._put_swconfig_on_bts()
            self._configuration_reset(admin_version)
        except AdminApiProcedureTimeoutException:
            assert self._is_bts_uncommissioned(), 'Bts still commissioned'
            logger.warning(f"Configuration reset {SUCCESSFUL_REMOTE_PROCEDURE_MSG} however timeout was reached")
        except BbCardNotAvailableError:
            self.get_bts_snapshot(snapshot_filename=SNAPSHOT_BB_CARD, admin_version=admin_version,
                                  success_msg="additional snapshot for bb card availability collected")
            with RemoteAdminApi(release=admin_version) as api:
                logger.debug("Resetting site for recovery BB module(s)")
                api.reset_site()
            self.wait_for_bb_cards_online(admin_version)
            logger.info(f"Configuration reset {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")
        except AdminConnectionError as admin_error:
            raise AdminConnectionError(admin_error)

    def _configuration_reset(self, admin_version):
        logger.info("Configuration reset of {} ongoing...".format(self.current_bts_sw))
        with RemoteAdminApi(release=admin_version) as _admin:
            _admin.reset_configuration(timeout=OPERATION_TIMEOUT)
        RemoteAdminApi(release=admin_version).wait_for_admin_connection_possibility()
        self.wait_for_bb_cards_online(admin_version)
        logger.info(f"Configuration reset {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")

    def bts_sw_update(self, build_path, admin_version):
        logger.info("BTS SW Update ongoing...")
        self.try_to_sw_update_ignoring_procedure_failures(build_path, admin_version)
        self.wait_for_bb_cards_online(admin_version)
        logger.info(f"BTS SW Update {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")

    @staticmethod
    def commission_bts(scf_path, admin_version):
        BtsUpdater._put_swconfig_on_bts()
        logger.info("BTS Commissioning ongoing...")
        from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
        interval = 30
        timeout_for_cplane_busy = 1000
        cplane_timeout = time() + timeout_for_cplane_busy
        while cplane_timeout > time():
            try:
                logger.info("Performing full commissioning with {}".format(scf_path))
                with RemoteAdminApi(release=admin_version) as _admin:
                    status = _admin.perform_commissioning(scf_file=scf_path, skip_parameter_relation_errors=True,
                                                          timeout=OPERATION_TIMEOUT)
                    logger.debug("Received commissioning status: {}".format(status))
                    logger.info(f"BTS Commissioning {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")
                return
            except AdminApiProcedureFailureException as error:
                logger.debug(f"Log error AdminApiProcedureFailureException: {error.args}")
                if "CPlane is busy" in str(error):
                    logger.info(f"Wait {interval}s and check if CPlane is not busy")
                else:
                    assert False, "Commissioning has failed on other AdminApiProcedureFailureException error"
            sleep(interval)
        assert False, "Commissioning has failed, please check the logs - timeout"

    def wait_for_on_air(self, build_path, admin_version, faults_to_skip=None):
        global FORBIDDEN_TASK_FORCE_FAULTS
        if faults_to_skip:
            FORBIDDEN_TASK_FORCE_FAULTS = list(filter(lambda f: f not in faults_to_skip, FORBIDDEN_TASK_FORCE_FAULTS))
            logger.info(FORBIDDEN_TASK_FORCE_FAULTS)
        logger.info("BTS startup to OnAir ongoing...")
        if self._wait_for_bts_startup_with_compatible_sw_on_radios(admin_version)\
                and not self._are_all_cells_on_air(admin_version):
            self._try_to_update_software_for_radio_ignoring_procedure_failures(build_path, admin_version)
        self._wait_for_all_cells_on_air(admin_version)
        logger.info(f"BTS startup to OnAir {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")

    @staticmethod
    def get_bts_snapshot(snapshot_filename, admin_version,
                         success_msg=f"Collecting Snapshot {SUCCESSFUL_REMOTE_PROCEDURE_MSG}"):
        logger.info("Waiting for admin connection possibility to collect snapshot")
        RemoteAdminApi(release=admin_version).wait_for_admin_connection_possibility()
        file_path = os.path.join(os.getcwd(), snapshot_filename)
        logger.info("Collecting snapshot to {}".format(file_path))
        with RemoteAdminApi(admin_version) as _admin:
            _admin.get_snapshot(target_file_name=file_path, timeout=600)
        logger.info(success_msg)

    def download_current_scf(self, admin_version):
        if self._is_bts_commissioned():
            scf_name = "safe_copy_SCF.xml"
            with RemoteAdminApi(release=admin_version) as _admin:
                logger.info("downloading current SCF: {}".format(scf_name))
                _admin.get_current_scf_file(local_dir_path=os.getcwd(), file_name=scf_name)
        else:
            logger.warning("BTS is not commissioned, no SCF to download")

    def wait_for_bb_cards_online(self, admin_version):
        logger.debug("Waiting for bb cards online")
        timeout = OPERATION_TIMEOUT
        while not self._are_bb_cards_online(admin_version) and timeout > 0:
            timeout -= RETRY_INTERVAL
            sleep(RETRY_INTERVAL)
        if timeout <= 0:
            raise BbCardNotAvailableError('At least one BB card is not available after {}s'.format(OPERATION_TIMEOUT))

    @staticmethod
    def _are_bb_cards_online(admin_version):
        with RemoteAdminApi(release=admin_version) as _admin:
            bb_cards_status = _admin.get_fbb_info()
        if not bb_cards_status:
            return False
        for bb_card in bb_cards_status:
            if bb_card['status'].get('operationalState').lower() != 'enabled':
                return False
        return True

    def _wait_for_bts_startup_with_compatible_sw_on_radios(self, admin_version):
        timeout = OPERATION_TIMEOUT
        interval = 2 * RETRY_INTERVAL
        logger.info("Waiting {}s for OnAir/Incompatible RF SW".format(timeout))
        while not self._are_all_cells_on_air(admin_version) and timeout > 0:
            self._log_when_forbidden_task_force_fault_raised(admin_version)
            sleep(interval)
            if self._is_incompatible_sw_fault_active(admin_version):
                logger.warning("Incompatible SW detected")
                return True
            timeout -= interval
        return False

    def _wait_for_all_cells_on_air(self, admin_version):
        timeout = OPERATION_TIMEOUT
        logger.info("Waiting {}s for All Cells OnAir".format(timeout))
        while not self._are_all_cells_on_air(admin_version) and timeout > 0:
            self._log_when_forbidden_task_force_fault_raised(admin_version)
            timeout -= RETRY_INTERVAL
            sleep(RETRY_INTERVAL)
        self._log_when_forbidden_task_force_fault_found_in_the_history(admin_version)
        assert timeout > 0, "BTS could not reach OnAir within {}s".format(OPERATION_TIMEOUT)

    def _are_all_cells_on_air(self, admin_version):
        cells_name = self.rat_cells
        cells = []
        with RemoteAdminApi(release=admin_version) as _admin:
            for rat_cell in cells_name:
                cells += _admin.get_managed_objects(class_name=rat_cell, timeout=30)
        for cell in cells:
            if not self._is_on_air_status(cell):
                return False
        return True

    @staticmethod
    def _is_on_air_status(cell):
        return True if cell["parameters"]["operationalState"].lower() == 'enabled' else False

    @property
    def rat_cells(self):
        if self._rat_cell is None:
            self._rat_cell = self._determine_rat_cell()
        return self._rat_cell

    @retry(stop_max_attempt_number=3, wait_fixed=10000)
    def _determine_rat_cell(self):
        rats = self._get_rat_name_for_configured_cells()
        if len(rats) > 1:
            return ["LNCEL_R", "NRCELL_R"]
        return ["LNCEL_R"] if rats[0].lower() == "lte" else ["NRCELL_R"]

    def _get_rat_name_for_configured_cells(self):
        rats = []
        rat_states = self.bts_info["ratState"]
        for rat in rat_states:
            if rat_states[rat].strip() != "NO_CELLS":
                rats.append(rat)
        return rats

    def _try_to_update_software_for_radio_ignoring_procedure_failures(self, build_path, admin_version):
        logger.info("---Update SW on Radio ongoing...")
        timeout = OPERATION_TIMEOUT + 300
        interval = 2 * RETRY_INTERVAL
        error_list = []
        while timeout > 0:
            self._log_when_forbidden_task_force_fault_raised(admin_version)
            try:
                self._sw_update(build_path, admin_version)
                logger.info("---SW update on Radio completed")
                return
            except Exception as error:
                error_list.append(error)
                timeout -= interval
                sleep(interval)
        assert False, "Remote SW update procedure has failed with every attempt during given {}m time " \
                      "with the exception list: {}".format(timeout // 60, error_list)

    def _sw_update(self, build_path, admin_version):
        active_release = self.active_sw_release
        with RemoteAdminApi(release=active_release) as _admin:
            _admin.update_software(sw_package=build_path, should_activate=True, timeout=SW_UPDATE_TIMEOUT)
        RemoteAdminApi(release=admin_version).wait_for_admin_connection_possibility()

    def try_to_sw_update_ignoring_procedure_failures(self, build_path, admin_version):
        interval = 30
        update_procedure_end_time = time() + SW_UPDATE_SUCCESSFUL_START_TIMEOUT

        active_partition_to_set_if_sw_activation_timeout = self._get_new_active_partition()
        active_release = self.active_sw_release
        logger.info("Updating BTS SW with {} admin release version".format(active_release))
        admin_api = RemoteAdminApi(release=active_release)
        _admin_connection_instance = admin_api.get_admin_connection()
        _admin_connection_instance.wait_sw_update_possible()
        while time() < update_procedure_end_time:
            try:
                _admin_connection_instance.update_software(sw_package=build_path, should_activate=True,
                                                           timeout=SW_UPDATE_TIMEOUT)
                admin_api.admin.teardown()
                break
            except AdminApiProcedureFailureException as err:
                logger.warning('Entered AdminApiProcedureFailureException')
                if SOFTWARE_ACTIVATION_TIMEOUT_STATUS_MSG in str(err):
                    logger.warning('Entered software activation status if statement')
                    admin_api.admin.teardown()
                    self._set_new_active_partition_and_reboot_the_bts(
                        active_partition_to_set_if_sw_activation_timeout)
                    RemoteAdminApi(release=admin_version).wait_for_admin_connection_possibility()
                    assert self._read_running_partition_from_bts() == \
                           active_partition_to_set_if_sw_activation_timeout, "Active partition not changed after reset"
                    return
                else:
                    logger.info(f"Attempt for SW update failed with: '{err}', "
                                f"retrying after {interval}s")
                    sleep(interval)
        else:
            admin_api.admin.teardown()
            raise AssertionError(f"Software update failed to start in time {SW_UPDATE_SUCCESSFUL_START_TIMEOUT//60}m")
        self._verify_that_bts_was_updated(build_path, admin_version)

    @staticmethod
    def _read_running_partition_from_bts():
        logger.debug("Reading the running partition from bts")
        active_partition_listing = os.popen(
            SSH_TO_THE_BTS + '"ls -Al /ffs/run | grep -oE [1-2]$"') \
            .read().strip()
        logger.debug("The running partition: {}".format(active_partition_listing))
        return active_partition_listing

    @staticmethod
    def _put_swconfig_on_bts():
        logger.debug("Creating swconfig file in /ffs/run")
        swconfig_path = "/home/ute/remote_update/swconfig.txt"
        try:
            with open(swconfig_path):
                os.system(SCP_TO_THE_BTS.format(source=swconfig_path, target="/ffs/run/swconfig.txt"))
        except FileNotFoundError:
            logger.error(f"{swconfig_path} file not found")

    def _verify_that_bts_was_updated(self, build_path, admin_version):
        sw_build_elements = os.path.abspath(build_path).split("_")  # FIXME: it won't work in dir without "_" in name
        release_numbers_only = slice(3, 6)
        build_version_nr = "_".join(sw_build_elements[release_numbers_only])
        timeout = 420
        self._wait_for_possible_ping_stop(timeout)
        self._wait_for_ssh_open(timeout)
        RemoteAdminApi(release=admin_version).wait_for_admin_connection_possibility()
        current_sw = self.current_bts_sw
        assert build_version_nr in current_sw, \
            f"New software was not activated. Running SW: {current_sw}," \
            f" expected version: {build_version_nr} for {sw_build_elements[1].split('/')[1]} stream"

    def _wait_for_possible_ping_stop(self, timeout):
        start_time = time()
        interval = 5
        while start_time + timeout > time():
            ping_response = self._execute_command("ping -W 3 -c 1 192.168.255.129")
            if any(map(lambda msg: msg in ping_response, ["Unreachable", "0 received"])):
                logger.debug("Response for ping from bts stopped. Wait for bts to restart.")
                return
            sleep(interval)

    def _wait_for_ssh_open(self, timeout):
        start_time = time()
        interval = 5
        while start_time + timeout > time():
            if "22/tcp open" in self._execute_command("nmap -p 22 192.168.255.129"):
                logger.debug("Ssh port is open. Bts correctly restarted")
                return
            sleep(interval)
        logger.debug("Waiting for open SSH port fails")
        raise BtsResetException(f"Timeout, ssh port is closed after {timeout//60}m")

    def _get_bts_uptime(self):
        cmd_uptime = SSH_TO_THE_BTS + "'cat /proc/uptime'"
        try:
            output = self._execute_command(cmd_uptime).split()[0]
            if output:
                bts_up_time = float(output)
                logger.info("Current bts uptime {}".format(bts_up_time))
                return bts_up_time
        except TimeoutExpired:
            logger.warning(f"Command '{cmd_uptime}' execution timeout.")
        return

    def change_sw_partition(self, admin_version):
        active_partition_to_set = self._get_new_active_partition()
        logger.debug("Partition to be changed: {}".format(active_partition_to_set))
        self._set_new_active_partition_and_reboot_the_bts(active_partition_to_set)
        RemoteAdminApi(release=admin_version).wait_for_admin_connection_possibility()
        self.wait_for_bb_cards_online(admin_version)
        logger.info(f"Switching SW partition {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")

    @staticmethod
    def _set_new_active_partition_and_reboot_the_bts(partition_number):
        set_new_partition_command = SSH_TO_THE_BTS + "'uboot_env set active_partition={}'".format(partition_number)
        os.system(set_new_partition_command)
        logger.info("New partition set, now rebooting the BTS")
        os.system(SSH_TO_THE_BTS + "'reboot'")

    def _get_new_active_partition(self):
        return '1' if self._read_active_partition_from_uboot_env() == '2' else '2'

    @staticmethod
    def _read_active_partition_from_uboot_env():
        logger.debug("Reading active partition from uboot_env")
        run_uboot_env_get_active_partition_cmd = SSH_TO_THE_BTS + "'uboot_env get active_partition | grep -oE [1-2]$'"
        return os.popen(run_uboot_env_get_active_partition_cmd).read().strip()

    def _is_incompatible_sw_fault_active(self, admin_version):
        assert self._is_bts_commissioned(), \
            "BTS must be commissioned, number of detected RF modules depends on BB cards"
        logger.debug("Checking for incompatible sw fault")
        self._wait_for_all_configured_radios_appeared(admin_version)
        active_faults = self._get_raw_active_faults(admin_version)
        for fault in active_faults:
            if int(fault['faultId']) == 23:
                logger.warning("---Incompatible SW detected on Radio!")
                return True
        return False

    def _wait_for_all_configured_radios_appeared(self, admin_version):
        logger.debug("Waiting for all configured radios")
        timeout = WAIT_FOR_RADIOS_TIMEOUT
        while not self._are_all_rf_modules_detected() and timeout > 0:
            timeout -= RETRY_INTERVAL
            sleep(RETRY_INTERVAL)
        assert timeout > 0, "\nNot All RF modules are ready. " \
                            "Please check active faults: {}".format(self._get_active_faults(admin_version))

    def _log_when_forbidden_task_force_fault_raised(self, admin_version):
        for faultId in self._get_raw_active_faults(admin_version):
            if int(faultId['faultId']) in FORBIDDEN_TASK_FORCE_FAULTS:
                logger.warning(f"Forbidden fault {faultId['faultId']} is raised: {TRUCK_ROLL_STOP_AND_FIX_MSG}")

    def _log_when_forbidden_task_force_fault_found_in_the_history(self, admin_version):
        try:
            for faultId in self._get_raw_historical_faults(admin_version):
                if int(faultId['faultId']) in FORBIDDEN_TASK_FORCE_FAULTS:
                    logger.warning(f"Forbidden fault {faultId['faultId']} is raised: {TRUCK_ROLL_STOP_AND_FIX_MSG}")
        except AdminApiProcedureTimeoutException:
            logger.warning("Getting historical alarms timeout")

    def _get_active_faults(self, admin_version):
        alarms = self._get_raw_active_faults(admin_version)
        return self._alarm_msg(alarms)

    @staticmethod
    def _get_raw_active_faults(admin_version):
        with RemoteAdminApi(admin_version) as _admin:
            return _admin.get_active_alarms()

    @staticmethod
    def _get_raw_historical_faults(admin_version):
        with RemoteAdminApi(admin_version) as _admin:
            return _admin.get_historic_alarms(load_history=True, timeout=120)

    @staticmethod
    def _execute_command(command, timeout=BTS_SSH_COMMAND_TIMEOUT):
        try:
            return check_output(command, shell=True, timeout=timeout).decode("utf-8")
        except CalledProcessError as err:
            return err.output.decode("utf-8")

    @staticmethod
    def _alarm_msg(alarms):
        msg = ""
        for fault in alarms:
            msg += '\n{} fault ({}) - {}'.format(fault['severity'], fault['faultId'], fault['faultName'])
        return msg

    def _are_all_rf_modules_detected(self):
        logger.debug("Checking RF modules availability")
        for radio in self.bts_info['radioModules']['rmod']:
            if radio['status'].get('powerState') is None:
                return False
        for radio in self.bts_info['radioModules']['rmod']:
            if radio['status'].get('availabilityStatus') not in ['NotInstalled', 'not installed']:
                return True
        return False

    def _is_bts_commissioned(self):
        logger.debug("Checking BTS commissioning status")
        return False if self.bts_info['status']['proceduralState'] == 'NotCommissioned' else True

    def _is_bts_uncommissioned(self):
        return not self._is_bts_commissioned()

    @property
    def active_sw_release(self):
        active_sw_release = get_sbts_admin_version()
        logger.info("Active SW release to be used for admin is {}".format(active_sw_release))
        return active_sw_release

    @property
    def current_bts_sw(self):
        nr_of_attempts = 5
        wait_between_sw_checks = 15
        for attempt in range(nr_of_attempts):
            version = self.bts_info['swInfo']['swVersion']
            if version:
                logger.info(f"Current SW version is : {version}, read in attempt #{attempt + 1}")
                return version
            if attempt < nr_of_attempts:
                sleep(wait_between_sw_checks)
        raise AssertionError("Problem with reading the current SW from the BTS")

    @property
    def bts_info(self):
        with RemoteAdminApi(release=self.active_sw_release) as _admin:
            return _admin.get_bts_info()


class RemoteAdminApi(object):
    def __init__(self, release):
        self.admin = admin()
        self._release = release

    def __enter__(self):
        try:
            return self.get_admin_connection()
        except AdminApiProcedureTimeoutException as err:
            logger.warning("First attempt to connect with admin failed: {}\n retrying...".format(err))
            return self.get_admin_connection()

    def get_admin_connection(self):
        return self.admin.connect_to(bts_host=self.get_bts_ip(), release=self._release)

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.admin.teardown()

    def wait_for_admin_connection_possibility(self):
        timeout = OPERATION_TIMEOUT / 3
        connection_failure_reasons = []
        logger.info("Waiting {}s for admin connection possibility".format(timeout))
        while timeout > 0:
            sleep(RETRY_INTERVAL)
            try:
                self.admin.connect_to(bts_host=self.get_bts_ip())
                self.admin.teardown()
                return
            except Exception as err:
                connection_failure_reasons.append(err)
                timeout -= RETRY_INTERVAL
        raise AdminConnectionError("There was problem with Admin connection to BTS within {}s due to following"
                                   " errors={}".format(timeout, connection_failure_reasons))

    def get_bts_ip(self):
        port_open = "443/tcp open"
        ip1 = "192.168.255.1"
        ip129 = "192.168.255.129"
        nmap1 = self._get_nmap_output_for_ip(ip1)
        if port_open in nmap1:
            return ip1
        nmap129 = self._get_nmap_output_for_ip(ip129)
        assert port_open in nmap1 + nmap129, \
            "There's no admin port open on both BTS IPs:\nnmap {}\n{}\nnmap {}\n{}".format(ip1, nmap1, ip129, nmap129)
        return ip129

    @staticmethod
    def _get_nmap_output_for_ip(ip):
        nmap_ip = "nmap -p 443 {}".format(ip).split()
        return check_output(nmap_ip).decode('utf-8')


class Operation(Enum):
    SaveCurrentSCF = 0
    ConfigReset = 1
    SwUpdate = 2
    CommissionBts = 3
    WaitForOnAir = 4
    AllUpdateSteps = 5
    CollectSnapshot = 6
    SetNewActivePartition = 7
    WaitForBbmodAvailability = 8


def display_error_and_exit():
    logger.warning(MANUAL_INFO_MSG)
    exit(0)


def get_sbts_admin_version():
    logger.debug("Reading active SW release version")
    get_active_release_cmd = SSH_TO_THE_BTS + "'ls /rom/TargetBD*.xml | grep -Eo SBTS2.{3}'"
    return os.popen(get_active_release_cmd).read().strip()


if __name__ == "__main__":
    print(os.getpid())
    if len(sys.argv) == 1:
        display_error_and_exit()

    operation = sys.argv[1]
    updater = BtsUpdater()
    version_for_admin = get_sbts_admin_version()

    if operation == Operation.SaveCurrentSCF.name:
        updater.download_current_scf(version_for_admin)

    elif operation == Operation.ConfigReset.name:
        updater.configuration_reset(version_for_admin)

    elif operation == Operation.SwUpdate.name:
        sw_build = sys.argv[2]
        updater.bts_sw_update(sw_build, version_for_admin)

    elif operation == Operation.CommissionBts.name:
        scf_file = sys.argv[2]
        updater.commission_bts(scf_file, version_for_admin)

    elif operation == Operation.WaitForOnAir.name:
        sw_build = sys.argv[2]
        stop_and_fix_faults_to_skip = [int(fault) for fault in sys.argv[3].split(',')] if len(sys.argv) == 4 else None
        updater.wait_for_on_air(sw_build, version_for_admin, stop_and_fix_faults_to_skip)

    elif operation == Operation.CollectSnapshot.name:
        snapshot_name = sys.argv[2]
        updater.get_bts_snapshot(snapshot_name, version_for_admin)

    elif operation == Operation.AllUpdateSteps.name:
        scf_file = sys.argv[2] if sys.argv[2].endswith(".xml") else None
        sw_build = sys.argv[3] if sys.argv[3].endswith(".zip") else None
        stop_and_fix_faults_to_skip = [int(fault) for fault in sys.argv[4].split(',')] if len(sys.argv) == 5 else None
        if scf_file and sw_build:
            updater.download_current_scf(version_for_admin)
            updater.configuration_reset(version_for_admin)
            updater.bts_sw_update(sw_build, version_for_admin)
            updater.commission_bts(scf_file, version_for_admin)
            updater.wait_for_on_air(sw_build, version_for_admin, stop_and_fix_faults_to_skip)
        else:
            display_error_and_exit()

    elif operation == Operation.SetNewActivePartition.name:
        updater.change_sw_partition(version_for_admin)

    elif operation == Operation.WaitForBbmodAvailability.name:
        RemoteAdminApi(release=version_for_admin).wait_for_admin_connection_possibility()
        updater.wait_for_bb_cards_online(version_for_admin)
        logger.info(f"Bbmod check {SUCCESSFUL_REMOTE_PROCEDURE_MSG}")

    else:
        display_error_and_exit()

    logger.info("*** All actions performed successfully ***")
