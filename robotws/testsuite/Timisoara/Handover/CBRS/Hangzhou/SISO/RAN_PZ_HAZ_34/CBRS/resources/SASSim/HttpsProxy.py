# !/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import time
import datetime
import logging
import select
import argparse
from utils.LoggerHandler import LoggerHandler
from httpBase.HttpRequestParser import HttpRequestParser

# port number binded to proxy service
PORT_NUM = 4431

# True means support IPv6 connection
# False means support IPv4 connection only
IPV6_ENABLE = False

# log file, should be None or str of file name. None means standard output
LOG_FILE = 'HttpsProxy.log'

# log level, should be one of following (in increasing order of severity):
# logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR, logging.CRITICAL
LOG_LEVEL = 'INFO'


# socket conf
UN_CONN_NUM = 16
SOCK_BUF_MAX = 8192


def logging_init(log_file, level):
    level_map = {'DEBUG': logging.DEBUG,
                 'INFO': logging.INFO,
                 'WARNING': logging.WARNING,
                 'ERROR': logging.ERROR,
                 'CRITICAL': logging.CRITICAL}
    return LoggerHandler('HttpsProxy', log_file, level_map.get(level, logging.INFO))


class Proxy(object):

    def __init__(self, logHandler, port, is_ipv6):
        self.socket_list = []
        self.tunnel = {}
        self.log = logHandler
        self.port = port
        self.ipv6 = is_ipv6
        self.listensocket = None

    def create_tunnel(self):
        clientsocket = None
        targetsocket = None
        targetname = None
        targetport = None
        clientsocket, clientaddr = self.listensocket.accept()
        self.log.info('accepted new connection from %s:%s' % (clientaddr[0], clientaddr[1]))
        clientsocket.setblocking(1)
        clientsocket.settimeout(5)
        req = clientsocket.recv(SOCK_BUF_MAX)
        self.log.debug('received data from client %s:%s\r\n%s' % (clientaddr[0], clientaddr[1], req))
        now = datetime.datetime.utcnow()
        header_date = now.strftime("Date: %a, %d %b %Y %H:%M:%S GMT")
        status = 200
        http_p = HttpRequestParser(req.decode('utf-8'))
        if http_p.req_parse() is False:
            status = http_p.get_status()
            self.log.warning('parsing http header fail %d' % status)
        else:
            http_method = http_p.get_method()
            if http_method != 'CONNECT':
                self.log.warning('unsupported method %s' % http_method)
                status = 405
            else:
                http_uri = http_p.get_uri()
                try:
                    if http_uri.find(']:') >= 0:
                        # IPv6 case
                        targetname, targetport = http_uri.split(']:')
                        targetname = targetname.lstrip('[')
                        targetsocket = socket.socket(socket.AF_INET6)
                    else:
                        targetname, targetport = http_uri.split(':')
                        targetsocket = socket.socket()
                    targetsocket.setblocking(1)
                    targetsocket.settimeout(5)
                    targetsocket.connect((targetname, int(targetport)))
                except socket.error as err:
                    self.log.warning('fail to connect target %s:%s' % (targetname, targetport))
                    status = 502
            res = http_p.res_builder(status, header=header_date)
            resb = res[1].encode('utf-8')
            clientsocket.sendall(resb)
            self.log.debug('sent data to client %s:%s\r\n%s' % (clientaddr[0], clientaddr[1], resb))
            if status == 200:
                self.socket_list.append(clientsocket)
                self.socket_list.append(targetsocket)
                self.tunnel[clientsocket] = targetsocket
                self.tunnel[targetsocket] = clientsocket
                self.log.info('created a tunnel %s:%s <--> %s:%s' % (clientaddr[0], clientaddr[1],
                                                                     targetname, targetport))
            else:
                if clientsocket is not None:
                    clientsocket.close()
                if targetsocket is not None:
                    targetsocket.close()

    def forward(self, endsocket):
        try:
            data = endsocket.recv(SOCK_BUF_MAX)
            if len(data) > 0:
                self.tunnel[endsocket].sendall(data)
            else:
                self.close_tunnel(endsocket)
        except socket.error as err:
            self.log.warning('fordwarding error :%s', err)
            self.close_tunnel(endsocket)

    def close_tunnel(self, endsocket):
        self.log.info('closing tunnel on %s:%s' % (endsocket.getpeername()[0:2]))
        self.socket_list.remove(endsocket)
        self.socket_list.remove(self.tunnel[endsocket])
        peer = self.tunnel[endsocket]
        peer.close()
        self.tunnel.pop(peer)
        endsocket.close()
        self.tunnel.pop(endsocket)

    def end(self):
        for sock in self.socket_list:
            sock.close()
        del self.socket_list[:]
        self.tunnel.clear()
        self.log.info('proxy end.')

    def start(self):
        if self.ipv6 is True:
            self.listensocket = socket.socket(socket.AF_INET6)
            self.log.info('created ipv6 socket')
        else:
            self.listensocket = socket.socket()
            self.log.info('created ipv4 socket')
        # reuse a local socket in TIME_WAIT state
        self.listensocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # blocking mode
        self.listensocket.setblocking(1)
        self.listensocket.settimeout(5)
        self.listensocket.bind(('', self.port))
        self.listensocket.listen(UN_CONN_NUM)
        self.log.info('start listening on port %d' % self.port)
        self.socket_list.append(self.listensocket)
        while True:
            try:
                time.sleep(0.01)
                rlist, wlist, xlist = select.select(self.socket_list, [], [])
                for readysocket in rlist:
                    if readysocket == self.listensocket:
                        self.create_tunnel()
                    else:
                        self.forward(readysocket)
                    break
            except socket.error as err:
                self.log.warning('socket error :%s', err)
                continue
            except KeyboardInterrupt as err:
                logHandler.info('key board interrupt')
                self.end()
                break
            except Exception as err:
                self.end()
                raise


def proxy_main(logHandler, port, is_ipv6):
    proxy = Proxy(logHandler, port, is_ipv6)
    proxy.start()


def get_args():
    parser = argparse.ArgumentParser(description='Https Proxy')
    parser.add_argument('-port', type=int, default=PORT_NUM, help='default: %d' % PORT_NUM)
    parser.add_argument('-ipv6', action='store_true', help='default: False')
    parser.add_argument('-logLevel', default='INFO', help='DEBUG, INFO, WARNING, ERROR, CRITICAL')
    parser.add_argument('-logFile', type=str, default=LOG_FILE, help='default: %s' % LOG_FILE)
    return parser.parse_args()


# main entry
if __name__ == '__main__':
    try:
        args = get_args()
        logHandler = logging_init(args.logFile, args.logLevel)
        logHandler.info('')
        logHandler.info('HttpsProxy start...')
        proxy_main(logHandler, args.port, args.ipv6)
    except KeyboardInterrupt:
        logHandler.info('key board interrupt')
    except Exception as err:
        logHandler.critical('error :%s', err)
    finally:
        # logHandler.info('HttpsProxy terminate...')
        pass
