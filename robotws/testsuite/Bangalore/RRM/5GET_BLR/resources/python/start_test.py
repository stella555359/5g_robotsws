#!/usr/bin/env python
import os
import paramiko
import socket
import sys
import subprocess
import zipfile
import time
import re
from re import sub
import yaml
import pexpect
import stat
import shlex
from time import sleep
from shutil import move, rmtree, copytree, copy
from xml.dom import minidom

#  Author Krakow team.
#  modified and Maintaining by vivek.gv@nokia.com


class TestExecutor(object):
    enb_ip = '192.168.255.1'
    enb_user = 'toor4nsn'
    enb_pass = 'oZPS0POrRieRtu'
    FSMr3_cpu_rachitectures = ["mips64"]
    FSMr4_cpu_rachitectures = ["armv7l", "aarch64"]
    FSMr6_cpu_rachitectures = ["x86_64"]
    LOGDIR = 'Logs'
    remote_logs_location = \
        os.path.join("/", "home", "ute", "rotta", "Rotta4internal_5G", "BLR_5GET", "Regression", "manual_runs")
    report_logs_location = \
        '\\eseefsn50.emea.nsn-net.net\\rotta4internal\\Rotta4internal_5G\\BLR_5GET\\Regression\\manual_runs'
    tmp_logs_location = os.path.join("/", "home", "ute", "LOGS", "CRT_MANUAL_RUNS")
    os.system('mkdir ' + tmp_logs_location)
    os.system('sudo mkdir /mnt/syve')
    logs_dir = None
    qc_path = '/home/ute/robotlte/testsuite/WMP/GVe/Bangalore/PS_SyVe/resources/qc.conf'
    labels = ['5GET', 'PUBS_RF_LAA_R4']
    local_logs = None

    def __init__(self):
        self.sw_release = None
        self.sw_version = None
        self.hw_platform = None
        self.robot_file_path = None
        self.app_server_ssh = None
        self.feature = None
        self.result = None
        self.date = None
        self.detect_sw_version_and_hw_platform()
        self.report_destination_dir_passed = None
        self.is_passed = None
        self.label = None

    def _get_connected_paramiko_client(self, hostname, username, password):
        try:
            ssh_client = paramiko.SSHClient()
            ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            ssh_client.connect(hostname=hostname, username=username,
                               password=password, allow_agent=False, look_for_keys=False)
        except Exception as e:
            print(("[Connecting to {}] Problem with connection to {}: {})".format(hostname, hostname, e)))
            sys.exit()
        return ssh_client

    def ssh_send_cmd_and_return_output(self, ssh_client, command, timeout=10):
        """ tbc """
        output = ''
        stdin, stdout, stderr = ssh_client.exec_command(command, timeout=timeout)
        try:
            for line in iter(stdout.readline, ''):
                output = "".join((output, line))
        except socket.timeout:
            print(('[send to RP][Checking enb build] socket timeout in stdout when executing \'%s\'' % command))
            sys.exit()
        else:
            return output

    def detect_sw_version_and_hw_platform(self):
        ssh_client = \
            self._get_connected_paramiko_client(hostname=self.enb_ip, username=self.enb_user, password=self.enb_pass)

        if ssh_client.get_transport().is_active():
            output = self.ssh_send_cmd_and_return_output(ssh_client, 'ls -1 /rom/')
            match = re.search('TargetBD_(\\w+)\\.xml', output)

            if match:
                self.sw_version = match.group(1)
            else:
                print("[send to RP][eNB SSH] Cannot detect eNB build!. Exiting")
                sys.exit()
        if ssh_client.get_transport().is_active():
            read_cpu_architecture = self.ssh_send_cmd_and_return_output(ssh_client, 'lscpu | grep Architecture')
            fsmr3 = False
            fsmr4 = False
            fsmr6 = False
            for cpu in self.FSMr3_cpu_rachitectures:
                if cpu in read_cpu_architecture:
                    fsmr3 = True
                    break
            for cpu in self.FSMr4_cpu_rachitectures:
                if cpu in read_cpu_architecture:
                    fsmr4 = True
                    break
            for cpu in self.FSMr6_cpu_rachitectures:
                if cpu in read_cpu_architecture:
                    fsmr6 = True
                    break
            if fsmr3 and fsmr4 and fsmr6:
                print("[send to RP][Checking enb HW_PLATFORM] Could not determine eNB HW HW_PLATFORM. Exiting")
                sys.exit()
            elif not fsmr3 and not fsmr4 and not fsmr6:
                print("[send to RP][Checking enb HW_PLATFORM] Cannot find eNB HW HW_PLATFORM. Exiting")
                sys.exit()
            elif fsmr3:
                self.hw_platform = "FSMr3"
            elif fsmr4:
                self.hw_platform = "FSMr4"
            elif fsmr6:
                self.hw_platform = "FSMr6"
            else:
                print("[send to RP][Checking enb HW_PLATFORM] Unknown error. Exiting")
                sys.exit()
        else:
            print("[send to RP][Checking enb build] SSH connection to eNB is not active. Exiting")
            sys.exit()
        if self.sw_version and self.hw_platform:
            return (self.sw_version, self.hw_platform)
        else:
            print("[send to RP][Checking enb SW_VERSION and HW_PLATFORM] Unknown error. Exiting")
            sys.exit()

    def detect_sw_release(self):
        banner_text = "Manually set SW RELEASE"
        if self.sw_release is None:
            if self.sw_version is None:
                self.detect_sw_version_and_hw_platform()
            try:
                match = re.search("^([^_]+)", self.sw_version)
                self.sw_release = match.group(1)
            except Exception:
                print("[send to RP][Checking enb SW_RELEASE] Could not recognize SW_RELEASE from SW_VERSION:\'%s\'. \
                Exiting" % self.sw_version)
                sys.exit()
            banner_text = "  Detected SW RELEASE  "
        print("""###########################################################
######### %s: %12s   #########
###########################################################""" % (banner_text, self.sw_release))
        return self.sw_release

    def get_vm_hostname(self):
        return socket.gethostname().upper()

    def get_config_dir(self):
        return self.get_vm_hostname().replace('-', '_')

    def get_logs_dir(self, robot_file_path):
        base_name = os.path.basename(robot_file_path)
        match = re.search('(.+)\\.robot', base_name)
        if match:
            return match.group(1)
        else:
            print("[starting robot test] Cannot resolve logs dir! Check if provided test file has *.robot extension")
            sys.exit()

    def create_rp_tl_name(self, organization_code=1, site_code='2'):
        hostname = self.get_vm_hostname()
