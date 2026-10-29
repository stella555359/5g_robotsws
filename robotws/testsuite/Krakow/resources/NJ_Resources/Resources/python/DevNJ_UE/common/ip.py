"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import re
import time
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

get_ipv4addr_cmd = "ifconfig usb0.1 | grep 'inet addr' | awk '{print $2}' | tr -d 'addr:'"
get_ipv6addr_cmd1 = "ifconfig usb0.1 | grep 'inet6 addr' | grep 'Scope:Global'| awk '{print $3}' | tr A-Z a-z | "
get_ipv6addr_cmd2 = "cut -d '/' -f 1"
ipv4_pattern = '(?<![\\.\\d])(([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])\\.)' \
               '{3}([1-9]?\\d|1\\d\\d|2[0-4]\\d|25[0-5])(?![\\.\\d])'
comd_start_cmd = "/etc/init.d/comd start"


class Ip(object):

    def __init__(self, ue_info):
        self.conn = None
        self.ue_config = ue_info
        # logger.info(self.ue_config)
        self.sshManager = ssh()
        self.add_default_route_flag = True
        self.ute_iperf_itf_ip_dict = {}
        self.sma_ue_addr_dict = {}

    def get_epc_side_ipaddr(self, ip_addr_dict, ue_index):
        """
        Main Function:
        This method used to retrieve epc side ip address for UL data transfer

        Arguments:
            :param ip_addr_dict: ip address list
            :param ue_index: UE identifier

        Return Value:
            ip address of EPC side for UL data transfer

        Examples:
            ${app_server_addr}  Get Epc Side Ipaddr  ip_addr_list=${ute_iperf_itf_ip_list}  ue_index=${ue_index}

        Version:
            | Author | Version | Delivery Date | Comments |
            | Sun Jingang | 1.0.0 | 2022/2/24 | First approved version by VA |
        """
        logger.info("\n---get_epc_side_ipaddr---1---ip_addr_dict: {}---".format(ip_addr_dict))
        if not ip_addr_dict:
            i = 0
            while i < 5:
                try:
                    i += 1
                    if not self.sma_ue_addr_dict:
                        self.fetch_smawave_ue_addr(ue_index)
                    ip_addr_dict = self.sma_ue_addr_dict
                    break
                except Exception as e:
                    ex = e
                    time.sleep(20)
            else:
                assert ip_addr_dict, "Fetch UE {} Addr Failed after retrying for 3 minutes. " \
                                     "The last error is: {}".format(ue_index, ex)

        logger.info("\n---get_epc_side_ipaddr---2---ip_addr_dict: {}---".format(ip_addr_dict))
        try:
            ip_address = ip_addr_dict.get(ue_index)
            return ip_address
        except Exception:
            raise Exception("invalid ue index - list index out of range")

    def fetch_smawave_ue_addr(self, ue_index):
        """
        This method used to get SMAWave UE IP address after attach operation.
        Please ensure comd service restart otherwise can't obtain assigned address.

        :param ue_index : UE identifier index
        """
        ute_iperf_itf_ip = self.ue_config.get('UE_{}'.format(ue_index)).get('CONSTRUCTOR_PARAMETERS').get(
            'configuration').get('data_transfer').get('iperf_interface_ip')
        self.ute_iperf_itf_ip_dict.update({ue_index: ute_iperf_itf_ip})
        logger.info("\nThe UTE iperf interface IP address for UE_{} is {}.".format(
            ue_index, ute_iperf_itf_ip), also_console=True)
        is_ipv4 = re.match(ipv4_pattern, ute_iperf_itf_ip)
        if is_ipv4:
            tmp_list = ute_iperf_itf_ip.split('.')
        else:
            tmp_list = ute_iperf_itf_ip.split(':')
        sub_ip_string = tmp_list[0]
        logger.info("\nBegin to get SMAwave UE_{} assigned IP address.".format(ue_index), also_console=True)

        if is_ipv4:
            self.sshManager.send_command(command=get_ipv4addr_cmd, connection='SMA_{}'.format(ue_index))
        else:
            self.sshManager.send_command(command=get_ipv6addr_cmd1 + get_ipv6addr_cmd2,
                                         connection='SMA_{}'.format(ue_index))
        ip_addr = self.sshManager.read_output(connection='SMA_{}'.format(ue_index))
        logger.info("\n---fetch_smawave_ue_addr---ip_addr: {}---".format(ip_addr))
        if sub_ip_string in ip_addr:
            smawave_ue_addr = ip_addr.rstrip('\n')
            self.sma_ue_addr_dict.update({ue_index: smawave_ue_addr})
            logger.info("\nSMAWave UE_{} assigned IP address is {}.".format(ue_index, smawave_ue_addr),
                        also_console=True)
            if self.add_default_route_flag and is_ipv4:
                self.check_and_add_default_route_between_app_server_and_smawave_ue(ue_index)
        else:
            raise Exception("Can't find substring {} in IP address {}".format(sub_ip_string, ip_addr))

    def fetch_android_ue_addr(self, serial_number, ue_index):
        """
        This method used to get Android UE IP address after attach operation.

        :param serial_number: the serial number of phone
        :param ue_index: UE identifier index
        """
        ute_iperf_itf_ip = self.ue_config.get('UE_{}'.format(ue_index)).get('CONSTRUCTOR_PARAMETERS').get(
            'configuration').get('data_transfer').get('iperf_interface_ip')
        logger.info("\nThe UTE iperf interface IP address for UE_{} is {}.".format(
            ue_index, ute_iperf_itf_ip), also_console=True)
        self.ute_iperf_itf_ip_dict.update({ue_index: ute_iperf_itf_ip})
        get_ipaddr_cmd_android = \
            "adb -s {} shell ip a |grep inet |grep global |awk '{{print $2}}'| cut -d / -f 1 | head -n 1".\
            format(serial_number)
        logger.info("\nBegin to get Android UE IP address.", also_console=True)
        self.sshManager.send_command(command=get_ipaddr_cmd_android, connection='cpc_{}'.format(ue_index))
        android_ue_ip_addr = self.sshManager.read_output(connection='cpc_{}'.format(ue_index))
        android_ue_ip_addr = android_ue_ip_addr.strip('\n').strip('\r')
        if android_ue_ip_addr == "":
            raise Exception("No IP Address Found.")
        logger.info("\nAndroid UE assigned IP address is {}.".format(android_ue_ip_addr), also_console=True)
        return android_ue_ip_addr

    def check_and_add_default_route_between_app_server_and_smawave_ue(self, ue_index):
        """
        This method is to enusre the default route is exsit between App Server and SMAwave UE before
        data transfer is performed, add one default route if not exist.
        Note : This method is just used for some abnormal SMAwave UEs as WA, it will be removed
        or commented when related bug is resolved, the issue appear on UE load SQXR60_V1.0.1

        :param ue_index : UE identifier index
        """
        logger.info("\nBegin to check whether default route is exist between App Server and SMAWave UE.",
                    also_console=True)
        route_check_cmd = 'ip route > /tmp/ue_{}_route_table.txt'.format(ue_index)
        route_add_cmd = 'route add -net 0.0.0.0 gw 27.168.1.9'
        self.sshManager.send_command(command=route_check_cmd, connection='SMA_{}'.format(ue_index))
        output_dir = BuiltIn().replace_variables('${OUTPUT_DIR}') + '/ue_{}_route_table.txt'.format(ue_index)
        self.sshManager.download_file(remote_path='/tmp/ue_{}_route_table.txt'.format(ue_index),
                                      local_path=output_dir,
                                      connection='SMA_{}'.format(ue_index))
        return_result = self.check_default_route_exist(output_dir)
        if return_result:
            logger.info("\nthe default route is already exist,no other operation is required!", also_console=True)
        else:
            logger.info("\nthe default route is not exist,begin to add it!", also_console=True)
            self.sshManager.send_command(command=route_add_cmd, connection='SMA_{}'.format(ue_index))

    @staticmethod
    def check_default_route_exist(input_file):
        """
        This method used to parse 'ip route' command output file

        :param input_file:
        :return: True if found False otherwise
        """
        with open(input_file) as FH:
            for item in FH:
                if 'default' in item and '27.168' in item and 'usb0.1' in item:
                    return 'True'
        return 'False'
