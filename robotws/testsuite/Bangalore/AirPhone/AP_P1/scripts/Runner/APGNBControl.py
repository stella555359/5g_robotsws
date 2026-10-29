from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.transport.ssh.exceptions import ConnectFailedError
import time
import re
import subprocess
import functools
import argparse
import os
from retrying import retry
from errors import ADETTimeout, RadioNotInstalled, retry_if_ap_failed_startup
from robot.libraries.BuiltIn import BuiltIn
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru


class APGNBControl():
    AP_IP = '192.168.200.1'
    GNB_IP = '192.168.255.129'
    AP_CRASH_LOGS_PATH = '/ffs/run/logs'
    GNB_CRASH_LOGS_PATH = '/ffs/run/logs'
    AP_PARTITION_PATH = '/ffs'
    AP_ADET = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n {}'
    GNB_ADET = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -n {}'
    L1B_DICT_MAP = {'2_nodes': '0x224D:0x574A,0x234D:0x584A',
                    '3_nodes': '0x224D:0x574A,0x225D:0x594A,0x234D:0x584A'}

    def __init__(self):
        self.ssh = ssh()
        self.admin = admin()

    def login_to_ap(self):
        try:
            self.ssh.connect_to(self.AP_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='AP')
        except ConnectFailedError as e:
            loguru.logger.info('SSH Login To AP Failed with error {}'.format(str(e)))
            return False
        return True

    def login_to_gnb(self):
        try:
            self.ssh.connect_to(self.GNB_IP, 'toor4nsn', 'oZPS0POrRieRtu', alias='GNB')
        except ConnectFailedError as e:
            loguru.logger.info('SSH Login To GNB Failed with error {}'.format(str(e)))
            return False
        return True

    def disconnect_ap(self):
        try:
            self.ssh.disconnect(connection='AP')
        except Exception as e:
            pass
        return

    def disconnect_gnb(self):
        try:
            self.ssh.disconnect(connection='GNB')
        except Exception as e:
            pass
        return

    def gnb_ssh_connection(func):
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            try:
                if self.login_to_gnb():
                    return func(self, *args, **kwargs)
            finally:
                self.disconnect_gnb()
        return wrapper

    def ap_ssh_connection(func):
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            try:
                if self.login_to_ap():
                    return func(self, *args, **kwargs)
            finally:
                self.disconnect_ap()
        return wrapper

    def gnb_admin_connection(func):
        @functools.wraps(func)
        def wrapper(self, *args, **kwargs):
            try:
                self.admin.connect_to()
                return func(self, *args, **kwargs)
            finally:
                self.admin.teardown()
        return wrapper

    @ap_ssh_connection
    def reboot_ap(self):
        self.ssh.send_command('system-module-reboot', connection='AP')
        loguru.logger.info('Succesfully Rebooted AP as part of recovery.')
        return

    @gnb_ssh_connection
    def reboot_gnb(self):
        self.ssh.send_command('system-module-reboot', connection='GNB')
        loguru.logger.info('Succesfully Rebooted GNB as part of recovery.')
        return

    def timed_wait_task(timeout, step_time):
        def inner(func):
            @functools.wraps(func)
            def wrapper(self, *args, **kwargs):
                initial_time = current_time = time.time()
                while (current_time - initial_time) < timeout:
                    if func(self, *args, **kwargs):
                        return True
                    time.sleep(step_time)
                    current_time = time.time()
                loguru.logger.info('{} Got timedout waiting for {}'.format(func.__name__, timeout))
                return False
            return wrapper
        return inner

    def check_adet_ready(self):
        self.wait_for_ap_ready()
        self.wait_for_gnb_ready()
        return

    def is_units_ready(self, adet_output, connection):
        loguru.logger.info("Checking for {0} units ready..".format(connection))
        units_out = re.findall(r'FSM[\d]_[A-Z0-9].*', adet_output)
        loguru.logger.info("{0} units status..\n {1}".format(connection, units_out))
        return all('ready' in node for node in units_out)

    def is_nodes_ready(self, adet_output, connection):
        loguru.logger.info("Checking for {0} Nodes ready..".format(connection))
        nodes = re.findall(r'\[0x\d*].*', adet_output)
        loguru.logger.info("{0} nodes status..\n {1}".format(connection, nodes))
        expected_states = ['ready', 'sleep']
        return all(node.split(" ")[1].replace('\r', '') in expected_states for node in nodes)

    @ap_ssh_connection
    @timed_wait_task(timeout=300, step_time=30)
    def wait_for_ap_ready(self):
        loguru.logger.info('Checking ADET Ready on AP')
        nodeid = self.ssh.execute("ownnid", connection='AP')
        adet_output = self.ssh.execute(self.AP_ADET.format(nodeid), connection='AP')
        if self.is_units_ready(adet_output, 'AP') and self.is_nodes_ready(adet_output, 'AP'):
            loguru.logger.info('ADET is Ready for AP')
            return True
        return False

    @gnb_ssh_connection
    @timed_wait_task(timeout=300, step_time=30)
    def wait_for_gnb_ready(self, timeout=600):
        loguru.logger.info('Checking ADET Ready on GNB.')
        nodeid = self.ssh.execute("ownnid", connection='GNB')
        adet_output = self.ssh.execute(self.GNB_ADET.format(nodeid), connection='GNB')
        if self.is_units_ready(adet_output, 'GNB') and self.is_nodes_ready(adet_output, 'GNB'):
            loguru.logger.info('ADET is Ready for GNB')
            return True
        return False

    @gnb_admin_connection
    @timed_wait_task(timeout=300, step_time=30)
    def check_gnb_state_configured(self, timeout=600):
        loguru.logger.info('Checking If GNB State is ready.')
        bts_state = self.admin.get_mrbts_state()
        if bts_state in ['Configured', 'OnAir', 'IntegratedToRan']:
            loguru.logger.info('BTS State is {}'.format(bts_state))
            return True
        return False

    @gnb_admin_connection
    @timed_wait_task(timeout=300, step_time=30)
    def check_gnb_radio_online_state(self, timeout=600):
        loguru.logger.info('Checking If Radio State is Online.')
        rmod = self.admin.get_bts_info()['radioModules']['rmod']
        if rmod:
            if rmod[0]['status']['operationalState'] == 'enabled':
                loguru.logger.info('Radio State is {}'.format(rmod[0]['status']['operationalState']))
                return True
        return False

    def wait_for_ap_to_be_reachable(self):
        self.wait_for_node_to_be_reachable(self.AP_IP)
        return

    def wait_for_ap_to_go_down(self):
        self.wait_for_ap_to_be_down()
        return

    def wait_for_ap_to_be_down(self):
        self.wait_for_node_to_be_down(self.AP_IP)
        return

    def wait_for_gnb_to_be_down(self):
        self.wait_for_node_to_be_down(self.GNB_IP)
        return

    @timed_wait_task(timeout=120, step_time=10)
    def wait_for_node_to_be_down(self, ip, timeout=120):
        loguru.logger.info('Wait For {} to go down.'.format(ip))
        if subprocess.call('ping -c 1 {} > /dev/null 2>&1'.format(ip), shell=True) != 0:
            loguru.logger.info('Node {} is now down'.format(ip))
            return True
        return False

    @timed_wait_task(timeout=240, step_time=20)
    def wait_for_node_to_be_reachable(self, ip, timeout=180):
        loguru.logger.info('Wait For {} to be reachable.'.format(ip))
        if subprocess.call('ping -c 5 {} > /dev/null 2>&1'.format(ip), shell=True) == 0:
            loguru.logger.info('Node {} is now reachable'.format(ip))
            return True
        return False

    def check_and_enbale_l1b_mapping(self, suite_name):
        status = self.l1b_mapping(suite_name)
        if status:
            loguru.logger.info('Reboting GNB after l1bypass Mapping.')
            self.reboot_gnb()
            self.wait_for_gnb_to_be_down()
            time.sleep(60)
        return

    def update_l1b_mapping(self, expected_map, output_map, dict_key):
        if expected_map == output_map:
            loguru.logger.info('L1B Mapping is already present for {}...'.format(dict_key))
            return False

        else:
            loguru.logger.info('Updating L1B Mapping for {}...'.format(dict_key))
            output = self.ssh.execute(
                "echo 'tag -3w app.btsom.nts.L1BypassMap {}' | nc 0 15007".format(
                    self.L1B_DICT_MAP[dict_key]), connection='GNB')
            tag_output = output.encode('ascii').replace('AaShell>', '').replace('\r\r\n', '').strip()
            loguru.logger.info('L1B Mapping command output : {}'.format(tag_output))
            return True
        return

    @gnb_ssh_connection
    def l1b_mapping(self, suite_name):
        l1bmap_output_two_nodes = "app.btsom.nts.L1BypassMap = {}".format(self.L1B_DICT_MAP['2_nodes'])
        l1bmap_output_three_nodes = "app.btsom.nts.L1BypassMap = {}".format(self.L1B_DICT_MAP['3_nodes'])

        loguru.logger.info('Check and Update L1B Mapping...')
        output = self.ssh.execute("echo 'tag -3r app.btsom.nts.L1BypassMap' | nc 0 15007", connection='GNB')
        tag_output = output.encode('ascii').replace('AaShell>', '').replace('\r\r\n', '').strip()

        if "5GC001167" in suite_name:
            status = self.update_l1b_mapping(l1bmap_output_three_nodes, tag_output, '3_nodes')
            return status
        else:
            status = self.update_l1b_mapping(l1bmap_output_two_nodes, tag_output, '2_nodes')
            return status
        return

    @retry(retry_on_exception=retry_if_ap_failed_startup, stop_max_attempt_number=2,
           wait_fixed=5000, wrap_exception=False)
    def reboot_ap_and_recover(self):
        self.reboot_ap()
        self.wait_for_ap_to_go_down()
        self.wait_for_ap_to_be_reachable()
        self.check_adet_ready()
        if not self.check_gnb_state_configured():
            self.reboot_gnb_with_admin()
        if not self.check_gnb_radio_online_state():
            self.reboot_gnb_with_admin()
            raise RadioNotInstalled()
        return

    @retry(retry_on_exception=retry_if_ap_failed_startup, stop_max_attempt_number=2,
           wait_fixed=5000, wrap_exception=False)
    def reboot_gNB_and_clean_env(self):
        self.reboot_gnb_with_admin()
        self.wait_for_gnb_to_be_down()
        self.wait_for_ap_to_go_down()
        self.wait_for_ap_to_be_reachable()
        self.check_adet_ready()
        if not self.check_gnb_state_configured():
            self.reboot_gnb_with_admin()
        if not self.check_gnb_radio_online_state():
            self.reboot_gnb_with_admin()
            raise RadioNotInstalled()
        return

    @gnb_admin_connection
    def reboot_gnb_with_admin(self):
        loguru.logger.info('Reboot via the ADMIN CLI.')
        output = self.admin.reset(reset_coverage='Site', wait_for_reconnection=True, timeout=600, connection='default')
        return

    def get_airphone_crash_logs(self, connection):
        command = r"find {} -type f \( -name '*0x*' -not -name '*_rpramjournal*' -o -name '*core*' \)".\
            format(self.AP_CRASH_LOGS_PATH)
        crash_logs_status = self.ssh.execute(command=command, connection=connection).replace('\r\n', '\n')
        return crash_logs_status

    @ap_ssh_connection
    def get_airphone_active_standby_partition(self):
        command = f"ls -l {self.AP_PARTITION_PATH}"
        output = self.ssh.execute(command=command, connection='AP')
        active_partition = None
        standby_partition = None

        for line in output.splitlines():
            if line.startswith("l") and "->" in line:
                left, right = line.split("->")
                link_name = left.split()[-1]
                target_partition = right.strip().split("/")[-1]

                if link_name == "run":
                    active_partition = target_partition
                elif link_name == "stb":
                    standby_partition = target_partition

        return active_partition, standby_partition

    @ap_ssh_connection
    def get_DDAL_RETURN_VALUE(self):
        command = (r"ddal -s ddal_boot_get_reset_loop_count").format(self.AP_PARTITION_PATH)
        output = self.ssh.execute(command=command, connection='AP').replace('\r\n', '\n')
        ddal_return_value = None
        val = None
        for line in output.splitlines():
            line = line.strip()
            if line.startswith("DDAL_RETURN_VALUE="):
                ddal_return_value = line.split("=")[1].strip()
            elif line.startswith("val="):
                val = line.split("=")[1].strip()

        return ddal_return_value, val

    @ap_ssh_connection
    def get_airphone_coredumper_logs(self):
        command = (r"find {} -type f").format(self.AP_CRASH_LOGS_PATH)
        all_files = self.ssh.execute(command=command, connection='AP').replace('\r\n', '\n').strip().split('\n')
        valid_files = [f for f in all_files if f.endswith('_core_log.txt')]
        invalid_files = [f for f in all_files if not f.endswith('_core_log.txt')]
        keywords = ('core', 'crash', 'dumps')
        filtered_invalid_files = [
            f for f in invalid_files
            if any(kw in f.lower() for kw in keywords) and 'dummy' not in f.lower()
        ]
        if filtered_invalid_files:
            BuiltIn().log("Crash log found in AP: {}".format(filtered_invalid_files), "ERROR")
        return filtered_invalid_files

    @ap_ssh_connection
    def log_airphone_crash_logs(self):
        crash_logs_collected = self.get_airphone_crash_logs(connection='AP')
        if crash_logs_collected:
            BuiltIn().log("Crash log found in AP: {}".format(crash_logs_collected), "WARN")
        return

    def get_gnb_crash_logs(self, connection):
        command = r"find {} -type f \( -name '*0x*' -not -name '*_rpramjournal*' -o -name '*core*' \)".\
            format(self.GNB_CRASH_LOGS_PATH)
        crash_logs_status = self.ssh.execute(command=command, connection=connection).replace('\r\n', '\n')
        return crash_logs_status

    @gnb_ssh_connection
    def get_gnb_coredumper_logs(self):
        command = (r"find {} -type f").format(self.GNB_CRASH_LOGS_PATH)
        all_files = self.ssh.execute(command=command, connection='GNB').replace('\r\n', '\n').strip().split('\n')
        valid_files = [f for f in all_files if f.endswith('_core_log.txt')]
        invalid_files = [f for f in all_files if not f.endswith('_core_log.txt')]
        keywords = ('core', 'crash', 'dumps')
        filtered_invalid_files = [
            f for f in invalid_files
            if any(kw in f.lower() for kw in keywords) and 'dummy' not in f.lower()
        ]
        if filtered_invalid_files:
            BuiltIn().log("Crash log found in GNB: {}".format(filtered_invalid_files), "ERROR")
        return filtered_invalid_files

    @gnb_ssh_connection
    def log_gnb_crash_logs(self):
        crash_logs_collected = self.get_gnb_crash_logs(connection='GNB')
        if crash_logs_collected:
            BuiltIn().log("Crash log found in GNB: {}".format(crash_logs_collected), "WARN")
        return

    @ap_ssh_connection
    def ap_wts_config_backup(self, output_dir):
        os.system("scp {0}:/ffs/run/swconfig.txt {1} >/dev/null 2>&1".format(self.AP_IP, output_dir))
        os.system("scp {0}:/ffs/run/simmode/iphy.xml {1} >/dev/null 2>&1".format(self.AP_IP, output_dir))
        os.system("{0} {1}".format('ls /opt/wts/latest/*.cfg | grep -v sosReport.cfg | xargs cp -t', output_dir))
        return

    @gnb_ssh_connection
    def gnb_config_backup(self, output_dir):
        os.system("scp {0}:/ffs/run/swconfig.txt {1} >/dev/null 2>&1".format(self.GNB_IP, output_dir))
        os.system("scp {0}:/ffs/run/TargetBD*xml {1} >/dev/null 2>&1".format(self.GNB_IP, output_dir))
        return

    @gnb_admin_connection
    def get_coam_scf(self, output_dir, file_name='scf.xml', timeout=60):
        scf_dir_path = self.admin.get_current_scf_file(output_dir, file_name, timeout=timeout)
        return scf_dir_path

    @gnb_ssh_connection
    def reset_reboot_count_on_gnb(self):
        output = self.ssh.execute('set -m ; ddal -s ddal_boot_set_reset_loop_count 0', connection='GNB')
        loguru.logger.info('Output of the reset count command : {}'.format(output))
        output = self.ssh.execute('set -m ; ddal -s ddal_boot_get_reset_loop_count', connection='GNB')
        loguru.logger.info('Value of the reset count in gNB : {}'.format(output))
        loguru.logger.info('Succesfully Reset Count on GNB as part of recovery.')


# The arguments will be parsed from jentkins
def get_args():
    parser = argparse.ArgumentParser(description='Parameters to be passed for l1bypass Mapping')
    parser.add_argument('--suite', required=True, help='TestSuite folder.')
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = get_args()
    APGNBControl().check_and_enbale_l1b_mapping(args.suite)
