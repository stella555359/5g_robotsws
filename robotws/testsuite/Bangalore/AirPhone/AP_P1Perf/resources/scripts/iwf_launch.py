import re
import subprocess
from pathlib import Path
import time
import argparse
from iwf_preconfigs import ConfigureIWF


class CheckConfigureIWFException(Exception):
    pass


class CheckConfigureIWF:
    def __init__(self, strace, strace_log, enable_dss):
        self.p = None
        self.out = None
        self.err = None
        self.strace = strace
        self.strace_log = strace_log
        self.enable_dss = enable_dss
        self.iwf = ConfigureIWF(self.enable_dss)
        self.restart_count = 0
        self.iwf_bring_up_cmds = [
            "rm -rf /var/run/iwf.pid",
            "cd /opt/wts/latest/",
            "ls -lrt",
            "sudo ./iwf -- -R rx:8192,tx:8192 -r rx:8192,tx:8192 -v info -K period:10,count:10",
            ]

    def open_command(self, cmd):
        try:
            self.p = subprocess.Popen(["sudo", "-i"], stdin=subprocess.PIPE)
            self.p.communicate("{}\n".format(cmd).encode("utf-8"))
        except CheckConfigureIWFException as e:
            print(f"run command failed with - {e}")

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
                output = self.open_command('kill -15 '+m.group(1))
            else:
                raise CheckConfigureIWFException(" unable to find the process id of iwf")
        except CheckConfigureIWFException as e:
            raise CheckConfigureIWFException("unable to kill the IWF Process id")

    def enable_strace(self):
        try:
            output = self.iwf.run_command("ps -eaf | grep iwf | grep rx:8192")
            m = re.search('root\\s*(\\d+)\\s', str(output))
            if m:
                # strace -p 6711 -fFv -ttt -o iwfstrace4.log &
                output = self.open_command('strace -p '+m.group(1)+' -fFv -ttt -o '+self.strace_log+' &')
            else:
                raise CheckConfigureIWFException(" unable to find the process id of iwf")
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
                self.open_command("rm -rf /dev/hugepages/rtemap*")
                output = self.iwf.run_command("cat /proc/meminfo | grep Huge")
                self.open_command("; ".join(self.iwf_bring_up_cmds))
                print("Started IWF Process")
                if self.strace == 'True':
                    self.enable_strace()
                self.check()
        except CheckConfigureIWFException as e:
            print("iwf check is needed")

    def recover_file_absense(self):
        if self.check_socket_management_file() is False:
            self.kill_iwf()
            self.open_command("rm -rf /dev/hugepages/rtemap*")
            self.iwf.run_command("cat /proc/meminfo | grep Huge")
            self.open_command("; ".join(self.iwf_bring_up_cmds))
            self.restart_count += 1
            print("Restarted IWF Process - {}".format(self.restart_count))
            if self.strace is True:
                self.enable_strace()

    def check(self):
        if not self.iwf.check_ens3v() and not self.iwf.check_iwf_status():
            self.iwf.run_command("rm -rf /dev/hugepages/rtemap*")
            output = self.iwf.run_command("cat /proc/meminfo | grep Huge")
            if self.hughpage_check(output) is False:
                raise CheckConfigureIWFException("insufficient hughpages")
            self.open_command("; ".join(self.iwf_bring_up_cmds))
            self.restart_count += 1
            print("Restarted IWF Process - {}".format(self.restart_count))
            if not self.iwf.check_ens3v() and not self.iwf.check_iwf_status():
                raise CheckConfigureIWFException("IWF not Configured! needs manual checks")

    def check_interface_ping(self):
        self.iwf.run_command("cat /proc/meminfo | grep Huge")
        time.sleep(5)
        self.iwf.run_command("ping -I ens3v 10.0.2.150 -c 2")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="script will enable iwf on the VM")
    parser.add_argument('-strace', "--enable_strace", default="False",
                        help="possible values: True, False")
    parser.add_argument('-slog', "--strace_log", default='iwfstrace.log',
                        help="strace log name")
    parser.add_argument('-d', "--enable_dss", default='false',
                        help="enable dss logs")
    args = parser.parse_args()
    print(args)
    conf = CheckConfigureIWF(args.enable_strace, args.strace_log, args.enable_dss)
    conf.config()
    conf.recover_file_absense()
    conf.check_interface_ping()
