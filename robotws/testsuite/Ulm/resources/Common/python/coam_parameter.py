from builtins import str
from taf.sbts.oam.coam.admin import admin
from taf.config.scf import scf
from common_utilities import get_log_path
import datetime
import os
import copy
import re
import lxml.etree as tree
import json


try:
    import unittest2 as unittest
except ImportError:
    import unittest

try:
    from unittest.mock import patch, Mock
except ImportError:
    from mock import patch, Mock

coam = admin()
scf_delta = scf()
namespace = {'ns': 'raml21.xsd'}


class ParameterHandle(Exception):
    pass


def _get_root_dn(root_dn, dn=None):
    mrbts_root = root_dn['MRBTS']
    if dn in [None, mrbts_root]:
        return mrbts_root
    else:
        dn_root = mrbts_root
        dn_spl = str(dn).split('/')
        index_s = 0
        if 'MRBTS' in dn:
            index_s += 1
        if 'NRBTS' in dn:
            if root_dn['NRBTS'] is None:
                dn_root += '/' + dn_spl[index_s]
            else:
                dn_root += '/' + root_dn['NRBTS']
            index_s += 1
        if index_s != len(dn_spl):
            dn_root += '/' + '/'.join(dn_spl[index_s:len(dn_spl)])
        return dn_root


def _is_parameter_list(dist_name, p_name):
    try:
        scf_delta.get_value_from_scf(dist_name=dist_name, p_name=p_name)
        return False
    except Exception:
        return True


def _get_commissioning_results(commission_resp):
    if commission_resp['validationResult']['niddValidationResult']['status'] == 'OK' and \
            commission_resp['commissioningResult']['activationResult']['resultNode']['parameters']['result'] == \
            'Success':
        return 'RESET_PASS' if commission_resp['commissioningResult']['isGoingToTriggerReset'] else 'PASS'
    else:
        raise ParameterHandle(
            'recommission is failed. result: {}'.format(commission_resp))


def _get_delta_config(delta_operation, connection="gnb-0-OAM-http-session"):
    bts_root_dn = get_site_root_dist_name(connection=connection)
    delta_id = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
    delta_file_name = os.path.join(
        get_log_path(), '{}_{}_delta.json'.format(delta_operation, delta_id))
    coam.create_delta(delta_id=delta_id)
    return bts_root_dn, delta_id, delta_file_name


def _check_condition(condition, description):
    if not condition:
        raise ParameterHandle(description)


def _cond_str_value(x, y):
    """
    Check strings are matching or nor
    :param x:
    :param y:
    :return: True or False
    """
    return x.lower() == y.lower()


def _cond_set_value(x, y):
    """
    Check Set of x is subset of y
    :param x:
    :param y:
    :return: True or False
    """
    return set(x).issubset(set(y))


def _get_param_value_from_scf(dist_name, p_name, p_value, p_index=0, check_value=False):
    if check_value:
        desc = 'Value should not empty for parameter[{}], if check_value is True'.format(
            p_name)
        _check_condition(p_value, desc)
    if not _is_parameter_list(dist_name, p_name):
        value = scf_delta.get_value_from_scf(
            dist_name=dist_name, p_name=p_name, index=p_index)
        value = value if value not in [
            'True', 'true', 'False', 'false'] else value.lower()
        if check_value:
            desc = 'Values are not matched[{},{}]'.format(p_value, value)
            condition = _cond_str_value(value, p_value)
            _check_condition(condition, desc)
        return value
    if isinstance(p_value, list):
        if isinstance(p_value[0], ("".__class__, u"".__class__)):
            value = scf_delta.get_all_values_from_scf(
                dist_name=dist_name, list_name=p_name)
            if check_value:
                desc = 'Values are not matched[{},{}]'.format(p_value, value)
                condition = _cond_set_value(p_value, value)
                _check_condition(condition, desc)
            return value
        else:
            for param_index, param in enumerate(p_value):
                for ele_name, ele_value in list(param.items()):
                    value = scf_delta.get_value_from_scf(dist_name=dist_name, p_name=ele_name, list_name=p_name,
                                                         index=param_index)
                    value = value if value not in [
                        'True', 'true', 'False', 'false'] else value.lower()
                    if check_value:
                        desc = 'Values are not matched[{},{}]'.format(
                            ele_value, value)
                        condition = _cond_str_value(value, ele_value)
                        _check_condition(condition, desc)
                    p_value[param_index][ele_name] = value
            return p_value
    if p_value is None or not isinstance(p_value, list):
        value = scf_delta.get_all_values_from_scf(
            dist_name=dist_name, list_name=p_name)
        if check_value:
            desc = 'Values are not matched[{},{}]'.format(p_value, value)
            condition = _cond_set_value(p_value, value)
            _check_condition(condition, desc)
        return value


