from robot.api import logger
from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from ute_common_abstract_core.message import KeyFindingDict, NotFoundKey
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_utilities import robot_kw, robot_logger
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_common import get_admin_connection, verify_admin_reloaded_and_sw_changed
from taf.rfrl.uuf4all.resources.python.uuf_rfrl_exceptions import MissingDeltaPlanError, \
    WrongBtsStateError, BtsStateCheckError, AdminNotReloadedError, \
    SwVersionNotChangedError
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.internal.robot_typecasts import time_to_seconds
import re
from taf.hw.rf_attenuator import rf_attenuator
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools import keywords
from pprint import pformat
from datetime import datetime
import time
from shutil import copyfile
import taf.rfrl.procedures.resources.python.connections as connections


def flatten(in_list):
    out_list = []
    logger.debug(f'flatten(): {in_list=}')

    def loop(li):
        for el in li:
            if isinstance(el, list):
                loop(el)
            else:
                out_list.append(str(el))
    loop(in_list)
    logger.debug(f'flatten(): {out_list=}')
    return out_list


@keyword("Convert [${string_to_convert}] to list")
def convert(string_to_convert: str) -> list:
    """Converts string_to_convert
    eg. '1,2, 3,44..48 , 4, 6, 5,7,77,22..24'
    to Python list ['1', '2', '3', '44', '45', '46', '47', '48', '4', '6', '5', '7', '77', '22', '23', '24']
    """
    if string_to_convert is None:
        return None
    final_list = flatten([list(range(int(el.split("..")[0]), 1+int(el.split("..")[1]))) if ".." in el else el.strip()
                          for el in string_to_convert.split(",")])
    return final_list


def convert_unit_to_uexgate(expected_tput):
    expected, unit = re.split(r"(\D+)", expected_tput)[0:2]
    expected = int(expected)
    logger.debug(f"convert_unit_to_uexgate: {expected=} {unit=}")
    if unit == "Kbits/sec":
        unit = "kbps"
    elif unit == "Mbits/sec":
        unit = "Mbps"
    else:
        raise ValueError(f"Currently allowed unit are: [Kbits/sec | Mbits/sec]")
    return expected, unit


def verify_throughput_in_cus_cell(cell_id, t_type, expected, deviation):
    """
    This function verifies average throughput on cell with expected one
    param t_type - 'dl' or 'ul' - uses trf_dtat_stats (RECOMMENDED), otherwise (e.g. dl_mac) uses cell_stats
    """
    uexgate = BuiltIn().get_library_instance("ta_uexgate")
    expected, unit = convert_unit_to_uexgate(expected)
    deviation = int(re.split(r"(\D+)", deviation)[0]) * expected / 100
    logger.info(f"Expected {expected}{unit}, deviation +-{deviation}{unit}")
    if t_type == 'dl' or t_type == 'ul':
        tput = uexgate.get_trf_data_stats(unit=unit, ue=cell_id, cell=cell_id)[t_type]
    else:
        tput = uexgate.get_cell_stats(type=t_type, unit=unit, id=cell_id)
    logger.info(f"{t_type} tput of cell_{cell_id} is: {tput}", also_console=False)
    avg_tput = tput["avg"]
    logger.info(f"Average {t_type} tput of cell_{cell_id} is: {avg_tput:.3f}", also_console=True)
    if abs(expected - avg_tput) > deviation:
        raise ValueError(f"Actual {t_type} throughput ({avg_tput:.3f}{unit}) on cell {cell_id}" +
                         f" is not as expected ({expected - deviation}{unit} < {expected}{unit}" +
                         f" < {expected + deviation}{unit})")


