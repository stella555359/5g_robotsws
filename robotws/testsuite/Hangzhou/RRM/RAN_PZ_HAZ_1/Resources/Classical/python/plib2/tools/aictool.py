
# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

import logging
import sys
import json
import os
import re
import time
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
from robot.libraries.OperatingSystem import OperatingSystem
from taf.gnb.oam.coam.vdu import vdu
from taf.gnb.oam.coam.cu import cu
from ute_fsmaccess import ute_fsmaccess
from robot.api import logger
from functools import wraps
import traceback

from types import SimpleNamespace

from pprint import pprint, pformat

os_obj = OperatingSystem()
robot_obj = BuiltIn()
kw = robot_obj.run_keyword
pv = robot_obj.get_variable_value
log_console = robot_obj.log_to_console


__units = {
    "vcu_0": SimpleNamespace(object=cu()),
    "vdu_0": SimpleNamespace(object=vdu()),
    "vdu_1": SimpleNamespace(object=vdu()),
}

for unit in __units:
    item = __units[unit]
    item.iscu = 'cu' in unit
    item.isdu = 'du' in unit
    item.alias = 'paic_' + unit
    item.index = int(unit.split('_')[-1])
    item.ssh_conn = None
    item.podlist = []


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
        obj._paic_login(unit_name)
        try:
            r = func(*args, **kwargs)
        finally:
            obj._paic_logout(unit_name)
        return r
    return wrapper


