import json
import time
from datetime import datetime, timedelta
from pprint import PrettyPrinter

import snapshot_history_file_tool as snap_history_file
import snapshot_utilities as tools
from bts_syslog import BtsSysHandler
from gnb_methods import GnbApiWeb as gnb
from gnb_methods import GnbSsh as ssh_gnb
from gnb_methods import ParameterException
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as gnbcell
from taf.rfrl.bts.devices.du.combined.cell_operations import GenericCombinedCellOperations as gnbcombined
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning as gnbscf
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GenericLog

from testsuite.Krakow.OAM.features.CB006483.admin_cli.keywords import AdminCommand as cli

pp = PrettyPrinter(indent=4)
tl = BuiltIn().get_variable_value("${tl}")
admin_cli = gnb()


def trigger_fault_1900():
    mrbts_id = tl.gnbs[0].instance_id
    dist_name = "MRBTS-{}/NRBTS-1/NRCELL-1".format(mrbts_id)
    gnb().perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter="pMax",
                                            operation="update",
                                            value=0)


def restore_from_fault_1900():
    mrbts_id = tl.gnbs[0].instance_id
    dist_name = "MRBTS-{}/NRBTS-1/NRCELL-1".format(mrbts_id)
    gnb().perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter="pMax",
                                            operation="update",
                                            value=260)


def get_all_cell_num(cell_type='nr'):
    info = get_cells_info(cell_type=cell_type)  # FIXME: from where it should be imported?
    nr_cell = [cell['globalCellId'] for cell in info]
    if nr_cell:
        return nr_cell
    raise Exception('Not found cell num in {}'.format(info))


def trigger_fault_49(cell_id=0):
    """"
    Fault 49 appears when cell is blocked
    """
    GnbCellOperations().block_cell(cell_id=int(cell_id))


def clear_fault_49(cell_id=0):
    GnbCellOperations().unblock_cell(cell_id=int(cell_id))


def trigger_fault_6253(lncelid=0):
    PARAMETER = 'prachConfIndex'
    INCORRECT_VALUE = 57

    bts_info = admin_cli.get_bts_info()
    lncel_technology = bts_info['cells']['lte'][lncelid]['technology']
    lncel_technology_nidd = f'LNCEL_{lncel_technology}-0'
    dist_name = bts_info['cells']['lte'][lncelid]['id']['configuration'] + '/' + lncel_technology_nidd

    gnb().perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter=PARAMETER,
                                            operation="update",
                                            value=INCORRECT_VALUE,
                                            skip_parameter_relation_errors=True)


def clear_fault_6253(lncelid=0):
    PARAMETER = 'prachConfIndex'
    CORRECT_VALUE = 3

    bts_info = admin_cli.get_bts_info()
    lncel_technology = bts_info['cells']['lte'][lncelid]['technology']
    lncel_technology_nidd = f'LNCEL_{lncel_technology}-0'
    dist_name = bts_info['cells']['lte'][lncelid]['id']['configuration'] + '/' + lncel_technology_nidd

    gnb().perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter=PARAMETER,
                                            operation="update",
                                            value=CORRECT_VALUE)
    gnb().reset_site()


def trigger_fault_6257(lncell_nidd_id=1):
    instance_id = gnb().mrbts_id
    dist_name = f"MRBTS-{instance_id}/LNBTS-{instance_id}/LNCEL-{lncell_nidd_id}/UFFIM-1"

    gnb().perform_object_recommissioning(dist_name=dist_name,
                                         operation="delete",
                                         parameter=[],
                                         skip_parameter_relation_errors=True)


def set_snapshot_destination(location='lss'):
    admin_cli.set_diagnostic_snap_destination(location=location)


def set_snapshot_destination_for_6450(location='lss'):
    admin_cli.set_diagnostic_snap_destination_for_fault_6450(location=location)


def set_ip_port_directory_for_lss(ip_addr=BuiltIn().get_variable_value("${LSS_IP_ADDR}"), port='22', directory=''):
    admin_cli.set_ip_port_directory_for_lss(ip_addr=ip_addr, port=port, directory=directory)


def restore_default_faultSnapshotTriggers():
    admin_cli.restore_default_fault_snapshot_triggers()


def add_fault_defined_by_user(fault_number, trigger_type):
    admin_cli.set_fault_snapshot_trigger(fault_number, trigger_type)


