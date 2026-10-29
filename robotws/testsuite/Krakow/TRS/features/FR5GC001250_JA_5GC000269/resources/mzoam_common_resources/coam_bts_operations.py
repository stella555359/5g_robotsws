import string

from robot.api import logger
from taf.gnb.oam.coam.admin import admin
from ute_common_admin.exception import AdminApiProcedureFailureException
from testsuite.Krakow.TRS.features.FR5GC001250_JA_5GC000269.resources.mzoam_common_resources.decorators\
    import retry_if_fail, create_object_if_update_fails

current_scf_path = 'current_scf.xml'


def create_connection(ip_address, username="Nemuadmin", password="nemuuser", alias="cOAM_admin",
                      date="/home/ute/test_results"):
    api = admin()
    connection = api.connect_to(bts_host=ip_address, name=alias, username=username, password=password,
                                admin_api_log_dir=date)
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


def get_active_alarms(connection):
    return connection.get_active_alarms()


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


@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=30, part_of_msg="BTS is not ready")
@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=60,
               part_of_msg="GNSS SW update is ongoing")
def change_parameter_on_bts(dist_name, param_name, param_value, connection, skip_parameter_relation_errors=True,
                            timeout=900):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=param_name,
                                                 operation='update', value=param_value, timeout=timeout,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed parameter change on BTS ({}/{}), {}".format(dist_name, param_name, param_value))


@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=30, part_of_msg="BTS is not ready")
def delete_parameter_on_bts(dist_name, parameter, value, connection, skip_parameter_relation_errors=True,
                            timeout=900):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=parameter,
                                                 operation="delete", value=value, timeout=timeout,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed parameter delete on BTS ({}/{}), {}".format(dist_name, parameter, value))


@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=30, part_of_msg="BTS is not ready")
@create_object_if_update_fails()
def manage_object_on_bts(dist_name, param_name, operation, connection, skip_parameter_relation_errors=True,
                         timeout=900):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_object_recommissioning(dist_name=dist_name, parameter=param_name,
                                              operation=operation, timeout=timeout,
                                              skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed object operation '{}' on BTS ({}), {}".format(operation, dist_name, param_name))


@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=30, part_of_msg="BTS is not ready")
def delete_list_from(dist_name, abbreviation, connection, skip_parameter_relation_errors=True,
                     timeout=900):
    dist_name = format_dist_name(dist_name, connection)
    connection.perform_parameter_recommissioning(dist_name=dist_name, parameter=abbreviation,
                                                 operation='delete', value=False, timeout=timeout,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors)
    logger.console("Performed list delete on BTS ({}/{})".format(dist_name, abbreviation))


def add_public_ssh_key_to_bts_to(owner, list_of_filepaths, connection):
    public_key_path = list_of_filepaths[-1]
    with open(public_key_path, 'r') as f:
        public_key = f.read().replace('\n', '')
    payload = [{'keyDescription': '# TEST', 'keyValue': public_key}]
    change_parameter_on_bts('MRBTS-{}/MNL-1/MNLENT-1/SECADM-1'.format(get_mrbts_id(connection)),
                            owner, payload, connection)


def download_scf_file(connection, path=current_scf_path, timeout=60):
    connection.get_current_scf_file('.', path, timeout)


def rollback_software_by_webem(connection):
    connection.rollback_software()


def get_software_info_by_webem(connection):
    software_version = connection.get_software_info()
    return software_version


def get_bts_sw_version(connection):
    api = admin()
    return api.get_sw_version(connection=connection)


def get_bts_sw_release_name(connection):
    api = admin()
    return api.get_sw_release_name(connection=connection)


@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=30, part_of_msg="BTS is not ready")
@retry_if_fail(AdminApiProcedureFailureException, max_retries=20, interval_sec=60,
               part_of_msg="GNSS SW update is ongoing")
def commission_scf(scf_file, connection, timeout=300, skip_parameter_relation_errors=True):
    connection.perform_commissioning(
        scf_file=scf_file, skip_parameter_relation_errors=skip_parameter_relation_errors, timeout=timeout
    )


def format_hostname_string(raw_hostname):
    return string.replace(raw_hostname, '-', '_')
