# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import time
import logging
import telnetlib
import sys
import six
import os
import re


class c_rf_device(object):

    def __init__(self, ip, port, inport_count, outport_count, logger):
        self.ip = ip
        self.port = port
        self.inport_count = inport_count
        self.outport_count = outport_count
        self.conn = None
        self.logger = logger or logging.getLogger(__file__)
        self.logger.info('PA [%s] Beginning' % (self.ip))
        self.min = 0
        self.max = 120
        self.connect_fail_count = 0

    def connect(self, retry='Y'):
        times = 30 if retry == 'Y' else 1
        self.logger.info('Try to connect to : %s:%s' % (self.ip, self.port))
        for i in range(times):
            try:
                self.conn = telnetlib.Telnet(self.ip, self.port, 30)
                self.logger.info('Successfully connected to : %s:%s' % (self.ip, self.port))
                break
            except Exception:
                self.logger.warn('Connect to PA failed, I will try after 5 seconds')

                if times > 1:
                    time.sleep(5)
        if not self.conn:
            raise Exception('Could not connect to PA, case will failed!')

    def disconnect(self):
        if self.conn:
            self.conn.close()
            self.conn = None
            self.logger.info('Disconnect from : %s:%s' % (self.ip, self.port))

    def execute_commands(self, cmdlist=[], delay=0.5):
        self.logger.debug('Prepare for command: {}'.format(cmdlist))
        if not self.conn:
            self.logger.debug('Need reconnected')
            self.connect()
            time.sleep(1)
            response = self.conn.read_very_eager().decode()
            self.logger.info('Get Response : ' + response)
            if 'CMDERR' in response.upper():
                raise Exception('Adjust PA error, response: {}'.format(response))

        if self.conn:
            self.logger.debug('Connection is OK.')
            cmdlist = [cmdlist] if not isinstance(cmdlist, list) else cmdlist
            for cmd in cmdlist:
                self.logger.info('Send: {}'.format(cmd))
                self.conn.write(six.b(cmd + '\r\n'))
                self.logger.debug('Send command: ' + cmd)
                time.sleep(delay)
                if self.conn:
                    self.logger.debug('Try to read response...')
                    response = self.conn.read_very_eager().decode()
                    self.logger.debug('Get Response : ' + response)
                    self.logger.info('RECV: {}'.format(response))
        else:
            self.logger.error('No connection is found.')

    def change_signal(self, inport, outport, signal):
        pass

    def reboot(self):
        self.logger.warning('This PA/RFwitch does not support reboot operation')
        return False


class c_jx_pa(c_rf_device):

    def clear_all(self, rfconnection=[]):
        cmds = ['set %d, 120' % (x) for x in range(1, int(self.inport_count) + 1)]
        self.execute_commands(cmds)

    def change_signal(self, inport, outport, signal):
        cmds = ['set %s, %s' % (inport, signal)]
        self.execute_commands(cmds)

    def clear_port(self, inport, outport):
        self.change_signal(inport, outport, '120')


class c_jxb_pa(c_rf_device):

    def __init__(self, ip, port, inport_count, outport_count, logger):
        super().__init__(ip, port, inport_count, outport_count, logger)
        self.scmd = 'SET' if self.ip in ['10.69.82.232'] else 'set'

    def clear_all(self, rfconnection=None):
        cmds = [f'{self.scmd}:{x}:120' for x in range(1, int(self.inport_count) + 1)]
        self.execute_commands(cmds)

    def change_signal(self, inport, outport, signal):
        cmds = [f'{self.scmd}:{inport}:{signal}']
        self.execute_commands(cmds)

    def clear_port(self, inport, outport):
        self.change_signal(inport, outport, '120')