def _get_lss_credentials_base_on_snap_location(snap_location):
    user = snap_location.split('/')[2]
    if user == "ute":
        username = BuiltIn().get_variable_value("${LSS_USERNAME}")
        password = BuiltIn().get_variable_value("${LSS_PASSWORD}")
    else:
        username = BuiltIn().get_variable_value("${LSS_SECONDARY_USERNAME}")
        password = BuiltIn().get_variable_value("${LSS_SECONDARY_PASSWORD}")
    return username, password


def wait_for_snapshot_on_lss(timestamp, snap_location="/home/coam", timeout=60):
    host = BuiltIn().get_variable_value("${LSS_IP_ADDR}")
    username, password = _get_lss_credentials_base_on_snap_location(snap_location=snap_location)
    tools.wait_for_snapshot_on_remote_server(timestamp, snap_location, "LSS", host, username, password, timeout=timeout)
    wait_for_synchronization(5)


def wait_until_snapshot_starts_upload_on_lss(timestamp, snap_location="/home/coam", timeout=60):
    host = BuiltIn().get_variable_value("${LSS_IP_ADDR}")
    username, password = _get_lss_credentials_base_on_snap_location(snap_location=snap_location)
    tools.wait_until_snapshot_starts_upload_on_LSS(timestamp, snap_location, host, username, password, timeout=timeout)
    wait_for_synchronization(5)


def wait_for_snapshot_on_netact(timestamp, timeout):
    snap_location = BuiltIn().get_variable_value("${SNAP_LOCATION}")
    host = tl.nms.netact.ssh_connections_info.addr
    username = tl.nms.netact.ssh_connections_info.username
    password = tl.nms.netact.ssh_connections_info.password
    tools.wait_for_snapshot_on_remote_server(timestamp=timestamp,
                                             path=snap_location,
                                             server="NetAct",
                                             host=host,
                                             username=username,
                                             password=password,
                                             timeout=timeout)


def wait_for_snapshot_on_one_of_two_netact(timestamp, timeout):
    snap_location = BuiltIn().get_variable_value("${SNAP_LOCATION}")
    host_netact_1 = tl.nms.netact.ssh_connections_info.addr
    host_netact_2 = BuiltIn().get_variable_value("${NODE_IP}")
    username = tl.nms.netact.ssh_connections_info.username
    password = tl.nms.netact.ssh_connections_info.password
    if not tools.wait_for_snapshot_on_remote_server(timestamp=timestamp,
                                                    path=snap_location,
                                                    server="NetAct",
                                                    host=host_netact_1,
                                                    username=username,
                                                    password=password,
                                                    timeout=timeout,
                                                    raise_exception=False):
        tools.wait_for_snapshot_on_remote_server(timestamp=timestamp,
                                                 path=snap_location,
                                                 server="NetAct",
                                                 host=host_netact_2,
                                                 username=username,
                                                 password=password,
                                                 timeout=30)
    else:
        logger.console(f'Should not found the snap on NetAckt {host_netact_2}')
        check_if_snapshot_is_not_uploaded_on_netact(timestamp=timestamp,
                                                    snap_location=snap_location,
                                                    server="NetAct",
                                                    host=host_netact_2,
                                                    username=username,
                                                    password=password,
                                                    timeout=30)


def check_if_snapshot_is_not_uploaded_on_lss_and_alarm_6450_is_visible(
        timestamp, snap_location, timeout,
        username=BuiltIn().get_variable_value("${LSS_USERNAME}"),
        password=BuiltIn().get_variable_value("${LSS_PASSWORD}")):
    host = tl.test_pcs[1].default_ssh_connection_details.addr
    start_time = time.time()
    while time.time() < start_time + float(timeout):
        tools.check_if_snapshot_is_not_on_lss(timestamp, snap_location, host, username, password, timeout=5)
        admin_cli.check_if_alarm_is_visible(faultid=6450, severity='', timeout=1)
        wait_for_synchronization(5)


def check_if_snapshot_is_not_uploaded_on_lss_and_alarm_10_is_visible(
        timestamp, snap_location, timeout,
        username=BuiltIn().get_variable_value("${LSS_USERNAME}"),
        password=BuiltIn().get_variable_value("${LSS_PASSWORD}")):
    host = tl.test_pcs[1].default_ssh_connection_details.addr
    start_time = time.time()
    while time.time() < start_time + float(timeout):
        tools.check_if_snapshot_is_not_on_lss(timestamp, snap_location, host, username, password, timeout=5)
        admin_cli.check_if_alarm_is_visible(faultid=10, severity='', timeout=1)
        wait_for_synchronization(5)


