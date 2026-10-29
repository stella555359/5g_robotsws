# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import six
import logging
import paramiko


class c_pet_shenick(object):

    def __init__(self, host, port, partition, username='cli', password='diversifEye', logger=None):
        self.host = host
        self.port = int(port)
        self.username = username
        self.password = password
        self.partition = partition
        self.logger = logger or logging.getLogger('PET_TA')
        self.cli_username = 'tm500'
        self.cli_password = 'tm500'

        self.ssh = None
        self.chan = None
        self.prompt = 'cli@diversifEye:~$'

    def connect(self):
        if not bool(self.ssh):
            self.logger.info('Connect to {} ...'.format(self.host))
            self.ssh = paramiko.SSHClient()
            self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh.connect(self.host, self.port, self.username, self.password)
            self.chan = self.ssh.invoke_shell()
            for line in self.read_until_prompt():
                self.logger.info(line)
            self.logger.info('Connect to Shenick done.')

    def read_until_prompt(self):
        response = ''
        while self.prompt not in response:
            if six.PY2:
                response += self.chan.recv(9999)
            else:
                response += self.chan.recv(9999).decode('iso-8859-1')
        return response.splitlines()

    def disconnect(self):
        self.logger.info('Disconnect from Shenick')
        if self.ssh:
            self.chan.close()
            self.ssh.close()
            self.ssh = None
        self.logger.info('Disconnect from Shenick done.')

    def execute_shell_command(self, command):
        self.connect()
        self.logger.info('Execute Shell command: {}'.format(command))
        self.chan.send(command + '\n')
        response = self.read_until_prompt()
        self.logger.info('Command Response:')
        for line in response:
            self.logger.info(line)
        return '\n'.join(response)

    def execute_cli_command(self, cmd):
        cmd = 'cli -u {} -p {} {}'.format(self.cli_username, self.partition, cmd)
        return self.execute_shell_command(cmd)

    def stop_running_test_group(self):
        output = self.execute_cli_command('help')
        cmd = 'showRunningTestGroup' if 'showRunningTestGroup' in output else 'showActiveState'
        output = self.execute_cli_command(cmd)
        line = [x for x in output.splitlines() if '//' in x]
        if line:
            import re
            running_group = re.findall(r'//([\S]*)', line[0])[0]
            self.logger.debug('Current Running TestGroup is: {}'.format(running_group))
            self.execute_cli_command('stopTestGroup {}'.format(running_group))
        else:
            self.logger.info('There is no RUNNING test group.')

    def start_test_group(self, groupname):
        self.execute_cli_command('startTestGroup {}'.format(groupname))


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.INFO)
    shenick = c_pet_shenick(host='10.69.71.225', port=22200, partition=1)
    shenick.connect()
    shenick.stop_running_test_group()
    shenick.disconnect()
    logging.info('OK')
