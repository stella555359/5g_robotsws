from robot.libraries.BuiltIn import BuiltIn, logger
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import (
    get_mrbts_id,
    use_admin_connection,
)
from taf.rfrl.bts.devices.du.cell_operations import EnbCellOperations, GenericCellOperations
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations
from taf.rfrl.bts.devices.asir.asir_operations import EnbAsirHubOperations, GnbAsirHubOperations
from pprint import pformat
import random
import json
import time
import subprocess
import pytz
import datetime
from on_air_tl_preparation.testline_preparation import *


def prepare_gnb_neighbour(scfs_path=False,
                          should_5G_neighbour_be_changed=True,
                          swconfig_from_path="commissionings/Krakow/swconfig/default_swconfig.txt",
                          upload_swconfig_to_neighbour=True,
                          increase_timeout_for_update_sw=False,
                          neighbour_incompatible_error_timer=False,
                          neighbour_increase_timeout_for_update_sw=False,
                          increase_time_for_checking_neighbour_bbmod=False,
                          increase_time_for_checking_neighbour_radios=False,
                          increase_time_for_checking_neighbour_cells=False,
                          scf_prefix_tag=None,
                          log_dir=None,
                          certificates=None):
    if log_dir is None:
        log_dir = os.path.join(get_builtin_value('OUTPUT DIR'), 'preparation')
    increase_timeout_for_update_sw = int(increase_timeout_for_update_sw) if increase_timeout_for_update_sw else 1800
    neighbour_increase_timeout_for_update_sw = int(neighbour_increase_timeout_for_update_sw) \
        if neighbour_increase_timeout_for_update_sw else 1800
    should_not_print_log_about_success = []

    main_bts, neighbour_enbs, neighbour_gnbs = get_neighbour_gnbs_and_enbs_info_defaults()
    if certificates:
        certificates_gnb, certificates_enb = group_certificates(certificates)
        certificates_gnb_main = certificates_gnb.pop(0)
    else:
        certificates_gnb, certificates_enb, certificates_gnb_main = None, None, None

    power_on_all_pdu_ports()

    if should_5G_neighbour_be_changed:
        prepare_5g_bts_neighbours(increase_time_for_checking_neighbour_bbmod,
                                  increase_time_for_checking_neighbour_cells,
                                  increase_time_for_checking_neighbour_radios, log_dir, neighbour_gnbs,
                                  neighbour_incompatible_error_timer, neighbour_increase_timeout_for_update_sw,
                                  scf_prefix_tag, scfs_path, should_not_print_log_about_success, swconfig_from_path,
                                  upload_swconfig_to_neighbour, certificates_gnb)

    if not any(should_not_print_log_about_success):
        log_banner_to_console('"Power Stride and Ready to Ride!"\n'
                              '                     *    '
                              'https://www.youtube.com/watch?v=p0wT4uBitcY&ab_channel=Sherif\n'
                              '                     *    Testline prepared for testing')


def add_ssh_key(filename, path, bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_ip = get_enb_host()
    else:
        bts_ip = get_gnb_host(bts_id=bts_id)

    scp_to_bts = ['sshpass', '-p', 'oZPS0POrRieRtu', 'scp', f'{path}/{filename}', f'{path}/{filename}.pub',
                  f'toor4nsn@{bts_ip}:/root/.ssh/']
    process = subprocess.Popen(scp_to_bts, stdin=subprocess.PIPE)
    time.sleep(5)
    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', f'toor4nsn@{bts_ip}']
    chmod = ['chmod', '600', f'/root/.ssh/{filename}', f'/root/.ssh/{filename}.pub']
    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE)

    for command in [chmod]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        time.sleep(5)