def check_if_snapshot_is_not_uploaded_on_lss_and_alarm_49_is_visible(
        timestamp, snap_location, timeout,
        username=BuiltIn().get_variable_value("${LSS_USERNAME}"),
        password=BuiltIn().get_variable_value("${LSS_PASSWORD}")):
    host = tl.test_pcs[1].default_ssh_connection_details.addr
    start_time = time.time()
    while time.time() < start_time + float(timeout):
        tools.check_if_snapshot_is_not_on_lss(timestamp, snap_location, host, username, password, timeout=5)
        admin_cli.check_if_alarm_is_visible(faultid=49, severity='', timeout=1)
        wait_for_synchronization(5)


def check_if_snapshot_is_not_uploaded_on_netact(host, username, password, snap_location, timestamp, timeout,
                                                raise_exception):
    start_time = time.time()
    while time.time() < start_time + float(timeout):
        tools.check_if_snapshot_is_not_on_netact(timestamp, snap_location, host, username, password, timeout=5,
                                                 raise_exception=raise_exception)
        wait_for_synchronization(5)


def check_if_fault_snapshot_triggers_is_activated():
    admin_cli.check_if_fault_snapshot_triggers_is_activated()


def check_if_alarm_is_visible(faultid, severity='', timeout=60):
    admin_cli.check_if_alarm_is_visible(faultid=faultid, severity=severity, timeout=timeout)


def check_if_alarm_is_not_visible(faultid, severity='', timeout=60):
    admin_cli.check_if_alarm_is_not_visible(faultid=faultid, severity=severity, timeout=timeout)


def get_timestamp_for_given_fault(fault_id):
    return admin_cli.get_timestamp_for_given_fault(fault_id)


def get_timestamp_of_clearing_fault(fault_id):
    return admin_cli.get_timestamp_of_clearing_fault(fault_id)


def get_fault_list():
    return admin_cli.get_list_of_faults()


def check_fault_list_is_empty():
    fault_list_from_gnb = admin_cli.get_list_of_faults()
    if fault_list_from_gnb:
        raise Exception('Fault list is not empty! The current list: {}'.format(fault_list_from_gnb))


def check_fault_list_contains_no_default_triggers():
    fault_list_from_gnb = admin_cli.get_list_of_faults()
    default_faults_gnb = [
        fault
        for fault in fault_list_from_gnb
        if admin_cli.is_fault_in_default_faults_list(fault)
    ]
    if default_faults_gnb:
        raise ParameterException(
            f'There should not be any default faults configured, but there is! List: {pp.pformat(default_faults_gnb)}.'
        )
    logger.info(f'There are only non default snapshot fault triggers (as expected): {pp.pformat(fault_list_from_gnb)}')


def check_if_default_and_not_default_fault_triggers_are_set():
    fault_list_from_gnb = admin_cli.get_list_of_faults()
    default_faults_gnb = [
        fault
        for fault in fault_list_from_gnb
        if admin_cli.is_fault_in_default_faults_list(fault)
    ]
    user_defined_faults_gnb = [
        fault
        for fault in fault_list_from_gnb
        if not admin_cli.is_fault_in_default_faults_list(fault)
    ]
    logger.info(f'Active default faultSnapshotTriggers: {pp.pformat(default_faults_gnb)}')
    logger.info(f'Active user defined faultSnapshotTriggers: {pp.pformat(user_defined_faults_gnb)}')
    if not default_faults_gnb or not user_defined_faults_gnb:

        raise ParameterException(
            f'There should be at least one default faultSnapshotTrigger (are {len(default_faults_gnb)}) '
            f'and at least one user defined faultSnapshotTriggers (are {len(user_defined_faults_gnb)})!'
        )


def get_default_triggers():
    active_fault_triggers_list_from_gnb = admin_cli.get_list_of_faults()
    logger.info(pp.pformat(active_fault_triggers_list_from_gnb))
    return active_fault_triggers_list_from_gnb


def disable_actDefaultFaultSnapTriggers_by_cli():
    admin_cli.disable_actDefaultFaultSnapTriggers()


def enable_actDefaultFaultSnapTriggers_by_cli():
    admin_cli.enable_actDefaultFaultSnapTriggers()


def delete_fault_snapshot_trigger(fault_number, trigger_type):
    admin_cli.delete_fault_snapshot_trigger(fault_number=fault_number, trigger_type=trigger_type)


def compare_fault_trigger_lists(fault_list_1, fault_list_2):
    if len(fault_list_1) != len(fault_list_2):
        raise Exception("Fault trigger list are not equal")
    for fault in fault_list_1:
        if fault not in fault_list_2:
            raise Exception("Fault trigger list are not equal", fault)


