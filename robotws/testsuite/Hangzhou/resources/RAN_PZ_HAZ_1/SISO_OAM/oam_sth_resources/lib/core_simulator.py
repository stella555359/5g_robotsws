import logging
import telnetlib
import time
import sys
import datetime
import paramiko
import re


class core_simulator(object):
    hostname = '',
    username = ''
    password = ''
    home_directory = ''
    cfg_file = ''

    def __init__(self):
        pass

    def connect_to(self, host_ip='10.97.92.238', username='ute', password='UTE.debian12',
                   home_directory='/opt/iphy/WTS/', cfg_file='WTS_SA.cfg'):
        self.tn = telnetlib.Telnet()
        self.ssh = paramiko.SSHClient()
        self.host_ip = host_ip
        self.username = username
        self.password = password
        self.home_directory = home_directory
        self.cfg_file = cfg_file
        know_host = paramiko.AutoAddPolicy()
        self.ssh.set_missing_host_key_policy(know_host)
        self.ssh.connect(
            hostname=self.host_ip,
            port=22,
            username=self.username,
            password=self.password
        )

        try:
            logging.info('Connecting to Core Simulator ' + self.host_ip)
            self.restart_egate_edaemon()
            self.tn.open(self.host_ip, 20000)
            self.init_simulator()
        except Exception:
            logging.warning('%s Telnet to server failed' % self.host_ip)
            self.restart_egate_edaemon()
            self.tn.open(self.host_ip, 20000)
            self.init_simulator()
            raise Exception('Connect to simulator failed')
        self.tn.read_until(b'EGATE>', timeout=10)
        return True

    def execute_command(self, command):
        logging.info('Execute command "' + command + '"')
        self.tn.write(command.encode('ascii') + b'\r')
        time.sleep(2)
        command_result = self.tn.read_very_eager().decode('ascii')
        logging.debug('Command "' + command + '" output: ' + command_result)
        return command_result

    def logout_host(self):
        self.tn.write(b"exit\n")

    def restart_egate_edaemon(self):
        logging.info("Restaring egate/edaemon...")
        stdin, stdout, stderr = self.ssh.exec_command(
            "sudo pkill egate; sudo pkill edaemon;\
             cd " + self.home_directory + ";sudo ./edaemon --port 22222; ./egate --port 20000")
        logging.info(stdout.read().decode())
        stdin, stdout, stderr = self.ssh.exec_command("ps -ef | grep -v grep|grep -E \"egate|edaemon\"")
        output = stdout.read().decode()
        logging.info(output)
        if 'egate' in output and 'edaemon' in output:
            logging.info('egate and edaemon is running.')
        else:
            logging.error('egate or edaemon is NOT running.')
            raise Exception('egate or edaemon is NOT running.')
        logging.info("Restaring egate/edaemon complete.")

    def init_simulator(self, reset=False):
        logging.info('Initialising simulator')
        time.sleep(5)
        if reset is True:
            self.execute_command('reset')
            time.sleep(5)
        output = self.execute_command('state')
        if 'The state is ACTIVE' in output:
            return True
        elif 'The state is INIT' in output:
            # self.start_simulator()
            pass
        elif 'The state is CONFIGURED' in output:
            self.execute_command('reset')
            # self.start_simulator()
        elif 'The state is ACTIVATING' in output:
            self.wait_startup_complete()
            return True
        logging.warning('State is unknown')
        self.start_simulator()

    def reinit_simulator(self):
        logging.info('re-initialising simulator')
        self.tn.close()
        self.restart_egate_edaemon()
        self.connect_to(host_ip=self.host_ip, username=self.username, password=self.password,
                        home_directory=self.home_directory, cfg_file=self.cfg_file)
        self.init_simulator()
        logging.info('re-initialising simulator complete')

    def start_simulator(self):
        logging.info('start simulator')
        output = self.execute_command('cfg file=' + self.cfg_file)
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

    def get_configured_ues(self):
        cmd = 'cat ' + self.home_directory + '/' + self.cfg_file + '|grep -i set_ue'
        stdin, stdout, stderr = self.ssh.exec_command(cmd)
        output = stdout.read().decode()
        ids = re.findall("id=(\\d+)", output)
        tmp_imsis = re.findall("suci=\\d+:(\\d+):(\\d+):\\d+:\\d+:\\d+:(\\d+)", output)
        imsis = []
        for tmp_imsi in tmp_imsis:
            imsi = ''.join(tmp_imsi)
            imsis.append(imsi)
        return ids, imsis

    def teardown(self):
        self.tn.close()
        self.ssh.close()


logging.basicConfig(level=logging.INFO, filename=__file__ + '.log', filemode='a',
                    format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s, %(message)s')

if __name__ == '__main__':
    client = core_simulator()
    client.connect_to(host_ip='10.97.92.238', username='ute', password='UTE.debian12')
    # cmd = "state"
    # out = client.execute_command(cmd)
    # print(out)
    ids, imsis = client.get_configured_ues()
    print(ids)
    print(imsis)