#        return "%s_%s_%s" % (organization_code, site_code, hostname.replace('-', '_'))
        return hostname.replace('-', '_')

    def get_qc_file_path(self):
        current_file = os.path.dirname(__file__)
        realPath = os.path.realpath(current_file)
        base_name = os.path.basename(realPath)
        if self.hw_platform is None:
            print("[send to RP][creating qc file path] Unknown HW PLATFORM")
        return base_name + "_" + self.hw_platform + '.qc'

    def execute_cmd(self, command):
        print("Executing: ", command)
        return_code = subprocess.call(command, shell=True)
        return return_code

    def detect_feature(self, robot_file_path):
        path, file = os.path.split(robot_file_path)
        match = re.search("^([^._-]+)", file)
        self.feature = match.group(1)

    def start_robot_test(self, perform_commissioning=False, local_logs=False):
        cmd_elements = []
# vgv        cmd_elements.append('robot --variable CONFIGURATION:Bangalore.1_2_CLOUD450 -b debug.log -L trace ')
        cmd_elements.append('robot')
        self.date = time.strftime("%Y-%m-%d_%H-%M-%S")

        if local_logs:
            self.logs_dir = self.get_logs_dir(self.robot_file_path)
            if os.path.exists(self.logs_dir):
                rmtree(self.logs_dir)
        else:
            if self.feature is None:
                self.detect_feature(self.robot_file_path)
            if os.path.exists(self.tmp_logs_location):
                rmtree(self.tmp_logs_location)
            os.makedirs(self.tmp_logs_location)
            self.logs_dir = self.tmp_logs_location
        cmd_elements.extend(['-d', self.logs_dir])
        cmd_elements.extend(['--loglevel', 'TRACE'])