def stabilize_lte_cus_tput(cell_list, t_type: str, expected_dict, deviation, timeout=60):
    """
    function waits until tput reach expected value (minus deviation) or time exceed
    param t_type - 'dl' or 'ul' - uses trf_dtat_stats (RECOMMENDED), otherwise (e.g. dl_mac) uses cell_stats
    param expected_dict - must be dict of 2-el list where key is cell and list contains dl and ul expected tputs
    """
    uexgate = BuiltIn().get_library_instance("ta_uexgate")
    if not isinstance(cell_list, list):
        cell_list = [cell_list]
    direction = 0 if t_type.startswith('dl') else 1
    start = time.time()
    while time.time() < start + time_to_seconds(timeout):
        tput_too_low = False
        for cell_id in cell_list:
            logger.debug(f'{cell_id=}, {expected_dict[cell_id]=}')
            logger.debug(f'{expected_dict[cell_id][direction]=}')
            expected, unit = convert_unit_to_uexgate(dict(expected_dict)[cell_id][direction])
            deviation_ = int(re.split(r"(\D+)", deviation)[0]) * expected / 100
            logger.info(f"Expected {expected}{unit}, deviation +-{deviation_}{unit}")
            if t_type == 'dl' or t_type == 'ul':
                tput = uexgate.get_trf_data_stats(unit=unit, ue=cell_id, cell=cell_id)[t_type]
            else:
                tput = uexgate.get_cell_stats(type=t_type, unit=unit, id=cell_id)
            logger.info(f"{t_type} tput of cell_{cell_id} is: {tput}", also_console=False)
            curr_tput = tput["cur"]
            logger.info(f"Current {t_type} tput of cell_{cell_id} is: {curr_tput:.3f}", also_console=False)
            tput_too_low = True if expected - curr_tput > deviation_ else tput_too_low
        if not tput_too_low:
            logger.info(f"Tput stabilization ended. Elapsed {time.time() - start:.3f} seconds", also_console=True)
            return True
        time.sleep(5)
    logger.warn(f"Tput stabilization unsuccesfull. Timeout after {time.time() - start:.3f} seconds")
    return False


@robot_kw
def get_certain_sw_version(admin_inst, connection, sw_type="Active SW version"):
    """
    param sw_type - Possible values are: "Active SW version", "Passive SW version", "Planned SW version",
                    "Active GSM RAT version", "Active WCDMA RAT version",
                    "Active LTE RAT version", "Active NR RAT version"
    """
    sw_version = admin_inst.get_software_info(connection=connection)[sw_type]
    logger.info(f"{sw_version=}")
    if sw_version.split("_", 3)[2] == "9999" or sw_version.split("_", 3)[2] == "9990":
        sw_version = "_".join(["SBTS00", sw_version.split("_", 1)[1]])
    if "5G" in sw_version.split("_", 1)[0]:
        release = sw_version.split("_", 1)[0]
        build_number = ".".join([_.lstrip("0") for _ in sw_version.split("_")[2::]])
        sw_version = "_".join([release, build_number])
    return sw_version


def check_sw_version_and_rollback_if_needed(expected_sw_ver: str, remote=False, rollback_timeout=600,
                                            site_timeout=900, cell_timeout=120):
    GnbDuOperations().connect()
    admin_inst = admin()
    admin_connection = connections.get_default_admin_connection_alias()
    passive_sw_version = get_certain_sw_version(admin_inst, connection=admin_connection, sw_type="Passive SW version")
    active_sw_version = get_certain_sw_version(admin_inst, connection=admin_connection, sw_type="Active SW version")
    logger.info(f"Expected SW version is {expected_sw_ver}"
                + f", passive sw version is {passive_sw_version}, active sw version is {active_sw_version}")
    if expected_sw_ver == active_sw_version:
        robot_logger(
            "Active SW on BTS : {}\nNo need to Rollback".format(active_sw_version), "info")
        logger.info(f"{datetime.now().strftime('%X')} - Teardown Admin Connection", also_console=True)
        admin_inst.teardown_all_aliases_for_admin()
    elif expected_sw_ver == passive_sw_version:
        try:
            robot_logger(
                "Active SW on BTS : {}\nStarting SW Rollback".format(active_sw_version), "info")
            rollback_status = admin_inst.rollback_software(timeout=2400, connection=admin_connection)
            logger.info(f"{datetime.now().strftime('%X')} - {rollback_status}", also_console=True)
            start = time.time()
            while time.time() < start + time_to_seconds(rollback_timeout):
                try:
                    verify_admin_reloaded_and_sw_changed(expected_sw_ver)
                    break
                except Exception as ex:
                    logger.info(f"{datetime.now().strftime('%X')} - {ex=}", also_console=False)
                    time.sleep(30)
            else:
                verify_admin_reloaded_and_sw_changed(expected_sw_ver)
            logger.info(f"{datetime.now().strftime('%X')} - SW version changed", also_console=True)
            GnbDuOperations().wait_for_site_to_be_onair(timeout=site_timeout)
            logger.info(f"{datetime.now().strftime('%X')} - Site OnAir", also_console=True)
            GnbCellOperations().wait_for_all_cells_to_be_onair(timeout=cell_timeout)
            logger.info(f"{datetime.now().strftime('%X')} - All cells OnAir", also_console=True)
            return rollback_status
        except Exception as e:
            robot_logger(
                "Exception occurred during SW Rollback {}".format(e), "error")
            raise e
        finally:
            logger.info(f"{datetime.now().strftime('%X')} - Teardown Admin Connection", also_console=True)
            admin_inst.teardown_all_aliases_for_admin()
    else:
        robot_logger(
            "Active SW on BTS : {}\nPassive SW on BTS : {}\n".format(active_sw_version, passive_sw_version)
            + "Provide proper SW version ({})".format(expected_sw_ver), "error")
        logger.info(f"{datetime.now().strftime('%X')} - Teardown Admin Connection", also_console=True)
        admin_inst.teardown_all_aliases_for_admin()
        raise Exception


