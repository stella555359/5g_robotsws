#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import sys
import os
import six
import logging
import socket
import time
import telnetlib
import binascii


'''
    我们目前支持5款PB，分别是：
    1、APC，主要用在TM500上；APC也分为2款，访问端口都是23；
        老款是RackPDU, 版本号一般是3.7.3或者3.7.4，通过输入一些数字来操作；
        新款是版本646，可以通过诸如olStatus命令的方式，直接查询和控制端口；
    2、Facom(HBTE)的PB，用在基站上；因为有些更新了firmware，
        更新过的PB访问端口是5000，采用诸如：$TA,D,0{}{}* 命令的方式来控制；
        没更新过的访问端口是4001；通过发送诸如01050000FF008C3A的一段16进制值来控制
    3、JX的PB，访问端口是3000，通过诸如SET:1:ON的方法来控制；
'''


class c_pet_pb_c(object):

    def __init__(self, host, port, logger=None):
        self.host = host
        self.port = port
        self.logger = logger or logging.getLogger('PET_TA')
        self.conn = None

    def __del__(self):
        if self.conn:
            self.disconnect()

    def is_port_on(self, port):
        return self.get_port_status(port).upper() == 'ON'

    def is_port_off(self, port):
        return not self.is_port_on(port)

    def power_on(self, port):
        for sport in str(port).split(','):
            self.logger.info('')
            self.logger.info(f'*********  TASK: POWER ON {self.host}:{sport}  **********  ')
            if not self.is_port_on(sport):
                self.set_port_status(sport, 'ON')
            else:
                pass
            self.logger.info(f'*********  TASK DONE                      **********  ')

    def power_off(self, port):
        for sport in str(port).split(','):
            self.logger.info('')
            self.logger.info(f'*********  TASK: POWER OFF {self.host}:{sport}  **********  ')
            if self.is_port_on(sport):
                self.set_port_status(sport, 'OFF')
            self.logger.info(f'*********  TASK DONE                       **********  ')

    def get_port_status(self, port):
        return 'ON'

    def set_port_status(self, port, status):
        return 'ON'

    def reboot(self, port=1, interval=5):
        self.power_off(port)
        time.sleep(interval)
        self.power_on(port)

    def disconnect(self):
        if self.conn and hasattr(self.conn, 'close'):
            self.conn.close()
            self.conn = None


class c_pet_pb_facom_4001(c_pet_pb_c):

    CHECK_CODE = {1: "010200000001B9CA", 2: "010200010001E80A",
                  3: "010200020001180A", 4: "01020003000149CA",
                  5: "010200040001F80B", 6: "010200050001A9CB",
                  7: "01020006000159CB", 8: "010200070001080B"}

    POWER_ON_CODE = {1: "01050000FF008C3A", 2: "01050001FF00DDFA",
                     3: "01050002FF002DFA", 4: "01050003FF007C3A",
                     5: "01050004FF00CDFB", 6: "01050005FF009C3B",
                     7: "01050006FF006C3B", 8: "01050007FF003DFB"}

    POWER_OFF_CODE = {1: "010500000000CDCA", 2: "0105000100009C0A",
                      3: "0105000200006C0A", 4: "0105000300003DCA",
                      5: "0105000400008C0B", 6: "010500050000DDCB",
                      7: "0105000600002DCB", 8: "0105000700007C0B"}

    POWER_OFF_STATUS = '01020100A188'
    POWER_ON_STATUS = '010201016048'

    def __init__(self, host='', logger=None, port=4001):
        super(c_pet_pb_facom_4001, self).__init__(host, port, logger)
        self.name = 'FACOM_4001'

    def connect(self, try_times=30):
        if self.conn is None:
            p_Socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            p_Socket.settimeout(3)
            for i in range(try_times):
                try:
                    self.logger.debug(f'Try to connect facom {self.host}...')
                    p_Socket.connect((self.host, 4001))
                    connected = True
                    self.logger.debug(f'Connect facom {self.host} successfully.')
                    break
                except Exception:
                    self.logger.warning(f'Connect to FACOM PB {self.host} failed, tried after 5s')
                    time.sleep(5)
            if not connected:
                raise Exception(f'Could not connect to FACOM PB {self.host} finally.')
            self.conn = p_Socket

    def is_port_on(self, port):
        return self._get_port_status(port).upper() == 'ON'

    def _get_port_status(self, port):
        self.connect()
        cmd = self.CHECK_CODE[int(port)]
        self.logger.debug(f'Send command: {cmd}')
        self.conn.send(binascii.a2b_hex(cmd))
        reply = self.conn.recv(1024)
        reply = binascii.b2a_hex(reply).decode().upper()
        self.logger.debug(f'Response Value: {reply}')
        reply = 'ON' if reply == self.POWER_ON_STATUS else 'OFF'
        self.logger.info(f'Port {port} Current Status is: {reply}')
        return reply

    def _set_port_status(self, port, status):
        self.logger.debug(f'Try to set port {port} status to {status} ...')
        self.connect()
        cmd = self.POWER_ON_CODE[int(port)] if status == 'ON' else self.POWER_OFF_CODE[int(port)]
        self.logger.debug(f'Send command: {cmd}')
        self.conn.send(binascii.a2b_hex(cmd))
        reply = self.conn.recv(1024)
        reply = binascii.b2a_hex(reply).decode().upper()
        self.logger.debug(f'Response Value: {reply}')
        self.logger.debug(f'Try to set port {port} status to {status} done')
        time.sleep(1)

    def set_port_status(self, port, status):
        status = status.upper().strip()
        self._set_port_status(port, status)
        for i in range(30):
            curr_status = self._get_port_status(port)
            if curr_status == status:
                # self.logger.info(f'Port {port} status is already {status}')
                return 0
            else:
                self.logger.warning(f'Port {port} status is not expected')
                self._set_port_status(port, status)
        raise Exception(f'Set port {port} to status {status} failed.')


