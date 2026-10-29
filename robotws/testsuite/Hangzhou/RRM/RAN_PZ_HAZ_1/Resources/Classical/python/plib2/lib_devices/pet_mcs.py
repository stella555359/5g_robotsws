# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import time
import logging
import telnetlib
import six
import re
import os
import sys
import socket
from robot.api import logger
try:
    from pet_ssh import cpc_factory
except Exception:
    from .pet_ssh import cpc_factory


class McsController_JX_1(object):

    def __init__(self, id='', logger=None, **kwargs):
        self._show_in_rfhub = False
        self.id = id
        self.version = 1
        self.logger = gv.logger
        self.mcs_conn = None
        self.db = gv.db['mcs'][id]
        self.frequency = self.db.get('frequency', '2600')
        self.db_path = self.db.get('db_path', '')
        self.app_path = self.db.get('app_path', '')
        self.mcs_port = self.db.get('mcs_port', '18888')
        self.device_ip = self.db.get('device_ip', '18888')
        self.host = self.db.get('host')
        self.device_connected = False
        self.cpc = None

    def setup(self, control_pc=True):
        self.cpc = cpc(host=self.db.get('cpc'))
        self.cpc.connect()
        self.cpc.get_rdp_session()
        self.stop_msc_server()
        self.start_mcs_server()

        self.cpc.wait_until_port_is_listening(self.mcs_port, 5)
        self.connect_mcs()

    def teardown(self):
        self.disconnect_mcs()
        if self.cpc:
            self.cpc.disconnect()

    def start_mcs_server(self):
        mcs_server_dir = self.app_path.replace('\\', '/')
        cmd = 'psexec.exe -i {} -d -u {} -p {} -s {}'.format(
            self.cpc.rdp_session_id, self.cpc.username, self.cpc.password, mcs_server_dir)
        self.cpc.execute_command(cmd)

    def stop_msc_server(self):
        self.cpc.kill_process_by_keywords([os.path.basename(self.app_path.replace('\\', '/'))])

    def prepare_mcs(self):
        self.mcs_connect_to_device()
        self.device_connected = True
        self.mcs_load_db()
        self.mcs_set_frequency()
        self.logger.info('Prepare MCS Done.')

    def connect_mcs(self):
        self.logger.info('Connect to MCS Server...')
        self.mcs_conn = telnetlib.Telnet(self.host, self.mcs_port, 5)
        self.logger.info('Connect to MCS Server done.')

    def disconnect_mcs(self):
        if self.mcs_conn:
            self.logger.info('Disconnect to MCS Server...')
            if self.device_connected:
                self.mcs_dis_connect_to_device()
            self.mcs_conn.close()
            self.mcs_conn = None
            self.logger.info('Disconnect to MCS Server done.')

    def execute_mcs_command(self, command='', timout=3, prompt=b':OK'):
        self.logger.info('Execute MCS command:  {}'.format(command))
        self.mcs_conn.write(six.b(command + '\r\n'))
        if prompt:
            output = self.mcs_conn.read_until(b':OK', timout).decode()
        else:
            time.sleep(timout)
            output = self.mcs_conn.read_very_eager().decode()
        self.logger.info('MCS command response: {}'.format(output))
        return output

    def mcs_connect_to_device(self):
        return self.execute_mcs_command('CONNect:DEVIce:{}'.format(self.device_ip))

    def mcs_dis_connect_to_device(self):
        return self.execute_mcs_command('DISCONNect:DEVIce:{}'.format(self.device_ip))

    def mcs_load_db(self):
        return self.execute_mcs_command('CONNect:DB:{}'.format(self.db_path))

    def mcs_set_frequency(self):
        return self.execute_mcs_command('SET:FREQuency:{}'.format(self.frequency), 300)

    def mcs_set_att(self, inport, outport, value):
        # example: mcs_set_value(A1,B1,10)
        return self.execute_mcs_command('SETM:ATT:{}{},{}'.format(inport, outport, value))

    def mcs_set_atts(self, lines):
        # example: mcs_set_value(['A1B1,10','A2B2,10'])
        command = ';'.join(lines)
        return self.execute_mcs_command('SETM:ATT:{}'.format(command))

    def mcs_set_phase(self, inport, outport, value):
        # example: mcs_set_value(A1,B1,10)
        return self.execute_mcs_command('SETM:PHASe:{}{},{}'.format(inport, outport, value))

    def mcs_set_phases(self, lines):
        # example: mcs_set_phases(['A1B1,10','A2B2,10'])
        command = ';'.join(lines)
        return self.execute_mcs_command('SETM:PHASe:{}'.format(command))

    def mcs_set_phase_and_att(self, inport, outport, phase, att):
        return self.execute_mcs_command('SETM:{}{},{},{}'.format(inport, outport, att, phase))

    def mcs_set_phase_and_atts(self, lines):
        # example: mcs_set_phases(['A1B1,att1,phase1','A2B2,att2,phase2'])
        command = ';'.join(lines)
        return self.execute_mcs_command('SETM:{}'.format(command))

    def mcs_read_phase_and_att(self, port='', timout=1):
        # example: mcs_read_phase_and_att('A1B2')
        output = self.execute_mcs_command('READm:STATus:{}'.format(port), prompt=b'', timout=0.1)
        return output.split(':')[-1].split(',')[1:]

    def mcs_set_phase_and_atts_from_csv_file1(self, csv_file):
        self.logger.info('Load CSV file: {}'.format(csv_file))
        if not os.path.exists(csv_file):
            raise Exception('File does not exist: {}'.format(csv_file))

        lines = open(csv_file).readlines()
        for line in [x for x in lines if x.strip()][1:]:
            col_name = line.split(',')[0]
            col_values = [x.split('|') for x in line.split(',')[1:-1]]
            for index_a, (att, phase) in enumerate(col_values):
                self.execute_mcs_command('SETM:A{}{},{},{}'.format(index_a + 1, col_name, att, phase))

    def mcs_set_phase_and_atts_from_csv_file(self, csv_file):
        self.logger.info('Load CSV file: {}'.format(csv_file))
        if not os.path.exists(csv_file):
            raise Exception('File does not exist: {}'.format(csv_file))

        lines = open(csv_file).readlines()
        for line in [x for x in lines if x.strip()][1:]:
            col_name = line.split(',')[0]
            col_values = [x.split('|') for x in line.split(',')[1:-1]]
            cmdlist = []
            for index_a, (att, phase) in enumerate(col_values):
                cmdlist.append('A{}{},{},{}'.format(index_a + 1, col_name, att, phase))
            self.execute_mcs_command('SETM:' + ';'.join(cmdlist))
            time.sleep(4)

    def dump(self):
        # AnBm  16*(n-1) + m; n from 1~64, m from 1~16
        ports = ';'.join(['A{}B1'.format(a + 1) for a in range(64)])
        output = self.execute_mcs_command('READm:STATus:{}'.format(ports)).split(':')[-1]
        for config in output.split(';'):
            print(config)

    def connect_to_device_directly(self):
        self.device_conn = telnetlib.Telnet(self.host, 3000, 5)

    def dump_directly(self):
        # AnBm  16*(n-1) + m; n from 1~64, m from 1~16
        self.device_conn = telnetlib.Telnet(self.host, 3000, 5)
        for m in range(1, 17):
            line_ports = [str(16 * (n - 1) + m) for n in range(1, 65)]
            # print(line_ports)
            command = 'READM:' + ':'.join(line_ports)
            self.logger.info(command)
            self.device_conn.write(six.b(command + '\r\n'))
            output = self.device_conn.read_until(b'READM', 3).decode()
            output += self.device_conn.read_very_eager().decode()
            self.logger.info('MCS command response: {}'.format(output))
        self.device_conn.close()


