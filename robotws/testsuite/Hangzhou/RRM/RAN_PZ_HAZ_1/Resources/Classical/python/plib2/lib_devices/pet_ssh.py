# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import sys
import logging
import paramiko
try:
    from common import global_store, run_command
except Exception:
    from .common import global_store, run_command
logging.getLogger('paramiko').setLevel(logging.WARNING)


class pet_ssh(object):

    def __init__(self, **kwargs):
        self.host = kwargs.get('host', '127.0.0.1')
        self.username = kwargs.get('username', '')
        self.password = kwargs.get('password', '')
        self.port = kwargs.get('port', 22)
        self.os = kwargs.get('os', 'windows').lower()
        self.is_linux = self.os != 'windows'
        self.conn = None
        self.logger = kwargs.get('logger', logging.getLogger(__file__))
        self.prompt = '#'
        self.timeout = 10
        self.shell = None
        self.setup_ed = False
        self.alias = kwargs.get('alias', self.__str__())
        self.trans = None
        self.sftp = None

    def __str__(self):
        return 'cpc_' + self.host

    def __repr__(self):
        return self.__str__()

    def __del__(self):
        self.disconnect()
        global_store.del_mo(self.alias)

    def connect(self):
        if self.conn is None:
            self.conn = paramiko.SSHClient()
            self.conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.conn.connect(self.host, self.port, self.username, self.password)
            self.shell = self.conn.invoke_shell()
            self.trans = paramiko.Transport(sock=(self.host, self.port))
            self.trans.connect(username=self.username, password=self.password)
            self.sftp = paramiko.SFTPClient.from_transport(self.trans)
        return self

    def disconnect(self):
        if self.conn:
            if self.shell:
                self.shell.close()
            if self.trans:
                self.trans.close()
                self.trans = None
            self.conn.close()
            self.conn = None

    def _smart_decode(self, output1, log=True):
        try:
            output = output1.decode("utf8")
        except Exception:
            self.logger.info('Try to use gbk decode...')
            try:
                output = output1.decode("gbk")
                if log:
                    self.logger.info(output)
            except Exception:
                self.logger.info('Try to use iso-8859-1 decode...')
                output = output1.decode("iso-8859-1", "ignore")
        # remove color special character
        import re
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        output = ansi_escape.sub('', output)
        return output

    def exec_command(self, command='', get_pty=False, log=True):
        self.connect()
        self.logger.info('    ssh command: --> ' + str(command))
        p, stdout, stderr = self.conn.exec_command(command, get_pty=get_pty)

        while not stdout.channel.exit_status_ready() and not stdout.channel.recv_ready():
            time.sleep(1)
        while not stderr.channel.exit_status_ready() and not stderr.channel.recv_ready():
            time.sleep(1)
        output = self._smart_decode(stdout.read(), log)
        response = output
        if output.strip():
            self.logger.debug('    <-- STDOUT:')
            if log:
                for line in output.splitlines():
                    if line.strip():
                        self.logger.debug('    <---- {}'.format(line))

        output = self._smart_decode(stderr.read(), log)
        response += '\n{}'.format(output)
        if output.strip():
            self.logger.debug('    <-- STDERR:')
            if log:
                for line in output.splitlines():
                    if line.strip():
                        self.logger.debug('    <-- {}'.format(line))
        if 'PsExec could not start' in output:
            raise Exception('PSexec execute failed.')
        return response

    def send_char(self, command=''):
        self.shell.send(command + '\n')
        self.logger.debug('----> {}'.format(command))

    def send_ctrl_c(self):
        self.send_char('\x03' + '\n')

    def exec_shell_command(self, command='', timeout=1, prompt=''):
        self.send_char(command)
        time.sleep(timeout)
        response = self.read_shell_response()
        self.logger.debug('<---- {}'.format(response))
        return response

    def read_shell_response(self):
        return self._smart_decode(self.shell.recv(9999))

    def read_until_prompt(self, prompt='', timeout=0, loginterval=0.1):
        prompt = prompt or self.prompt
        timeout = timeout or self.timeout
        start_time = time.time()
        response = ''
        while prompt not in response and time.time() - start_time < timeout:
            resp = self.read_shell_response()
            if resp:
                self.logger.debug('<---- {}'.format(resp))
                response += resp
            else:
                time.sleep(loginterval)
        return response

    def list_files(self, remote_dire):
        import stat
        files = self.sftp.listdir_attr(remote_dire)
        files = [x.filename for x in files if stat.S_ISREG(x.st_mode)]
        files.sort()
        return files

    def put_file_to_cpc(self, src_filename, dst_filename):
        self._rebuild_key()
        cmd = 'sshpass -p {} scp -o "StrictHostKeyChecking no" {} {}@{}:{}'.format(
            self.password, src_filename, self.username, self.host, dst_filename)
        self.logger.info('Local run: {}'.format(cmd))
        # os.system(cmd)
        run_command(cmd)

    def _rebuild_key(self):
        try:
            cmd = f'ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "{self.host}"'
            self.logger.info(cmd)
            self.logger.info(os.popen(cmd).read())
        except Exception as E:
            self.logger.info(E)

    def get_file_from_cpc(self, src_filename, dst_filename):
        # self._rebuild_key()
        cmd = 'sshpass -p {} scp -o "StrictHostKeyChecking no" -o "UserKnownHostsFile=/dev/null" {}@{}:{} {}'.format(
            self.password, self.username, self.host, src_filename, dst_filename)
        self.logger.info('Local run: {}'.format(cmd))
        run_command(cmd)
        # os.system(cmd)

    def exec_command_background(self, command=''):
        # Usage: s1.exec_command_background('nohup tcpdump -i br1 sctp -w /tmp/local.pcap >/dev/null 2>&1 &')
        self.connect()
        self.logger.info('Exec Command background: [{}] on [{}:{}]'.format(
            command, self.host, self.port))
        channel = self.conn.get_transport().open_session()
        channel.exec_command(command)

    def port_is_listening(self, port_num):
        if self.is_linux:
            output = self.exec_command('sudo netstat -na|grep LISTEN|grep {}'.format(port_num))
            return output.split()[3].split(':')[-1].strip() == str(port_num)
        else:
            output = self.exec_command('netstat -na|find /I "%s"' % (str(port_num)))
            return 'LISTENING' in output

    def wait_until_port_is_listening(self, port_num, timeout='5'):
        for i in range(int(timeout)):
            if self.port_is_listening(port_num):
                return 0
            else:
                time.sleep(1)
        raise Exception('Cound not find port [%s] listening in [%s] seconds' % (port_num, timeout))

    def setup(self):
        if not self.setup_ed:
            self.connect()
            self.setup_ed = True

    def teardown(self):
        if self.conn:
            self.disconnect()
            self.conn = None