class c_pet_pb_facom_5000(c_pet_pb_c):

    def __init__(self, host='', port=5000, logger=None):
        super(c_pet_pb_facom_5000, self).__init__(host, port, logger)
        self.name = 'PB5000'

    def connect(self):
        if self.conn is None:
            self.logger.debug(f'Connect to HBTE PB: {self.host}:{self.port}')
            self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.conn.settimeout(3)
            self.conn.connect((self.host, self.port))
            self.logger.debug('Connect done.')

    def execute_command(self, cmd):
        self.connect()
        self.conn.send(six.b(cmd.strip() + '\r\n'))
        self.logger.debug('Send command: ' + cmd)
        time.sleep(1)
        output = self.conn.recv(1024).decode()
        self.logger.debug('Get Response : ' + output)
        return output

    def query_device(self):
        output = self.execute_command('$TA,Z*')
        return output

    def get_port_status(self, port):
        output = self.execute_command('$TA,D*')
        output = [x.strip() for x in output.splitlines() if x.strip()]
        portinfo = output[0].split(',')[-1]
        s = (int(port) - 1) * 4
        status = portinfo[s + 2:s + 4]
        status = 'ON' if status == '01' else 'OFF'
        self.logger.info(f'Port {port} Current Status: {status}')
        return status

    def is_port_on(self, port):
        return self.get_port_status(port) == 'ON'

    def set_port_status(self, port, status):
        for i in range(30):
            curr_status = self.get_port_status(port)
            if curr_status == status:
                return
            else:
                rstatus = '01' if status.lower() == 'on' else '00'
                output = self.execute_command('$TA,D,0{}{}*'.format(port, rstatus))
                output = [x.strip() for x in output.splitlines() if x.strip()]


