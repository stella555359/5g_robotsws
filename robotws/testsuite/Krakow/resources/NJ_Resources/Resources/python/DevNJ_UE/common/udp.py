"""
:author: Min Dai
:contact: min.b.dai@nokia-sbell.com
"""
import random
import logging
import subprocess
from robot.api import logger


class Udp(object):

    def __init__(self):
        pass

    @staticmethod
    def get_available_udp_port(lines, min_port=40000, max_port=45000):
        """
        Find one free and available udp port for iperf data traffic

        :param lines: list of occupied udp ports
        :param min_port: minimal port number
        :param max_port: max port number
        :return: free and available port number
        """
        logging.debug("starting find random free udp port.")
        i = 0
        while i < 100:
            i += 1
            logging.debug("trying find free udp port, i = {}".format(i))
            port = random.randint(min_port, max_port)
            port_str = ':{}'.format(port)
            logging.debug("testing udp port: {}".format(port))
            if any(port_str in line for line in lines):
                logging.debug("this port is occupied: {}".format(port))
                continue
            logger.info("found free udp port: {}".format(port))
            return port

    @staticmethod
    def get_occupied_udp_port_list():
        """
        Search the udp port list which has been occupied.

        :return: occupied udp port list
        """
        udp_port_str = ((subprocess.check_output(["netstat", "-nulp"])).decode('utf-8')).strip()
        tmpList = udp_port_str.split("\n")
        del tmpList[0:2]
        update_port_list = []

        for i in tmpList:
            val = i.split()
            del val[0:3]
            del val[1]
            valTmp = (val[0].split(":"))[-1]
            val[0] = valTmp
            valTmp = val[1].split('/')
            val[1] = valTmp[-1]
            val = ' '.join(val)
            update_port_list.append(val)
        return update_port_list
