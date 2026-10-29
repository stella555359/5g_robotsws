# -*- coding: UTF-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""

import sys
import time
import socket


class c_udp_mirror(object):

    def __init__(self, dst, src_port, dst_port):
        self.src_port = src_port
        self.dst = dst
        self.dst_port = dst_port
        self.socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        self.socket.bind(('', src_port))
        self.conn = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def run(self):
        while True:
            msg, addr = self.socket.recvfrom(8192)
            self.conn.sendto(msg, (self.dst, self.dst_port))
            # time.sleep(0.1)


if __name__ == '__main__':
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-s", "--src_port", dest="src_port", default='51000', help='Sepcific the Customer info')
    parser.add_option("-d", "--destip", dest="destip", default='192.168.255.127', help='Sepc FDD Customer info')
    parser.add_option("-p", "--dst_port", dest="dst_port", default='51000', help='Sepcific the Customer info')

    (options, sys.argv[1:]) = parser.parse_args()
    p = c_udp_mirror(options.destip, int(options.src_port), int(options.dst_port))
    p.run()
