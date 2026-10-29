import testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords as krk7keywords
from taf.transport.ssh.exceptions import CommandExecutionError, ConnectionError
from robot.libraries.BuiltIn import BuiltIn, logger
from taf.transport.ssh import ssh
from datetime import datetime, timedelta
import re
import time
import json


def get_current_date() -> datetime:
    return datetime.now()


def get_bts_info_from_init_file() -> dict:
    bts_info = {
        "enb_mplane_addr": BuiltIn().get_variable_value(
            '${tl.enbs[0].x2_link_addr.v4}').split("/")[0],
        "gnb_mplane_addr": BuiltIn().get_variable_value(
            '${tl.gnbs[0].cu.oam_ssh_connection_details.addr}'),
        "username": BuiltIn().get_variable_value(
            '${tl.gnbs[0].cu.oam_ssh_connection_details.username}'),
        "password": BuiltIn().get_variable_value(
            '${tl.gnbs[0].cu.oam_ssh_connection_details.password}'),
        "awpqz_gnb_ru_sn": BuiltIn().get_variable_value(
            '${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[0].serial_number}'),
        "aphg_gnb_ru_sn": BuiltIn().get_variable_value(
            '${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].rus[1].serial_number}'),
        "apha_enb_ru_sn": BuiltIn().get_variable_value(
            '${tl.enbs[0].system_module.common_units[0].capacity_units[0].rus[1].serial_number}'),
        "aphg_enb_ru_sn": BuiltIn().get_variable_value(
            '${tl.enbs[0].system_module.common_units[0].capacity_units[0].rus[0].serial_number}'),
        "enb_bts_id": BuiltIn().get_variable_value(
            '${tl.enbs[0].global_bts_id}'),
        "gnb_bts_id": BuiltIn().get_variable_value(
            '${tl.gnbs[0].global_bts_id}')
    }
    return bts_info


def check_file_properties(directory_contents: str, file_size: str, start_time: str, end_time: str):
    file_info = [line for line in directory_contents.splitlines() if 'geolocation' in line][0]
    if not file_info:
        raise FileNotFoundError(f'Blackbox file not exist in {directory_contents}.')
    blackbox_name = file_info.split(" ")[-1]
    file_regex = r"blackbox_stored\d+_geolocation"
    assert re.search(file_regex, blackbox_name), f"{file_regex} not found in {blackbox_name}"
    file_info_without_space = [string for string in file_info.split(' ') if string != ""]
    if file_size == 'empty':
        assert int(file_info_without_space[4]) == 0, f'File size should be {file_size}'
    else:
        assert int(file_info_without_space[4]) != 0, f'File size should be {file_size}'
    verife_file_update_time(start_time, file_info, end_time)


def verify_blackbox_file_on_smod(dedicated_folder: str,
                                 file_size: str,
                                 start_time: str,
                                 end_time: str,
                                 bts_type: str = "gnb"):
    bts_hw_info = get_bts_info_from_init_file()
    with krk7keywords.use_ssh_connection(hostname=get_bts_mplane_addr(bts_type),
                                         username=bts_hw_info["username"],
                                         password=bts_hw_info["password"]) as connection:
        try:
            cmd = f"ls -l {dedicated_folder}"
            directory_contents = connection.execute(cmd)
        except (CommandExecutionError, ConnectionError, ValueError) as err:
            raise err
    check_file_properties(directory_contents, file_size, start_time, end_time)


def verify_blackbox_file_on_bbmod(bbmod_ip: str,
                                  dedicated_folder: str,
                                  file_size: str,
                                  start_time: str,
                                  end_time: str,
                                  bts_type: str = "gnb"):
    bts_hw_info = get_bts_info_from_init_file()
    proxy_connection = ssh().connect_to(get_bts_mplane_addr(bts_type),
                                        bts_hw_info["username"],
                                        bts_hw_info["password"])
    with krk7keywords.use_ssh_connection(hostname=bbmod_ip,
                                         username=bts_hw_info["username"],
                                         password=bts_hw_info["password"],
                                         proxy=proxy_connection) as connection:
        try:
            cmd = f"ls -l {dedicated_folder}"
            directory_contents = connection.execute(cmd)
        except (CommandExecutionError, ConnectionError, ValueError) as err:
            raise err
    check_file_properties(directory_contents, file_size, start_time, end_time)


