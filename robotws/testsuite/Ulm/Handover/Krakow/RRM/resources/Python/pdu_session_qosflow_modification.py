from ta_egate_cmd_parser import ta_egate_cmd_parser as _ta_egate_cmd_parser
import re
import os
import json
import sys
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
import pprint


PARSER = _ta_egate_cmd_parser()
CMD_PARAM_TO_DISP_PARAM_MAPPING = {'qos_flow': 'Id',
                                   '5qi': 'FiveQI',
                                   'qos_flow_type': 'qos_flow_type',
                                   'gfbr_ul': 'gfbr_ul(kbps)',
                                   'gfbr_dl': 'gfbr_dl(kbps)',
                                   'mfbr_ul': 'mfbr_ul(kbps)',
                                   'mfbr_dl': 'mfbr_dl(kbps)',
                                   'priority': 'ARP Priority',
                                   'pci': 'pci',
                                   'pvi': 'pvi'}


FILE_NAME = 'qosflow_disp_output.log'
ALLOWED_PARAMS = ['save', 's', 'restore', 'r', 'modify', 'm']
MAX_LINE_LENGTH = 195
# Any qosflow predefined in lua/cfg file can not be configured with this 5qi (AirPhone restriction)
DUMMY_5QI = 255


def get_all_flows_by_qosflow_id():
    return PARSER.get_command('qosflow_disp').without_id_by_qosflow().execute_and_parse()


def get_all_flows_by_fiveqi_id():
    return PARSER.get_command('qosflow_disp').without_id_by_fiveqi().execute_and_parse()


def get_single_flow(flow_id):
    return PARSER.get_command('qosflow_disp').with_id(int(flow_id)).execute_and_parse()


def prepare_qosflow_modify_cmd_for_5qi_change(**params):
    qos_dict = _parse_qos(params, 'qos_to_mod')
    commands = []
    if qos_dict:
        for i in range(len(qos_dict['qos'])):
            cmds = prepare_command_for_one_qos_mod(qos_dict, i)
            # cmds = prepare_commands_set_for_one_qos_mod(qos_dict, i)
            commands += cmds
    print(f'prepare_qosflow_modify_cmd:\n {pprint.pformat(commands)}')
    return commands


# probably will be removed, need to check AP implementation
def prepare_command_for_one_qos_mod(qos_dict, i):
    if not qos_dict['5qi_changed'][i]:
        return []
    qos = qos_dict['qos'][i]
    fiveqi_new = qos_dict['5qi_target'][i]
    qos_type = qos_dict['type_target'][i]
    return [f'qosflow_modify qos_flow={qos} 5qi={fiveqi_new} qos_flow_type={qos_type}']


def prepare_commands_set_for_one_qos_mod(qos_dict, i):
    commands = []
    if not qos_dict['5qi_changed'][i]:
        return []
    qos = qos_dict['qos'][i]
    fiveqi_old = qos_dict['5qi_old'][i]
    fiveqi_new = qos_dict['5qi_target'][i]
    qos_type = qos_dict['type_target'][i]
    qosflow_disp = PARSER.get_command(
        'qosflow_disp').without_id_by_fiveqi().execute_and_parse()
    qos_of_fiveqi_new = qosflow_disp[fiveqi_new]['Id']
    commands.append(
        f'qosflow_modify qos_flow={qos_of_fiveqi_new} 5qi={DUMMY_5QI}')
    commands.append(
        f'qosflow_modify qos_flow={qos} 5qi={fiveqi_new} qos_flow_type={qos_type}')
    commands.append(
        f'qosflow_modify qos_flow={qos_of_fiveqi_new} 5qi={fiveqi_old}')
    return commands