#        robot_configuration = 'CONFIGURATION:' + os.getenv('UTE_CONFIGURATION') + ' -b debug.log '
        robot_configuration = \
            '/home/ute/testline_configuration/' + socket.gethostname().upper().replace("-", "_") + '/'
        cmd_elements.extend(['-b debug.log  -V', robot_configuration])
        if perform_commissioning:
            cmd_elements.extend(['--variable', 'PERFORM_COMMISSIONING:true'])
        cmd_elements.extend(['-v', 'SW_RELEASE:%s' % self.sw_release])
        cmd_elements.extend([' -v ENB_BUILD:' + self.parse_build_to_report() + ' -v ENB_BRANCH:5G'])
        cmd_elements.extend([' -C on '])
        cmd_elements.append(self.robot_file_path)

        command = ' '.join(cmd_elements)
        self.qc_path = self.robot_file_path.replace(".robot", ".qc")
        self.execute_cmd(command)

    def _make_build_trunk(self, branch_build):
        branch_appender = sub(r"[a-zA-Z]+(\d+[a-zA-Z\d]*)(_FSM\d)?.*", r'\1', branch_build)
        trunk_build = branch_build.replace(branch_appender, '00', 1)
        return trunk_build

    def parse_build_to_report(self):
        build_name = self.sw_version
        if '_ENB_9999_' in build_name:
            trunk_build_name = self._make_build_trunk(build_name)
            return trunk_build_name
        else:
            return build_name

    def report_test_to_RP(self):
        cmd_elements = []
        cmd_elements.append('ute_reporting_portal')
        cmd_elements.append('send')
        output_xml_path = self.logs_dir + '/' + 'output.xml'
        cmd_elements.extend(['-ro', output_xml_path])
        cmd_elements.extend(['-tl', self.create_rp_tl_name()])
        cmd_elements.extend(['-l', self.label])
        cmd_elements.extend(['--sw_version', self.parse_build_to_report()])
        cmd_elements.extend(['-qc', self.qc_path])
        cmd_elements.extend(['--log_link', self.report_destination_dir_passed.replace("/", "\\")])
