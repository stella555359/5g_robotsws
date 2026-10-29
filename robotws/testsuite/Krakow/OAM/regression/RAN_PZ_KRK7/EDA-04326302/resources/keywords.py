from pprint import pformat
from robot.libraries.BuiltIn import BuiltIn, logger
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import use_admin_connection
import subprocess
import time
import json
import random


def get_rmod_ip(rmod_sn):
    ssh_bts_login = ['sshpass', '-p', 'oZPS0POrRieRtu', 'ssh', 'toor4nsn@192.168.255.129']
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
    fhnet = ['lxc-attach', '-n', '0x1018']
    rm_host = ['rm', '/user/toor4nsn/.ssh/known_hosts']
    ssh_ru = ['ssh', '-o', 'StrictHostKeyChecking=accept-new', f'root@{get_rmod_ip(rmod_sn)}']
    set_ant_pmax = ['dapd', '-gt', '0', '-60']
    confirm_stats = ['dapd', '-gcs', '0']

    process = subprocess.Popen(ssh_bts_login, stdin=subprocess.PIPE)

    for command in [fhnet, rm_host, ssh_ru, set_ant_pmax, confirm_stats]:
        command_str = ' '.join(command) + '\n'
        process.stdin.write(command_str.encode())
        process.stdin.flush()
        time.sleep(5)


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