class McsController_JX_2(object):

    def __init__(self, **kwargs):
        self.host = kwargs.get('host', '')
        self.port = int(kwargs.get('port', '28888'))
        self.cpc_addr = kwargs.get('cpc_ip', '')
        self.username = kwargs.get('username', r'noklab\\csv5-tester')
        self.password = kwargs.get('password', 'Nokia123!')
        self.logger = kwargs.get('logger', logging.getLogger(__file__))
        self.logger.info('Init MCS2')
        self.conn = None

    def __del__(self):
        self.disconnect()

    def connect(self):
        if self.conn is None:
            self.logger.info('Connect to MCS: {}:{}'.format(self.host, self.port))
            self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.conn.settimeout(10)
            self.logger.info(f'MCS: {self.host}:{self.port}')
            self.conn.connect((self.host, self.port))
            self.logger.info('Connect done.')

    def disconnect(self):
        if self.conn:
            self.conn.close()

    def execute_command(self, cmd='', expect_str=''):
        self.connect()
        self.conn.send(six.b(cmd.strip() + '\r\n'))
        self.logger.debug('Send command: ' + cmd)
        if expect_str:
            output = ''
            for i in range(300):
                resp = self.conn.recv(1024).decode()
                output += resp
                self.logger.debug('<--- ' + resp.replace('\n', ''))
                if expect_str in output:
                    return output
                else:
                    time.sleep(1)
        else:
            output = self.conn.recv(1024).decode()
            self.logger.debug('Get Response : ' + output)
        return output

    def get_system_info(self):
        output = self.execute_command('SYSTem:IDN')
        self.device_scale = output.split('-')[1]
        self.ph_step_num = output.split('-')[2].split(',')[0]
        if 'A' in self.ph_step_num:
            self.ph_step = 1.40625
        elif 'B' in self.ph_step_num:
            self.ph_step = 2.8125
        elif 'C' in self.ph_step_num:
            self.ph_step = 5.625
        self.logger.info('scale: {}, ph_step:{}'.format(self.device_scale, self.ph_step))

    def get_resource_usage(self):
        output = self.execute_command('GETM:INFO')
        if self.cpc_addr:
            pass
        else:
            ip_addr = list(set(re.findall(r'([\d]{1,3}[.][\d]{1,3}[.][\d]{1,3}[.][\d]{1,3})', output)))
            if ip_addr:
                self.logger.info('Resource used by {}'.format(ip_addr))
                self.cpc_addr = ip_addr[0]
            else:
                self.logger.info('Resource are free.')
                return 0

        self.cpc = cpc_factory(host=self.cpc_addr,
                               username=self.username,
                               password=self.password,
                               os='windows')
        self.cpc.connect()
        # self.cpc.get_rdp_session()
        self.cpc.kill_process_by_keywords(['MCS_Controller.exe'])
        self.cpc.disconnect()
        self.other_clients = self.cpc_addr

    def lock_all_channel(self):
        for i in range(1, 17):
            self.execute_command('SET:ALLOC:CHANnel:{}'.format(i))

    def get_frequency(self):
        output = self.execute_command('GET:CSN')
        frequency = output.split(':')[2].split(';')[0]
        self.logger.info('Frequency: {}'.format(frequency))
        self.execute_command('CSN:LOAD:{}'.format(frequency), 'CSN:LOAD:OK')

    def set_phase_and_atts_with_csv_file(self, csv_file):
        self.logger.info('Load CSV file: {}'.format(csv_file))
        if not os.path.exists(csv_file):
            raise Exception('File does not exist: {}'.format(csv_file))

        lines = open(csv_file).readlines()
        cmds = []
        for line in [x for x in lines if x.strip()][1:]:
            col_name = line.split(',')[0]
            col_values = [x.split('|') for x in line.split(',')[1:-1]]
            for index_a, (att, phase) in enumerate(col_values):
                cmds.append('A{}{},{},{}'.format(index_a + 1, col_name, att, phase))
        self.execute_command('SETM:{}'.format(';'.join(cmds)), 'SETM:OK')

    def setup(self):
        self.connect()
        self.get_system_info()
        self.get_resource_usage()
        self.lock_all_channel()
        self.get_frequency()

    def teardown(self):
        self.disconnect()


