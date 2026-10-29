

import os
import time
import sys
import logging
import paramiko
logging.getLogger("paramiko").setLevel(logging.WARNING)


class c_rrm_ssh(object):

    def __init__(self, **kwargs):
        self.host = kwargs.get('host', '127.0.0.1')
        self.username = kwargs.get('username', r'noklab\csv5-tester')
        self.password = kwargs.get('password', 'Nokia123!')
        self.port = kwargs.get('port', 22)
        self.os = kwargs.get('os', 'windows')
        self.is_linux = self.os.lower() == 'linux'
        self.conn = None
        self.logger = kwargs.get('logger', logging.getLogger('RRM'))
        self.prompt = '#'
        self.timeout = 10

    def connect(self):
        if self.conn is None:
            self.conn = paramiko.SSHClient()
            self.conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.conn.connect(self.host, self.port, self.username, self.password)
            self.shell = self.conn.invoke_shell()
        return self

    def disconnect(self):
        if self.conn:
            self.shell.close()
            self.conn.close()
            self.conn = None

    def execute_command(self, command):
        self.logger.info('CPC command: ' + str(command))
        p, stdout, stderr = self.conn.exec_command(command)

        while not stdout.channel.exit_status_ready() and not stdout.channel.recv_ready():
            time.sleep(1)
        while not stderr.channel.exit_status_ready() and not stderr.channel.recv_ready():
            time.sleep(1)

        output = stdout.read().decode()
        response = output
        if output.strip():
            self.logger.debug('--> STDOUT:')
            for line in output.splitlines():
                if line.strip():
                    self.logger.debug('-----> {}'.format(line))

        output = stderr.read().decode()
        response += '\n{}'.format(output)
        if output.strip():
            self.logger.debug('--> STDERR:')
            for line in output.splitlines():
                if line.strip():
                    self.logger.debug('-----> {}'.format(line))

        if 'PsExec could not start' in output:
            raise Exception('PSexec execute failed.')
        return response

    def send_char(self, command=''):
        self.shell.send(command + '\n')
        self.logger.debug('----> {}'.format(command))

    def send_ctrl_c(self):
        self.send_char('\x03' + '\n')

    def exec_shell_command(self, command='', timeout=0, prompt=''):
        self.send_char(command)
        response = self.read_until_prompt(timeout=timeout, prompt=prompt)
        return response

    def read_shell_response(self):
        return self.shell.recv(9999).decode('iso-8859-1')

    def read_until_prompt(self, prompt='', timeout=0, loginterval=0.1):
        prompt = prompt or self.prompt
        timeout = timeout or self.timeout
        start_time = time.time()
        response = ''
        while prompt not in response and time.time() - start_time < timeout:
            resp = self.read_shell_response()
            if resp:
                self.logger.debug(resp)
                response += resp
            else:
                time.sleep(loginterval)
        return response

    def port_is_listening(self, port_num):
        pass

    def wait_until_port_is_listening(self, port_num, timeout='5'):
        for i in range(int(timeout)):
            if self.port_is_listening(port_num):
                return 0
            else:
                time.sleep(1)
        raise Exception('Cound not find port [%s] listening in [%s] seconds' % (port_num, timeout))


class c_rrm_win_cpc(c_rrm_ssh):

    def __init__(self, **kwargs):
        super(c_rrm_win_cpc, self).__init__(**kwargs)
        self.os = 'windows'
        self.is_linux = False
        if '\\' in self.username:
            self.username_l = r'\\'.join(self.username.split('\\'))
            self.username_p = '\\'.join(self.username.split('\\'))
            self.username_s = self.username.split('\\')[-1]
        # self.username_l = r'noklab\\csv5-tester'
        # self.username_p = r'noklab\csv5-tester'
        # self.username_s = self.username.split('\\')[-1]

    def setup(self):
        self.connect()
        self.get_rdp_session()

    def teardown(self):
        if self.conn:
            self.disconnect()

    def get_rdp_session(self):
        self.rdp_session_id = 0
        lines = [x for x in self.execute_command(
            'query session|findstr {}'.format(self.username_s)).splitlines() if x.strip()]
        lines = [x for x in lines if x.strip() and 'query' not in x and 'c:\\' not in x.lower()]
        if lines:
            words = [x.strip() for x in lines[0].strip().split()]
            self.rdp_session_id = words[words.index(self.username.split('\\')[-1]) + 1]
            if self.rdp_session_id.isdigit():
                self.logger.info('Found RDP Session id: {}'.format(self.rdp_session_id))
        else:
            self.logger.warn('Not Found RDP Session id, use {}'.format(self.rdp_session_id))

    def kill_process_by_keywords(self, include_keywords=None):
        cmd = 'wmic process get Processid, commandline'
        for keyword in include_keywords:
            cmd += '|findstr {} '.format(keyword)
        lines = self.execute_command(cmd)
        lines = [x.strip() for x in lines.splitlines() if x.strip() if 'wmic' not in x]

        for line in lines:
            processid = line.split()[-1].strip()
            if processid.isdigit():
                self.execute_command('taskkill /F /PID {}'.format(processid))

    def port_is_listening(self, port_num):
        if self.is_linux:
            output = self.execute_command('sudo netstat -na|grep LISTEN|grep {}'.format(port_num))
            return output.split()[3].split(':')[-1].strip() == str(port_num)
        else:
            output = self.execute_command('netstat -na|find /I "%s"' % (str(port_num)))
            return 'LISTENING' in output

    def stop_application(self, appinfo):
        output = self.execute_command('tasklist |find "%s"' % (appinfo)).splitlines()
        process_list = [x.split()[1] for x in output if x.strip() and
                        len(x.split()) > 1 and x.split()[1].isdigit()]
        if process_list:
            cmd = 'taskkill /F ' + ' /PID '.join([''] + process_list)
            self.execute_command(cmd)

    def execute_psexec(self, command):
        command = command.replace('\\', '/')
        cmd = 'psexec.exe -i {} -d -u {} -p {} -s {}'.format(
            self.rdp_session_id, self.username_p, self.password, command)
        self.execute_command(cmd)

    def put_file_to_cpc(self, src_filename, dst_filename):
        self.execute_command(r'del %s' % dst_filename)
        cmd = 'sshpass -p {cpc.password} scp {src_filename} {cpc.username_l}@{cpc.host}:{dst_filename}'.format(
            cpc=self, src_filename=src_filename, dst_filename=dst_filename)
        self.logger.info('Local run: {}'.format(cmd))
        os.system(cmd)

    def get_file_from_cpc(self, src_filename, dst_filename):
        cmd = 'sshpass -p {cpc.password} scp {cpc.username_l}@{cpc.host}:{src_filename} {dst_filename}'.format(
            cpc=self, src_filename=src_filename, dst_filename=dst_filename)
        self.logger.info('Local run: {}'.format(cmd))
        os.system(cmd)

    def deploy_file(self, localfile='', remotefile='', override=False):
        self.put_file_to_cpc(localfile, remotefile)


if __name__ == '__main__':
    import logging
    logging.basicConfig(
        format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S', level=logging.DEBUG)

    cpc = c_rrm_win_cpc(host='10.106.212.201')
    print(cpc.username_s)
    print(cpc.username_l)
    print(cpc.username_p)
    # cpc.setup()
    # cpc.teardown()