class c_pet_apc(c_pet_pb_c):

    def __init__(self, host='', port=23, username='apc', password='apc', logger=None):
        self.host = host
        self.port = port
        self.username = username
        self.password = password
        self.conn = None
        self.logger = logger or logging.getLogger('APC')
        self.apc_type = ''

    def _show_log(self, output):
        for line in output.splitlines():
            self.logger.debug('<---- ' + line)

    def _setup_connection(self):
        for i in range(30):
            try:
                tn = telnetlib.Telnet(self.host, self.port)
                return tn
            except Exception as E:
                self.logger.error('Telnet Connect Error, try later...')
                time.sleep(5)
        raise Exception('Telnet Connect failed for 30 times')

    def connect(self):
        if self.conn is None:
            name_prompt = b'User Name :'
            pass_prompt = b'Password  :'
            output = b''
            # try:
            self.logger.debug(f'Connect {self.host} {self.port} {self.username}/{self.password} ')
            tn = self._setup_connection()
            if tn:
                output += tn.read_until(name_prompt, 5)
                tn.write(six.b(f'{self.username}\r\n'))
                output += tn.read_until(pass_prompt, 5)
                tn.write(six.b(f'{self.password}\r\n'))
                n, match, previous_text = tn.expect([br'apc>', br'> '], 5)
                output += previous_text
                output = output.decode()
                self._show_log(output)
                if 'RackPDU' in output:
                    self.apc_type = 'rackpdu'
                    self.prompt = '> '
                elif 'Type ? for command listing' in output:
                    self.apc_type = 'apc_646'
                self.conn = tn
                self.logger.debug(f'Connect successfully. APC type: {self.apc_type}')
            # except Exception as E:
            #     self.logger.error('!!!! APC ERROR: {}'.format(E))

    def send_commands(self, cmdlist=[], lastprompt=b'', conn=None, timeout=5):
        ret = b''
        for cmd in cmdlist:
            if cmd.strip():
                self.logger.debug('----> [{}]'.format(cmd))
                conn.write(six.b(cmd + '\r\n'))
                output = conn.read_until(lastprompt, timeout)
                ret += output
                self._show_log(output.decode())
        return ret

    def get_port_status(self, port):
        curr_status = 'UNKNOWN'
        self.connect()
        if self.apc_type == 'rackpdu':
            output = self.send_commands(['1', '2', '1'], conn=self.conn, lastprompt=b'> ').decode()
            line = [x for x in output.splitlines() if f'{port}- ' in x]
            if line:
                # self.logger.error(line)
                curr_status = 'ON' if 'ON' in line[-1] else 'OFF'
            else:
                raise Exception(f'Could not find Outlet {port} in output.')
        elif self.apc_type == 'apc_646':
            output = self.send_commands([f'olStatus {port}'], conn=self.conn, lastprompt=b'apc>').decode()
            line = [x for x in output.splitlines() if f'{port}: ' in x]
            if line:
                curr_status = 'ON' if line[0].split()[-1].upper() == 'ON' else 'OFF'
            else:
                raise Exception(f'Could not find Outlet {port} in output.')
        self.logger.info(f'Port {port} Current Status: {curr_status}')
        self.disconnect()
        return curr_status

    def disconnect(self):
        if self.conn:
            # if self.apc_type == 'apc_646':
            #     self.send_commands(['exit'], conn=self.conn, timeout=1)
            self.conn.close()
            self.conn = None
            self.logger.debug('Disconnect successfully.')
            time.sleep(1)

    def wait_until_port_is_reachable(self, host='', port='', timeout=300, interval=5):
        start_time = time.time()
        while time.time() < start_time + timeout:
            try:
                tn = telnetlib.Telnet(host, port)
                tn.close()
                return 0
            except Exception as E:
                time.sleep(interval)
        raise Exception(f'Could not reach {host}:{port} in {timeout}s')

    def set_port_status(self, port, status):
        self.connect()
        output = b''
        p_refresh = b'<ENTER>- Refresh, <CTRL-L>- Event Log'
        p_continue = b'Press <ENTER> to continue...'
        p_yes = b"Enter 'YES' to continue or <ENTER> to cancel"
        if status == 'ON':
            if self.apc_type == 'rackpdu':
                output += self.send_commands(['1', '2', '1', str(port), '1'], conn=self.conn, lastprompt=p_refresh)
                output += self.send_commands(['1'], conn=self.conn, lastprompt=p_yes)
                output += self.send_commands(['YES'], conn=self.conn, lastprompt=p_continue)
                output += self.send_commands([''], conn=self.conn, lastprompt=p_refresh)
            else:
                output += self.send_commands(['olOn %s' % (port)], b'Success', self.conn)
        else:
            if self.apc_type == 'rackpdu':
                output += self.send_commands(['1', '2', '1', str(port), '1'], conn=self.conn, lastprompt=p_refresh)
                output += self.send_commands(['2'], conn=self.conn, lastprompt=p_yes)
                output += self.send_commands(['YES'], conn=self.conn, lastprompt=p_continue)
                output += self.send_commands([''], conn=self.conn, lastprompt=p_refresh)
            else:
                output += self.send_commands(['olOff %s' % (port)], b'Success', self.conn)
        self.disconnect()
        self.get_port_status(port)
        return output.decode()


class c_pet_jx(c_pet_pb_c):

    def __init__(self, host='', port=3000, logger=None):
        super(c_pet_jx, self).__init__(host, port, logger)
        self.conn = None

    def connect(self):
        if self.conn is None:
            for i in range(10):
                try:
                    self.logger.info('Try to connect JX PB for %d times: ' % (i + 1))
                    self.conn = telnetlib.Telnet(self.host, self.port)
                    break
                except Exception as E:
                    self.logger.info('Connect failed, try again later')
                    time.sleep(5)
            if self.conn:
                self.logger.info('Connect successfully')

    def set_port_status(self, port, status):
        self.connect()
        self.logger.info('Power off {}-{}'.format(self.host, port))
        cmd = f'SET:{port}:{status}'
        self.logger.info(f'----> {cmd}')
        self.conn.write(six.b(cmd + '\r\n'))
        n, match, previous_text = self.conn.expect([br':OK'], 5)
        output = previous_text.decode()
        self.logger.info('<----    {}'.format(output))

    def get_port_status(self, port):
        self.connect()
        self.logger.info('Read {}-{}'.format(self.host, port))
        cmd = 'READ:{}'.format(port)
        self.logger.info(f'----> {cmd}')
        self.conn.write(six.b(cmd + '\r\n'))
        n, match, previous_text = self.conn.expect([br':ON', br':OFF'], 5)
        output = previous_text.decode()
        self.logger.info('<----    {}'.format(output))
        return output.upper().split(':')[-1].splitlines()[0]