class c_hb_pa(c_rf_device):

    def clear_all(self, rfconnection=[]):
        cmds = ['$TA,C,%0.2dFE*' % (x) for x in range(1, int(self.inport_count) + 1)]
        self.execute_commands(cmds, 0.2)

    def change_signal(self, inport, outport, signal):
        cmds = ['$TA,C,%0.2d%0.2X*' % (int(inport), int(signal) * 2)]
        return self.execute_commands(cmds, 0.2)

    def clear_port(self, inport, outport):
        self.change_signal(inport, outport, '177')


class c_rf_device_new(object):

    def __init__(self, ip, port, inport_count, outport_count, logger=None):
        self.ip = ip
        self.port = 1000
        self.inport_count = inport_count
        self.outport_count = outport_count
        self.conn = None
        self.logger = logger or logging.getLogger(__file__)
        self.min = 0
        self.max = 120
        self.connect_fail_count = 0
        self.prompt = b''
        self.expectes = [re.compile(b'TopYoung>>', re.IGNORECASE),
                         re.compile(b'OK', re.IGNORECASE),
                         re.compile(b'cmderr', re.IGNORECASE)]
        self.expectes = [b'OK', b'CMDERR']

    def connect(self):
        self.logger.info('Try to connect to : %s:%s' % (self.ip, self.port))
        self.conn = telnetlib.Telnet(self.ip, self.port, 3)
        self.logger.info('Connect OK.')

    def disconnect(self):
        if self.conn:
            self.conn.close()
            self.conn = None
            self.logger.info('Disconnect from : %s:%s' % (self.ip, self.port))

    def execute_command(self, command):
        self.logger.debug('Execute command: {}'.format(command))
        self.conn.write(six.b('{}\r\n'.format(command).upper()))
        index, b, output = self.conn.expect(self.expectes)
        if index == 1:  # CMDERR
            raise Exception('Run command error: {}.'.format(output.decode()))
        output = '\n'.join([x for x in output.decode().splitlines() if x.strip()])
        self.logger.debug('Get Response:    {}'.format(output))

    def execute_commands(self, cmdlist=[], delay=0):
        if not self.conn:
            self.connect()

        cmdlist = [cmdlist] if not isinstance(cmdlist, list) else cmdlist
        for cmd in cmdlist:
            # self.logger.info('*********   ' + cmd)
            self.execute_command(cmd)

    def change_signal(self, inport, outport, signal):
        pass

    def reboot(self):
        self.logger.warning('This PA/RFwitch does not support reboot operation')
        return False


class c_jx_matrix(c_rf_device_new):

    def __init__(self, ip, port, inport_count, outport_count, logger):
        super(c_jx_matrix, self).__init__(ip, port, inport_count, outport_count, logger)
        self.prompt = b'TopYoung>>' if inport_count == 32 else b'OK'

    def get_port_number(self, inport, outport):
        return (int(inport) - 1) * int(self.outport_count) + int(outport)

    def clear_all(self, rfconnections=[]):
        if rfconnections:
            cmdlist1 = []
            self.max = 93
            scmd = 'set' if int(self.inport_count) == 32 else 'SET'
            if self.ip in ['10.69.71.230', '10.69.82.232', '10.56.17.14']:
                scmd = 'SET'
            for rfconnection in rfconnections:
                self.logger.info('Clear all for {}'.format(rfconnection))
                inport, outport, signal = rfconnection.split(',')
                for i in range(1, int(self.outport_count) + 1):
                    cmdlist1.append('%s:%d:93' % (
                        scmd, self.get_port_number(inport, i)))
                for i in range(1, int(self.inport_count) + 1):
                    cmdlist1.append(
                        '%s:%d:93' % (scmd, self.get_port_number(i, outport)))
            self.execute_commands(cmdlist1, 0.1)
        else:
            for inport in range(1, int(self.inport_count) + 1):
                for outport in range(1, int(self.outport_count) + 1):
                    self.clear_port(inport, outport)

    def change_signal(self, inport, outport, signal):
        cmdlist1 = []
        cmdlist2 = []
        scmd = 'set' if int(self.inport_count) == 32 else 'SET'
        if self.ip in ['10.69.71.230', '10.56.17.14', '10.69.82.232']:
            scmd = 'SET'
        cmdlist2.append(
            '%s:%d:%d' % (scmd, self.get_port_number(inport, outport), int(signal)))
        cmdlist1 = list(set(cmdlist1))
        cmdlist1.sort()
        for cmd in cmdlist1 + cmdlist2:
            self.logger.debug(cmd)
        self.execute_commands(cmdlist1 + cmdlist2, 0.1)

    def clear_port(self, inport, outport):
        self.change_signal(inport, outport, '93')

    def reboot(self):
        cmd = 'wget http://{}/cgi-bin/reboot.cgi'.format(self.ip)
        self.logger.info('Restart RFSwitch, cmd: {}'.format(cmd))
        os.system(cmd)
        self.logger.info('Wait 30s for rfswitch up.')
        time.sleep(30)
        self.logger.info('Reboot rfswitch done.')
        return True