def set_snapshotUploadDelayForFault6450(delay, skip_parameter_relation_errors=True, should_activate=True):
    admin_cli.set_snapshotUploadDelayForFault6450(delay=delay,
                                                  skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                  should_activate=should_activate)


def prepare_parameter_on_cell_base_on_existing_cell(cell_info, cell_number):
    lcrid_param = {'lcrId': str(cell_number)}
    cell_parameters_dict = cell_info.copy()
    cell_parameters_dict.update(lcrid_param)
    return cell_parameters_dict


def get_list_of_adding_cell(current_cell_list, number_of_adding_cell):
    start_cell = int(current_cell_list[-1]) + 1
    end_cell = start_cell + int(number_of_adding_cell)
    next_cell_list = [str(cell) for cell in range(start_cell, end_cell)]
    logger.info('Next list cells {}'.format(next_cell_list))
    return next_cell_list


def add_new_cells_based_on_existing_cell(current_cell_list, cell_info, list_of_adding_cell,
                                         bts_id=0, group_id=0, du_id=0, bts_type='GNB'):
    for cell in list_of_adding_cell:
        logger.console('Create cell {}'.format(cell))
        new_cell_info = prepare_parameter_on_cell_base_on_existing_cell(cell_info, cell)
        gnbcombined(bts_type=bts_type, alarm=None, bbu=None, cell=gnbcell(), scf=gnbscf(), ru=None).\
            add_new_cell_based_on_existing_cell_to_configuration(
            cell_parameters=new_cell_info,
            cell_id_to_copy_from=str(current_cell_list[0]),
            nrcell_include_subobject=True,
            activate_plan_despite_errors=True,
            bts_id=bts_id,
            group_id=group_id,
            du_id=du_id)


def remove_cells(cell_list, bts_type='GNB', bts_id=0, group_id=0, du_id=0):
    logger.console('Delete cells {}'.format(', '.join(cell_list)))
    gnbcombined(bts_type=bts_type, alarm=None, bbu=None, cell=gnbcell(), scf=gnbscf(), ru=None).\
        remove_cell_from_configuration(cell_id=cell_list,
                                       bts_id=bts_id,
                                       cell_group_id=str(group_id),
                                       du_id=du_id)


def set_maxNumSnapByFaultTrigPerDay(max_num, skip_parameter_relation_errors=True, should_activate=True):
    if not 1 <= int(max_num) <= 200:
        raise Exception("Value of maxNumSnapByFaultTrigPerDay must has value between 1 to 200, but {} has been set".
                        format(max_num))
    admin_cli.set_maxNumSnapByFaultTrigPerDay(max_num=max_num,
                                              skip_parameter_relation_errors=skip_parameter_relation_errors,
                                              should_activate=should_activate)


def wait_for_synchronization(delay):
    time.sleep(delay)


def start_btslog():
    btslog = BtsSysHandler()
    btslog.start_collecting_btslog()
    wait_for_synchronization(120)  # timeout for ensure that btslog started and created /tmp/btslog2 directory
    return btslog


def stop_btslog(btslog):
    btslog.stop_collecting_btslog()


def check_snapshot_exceeded_limit_message_presence_in_logs(timeout=1800):
    message = r'Limit defined by TRBLCADM.maxNumSnapByFaultTrigPerDay \(\w+\) exceeded'
    # TODO: Consider new argument fault_id for checking if limit exceeded for desired fault
    BtsSysHandler.wait_for_message_in_syslog(regex=message, timeout=timeout)


def set_actCli(value='True'):
    admin_cli.set_actCli(value)


def lock_x2c_link(status='locked'):
    admin_cli.x2c_link_lock_unlock(status)


def unlock_x2c_link(status='unlocked'):
    admin_cli.x2c_link_lock_unlock(status)


def check_if_snapshot_file_parameters_are_correct(result):
    param_list = list(result.keys())
    logger.info('Parameters from snapshot_file_history: {}'.format(param_list))
    default_parameters = BuiltIn().get_variable_value("@{SNAPSHOT_FILE_PARAMETERS}")
    logger.info('Default parameters: {}'.format(default_parameters))
    if len(param_list) != len(default_parameters):
        raise Exception("Snapshot file history parameters list are not equal")
    for param in default_parameters:
        if param not in param_list:
            raise Exception("Missing parameter in snapshot file history", param_list)


def create_directories_on_lss(directories, parent_dir, user, group):
    tools.create_directories_on_lss(directories=directories,
                                    parent_dir=parent_dir,
                                    user=user,
                                    group=group)


def delete_directories_on_lss(directories, parent_dir, user):
    tools.delete_directories_on_lss(directories=directories,
                                    parent_dir=parent_dir,
                                    user=user)