def with_ssh(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        obj, unit_name = args[:2]
        obj._open_k8s_connection(unit_name)
        r = func(*args, **kwargs)
        obj._paic_logout(unit_name)
        return r
    return wrapper


class pkw_aic(object):

    """

    =  基本说明  =

    本库主要提供针对 ``AirPhone`` 的 keyword

    """

    def __init__(self):
        self.vdu_name = 'pet_vdu'
        self.vcu_name = 'pet_vcu'
        self.vdu_object = None
        self.vcu_object = None
        self.cu_config = None
        self.du_configs = []
        self.__load_config()

    @classmethod
    def __status_failed(self, resp):
        # logprint(resp)
        return resp['status'] in ['failure']

    @classmethod
    def __status_succeed(self, resp):
        logprint(resp)
        return resp['status'] in ['success']

    def __load_config(self):
        tlname = os.popen('hostname').read().splitlines()[0].replace('-', '_')
        tl_config_path = os.path.expanduser(f'~/testline_configuration/{tlname}')
        src_file = os.path.join(tl_config_path, '__init__.py')
        dst_file = os.path.join(tl_config_path, 'ta.py')
        if not os.path.exists(dst_file):
            os.system(f'cp {src_file} {dst_file}')
        try:
            import importlib
            sys.path.append(os.path.expanduser(f'~/testline_configuration/{tlname}'))
            tl = importlib.import_module('ta').tl
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
        finally:
            if os.path.exists(dst_file):
                os.remove(dst_file)

    def _paic_login(self, unit_name):
        logger.info(f'Login {unit_name}')
        cu_config = self.cu_config
        du_configs = self.du_configs
        unit = _get_unit(unit_name)
        if unit.iscu:
            host = cu_config.host if cu_config else '192.168.100.129'
            username = cu_config.username if cu_config else 'Nemuadmin'
            password = cu_config.password if cu_config else 'Nemuadmin'
            port = ''
        if unit.isdu:
            du_config = [x for x in du_configs if x.instance_id - 1 == unit.index]
            du_config = du_config[0] if du_config else None
            host = du_config.host if cu_config else '192.168.255.129'
            username = du_config.username if cu_config else 'Nemuadmin'
            password = du_config.password if cu_config else 'Nemuadmin'
            port = ''

        self._paic_logout(unit_name)

        if unit.iscu:
            unit.object.connect_to(
                host=host,
                port=port,
                username=username,
                password=password,
                secure=True,
                alias=unit.alias)
        if unit.isdu:
            unit.object.connect_to(
                host=host,
                port=port,
                username=username,
                password=password,
                secure=True,
                connection_name=unit.alias)

    def _paic_logout(self, unit_name):
        unit = _get_unit(unit_name)
        try:
            unit.object.disconnect(unit.alias)
        except Exception as E:
            pass

    def __upload_plan_file(self, unit_name, scf_file):
        logger.info('')
        unit = _get_unit(unit_name)
        logger.info(f'Upload SCF file: {scf_file}')
        if unit.iscu:
            resp = unit.object.upload_plan_file(scf_file, connection=unit.alias)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = _wait_until_operation_done(
                90, 1, unit.object.get_operation_state_of_uploading_plan,
                action_id, connection=unit.alias)
        if unit.isdu:
            resp = unit.object.upload_plan(scf_file, vdu_connection=unit.alias)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = _wait_until_operation_done(
                90, 1, unit.object.get_upload_plan_operation_status,
                action_id, vdu_connection=unit.alias)
        if self.__status_failed(current):
            raise Exception(f'Upload SCF Failed: {current}')
        logger.info(f'Upload SCF file: {scf_file} done, plan_id: {plan_id}')
        return plan_id

    def __validate_full_plan(self, unit_name, plan_id):
        logger.info('')
        unit = _get_unit(unit_name)
        logger.info('Validate plan...')
        if unit.iscu:
            resp = unit.object.plan_validation(plan_id, connection=unit.alias)
            current = _wait_until_operation_done(
                90, 1, unit.object.get_operation_state_of_validating_plan,
                plan_id=plan_id, operation_id=resp['action_id'], connection=unit.alias)
        if unit.isdu:
            resp = unit.object.validate_plan(plan_id, vdu_connection=unit.alias)
            current = _wait_until_operation_done(
                90, 1, unit.object.get_validate_plan_operation_status,
                plan_id=plan_id, operation_id=resp['action_id'], vdu_connection=unit.alias)
        if self.__status_failed(current):
            raise Exception(f'Validate plan Failed: {current}')
        logger.info(f'Validate plan done. {current}')

    def __activate_full_plan(self, unit_name, plan_id):
        unit = _get_unit(unit_name)
        logger.info('')
        logger.info('Activate plan...')
        if unit.iscu:
            resp = unit.object.plan_activation(plan_id, connection=unit.alias)
            logger.info(resp)
            logger.info('Sleep 90s for Wait activate successful.')
            time.sleep(90)
            current = _wait_until_operation_done(
                300, 3, unit.object.get_operation_state_of_activating_plan,
                plan_id=plan_id, operation_id=resp['id'], connection=unit.alias)
        if unit.isdu:
            resp = unit.object.activate_plan(plan_id, vdu_connection=unit.alias)
            logger.info('Sleep 90s for Wait activate successful.')
            time.sleep(90)
            for _ in range(300):
                try:
                    unit.object.get_activate_plan_operation_status(
                        plan_id=plan_id, operation_id=resp['id'], vdu_connection=unit.alias)
                    break
                except Exception as E:
                    logger.info('vdu is still not available.')
                    time.sleep(3)

            current = _wait_until_operation_done(
                300, 3, unit.object.get_activate_plan_operation_status,
                plan_id=plan_id, operation_id=resp['id'], vdu_connection=unit.alias)

        if self.__status_failed(current):
            raise Exception(f'Activate plan Failed: {current}')
        logger.info(f'Activate plan done {current}')

    def _full_commission(self, unit_name, scf_file):
        try:
            self._paic_login(unit_name)
            plan_id = self.__upload_plan_file(unit_name, scf_file)
            self.__validate_full_plan(unit_name, plan_id)
            self.__activate_full_plan(unit_name, plan_id)
        finally:
            self._paic_logout(unit_name)

    def _perform_full_commission_for_vdu(self, unit_name, scf_file):
        _unit = _get_unit(unit_name)
        vdu_object = _unit.object
        alias = _unit.alias

        # Upload SCF
        logger.info(f'Upload SCF file: {scf_file}')
        resp = vdu_object.upload_plan(scf_file, vdu_connection=alias)
        action_id, plan_id = resp['action_id'], resp['plan_id']
        logger.debug(resp)
        for _ in range(60):
            current = vdu_object.get_upload_plan_operation_status(action_id, vdu_connection=alias)
            if current['status'] == 'success':
                logger.info('Upload SCF Done.')
                break
            else:
                logger.info(f'Wait for Upload SCF done, {current["status"]}')
                time.sleep(1)

        # Valid SCF
        logger.info('Validate plan...')
        resp = vdu_object.validate_plan(plan_id, vdu_connection=alias)
        for _ in range(120):
            current = vdu_object.get_validate_plan_operation_status(
                plan_id=plan_id, operation_id=resp['action_id'], vdu_connection=alias)
            logger.info(current)
            if current['status'].lower() == 'success':
                logger.info('Validate plan done')
                break
            else:
                time.sleep(1)

        # Activate SCF
        logger.info(f'Start to activate plan: {plan_id}')
        resp = vdu_object.activate_plan(plan_id, vdu_connection=alias)
        logger.info(resp)
        logger.info('Sleep 90s for Wait activate successful.')
        time.sleep(90)
        for _ in range(300):
            try:
                vdu_object.get_activate_plan_operation_status(
                    plan_id=plan_id, operation_id=resp['id'], vdu_connection=alias)
                break
            except Exception as E:
                logger.info('vdu is still not available.')
                time.sleep(3)

        for _ in range(300):
            current = vdu_object.get_activate_plan_operation_status(
                plan_id=plan_id, operation_id=resp['id'], vdu_connection=alias)
            logger.info(current)
            if current['status'].lower() == 'success':
                logger.info('Activate plan done')
                break
            else:
                if current['status'].lower() == 'failure':
                    raise Exception(f'Activate plan failed: {current}')
                time.sleep(3)
        logger.info('Activation SCF for vDU Done.')

    def _perform_full_commission_for_vcu(self, unit_name, scf_file):
        _unit = _get_unit(unit_name)
        vcu_object = _unit.object
        alias = _unit.alias

        logger.info(f'Upload SCF file: {scf_file}')
        resp = vcu_object.upload_plan_file(scf_file, connection=alias)
        action_id, plan_id = resp['action_id'], resp['plan_id']
        logger.info(resp)
        for _ in range(60):
            current = vcu_object.get_operation_state_of_uploading_plan(action_id, connection=alias)
            if current['status'] == 'success':
                logger.info('Upload SCF Done.')
                break
            else:
                logger.info(f'Wait for Upload SCF done, {current["status"]}')
                time.sleep(1)

        logger.info('Validate plan...')
        resp = vcu_object.plan_validation(plan_id, connection=alias)

        current = _wait_until_operation_done(
            300, 3, unit.object.get_operation_state_of_validating_plan,
            plan_id=plan_id, operation_id=resp['action_id'], connection=alias)

        if self.__status_failed(current):
            raise Exception(f'Validate Plan Failed: {current}')

        logger.info(f'Start to activate plan: {plan_id}')
        resp = vcu_object.plan_activation(plan_id, connection=alias)
        logger.info(resp)
        logger.info('Sleep 90s for Wait activate successful.')
        time.sleep(90)
        logger.info(resp)

        current = _wait_until_operation_done(
            300, 3, unit.object.get_operation_state_of_activating_plan,
            plan_id=plan_id, operation_id=resp['id'], connection=alias)

        if self.__status_failed(current):
            raise Exception(f'Activate plan failed: {current}')

        logger.info('Activation SCF for vCU Done.')

    @with_rest
    @keyword
    def paic_perform_full_commission(self, unit_name, scf_file):
        logger.info(f'Full commission for {unit_name}, file: {scf_file}')
        if not os.path.exists(scf_file):
            raise Exception(f'SCF file: {scf_file} does not exists.')
        scf_file = os.path.abspath(os.path.expanduser(scf_file))

        plan_id = self.__upload_plan_file(unit_name, scf_file)
        self.__validate_full_plan(unit_name, plan_id)
        self.__activate_full_plan(unit_name, plan_id)

    @with_rest
    @keyword
    def paic_unit_is_onair(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.iscu:
            vcu_status = unit.object.get_cu_state(connection=unit.alias)
            logger.info(f'Current vCU status: {vcu_status["operational_state"]}')
            onair = vcu_status.get("operational_state", '').lower() == 'enabled'
            if not onair:
                raise Exception(f'vCU {unit_name} is not all onair')
        if unit.isdu:
            vdu_status = unit.object.get_vdu_state_data(vdu_connection=unit.alias)
            logger.info(f'Current vDU status: {vdu_status["operational_state"]}')
            onair = str(vdu_status.get("operational_state", '')).lower() == 'onair'
            if not onair:
                raise Exception(f'vDU {unit_name} is not onair')

    @with_rest
    @keyword
    def paic_unit_cell_are_onair(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.iscu:
            cell_status = unit.object.get_cells_statuses(connection=unit.alias)
            operation_status = [x['operational_state'] for x in cell_status]
            logger.info(f'Current CU Cell Status: {operation_status}')
            onair = not bool([x for x in operation_status if str(x).lower() not in ['enabled']])
            if not onair:
                raise Exception('vCU cells is not onair')
        if unit.isdu:
            cell_status = unit.object.get_vdu_cells_status(vdu_connection=unit.alias)
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

    def __remove_existing_delta_plan(self, unit_name):
        logger.info('Remove existing delta plan')
        unit = _get_unit(unit_name)
        if unit.iscu:
            curr_plans = unit.object.get_delta_plan_list(connection=unit.alias)
            for plan in curr_plans:
                unit.object.delete_delta_plan(plan['plan_id'], connection=unit.alias)
        if unit.isdu:
            curr_plans = unit.object.get_delta_plan_info_list(vdu_connection=unit.alias)
            for plan in curr_plans:
                unit.object.delete_delta_plan_file(plan['plan_id'], vdu_connection=unit.alias)

    def __create_delta_plan(self, unit_name, plan_name='paic_delta'):
        unit = _get_unit(unit_name)
        logger.info(f'Create Delta plan: {plan_name}')
        if unit.iscu:
            resp = unit.object.generate_delta_plan(plan_name, connection=unit.alias)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = _wait_until_operation_done(
                90, 1, unit.object.get_action_state_of_generating_delta_plan,
                action_id=action_id, connection=unit.alias)

        if unit.isdu:
            resp = unit.object.generate_delta_plan(plan_name, vdu_connection=unit.alias)
            action_id, plan_id = resp['action_id'], resp['plan_id']
            current = _wait_until_operation_done(
                90, 1, unit.object.get_delta_plan_generated_action_status,
                action_id=action_id, vdu_connection=unit.alias)

        if self.__status_failed(current):
            raise Exception(f'Create Delta Plan Failed: {current}')
        return plan_id

    def __get_mo_uuid_of_distname(self, unit_name, plan_id, dist_name):
        unit = _get_unit(unit_name)
        if unit.iscu:
            molist = unit.object.get_delta_plan_tree_diff(plan_id=plan_id, connection=unit.alias).get('created', [])
        if unit.iscu:
            molist = unit.object.get_tree_of_delta_plan(plan_id=plan_id, vdu_connection=unit.alias).get('created', [])
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

    def __validate_delta_plan(self, unit_name, plan_id, raise_exception=True):
        logger.info('Validate Delta Plan ...')
        unit = _get_unit(unit_name)
        if unit.iscu:
            resp = unit.object.validate_delta_plan(plan_id=plan_id, connection=unit.alias)
            logger.debug(resp)
            current = _wait_until_operation_done(
                90, 1, unit.object.get_action_state_of_validating_delta_plan,
                plan_id, resp['action_id'], connection=unit.alias)

        if unit.isdu:
            resp = unit.object.validate_delta_plan(delta_plan_id=plan_id, vdu_connection=unit.alias)
            logger.info(resp)
            current = _wait_until_operation_done(
                90, 1, unit.object.get_validate_delta_plan_operation_status,
                plan_id, resp['action_id'], vdu_connection=unit.alias)

        if self.__status_failed(current):
            if raise_exception:
                raise Exception(f'Paramter valid operation failed: {current}')

        if unit.iscu:
            resp = unit.object.get_latest_validation_result_of_delta_plan(plan_id, connection=unit.alias)
        if unit.isdu:
            resp = unit.object.get_delta_plan_validation_results(
                plan_id, current['validation_id'], vdu_connection=unit.alias)
        logger.info(f'Validate Result: {resp}')
        return resp

    def __activate_delta_plan(self, unit_name, plan_id, force_reset=False):
        logger.info('Activate Delta Plan ...')
        unit = _get_unit(unit_name)
        if unit.iscu:
            resp = unit.object.activate_delta_plan(plan_id, force_reset, connection=unit.alias)
            current = _wait_until_operation_done(
                90, 1, unit.object.get_operation_state_of_activating_delta_plan,
                plan_id, resp['operation_id'], connection=unit.alias)

        if unit.isdu:
            resp = unit.object.activate_delta_plan(plan_id, force_reset, vdu_connection=unit.alias)
            current = _wait_until_operation_done(
                90, 1, unit.object.get_activate_delta_plan_operation_status,
                plan_id, resp['operation_id'], vdu_connection=unit.alias)

        if self.__status_failed(current):
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

    def __upload_params(self, unit_name, plan_id, param_list):
        unit = _get_unit(unit_name)
        distnames = list(set([x['distname'] for x in param_list]))
        for distname in distnames:
            if unit.iscu:
                mo_uuid, pmlist = self.__generate_pmlist(unit_name, plan_id, distname, param_list)
                resp = unit.object.update_parameters_of_delta_plan(
                    plan_id, mo_uuid, param_list, connection=unit.alias)
                logger.info(resp)
                current = _wait_until_operation_done(
                    90, 1, unit.object.get_action_state_of_updating_parameters_of_delta_plan,
                    plan_id, resp['action_id'], connection=unit.alias)
                if self.__status_failed(current):
                    raise Exception(f'Paramter change failed: {current}')

            if unit.isdu:
                pmlist = {}
                for item in [x for x in param_list if x['distname'] == distname]:
                    pmlist.update({item['parameter_path'].replace('/', ''): item['value']})
                logprint(pmlist)
                resp = unit.object.update_vdu_parameter_of_delta_plan(
                    plan_id, distname, pmlist, vdu_connection=unit.alias)
                logger.info(resp)

                current = _wait_until_operation_done(
                    90, 1, unit.object.get_update_paras_action_status_of_delta_plan,
                    plan_id, action_id=resp['action_id'], vdu_connection=unit.alias)
                if self.__status_failed(current):
                    raise Exception(f'vDU Upload parameter Failed: {current}')

    @with_rest
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
        self.__remove_existing_delta_plan(unit_name)
        plan_id = self.__create_delta_plan(unit_name)
        self.__upload_params(unit_name, plan_id, param_list)
        if activate_plan:
            self.__validate_delta_plan(unit_name, plan_id)
            self.__activate_delta_plan(unit_name, plan_id)
        else:
            return self.__validate_delta_plan(unit_name, plan_id, raise_exception=False)

    @keyword
    def paic_delta_commission(self, unit_name, param_list):
        return self.paic_valid_pmchange(unit_name, param_list, True)

    @with_rest
    @keyword
    def paic_dump_scf(self, unit_name, scf_file):
        unit = _get_unit(unit_name)
        scf_file = os.path.abspath(os.path.expanduser(scf_file))
        if unit.iscu:
            unit.object.get_current_plan_file(scf_file, connection=unit.alias)
        if unit.isdu:
            unit.object.get_current_plan_file(
                os.path.dirname(scf_file), os.path.basename(scf_file), vdu_connection=unit.alias)

    def _open_k8s_connection(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.ssh_conn is None:
            logger.info(f'Login to {unit_name} core:')
            fsm_obj = ute_fsmaccess()
            fsm_obj.setup_enb_fsm_access(
                host=unit.config.mn_ssh_host,
                user=unit.config.mn_ssh_username,
                password=unit.config.mn_ssh_password,
                alias=unit.alias,
                prompt="$", fallback_prompt="$")
            unit.ssh_conn = fsm_obj
        return unit

    def _close_k8s_connection(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.ssh_conn:
            unit.ssh_conn.teardown_enb_fsm_access(alias=unit.alias)
            unit.ssh_conn = None

    def _exec_cmd_on_unit(self, unit_name, cmd):
        logger.info(f'Exec on {unit_name}: [{cmd}]')
        unit = self._open_k8s_connection(unit_name)
        return unit.ssh_conn.execute_command_on_enb(cmd, alias=unit.alias)

    def _get_pods_list(self, unit_name):
        unit = _get_unit(unit_name)
        if unit.podlist:
            return unit.podlist
        else:
            po_du_name_list = []
            pod_check_cmd = ("kubectl get pods -n %s | awk '{print $1}'" % unit.config.namespace)
            try:
                rt1 = self._exec_cmd_on_unit(unit_name, pod_check_cmd)
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
        rt1 = self._exec_cmd_on_unit(unitname, container_check_cmd)
        container_name_list = [x for x in rt1.splitlines() if f'-{unit.config.namespace}-' in x]
        return container_name_list

    def _capture_sys_log(self, unit_name):
        unit = _get_unit(unit_name)
        namespace = unit.config.namespace
        podname = self._get_full_podname(unit_name, 'logservice')
        ctl_log_name = "ctr-" + namespace + "-logprocessor"
        login_po_cmd = (f"kubectl exec -i -n {namespace} {podname} -c {ctl_log_name} -- ls /var/log/syslog/")
        all_syslog_list = self._exec_cmd_on_unit(unit_name, login_po_cmd)
        if all_syslog_list:
            for syslog_name in all_syslog_list.split():
                if 'syslog' in syslog_name:
                    remove_syslog_cmd = (
                        f"kubectl exec -i -n {namespace} {podname} -c {ctl_log_name}"
                        f" -- rm /var/log/syslog/{syslog_name}")
                    self._exec_cmd_on_unit(unit_name, remove_syslog_cmd)
                else:
                    continue

    def __kubectl_cmd(self, unit_name, pod_name, contain_name, cmd):
        unit = _get_unit(unit_name)
        return f'kubectl exec -i -n {unit.ns} {pod_name} -c {contain_name} -- {cmd}'

    def _exec_cmd_on_container(self, unit_name, pod_name, contain_name, cmd):
        unit = _get_unit(unit_name)
        # cmd = self.__kubectl_cmd(unit_name, pod_name, contain_name, cmd)
        # pod_fullanme = self._get_full_podname(unit_name, pod_name)


if __name__ == '__main__':
    logging.basicConfig(format='%(name)s-%(asctime)s [%(levelname)s] %(message)s',
                        datefmt="%Y-%m-%d %H:%M:%S", level=logging.INFO, stream=sys.stdout)
    obj = pkw_aic()
    # obj.paic_dump_scf('vcu_0', 'scf_vcu.xml')
    # obj._open_k8s_connection('vcu_0')
    # obj._close_k8s_connection('vcu_0')
    # obj._exec_cmd_on_unit('vcu_0', 'pwd')
    # obj._exec_cmd_on_unit('vdu_0', 'pwd')

    # pprint(_get_unit('vcu_0').config)
    # podlist = obj._get_container_list('vcu_0', 'logservice')
    # pprint(podlist)
