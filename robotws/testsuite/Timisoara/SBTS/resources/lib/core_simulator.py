import logging
import telnetlib
import time
import sys
import datetime
import paramiko


class core_simulator(object):
    hostname = '10.97.92.235',
    username = 'ute'
    password = 'ute'

    def __init__(self,
                 host_ip='10.97.92.235',
                 username='ute',
                 password='ute',
                 ):
        self.tn = telnetlib.Telnet()
        self.ssh = paramiko.SSHClient()
        self.host_ip = host_ip
        self.username = username
        self.password = password

    def login_host(self):
        try:
            logging.info(self.host_ip)
            self.tn.open(self.host_ip, 20000)
        except Exception:
            logging.warning('%s Telnet to server failed' % self.host_ip)
            self.restart_egate_edaemon()
            self.init_simulator()
            # self.tn.open(self.host_ip, 20000)
            # raise Exception('Connect to simulator failed')
        self.tn.read_until(b'EGATE>', timeout=10)
        return True

    def execute_command(self, command):
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
             cd /home/ute/WTS;sudo ./edaemon --port 22222; ./egate --port 20000")
        logging.info(stdout.read().decode())
        stdin, stdout, stderr = self.ssh.exec_command("ps -ef | grep -v grep|grep -E \"egate|edaemon\"")
        output = stdout.read().decode()
        logging.info(output)
        if 'egate' in output and 'edaemon' in output:
            logging.info('egate and edaemon is running.')
        else:
            logging.error('egate or edaemon is NOT running.')
            raise Exception('egate or edaemon is NOT running.')

    def init_simulator(self, reset=False):
        self.login_host()
        output = self.execute_command('state')
        if reset is True:
            self.execute_command('reset')
            time.sleep(5)
        if 'The state is ACTIVE' in output:
            return True
        elif 'The state is INIT' in output:
            self.start_simulator()
        elif 'The state is CONFIGURED' in output:
            self.execute_command('reset')
            self.start_simulator()
        elif 'The state is ACTIVATING' in output:
            wait_startup_complete()

    def start_simulator(self):
        logging.info('start simulator')
        output = self.execute_command('cfg file=SA_22262_classical.cfg')
        time.sleep(5)
        output = self.execute_command('state')
        if 'The state is CONFIGURED' in output:
            output = self.execute_command('start')
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
            output = self.execute_command('state')
            if 'The state is ACTIVATING' in output:
                time.sleep(5)
                continue
            elif 'The state is ACTIVE' in output:
                return True
            else:
                return False


logging.basicConfig(level=logging.INFO, filename=__file__+'.log', filemode='a',
                    format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s, %(message)s')

if __name__ == '__main__':
    client = core_simulator(host_ip='10.97.92.235', username='ute', password='UTE.debian12')
    # client.init_simulator()
    client.login_host()
    cmd = "state"
    out = client.execute_command(cmd)
    print(out)