def Change_lss_credentials(username, password):
    admin_cli.configure_lss_account(username, password)


def get_snapshot_history(dir_path='/tmp', snapshot_file_name='Snapshot_history.txt'):
    return cli().get_snapshot_history(dir_path, snapshot_file_name)


def get_snapshot_history_file_result(snap_location=None,
                                     dir_path='/tmp',
                                     snapshot_file_name='Snapshot_history.txt'):
    return cli().get_snapshot_history_file_result(snap_location, dir_path, snapshot_file_name)


def generate_diff_between_two_snapshot_files(snapshot_file_name_earlier,
                                             snapshot_file_name_latest,
                                             dir_path='/tmp'):
    return snap_history_file.generate_diff_between_two_snapshot_files(snapshot_file_name_earlier,
                                                                      snapshot_file_name_latest,
                                                                      dir_path)


def parse_snapshot_history_file(path_to_file):
    return snap_history_file.parse_snapshot_history_file(path_to_file)


def check_snapshot_history_15min_same_trigger(snapshot_history_during_test, fault_id, trigger_type):
    trigger_type = snap_history_file.format_trigger_type_from_webem_format(trigger_type)
    snap_history_file.check_if_same_fault_in_15_min_has_proper_info(snapshot_history_during_test,
                                                                    fault_id,
                                                                    trigger_type)


def change_interface_state_on_lss(interface, state):
    host = tl.test_pcs[1].default_ssh_connection_details.addr
    username = tl.test_pcs[1].default_ssh_connection_details.username
    password = tl.test_pcs[1].default_ssh_connection_details.password
    tools.change_interface_state_on_lss(interface, state, host, username, password)


def collect_snapshot_and_check_if_contains_core_dumps():
    robot_logs_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
    snapshot_path = GenericLog().collect_snapshot(log_dir=robot_logs_dir, timeout=1800)

    tools.unpack_all_file_from_zip(snapshot_path, robot_logs_dir + "/snapshot/")
    file_tree = tools.get_snapshot_file_organization(robot_logs_dir + "/snapshot/")
    result = tools.get_file_from_snapshot_by_key('crashdumps', file_tree)
    logger.console("Snapshot core dump: " + str(result))

    if not result:
        raise Exception("Snapshot does not contain core dumps logs.".format(snapshot_path))


def verify_if_bts_gather_core_dumps_logs():
    ssh_gnb().verify_if_bts_gather_core_dumps_logs()


def verify_result_of_last_snapshot_in_snapshot_history_file(output_snap_history, expected_result, failed_reason):

    if type(output_snap_history) is list:
        last_entry_snap_hist = json.loads(output_snap_history[-1])
    elif type(output_snap_history) is dict:
        last_entry_snap_hist = output_snap_history
    else:
        raise Exception("Not supported type of output_snap_history.")

    if not last_entry_snap_hist['snapshot_result'] == expected_result and \
            failed_reason not in last_entry_snap_hist['failed_reason']:
        raise Exception("Snapshot result of the last collected snapshot is not: {}".format(expected_result))


def add_hours_delay_to_timestamp(timestamp, delay, minutes=0, seconds=0):
    timestamp = datetime.strptime(timestamp, "%Y%m%d%H%M")
    new_timestamp = timestamp + timedelta(hours=int(delay), minutes=int(minutes), seconds=int(seconds))
    return new_timestamp.strftime("%Y%m%d%H%M")


def trigger_fault_6450():
    ssh_gnb().kill_sigsegv()
    time.sleep(5)
    gnb().reset_site()


def are_two_faultTriggerLists_equal(fault_trigger_list1: list, fault_trigger_list2: list):
    if len(fault_trigger_list1) != len(fault_trigger_list2):
        raise Exception('Two list of faultSnapshotTriggers are not equal due to difference in no. of elements!')
    for fault_trigger in fault_trigger_list1:
        if fault_trigger not in fault_trigger_list2:
            raise Exception('Two faultSnapshotTrigger list are not equal!')


def are_two_faultTriggerLists_not_equal(fault_trigger_list1: list, fault_trigger_list2: list):
    if len(fault_trigger_list1) != len(fault_trigger_list2):
        return
    differs = []
    for fault_trigger in fault_trigger_list1:
        if fault_trigger not in fault_trigger_list2:
            differs.append(fault_trigger)
    for fault_trigger in fault_trigger_list2:
        if fault_trigger not in fault_trigger_list1:
            differs.append(fault_trigger)
    if not differs:
        raise Exception('Two faultSnapshotTriggers seems to be identical, but should not!')
