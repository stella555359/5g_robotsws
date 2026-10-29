#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import os
import sys
import logging
import json
from pprint import pprint
from uepc import WinPC, LinuxPC


class FindUE:

    def __init__(self) -> None:
        fname = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-2])
        fname = fname + '/config/commercial_ue.json'
        if os.path.exists(fname):
            self.config = json.load(open(fname))
        else:
            self.config = {}
        self.config_fname = fname

    def get_ues(self, cpc):
        lines = cpc.exec_command('adb devices -l')
        return [x.split()[0].strip() for x in lines.splitlines() if x.strip() and 'device ' in x]

    def run(self, options):
        if options.os == 'windows':
            pc = WinPC(hostname=options.hostname, username=options.username,
                       password=options.password, port=options.port, os=options.os,
                       logger=logging.getLogger('Commercial UE'))
        else:
            pc = LinuxPC(hostname=options.hostname, username=options.username,
                         password=options.password, port=options.port, os=options.os,
                         logger=logging.getLogger('Commercial UE'))
        pc.setup()
        serials = self.get_ues(pc)
        item = dict(hostname=options.hostname, username=options.username, password=options.password,
                    port=options.port, os=options.os, ues={})
        for serialno in serials:
            item['ues'][serialno] = dict(serialno=serialno, model="")
        self.config['control pcs'][options.hostname] = item
        pprint(self.config)

        with open(self.config_fname, 'w', encoding='utf-8') as f:
            json.dump(self.config, f, indent=4, sort_keys=True)


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)

    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("--hostname",   dest="hostname")
    parser.add_option("--username",   dest="username", default=r'noklab\csv5-tester')
    parser.add_option("--password",   dest="password", default='Nokia123!')
    parser.add_option("--port",       dest="port", default=22)
    parser.add_option("--os",   dest="os", default='windows')

    (options, sys.argv[1:]) = parser.parse_args()
    fu = FindUE()
    fu.run(options)
