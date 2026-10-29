from robot.api import logger
from taf.sbts.oam.coam.admin import admin
current_scf_path = 'current_scf.xml'


def create_connection(ip_address, username="Nemuadmin", password="nemuuser", alias="cOAM_admin"):
    api = admin()
    connection = api.connect_to(bts_host=ip_address, name=alias, username=username, password=password)
    return connection


def teardown_connection(connection):
    api = admin()
    api.teardown(connection)


def get_mrbts_id(connection):
    bts_info = connection.get_bts_info()
    assert 'mrbtsID' in bts_info, 'Could not get the MRBTS ID from get_mrbts_id().'
    return bts_info['mrbtsID']


def get_current_scf_file(connection, filename=current_scf_path):
    api = admin()
    return admin.get_current_scf_file(api, local_dir_path=".", file_name=filename, connection=connection)


def get_snapshot_file(location, coverage, timeout, connection, force=True):
    api = admin()
    logger.console("Gathering Snapshot file")
    api.collect_snapshot(target_file_name=location, coverage=coverage, force=force, timeout=int(timeout),
                         connection=connection)


def format_dist_name(dist_name, connection):
    if 'MRBTS-' not in dist_name:
        bts_id = get_mrbts_id(connection)
        return 'MRBTS-{}/'.format(bts_id) + dist_name
    return dist_name


def change_parameter_on_bts(dist_name, param_name, param_value, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=param_name,
                                                 operation='update', value=param_value,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed parameter change on BTS ({}/{}), {}".format(dist_name, param_name, param_value))


def delete_parameter_on_bts(dist_name, parameter, value, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter,
                                                 operation="delete", value=value,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed parameter delete on BTS ({}/{}), {}".format(dist_name, parameter, value))


def manage_object_on_bts(dist_name, param_name, operation, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_object_recommissioning(dist_name=dist_name, parameter=param_name,
                                              operation=operation,
                                              skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed object operation '{}' on BTS ({}), {}".format(operation, dist_name, param_name))


def download_scf_file(connection, path=current_scf_path):
    connection.get_current_scf_file('.', path)


def get_current_software_version(connection):
    return admin().get_sw_version(connection=connection)


def delete_list_from(dist_name, abbreviation, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=abbreviation,
                                                 operation='delete', value=False,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed list delete on BTS ({}/{})".format(dist_name, abbreviation))


def add_public_ssh_key_to_bts_to(owner, list_of_filepaths, connection):
    public_key_path = list_of_filepaths[-1]
    with open(public_key_path, 'r') as f:
        public_key = f.read().replace('\n', '')
    payload = [{'keyDescription': '# TEST', 'keyValue': public_key}]
    change_parameter_on_bts('MRBTS-{}/MNL-1/MNLENT-1/SECADM-1'.format(get_mrbts_id(connection)),
                            owner, payload, connection)