class cpc_windows(pet_ssh):

    def __init__(self, **kwargs):
        super(cpc_windows, self).__init__(**kwargs)
        self.username = kwargs.get('username', r'noklab\csv5-tester')
        self.password = kwargs.get('password', r'Nokia123!')
        self.os = 'windows'
        self.is_linux = False
        # self.username_p = r'noklab\csv5-tester'
        self.username_s = self.username.split('\\')[-1]
        self.username_l = r'noklab\\' + self.username_s
        self.username_p = 'noklab\\' + self.username_s
        self.rdp_session_id = 0

    def get_rdp_session(self):
        lines = [x for x in self.exec_command(
            'query session|findstr {}'.format(self.username_s)).splitlines() if x.strip()]
        lines = [x for x in lines if x.strip() and 'query' not in x and 'c:\\' not in x.lower()]
        if lines:
            words = [x.strip() for x in lines[0].strip().split()]
            self.rdp_session_id = words[words.index(self.username.split('\\')[-1]) + 1]
            if self.rdp_session_id.isdigit():
                self.logger.info('Found RDP Session id: {}'.format(self.rdp_session_id))
        else:
            self.logger.warn('Not Found RDP Session id, use {}'.format(self.rdp_session_id))

    def _env_variable(self, pname):
        if pname.lower() in self.env:
            return self.env[pname.lower()]
        else:
            return ''

    def get_env_variable(self):
        self.env = {}
        self.temp_path = 'c:/temp'
        output = [line for line in self.exec_command('set').splitlines() if '=' in line]
        for line in output:
            try:
                name, value = line.split('=')
                self.env[name.lower()] = value
            except Exception as E:
                pass
        self.temp_path = self._env_variable('TEMP')
        self.logger.info('Temp path: {}'.format(self.temp_path))

    def setup(self):
        super(cpc_windows, self).connect()
        self.get_rdp_session()

    def put_file_to_cpc(self, src_filename, dst_filename):
        self.exec_command(r'del %s' % dst_filename)
        cmd = 'sshpass -p {} scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null {} {}@{}:{}'.format(
            self.password, src_filename, self.username_l, self.host, dst_filename)
        self.logger.info('Local run: {}'.format(cmd))
        os.system(cmd)

    def get_file_from_cpc(self, src_filename, dst_filename):
        cmd = 'sshpass -p {} scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null {}@{}:{} {}'.format(
            self.password, self.username_l, self.host, src_filename, dst_filename)
        self.logger.info('Local run: {}'.format(cmd))
        os.system(cmd)

    def kill_process_by_keywords(self, include_keywords=None):
        cmd = 'wmic process get Processid, commandline'
        for keyword in include_keywords:
            cmd += '|findstr {} '.format(keyword)
        cmd += '|findstr -V "findstr"'
        lines = self.exec_command(cmd)
        lines = [x.strip() for x in lines.splitlines() if x.strip() if 'wmic' not in x]

        for line in lines:
            processid = line.split()[-1].strip()
            if processid.isdigit():
                self.exec_command('taskkill /T /F /PID {}'.format(processid))

    def start_application(self, *args):
        cmd = 'psexec.exe -i {cpc.rdp_session_id} -d -u {cpc.username_p} -p {cpc.password} '.format(
              cpc=self)
        cmd += ' '.join(['{}'.format(x) for x in args])
        return self.exec_command(cmd)


