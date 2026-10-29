

# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

import time
import logging
import sys
import json
import os
import re
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
from robot.libraries.OperatingSystem import OperatingSystem
from taf.gnb.oam.coam.vdu import vdu
from taf.gnb.oam.coam.cu import cu

from taf.transport.ssh import ssh
from robot.api import logger
from functools import wraps
import traceback
from types import SimpleNamespace
from pprint import pprint, pformat
logging.getLogger('paramiko').setLevel(logging.WARNING)

os_obj = OperatingSystem()
robot_obj = BuiltIn()
kw = robot_obj.run_keyword
pv = robot_obj.get_variable_value
log_console = robot_obj.log_to_console


def is_robot_execution_context():
    return BuiltIn().get_library_instance('BuiltIn') is not None


def import_related_libs(libtlist):

    if isinstance(libtlist, str):
        libtlist = [libtlist]

    for line in libtlist:
        if ',' in line:
            lib_name, withname = line.split(',')
            kw('import_library', lib_name, 'AS', withname)
        else:
            lib_name, withname = line, ''
            try:
                robot_obj.get_library_instance(lib_name)
                log_console(f'lib {lib_name} already exist.')
            except Exception as E:
                log_console(f'lib {lib_name} does not exist, I will import it.')
                robot_obj.import_library(lib_name)


class UnitBase(SimpleNamespace):

    pm_module = 'oampm'
    pm_path = '/mnt/services/SS_OAM/PMSTAT/pm_report_files'

    def pod(self, podname):
        return f'ute-{self.ns}-{podname}-0'

    def container(self, container_name):
        return f'ctr-{self.ns}-{container_name}'


__units = {
    "vcu_0": UnitBase(object=cu()),
    "vdu_0": UnitBase(object=vdu()),
    "vdu_1": UnitBase(object=vdu()),
}

for unit in __units:
    item = __units[unit]
    item.iscu = 'cu' in unit
    item.isdu = 'du' in unit
    item.alias = 'paic_' + unit
    item.index = int(unit.split('_')[-1])
    item.ssh_conn = None
    item.core_ssh = None
    item.podlist = []
    if item.iscu:
        item.connstr = f'connection={item.alias}'
    else:
        item.connstr = f'vdu_connection={item.alias}'


def _get_unit(unit_name):
    unit_name = unit_name.strip().replace('-', '_')
    if unit_name in __units:
        return __units[unit_name]
    else:
        raise Exception("Unit %s not valid" % unit_name)


def _wait_until_fun_done(timer, interval, fun, *args):
    ctime = time.time()
    while time.time() < ctime + int(timer):
        if fun(*args):
            return 0
        else:
            time.sleep(interval)
    raise Exception(f'Timeout for fun: {fun} {args}')


def _wait_until_operation_done(timer, interval, fun, *args, **kwargs):
    ctime = time.time()
    current = None
    while time.time() < ctime + int(timer):
        current = fun(*args, **kwargs)
        logger.info(current)
        if current['status'].lower() in ['ongoing']:
            time.sleep(int(interval))
        else:
            return current
    return current


def _check_asyc_call(timer, interval, error_prompt, fun, *args, **kwargs):
    current = _wait_until_operation_done(timer, interval, fun, *args, **kwargs)
    if current['status'] in ['failure']:
        raise Exception(f'{error_prompt} {current}')


def logprint(p):
    logger.info(pformat(p))


