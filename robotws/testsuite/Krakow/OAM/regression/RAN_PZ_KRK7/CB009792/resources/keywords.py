import json
from pprint import pformat
from typing import List, Optional

from robot.libraries.BuiltIn import BuiltIn, logger
from taf.config.testline.airscale import SlotId
from taf.config.testline.connection_details import SshServiceDetails
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import (
    get_mrbts_id,
    use_admin_connection,
    use_ssh_connection,
    get_commissioning_path_for_test_case as get_path
)
from ute_common_admin.exception import AdminApiProcedureFailureException
import subprocess
import shlex


def toggle_nr_cells_barred_state(
    excepted_cell_pci: Optional[int] = None, to_be_barred: bool = True
):
    """Toggles `cellBarred` parameter to `barred`/`notBarred` state for desired NRCELL.
    If no `expected_cell_pci` is given then all NRCELLs would have commissioned parameter.

    Used for making desired NRCELL able to be attachable by UEs (when cell has `cellBarred` set to `notBarred`).

    :param Optional[int] excepted_cell_pci: defaults to None (if None all NRCELLs are affected)
    :param bool to_be_barred: if True then `barred` is set, otherwise `notBarred`, defaults to True
    """

    if excepted_cell_pci is None:
        excepted_cell_id = None
    else:
        excepted_cell_id = get_nr_cells_info()[excepted_cell_pci]

    planned_value = {
        True: "barred",
        False: "notBarred"
    }
    delta_nr_cells_barred_state_update = []

    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        nr_cells = bts_info["cells"]["nr"]

        for nr_cell in nr_cells:
            configuration_id = nr_cell["id"].get("configuration")
            if configuration_id:
                nr_cell_class, nr_cell_id = configuration_id.split("/")[-1].split("-")

                if (
                    "NRCELL" in nr_cell_class
                    and str(excepted_cell_id) not in nr_cell_id
                ):
                    nrcell_cell_barred_delta_parameter_update = {
                        "distName": configuration_id,
                        "operation": "update",
                        "parameters": [
                            {
                                "parameterName": "cellBarred",
                                "value": planned_value[to_be_barred],
                                "operation": "update",
                            }
                        ],
                    }

                    delta_nr_cells_barred_state_update.append(nrcell_cell_barred_delta_parameter_update)

    logger.info(f"NRCELL `cellBarred` delta configuration: {pformat(delta_nr_cells_barred_state_update)}.")
    with use_admin_connection() as connection:
        connection.perform_delta_recommissioning(
            delta_file=json.dumps(delta_nr_cells_barred_state_update)
        )


def toggle_lte_cells_barred_state(
    excepted_cell_pci: Optional[int] = None, to_be_barred: bool = True
):
    """Toggles `cellBarred` parameter to `barred`/`notBarred` state for desired LNCELL.
    If no `expected_cell_pci` is given then all NRCELLs would have commissioned parameter.

    Used for making desired LNCELL able to be attachable by UEs (when cell has `cellBarred` set to `notBarred`).

    :param Optional[int] excepted_cell_pci: defaults to None (if None all NRCELLs are affected)
    :param bool to_be_barred: if True then `barred` is set, otherwise `notBarred`, defaults to True
    """
    if excepted_cell_pci is None:
        excepted_cell_id = None
    else:
        excepted_cell_id = get_lte_cells_info()[excepted_cell_pci]

    planned_value = {
        True: "barred",
        False: "notBarred"
    }
    delta_lte_cells_barred_state_update = []

    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        lte_cells = bts_info["cells"]["lte"]

        for lte_cell in lte_cells:
            configuration_id = lte_cell["id"].get("configuration")
            if configuration_id:
                lte_cell_class, lte_cell_id = configuration_id.split("/")[-1].split("-")

                if (
                    "LNCEL" in lte_cell_class
                    and str(excepted_cell_id) not in lte_cell_id
                ):
                    lte_cell_barred_delta_parameter_update = {
                        "distName": f"{configuration_id}/SIB-0",
                        "operation": "update",
                        "parameters": [
                            {
                                "parameterName": "cellBarred",
                                "value": planned_value[to_be_barred],
                                "operation": "update",
                            }
                        ],
                    }
                    delta_lte_cells_barred_state_update.append(
                        lte_cell_barred_delta_parameter_update
                    )

    logger.info(f"LNCELL `cellBarred` delta configuration: {pformat(delta_lte_cells_barred_state_update)}.")
    with use_admin_connection() as connection:
        connection.perform_delta_recommissioning(
            delta_file=json.dumps(delta_lte_cells_barred_state_update)
        )