# vgv        cmd_elements.extend(['--log_link', self.report_destination_dir_passed])
        command = ' '.join(cmd_elements)
        print("\n\n")
        self.execute_cmd(command)

    def parse_xml_file(self, path):
        path_xml = os.path.join(path, "output.xml")
        if os.path.exists(path_xml):
            mytree = minidom.parse(path_xml)
            tagname = mytree.getElementsByTagName('stat')[2]
            result = tagname.attributes['fail'].value
            return(result)
        else:
            return("1")

    def remove_logs(self, path_of_logs_folders, list_of_subfolders):
        list_of_logs_to_remove = []
        pass_counter = 0
        for logs_folder in list_of_subfolders:
            path_for_logs_folder = os.path.join(path_of_logs_folders, logs_folder)
            list_of_logs_to_remove.append(path_for_logs_folder)
            if (self.parse_xml_file(path_for_logs_folder) == "0"):
                pass_counter += 1
        sorted_logs = sorted(list_of_logs_to_remove, key=os.path.getmtime)
        if (self.parse_xml_file(sorted_logs[0]) == "0" and pass_counter <= 1):
            rmtree(sorted_logs[1])
        else:
            rmtree(sorted_logs[0])

    def remove_Pass_Failed_logs(self, directory_path):
        Failed_list_of_subfolders = []
        Passed_list_of_subfolders = []
        max_num_of_Passed_logs = 7
        max_num_of_Failed_logs = 3
        Pass_log_count = 0
        Fail_log_count = 0
        list_of_subfolders = os.listdir(directory_path)
        for log_file in list_of_subfolders:
            if log_file.find("PASSED_"):
                Fail_log_count += 1
                Failed_list_of_subfolders.append(directory_path + "/" + log_file)
            else:
                Pass_log_count += 1
                Passed_list_of_subfolders.append(directory_path + "/" + log_file)
        Passed_list_of_subfolders1 = sorted(Passed_list_of_subfolders, key=os.path.getmtime)
        Failed_list_of_subfolders1 = sorted(Failed_list_of_subfolders, key=os.path.getmtime)
        if len(Passed_list_of_subfolders) > max_num_of_Passed_logs:
            for i in range(0, len(Passed_list_of_subfolders)-max_num_of_Passed_logs, 1):
                print("-" * 100)
                print("Old Passed Log removed=", Passed_list_of_subfolders1[i])
                rmtree(Passed_list_of_subfolders1[i])
        if len(Failed_list_of_subfolders) > max_num_of_Failed_logs:
            for i in range(0, len(Failed_list_of_subfolders)-max_num_of_Failed_logs, 1):
                print("-" * 100)
                print("Old Failed Log removed=", Failed_list_of_subfolders1[i])
                rmtree(Failed_list_of_subfolders1[i])

    def logs_organization(self):
        destination_dir = os.path.join(self.remote_logs_location, self.sw_release, self.feature, self.date)
        destination_dir_passed = \
            os.path.join(self.remote_logs_location, self.sw_release,
                         self.feature, "{}_{}".format("PASSED", self.date))
        self.report_destination_dir_passed = \
            os.path.join(self.report_logs_location, self.sw_release,
                         self.feature, "{}_{}".format("PASSED", self.date))
        print ('\n log_path \n' + self.report_destination_dir_passed + '\n\n')

        move_logs = copytree(self.logs_dir, destination_dir)
        directory_path = os.path.join(self.remote_logs_location, self.sw_release, self.feature)
        self.is_passed = True if self.parse_xml_file(destination_dir) == "0" else False
        print ("-----------BLR_ET disk location-----------")
        if self.is_passed:
            os.rename(destination_dir, destination_dir_passed)
            print("Output:   " + os.path.join(destination_dir_passed, "output.xml"))
            print("Log:      " + os.path.join(destination_dir_passed, "log.html"))
            print("Report:   " + os.path.join(destination_dir_passed, "report.html"))
        else:
            print("Output:   " + os.path.join(destination_dir, "output.xml"))
            print("Log:      " + os.path.join(destination_dir, "log.html"))
            print("Report:   " + os.path.join(destination_dir, "report.html"))

        self.remove_Pass_Failed_logs(directory_path)

    def execute_and_report_test(self, robot_file_path, perform_commissioning=False, skip_report=False,
                                gather_rtg_logs=False, local_logs=False, pcap_logs=False, zip_logs=False):
        # if local_logs is False:
        #    self._remount_mnt_pubs()
        self.local_logs = local_logs

        if gather_rtg_logs:
            syslog_process, pcap_process = self.start_gathering_rtg_logs()
        if pcap_logs:
            self.start_gathering_pcap_logs()
        self.robot_file_path = robot_file_path
        self.start_robot_test(perform_commissioning=perform_commissioning, local_logs=local_logs)
        if pcap_logs:
            self.stop_gathering_pcap_logs()
        if not local_logs:
            self.parse_xml_file(self.logs_dir)
            self.logs_organization()
        if zip_logs and local_logs:
            self.zip_logs_locally()
        elif zip_logs:
            self.zip_logs_remotely()
        if not skip_report and self.is_passed and not self.local_logs:
            self.report_test_to_RP()
        if gather_rtg_logs:
            self.stop_gathering_rtg_logs(syslog_process=syslog_process, pcap_process=pcap_process)

    def zip_logs_locally(self):
        path = self.get_logs_dir(self.robot_file_path)
        if not os.path.exists(path):
            print('[Problem with packing logs] There is no directory with robot logs !!!')
            return
        try:
            move('IPSL_log/', path)
        except Exception as exp:
            print('There is no directory with IPSL logs.')
            print("exception", exp)

        try:
            move('PM_Counter_files/', path)
        except Exception as exp:
            print('There is no directory with PM Counters files.')
            print("exception", exp)

        if not os.path.exists(self.LOGDIR) or not os.path.isdir(self.LOGDIR):
            try:
                os.mkdir(self.LOGDIR)
            except Exception as exp:
                print('Cannot create % directory' % self.LOGDIR)
                raise exp

        zip_local_name = self.LOGDIR + '/' + path + '_' + self.date + '.zip'
        root_name = os.path.abspath(os.getcwd())
        dst = zipfile.ZipFile(zip_local_name, 'w', zipfile.ZIP_DEFLATED)
        print("Zipping files to : %s" % root_name + "/" + zip_local_name)
        for root, dirs, files in os.walk(path):
            for file in files:
                dst.write(os.path.join(root, file))
        print("Removing files from: %s" % root_name + "/" + path + "/")
        rmtree(path)
        dst.close()
        print("Successfull ziped file.")

    def zip_logs_remotely(self):
        destination_dir = os.path.join(self.remote_logs_location, self.sw_release, self.feature, self.date)
        destination_dir_passed = \
            os.path.join(self.remote_logs_location, self.sw_release,
                         self.feature, "{}_{}".format("PASSED", self.date))

        zip_remote_name = ""
        path = ""
        if self.is_passed:
            if not os.path.exists(destination_dir_passed):
                print('[Problem with packing logs] There is no directory with robot logs !!!')
                return
            zip_remote_name = \
                os.path.join(self.remote_logs_location, self.sw_release,
                             self.feature, "{}_{}_{}".format("PASSED", "zip", self.date))
            path = destination_dir_passed

            self.report_destination_dir_passed = \
                os.path.join(self.report_logs_location, self.sw_release,
                             self.feature, "{}_{}_{}".format("PASSED", "zip", self.date))

        else:
            if not os.path.exists(destination_dir):
                print('[Problem with packing logs] There is no directory with robot logs !!!')
                return