def get_prrh_pid(prrh_id, rmod_sn, bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_ip = get_enb_host()
    else:
        bts_ip = get_gnb_host(bts_id=bts_id)

    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', f'toor4nsn@{bts_ip}']
    fhnet_1 = ['lxc-attach', '-n', '0x1018']
    fhnet_2 = ['lxc-attach', '-n', '0x2018']
    rm_host = ['rm', '/user/toor4nsn/.ssh/known_hosts']
    ssh_ru = ['ssh', '-o', 'StrictHostKeyChecking=accept-new', f'toor4nsn@{get_rmod_ip(rmod_sn, bts, bts_id)}']
    pid = ['ps', '-ef', '|', 'grep', 'hwrel']

    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    for command in [fhnet_1, fhnet_2, rm_host, ssh_ru]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        time.sleep(3)

    command_str = ' '.join(pid) + '\n'
    process.stdin.write(command_str.encode())
    process.stdin.flush()
    output, error = process.communicate()
    output = output.decode()
    lines = output.splitlines()
    for line in lines:
        logger.console(line)
        parts = line.split(' ')
        if f'--addr=90{prrh_id}' in parts:
            for part in parts:
                if part != 'rfsw' and part.isnumeric():
                    prrh_pid = part
                    logger.console(prrh_pid)
                    break
    return prrh_pid


def trigger_fid_on_prrh(fid, ant, prrh_id, rmod_sn, bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_ip = get_enb_host()
    else:
        bts_ip = get_gnb_host(bts_id=bts_id)
    if str(fid) == '1907':
        fid = 'TXALARM'
    elif str(fid) == '1908':
        fid = 'GCALARM'
    elif str(fid) == '1911':
        fid = 'RXALARM'
    else:
        ValueError(f'fid={fid} should be 1907 or 1908 or 1911')

    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', f'toor4nsn@{bts_ip}']
    fhnet_1 = ['lxc-attach', '-n', '0x1018']
    fhnet_2 = ['lxc-attach', '-n', '0x2018']
    rm_host = ['rm', '/user/toor4nsn/.ssh/known_hosts']
    ssh_ru = ['ssh', '-o', 'StrictHostKeyChecking=accept-new', f'toor4nsn@{get_rmod_ip(rmod_sn, bts, bts_id)}']
    telnet = ['telnet', 'localhost', '15007']
    alarm_simulate = ['alarm_simulate', f'{fid}', f'{ant}', f'@{get_prrh_pid(prrh_id, rmod_sn, bts, bts_id)}']
    quit_telnet = ['quit']

    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE)

    for command in [fhnet_1, fhnet_2, rm_host, ssh_ru, telnet, alarm_simulate, quit_telnet]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        time.sleep(5)


def verify_gnb_asir_alarm_is_active(fault_name, bts_id=0):
    active_alarms = GnbAsirHubOperations(bts_id=int(bts_id)).get_active_asir_webem_alarms(bts_id=int(bts_id))
    for active_alarm in active_alarms:
        if fault_name == active_alarm['fault_name']:
            logger.info(f"'{fault_name}' alarm is visible in asir webem")
            return
    raise ValueError(f"'{fault_name}' alarm is not visible in asir webem")


def verify_enb_asir_alarm_is_active(fault_name):
    active_alarms = EnbAsirHubOperations().get_active_asir_webem_alarms()
    for active_alarm in active_alarms:
        if fault_name == active_alarm['fault_name']:
            logger.info(f"'{fault_name}' alarm is visible in asir webem")
            return
    raise ValueError(f"'{fault_name}' alarm is not visible in asir webem")


def verify_gnb_asir_alarm_is_not_active(fault_name, bts_id=0):
    active_alarms = GnbAsirHubOperations(bts_id=bts_id).get_active_asir_webem_alarms()
    for active_alarm in active_alarms:
        if fault_name == active_alarm['fault_name']:
            raise ValueError(f"Unexpected '{fault_name}' alarm is visible in asir webem")
    logger.info(f"'{fault_name}' alarm is not visible in asir webem")


def verify_enb_asir_alarm_is_not_active(fault_name):
    active_alarms = EnbAsirHubOperations().get_active_asir_webem_alarms()
    for active_alarm in active_alarms:
        if fault_name == active_alarm['fault_name']:
            raise ValueError(f"Unexpected '{fault_name}' alarm is visible in asir webem")
    logger.info(f"'{fault_name}' alarm is not visible in asir webem")


def get_gnb_host(bts_id=0):
    bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[int(bts_id)]
    bts_host = bts_instance.oam_ip.v4.split("/")[0]
    return bts_host


def get_enb_host():
    bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).enbs[0]
    bts_host = bts_instance.oam_ip.v4.split("/")[0]
    return bts_host