def change_actLocInfoStore_status(status: str, bts_type: str = "gnb"):
    with krk7keywords.use_admin_connection(bts_host=get_bts_mplane_addr(bts_type)) as connection:
        featcadm_objects = connection.get_managed_objects("FEATCADM_A", timeout=30)
        actLocInfoStore_status = featcadm_objects[0]['parameters']['actLocInfoStore']
        if actLocInfoStore_status != status:
            connection.perform_parameter_recommissioning(
                dist_name=f'MRBTS-{get_bts_id(bts_type)}/MNL-1/MNLENT-1/FEATCADM-1',
                parameter="actLocInfoStore",
                operation="update",
                value=status)


def change_accLevSet_status(value: str, bts_type: str = "gnb"):
    with krk7keywords.use_admin_connection(bts_host=get_bts_mplane_addr(bts_type)) as connection:
        featcadm_objects = connection.get_managed_objects("FEATCADM_A", timeout=30)
        accLevSet_value = featcadm_objects[0]['parameters']['accLevSet']
        if accLevSet_value != value:
            connection.perform_parameter_recommissioning(
                dist_name=f'MRBTS-{get_bts_id(bts_type)}/MNL-1/MNLENT-1/FEATCADM-1',
                parameter="accLevSet",
                operation="update",
                value=value)


def update_modulePositioninformation_object(dist_name: str,
                                            actLocInfoStore: str,
                                            accLevSet: str,
                                            altitude: str,
                                            latitude: str,
                                            longitude: str):
    actx2_delta_parameter_update = [
        {
            "distName": "MRBTS-81055/MNL-1/MNLENT-1/FEATCADM-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actLocInfoStore",
                    "value": actLocInfoStore,
                    "operation": "update"
                },
                {
                    "parameterName": "accLevSet",
                    "value": accLevSet,
                    "operation": "update"
                }
            ]
        },
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "modulePositionInformation",
                    "value": [
                        {
                            "altitude": altitude,
                            "latitude": latitude,
                            "longitude": longitude
                        }
                    ],
                    "operation": "update"
                }
            ]
        }
    ]
    with krk7keywords.use_admin_connection() as conn:
        conn.perform_delta_recommissioning(
            delta_file=json.dumps(actx2_delta_parameter_update)
        )


def get_file_from_ru(file_path: str,
                     container_name: str,
                     ru_username: str,
                     ru_addr: str,
                     ru_password: str,
                     bts_type: str):
    bts_hw_info = get_bts_info_from_init_file()
    ssh_to_ru_cmd = ''.join(('lxc-attach -n ', container_name, ' ssh ', ru_username, '@', ru_addr, '\n'))
    read_buff_size = 65536
    try:
        time.sleep(300)
        logger.console(f"\nConnecting to ru: {ru_addr}")
        conn = ssh().connect_to(get_bts_mplane_addr(bts_type), bts_hw_info["username"], bts_hw_info["password"])
        channel = conn.invoke_shell()
        time.sleep(2)
        channel.send(ssh_to_ru_cmd)
        time.sleep(2)
        channel.send(''.join((ru_password, '\n')))
        time.sleep(2)
        channel.send(''.join(('cat ', file_path, '\n')))
        time.sleep(2)
        ru_file = channel.recv(read_buff_size)
    except (CommandExecutionError, ConnectionError) as err:
        raise err
    finally:
        ssh().disconnect(connection=conn)
    return ru_file


def verify_permanent_file_on_ru(file_path: str,
                                container_name: str,
                                ru_username: str,
                                ru_password: str,
                                ru_name: str,
                                start_time: str,
                                end_time: str,
                                bts_type: str = "gnb",
                                file_con_expec: str = "data"):
    ru_addr = get_ru_addr_from_frips_file(ru_name, bts_type)
    file_content = get_file_from_ru(file_path, container_name, ru_username, ru_addr, ru_password, bts_type)
    if file_con_expec == "clean":
        check_permanent_file_is_clean(file_content)
    elif file_con_expec == "data":
        check_permanent_file_data(file_content, ru_name, bts_type, start_time, end_time)
    elif file_con_expec == "without_managed_object":
        check_permanent_file_without_managed_object(file_content, ru_name, bts_type, start_time, end_time)
    else:
        raise Exception("Chose correct file_con_expec param option")


