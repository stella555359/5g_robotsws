import logging
import telnetlib
import time
import sys
import datetime
import subprocess
import os
import re


class airphone(object):
    hostname = 'localhost'
    username = 'ute'
    password = 'ute'
    cfg_file = 'basic_setup.cfg'
    edaemon_port = '50000'

    def __init__(self):
        self.tn = telnetlib.Telnet()

    def login_host(self):
        try:
            logging.info(self.hostname)
            self.tn.open(self.hostname, 20000)
        except Exception:
            logging.warning('Telnet to server failed')
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

    def start_edaemon_egate(self):
        subprocess.getoutput("sudo pkill egate; sudo pkill edaemon")
        os.system("cd /opt/iphy/latest/;sudo ./edaemon --port " + self.edaemon_port + ";./egate --port 20000")
        output = subprocess.getoutput("ps -ef | grep -v grep|grep -E \"egate|edaemon\"")
        logging.info(output)
        if 'egate' in output and 'edaemon' in output:
            logging.info('egate and edaemon is running.')
        else:
            logging.error('egate or edaemon is NOT running.')
            raise Exception('egate or edaemon is NOT running.')

    def init_simulator(self, reset=False):
        self.get_edaemon_port_from_cfg_file()
        self.add_missing_ips_in_cfg()
        self.start_edaemon_egate()
        time.sleep(5)
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
        output = self.execute_command('cfg_sim file=' + self.cfg_file)
        time.sleep(5)
        output = self.execute_command('state')
        if 'The state is CONFIGURED' in output:
            output = self.execute_command('start')
            self.wait_startup_complete()

    def get_edaemon_port_from_cfg_file(self):
        cfg_file_path = "/opt/iphy/latest/" + self.cfg_file
        cfg = open(cfg_file_path, "r").read()
        match = re.search('DAEMON_PORT="(\\d+)"', cfg)
        if match:
            self.edaemon_port = match.group(1)
        else:
            raise Exception("edaemon port not definded in cfg file")
        pass

    def add_missing_ips_in_cfg(self):
        cfg_file_path = "/opt/iphy/latest/" + self.cfg_file
        if not os.path.exists(cfg_file_path):
            logging.error(cfg_file_path + ' not found.')
            raise Exception('cfg file not found')
        cfg = open(cfg_file_path, "r").read()
        ips = re.findall("10.\\d+\\.\\d+\\.\\d+", cfg)
        ips = list(dict.fromkeys(ips))
        local_ips = subprocess.getoutput("ip a ")
        for ip in ips:
            if ip not in local_ips:
                interface = 'eth3'
                if '10.0.2' in ip:
                    continue
                elif '10.0.1' in ip:
                    interface = 'eth3'
                else:
                    logging.error('Unkown network in cfg file. ' + str(ip))
                    # raise Exception('Unkown network in cfg file')
                output = subprocess.getoutput("sudo ip a add " + ip + "/24 dev " + interface)
                logging.info(output)
            pass
        pass

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


logging.basicConfig(level=logging.INFO, filename=__file__ + '.log', filemode='a',
                    format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s, %(message)s')

if __name__ == '__main__':
    client = airphone()
    client.init_simulator()
    cmd = "state"
    out = client.execute_command(cmd)
    print(out)