def prepare_part_of_ue_pdu_session_modification_cmd(**params):
    pdus_dict = _parse_to_pdu_dict(**params)
    output = []
    for pdu_to_mod in pdus_dict:
        pdu = pdu_to_mod.get('pdu')
        qos_to_add = _parse_qos(pdu_to_mod, 'qos_to_add')
        qos_to_del = _parse_qos(pdu_to_mod, 'qos_to_del')
        qos_to_mod = _parse_qos(pdu_to_mod, 'qos_to_mod')
        ul_tnl = pdu_to_mod.get('ul_tnl')
        dl_tnl = pdu_to_mod.get('dl_tnl')
        s = f'pdu={pdu}'
        if qos_to_add:
            s += ' qosflows_to_add=' + ','.join(qos_to_add.get('qos'))
        if qos_to_del:
            s += ' qosflows_to_del=' + ','.join(qos_to_del.get('qos'))
        if qos_to_mod:
            s += ' qosflows_to_modify=' + ','.join(qos_to_mod.get('qos'))
        if ul_tnl:
            s += ' switch_ul_tunnel_endpoint=' + ''.join(ul_tnl)
        if dl_tnl:
            s += ' dl_tunnel_endpoint=' + ''.join(dl_tnl)
        output.append(s)
    output = ' '.join(output)
    print(
        f'prepare_part_of_ue_pdu_session_modification_cmd:\n {pprint.pformat(output)}')
    return output


def get_5qi_add_mod_per_pdu(pdu_id, **params):
    pdus_dict = _parse_to_pdu_dict(**params)
    fiveqi_list = []
    for pdu_to_mod in pdus_dict:
        if pdu_to_mod['pdu'] == pdu_id:
            add_list = _parse_qos(pdu_to_mod, 'qos_to_add').get('5qi_target')
            mod_list = _parse_qos(pdu_to_mod, 'qos_to_mod').get('5qi_target')
            if add_list:
                fiveqi_list += add_list
            if mod_list:
                fiveqi_list += mod_list
            fiveqi_str = ','.join(fiveqi_list)
            print(f'get_5qi_add_mod_per_pdu: {fiveqi_str}')
            return fiveqi_str


def get_5qi_rel_per_pdu(pdu_id, **params):
    pdus_dict = _parse_to_pdu_dict(**params)
    fiveqi_list = []
    for pdu_to_mod in pdus_dict:
        if pdu_to_mod['pdu'] == pdu_id:
            add_list = _parse_qos(pdu_to_mod, 'qos_to_del').get('5qi_target')
            if add_list:
                fiveqi_list += add_list
            fiveqi_str = ','.join(fiveqi_list)
            print(f'get_5qi_rel_per_pdu: {fiveqi_str}')
            return fiveqi_str


def get_old_5qi_changed_per_pdu(pdu_id, **params):
    pdus_dict = _parse_to_pdu_dict(**params)
    fiveqi_list = []
    for pdu_to_mod in pdus_dict:
        if pdu_to_mod['pdu'] == pdu_id:
            fiveqi_changed = _parse_qos(
                pdu_to_mod, 'qos_to_mod').get('5qi_changed')
            fiveqi_old = _parse_qos(pdu_to_mod, 'qos_to_mod').get('5qi_old')
            if not fiveqi_changed:
                return ''
            for changed, fiveqi in zip(fiveqi_changed, fiveqi_old):
                if changed:
                    fiveqi_list += fiveqi
            fiveqi_str = ','.join(fiveqi_list)
            print(f'get_old_5qi_changed_per_pdu: {fiveqi_str}')
            return fiveqi_str


def _parse_to_pdu_dict(**params):
    supported_params = ['pdu', 'qos_to_add',
                        'qos_to_del', 'qos_to_mod', 'ul_tnl', 'dl_tnl_ip']
    for param in params:
        assert param in supported_params, f'{param} is not allowed, allowed params: {supported_params}'

    pdu_list = params.get('pdu').strip().split(';')
    for key in params.keys():
        updated_param = params[key].strip().split(';')
        assert len(pdu_list) == len(updated_param), f'number of entries for {key}: ({len(updated_param)}) should '\
                                                    f'be equal to number of modified PDUs ({len(pdu_list)})'
        params.update({key: updated_param})
    # print(f'Split input params to lists:\n {pprint.pformat(params)}')

    list_of_params_for_each_pdu = []
    for i in range(len(pdu_list)):
        l1 = [item[i] for item in params.values()]
        l1 = dict(zip(params.keys(), l1))
        list_of_params_for_each_pdu.append(l1)
    print(f'Split input params to dictionary, separate for each PDU session:\n '
          f'{pprint.pformat(list_of_params_for_each_pdu)}')
    return list_of_params_for_each_pdu


