#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import os
import json
import inspect
from types import SimpleNamespace
from typing import Union
import logging
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from library.uebox_worker.spark_app import SparkApp
from library.uebox_worker.dingli_app import DingliApp


CMD_TIMEOUT = 60

robot_obj = BuiltIn()
os_obj = OperatingSystem()
kw = robot_obj.run_keyword
rv = robot_obj.get_variable_value
log_to_console = robot_obj.log_to_console

UES = {}
APPS = {}
logger.info('OK')


class BoxUE(object):

    def __init__(self, imsi, logger=logger) -> None:
        self.imsi = imsi
        self.cpc = None
        self.provider = None
        self.load_config()

        self.app: Union[SparkApp, DingliApp] = None
        if self.cpc.hostname in APPS:
            self.app = APPS[self.cpc.hostname]
        elif self.provider == 'spark':
            self.app = SparkApp(self.cpc.hostname, logger=logger)
            APPS.update({self.cpc.hostname: self.app})
        elif self.provider == 'dingli':
            self.app = DingliApp(self.cpc.hostname, logger=logger)
            APPS.update({self.cpc.hostname: self.app})
        UES[self.imsi] = self
        self.app.ues = self.cpc.uemap if hasattr(self.cpc, 'uemap') else {}

    def load_config(self) -> None:
        module_path = os.path.dirname(os.path.abspath(__file__))
        fname = os.path.join(module_path, 'config/uebox.json')
        data = json.load(open(fname, encoding='utf-8'))
        for cpc_ip in data['control pc']:
            pc = data['control pc'][cpc_ip]
            pc.update(hostname=cpc_ip)
            if self.imsi in pc.get('sparkues', []):
                self.provider = 'spark'
                self.cpc = SimpleNamespace(**pc)
            if self.imsi in pc.get('dingliues', []):
                self.provider = 'dingli'
                self.cpc = SimpleNamespace(**pc)
        if self.cpc is None:
            raise Exception(f'IMSI {self.imsi} not found in UEBox config')

    def __repr__(self) -> str:
        return f'BoxUE({self.provider}, {self.imsi}, {self.cpc.hostname})'


class Traffic_UEBox_Operation(object):

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'

    def __init__(self) -> None:
        self.setuped = False
        self.in_robot = False
        self.debug = False
        self.loglevel = logging.DEBUG

    def setup(self):
        if self.setuped:
            return 0

        self.in_robot = False
        try:
            BuiltIn().get_library_instance('BuiltIn')
            self.in_robot = True
        except Exception as E:
            pass

        self.debug = self.in_robot and rv('${DEBUG_UEBOX}', 'N').upper() in ['Y', 'YES', 'TRUE']

        self.logger = logging.getLogger('UEBOX')
        logfile = 'uebox.log'
        if self.in_robot:
            logfile = os.path.join(robot_obj.get_variable_value('${OUTPUT_DIR}'), 'uebox.log')

        if len(self.logger.handlers) == 0:
            from logging.handlers import RotatingFileHandler
            file_handler = RotatingFileHandler(logfile, maxBytes=20 * 1024 * 1024, backupCount=2)
            file_handler.setLevel(self.loglevel)
            formatter = logging.Formatter('%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                                          datefmt='%Y-%m-%d %H:%M:%S')
            file_handler.setFormatter(formatter)
            self.logger.addHandler(file_handler)
        self.setuped = True

    def _pm_check(self, fun, **kwargs):
        params = inspect.signature(fun).parameters
        # 遍历参数信息
        pmtypes = {}
        for parameter_name, parameter in params.items():
            # print(parameter_name, parameter)
            if parameter.annotation != inspect.Parameter.empty:
                # print(f"Parameter '{parameter_name}' type annotation: {parameter.annotation}")
                pmtypes[parameter_name.lower()] = parameter.annotation
            else:
                print(f"Parameter '{parameter_name}' has no type annotation")

        for user_pm in kwargs:
            if user_pm.lower() not in [x.lower() for x in params]:
                raise Exception(f'Invalid parameter: {user_pm}')

        new_kwargs = {}
        for arg in kwargs:
            for real_pm in params:
                if real_pm.lower() == arg.lower():
                    pmvalue = kwargs[arg]
                    if real_pm.lower() in pmtypes:
                        if isinstance(1, pmtypes[real_pm.lower()]):
                            pmvalue = int(pmvalue)
                    new_kwargs[real_pm] = pmvalue
                    break

        return new_kwargs

    def _smart_logger(self):
        self.logger = logger
        try:
            self.debug = robot_obj.get_variable_value('${DEBUG}', 'N').upper() in ['Y', 'YES', 'TRUE']
            if self.debug:
                self.logger.info = robot_obj.log_to_console
                self.logger.debug = robot_obj.log_to_console
                self.set_loggered = True
        except Exception as E:
            self.logger.error(E)
            self.set_loggered = True

    def Traffic_UEBox_Operation(self, operation: str, ue_imsi: str, **kwargs):
        self.setup()
        imsi_response = {}
        for imsi in [x.strip() for x in ue_imsi.split(',')]:
            ue = UES.get(imsi, BoxUE(imsi, self.logger))
            app = ue.app
            self.logger.info('')
            self.logger.info(f'************      Execute operation: "{operation}" for UE: {ue}, {app}    ********')
            op = operation.replace(' ', '_').strip().lower()
            if hasattr(app, op):
                fun = getattr(app, op)
                new_kwargs = self._pm_check(fun, **kwargs)
                params = inspect.signature(fun).parameters
                if not self.debug:
                    app.setup()
                if 'EQIndex' in params:
                    EQIndex = app.imsi2eqindex(imsi)
                    rep = fun(EQIndex, **new_kwargs)
                    imsi_response[imsi] = rep
                else:
                    fun(**new_kwargs)
            else:
                raise Exception(f'Invalid operation: {operation}')
        return imsi_response


if __name__ == '__main__':
    to = Traffic_UEBox_Operation()
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    app = SparkApp('10.56.201.38')
    app.setup()
    # app = DingliApp('10.69.65.101')
    # app.cpc.find_process(['Pioneer.exe'])
    # for i in range(1, 9):
    #     app.exec_at_cmd(i, 'ATI')
    # app._auto_check()
    app.start_testplan(8, 'Ping')
    # app.get_test_status(8)
    app.wait_until_testplan_done(8, '30s')
