# -*- coding: utf-8 -*
"""
Author: Ren Biyao
Description: This knid of cpe does not have android layer
             1. can only use At command or modem on/off
             2. ul iperf needs to be installed within cygwin
             3. can not use <adb shell ifconfig> to get ue ip, use <ipconfig> instead
"""
import paramiko
import logging
from taf.transport.ssh import ssh
import re
import time
import hashlib
from serial import Serial
import serial.tools.list_ports

# tl = BuiltIn().get_variable_value('${tl}')


class Cpe_operation(object):
    def __init__(self):
        self.ssh = ssh()

    def login_cpc(self, hostname, username, password):
        """
        Description: login cpc
        """
        for x_retry in range(4):
            login_cpc_status = self.ssh.connect_to(hostname=hostname, username=username, password=password,
                                                   alias="login_cpc", timeout=50.0)
            if login_cpc_status is True:
                break

    def start_ul_data_transfer(self, hostname, username, password, ue_ip, appserver_ip,
                               duration, ul_tput, port, protocol, ue_sn):
        # login cpc with retry
        self.login_cpc(hostname=str(hostname), username=str(username), password=str(password))
        # kill existing iperf on cpc
        iperf_filter = "ps -ef | grep iperf |grep %s |grep -v grep |awk \'{print $2}\'" % (port)
        kill_cur_iperf = "adb -s {} shell {} |xargs adb -s {} shell kill -9".format(ue_sn, iperf_filter, ue_sn)
        self.ssh.send_command(command=kill_cur_iperf, connection="login_cpc")
        time.sleep(3)
        # add route with admin privilege
        add_route = self.ssh.execute(command="route add {} {}".format(appserver_ip, ue_ip),
                                     connection="login_cpc", timeout=30.0)
        if "OK" or "The object already exists" in add_route:
            # logging.info("ul route add for appserver and ue OK")
            print("ul route add for appserver and ue OK")
            # need to install iperf in cygwin setup
            print(str(protocol.lower()))
            if protocol.lower() == 'udp':
                ul_iperf_cmd = "iperf -c {} -B {} -u -p {} -w 512K -l 1300B -f k -b {} -t " \
                               "{} -i1".format(appserver_ip, ue_ip, port, ul_tput, duration)
                self.ssh.send_command(command=ul_iperf_cmd, connection="login_cpc")

            output = self.ssh.execute(command="ps -ef | grep iperf", connection="login_cpc", timeout=20.0)
            self.ssh.disconnect(connection="login_cpc")
        else:
            self.ssh.disconnect(connection="login_cpc")
            raise Exception("ul route add for appserver and ue NOK")

    def stop_ul_data_transfer(self, hostname, username, password, port, ue_sn):
        """
        stop ul iperf process
        """
        self.login_cpc(hostname=str(hostname), username=str(username), password=str(password))
        iperf_filter = "ps -ef | grep iperf |grep %s |grep -v grep |awk \'{print $2}\'" % (port)
        kill_cur_iperf = "adb -s {} shell {} |xargs adb -s {} shell kill -9".format(ue_sn, iperf_filter, ue_sn)
        self.ssh.send_command(command=kill_cur_iperf, connection="login_cpc")
        time.sleep(1)
        self.ssh.disconnect(connection="login_cpc")

# if __name__ == '__main__':
    # ssh_login(ip='10.71.218.237', port='22', username='mn5gran', passwd='nokia123@')
    # ssh.close()
    # cpe = Cpe_operation()
    # cpe.start_ul_data_transfer(hostname='10.71.218.237', username='mn5gran', password ='nokia123@',
    #                            ue_ip='10.64.21.54', appserver_ip='10.71.219.21',
    #                            duration='60', ul_tput='100M', port='41105', ue_sn='adc17e83',
    #                            protocol='UdP')

    # "iperf -c 10.71.219.21 -u -p 41105 -w 512K -l 1300B -f k -b 100M -t 9999 -i1"
