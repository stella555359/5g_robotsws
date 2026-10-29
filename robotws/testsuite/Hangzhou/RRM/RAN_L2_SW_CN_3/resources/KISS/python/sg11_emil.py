# -*- coding: utf-8 -*-

from ta_aatrace import ta_aatrace
# import ConfigParser
import configparser
import re
import pkg_resources
import os
from ttitrace_control import get_mac_tti_address
import sys

ta_aatrace = ta_aatrace()

rack = {'1': 'FSM1',
        '2': 'FSM2'
        }

board = {'2': 'FSP1',
         '3': 'FSP2',
         '4': 'FSP3'
         }

cpu = {'3': 'K2A',
       '4': 'K2B',
       '5': 'K2C',
       '6': 'K2D'
       }


def _read_session():
    listed = []
    # config=ConfigParser.ConfigParser()
    config = configparser.ConfigParser()
    nodeIni_path = pkg_resources.resource_filename('ta_aatrace', 'syscom/resource/WMP_nodes.ini')
    config.read(nodeIni_path)
    for session in config.sections():
        listed.append(session)
    return listed


def module_type(enb_type):
    listed = []
    for session in _read_session():
        if enb_type in session:
            listed.append(_del_underline(session))
    return listed


def _del_underline(text):
    return re.sub('([a-zA-Z]+)\\_(\\d)', r'\1\2', text)


def generate_profile(message_listed):
    module_listed = _tract_macadd_return_module()
    save_file = '{}/profile.txt'.format(os.path.dirname(__file__))
    file = open(save_file, 'w+')
    for i in module_listed:
        file.write('[{}]\n'.format(l))
        file.write('=\n')
        for i, message in enumerate(message_listed, 1):
            file.write('Signal{}={}|0x0|0\n'.format(i, message))
        file.write('HeavyLoad1=0x500c|5000\n')
        file.write('HeavyLoad2=0x5036|5000\n')
        file.write('HeavyLoad3=0x503c|10000\n')
        file.write('HeavyLoad4=0x5077|10000\n')
        file.write('HeavyLoad5=0x5004|5000\n')
        file.write('HeavyLoad6=0x5000|5000\n')
        file.write('HeavyLoad7=0x504f|5000\n')
        file.write('HeavyLoad8=0x8021|10000\n')
    file.close()
    return os.path.abspath(save_file)


def _tract_macadd_return_module():
    add_list = []
    str_list = []
    module_listed = []
    for add in get_mac_tti_address().split(','):
        add_list.append(add[0:3])
    for element in list(set(add_list)):
        num = list(element)
        if len(num) == 3:
            string = 'FSMr4_{}_{}_{}'.format(rack[num[0]], board[num[1]], cpu[num[2]])
            str_list.append(string)
    for enb_type in str_list:
        temp = module_type(enb_type)
        module_listed += temp
    return list(set(module_listed))


def sg11_start_aatrace(filename, message_list, enb_port=15004):
    try:
        ta_aatrace.teardown_all_aliases_for_aatrace()
    except Exception as result:
        pass
    config_file = generate_profile(message_list)
    ta_aatrace.start_aatrace(filename=filename, config_file=config_file, enb_port=enb_port)


def sg11_stop_aatrace():
    ta_aatrace.stop_and_collect_aatrace_file()


if __name__ == "__main__":
    sg11_start_aatrace(sys.argv[1], sys.argv[2])
    sg11_stop_aatrace()
    pass