def _parse_qos(dict_to_check, key):
    s = dict_to_check.get(key)
    if not s:
        return {}
    d = dict()
    d['qos'] = re.findall(r'(\d+)\([^)]*\)', s)
    d['5qi_changed'] = [True if x == '->' else False
                        for x in re.findall(r'\d+\((?:GBR_)?(?:5QI\d+)?((?:->)?)(?:GBR_)?5QI\d+\)', s)]
    d['5qi_old'] = re.findall(r'\d+\((?:GBR_)?5QI(\d+)[^)]*\)', s)
    d['5qi_target'] = re.findall(r'\d+\([^)]*5QI(\d+)\)', s)
    d['type_target'] = ['gbr' if x == 'GBR_' else 'non-gbr'
                        for x in re.findall(r'\d+\((?:GBR_)?(?:5QI\d+->)?((?:GBR_)?)5QI\d+\)', s)]
    return d


def save_initial_qosflow_configuration_from_egate():
    try:
        path = BuiltIn().get_variable_value('${OUTPUT_DIR}', os.getcwd())
    except RobotNotRunningError:
        path = os.getcwd()
    file = path + "/" + FILE_NAME
    output = get_all_flows_by_qosflow_id()
    with open(file, 'w+') as f:
        json.dump(output, f)
        print('=' * MAX_LINE_LENGTH)
        print(f'qosflow_disp result saved to {file}')


def restore_initial_qosflow_configuration_in_egate():
    initial_config = read_initial_qosflow_configuration()
    current_config = get_all_flows_by_qosflow_id()
    cmd_list = []
    for qosflow, params in initial_config.items():
        if params != current_config[qosflow]:
            cmd = f'qosflow_modify qos_flow={params["Id"]}'
            for k, v in CMD_PARAM_TO_DISP_PARAM_MAPPING.items():
                if params[v] != current_config[qosflow][v]:
                    cmd += ' ' + f'{k}={params[v]}'
            cmd_list.append(cmd)
    if cmd_list:
        print(f'Execute egate command to restore initial settings:\n')
        failed = []
        passed = []
        for cmd in cmd_list:
            try:
                status = PARSER.run_command(cmd)
                if status:
                    passed.append(cmd)
                else:
                    failed.append(cmd)
            except Exception as err:
                print(err)
                failed.append(cmd)
        print('=' * MAX_LINE_LENGTH)
        print(f'Commands executed successfully:\n {pprint.pformat(passed)} ')
        assert not failed, f'Commands NOT executed successfully:\n {pprint.pformat(failed)}'
    else:
        print('=' * MAX_LINE_LENGTH)
        print(f'No QoSflow was changed during test case execution')


def read_initial_qosflow_configuration():
    try:
        path = BuiltIn().get_variable_value('${OUTPUT_DIR}', os.getcwd())
    except RobotNotRunningError:
        path = os.getcwd()
    file = path + "/" + FILE_NAME
    print(f'Restore qosflow_disp result from file: {file}')
    with open(file, 'r') as f:
        return json.load(f)


if __name__ == '__main__':
    # params_from_robot =\
    #     {'pdu': '1;2;3', 'qos_to_add': ';5(5QI6),4(5QI4);4(5QI4)', 'qos_to_del': '4(5QI4);;5(5QI6),4(5QI4)',
    #      'qos_to_mod': '2(5QI7->5QI88);2(5QI7->GBR_5QI88),5(GBR_5QI5->5QI7),3(5QI8);', 'ul_tnl': '1.2.3.4;;',
    #      'dl_tnl_ip': ';;10.1.2.200'}
    #
    # prepare_qosflow_modify_cmd_for_5qi_change(**params_from_robot)
    # prepare_part_of_ue_pdu_session_modification_cmd(**params_from_robot)
    # get_5qi_add_mod_per_pdu(pdu_id='2', **params_from_robot)
    # get_5qi_rel_per_pdu(pdu_id='2', **params_from_robot)
    # get_old_5qi_changed_per_pdu(pdu_id='2', **params_from_robot)
    action = sys.argv[1]
    assert action in ALLOWED_PARAMS, f'Allowed params: {ALLOWED_PARAMS}'
    if action in ['save', 's']:
        save_initial_qosflow_configuration_from_egate()
    elif action in ['restore', 'r']:
        restore_initial_qosflow_configuration_in_egate()
    elif action in ['modify', 'm']:
        qos_flows_to_modify = sys.argv[2]
        print(qos_flows_to_modify)
        cmds = prepare_qosflow_modify_cmd_for_5qi_change(
            qos_to_mod=qos_flows_to_modify)
        for cmd in cmds:
            PARSER.run_command(cmd)