def _get_cells_info(rat_type: str) -> dict:
    """Get cells info as dictionary with PCI as keys and cell ID as value.

    :param str rat_type: 'lte' or 'nr' are allowed
    :return dict: cells info provided as {PCI : CELL_ID}
    """
    cells_info = {}

    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        cells_by_rat = bts_info["cells"][rat_type.lower()]
        cells_info = {
            cell["physicalCellId"]: cell["globalCellId"] for cell in cells_by_rat
        }

    logger.info(f"Cells info with PCI to CELL_ID mapping: {pformat(cells_info)}.")
    return cells_info


def get_lte_cells_info() -> dict:
    """Get LTE cells info as dictionary with PCI as keys and cell ID as value.

    :return dict: cells_info = {PCI : CELL_ID}.
    """

    return _get_cells_info(rat_type="lte")


def get_nr_cells_info() -> dict:
    """Get NR cells info as dictionary with PCI as keys and cell ID as value.

    :return dict: cells_info = {PCI : CELL_ID}.
    """
    return _get_cells_info(rat_type="nr")


def toggle_power_state_for_bbmod(bbmod_sn: str, power_on: bool = True):
    """Power ON or power OFF desired Baseband Module.

    :param str bbmod_sn: Baseband Module Serial Number
    :param bool power_on: True to power ON, False to power OFF, defaults to True
    """

    airscale_common_unit = (
        BuiltIn().get_variable_value("${tl}").gnbs[0].dus[0].airscale.common_units[0]
    )
    capacity_units = airscale_common_unit.capacity_units

    bbmod_slot_mappings = {
        bbmod.serial_number: bbmod.slot_id for bbmod in capacity_units
    }

    bbmod_slot_id = bbmod_slot_mappings[bbmod_sn]

    slot_id_to_ddal_mapping = {
        SlotId.B1: "1",
        SlotId.B2: "2",
        SlotId.B3: "3",
        SlotId.B4: "4",
        SlotId.B5: "5",
        SlotId.B6: "6",
    }

    state_to_command = {
        True: "DDAL_POWER_ON",
        False: "DDAL_POWER_OFF"
    }

    ddal_power_fsp = f"DDAL_POWER_FSP{slot_id_to_ddal_mapping[bbmod_slot_id]}"
    command = f"ddal -s ddal_power_set {ddal_power_fsp} {state_to_command[power_on]}"

    tl = BuiltIn().get_variable_value("${tl}", None)
    ssh_connection_details: SshServiceDetails = tl.gnbs[0].cu.oam_ssh_connection_details

    logger.info(f"Running command {command} to toggle BBMOD {bbmod_sn} to state_to_command[power_on].")
    with use_ssh_connection(
        hostname=ssh_connection_details.addr,  # type: ignore
        username=ssh_connection_details.username,  # type: ignore
        password=ssh_connection_details.password  # type: ignore
    ) as ssh:
        ssh.execute(command)


def toggle_sfp_administrative_state(bbmod_id: int, planned_value: str = "Unlocked"):
    """Toggle administrativeState parameter of all SFP objects in specified BBMOD object
        and activate with auto-generated delta configuration.

    :param int: bbmod_id - Baseband Module ID
    :param str: planned_value - "Unlocked" or "Locked"
    """

    delta_sfp_administrative_state_update = []

    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        baseband_modules = bts_info["basebandModules"]
        for bbmod in baseband_modules:
            ports = bbmod["ports"]

            for port in ports:
                configuration_id = port["id"].get("configuration")
                if configuration_id:
                    bbmod_port_class = configuration_id.split("/")[-1].split("-")[0]
                    bbmod_conf_id = configuration_id.split("/")[-2].split("-")[-1]
                    if "SFP" in bbmod_port_class and str(bbmod_id) in bbmod_conf_id:
                        delta_spf_administrative_state = {
                            "distName": f"{configuration_id}/LANE-1",
                            "operation": "update",
                            "parameters": [
                                {
                                    "parameterName": "administrativeState",
                                    "value": planned_value.title(),
                                    "operation": "update",
                                }
                            ],
                        }
                        delta_sfp_administrative_state_update.append(delta_spf_administrative_state)

    logger.info(f"Toggle SFT administrative state delta: {pformat(delta_sfp_administrative_state_update)}.")
    with use_admin_connection() as connection:
        connection.perform_delta_recommissioning(delta_file=json.dumps(delta_sfp_administrative_state_update))


