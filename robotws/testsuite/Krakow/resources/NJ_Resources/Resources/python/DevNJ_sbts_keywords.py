"""
    author: Fuzengz
    contact: fuzeng.zhu@nokia-sbell.com
    feature: support all 4G/5G feature
"""
import os
from moler.util.moler_test import MolerTest
from taf.sbts.oam.coam.admin import admin
from taf.ul.sc.asimgr import AsiMgr
from robot.api import logger
from pprint import pprint
import time
import re
from json import loads, dumps
from datetime import datetime
from dateutil import tz
import threading
import sshtunnel
from taf.ul.sc.util import util
from taf.ul.sc.gnb.airscale import AirScale
from xml.dom.minidom import parse
from taf.internal.sbts.admin.exceptions.exception import AdminApiProcedureFailureException
from functools import reduce


def _compare_status(dict_id_and_status, dict_expected_status):
    dict_check_result = {'check_result': True, 'check_details': {}}
    for id, status in dict_id_and_status.items():
        if status is None:
            dict_check_result['check_result'] = False
            dict_check_result['check_details'][id] = None
            continue
        if not dict_expected_status:
            continue
        for k, expected_value in dict_expected_status.items():
            real_value = status.get(k)
            if k.lower() == 'availabilityStatus'.lower() and not real_value:
                real_value = 'online'
            if real_value.strip().lower().replace(' ', '') != expected_value.strip().lower().replace(' ', ''):
                dict_check_result['check_result'] = False
                if not dict_check_result['check_details'].get(id):
                    dict_check_result['check_details'][id] = {}
                dict_check_result['check_details'][id][k] = {'real': real_value, 'expected': expected_value}

    return dict_check_result


def _moler_test_console(cause, instance_id, mode='info', result=None):
    if result is True:
        info = 'Trigger {} of {}, {}...'.format(cause, instance_id, 'Success')
        MolerTest.info(info)
    elif result is False:
        info = 'Trigger {} of {}, {}...'.format(cause, instance_id, 'Failed')
        MolerTest.error(info)
    else:
        if mode == 'info':
            info = 'Trigger {} of {}....'.format(cause, instance_id)
            MolerTest.info(info)


def _find_key_value_in_dict(dict_info, key, value):
    for keys, values in dict_info.items():
        if str(keys) == str(key) and str(values) == str(value):
            return True
        else:
            if type(values) is dict:
                ret = _find_key_value_in_dict(values, key, value)
                if ret is True:
                    return True
    return False


def _get_bb_status(adm, connection):
    bb_list = []
    try:
        bb_info = adm.get_fbb_info(connection=connection)
        # print bb_info
        if len(bb_info):
            for i in bb_info:
                tmp_dict = {}
                tmp_dict['operationalState'] = re.sub(r'\s+', '', str(i['status']['operationalState'])).lower()
                tmp_dict['availabilityStatus'] = re.sub(r'\s+', '', str(i['status'].get('availabilityStatus',
                                                                                        'online'))).lower()
                tmp_dict['proceduralStatus'] = re.sub(r'\s+', '', str(i['status']['proceduralStatus'])).lower()
                tmp_dict['administrativeState'] = re.sub(r'\s+', '', str(i['status']['administrativeState'])).lower()
                tmp_dict['usageState'] = re.sub(r'\s+', '', str(i['status']['usageState'])).lower()
                tmp_dict['internal_id'] = str(
                    re.search(r'.*MRBTS-.*BBMOD_R-\d+', i['id']['internal'], re.M | re.I).group())
                try:
                    tmp_dict['instance_id'] = int(
                        re.search(r'.*MRBTS-.*BBMOD-(\d+?)', i['id']['configuration'], re.M | re.I).groups()[0])
                    tmp_dict['configuration_id'] = str(
                        re.search(r'.*MRBTS-.*BBMOD-\d+', i['id']['configuration'], re.M | re.I).group())
                except Exception as e:
                    MolerTest.info(str(e))
                    tmp_dict['configuration_id'] = None
                    tmp_dict['instance_id'] = None
                bb_list.append(tmp_dict)
    except Exception as e:
        MolerTest.error(str(e))
    return bb_list


def _format_cablink_extmod(list_info):
    final_list = []
    if list_info:
        for i in list_info:
            status_dict = {}
            for key, value in i.items():
                if not isinstance(value, dict):
                    status_dict[str(key).lower()] = str(value)
                else:
                    for keys, values in value.items():
                        status_dict[str(keys).lower()] = str(values)
            final_list.append(status_dict)
    return final_list


@MolerTest.raise_background_exceptions(check_steps_end=True)
def reset_sbts(oam_ip='192.168.255.129', connection=None, timeout=1200, port=443):
    """
    Reset SBTS
    :param oam_ip:  IP for BTS LMP or mplane
    :return: True or False, True means success, False means failed.
    Examples:
    ...  Example 1: Reset SBTS   oam_ip=
    """
    adm = admin()
    result = False
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip, bts_port=port)
        _moler_test_console('resetting', 'BTS')
        ret = adm.reset_site(timeout=timeout, connection=connection, detailed_output=True)
        MolerTest.info(ret)
        if ret:
            if ret['errorCode'] == 0 and str(ret['requestStatus']) == 'completed':
                result = True
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    _moler_test_console('resetting', 'BTS', result=result)
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def reset_sbts_via_virtual_machine_lmp(vm_ip, vm_user, vm_password,
                                       vm_ssh_port=22, lmp='192.168.255.129', https_port=443):
    """
    Reset SBTS Via Virtural Machine Lmp
    :param vm_ip:  IP for BTS virtual machine which connected with BTS LMP
    :param vm_user: username of virtual machine.
    :param vm_password: password of virtual machine.
    :param vm_ssh_port: the port of virtual machine.
    :return: True or False, True means success, False means failed.
    Examples:
    ...  Example 1: Reset SBTS Via Virtural Machine Lmp   vm_ip=    vm_user=     vm_password=
    """
    try:
        with sshtunnel.open_tunnel(
                ssh_address_or_host=(vm_ip, int(vm_ssh_port)),
                remote_bind_address=(lmp, https_port),
                ssh_username=vm_user,
                ssh_password=vm_password,
                block_on_close=False,
        ) as tunnel1:
            _moler_test_console('connecting', 'BTS')
            reset_sbts(oam_ip='127.0.0.1', connection=None, timeout=1200, port=tunnel1.local_bind_port)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_cablink_status(cablink_ids='all', expect_status=None, oam_ip='192.168.255.129', connection=None,
                              timeout=10):
    """
    Check SBTS Cablink Status
    Restriction: this keyword is NOT applicable if gNB is in un-commissioned state" in the documentation of keywords
    (Refer to https://confluence.ext.net.nokia.com/display/NewMobility/Drop-10 for background)
    ...  Description: Pass parameters ext_rmod ids and dictionary of expected status, return a bool result
    ...  Example:
    ...  before use this keyword, please define the dict as  ${dict_check_status}    Create Dictionary
    ...  availabilityStatus=Online     operationalState=enabled
    ...  Check SBTS Cablink Status   2    ${dict_check_status}
    ...  Check SBTS Cablink Status  ALL    ${dict_check_status}
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]  ${cablink_ids}  &{expect_status}
    """
    if str(cablink_ids).lower() != 'all':
        if type(cablink_ids) is str or unicode or int:
            cablink_ids_list = re.compile(r'\d+').findall(str(cablink_ids))
        elif type(cablink_ids) is list:
            cablink_ids_list = re.compile(r'\d+').findall(' '.join(cablink_ids))
    adm = admin()
    res_list = []

    def _cablink_status_compare_(info, id=None):
        check_list = []
        i = info
        partten = r'/MRBTS-\d+.*MRBTS_A-\d+/EQM_A-\d+/HWTOP_A-\d+/CABLINK_A-\d+'
        if id:
            partten = r'/MRBTS-\d+.*MRBTS_A-\d+/EQM_A-\d+/HWTOP_A-\d+/CABLINK_A-{}'.format(id)
        if re.search(partten, i['configdn'], re.I | re.M):
            for k, v in expect_status.items():
                value = str(i.get(str(k).lower())).lower().replace(' ', '')
                if not value or value == 'none':
                    value = 'online'
                if value != str(v).lower():
                    check_list.append({'real_value': value,
                                       'expected_value': str(v).lower(),
                                       'distname': i['configdn']})

        if check_list:
            results = {'check_info': check_list}
        else:
            results = {'check_info': None}
        return results

    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        ret = adm.get_managed_objects("CABLINK_R", timeout, connection=connection)
        ret = _format_cablink_extmod(ret)
        if cablink_ids != 'all':
            for x in cablink_ids_list:
                for i in ret:
                    results = _cablink_status_compare_(i, x)
                res_list.append(results)
        else:
            for i in ret:
                results = _cablink_status_compare_(i)
                res_list.append(results)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    if res_list:
        for result in res_list:
            if result['check_info'] is not None:
                MolerTest.error(res_list)
                break
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_external_smod_status(ext_rmod_ids='all', oam_ip='192.168.255.129', expect_status=None, connection=None,
                                    timeout=10):
    """
    Check SBTS External SMOD Status
    Restriction: this keyword is NOT applicable if gNB is in un-commissioned state" in the documentation of keywords
    (Refer to https://confluence.ext.net.nokia.com/display/NewMobility/Drop-10 for background)
    ...  Description: Pass parameters ext_rmod ids and dictionary of expected status, return a bool result
    ...  Example:
    ...  before use this keyword, please define the dict as  ${dict_check_status}    Create Dictionary
    ...  availabilityStatus=Online     operationalState=enabled
    ...  Check SBTS External SMOD Status   2    ${dict_check_status}
    ...  Check SBTS External SMOD Status   ALL    ${dict_check_status}
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]  ${ext_rmod_ids}  &{expect_status}
    """
    if str(ext_rmod_ids).lower() != 'all':
        if type(ext_rmod_ids) is str or unicode or int:
            ext_rmod_ids_list = re.compile(r'\d+').findall(str(ext_rmod_ids))
        elif type(ext_rmod_ids) is list:
            ext_rmod_ids_list = re.compile(r'\d+').findall(' '.join(ext_rmod_ids))
    adm = admin()
    ext_details = []
    res_list = []
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        ret = adm.get_managed_objects("SMOD_EXT_R", timeout, connection=connection)
        smod_r = _format_cablink_extmod(ret)
        res = adm.get_managed_objects("SMOD_EXT_L", timeout, connection=connection)
        smod_l = _format_cablink_extmod(res)
        MolerTest.info(smod_r)
        MolerTest.info(smod_l)
        if str(ext_rmod_ids).lower() != 'all':
            for i in ext_rmod_ids_list:
                for x in smod_r:
                    for key, value in x.items():
                        if re.search(r'/MRBTS-\d+.*/MRBTS_A-\d+/EQM_A-\d+/SMOD_EXT_A-{}'.format(i), value,
                                     re.I | re.M):
                            ext_details.append(x)
        else:
            for x in smod_r:
                for key, value in x.items():
                    if re.search(r'/MRBTS-\d+.*/MRBTS_A-\d+/EQM_A-\d+/SMOD_EXT_A-\d+', value, re.I | re.M):
                        ext_details.append(x)
        if not ext_details:
            MolerTest.error('No any EXT SMOD found ...')
        MolerTest.info(ext_details)
        for y in ext_details:
            for z in smod_l:
                if z['serialnumber'] == y['serialnumber']:
                    check_list = []
                    for k, v in expect_status.items():
                        if str(eval(z['stateinfo']).get(k, 'online')).lower().replace(' ', '') != str(v).lower():
                            check_list.append({'real_value': str(eval(z['stateinfo']).get(k, 'online')).lower().
                                              replace(' ', ''), 'expected_value': str(v).lower(),
                                               'distname': y['configdn']})
                    if check_list:
                        results = {'check_info': check_list}
                    else:
                        results = {'check_info': None}
            res_list.append(results)
            MolerTest.info(res_list)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    if res_list:
        for result in res_list:
            if result['check_info'] is not None:
                MolerTest.error(res_list)
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def download_sbts_commissioning(oam_ip='192.168.255.129', local_dir_path='/tmp/', connection=None, export_type=None,
                                parameters_save_variant=None, file_name=None, timeout=800):
    """
    Download SBTS Commissioning
    :param oam_ip: OAM IP for ssh to nodeb
    :param local_dir_path: default /tmp/ or defined by input
    :param file_name: default scf_unixtime.xml or defined by input
    :param connection: the connection alias if using an existing OAM connection
    :param export_type: one of configuration, configurationAndRuntimeObjects, runtimeObjects.
                                None means default Admin API behavior.
    :param parameters_save_variant: one of actualValues, plannedValues. None means default Admin API behavior.
    :return: file full path
    Examples:
    ...  Example 1: Download SBTS Commissioning or Download SBTS Commissioning   oam_ip=
    """

    if file_name is None:
        file_name = 'scf_{}.xml'.format(int(time.mktime(datetime.now().timetuple())))
    adm = admin()
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        ret = adm.get_current_scf_file(local_dir_path=local_dir_path, file_name=file_name, timeout=timeout,
                                       connection=connection, export_type=export_type,
                                       parameters_save_variant=parameters_save_variant)
        MolerTest.info(ret)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    MolerTest.steps_end()
    return ret


@MolerTest.raise_background_exceptions(check_steps_end=True)
def reset_sbts_configuration(oam_ip='192.168.255.129', connection=None, timeout=800):
    """
    Reset SBTS Configuration
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: True or False, True means operate success, False means Failed~
    Examples:
    ...  Example 1: Reset SBTS Configuration or Reset SBTS Configuration    oam_ip=
    """
    adm = admin()
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        ret = adm.reset_configuration(remove_operator_certificates=True, remove_user_account_credentials=True,
                                      timeout=timeout, detailed_output=True, connection=connection)
        MolerTest.info(ret)
        if ret['errorCode'] == 0 and str(ret['requestStatus']).lower() == 'completed':
            pass
        else:
            MolerTest.error('Wrong code or status replies from ADMIN API...')
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def get_sbts_parameter_value_from_scf(oam_ip='192.168.255.129', parameter=None, connection=None):
    """
    Get Sbts Sarameter Value From Scf
    :param oam_ip: OAM IP for ssh to nodeb
    :param parameter: parameter Name
    :return: a list of results
    Examples:
    ...  Example 1: Get Sbts Sarameter Value From Scf    parameter=appAdmActivated
    ...             result is [u'false']
    """
    MolerTest.info('If want to query {}, please confirm this parameter is unique existing (VS others) in SCF file'.
                   format(parameter))
    adm = admin()
    res = None
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        ret = adm.get_scf(connection=connection)
        MolerTest.info('Begin query {} ...'.format(parameter))
        pattern = r'.*{}.*>(\w+?)<.*'.format(parameter)
        res = re.compile(pattern).findall(ret)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    MolerTest.steps_end()
    return res


def enable_sbts_actasi_flag(oam_ip='192.168.255.129'):
    """
    Enable SBTS ActASI Flag
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: True or False, True means operate success, False means Failed~
    Examples:
    ...  Example 1: Enable SBTS ActASI Flag or Enable SBTS ActASI Flag    oam_ip=
    """
    return perform_actasi_operation(oam_ip=oam_ip, connection=None, method='enable')


def disable_sbts_actasi_flag(oam_ip='192.168.255.129'):
    """
    Disable SBTS ActASI Flag
    :param oam_ip: OAM IP for ssh to nodeb
    :return: True or False, True means operate success, False means Failed~
    Examples:
    ...  Example 1: Disable SBTS ActASI Flag or Enable SBTS ActASI Flag    oam_ip=
    """
    return perform_actasi_operation(oam_ip=oam_ip, connection=None, method='disable')


@MolerTest.raise_background_exceptions(check_steps_end=True)
def perform_actasi_operation(oam_ip='192.168.255.129', method='enable', connection=None):
    adm = admin()
    if method.lower() == 'enable':
        target = 'true'
    elif method.lower() == 'disable':
        target = 'false'
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        ret = adm.get_scf()
        value = re.search(r'.*actasi">(\D+?)<.*', ret, re.I | re.M).groups()[0]
        dist_name = re.search(r'(MRBTS-\d+/MNL-\d+/MNLENT-\d+/FEATCADM-\d+?)', ret, re.I | re.M).groups()[0]
        MolerTest.info(dist_name)
        if value != target:
            res = adm.perform_parameter_recommissioning(dist_name=dist_name,
                                                        parameter='actAsi', operation='update', value=target,
                                                        skip_parameter_relation_errors=False, should_activate=True,
                                                        timeout=300, connection=None)

    except Exception as e:
        MolerTest.error(str(e))
    finally:
        try:
            final_status = re.search(r'.*actasi">(\D+?)<.*', adm.get_scf(), re.I | re.M).groups()[0]
            if final_status == target:
                result = True
                MolerTest.info('actAsi setting success')
            else:
                result = False
                MolerTest.error('actAsi setting failed')
        except Exception as e:
            result = False
            MolerTest.error(str(e))
        adm.teardown_admin()
        MolerTest.steps_end()
    return result


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_bbmod_status(bbmod_id='all', dict_check_status={}, oam_ip='192.168.255.129', port=443, connection=None):
    """
    Check SBTS BBMOD Status
    Restriction:
    1. This keyword is NOT applicable if gNB is in un-commissioned state" in the documentation of keywords
    (Refer to https://confluence.ext.net.nokia.com/display/NewMobility/Drop-10 for background)
    2. This keyword is NOT application to SBTS with ASOE
    ...  Description: Pass parameters BBMOD ids and dictionary of expected status, return a bool result
    ...  Example:
    ...  before use this keyword, please define the dict as  ${dict_check_status}    Create Dictionary
    ...  ... usageState=Active     administrativeState=Unlocked
    ...  Check SBTS BBMOD Status  2    ${dict_check_status}
    ...  Check SBTS BBMOD Status  ALL    ${dict_check_status}
    ...  Restriction: this keyword is not applicable if gNB is in un-commissioned state
    [Arguments]  ${bbmod_id}  &{dict_expected_status}
    """
    if bbmod_id.lower() != 'all':
        if type(bbmod_id) is str or unicode:
            str_bbmods_list = re.compile(r'\d+').findall(bbmod_id)
        elif type(bbmod_id) is list:
            str_bbmods_list = re.compile(r'\d+').findall(' '.join(bbmod_id))
    adm = admin()
    check_result = True
    dict_result_ = {}
    diff_list = []
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip, bts_port=port)
        try:
            bb_list = _get_bb_status(adm, connection=connection)
            MolerTest.info(bb_list)
        except Exception as e:
            MolerTest.error('Get BB info Failed as: ', str(e))
        if bb_list:
            for i in bb_list:
                dict_result = {}
                if bbmod_id.lower() == 'all':
                    for key, value in dict_check_status.items():
                        if i[key].lower() != value.lower():
                            dict_result[key] = {'real_value': i[key], 'expected_val': str(value)}
                            check_result = False
                else:
                    if str_bbmods_list:
                        if str(i['instance_id']) in str_bbmods_list:
                            for key, value in dict_check_status.items():
                                if i[key].lower() != value.lower():
                                    dict_result[key] = {'real_value': i[key], 'expected_val': str(value)}
                                    check_result = False
                if dict_result:
                    dict_result_['BBMOD_{}'.format(i['instance_id'])] = dict_result
            if dict_result_:
                diff_list.append(dict_result_)
        else:
            MolerTest.error("No Any BB modules detected!!!")
            return {'check_result': False, 'check_info': 'No BB Module Detected...'}
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
        if diff_list:
            MolerTest.error(diff_list)
        MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def operate_BB(str_bbmods='all', oam_ip="192.168.255.129", method='Locked', connection=None, timeout=300):
    if str_bbmods.lower() != 'all':
        if type(str_bbmods) is str or unicode:
            str_bbmods_list = re.compile(r'\d+').findall(str_bbmods)
        elif type(str_bbmods) is list:
            str_bbmods_list = re.compile(r'\d+').findall(' '.join(str_bbmods))
    adm = admin()
    if method.lower() == 'locked' or method.lower() == 'lock' or method.lower() == 'block' or \
            method.lower() == 'blocked':
        method = 'Locked'
        current = 'unlocked'
    elif method.lower() == 'unlocked' or method.lower() == 'unlock' or method.lower() == 'unblock' or \
            method.lower() == 'unblocked':
        method = 'Unlocked'
        current = 'locked'

    def _operate_bb_(method, dict_info, timeout=300, connection=None):
        result = False
        try:
            if method == 'Unlocked' or method == 'Locked':
                key = 'result'
                value = 'Success'
                if dict_info['configuration_id']:
                    if dict_info['administrativeState'].lower() == current:
                        ret = adm.perform_parameter_recommissioning(dist_name=dict_info['configuration_id'],
                                                                    parameter='administrativeState',
                                                                    operation='update',
                                                                    value=method,
                                                                    skip_parameter_relation_errors=True,
                                                                    connection=connection)
                    else:
                        MolerTest.info('The BBMOD instance_{} is {}, this is not a expect value, skipped...'.format(
                            dict_info['instance_id'], method))
                        return True
                else:
                    MolerTest.info('The BBMOD instance_{} is not configured, {} operation skipped...'.format(
                        dict_info['instance_id'], method))
                    return True
            elif method == 'reset':
                key = 'status'
                value = 'Succeeded'
                if dict_info['configuration_id']:
                    if dict_info['operationalState'].lower() == 'enabled':
                        ret = adm.reset_unit(dist_name=dict_info['configuration_id'],
                                             reset_type='Warm', timeout=timeout, connection=connection)
                    else:
                        MolerTest.info('The BBMOD instance_{} is not enabled, {} operation skipped...'.format(
                            dict_info['instance_id'], method))
                        return True

            if ret:
                if type(ret) is dict:
                    result = _find_key_value_in_dict(ret, key, value)
                    if result is True:
                        return True
                elif type(ret) is list:
                    for x in ret:
                        result = _find_key_value_in_dict(x, key, value)
                        if result is True:
                            return True

        except Exception as e:
            MolerTest.error(str(e))
            result = False
        finally:
            _moler_test_console('{} BBMODs'.format(method), 'instance_{}'.format(
                dict_info['instance_id']), mode='info')
        return result

    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        try:
            bb_list = _get_bb_status(adm, connection=connection)
            MolerTest.info(bb_list)
        except Exception as e:
            MolerTest.error('Get BB info Failed as: ', str(e))
        if bb_list:
            for i in bb_list:
                if i['instance_id']:
                    key_name = 'instance_{}'.format(i['instance_id'])
                    if str_bbmods.lower() != 'all':
                        if str(i['instance_id']) in str_bbmods_list:
                            _moler_test_console('{} BBMODs'.format(method), key_name, mode='info')
                            ret = _operate_bb_(method, i, timeout=timeout, connection=connection)
                            _moler_test_console('{} BBMODs'.format(method), key_name, mode='info', result=ret)
                    elif str_bbmods.lower() == 'all':
                        _moler_test_console('{} BBMODs'.format(method), key_name, mode='info')
                        ret = _operate_bb_(method, i, timeout=timeout, connection=connection)
                        _moler_test_console('{} BBMODs'.format(method), key_name, mode='info', result=ret)
        else:
            MolerTest.error("No Any BB modules detected!!!")
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        MolerTest.info('{} BBMODs Done!!!'.format(method))
        if not connection:
            adm.teardown_admin()
    MolerTest.steps_end()


