# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import subprocess
import sys
import os


def start_iperf(args, log_file=None):
    """xx
    """
    if os.path.exists(log_file):
        try:
            os.remove(log_file)
        except Exception as e:
            print("Error: %s" % str(e))
            os.system("rm -f %s" % log_file)
    if not log_file:
        redirect_stream = sys.stdout
    else:
        redirect_stream = open(log_file, 'a')
    p = subprocess.Popen(args, stdout=redirect_stream)
    p.wait()


def get_log_file():
    """ get
    """
    for arg in sys.argv[1:]:
        if arg == '-o' or arg == '--output':
            return sys.argv[1:][sys.argv[1:].index(arg) + 1]


def parse_args():
    """ parse
    """
    args = sys.argv[1:]
    cmd = ''
    continue_flag = False
    for arg in args[:]:
        if arg == "-o" or arg == "--output":
            continue_flag = True
            continue
        if continue_flag:
            continue_flag = False
            continue
        cmd = cmd + ' ' + arg
    return cmd.strip()


if __name__ == "__main__":
    log_file = get_log_file()
    args = parse_args()
    print("Exec Cmd: \"%s\"" % args)
    start_iperf(args, log_file)
