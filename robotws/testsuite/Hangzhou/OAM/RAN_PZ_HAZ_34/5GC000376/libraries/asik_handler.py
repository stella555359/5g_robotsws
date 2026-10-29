#!/usr/bin/env python
# -*- coding: utf-8 -*-

import paramiko
import time

__author = 'Mehdi Khediri'
__contact = 'mehdi.khediri@nokia.com'


class asik_handler(object):
    """
    This class is used to take BIP Log (L1/L2) from ASIK directly
    It prepares the ASIK and the Loner to mirror the traces and make a tcpdump
    without using an external tool (e.g Airframe)

    This class does not upload the .pcap file created after the tcpdump from the ASIK.

    5 methods are avalaible to mirror the trafic into the Loner to the ASIK.
    """

    def connect(self, i_ipAddr, i_username="toor4nsn", i_password="oZPS0POrRieRtu"):
        v_ASIK_IP = i_ipAddr
        v_username = i_username
        v_password = i_password

        # ********* Connection to ASIK ****************
        self.vASIK_ssh = paramiko.SSHClient()
        self.vASIK_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.vASIK_ssh.connect(v_ASIK_IP, username=v_username, password=v_password)
        self.shell = self.vASIK_ssh.invoke_shell()

        # ********* Prepare shell ***************
        time.sleep(1)
        self.shell.recv(9999)
        self.shell.send("\n")
        self.shell.send("sudo bash\n")
        time.sleep(1)
        output = self.shell.recv(9999)

        return output

    def connectToCU(self, i_ipAddr, i_username="toor4nsn", i_password="oZPS0POrRieRtu"):
        v_ASIK_IP = i_ipAddr
        v_username = i_username
        v_password = i_password

        # ********* Connection to ASIK ****************
        self.vCU_ssh = paramiko.SSHClient()
        self.vCU_ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.vCU_ssh.connect(v_ASIK_IP, username=v_username, password=v_password)
        self.shellCU = self.vCU_ssh.invoke_shell()

        # ********* Prepare shell ***************
        time.sleep(1)
        self.shellCU.recv(9999)
        self.shellCU.send("\n")
        # self.shellCU.send("sudo bash\n")
        time.sleep(1)
        output = self.shellCU.recv(9999)

        return output

    def close(self):
        self.vASIK_ssh.close()

    def closeCU(self):
        self.vCU_ssh.close()

    def Write_Abil_Register_with_bsh(self, i_method_number=1):
        """
        This function is used to write in the register of the ABIL to activate mirroring
        to capture L2L1 traces
        """

        self.shell.send("bsh 1:2 \n")
        time.sleep(1)
        output = self.shell.recv(9999)
        time.sleep(1)

        if i_method_number == "1":
            v_command_list = [
                "bip0=`ifconfig arb0p0 | grep HWaddr`",
                "bip0_mac=${bip0:38:17}",
                "bip0_arp=`cat /sys/class/xlgx/xlgx0/device/arb_rules | grep -a $bip0_mac`",
                'bip0_arp_index=${bip0_arp:1:1}',
                'mac_conf=`dump-ethss-xlgx-regs xlgx0 | grep  "MAC_CONF\\[$bip0_arp_index\\]"`',
                'mac_conf_value=${mac_conf:32:32}',
                'mac_conf_value_mod="$((mac_conf_value|0x4))"',
                "fpga_rw wn xlgx002_xlgx_blk.MAC_CONF[$bip0_arp_index] $mac_conf_value_mod_hex"
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += "%s\n" % self.shell.recv(9999)

        elif i_method_number == "2":
            v_command_list = [
                'echo 0x1 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask;',
                'echo 0x2 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag'
            ]
            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += "%s\n" % self.shell.recv(9999)

        elif i_method_number == "3":
            v_command_list = [
                'echo 0x1 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask;',
                'echo 0x4 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag'
            ]
            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += "%s\n" % self.shell.recv(9999)

        elif i_method_number == "4":
            v_command_list = [
                'echo 0x3 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask',
                'echo 0x4 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag',
                'cat /sys/class/xlgx/xlgx0/device/monitored_ports_mask',
                'cat /sys/class/xlgx/xlgx0/device/monitoring_port_flag'
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += "%s\n" % self.shell.recv(9999)

        elif i_method_number == "5":
            v_command_list = [
                "var=`fpga_rw ra 0xDF1D038C 32 | egrep -in '000(8|a)$'`",
                'first_char="${var:0:1}"',
                "offset=$((($first_char-1)*4))",
                'dec_addr=$((3743220620+$offset))',
                "registerValue=`fpga_rw ra $MACADDR`",
                'modifiedRegisterValue="${registerValue::-1}""a"',
                "fpga_rw wa $MACADDR $modifiedRegisterValue"
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += "%s\n" % self.shell.recv(9999)

        if "ERROR" in output:
            CollectLog_flag = False
            raise NameError("Error: %s" % output.split("ERROR", 1)[1])

        self.shell.send("exit\n")

        return output

    def MirrorASIKToAbil(self, i_source_port, i_dest_port):
        self.v_source_port = i_source_port
        self.v_dest_port = i_dest_port
        try:
            v_command_list = [
                "dbgrrc enable port %s" % i_source_port,
                "dbgrrc enable port %s" % i_dest_port,
                "dbgrrc set port %s mtu 9216" % i_dest_port,
                "ifconfig etha01 mtu 9216",
                "dbgrrc mirror sport %s dport %s e b" % (i_source_port, i_dest_port)
            ]

            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += "%s\n" % self.shell.recv(9999)

            return output
        except Exception as e:
            return "Mirror ASIK Exception: %s" % e

    def tcp_dump_on_Asik(self, i_capture_port="etha01", i_dir_path="ffs/run/config/scripts", i_bip_filter=None):
        """
            This function is used to launch tcpdump in ASIK
        """

        self.v_capture_port = i_capture_port
        self.shell.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shell.recv(9999)
        if i_bip_filter is None:
            # v_bip_filter = "ether proto 0x8951"
            v_bip_filter = ""
        else:
            v_bip_filter = i_bip_filter
        # self.shell.send("ifconfig %s mtu 9216; ifconfig %s up\n" % (i_capture_port, i_capture_port))
        # time.sleep(1)
        # output1 = self.shell.recv(9999)

        self.shell.send("tcpdump -i %s %s -B 10000 -C 1000 -w %s/bip_log.pcap -W 50\n" % (
            i_capture_port, v_bip_filter, i_dir_path))
        time.sleep(2)
        output = self.shell.recv(9999)

        # output="output1:%s \n output2:%s \n " % (output1, output2)
        return output

    def general_tcpdump(self, smod, i_dir_path="ffs/run/config/scripts", i_filename="PCMD_DU.pcap"):
        # tcpdump -i any - w /tmp/PCMD_DU_date.pcap
        interface = {"ASIK": "fp0", "ASIB": "br1", "ASIL": "br0", "ASOE": "br0"}
        self.v_capture_port = "any"
        self.shell.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shell.recv(9999)
        self.shell.send("tcpdump -i %s -u -w %s/%s\n" % (interface[smod], i_dir_path, i_filename))
        time.sleep(2)
        output = self.shell.recv(9999)

        return output

    def general_tcpdump_ASIB(self, i_dir_path="ffs/run/config/scripts", i_filename="PCMD_DU.pcap"):
        # tcpdump -i any - w /tmp/PCMD_DU_date.pcap
        self.v_capture_port = "any"
        self.shell.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shell.recv(9999)
        self.shell.send("tcpdump -i br1 -w %s/%s\n" % (i_dir_path, i_filename))
        time.sleep(2)
        output = self.shell.recv(9999)

        return output

    def general_tcpdump_ASIK(self, i_dir_path="ffs/run/config/scripts", i_filename="PCMD_DU.pcap"):
        # tcpdump -i any - w /tmp/PCMD_DU_date.pcap
        self.v_capture_port = "any"
        self.shell.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shell.recv(9999)
        self.shell.send("tcpdump -i fp0 -w %s/%s\n" % (i_dir_path, i_filename))
        time.sleep(2)
        output = self.shell.recv(9999)

        return output

    def general_tcpdump_ASOE(self, i_dir_path="ffs/run/config/scripts", i_filename="PCMD_DU.pcap"):
        # tcpdump -i any - w /tmp/PCMD_DU_date.pcap
        self.v_capture_port = "any"
        self.shell.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shell.recv(9999)
        self.shell.send("tcpdump -i br0 -w %s/%s\n" % (i_dir_path, i_filename))
        time.sleep(2)
        output = self.shell.recv(9999)

        return output

    def general_tcpdumpOnCU(self, i_dir_path="ffs/run/config/scripts", i_filename="PCMD_CU.pcap"):
        # tcpdump -i any - w /tmp/PCMD_DU_date.pcap
        self.v_capture_port = "any"
        self.shellCU.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shellCU.recv(9999)
        self.shellCU.send("sudo tcpdump -i any -u -w %s/%s\n" % (i_dir_path, i_filename))
        time.sleep(2)
        output = self.shellCU.recv(9999)
        return output

    def C4MN_tcpdumpDU(self, i_dir_path="ffs/run/config/scripts", i_filename="PCMD_DU.pcap", i_C4MN_IP="10.75.189.43"):
        # tcpdump -i any - w /tmp/PCMD_DU_date.pcap
        self.v_capture_port = "any"
        self.shell.send("mkdir %s\n" % i_dir_path)
        time.sleep(2)
        output = self.shell.recv(9999)
        self.shell.send("tcpdump -i any -n host %s -u -w %s/%s\n" % (i_C4MN_IP, i_dir_path, i_filename))
        time.sleep(2)
        output = self.shell.recv(9999)

        return output

    def kill_tcpdump(self, i_method_number="1", iKillCU=False):
        """
            This function is used to kill the tcpdump launched.
            Two method are available
        """
        if i_method_number == "1":
            self.shell.send("ps -ef|grep tcpdump\n")
            self.shell.send("pkill tcpdump\n\n")
            time.sleep(1)
            output = self.shell.recv(9999)
            if iKillCU:
                self.shellCU.send("ps -ef|grep tcpdump\n")
                self.shellCU.send("pkill tcpdump\n\n")
                time.sleep(1)
                output = self.shellCU.recv(9999)

        elif i_method_number == "2":
            v_command_list = [
                "ps -ef|grep tcpdump|grep -v grep|grep %s" % self.v_capture_port,
                "ps -ef|grep tcpdump|grep -v grep|grep %s" % self.v_capture_port
            ]
            output = ""
            for v_command in v_command_list:
                self.shell.send("%s\n" % v_command)
                time.sleep(1)
                output += self.shell.recv(9999)

        return output

    def disable_mirroring(self):
        v_command_list = [
            "dbgrrc mirror sport %s dport %s d b" % (self.v_source_port, self.v_dest_port),
            "bsh 1:2",
            "echo 0x0 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask",
            "echo 0x0 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag",
            "exit"
        ]
        output = ""
        for v_command in v_command_list:
            self.shell.send("%s\n" % v_command)
            time.sleep(1)
            output += self.shell.recv(9999)

        return output

    def download_file_from_Asik(self, i_filename, i_local_path):
        """
        This function is used to download a file from the ASIK to the PC
        :i_filename:    directory path to the file (eg: /local/user/filename.txt)
        :i_local_path:  directory on the PC to download the file
        """

        v_command_list = [
            '[ -f %s ] && echo "Found" || echo "Not Found"\n' % i_filename,
        ]
        output = ""

        try:
            sftp = self.vASIK_ssh.open_sftp()
            sftp.get("%s" % i_filename, "%s" % i_local_path)
            time.sleep(20)
            sftp.close()

        except Exception as e:
            sftp.close()

        return output

    def download_file_from_CU(self, i_filename, i_local_path):
        """
        This function is used to download a file from the ASIK to the PC
        :i_filename:    directory path to the file (eg: /local/user/filename.txt)
        :i_local_path:  directory on the PC to download the file
        """

        v_command_list = [
            '[ -f %s ] && echo "Found" || echo "Not Found"\n' % i_filename,
        ]
        output = ""

        try:
            sftp = self.vCU_ssh.open_sftp()
            sftp.get("%s" % i_filename, "%s" % i_local_path)
            time.sleep(20)
            sftp.close()

        except Exception as e:
            sftp.close()

        return output
