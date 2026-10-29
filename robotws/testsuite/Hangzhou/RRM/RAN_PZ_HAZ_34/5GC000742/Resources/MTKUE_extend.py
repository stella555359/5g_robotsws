import json
import logging
from robot.libraries.BuiltIn import BuiltIn
from abc import ABCMeta, abstractmethod
from taf.transport.ssh import ssh
from taf.ue.rpc.mtk import mtk
import re
import time


def get_value_from_dict_by_key(msg, needkey):
    tmp = msg
    if isinstance(tmp, dict):
        for k, v in tmp.items():
            if k == needkey:
                return v
            else:
                if isinstance(v, dict):
                    res = get_value_from_dict_by_key(v, needkey)
                    if res is not None:
                        return res


class MaceProxy(object):

    def __init__(self):
        self._pyro_client = None
        self.alias = "MTK"

    def setup(self, server_ip, pyro_port):
        self._pyro_client = mtk()
        self._pyro_client.configure(hostname=server_ip, port=pyro_port)
        self._pyro_client.create_proxy(self.alias)
        logging.info(
            'Proxy service Connected! IP:{} PROT:{}'.format(
                server_ip, pyro_port))

    def send_at_command(self, cmd):
        ret = self._pyro_client.send_at_command(cmd, self.alias)
        logging.info('{} response = {}'.format(cmd, ret))
        return ret

    def resetlog(self, db, com='auto'):
        self._pyro_client.connect_device(db, proxy=self.alias)
        self._pyro_client.set_filter(proxy=self.alias)

    def inject_message(
            self,
            message_id,
            src_module,
            dest_module,
            sap,
            local_param):
        ret = self._pyro_client.inject_message(
            message_id, src_module, sap, local_param, dest_module, self.alias)
        logging.info('inject_message {} {} {} {} {}, response = {}'.format(
            message_id, src_module, sap, local_param, dest_module, ret))
        return ret

    def collect_ota_message_until(self, expected, wait_timeout=30):
        ret = self._pyro_client.read_ota_message_until(
            expected, wait_timeout=wait_timeout, proxy=self.alias)
        logging.info('ota message = {}'.format(ret[-1]))
        return ret[-1]

    def collect_ota_json_message_unitl(self, expected, wait_timeout=30):
        ret = self._pyro_client.read_ota_message_details_until(
            expected, wait_timeout=wait_timeout, proxy=self.alias)
        logging.info('ota json message = {}'.format(ret[-1]))
        return ret[-1]

    def ports_ready(self):
        logging.info('mace ports ready.')
        ret = self._pyro_client.is_com_ports_ready(proxy=self.alias)
        logging.info('mace ports ready response = {}'.format(ret))
        return ret


class UECONFIG():

    def init_config(self, varstr="${tl.ues[0]}"):
        ueobj = BuiltIn().get_variable_value(varstr)
        ueinfo = self._MapConfigToDict(ueobj)
        try:
            ueinfo = self._MapFromMTKextend(ueinfo)
        except BaseException as error:
            logging.info("failed to map from mtkextend error:{}".format(error))
            pass
        return ueinfo

    def _MapFromMTKextend(self, ue_config):
        mtkextend = BuiltIn().get_variable_value("${MTK_extend}")
        if "inject_file" in mtkextend:
            ue_config['ue']['inject_message'] = self._get_inject_msg(
                mtkextend['inject_file'])
        if "cmd_file" in mtkextend:
            ue_config['ue']['beforeattach'] = self._get_at_commmands(
                mtkextend['cmd_file'])
        return ue_config

    def _MapConfigToDict(self, ue):
        ue_config = {
            'ue': {
                "edb_file_path": ue.edb_file_path,
                'apn': ue.apn_url},
            "controlpc": {
                "host": ue.ssh_connection_details.addr,
                "username": ue.ssh_connection_details.username,
                "password": ue.ssh_connection_details.password,
                'pyro_port': ue.server_port}
        }
        self.config = ue_config
        ue_config['ue']['inject_message'] = []
        if hasattr(ue, "inject_file"):
            ue_config['ue']['inject_message'] = self._get_inject_msg(
                ue.inject_file)
        if hasattr(ue, "cmd_file"):
            ue_config['ue']['beforeattach'] = self._get_at_commmands(
                ue.cmd_file)
        return ue_config

    def _get_inject_msg(self, filepath):
        conn = ssh().connect_to(
            hostname=self.config["controlpc"]['host'],
            username=self.config["controlpc"]['username'],
            password=self.config["controlpc"]['password'],
            alias="init_mtk")
        ssh().download_file(filepath, "/tmp/injectfile.tcl", "init_mtk")
        ssh().disconnect(connection="init_mtk")
        f = open("/tmp/injectfile.tcl", 'r')
        lines = f.readlines()
        regx = r"send_pcommand ([\s\S]*)"
        inject_messages = []
        for line in lines:
            line = line.replace(
                '"',
                '').replace(
                "'",
                '').replace(
                '\r\n',
                '')
            ret = re.match(regx, line)
            if ret:
                message = ret.group(1)
                message = message.split(" ")
                inject_messages.append(message)
        f.close()
        return inject_messages

    def _get_at_commmands(self, filepath):
        all_cmd = []
        conn = ssh().connect_to(
            hostname=self.config["controlpc"]['host'],
            username=self.config["controlpc"]['username'],
            password=self.config["controlpc"]['password'],
            alias="init_mtk")
        if isinstance(filepath, list):
            filepath = filepath
        else:
            filepath = [filepath]
        for file in filepath:
            ssh().download_file(file, "/tmp/atcommand.txt", "init_mtk")
            commands = self._format_at_command("/tmp/atcommand.txt")
            all_cmd.append(commands)
        ssh().disconnect(connection="init_mtk")
        return all_cmd

    def _format_at_command(self, filepath):
        f = open(filepath, "r")
        lines = f.readlines()
        commands = []
        start = False
        for line in lines:
            if start and line[1] == " ":
                cmd = line.replace("\n", "")
                cmd = cmd.strip()
                commands.append(cmd)
            else:
                start = False
            if "before_Attach" in line:
                start = True
        f.close()
        return commands


