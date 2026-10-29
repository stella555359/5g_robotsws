# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import logging

try:
    from pet_ssh import cpc_factory
except Exception:
    from .pet_ssh import cpc_factory

PROXY_PORT = 30000


class c_Proxy_Client(object):

    def __init__(self, **kwargs):
        self.host = kwargs.get('host')
        self.proxy_port = int(kwargs.get('proxy_port', 30000))
        self.alias = 'agent_{}_{}'.format(self.host, self.proxy_port)
        self.cpc = cpc_factory(**kwargs)
        self.proxy_server_file = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                              'pet_proxy_server.py')

    def __str__(self):
        return self.alias

    def __repr__(self):
        return self.__str__()

    def setup(self):
        self.cpc.setup()
        if self.cpc.is_linux:
            self.setup_for_linux()
        else:
            self.setup_for_windows()
        from xmlrpc import client as xml_client
        self.server = xml_client.ServerProxy('http://{}:{}'.format(self.host, self.proxy_port))

    def setup_for_windows(self):
        dst_file = r'c:\\python27\\pet_proxy_server.py'
        self.cpc.kill_process_by_keywords(['python', 'pet_proxy_server'])
        self.cpc.put_file_to_cpc(self.proxy_server_file, dst_file)
        self.cpc.start_application('c:\\python27\\python.exe', dst_file)
        self.cpc.wait_until_port_is_listening(self.proxy_port, 30)

    def setup_for_linux(self):
        pass

    def exec_cli(self, command):
        succeed, msg = self.server.exec_os_command(command)
        return succeed, msg


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    # agent = c_Proxy_Client(host='10.108.230.50')
    # agent.setup()

    from xmlrpc import client as xml_client
    import argparse
    server = xml_client.ServerProxy('http://10.108.230.50:30000')
    ports = [argparse.Namespace(**port) for port in server.list_comports_of()]
    ports = [x for x in ports if 'Quectel USB AT Port' in x.description]
    for port in ports:
        print(port)