def verife_time_stamp(start_time: str, time_stamp: str, end_time: str):
    time_stamp = time_stamp.replace("<parameterName>Timestamp</parameterName><value>", "").replace("</value>", "")[:-6]
    file_time = datetime.strptime(time_stamp, "%Y-%m-%dT%H:%M:%S")
    start_time = datetime.strptime(start_time, "%Y-%m-%d %H:%M:%S.%f")
    end_time = datetime.strptime(end_time, "%Y-%m-%d %H:%M:%S.%f")
    if not (start_time < file_time < end_time):
        raise RuntimeError(f"\nTime stamp error: {start_time} < {file_time} < {end_time}")


def verife_file_update_time(start_time: str, file_info: str, end_time: str):
    date_patern = "(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\\s+(?:\\d{1,2}) (?:\\d{2}):(?:\\d{2})"
    file_time = re.findall(date_patern, file_info)[0]
    file_time = str(datetime.now().year) + file_time
    update_time = datetime.strptime(file_time, "%Y%b %d %H:%M") - timedelta(hours=2)
    start_time = datetime.strptime(start_time, "%Y-%m-%d %H:%M:%S.%f")
    end_time = datetime.strptime(end_time, "%Y-%m-%d %H:%M:%S.%f")
    if not (start_time < update_time < end_time):
        raise RuntimeError(f"\nFile time error: {start_time} < {update_time} < {end_time}")


def get_ru_serial_number(bts_type: str, ru_name: str):
    bts_hw_info = get_bts_info_from_init_file()
    if bts_type == "gnb":
        if ru_name == "awpqz":
            return bts_hw_info["awpqz_gnb_ru_sn"]
        elif ru_name == "aphg":
            return bts_hw_info["aphg_gnb_ru_sn"]
    elif bts_type == "enb":
        if ru_name == "apha":
            return bts_hw_info["apha_enb_ru_sn"]
        elif ru_name == "aphg":
            return bts_hw_info["aphg_enb_ru_sn"]
    else:
        raise Exception(f"{ru_name} RU not found in init file")


def get_bts_sw_version(bts_type: str, ru_name: str):
    bts_hw_info = get_bts_info_from_init_file()
    if bts_type == "enb" and ru_name != "aphg":
        with krk7keywords.use_admin_connection(bts_hw_info["enb_mplane_addr"]) as conn:
            enb_software = conn.get_software_info()["Active SW version"]
        return enb_software
    elif bts_type == "gnb" or ru_name == "aphg":
        with krk7keywords.use_admin_connection(bts_hw_info["gnb_mplane_addr"]) as conn:
            gnb_software = conn.get_software_info()["Active SW version"]
        return gnb_software
    else:
        raise Exception(f"{bts_type} unknow base stationt type. Select enb or gnb")


def get_bts_mplane_addr(bts_type: str):
    bts_hw_info = get_bts_info_from_init_file()
    if bts_type == "enb":
        return bts_hw_info["enb_mplane_addr"]
    elif bts_type == "gnb":
        return bts_hw_info["gnb_mplane_addr"]
    else:
        raise Exception(f"{bts_type} unknow base stationt type. Select enb or gnb")


def get_bts_id(bts_type: str):
    bts_hw_info = get_bts_info_from_init_file()
    if bts_type == "enb":
        return bts_hw_info["enb_bts_id"]
    elif bts_type == "gnb":
        return bts_hw_info["gnb_bts_id"]
    else:
        raise Exception(f"{bts_type} unknow base stationt type. Select enb or gnb")


def check_permanent_file_is_clean(permanent_file: str):
    clean_file_pattern = "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://schemas.xmlsoap.org/soap/envelope/\">"\
                          "<SOAP-ENV:Header><version>1.0</version></SOAP-ENV:Header><SOAP-ENV:Body><permanentObjects/>"\
                          "</SOAP-ENV:Body></SOAP-ENV:Envelope>"
    if not re.findall(clean_file_pattern, str(permanent_file)):
        raise Exception(f"Permanent file should be empty")


