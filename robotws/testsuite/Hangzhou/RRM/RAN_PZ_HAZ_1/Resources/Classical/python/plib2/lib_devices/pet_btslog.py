# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import socket
import sys
import logging
from threading import Thread
try:
    from pet_ssh import cpc_factory
except Exception:
    from .pet_ssh import cpc_factory


class pet_btslog(object):

    def __init__(self, **kwargs):
        self.log_filename = kwargs.get('filename', '/tmp/btslog.log')
        self.host = kwargs.get('host', '127.0.0.1')
        self.username = kwargs.get('username', 'ute')
        self.password = kwargs.get('password', 'uteUTE!')
        self.os = kwargs.get('os', 'linux')
        self.logger = kwargs.get('logger', logging.getLogger(__file__))
        self.is_local = self.host == '127.0.0.1'
        self.stop_flag = True
        self.port = 51000
        self.cpc = None
        self.socket = None

    def get_free_tcp_port(self):
        tcp = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        tcp.bind(('', 0))
        addr, port = tcp.getsockname()
        tcp.close()
        return port

    def remove_local_firewall(self):
        # remove local reject iptables
        output = os.popen('sudo iptables -L --line-numbers|grep REJECT').readlines()
        output = [x.split()[0] for x in output if 'anywhere' in x]
        if output:
            self.logger.info('Local iptables is not ok, try to fix it')
            line_number = output[0].split()[0]
            cmd = 'sudo iptables -D INPUT ' + line_number
            self.logger.info(cmd)
            os.system(cmd)
            self.logger.info('sudo iptables -L --line-numbers|grep REJECT')
        else:
            self.logger.info('Local iptables is ok')

    def kill_process_for_port(self, port):
        output = os.popen('sudo netstat -nalp |grep {}|grep -v grep').readline()
        for line in [x for x in output if x]:
            self.logger.debug(line)
            pid = line.split()[-1].split('/')[0]
            self.logger.info('Kill process: ' + pid)
            os.system('sudo kill -9 ' + pid)

    def start(self, **kwargs):
        self.remove_local_firewall()
        if self.is_local:
            pass
        else:
            path = os.path.dirname(os.path.abspath(__file__))
            local_file = os.path.join(path, 'udp_forward.py')

            cpc = cpc_factory(host=self.host, username=self.username, password=self.password,
                              os=self.os, logger=self.logger)
            cpc.logger = self.logger
            cpc.connect()
            # kill official btslog tool
            cpc.kill_process_with_keywords(keywords='btslog')
            # kill udp_forward.py tool
            cpc.kill_process_with_keywords(keywords='udp_forward.py')
            self.port = self.get_free_tcp_port()

            cpc.put_file_to_cpc(local_file, '/tmp/udp_forward.py')
            local_ip = socket.gethostbyname(socket.gethostname())
            cmd = ('nohup python /tmp/udp_forward.py --src_port 51000 '
                   '--destip {} --dst_port {}  >/dev/null 2>&1 &').format(local_ip, self.port)
            cpc.exec_command_background(cmd)
            self.cpc = cpc

        self.kill_process_for_port(self.port)
        self.socket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        self.socket.settimeout(1.0)
        self.socket.bind(('', self.port))

        self.stop_flag = False
        self.thread = Thread(target=btslog_monitor_thread, args=(self, ))
        self.thread.name = 'Btslogger'
        self.thread.start()

    def stop(self):
        self.stop_flag = True
        if self.cpc:
            self.cpc.kill_process_with_keywords(keywords='udp_forward.py')
        if self.socket:
            self.socket.close()

    def teardown(self):
        self.stop()


def _smart_decode(output1):
    if isinstance(output1, bytes):
        try:
            output = output1.decode("utf8")
        except Exception:
            try:
                output = output1.decode("gbk")
            except Exception:
                output = output1.decode("iso-8859-1", "ignore")
        return output
    else:
        return output1


def btslog_monitor_thread(btslogger):
    buf = ''
    msg = None
    while True:
        if btslogger.stop_flag:
            break
        if not bool(btslogger.socket):
            return 0
        try:
            msg, addr = btslogger.socket.recvfrom(8192)
        except Exception as e:
            btslogger.logger.info('Error: {}'.format(e))

        if btslogger.stop_flag:
            btslogger.socket.close()
        # try:
        #     if msg:
        #         try:
        #             msg = msg.decode()
        #         except Exception as E:
        #             pass
        # except Exception:
        #     if msg:
        #         try:
        #             msg = msg.decode('iso-8859-1')
        #         except Exception as E:
        #             pass
        if msg:
            msg = _smart_decode(msg)
            buf += msg
            if buf:
                recvdata = buf.splitlines()[:-1]
                buf = buf.splitlines()[-1]
                for line in recvdata:
                    if line.strip():
                        if ord(line[0]) == 0:
                            line = line[1:]
                        if btslogger.log_filename:
                            with open(btslogger.log_filename, 'a') as f:
                                f.write(line + '\n')


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s',
                        datefmt='%Y-%m-%d %H:%M:%S', level=logging.DEBUG)

    logger = logging.getLogger(__file__)
    logger.info('Start')
    # p = pet_btslog(host='10.56.221.82', port=51000, username='ute', password='qqwweeRR0-', logger=logger)
    p = pet_btslog(host='127.0.0.1', logger=logger)
    p.start()
    time.sleep(10)
    p.stop()