#            zip_remote_name = os.path.join(self.remote_logs_location, self.sw_release, self.feature,
#                                           "{}_{}".format(os.path.basename(self.get_logs_dir(self.robot_file_path)),
#                                                          self.get_vm_hostname()), "{}_{}".format("zip", self.date))
            zip_remote_name = os.path.join(self.remote_logs_location, self.sw_release,
                                           self.feature, "{}_{}".format("zip", self.date))
            path = destination_dir
        if not os.path.exists(zip_remote_name) or not os.path.isdir(zip_remote_name):
            try:
                os.mkdir(zip_remote_name)
            except Exception as exp:
                print('Cannot create %s directory' % zip_remote_name)
                raise exp

        try:
            copy(path + "/" + "log.html", zip_remote_name)
            copy(path + "/" + "output.xml", zip_remote_name)
            copy(path + "/" + "report.html", zip_remote_name)
        except Exception as exp:
            print('Could not copy file to %s.' % path)
            raise exp

        zip_remote_name = zip_remote_name + "/" + "logs.zip"
        dst = zipfile.ZipFile(zip_remote_name, 'w', zipfile.ZIP_DEFLATED)
        print("\n\nZipping files to : %s" % zip_remote_name)
        for root, dirs, files in os.walk(path):
            for file in files:
                dst.write(os.path.join(root, file), file)
        print("Removing files from: %s" % path + "/")
        rmtree(path)
        dst.close()
        print("Successfull zipPed file. Location: %s" % zip_remote_name)

    def start_gathering_pcap_logs(self):
        ssh_client_pcap = self._get_connected_paramiko_client(self.enb_ip, self.enb_user, self.enb_pass)

        if ssh_client_pcap.get_transport().is_active():
            stdin, stdout, stderr = \
                ssh_client_pcap.exec_command('nohup tcpdump -i br1 sctp -w /rom/logs/X2S1_lte_backhaul.pcap -s 0',
                                             timeout=10)

    def stop_gathering_pcap_logs(self):
        ssh_client = self._get_connected_paramiko_client(hostname=self.enb_ip, username=self.enb_user,
                                                         password=self.enb_pass)

        if ssh_client.get_transport().is_active():
            stdin, stdout, stderr = ssh_client.exec_command('pkill tcpdump', timeout=10)
        sftp_client = ssh_client.open_sftp()
        sftp_client.get('/rom/logs/X2S1_lte_backhaul.pcap', os.path.join(self.logs_dir, "X2S1_backhaul.pcap"))
        sftp_client.close()

        if ssh_client.get_transport().is_active():
            stdin, stdout, stderr = ssh_client.exec_command('rm /rom/logs/X2S1_lte_backhaul.pcap', timeout=10)

    def start_gathering_rtg_logs(self):
        syslog_file_filepath = os.path.join("/", "tmp", "rtg_syslog.txt")
        command = " ".join(["sudo", "/usr/bin/python", "/usr/rtg/lib/diag/rtg_pcap.py", "-c", "1", "--sch", "--phy",
                            "--payload", "2"])
        pcap_process = pexpect.spawn(command=command, timeout=None)
        print("\n[Starting RTG logs gathering] Waiting to start pcap capture")
        pcap_process.expect('Press any key to start wireshark collection')
        pcap_process.sendline('')
        print("\n[Starting RTG logs gathering] Pcap capture started")

        print("\n[Starting RTG logs gathering] Starting syslog capture")
        with open(syslog_file_filepath, 'w') as syslog_file:
            syslog_process = subprocess.Popen(["/bin/nc", "-nul", "-p", "51601"], shell=False, stdout=syslog_file)
        return (syslog_process, pcap_process)

    def stop_gathering_rtg_logs(self, syslog_process, pcap_process):
        old_syslog_file_filepath = os.path.join("/", "tmp", "rtg_syslog.txt")
        new_syslog_file_filepath = os.path.join(self.logs_dir, "rtg_syslog.txt")
        old_pcap_file_filepath = os.path.join("/", "home", "rtg", "logs", "pcaps", "rtg_wireshark.tar.gz")
        new_pcap_file_filepath = os.path.join(self.logs_dir, "rtg_wireshark.tar.gz")
        syslog_process.kill()
        move(old_syslog_file_filepath, new_syslog_file_filepath)
        print(("\n[Stopping RTG logs gathering] Syslog process killed. Logs can be found in:  \
        {}".format(new_syslog_file_filepath)))

        pcap_process.expect('Press any key to stop wireshark collection')
        pcap_process.sendline('')
        pcap_process.expect('Captured to {}'.format(old_pcap_file_filepath))
        pcap_process.close(force=True)
        subprocess.call(["sudo", "chown", "-R", "ute:ute", os.path.dirname(old_pcap_file_filepath)])
        move(old_pcap_file_filepath, new_pcap_file_filepath)
        print(("\n[Stopping RTG logs gathering] Pcap process killed. Logs can be found in:    \
        {}".format(new_pcap_file_filepath)))