def check_permanent_file_data(permanent_file: str, ru_name: str, bts_type: str, start_time: str, end_time: str):
    times_tamps = []
    file_content_pattern = [
        f"<parameterName>BtsVersion</parameterName><value>{get_bts_sw_version(bts_type, ru_name)}</value>",
        "<parameterName>Location</parameterName><value>.*?value>",
        f"<parameterName>ModuleSerialNumber</parameterName><value>{get_ru_serial_number(bts_type, ru_name)}</value>",
        "<managedObject distName=\"moduleDetectedLocation\" class=\"Permanent\">",
        "<managedObject distName=\"moduleConfiguredLocation\" class=\"Permanent\">",
        "<parameterName>Timestamp</parameterName><value>"
        "(?:\\d{4})-(?:\\d{2})-(?:\\d{2})T(?:\\d{2}):(?:\\d{2}):(?:\\d{2})-(?:\\d{2}):(?:\\d{2})</value>"]
    for reg in file_content_pattern:
        file_items = re.findall(reg, str(permanent_file))
        logger.console(f"\nPermanent file:\n{file_items}")
        if not file_items:
            raise Exception(f"{reg} not found in permanent file on RU")
        elif reg == file_content_pattern[-1]:
            times_tamps = file_items
    if ru_name != "aphg" and bts_type != "enb":
        verife_time_stamp(start_time, times_tamps[0], end_time)


def check_permanent_file_without_managed_object(permanent_file: str,
                                                ru_name: str,
                                                bts_type: str,
                                                start_time: str,
                                                end_time: str):
    times_tamps = []
    file_content_pattern = [
        "<parameterName>BtsId</parameterName><value>.*?</value>",
        f"<parameterName>BtsVersion</parameterName><value>{get_bts_sw_version(bts_type, ru_name)}</value>",
        "<parameterName>Timestamp</parameterName><value>"
        "(?:\\d{4})-(?:\\d{2})-(?:\\d{2})T(?:\\d{2}):(?:\\d{2}):(?:\\d{2})-(?:\\d{2}):(?:\\d{2})</value>"]
    for reg in file_content_pattern:
        file_items = re.findall(reg, str(permanent_file))
        logger.console(f"\nPermanent file:\n{file_items}")
        if not file_items:
            raise Exception(f"{reg} not found in permanent file on RU")
        elif reg == file_content_pattern[-1]:
            times_tamps = file_items
    if ru_name != "aphg" and bts_type != "enb":
        verife_time_stamp(start_time, times_tamps[0], end_time)


def get_ru_addr_from_frips_file(ru_name: str, bts_type: str):
    frips_file = get_frips_file(bts_type)
    ru_pattern = f"MRBTS-.*?;{ru_name.upper()}"
    ip_pattern = r"\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"
    ru_addr = re.findall(ip_pattern, re.findall(ru_pattern, frips_file)[0])
    return ru_addr[0]


def get_frips_file(bts_type: str):
    bts_hw_info = get_bts_info_from_init_file()
    with krk7keywords.use_ssh_connection(hostname=get_bts_mplane_addr(bts_type),
                                         username=bts_hw_info["username"],
                                         password=bts_hw_info["password"]) as connection:
        try:
            cmd = "cat /rom/config/FRIps.txt"
            frips_file = connection.execute(cmd)
            logger.console(f"\nFRIps file:\n{frips_file}")
        except (CommandExecutionError, ConnectionError) as err:
            raise err
    return frips_file


def perform_bts_commissioning(scf_file: str, bts_type: str = "gnb"):
    with krk7keywords.use_admin_connection(bts_host=get_bts_mplane_addr(bts_type)) as conn:
        conn.perform_commissioning(scf_file=scf_file)


def set_restrictions_via_parameter_editor(prevent_param_type: str,
                                          operation: str,
                                          prevented_param: list,
                                          bts_type: str = "gnb"):
    with krk7keywords.use_admin_connection(bts_host=get_bts_mplane_addr(bts_type)) as connection:
        connection.perform_parameter_recommissioning(
            dist_name=f'MRBTS-{get_bts_id(bts_type)}/MNL-1/MNLENT-1/FEATCADM-1',
            parameter=prevent_param_type,
            operation=operation,
            value=prevented_param)


def get_scf_path_from_robotws(file_name: str):
    return krk7keywords.get_default_scf_path(file_name)
