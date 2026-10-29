"""
:copyright: Nokia Networks
:authors:
:maintainers:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
"""
import re
import subprocess
import time
import argparse
import logging
from testsuite.Krakow.RRM.Airphone.CB012734.config.iwf_preconfigs import ConfigureIWF

logger = logging.getLogger()


class CheckConfigureIWFException(Exception):
    pass


class CheckConfigureIWF:
    def __init__(self):
        self.process_root = None
        self.out = None
        self.err = None
        self.iwf = ConfigureIWF()
        self.restart_count = 0

    def open_command(self, cmd):
        try:
            self.process_root = subprocess.Popen(["sudo", "-i"], stdin=subprocess.PIPE)
            self.process_root.communicate("{}\n".format(cmd).encode("utf-8"))
        except CheckConfigureIWFException as e:
            logger.info(f"run command failed with - {e}")

    def hughpage_check(self, output):
        hughpage_data = output.split('\n')
        hughpages_found = False
        for hughpage in hughpage_data:
            m = re.search('HugePages_Free:\\s*1024', hughpage)
            if m:
                hughpages_found = True
        return hughpages_found

    def kill_iwf(self):
        try:
            output = self.iwf.run_command("ps -eaf | grep iwf | grep rx:8192")
            m = re.search('root\\s*(\\d+)\\s', str(output))
            if m:
                self.iwf.run_command('sudo bash -c \"kill -9 ' + m.group(1) + ' \"')
            else:
                raise CheckConfigureIWFException("unable to find the process id of iwf")
        except CheckConfigureIWFException as e:
            raise CheckConfigureIWFException("unable to kill the IWF Process id")

    def check_socket_management_file(self):
        time.sleep(5)
        file_found = False
        output = self.iwf.run_command('ls /var/run/')
        if 'wts-iwf-master-socket-management' in self.iwf.run_command('ls /var/run/'):
            file_found = True
        return file_found

    def config(self):
        try:
            if not self.iwf.check_iwf_status():
                self.iwf.check_hugepages(self.iwf.nr_hugepages_size)
                self.iwf_bring_up_cmds()
                logger.info("Started IWF Process")
        except CheckConfigureIWFException as e:
            logger.info("iwf check is needed")

    def recover_file_absense(self):
        if self.check_socket_management_file() is False:
            self.restart_count += 1
            self.kill_iwf()
            self.iwf.run_command('sudo bash -c \"rm -rf /dev/hugepages/rtemap*\"')
            self.iwf.check_hugepages(self.iwf.nr_hugepages_size)
            self.iwf_bring_up_cmds()
            logger.info("Restarted IWF Process - {}".format(self.restart_count))

    def check_with_restart(self):
        if self.restart_count <= 3:
            if not self.iwf.check_ens3v() and not self.iwf.check_iwf_status():
                self.restart_count += 1
                new_nr_hugepages_size = int(self.iwf.nr_hugepages_size) - 50
                self.iwf.run_command('sudo bash -c \"rm -rf /dev/hugepages/rtemap*\"')
                self.iwf.config_hugepages(new_nr_hugepages_size)
                self.iwf.run_command('sudo bash -c \"rm -rf /dev/hugepages/rtemap*\"')
                self.iwf.check_hugepages(new_nr_hugepages_size)
                self.iwf_bring_up_cmds()
                logger.info("Restarted IWF Process - {}".format(self.restart_count))
                if not self.iwf.check_ens3v() and not self.iwf.check_iwf_status():
                    raise CheckConfigureIWFException("IWF not Configured! needs manual checks")
        else:
            raise Exception("IWF not Configured! needs manual checks")

    def check_interface_ping(self):
        self.iwf.run_command("sudo cat /proc/meminfo | grep Huge")
        time.sleep(5)
        self.iwf.run_command("ping -I ens3v 10.0.2.150 -c 2")

    def iwf_bring_up_cmds(self):
        self.iwf.run_command('sudo bash -c \"rm -rf /var/run/iwf.pid\"')
        time.sleep(2)
        try:
            self.iwf.run_command(
                'sudo /opt/wts/latest/iwf -- -R rx:8192,tx:8192 -r rx:8192,tx:8192 -v info -K period:10,count:10')
        except subprocess.CalledProcessError as cpe:
            if cpe.returncode == 134:
                logger.info(cpe.output)
                logger.info("Restart IWF process")
                self.check_with_restart()
            else:
                raise CheckConfigureIWFException("IWF not Configured! needs manual checks")

    def iwf_launch_start(self):
        self.config()
        self.recover_file_absense()
        self.check_interface_ping()