def toggle_asirmod_administrative_state(asirmod_id: int, to_be_locked: bool = True):
    """Toggles `administrativeState` parameter to `Locked`/`Unlocked` state for desired ASIRMOD.

    :param int asirmod_id: ID of toggled ASIRMOD
    :param bool to_be_locked: if True then `Locked` is set, otherwise `Unlocked`, defaults to True
    """
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        asirmods = bts_info["radioModules"]["asirmod"]
        for asirmod in asirmods:
            configuration_id = asirmod["id"].get("configuration")
            if configuration_id:
                asirmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(asirmod_id) in asirmod_conf_id:  # type: ignore
                if to_be_locked:
                    response = connection.lock(dist_name=configuration_id, detailed_output=True, timeout=60)
                    logger.info(f'lock operation response: {response}')
                    return
                response = connection.unlock(dist_name=configuration_id, detailed_output=True, timeout=60)
                logger.info(f'unlock operation response: {response}')


def toggle_bbmod_administrative_state(bbmod_id: int, to_be_locked: bool = True):
    """Toggles `administrativeState` parameter to `Locked`/`Unlocked` state for desired BBMOD.

    :param int bbmod_id: ID of toggled BBMOD
    :param bool to_be_locked: if True then `Locked` is set, otherwise `Unlocked`, defaults to True
    """
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        baseband_modules = bts_info["basebandModules"]
        for bbmod in baseband_modules:
            configuration_id = bbmod["id"].get("configuration")
            if configuration_id:
                bbmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(bbmod_id) in bbmod_conf_id:  # type: ignore
                if to_be_locked:
                    response = connection.lock(dist_name=configuration_id, detailed_output=True, timeout=60)
                    logger.info(f'lock operation response: {response}')
                    return
                response = connection.unlock(dist_name=configuration_id, detailed_output=True, timeout=60)
                logger.info(f'unlock operation response: {response}')


def get_asirmod_administrative_state(asirmod_id: int) -> str:
    """Returns `administrativeState` parameter of desired ASIRMOD.

    :param int asirmod_id: ID of desired ASIRMOD's administrativeState
    :return str: `administrativeState` parameter value - `Locked`/`Unlocked`
    """
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        asirmods = bts_info["radioModules"]["asirmod"]
        for asirmod in asirmods:
            configuration_id = asirmod["id"].get("configuration")
            if configuration_id:
                asirmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(asirmod_id) in asirmod_conf_id:
                administrative_state = asirmod["status"].get("administrativeState")
    return administrative_state


def verify_asirmod_is_locked(asirmod_id: int):
    """To verify if `administrativeState` parameter value of desired ASIRMOD is set to `Locked`.

    :param int asirmod_id: ID of desired ASIRMOD
    :raises ValueError: raised if administrativeState is not equal to `Locked`
    """
    administrative_state = get_asirmod_administrative_state(asirmod_id=asirmod_id)
    if administrative_state != "Locked":
        raise ValueError('ASIRMOD administrativeState is not equal to "Locked"')


def get_bbmod_administrative_state(bbmod_id: int) -> str:
    """Returns `administrativeState` parameter of desired BBMOD.

    :param int bbmod_id: ID of desired BBMOD's administrativeState
    :return str: `administrativeState` parameter value - `Locked`/`Unlocked`
    """
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info()
        baseband_modules = bts_info["basebandModules"]
        for bbmod in baseband_modules:
            configuration_id = bbmod["id"].get("configuration")
            if configuration_id:
                bbmod_conf_id = configuration_id.split("/")[-1].split("-")[-1]
            if str(bbmod_id) in bbmod_conf_id:
                administrative_state = bbmod["status"].get("administrativeState")
    return administrative_state


def verify_bbmod_is_locked(bbmod_id: int):
    """To verify if `administrativeState` parameter value of desired BBMOD is set to `Locked`.

    :param int bbmod_id: ID of desired BBMOD
    :raises ValueError: raised if administrativeState is not equal to `Locked`
    """
    administrative_state = get_bbmod_administrative_state(bbmod_id=bbmod_id)
    if administrative_state != "Locked":
        raise ValueError('BBMOD administrativeState is not equal to "Locked"')