def lock_sbts_bbmod(str_bbmods='all', oam_ip="192.168.255.129", timeout=300, connection=None):
    """
    keyword Lock_SBTS_BBMOD
    operate BB Modules
    Restriction:
    1. This keyword is NOT applicable if gNB is in un-commissioned state" in the documentation of keywords
    (Refer to https://confluence.ext.net.nokia.com/display/NewMobility/Drop-10 for background)
    2. This keyword is NOT application to SBTS with ASOE

    :param str_bbmods: str of BBMODs IDs and splitted by ' ', if it is null, all of BB will reset
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: None
    Examples:
    ...  Example 1: lock 1 BBMOD with id 2.
    ...    Lock SBTS BBMOD  2
    ...  Example 2: lock 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Lock SBTS BBMOD  1 2
    ...  Example 3: Reset all BBMODs
    ...    lock BBMODs
    """
    operate_BB(str_bbmods=str_bbmods, oam_ip=oam_ip, method='Locked', timeout=timeout, connection=connection)


def unlock_sbts_bbmod(str_bbmods='all', oam_ip="192.168.255.129", timeout=300, connection=None):
    """
    keyword Unlock_SBTS_BBMOD
    operate BB Modules
    Restriction:
    1. This keyword is NOT applicable if gNB is in un-commissioned state" in the documentation of keywords
    (Refer to https://confluence.ext.net.nokia.com/display/NewMobility/Drop-10 for background)
    2. This keyword is NOT application to SBTS with ASOE
    :param str_bbmods: str of BBMODs IDs and splitted by ' ', if it is null, all of BB will reset
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: None
    Examples:
    ...  Example 1: unlock 1 BBMOD with id 2.
    ...    Unlock SBTS BBMOD  2
    ...  Example 2: unlock 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Unlock SBTS BBMOD  1 2
    ...  Example 3: unlock all BBMODs
    ...    Unlock SBTS BBMOD
    """
    operate_BB(str_bbmods=str_bbmods, oam_ip=oam_ip, method='Unlocked', timeout=timeout, connection=connection)


def reset_sbts_bbmod(str_bbmods='all', oam_ip="192.168.255.129", timeout=300, connection=None):
    """
    keyword Reset_SBTS_BBMOD
    operate BB Modules
    Restriction:
    1. This keyword is NOT applicable if gNB is in un-commissioned state" in the documentation of keywords
    (Refer to https://confluence.ext.net.nokia.com/display/NewMobility/Drop-10 for background)
    2. This keyword is NOT application to SBTS with ASOE

    :param str_bbmods: str of BBMODs IDs and splitted by ' ', if it is null, all of BB will reset
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: reset actions, True or False, True means success, False means failed in certain steps
    Examples:
    ...  Example 1: Reset 1 BBMOD with id 2.
    ...    Reset SBTS BBMOD  2
    ...  Example 2: Reset 2 BBMODs with id 1 and 2, notify parameter 1 and 2 separated by single space.
    ...    Reset SBTS BBMOD  1 2
    ...  Example 3: Reset all BBMODs
    ...    Reset SBTS BBMOD
    """
    operate_BB(str_bbmods=str_bbmods, oam_ip=oam_ip, method='reset', timeout=timeout, connection=connection)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asirmod_status(asirmod_list=[], expected_status_dict={}, oam_ip="192.168.255.129", port=443, connection=None):
    """
    keyword check_asirmod_status
    Get asirmods' status and check if status values are expected
    :param asirmod_list: list of asirmod IDs, check all asirmods if list is empty
    :param expected_status_dict: dictionary of status/value
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: Dictionry of Check Result

    Examples:
    Example 1: Test check_asirmod_status, all asirmods
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_asirmod_status | expected_status_dict=${expected_status} |
    Example 2: Test check_asirmod_status, asirmod 1 and 2, specified OAM IP
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_asirmod_status | asirmod_list=1 2 | expected_status_dict=${expected_status} |
    |...   oam_ip=192.168.255.129 |
    Example 3: Test check_asirmod_status, asirmods 1 and 2, using existed connection
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_asirmod_status | asirmod_list=1 2 | expected_status_dict=${expected_status} | connection=abc |

    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    asirmod_list = asirmod_list if isinstance(asirmod_list, list) else str(asirmod_list).split()
    dict_asirmod_status = {}
    for id in asirmod_list:
        dict_asirmod_status[str(id)] = None
    try:
        bts_info = adm.get_bts_info(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()
    raw_asirmod_list = bts_info['radioModules']['asirmod']
    for asirmod in raw_asirmod_list:
        id = asirmod['id']['configuration'].split('-')[-1]
        if not asirmod_list or str(id) in [str(asir) for asir in asirmod_list]:
            dict_asirmod_status[id] = asirmod['status']
    logger.info("dict_status:{}".format(dict_asirmod_status), also_console=True)
    compare_res = _compare_status(dict_asirmod_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_cell_status(cell_list=None, bbmod_id_list=None, expected_status_dict={}, oam_ip="192.168.255.129",
                           port=443,
                           connection=None):
    """
    keyword check_sbts_cell_status
    Get cells' status and check if status values are expected
    :param cell_list: a flexible condition combination, it can support type of string, list and dictionary
    :param bbmod_id_list: BBMOD ID list. If NOT None, means to check the status of cells created on this BBMOD. It can
                     be a string separated by a space, or a list structure.
                     This parameter is mutually exclusive to param cell_list.
                     ***RESTRICTION***:
                     1) this parameter is applicable to gNB ONLY.
                     2) this parameter is NOT applicable to SBTS with ASOE
    :param expected_status_dict: dictionary of status/value
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: Dictionry of Check Result

    Examples:
    Example 1: Test check_sbts_cell_status, all cells
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_sbts_cell_status | expected_status_dict=${expected_status} |
    Example 2: Test check_sbts_cell_status, cell 1 and 2, specified OAM IP
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_sbts_cell_status | cell_list=1 2 | expected_status_dict=${expected_status} |
    |...   oam_ip=192.168.255.129 |
    Example 3: Test check_sbts_cell_status, cell 1 and 2, using existed connection
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_sbts_cell_status | cell_list=1 2 | expected_status_dict=${expected_status} | connection=abc |
    Example 4: Check status of cells created on gNB BBMOD-1
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_sbts_cell_status | bbmod_id_list=1 | expected_status_dict=${expected_status} |
    Example 5: Check status of cells created on gNB BBMOD-1 and BBMOD-2
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_sbts_cell_status | bbmod_id_list=1 2 | expected_status_dict=${expected_status} |
    Example 6: Test check_sbts_cell_status, NR cell 1, specified OAM IP
    | ${cell_list} | Create Dictionary | nr=1 |
    | ${expected_status} | Create Dictionary | administrativeState=unlocked | operationalState=disabled |
    | check_sbts_cell_status | cell_list=${cell_list} | expected_status_dict=${expected_status} |
    |...   oam_ip=192.168.255.129 |
    Example 7: Test check_sbts_cell_status, NR cell and LTE cell, specified OAM IP
    | ${nr_cell_id} | Create List | 1  2 |
    | ${lte_cell_id} | Create List | 1  2 |
    | ${cell_list} | Create Dictionary | nr=${nr_cell_id} | lte=${lte_cell_id} |
    | check_sbts_cell_status | cell_list=${cell_list} | expected_status_dict=${expected_status} |
    |...   oam_ip=192.168.255.129 |
    """

    if not cell_list:
        cell_list = []

    if isinstance(cell_list, str):
        cell_list = cell_list.split()

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    dict_cell_status = {}
    try:
        if bbmod_id_list:
            cell_list = []
            bbmod_ids = bbmod_id_list if isinstance(bbmod_id_list, list) else str(bbmod_id_list).split()
            for nrcell in adm.get_managed_objects(class_name="NRCELL_R", timeout=10, connection=connection):
                for bb in nrcell['parameters']['modDNList']:
                    if bb.split('-')[-1] in bbmod_ids:
                        cid = adm.get_cell_specific_info(cell_id=nrcell['distName'], connection=connection)[
                            'globalCellId']
                        if str(cid) not in cell_list:
                            cell_list.append(str(cid))

        if isinstance(cell_list, list):
            for cell_type in ["lte", "wcdma", "gsm", "nr"]:
                for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection):
                    if not cell_list or str(cell_info['globalCellId']) in [str(cell) for cell in cell_list]:
                        dict_cell_status[str(cell_info['id']['configuration'])] = cell_info['status']
        else:
            for k_rat, v_id in cell_list.items():
                for cell_info in adm.get_cells_info(cell_type=k_rat.lower(), connection=connection):
                    if isinstance(v_id, list):
                        if str(cell_info['globalCellId']) in [str(cell) for cell in v_id]:
                            dict_cell_status[str(cell_info['id']['configuration'])] = cell_info['status']
                    else:
                        if str(v_id) == str(cell_info['globalCellId']):
                            dict_cell_status[str(cell_info['id']['configuration'])] = cell_info['status']

    finally:
        if not connection:
            adm.teardown_admin()
    pprint(dict_cell_status)
    if not dict_cell_status:
        MolerTest.error("Get cell status result: {}".format(dict_cell_status))

    compare_res = _compare_status(dict_cell_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()


def _verify_faults(all_fault_id_list, forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list):
    result_dict = {'all_fault_id_list': all_fault_id_list}
    all_fault_id_set = set(all_fault_id_list)
    prefixes = ['forbidden', 'allowed', 'required']
    result_dict['check_result'] = True

    if allowed_fault_id_list:
        allowed_fault_id_list = (allowed_fault_id_list if isinstance(allowed_fault_id_list, list)
                                 else str(allowed_fault_id_list).split()) + \
                                (required_fault_id_list if isinstance(required_fault_id_list, list)
                                 else str(required_fault_id_list).split())

    for i, v in enumerate([forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list]):
        if v is not None:
            v = v if isinstance(v, list) else str(v).split()
            set_v = set(v)
            if prefixes[i] == 'forbidden':
                result_dict[prefixes[i] + '_failures'] = list(all_fault_id_set.intersection(set_v))
            elif prefixes[i] == 'allowed':
                result_dict[prefixes[i] + '_failures'] = list(all_fault_id_set - set_v)
            elif prefixes[i] == 'required':
                result_dict[prefixes[i] + '_failures'] = list(set_v - all_fault_id_set)

            if result_dict[prefixes[i] + '_failures']:
                result_dict['check_result'] = False
    return result_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_active_alarm(forbidden_fault_id_list=None, allowed_fault_id_list=None, required_fault_id_list=None,
                            oam_ip="192.168.255.129", connection=None):
    """
    keyword check_sbts_active_alarm
    Get SBTS' active alarms and check if the alarms match given 3 conditions, forbidden/allowed/required,
    If the condition fault ID list is not specified or None, the keyword will skip the check
    By default, parameter is list, but also support str that elements are separated by a space.
    Please refer to Examples
    :param forbidden_fault_id_list: list of fault IDs that should not appear
    :param allowed_fault_id_list: list of fault IDs that are allowed to appear
    :param required_fault_id_list: list of fault IDs that must appear
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: Dictionry of Check Result

    Examples:
    Example 1: Test check_sbts_alarm, set allowed_fault_id_list to ${NULL}, that means all faults allowed
    | check_sbts_alarm | allowed_fault_id_list=${Null} |
    or
    | check_sbts_alarm  |

    Example 2: Test check_sbts_alarm, set allowed_fault_id_list to empty string or list, that means no faults allowed
    | check_sbts_alarm  allowed_fault_id_list='' |

    Example 3: Test check_sbts_alarm '61649', '77777' forbidden, '7100', '7300', '4479' allowed, , '61524' required
    | check_sbts_alarm | forbidden_fault_id_list=61649 77777 | allowed_fault_id_list=7100 7300 4479 |
    | ...   required_fault_id_list=61524 |

    Example 4: Test check_sbts_alarm, faults '1234', '1235' forbidden, with oam_ip
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | check_sbts_alarm | forbidden_fault_id_list=1234 1235 | connection=abc |
    | teardown_admin_connection | connection=abc |

    Example 5: Test check_sbts_alarm, faults '1234', '1235' forbidden, with an existed connection
    | check_sbts_alarm | forbidden_fault_id_list=1234 1235 | oam_ip=192.168.255.129 |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        all_fault_id_list = [str(alarm['faultId']) for alarm in adm.get_active_alarms(connection=connection)]
    finally:
        if not connection:
            adm.teardown_admin()

    result_dict = _verify_faults(all_fault_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                 required_fault_id_list)
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


def get_sbts_active_alarm(severity=None, timeout=10, oam_ip="192.168.255.129", connection=None):
    """
    keyword get_sbts_active_alarm
    Get SBTS' active alarms
    Please refer to Examples

    :param severity: Alarm severity (critical, major, minor or warning)
    :param timeout: Timeout for the operation
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: List of active alarms

    Examples:
    | ${alarm_list} | get_sbts_active_alarm |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        alarm_list = adm.get_active_alarms(severity=severity, timeout=timeout, connection=connection)
        logger.info("All active alarms retrieved from SBTS are: {}".format(alarm_list))
        return alarm_list
    finally:
        if not connection:
            adm.teardown_admin()


def _oper_sbts_cell(oper, cell_list=None, oam_ip="192.168.255.129", connection=None):
    """
    function _oper_sbts_cell
    Do operation on cell list
    :param oper: block unblock
    :param cell_list: a flexible condition combination, it can support type of string, list and dictionary
    :param oam_ip: OAM IP for ssh to NodeB
    :param connection: the connection alias if using an existing OAM connection
    :return: None

    Examples:
    Example: block cell 1 and 2
    _oper_sbts_cell(oper='block', cell_list=[1,2])
    """
    if not cell_list:
        cell_list = []

    if isinstance(cell_list, str):
        cell_list = cell_list.split()

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    dict_cell_dist_name = {}
    try:
        if isinstance(cell_list, list):
            for cell_type in ["lte", "wcdma", "gsm", "nr"]:
                for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection):
                    if not cell_list or str(cell_info['globalCellId']) in [str(cell) for cell in cell_list]:
                        dict_cell_dist_name[str(cell_info['id']['configuration'])] = cell_info['id']['internal']
        else:
            for k_rat, v_id in cell_list.items():
                for cell_info in adm.get_cells_info(cell_type=k_rat.lower(), connection=connection):
                    if isinstance(v_id, list):
                        if str(cell_info['globalCellId']) in [str(cell) for cell in v_id]:
                            dict_cell_dist_name[str(cell_info['id']['configuration'])] = cell_info['id']['internal']
                    else:
                        if str(v_id) == str(cell_info['globalCellId']):
                            dict_cell_dist_name[str(cell_info['id']['configuration'])] = cell_info['id']['internal']

        logger.info("cell info: {}".format(dict_cell_dist_name), also_console=True)
        for cell_id, dist_name in dict_cell_dist_name.items():
            logger.info("{} cell {} dist_name: {}".format(oper, cell_id, dist_name), also_console=True)
            if 'block' == oper.lower():
                adm.block_cell(dist_name=dist_name, connection=connection)
            elif 'unblock' == oper.lower():
                adm.unblock_cell(dist_name=dist_name, connection=connection)
            else:
                raise Exception('operation not supported')
    finally:
        if not connection:
            adm.teardown_admin()


def block_sbts_cell(cell_list=[], oam_ip="192.168.255.129", connection=None):
    """
    Keyword block_sbts_cell
    block operation on cell list
    :param cell_list: a flexible condition combination, it can support type of string, list and dictionary
    :param oam_ip: OAM IP for ssh to NodeB
    :param connection: the connection alias if using an existing OAM connection
    :return: None

    Examples:
    Example 1: block all cells
    | block_sbts_cell |
    Example 2: block all rat types of cells 1 and 2 with oam ip
    | block_sbts_cell | cell_list=1 2 | oam_ip=192.168.255.129 |
    Example 3: block all rate types of cells 1 and 2 with an existing connection
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | block_sbts_cell | cell_list=1 2 | connection=abc |
    Example 4: block NR cell 1 with oam ip
    | ${cell_list} | Create Dictionary | nr=1 |
    | block_sbts_cell | cell_list=${cell_list} | oam_ip=192.168.255.129 |
    Example 5: block NR cell and LTE cell with oam ip
    | ${nr_cell_id} | Create List | 1  2 |
    | ${lte_cell_id} | Create List | 1  2 |
    | ${cell_list} | Create Dictionary | nr=${nr_cell_id} | lte=${lte_cell_id} |
    | block_sbts_cell | cell_list=${cell_list} | oam_ip=192.168.255.129 |
    """
    _oper_sbts_cell(oper='block', cell_list=cell_list, oam_ip=oam_ip, connection=connection)


def unblock_sbts_cell(cell_list=[], oam_ip="192.168.255.129", connection=None):
    """
    Keyword unblock_sbts_cell
    unblock operation on cell list
    :param cell_list: a flexible condition combination, it can support type of string, list and dictionary
    :param oam_ip: OAM IP for ssh to NodeB
    :param connection: the connection object or alias if using an existing OAM connection
    :return: None

    Examples:
    Example 1: unblock all cells
    | block_sbts_cell |
    Example 2: unblock all rat types of cells 1 and 2 with oam ip
    | block_sbts_cell | cell_list=1 2 | oam_ip=192.168.255.129 |
    Example 3: unblock all rat types of cells 1 and 2 with an existing connection
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | unblock_sbts_cell | cell_list=1 2 | connection=abc |
    Example 4: unblock NR cell 1 with oam ip
    | ${cell_list} | Create Dictionary | nr=1 |
    | unblock_sbts_cell | cell_list=${cell_list} | oam_ip=192.168.255.129 |
    Example 5: unblock NR cell and LTE cell with oam ip
    | ${nr_cell_id} | Create List | 1  2 |
    | ${lte_cell_id} | Create List | 1  2 |
    | ${cell_list} | Create Dictionary | nr=${nr_cell_id} | lte=${lte_cell_id} |
    | unblock_sbts_cell | cell_list=${cell_list} | oam_ip=192.168.255.129 |
    """
    _oper_sbts_cell(oper='unblock', cell_list=cell_list, oam_ip=oam_ip, connection=connection)


def collect_sbts_snapshot(target_file_name, coverage="Full", force=True, regexp_filter=None, reason=None, cells=None,
                          timeout=360, detailed_output=False, oam_ip="10.84.190.118", connection=None):
    """
    Keyword collect_sbts_snapshot
    Order snapshot creation, collection and save it in local path.

    :param str target_file_name: Location where snapshot shall be saved.
    :param str coverage: Full, Minor or HealthCheck (only for SRAN) snapshot scope. defaults set to Full.
    :param bool force: True or False to force snapshot creation.
    :param Union[str, int] timeout: Timeout for the operation.
            Note: CLI request for snapshot is not cancelled after timeout. For cancel please call snapshot_cancel()
    :param str regexp_filter: (optional) optional, since SBTS18, Data "regExpFilter" will be ignored if coverage is
            "HealthCheck"
    :param str reason: (optional) reason for the operation.
    :param list[str] cells: (optional) list of str of network cell distnames (only for SRAN builds)
    :param bool detailed_output: return full request response when True, defaults set to False.
    :param oam_ip: OAM IP for ssh to NodeB
    :param connection: the connection alias if using an existing OAM connection
    :return str: Status of the operation.
    Examples:
    Example1: Collect snapshot
    | ${ret}  collect_sbts_snapshot | target_file_name=/tmp/snapfile | coverage=Minor |
    | Log To Console | ${ret} |
    Example2: Collect snapshot with an existing connection
    | setup_admin_connection |
    | ${ret}  collect_sbts_snapshot | target_file_name=/tmp/snapfile | coverage=Minor | connection=sbts_oam_admin |
    | Log To Console | ${ret} |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        return adm.collect_snapshot(target_file_name=target_file_name, coverage=coverage, force=force,
                                    regexp_filter=regexp_filter, reason=reason, cells=cells, timeout=timeout,
                                    detailed_output=detailed_output, connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()


def setup_admin_connection(oam_ip="192.168.255.129", connection="sbts_oam_admin"):
    """
    Keyword setup_admin_connection
    Set up an admin connection
    :param oam_ip: OAM IP for ssh to NodeB
    :param connection: the connection name, aka alias
    :return AdminConnection: Connection object
    Examples:
    Example1: Set up a connection, and use connection name
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | unblock_sbts_cell | cell_list=1 2 | connection=abc |
    Example2: Set up a connection, and use connection object
    | ${conn} | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | unblock_sbts_cell | cell_list=1 2 | connection=${conn} |
    """
    return admin().setup_admin(bts_host=oam_ip, name=connection)


def teardown_admin_connection(connection="sbts_oam_admin"):
    """
    Keyword teardown_admin_connection
    Teardown an admin connection
    :param connection: the connection, or connection's name

    Examples:
    Example1: Set up a connection, and teardown with connection name
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | teardown_admin_connection | connection=abc |
    Example2: Set up a connection, and teardown with connection object
    | ${conn} | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | teardown_admin_connection | connection=${conn} |
    """
    admin().teardown(connection=connection)


def get_sbts_counter_value(dist_name, reporting_period='latest', oam_ip="192.168.255.129", connection=None):
    """
    keyword Get Sbts Counter Value
    Get All or latest SBTS PM counter value
    :param dist_name: It can support type of string or list.
        It should be in the format like BTS/SMOD/SFP-1/RMOD-1/SFPRM/M55603C00011. It consists of 3 parts:
        Part1: BTS or TRS, means BTS counters or Transport counters
        Part2: Counter full path displayed in WebEM UI without last part, for example, full path is
               SMOD/SFP-1/RMOD-1/SFPRM/SFP_RMOD_BITS_FAIL, then part2 is SMOD/SFP-1/RMOD-1/SFPRM
        Part3: counter id
    :param reporting_period: all or latest, which reporting period that the PM counter value will be returned.
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: A dictionary contains dist_name and pair of timestamp and value

    Examples:
    Example 1: Get all value of the counter
    | ${dict_value} | Get Sbts Counter Value | dist_name=BTS/SMOD/SFP-1/RMOD-1/SFPRM/M55603C00011 |
    ...             | reporting_period=All |
    Example 2: Get latest value of the counter
    | ${dict_value} | Get Sbts Counter Value | dist_name=BTS/SMOD/SFP-1/RMOD-1/SFPRM/M55603C00011 |
    Example 3: Get latest value of the counter
    | ${dist_name}  | Create List | BTS/CELLS/NRCELL-1/NCAV/M55601C00001  BTS/CELLS/NRCELL-2/NCAV/M55601C00001
    ...                             BTS/CELLS/NRCELL-2/NCAV/M55601C00003  BTS/CELLS/NRCELL-2/NCAV/M55601C00004 |
    | ${dict_value} | Get Sbts Counter Value | dist_name=${dist_name} |

    Version:
    | Author | Version | Delivery Date | Comments |
    | Zhao Longmei | 1.0.1 | 2022/8/19 | Modify the type of parameter dist_name and the type of return parameter |
    """

    if isinstance(dist_name, str):
        dist_name = dist_name.split()

    dict_dist_counter = {}
    des_dict = {}
    new_dict = {}

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        for dist_name_each in dist_name:
            counter = adm.get_counters_info(dist_name=dist_name_each, timeout=60, connection=connection)
            dict_dist_counter[dist_name_each] = counter
    finally:
        if not connection:
            adm.teardown_admin()

    def return_dict(counter_dict, keys):
        for key in keys:
            counter_dict = counter_dict.get(key)
            yield counter_dict

    def func(seconds):
        return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(seconds))

    for dist_name_each in dist_name:
        for value in return_dict(dict_dist_counter.get(dist_name_each), dist_name_each.split('/')):
            dict_list = [value]
        new_dict[dist_name_each] = dict_list[-1]

        if reporting_period.lower() == 'latest':
            latest_period = max(period for period in new_dict.get(dist_name_each))
            des_dict[dist_name_each] = {func(float(latest_period)): new_dict.get(dist_name_each)[latest_period]}
        elif reporting_period.lower() == 'all':
            des_dict[dist_name_each] = {func(float(key)): value for key, value in new_dict.get(dist_name_each).items()}
    return des_dict