class cpc_linux(pet_ssh):

    def __init__(self, **kwargs):
        super(cpc_linux, self).__init__(**kwargs)
        self.username = kwargs.get('username', 'ute')
        self.password = kwargs.get('password', 'qqwweeRR0-')

    def kill_process_with_keywords(self, keywords=[]):
        keywords = keywords if isinstance(keywords, list) else [keywords]
        cmd = 'ps -ef'
        for keyword in keywords:
            cmd += '|grep ' + keyword
        cmd += '|grep -v grep'
        found = False
        for line in [x for x in self.exec_command(cmd).splitlines() if x.strip()]:
            pid = line.split()[1]
            self.exec_command('sudo kill -9 ' + pid)
            found = True
        return found


def cpc_factory(**kwargs):
    alias = kwargs.get('alias', 'cpc_{}'.format(kwargs.get('host')))
    if global_store.get_mo(alias):
        logging.info('MO {} already exist'.format(alias))
        return global_store.get_mo(alias)
    else:
        logging.info('MO {} does not exist, create it'.format(alias))
        cpc = cpc_windows(**kwargs) if 'window' in kwargs.get('os', 'windows').lower() else cpc_linux(**kwargs)
        global_store.add_mo(cpc, alias)
        return cpc


def init_cpc(**kwargs):
    cpc = cpc_windows(**kwargs) if 'window' in kwargs.get('os', 'windows').lower() else cpc_linux(**kwargs)
    return cpc


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    logging.info('OK')
    logging.info(global_store._mos)
    # cpc = cpc_factory(host='10.106.232.47', username='ute', password='uteUTE!', alias='testpc')
    cpc = cpc_factory(host='10.69.82.132', username='ute', password='qqwweeRR0-', alias='testpc', os='linux')
    cpc.connect()
    print(cpc.list_files('/home/ute/temp'))
    # output = cpc.exec_command('sudo iptables -L --line-numbers|grep REJECT').splitlines()
    # output = [x.split()[0] for x in output if 'anywhere' in x]
    # print(output)
    cpc.disconnect()
    # cpc2 = cpc_factory(host='10.69.82.132', username='ute', password='qqwweeRR0-', alias='testpc')
    # # cpc.connect()
    # # cpc.disconnect()
    # logging.info(global_store._mos)
    # global_store.del_mo('testpc')
    # logging.info(global_store._mos)