class MCS_Hbte(object):

    def __init__(self, host, port=23) -> None:
        self.host = host
        self.port = port
        self.mcs_conn = None
        self.logger = logger

    def connect(self):
        self.mcs_conn = telnetlib.Telnet(self.host, self.port, 5)

    def execute_mcs_command(self, command='', timout=1, prompt=b'OK'):
        self.logger.info('Execute MCS command:  {}'.format(command))
        self.mcs_conn.write(six.b(command + '\r\n'))
        if prompt:
            output = self.mcs_conn.read_until(b':OK', timout).decode()
        else:
            time.sleep(timout)
            output = self.mcs_conn.read_very_eager().decode()
        self.logger.info('MCS command response: {}'.format(output))
        return output

    def login(self, username='USER 1'):
        return self.execute_mcs_command('LOGIN:{}'.format(username))

    def force_free_channel(self):
        return self.execute_mcs_command('forcefree')

    def get_system_info(self):
        return self.execute_mcs_command('query:info')

    def alloc_channel(self, channelid):
        return self.execute_mcs_command(f'set:alloc:channel:{channelid}')

    def read_from_csv(self, csv_filename):
        m_phase = []
        from types import SimpleNamespace
        if os.path.exists(csv_filename):
            lines = open(csv_filename).read().splitlines()[2:]
            for rownum, line in enumerate(lines):
                for colnum, value in enumerate([x for x in line.split(',') if x.strip()]):
                    m_phase.append(SimpleNamespace(col=colnum, row=rownum, value=float(value)))
        return m_phase

    def set_with_matrix(self, mode, m_phase):
        for colnum in range(16):
            points = [x for x in m_phase if x.col == colnum]
            cmd = ''
            for point in points:
                cmd += f'{point.row+1},{point.col+1},{point.value};'
            if mode.lower() == 'phase':
                cmd = 'set:phase:' + cmd
            else:
                cmd = 'set:att:' + cmd
            cmd = cmd[:-1]
            self.alloc_channel(colnum + 1)
            self.execute_mcs_command(cmd)

    def config_mcs_with_csv_file(self, phase_file, att_file):
        self.force_free_channel()
        m_phase = self.read_from_csv(phase_file)
        m_att = self.read_from_csv(att_file)
        self.set_with_matrix('phase', m_phase)
        self.set_with_matrix('att', m_att)


if __name__ == '__main__':
    logging.basicConfig(format='%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                        datefmt="%Y-%m-%d %H:%M:%S", level=logging.INFO, stream=sys.stdout)

    # mcs = McsController_JX_2(host="10.106.164.105", port=28888)
    # mcs.connect()

    fname = '/mnt/c/N-20N3PF224J8X-Data/ju/Downloads/64x16-Phase2.csv'
    fname = '/mnt/c/N-20N3PF224J8X-Data/ju/Downloads/64x16-Att.csv'
    mcs = MCS_Hbte(host='10.97.83.203')
    mcs.connect()
    mcs.login()
    # mcs.get_system_info()
    # mcs.force_free_channel()
    m_phase = mcs.read_from_csv(fname)
    print(m_phase[0])
    mcs.set_with_matrix('att', m_phase)
    # mcs.set_with_matrix('phase', m_phase)
