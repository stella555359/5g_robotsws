import time

from robot.api import logger
from robot.libraries.Telnet import Telnet


class SignalGenerator(object):
    def __init__(self) -> None:
        self.telnet = Telnet()

    def connect_to_generator(self, gen_host, gen_port):
        self.telnet.open_connection(host=gen_host, port=gen_port)
        time.sleep(4)
        outpu = self.telnet.read()
        logger.console(outpu)

    def execute_query(self, query):
        self.telnet.read()
        self.telnet.write(query)
        time.sleep(4)
        outpu = self.telnet.read()
        logger.console(outpu)

    def execute_cmd(self, cmd):
        self.telnet.read()
        self.telnet.write(cmd)
        time.sleep(4)
        self.telnet.read()

    def close_connections(self):
        self.telnet.close_all_connections()