class c_hb_matrix(c_rf_device):

    def clear_all(self, rfconnections=[]):
        if rfconnections:
            for rfconnection in rfconnections:
                inport, outport, single = rfconnection.split(',')
                cmdlist = []
                self.logger.info(
                    'Adjust HB Matrix signal for %s 60' % (inport))
                empty_row = ('FF' *
                             (int(inport) - 1) + '78' + 'FF' * (
                                 int(self.inport_count) - int(inport)))
                cmdlist.append('$TA,G,%s*' % (empty_row * int(self.outport_count)))

                self.logger.info(
                    'Adjust HB Matrix signal for %s 60' % (outport))
                empty_col = 'FF' * int(self.inport_count)
                empty_col2 = empty_col * (
                    int(self.outport_count) - int(outport))
                cmdlist.append(
                    '$TA,G,%s%s%s*' % (empty_col * (int(outport) - 1),
                                       '78' * int(self.inport_count), empty_col2))
                return self.execute_commands(cmdlist)
        else:
            for inport in range(1, int(self.inport_count) + 1):
                for outport in range(1, int(self.outport_count) + 1):
                    self.clear_port(inport, outport)

    def change_signal(self, inport, outport, signal):

        cmdlist = []
        self.max = 60

        port = str((int(outport) - 1) * int(self.inport_count) + int(inport))
        self.logger.info(
            'Adjust HB Matrix signal for signal port %s ' % (port))
        cmdlist.append(
            '$TA,A,%0.2d%0.2d%0.2X*' % (int(inport), int(outport), 2 * int(signal)))
        return self.execute_commands(cmdlist)

    def clear_port(self, inport, outport):
        self.change_signal(inport, outport, '60')


def change_pa_signal(host, port, device_type, model, total_in_port,
                     total_out_port, points, signal, clear_all=False, logger=None):
    if device_type == 'pa':
        if model == 'jx':
            PA = c_jx_pa
        if model == 'jxb':
            PA = c_jxb_pa
        if model == 'hb':
            PA = c_hb_pa
    else:
        if model == 'jx':
            PA = c_jx_matrix
        if model == 'hb':
            PA = c_hb_matrix
    device = PA(host, port, total_in_port, total_out_port, logger)
    device.connect()
    logger.info('')
    # ports: like: A5B8,A6B2
    try:
        for point in points.split(','):
            point = point.strip()
            if point:
                logger.info(f'Work for: {point}  ==> {signal}')
                inport, outport = re.findall('[A-Za-z]([0-9]*)', point)
                if clear_all and device_type != 'pa':
                    device.clear_all([f'{inport},{outport},93'])
                device.change_signal(int(inport), int(outport), int(signal))
                time.sleep(0.1)
    finally:
        device.disconnect()


def change_pa_signal2(paid, points, signal, clear_all=False, logger=None):
    try:
        from .common import device_config
    except Exception:
        from common import device_config
    config = device_config('pa', paid)
    change_pa_signal(config.host, config.port,
                     config.devicetype, config.model,
                     config.inport, config.outport,
                     points, signal, clear_all, logger)
