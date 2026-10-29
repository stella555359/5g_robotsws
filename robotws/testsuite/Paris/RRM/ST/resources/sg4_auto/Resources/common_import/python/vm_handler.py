import paramiko
import time

__author = 'Mehdi Khediri and Babette Lekouta and william ngonkou'
__contact = 'mehdi.khediri@nokia.com and babett.lekouta_megho@nokia.com'


class vm_handler(object):
    """
    This class is used to manage hytem matrix. This matrix allows to make an handover.
    output 1 is used. At the beginning, Ue is attached to input1. We want to make HO from input 1 to input2
    """

    def connect(self, i_ipAddr, i_username="localuser", i_password="10c@1user"):
        v_VM_IP = i_ipAddr
        v_username = i_username
        v_password = i_password

        # ********* Connection to ASIK ****************
        self.vvm_ssh = paramiko.SSHClient()
        self.vvm_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.vvm_ssh.connect(v_VM_IP, username=v_username, password=v_password)
        self.shell = self.vvm_ssh.invoke_shell()

        # ********* Prepare shell ***************
        time.sleep(1)
        self.shell.recv(9999)
        self.shell.send("\n")
        time.sleep(1)
        output = self.shell.recv(9999)

    def close(self):
        self.vvm_ssh.close()

    def hytemTelnet(self, ihyetm_ip, i_ip_port, i_output, i_list_hytem):
        try:
            v_temp = "set --%s --attenuations %s" % (i_output, i_list_hytem)

            v_command_list = [
                "telnet  %s %s \n" % (ihyetm_ip, i_ip_port),
                "%s \n" % v_temp,
                "exit\n"
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(5)
                output += "%s\n" % self.shell.recv(9999)

            return output
        except Exception as e:
            return "Hytem TELNET Exception: %s" % e

    def hytemTelnet323(self, ihyetm_ip, i_ip_port, i_output, i_list_hytem):

        try:
            v_temp = "ATT %s %s" % (i_output, i_list_hytem)

            v_command_list = [
                "telnet  %s %s \n" % (ihyetm_ip, i_ip_port),
                "%s \n" % v_temp,
                "exit\n"
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(5)
                output += "%s\n" % self.shell.recv(9999)

            return output
        except Exception as e:
            return "Hytem TELNET Exception: %s" % e
