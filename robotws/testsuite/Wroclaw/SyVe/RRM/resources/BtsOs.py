import subprocess
from time import time, sleep

from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Ssh import execute_ssh_command
from testsuite.Wroclaw.SyVe.RRM.resources.ProxySsh import execute_ssh_proxy_command
from testsuite.Wroclaw.SyVe.RRM.resources.NetWorking import (
    THREE_PINGS_THE_HOST, IP1, IP129, NMAP_FOR_HTTPS, PORT_OPEN, OFFLINE_RESP_LIST, ONLINE_RESP)
from testsuite.Wroclaw.SyVe.RRM.resources.VmOs import VmOs
from testsuite.Wroclaw.SyVe.RRM.resources.bsh_interface import execute_ssh_command_on_bsh

COMMAND_TIMEOUT = 60


class BtsOs:
    def __init__(self, vm_connection_details=None):
        self._vm_connection_details = vm_connection_details
        self._bts_connection_data = Env.GNB_SSH_CONNECTION_DETAILS

    def get_uboot_env_active_partition(self):
        active_partition = self._execute_command("uboot_env get active_partition")
        return active_partition

    def get_running_partition(self):
        running_partition = self._execute_command("readlink -f /ffs/run")
        return running_partition

    def assert_running_and_active_partition(self):
        assert self.get_uboot_env_active_partition()[-1] == self.get_running_partition()[-1], \
            f"Active partition is not the same as running partition on bts at " + \
            f"vm with address: {self._vm_connection_details.addr}." if self._vm_connection_details else "local vm"

    def config_reset(self):
        self.assert_running_and_active_partition()
        self.remove_config()
        self.reboot_bts()

    def reboot_bts(self):
        self._execute_command("reboot")
        self._wait_for_bts_restart()

    def is_bts_unreachable_via_lmp(self):
        unreachable = self._is_bts_unreachable_via_lmp()
        if unreachable:
            Logger.warning("BTS is unreachable via LMP or Local Network is unstable")
        return unreachable

    def _is_bts_unreachable_via_lmp(self):
        ping_ip_1_output = self._execute_command_on_vm(THREE_PINGS_THE_HOST.format(IP1))
        ping_ip_129_output = self._execute_command_on_vm(THREE_PINGS_THE_HOST.format(IP129))
        return any(map(lambda msg: msg in ping_ip_1_output, OFFLINE_RESP_LIST)) and \
            any(map(lambda msg: msg in ping_ip_129_output, OFFLINE_RESP_LIST))

    def is_bts_unreachable_via_mplane(self, ip):
        ping_output = self._execute_command_on_vm(THREE_PINGS_THE_HOST.format(ip))
        if ONLINE_RESP not in ping_output:
            Logger.warning(f"Network may be unstable, received MPLANE ping output: {ping_output}")
        return any(map(lambda msg: msg in ping_output, OFFLINE_RESP_LIST))

    def is_https_connection_open(self):
        return PORT_OPEN in self._execute_command_on_vm(NMAP_FOR_HTTPS.format(IP129))

    def remove_config(self):
        remove_bts_config_dir_cmd = "rm -rf /rom/config/"
        self._execute_command(remove_bts_config_dir_cmd)

    def get_current_sw_version(self):
        cmd = "basename /rom/TargetBD_*.xml"
        output, _ = self._execute_command(cmd)
        return output.replace("TargetBD_", "").replace(".xml", "")

    def collect_snapshot(self, snapshot_name, nc_address=0):
        return self._execute_command(f"echo 'log -a -z /ram{snapshot_name}' | nc {nc_address} 15007")

    def get_network_interface_list_on_bb_module(self):
        arp_output, arp_error = self._execute_command("arp -a")
        Logger.debug(f'arp -a output was: {arp_output}')
        Logger.debug(f'arp -a errors were: {arp_error}')
        return arp_output.split('\n')

    def get_current_minute(self):
        return int(self._execute_command("date +%M")[0])

    def get_epoch(self):
        return int(self._execute_command("date +%s")[0])

    def get_slice_aware_log_line(self, bsh_number="1:1"):
        command = "zgrep actCellSliceAwareScheduler /tmp/node_L2RT20/tmp/ASP-1740_startup*"
        output, error = execute_ssh_command_on_bsh(smod_ssh_connection_parameters=self._bts_connection_data,
                                                   bsh_number=bsh_number,
                                                   command=command)
        return None if error else output

    def get_uptime_in_seconds(self):
        return float(self._execute_command("cat /proc/uptime")[0].split()[0])

    def get_passive_sw_version(self):
        return self._execute_command('ls /ffs/stb/TargetBD*.xml | grep -Eo "(SBTS.*ENB_.*_[0-9]*)"')

    def get_active_sw_version(self):
        return self._execute_command('ls /ffs/run/TargetBD*.xml | grep -Eo "(SBTS.*ENB_.*_[0-9]*)"')

    def get_passive_and_active_software_version(self):
        passive_sw_version = self.get_passive_sw_version()
        active_sw_version = self.get_active_sw_version()
        return 'Passive sw version: {} Active sw version: {}'.format(passive_sw_version, active_sw_version)

    def _wait_for_bts_restart(self):
        Logger.debug("Waiting for bts to be unreachable via lmp.")
        self._wait_for_unpingable_lmp()
        Logger.debug("Bts is down. Waiting for https port to open.")
        self._wait_for_https_connection()
        Logger.debug(f"Https port on address: {IP129} is open.")

    def _wait_for_unpingable_lmp(self):
        self._wait(self._is_bts_unreachable_via_lmp)

    def _wait_for_https_connection(self):
        self._wait(self.is_https_connection_open)

    @staticmethod
    def _wait(wait_for_expected_change, timeout=5*60, interval=5):
        start_time = time()
        while start_time + timeout > time():
            sleep(interval)
            if wait_for_expected_change():
                return
        raise AssertionError(f"Timeout: {wait_for_expected_change.__name__} {timeout // 60}m.")

    def _execute_command(self, cmd, execution_timeout=COMMAND_TIMEOUT):
        if not self._vm_connection_details:
            return self._execute_command_directly(cmd, execution_timeout)
        else:
            return self._execute_command_remotely(cmd, execution_timeout)

    def _execute_command_remotely(self, cmd, execution_timeout):
        return execute_ssh_proxy_command(self._vm_connection_details, self._bts_connection_data, cmd,
                                         execution_timeout, look_for_keys=True)

    def _execute_command_directly(self, cmd, execution_timeout):
        return execute_ssh_command(self._bts_connection_data, cmd, execution_timeout, look_for_keys=True)

    def _execute_command_on_vm(self, cmd, execution_timeout=COMMAND_TIMEOUT):
        if not self._vm_connection_details:
            try:
                return VmOs.execute_single_command_in_shell(cmd)
            except subprocess.CalledProcessError as err:
                return err.output.decode("utf-8")
        else:
            output, err = execute_ssh_command(self._vm_connection_details, cmd, execution_timeout, look_for_keys=True)
            return output if err == "" else err
