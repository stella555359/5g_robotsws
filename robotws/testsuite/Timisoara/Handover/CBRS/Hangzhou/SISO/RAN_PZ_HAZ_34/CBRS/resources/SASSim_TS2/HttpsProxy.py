#!/usr/bin/env python
# -*- coding: utf-8 -*-


import socket
import time
import datetime
import logging
import select
import argparse
import configparser
import os
import sys
from utils.LoggerHandler import LoggerHandler
from httpBase.HttpRequestParser import HttpRequestParser
from threading import Thread, Event, Timer, Lock

mutex = Lock()

# ############################# DEFAULT CONFIGURATION START ###############
# port number binded to proxy service
PORT_NUM = 4431

# True means support IPv6 connection
# False means support IPv4 connection only
IPV6_ENABLE = False

# log file, should be None or str of file name. None means standard output
LOG_FILE = "HttpsProxy.log"

# log level, should be one of following (in increasing order of severity):
# logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR, logging.CRITICAL
LOG_LEVEL = "INFO"

# proxy keep connection max time duration.
# when timeout proxy will close connection with client
PROXY_KEEP_ALIVE_TIMER = 30.0

# ############################## DEFAULT CONFIGURATION END ################


# socket conf
UN_CONN_NUM = 16
SOCK_BUF_MAX = 8192


def get_https_proxy_log_path(confPath):
    proxy_log_file = LOG_FILE
    sec = "conf"
    try:
        config = configparser.ConfigParser()
        conPath = confPath
        config.read(conPath)

        items = config.items("conf")
        if config.has_option(sec, "proxy_log_name"):
            # sas_log_file = config.get(sec, 'proxy_log_name')
            proxy_log_file = config.get(sec, "proxy_log_name")
    except BaseException:
        print("parsing config file failed. unexcept error.")
    finally:
        return proxy_log_file


def logging_init(level, confPath):
    level_map = {
        "DEBUG": logging.DEBUG,
        "INFO": logging.INFO,
        "WARNING": logging.WARNING,
        "ERROR": logging.ERROR,
        "CRITICAL": logging.CRITICAL,
    }
    return LoggerHandler(
        "HttpsProxy",
        get_https_proxy_log_path(confPath),
        level_map.get(level, logging.INFO),
    )


def TimerReset(*args, **kwargs):
    """Global function for Timer"""
    return _TimerReset(*args, **kwargs)


class _TimerReset(Thread):
    """Call a function after a specified number of seconds:

    t = TimerReset(30.0, f, args=[], kwargs={})
    t.start()
    t.cancel() # stop the timer's action if it's still waiting
    """

    def __init__(self, interval, function, args=[], kwargs={}):
        Thread.__init__(self)
        self.interval = interval
        self.function = function
        self.args = args
        self.kwargs = kwargs
        self.finished = Event()
        self.resetted = True

    def cancel(self):
        """Stop the timer if it hasn't finished yet"""
        print("Time: %s - timer cacel..." % time.asctime())
        self.finished.set()

    def run(self):
        while not self.finished.isSet():
            print("Time: %s - timer running..." % time.asctime())

            self.resetted = True
            while self.resetted:
                print(
                    "Time: %s - timer waiting for timeout in %.2f..."
                    % (time.asctime(), self.interval)
                )
                self.resetted = False
                self.finished.wait(self.interval)

            if not self.finished.isSet():
                self.function(*self.args, **self.kwargs)
        print("Time: %s - timer finished!" % time.asctime())

    def reset(self, interval=None):
        """Reset the timer"""

        if interval:
            print("Time: %s - timer resetting to %.2f..." % (time.asctime(), interval))
            self.interval = interval
        else:
            print("Time: %s - timer resetting..." % time.asctime())

        self.resetted = True
        self.finished.set()
        self.finished.clear()


