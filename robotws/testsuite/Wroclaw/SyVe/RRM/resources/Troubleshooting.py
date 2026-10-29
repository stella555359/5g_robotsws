from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import NetWorking
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import download_file, execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import Ssh
from testsuite.Wroclaw.SyVe.RRM.resources.ProxySsh import ProxySsh, DEFAULT_TIMEOUT
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSnapshot import BtsSnapshot
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults, FORBIDDEN_TASK_FORCE_FAULTS
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime
from time import sleep
import copy

HOUR_SECONDS = 3600
HOURS_SLEEP = 24
# TIME_TO_SLEEP_TEST_LINE_STOP = HOUR_SECONDS * HOURS_SLEEP # stop & fix disabled


class Troubleshooting(object):
    def __init__(self):
        self.faults = BtsFaults()
        self.network = NetWorking()

    @staticmethod
    def collect_snapshot_via_ssh_if_suite_fails(snapshot_name, nc_address=0):
        if BuiltIn().get_variable_value("${SUITE_STATUS}") == "FAIL":
            try:
                Troubleshooting._collect_snapshot_via_ssh(snapshot_name, nc_address)
            except Exception as error:
                Logger.warning(error)

    def collect_snapshot_via_ssh(self, snapshot_name, nc_address=0):
        try:
            self._collect_snapshot_via_ssh(snapshot_name, nc_address)
        except Exception as error:
            Logger.warning(error)

    @staticmethod
    def collect_abia_logs_if_suite_fails(enb_conn_details):
        if BuiltIn().get_variable_value("${SUITE_STATUS}") == "FAIL":
            try:
                Troubleshooting._collect_abia_logs(enb_conn_details)
            except Exception as error:
                Logger.warning(error)

    def freeze_test_line_for_task_force_if_forbidden_faults_or_connectivity_problems_detected(self,
                                                                                              skip_fault10=False):
        self.check_if_gnb_is_pingable_via_lmp_and_freeze_test_line_otherwise()
        Logger.info(f"Checking forbidden faults: {FORBIDDEN_TASK_FORCE_FAULTS} are raised in the BTS now")
        self.check_active_fault_and_freeze_test_line_if_forbidden_fault_found(skip_fault10_checking=skip_fault10)
        Logger.info(f"Checking forbidden faults: {FORBIDDEN_TASK_FORCE_FAULTS} were raised in the BTS history")
        self.check_historical_faults_and_freeze_test_line_if_forbidden_fault_found(skip_fault10_checking=skip_fault10)
        self.check_if_gnb_is_pingable_via_mplane_and_freeze_test_line_otherwise()

    def check_active_fault_and_freeze_test_line_if_forbidden_fault_found(self, snapshot_name='long_sleep_snapshot.zip',
                                                                         nc_address=0, gnb_id=0, lmp_ip_if_gnb0=True,
                                                                         skip_fault10_checking=False):
        try:
            if self.faults.is_forbidden_task_force_fault_raised(gnb_id, lmp_ip_if_gnb0, skip_fault10_checking):
                self.collect_snapshot_and_freeze_testline(snapshot_name, nc_address)
        except Exception as long_time_err:
            Logger.warning(f"Check for active forbidden fault failed: {long_time_err}")

    def check_historical_faults_and_freeze_test_line_if_forbidden_fault_found(self, skip_fault10_checking=False):
        try:
            if self.faults.was_forbidden_task_force_fault_raised(skip_fault10_checking=skip_fault10_checking):
                self.collect_snapshot_and_freeze_testline()
        except Exception as long_time_err:
            Logger.warning(f"Check for historical forbidden fault failed: {long_time_err}")

    def check_if_gnb_is_pingable_via_mplane_and_freeze_test_line_otherwise(self):
        if Env.get_suite_flag_if_bts_commission_was_attempted():
            self._check_if_gnb_is_pingable(local_connection=False)

    def check_if_gnb_is_pingable_via_lmp_and_freeze_test_line_otherwise(self):
        self._check_if_gnb_is_pingable(local_connection=True)

    def _check_if_gnb_is_pingable(self, local_connection):
        ip = self.network.get_gnb_mplane_ip(lmp_ip_if_gnb0=local_connection)
        Logger.info(f"Checking if GNB IP:{ip} is pingable")
        if ((local_connection and BtsOs().is_bts_unreachable_via_lmp()) or
                (not local_connection and BtsOs().is_bts_unreachable_via_mplane(ip))):
            self.collect_snapshot_and_freeze_testline()

    def collect_snapshot_and_freeze_testline(self, snapshot_name='long_sleep_snapshot.zip', nc_address=0):
        if not Env.is_suite_flag_stop_and_fix_raised():
            VmOs().task_force_stop_and_fix_command()
            Env.set_suite_flag_if_stop_and_fix_is_raised()
        self._snapshot_long_sleep(snapshot_name, nc_address)

    def compress_file_from_bbmod_to_download(self, vm_connection, fsp_ip, file_name, file_dir,
                                             execution_timeout=DEFAULT_TIMEOUT, look_for_keys=False):
        """
        Function creates and returns ssh client object via proxy.
        It may be used as one connection used many times in the test
        WARNING - close() function must be called to close ssh_client in teardown
        :param vm_connection: connection details to VM for example LTE VM
        :param fsp_ip: fsp address ip
        :param file_name: file name to compress the file
        :param file_dir: file dir to compress as tar.gz
        :param execution_timeout: how long wait for the execution ends
        :param look_for_keys: Try to connect with ssh keys first
        """
        fsp_connection = self._prepare_fsp_connection_object(fsp_ip)
        cmd = "tar -czvf {}.tar.gz {}".format(file_name, file_dir)
        with Ssh(vm_connection, look_for_keys=look_for_keys) as ssh_vm_enb:
            with ProxySsh(Env.GNB_SSH_CONNECTION_DETAILS, proxy=ssh_vm_enb) as enb:
                with ProxySsh(fsp_connection, proxy=enb) as enb_fsp:
                    _, stdout, stderr = enb_fsp.exec_command(cmd, timeout=execution_timeout)
                    Logger.debug("Prepared files:\n {}".format(stdout.read().decode('utf-8').strip()))

    def download_file_from_bbmod(self, vm_connection, fsp_ip, source, target, execution_timeout=DEFAULT_TIMEOUT,
                                 look_for_keys=False):
        """
        Function creates and returns ssh client object via proxy and download file.
        It may be used as one connection used many times in the test
        WARNING - close() function must be called to close ssh_client in teardown
        :param vm_connection: connection details to VM for example LTE VM
        :param fsp_ip: fsp address ip
        :param source: remote file path to be downloaded
        :param target: local target file path
        :param execution_timeout: how long wait for the execution ends
        :param look_for_keys: Try to connect with ssh keys first
        """
        fsp_connection = self._prepare_fsp_connection_object(fsp_ip)
        cmd = "rm -rf {}".format(source)
        with Ssh(vm_connection, look_for_keys=look_for_keys) as ssh_vm_enb:
            with ProxySsh(Env.GNB_SSH_CONNECTION_DETAILS, proxy=ssh_vm_enb) as enb:
                with ProxySsh(fsp_connection, proxy=enb) as enb_fsp:
                    Logger.debug("Download and clean file source {} target {}".format(source, target))
                    enb_fsp.open_sftp().get(source, target)
                    _, stdout, stderr = enb_fsp.exec_command(cmd, timeout=execution_timeout)

    @staticmethod
    def _prepare_fsp_connection_object(fsp_ip):
        fsp_connection = copy.copy(Env.GNB_SSH_CONNECTION_DETAILS)
        fsp_connection.addr = fsp_ip
        return fsp_connection

    @staticmethod
    def _collect_abia_logs(enb_conn_details):
        abia_log_path = "/var/log/"
        list_of_ips = Troubleshooting._get_abia_ip_list(enb_conn_details)
        for ip in list_of_ips:
            ip = ip.replace("(", "").replace(")", "")
            log_filename = "logsvar_{}".format(ip)
            output_dir = VmOs.join_path_elements(Env.OUTPUT_DIR, log_filename)
            Logger.info("Downloading {} to {}".format(log_filename, output_dir))
            Troubleshooting().compress_file_from_bbmod_to_download(enb_conn_details, ip, log_filename,
                                                                   abia_log_path, look_for_keys=True)
            Troubleshooting().download_file_from_bbmod(enb_conn_details, ip,
                                                       "/user/toor4nsn/{}.tar.gz".format(log_filename),
                                                       "{}.tar.gz".format(output_dir), look_for_keys=True)

    @staticmethod
    def collect_asp_logs_and_return_log_name(node_to_download_from, file_name="ASP-1740_startup.log"):
        _bbmod_asp_file_to_download = "bget 1:1 /tmp/{}/tmp/{} /tmp/".format(node_to_download_from, file_name)
        _gnb_file_to_download = "/tmp/{}".format(file_name)
        _asp_log_dir = str(Env.test_log_dir) + "_ASP"
        VmOs.make_empty_dir(_asp_log_dir)
        execute_ssh_command(Env.GNB_SSH_CONNECTION_DETAILS, _bbmod_asp_file_to_download, execution_timeout=20)
        asp_filepath = VmOs.join_path_elements(_asp_log_dir, file_name)
        download_file(Env.GNB_SSH_CONNECTION_DETAILS, _gnb_file_to_download, asp_filepath)
        return asp_filepath

    @staticmethod
    def _get_abia_ip_list(enb_conn_details):
        interface_list = BtsOs(enb_conn_details).get_network_interface_list_on_bb_module()
        fsp_only_interface_list = VmOs.create_fsp_only_abia_network_interface_list(interface_list)
        list_of_ips = VmOs.get_list_of_network_interface_ips(fsp_only_interface_list)
        return list_of_ips

    @staticmethod
    def _collect_snapshot_via_ssh(snapshot_name, nc_address):
        BtsOs().collect_snapshot(VmOs.join_path_elements("/", snapshot_name), nc_address)
        download_file(Env.GNB_SSH_CONNECTION_DETAILS, VmOs.join_path_elements("/ram/", snapshot_name),
                      VmOs.join_path_elements(Env.OUTPUT_DIR, snapshot_name))

    def _snapshot_long_sleep(self, snapshot_name, nc_address):
        try:
            BtsSnapshot().collect_snapshot(Env().test_log_dir)
        except Exception as snapshot_err:
            Logger.warning(f"Admin snapshot failed try via ssh: {snapshot_err}")
            self.collect_snapshot_via_ssh(snapshot_name, nc_address)
        finally:
            assert False, "Stop and fix failure detected, execution stopped"
            # weekend_starting_days = (4, 5)                            # stop & fix disabled
            # dt = datetime.now()
            # today = dt.weekday()
            # if today not in weekend_starting_days:
            #     sleep(TIME_TO_SLEEP_TEST_LINE_STOP)
            # else:
            #     Logger.warning(f"Test Execution day is {dt.strftime('%A')}!\n"
            #                    f"Task force 24h sleep not started as weekend started and noone could check the TL!!!")
