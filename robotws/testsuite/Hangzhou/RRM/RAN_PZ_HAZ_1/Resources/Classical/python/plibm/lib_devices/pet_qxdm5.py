# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import six
import logging
import time
import os
import socket
import time
import json
import select
import re
import six
from xmlrpc import client as xml_client

from pet_ssh import cpc_factory


class Qxdm5Client():

    def __init__(self, host, port=22, username='csv5-tester', password='Nokia123!', g4_port=5, logger=None):
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.g4_port = g4_port

        self.logger = logger or logging.getLogger('PET_TA')
        self.cpc = cpc_factory(host=host, port=port, username=username, password=password, os='windows')
        self.rpc_port = 8001
        self.ueid = '0'
        self.version = 5

    def stop_agent(self):
        self.cpc.exec_command('taskill /f /im python.exe')

    def start_agent(self):
        cmd = ('psexec -i {} -d -u {} -p {} '
               ' c:\\python27\\python.exe c:\\python27\\qxdm5_rpcs.py').format(
                   self.cpc.rdp_session_id, self.cpc.longname, self.cpc.password)
        self.execute_command(cmd)

    def setup(self):
        self.cpc.setup()
        self.stop_agent()
        self.start_agent()
        time.sleep(2)
        super(Qxdm5Client, self).setup('LOW')
        self.server = xml_client.ServerProxy(f'http://{self.host}:{self.rpc_port}')
        self.logger.info('setup Client done')

    def setup_server(self):
        self.logger.info('Deivce kw: {}'.format(self.device_kw))
        self.server.setup(self.device_kw)

    def reset_ue(self):
        self.server.send_command('mode reset')

    def deattach_ue(self):
        self.server.send_command('mode lpm')
        self.logger.info('deattach ok')

    def attach_ue(self):
        self.server.send_command('mode online')

    def reattach_ue(self):
        self.deattach_ue()
        time.sleep(2)
        self.attach_ue()

    def start_logging(self):
        self.server.start_logging()

    def save_logfile(self, filename):
        self.server.save_logfile(r'{}'.format(filename))

    def attach_and_save_log(self, hdf_file='c:\\ta\\ta.hdf', dmc_file='c:\\ta\\attach_dmc.dmc', wait_time=10):
        self.setup_server()
        self.server.create_diag_service(dmc_file)
        self.server.create_qxdm_service()
        self.start_logging()
        self.deattach_ue()
        time.sleep(2)
        self.attach_ue()
        time.sleep(wait_time)
        self.save_logfile(hdf_file)
        self.server.teardown()

    def save_attach_log(self, traffic_time, hdf_file='c:\\ta\\ta.hdf', dmc_file='c:\\ta\\attach_dmc.dmc'):
        self.start_log(dmc_file)
        time.sleep(int(traffic_time))
        self.stop_log(hdf_file)

    def start_log(self, dmc_file='c:\\ta\\attach_dmc.dmc'):
        self.logger.info('QXDM start log...')
        self.setup_server()
        self.server.create_diag_service(dmc_file)
        self.server.create_qxdm_service()
        self.start_logging()

    def stop_log(self, hdf_file='c:\\ta\\ta.hdf'):
        self.logger.info('QXDM stop log...')
        self.save_logfile(hdf_file)
        self.server.teardown()

    def save_throughput_log(self, traffic_time, hdf_file='c:\\ta\\ta.hdf', dmc_file='c:\\ta\\tput_dmc.dmc'):
        self.start_log(dmc_file)
        time.sleep(int(traffic_time))
        self.stop_log(hdf_file)

    def read_imei(self):
        response = self.server.execute_command_on_com_port(f'COM{self.public_port}', '38400', 'at+cimi')
        self.logger.info(response)
        lines = [x for x in re.findall(r'[0-9]+', response) if x.strip()]
        self.logger.info(lines)
        return lines[0]

    def dump_uim(self):
        s = 'c:\\python27\\python.exe c:\\python27\\efstool.py -p {} -d down -l c:\\ta\\dump.efs'.format(self.g4_port)
        cmd = 'psexec -i {cpc.rdp_session_id} -d -u {cpc.longname} -p {cpc.password} {s}'.format(
              cpc=self.cpc, s=s)
        self.cpc.execute_command(cmd)
        time.sleep(5)

    def import_uim(self, remote_file):
        s = 'c:\\python27\\python.exe c:\\python27\\efstool.py -p {} -d up -l {}'.format(self.g4_port, remote_file)
        cmd = 'psexec -i {cpc.rdp_session_id} -d -u {cpc.longname} -p {cpc.password} {s}'.format(
              cpc=self.cpc, s=s)
        self.execute_command(cmd)
        time.sleep(5)

    def switch_uim(self, uimfile, cardname='uim0', need_reboot=True):
        # 需要准备efs文件
        self.logger.info('UIM file is: {}'.format(uimfile))
        if not os.path.exists(uimfile):
            raise Exception('UIM file {} does not exist.'.format(uimfile))
        self.cpc.put_file_to_cpc(uimfile, 'C:\\ta\\ta.efs')
        self.import_uim('C:\\ta\\ta.efs')
        if need_reboot:
            self.server.reset_phone()
            time.sleep(40)

    def get_ue_ip(self):
        lines = self.execute_command('adb shell "ifconfig|grep inet"').splitlines()
        lines = [x for x in lines if 'inet6' not in x]
        lines = [x for x in lines if '127.0.0.1' not in x if x.strip()]
        lines = [x for x in lines if 'addr:' in x]
        ipaddr = lines[0].split()[1].split(':')[-1].strip() if lines else ''
        return ipaddr

    # QCAT part
    def reformat_message(self, msg):
        text = msg['text'].splitlines()
        i = 0
        if text:
            for i in range(len(text)):
                if 'Interpreted PDU' in text[i]:
                    break
                else:
                    if text[i].strip():
                        for part in text[i].split(','):
                            if '=' in part:
                                key = part.split('=')[0].strip().replace(' ', '_').replace('.', '_')
                                value = part.split('=')[1].strip().replace(' ', '_')
                                msg[key] = value
            msg['text'] = '\n'.join(text[i:])
            msg['type'] = hex(eval(str(msg.get('type', '0')))).upper()
            if msg.get('subtitle', '/'):
                msg['msg_type'], msg['msg_title'] = msg.get('subtitle', '/').split('/')
                msg['msg_type'] = msg['msg_type'].strip()
                msg['msg_title'] = msg['msg_title'].strip()

    def read_isf_messages(self, json_file):
        msgs = json.loads(open(json_file).read())
        for msg in msgs:
            self.reformat_message(msg)
        with open(json_file, 'w') as f:
            f.write(json.dumps(msgs))
        return msgs

    def read_isf_messages2(self, json_file):
        msgs = json.loads(open(json_file).read())
        return msgs

    def get_hdf_content(self, remote_isf_filename, local_isf_filename, local_json_file, myfilter='0xB0C0'):
        cmd = ('c:\\python27\\python.exe c:\\python27\\pet_isftool.py -o full -s '
               '{} -d C:\\ta\\ta_filtered.hdf -j C:\\ta\\ta_filtered.json'.format(remote_isf_filename))
        if myfilter:
            cmd += ' -f {}'.format(myfilter)
        self.execute_command(cmd)
        self.get_file_from_cpc(r'C:\ta\ta_filtered.hdf', local_isf_filename)
        self.get_file_from_cpc(r'C:\ta\ta_filtered.json', local_json_file)
        return self.read_isf_messages(local_json_file)

    def test(self):
        self.server.setup()
        self.server.create_diag_service('c:\\ta\\attach_dmc.dmc')
        self.start_logging()
        time.sleep(10)
        self.server.save_logfile(r'c:\ta\test.hdf')
        self.server.teardown()


if __name__ == '__main__':
    logging.basicConfig(
        format='%(asctime)s %(name)s: [%(levelname)5s] %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S', level=logging.DEBUG)

    client = Qxdm5Client(id='104')
    client.setup()
    # client.read_imei()
    client.setup_server()
    # imei = client.read_imei()
    # print('xxxxxxx   ', imei)
    logging.info('0')
    # client.server.create_diag_service('c:\\ta\\attach_dmc.dmc')
    # logging.info('1')
    client.server.create_qxdm_service()
    client.server.teardown()