def log_keys_ue_info(ue_info: dict, key_list: list[str]):
    info = ''
    for key in key_list:
        try:
            info += f"{key}:{str(KeyFindingDict.get_all_values_by_key(ue_info, key)).strip('[]')} "
        except NotFoundKey:
            logger.trace(f"NotFoundKey: {key}")
    logger.info(f"UE connected to {info}", also_console=True)


def unblock_all_blocked_cells(cells_list):
    """
    This function unblocks all cells blocked
    :param cells_list - List of all configured cells
    :return adm_alias - admin connection object
    """
    general_cells_info = []
    admin_inst = admin()
    adm_alias = admin_inst.connect_to()
    bts_cells_info = adm_alias.get_bts_info(timeout=10, connection=adm_alias)
    rats = ["lte", "nr"]
    dist_name_runtime_cells_blocked = []
    for rat in rats:
        general_cells_info.extend(bts_cells_info[rat])
    for cell_id in cells_list:
        for cell_info in general_cells_info:
            if cell_info['status']['blockingState'] != "Unblocked" and cell_info["globalCellId"] == int(cell_id):
                dist_name_runtime_cells_blocked.append(cell_info['id']['internal'])
    for dist in dist_name_runtime_cells_blocked:
        adm_alias.unlock_cell(dist_name=dist)
    admin_inst.teardown_all_aliases_for_admin()


def setup_attenuation_for_nr_and_lte_cells(port, value):
    att = rf_attenuator()
    radio_rack = att.setup_attenuator(vendor='RadioRack',
                                      ip_addr='10.253.176.134',
                                      port=50000,
                                      attenuation_port_numbers=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
                                                                12, 13, 14, 15, 16])
    radio_rack.set_port_attenuation(port=port, attenuation_value=value)


def log_alarms(also_console=False):
    with keywords.use_admin_connection() as connection:
        alarms = connection.get_active_alarms()
    logger.write(pformat(alarms), level='DEBUG')
    logger.info("Alarm brief", also_console=also_console)
    for alarm in alarms:
        logger.info(f"*AlarmId: {alarm['alarmId']}; alarmName: {alarm['alarmName']}\n"
                    + f" |-FaultId: {alarm['additionalFaultID']}; faultName: {alarm['faultName']}\n"
                    + f" |-Object: {alarm['alarmingObjectIds'][0]['configuration']}",
                      also_console=also_console)


def config_handler(scf_file_paths):
    admin_inst = admin()
    admin_conn = admin_inst.connect_to()
    sw_version = admin_conn.get_software_info()["Active SW version"]
    if sw_version.split("_", 3)[2] == "9999" or sw_version.split("_", 3)[2] == "9990":
        sw_version = "_".join(["SBTS00", sw_version.split("_", 1)[1]])
    match = re.search(r'([A-Z0-9]+)', sw_version)
    if match:
        release = match.group()
        path_with_release = scf_file_paths + f"/{release}"
        return path_with_release


def add_param_to_swconfig(parameter, path):
    with open(path, 'r+') as sw_config:
        raw_param = parameter.split("#", 1)[0].strip(" ")                   # drop comments in file
        logger.info(f"Searching {raw_param} in swconfig...")
        param_found = any([raw_param in line for line in sw_config])
        if not param_found:
            logger.info(f"Not found. Adding new {parameter=} to swconfig")
            sw_config.write(f"\n{parameter}\n")
        else:
            logger.info(f"'{parameter=}' already in swconfig, skipping.")


def copy_and_modify_swconfig(parameters_list=[],
                             source_path="commissionings/Krakow/swconfig/default_swconfig.txt",
                             target_path="custom_swconfig.txt"):
    copyfile(src=source_path, dst=target_path)
    parameters_list = [parameters_list] if isinstance(parameters_list, str) else parameters_list
    for parameter in parameters_list:
        add_param_to_swconfig(parameter, target_path)
