from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import ONE_PING_THE_HOST
from testsuite.Wroclaw.SyVe.RRM.resources.ScfPathFinder import ScfPathFinder
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import upload_file, download_file, execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs as Os
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.SwDownloader import SwDownloader
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.external.ConfigurationResetScript import Operation, \
    SW_UPDATE_TIMEOUT, SW_UPDATE_SUCCESSFUL_START_TIMEOUT, OPERATION_TIMEOUT, PROCEDURE_SNAPSHOT_NAMES, \
    SUCCESSFUL_REMOTE_PROCEDURE_MSG, TRUCK_ROLL_STOP_AND_FIX_MSG
from time import sleep, time
from datetime import datetime

CHAIN_COMMANDS = " && "
VENV_FILE = "test_repo/bin/activate"
ACTIVATE_VENV = "source ~/" + VENV_FILE + CHAIN_COMMANDS
UPDATE_DIR = "remote_update"


class ConfigOperationException(Exception):
    pass


class RemoteBtsManager(object):
    def __init__(self):
        self.ute_home = "/home/ute/"
        self.remote_dir = Os.join_path_elements(self.ute_home, UPDATE_DIR)
        self.script_dir = "testsuite/Wroclaw/SyVe/RRM/resources/external/"
        self.script_name = "ConfigurationResetScript.py"
        self.swconfig_name = "swconfig.txt"
        self.scf_location_on_target = Os.join_path_elements(self.ute_home, self.remote_dir, f"SCF_{Env.STREAM_SW}.xml")
        self.script_location_on_target = Os.join_path_elements(self.ute_home, self.remote_dir, self.script_name)
        self.swconfig_location_on_target = Os.join_path_elements(self.ute_home, self.remote_dir, self.swconfig_name)
        self.ssh_details = None
        self.sw_build = None
        self.sw_downloader = SwDownloader()
        self.bts_name = "Not_provided"
        self.bts_id = None
        self.current_pid = None

    def perform_update_and_manage_startup_to_on_air(self, feature, bts_name, ssh_connection_details, bts_id=0,
                                                    faults_to_skip=None, recommission_node=False, *scf_path_params):
        self._prepare_environment(bts_name, ssh_connection_details, bts_id)
        if Env.RELEASE_SW_VERSION == BtsOs(self.ssh_details).get_current_sw_version():
            Logger.info("Update unnecessary. Actual Sw version same as requested update.")
            is_uncommisisoned = not self._is_remote_bts_pingable_via_mplane()
            if is_uncommisisoned or recommission_node:
                if is_uncommisisoned:
                    Logger.warning("Bts is not pingable. Assuming it's uncommisioned. "
                                   "Performing commissioning and managing bts to reach on air state.")
                self._commission_and_manage_bts_to_reach_on_air_state(feature, faults_to_skip,
                                                                      *scf_path_params)

            return
        self._start_truck_roll_if_remote_bts_is_not_pingable_via_lmp()
        self._perform_config_reset_and_manage_startup_to_on_air(feature, faults_to_skip, *scf_path_params)
        self._start_truck_roll_if_remote_bts_is_not_pingable_on_any_interface()

    def collect_bts_snapshot_on_remote_vm_in_case_failure(self, bts_name,
                                                          ssh_connection_details=Env.LTE_VM_SSH_CONN_DETAILS,
                                                          suite_level=True, remove_remote_dir=True):
        execution_state_level_status = "${SUITE_STATUS}" if suite_level else "${TEST_STATUS}"
        Logger.debug(f"Test level status is: {execution_state_level_status}, suite level"
                     f" {type(suite_level)}: {suite_level}")
        collect_dir = Env.OUTPUT_DIR if suite_level else Env().test_log_dir
        if BuiltIn().get_variable_value(execution_state_level_status) == "FAIL":
            try:
                self._prepare_environment(bts_name, ssh_connection_details)
                self._collect_bts_snapshot(bts_name, snapshot_path=collect_dir)
            except AssertionError as error:
                Logger.warning(error)
        self._update_ssh_parameters(ssh_connection_details)
        if remove_remote_dir:
            self._remove_remote_dir()

    def manage_commissioned_remote_bts_to_reach_on_air_state(self, bts_name, ssh_connection_details, faults_to_skip):
        self.bts_name = bts_name if self.bts_name == "Not_provided" else self.bts_name
        self._update_ssh_parameters(ssh_connection_details)
        self.sw_build = self._wait_for_sw_build()
        if not self.sw_build:
            self._download_sw_build()
            self.sw_build = self._wait_for_sw_build()
        self._manage_commissioned_bts_to_reach_on_air_state(faults_to_skip)

    def wait_for_bbmod_remote_cart_to_be_enabled(self, bts_name, ssh_connection_details):
        self._prepare_environment(bts_name, ssh_connection_details)
        self._wait_for_remote_operation_end(Operation.WaitForBbmodAvailability.name, OPERATION_TIMEOUT)
        self._remove_remote_dir()

    def _collect_bts_snapshot(self, title_postfix, snapshot_path=Env.OUTPUT_DIR):
        snapshot_directory = Os.join_path_elements(snapshot_path, f"remote_{self.bts_name}_logs")
        Os.make_dir(snapshot_directory)
        snapshot_file_name = f"Snapshot_neighbour_{title_postfix}.zip"
        snapshot_file_path = Os.join_path_elements(snapshot_directory, snapshot_file_name)
        remote_snapshot_file_path = Os.join_path_elements(self.remote_dir, snapshot_file_name)
        self._execute_snapshot_cmd(remote_snapshot_file_path)
        self._download_snapshot_to_local_os(remote_snapshot_file_path, snapshot_file_path)

    def _start_truck_roll_if_remote_bts_is_not_pingable_on_any_interface(self):
        self._start_truck_roll_if_remote_bts_is_not_pingable_via_lmp()
        self._start_truck_roll_if_remote_bts_is_not_pingable_via_mplane()

    def _start_truck_roll_if_remote_bts_is_not_pingable_via_mplane(self):
        if not self._is_remote_bts_pingable_via_mplane():
            self._start_truck_roll_procedure()

    def _is_remote_bts_pingable_via_mplane(self):
        bts_instance_id = self.bts_name.split("-")[1]
        bts_mplane_ip = Env.ENBS[self.bts_id].oam_ip.v4 \
            if bts_instance_id.startswith("4") else Env.GNBS[self.bts_id].oam_ip.v4
        Logger.info(f"Checking if remote BTS:{bts_instance_id} is pingable via MPLANE IP: {bts_mplane_ip}")
        output = self._vm_ssh_command(ONE_PING_THE_HOST.format(bts_mplane_ip))
        return not any(map(lambda x: x in output, ["Unreachable", "100% packet loss",  "not found"]))

    def _start_truck_roll_if_remote_bts_is_not_pingable_via_lmp(self):
        Logger.info(f"Checking if remote BTS is pingable via LMP from: {self.ssh_details.addr}")
        if BtsOs(self.ssh_details).is_bts_unreachable_via_lmp():
            self._start_truck_roll_procedure()

    def _perform_config_reset_and_manage_startup_to_on_air(self, feature, faults_to_skip, *scf_path_params):
        """
        Function performs config reset procedure with sw update to the being under the test BTS SW
        commissions the BTS to the given SCF for the feature and waits for OnAir with possible incompatible Sw on Radio
        handling
        :param feature: full feature number used in the repository path (case sensitive)
        :param faults_to_skip: list of faults number to be skipped
        :param scf_path_params: additional parameters for SCF file lookup
        :return: None
        """
        self._prepare_remote_bts_manager_config(feature, *scf_path_params)
        self._perform_configuration_reset_via_ssh()
        self._perform_sw_update()
        self._commission_remote_site()
        self._manage_commissioned_bts_to_reach_on_air_state(faults_to_skip)

    def _commission_and_manage_bts_to_reach_on_air_state(self, feature, faults_to_skip, *scf_path_params):
        self._prepare_remote_bts_manager_config(feature, *scf_path_params)
        self.sw_build = self._wait_for_sw_build()
        self._commission_remote_site()
        self._manage_commissioned_bts_to_reach_on_air_state(faults_to_skip)

    def _prepare_remote_bts_manager_config(self, feature, *scf_path_params):
        self._upload_scf_file(feature, *scf_path_params)
        self._download_sw_build()

    def _prepare_environment(self, bts_name, ssh_connection_details, bts_id=None):
        self.bts_id = bts_id
        self.bts_name = bts_name
        self._update_ssh_parameters(ssh_connection_details)
        self._create_remote_directory_if_not_created()
        self._upload_script_files()

    def _execute_snapshot_cmd(self, remote_snapshot_file_path):
        Logger.info(f"Performing REMOTE snapshot collecting: {remote_snapshot_file_path}")
        self._wait_for_remote_operation_end(Operation.CollectSnapshot.name,
                                            OPERATION_TIMEOUT, remote_snapshot_file_path)

    def _wait_for_remote_operation_end(self, operation_name, timeout, *params):
        self._perform_configuration_remote_script_operation(operation_name, *params)
        try:
            self._wait_for_pass_or_fail_lines_in_output_file(timeout)
        except ConfigOperationException as err:
            raise AssertionError(f"Something went wrong in operation {operation_name}: {err}.")
        finally:
            self._download_output_files()

    def _download_output_files(self):
        update_logs_dir = Os.join_path_elements(Env.OUTPUT_DIR, f"remote_{self.bts_name}_logs")
        Os.make_dir(update_logs_dir)
        source = Os.join_path_elements(self.remote_dir, self.operation_log_filename)
        target = Os.join_path_elements(update_logs_dir, self.operation_log_filename)
        download_file(self.ssh_details, source, target, look_for_keys=True)

    def _perform_configuration_remote_script_operation(self, operation_name, *script_params):
        self.operation_log_filename = f"{operation_name}.log"
        self._vm_ssh_command(self._generate_config_reset_script_cmd(operation_name, *script_params))
        operation_file = f"{Os.join_path_elements(self.remote_dir, self.operation_log_filename)}"
        self.current_pid = self._wait_for_python_pid(operation_file)

    def _wait_for_python_pid(self, operation_file):
        start_time = time()
        timeout = 10
        another_pid_check_attempt = 1
        while start_time + timeout > time():
            sleep(another_pid_check_attempt)
            current_pid = self._vm_ssh_command(f"head -n 1 {operation_file}").strip()
            if current_pid:
                return current_pid
        raise ConfigOperationException(f"Python startup timeout: {timeout}s")

    def _generate_config_reset_script_cmd(self, operation_name, *script_params):
        return f"{ACTIVATE_VENV}cd {self.remote_dir}" \
               f"{CHAIN_COMMANDS}(nohup python {self.script_location_on_target} " \
               f"{operation_name} {' '.join(script_params).strip()} &> {self.operation_log_filename} &) " \
               f"{CHAIN_COMMANDS}exit"

    def _wait_for_pass_or_fail_lines_in_output_file(self, timeout):
        start_time = time()
        sleep_time = 15
        read_file_cmd = f"cat {Os.join_path_elements(self.remote_dir, self.operation_log_filename)}"
        while start_time + timeout > time():
            sleep(sleep_time)
            pid_output = self._vm_ssh_command("pgrep python")
            file_output = self._vm_ssh_command(read_file_cmd, verbose=False)
            if self.current_pid not in pid_output:
                if SUCCESSFUL_REMOTE_PROCEDURE_MSG in file_output:
                    return
                raise ConfigOperationException(f"Operation failed. Output: {file_output}")
            if SUCCESSFUL_REMOTE_PROCEDURE_MSG in file_output and self.current_pid in pid_output:
                self._vm_ssh_command(f"kill -9 {self.current_pid}")
        self._vm_ssh_command(f"kill -9 {self.current_pid}")
        raise ConfigOperationException(f"Operation Timeout: {timeout//60}m")

    def _start_truck_roll_procedures_if_failure_msg_in_output(self, output):
        if TRUCK_ROLL_STOP_AND_FIX_MSG in output:
            Logger.warning(f"{TRUCK_ROLL_STOP_AND_FIX_MSG} found in remote update procedures logs")
            self._collect_bts_snapshot(title_postfix='stop_and_fix')

    def _download_snapshot_to_local_os(self, remote_snapshot_path, snapshot_path):
        Logger.info(f"Downloading {remote_snapshot_path} to {snapshot_path}")
        download_file(self.ssh_details, remote_snapshot_path, snapshot_path, look_for_keys=True)

    def _update_ssh_parameters(self, ssh_connection_details):
        self.ssh_details = ssh_connection_details

    def _create_remote_directory_if_not_created(self):
        if not self._is_remote_update_directory_created():
            self._create_remote_directory()

    def _is_remote_update_directory_created(self):
        Logger.info(f"Checking if {UPDATE_DIR} directory created.")
        list_home_directory_cmd = f"ls {self.ute_home}"
        return UPDATE_DIR in self._vm_ssh_command(list_home_directory_cmd)

    def _create_remote_directory(self):
        create_dir_cmd = f"mkdir {self.remote_dir}"
        Logger.info(f"Creating '{self.remote_dir}' directory")
        self._vm_ssh_command(create_dir_cmd)

    def _remove_remote_dir(self):
        remove_dir_cmd = f"rm -rf {self.remote_dir}"
        Logger.info(f"Removing '{self.remote_dir}' directory")
        self._vm_ssh_command(remove_dir_cmd)

    def _download_sw_build(self):
        Logger.info("Downloading SBTS SW")
        sw_download_cmd = (f"(nohup scp {Env.VM_HOST}:{self.sw_downloader.file_path}"
                           f" {self.remote_dir} 1>/dev/null 2>/dev/null &); exit")
        self._vm_ssh_command(sw_download_cmd)

    def _upload_script_files(self):
        Logger.info(f"Uploading ConfigurationResetScript file to: {self.script_location_on_target}")
        upload_file(self.ssh_details, Os.join_path_elements(self.script_dir, self.script_name),
                    self.script_location_on_target, look_for_keys=True)
        upload_file(self.ssh_details, Os.join_path_elements(self.script_dir, self.swconfig_name),
                    self.swconfig_location_on_target, look_for_keys=True)

    def _upload_scf_file(self, feature, *scf_path_params):
        scf_file = ScfPathFinder().get_scf_path_for_feature(feature, self.bts_name, *scf_path_params)
        Logger.info(f"Uploading SCF file to: {self.scf_location_on_target}")
        upload_file(self.ssh_details, scf_file, self.scf_location_on_target, look_for_keys=True)

    def _perform_configuration_reset(self):
        config_reset_operations_with_safe_margin = 4 * OPERATION_TIMEOUT + 3
        Logger.info("Performing Remote BTS configuration reset")
        self._wait_for_remote_operation_end(Operation.ConfigReset.name,
                                            config_reset_operations_with_safe_margin)
        self._download_snapshots_of_failed_procedure_attempts_to_local_os()

    def _perform_configuration_reset_via_ssh(self):
        Logger.info(f"Performing config reset by removing config files "
                    f"on Bts on vm with addr: {self.ssh_details.addr}.")
        BtsOs(self.ssh_details).config_reset()
        Logger.info(f"Config reset of Bts on vm with "
                    f"addr: {self.ssh_details.addr} {SUCCESSFUL_REMOTE_PROCEDURE_MSG}.")

    def _download_snapshots_of_failed_procedure_attempts_to_local_os(self):
        for snapshot_name in PROCEDURE_SNAPSHOT_NAMES:
            try:
                remote_snapshot_path = Os.join_path_elements(self.remote_dir, snapshot_name)
                snapshot_file_path = Os.join_path_elements(Env.OUTPUT_DIR,
                                                           f"remote_{self.bts_name}_logs", snapshot_name)
                output = self._vm_ssh_command(f"if test -f {remote_snapshot_path}; then echo 'true'; fi")
                if output:
                    download_file(self.ssh_details, remote_snapshot_path, snapshot_file_path, look_for_keys=True)
                    self._vm_ssh_command(f"rm {remote_snapshot_path}")
            except Exception as error:
                Logger.debug(error)

    def _perform_sw_update(self):
        Logger.info("Perform Remote BTS SW update")
        self.sw_build = self._wait_for_sw_build().strip()
        cumulative_timeout = SW_UPDATE_TIMEOUT + SW_UPDATE_SUCCESSFUL_START_TIMEOUT
        self._wait_for_remote_operation_end(Operation.SwUpdate.name, cumulative_timeout, self.sw_build)

    def _commission_remote_site(self):
        Logger.info(f"Performing REMOTE commissioning with source SCF file: {self.scf_location_on_target}")
        self._wait_for_remote_operation_end(Operation.CommissionBts.name,
                                            OPERATION_TIMEOUT, self.scf_location_on_target)

    def _manage_commissioned_bts_to_reach_on_air_state(self, faults_to_skip):
        Logger.info(f"Making sure SW on Radios is updated and waiting for Remote BTS {self.bts_name} startup to OnAir")
        faults_to_skip_cmd = ",".join([str(fault) for fault in faults_to_skip]) if faults_to_skip else ""
        if faults_to_skip:
            Logger.warning(f"Fault(s) skipped in checking unexpected faults during startup: {faults_to_skip_cmd}")
        self._wait_for_remote_operation_end(Operation.WaitForOnAir.name,
                                            SW_UPDATE_TIMEOUT, self.sw_build, faults_to_skip_cmd)

    def _vm_ssh_command(self, cmd, timeout=OPERATION_TIMEOUT, verbose=True):
        Logger.debug(f"Executing SSH command on REMOTE VM: {cmd}")
        output, errors = execute_ssh_command(self.ssh_details, cmd, execution_timeout=timeout, look_for_keys=True)
        if verbose:
            Logger.debug(f"SSH command result on Remote VM:\n output={output}\n errors={errors}")
        self._start_truck_roll_procedures_if_failure_msg_in_output(output)
        return output

    def _wait_for_sw_build(self):
        self._wait_for_scp_end()
        get_sw_build_cmd = f"ls {self.remote_dir}/SBTS*"
        return Os.join_path_elements(self.ute_home, self._vm_ssh_command(get_sw_build_cmd))

    def _wait_for_scp_end(self):
        interval = 3
        timeout = 3600
        is_scp_running = "pgrep scp"
        while timeout > 0:
            if not self._vm_ssh_command(is_scp_running):
                return
            sleep(interval)
            timeout -= interval
        assert False, "SBTS SW download takes too long for REMOTE site update"