class MTKUE(MaceProxy):

    @abstractmethod
    def __init__(self):
        pass

    def _inject_message_from_file(self):
        if len(self.ue_config['ue']['inject_message']) > 0:
            messages = self.ue_config['ue']['inject_message']
        else:
            messages = [["MOD_VGMM", 1, "SET_FOR_BIT"]]
        message_id = 'MSG_ID_TST_INJECT_STRING'
        src_module = 'MOD_DHL_READER'
        des_module = None
        sap = 'INVALID_SAP'
        local_param = {'index': 0, 'string': ''}
        for message in messages:
            des_module = message[0]
            try:
                message[1] = int(message[1])
            except BaseException:
                pass
            local_param['index'] = message[1]
            local_param['string'] = message[2]
            self.inject_message(
                message_id,
                src_module,
                des_module,
                sap,
                local_param)
            time.sleep(1)

    def _send_before_attach_command(self, index):
        commands = self.ue_config['ue']['beforeattach'][index]
        self._send_at_commands(commands, interval=1)

    def _get_nas_5gs(self, otamsg, keyname="nas-5gs"):
        res = get_value_from_dict_by_key(otamsg, keyname)
        return res

    def _get_ue_ip_new(self):
        expected = "pdu_addr_inf_ipv4"
        logging.info("Collecting ue ip with expected '{}'".format(expected))
        msgdetail = self.collect_ota_json_message_unitl(
            expected, wait_timeout=120)
        msgdetail = re.sub(
            r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{6}',
            '',
            msgdetail)
        logging.info("Collecting ue ip with expected '{}'".format(msgdetail))
        msgdetail = json.loads(msgdetail, encoding='utf-8')

        nas5gs_msg = self._get_nas_5gs(msgdetail)
        ueip = nas5gs_msg['Plain NAS 5GS Message']['Payload container'][
            'Plain NAS 5GS Message']['PDU address']['nas_5gs.sm.pdu_addr_inf_ipv4']
        drbips = self._get_multiDRB_ip(nas5gs_msg)
        logging.info("multiDRB '{}'".format("|".join(drbips)))
        return (ueip, drbips)

    def _get_multiDRB_ip(self, nas5gs_msg):
        rules = nas5gs_msg['Plain NAS 5GS Message']['Payload container'][
            'Plain NAS 5GS Message']['QoS rules - Authorized QoS rules']
        ips = []
        for rule in rules:
            DRBip = get_value_from_dict_by_key(
                rules[rule], "nas_5gs.sm.pdu_addr_inf_ipv4")
            if DRBip is not None:
                ips.append(DRBip)
        return ips

    def _get_ota_json_val(self, expected, msgdetail):
        if expected in msgdetail:
            lines = msgdetail.split('\r\n')
            pattern_str = r'{}":\s*"(.*)"'.format(expected)
            pattern = re.compile(pattern_str)
            for line in lines:
                logging.info(line)
                result = pattern.search(line)
                if result:
                    return result.groups(1)[0].strip()
        else:
            return None

    def _send_at_commands(self, commands, interval=None):
        for cmd in commands:
            self.send_at_command(cmd)
            if interval:
                time.sleep(interval)

    def init_mtk(
            self,
            ue_config_path=None,
            alias=None,
            reset=False,
            beforeattach=None,
            inject_file=None,
            cmd_file=None):
        MaceProxy.__init__(self)
        ueconfig = UECONFIG()
        self.ue_config = ueconfig.init_config()
        if inject_file:
            self.ue_config['ue']["inject_message"] = ueconfig._get_inject_msg(
                inject_file)
        if cmd_file:
            self.ue_config['ue']["beforeattach"] = ueconfig._get_at_commmands(
                cmd_file)
        self.setup(
            self.ue_config['controlpc']['host'],
            self.ue_config['controlpc']['pyro_port'])
        if reset:
            self.resetlog(db=self.ue_config['ue']['edb_file_path'])
            self.send_at_command(r"AT+CFUN=1,1")
            logging.info("Reset MTK wait 30s")
            time.sleep(30)
        p_status = self.ports_ready()
        if p_status:
            if beforeattach is not None:
                self._send_before_attach_command(int(beforeattach))
            self._inject_message_from_file()
        else:
            raise Exception("Port disconnected, Exit test.")

    def create_pdu_session(
            self,
            id="1",
            wap="wap1.nokia.com",
            slice=False,
            multiDRB=False,
            retry=0,
            waittime=30):
        if slice:
            cmds = [r'AT+EAPNACT={id},"{wap}","default",0'.format(
                id=id, wap=wap)]
        else:
            cmds = [r'AT+CGDCONT={id},"IPV4V6","{wap}"'.format(id=id, wap=wap),
                    r'AT+CGACT=1,{id}'.format(id=id)]
        retry = int(retry)
        while retry >= 0:
            self.resetlog(db=self.ue_config['ue']['edb_file_path'])
            self._send_at_commands(cmds)
            expected = "VGSM_PDU_SESSION_ESTABLISHMENT_ACCEPT"
            otamsg = self.collect_ota_message_until(expected, waittime)
            if expected in otamsg:
                logging.info("Create PDU {} success.".format(id))
                res = self._get_ue_ip_new()
                if multiDRB:
                    return res
                else:
                    return res[0]
            else:
                cause = self.get_expected_val("nas_5gs.mm.5gmm_cause")
                logging.info("casues:{}".format(cause))
                if cause == "90":
                    retry = retry - 1
                else:
                    raise Exception("Failed to create PDU {}.".format(id))
        raise Exception("Failed to create PDU {}.".format(id))

    def release_pdu_session(self, id="1", slice=False, waittime=30):
        if slice:
            cmd = r'AT+EAPNACT=0,{}'.format(id)
        else:
            cmd = r'AT+CGACT=0,{}'.format(id)
        self.resetlog(db=self.ue_config['ue']['edb_file_path'])
        ret = self.send_at_command(cmd)
        expected = "VGSM_PDU_SESSION_RELEASE_COMPLETE"
        otamsg = self.collect_ota_message_until(expected, waittime)
        if expected in otamsg:
            logging.info("Release PDU {} success.".format(id))
        else:
            raise Exception("Failed to release PDU {}.".format(id))

    def get_expected_val(self, expected, waittime=120):
        msgdetail = self.collect_ota_json_message_unitl(
            expected, wait_timeout=waittime)
        result = self._get_ota_json_val(expected, msgdetail)
        return result

    def _check_ota_json_ie(self, expected, msgdetail):
        if expected in msgdetail:
            return expected
        else:
            return None

    def check_expected_ie(self, expected, waittime=120):
        msgdetail = self.collect_ota_json_message_unitl(
            expected, wait_timeout=waittime)
        result = self._check_ota_json_ie(expected, msgdetail)
        return result

    def get_expected_msg_with_given_ie(self, expected, waittime=120):
        msgdetail = self.collect_ota_json_message_unitl(
            expected, wait_timeout=waittime)
        return msgdetail

    def get_expected_val_in_given_msg(self, expected, msgdetail):
        result = self._get_ota_json_val(expected, msgdetail)
        return result

    def check_expected_ie_in_given_msg(self, expected, msgdetail):
        result = self._check_ota_json_ie(expected, msgdetail)
        return result