class Proxy(object):
    def __init__(self, logHandler, port, is_ipv6, proxy_timeout):
        self.socket_list = []
        self.tunnel = {}
        self.log = logHandler
        self.port = port
        self.proxy_timeout = proxy_timeout
        self.ipv6 = is_ipv6
        self.listensocket = None
        self.clientTimer = None
        self.clientSocket = None

    def onClienTimeout(self):
        self.log.info("Time: %s - discnnecting with CBRS..." % time.asctime())
        print("disconnect")
        self.close_tunnel(self.clientSocket)
        self.clientTimer.reset()

    def create_tunnel(self):
        clientsocket = None
        self.clientSocket = None
        targetsocket = None
        targetname = None
        targetport = None
        clientsocket, clientaddr = self.listensocket.accept()
        self.log.info(
            "accepted new connection from %s:%s" % (clientaddr[0], clientaddr[1])
        )
        clientsocket.setblocking(1)
        clientsocket.settimeout(5)
        req = clientsocket.recv(SOCK_BUF_MAX)
        self.log.debug(
            "received data from client %s:%s\r\n%s"
            % (clientaddr[0], clientaddr[1], req.decode())
        )
        now = datetime.datetime.utcnow()
        header_date = now.strftime("Date: %a, %d %b %Y %H:%M:%S GMT")
        status = 200
        http_p = HttpRequestParser(req.decode("utf-8"))
        if not http_p.req_parse():
            status = http_p.get_status()
            self.log.warning("parsing http header fail %d" % status)
        else:
            http_method = http_p.get_method()
            if http_method != "CONNECT":
                self.log.warning("unsupported method %s" % http_method)
                status = 405
            else:
                http_uri = http_p.get_uri()
                try:
                    if http_uri.find("]:") >= 0:
                        # IPv6 case
                        targetname, targetport = http_uri.split("]:")
                        targetname = targetname.lstrip("[")
                        targetsocket = socket.socket(socket.AF_INET6)
                    else:
                        targetname, targetport = http_uri.split(":")
                        targetsocket = socket.socket()
                    targetsocket.setblocking(1)
                    targetsocket.settimeout(5)
                    targetsocket.connect((targetname, int(targetport)))
                except socket.error as err:
                    self.log.warning(
                        "fail to connect target %s:%s" % (targetname, targetport)
                    )
                    status = 502
            res = http_p.res_builder(status, header=header_date)
            resb = res[1].encode("utf-8")
            clientsocket.sendall(resb)
            self.log.debug(
                "sent data to client %s:%s\r\n%s"
                % (clientaddr[0], clientaddr[1], resb.decode())
            )
            if status == 200:
                self.socket_list.append(clientsocket)
                self.socket_list.append(targetsocket)
                self.tunnel[clientsocket] = targetsocket
                self.tunnel[targetsocket] = clientsocket
                # workaround
                self.clientSocket = clientsocket
                self.log.info(
                    "created a tunnel %s:%s <--> %s:%s"
                    % (clientaddr[0], clientaddr[1], targetname, targetport)
                )
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
                self.clientTimer.reset()
            else:
                self.close_tunnel(endsocket)
        except socket.error as err:
            self.log.warning("fordwarding error :%s", err)
            self.close_tunnel(endsocket)

    def close_tunnel(self, endsocket):
        mutex.acquire()
        if endsocket in self.socket_list:
            self.log.info("closing tunnel on %s:%s" % (endsocket.getpeername()[0:2]))
            self.socket_list.remove(endsocket)
            self.socket_list.remove(self.tunnel[endsocket])
            peer = self.tunnel[endsocket]
            peer.shutdown(socket.SHUT_RDWR)
            peer.close()
            self.tunnel.pop(peer)
            endsocket.shutdown(socket.SHUT_RDWR)
            endsocket.close()
            self.tunnel.pop(endsocket)
        mutex.release()

    def end(self):
        for sock in self.socket_list:
            sock.shutdown(socket.SHUT_RDWR)
            sock.close()

        del self.socket_list[:]
        if self.clientTimer is not None:
            self.clientTimer.cancel()
            self.clientTimer = None
        self.tunnel.clear()
        self.log.info("proxy end.")

    def start(self):
        if self.ipv6:
            self.listensocket = socket.socket(socket.AF_INET6)
            self.log.info("created ipv6 socket")
        else:
            self.listensocket = socket.socket()
            self.log.info("created ipv4 socket")
        # reuse a local socket in TIME_WAIT state
        self.listensocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # blocking mode
        self.listensocket.setblocking(1)
        self.listensocket.settimeout(5)
        self.listensocket.bind(("", self.port))
        self.listensocket.listen(UN_CONN_NUM)
        self.log.info("start listening on port %d" % self.port)
        self.socket_list.append(self.listensocket)
        self.clientTimer = TimerReset(self.proxy_timeout, self.onClienTimeout)
        self.clientTimer.start()

        while True:
            try:
                time.sleep(0.01)
                rlist, wlist, xlist = select.select(self.socket_list, [], [])
                for readysocket in rlist:
                    if readysocket == self.listensocket:
                        self.create_tunnel()
                    else:
                        self.forward(readysocket)
                    break  # handle one socket per select operation
            except socket.error as err:
                self.log.warning("socket error :%s", err)
                continue
            except KeyboardInterrupt as err:
                logHandler.info("key board interrupt")
                self.end()
                break
            except Exception as err:
                self.end()
                raise


def proxy_main(logHandler, port, is_ipv6, proxy_timeout):
    proxy = Proxy(logHandler, port, is_ipv6, proxy_timeout)
    proxy.start()


def get_args():
    parser = argparse.ArgumentParser(description="Https Proxy")
    parser.add_argument(
        "-port", type=int, default=PORT_NUM, help="default: %d" % PORT_NUM
    )
    parser.add_argument("-ipv6", action="store_true", help="default: False")
    parser.add_argument(
        "-logLevel", default="INFO", help="DEBUG, INFO, WARNING, ERROR, CRITICAL"
    )
    parser.add_argument(
        "-proxy_timeout",
        type=float,
        default=PROXY_KEEP_ALIVE_TIMER,
        help="default %d" % PROXY_KEEP_ALIVE_TIMER,
    )
    parser.add_argument("-conf", default="SAS_Sim.conf", help="default: SAS_Sim.conf")
    return parser.parse_args()


# main entry
if __name__ == "__main__":
    try:
        args = get_args()
        logHandler = logging_init(args.logLevel, args.conf)
        logHandler.info("")
        logHandler.info("HttpsProxy start...")
        proxy_main(logHandler, args.port, args.ipv6, args.proxy_timeout)
    except KeyboardInterrupt:
        logHandler.info("key board interrupt")
    except Exception as err:
        logHandler.critical("error :%s", err)
    finally:
        # logHandler.info('HttpsProxy terminate...')
        pass
