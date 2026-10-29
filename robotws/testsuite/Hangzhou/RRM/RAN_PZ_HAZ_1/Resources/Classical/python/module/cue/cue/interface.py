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
import copy
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
try:
    from .androidue import AndroidUeManager
except Exception as E:
    from .androidue import AndroidUeManager
from pprint import pprint


CMD_TIMEOUT = 60

robot_obj = BuiltIn()
os_obj = OperatingSystem()
kw = robot_obj.run_keyword
rv = robot_obj.get_variable_value
log_to_console = robot_obj.log_to_console

UES = {}
APPS = {}
logger.info('OK')


class cue(object):

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

        self.debug = self.in_robot and rv('${DEBUG_CUE}', 'N').upper() in ['Y', 'YES', 'TRUE']

        self.logger = logging.getLogger('CUE')
        logfile = 'cue.log'
        if self.in_robot:
            logfile = os.path.join(robot_obj.get_variable_value('${RESULT_DIR}'), logfile)

        if len(self.logger.handlers) == 0:
            from logging.handlers import RotatingFileHandler
            file_handler = RotatingFileHandler(logfile, maxBytes=20 * 1024 * 1024, backupCount=2)
            file_handler.setLevel(self.loglevel)
            formatter = logging.Formatter('%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                                          datefmt='%Y-%m-%d %H:%M:%S')
            file_handler.setFormatter(formatter)
            self.logger.addHandler(file_handler)

        self.AUM = AndroidUeManager(self.logger)
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

        fun_name = fun.__name__.lower()
        if fun_name.startswith('get_') or fun_name.startswith('set_'):
            pass
        else:
            for user_pm in kwargs:
                if user_pm not in ['item']:
                    if user_pm.lower() not in [x.lower() for x in params]:
                        raise Exception(f'Invalid parameter: {user_pm}')

        new_kwargs = {}
        for arg in kwargs:
            for real_pm in params:
                if real_pm.lower() == arg.lower():
                    pmvalue = kwargs[arg]
                    # if real_pm.lower() in pmtypes:
                    #     print('----------  ', real_pm, pmtypes[real_pm.lower()])
                    #     if isinstance(1, pmtypes[real_pm.lower()]):
                    #         pmvalue = int(pmvalue)
                    new_kwargs[real_pm] = pmvalue
                    break

        return new_kwargs

    def _smart_logger(self):
        self.logger = logger
        try:
            self.debug = robot_obj.get_variable_value('${DEBUG_CUE}', 'N').upper() in ['Y', 'YES', 'TRUE']
            if self.debug:
                self.logger.info = robot_obj.log_to_console
                self.logger.debug = robot_obj.log_to_console
                self.set_loggered = True
        except Exception as E:
            self.logger.error(E)
            self.set_loggered = True

    def get_ue_maps(self):
        ues = robot_obj.get_variable_value('${tl}').ues
        serialnos = []
        for item in ues:
            if isinstance(item, dict):
                p = item.get('UE_POOLS', {}).get('AndroidUePool', {}).get('inline_config', {})
                for at in p:
                    sn = p[at].get('CONSTRUCTOR_PARAMETERS', {}).get('serial_number', '')
                    if sn and sn not in serialnos:
                        serialnos.append(sn)
            else:
                if item.serial_number not in serialnos:
                    serialnos.append(item.serial_number)
        return serialnos

    def Commercial_UE_Operation(self, operation: str, **kwargs):
        self.setup()
        item = kwargs.get('item', '')
        ues = []
        ue_indexs = kwargs.get('ue_index', '')
        if ue_indexs:
            uelist = self.get_ue_maps()
            uelist = [uelist[int(index)] for index in ue_indexs.split(',')]
            ues = [self.AUM.ue(serialno) for serialno in uelist]

        serialnos = kwargs.get('serialno', '')
        if serialnos:
            ues += [self.AUM.ue(serialno) for serialno in serialnos.split(',')]
        for ue in ues:
            self.logger.info('')
            self.logger.info(f'************      Execute operation: "{operation}" for UE: {ue}    ********')
            ue.debug = self.debug
            # return 0
            op = operation.replace(' ', '_').strip().lower()

            if op.lower() in ['get', 'set']:
                if item:
                    op = f'{op.lower()}_{item}'
                else:
                    raise Exception('Please specify the item to get or set')

            if op.lower() in ['ui_operation']:
                if item:
                    op = item.lower()
                else:
                    raise Exception(f'Please specify the item for {op}')

            if hasattr(ue, op):
                fun = getattr(ue, op)
                new_kwargs = copy.deepcopy(kwargs)
                if 'serialno' in new_kwargs:
                    del new_kwargs['serialno']
                if 'ue_index' in new_kwargs:
                    del new_kwargs['ue_index']
                new_kwargs = self._pm_check(fun, **new_kwargs)
                return fun(**new_kwargs)
            else:
                raise Exception(f'Invalid operation: {operation}')


if __name__ == '__main__':
    cup = cue()
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    serialnos = '7TD0221525014570,H4K5T21107016538'
    cup.Commercial_UE_Operation(operation='is_calling', serialno=serialnos)