def _append_list_param_items(parameters, bts_root_dn, connection="gnb-0-OAM-http-session",
                             config_type='configuration'):
    scf_path = get_current_scf_configuration_file(
        connection=connection, config_type=config_type)
    root = tree.parse(scf_path)
    item_tag_name = '{' + namespace['ns'] + '}item'
    param_ret = copy.deepcopy(parameters)
    for ii, param in enumerate(param_ret):
        dist_name = _get_root_dn(bts_root_dn, param.get('dist_name'))
        p_name = param['parameter']
        p_value = param.get('value')
        if _is_parameter_list(dist_name, p_name) and isinstance(p_value, list):
            path = "//ns:managedObject[@distName='{dn}']//ns:list[@name='{ln}']//ns:item".format(dn=dist_name,
                                                                                                 ln=p_name)
            items = root.xpath(path, namespaces=namespace)
            if items:
                elements = {}
                for item_index, item in enumerate(items):
                    for element in item.iter():
                        if element.tag == item_tag_name:
                            continue
                        if elements.get(item_index) is None:
                            elements[item_index] = {
                                element.attrib['name']: element.text}
                        else:
                            elements.get(item_index).update(
                                {element.attrib['name']: element.text})
                if elements:
                    for item_index, item_param in enumerate(p_value):
                        for ele_name, ele_value in list(item_param.items()):
                            elements.get(item_index).update(
                                {ele_name: ele_value})
                    param['value'] = list(elements.values())
    return param_ret


def get_site_root_dist_name(connection="gnb-0-OAM-http-session"):
    """
    Get BTS Root Dist Name
    :param connection: AdminConnection object or if used, string name alias
    :return: Root Dist Name
    """
    bts_info = coam.get_bts_info(connection=connection)
    root_dist = {}
    if 'requestMessage' in bts_info:
        bts_info = bts_info['requestMessage']
    root_dist['MRBTS'] = bts_info['id']['configuration']
    try:
        root_dist['NRBTS'] = 'NRBTS-' + re.findall('/MRBTS-.*NRBTS_A-(.*)/',
                                                   bts_info['cellsGroup'][0]['id']['internal'])[0]
    except (KeyError, IndexError):
        root_dist['NRBTS'] = None

    return root_dist


def get_current_scf_configuration_file(connection="gnb-0-OAM-http-session", config_type='configuration'):
    """
     Get BTS Current BTS SCF file
    :param config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
    :param connection: AdminConnection object or if used, string name alias
    :return: Path to the file with current SCF content
    """
    current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
    if config_type not in ['configuration', 'configurationAndRuntimeObjects', 'runtimeObjects']:
        raise ParameterHandle(
            'Invalid config_type({}) type'.format(config_type))
    scf_file_path = os.path.join(
        get_log_path(), 'scf_{}.xml'.format(current_time))
    coam.get_current_scf_file(local_dir_path=get_log_path(),
                              file_name='scf_{}.xml'.format(current_time),
                              export_type=config_type, timeout=30, connection=connection)
    if not os.path.exists(scf_file_path):
        raise ParameterHandle('SCF file {} not exists'.format(scf_file_path))
    return scf_file_path