def _run_cleanup():
    process_names = ["/bin/nc", "rtg_pcap.py", "gulp"]
    for process_name in process_names:
        try:
            kill_process = subprocess.call("pkill " + process_name, shell=True)
        except OSError as e:
            print(("Cleanup failed:   {}".format(e)))


if __name__ == "__main__":
    help_string = """
    ###########################################################
    -h, --help - prints help

    Usage:

    Test without commissioning:
        ./start_test <robot_file_path>


    Test with commissioning:
        ./start_test -c <robot_file_path>
    or
        ./start_test --perform_commissioning <robot_file_path>


    Test with manually set sw release (reporting to RP and QC):
        ./start_test -r <sw_release> eg. -r FL16A
    or
        ./start_test --release <sw_release> eg. --release FL16A

    Test without report to RP and QC:
        ./start_test -s <robot_file_path>
    or
        ./start_test --skip_report <robot_file_path>

    Report to RP and QC - obligatory parametr - label for TL:
        ./start_test  --label <label> <robot_file_path> eg.  --label PUBS_RF_MBMS_2xFRIG_2_UE_R4

    Skip zipping logs after test:
        ./start_test -nz <robot_file_path>
    or
        ./start_test --no_zip <robot_file_path>

    Logging to local direction instead of remote /mnt/pubs/WMP/manual_runs:
        ./start_test -l <robot_file_path>
    or
        ./start_test --local_logs <robot_file_path>

    Gather debug logs for RTG tests (syslog + pcap):
        ./start_test -rtg <robot_file_path>
    or
        ./start_test --rtg_debug_logs <robot_file_path>

    <robot_file_path> has to match *.robot pattern
    ###########################################################
    """

    perform_commissioning = False
    skip_report = False
    robot_file_path = ''
    zip_logs = True
    gather_rtg_logs = False
    local_logs = False
    pcap_logs = False
    set_label = False

    executor = TestExecutor()
    args_list = sys.argv[1:]
    for arg in args_list:
        if arg in ['-h', '--help', '?']:
            print(help_string)
            sys.exit()
        elif arg in ['-c', '--commissioning']:
            perform_commissioning = True
        elif arg in ['-s', '--skip_report']:
            skip_report = True
        elif arg in ['-nz', '--no_zip']:
            zip_logs = False
        elif arg in ['--label']:
            current_index = args_list.index(arg)
            try:
                executor.label = args_list[current_index + 1]
                set_label = True
            except IndexError:
                print("No label provided with \'%s\' arg" % arg)
            finally:
                if executor.label not in executor.labels:
                    print("No such label: %s" % executor.label)
                    print("Choose from following labels:")
                    for label in executor.labels:
                        print(label)
                    sys.exit()
        elif arg in ['-rtg', '--rtg_debug_logs']:
            gather_rtg_logs = True
        elif arg in ['-l', '--local_logs']:
            local_logs = True
        elif arg in ['-p', '--pcap_logs']:
            pcap_logs = True
        elif arg in ['-r', '--release']:
            current_index = args_list.index(arg)
            try:
                executor.sw_release = args_list[current_index + 1]
            except IndexError:
                print("No SW release provided with \'%s\' arg" % arg)
        else:
            if args_list.index(arg) == len(args_list) - 1:
                try:
                    assert arg.endswith('.robot')
                    robot_file_path = arg
                except AssertionError as e:
                    print("Test file path has to match *.robot pattern")
                    sys.exit()
            else:
                continue

    if not skip_report and not set_label:
        print("If there is no \'-s\' flag use the \'--label\' flag")
        print("Choose from following labels:")
        for label in executor.labels:
            print(label)
        sys.exit()

    if local_logs and not skip_report:
        print("It is not available local run (-l) run and report test (no -s)")
        sys.exit()

    try:
        executor.detect_sw_release()
        #        executor.open_firewall_ports_on_appserver()
        executor.execute_and_report_test(robot_file_path, perform_commissioning=perform_commissioning,
                                         skip_report=skip_report, gather_rtg_logs=gather_rtg_logs,
                                         local_logs=local_logs, pcap_logs=pcap_logs, zip_logs=zip_logs)

    finally:
        #        executor.close_firewall_ports_on_appserver()
        _run_cleanup()
