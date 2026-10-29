import subprocess
import os
import io
import sys
import time
import stat
import shutil
import re
import socket
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru


class AgentInstaller():
    def __init__(self, topology, gnb_build, ap_build, custom_config, variant, force_install, custom_config_p1):
        self.topology = topology
        self.gnb_build = gnb_build
        self.ap_build = ap_build
        self.custom_config = custom_config
        self.variant = str(variant)
        self.force_install = str(force_install)
        self.root_path = "/home/ute/custom_config/"
        self.tools_profile = os.environ.get("TOOLS_PROFILE", "TTI_LEGACY")
        self.custom_config_p1 = custom_config_p1

    def execute_command_in_shell(self, command, log=True, timeout=0.5):
        filename = "agent_runner_shell_output.log"
        with io.open(filename, "w") as writer, io.open(filename, "r", 1) as reader:
            process = subprocess.Popen(
                command, shell=True, executable="/bin/bash", stdout=writer
            )
            while process.poll() is None:
                try:
                    _reader = reader.read()
                    if isinstance(_reader, bytes):
                        _reader = _reader.decode("utf-8")
                    if _reader:
                        loguru.logger.info(_reader)
                    if "fatal" in _reader:
                        raise ShellException
                    elif "unable to re-open stdin" in _reader:
                        raise ShellException
                except UnicodeDecodeError:
                    pass
        return filename

    def check_ap_and_gnb_sw(self):
        """Check ap and gnb installed software versions are same as requested versions"""
        loguru.logger.info("AP and gNB software check:")
        workspace = os.environ["WORKSPACE"]
        script_name = "entitytests/tools/scripts/ap_operations.py"
        script_path = os.path.join(workspace, script_name)
        os.chmod(script_path, 0o744)
        script_options = "-a {} -b {} -s".format(self.ap_build, self.gnb_build)
        cmd = ["python", script_name]+script_options.split(" ")
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        os.chmod(script_path, 0o644)
        loguru.logger.info(stdout)
        exit_code = process.returncode
        loguru.logger.info(f'exit code for AP & gNB software check is: {exit_code}')
        if exit_code == 10:
            return True
        return False

    def agent_log_file_change(self):
        """agent log file change based on the variant"""
        loguru.logger.info("variant and topology change in agent.log file")
        try:
            for agent_files in ["/home/ute/testline_update_results/agent.log",
                                "/home/ute/testline_update_results/execution/logs/agent.log"]:
                with open(agent_files, "r+") as file:
                    data = file.read()
                    label_name = re.search("LABEL:\\s+(\\S+)", data)
                    data = data.replace(label_name.group(1), self.topology)
                    variant_name = re.search("VARIANT:\\s+(\\S+)", data)
                    data = data.replace(variant_name.group(1), self.variant)
                    file.seek(0)
                    file.write(data)
        except Exception as e:
            print(e)

    def check_if_install_was_success(self):
        """Verfies if install is successful or not from agent.log"""
        loguru.logger.info("Verify previous install is successful or not in agent.log file")
        agent_log_file = "/home/ute/testline_update_results/agent.log"
        try:
            with open(agent_log_file, 'r+') as file:
                data = file.read()
                matches = re.search("ERROR\\s+ EXIT CODE:\\s+(\\d+)", data)
                if matches is None:
                    loguru.logger.info("Previous installation was successful")
                    return True
                else:
                    if matches.group(1) == 1:
                        loguru.logger.info("Previous installation was failed!! Forcing full install")
                        return False
        except FileNotFoundError:
            print(f"File {agent_log_file} not found. Installation is not done yet")
            return False

    def check_if_topology_matches(self):
        """Verifies if given topology and installed topology matches from agent.log"""
        loguru.logger.info("Verify if given topology and installed topology matches from ute-ca-executions.json")
        execution_id = os.listdir('/home/ute/.ute-ca/executions')[0]
        agent_log_file = '/home/ute/.ute-ca/executions/' + execution_id + '/logs/ute-ca-executions.json'
        try:
            with open(agent_log_file, 'r+') as file_handle:
                data = file_handle.read()
                agent_log_file_topology = re.search(r'"label"\s*:\s*"([^"]+)"', data).group(1)
                if agent_log_file_topology == self.topology:
                    loguru.logger.info("Topology input provided is matching with installed topology")
                    return True
                else:
                    loguru.logger.info("Topology input provided is not matching with installed topology!"
                                       " Forcing full install")
                    return False
        except FileNotFoundError:
            print(f"File {agent_log_file} not found. Installation is not done yet")
            return False

    def check_if_variant_matches(self):
        """Verifies if given topology and installed topology matches from agent.log"""
        loguru.logger.info("Verify if given variant and installed variant matches from ute-ca-executions.json")
        execution_id = os.listdir('/home/ute/.ute-ca/executions')[0]
        agent_log_file = '/home/ute/.ute-ca/executions/' + execution_id + '/logs/ute-ca-executions.json'
        with open(agent_log_file, 'r+') as file_handle:
            data = file_handle.read()
            agent_log_file_variant = re.search(r'"variant"\s*:\s*"([^"]+)"', data).group(1)
            loguru.logger.info(f" variant from ute-ca-executions.json is {agent_log_file_variant}"
                               f" and given variant is {self.variant} ")
        if agent_log_file_variant == self.variant:
            loguru.logger.info("Given variant matches with installed variant")
            return True
        else:
            loguru.logger.info("Variant input provided does not match with installed variant! Forcing full install")
            return False

    def fixdpkg(self):
        """Fixing dpkg issues if any"""
        loguru.logger.info("Fixing dpkg issues if any")
        cmds = ["sudo dpkg --configure -a --force-confnew", "sudo apt-get -f install"]
        for cmd in cmds:
            output = os.system(cmd)
            loguru.logger.info(output)

    def startdocker(self):
        """Restarting docker"""
        loguru.logger.info("Restarting docker")
        cmds = ["sudo systemctl restart docker > /dev/null 2>&1",
                "sudo systemctl is-active docker > /dev/null 2>&1",
                "sudo docker stop postgres > /dev/null 2>&1",
                "sudo docker rm -v postgres > /dev/null 2>&1"]
        for cmd in cmds:
            output = os.system(cmd)
            loguru.logger.info(output)

    def killagent(self):
        """Killing all ute-ca instances"""
        loguru.logger.info("killing all ute-ca instances")
        cmds = ["sudo pkill agentctl",
                "sudo systemctl stop ute-ca",
                "sudo apt-get purge -y ute-ca ute-ca-essentials",
                "sudo apt-get purge -y ute-ca",
                "sudo apt-get -y autoremove"]
        for cmd in cmds:
            output = os.system(cmd)
            loguru.logger.info(output)

    def update_systemd(self):
        loguru.logger.info("Update systemd-journald")
        cmd = "sudo systemctl restart systemd-journald"
        output = os.system(cmd)
        loguru.logger.info(output)

    def cleanup_root_archives(self):
        loguru.logger.info("Clearing root archive")
        cmd = "sudo rm -r /var/cache/apt/archives/*"
        output = os.system(cmd)
        loguru.logger.info(output)

    def remove_all_rotated_logs(self):
        loguru.logger.info("Clearing all rotated logs")
        cmds = [r'sudo find /var/log -type f -regex ".*\.gz$" -delete',
                r'sudo find /var/log -type f -regex ".*\.[0-9]$" -delete']
        for cmd in cmds:
            output = os.system(cmd)
            loguru.logger.info(output)

    def cleanup_collectd(self):
        loguru.logger.info("Clearing collects logs")
        hostname = subprocess.check_output("hostname", shell=True)
        hostname = hostname.decode("UTF-8").strip()
        cmd = f"sudo rm -rf /var/lib/collectd/rrd/{hostname}.ute/"
        output = os.system(cmd)
        loguru.logger.info(output)

    def stopdnsmasq(self):
        """Stopping DNS Masq"""
        loguru.logger.info("stopping DNS Masq")
        cmd = "sudo systemctl stop dnsmasq"
        output = os.system(cmd)
        loguru.logger.info(output)

    def folder_deletion(self, path, folder_name):
        """delete folder/files excluding specified one"""
        if os.path.exists(path):
            loguru.logger.info(f"cleaning files in path: {path}, excluding {folder_name}")
            all_folders = [folders for folders in os.listdir(path) if os.path.isdir(os.path.join(path, folders))]
            if folder_name in all_folders:
                all_folders.remove(folder_name)
            if len(all_folders) != 0:
                for folder in all_folders:
                    os.system(f"rm -rf {path}/{folder}/")
                    loguru.logger.info(f"Removed folder: {path}/{folder}/")

    def cleanup_disk(self):
        """check disk space and cleanup"""
        home_disk_space = (shutil.disk_usage("/").used)/(shutil.disk_usage("/").total)*100
        loguru.logger.info(f"Current Disk Space of Root={home_disk_space}")
        if home_disk_space > 68:
            loguru.logger.info("Disk space greater than 70%, Cleaning Cache")
            os.system("sudo apt-get clean")
            disk_freed = (shutil.disk_usage("/").used)/(shutil.disk_usage("/").total)*100
            loguru.logger.info(f"Consumed Disk Space after clean up={disk_freed}")

    def cleanup_tmp(self):
        """check tmp folder and cleanup"""
        home_disk_space = (shutil.disk_usage("/tmp").used)/(shutil.disk_usage("/tmp").total)*100
        loguru.logger.info(f"Current Disk Space of tmp={home_disk_space}")
        if home_disk_space > 10:
            loguru.logger.info("Disk space greater than 70%, Cleaning Cache")
            os.system("sudo pkill tcpdump")
            os.system("sudo rm -rf /tmp/*")
            os.system("sudo rm -r /var/tmp/*")
            disk_freed = (shutil.disk_usage("/tmp").used)/(shutil.disk_usage("/tmp").total)*100
            loguru.logger.info(f"Consumed tmp Space after clean up={disk_freed}")

    def cleanup_ute_files(self):
        """cleaning up of cache /opt/wts/* /opt/iphy/* dirctories"""
        loguru.logger.info("[UTE VM] Cleaning up directories /home/ute/.ute-ca/cache/*, /opt/wts/*, /opt/iphy/*")
        cmds = ["sudo rm -rf /opt/wts/* /opt/iphy/*", "echo 'Clearing agent log folder'",
                "rm -rf /home/ute/testline_update_results", "rm -rf /home/ute/testline_init_results",
                "mkdir -p /home/ute/testline_update_results", "mkdir -p /home/ute/testline_init_results/",
                "echo 'Common agent temp folders'", "sudo rm -rf /home/ute/.ute-ca/tmp",
                "sudo rm /home/ute/.ute-ca/logs_*.tar.gz", "echo 'Contents in /home/ute/output/builds'",
                "ls -lrt /home/ute/output/builds/", "echo 'Cleaning up output/builds directory'",
                "rm -rf /home/ute/output/builds/*"]
        for cmd in cmds:
            output = os.system(cmd)
            loguru.logger.info(output)

    def agent_dependent_files_cleanup(self):
        """Cleaning up agent installation dependent files"""
        loguru.logger.info("Cleaning up agent processes and packages")
        self.fixdpkg()
        self.startdocker()
        self.remove_all_rotated_logs()
        self.cleanup_root_archives()
        self.update_systemd()
        self.cleanup_collectd()
        self.killagent()
        self.stopdnsmasq()
        self.cleanup_ute_files()
        self.cleanup_disk()
        self.cleanup_tmp()
        self.folder_deletion("/home/ute/.ute-ca/cache/airphone/", self.ap_build)
        self.folder_deletion("/home/ute/.ute-ca/cache/bts/", self.gnb_build)
        output = os.system("find /home/ute/.ute-ca/cache/ -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'")
        loguru.logger.info(output)

    def install(self):
        if (self.force_install == 'false' and self.check_ap_and_gnb_sw() and self.check_if_topology_matches()
                and self.check_if_variant_matches() and self.check_if_install_was_success()):
            loguru.logger.info("Proceeding without Installation as given AP & gNB builds"
                               " and topology and variant are installed")
            self.agent_log_file_change()
            rc = 0
        else:
            os.system('rm -rf /home/ute/.ute-ca/executions/*')
            self.agent_dependent_files_cleanup()
            output, error = self._get_ute_ca_service_status()
            loguru.logger.info('ute-ca service status after cleanup is \n {}'.format(output))
            self._install_ute_ca_packages()
            self._start_ute_ca_services()
            output, error = self._get_ute_ca_service_status()
            loguru.logger.info('ute-ca service status after restart of services is \n {}'.format(output))
            install_command = self._get_common_agent_install_command()
            loguru.logger.info(install_command)
            rc = subprocess.call(install_command, shell=True)
        return rc

    def _get_ute_ca_service_status(self):
        ute_ca_status_check_cmd = 'sudo systemctl status ute-ca'
        result = subprocess.run(ute_ca_status_check_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
                                timeout=180)
        loguru.logger.info(result)
        stdout = result.stdout.decode('utf-8')
        stderr = result.stderr.decode('utf-8')
        return stdout, stderr

    def _install_ute_ca_packages(self):
        try:
            common_agent_version = os.environ['COMMON_AGENT_VERSION']
        except KeyError as e:
            common_agent_version = ''
        ca_version = ('ute-ca={}'.format(common_agent_version) if common_agent_version != '' else "ute-ca")
        cmds = ["sudo apt update",
                ("sudo DEBIAN_FRONTEND=noninteractive apt install -y ute-ca --allow-downgrades"
                 "&& echo 'Successfully installed on:' && cat /proc/sys/kernel/hostname")]
        ca_shell_commands = " && ".join(cmds)
        ca_install_cmds = ca_shell_commands.replace("-y ute-ca", '-y {}'.format(ca_version))
        self.execute_command_in_shell(ca_install_cmds)
        return

    def _start_ute_ca_services(self):
        start_ute_ca_cmd = "sudo systemctl start ute-ca"
        result = subprocess.run(start_ute_ca_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
                                timeout=180)
        loguru.logger.info(result)
        stdout = result.stdout.decode('utf-8')
        stderr = result.stderr.decode('utf-8')
        if 'Failed to start' in str([stdout, stderr]) or 'systemctl daemon-reload' in str([stdout, stderr]) \
                or 'failed' in str([stdout, stderr]):
            loguru.logger.info("reloading system daemon services")
            rc = subprocess.call('sudo systemctl daemon-reload', shell=True)
            if rc == 0:
                loguru.logger.info('restarting ute ca services afte daemon reload')
                start_rc = subprocess.call(start_ute_ca_cmd, shell=True)
                loguru.logger.info(start_rc)
        return

    def _get_common_agent_install_command(self):
        """Conditional statement added to support custom config file path"""
        if self.tools_profile != 'False':
            agentctl_base_cmd = ' '.join(['agentctl exec',
                                          '--label', self.topology,
                                          '--sm-build', self.gnb_build,
                                          '--airphone-build', self.ap_build,
                                          '--required-state', 'configured',
                                          '--output', '/home/ute/testline_update_results',
                                          '--tools-profile', self.tools_profile])
        else:
            agentctl_base_cmd = ' '.join(['agentctl exec',
                                          '--label', self.topology,
                                          '--sm-build', self.gnb_build,
                                          '--airphone-build', self.ap_build,
                                          '--required-state', 'configured',
                                          '--output', '/home/ute/testline_update_results'])
        if (self.custom_config == "" and self.variant == ""):
            return agentctl_base_cmd
        elif (self.custom_config_p1 is not None):
            agentctl_base_cmd = agentctl_base_cmd.replace('configured', 'commissioned')
            return ' '.join([agentctl_base_cmd,
                             '--local-topology-config', self.custom_config_p1,
                             '--variant', self.variant,
                             '--no-scf-validation'])
        elif ("PRIVATE" in self.variant):
            return agentctl_base_cmd + ' --variant' + ' ' + self.variant + ' --no-scf-validation'
        elif (self.custom_config == ""):
            return agentctl_base_cmd + ' --variant' + ' ' + self.variant
        else:
            return ' '.join([agentctl_base_cmd,
                             '--variant', self.variant,
                             '--local-topology-config', self.custom_config,
                             '--no-scf-validation'])


def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='To Run Agent to install custom AP and GNB Build.')
    parser.add_argument('--topology', required=True, help='Topology to use with Agent.')
    parser.add_argument('--gnb_build', required=True, help='GNB Build to be used with Agent.')
    parser.add_argument('--ap_build', required=False, help='AP Build to be used with Agent.')
    parser.add_argument('--custom_config', required=False, help='custom_config to be used')
    parser.add_argument('--custom_config_p1', required=False, default=None, help='custom_config to be used')
    parser.add_argument('--variant', required=False, default="", help='Specify the variant name')
    parser.add_argument('--force_install', required=False, default="", help='config load without CA install')
    args = parser.parse_args()
    return args


def main(args):
    agent = AgentInstaller(args.topology, args.gnb_build, args.ap_build, args.custom_config, args.variant,
                           args.force_install, args.custom_config_p1)
    rc = agent.install()
    return rc


if __name__ == "__main__":
    import sys
    args = get_args()
    return_code = main(args)
    sys.exit(return_code)