def get_sbts_sfp_measurement_value(direction, type, source_link_port=None, oam_ip="192.168.255.129", connection=None):
    """
    keyword Get Sbts Sfp Measurement Value
    SFP monitoring test
    :param direction: 'source' or 'destination'
    :param type: TXSupplyVoltage,TXBiasCurrent,TXOpticalPowerDBM,TXOpticalPowerUW,RXOpticalPowerDBM,RXOpticalPowerUW,
           LCV,BER,moduleTemperature
    :param source_link_port: the source link of source
           Note: will get the valve according to a given link, or get all links value if source_link_port=null
    :param oam_ip: OAM IP for ssh to nodeb
    :param connection: the connection alias if using an existing OAM connection
    :return: measurement value

    Examples:
    Example 1: Get all link value
    | ${value} | Get Sbts Sfp Measurement Value | direction=source| type=TXSupplyVoltage |
    Example 2: Get a given link value
    | ${value} | Get Sbts Sfp Measurement Value | direction=destination | type=TXSupplyVoltage |
    | ...  source_link_port=ASIRMOD-1/OPT_IF5 |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        parameter = adm.get_sfp_links(action="getLinksWithParameters", connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()
    value = []
    for data in parameter['connected']:
        type_value = data['data']['measurements'][type][direction]
        if source_link_port is None:
            value.append(type_value)
        elif data['data']['linkPorts']['source'] == source_link_port:
            value = type_value

    return value


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_history_alarm(forbidden_fault_id_list=None, allowed_fault_id_list=None, required_fault_id_list=None,
                             connection="sbts_oam_admin"):
    """
    Check the SBTS historical alarm(s) retrieved in the current WebEM session.
    In order to use this keyword, the ADMIN API connection must be established and teared-down explicitly.
    Refer to below example for the keyword usage.

    *** Test Cases ***
    Test case for Check Sbts History Alarm
        [Setup]  Setup Admin Connection
        Block SBTS Cell  connection=sbts_oam_admin
        Unblock SBTS Cell  connection=sbts_oam_admin
        Check SBTS History Alarm  allowed_fault_id_list=49  required_fault_id_list=49
        [Teardown]  Teardown Admin Connection

    By default, parameter is list, but also support str that elements are separated by a space.

    :param list[int] forbidden_fault_id_list: list of fault IDs that should not appear
    :param list[int] allowed_fault_id_list: list of fault IDs that are allowed to appear
    :param list[int] required_fault_id_list: list of fault IDs that must appear
    :param str connection: ADMIN API connection.
    """
    adm = admin()
    his_alarms = [str(alarm['faultId']) for alarm in adm.get_historic_alarms(connection=connection)]
    MolerTest.info("History alarms retrieved are: {}".format(his_alarms))
    result_dict = _verify_faults(his_alarms, forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list)
    MolerTest.info("_verify_faults result: {}".format(result_dict))
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def get_asir_alarm(alarm_type="active", device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Get alarms (active or cleared) from ASiR WebEM.

    :param str alarm_type: alarm type: active or cleared (history alarm).
    :param str device_name: default is "GNB0_ASIMGR"
    :param str pw: account and password
    :param str ne: ip address
    """
    asimgr = AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True)
    alarms_ordered_dict = asimgr.get_alarms_file_content()
    alarms_dict = loads(dumps(alarms_ordered_dict))
    report_items = alarms_dict.get('faultReport')
    alarms_list = []
    for ri in report_items:
        if isinstance(ri, dict):
            fault_object = ri.get('fault')
            if fault_object and isinstance(fault_object, list):
                alarms_list = list(filter(lambda dict_elem: dict_elem.get('faultState') == alarm_type, fault_object))
            if fault_object and isinstance(fault_object, dict) and fault_object.get('faultState') == alarm_type:
                alarms_list = [fault_object]

    MolerTest.info("All {} alarms retrieved from ASiR are: {}".format(alarm_type, alarms_list))
    MolerTest.steps_end()
    return alarms_list


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asir_history_alarm(appeared_time_later_than, device_name="GNB0_ASIMGR",
                             pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                             forbidden_fault_id_list=None, allowed_fault_id_list=None, required_fault_id_list=None):
    """
    Check ASiR WebEM history alarms that have been raised since the given timestamp.
    Refer to example below about how to use this keyword:

    *** Test Cases ***
    [23] Verify ASiR History Alarm
        ${start_time}  DateTime.Get Current Date  result_format=epoch  exclude_millis=True
        Block Ants  1
        Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
        Unblock Ants  1
        Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=enabled
        Check ASiR History Alarm  appeared_time_later_than=${start_time}  allowed_fault_id_list=4348
        ....    required_fault_id_list=4348

    By default, alarm parameter is list, but also support str that elements are separated by a space.
    Please refer to Examples

    :param float appeared_time_later_than: Epoch time (Epoch time is the time in seconds since the UNIX epoch
                  i.e. 00:00:00.000 (UTC) 1 January 1970.) Refer to below example to get Epoch time:
    :param str device_name: Depends on the test line configuration, the possible values could be "GNB0_ASIMGR",
                  "ENB0_ASIMGR". Default is "GNB0_ASIMGR".
    :param str pw: account and password
    :param str ne: ip address
    :param list[int] forbidden_fault_id_list: list of fault IDs that should not appear
    :param list[int] allowed_fault_id_list: list of fault IDs that are allowed to appear
    :param list[int] required_fault_id_list: list of fault IDs that must appear
    :return None
    """
    history_alarm_list = get_asir_alarm(alarm_type="cleared", device_name=device_name, pw=pw, ne=ne)

    def _convert_utc_to_local_tz(utc_time):
        from_zone = tz.tzutc()
        to_zone = tz.tzlocal()
        utc = datetime.strptime(utc_time, "%Y-%m-%dT%H:%M:%S.%fZ")
        utc = utc.replace(tzinfo=from_zone)
        central = utc.astimezone(to_zone)
        return time.mktime(central.timetuple())

    delta_alarm_list = [elem for elem in history_alarm_list
                        if _convert_utc_to_local_tz(elem.get("timeStarted")) >= appeared_time_later_than]

    MolerTest.info("Total {} history alarm(s). {} alarm(s) raised after {}".format(
        len(history_alarm_list), len(delta_alarm_list),
        time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(appeared_time_later_than))))
    MolerTest.info("Delta alarm(s): {}".format(delta_alarm_list))

    delta_alarm_id_list = [str(alarm['faultId']) for alarm in delta_alarm_list]

    result_dict = _verify_faults(delta_alarm_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                 required_fault_id_list)
    MolerTest.info("_verify_faults result: {}".format(result_dict))

    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))

    MolerTest.steps_end()


def get_sbts_release_verison(ip_addr="192.168.255.129", connection=None, timeout=15):
    """
    Keyword get_sbts_release_verison
    Get SBTS station active release version.
    :param ip_addr: OAM or M-plane IP address to ssh login sbts
    :param connection: the connection alias if using an existing OAM connection
    :param timeout: Keyword execution timeout.
    :return: Version number as string ie. SBTS21B

    Example:
    Example 1: get TL Release version
    | get_sbts_release_verison |
    Example 2: get TL Release version with an existing connection
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | get_sbts_release_verison | connection=abc |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=ip_addr)

    try:
        rel_version = adm.get_sw_release_name(timeout=timeout, connection=connection)
        return rel_version

    except Exception as ex:
        MolerTest.error(str(ex))

    finally:
        if not connection:
            adm.teardown_admin()


def waiting_for_sbts_connection(ip_addr='192.168.255.129', timeout=600):
    """
    Wait for ssh
    :param ip_addr: IP address of gNB
    :para timeout: time to ping bts
    :return: None
    """
    while time.time() <= time.time() + timeout:
        result = os.system('ping -c 1 {}'.format(ip_addr))
        if int(result) == 0:
            logger.info('BTS is pingable', also_console=True)
            break
    else:
        logger.info('BTS is not pingable in {}'.format(timeout), also_console=True)


def _operate_antmod(operation, ant_list=[], device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Internal method _operate_antmod
    Do operation on ANT Module.
    :param operation: operation type, block/unblock/reset
    :param ant_list: list of AntMod IDs
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.
    """
    all_ant_list = _get_antmod_id_list(device_name=device_name, pw=pw, ne=ne)
    logger.info("All available Ant Mod ID : {0}".format(all_ant_list))

    ant_list = ant_list if isinstance(ant_list, list) else str(ant_list).split()
    logger.info("To be {0}ed Ant ID : {1}".format(operation, ant_list))

    asir_mgr = AsiMgr(device_name=device_name, pw=pw, ne=ne)
    asir_mgr.connect_to_asimgr()

    if operation.lower() not in ['block', 'unblock', 'reset']:
        raise Exception("operation {0} is not supported.".format(operation))

    for ant_id in all_ant_list:
        if not ant_list or ant_id in ant_list:
            logger.info("{0} ANTMOD-{1}".format(operation, ant_id), also_console=True)
            if operation.lower() == 'block':
                result = asir_mgr.block_ant(number=ant_id)
            elif operation.lower() == 'unblock':
                result = asir_mgr.unblock_ant(number=ant_id)
            else:
                result = asir_mgr.reset_asirant(number_of_ant=ant_id)
            logger.info("{0} ANTMOD-{1} result: {2}".format(operation, ant_id, result), also_console=True)


