#!/usr/bin/python3
# -*- coding: UTF-8 -*-

import os
import sys
import time
import re
import logging
import json
from types import SimpleNamespace
from pprint import pprint

above_path = os.sep.join(os.path.dirname(os.path.abspath(__file__)).split(os.sep)[:-1])
sys.path.append(above_path)
sys.path.append(os.path.join(above_path, 'lib_devices'))

formatter = logging.Formatter('%(asctime)s [%(levelname)5s] %(message)s',
                              datefmt='%Y-%m-%d %H:%M:%S')
logging.basicConfig(format=formatter._fmt, datefmt=formatter.datefmt, level=logging.INFO)
logger = logging.getLogger()


class PATool(object):

    def __init__(self, args):
        args = args

    def run(self):
        from lib_devices.pet_pa import change_pa_signal, change_pa_signal2

        if args.paname:
            change_pa_signal2(args.paname, args.points, args.signal, args.clear_all, logger)
        else:
            change_pa_signal(args.host, args.port,
                             args.device_type, args.model,
                             args.points, args.signal,
                             args.clear_all, logger)


if __name__ == "__main__":

    import argparse
    parser = argparse.ArgumentParser(description='PA/RFSwitch 控制工具',  epilog='如果有问题，请和开发联系。')
    parser.add_argument("--id",
                        dest="paid",
                        default='',
                        help='PA/RFSwitch的ID，如果指定这个名字，那么就从配置文件里面读取PA的信息')

    parser.add_argument("--host",
                        dest="host",
                        help='PA/RFSwitch的IP地址')

    parser.add_argument("--port",
                        dest="port",
                        default=23,
                        help='PA/RFSwitch的访问端口，缺省值：23')

    parser.add_argument("--device_type",
                        dest="device_type",
                        choices=['pa', 'rfswitch'],
                        default='pa',
                        help='指定设备是PA还是RFSwitch，缺省是pa')

    parser.add_argument("--model",
                        dest="model",
                        choices=['jx', 'jxb', 'hb'],
                        help='指定设备的规格')

    parser.add_argument("--total_in_port",
                        dest="total_in_port",
                        default=8,
                        help='PA/RFSwitch的入口数量，缺省是8')

    parser.add_argument("--total_out_port",
                        dest="total_out_port",
                        default=16,
                        help='PA/RFSwitch的出口数量，缺省是16')

    parser.add_argument("--points",
                        dest="points",
                        help='指定要条件的端点，比如是A1B2; 可以指定多个端点，用逗号隔开')

    parser.add_argument("--signal",
                        dest="signal",
                        help='指定信号值')

    parser.add_argument("--need_clear",
                        dest="clear_all",
                        action='store_true',
                        default=False,
                        help='指定要条件的端点，比如是A1B2; 可以指定多个端点，用逗号隔开')

    args = parser.parse_args()
    pprint(args)

    from lib_devices.pet_pa import change_pa_signal, change_pa_signal2

    if args.paid:
        change_pa_signal2(args.paid, args.points, args.signal, args.clear_all, logger)
    else:
        change_pa_signal(args.host, args.port,
                         args.device_type, args.model,
                         args.points, args.signal,
                         args.clear_all, logger)