def get_list_values_from_scf_file(parameters, local_dir_path=None, check_value=False,
                                  connection="gnb-0-OAM-http-session", config_type='configuration'):
    """
    Get values from SCF XML file
    :return: list of dicts with current values
    :param config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
    :param local_dir_path: Current SCF XML file
    :param parameters: list of dicts
    examples:
           parameters = [ {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'gnbIdLength', 'value':'22'},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
                         'value':[{'mcc':None,'mnc':None, "mncLength":'2'}]},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'lteNrDualConnectAllowed',
                         value':'allowed'},
                         {'dist_name': 'MNL-1/MNLENT-2/SYNC-1/CLOCK-1/TOP-1/TOPP-1', 'parameter':'topMasterList',
                         value':[{'masterIpAddr':None}], p_index=1},
                        ]
    :param connection: AdminConnection object or if used, string name alias
    :param check_value: verify value with current value, through exception if not equal.
    """
    if local_dir_path is None:
        local_dir_path = get_current_scf_configuration_file(
            connection=connection, config_type=config_type)
    scf_delta.load_scf(local_dir_path)
    bts_root_dn = get_site_root_dist_name(connection=connection)
    param_ret = copy.deepcopy(parameters)
    for ii, param in enumerate(param_ret):
        dist_name = _get_root_dn(bts_root_dn, param.get('dist_name'))
        if 'parameter' in param:
            param_ret[ii]['value'] = _get_param_value_from_scf(dist_name=dist_name, p_name=param['parameter'],
                                                               p_value=param.get('value'), check_value=check_value,
                                                               p_index=param.get('p_index', 0))
    return param_ret


def get_single_value_from_scf_file(parameter=None, list_name=None, dist_name=None, p_index=0, local_dir_path=None,
                                   config_type='configuration', connection="gnb-0-OAM-http-session"):
    """
    Get values from SCF XML file
    :param p_index: optional parameter, should be castable to int. Should be used if more than one match expected.
    Indexing starts from 0.
    :param config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
    :return: return parameter value
    :param local_dir_path:  local SCF XML file, default get XML file from BTS
    :param parameter:  Name of parameter
    :param list_name:  List name
    :param dist_name:  Object distName
    :param connection: AdminConnection object or if used, string name alias
    """
    if list_name is None and parameter is None:
        raise ParameterHandle(
            'Invalid input, either param_name or list_name should set')
    if list_name is not None:
        parameters = [{'dist_name': dist_name, 'parameter': list_name, 'p_index': p_index,
                       'value': [{parameter: None}]}]
        value = get_list_values_from_scf_file(parameters=parameters, local_dir_path=local_dir_path,
                                              config_type=config_type, connection=connection)
        return value[0]['value'][0][parameter]
    else:
        parameters = [{'dist_name': dist_name,
                       'p_index': p_index, 'parameter': parameter}]
        value = get_list_values_from_scf_file(parameters=parameters, local_dir_path=local_dir_path,
                                              config_type=config_type, connection=connection)
        return value[0]['value']


def add_update_parameters_to_delta(parameters, delta_id, bts_root_dn=None, connection="gnb-0-OAM-http-session"):
    """
    Append parameter update to delta
    :param parameters:list of dicts, examples are below.
           parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList',
                         'value':[{'syncInputPrio':'1','syncInputType':'1pps/ToD from external GNSS receiver'}]},
                         {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
                        ]
    :param delta_id:  ID of delta JSON
    :param bts_root_dn: BTS root Dist name
    :param connection: AdminConnection object or if used, string name alias
    """
    bts_root_dn = bts_root_dn or get_site_root_dist_name(connection=connection)
    for param in parameters:
        dist_name = _get_root_dn(bts_root_dn, param.get('dist_name'))
        coam.append_parameter_update_to_delta(dist_name=dist_name, parameter=param['parameter'],
                                              value=param['value'], delta_id=delta_id)


def add_delete_parameters_to_delta(parameters, delta_id, bts_root_dn=None, connection="gnb-0-OAM-http-session"):
    """
    Append parameter delete to delta
    :param parameters:list of dicts, examples are below.
           parameters = [ {'dist_name': None, 'parameter':'btsName'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList'},
                         {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup'},
                        ]
    :param delta_id:  ID of delta JSON
    :param bts_root_dn: BTS root Dist name
    :param connection: AdminConnection object or if used, string name alias
    """
    bts_root_dn = bts_root_dn or get_site_root_dist_name(connection=connection)
    for param in parameters:
        dist_name = _get_root_dn(bts_root_dn, param.get('dist_name'))
        coam.append_parameter_delete_to_delta(dist_name=dist_name, parameter=param['parameter'],
                                              delta_id=delta_id)