def get_rmod_ip(rmod_sn, bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_ip = get_enb_host()
    else:
        bts_ip = get_gnb_host(bts_id=bts_id)

    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', f'toor4nsn@{bts_ip}']
    cat_rmods_info = ['cat', '/rom/config/FRIps.txt']
    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    for command in [cat_rmods_info]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        output, error = process.communicate()
        output = output.decode()
        lines = output.splitlines()
        for line in lines:
            parts = line.split(';')
            if rmod_sn in parts:
                rmod_ip = parts[2]
    return rmod_ip


def trigger_FID1907(rmod_sn):
    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', 'toor4nsn@192.168.255.129']
    fhnet_1 = ['lxc-attach', '-n', '0x1018']
    fhnet_2 = ['lxc-attach', '-n', '0x2018']
    rm_host = ['rm', '/user/toor4nsn/.ssh/known_hosts']
    ssh_ru = ['ssh', '-o', 'StrictHostKeyChecking=accept-new', f'root@{get_rmod_ip(rmod_sn)}']
    set_ant0_pmax = ['dapd', '-gt', '0', '-60']
    confirm_ant0_stats = ['dapd', '-gcs', '0']

    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE)

    for command in [fhnet_1, fhnet_2, rm_host, ssh_ru, set_ant0_pmax, confirm_ant0_stats]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        time.sleep(3)


def trigger_FID1920_in_startup(rmod_sn):
    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', 'toor4nsn@192.168.255.129']
    fhnet_1 = ['lxc-attach', '-n', '0x1018']
    fhnet_2 = ['lxc-attach', '-n', '0x2018']
    rm_host = ['rm', '/user/toor4nsn/.ssh/known_hosts']
    rm_desired_host = ['ssh-keygen', '-R', f'{get_rmod_ip(rmod_sn)}']
    ssh_ru = ['ssh', '-o', 'StrictHostKeyChecking=accept-new', f'root@{get_rmod_ip(rmod_sn)}']
    set_alarm_test = ['dapd', '-alarmTest', '0', '1003', '1']

    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE)

    for command in [fhnet_1, fhnet_2, rm_host, rm_desired_host, ssh_ru, set_alarm_test]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        time.sleep(3)


