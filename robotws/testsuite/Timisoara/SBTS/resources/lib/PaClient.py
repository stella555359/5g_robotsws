import logging
import time
import sys
import socket
import re


class PaClient(object):
    """docstring for PaClient"""

    def __init__(self, host, port=1000):
        super(PaClient, self).__init__()
        self.host = host
        self.port = port
        self.connected = False

    def connect_to_pa(self, host, port, timeout=10):
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            s.settimeout(timeout)
            s.connect((host, port))
            self.connected = True
        except Exception as e:
            logging.error('Connect to host: ' + host + ':' + str(port) + ' failed.')
            raise e
        else:
            pass
        return s

    def execute_pa_command(self, cmd):
        if not self.connected:
            self.paSocket = self.connect_to_pa(host=self.host, port=self.port, timeout=10)
            self.read_pa_info()
        cmd = cmd + '\r\n'
        cmdByte = cmd.encode('utf_8')
        self.paSocket.sendall(cmdByte)
        data = self.paSocket.recv(1024).decode('utf_8')
        # print(data)
        logging.info('command: "' + cmd + '" output: ' + data)
        return data
        pass

    def read_pa_info(self):
        data = self.execute_pa_command('*IDN?')
        logging.info('PA details: ' + data)
        for port in range(1, 17):
            data = self.execute_pa_command('READ:' + str(port))
        pass

    def read_port_value(self, port):
        data = self.execute_pa_command('READ:' + str(port))
        match = re.search('REREAD:' + str(port) + ':(\\d+)', data)
        if match:
            return match.group(1)
        else:
            raise Exception('output error!!!')
        pass

    def set_port_value(self, port, value):
        output = self.execute_pa_command('SET:' + str(port) + ':' + str(value))
        if "RESET:" + str(port) + ":OK" not in output:
            raise Exception('Set port value failed')
        portValue = self.read_port_value(port)
        logging.info('port ' + str(port) + ' was set to ' + str(portValue))
        pass

    def auto_set_port_value(self, port, startValue, endValue, step, interval):
        logging.info(
            'auto set port value: startValue=' + str(startValue) + ', endValue=' + str(endValue) + ', step=' + str(
                step) + ', interval=' + str(interval))
        self.set_port_value(port, startValue)
        for value in range(int(startValue), int(endValue), int(step)):
            time.sleep(float(interval))
            self.set_port_value(port, value)
        if value < int(endValue):
            self.set_port_value(port, endValue)
        logging.info('Auto set port ' + str(port) + ' value ' + str(startValue) + 'dB-' + str(
            endValue) + 'dB successfully complete.')
        pass

    def disconnect_from_pa(self):
        self.paSocket.close()
        pass


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO, filename=__file__ + '.log', filemode='a',
                        format='%(asctime)s - %(pathname)s[line:%(lineno)d] - %(levelname)s: %(funcName)s, %(message)s',
                        force=True)
    PaClient(host='10.97.92.221', port=1000).auto_set_port_value(port=2, startValue=3, endValue=54, step=4,
                                                                 interval=0.5)