def add_delete_objects_to_delta(parameters, delta_id, bts_root_dn=None, connection="gnb-0-OAM-http-session"):
    """
    Append managed object  delete to delta
    :param parameters:list of dicts, examples are below.
           parameters = [ {'dist_name': None'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1'},
                         {'dist_name': 'NRBTS-1/NRDU-1'},
                        ]
    :param delta_id:  ID of delta JSON
    :param bts_root_dn: BTS root Dist name
    :param connection: AdminConnection object or if used, string name alias
    """
    bts_root_dn = bts_root_dn or get_site_root_dist_name(connection=connection)
    for param in parameters:
        dist_name = _get_root_dn(bts_root_dn, param.get('dist_name'))
        coam.append_managed_object_to_delta(
            dist_name=dist_name, operation='delete', delta_id=delta_id)


def add_objects_to_delta(parameters, delta_id, bts_root_dn=None, connection="gnb-0-OAM-http-session"):
    """
    Append managed object  create to delta
    :param parameters:list of dicts, examples are below.
           parameters = [ {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'gnbIdLength', 'value':'22'},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
                         'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'lteNrDualConnectAllowed',
                         value':'allowed'},
                        ]
    :param delta_id:  ID of delta JSON
    :param bts_root_dn: BTS root Dist name
    :param connection: AdminConnection object or if used, string name alias
    """
    bts_root_dn = bts_root_dn or get_site_root_dist_name(connection=connection)
    append_object_list = []
    for param in parameters:
        dist_name = _get_root_dn(bts_root_dn, param.get('dist_name'))
        if dist_name not in append_object_list:
            coam.append_managed_object_to_delta(
                dist_name=dist_name, operation='create', delta_id=delta_id)
            append_object_list.append(dist_name)
        if 'parameter' in param:
            coam.append_parameter_update_to_delta(dist_name=dist_name, parameter=param['parameter'],
                                                  value=param['value'], delta_id=delta_id)


def convert_delta_scf_xml_multi_operation(delta_xml_path):
    json_parameters = list()
    json_return = list()
    json_return_rev = list()
    root = tree.parse(delta_xml_path)

    for operation in ("create", "update", "delete"):
        mo = root.xpath(
            "//ns:managedObject[@operation='{op}']".format(op=operation), namespaces=namespace)
        if len(mo) > 0:
            json_operation = convert_delta_scf_xml(
                delta_xml_path, delta_operation=operation)
            json_parameters.append(json_operation["parameters"])

            with open(json_operation["updated"], 'r') as myfile:
                data = myfile.read()
                json_return.append(json.loads(data))

            if operation == "delete":  # delete does not need reverse
                continue
            with open(json_operation["reverse"], 'r') as myfile:
                data = myfile.read()
                json_return_rev.append(json.loads(data))

    json_parameters = sum(json_parameters, [])
    json_return = sum(json_return, [])
    json_return_rev = sum(json_return_rev, [])
    return {'parameters': json_parameters, 'updated': json.dumps(json_return), 'reverse': json.dumps(json_return_rev)}


def create_update_parameters_delta(parameters, connection="gnb-0-OAM-http-session"):
    """
    Create JSON Delta recommission file for parameter update
    :param parameters: list of dicts, examples are below.
           parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList',
                         'value':[{'syncInputPrio':'1','syncInputType':'1pps/ToD from external GNSS receiver'}]},
                         {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
                        ]
    :param connection: AdminConnection object or if used, string name alias
    :return: dictionary which contains updated and reverse JSON Delta recommission file
    """
    bts_root_dn, delta_id, delta_file_name = _get_delta_config(
        delta_operation='update', connection=connection)
    appended_params = _append_list_param_items(
        parameters, bts_root_dn, connection=connection)
    add_update_parameters_to_delta(parameters=appended_params, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                   connection=connection)
    coam.save_delta(target_file_name=delta_file_name, delta_id=delta_id)
    rev_delta_file_name = delta_file_name.replace('.json', '_rev.json')
    coam.remove_delta(delta_id=delta_id)
    coam.create_delta(delta_id=delta_id)
    rev_parameters = get_list_values_from_scf_file(parameters=appended_params, check_value=False,
                                                   connection=connection)
    add_update_parameters_to_delta(parameters=rev_parameters, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                   connection=connection)
    coam.save_delta(target_file_name=rev_delta_file_name, delta_id=delta_id)
    return {'updated': delta_file_name, 'reverse': rev_delta_file_name}