def create_object_cellscalculationreq():
    """Creates `CELLSCALCULATIONREQ` object."""

    with use_admin_connection() as connection:
        mrbts_id = get_mrbts_id()
        connection.perform_object_recommissioning(
            dist_name=f"MRBTS-{mrbts_id}/MNL-1/CMD-1/CELLSCALCULATIONREQ-1",
            parameter=[],
            operation="create",
        )


def fetch_active_fault_ids() -> List[int]:
    """Fetches list of fault id of active alarms.

    :return List[int]: active alarm's fault ids, e.g. [4655, 61524, 4654, 61652, 61649]
    """
    with use_admin_connection() as connection:
        active_alarms = connection.get_active_alarms()
        active_faults_ids = [active_alarm["faultId"] for active_alarm in active_alarms]
    return active_faults_ids


def check_if_alarm_in_active_alarms(fault_id: int) -> bool:
    """Checks if given fault_id is present in active fault IDs.

    :param int fault_id: fault ID to be checked
    :return bool:
    """
    active_faults_ids = fetch_active_fault_ids()
    return int(fault_id) in active_faults_ids


def perform_delta_recommissioning_for_test_case(test_case_name: str, scf_path):
    """Performs delta recommissioning for desired test case.

    :param str test_case_name: E.g. A02
    """
    delta_file_path = get_path(test_case_name=test_case_name, scf_type="delta")
    with use_admin_connection() as connection:
        try:
            connection.perform_delta_recommissioning(delta_file=delta_file_path)
        except AdminApiProcedureFailureException:
            fix_delta(test_case_name=test_case_name, scf_path=scf_path)
            connection.perform_delta_recommissioning(delta_file=delta_file_path)


def get_required_parameters(scf_path):
    """Returns list of parameters necessary to change

    :return _type_: list of dicts
    """
    required_parameters_list = []
    with open(f"{scf_path}/debug.log", 'r') as file:
        for line in file:
            if '"errorCode": 23' in line:
                debug_line = line
        index = debug_line.find('Received response:')
        if index != -1:
            debug_log = json.loads((debug_line[index + len('Received response:)'):]))

        errors = debug_log['payload']['requestMessage']['niddValidationResult']['logs']['definitionErrors']
        for error in errors:
            if error['error'][0]['key'] == "PARAMETER_IS_REQUIRED":
                distName = error.get('distName')
                parameter = error.get('parameter')
                required_parameter = {distName: parameter}
            required_parameters_list.append(required_parameter)
    return required_parameters_list


def get_value_of_parameter(parameter_name):
    """Returns value of desired parameter based on the current SCF

    :param _type_ parameter_name: _description_
    :return _type_: _description_
    """
    logger.console(parameter_name)
    with use_admin_connection() as connection:
        scf_content = connection.get_scf(export_type='configuration')
        index = scf_content.find(f'"{parameter_name}">')
        if index != -1:
            parameter_value = \
                scf_content[index + len(f'"{parameter_name}">'):(index+len(f'"{parameter_name}">')+50)].split()[0][:-4]
            return parameter_value


def fix_delta(test_case_name, scf_path):
    """Adds needed parameters to deltas
    """
    delta_file_path = get_path(test_case_name=test_case_name, scf_type="delta")
    with open(delta_file_path, 'r') as file:
        file_data = json.load(file)

        parameters_list = get_required_parameters(scf_path=scf_path)

        for parameter in parameters_list:
            for key in file_data:
                distname = list(parameter.keys())[0]
                if key["distName"] == distname:
                    parameter_name = list(parameter.values())[0]
                    value = get_value_of_parameter(parameter_name=parameter_name)
                    new_data = {"parameterName": f"{parameter_name}",
                                "value": f"{value}",
                                "operation": "update"}
                    key["parameters"].append(new_data)
    with open(delta_file_path, 'w') as file:
        json.dump(file_data, file)


def kill_admins():
    """Kill admin processes
    """
    ps = subprocess.Popen(['ps', '-aux'], stdout=subprocess.PIPE)
    grep = subprocess.Popen(['grep', 'admin'], stdin=ps.stdout, stdout=subprocess.PIPE)
    tr = subprocess.Popen(['tr', '-s', ' '], stdin=grep.stdout, stdout=subprocess.PIPE)
    cut = subprocess.Popen(['cut', '-d', ' ', '-f2'], stdin=tr.stdout, stdout=subprocess.PIPE)
    kill = subprocess.Popen(['xargs', 'kill'], stdin=cut.stdout, stdout=subprocess.PIPE)