class c_pet_nokia(c_pet_pb_c):

    def __init__(self, host='', logger=None):
        super(c_pet_nokia, self).__init__(host, logger)
        from taf.hw.pdu.devices.fpfh import FPFHhttp
        self.conn = FPFHhttp(host=host, login='admin', password='admin', timeout=10)

    def set_port_status(self, port, status):
        if status.lower() == 'on':
            self.logger.info('Power On {}-{}'.format(self.host, port))
            self.conn.power_on(int(port))
        if status.lower() == 'off':
            self.logger.info('Power OFFF {}-{}'.format(self.host, port))
            self.conn.power_off(int(port))

    def get_port_status(self, port):
        status = self.conn.get_port_status(port)
        self.logger.info(f'Port {port} Current Status: {status.upper()}')
        return self.conn.get_port_status(port)


def pb_factory(host='', factory='facom', logger=None):
    def port_reachable(port):
        p_Socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        reachable = False
        try:
            p_Socket.settimeout(1)
            p_Socket.connect((host, port))
            reachable = True
        except Exception as E:
            pass
        finally:
            p_Socket.close()
        return reachable

    alogger = logger or logging.getLogger('PB_TA')
    if factory == 'apc':
        alogger.debug(f'{host} is a APC.')
        return c_pet_apc(host=host, logger=logger)
    elif factory.lower() == 'nokia':
        return c_pet_nokia(host=host, logger=logger)
    elif port_reachable(4001):
        alogger.debug(f'{host} is a FACOM HBTE 4001.')
        return c_pet_pb_facom_4001(host=host, logger=logger)
    elif port_reachable(5000):
        alogger.debug(f'{host} is a FACOM HBTE 5000.')
        return c_pet_pb_facom_5000(host=host, logger=logger)
    elif port_reachable(3000):
        alogger.debug(f'{host} is a JX PB.')
        return c_pet_jx(host=host, logger=logger)
    elif port_reachable(23):
        alogger.debug(f'{host} is a APC.')
        return c_pet_apc(host=host, logger=logger)
    else:
        raise Exception(f'Unknonw PB type for {host}')


def unit_test(host='', factory='', port=1, logger=None):
    pb = pb_factory(host=host, factory=factory, logger=logger)
    # pb.get_port_status(port)
    # pb.power_on(port)
    pb.power_off(port)
    pb.get_port_status(port)
    # pb.power_on(port)
    # pb.power_on(port)


if __name__ == '__main__':

    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-i",  dest="ip", default='', help='ip of pb')
    parser.add_option("-f",  dest="factory", default='facom', help='like: facom or apc')
    parser.add_option("-o",  dest="operation", default='ON', help='like: ON/OFF')
    parser.add_option("-p",  dest="ports", help='like: 1,2,3')

    (options, sys.argv[1:]) = parser.parse_args()

    import logging
    logging.basicConfig(format='%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                        datefmt="%Y-%m-%d %H:%M:%S", level=logging.INFO)
    logger = logging.getLogger('UTE')
    # pb = pb_factory(host=options.ip, factory=options.factory, logger=logger)
    # for port in options.ports.split(','):
    #     if options.operation.upper() == 'ON':
    #         pb.power_on(int(port))
    #     else:
    #         pb.power_off(int(port))

    # facom 4001: test passed
    # unit_test(host='10.69.64.99', factory='facom_4001', port=1)

    # facom 5000 not passed
    # unit_test(host='10.69.64.119', factory='facom_5000', port=6)

    #  JX
    # unit_test(host='10.56.201.6', factory='jx', port=6)

    # # APC  646
    # unit_test(host='10.69.66.134', factory='apc', port=1)

    # # APC  373
    # unit_test(host='10.69.65.117', factory='apc', port=1)

    # # APC  374
    # unit_test(host='10.69.81.242', factory='apc', port=1)

    # Nokia PB
    unit_test(host='10.69.80.201', factory='Nokia', port=2, logger=logger)
