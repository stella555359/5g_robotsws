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

    def load_seq(self, ip, port, player_num, seq_filename):
        try:
            # TODO Remove 1
            cmd = "SEQ %s %s" % (player_num, seq_filename)

            v_command_list = [
                "telnet  %s %s \n" % (ip, port),
                "%s \n" % cmd,
                "\n"
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(5)
                output += "%s\n" % self.shell.recv(9999)

            print(output)
            return output
        except Exception as e:
            return "Hytem TELNET Exception: %s" % e

    def sync(self, ip, port, player_num, player_sync, master='0', local='-1'):
        try:
            cmd = "SYNC %s %s %s %s" % (player_num, master, local, player_sync)

            v_command_list = [
                "telnet  %s %s \n" % (ip, port),
                "%s \n" % cmd,
                "\n"
            ]
            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(5)
                output += "%s\n" % self.shell.recv(9999)
            print(output)
            return output
        except Exception as e:
            return "Hytem TELNET Exception: %s" % e

    def set_player(self, ip, port, request, player_num=1):
        """
            request : START, PAUSE or STOP
            player_numm: default 1
        """
        try:
            cmd = "%s %s" % (request, player_num)

            v_command_list = [
                "telnet  %s %s \n" % (ip, port),
                "%s \n" % cmd,
                "\n"
            ]
            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(5)
                output += "%s\n" % self.shell.recv(9999)
            print(output)
            return output
        except Exception as e:
            return "Hytem TELNET Exception: %s" % e


if __name__ == '__main__':
    ip = '10.0.116.180'
    port = '1'
    login = 'players'
    pwd = 'players'
    vm_handler = vm_handler()
    vm_handler.connect(ip, login, pwd)
    vm_handler.load_seq(ip, port, '5', 'RLF_EDA_v2_OK_Reestab.sqc')
    vm_handler.load_seq(ip, port, '6', 'RLF_EDA_v2_OK_Reestab.sqc')
    vm_handler.load_seq(ip, port, '7', 'RLF_EDA_v2_OK_Reestab.sqc')
    vm_handler.load_seq(ip, port, '8', 'RLF_EDA_v2_OK_Reestab.sqc')
    vm_handler.sync(ip, port, '5', '5', '0', '-1')
    vm_handler.sync(ip, port, '6', '5', '1', '-1')
    vm_handler.sync(ip, port, '7', '5', '1', '-1')
    vm_handler.sync(ip, port, '8', '5', '1', '-1')
    vm_handler.set_player(ip, port, 'START', 1)
    time.sleep(5)
    vm_handler.set_player(ip, port, 'PAUSE', 1)
    time.sleep(5)
    vm_handler.set_player(ip, port, 'STOP', 1)
    vm_handler.close()
