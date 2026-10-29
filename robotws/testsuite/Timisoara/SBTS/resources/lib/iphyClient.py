import logging
import telnetlib
import time
import sys
import datetime
import paramiko


class iphyClient():
    hostname = '',
    username = 'ute'
    password = 'ute'

    def __init__(self, host_ip, username='ute', password='ute'):
        self.tn = telnetlib.Telnet()
        self.ssh = paramiko.SSHClient()
        self.host_ip = host_ip
        self.username = username
        self.password = password

    def login_host(self, host_ip, port=20000):
        try:
            self.tn.open(host_ip, port)
        except Exception:
            logging.warning('%s Telnet to server failed' % host_ip)
            self.restart_egate_edaemon()
            self.tn.open(host_ip, port)
        self.tn.read_until(b'EGATE>', timeout=10)
        return True

    def execute_iphy_command(self, command):
        logging.info('Execute command: ' + command)
        self.tn.write(command.encode('ascii') + b'\r')
        time.sleep(2)
        command_result = self.tn.read_very_eager().decode('ascii')
        logging.debug('Execute command: ' + command_result)
        return command_result

    def logout_host(self):
        self.tn.write(b"exit\n")

    def restart_egate_edaemon(self):
        know_host = paramiko.AutoAddPolicy()
        self.ssh.set_missing_host_key_policy(know_host)
        self.ssh.connect(
            hostname=self.host_ip,
            port=22,
            username=self.username,
            password=self.password
        )
        stdin, stdout, stderr = self.ssh.exec_command(
            "sudo pkill egate; sudo pkill edaemon;\
             cd /opt/iphy/latest; ./egate --port 20000; sudo ./edaemon --port 10000")
        logging.info(stdout.read().decode())
        stdin, stdout, stderr = self.ssh.exec_command("ps -ef | grep -v grep|grep -E \"egate|edaemon\"")
        logging.info(stdout.read().decode())

    def init_iphy(self, reset=False):
        self.login_host(host_ip=self.host_ip, port=20000)
        output = self.execute_iphy_command('state')
        if reset is True:
            self.execute_iphy_command('reset')
            time.sleep(5)
        if 'The state is ACTIVE' in output:
            logging.info('The state is ACTIVE.')
            logging.info('The state is ACTIVE')
            return True
        elif 'The state is INIT' in output:
            logging.info('The state is INIT')
            self.start_iphy()
        elif 'The state is CONFIGURED' in output:
            logging.info('The state is CONFIGURED')
            self.execute_iphy_command('reset')
            self.start_iphy()
        elif 'The state is ACTIVATING' in output:
            wait_startup_complete()

    def start_iphy(self):
        logging.info('start iphy')
        output = self.execute_iphy_command('cfg file=/opt/iphy/latest/tddLuaScripts/lte_wraparound_cfg.lua')
        time.sleep(5)
        output = self.execute_iphy_command('state')
        if 'The state is CONFIGURED' in output:
            output = self.execute_iphy_command('start')
            self.wait_startup_complete()

    def wait_startup_complete(self, timeout=15 * 60):
        logging.info('wait...')
        start_time = datetime.datetime.now()
        while True:
            now = datetime.datetime.now()
            if (now - start_time).seconds > timeout:
                logging.info('timeout')
                return False
            logging.info('Waiting state update...')
            output = self.execute_iphy_command('state')
            if 'The state is ACTIVATING' in output:
                time.sleep(5)
                continue
            elif 'The state is ACTIVE' in output:
                return True
            else:
                return False


if __name__ == '__main__':
    iphyClient = iphyClient(host_ip='10.97.92.53', username='ute', password='ute')
    iphyClient.init_iphy()
