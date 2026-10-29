# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import sys
import logging

try:
    from robot.api import logger
    from robot.libraries import BuiltIn
except Exception:
    logger = logging.getLogger('PetTA')

from lib_devices.common import IpaMmlItem, init_keyword_group


class c_global_var_list(IpaMmlItem):

    def __init__(self):
        self._show_in_rfhub = False
        self.ta_server = '10.106.200.66'
        self.local_tool_path = '/home/ute/temp/tools'
        self.suite = IpaMmlItem()
        self.case = IpaMmlItem()
        self.case.case_dire = '/tmp'
        self.logger = logger
        self.resources = ''

        self.robot_file = ''
        self.operator = ''
        self.queue = ''
        try:
            self.output_dire = self.pv('${RESULT_DIR}')
            self.robot_file = self.pv('${SUITE_SOURCE}')
            self.debug = self.pv('${DEBUG_MODE}') == 'YES'
            self.tl = self.pv('${tl}')
            self.tlname = self.pv('${CONFIGURATION}').split('.')[-1]
            self.install_build = self.pv('${INSTALL_BUILD}').upper() == 'YES'
            self.resources = self.pv('${RESERVE_RESOURCE}')
            self.jobname = self.pv('${JENKINS_PROJECT}')
            # 1: do nothing, 2: clean log only when case passed; 3: always clean log
            self.clean_log = int(self.pv('${CLEAN_LOG}')) or 1
            self.clean_log_size = int(self.pv('${CLEAN_LOG_SIZE}')) * 1024 * 1024 or 10 * 1024 * 1024
        except Exception:
            pass
        self.admin_master = None
        self.bts_version = ''
        self.robot_path = os.path.dirname(self.robot_file)
        self.py_path = os.path.dirname(os.path.abspath(__file__))
        self.keyword_group = init_keyword_group()
        self.is_vm = bool(os.popen('ip -4 a|grep 192.168.255.126').read().strip())
        self.teardown_list = []
        self.domain_name = 'ju'
        self.domain_password = 'mmnnbbVV0-'
        self.file_server = '10.56.111.190'

        self.mo = {
            'android': {
            },
            'ssh': {
            }
        }
        # try:
        #     if self.is_vm:
        #         self.install_lib('mysql-connector-python')
        # except Exception as E:
        #     self.write_console('Error in install lib')

    def pv(self, varname):
        builtin = BuiltIn.BuiltIn()
        if varname in builtin.get_variables():
            return builtin.get_variables()[varname]
        else:
            return ''

    def kw(self, kwname, *args):
        builtin = BuiltIn.BuiltIn()
        return builtin.run_keyword(kwname, *args)

    def exec_local_command(self, command):
        logger.info('Run local command: {}'.format(command))
        os.system(command)
        # import subprocess
        # p = subprocess.Popen(command, stdout=subprocess.PIPE,
        #                      stderr=open(os.devnull, 'w'), shell=True)
        # out, error = p.communicate()
        # if out:
        #     logger.info('command output: [%s]' % (out.decode()))
        # if error:
        #     logger.error('command error: [%s]' % (error.decode()))
        # if out:
        #     return out.decode()
        # if error:
        #     return error.decode()

    def write_console(self, s):
        logger.console('\n' + str(s))
        logging.info(s)

    def casefile(self, filename):
        return os.path.join(self.case.case_dire, filename)

    def show_env(self):
        self.python_version = 'python {v.major}.{v.minor}.{v.micro}'.format(v=sys.version_info)
        self.python_path = sys.path
        self.python_app = sys.executable
        self.logger.console('{} | {}'.format(self.python_version, self.python_app))
        for path in self.python_path:
            self.logger.console(path)
        self.logger.console('Debug mode: {}'.format(self.debug))

    def dict2obj(self, data):
        import json
        from types import SimpleNamespace
        print(str(data))
        return json.loads(str(data).replace("'", '"'), object_hook=lambda d: SimpleNamespace(**d))
        obj = IpaMmlItem()
        for key in data:
            value = data[key]
            setattr(obj, key, value)

        return obj

    def winpath(self, path):
        return "{}".format('\\\\'.join(path.split('\\')))

    def get_remote_file(self, host, port, username, password, remotefile, localfile):
        import paramiko
        self.conn = paramiko.SSHClient()
        self.conn.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.conn.connect(host, port, username, password)
        self.shell = self.conn.invoke_shell()
        self.trans = paramiko.Transport(sock=(host, port))
        self.trans.connect(username=username, password=password)
        self.sftp = paramiko.SFTPClient.from_transport(self.trans)
        self.sftp.get(remotefile, localfile)
        self.trans.close()
        self.conn.close()

    def get_130_file(self, remotefile, localfile):
        self.get_remote_file('10.106.200.66', 22, 'ute', 'qqwweeRR0-', remotefile, localfile)

    def install_lib(self, libname):
        python_path = sys.executable
        lines = os.popen(f'{python_path} -m pip list|grep {libname}').read().splitlines()
        if lines:
            self.write_console(f'Python Lib {libname} already exist.')
        else:
            self.write_console(f'Python Lib {libname} does not exist, need to install')
            lines = os.popen(f'{python_path} -m pip install {libname}').read().splitlines()

    def teardown(self):
        self.logger.info('Teardown gv')
        for obj in self.teardown_list:
            if hasattr(obj, 'teardown'):
                obj.teardown()
            self.teardown_list.remove(obj)

    def andriod_ue(self, serialno):
        if serialno in self.mo['andriod_ue']:
            return self.mo['andriod_ue'][serialno]
        else:
            return None

    def add_andriod_ue(self, serialno, ue):
        self.mo['android_ue'].update({serialno: ue})

    def mybool(self, value):
        return value.upper() in ['Y', 'YES']


gv = c_global_var_list()
