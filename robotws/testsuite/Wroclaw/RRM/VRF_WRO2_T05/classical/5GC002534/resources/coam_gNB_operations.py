from robot.api import logger
from taf.sbts.oam.coam.admin import admin

current_scf_path = 'current_scf.xml'
bck_scf_name = 'scf_backup.xml'
valideStates = {'Configured', 'OnAir'}


def create_connection(ip_address, username="Nemuadmin", password="nemuuser", alias="cOAM_admin"):
    api = admin()
    if ':' in ip_address:
        ip_address = '[' + ip_address + ']'
    connection = api.connect_to(bts_host=ip_address, name=alias, username=username, password=password)
    return connection


def teardown_connection(connection):
    api = admin()
    api.teardown(connection)


def get_mrbts_id(connection):
    bts_info = connection.get_bts_info()
    assert 'mrbtsID' in bts_info, 'Could not get the MRBTS ID from get_mrbts_id().'
    return bts_info['mrbtsID']


def get_current_scf_file(connection):
    api = admin()
    admin.get_current_scf_file(api, local_dir_path=".", file_name=current_scf_path, connection=connection)


def backup_scf_file(connection):
    api = admin()
    admin.get_current_scf_file(api, local_dir_path=".", file_name=bck_scf_name,
                               timeout=900, connection=connection)


def restore_scf_file(connection):
    api = admin()
    admin.perform_commissioning(api, scf_file=bck_scf_name, skip_parameter_relation_errors=True,
                                timeout=900, connection=connection)


def check_gNB_Status(gNBStatus):
    return gNBStatus in valideStates


def check_gNB_Ready(connection):
    gNB_statuses = connection.get_bts_statuses()
#    logger.console("gNB_statuses :{}".format(gNB_statuses))
    return check_gNB_Status(gNB_statuses["proceduralState"])


def format_dist_name(dist_name, connection):
    if 'MRBTS-' not in dist_name:
        bts_id = get_mrbts_id(connection)
        return 'MRBTS-{}/'.format(bts_id) + dist_name
    return dist_name


def change_parameter_on_gNB(dist_name, param_name, param_value, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=param_name,
                                                 operation='update', value=param_value,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                 timeout=900)
    logger.console("Perfomed parameter change on gNB ({}/{}), {}".format(dist_name, param_name, param_value))


def delete_parameter_on_gNB(dist_name, parameter, value, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter,
                                                 operation="delete", value=value,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Perfomed parameter delete on gNB ({}/{}), {}".format(dist_name, parameter, value))


def download_scf_file(connection, path=current_scf_path):
    connection.get_current_scf_file('.', path)


def delete_list_from(dist_name, abbreviation, connection, skip_parameter_relation_errors=True):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=abbreviation,
                                                 operation='delete', value=False,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Perfomed list delete on gNB ({}/{})".format(dist_name, abbreviation))
