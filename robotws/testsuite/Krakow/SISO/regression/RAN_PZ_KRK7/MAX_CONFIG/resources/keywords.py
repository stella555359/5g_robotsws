import random
import os
from robot.libraries.BuiltIn import BuiltIn, logger
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import (
    get_mrbts_id,
    use_admin_connection,
    use_ssh_connection,
)


def get_bbmods_ids():
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        bbmods = bts_info["basebandModules"]
        bbmods_ids_list = []
        for bbmod in bbmods:
            configuration_id = bbmod["id"].get("configuration")
            if configuration_id:
                bbmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                bbmods_ids_list.append(bbmod_conf_id)
        return bbmods_ids_list


def get_rmods_ids():
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        rmods_ids_list = []
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                rmods_ids_list.append(rmod_conf_id)
        return rmods_ids_list


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


def get_locked_rmods_ids():
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        locked_rmods_ids_list = []
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                administrative_state = rmod["status"].get("administrativeState")
                if administrative_state == "Locked":
                    rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                    locked_rmods_ids_list.append(rmod_conf_id)
        return locked_rmods_ids_list


def get_locked_nrcells_ids():
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        locked_nrcells_ids_list = []
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                administrative_state = nrcell["status"].get("administrativeState")
                if administrative_state == "Locked":
                    rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                    locked_nrcells_ids_list.append(rmod_conf_id)
        return locked_nrcells_ids_list


def lock_random_rmod(quantity=1):
    for i in range(int(quantity)):
        random_rmod_id = random.choice(get_rmods_ids())
        lock_rmod(random_rmod_id)
        verify_rmod_is_locked(random_rmod_id)


def lock_random_nrcell(quantity=1):
    for i in range(int(quantity)):
        random_nrcell_id = random.choice(get_nrcells_ids())
        lock_nrcell(random_nrcell_id)
        verify_nrcell_is_locked(random_nrcell_id)


def unlock_all_rmods():
    for locked_rmod_id in get_locked_rmods_ids():
        unlock_rmod(int(locked_rmod_id))


def unlock_all_nrcells():
    for locked_nrcell_id in get_locked_nrcells_ids():
        unlock_nrcell(int(locked_nrcell_id))


def lock_rmod(rmod_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(rmod_id) == rmod_conf_id:
                logger.console(f'Lock RMOD-{rmod_id}')
                response = connection.lock(dist_name=configuration_id, detailed_output=True, timeout=600)


def lock_nrcell(nrcell_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(nrcell_id) == nrcell_conf_id:
                logger.console(f'Lock NRCELL-{nrcell_id}')
                connection.lock(dist_name=configuration_id, detailed_output=True, timeout=600)


def unlock_rmod(rmod_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(rmod_id) == rmod_conf_id:
                logger.console(f'Unlock RMOD-{rmod_id}')
                response = connection.unlock(dist_name=configuration_id, detailed_output=True, timeout=600)


def unlock_nrcell(nrcell_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("internal")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(nrcell_id) == nrcell_conf_id:
                logger.console(f'Unlock NRCELL-{nrcell_id}')
                connection.unlock(dist_name=configuration_id, detailed_output=True, timeout=600)


def verify_rmod_is_locked(rmod_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(rmod_id) == rmod_conf_id:
                administrative_state = rmod["status"].get("administrativeState")
                if administrative_state != "Locked":
                    raise ValueError(f'RMOD-{rmod_id} administrativeState is not equal "Locked"')


def verify_nrcell_is_locked(nrcell_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(nrcell_id) == nrcell_conf_id:
                administrative_state = nrcell["status"].get("administrativeState")
                if administrative_state != "Locked":
                    raise ValueError(f'RMOD-{nrcell_id} administrativeState is not equal "Locked"')


def get_runtime_rmod_dist_name(rmod_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        rmods = bts_info["radioModules"]["rmod"]
        for rmod in rmods:
            configuration_id = rmod["id"].get("configuration")
            if configuration_id:
                rmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(rmod_id) == rmod_conf_id:
                dist_name = rmod["id"].get("runtime")
                return dist_name


def get_runtime_bbmod_dist_name(bbmod_id: int):
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        bbmods = bts_info["basebandModules"]
        for bbmod in bbmods:
            configuration_id = bbmod["id"].get("configuration")
            if configuration_id:
                bbmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(bbmod_id) == bbmod_conf_id:
                dist_name = bbmod["id"].get("runtime")
                return dist_name


def reset_rmod(rmod_id: int, reset_type='Soft', timeout=600, detailed_output=False):
    dist_name = get_runtime_rmod_dist_name(rmod_id=rmod_id)
    logger.console(f'Reset RMOD-{rmod_id}')
    with use_admin_connection() as connection:
        connection.reset_unit(dist_name=dist_name,
                              reset_type=reset_type,
                              timeout=timeout,
                              detailed_output=detailed_output)


def reset_bbmod(bbmod_id: int, reset_type='Warm', timeout=600, detailed_output=False):
    dist_name = get_runtime_bbmod_dist_name(bbmod_id=bbmod_id)
    logger.console(f'Reset BBMOD-{bbmod_id}')
    with use_admin_connection() as connection:
        connection.reset_unit(dist_name=dist_name,
                              reset_type=reset_type,
                              timeout=timeout,
                              detailed_output=detailed_output)


def reset_random_rmod(rmod_id_list: list = None):
    if rmod_id_list is None:
        random_rmod_id = random.choice(get_rmods_ids())
    else:
        random_rmod_id = random.choice(rmod_id_list)
    reset_rmod(random_rmod_id)


def reset_random_bbmod(bbmod_id_list: list = None):
    if bbmod_id_list is None:
        random_bbmod_id = random.choice(get_bbmods_ids())
    else:
        random_bbmod_id = random.choice(bbmod_id_list)

    reset_bbmod(random_bbmod_id)


def perform_commissioning(bts_id=None, scf_file=None, skip_parameter_relation_errors=False, should_activate=True,
                          timeout=3600):
    with use_admin_connection() as connection:
        connection.perform_commissioning(bts_id=bts_id,
                                         scf_file=scf_file,
                                         skip_parameter_relation_errors=skip_parameter_relation_errors,
                                         should_activate=should_activate,
                                         timeout=timeout)


def add_timeout_to_function(filepath, function_name, variable_name="timeout", value=1200):
    if not os.path.exists(filepath):
        logger.info(f"Error: File not found at {filepath}")
        return

    try:
        with open(filepath, 'r') as f:
            file_content = f.readlines()
    except Exception as e:
        logger.info(f"Error reading file: {e}")
        return

    function_found = False
    function_found_temp = False
    new_content = []
    for line in file_content:
        if function_name in line and "def " + function_name in line or function_found_temp:
            function_found = True
            function_found_temp = True

            if "):" in line:
                new_line = line.rstrip() + f"\n        {variable_name}={value}\n"
                new_content.append(new_line)
                function_found_temp = False
            else:
                new_content.append(line)

        else:
            new_content.append(line)

    if not function_found:
        logger.info(f"Error: Function '{function_name}' not found in file.")
        return

    try:
        with open(filepath, 'w') as f:
            f.writelines(new_content)
        logger.info(f"Successfully added timeout parameter to function '{function_name}' in {filepath}")
    except Exception as e:
        logger.info(f"Error writing to file: {e}")