def with_rest(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        obj, unit_name = args[:2]
        r = None
        obj.paic_login(unit_name)
        try:
            r = func(*args, **kwargs)
        finally:
            pass
            # obj._paic_logout(unit_name)
        return r
    return wrapper


def with_ssh(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        obj, unit_name = args[:2]
        obj._open_k8s_connection(unit_name)
        r = func(*args, **kwargs)
        obj._close_k8s_connection(unit_name)
        return r
    return wrapper


class pkw_aic(object):

    """

    =  基本说明  =

    本库主要提供针对 ``AirPhone`` 的 keyword

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'

    def __init__(self):
        self.vdu_name = 'pet_vdu'
        self.vcu_name = 'pet_vcu'
        self.vdu_object = None
        self.vcu_object = None
        self.cu_config = None
        try:
            BuiltIn().get_library_instance('BuiltIn')
            self.in_robot = True
        except Exception as E:
            self.in_robot = False

        self._tl = None
        self.du_configs = []
        if self.in_robot:
            self.__import_lib()
        self.login_units = []

    @property
    def tl(self):
        if self._tl:
            return self._tl
        else:
            try:
                self._tl = pv('${tl}')
            except Exception as E:
                self._tl = None

            if self._tl is None:
                import importlib
                tlname = os.popen('hostname').read().splitlines()[0].replace('-', '_')
                config_path = os.path.expanduser('~/testline_configuration')
                if os.path.exists(config_path):
                    os_obj.run(f'cp -r {config_path}/{tlname} .')
                    self._tl = importlib.import_module(tlname).tl
                    os_obj.run(f'rm -rf {tlname}')
        return self._tl

    def __import_lib(self):
        installed_libs = None
        try:
            installed_libs = robot_obj.get_library_instance('ssh', all=True)
        except Exception as E:
            pass
        robot_obj.import_library('taf.gnb.oam.coam.cu', 'WITH NAME', 'vcu_0')
        robot_obj.import_library('taf.gnb.oam.coam.vdu', 'WITH NAME', 'vdu_0')
        robot_obj.import_library('taf.gnb.oam.coam.vdu', 'WITH NAME', 'vdu_1')
        if installed_libs and 'ssh' not in installed_libs:
            robot_obj.import_library('taf.transport.ssh', 'WITH NAME', 'ssh')

    @classmethod
    def __status_failed(self, resp):
        return resp['status'] in ['failure']

    @classmethod
    def __status_succeed(self, resp):
        logprint(resp)
        return resp['status'] in ['success']

    def __load_config(self):
        tl = self.tl

        if tl is None:
            raise Exception('tl is None')

        cu_mn = tl.gnbs[0].cloud_deployment.cloud_hosting.master_node
        cu_config = SimpleNamespace(
            host=tl.gnbs[0].cu.oam_http_connection_details.addr,
            username=tl.gnbs[0].cu.oam_http_connection_details.username,
            password=tl.gnbs[0].cu.oam_http_connection_details.password,
            namespace=tl.gnbs[0].cloud_deployment.cloud_hosting.namespace,
            mn_ssh_host=cu_mn.ssh_connection_details.addr,
            mn_ssh_username=cu_mn.ssh_connection_details.username,
            mn_ssh_password=cu_mn.ssh_connection_details.password,
            mn_ssh_port=cu_mn.ssh_connection_details.port,
        )
        unit = _get_unit('vcu_0')
        unit.config = cu_config
        unit.ns = unit.config.namespace
        dus = tl.gnbs[0].dus
        du_configs = []
        for du in dus:
            mn = du.cloud_deployment.cloud_hosting.master_node
            du_configs.append(
                SimpleNamespace(
                    host=du.oam_http_connection_details.addr,
                    username=du.oam_http_connection_details.username,
                    password=du.oam_http_connection_details.password,
                    instance_id=du.instance_id,
                    namespace=du.cloud_deployment.cloud_hosting.namespace,
                    mn_ssh_host=mn.k8s_connection_details.ip_addr,
                    mn_ssh_username=mn.k8s_connection_details.username,
                    mn_ssh_password=mn.k8s_connection_details.password,
                    mn_ssh_port=mn.k8s_connection_details.port,
                )
            )
            unit = _get_unit(f'vdu_{du.instance_id - 1}')
            unit.config = du_configs[-1]
            unit.ns = unit.config.namespace
        self.cu_config = cu_config
        self.du_configs = du_configs

    def _smart_call(self, unit_name, funname, *pmlist, **kwargs):
        '''
        所有传入参数采用字典方式，例如：
        kwargs传入了原始的参数类型，在这里对于robot的调用需要转换，对于函数调用，不需要转换；
        '''
        unit = _get_unit(unit_name)
        if funname == 'connect_to':
            p1 = 'alias' if unit.iscu else 'connection_name'
        else:
            p1 = f'connection' if unit.iscu else 'vdu_connection'
        kwargs.update({p1: unit.alias})

        if self.in_robot:
            pmlist = []
            for item in kwargs:
                key = item
                value = kwargs[item]
                if isinstance(value, bool):
                    value = r'${True}' if value else r'${False}'
                if isinstance(value, str):
                    value = value if value else r'${EMPTY}'
                if isinstance(value, list) or isinstance(value, dict):
                    varname = f'tmpv_{len(pmlist)}'
                    robot_obj.set_test_variable('$' + varname, value)
                    value = '${' + varname + '}'
                pmlist.append(f'{key}={value}')
            return kw(f'{unit_name}.{funname}', *pmlist)
        else:
            return getattr(unit.object, funname)(**kwargs)

    def _bi_call(self, robot_funname, python_funname, *pmlist, **kwargs):
        '''
        用来实现robot和python的函数调用
        第一个参数是robot的kw的名字，会传给kw这个函数，作为第一个参数；
        第二个参数是python的函数对象；
        '''
        if self.in_robot:
            pmlist = []
            for item in kwargs:
                key = item
                value = kwargs[item]
                if isinstance(value, bool):
                    value = r'${True}' if value else r'${False}'
                if isinstance(value, str):
                    value = value if value else r'${EMPTY}'
                if isinstance(value, list) or isinstance(value, dict):
                    varname = f'tmpv_{len(pmlist)}'
                    robot_obj.set_test_variable('$' + varname, value)
                    value = '${' + varname + '}'
                pmlist.append(f'{key}={value}')
            return kw(f'{robot_funname}', *pmlist)
        else:
            return python_funname(*pmlist, **kwargs)

    def _wait_until_rest_api_available(self, host, timeout=300):
        for _ in range(timeout):
            lines = os.popen(f'nc -zv {host} 443').read()
            log_console(lines)
            if 'refused'.lower() in lines.lower():
                time.sleep(1)
            else:
                return 0
        raise Exception(f'{host}:443 could not been reach in 300s')

    def paic_login(self, unit_name):
        # logger.info('Try to login...')
        # if unit_name in self.login_units and not forced:
        #     return 0
        self.__load_config()
        logger.debug(f'REST Login {unit_name}')
        cu_config = self.cu_config
        du_configs = self.du_configs
        unit = _get_unit(unit_name)
        if unit.iscu:
            host = cu_config.host if cu_config else '192.168.100.129'
            username = cu_config.username if cu_config else 'Nemuadmin'
            password = cu_config.password if cu_config else 'nemuuser'
            port = ''
        if unit.isdu:
            du_config = [x for x in du_configs if x.instance_id - 1 == unit.index]
            du_config = du_config[0] if du_config else None
            host = du_config.host if cu_config else '192.168.255.129'
            username = du_config.username if cu_config else 'Nemuadmin'
            password = du_config.password if cu_config else 'nemuuser'
            port = ''

        self.paic_logout(unit_name)
        port = '${EMPTY}' if self.in_robot else ''
        self._smart_call(unit_name, 'connect_to',
                         host=host, port=port, username=username,
                         password=password, secure=True)
        self.login_units.append(unit_name)

    def paic_logout(self, unit_name):
        unit = _get_unit(unit_name)
        if self.in_robot:
            kw('run keyword and ignore error', f'{unit_name}.disconnect', unit.alias)
        else:
            try:
                unit.object.disconnect(unit.alias)
            except Exception as E:
                pass

    @keyword
    def paic_wait_until_operation_done(self, timer, interval, unit_name, kwname, *args, **kwargs):
        ctime = time.time()
        current = None
        while time.time() < ctime + int(timer):
            current = self._smart_call(unit_name, kwname, *args, **kwargs)
            logger.info(current)
            if current['status'].lower() in ['ongoing']:
                time.sleep(int(interval))
            else:
                return current
        return current

    @with_rest
    def __remove_existing_plan_file(self, unit_name):
        logger.info('Remove existing plan file')
        unit = _get_unit(unit_name)
        if unit.iscu:
            staged_plan_files = self._smart_call(unit_name, 'get_staged_plans_list')
            for stated_plan in staged_plan_files:
                self._smart_call(unit_name, 'plan_delete', plan_id=stated_plan['plan_id'])
        if unit.isdu:
            staged_plan_files = self._smart_call(unit_name, 'get_staged_plans_info_list')
            for stated_plan in staged_plan_files:
                self._smart_call(unit_name, 'delete_staged_plan_file', plan_id=stated_plan['plan_id'])

    @with_rest
    def __upload_plan_file(self, unit_name, scf_file):
        logger.info('')
        unit = _get_unit(unit_name)
        logger.info(f'Upload SCF file: {scf_file}')
        if unit.iscu:
            resp = self._smart_call(unit_name, 'upload_plan_file', path_to_plan_file=scf_file)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_operation_state_of_uploading_plan', operation_id=action_id)
        if unit.isdu:
            resp = self._smart_call(unit_name, 'upload_plan', path_to_plan_file=scf_file)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_upload_plan_operation_status', operation_id=action_id)

        if self.__status_failed(current):
            raise Exception(f'Upload SCF Failed: {current}')
        logger.info(f'Upload SCF file: {scf_file} done, plan_id: {plan_id}')
        return plan_id

    @with_rest
    def __validate_full_plan(self, unit_name, plan_id):
        logger.info('')
        unit = _get_unit(unit_name)
        logger.info('Validate plan...')
        if unit.iscu:
            resp = self._smart_call(unit_name, 'plan_validation', plan_id=plan_id)
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_operation_state_of_validating_plan',
                plan_id=plan_id, operation_id=resp['action_id'])

        if unit.isdu:
            resp = self._smart_call(unit_name, 'validate_plan', plan_id=plan_id)
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_validate_plan_operation_status',
                plan_id=plan_id, operation_id=resp['action_id'])

        if self.__status_failed(current):
            raise Exception(f'Validate plan Failed: {current}')
        logger.info(f'Validate plan done. {current}')

    @with_rest
    def __activate_full_plan(self, unit_name, plan_id):
        unit = _get_unit(unit_name)
        logger.info('')
        logger.info('Activate plan...')
        if unit.iscu:
            resp = self._smart_call(unit_name, 'plan_activation', plan_id=plan_id)
            logger.info('Sleep 120s')
            time.sleep(120)
            self._wait_until_rest_api_available(unit.config.host)
            self.paic_login(unit_name)
            current = self.paic_wait_until_operation_done(
                300, 3, unit_name, 'get_operation_state_of_activating_plan',
                plan_id=plan_id, operation_id=resp['id'])

        if unit.isdu:
            resp = self._smart_call(unit_name, 'activate_plan', plan_id=plan_id)
            logger.info('Sleep 120s')
            time.sleep(120)
            self.paic_login(unit_name)
            current = self.paic_wait_until_operation_done(
                300, 3, unit_name, 'get_activate_plan_operation_status',
                plan_id=plan_id, operation_id=resp['id'])

        if self.__status_failed(current):
            raise Exception(f'Activate plan Failed: {current}')
        logger.info(f'Activate plan done {current}')

    @keyword
    def paic_perform_full_commission(self, unit_name, scf_file):
        logger.info(f'Full commission for {unit_name}, file: {scf_file}')
        if not os.path.exists(scf_file):
            raise Exception(f'SCF file: {scf_file} does not exists.')
        scf_file = os.path.abspath(os.path.expanduser(scf_file))

        self.__remove_existing_plan_file(unit_name)
        plan_id = self.__upload_plan_file(unit_name, scf_file)
        self.__validate_full_plan(unit_name, plan_id)
        self.__activate_full_plan(unit_name, plan_id)

    @with_rest
    @keyword
    def paic_reset_unit(self, unit_name):
        logger.info(f'Reset {unit_name}')
        unit = _get_unit(unit_name)
        if unit.iscu:
            self._smart_call(unit_name, 'reset_cu')
        if unit.isdu:
            self._smart_call(unit_name, 'reset_vdu')

    @with_rest
    @keyword
    def paic_unit_is_onair(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.iscu:
            vcu_status = self._smart_call(unit_name, 'get_cu_state')
            logger.info(f'Current vCU status: {vcu_status["operational_state"]}')
            onair = vcu_status.get("operational_state", '').lower() == 'enabled'
            if not onair:
                raise Exception(f'vCU {unit_name} is not all onair')
        if unit.isdu:
            vdu_status = self._smart_call(unit_name, 'get_vdu_state_data')
            logger.info(f'Current vDU status: {vdu_status["operational_state"]}')
            onair = str(vdu_status.get("operational_state", '')).lower() == 'onair'
            if not onair:
                raise Exception(f'vDU {unit_name} is not onair')

    @with_rest
    @keyword
    def paic_unit_cell_are_onair(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.iscu:
            cell_status = self._smart_call(unit_name, 'get_cells_statuses')
            operation_status = [x['operational_state'] for x in cell_status]
            logger.info(f'Current CU Cell Status: {operation_status}')
            onair = not bool([x for x in operation_status if str(x).lower() not in ['enabled']])
            if not onair:
                raise Exception('vCU cells is not onair')
        if unit.isdu:
            cell_status = self._smart_call(unit_name, 'get_vdu_cells_status')
            operation_status = [x['operational_state'] for x in cell_status]
            logger.info(f'Current DU Cell Status: {operation_status}')
            onair = not bool([x for x in operation_status if str(x).lower() not in ['enabled']])
            if not onair:
                raise Exception('vDU cell is not all onair')

    @keyword
    def paic_wait_until_unit_is_onair(self, unit_name, check_cell=True, timeout=900):
        retry = '{}x'.format(int(timeout/3))
        kw('Wait Until Keyword Succeeds',  retry, '3s', 'paic_unit_is_onair')
        if check_cell:
            kw('Wait Until Keyword Succeeds',  retry, '3s', 'paic_unit_cell_are_onair', unit_name)

    @with_rest
    def __remove_existing_delta_plan(self, unit_name):
        log_console('Remove existing delta plan')
        unit = _get_unit(unit_name)
        if unit.iscu:
            curr_plans = self._smart_call(unit_name, 'get_delta_plan_list')
            for plan in curr_plans:
                self._smart_call(unit_name, 'delete_delta_plan', plan_id=plan['plan_id'])
        if unit.isdu:
            curr_plans = self._smart_call(unit_name, 'get_delta_plan_info_list')
            for plan in curr_plans:
                self._smart_call(unit_name, 'delete_delta_plan_file', plan_id=plan['plan_id'])

    @with_rest
    def __create_delta_plan(self, unit_name, plan_name='paic_delta'):
        unit = _get_unit(unit_name)
        log_console(f'Create Delta plan: {plan_name}')
        if unit.iscu:
            resp = self._smart_call(unit_name, 'generate_delta_plan', plan_name=plan_name)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_action_state_of_generating_delta_plan',
                action_id=action_id)

        if unit.isdu:
            resp = self._smart_call(unit_name, 'generate_delta_plan', f'plan_name={plan_name}')
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_delta_plan_generated_action_status',
                f'action_id={action_id}')

        if self.__status_failed(current):
            raise Exception(f'Create Delta Plan Failed: {current}')
        return plan_id

    @with_rest
    def __get_mo_uuid_of_distname(self, unit_name, plan_id, dist_name):
        unit = _get_unit(unit_name)
        if unit.iscu:
            molist = self._smart_call(unit_name, 'get_delta_plan_tree_diff', plan_id=plan_id).get('created', [])
        if unit.isdu:
            molist = self._smart_call(unit_name, 'get_tree_of_delta_plan', plan_id=plan_id).get('created', [])
        parent_uid = None
        mo = None
        for p in dist_name.split('/'):
            mo = [x for x in molist if x['name'] == p and x['parent_mo_uuid'] == parent_uid]
            if mo:
                parent_uid = mo[0]['mo_uuid']
            else:
                raise Exception('Could not find ')
        if mo:
            return mo[0]['mo_uuid']

    @with_rest
    def __validate_delta_plan(self, unit_name, plan_id, raise_exception=True):
        log_console('Validate Delta Plan ...')
        unit = _get_unit(unit_name)
        if unit.iscu:
            resp = self._smart_call(unit_name, 'validate_delta_plan', plan_id=plan_id)
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_action_state_of_validating_delta_plan',
                plan_id=plan_id, action_id=resp['action_id'])

        if unit.isdu:
            resp = self._smart_call(unit_name, 'validate_delta_plan', delta_plan_id=plan_id)
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_validate_delta_plan_operation_status',
                delta_plan_id=plan_id, action_id=resp['action_id'])

        if self.__status_failed(current):
            if raise_exception:
                raise Exception(f'Paramter valid operation failed: {current}')

        if unit.iscu:
            resp = self._smart_call(unit_name, 'get_latest_validation_result_of_delta_plan',
                                    plan_id=plan_id)
        if unit.isdu:
            resp = self._smart_call(unit_name, 'get_delta_plan_validation_results',
                                    plan_id=plan_id,
                                    validation_id=current['validation_id'])
        return resp

    @with_rest
    def __activate_delta_plan(self, unit_name, plan_id, force_reset=False):
        log_console('Activate Delta Plan ...')
        unit = _get_unit(unit_name)
        current = None
        if unit.iscu:
            resp = self._smart_call(unit_name, 'activate_delta_plan', plan_id=plan_id, force_reset=force_reset)
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_operation_state_of_activating_delta_plan',
                plan_id=plan_id, operation_id=resp['operation_id'])

        if unit.isdu:
            resp = self._smart_call(unit_name, 'activate_delta_plan', delta_plan_id=plan_id, force_reset=force_reset)
            current = self.paic_wait_until_operation_done(
                90, 1, unit_name, 'get_activate_delta_plan_operation_status',
                delta_plan_id=plan_id, operation_id=resp['id'])

        if current and self.__status_failed(current):
            raise Exception(f'Activate Delta Plan Failed: {current}')

    def __generate_pmlist(self, unit_name, plan_id, distname, param_list):
        pmlist = []
        mo_uuid = self.__get_mo_uuid_of_distname(unit_name, plan_id, distname)
        item = [x for x in param_list if x['distname'] == distname]
        for item in [x for x in param_list if x['distname'] == distname]:
            pmlist.append(dict(
                operation_type=item['operation_type'],
                parameter_path=item['parameter_path'],
                value=item['value']))
        return mo_uuid, pmlist

    @with_rest
    def __upload_params(self, unit_name, plan_id, param_list):
        unit = _get_unit(unit_name)
        distnames = list(set([x['distname'] for x in param_list]))
        for distname in distnames:
            if unit.iscu:
                mo_uuid, pmlist = self.__generate_pmlist(unit_name, plan_id, distname, param_list)
                resp = self._smart_call(unit_name, 'update_parameters_of_delta_plan',
                                        plan_id=plan_id, mo_uuid=mo_uuid, parameter_change_list=param_list)
                current = self.paic_wait_until_operation_done(
                    90, 1, unit_name, 'get_action_state_of_updating_parameters_of_delta_plan',
                    plan_id=plan_id, action_id=resp['action_id'])
                if self.__status_failed(current):
                    raise Exception(f'Paramter change failed: {current}')

            if unit.isdu:
                pmlist = {}
                for item in [x for x in param_list if x['distname'] == distname]:
                    pmlist.update({item['parameter_path'].replace('/', ''): item['value']})
                logprint(pmlist)
                resp = self._smart_call(unit_name, 'update_vdu_parameter_of_delta_plan',
                                        plan_id=plan_id, mo_dn=distname, updated_paras_dict=pmlist)
                current = self.paic_wait_until_operation_done(
                    90, 1, unit_name, 'get_update_paras_action_status_of_delta_plan',
                    plan_id=plan_id, action_id=resp['action_id']
                )
                if self.__status_failed(current):
                    raise Exception(f'vDU Upload parameter Failed: {current}')

    @keyword
    def paic_validate_pmchange(self, unit_name, param_list, activate_plan=False):
        '''
            param_list = [
                {
                    "distname": "MRBTS-1/NRBTS-1/NRDRB-1",
                    "operation_type": "replace",
                    "parameter_path": "/sduDiscardIntervalTmr",
                    "value": "200"
                },
                {
                    "distname": "MRBTS-1/NRBTS-1/NRDRB-1",
                    "operation_type": "replace",
                    "parameter_path": "/queuingDelayDiscardEnabled",
                    "value": "False"
                },
                {
                    "distname": "MRBTS-1/NRBTS-1/NRCELL-1",
                    "operation_type": "replace",
                    "parameter_path": "/a1MeashoEnabled",
                    "value": "rsrp"
                }
            ]
        '''
        log_console('Validate pm change')
        param_list = self.__remove_same_params(unit_name, param_list)
        if param_list:
            self.__remove_existing_delta_plan(unit_name)
            plan_id = self.__create_delta_plan(unit_name)
            self.__upload_params(unit_name, plan_id, param_list)
            if activate_plan:
                self.__validate_delta_plan(unit_name, plan_id)
                self.__activate_delta_plan(unit_name, plan_id)
            else:
                return self.__validate_delta_plan(unit_name, plan_id, raise_exception=False)
        else:
            log_console('All parameters are same, no change is needed.')

    @keyword
    def paic_perform_delta_commission(self, unit_name, param_list):
        log_console('Perform Delta commission...')
        return self.paic_validate_pmchange(unit_name, param_list, True)

    @with_rest
    @keyword
    def paic_dump_scf(self, unit_name, scf_file):
        logger.info(f"Dump {unit_name}'s SCF file to {scf_file}")
        unit = _get_unit(unit_name)
        scf_file = os.path.abspath(os.path.expanduser(scf_file))
        if unit.iscu:
            self._smart_call(unit_name, 'get_current_plan_file', path=scf_file)
        if unit.isdu:
            self._smart_call(unit_name, 'get_current_plan_file',
                             local_dir_path=os.path.dirname(scf_file),
                             filename=os.path.basename(scf_file))

    def _open_k8s_connection(self, unit_name):
        self.__load_config()
        unit = _get_unit(unit_name)
        if unit.core_ssh is None:
            logger.info(f'First Login to {unit_name} core:')
            unit.core_ssh = ssh()
            self._bi_call('ssh.connect_to', unit.core_ssh.connect_to,
                          hostname=unit.config.mn_ssh_host,
                          username=unit.config.mn_ssh_username,
                          password=unit.config.mn_ssh_password,
                          alias=unit.alias,
                          )
        return unit

    def _close_k8s_connection(self, unit_name):
        unit = _get_unit(unit_name)
        if self.in_robot:
            kw('ssh.disconnect', f'alias={unit.alias}')
        else:
            if unit.core_ssh:
                unit.core_ssh.disconnect(connection=unit.alias)
                unit.core_ssh = None

    @keyword
    def paic_exec_core_cmd_on_unit(self, unit_name, cmd):
        unit = self._open_k8s_connection(unit_name)
        logger.info(f'Exec on {unit_name}: [{cmd}]')
        if self.in_robot:
            output = kw(f'ssh.execute', cmd, f'connection={unit.alias}')
        else:
            output = unit.core_ssh.execute(cmd, connection=unit.alias)
        logger.debug(f'<===  Output: {output}')
        return output

    def _get_pods_list(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.podlist:
            return unit.podlist
        else:
            po_du_name_list = []
            pod_check_cmd = ("kubectl get pods -n %s | awk '{print $1}'" % unit.config.namespace)
            try:
                rt1 = self.paic_exec_core_cmd_on_unit(unit_name, pod_check_cmd)
                for pod in rt1.split("\n")[1:]:
                    if pod.strip().count(unit.config.namespace):
                        po_du_name_list.append(pod.strip())
            except Exception:
                detail = traceback.format_exc()
                raise Exception(detail)
            finally:
                unit.podlist = po_du_name_list
                return po_du_name_list

    def _get_full_podname(self, unit_name, pod_name):
        podlist = self._get_pods_list(unit_name)
        podlist = [x for x in podlist if pod_name.lower() in x.lower()]
        if podlist:
            return podlist[0]
        else:
            raise Exception(f'Could not find pod that name contains {pod_name}')

    def _get_container_list(self, unitname, pod_name):
        unit = _get_unit(unitname)
        pod_full_name = self._get_full_podname(unitname, pod_name)
        container_check_cmd = ("kubectl describe pods %s -n %s |grep 'Container ID:' -B 1" %
                               (pod_full_name, unit.config.namespace))
        rt1 = self.paic_exec_core_cmd_on_unit(unitname, container_check_cmd)
        container_name_list = [x for x in rt1.splitlines() if f'-{unit.config.namespace}-' in x]
        return container_name_list

    def _capture_sys_log(self, unit_name):
        unit = _get_unit(unit_name)
        namespace = unit.config.namespace
        podname = self._get_full_podname(unit_name, 'logservice')
        ctl_log_name = "ctr-" + namespace + "-logprocessor"
        login_po_cmd = (f"kubectl exec -i -n {namespace} {podname} -c {ctl_log_name} -- ls /var/log/syslog/")
        all_syslog_list = self.paic_exec_core_cmd_on_unit(unit_name, login_po_cmd)
        if all_syslog_list:
            for syslog_name in all_syslog_list.split():
                if 'syslog' in syslog_name:
                    remove_syslog_cmd = (
                        f"kubectl exec -i -n {namespace} {podname} -c {ctl_log_name}"
                        f" -- rm /var/log/syslog/{syslog_name}")
                    self.paic_exec_core_cmd_on_unit(unit_name, remove_syslog_cmd)
                else:
                    continue

    def __kubectl_cmd(self, unit_name, pod_name, contain_name, cmd):
        unit = _get_unit(unit_name)
        return f'kubectl exec -it -n {unit.ns} {pod_name} -c {contain_name} -- sh -c "{cmd}"'

    def _exec_cmd_on_container(self, unit_name, pod_name, contain_name, cmd):
        return self.paic_exec_core_cmd_on_unit(unit_name, self.__kubectl_cmd(unit_name, pod_name, contain_name, cmd))

    def __remove_same_params(self, unit_name, param_list):
        fname = '/tmp/paic_scf.xml'
        self.paic_dump_scf(unit_name, fname)
        ns = {"scfns": "raml21.xsd"}
        from lxml import etree
        tree = etree.parse(fname)
        result = []
        for item in param_list:
            distname = item['distname']
            pname = item['parameter_path'].split('/')[-1]
            mo = tree.xpath(f'//scfns:managedObject[@distName="{distname}"]', namespaces=ns)
            if mo:
                params = mo[0].xpath(f'./scfns:p[@name="{pname}"]', namespaces=ns)
                if params:
                    current_value = params[0].xpath('./text()', namespaces=ns)[0]
                    log_console(f'Current value: {pname} {current_value}')
                    if str(current_value) == str(item['value']):
                        logger.info(f'{distname}--{pname} is same as in device, not need to modify.')
                    else:
                        result.append(item)
                else:
                    raise Exception(f'Could not find {distname} --- {pname}')
            else:
                raise Exception(f'Could not find distname: {distname}')
        return result

    @with_rest
    @keyword
    def paic_get_counter(self, unit_name, counter_dn, counter_id):
        unit = _get_unit(unit_name)
        if unit.iscu:
            measureid = re.findall(r'M(\d+)C', counter_id)[0]
            if self.in_robot:
                result = kw(f'{unit_name}.get_counter', f'measurement_id={measureid}',
                            f'dimension_dist_name={counter_dn}', f'counter_id={counter_id}', unit.connstr)
            else:
                result = unit.object.get_counter(measureid, counter_dn, counter_id, unit.alias)
        if unit.isdu:
            if self.in_robot:
                result = kw(f'{unit_name}.get_counter_values',
                            f'dimension_dn={counter_dn}', f'counter_id={counter_id}', unit.connstr)
            else:
                result = unit.object.get_counter_values(counter_dn, counter_id, unit.alias)
        return result

    @keyword
    def paic_delete_all_counter_files(self, unit_name):
        unit = _get_unit(unit_name)
        podname = unit.pod(unit.pm_module)
        container = unit.container(unit.pm_module)
        return self._exec_cmd_on_container(
            unit_name,
            podname,
            container,
            f'rm -rf {unit.pm_path}/*.xml*')

    @keyword
    def paic_wait_until_new_counter_file_found(self, unit_name):
        """
        Waits until a new counter file is found in the specified unit.

        Args:
            unit_name (str): The name of the unit.

        Returns:
            None
        """
        def _count_pm_file():
            c = self._exec_cmd_on_container(unit_name, podname, container, f'ls -latr {path}').splitlines()[0]
            try:
                return int(c)
            except Exception as E:
                return 0

        unit = _get_unit(unit_name)
        podname = unit.pod(unit.pm_module)
        container = unit.container(unit.pm_module)
        path = f'{unit.pm_path}/*.xml*|wc -l'

        init_file_count = _count_pm_file()
        logger.info(f'Init File Count {init_file_count}')
        for _ in range(180):
            curr_count = _count_pm_file()
            logger.info(f'Current File Count {curr_count}')
            if curr_count > init_file_count:
                break
            else:
                time.sleep(10)

    @keyword
    def paic_wait_until_new_counter_found(self, unit_name, counter_dn, counter_id):
        def _count_timestamps():
            counter = self.paic_get_counter('vcu_0', counter_dn, counter_id)
            logger.debug(f'Counter: {counter}')
            if counter:
                return len(counter['values'])
            else:
                return -1

        unit = _get_unit(unit_name)

        init_file_count = _count_timestamps()
        logger.info(f'Init Count timestamps {init_file_count}')
        for _ in range(180):
            curr_count = _count_timestamps()
            logger.info(f'Current Count timestamps {curr_count}')
            if curr_count > init_file_count:
                break
            else:
                time.sleep(10)

    def __parse_pmfile(self, filename, cared_counters=[]):
        import gzip
        from lxml import etree
        from types import SimpleNamespace
        tree = etree.fromstring(gzip.open(filename, 'rb').read())
        result = []
        for counter in cared_counters:
            for node in tree.xpath(f'//{counter}'):
                item = SimpleNamespace(
                    counter=counter,
                    value=float(node.text),
                    distname=node.xpath('../../MO/DN/text()')[0],
                    timestamp=node.xpath('../../../@startTime')[0],
                    )
                result.append(item)
        return result

    @keyword
    def paic_download_pm_files(self, unit_name, local_dire):
        """
        从Kubernetes pod下载性能管理（PM）文件到本地目录。

        Args:
            unit_name (str): 单元名称。
            local_dire (str): 将下载PM文件的本地目录。

        Returns:
            None
        """

        # 打开与Kubernetes的连接
        self._open_k8s_connection(unit_name)

        # 获取单元对象
        unit = _get_unit(unit_name)

        # 获取PM模块的pod名称和container名称
        podname = unit.pod(unit.pm_module)
        container = unit.container(unit.pm_module)

        # 在单元上执行命令，将PM文件打包并拷贝到/tmp目录
        self.paic_exec_core_cmd_on_unit(
            unit_name,
            f'kubectl exec -n {unit.ns} {podname} -c {container} -- tar -cvf /tmp/pm.tar {unit.pm_path}')
        self.paic_exec_core_cmd_on_unit(
            unit_name,
            f'kubectl cp -n {unit.ns} {podname}:tmp/pm.tar -c {container} /tmp/pm.tar')

        # 如果本地目录不存在，则创建
        if not os.path.exists(local_dire):
            os_obj.run(f'mkdir -p {local_dire}')

        # 从单元的core_ssh对象下载文件到本地目录，并解压缩
        unit.core_ssh.download_file('/tmp/pm.tar', local_dire + '/pm.tar', connection=unit.alias)
        os_obj.run(f'cd {local_dire} && tar -xvf pm.tar --strip-components=5')

        # 删除/tmp目录下的pm.tar文件
        os_obj.run(f'cd {local_dire} && rm -rf pm.tar')

    @keyword
    def paic_get_counter_in_files(self, pm_file, counterid, distname=''):
        """
        Retrieves counter values from PM files.

        Args:
            pm_file (str): The path to the PM file or directory containing PM files.
            counterid (str): The ID(s) of the counter(s) to retrieve values for.
            Multiple IDs can be provided separated by commas.
            distname (str, optional): The distribution name to filter the results. Defaults to an empty string.

        Returns:
            dict: A dictionary containing the counter IDs as keys and a list of corresponding values as values.
        """
        path = pm_file
        result = []
        values = dict()
        cid_list = counterid.split(',')
        if os.path.isdir(path):
            files = [x for x in os.listdir(path)]
            for filename in files:
                result += self.__parse_pmfile(os.path.join(path, filename), cid_list)
        else:
            result += self.__parse_pmfile(path, cid_list)

        if distname and distname.lower() != 'all':
            result = [x for x in result if x.distname == distname]

        for cid in cid_list:
            values[cid] = []
            for item in result:
                if item.counter == cid:
                    values[cid].append(int(item.value))
        return values

    def test(self):
        pass


if __name__ == '__main__':
    logging.basicConfig(format='%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                        datefmt="%Y-%m-%d %H:%M:%S", level=logging.INFO, stream=sys.stdout)
    obj = pkw_aic()
    vcu = 'vcu_0'
    vdu = 'vdu_0'
    # print(obj.tl)
    obj.paic_login(vcu)
    obj.paic_login(vcu)
    # pprint(obj.cu_config)
