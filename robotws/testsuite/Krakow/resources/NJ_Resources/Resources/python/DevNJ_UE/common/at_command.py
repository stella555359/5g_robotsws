"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import re
from robot.api import logger
from taf.transport.ssh import ssh


class AtCommand(object):
    def __init__(self, ue_info, ue_index):
        """
        Class for sending or parse AT command related functions.

        :param ue_info: UE information
        :param ue_index: UE identifier index
        """
        self.conn = None
        self.ue_index = ue_index
        self.ue_config = ue_info
        self.ue_alias = "UE_{}".format(ue_index)
        self.sshManager = ssh()

    def connect(self, conn=None):
        """
        Setup connection with UE
        """
        try:
            if conn is None:
                ue_info = self.ue_config.get('{}'.format(self.ue_alias)).get(
                    'CONSTRUCTOR_PARAMETERS').get('configuration')
                host_name = ue_info.get('ue_pc_ip')
                user_name = ue_info.get('login')
                pass_word = ue_info.get('password')
                self.conn = self.sshManager.connect_to(hostname=host_name, username=user_name, password=pass_word,
                                                       alias='SMA_{}'.format(self.ue_index))
            else:
                self.conn = conn
        except ConnectionError as msg:
            raise Exception("Connect to UE failed with Error: {}".format(msg))
        return self.conn

    def disconnect(self):
        """
        Close connection with UE
        """
        self.sshManager.disconnect(connection=self.conn)

    def send_at_cmd_to_ue(self, at_cmd, conn=None, timeout=4):
        """
        Send AT command to qualcomm UE

        :param at_cmd: AT_COMMAND define on 3gpp
        :param conn: ssh connection of UE
        :param timeout: Get return timeout
        :return <str> response of AT_COMMAND
        """
        at_cmd = str(at_cmd)

        if conn is None:
            self.conn = self.connect(self.ue_index)
        else:
            self.conn = conn

        logger.info("Sending AT command:{}".format(at_cmd))
        self.sshManager.send_command(command=at_cmd, connection=self.conn)
        res = self.sshManager.read_output(connection=self.conn)

        return res

    def execute_at_cmd_to_ue(self, at_cmd, conn=None, timeout=4):
        """
        Execute AT command to qualcomm UE

        :param at_cmd: AT_COMMAND define on 3gpp
        :param conn: ssh connection of UE
        :param timeout: Get return timeout
        :return <str> response of AT_COMMAND
        """
        at_cmd = str(at_cmd)

        if conn is None:
            self.conn = self.connect(self.ue_index)
        else:
            self.conn = conn

        logger.info("Execute AT command:{}".format(at_cmd))
        self.sshManager.execute(command=at_cmd, connection=self.conn)
        res = self.sshManager.read_output(connection=self.conn)

        return res

    @staticmethod
    def verify_atcmd_output(at_cmd_res):
        """
        This method used to verify the output of command AT+COPS?

        :param at_cmd_res: AT command output from openwrt
        :return one of 5G/4G/Idle, None otherwise
        """
        logger.info("The original output to be verified is : {0}".format(at_cmd_res))
        new_string = re.sub('[\r\n]', '', at_cmd_res)
        logger.info("Updated output to be verified is : {0}".format(new_string))
        result = re.match("\\+COPS:\\s*0,\\d+,\"([^\"]*)\",(\\d*)OK", new_string)
        if result and (result.group(2) == '13' or result.group(2) == '11'):
            return '5G'
        elif result and result.group(2) == '7':
            return '4G'
        else:
            ret = re.match("\\+COPS:\\s*\\d?OK", new_string)
            return 'Idle' if ret else None

    @staticmethod
    def verify_attach_status(input_value):
        """
        This method used to verify smawave UE attach status

        :param input_value: output of verify_atcmd_output method
        :return Attach, Error_status otherwise
        """
        return 'Attach' if input_value in ['4G', '5G'] else 'Error_status'

    @staticmethod
    def parse_atcmd_cell_info_into_dict(input_str):
        """
        This method used to parse output of check cell info at command

        :param input_str: AT command output from openwrt
        :return: cell info dictionary format as below:
        {'mode': 'ENDC',
         'cell_details': [{'pci': 311, 'cell_id': '841D01', 'arfcn': '3E8', 'is_service': '1', 'band': '102'},
                          {'pci': 313, 'cell_id': '', 'arfcn': '6979E', 'is_service': '1', 'band': '5066'}]}
        """
        parse_dict = {'mode': '', 'cell_details': []}
        logger.info("The output of AT+GTCCINFO? command : {0}".format(input_str))
        if input_str:
            resp_list = [re.sub('[\r\n]', '', item.strip()) for item in input_str if item.strip() != '']
            for iter_str in resp_list:
                if iter_str.endswith('cell:') and 'neighbor' not in iter_str:
                    if 'LTE-NR' and 'EN-DC' in iter_str:
                        parse_dict['mode'] = 'ENDC'
                    elif 'NR' in iter_str and '-' not in iter_str:
                        parse_dict['mode'] = 'NR'
                    elif 'LTE' in iter_str and '-' not in iter_str:
                        parse_dict['mode'] = 'LTE'

                if iter_str[0].isdigit() and iter_str[-1].isdigit() and ',' in iter_str:
                    tmp_dict = {}
                    tmp_dict['is_service'] = iter_str.split(',')[0]
                    tmp_dict['cell_id'] = iter_str.split(',')[5]
                    tmp_dict['arfcn'] = iter_str.split(',')[6]
                    tmp_dict['pci'] = int(iter_str.split(',')[7], 16)
                    tmp_dict['band'] = iter_str.split(',')[8][2:]
                    parse_dict['cell_details'].append(tmp_dict)

        return parse_dict

    @staticmethod
    def parse_atcmd_locked_freq_info(input_string):
        """
        This method used to parse the output of command AT+GTFREQLOCK?

        :param input_string: AT command output from openwrt
        :return the locked frequency(xfcn means earfcnDL for 4G, nrarfcn for 5G), pci or scs,
                if no locked frequency return None

        e.g. Returned locked frequency: {'4G': {'xfcn': '1650', 'pci': '310'}, '5G': {'xfcn': '636200', 'scs': '1'}}
             No frequency locked: {'4G': None, '5G': None}
             Status not available: {'4G': 'ongoing', '5G': 'ongoing'}
        """
        logger.info("The original output to be parsed is : {0}".format(input_string))
        new_string = re.sub('[\r\n]', '', input_string)
        logger.info("Updated output to be verified is : {0}".format(new_string))
        result = re.match("\\+GTFREQLOCK:\\s*4G:\\s*(\\S+)5G:\\s*(\\S+)OK", new_string)
        logger.info("result: {0}".format(result))
        parse_dict = {'4G': None, '5G': None}
        if result and result.group(1) != '0':
            ret = re.match("\\d+,(\\d+),(\\d+)", result.group(1))
            parse_dict['4G'] = {'xfcn': ret.group(1), 'pci': ret.group(2)}
        if result and result.group(2) != '0':
            ret = re.match("\\d+,(\\d+),(\\d+)", result.group(2))
            parse_dict['5G'] = {'xfcn': ret.group(1), 'scs': ret.group(2)}
        if not result and re.match(".*OK", new_string):
            parse_dict.update([('4G', 'ongoing'), ('5G', 'ongoing')])

        return parse_dict

    @staticmethod
    def parse_atcmd_sa_mode_info(input_string):
        """
        This method used to parse the output of command AT+GTSET?

        :param input_string: AT command output from openwrt
        :return the SA mode status, enable means SA mode on, disable means SA mode off,
                                    unavailable means input_string does not contain "5GSACTR"

        e.g. Returned
             SA mode on: 'enable'
             SA mode off: 'disable'
             Status not available: 'unavailable'
        """
        logger.info("The original output to be parsed is : {0}".format(input_string))
        new_string = re.sub('[\r\n]', '', input_string)
        logger.info("Updated output to be verified is : {0}".format(new_string))
        result = re.search("\\+GTSET: \"5GSACTR\",\\d", new_string)
        logger.info("result: {0}".format(result))
        logger.info("result.group(): {0}".format(result.group()))
        logger.info("result.group().split()[-1]: {0}".format(result.group()[-1]))
        if result and result.group()[-1] == '1':
            return 'enable'
        if result and result.group()[-1] == '0':
            return 'disable'
        if not result and re.match(".*OK", new_string):
            return 'unavailable'