def verify_all_bbmods_online_status(bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_type = 'ENB'
    else:
        bts_type = 'GNB'
    GenericDuOperations(bts_type=bts_type).verify_bbmod_online_status(bts_id=int(bts_id),
                                                                      du_id=0,
                                                                      bbmod_id=None,
                                                                      skip_not_installed=False)


def verify_RMOD_procedural_status(rmod_id: int, status: str, timeout=300):
    start_time = time.time()
    while time.time() - start_time < timeout:
        procedural_status = get_RMOD_procedural_status(rmod_id)
        if procedural_status == status:
            break


def get_RMOD_procedural_status(rmod_id: int):
    with use_admin_connection() as connection:
        procedural_status = None
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(rmod_id) == str(rmod_conf_id):
                procedural_status = rmod["status"].get("proceduralStatus")
                break
    return procedural_status


def verify_RMOD_operational_state(rmod_id: int, status: str, bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
    else:
        bts_host = " "

    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(rmod_id) == rmod_conf_id:
                operational_state = rmod["status"].get("operationalState")
                if operational_state != status:
                    raise ValueError(f'RMOD-{rmod_id} operationalState is not equal to {status}')
                else:
                    break
        if operational_state is None:
            raise ValueError(f'RMOD-{rmod_id} not found')


def reset_site(bts="gnb", bts_id=0, timeout=300, wait_for_reconnection=True, detailed_output=False,
               graceful_cell_shutdown=None, reset_without_ru=None):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
    else:
        bts_host = " "

    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:
        connection.reset_site(timeout=timeout, wait_for_reconnection=wait_for_reconnection,
                              detailed_output=detailed_output,
                              graceful_cell_shutdown=graceful_cell_shutdown,
                              reset_without_ru=reset_without_ru)


def get_nrcells_ids():
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        nrcells_ids_list = []
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                nrcells_ids_list.append(nrcell_conf_id)
        return nrcells_ids_list


def get_ltecells_ids(bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
    else:
        bts_host = " "

    with use_admin_connection(bts_host, bts_id=bts_id) as connection:
        bts_info = connection.get_bts_info(timeout=600)
        ltecells = bts_info["cells"]["lte"]
        ltecells_ids_list = []
        for ltecell in ltecells:
            configuration_id = ltecell["id"].get("configuration")
            if configuration_id:
                ltecell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                ltecells_ids_list.append(ltecell_conf_id)
        return ltecells_ids_list


def verify_all_expected_nrcells_are_onair(nrcells_to_skip):
    all_nrcell_list = get_nrcells_ids()
    nrcell_list = [nrcell for nrcell in all_nrcell_list if nrcell not in nrcells_to_skip]

    for nrcell in nrcell_list:
        verify_nrcell_is_onair(nrcell_id=nrcell)


def verify_all_expected_ltecells_are_onair(ltecells_to_skip, bts="gnb"):
    all_ltecell_list = get_ltecells_ids(bts=bts)
    ltecell_list = [ltecell for ltecell in all_ltecell_list if ltecell not in ltecells_to_skip]

    for ltecell in ltecell_list:
        verify_ltecell_is_onair(ltecell_id=ltecell, bts=bts)


def verify_nrcell_is_onair(nrcell_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(nrcell_id) == nrcell_conf_id:
                operational_state = nrcell["status"].get("operationalState")
                availability_status = nrcell["status"].get("availabilityStatus")
                administrative_state = nrcell["status"].get("administrativeState")

                if operational_state != "enabled" or availability_status is not None or \
                        administrative_state != "Unlocked":
                    raise ValueError(f'NRCELL-{nrcell_id} '
                                     f'operationalState is {operational_state},'
                                     f'availabilityStatus is {availability_status} and '
                                     f'administrativeState is {administrative_state}')


def verify_ltecell_is_onair(ltecell_id: int, bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
    else:
        bts_host = " "

    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:
        bts_info = connection.get_bts_info(timeout=600)
        ltecells = bts_info["cells"]["lte"]
        for ltecell in ltecells:
            configuration_id = ltecell["id"].get("configuration")
            if configuration_id:
                ltecell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(ltecell_id) == ltecell_conf_id:
                operational_state = ltecell["status"].get("operationalState")
                availability_status = ltecell["status"].get("availabilityStatus")
                administrative_state = ltecell["status"].get("administrativeState")

                if operational_state != "enabled" or availability_status is not None or \
                        administrative_state != "unlocked":
                    raise ValueError(f'LNCEL-{ltecell_id} '
                                     f'operationalState is {operational_state},'
                                     f'availabilityStatus is {availability_status} and '
                                     f'administrativeState is {administrative_state}')


def change_expected_cell_size(cell_id: int):
    expected_cell_size_values = ["2.1km", "5km", "10km", "15km", "30km", "60km", "100km"]
    delta_expected_cell_size_update = []
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                if nrcell_conf_id == str(cell_id):
                    expected_cell_size = nrcell.get("expectedCellSize")
                    logger.console(f"Current expectedCellSize value: {expected_cell_size}")
                    expected_cell_size_values.remove(expected_cell_size)
                    random_expected_cell_size = random.choice(expected_cell_size_values)
                    delta_expected_cell_size = {
                        "distName": f"{configuration_id}",
                        "operation": "update",
                        "parameters": [
                            {
                                "parameterName": "expectedCellSize",
                                "value": f"{random_expected_cell_size}",
                                "operation": "update",
                            }
                        ],
                    }
                    logger.console(f"New expectedCellSize value: {random_expected_cell_size}")
                    delta_expected_cell_size_update.append(delta_expected_cell_size)
                    logger.console(
                        f"NRCELL `expectedCellSize` delta configuration: {pformat(delta_expected_cell_size_update)}.")

    with use_admin_connection() as connection:
        connection.perform_delta_recommissioning(delta_file=json.dumps(delta_expected_cell_size_update))


def change_pmax(cell_id: int):
    delta_pmax_update = []
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                if nrcell_conf_id == str(cell_id):
                    pmax = nrcell.get("maximumOutputPower")
                    logger.console(f"Current pMax value: {pmax}")
                    new_pmax_value_list = [pmax + 0.1, pmax - 0.1]
                    new_pmax_value = random.choice(new_pmax_value_list)*10
                    delta_pmax = {
                        "distName": f"{configuration_id}",
                        "operation": "update",
                        "parameters": [
                            {
                                "parameterName": "pMax",
                                "value": f"{new_pmax_value}",
                                "operation": "update",
                            }
                        ],
                    }
                    logger.console(f"New pMax value: {new_pmax_value}")
                    delta_pmax_update.append(delta_pmax)
                    logger.console(
                        f"NRCELL `pMax` delta configuration: {pformat(delta_pmax_update)}.")

    with use_admin_connection() as connection:
        connection.perform_delta_recommissioning(delta_file=json.dumps(delta_pmax_update))


def change_random_parameter_with_nrcell_locking(cell_id: int):

    change_expected_cell_size(cell_id)
    # change_pmax(cell_id)
    # pmax = lambda: change_pmax(cell_id)
    # expected_cell_size = lambda: change_expected_cell_size(cell_id)
    # random_function = random.choice([pmax, expected_cell_size])
    # random_function()
# random.choice([change_pmax(cell_id), change_expected_cell_size(cell_id)]) ## TBD


def lock_enb_cell(bts_id=0, cell_id=1, du_id=0, administrative_state=False, max_attempts=4):
    attempt = 1
    err = None
    while attempt <= int(max_attempts):
        try:
            GenericCellOperations().lock_cell(bts_id=bts_id,
                                              cell_id=cell_id,
                                              du_id=du_id,
                                              administrative_state=administrative_state)
            break
        except AdminApiProcedureFailureException as err:
            if 'CPlane is busy' in repr(err):
                logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                logger.debug(repr(err))
                time.sleep(20)
                attempt += 1
                continue
            raise err
    else:
        raise err


def unlock_enb_cell(bts_id=0, cell_id=1, du_id=0, administrative_state=False, max_attempts=4):
    attempt = 1
    err = None
    while attempt <= int(max_attempts):
        try:
            GenericCellOperations().unlock_cell(bts_id=bts_id,
                                                cell_id=cell_id,
                                                du_id=du_id,
                                                administrative_state=administrative_state)
            break
        except AdminApiProcedureFailureException as err:
            if 'CPlane is busy' in repr(err):
                logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                logger.debug(repr(err))
                time.sleep(20)
                attempt += 1
                continue
            raise err
    else:
        raise err


def reset_cell_via_gui(bts_id=0, cell_id=1, du_id=0, with_graceful=False, timeout=60):
    GenericCellOperations().reset_cell_via_gui(bts_id=bts_id,
                                               cell_id=cell_id,
                                               du_id=du_id,
                                               with_graceful=with_graceful,
                                               timeout=timeout)


def reset_enb_cell(bts_id=0, cell_id=1, du_id=0, detailed_output=False, graceful_cell_shutdown=False, timeout=60):
    EnbCellOperations().reset_cell(bts_id=bts_id,
                                   cell_id=cell_id,
                                   du_id=du_id,
                                   detailed_output=detailed_output,
                                   graceful_cell_shutdown=graceful_cell_shutdown,
                                   timeout=timeout)


def setup_maintenance_window(bts="gnb", bts_id=0, graceful_cell_shutdown="yes", time_to_start=900, duration=30):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
        mrbts_id = get_mrbts_id(bts="enb")
    else:
        bts_host = " "
        mrbts_id = get_mrbts_id(bts_id=bts_id)

    delete_maintenance_window(bts=bts, bts_id=bts_id)
    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:

        mnl_paramters = connection.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/MNL-1",
                                                             parameter_list=["timeZone"])

    time_zone = mnl_paramters[0]["parameters"].get("timeZone")
    utc = pytz.utc
    pytz_time_zone = pytz.timezone(time_zone.split(" ")[-1])
    now_utc = datetime.datetime.utcnow()
    current_local_time = now_utc.astimezone(pytz_time_zone)
    start_time = current_local_time + datetime.timedelta(seconds=time_to_start)
    hour = start_time.hour
    minute = start_time.minute

    if hour < 10 and minute < 10:
        formated_start_time = f"0{hour}:0{minute}"
    elif hour < 10:
        formated_start_time = f"0{hour}:{minute}"
    elif minute < 10:
        formated_start_time = f"{hour}:0{minute}"
    else:
        formated_start_time = f"{hour}:{minute}"

    logger.console(f"Set maintenance windows start time: {formated_start_time}")

    delta_maintenance_window_update = []
    delta_maintenance_window = {
            "distName": f"MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FMCADM-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "maintenanceWindow",
                    "value": [
                        {
                            "daysOfWeek": "127",
                            "gracefulCellShutdown": f"{graceful_cell_shutdown}",
                            "inUse": "true",
                            "startTime": f"{formated_start_time}",
                            "windowDuration": f"{duration}"
                        }
                    ],
                    "operation": "update"
                }
            ]
        }

    delta_maintenance_window_update.append(delta_maintenance_window)

    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:
        connection.perform_delta_recommissioning(delta_file=json.dumps(delta_maintenance_window_update))


def delete_maintenance_window(bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
    else:
        bts_host = " "

    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:
        scf_content = connection.get_scf(export_type='configuration')
        if "maintenanceWindow" in scf_content:
            bts_info = connection.get_bts_info(timeout=600)
            configuration = bts_info["id"]["configuration"]
            delta_delete_maintenance_window_update = []
            delta_delete_maintenance_window = {
                "distName": f"{configuration}/MNL-1/MNLENT-1/FMCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "maintenanceWindow",
                        "value": "",
                        "operation": "delete"
                    }
                ]
            }
            delta_delete_maintenance_window_update.append(delta_delete_maintenance_window)
            connection.perform_delta_recommissioning(delta_file=json.dumps(delta_delete_maintenance_window_update))
            logger.console("maintenanceWindow deleted")
        else:
            logger.console("maintenanceWindow not found")


def verify_maintenance_window_result(rmod_id, parameter_name="maintenanceWindowResult"):

    mrbts_id = get_mrbts_id()
    expected_maintenance_window_result = f"Radio recovery reset:MRBTS-{mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-{rmod_id}"

    gnb_connection = GenericDuOperations("GNB")
    gnb_connection.connect()
    connection = gnb_connection.rest_alias.format(0, 0)
    fmcadm_parameters = \
        gnb_connection.admin.get_parameter_by_distname(connection=connection,
                                                       dist_name=f"MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1",
                                                       parameter_list=["maintenanceWindowResult"])

    maintenance_window_result = fmcadm_parameters[0]["parameters"].get("maintenanceWindowResult")

    if maintenance_window_result != expected_maintenance_window_result:
        raise ValueError(f"{maintenance_window_result} is not equal {expected_maintenance_window_result}")


def verify_asir_maintenance_window_result(quantity, parameter_name="maintenanceWindowResult", bts="gnb", bts_id=0):
    if bts.lower() == "enb":
        mrbts_id = get_mrbts_id(bts="enb")
        bts_type = "ENB"
    else:
        mrbts_id = get_mrbts_id(bts_id=bts_id)
        bts_type = "GNB"

    expected_maintenance_window_result = f"ASIR pRRH recovery reset: {quantity} pRRH"

    bts_connection = GenericDuOperations(bts_type)
    bts_connection.connect()
    connection = bts_connection.rest_alias.format(int(bts_id), 0)
    fmcadm_parameters = \
        bts_connection.admin.get_parameter_by_distname(connection=connection,
                                                       dist_name=f"MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1",
                                                       parameter_list=["maintenanceWindowResult"])

    maintenance_window_result = fmcadm_parameters[0]["parameters"].get("maintenanceWindowResult")

    if maintenance_window_result != expected_maintenance_window_result:
        raise ValueError(f"{maintenance_window_result} is not equal {expected_maintenance_window_result}")


def set_act_force_unit_auto_reset(bts="gnb", bts_id=0, expected_value="true"):
    if bts.lower() == "enb":
        bts_host = get_enb_host()
    else:
        bts_host = " "

    with use_admin_connection(bts_host=bts_host, bts_id=bts_id) as connection:
        bts_info = connection.get_bts_info(timeout=600)
        mrbts_id = bts_info["id"].get("configuration").split("-")[-1]
        fmcadm_parameters = connection.get_parameter_by_distname(dist_name=f"MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FMCADM-1",
                                                                 parameter_list=["actForceUnitAutoReset"])
        act_force_unit_auto_reset = fmcadm_parameters[0]["parameters"].get("actForceUnitAutoReset")
        if str(act_force_unit_auto_reset).lower() != str(expected_value).lower():
            delta_act_force_unit_auto_reset_update = []
            delta_act_force_unit_auto_reset = {
                "distName": f"MRBTS-{mrbts_id}/MNL-1/MNLENT-1/FMCADM-1",
                "operation": "update",
                "parameters": [
                    {
                        "parameterName": "actForceUnitAutoReset",
                        "value": f"{expected_value.lower()}",
                        "operation": "update"
                    }
                ]
            }
            delta_act_force_unit_auto_reset_update.append(delta_act_force_unit_auto_reset)
            connection.perform_delta_recommissioning(delta_file=json.dumps(delta_act_force_unit_auto_reset_update))
            logger.console(f"Set actForceUnitAutoReset to {expected_value}")
        else:
            logger.console(f"actForceUnitAutoReset is {expected_value}")
