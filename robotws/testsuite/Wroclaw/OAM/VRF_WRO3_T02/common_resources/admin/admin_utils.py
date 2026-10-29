from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import re
from contextlib import contextmanager
from taf.sbts.oam.coam.admin import admin
from robot.api.logger import console

current_scf_path = 'current_scf.xml'


def check_if_cells_are_enabled(cells):
    # cells_state_list = re.findall(".*'operationalState':\\s'(.*)'", str(cells))
    cells_state_list = re.findall("'operationalState'(?:[^']|'')*'[a-zA-Z]*.'", str(cells))
    # logger.console(str(cells))
    logger.console(str(cells_state_list))
    if 'Disabled' in str(cells_state_list):
        return False
    # for state_group_list in cells_state_list:
    #     if state_group_list[1].upper() != 'ENABLED':
    #         return False
    return True


@contextmanager
def create_admin_connection():
    api = admin()
    connection = api.connect_to()
    logger.debug('contextmanager ADMIN connection object: {}'.format(connection))
    yield connection
    api.teardown_admin(connection=connection)


def create_connection_if_not_exist(connection, alias):
    if not connection:
        return BuiltIn().run_keyword('admin.Connect to ADMIN', 'alias={}'.format(alias))
    return connection


def create_multiple_parameters_recommission_list(params_dict):
    return [{
        'parameterName': param_name,
        'operation': 'update',
        'value': param_value
    } for param_name, param_value in params_dict.items()]


def download_scf_file(connection, path=current_scf_path):
    connection.get_current_scf_file('.', path)


def format_dist_name(dist_name, connection):
    if 'MRBTS-' not in dist_name:
        bts_id = get_mrbts_id(connection)
        return 'MRBTS-{}/'.format(bts_id) + dist_name
    return dist_name


def format_multiple_parameters_summary(params_dict):
    str_dict = ['{}: {}'.format(key, value) for key, value in params_dict.items()]
    return ', '.join(str_dict)


def get_fault_ids_from_alarms(active_alarms):
    return [alarm['faultId'] for alarm in active_alarms]


def get_mrbts_id(connection):
    bts_info = connection.get_bts_info()
    assert 'mrbtsID' in bts_info, 'Could not get the MRBTS ID from get_mrbts_id().'
    return bts_info['mrbtsID']


def get_nms_status(nms_list, manager_id):
    """Get NMS status based on Manager ID"""
    for nms in nms_list:
        for manager in nms['managerInfo']:
            if manager['managerId'] == manager_id:
                return nms['oamTlsStatus']


def get_object_path_infomodel(search_object, connection):
    api = admin()
    obj_dict_list = api.get_parameters_for_all(class_name=search_object, connection=connection)
    obj_path_list = []
    for obj_dict in obj_dict_list:
        obj_path = obj_dict['id']
        obj_path_list.append(obj_path)
    logger.console("{}(s) path list: \n{}".format(search_object, obj_path_list))
    return obj_path_list


def get_unit_status(unit_path, connection):
    api = admin()
    obj_dict = api.get_parameters(dist_name=unit_path, connection=connection)
    unit_status = obj_dict['operationalState']
    logger.console("{} status: \n{}".format(unit_path.split("/")[-1].replace('_R', ''), unit_status))
    return unit_status


def manage_object_on_bts(dist_name, param_name, operation, connection, skip_parameter_relation_errors=False,
                         timeout=900):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_object_recommissioning(dist_name=dist_name, parameter=param_name,
                                              operation=operation, timeout=timeout,
                                              skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed object operation '{}' on BTS ({}), {}".format(operation, dist_name, param_name))


def parse_local_user_name(account_user_type):
    return account_user_type[0] + account_user_type[1:3].lower() + account_user_type[3:] \
        if account_user_type != 'Nemuadmin' else account_user_type


def check_if_all_rus_operationalStates_have_expected_value(expected_value, bts_host):
    api = admin()
    connection = api.connect_to(bts_host)
    all_rus = connection.get_bts_info()['radioModules']['rmod']
    api.teardown_admin(connection=connection)
    return all([bool(re.match(expected_value, ru['status']['operationalState'])) for ru in all_rus])