def create_delete_parameters_delta(parameters, connection="gnb-0-OAM-http-session"):
    """
    Create JSON Delta recommission file for parameter delete
    :param parameters: list of dicts, examples are below.
           parameters = [ {'dist_name': None, 'parameter':'btsName'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList'},
                         {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup'},
                        ]
    :param connection: AdminConnection object or if used, string name alias
    :return: dictionary which contains updated JSON Delta recommission file
    """
    bts_root_dn, delta_id, delta_file_name = _get_delta_config(
        delta_operation='delete', connection=connection)
    add_delete_parameters_to_delta(parameters=parameters, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                   connection=connection)
    coam.save_delta(target_file_name=delta_file_name, delta_id=delta_id)
    return {'updated': delta_file_name}


def create_delete_objects_delta(parameters, connection="gnb-0-OAM-http-session"):
    """
    Create JSON Delta recommission file for delete managed objects
    :param parameters: list of dicts, examples are below.
           parameters = [ {'dist_name': None'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1'},
                         {'dist_name': 'NRBTS-1/NRDU-1'},
                        ]
    :param connection: AdminConnection object or if used, string name alias
    :return: dictionary which contains updated JSON Delta recommission file
    """
    bts_root_dn, delta_id, delta_file_name = _get_delta_config(
        delta_operation='delete', connection=connection)
    add_delete_objects_to_delta(parameters=parameters, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                connection=connection)
    coam.save_delta(target_file_name=delta_file_name, delta_id=delta_id)
    return {'updated': delta_file_name}


def create_objects_delta(parameters, connection="gnb-0-OAM-http-session"):
    """
    Create JSON Delta recommission file for create managed objects
    :param parameters: list of dicts, examples are below.
           parameters = [ {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'gnbIdLength', 'value':'22'},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
                         'value':[{'mcc':'262','mnc':'3', "mncLength":'2'}]},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
                         {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'lteNrDualConnectAllowed',
                         value':'allowed'},
                        ]
    :param connection: AdminConnection object or if used, string name alias
    :return: dictionary which contains updated and reverse JSON Delta recommission file
    """
    bts_root_dn, delta_id, delta_file_name = _get_delta_config(
        delta_operation='create', connection=connection)
    add_objects_to_delta(parameters=parameters, delta_id=delta_id,
                         bts_root_dn=bts_root_dn, connection=connection)
    coam.save_delta(target_file_name=delta_file_name, delta_id=delta_id)
    rev_delta_file_name = delta_file_name.replace('.json', '_rev.json')
    coam.remove_delta(delta_id=delta_id)
    coam.create_delta(delta_id=delta_id)
    add_delete_objects_to_delta(parameters=parameters, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                connection=connection)
    coam.save_delta(target_file_name=rev_delta_file_name, delta_id=delta_id)
    return {'updated': delta_file_name, 'reverse': rev_delta_file_name}


def perform_scf_delta_commission(delta_file, skip_parameter_relation_errors=False, should_activate=True, timeout=60,
                                 connection="gnb-0-OAM-http-session"):
    """
    This keyword is used to Perform delta recommissioning and return status
    :return: raise exception if recommission failed, PASS - online parameter update
                  RESET_PASS - parameter update is successful and BTS is going to trigger reset
    :param delta_file: Delta JSON or path to JSON file.
    :param skip_parameter_relation_errors:  Skip parameter relation errors.
    :param should_activate:  should automatically activate plan.
    :param timeout:  Time to wait for positive procedure result
    :param connection: AdminConnection object or if used, string name alias
    """
    result = coam.perform_delta_recommissioning(delta_file=delta_file,
                                                skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                should_activate=should_activate, timeout=timeout,
                                                connection=connection)
    return _get_commissioning_results(commission_resp=result)