def block_antmod(ant_list=[], device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    keyword block_antmod
    Block AntMod via AsiMgr according to given Ant list, block all AntMods if no parameter is provided.
    :param ant_list: list of AntMod IDs
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.

    Examples:
    Example 1: block all 5G ANTMOD
    | block_antmod |
    Example 2: block 5G ANTMOD-2
    | block_antmod | ant_list=2 |
    Example 3: block 4G ANTMOD-1
    | block_antmod | ant_list=1 | device_name=ENB0_ASIMGR |
    """
    _operate_antmod(operation='block', ant_list=ant_list, device_name=device_name, pw=pw, ne=ne)


def unblock_antmod(ant_list=[], device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    keyword unblock_antmod
    Unblock AntMod via AsiMgr according to given Ants list, unblock all AntMods if no parameter is provided.
    :param ant_list: list of AntMod IDs
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.

    Examples:
    Example 1: unblock all 5G ANTMOD
    | unblock_antmod |
    Example 2: unblock 5G ANTMOD-2
    | unblock_antmod | ant_list=2 |
    Example 3: unblock 4G ANTMOD-1
    | unblock_antmod | ant_list=1 | device_name=ENB0_ASIMGR |
    """
    _operate_antmod(operation='unblock', ant_list=ant_list, device_name=device_name, pw=pw, ne=ne)


def reset_antmod(ant_list=[], device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    keyword reset_antmod
    Reset AntMod via AsiMgr according to a given Ants list, Reset all AntMods if no parameter is provided.
    :param ant_list: list of AntMod IDs
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.

    Examples:
    Example 1: Reset all 5G ANTMOD
    | reset_antmod |
    Example 2: Reset 5G ANTMOD-2
    | reset_antmod | ant_list=2 |
    Example 3: Reset 4G ANTMOD-1
    | reset_antmod | ant_list=1 | device_name=ENB0_ASIMGR |
    """
    _operate_antmod(operation='reset', ant_list=ant_list, device_name=device_name, pw=pw, ne=ne)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_antmod_status(ant_list=[], expected_status_dict={}, device_name="GNB0_ASIMGR",
                        pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    keyword check_antmod_status
    Get Ant Module status and check whether status is expected or not.
    :param ant_list: list of AntMod IDs
    :param expected_status_dict: expected status with dictionary of key/value pair
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.
    :return: dictionary of check result

    Examples:
    Example 1: Check all 5G Ant Module status
    | ${expected_status} | Create Dictionary | localState=blocked | operationalState=disabled |
    | check_antmod_status | expected_status_dict=${expected_status} |
    Example 2: Check status of 5G ANT Module 1 and 2
    | ${expected_status} | Create Dictionary | localState=blocked | operationalState=disabled |
    | check_antmod_status | ant_list=1 2 | expected_status_dict=${expected_status} |
    Example 3: Check status of 4G ANT Module 2
    | ${expected_status} | Create Dictionary | localState=blocked | operationalState=disabled |
    | check_antmod_status | ant_list=2 | expected_status_dict=${expected_status} | device_name=ENB0_ASIMGR |
    """
    all_ant_raw_status = AsiMgr(autoconnect=True, device_name=device_name, pw=pw, ne=ne).get_all_ants_status()
    all_ant_status = _convert_orderdict_to_list_status(all_ant_raw_status)
    logger.info("All Ant Module status : {0}".format(all_ant_status))

    ant_list = ant_list if isinstance(ant_list, list) else str(ant_list).split()
    logger.info("Check Ant ID : {0} Status".format(ant_list))

    dict_antmod_status = {}
    for index in ant_list:
        dict_antmod_status[str(index)] = None

    for ant in all_ant_status:
        if not ant_list or ant.get('status').get('configDN').split('-')[-1] in ant_list:
            dict_antmod_status[ant.get('status').get('configDN').split('-')[-1]] = ant.get('status')

    logger.info("Ant Module {0} dict status : {1}".format(ant_list, dict_antmod_status))

    compare_result = _compare_status(dict_antmod_status, expected_status_dict)
    if not compare_result['check_result']:
        MolerTest.error("Ant Module status check result: {}".format(compare_result))
    MolerTest.steps_end()


def _get_antmod_id_list(hub_id=None, device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Internal method  _get_antmod_id_list
    Use to get ant module id list.
    """
    hw_inventory_info = AsiMgr(autoconnect=True, device_name=device_name,
                               pw=pw, ne=ne).get_asi_hw_data_based_on_commissioning()
    logger.info("ASIR Module HW inventory info : {0}".format(hw_inventory_info))
    ant_mod_id_list = []
    for hub in hw_inventory_info:
        if hub_id is None or hub['@id'] == str(hub_id):
            ant_mod_id_list = ant_mod_id_list + [ant['configDN'] for ant in hub['ANTMOD_R']]
    return ant_mod_id_list


def _convert_orderdict_to_list_status(ordered_dict):
    """
    Internal method  _convert_orderdict_to_list_status
    Use to convert status of orderedDict type into list type.
    """
    raw_list = loads(dumps(ordered_dict)).get('raml').get('cmData').get('managedObject')
    list_items = []
    for raw_item in raw_list:
        list_raw_item_status = raw_item.get('p')
        item_status = {}
        for raw_item_status in list_raw_item_status:
            if raw_item.get('@name') == 'availabilityStatus':
                continue
            item_status[raw_item_status.get('@name')] = raw_item_status.get('#text')

        list_items.append({'distName': raw_item.get('@distName'),
                           'class': raw_item.get('class'),
                           'status': item_status})
    return list_items


def _operate_asirmod(operation, asir_list=[], oam_ip="192.168.255.129", connection=None):
    """
    Internal method _operate_asirmod
    Do operation on given ASIR Module.
    :param operation: operation type, lock or unlock
    :param asir_list: list of ASIR Mod IDs
    :param oam_ip: OAM IP for ssh to BTS station
    :param connection: the connection alias if using an existing OAM connection
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    asir_list = asir_list if type(asir_list) is list else str(asir_list).split()
    dict_asir_dist_name = {}
    for asir_id in asir_list:
        dict_asir_dist_name[str(asir_id)] = None

    if operation.lower() not in ['lock', 'unlock']:
        raise Exception("operation {0} is not supported.".format(operation))

    try:
        bts_info = adm.get_bts_info(connection=connection)
        for asir_item in bts_info['radioModules']['asirmod']:
            asir_sub_item = asir_item['id']['configuration']
            if not asir_list or asir_sub_item.split('-')[-1] in asir_list:
                dict_asir_dist_name[asir_sub_item.split('-')[-1]] = asir_sub_item
        logger.info("ASIR Module dist name dict: {0}".format(dict_asir_dist_name))

        for asir_id, dist_name in dict_asir_dist_name.items():
            logger.info("{0} ASIRMOD {1}".format(operation, asir_id), also_console=True)
            para_value = 'Locked' if operation.lower() == 'lock' else "Unlocked"

            result = adm.perform_parameter_recommissioning(dist_name=dist_name,
                                                           parameter="administrativeState",
                                                           operation='update',
                                                           value=para_value,
                                                           skip_parameter_relation_errors=True,
                                                           connection=connection)

            logger.info("{0} operation result : {1}".format(operation, result), also_console=True)
            nidd_validation_result = result.get('validationResult', {}).get('niddValidationResult', {}).get('status')
            pdl_validation_result = result.get('validationResult', {}).get('pdlValidationResult', {}).get('status')
            activation_result = result.get('commissioningResult', {}).get('activationResult', {}). \
                get('resultNode', {}).get('parameters', {}).get('result')

            if nidd_validation_result.lower() != 'ok':
                raise Exception("NIDD Validation failed due to {}".format(
                    result.get('validationResult', {}).get('niddValidationResult', {}).get('logs')))
            if pdl_validation_result.lower() != 'ok':
                raise Exception("PDL Validation failed due to {}".format(
                    result.get('validationResult', {}).get('pdlValidationResult', {}).get('logs')))
            if activation_result.lower() != 'success':
                raise Exception("Activation failed due to {}".format(
                    result.get('commissioningResult', {}).get('activationResult', {}).get('resultNode', {}).get(
                        'parameters')))

    except Exception as e:
        raise Exception(str(e))

    finally:
        if not connection:
            adm.teardown_admin()


def lock_asirmod(asir_list=[], oam_ip="192.168.255.129", connection=None):
    """
    Keyword lock_asirmod
    Do lock operation on given ASIR module list.
    :param asir_list: list of ASIR Mod IDs, lock all asirmod if list is empty
    :param oam_ip: OAM IP for ssh to BTS station
    :param connection: the connection alias if using an existing OAM connection

    Example:
    Example 1: lock all asir module
    | lock_asirmod |
    Example 2: lock asirmod 1 and 2 with oam ip
    | lock_asirmod | asir_list=1 2 | oam_ip=192.168.255.129 |
    Example 3: lock asirmod 1 and 2 with an existing connection
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | lock_asirmod | asir_list=1 2 | connection=abc |
    """
    _operate_asirmod(operation='Lock', asir_list=asir_list, oam_ip=oam_ip, connection=connection)


def unlock_asirmod(asir_list=[], oam_ip="192.168.255.129", connection=None):
    """
    Keyword unlock_asirmod
    Do unlock operation on given ASIR module list.
    :param asir_list: list of ASIR Mod IDs, unlock all asirmod if list is empty
    :param oam_ip: OAM IP for ssh to BTS station
    :param connection: the connection alias if using an existing OAM connection

    Example:
    Example 1: unlock all asir module
    | unlock_asirmod |
    Example 2: unlock asirmod 1 and 2 with oam ip
    | unlock_asirmod | asir_list=1 2 | oam_ip=192.168.255.129 |
    Example 3: unlock asirmod 1 and 2 with an existing connection
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | unlock_asirmod | asir_list=1 2 | connection=abc |
    """
    _operate_asirmod(operation='Unlock', asir_list=asir_list, oam_ip=oam_ip, connection=connection)


def reset_asirmod(asir_list=[], timeout=240, oam_ip="192.168.255.129", connection=None):
    """
    Keyword reset_asirmod
    Do reset operation on given ASIR module list.
    :param asir_list: list of ASIR Mod IDs, reset all asirmod if list is empty
    :param timeout: time duration for waiting asir module come up after reset operation
    :param oam_ip: OAM IP for ssh to BTS station
    :param connection: the connection alias if using an existing OAM connection

    Example:
    Example 1: reset all asir module
    | reset_asirmod |
    Example 2: reset asirmod 1 and 2 with oam ip
    | reset_asirmod | asir_list=1 2 | oam_ip=192.168.255.129 |
    Example 3: reset asirmod 1 and 2 with an existing connection and given timeout
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | reset_asirmod | asir_list=1 2 | timeout=300 | connection=abc |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    asir_list = asir_list if type(asir_list) is list else str(asir_list).split()
    dict_asir_dist_name = {}
    for asir_id in asir_list:
        dict_asir_dist_name[str(asir_id)] = None

    try:
        bts_info = adm.get_bts_info(connection=connection)
        for asir_item in bts_info['radioModules']['asirmod']:
            asir_sub_item = asir_item['id']['configuration']
            if not asir_list or asir_sub_item.split('-')[-1] in asir_list:
                dict_asir_dist_name[asir_sub_item.split('-')[-1]] = asir_sub_item
        logger.info("ASIR Module dist name dict: {0}".format(dict_asir_dist_name))

        for asir_id, dist_name in dict_asir_dist_name.items():
            logger.info("Reset ASIRMOD {0}".format(asir_id), also_console=True)
            result = adm.reset_unit(dist_name=dist_name,
                                    timeout=timeout,
                                    connection=connection)
            logger.info("Reset operation result : {0}".format(result), also_console=True)

    except Exception as ex:
        if "not completed within" in str(ex):
            raise Exception("Reset oper not completed within {0}s, detailed error msg: {1}".format(timeout, str(ex)))

    finally:
        if not connection:
            adm.teardown_admin()


def get_sbts_sw_version(ip_addr="192.168.255.129", connection=None, timeout=15):
    """
    Keyword get_sbts_sw_version
    Get SBTS station active software version.
    :param ip_addr: OAM or M-plane IP address to ssh login sbts
    :param connection: the connection alias if using an existing OAM connection
    :param timeout: Keyword execution timeout.
    :return: Version number as string ie. SBTS21B_ENB_9999_210528_000016

    Example:
    Example 1: get TL SW version
    | get_sbts_sw_version |
    Example 2: get TL SW version with an existing connection
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | get_sbts_sw_version | connection=abc |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=ip_addr)

    try:
        sw_version = adm.get_sw_version(timeout=timeout, connection=connection)
        return sw_version

    except Exception as ex:
        MolerTest.error(str(ex))

    finally:
        if not connection:
            adm.teardown_admin()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_site_status(expect_status, oam_ip="192.168.255.129", connection=None):
    """
    Keyword check_sbts_site_status
    Check sBTS site status with expected one.
    :param expect_status: expected status with string type ie.IntegratedToRan/OnAir
    :param oam_ip: OAM IP address to ssh login sBTS
    :param connection: the connection alias if using an existing OAM connection

    Example:
    Example 1: check sBTS site status with expected OnAir status
    | check_sbts_site_status | expect_status=On Air |
    Example 2: check sBTS site status with expected IntegratedToRan status using exist connection
    adm = admin()
    | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
    | check_sbts_site_status | expect_status=IntegratedToRan | connection=abc |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    dict_check_result = {'check_result': True, 'check_details': {}}
    try:
        return_result = adm.get_bts_statuses(connection=connection)
        if type(return_result) is dict and 'proceduralState' in return_result.keys():
            current_status = return_result.get('proceduralState')
            trans_expect_status = ''.join(expect_status.split()).lower()
            if current_status.lower() != trans_expect_status:
                dict_check_result['check_result'] = False
                dict_check_result['check_details'] = {'actual': current_status, 'expect': expect_status}

    finally:
        if not connection:
            adm.teardown_admin()

    if not dict_check_result['check_result']:
        MolerTest.error("sBTS site status check result: {0}".format(dict_check_result))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_hubmod_status(hub_id_list=[], expected_status_dict={}, device_name="GNB0_ASIMGR",
                        pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    keyword check_hubmod_status
    Get Hub Module status and check whether status is expected or not.
    :param hub_id_list: ASiR sHUB ID list, reset all Hub Module if list is empty
                        The ID here means the ASIRMOD ID (ASIRMOD-x) which could be seen from gNB/eNB WebEM
    :param expected_status_dict: expected status with dictionary of key/value pair
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.
    :return: dictionary of check result

    Examples:
    Example 1: Check all 5G HUB Module status
    | ${expected_status} | Create Dictionary | localState=blocked | operationalState=disabled |
    | check_hubmod_status | expected_status_dict=${expected_status} |
    Example 2: Check status of 5G HUB Module 1 and 2
    | ${expected_status} | Create Dictionary | localState=blocked | operationalState=disabled |
    | check_hubmod_status | hub_id_list=1 2 | expected_status_dict=${expected_status} |
    Example 3: Check status of 4G HUB Module 2
    | ${expected_status} | Create Dictionary | localState=blocked | operationalState=disabled |
    | check_hubmod_status | hub_id_list=2 | expected_status_dict=${expected_status} | device_name=ENB0_ASIMGR |
    """
    all_hub_raw_status = AsiMgr(autoconnect=True, device_name=device_name, pw=pw, ne=ne).get_all_hubs_status()
    all_hub_status = _convert_orderdict_to_list_status(all_hub_raw_status)
    logger.info("All Hub Module status : {0}".format(all_hub_status))

    hubmod_list = hub_id_list if isinstance(hub_id_list, list) else str(hub_id_list).split()
    logger.info("Check Hub ID : {0} status".format(hubmod_list))

    dict_hubmod_status = {}
    for index in hubmod_list:
        dict_hubmod_status[str(index)] = None

    for hub in all_hub_status:
        if not hubmod_list or hub.get('status').get('configDN').split('-')[-1] in hubmod_list:
            dict_hubmod_status[hub.get('status').get('configDN').split('-')[-1]] = hub.get('status')

    logger.info("Hub Module {0} dict status : {1}".format(hubmod_list, dict_hubmod_status))

    compare_result = _compare_status(dict_hubmod_status, expected_status_dict)
    if not compare_result['check_result']:
        MolerTest.error("Hub Module status check result: {}".format(compare_result))
    MolerTest.steps_end()


def reset_hubmod(hub_id_list=[], timeout=180, device_name="GNB0_ASIMGR",
                 pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Keyword reset_hubmod
    Do reset operation on given HUB Module list.
    :param hub_id_list: ASiR sHUB ID list, reset all Hub Module if list is empty
                        The ID here means the ASIRMOD ID (ASIRMOD-x) which could be seen from gNB/eNB WebEM
    :param timeout: timeout for the reset operation.
    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.

    Example:
    Example 1: reset all 5G hub module
    | reset_hubmod |
    Example 2: reset 5G hubmod 1 and 2 with timeout 120s
    | reset_hubmod | hub_id_list=1 2 | timeout=120 |
    Example 3: reset 4G hubmod 1
    | reset_hubmod | hub_id_list=1 | device_name=ENB0_ASIMGR |
    """
    hw_inventory_info = AsiMgr(autoconnect=True, device_name=device_name,
                               pw=pw, ne=ne).get_asi_hw_data_based_on_commissioning()
    all_hub_list = [hub.get("asiRmodId") for hub in hw_inventory_info]
    logger.info("All Hub List : {0}".format(all_hub_list))

    asir_mgr = AsiMgr(device_name=device_name, pw=pw, ne=ne)
    asir_mgr.connect_to_asimgr()

    hubmod_list = hub_id_list if type(hub_id_list) is list else str(hub_id_list).split()
    for hub in all_hub_list:
        if not hubmod_list or str(hub) in hubmod_list:
            logger.info("Reset HubMod-{0}".format(hub), also_console=True)
            reset_result = _asir_reset_hub(hub, asir_mgr, timeout=timeout, device_name=device_name, pw=pw, ne=ne)
            logger.info("asirmod id : {0}, reset result : {1}".format(hub, reset_result), also_console=True)


def _asir_reset_hub(asirmod_id, asir_instance, oam_ip="192.168.255.129", connection=None,
                    timeout=180, device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Internal method _asir_reset_hub
    Generate one thread to reset hub via AsiMgr.
    """
    timeout = int(timeout)
    hubmod_id = _get_hubmod_id_from_asirmod_id(asirmod_id, device_name=device_name, pw=pw, ne=ne)
    logger.info("asirmod_id : {0}, mapped hubmod_id : {1}".format(asirmod_id, hubmod_id))
    oper_state_record = {}
    m_thread = threading.Thread(target=_gnb_check_hub_reseting,
                                args=(asirmod_id, oper_state_record, oam_ip, connection, timeout))
    m_thread.start()
    time.sleep(5)
    asir_instance.reset_asirhub(hubmod_id)
    m_thread.join(timeout)
    logger.info("finally hubmod_id {0} oper_state_record : {1}".format(hubmod_id, oper_state_record))
    return oper_state_record


def _get_hubmod_id_from_asirmod_id(asirmod_id=None, oam_ip="192.168.255.129",
                                   connection=None, device_name="GNB0_ASIMGR",
                                   pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Internal method _get_hubmod_id_from_asirmod_id
    Convert ASIRMOD ID (used in gNB WebEM for Hub) to HUBMOD ID (used in ASiR WebEM for Hub)
    :param asirmod_id: HUB ID (ASIRMOD-x)
    :return: HUB ID (HUBMOD-x)
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    try:
        bts_info = adm.get_bts_info(connection=connection)
        for hub in bts_info.get('radioModules').get('asirmod'):
            if hub.get('id').get('configuration').split('-')[-1] == str(asirmod_id):
                serial_number = hub.get('serialNumber')
                break
        else:
            raise Exception("Didn't find specified HUB information with ASiRMOD ID {0}".format(asirmod_id))
    finally:
        if not connection:
            adm.teardown_admin()

    hw_inventory_info = AsiMgr(autoconnect=True, device_name=device_name,
                               pw=pw, ne=ne).get_asi_hw_data_based_on_commissioning()
    for single_hub_info in hw_inventory_info:
        if single_hub_info.get("serialNumber") == serial_number:
            return single_hub_info.get("@id")
    else:
        raise Exception("Didn't find HUB information with serial number {0}".format(serial_number))


def _gnb_check_hub_reseting(asirmod_id, oper_state_record, oam_ip="192.168.255.129", connection=None, timeout=180):
    """
    Internal method _gnb_check_hub_reseting
    Keep checking hub reset status via gnb connection
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    try:
        start_time = time.time()
        i = 0
        oper_state_record['asirmod_id'] = asirmod_id
        oper_state_record['res'] = False
        oper_state_record['state_records'] = []

        while time.time() < start_time + timeout:

            hubs_info_list = adm.get_bts_info().get('radioModules').get('asirmod')

            for hub_info in hubs_info_list:
                # hub found
                if hub_info.get('id').get('configuration').split('-')[-1] == str(asirmod_id):
                    stat = hub_info.get('status').get('operationalState')
                    pprint("Round index : {0}, status : {1}".format(i, stat))
                    if not oper_state_record['state_records'] or oper_state_record['state_records'][-1] != stat:
                        oper_state_record['state_records'].append(stat)
                        pprint("HW stat hw_stat : {0}".format(oper_state_record))
                        if oper_state_record['state_records'][-1] == 'Enabled' \
                                and 'Disabled' in oper_state_record['state_records']:
                            oper_state_record['res'] = True
                            return
            i = i + 1
            time.sleep(1)
    except Exception as ex:
        logger.info("Enter into exception when poll check hub status : {0}".format(ex))

    finally:
        if not connection:
            adm.teardown_admin()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asir_active_alarm(device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                            forbidden_fault_id_list=None,
                            allowed_fault_id_list=None,
                            required_fault_id_list=None):
    """
    Keyword check_asir_active_alarm
    Get ASIR active alarms and check if the alarms match given 3 conditions, forbidden/allowed/required,
    If the condition fault ID list is not provided or None, the keyword will skip the check

    :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR, or ENB0_ASIMGR for 4G ASiR.
    :param str pw: account and password
    :param str ne: ip address
    Note that the number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline
    configuration file (tl.gnbs or tl.enbs of __init__.py). 0 means 1st element and 1 means 2nd element, and so on.

    By default, alarm parameter is list, but also support str that elements are separated by a space.
    Please refer to Examples

    :param forbidden_fault_id_list: list of fault IDs that should not appear
    :param allowed_fault_id_list: list of fault IDs that are allowed to appear
    :param required_fault_id_list: list of fault IDs that must appear
    :return: dictionary of check result

    Examples:
    Example 1: set allowed_fault_id_list to ${NULL}, that means all faults allowed
    | check_asir_active_alarm | allowed_fault_id_list=${Null} |
    or
    | check_asir_active_alarm  |

    Example 2: set allowed_fault_id_list to empty string or list, that means no faults allowed
    | check_sbts_alarm  allowed_fault_id_list='' |

    Example 3: check 5G active alarm '61649', '77777' forbidden, '7100', '7300', '4479' allowed, , '61524' required
    | check_asir_active_alarm | forbidden_fault_id_list=61649 77777 | allowed_fault_id_list=7100 7300 4479 |
    | ...   required_fault_id_list=61524 |

    Example 5: check 4G active alarm, faults '1234', '1235' forbidden
    | check_asir_active_alarm | device_name="ENB0_ASIMGR" | forbidden_fault_id_list=1234 1235 |
    """
    active_alarm_list = get_asir_alarm(device_name=device_name, pw=pw, ne=ne)
    logger.info("All active alarm list : {0}".format(active_alarm_list))

    active_alarm_id_list = [str(alarm['faultId']) for alarm in active_alarm_list]
    logger.info("All active alarm id list : {0}".format(active_alarm_id_list))

    verify_dict = _verify_faults(active_alarm_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                 required_fault_id_list)

    if not verify_dict['check_result']:
        MolerTest.error("ASIR active alarm check result: {0}".format(verify_dict))
    MolerTest.steps_end()


def collect_asir_commissioning(device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                               outputdir="/tmp"):
    """
    Collect ASiR commissioning file and save it under output dir

    :param device_name: Supply device_name with value 'GNB0_ASIMGR' (by default) for 5G ASiR, or 'ENB0_ASIMGR' for 4G
    ASiR. The number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the testline. If
    the test line is 5G + 4G configuration and test cases running on the VM connected to 5G gNB, and the keyword is
    going to collect 4G ASiR commissioning (means device_name='ENB0_ASIMGR'), then the commission file will be saved
    under output dir of VM connected to 4G eNB (not local VM that connected to 5G gNB).
    :param str pw: account and password
    :param str ne: ip address
    :param outputdir: path to commission file.

    :return: Full path including commission file name. For example, /tmp/192.168.255.129_scf.xml
    """
    asimgr = AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True)

    return asimgr.collect_commissioning_file(outputdir=outputdir)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def perform_full_commissioning_for_asir(scf="/tmp/192.168.255.129_scf.xml", device_name="GNB0_ASIMGR",
                                        pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Perform ASiR full commissioning

    :param scf: path to ASiR full commission file
    :param device_name: Supply device_name with value 'GNB0_ASIMGR' (by default) for 5G ASiR, or 'ENB0_ASIMGR' for 4G
                        ASiR. The number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in
                        the testline.
    :param str pw: account and password
    :param str ne: ip address
    """
    asimgr = AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True)
    asimgr.send_commission_fullfile(path=scf)
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def perform_asir_delta_commissioning(delta_file, scf_params=None, device_name="GNB0_ASIMGR",
                                     pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                                     upload_to_remote=False):
    """
    Perform ASiR delta commissioning

    :param scf: path to ASiR delta commission file (.xml)
    :param scf_params: dictionary of SCF parameters to be replaced in delta file. Default is None.
    :param device_name: Supply device_name with value 'GNB0_ASIMGR' (by default) for 5G ASiR, or 'ENB0_ASIMGR' for 4G
                        ASiR. The number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in
                        the testline.
    :param str pw: account and password
    :param str ne: ip address
    :param upload_to_remote: flag to indicate if commission file is needed to upload to the remote VM where the device
                             (given by 'device_name') is hosted. Default is False. If it is true, means the commission
                             file given by 'scf' parameter will be uploaded from local VM (where the test cases are
                             running) to remote VM (hosting the device specified by 'device_name' parameter).
    """
    if scf_params:
        delta_file = _generate_delta_scf_from_template(delta_file, scf_params, file_format="xml")

    if upload_to_remote:
        localdir, filename = os.path.split(delta_file)
        hop_device = device_name.split("_")[0]
        util().upload_files(local_dir=localdir, local_file=filename, remote_device_name=device_name,
                            remote_dir='/tmp', timeout=60, log_level='error', hops=[hop_device + "_WS"])
        MolerTest.info("Uploaded file {} to /tmp of remote VM where the device {} is hosted".
                       format(delta_file, device_name))
        delta_file = "/tmp/" + filename

    AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True).send_delta_commissioning(path=delta_file)
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def perform_sbts_full_commissioning(scf_file, oam_ip="192.168.255.129", timeout=300, port=443, connection=None):
    """
    Perform SBTS full commissioning

    :param scf_file: path to SCF file
    :param oam_ip: SBTS OAM IP address
    :param timeout: maximum time to wait in seconds
    :param connection: AdminConnection object or string name alias
    """
    result = _sbts_full_commissioning(scf_file=scf_file, oam_ip=oam_ip, timeout=timeout,
                                      connection=connection, port=port)

    MolerTest.info("Perform full commissioning result: {}".format(result))
    MolerTest.steps_end()


def _sbts_full_commissioning(scf_file, oam_ip, timeout, connection, port):
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    try:
        result = adm.perform_commissioning(scf_file=scf_file, skip_parameter_relation_errors=True,
                                           timeout=timeout, connection=connection)
        return result
    except Exception as ex:
        MolerTest.error("Exception caught during performing full commissioning: {}".format(ex))
    finally:
        if not connection:
            adm.teardown_admin()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def perform_sbts_delta_commissioning(delta_file, scf_params=None, oam_ip="192.168.255.129",
                                     timeout=300, connection=None):
    """
    Perform SBTS delta commissioning. Please refer to link below to get to know how the delta commission is generated
    and how this keyword should be used.

https://confluence.ext.net.nokia.com/display/NewMobility/Delta+Commissioning+Generation+and+Perform+Delta+Commissioning

    :param delta_file: Delta JSON or path to JSON file. XML format is NOT supported.
    :param scf_params: dictionary of parameters to be replaced in dalta_file. Default is None.
    :param oam_ip: SBTS OAM IP address
    :param timeout: maximum time to wait in seconds
    :param connection: AdminConnection object or string name alias
    """
    if scf_params:
        delta_file = _generate_delta_scf_from_template(delta_file, scf_params)

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    try:
        result = adm.perform_delta_recommissioning(delta_file=delta_file, skip_parameter_relation_errors=True,
                                                   timeout=timeout, connection=connection)
        MolerTest.info("Perform delta recommissioning result: {}".format(result))
    except Exception as ex:
        MolerTest.error("Exception caught during performing delta commissioning: {}".format(ex))
    finally:
        if not connection:
            adm.teardown_admin()

    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def reset_configuration_for_asir(device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Reset ASiR configuration

    :param device_name: Supply device_name with value 'GNB0_ASIMGR' (by default) for 5G ASiR, or 'ENB0_ASIMGR' for 4G
                        ASiR. The number followed by GNB or ENB indicates the order in which the gNB/eNB is defined in
                        the testline.
    :param str pw: account and password
    :param str ne: ip address
    """
    asimgr = AsiMgr(device_name=device_name, pw=pw, ne=ne, autoconnect=True)
    asimgr.configuration_reset()
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions()
def wait_until_asir_container_to_get_up(device_name="GNB0", step=20.0, timeout=330.0):
    """
    Check if the container is up every step seconds until the container gets up or timeout time expires.

    :param step: time in seconds between checks.
    :param timeout: max time function checks if the container is up.
    :param device_name: Supply device_name with value 'GNB0' (by default) for gNB, or 'ENB0' for eNB. The number
                        followed by GNB or ENB indicates the order in which the gNB/eNB is defined in the test line
                        configuration file.
    :return: Nothing.
    """
    airscale = AirScale(device_name=device_name, autoconnect=True)
    container_id = airscale.get_asi_container_id()
    MolerTest.info("ASiR Container ID is : {}".format(container_id))

    start_time = time.time()

    while time.time() - start_time < timeout:
        if airscale.get_asir_container_status(container_id):
            MolerTest.info("Container {} is up.".format(container_id))
            return
        MolerTest.sleep(step)
        MolerTest.info("Rechecking...")

    MolerTest.error("Container {} is down.".format(container_id))


@MolerTest.raise_background_exceptions(check_steps_end=True)
def perform_sbts_full_commissioning_via_virtual_machine_lmp(scf_file, vm_ip, vm_user, vm_password,
                                                            vm_ssh_port=22, lmp='192.168.255.129', https_port=443):
    """
    Perform SBTS full commissioning via virtual machine LMP.

    The most common case for using this keyword is like this:
    - test line configuration: 5G + 4G
    - test cases are running on 5G VM
    - configuration reset was conducted on 4G eNB in test case. The next step will be to perform full commissioning
      on eNB.
    In this scenario, eNB MPlane IP address cannot be used for commissioning because it is still not yet operational.
    Supplying eNB M-Plane IP address to keyword 'Perform SBTS Full Commissioning' does not work.

    :param scf_file: path to full commission file
    :param vm_ip: IP for virtual machine connected to target SBTS LMP
    :param vm_user: username of virtual machine connected to target SBTS LMP
    :param vm_password: password of virtual machine connected to target SBTS LMP
    :param vm_ssh_port: SSH port of of virtual machine connected to target SBTS LMP
    :param lmp: target SBTS LMP ip address
    :param https_port: https service port of target SBTS
    :return: None
    """
    try:
        with sshtunnel.open_tunnel(
                ssh_address_or_host=(vm_ip, int(vm_ssh_port)),
                remote_bind_address=(lmp, https_port),
                ssh_username=vm_user,
                ssh_password=vm_password,
                block_on_close=False,
        ) as tunnel:
            result = _sbts_full_commissioning(scf_file=scf_file, oam_ip="127.0.0.1", connection=None,
                                              timeout=300, port=tunnel.local_bind_port)
            MolerTest.info("Perform full commissioning via VM LMP result: {}".format(result))
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        MolerTest.steps_end()


def _generate_delta_scf_from_template(delta_template_path, dict_scf_para_replace, file_format="json"):
    delta_template = None
    with open(delta_template_path, 'r') as f_delta_template:
        delta_template = f_delta_template.read()

    for k, v in dict_scf_para_replace.items():
        delta_template = delta_template.replace('__{}__'.format(str(k).upper()), str(v))

    current_time = datetime.now().strftime("%Y%m%d%H%M%S%f")
    delta_scf_dir = os.path.join('/tmp', 'delta_scfs')
    if not os.path.exists(delta_scf_dir):
        os.mkdir(delta_scf_dir)

    delta_scf_file_path = os.path.join(delta_scf_dir, '{}_{}.{}'.format(
        os.path.splitext(os.path.basename(delta_template_path))[0], current_time, file_format))

    with open(delta_scf_file_path, 'a') as f_delta:
        f_delta.write(delta_template)

    return delta_scf_file_path


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_hub_status_consistency(oam_ip="192.168.255.129", connection=None, device_name="GNB0_ASIMGR",
                                      pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Main Function:
            Check Hub Status Consistency between gNB/eNB and ASiR, if hub status is consistency in gNB/eNB and ASiR,
            the function is pass, or if hub status is not consistency in gNB/eNB and ASiR side, the function is fail
            Currently below two type status are taken into account:
            1.SBTS ASIRMOD administrative state "Locked/Unlocked"/ASiR Hub Local State "blocked/unblocked"
            2.SBTS ASIRMOD Operational state "enabled/disabled"/ASiR Hub Operational State "enabled/disabled"

    Arguments:
            :param oam_ip: OAM IP for ssh to nodeb
            :param connection: the connection alias if using an existing OAM connection
            :param device_name: Depends on the test line configuration, the possible values could be
                                "GNB0_ASIMGR", "ENB0_ASIMGR". Default is "GNB0_ASIMGR".
            :param str pw: account and password
            :param str ne: ip address

    Return Value:
            none

    Examples:
            Example 1: Test check_sbts_hub_status_consistency, all asirmods
            | check_sbts_hub_status_consistency |
            Example 2: Test check_sbts_hub_status_consistency, specified OAM IP
            | check_sbts_hub_status_consistency | oam_ip=192.168.255.129 |
            Example 3: Test check_sbts_hub_status_consistency, using existed connection
            | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
            | check_sbts_hub_status_consistency | connection=abc |
            Example 4: Test check_sbts_hub_status_consistency in 4G platform
            | check_sbts_hub_status_consistency | device_name=ENB0_ASIMGR |

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/02/10 | First draft version |
            | Dai Min| 1.0.0 | 2022/02/17 | First approved version by VA |
    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    asirmod_list = []
    dict_asirmod_status = {}
    for id in asirmod_list:
        dict_asirmod_status[str(id)] = None
    try:
        bts_info = adm.get_bts_info(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()
    raw_asirmod_list = bts_info['radioModules']['asirmod']
    for asirmod in raw_asirmod_list:
        id = asirmod['id']['configuration'].split('-')[-1]
        if not asirmod_list or str(id) in [str(asir) for asir in asirmod_list]:
            dict_asirmod_status[id] = asirmod['status']
    logger.info("sbts_asirmod_status:{}".format(dict_asirmod_status), also_console=True)

    all_hub_raw_status = AsiMgr(autoconnect=True, device_name=device_name, pw=pw, ne=ne).get_all_hubs_status()
    all_hub_status = _convert_orderdict_to_list_status(all_hub_raw_status)
    logger.info("All Hub Module status : {0}".format(all_hub_status))
    hubmod_list = []
    dict_hubmod_status = {}
    for index in hubmod_list:
        dict_hubmod_status[str(index)] = None
    for hub in all_hub_status:
        if not hubmod_list or hub.get('status').get('configDN').split('-')[-1] in hubmod_list:
            dict_hubmod_status[hub.get('status').get('configDN').split('-')[-1]] = hub.get('status')
    logger.info("Hub Module dict status:{}".format(dict_hubmod_status), also_console=True)

    status_items_sbts = ['operationalState', 'administrativeState']
    status_items_asir = ['operationalState', 'localState']
    hub_match_rules = {
        'operationalState': {'enabled': 'enabled', 'disabled': 'disabled'},
        'administrativeState': {'locked': 'blocked', 'unlocked': 'unblocked'}
    }

    def _compare_hub_status(status_name, sbts_status, asir_status):
        if str(sbts_status).lower().replace(" ", "") == str(asir_status).lower().replace(" ", ""):
            return True
        if sbts_status:
            if asir_status is None and hub_match_rules.get(status_name) \
                    and hub_match_rules.get(status_name).get(sbts_status.lower()).replace(" ", "") is None:
                return True
            if asir_status is not None and hub_match_rules.get(status_name) \
                    and hub_match_rules.get(status_name).get(sbts_status.lower()).replace(" ", "") == \
                    asir_status.lower().replace(" ", ""):
                return True
            return False
        return False

    result_dict = {}
    for asirmod in dict_asirmod_status:
        asirmod_id = asirmod
        if not result_dict.get(asirmod_id):
            result_dict[asirmod_id] = {}
        asirmod_status = dict_asirmod_status[asirmod_id]
        for stat_item in status_items_sbts:
            if not result_dict[asirmod_id].get(stat_item):
                result_dict[asirmod_id][stat_item] = {}
            result_dict[asirmod_id][stat_item]['sbts'] = asirmod_status[stat_item]
        hubmod_id = _get_hubmod_id_from_asirmod_id(asirmod_id)
        hubmod_status = dict_hubmod_status[hubmod_id]
        for i, stat_item in enumerate(status_items_sbts):
            if not result_dict[asirmod_id].get(stat_item):
                result_dict[asirmod_id][stat_item] = {}
            result_dict[asirmod_id][stat_item]['asir'] = hubmod_status[status_items_asir[i]]

    consistent_result = True
    consistent_info = []
    for hub_id, compare_set in result_dict.items():
        for stat_item in status_items_sbts:
            sbts_stat_val = compare_set.get(stat_item).get('sbts')
            asir_stat_val = compare_set.get(stat_item).get('asir')
            res = _compare_hub_status(stat_item, sbts_stat_val, asir_stat_val)
            if not res:
                consistent_info.append('Hub [{}] Status [{}] SBTS Value [{}] ASIR [{}]'.format(
                    hub_id, stat_item, sbts_stat_val, asir_stat_val))
                consistent_result = False
    dict_ret = {'consistent_result': consistent_result, 'result_dict': result_dict}
    if consistent_info:
        dict_ret['consistent_info'] = consistent_info
    logger.info("consistent check result is:{}".format(dict_ret), also_console=True)

    if not dict_ret['consistent_result']:
        MolerTest.error("Status check result: {}".format(dict_ret['result_dict']))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_cell_status_consistency(oam_ip="192.168.255.129", connection=None, device_name="GNB0_ASIMGR",
                                       pw="Nemuadmin:nemuuser", ne="192.168.255.129"):
    """
    Main Function:
            Check Cell Status Consistency between gNB/eNB and ASiR, if cell status is consistency in gNB/eNB and ASiR,
            the function is pass, else the function is fail and error info printed.
            Currently only cell status operationalState "enabled/disabled" is taken into account:
            If cell is locked/blocked/initializing/failed, the operationalState is disabled, otherwise is enabled.
            For ASiR cell status, as long as the operationalState of any channel in the cell is enabled, the cell
            operationalState is enabled. otherwise is disabled. In other words, the cell operationalState is disabled
            only if the operationalState of all channels in the cell are disabled.

    Limitation:
            Due to 4G site with RF Sharing mode does not have independent ASiR cell status, this keyword can not be
            used for check 4G cells status consistency of RF Sharing mode.

    Arguments:
            :param oam_ip: OAM IP for ssh to nodeb
            :param connection: the connection alias if using an existing OAM connection
            :param device_name: Depends on the test line configuration, the possible values could be
                                "GNB0_ASIMGR", "ENB0_ASIMGR". Default is "GNB0_ASIMGR".
            :param str pw: account and password
            :param str ne: ip address

    Return Value:
            none

    Examples:
            Example 1: Test check_sbts_cell_status_consistency, all cells
            | check_sbts_cell_status_consistency |
            Example 2: Test check_sbts_cell_status_consistency, specified OAM IP
            | check_sbts_cell_status_consistency | oam_ip=192.168.255.129 |
            Example 3: Test check_sbts_cell_status_consistency, using existed connection
            | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
            | check_sbts_cell_status_consistency | connection=abc |
            Example 4: Check consistency status of cells in 4G platform, if default oam_ip is not 192.168.255.129, then
            oam_ip and device_name are required
            | check_sbts_cell_status_consistency | device_name=ENB0_ASIMGR | oam_ip=192.168.255.129 |

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/02/15 | First draft version |
            | Dai Min| 1.0.0 | 2022/02/17 | First approved version by VA |
    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    cell_list = []
    sbts_cell_status = {}
    for id in cell_list:
        sbts_cell_status[str(id)] = None
    try:
        for cell_type in ["lte", "wcdma", "gsm", "nr"]:
            for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection):
                if not cell_list or str(cell_info['globalCellId']) in [str(cell) for cell in cell_list]:
                    sbts_cell_status[str(cell_info['globalCellId'])] = cell_info['status']
    finally:
        if not connection:
            adm.teardown_admin()
    logger.info("sbts_cell_status:{}".format(sbts_cell_status), also_console=True)

    path_to_file = collect_asir_commissioning(device_name=device_name, pw=pw, ne=ne, outputdir="/tmp")

    def _get_cell_status_list_via_asir(path_to_scf):
        domTree = parse(path_to_scf)
        rootNode = domTree.documentElement
        mo_list = rootNode.getElementsByTagName("managedObject")
        cells_status_dict = {}
        # Find the cell ids can mapped to sbts cell ids
        for mo in mo_list:
            if mo.hasAttribute("class") and 'CELL_R' in mo.getAttribute("class").split(":")[-1]:
                elements_p = mo.getElementsByTagName("p")
                for elem in elements_p:
                    if elem.getAttribute("name") == 'configDN':
                        configDN_splits = elem.firstChild.nodeValue.split('/')
                        if 'BTS-1' in configDN_splits:
                            logger.info("configDN found BTS-1")
                            break
                else:
                    continue
                for elem in elements_p:
                    if elem.getAttribute("name") == 'lnCelId':
                        cell_id = int(elem.firstChild.nodeValue)
                        cell_r_dist_name = mo.getAttribute('distName')
                        cell_r = cell_r_dist_name.split('/')[-1]
                        cells_status_dict[cell_id] = {'globalCellId': cell_id, 'cell_r': cell_r,
                                                      'dist_name': cell_r_dist_name, 'channels': {}}
                        break

        for mo in mo_list:
            if mo.hasAttribute("class") and 'CHANNEL_R' in mo.getAttribute("class").split(":")[-1]:
                channel_r_dist_name = mo.getAttribute('distName')
                logger.info("channel_r_dist_name: {}".format(channel_r_dist_name))
                channel_r_cell_r = None
                for s in channel_r_dist_name.split('/'):
                    if s.startswith('CELL_R'):
                        channel_r_cell_r = s
                        break
                # looking for the lnCelID related Channel
                for v in cells_status_dict.values():
                    logger.info("v: {} {}".format(v.get('dist_name'), v.get('cell_r')))
                    # the CHANNEL_R's CELL_R in the dict
                    if channel_r_dist_name.startswith(v.get('dist_name')) and channel_r_cell_r == v.get('cell_r'):
                        cell_id = v.get('globalCellId')
                        channel_name = channel_r_dist_name.split('/')[-1]
                        logger.info("cell_id: {} channel_name: {}".format(cell_id, channel_name))
                        for elem_list in mo.getElementsByTagName("list"):
                            elem_list.unlink()
                        elem_p = mo.getElementsByTagName("p")
                        for elem in elem_p:
                            if elem.getAttribute("name") == 'operationalState':
                                channel_operationalState = elem.firstChild.nodeValue
                                cells_status_dict[cell_id]['channels'][channel_name] = channel_operationalState
                                break
                        break
                else:
                    continue
        for cell_id, cell_info in cells_status_dict.items():
            # any channel is enabled, then the cell operational state is enabled, otherwise is disabled
            for item in cell_info.get('channels').values():
                if item == 'enabled':
                    cells_status_dict[cell_id]['operationalState'] = 'enabled'
                    break
            else:
                cells_status_dict[cell_id]['operationalState'] = 'disabled'
        return cells_status_dict.values()

    asir_cell_status = _get_cell_status_list_via_asir(path_to_file)
    logger.info("asir_cell_status:{}".format(asir_cell_status), also_console=True)

    status_items = ['operationalState']
    result_dict = {}
    for cell in sbts_cell_status:
        cell_id = int(cell)
        if not result_dict.get(cell_id):
            result_dict[cell_id] = {'operationalState': {}}
        result_dict[cell_id]['operationalState']['sbts'] = sbts_cell_status[cell]['operationalState']

    for cell in asir_cell_status:
        cell_id = cell['globalCellId']
        if not result_dict.get(cell_id):
            result_dict[cell_id] = {'operationalState': {}}
        result_dict[cell_id]['operationalState']['asir'] = cell['operationalState']

    consistent_result = True
    consistent_info = []
    for cell_id, compare_set in result_dict.items():
        for stat_item in status_items:
            sbts_stat_val = compare_set.get(stat_item).get('sbts')
            asir_stat_val = compare_set.get(stat_item).get('asir')
            if str(sbts_stat_val).lower().replace(" ", "") != str(asir_stat_val).lower().replace(" ", ""):
                consistent_info.append('Cell [{}] Status [{}] SBTS Value [{}] ASIR [{}]'.format(
                    cell_id, stat_item, sbts_stat_val, asir_stat_val))
                consistent_result = False
    dict_ret = {'consistent_result': consistent_result,
                'result_dict': result_dict}
    if consistent_info:
        dict_ret['consistent_info'] = consistent_info
    logger.info("consistent check result is:{}".format(dict_ret), also_console=True)

    if not dict_ret['consistent_result']:
        MolerTest.error("Status check result: {}".format(dict_ret['result_dict']))
    MolerTest.steps_end()


def get_sbts_bbmod_status(oam_ip='192.168.255.129', port=443, timeout=20, connection=None):
    """
    Main Function:
        This function collects and return bbmod status

    Arguments:
        :param oam_ip: oam_ip for 5G or 4G
        :param port: webem port number
        :param connection: alias of admin connection

    Return Value:
        :return bbmod_list: list of bbmod status

    Examples:
        *** Test Cases ***
        [1]Test case for Check Sbts BBMOD Status
        [Setup]  Setup Admin Connection
        ${bbmod_list}  Get Sbts BBMOD Status  oam_ip=xxx.xxx.xxx.xxx  connection=sbts_oam_admin
        [Teardown]  Teardown Admin Connection

        [2]Test case for Check Sbts BBMOD Status
        ${bbmod_list}  Get Sbts BBMOD Status  oam_ip=xxx.xxx.xxx.xxx

        [3]Test case for Check Sbts BBMOD Status
        ${bbmod_list}  Get Sbts BBMOD Status

    Version:
        | Author | Version | Delivery Date | Comments |
        | Wang Cuicui | 1.0.0 | 2022/3/24 | First approved version by VA |

    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    try:
        bts_info = adm.get_bts_info(timeout=timeout, connection=connection)
        bbmod_list = bts_info['basebandModules']

    finally:
        if not connection:
            adm.teardown_admin()

    if bbmod_list:
        return bbmod_list


def get_sbts_bbmod_status_via_virtual_machine_lmp(vm_ip, vm_user, vm_password,
                                                  vm_ssh_port=22, lmp='192.168.255.129', https_port=443):
    """
    Main Function:
        This function collects and return bbmod status

        The most common case for using this keyword is like this:
        - test line configuration: 5G + 4G
        - test cases are running on 5G VM
        - configuration reset was conducted on 4G eNB in test case. The next step will be to
        get 4G bbmod status
        .
    Arguments:
        :param vm_ip: IP for virtual machine connected to target SBTS LMP
        :param vm_user: username of virtual machine connected to target SBTS LMP
        :param vm_password: password of virtual machine connected to target SBTS LMP
        :param vm_ssh_port: SSH port of of virtual machine connected to target SBTS LMP
        :param lmp: target SBTS LMP ip address
        :param https_port: https service port of target SBTS

    Return Value:
        :return bbmod_list: list of bbmod status

    Examples:
        *** Test Cases ***
        Test case for Check Sbts BBMOD Status
        ${bbmod_list}  Get Sbts BBMOD Status_Via_Virtual_Machine_Lmp  vm_ip=10.66.29.32
        ...  vm_user=ute  vm_password=ute


    Version:
        | Author | Version | Delivery Date | Comments |
        | Wang Cuicui | 1.0.0 | 2022/3/24 | First approved version by VA |

    """

    try:
        with sshtunnel.open_tunnel(
                ssh_address_or_host=(vm_ip, int(vm_ssh_port)),
                remote_bind_address=(lmp, https_port),
                ssh_username=vm_user,
                ssh_password=vm_password,
                block_on_close=False,
        ) as tunnel1:
            time.sleep(5)
            bbmod_list = get_sbts_bbmod_status(oam_ip='127.0.0.1', connection=None, port=tunnel1.local_bind_port)

    except Exception as e:
        MolerTest.error(str(e))
    finally:
        MolerTest.steps_end()

    if bbmod_list:
        return bbmod_list


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_all_sbts_bbmod_status_when_uncommissioned(bbmod_list, dict_check_status):
    """
    Main Function:
        This function check bbmod status when gnb under uncommission status,
        if gnb have commission please use keyword check_sbts_bbmod_status

    Arguments:
        :param bbmod_list: a list retrun from keyword get_sbts_bbmod_status
        :param dict_check_status: a dictionary inculde expect bbmod status

    Return Value:
        :return None

    Examples:
        *** Test Cases ***
        [1]Test case for Check Sbts BBMOD Status
        [Setup]  Setup Admin Connection
        ${expect_bbmod_status}  Create Dictionary  availabilityStatus=online
        ${bbmod_list}  Get Sbts BBMOD Status  oam_ip=xxx.xxx.xxx.xxx  connection=sbts_oam_admin
        Check All Sbts BBmod Status When Uncommissioned  ${bbmod_list}   ${expect_bbmod_status}
        [Teardown]  Teardown Admin Connection

        [2]Test case for Check Sbts BBMOD Status
        ${expect_bbmod_status}  Create Dictionary  availabilityStatus=online
        ${bbmod_list}  Get Sbts BBMOD Status  oam_ip=xxx.xxx.xxx.xxx
        Check All Sbts BBmod Status When Uncommissioned  ${bbmod_list}   ${expect_bbmod_status}

        [3]Test case for Check Sbts BBMOD Status
        ${expect_bbmod_status}  Create Dictionary  availabilityStatus=online
        ${bbmod_list}  Get Sbts BBMOD Status
        Check All Sbts BBmod Status When Uncommissioned  ${bbmod_list}   ${expect_bbmod_status}

        Others usage please study how to use Setup Admin Connection

    Version:
        | Author | Version | Delivery Date | Comments |
        | Wang Cuicui | 1.0.0 | 2022/3/24 | First approved version by VA |

    """

    check_result = True
    dict_result = {}

    if bbmod_list:
        for bbmod in bbmod_list:
            dict_bbmod_status = bbmod.get('status')
            if 'availabilityStatus' not in dict_bbmod_status or dict_bbmod_status['availabilityStatus'] == '':
                dict_bbmod_status['availabilityStatus'] = 'online'
            for k, v in dict_check_status.items():
                if dict_bbmod_status.get(k).lower().replace(' ', '') != str(v).lower().replace(' ', ''):
                    check_result = False
                    bbmod_runtime_id = bbmod.get('id').get('runtime').split('-')[-1]

                    if not dict_result.get(bbmod_runtime_id):
                        dict_result[bbmod_runtime_id] = {'runtime_id': bbmod_runtime_id}
                        dict_result[bbmod_runtime_id][k] = {'real_value': dict_bbmod_status.get(k),
                                                            'expect_value': str(v)}
    else:
        check_result = False

    if check_result:
        logger.info({'check_result': check_result, 'check_info': 'Check successfully',
                     'dict_result': dict_result}, also_console=True)
    else:
        logger.info({'check_result': check_result, 'check_info': 'Check Failed', 'dict_result': dict_result},
                    also_console=True)
        MolerTest.error('Check runtime BBMOD status failed with info {}'.format(dict_result))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def get_macro_xmod_r_xmod_mapping(mo_class=None, oam_ip='192.168.255.129'):
    """
    Main Function:
        This internal function is get XMOD_R XMOD mapping relationship.

    Arguments:
        :param mo_class: such as 'SMOD_R', 'BBMOD_R', 'ASIRMOD_R', 'CABLINK_R', 'CELL_R', etc.
        :param oam_ip: oam_ip for 5G or 4G

    Limitation:
        mo_class can not be 'SFP_R', 'MRBTS_R'

    Return Value:
        :return runtime_configure_dict

    Examples:
        ${asirmod_mapping_dict}=    get_macro_xmod_r_xmod_mapping  mo_class=ASIRMOD_R
        ${bbmod_mapping_dict}=      get_macro_xmod_r_xmod_mapping  mo_class=BBMOD_R
        ${gnsse_mapping_dict}=      get_macro_xmod_r_xmod_mapping  mo_class=GNSSE_R
        ${asiantl_mapping_dict}=    get_macro_xmod_r_xmod_mapping  mo_class=ASIANTL_R
        ${smod_mapping_dict}=       get_macro_xmod_r_xmod_mapping  mo_class=SMOD_R
        ${cablink_mapping_dict}=    get_macro_xmod_r_xmod_mapping  mo_class=CABLINK_R
        ${cell_mapping_dict}=       get_macro_xmod_r_xmod_mapping  mo_class=CELL_R

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/04/18 | First draft version |
            | Dai Min| 1.0.0 | 2022/04/20 | First approved version by VA |
    """
    runtime_configure_dict = {}
    adm = admin()
    connection = adm.setup_admin(bts_host=oam_ip, name=mo_class)

    try:
        mo_r_class = mo_class if mo_class.endswith('_R') else '{}_R'.format(mo_class)
        xmod_info = adm.get_managed_objects(class_name=mo_r_class, connection=connection)
        bts_info = adm.get_bts_info(connection=connection)
        logger.info("xmod_info:{}".format(xmod_info))

    except AdminApiProcedureFailureException:
        logger.error("Unsupported MO Class:{}".format(mo_class))

    finally:
        adm.teardown_admin(connection=mo_class)

    if mo_r_class.lower() != 'cell_r':
        for xmod in xmod_info:
            xmod_r = xmod['distName'].split('/')[-1]
            xmod_name = xmod_r.split('_')[0]
            runtime_configure_dict[str(xmod_r)] = str(xmod_name) + '-' + str(
                xmod['parameters']['configDN'].split('-')[-1])

    else:
        cell_info = bts_info['cells']
        for cell_type in ["lte", "wcdma", "gsm", "nr"]:
            cell_list = cell_info.get(cell_type)
            for cell in cell_list:
                cell_config = cell['id']['configuration'].split('/')[-1]
                cell_internal = cell['id']['internal'].split('/')[-1]
                runtime_configure_dict[str(cell_internal)] = str(cell_config)
    logger.info("runtime_configure_dict:{}".format(runtime_configure_dict), also_console=True)

    MolerTest.steps_end()
    return runtime_configure_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def get_asirmod_cablinkr_mapping_info(dict_condition=None, oam_ip="192.168.255.129", connection=None):
    """
    Main Function:
        This function is get ASiRMOD CABLINK_R status.
        If dict_condition is None, then return all CABLINK_R info,
        else, return all cablink detail info that meet dict_condition.

    Arguments:
        :param dict_condition: a dictionary inculding expected CABLINK_R info
        :param oam_ip: oam_ip for 5G or 4G
        :param connection: alias of admin connection

    Return Value:
        :return asirmod_cablinkr_mapping_dict

    Examples:
        *** Test Cases ***
        [1]Test case for Check 5G ASIRMOD cablink_r mapping info
        Log To Console  \n*** ALL CABLINK_R ***
        ${cablink_info}  Get ASIRMOD CABLINKR Mapping Info
        Log To Console  \n*** Filtered CABLINK_R ***
        ${dict_condition}  Create Dictionary  linkSpeed=ecpri25
        ${cablink_info}  Get ASIRMOD CABLINKR Mapping Info  dict_condition=${dict_condition}

        [2]Test case for Check 4G ASIRMOD cablink_r mapping info
        Log To Console  \n*** ALL CABLINK_R ***
        ${cablink_info}  Get ASIRMOD CABLINKR Mapping Info  oam_ip=172.30.1.10
        Log To Console  \n*** Filtered CABLINK_R ***
        ${dict_condition}  Create Dictionary  linkModeConfiguration=true  linkModeSynchronization=true  linkSpeed=cpri7
        ${cablink_info}  Get ASIRMOD CABLINKR Mapping Info  dict_condition=${dict_condition}  oam_ip=172.30.1.10

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/04/18 | First draft version |
            | Dai Min| 1.0.0 | 2022/04/20 | First approved version by VA |
    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    try:
        cablink_r_list = adm.get_managed_objects(class_name='CABLINK_R', connection=connection)
        logger.info("cablink_r_list:{}".format(cablink_r_list))

    finally:
        if not connection:
            adm.teardown_admin()

    asirmod_cablinkr_mapping_dict = {}
    all_asirmod_cablinkr_dict = {}
    for cablink_r in cablink_r_list:
        cablinkr_dic = {}
        asirmod_key = cablink_r.get('parameters').get('secondEndpointDN').split('/')[-1]
        cablinkr_key = cablink_r.get('distName').split('/')[-1]
        cablinkr_dic[str(cablinkr_key)] = cablink_r.get('parameters')
        if not all_asirmod_cablinkr_dict.get(asirmod_key):
            all_asirmod_cablinkr_dict[str(asirmod_key)] = []
        all_asirmod_cablinkr_dict[str(asirmod_key)].append(cablinkr_dic)

    # filter according to the dict_condition
    asirmodr_cablinkr_mapping_dict = {}
    for xmod_r, cablinkr_list in all_asirmod_cablinkr_dict.items():
        if xmod_r.split('_')[0] == 'ASIRMOD':
            if not dict_condition:
                asirmodr_cablinkr_mapping_dict[xmod_r] = cablinkr_list
            else:
                filter_list = []
                for cablink_r in cablinkr_list:
                    k = list(cablink_r.keys())[0]
                    v = cablink_r.get(str(k))
                    for k_s, v_s in dict_condition.items():
                        if not str(v_s).lower() == str(v.get(str(k_s))).lower():
                            break
                    else:
                        filter_list.append(cablink_r)
                asirmodr_cablinkr_mapping_dict[xmod_r] = filter_list

    # covert ASIRMOD_R-x to ASIRMOD-x
    asirmod_mapping_dict = get_macro_xmod_r_xmod_mapping(mo_class='ASIRMOD_R', oam_ip=oam_ip)
    for asirmod_r, cablinkr_list in asirmodr_cablinkr_mapping_dict.items():
        asirmod_name = asirmod_mapping_dict.get(asirmod_r)
        asirmod_cablinkr_mapping_dict[asirmod_name] = cablinkr_list
    logger.info("asirmod_cablinkr_mapping_dict:{}".format(asirmod_cablinkr_mapping_dict), also_console=True)

    MolerTest.steps_end()
    return asirmod_cablinkr_mapping_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def get_macro_celllist_from_xmod(mo_class=None, xmod_id_list=None, xmod_type='configuration', oam_ip="192.168.255.129",
                                 connection=None):
    """
    Main Function:
        This function is get macro cell list releated to xmod.
        If xmod_id_list is None, then return all mo_class releated cell list,
        else, return dedicated cell info that meet xmod_id_list.

    Arguments:
        :param mo_class: for example: CABLINK_R/ASIRMOD_R
        :param xmod_id_list: this is configuration id, for example ['1', '2', '3']
                             default is None which means will retrun all xmod related info
        :param xmod_type: runtime or configuration, default is configuration
        :param oam_ip: oam_ip for 5G or 4G
        :param connection: alias of admin connection

    Return Value:
        :return xmod_celllist_dict, for cell id, always configuration id

    Examples:
        *** Test Cases ***
        [1]Test case for Check 5G XMOD cell list
        Log To Console  \n*** cell_list1 ***
        ${cell_list1}  Get Macro Celllist From XMOD  mo_class=CABLINK  xmod_type=runtime  xmod_id_list=${None}
        Log To Console  \n*** cell_list2 ***
        ${cell_list2}  Get Macro Celllist From XMOD  mo_class=CABLINK_R  xmod_id_list=1 2 3 4  xmod_type=runtime
        Log To Console  \n*** cell_list3 ***
        ${id_list}  Create List  1  2  3
        ${cell_list3}  Get Macro Celllist From XMOD  mo_class=CABLINK_R  xmod_id_list=${id_list}  xmod_type=runtime
        Log To Console  \n*** cell_list4 ***
        ${cell_list4}  Get Macro Celllist From XMOD  mo_class=ASIRMOD

        [2]Test case for Check 4G XMOD cell list
        Log To Console  \n*** cell_list1 ***
        ${cell_list1}  Get Macro Celllist From XMOD  mo_class=CABLINK_R  xmod_type=runtime  oam_ip=172.30.1.10
        Log To Console  \n*** cell_list2 ***
        ${cell_list2}  Get Macro Celllist From XMOD  mo_class=CABLINK_R  xmod_id_list=1 2 4 6  oam_ip=172.30.1.10
        Log To Console  \n*** cell_list3 ***
        ${id_list}  Create List  1  2  4
        ${cell_list3}  Get Macro Celllist From XMOD  mo_class=CABLINK_R  xmod_id_list=${id_list}  oam_ip=172.30.1.10
        Log To Console  \n*** cell_list4 ***
        ${cell_list4}  Get Macro Celllist From XMOD  mo_class=ASIRMOD_R  oam_ip=172.30.1.10

    Version:
            | Author | Version | Delivery Date | Comments |
            | Dai Min| 0.0.1 | 2022/04/18 | First draft version |
            | Dai Min| 1.0.0 | 2022/04/20 | First approved version by VA |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)

    if xmod_id_list is not None:
        xmod_id_list = xmod_id_list if isinstance(xmod_id_list, list) else str(xmod_id_list).split()
    xmod_celllist_dict = {}

    try:
        assert mo_class, "mo_class is not provided"
        mo_r_class = mo_class if mo_class.endswith('_R') else '{}_R'.format(mo_class)
        mo_list = adm.get_managed_objects(class_name=mo_r_class, connection=connection)
        runtime_mo_cell_dict = {}
        cell_mapping_dict = get_macro_xmod_r_xmod_mapping(mo_class='CELL_R', oam_ip=oam_ip)
        for mo_ele in mo_list:
            mo_name = str(mo_ele.get('distName').split('/')[-1])
            cellr_list = adm.get_cell_mapping_by_module_id(module_id=mo_name, connection=connection)

            cellid_list = []
            for cellr in cellr_list:
                for cell_r, cell_c in cell_mapping_dict.items():
                    if cellr.split('/')[-1] == cell_r:
                        cellid = cell_c.split('-')[-1]
                        cellid_list.append(str(cellid))
            runtime_mo_cell_dict[mo_name] = sorted(cellid_list)

        # covert runtime_mo to configuration_mo
        configuration_mo_cell_dict = {}
        runtime_configure_mapping_dict = get_macro_xmod_r_xmod_mapping(mo_class=mo_r_class, oam_ip=oam_ip)
        for mo_k, mo_v in runtime_mo_cell_dict.items():
            for runtime_k, config_v in runtime_configure_mapping_dict.items():
                if mo_k == runtime_k:
                    configuration_mo_cell_dict[config_v] = mo_v
                    break

        # filter according to xmod_id_list
        if xmod_id_list:
            if xmod_type.lower() != 'runtime':
                for id in xmod_id_list:
                    for config_k, config_v in configuration_mo_cell_dict.items():
                        if config_k.split('-')[-1] == id:
                            xmod_celllist_dict[config_k] = config_v
                            break
            else:
                for id in xmod_id_list:
                    for config_k, config_v in configuration_mo_cell_dict.items():
                        if config_k.split('-')[-1] == id:
                            for k, v in runtime_configure_mapping_dict.items():
                                if v == config_k:
                                    key = k
                                    break
                            xmod_celllist_dict[str(key)] = config_v
                            break
        else:
            if xmod_type.lower() != 'runtime':
                xmod_celllist_dict = configuration_mo_cell_dict
            else:
                xmod_celllist_dict = runtime_mo_cell_dict

        logger.info("xmod_celllist_dict:{}".format(xmod_celllist_dict), also_console=True)

    finally:
        if not connection:
            adm.teardown_admin()

    MolerTest.steps_end()
    return xmod_celllist_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def operate_sbts_rat(operation, rat, oam_ip='192.168.255.129', connection=None, timeout=60):
    """
    Main Function:
        This function operate sbts rat with opeartions: block, unblock, reset.
        The timeout of reset rat suggest to set 300 by manual.

    Arguments:
        :param operation: string for operation: block | unblock | reset, others are not supported
        :param rat: string for rat technology: NR | LTE, others are not supported
        :param oam_ip: OAM IP for ssh to nodeb
        :param connection: the connection alias if using an existing OAM connection
        :param timeout: Default timeout is 60s, but Highlight that for reset, the timeout suggestion to 300s!
    Return Value:
        :return None

    Examples:
        *** Test Cases ***
        [1]Test case for Block NR RAT
        Operate sbts rat  "Block"  "NR"  oam_ip="xxx.xxx.xxx.xxx"
        [2]Test case for reset LTE RAT
        Operate sbts rat  "reset"  "LTE"  oam_ip="xxx.xxx.xxx.xxx"

    Version:
        | Author | Version | Delivery Date | Comments |
        | Wu Guozhen | 0.0.1 | 2022/04/15 | First draft version |
        | Wu Guozhen | 1.0.0 | 2022/04/28 | First approved version by VA |
    """
    adm = admin()
    if operation.lower() not in ['block', 'unblock', 'reset']:
        raise Exception("operation {0} is not supported.".format(operation))

    if rat.upper() not in ['LTE', 'NR']:
        raise Exception("rat {0} is not supported.".format(rat))
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)

        if operation.lower() == 'block':
            result = adm.block_rat(rat.upper(), timeout=timeout, connection=connection)
        elif operation.lower() == 'unblock':
            result = adm.unblock_rat(rat.upper(), timeout=timeout, connection=connection)
        else:
            result = adm.rat_reset(rat.upper(), timeout=timeout, connection=connection)
        logger.info("RAT Operate:{0} {1} has done with result: {2}".format(rat, operation, result),
                    also_console=True)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()
    MolerTest.steps_end()


def get_sbts_cell_ids_by_dedicated_rat(rat="ALL", oam_ip="192.168.255.129", connection=None, timeout=60):
    """
    Main Function:
            Get NR/LTE/ALL cell list.

    Arguments:
            :param rat: Depends on the technology of the cells, the possible values could be
                         "NR", "LTE", "ALL"
            :param oam_ip: IP for BTS LMP or mplane
            :param connection: the connection alias if using an existing OAM connection
            :param timeout: Keyword execution timeout

    Return Value:
            :return: dist_cell_ids: dict info

    Examples:
            Example 1: Get NR cell ids
            Get SBTS Cell Ids By Dedicated RAT  rat=NR
            Example 2: Get LTE cell ids
            Get SBTS Cell Ids By Dedicated RAT  rat=LTE
            Example 3: Get All cell ids
            Get SBTS Cell Ids By Dedicated RAT

    Version:
            | Author | Version | Delivery Date | Comments |
            | Xu Yan | 0.0.1 | 2022/04/15 | First draft version |
            | Xu Yan| 1.0.0 | 2022/04/28 | First approved version by VA |
    """
    adm = admin()
    dist_cell_ids = {}
    rat = rat.lower()
    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        for cell_type in ["nr", "lte"]:
            dist_cell_ids[cell_type] = []
            for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection, timeout=timeout):
                dist_cell_ids[cell_type].append(cell_info['globalCellId'])
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()

    return dist_cell_ids if rat == 'all' else {rat: dist_cell_ids[rat]}


def get_sbts_rat_status(rat="ALL", oam_ip="192.168.255.129", connection=None, timeout=60):
    """
    Main Function:
            Get LTE/NR RAT status.

    Arguments:
            :param rat: Depends on the technology of the RAT, the possible values could be
                         "NR", "LTE", "ALL"
            :param oam_ip: IP for BTS LMP or mplane
            :param connection: the connection alias if using an existing OAM connection
            :param timeout: Keyword execution timeout

    Return Value:
            :return: dist_rat_status: dict info

    Examples:
            Example 1: Get NR RAT status
            Get SBTS RAT Status  rat=NR
            Example 2: Get LTE RAT status
            Get SBTS RAT Status  rat=LTE
            Example 3: Get All RAT status
            Get SBTS RAT Status

    Version:
            | Author | Version | Delivery Date | Comments |
            | Xu Yan | 0.0.1 | 2022/04/19 | First draft version |
            | Xu Yan| 1.0.0 | 2022/04/28 | First approved version by VA |
    """
    adm = admin()
    dist_rat_status = {}
    rat = rat.lower()

    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        bts_info = adm.get_bts_info(connection=connection, timeout=timeout)
        rat_state = bts_info['ratState']
        for rat_type in ["nr", "lte"]:
            if rat == 'all' or rat_type == rat:
                dist_rat_status[rat_type] = rat_state[rat_type]
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()

    return dist_rat_status


def get_sbts_xmods_by_rat(module, rat='ALL', oam_ip="192.168.255.129", connection=None, timeout=60):
    """
    Main Function:
            Get LTE/NR BBMOD/RMOD/SMOD id list.

    Arguments:
            :param module: "BBMOD", "ASiRMOD", "SMOD"
            :param rat: Depends on the technology of the xMod, the possible values could be
                         "NR", "LTE", "mix"
            :param oam_ip: IP for BTS LMP or mplane
            :param connection: the connection alias if using an existing OAM connection
            :param timeout: Keyword execution timeout

    Return Value:
            :return: dist_xmods_id: dict info

    Examples:
            Example 1: Get NR BBMOD id list
            Get SBTS xMODs By RAT  Module=BBMOD  rat=NR
            Example 2: Get LTE BBMOD id list
            Get SBTS xMODs By RAT  Module=BBMOD  rat=NR
            Example 3: Get mix BBMOD id list
            Get SBTS xMODs By RAT  Module=BBMOD  rat=Mix
            Example 4: Get NR BBMOD id list
            Get SBTS xMODs By RAT  Module=ASiRMOD  rat=NR

    Version:
            | Author | Version | Delivery Date | Comments |
            | Xu Yan | 0.0.1 | 2022/04/19 | First draft version |
            | Xu Yan| 1.0.0 | 2022/04/28 | First approved version by VA |
    """
    adm = admin()
    dist_xmods_id = {}
    dist_cell_info = {}
    dist_xmods_info = {}
    dist_internal_cell_by_xmod = {}
    rat = rat.lower()

    try:
        if not connection:
            adm.setup_admin(bts_host=oam_ip)
        for cell_type in ["nr", "lte"]:
            dist_cell_info[cell_type] = []
            for cell_info in adm.get_cells_info(cell_type=cell_type, connection=connection, timeout=timeout):
                dist_cell_info[cell_type].append(cell_info['id']['internal'])
        bts_info = adm.get_bts_info(connection=connection, timeout=timeout)
        for xmod_type in ["basebandModules", "systemModules", "radioModules"]:
            dist_xmods_info[xmod_type] = []
            xmod_list = bts_info[xmod_type]['asirmod'] if xmod_type == "radioModules" else bts_info[xmod_type]
            for asirmod in xmod_list:
                dist_xmods_info[xmod_type].append(asirmod['id'])
                internal_cell = adm.get_cell_mapping_by_module_id(module_id=asirmod['id']['internal'])
                xmod = asirmod['id']['configuration'].split('/')[-1]
                dist_internal_cell_by_xmod[xmod] = internal_cell
        for tech in ['nr', 'lte', 'mix']:
            if not dist_xmods_id.get(tech.lower()):
                dist_xmods_id[tech.lower()] = []
        for k, v in dist_internal_cell_by_xmod.items():
            xmod_module = k.split('-')[0]
            xmod_id = k.split('-')[-1]
            if xmod_module == module.upper():
                for tech in ["nr", "lte"]:
                    if set(v).intersection(set(dist_cell_info[tech])):
                        dist_xmods_id[tech].append(xmod_id)
                if set(v).intersection(set(dist_cell_info['nr'])) and set(v).intersection(set(dist_cell_info['lte'])):
                    dist_xmods_id['mix'].append(xmod_id)
    except Exception as e:
        MolerTest.error(str(e))
    finally:
        if not connection:
            adm.teardown_admin()

    return {rat: dist_xmods_id.get(rat, [])} if rat != 'all' else dist_xmods_id


def set_cmp_server_settings(reference_number=None, preshared_key=None, timeout=60, detailed_output=False,
                            key_pool_type="RSA", oam_ip="192.168.255.129", connection=None):
    """
    Main Function:
        This function is set CMP server settings.

    Arguments:
        :param string reference_number: Reference number
        :param string preshared_key: Pre-shared key.
        :param Union[str, int] timeout: Time to wait for positive procedure result.
        :param bool detailed_output: return full request response when True, defaults set to False.
        :param string key_pool_type: key pool type ["RSA"|"ECDSA"]
        :param oam_ip: IP for BTS LMP or mplane
        :param Union[AdminConnection,str] connection: AdminConnection object or if used, string name alias.

    Return Value:
        :return: Union[str, dict]: operation status when detailed_output is False else full response.

    Examples:
        | ${output} | Set CMP Server Settings | reference_number=17538 | preshared_key=fNoz-4QR2-szLA-Magf |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Dai Min| 0.0.1 | 2022/07/07 | First draft version |
        | Dai Min| 1.0.0 | 2022/07/30 | First approved version by VA |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        output = adm.set_certificate_automatic_management(reference_number=reference_number,
                                                          preshared_key=preshared_key,
                                                          timeout=timeout,
                                                          connection=connection, detailed_output=detailed_output,
                                                          key_pool_type=key_pool_type)
    finally:
        if not connection:
            adm.teardown_admin()
    return output


def cmp_key_update(timeout=60, detailed_output=False, key_pool_type="RSA", oam_ip="192.168.255.129", connection=None):
    """
    Main Function:
        This function is update CMP key.

    Arguments:
        :param Union[str, int] timeout: Time to wait for positive procedure result.
        :param Union[AdminConnection,str] connection: AdminConnection object or if used, string name alias.
        :param bool detailed_output: return full request response when True, defaults set to False.
        :param string key_pool_type: key pool type ["RSA"|"ECDSA"]
        :return: Union[str, dict]: operation status i.e. "Rejected" or "Failed" when detailed_output
            is False else full response.
        :param oam_ip: IP for BTS LMP or mplane
        :param Union[AdminConnection,str] connection: AdminConnection object or if used, string name alias.

    Return Value:
        :return: Union[str, dict]: operation status when detailed_output is False else full response.

    Examples:
        | ${output} | CMP Key Update |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Dai Min| 0.0.1 | 2022/07/07 | First draft version |
        | Dai Min| 1.0.0 | 2022/07/30 | First approved version by VA |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        output = adm.cmp_update_key(timeout=timeout, detailed_output=detailed_output, key_pool_type=key_pool_type)
    finally:
        if not connection:
            adm.teardown_admin()
    return output


def cmp_initialize_certificates(timeout=60, detailed_output=False, key_pool_type="RSA", oam_ip="192.168.255.129",
                                connection=None):
    """
    Main Function:
        This function is CMP initialize certificate.

    Arguments:
        :param Union[str, int] timeout: Time to wait for positive procedure result.
        :param bool detailed_output: return full request response when True, defaults set to False.
        :param string key_pool_type: key pool type ["RSA"|"ECDSA"]
        :param oam_ip: IP for BTS LMP or mplane
        :param Union[AdminConnection,str] connection: AdminConnection object or if used, string name alias.

    Return Value:
        :return: Union[str, dict]: operation status i.e. "Rejected" or "Failed" when detailed_output
            is False else full response.

    Examples:
        | ${output} | CMP Initialize Certificates |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Dai Min| 0.0.1 | 2022/07/07 | First draft version |
        | Dai Min| 1.0.0 | 2022/07/30 | First approved version by VA |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        output = adm.cmp_initialize_certificate(timeout=timeout, detailed_output=detailed_output,
                                                key_pool_type=key_pool_type)
    finally:
        if not connection:
            adm.teardown_admin()
    return output


def install_certificates(cert_file, cert_type, cert_format, password=None, timeout=60, detailed_output=False,
                         key_pool_type=None, oam_ip="192.168.255.129", connection=None):
    """
    Main Function:
        This function is install certificate on MRBTS.

    Arguments:
        :param str cert_file: Certificate file path.
        :param str cert_type: Certificate type, one of: ["BtsTrustChain", "AdditionalCa", "CBRSVendorChain",
            "CBRSAdditionalCa"]
        :param str cert_format: Certificate format, one of: ["PEM", "P12", "DER"]
        :param str password: (optional) Certificate password.
        :param Union[str, int] timeout: Time to wait for positive procedure result.
        :param bool detailed_output: return full request response when True, defaults set to False.
        :param string key_pool_type: (optional) Certificate key pool type.
        :param oam_ip: IP for BTS LMP or mplane
        :param Union[AdminConnection,str] connection: AdminConnection object or if used, string name alias.

    Return Value:
        :return: Union[str, dict]: operation status when detailed_output is False else full response.
        :raises: ValueError if cert_type does not meet one of the given values.
        :raises: ValueError if cert_format does not meet one of the given values.

    Examples:
        | ${output} | Install Certificate | cert_file=${cert_file} | cert_type=${cert_type}|
        | ... cert_format=${cert_format} |

    Version:
        | Author | Version | Delivery Date | Comments |
        | Dai Min| 0.0.1 | 2022/07/07 | First draft version |
        | Dai Min| 1.0.0 | 2022/07/30 | First approved version by VA |
        | Wang Cuicui| 1.0.1 | 2022/10/18 | Add input parameter key_pool_type |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        output = adm.install_certificate(cert_file=cert_file,
                                         cert_type=cert_type,
                                         cert_format=cert_format,
                                         password=password,
                                         timeout=timeout,
                                         detailed_output=detailed_output,
                                         key_pool_type=key_pool_type)
    finally:
        if not connection:
            adm.teardown_admin()
    return output


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_active_alarm_custom(forbidden_fault_filters=None, allowed_fault_filters=None,
                                   required_fault_filters=None, oam_ip="192.168.255.129", connection=None):
    """
        Main Function:
            Get SBTS' active alarms and check if the alarms match given 3 filters group, forbidden/allowed/required.
            If one filters is not specified or None, the keyword will skip the check
            If check fails, Moler will print the result

        Arguments:
            :param forbidden_fault_filters: Filters for alarm should not appear
            :param allowed_fault_filters: Filters for alarms are allowed to appear
            :param required_fault_filters: Filters for alarms should appear
            :param oam_ip: OAM IP
            :param connection: existing connection
        Return Value:
            None

        Examples:
            Example 1: Check Sbts Active Alarm Custom, only allowed filter given
            # alarmId == 7220, max allowed appearance is 5
            ${allowed_alarm_1}  Create Dictionary  alarmId=7220  count=5
            # alarmId in 7107 7114 7115
            ${allowed_alarm_2}  Create Dictionary  alarmId=7107|7114|7115
            # faultId == 61029 and faultId == 61029
            ${allowed_alarm_3}  Create Dictionary  alarmId=61029  faultId=61029
            # faultId == 7523 and configObjectName match the regex
            ${allowed_alarm_4}  Create Dictionary  faultId=7523  configObjectName=NRBTS-\\d{1}/NRCELL-\\d{1}
            ${allowed_filter}  Create List  ${allowed_alarm_1}  ${allowed_alarm_2}  ${allowed_alarm_3}
            ...  ${allowed_alarm_4}
            SBTS_KW.Check Sbts Active Alarm Custom  allowed_fault_filters=${allowed_filter}

            Example 2:Check Sbts Active Alarm Custom, all filters given,
                required fault will be merged into allowed filter
            # alarmId == 7220, max allowed appearance is 5
            ${allowed_alarm_1}  Create Dictionary  alarmId=7220  count=5
            # alarmId in 7107 7114
            ${allowed_alarm_2}  Create Dictionary  alarmId=7107
            ${allowed_filter}  Create List  ${allowed_alarm_1}  ${allowed_alarm_2}

            # alarmId == 7114
            ${forbidden_alarm_1}  Create Dictionary  alarmId=7114
            #faultId == 7523 and configObjectName match the regex
            ${forbidden_alarm_2}  Create Dictionary  faultId=7523  configObjectName=NRBTS-\\d{1}/NRCELL-\\d{1}
            ${forbidden_filter}  Create List   ${forbidden_alarm_1}  ${forbidden_alarm_2}

            # faultId in 61648 61649 and accurate count is 2
            ${required_alarm_1}  Create Dictionary  faultId=61648|61649  count=2
            ${required_filter}  Create List   ${required_alarm_1}

            SBTS_KW.Check Sbts Active Alarm Custom  allowed_fault_filters=${allowed_filter}
            ...  forbidden_fault_filters=${forbidden_filter}  required_fault_filters=${required_filter}

            Example 3: Check Sbts Active Alarm Custom, only required filter given, with existed connection
            SBTS_KW.Setup Admin Connection  oam_ip=192.168.255.129    connection=bbb
            # alarmId == 7220, accurate appearance time == 5
            ${required_alarm_1}  Create Dictionary  alarmId=7220  count=5
            ${required_filter}  Create List   ${required_alarm_1}
            SBTS_KW.Check Sbts Active Alarm Custom  required_fault_filters=${required_filter}  connection=bbb
            [Teardown]  SBTS_KW.Teardown Admin Connection  connection=bbb

            Example 4: Check Sbts Active Alarm Custom, only required filter given, with oam_ip
            ${required_alarm_1}  Create Dictionary  alarmId=7220  count=5
            ${required_filter}  Create List   ${required_alarm_1}
            SBTS_KW.Check Sbts Active Alarm Custom  required_fault_filters=${required_filter}  oam_ip=192.168.255.129

            Example 5: Check Sbts Active Alarm Custom, with a sophisticated required filter, that the regex and count
            are computed.

            ${cell_list}  Create List  1  2
            SBTS_KW.Block Sbts Cell  cell_list=${cell_list}

            ${configObjectName_regex}  evaluate  "NRCELL-({cells})$".format(cells="|".join(@{cell_list}))
            ${alarm_cnt}  Get Length  ${cell_list}

            ${required_alarm_1}  Create Dictionary  faultId=49  configObjectName=${configObjectName_regex}
            ...  count=${alarm_cnt}
            ${required_filter}  Create List   ${required_alarm_1}
            SBTS_KW.Check Sbts Active Alarm Custom  required_fault_filters=${required_filter}
        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/08/24 | First draft version |
            | fuzengz| 1.0.0 | 2022/08/26 | First approved version by VA |
    """
    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip)
    try:
        alarm_list = adm.get_active_alarms(connection=connection)
        MolerTest.info("Active alarms retrieved are: {}".format(alarm_list))
    finally:
        if not connection:
            adm.teardown_admin()

    result_dict = \
        _verify_faults_custom(alarm_list, forbidden_fault_filters, allowed_fault_filters, required_fault_filters)
    pprint(result_dict)
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sbts_history_alarm_custom(forbidden_fault_filters=None, allowed_fault_filters=None,
                                    required_fault_filters=None, connection="sbts_oam_admin"):
    """
        Main Function:
            Get SBTS' history alarms and check if the alarms match given 3 filters group, forbidden/allowed/required.
            If one filters is not specified or None, the keyword will skip the check
            If check fails, Moler will print the result

        Arguments:
            :param forbidden_fault_filters: Filters for alarm should not appear
            :param allowed_fault_filters: Filters for alarms are allowed to appear
            :param required_fault_filters: Filters for alarms should appear
            :param connection: existing connection
        Return Value:
            None

        Examples:
            Example 1: Check Sbts History Alarm Custom, only allowed filter given
            [Setup]  SBTS_KW.Setup Admin Connection
            run keyword and ignore error  SBTS_KW.Block SBTS Cell  connection=sbts_oam_admin
            ${expected_blocked_status}  Create Dictionary  blockingState=Blocked
            Wait Until Keyword Succeeds  2min  10s  SBTS_KW.Check SBTS Cell Status  bbmod_id_list=1
            ...  expected_status_dict=${expected_blocked_status}  connection=sbts_oam_admin

            SBTS_KW.Unblock SBTS Cell  connection=sbts_oam_admin
            ${expected_unblocked_status}  Create Dictionary  blockingState=Unblocked
            Wait Until Keyword Succeeds  2min  10s  SBTS_KW.Check SBTS Cell Status  bbmod_id_list=1
            ...  expected_status_dict=${expected_unblocked_status}  connection=sbts_oam_admin

            # faultId == 49, and configObjectName match the regex, max allowed appearance is 2
            ${allowed_alarm_1}  Create Dictionary  faultId=49  configObjectName=NRBTS-\\d{1}/NRCELL-[1-2]  count=2
            ${allowed_filter}  Create List  ${allowed_alarm_1}
            SBTS_KW.Check Sbts History Alarm Custom  allowed_fault_filters=${allowed_filter}
            [Teardown]  SBTS_KW.Teardown Admin Connection

            Example 2: Check Sbts History Alarm Custom, all filters given,
                required fault will be merged into allowed filter
            [Setup]  SBTS_KW.Setup Admin Connection
            run keyword and ignore error  SBTS_KW.Block SBTS Cell  connection=sbts_oam_admin
            ${expected_blocked_status}  Create Dictionary  blockingState=Blocked
            Wait Until Keyword Succeeds  2min  10s  SBTS_KW.Check SBTS Cell Status  bbmod_id_list=1
            ...  expected_status_dict=${expected_blocked_status}  connection=sbts_oam_admin

            SBTS_KW.Unblock SBTS Cell  connection=sbts_oam_admin
            ${expected_unblocked_status}  Create Dictionary  blockingState=Unblocked
            Wait Until Keyword Succeeds  2min  10s  SBTS_KW.Check SBTS Cell Status  bbmod_id_list=1
            ...  expected_status_dict=${expected_unblocked_status}  connection=sbts_oam_admin

            # faultId == 49, configObjectName matches the regex and max allowed appearance is 1
            ${allowed_alarm_1}  Create Dictionary  faultId=49  configObjectName=NRBTS-\\d{1}/NRCELL-1  count=1
            ${allowed_filter}  Create List  ${allowed_alarm_1}

            # faultId == 49, configObjectName matches the regex
            ${forbidden_alarm_1}  Create Dictionary  faultId=49  configObjectName=NRBTS-\\d{1}/NRCELL-[3-9]
            ${forbidden_filter}  Create List   ${forbidden_alarm_1}

            # faultId == 49, configObjectName matches the regex and accurate appearance is 1
            ${required_alarm_1}  Create Dictionary  faultId=49  configObjectName=NRBTS-\\d{1}/NRCELL-2  count=1
            ${required_filter}  Create List   ${required_alarm_1}

            SBTS_KW.Check Sbts History Alarm Custom  allowed_fault_filters=${allowed_filter}
            ...  forbidden_fault_filters=${forbidden_filter}  required_fault_filters=${required_filter}
            [Teardown]  SBTS_KW.Teardown Admin Connection


        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/08/24 | First draft version |
            | fuzengz| 1.0.0 | 2022/08/26 | First approved version by VA |
    """
    adm = admin()
    alarm_list = adm.get_historic_alarms(connection=connection)
    MolerTest.info("History alarms retrieved are: {}".format(alarm_list))

    result_dict = \
        _verify_faults_custom(alarm_list, forbidden_fault_filters, allowed_fault_filters, required_fault_filters)
    pprint(result_dict)
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asir_active_alarm_custom(device_name="GNB0_ASIMGR", pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                                   forbidden_fault_filters=None,
                                   allowed_fault_filters=None,
                                   required_fault_filters=None):
    """
        Main Function:
            Get ASIR active alarms and check if the alarms match given 3 filters group, forbidden/allowed/required,
            If one filters is not specified or None, the keyword will skip the check
            If check fails, Moler will print the result

        Arguments:
            :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR,
                or ENB0_ASIMGR for 4G ASiR.
            :param str pw: account and password
            :param str ne: ip address
            :param forbidden_fault_filters: Filters for alarm should not appear
            :param allowed_fault_filters: Filters for alarms are allowed to appear
            :param required_fault_filters: Filters for alarms should appear
        Return Value:
            None

        Examples:
            Example 1: Verify ASiR Active Alarm, only allowed filter given
            run keyword and ignore error  Block Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=disabled
            # faultId == 61648
            ${allowed_alarm_1}  Create Dictionary  faultId=61648
            # faultName == Ant Blocked and sourceObject match ANTMOD_R-[1-2], max count is 2
            ${allowed_alarm_2}  Create Dictionary  faultName=Ant Blocked  sourceObject=ANTMOD_R-[1-2]  count=2
            ${allowed_filter}  Create List  ${allowed_alarm_1}  ${allowed_alarm_2}
            SBTS_KW.Check ASiR Active Alarm Custom  allowed_fault_filters=${allowed_filter}
            run keyword and ignore error  Unblock Ants  1 2


            Example 2: Verify ASiR Active Alarm, with allowed filter given and requried filter
            run keyword and ignore error  Block Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=disabled

            # faultId == 61648, max appearance count == 1
            ${allowed_alarm_1}  Create Dictionary  faultId=61648  count=1
            ${allowed_filter}  Create List  ${allowed_alarm_1}
            # faultName == Ant Blocked and sourceObject match ANTMOD_R-[1-2], accurate appearance count is 2
            ${required_alarm_1}  Create Dictionary  faultName=Ant Blocked  sourceObject=ANTMOD_R-[1-2]  count=2
            ${required_filter}  Create List  ${required_alarm_1}
            SBTS_KW.Check ASiR Active Alarm Custom  allowed_fault_filters=${allowed_filter}
            ...  required_fault_filters=${required_filter}
            run keyword and ignore error  Unblock Ants  1 2

            Example 3: Verify ASiR Active Alarm, with forbidden filter, allowed filter given and requried filter
            run keyword and ignore error  Block Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=disabled

            # faultId == 61648
            ${forbidden_alarm_1}  Create Dictionary  faultId=61649
            ${forbidden_filter}  Create List   ${forbidden_alarm_1}
            # faultId == 61648, max appearance count == 1
            ${allowed_alarm_1}  Create Dictionary  faultId=61648  count=1
            ${allowed_filter}  Create List  ${allowed_alarm_1}
            # faultName == Ant Blocked and sourceObject match ANTMOD_R-[1-2], accurate appearance count is 2
            ${required_alarm_1}  Create Dictionary  faultName=Ant Blocked  sourceObject=ANTMOD_R-[1-2]  count=2
            ${required_filter}  Create List  ${required_alarm_1}
            SBTS_KW.Check ASiR Active Alarm Custom  forbidden_fault_filters=${forbidden_filter}
            ...  allowed_fault_filters=${allowed_filter}  required_fault_filters=${required_filter}

            run keyword and ignore error  Unblock Ants  1 2

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/08/24 | First draft version |
            | fuzengz| 1.0.0 | 2022/08/26 | First approved version by VA |
    """
    alarm_list = get_asir_alarm(device_name=device_name, pw=pw, ne=ne)
    MolerTest.info("Active alarms retrieved are: {}".format(alarm_list))
    result_dict = \
        _verify_faults_custom(alarm_list, forbidden_fault_filters, allowed_fault_filters, required_fault_filters)
    pprint(result_dict)
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_asir_history_alarm_custom(appeared_time_later_than, device_name="GNB0_ASIMGR",
                                    pw="Nemuadmin:nemuuser", ne="192.168.255.129",
                                    forbidden_fault_filters=None, allowed_fault_filters=None,
                                    required_fault_filters=None):
    """
        Main Function:
            Get ASIR history alarms that have been raised since the given timestamp,
            and check if the alarms match given 3 filters group, forbidden/allowed/required,
            If one filters is not specified or None, the keyword will skip the check
            If check fails, Moler will print the result

        Arguments:
            :param float appeared_time_later_than: Epoch time (Epoch time is the time in seconds since the UNIX epoch
                  i.e. 00:00:00.000 (UTC) 1 January 1970.) Refer to below example to get Epoch time:
            :param device_name: Supply device_name with value GNB0_ASIMGR (by default) for 5G ASiR,
                    or ENB0_ASIMGR for 4G ASiR.
            :param str pw: account and password
            :param str ne: ip address
            :param forbidden_fault_filters: Filters for alarm should not appear
            :param allowed_fault_filters: Filters for alarms are allowed to appear
            :param required_fault_filters: Filters for alarms should appear
        Return Value:
            None

        Examples:
            Example 1: Verify ASiR History Alarm, with allowed filter given and requried filter
            ${start_time}  DateTime.Get Current Date  result_format=epoch  exclude_millis=True
            run keyword and ignore error  Block Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=disabled
            run keyword and ignore error  Unblock Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=enabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=enabled

            # faultId == 61648, max appearance count == 1
            ${allowed_alarm_1}  Create Dictionary  faultId=61648  count=1
            ${allowed_filter}  Create List  ${allowed_alarm_1}
            # faultName == Ant Blocked and sourceObject match ANTMOD_R-[1-2], accurate appearance count is 2
            ${required_alarm_1}  Create Dictionary  faultName=Ant Blocked  sourceObject=ANTMOD_R-[1-2]  count=2
            ${required_filter}  Create List  ${required_alarm_1}
            SBTS_KW.Check ASiR History Alarm Custom  appeared_time_later_than=${start_time}
            ...  allowed_fault_filters=${allowed_filter}  required_fault_filters=${required_filter}

            Example 2: Verify ASiR History Alarm, with forbidden filter, allowed filter given and requried filter
            ${start_time}  DateTime.Get Current Date  result_format=epoch  exclude_millis=True
            run keyword and ignore error  Block Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=disabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=disabled
            run keyword and ignore error  Unblock Ants  1 2
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  1  operationalState=enabled
            Wait Until Keyword Succeeds  2min  10s  Check Ant Status  2  operationalState=enabled

            # faultId == 61648
            ${forbidden_alarm_1}  Create Dictionary  faultId=61649
            ${forbidden_filter}  Create List   ${forbidden_alarm_1}
            # faultId == 61648, max appearance count == 1
            ${allowed_alarm_1}  Create Dictionary  faultId=61648  count=1
            ${allowed_filter}  Create List  ${allowed_alarm_1}
            # faultName == Ant Blocked and sourceObject match ANTMOD_R-[1-2], accurate appearance count is 2
            ${required_alarm_1}  Create Dictionary  faultName=Ant Blocked  sourceObject=ANTMOD_R-[1-2]  count=2
            ${required_filter}  Create List  ${required_alarm_1}

            SBTS_KW.Check ASiR History Alarm Custom  appeared_time_later_than=${start_time}
            ...  forbidden_fault_filters=${forbidden_filter}  allowed_fault_filters=${allowed_filter}
            ...  required_fault_filters=${required_filter}

        Version:
            | Author | Version | Delivery Date | Comments |
            | fuzengz| 0.0.1 | 2022/08/24 | First draft version |
            | fuzengz| 1.0.0 | 2022/08/26 | First approved version by VA |
    """
    history_alarm_list = get_asir_alarm(alarm_type="cleared", device_name=device_name, pw=pw, ne=ne)
    MolerTest.info("history alarms retrieved are: {}".format(history_alarm_list))

    def _convert_utc_to_local_tz(utc_time):
        from_zone = tz.tzutc()
        to_zone = tz.tzlocal()
        utc = datetime.strptime(utc_time, "%Y-%m-%dT%H:%M:%S.%fZ")
        utc = utc.replace(tzinfo=from_zone)
        central = utc.astimezone(to_zone)
        return time.mktime(central.timetuple())

    delta_alarm_list = [elem for elem in history_alarm_list
                        if _convert_utc_to_local_tz(elem.get("timeStarted")) >= appeared_time_later_than]

    MolerTest.info("delta alarms retrieved are: {}".format(delta_alarm_list))

    MolerTest.info("Total {} history alarm(s). {} alarm(s) raised after {}".format(
        len(history_alarm_list), len(delta_alarm_list),
        time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(appeared_time_later_than))))
    MolerTest.info("Delta alarm(s): {}".format(delta_alarm_list))

    result_dict = \
        _verify_faults_custom(delta_alarm_list, forbidden_fault_filters, allowed_fault_filters, required_fault_filters)
    pprint(result_dict)
    if not result_dict['check_result']:
        MolerTest.error("Status check result: {}".format(result_dict))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_sysmod_status(sysmod_list=None, expected_status_dict={}, oam_ip="192.168.255.129", port=443, running=False,
                        connection=None):
    """
    keyword check_sysmod_status
    Get sysmod status and check if status values are expected
    :param sysmod_list: a flexible condition combination, it can support type of string, list
                        if parameter running is True, the sysmod_list is useless, it means check runtime sysmod status

    :param expected_status_dict: dictionary of status/value
    :param oam_ip: OAM IP for ssh to nodeb
    :poram port: port number
    :param running: runtime status check flag, this parameter can be used when BBU dont have commission
    :param connection: the connection alias if using an existing OAM connection

    Version:
    | Author | Version | Delivery Date | Comments |
    | cuicuiw| 0.0.1 | 2022/10/27 | First draft version |
    | cuicuiw| 1.0.0 | 2022/10/27 | First approve version |
    """

    if not sysmod_list:
        sysmod_list = []

    if isinstance(sysmod_list, str):
        cell_list = sysmod_list.split()

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=port)

    dict_sysmod_status = {}
    try:
        for sysmod in adm.get_fsm_info(connection=connection):
            if not running:
                if not sysmod_list or sysmod.get("id").get("configuration").split("-")[-1] in \
                        [str(sysmod_id) for sysmod_id in sysmod_list]:
                    dict_sysmod_status[str(sysmod.get("id").get("configuration"))] = sysmod.get("status")
            else:
                dict_sysmod_status[str(sysmod.get("id").get("runtime"))] = sysmod.get("status")
    finally:
        if not connection:
            adm.teardown_admin()

    compare_res = _compare_status(dict_sysmod_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()


def _verify_faults_custom(all_alarm_list, forbidden_fault_filters, allowed_fault_filters, required_fault_filters):
    result_dict = {'all_alarm_list': all_alarm_list, 'check_result': True,
                   'allowed_filters': allowed_fault_filters, 'forbidden_filters': forbidden_fault_filters,
                   'required_filters': required_fault_filters,
                   'forbidden_fail': [], 'allowed_fail': [], 'required_fail': []}

    if required_fault_filters is not None and allowed_fault_filters is not None:
        for f_required in required_fault_filters:
            k_required = set(f_required.keys())
            k_required.discard('count')
            for f_allowed in allowed_fault_filters:
                k_allowed = set(f_allowed.keys())
                k_allowed.discard('count')
                if k_required == k_allowed \
                        and reduce(lambda x, y: x and f_allowed[y] == f_required[y], k_required, True):
                    break
            else:
                f_required_copy = f_required.copy()
                f_required_copy.pop('count', None)
                allowed_fault_filters.append(f_required_copy)

    for alarm in all_alarm_list:
        if allowed_fault_filters is not None:
            for f in allowed_fault_filters:
                k_allowed = set(f.keys())
                k_allowed.discard('count')
                k_allowed.discard('accum_count')
                if reduce(lambda x, y: x and re.search(str(f.get(y)), str(alarm.get(y))), k_allowed, True):
                    if f.get('count') is not None:
                        f['accum_count'] = int(f.get('accum_count', 0)) + 1
                        if int(f['accum_count']) > int(f['count']):
                            result_dict['check_result'] = False
                            result_dict['allowed_fail'].append(alarm)
                    break
            else:
                result_dict['allowed_fail'].append(alarm)
                result_dict['check_result'] = False

        if forbidden_fault_filters is not None:
            for f in forbidden_fault_filters:
                k_forbidden = set(f.keys())
                k_forbidden.discard('count')
                if reduce(lambda x, y: x and re.search(str(f.get(y)), str(alarm.get(y))), k_forbidden, True):
                    result_dict['forbidden_fail'].append(alarm)
                    result_dict['check_result'] = False

        if required_fault_filters is not None:
            for f in required_fault_filters:
                k_required = set(f.keys())
                k_required.discard('count')
                k_required.discard('accum_count')
                if reduce(lambda x, y: x and re.search(str(f.get(y)), str(alarm.get(y))), k_required, True):
                    f["accum_count"] = f.get("accum_count", 0) + 1

    if required_fault_filters is not None:
        for f in required_fault_filters:
            if f.get('count') is None:
                if int(f.get('accum_count', 0)) < 1:
                    result_dict['check_result'] = False
                    result_dict['required_fail'].append(f)
            else:
                if int(f.get('accum_count', 0)) != int(f.get('count', 0)):
                    result_dict['check_result'] = False
                    result_dict['required_fail'].append(f)

    return result_dict


@MolerTest.raise_background_exceptions(check_steps_end=True)
def reset_rmod(rmod_list=[], oam_ip="192.168.255.129", bts_port=443, reset_type='Soft', force_radio_reset=None,
               detailed_output=False, timeout=240, connection=None):
    """
    Main Function:
        Keyword reset_rmod
        Do reset operation on given mRRH module list.

    Arguments:
        :param rmod_list or str: list of Radio Mod IDs, reset all rmod if list is empty
        :param oam_ip: OAM IP for ssh to BTS station
        :param bts_port: AdminAPI port
        :param reset_type: can be `Soft`, `Hard` or `Warm`, defaults to `Soft`
        :param force_radio_reset: optional parameter to force radio reset
        :param detailed_output: return full request response when True, defaults set to False
        :param timeout: time duration for waiting radio module come up after reset operation
        :param connection: the connection alias if using an existing OAM connection

    Return Value:
        None

    Examples:
        Example 1: reset all radio module
        | reset_rmod |
        Example 2: reset rmod 1 and 2 with oam ip
        | reset_rmod | asir_list=1 2 | oam_ip=192.168.255.129 |
        Example 3: reset rmod 1 and 2 with an existing connection and given timeout
        adm = admin()
        | setup_admin_connection | oam_ip=192.168.255.129 | connection=abc |
        | reset_rmod | asir_list=1 2 | timeout=300 | connection=abc |
        | teardown_admin_connection | connection=abc |

    Version:
        | Author | Version | Delivery Date | Comments |
        | cuicuiw | 0.0.1 | 2023/01/09 | First draft version |
        | cuicuiw | 1.0.0 | 2023/01/11 | First approved version by VA |
    """

    adm = admin()

    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=bts_port)

    rmod_list = rmod_list if type(rmod_list) is list else str(rmod_list).split()

    dict_rmod_distname = {}

    try:
        bts_info = adm.get_bts_info(connection=connection)
        for rmod_item in bts_info.get("radioModules").get("rmod"):
            rmod_item_configuration = rmod_item.get("id").get("configuration")
            rmod_item_runtime = rmod_item.get("id").get("internal")
            if not rmod_list or rmod_item_configuration.split("-")[-1] in rmod_list:
                dict_rmod_distname[rmod_item_configuration.split("/")[-1]] = rmod_item_runtime
        logger.info("RMOD distname dict: {}".format(dict_rmod_distname))

        for rmod, dist_name in dict_rmod_distname.items():
            logger.info("Start reset {}".format(rmod), also_console=True)
            reset_result = adm.reset_unit(dist_name=dist_name,
                                          reset_type=reset_type,
                                          force_radio_reset=force_radio_reset,
                                          connection=connection,
                                          detailed_output=detailed_output,
                                          timeout=timeout)

            logger.info("End reset {} and result is: {}".format(rmod, reset_result), also_console=True)

            for reset_status in reset_result:
                if "parameters" in reset_status.keys():
                    if "succeeded" not in reset_status.get("parameters").get("status").lower():
                        MolerTest.error("Reset {} failed with result: {}".format(reset_result, reset_result))

    except Exception as e:
        if "not completed within" in str(e):
            raise Exception("Reset oper not completed within {0}s, detailed error msg: {1}".format(timeout, str(e)))
        else:
            raise
    finally:
        MolerTest.steps_end()
        if not connection:
            adm.teardown_admin()


def lock_rmod(rmod_list=[], oam_ip="192.168.255.129", bts_port=443, timeout=120, connection=None):
    _operate_rmod(operation="lock", rmod_list=rmod_list, oam_ip=oam_ip, bts_port=bts_port,
                  timeout=timeout, connection=connection)


def unlock_rmod(rmod_list=[], oam_ip="192.168.255.129", bts_port=443, timeout=120, connection=None):
    _operate_rmod(operation="unlock", rmod_list=rmod_list, oam_ip=oam_ip, bts_port=bts_port,
                  timeout=timeout, connection=connection)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_rmod_status(rmod_list=[], expected_status_dict={}, oam_ip="192.168.255.129", bts_port=443, connection=None):
    """
    Main Function:
        Keyword aims to check rmod status

    Arguments:
        :param rmod_list or str: list of Radio Mod IDs, reset all rmod if list is empty
        :param expected_status_dict
        :param oam_ip: OAM IP for ssh to BTS station
        :param bts_port: AdminAPI port
        :param connection: the connection alias if using an existing OAM connection

    Return Value:
            None

    Examples:
        | Lock Rmod | rmod_list=${rmod1} ${rmod2} |
        | ${expected_status} | Create Dictionary | administrativeState=locked  operationalState=enabled |
        | Wait Until Keyword Succeeds | 15min  30s | Check Rmod Status | rmod_list=${rmod1} ${rmod2} |
        | ...  expected_status_dict=${expected_status} |

        Unlock Rmod  rmod_list=${rmod1} ${rmod2}
        ${expected_status}  Create Dictionary  administrativeState=unlocked  operationalState=enabled
        Wait Until Keyword Succeeds  15min  30s  Check Rmod Status  rmod_list=${rmod1} ${rmod2}
        ...  expected_status_dict=${expected_status}

    Version:
        | Author | Version | Delivery Date | Comments |
        | cuicuiw | 0.0.1 | 2023/01/09 | First draft version |
        | cuicuiw | 1.0.0 | 2023/01/11 | First approved version by VA |
    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=bts_port)

    rmod_list = rmod_list if type(rmod_list) is list else str(rmod_list).split()
    dict_rmod_status = {}

    try:
        bts_info = adm.get_bts_info(connection=connection)
    finally:
        if not connection:
            adm.teardown_admin()

    for rmod_item in bts_info.get("radioModules").get("rmod"):
        rmod_item_configuration = rmod_item.get("id").get("configuration")
        if not rmod_list or rmod_item_configuration.split("-")[-1] in rmod_list:
            dict_rmod_status[rmod_item_configuration.split("/")[-1]] = rmod_item["status"]

    logger.info("dict_status:{}".format(dict_rmod_status), also_console=True)
    if not dict_rmod_status:
        MolerTest.error("Get rmod result: {}".format(dict_rmod_status))

    compare_res = _compare_status(dict_rmod_status, expected_status_dict)
    if not compare_res['check_result']:
        MolerTest.error("Status check result: {}".format(compare_res))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def _operate_rmod(operation, rmod_list=[], oam_ip="192.168.255.129", bts_port=443, timeout=120,
                  technology=None, detailed_output=False, connection=None):
    """
    Main Function:
        Keyword aims to lock unlock rmod
        Do lock unlock operation on given mRRH module list.

    Arguments:
        :param lock or lock operation, the value should be lock or unlock
        :param rmod_list or str: list of Radio Mod IDs, reset all rmod if list is empty
        :param oam_ip: OAM IP for ssh to BTS station
        :param bts_port: AdminAPI port
        :param detailed_output: return full request response when True, defaults set to False
        :param technology: one of <LTE, TETRA, NR, ALL> - should be None when dist_name is specified.This parameter is
        used for cell lock/unlock
        :param timeout: time duration for waiting radio module come up after reset operation
        :param connection: the connection alias if using an existing OAM connection

    Return Value:
            None

    Examples:
        | Lock Rmod | rmod_list=${rmod1} ${rmod2} |
        | ${expected_status} | Create Dictionary | administrativeState=locked  operationalState=enabled |
        | Wait Until Keyword Succeeds | 15min  30s | Check Rmod Status | rmod_list=${rmod1} ${rmod2} |
        | ...  expected_status_dict=${expected_status} |

        Unlock Rmod  rmod_list=${rmod1} ${rmod2}
        ${expected_status}  Create Dictionary  administrativeState=unlocked  operationalState=enabled
        Wait Until Keyword Succeeds  15min  30s  Check Rmod Status  rmod_list=${rmod1} ${rmod2}
        ...  expected_status_dict=${expected_status}

    Version:
        | Author | Version | Delivery Date | Comments |
        | cuicuiw | 0.0.1 | 2023/01/09 | First draft version |
        | cuicuiw | 1.0.0 | 2023/01/11 | First approved version by VA |
    """

    adm = admin()
    if not connection:
        adm.setup_admin(bts_host=oam_ip, bts_port=bts_port)

    rmod_list = rmod_list if type(rmod_list) is list else str(rmod_list).split()

    dict_rmod_distname = {}

    if operation.lower() not in ["lock", "unlock"]:
        raise Exception("operation {0} is not supported.".format(operation))

    try:
        bts_info = adm.get_bts_info(connection=connection)
        for rmod_item in bts_info.get("radioModules").get("rmod"):
            rmod_item_configuration = rmod_item.get("id").get("configuration")
            rmod_item_runtime = rmod_item.get("id").get("internal")
            if not rmod_list or rmod_item_configuration.split("-")[-1] in rmod_list:
                dict_rmod_distname[rmod_item_configuration.split("/")[-1]] = rmod_item_runtime
        logger.info("RMOD distname dict: {}".format(dict_rmod_distname))

        for rmod, dist_name in dict_rmod_distname.items():
            logger.info("Start {} {}".format(operation, rmod), also_console=True)
            if operation.lower() == "lock":
                operation_result = adm.lock(dist_name=dist_name,
                                            timeout=timeout,
                                            connection=connection,
                                            technology=technology,
                                            detailed_output=detailed_output)
            else:
                operation_result = adm.unlock(dist_name=dist_name,
                                              timeout=timeout,
                                              connection=connection,
                                              technology=technology,
                                              detailed_output=detailed_output)

            logger.info("End {} {} and result is: {}".format(operation, rmod, operation_result), also_console=True)

            if "completed" not in operation_result.lower():
                MolerTest.error("{} result: {}".format(operation, operation_result))

    except Exception as e:
        if "not completed within" in str(e):
            raise Exception("{} oper not completed within {}s, detailed error msg: {}".format(operation,
                                                                                              timeout, str(e)))
        else:
            raise
    finally:
        MolerTest.steps_end()
        if not connection:
            adm.teardown_admin()


if __name__ == '__main__':
    pass