def perform_scf_parameter_recommission(value, parameter=None, list_name=None, dist_name=None,
                                       skip_parameter_relation_errors=False, should_activate=True, timeout=60,
                                       operation='update', connection="gnb-0-OAM-http-session"):
    """
    Perform parameter recommissioning, update and delete operation can be used.
    :return: raise exception if recommission failed, PASS - online parameter update
                  RESET_PASS - parameter update is successful and BTS is going to trigger reset
    :param operation: update or delete
    :param value: Parameter value 10.0.1.99 or ['1','2']
    :param parameter: Parameter operation, update or delete can be chosen
    :param list_name: List name
    :param dist_name: Object distName
    :param skip_parameter_relation_errors: kip parameter relation errors
    :param should_activate: Should automatically activate plan
    :param timeout: Time to wait for positive procedure result
    :param connection: AdminConnection object or if used, string name alias
    """
    dist_name = _get_root_dn(get_site_root_dist_name(
        connection=connection), dist_name)
    if list_name is not None:
        if parameter is not None:
            value = [{parameter: value}]
        parameter = list_name
    elif parameter is None:
        raise ParameterHandle(
            'Invalid input, either param_name or list_name should set')
    result = coam.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter, operation=operation,
                                                    value=value,
                                                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                    should_activate=should_activate, timeout=timeout,
                                                    connection=connection)
    return _get_commissioning_results(commission_resp=result)


def perform_single_parameter_update(value, parameter=None, list_name=None, dist_name=None,
                                    skip_parameter_relation_errors=False, should_activate=True, timeout=60,
                                    connection="gnb-0-OAM-http-session"):
    """
    Perform parameter recommissioning, update and delete operation can be used.
    :return: raise exception if recommission failed, PASS - online parameter update
                  RESET_PASS - parameter update is successful and BTS is going to trigger reset
    :param value: Parameter value 10.0.1.99 or ['1','2']
    :param parameter: Parameter operation, update or delete can be chosen
    :param list_name: List name
    :param dist_name: Object distName
    :param skip_parameter_relation_errors: kip parameter relation errors
    :param should_activate: Should automatically activate plan
    :param timeout: Time to wait for positive procedure result
    :param connection: AdminConnection object or if used, string name alias
    """
    if list_name is not None:
        if parameter is not None:
            value = [{parameter: value}]
        parameter = list_name
    elif parameter is None:
        raise ParameterHandle(
            'Invalid input, either param_name or list_name should set')
    params = [{'dist_name': dist_name, 'parameter': parameter, 'value': value}]
    delta_file = create_update_parameters_delta(
        parameters=params, connection=connection)
    commission_status = perform_scf_delta_commission(delta_file=delta_file['updated'],
                                                     skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                     should_activate=should_activate, timeout=timeout,
                                                     connection=connection)

    return {'parameters': params, 'update_status': commission_status, 'reverse': delta_file['reverse']}


def convert_delta_scf_xml(delta_xml_path, delta_operation='update', connection='cOAM'):
    """
    This keyword is used to Convert Delta xml to Delta Json or list of parameters dict.
    :param delta_xml_path: Delta SCF xml file path
    :param delta_operation: if convert_to=='delta_json' then delta_operation is mandatory, Options: update, create,
                                            and delete
    :param connection: AdminConnection object or if used, string name alias
    :return:
    """
    item_tag_name = '{' + namespace['ns'] + '}item'
    p_tag_name = '{' + namespace['ns'] + '}p'
    list_tag_name = '{' + namespace['ns'] + '}list'
    root = tree.parse(delta_xml_path)
    mo_list = root.xpath(
        "//ns:managedObject[@operation='{op}']".format(op=delta_operation), namespaces=namespace)
    converted_params = []
    for mo in mo_list:
        dist_name = mo.attrib['distName']
        if delta_operation == 'delete' or delta_operation == 'create':
            converted_params.append({'dist_name': dist_name})
        mo_path = "//ns:managedObject[@distName='{dn}']".format(dn=dist_name)
        params = root.xpath(mo_path, namespaces=namespace)[0]
        for p_index, p_name in enumerate(params):
            if p_name.tag == p_tag_name:
                converted_params.append({'dist_name': dist_name, 'parameter': p_name.attrib['name'],
                                         'value': p_name.text})
                continue
            if p_name.tag == list_tag_name:
                list_items = []
                for item in p_name:
                    item_params = {}
                    if item.tag == p_tag_name:
                        list_items.append(item.text)
                    else:
                        for l_index, l_para in enumerate(item):
                            if l_para.tag == item_tag_name:
                                continue
                            item_params.update(
                                {l_para.attrib['name']: l_para.text})
                        list_items.append(item_params)
                converted_params.append({'dist_name': dist_name, 'parameter': p_name.attrib['name'],
                                         'value': list_items})
    if not converted_params:
        raise ParameterHandle(
            'Reading Delta xml {} file failed '.format(delta_xml_path))

    if delta_operation == 'update':
        delta_json_path = create_update_parameters_delta(
            parameters=converted_params, connection=connection)
    elif delta_operation == 'create':
        delta_json_path = create_objects_delta(
            parameters=converted_params, connection=connection)
    elif delta_operation == 'delete':
        delta_json_path = create_delete_objects_delta(
            parameters=converted_params, connection=connection)
    else:
        raise ParameterHandle(
            'Invalid Delta_operation [{}] '.format(delta_operation))
    return {'parameters': converted_params, 'updated': delta_json_path['updated'],
            'reverse': delta_json_path.get('reverse')}


def create_update_parameters_delta_without_backup(parameters, connection="gnb-0-OAM-http-session"):
    """
    Create JSON Delta recommission file for parameter update
    :param parameters: list of dicts, examples are below.
           parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
                         {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList',
                         'value':[{'syncInputPrio':'1','syncInputType':'1pps/ToD from external GNSS receiver'}]},
                         {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
                        ]
    :param connection: AdminConnection object or if used, string name alias
    :return: dictionary which contains updated JSON Delta recommission file
    """
    bts_root_dn, delta_id, delta_file_name = _get_delta_config(
        delta_operation='update', connection=connection)
    appended_params = _append_list_param_items(
        parameters, bts_root_dn, connection=connection)
    add_update_parameters_to_delta(parameters=appended_params, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                   connection=connection)
    coam.save_delta(target_file_name=delta_file_name, delta_id=delta_id)
    return {'updated': delta_file_name}


if __name__ == "__main__":
    # Unittest
    class TestCoamParameter(unittest.TestCase):
        def test_get_root_dn(self):
            root_dist_value = {'MRBTS': 'MRBTS-1000', 'NRBTS': 'NRBTS-2000'}
            _get_root_dn(root_dist_value, 'MRBTS-1000/NRBTS-1000')
            self.assertEqual(_get_root_dn(root_dist_value), 'MRBTS-1000')
            self.assertEqual(_get_root_dn(root_dist_value, 'MRBTS-1000/NRBTS-1000'),
                             'MRBTS-1000/NRBTS-2000')
            self.assertEqual(_get_root_dn(root_dist_value, 'MRBTS-1/NRBTS-1'),
                             'MRBTS-1000/NRBTS-2000')
            self.assertEqual(_get_root_dn(root_dist_value, 'NRBTS-1/NRCELL-1'),
                             'MRBTS-1000/NRBTS-2000/NRCELL-1')
            self.assertEqual(_get_root_dn(root_dist_value, 'MNL-1/MNLENT-1'),
                             'MRBTS-1000/MNL-1/MNLENT-1')
            root_dist_value = {'MRBTS': 'MRBTS-1000', 'NRBTS': None}
            _get_root_dn(root_dist_value, 'MRBTS-1000/NRBTS-1000')
            self.assertEqual(_get_root_dn(root_dist_value), 'MRBTS-1000')
            self.assertEqual(_get_root_dn(root_dist_value, 'MRBTS-1000/NRBTS-1000'),
                             'MRBTS-1000/NRBTS-1000')
            self.assertEqual(_get_root_dn(root_dist_value, 'MRBTS-1/NRBTS-1'),
                             'MRBTS-1000/NRBTS-1')
            self.assertEqual(_get_root_dn(root_dist_value, 'NRBTS-1/NRCELL-1'),
                             'MRBTS-1000/NRBTS-1/NRCELL-1')
            self.assertEqual(_get_root_dn(root_dist_value, 'MNL-1/MNLENT-1'),
                             'MRBTS-1000/MNL-1/MNLENT-1')

    unittest.main()
