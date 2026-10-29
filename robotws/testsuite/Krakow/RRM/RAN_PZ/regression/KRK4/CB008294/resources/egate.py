"""
:copyright: Nokia Networks
:author: Damian Zak, Mateusz Plinta, Mateusz Pajor, Damian Piasecki
:maintainer: Damian Zak, Mateusz Plinta, Mateusz Pajor
:contact: damian.zak@nokia.com, mateusz.plinta@nokia.com, mateusz.pajor@nokia.com, damian.piasecki@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG, MN_RAN_L2_SW_2_KRK_Vrf_SG
"""

import re
import statistics
import time

from robot.libraries.BuiltIn import BuiltIn
from ta5g_throughput import ta5g_throughput
from ta5g_ue_mobility import ta5g_ue_mobility

from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.utilities import logger_console, logger_console_info
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts import (
    deregister_ue, detach_ue, perform_attachment_and_pdu_session_establishment_of_multiple_sa_ues,
    attach_with_sgnb_addition_of_multiple_nsa_ues, start_traffic_for_multiple_ues, attach_ue_and_establish_pdu_session,
    attach_ue_and_perform_sgnb_addition
)
from variables import *


class TrafficValidationFail(Exception):
    pass


class ScellValidationFail(Exception):
    pass


class ThroughputException(Exception):
    pass


def run_egate_command(command, return_output=True):
    BuiltIn().get_library_instance("ta5g_egate")._ute_wtssim_instance.execute_egate_command(
        command, return_output=return_output
    )


def run_egate_command_with_output(command, return_output=True):
    BuiltIn().get_library_instance("ta5g_egate")._ute_wtssim_instance.execute_egate_command(
        command, return_output=return_output, fail_regexp="WAITFOROUTPUT"
    )


def perform_5g_attach(number_of_ues=1, net_arch="SA", cell_id=None):
    if net_arch == "SA":
        perform_attachment_and_pdu_session_establishment_of_multiple_sa_ues(
            number_of_ues=number_of_ues, cell_id=cell_id)
    else:
        attach_ue_and_perform_sgnb_addition(ue_id=11, cell_id=cell_id)


def perform_5g_attach_for_specific_ue(ue_ids=(1,), net_arch="SA", cell_id=1):
    if net_arch == "SA":
        for ue in ue_ids:
            attach_ue_and_establish_pdu_session(ue_id=ue, cell_id=cell_id)
    else:
        ta5g_ue_mobility().setup_x2_link()
        for ue in ue_ids:
            attach_ue_and_perform_sgnb_addition(ue_id=ue, cell_id=cell_id)


def perform_5g_attach_and_expect_release(ue_ids=(4,)):
    for ue in ue_ids:
        ta5g_ue_mobility().attach_ue_and_expect_release(ue_id=ue)


def perform_5g_detach(ue_ids=(1,), net_arch="SA"):
    if net_arch == "SA":
        for ue in ue_ids:
            deregister_ue(ue_id=ue, pass_regexp=r'Received UE Context Release Complete from GNB-\d+')
    else:
        for ue in ue_ids:
            detach_ue(ue_id=ue)


def start_traffic(number_of_ues=1, traffic_direction="dl", net_arch="SA",
                  ul_mbps=150, dl_mbps=150, first_trf_id=1, **kwargs):
    first_ue_id = 1 if net_arch == "SA" else 11
    logger_console(f"Start {traffic_direction} traffic for {number_of_ues} {net_arch} UE/UE's")
    start_traffic_for_multiple_ues(
        number_of_ues=number_of_ues,
        traffic_direction=traffic_direction,
        first_ue_id=first_ue_id,
        net_arch=net_arch.lower(),
        ul_mbps=ul_mbps,
        dl_mbps=dl_mbps,
        first_trf_id=first_trf_id,
        **kwargs
    )


def stop_traffic(number_of_ues=1, traffic_direction="dl", net_arch="SA"):
    first_ue_id = 1 if net_arch == "SA" else 11
    logger_console(f"Stop {traffic_direction} traffic for {number_of_ues} {net_arch} UE/UE's")
    egate = BuiltIn().get_library_instance("ta5g_egate")
    for ue_id in range(first_ue_id, first_ue_id + number_of_ues):
        egate._ute_wtssim_instance.execute_egate_command(
            cmd=f"trf_data_stop ue={ue_id} dir={traffic_direction} pdu=1")


def wait_for_cells_mibs(cell_subcell_map=None, mib_reception_list=(), timeout=360):
    egate = BuiltIn().get_library_instance("ta5g_egate")
    logger_console("Waiting for BTS ready state (waiting for MIB reception) ...")
    if cell_subcell_map:
        cell_list = sorted([PCI_TO_CELL_ID_MAP[pci] for pci in cell_subcell_map.keys()])
    elif mib_reception_list:
        cell_list = list(mib_reception_list)
    else:
        cell_list = []
    egate.wait_for_information_block_reception_for_given_cells(
        cells={2: cell_list}, infoblocktype="MasterInformationBlock-NR", timeout=timeout)


def _get_activated_cells_pcis(pcell_pci, cell_subcell_map, cc, direction, number_of_ues):
    cells_assignment = _calculate_cells_assignment_per_ue(
        pcell_pci=pcell_pci,
        cell_subcell_map=cell_subcell_map,
        cc=cc,
        direction=direction,
        number_of_ues=number_of_ues
    )
    activated = []
    for values in cells_assignment.values():
        for pci in values:
            if pci not in activated:
                activated.append(pci)
    return sorted(activated)


def _calculate_cells_assignment_per_ue(pcell_pci, cell_subcell_map, cc, direction="DL", number_of_ues=1):
    """
    Calculate cells PCI's assignment per UE

    :param pcell_pci: (int)
    :param cell_subcell_map: (dict) Map containing cells pci's as keys and DL/UL variants as values. Example:
                                    cell_subcell_map={51: ['DL', 'UL'], 52: ['DL']}
    :param cc: (int) Number of CA Component Carriers
    :param direction: (str) Communication direction (DL or UL)
    :param number_of_ues: (int)
    """
    def _get_potentially_activated_cells_pcis(pcell_pci, cell_subcell_map, cc, direction):
        contiguous_cells_list = []
        for pci in [_pci for _pci in cell_subcell_map.keys() if direction.upper() in cell_subcell_map[_pci]]:
            if pcell_pci - cc < pci < pcell_pci + cc:
                contiguous_cells_list.append(pci)
        return contiguous_cells_list

    final_with_pcell_dict = {}
    list_with_pcell_contiguous = []
    chosen = None
    contiguous_cells_list = _get_potentially_activated_cells_pcis(pcell_pci, cell_subcell_map, cc, direction)

    for cell in contiguous_cells_list:
        if cell + cc <= max(contiguous_cells_list) + 1:
            list_with_pcell_contiguous.append(tuple(range(cell, cell + cc)))

    for ue_id in range(number_of_ues):
        if len(final_with_pcell_dict.keys()) == 0:
            chosen = list_with_pcell_contiguous[0]
            final_with_pcell_dict[ue_id] = chosen
        else:
            list_to_pick_from = [element for element in list_with_pcell_contiguous if element != chosen]
            overlap_dict = {pick: len(set(chosen) & set(pick)) for pick in list_to_pick_from}
            if overlap_dict:
                chosen = min(overlap_dict, key=lambda k: overlap_dict[k])
            final_with_pcell_dict[ue_id] = chosen

    return final_with_pcell_dict


def _remove_pcell_from_cells_assignment(pcell_pci, cells_assignment):
    scells_idxs = {}
    for ue_id, cell_list in cells_assignment.items():
        scells_idxs[ue_id] = [pci for pci in cell_list if pci != pcell_pci]
    return scells_idxs


def _get_scell_idxs_map(scells_assignment_dl, scells_assignment_ul, ue_id):
    mapper = {pci: s_idx for s_idx, pci in enumerate(scells_assignment_dl[ue_id], start=1)}
    scell_idxs_dl = [0] + list(mapper.values())
    scell_idxs_ul = [0] + [mapper[pci] for pci in scells_assignment_ul[ue_id]]
    return scell_idxs_dl, scell_idxs_ul, mapper


def get_scells_pci_per_ue_mapping(pcell_pci, cc_dl, cc_ul, number_of_ues, cell_subcell_map):
    cells_assignment_per_ue_dl = _calculate_cells_assignment_per_ue(
        pcell_pci=pcell_pci,
        cell_subcell_map=cell_subcell_map,
        cc=cc_dl,
        direction="DL",
        number_of_ues=number_of_ues
    )
    cells_assignment_per_ue_ul = _calculate_cells_assignment_per_ue(
        pcell_pci=pcell_pci,
        cell_subcell_map=cell_subcell_map,
        cc=cc_ul,
        direction="UL",
        number_of_ues=number_of_ues
    )
    scells_pcis_dl = _remove_pcell_from_cells_assignment(pcell_pci, cells_assignment_per_ue_dl)
    scells_pcis_ul = _remove_pcell_from_cells_assignment(pcell_pci, cells_assignment_per_ue_ul)
    return scells_pcis_dl, scells_pcis_ul


def _get_cell_occurrences(cells_per_ue_mapping):
    pci_occurr = {}
    for values in cells_per_ue_mapping.values():
        for pci in values:
            pci_occurr.setdefault(pci, 0)
            pci_occurr[pci] += 1
    return pci_occurr


def scells_state_validation(cell_subcell_map={}, state="activation", messages_occurrences=1, custom_cc_dl=None):
    """
    Validate SCells state by parsing egate output using data calculated by _prepare_data_for_scells_validation function

    :param cell_subcell_map: (dict) Map containing cells pci's as keys and DL/UL variants as values. Example:
                                    cell_subcell_map={51: ['DL', 'UL'], 52: ['DL']}
    :param state: (str) State of expected cell behaviour, activation or deactivation
    :param messages_occurrences: (int)
    :param custom_cc_dl: (int)
    """
    cells_to_validate_map = _prepare_data_for_scells_validation(
        cell_subcell_map=cell_subcell_map,
        custom_cc_dl=custom_cc_dl
    )
    logger_console_info(f"Scells state validation: state={state}, scells_to_validate_map={cells_to_validate_map}")
    validate_scells_state_in_egate(
        cells_to_validate_map=cells_to_validate_map,
        messages_occurrences=messages_occurrences,
        state=state
    )


def _prepare_data_for_scells_validation(cell_subcell_map, custom_cc_dl):
    pcell_pci = BuiltIn().get_variable_value("${PCELL_PCI}")
    cc_dl = BuiltIn().get_variable_value("${CC_DL}") if custom_cc_dl is None else int(custom_cc_dl)
    number_of_ues = len(BuiltIn().get_variable_value("${UE_IDS}"))
    cell_subcell_map = cell_subcell_map or BuiltIn().get_variable_value("${CELL_SUBCELL_MAP}")
    cells_assignment_per_ue = _calculate_cells_assignment_per_ue(
        pcell_pci=pcell_pci,
        cell_subcell_map=cell_subcell_map,
        cc=cc_dl,
        direction="DL",
        number_of_ues=number_of_ues
    )
    logger_console_info(f"PCIs per UE assignment in DL: {cells_assignment_per_ue}")
    cells_to_validate_map = _remove_pcell_from_cells_assignment(pcell_pci, cells_assignment_per_ue)
    return cells_to_validate_map


def validate_scells_state_in_egate_by_exact_cell(cells_to_validate_map={}, messages_occurrences=1, state="activation"):
    """
    Validate SCells state by parsing egate output

    :param cells_to_validate_map: (dict) Map containing UE id's (AP indexing starting from 0) as keys and cells PCI's
                                         tuples as values. Example:
                                         cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 1: (60,)}
    :param state: (str) State of expected cell behaviour, activation or deactivation
    :param messages_occurrences: (int)
    """
    missing_scells = []
    retry = 20
    retry_interval = 0.5
    state_print = "activated" if state == "activation" else "deactivated"

    while retry > 0:
        run_egate_command("set_log flush", return_output=False)
        with open("/opt/wts/latest/egate_console.log") as egate_console:
            egate_console_content = egate_console.read()
            for ue_id, cell_list in cells_to_validate_map.items():
                for cell in cell_list:
                    regex_string = re.compile(
                        rf"UeId:\b{ue_id}\b.*PhysCellId:\s*{cell}.*{state_print} successfully at airphone")
                    if len(regex_string.findall(egate_console_content)) != int(messages_occurrences):
                        missing_scells.append(f"ScellID:{cell} for UE ID:{ue_id}")
            if len(missing_scells) == 0:
                logger_console("All SCells activated successfully")
                break
        retry -= 1
        time.sleep(retry_interval)
        if retry != 0:
            missing_scells.clear()
    if len(missing_scells) > 0:
        raise ScellValidationFail(f"\nFollowing SCells are missing {state} prints: {', '.join(missing_scells)}")


def validate_scells_state_in_egate(cells_to_validate_map={}, messages_occurrences=1, state="activation"):
    """
    Validate SCells state by parsing egate output

    :param cells_to_validate_map: (dict) Map containing UE id's (AP indexing starting from 0) as keys and cells PCI's
                                         tuples as values. Example:
                                         cells_to_validate_map={0: (52, 53, 54, 55, 56, 57, 58), 1: (60,)}
    :param state: (str) State of expected cell behaviour, activation or deactivation
    :param messages_occurrences: (int)
    """
    missing_scells = {}
    retry = 20
    retry_interval = 0.5
    state_print = "activated" if state == "activation" else "deactivated"

    while retry > 0:
        missing_scells = {}
        run_egate_command("set_log flush", return_output=False)
        with open("/opt/wts/latest/egate_console.log") as egate_console:
            egate_console_content = egate_console.read()
            for ue_id, cell_list in cells_to_validate_map.items():
                regex_string = re.compile(
                    rf"UeId:\b{ue_id}\b.*PhysCellId:\s*.* {state_print} successfully at airphone")
                cell_occurrences = len(regex_string.findall(egate_console_content))
                expected_occurrences = int(messages_occurrences) * len(cell_list)
                if cell_occurrences != expected_occurrences:
                    missing_scells[ue_id] = [cell_occurrences, expected_occurrences]
            if not missing_scells:
                logger_console("All SCells activated successfully")
                break
        retry -= 1
        time.sleep(retry_interval)
    if missing_scells:
        error_message = '\n'.join([f'{scells[0]} Scells activated for UE{ue_id + 1}, expected: {scells[1]}'
                                   for ue_id, scells in missing_scells.items()])
        raise ScellValidationFail(error_message)


def _get_scells_state_prints_count(cells_to_validate_map, state="deactivated"):
    scell_print_dict = {}
    run_egate_command("set_log flush", return_output=False)
    with open("/opt/wts/latest/egate_console.log") as egate_console:
        egate_console_content = egate_console.read()
        for ue_id, cell_list in cells_to_validate_map.items():
            scell_print_dict.setdefault(ue_id, {})
            for cell in cell_list:
                regex_string = re.compile(
                    rf"UeId:{ue_id}.*PhysCellId:\s*{cell}.*{state} successfully at airphone")
                scell_print_dict[ue_id][cell] = len(regex_string.findall(egate_console_content))
    return scell_print_dict


def get_scells_state_prints_count_per_cell(state="deactivated"):
    cells_to_validate_map = _prepare_data_for_scells_validation(
        cell_subcell_map=None,
        custom_cc_dl=None
    )
    return _get_scells_state_prints_count(cells_to_validate_map, state)


def validate_traffic(ue_id=1, traffic_direction="dl", cell_traffic_validation_map={},
                     overheated_cells=(), sleep_sec=1):

    def _check_if_no_traffic(cell):
        if data[f"CellIndex-{cell}"]["Average"]["value"] != "0":
            traffic_validation_fails.append(f"CellIdx: {cell} didn\'t drop traffic due to overheating")

    def _check_if_traffic_present(cell):
        if data[f"CellIndex-{cell}"]["Average"]["value"] == "0":
            traffic_validation_fails.append(f"CellIdx: {cell} dropped traffic while it should\'t")

    traffic_validation_fails = []
    channel_type = "pdsch" if traffic_direction.lower() == "dl" else "pusch"
    parameters = {"id": f"{ue_id}", "scell": "0-11", "type": f"{channel_type}"}
    parser_instance = BuiltIn().get_library_instance("ta_egate_cmd_parser")
    ue_stats_nr = parser_instance.get_command("ue_stats_nr")
    data = ue_stats_nr(**parameters).execute_and_parse()

    pcell_pci = BuiltIn().get_variable_value("${PCELL_PCI}")
    cc_dl = BuiltIn().get_variable_value("${CC_DL}")
    cc_ul = BuiltIn().get_variable_value("${CC_UL}")
    number_of_ues = len(BuiltIn().get_variable_value("${UE_IDS}"))
    if not cell_traffic_validation_map:
        cell_traffic_validation_map = BuiltIn().get_variable_value("${CELL_SUBCELL_MAP}")
    cells_assignment_per_ue_dl = _calculate_cells_assignment_per_ue(
        pcell_pci=pcell_pci,
        cell_subcell_map=cell_traffic_validation_map,
        cc=cc_dl,
        direction="DL",
        number_of_ues=number_of_ues
    )
    cells_assignment_per_ue_ul = _calculate_cells_assignment_per_ue(
        pcell_pci=pcell_pci,
        cell_subcell_map=cell_traffic_validation_map,
        cc=cc_ul,
        direction="UL",
        number_of_ues=number_of_ues
    )
    scells_pcis_dl = _remove_pcell_from_cells_assignment(pcell_pci, cells_assignment_per_ue_dl)
    scells_pcis_ul = _remove_pcell_from_cells_assignment(pcell_pci, cells_assignment_per_ue_ul)
    cell_idxs_dl, cell_idxs_ul, pci_to_scell_idx_map = _get_scell_idxs_map(scells_pcis_dl, scells_pcis_ul, ue_id-1)
    overheated_cells_idxs = [pci_to_scell_idx_map[CELL_ID_TO_PCI_MAP[nrcell]] for nrcell in overheated_cells]
    logger_console_info(f"PCIs to cellIdx mapping: {pci_to_scell_idx_map}")
    if traffic_direction.lower() == "dl":
        logger_console_info(f"PCIs per UE assignment in DL: {cells_assignment_per_ue_dl}")
        logger_console_info(f"cellIdx per UE assignment in DL: {cell_idxs_dl}")
        cells_with_expected_traffic = cell_idxs_dl
    else:
        logger_console_info(f"PCIs per UE assignment in UL: {cells_assignment_per_ue_ul}")
        logger_console_info(f"cellIdx per UE assignment in UL: {cell_idxs_ul}")
        cells_with_expected_traffic = cell_idxs_ul

    if overheated_cells_idxs:
        logger_console_info(f"Traffic validation during UE overheating:\n"
                            f"Overheadted cells PCIs: {overheated_cells}\n"
                            f"Overheadted cells indexes: {overheated_cells_idxs}")
    for cell in overheated_cells_idxs:
        if cell in cells_with_expected_traffic:
            cells_with_expected_traffic.remove(cell)
        _check_if_no_traffic(cell)
    for cell in cells_with_expected_traffic:
        _check_if_traffic_present(cell)
    joined_traffic_validation_fails = "\n".join(traffic_validation_fails)
    if len(traffic_validation_fails) > 0:
        raise TrafficValidationFail(f"\n{joined_traffic_validation_fails}")
    else:
        logger_console_info("Traffic validated successfully")
    time.sleep(sleep_sec)  # wait needed because of internal wts problems related to traffic statistics


def validate_traffic_by_egate_cell_indexes(ue_id=1, traffic_direction="dl",
                                           cells_idxs_with_traffic=(), overheated_cells_idxs=(),
                                           sleep_sec=1):
    traffic_validation_fails = []
    channel_type = "pdsch" if traffic_direction.lower() == "dl" else "pusch"
    parameters = {"id": f"{ue_id}", "scell": "0-11", "type": f"{channel_type}"}
    parser_instance = BuiltIn().get_library_instance("ta_egate_cmd_parser")
    ue_stats_nr = parser_instance.get_command("ue_stats_nr")
    data = ue_stats_nr(**parameters).execute_and_parse()

    if overheated_cells_idxs:
        logger_console("Traffic validation during UE overheating")
        for cell in overheated_cells_idxs:
            if data[f"CellIndex-{cell}"]["Average"]["value"] != "0":
                traffic_validation_fails.append(f"CellIdx: {cell} didn\'t drop traffic due to overheating")
    if cells_idxs_with_traffic:
        for cell in cells_idxs_with_traffic:
            if data[f"CellIndex-{cell}"]["Average"]["value"] == "0":
                traffic_validation_fails.append(f"CellIdx: {cell} dropped traffic while it should\'t")
    joined_traffic_validation_fails = "\n".join(traffic_validation_fails)
    assert len(traffic_validation_fails) == 0, f"Validation fail:\n{joined_traffic_validation_fails}"
    logger_console("Traffic validated successfully")
    time.sleep(sleep_sec)  # wait needed because of internal wts problems related to traffic statistics


def change_cqi_value(profile_id=3, cqi=0):
    logger_console(f"Change CQI value to: {cqi}")
    run_egate_command(f"csi_override_testmode_nr profile_id={profile_id} cqi={cqi} cqi_mode=fixed")


def activate_testmode_profile(ue_id=1, profile_id=3, scell=1, testmode="csi_override"):
    logger_console(f"Activate testmode profile on SCell: {scell}")
    run_egate_command(
        f"ue_testmode_set_nr id={ue_id} testmode={testmode} action=activate profile_id={profile_id} scell={scell}")


def create_bler_profile():
    run_egate_command("bler_testmode_nr profile_id=6 target_mcs=7")


def create_and_activate_beam_profile():
    logger_console("Create and activate Beam control testmode profile")
    run_egate_command("beam_control_testmode_nr profile_id=1 beamType=Analog ueBeamIndexInitial=0,1,2,3,7,8,9,10 "
                      "ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50")
    run_egate_command("beam_control_testmode_nr profile_id=2 beamType=Analog ueBeamIndexInitial=0 "
                      "ssbeam_bestbeam=10 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50")
    run_egate_command("ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach")


def perform_beam_switch():
    run_egate_command(
        "ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=2 beamaction=switch")


def perform_reestablishment(ue_id=1, cell=1):
    run_egate_command(f"ue_rrc_reestablish id={ue_id} cell={cell}")


def reestablishment_flow_validation(validation_type="deactivated"):
    retry = 5
    retry_interval = 5
    fail_msgs = []
    allowed_validation_types = [
        "deactivated", "sameGNB", "viaRRCSetup"
    ]
    prints_deactivated = {
        "message c1 : rrcReestablishmentRequest": 1,
        "T301 expired: No response to RRC Reestablishment Request": 1,
        "NgLink::OnReceiveUeContextReleaseComplete": 1
    }
    prints_sameGNB = {
        "message c1 : rrcReestablishmentRequest": 1,
        "message c1 : rrcReestablishmentComplete": 1,
        "message c1 : rrcReconfigurationComplete": 2,
    }
    prints_viaRRCSetup = {
        "message c1 : rrcReestablishmentRequest": 1,
        "AMF-1: Reauthentication procedure is complete": 1,
        "NgLink::OnReceiveUeContextReleaseComplete": 1,
        "message c1 : rrcSetupComplete": 2,
        "message c1 : rrcReconfigurationComplete": 4,
    }

    if validation_type not in allowed_validation_types:
        raise ValueError(f"{validation_type} is not a supported validation type!")

    def check_messages_occurrences(messages_dict):
        for msg, count in messages_dict.items():
            msg_occurrance = egate_console_content.count(msg)
            if msg_occurrance != count:
                fail_msgs.append(f"Message '{msg}' is found {msg_occurrance} times instead of {count} times!")

    while retry > 0:
        fail_msgs.clear()
        run_egate_command("set_log flush")
        with open("/opt/wts/latest/egate_console.log") as egate_console:
            egate_console_content = egate_console.read()
        if validation_type == "deactivated":
            check_messages_occurrences(prints_deactivated)
        if validation_type == "sameGNB":
            check_messages_occurrences(prints_sameGNB)
        if validation_type == "viaRRCSetup":
            check_messages_occurrences(prints_viaRRCSetup)
        if len(fail_msgs) == 0:
            break
        retry -= 1
        if retry > 0:
            time.sleep(retry_interval)
            continue

    error_msgs_content = '\n'.join(fail_msgs)
    message = f"Reestablishment failure detected due to missing messages:\n{error_msgs_content}"
    assert len(fail_msgs) == 0, message
    logger_console_info("Reestablishment flow validation successful!")


def check_if_expected_throughput_is_reached(dl_mbps, ul_mbps, ue_ids=(1,), margin="10%"):
    """
    The function for validating expected traffic is reached

    :param dl_mbps: (str) Expected DL throughput in Mbps
    :param ul_mbps: (str) Expected UL throughput in Mbps
    :param ue_ids: (tuple) IDs of the UEs for which validation should be performed
    :param margin: (str) Margin by which the reached value may differ from the expected value
    """
    logger_console_info(f"Start validating expected traffic is reached")
    for ue_id in ue_ids:
        time.sleep(2)
        _check_if_throughput_is_within_margin(ue_id=ue_id, expected_throughput=dl_mbps, traffic_direction="dl",
                                              margin=margin)
        time.sleep(2)
        _check_if_throughput_is_within_margin(ue_id=ue_id, expected_throughput=ul_mbps, traffic_direction="ul",
                                              margin=margin)


def check_traffic_stability(ue_ids=(1,), interval=5, samples=3, margin="10%"):
    """
    The function for validating traffic stability

    :param ue_ids: (tuple) IDs of the UEs for which validation should be performed
    :param interval: (int) Period of time between subsequent checks of the throughput value
    :param samples: (int) Number of subsequent throughput value checks
    :param margin: (str) Margin that cannot be exceeded
    """
    logger_console_info(f"Start validating traffic stability")
    for ue_id in ue_ids:
        dl_thr_samples_list = _get_ues_throughput_samples_list(traffic_direction="dl", ue_id=ue_id, interval=interval,
                                                               samples=samples)
        _check_if_deviation_is_within_margin(throughput_samples_list=dl_thr_samples_list, ue_id=ue_id,
                                             traffic_direction="dl", samples=samples, margin=margin)
        ul_thr_samples_list = _get_ues_throughput_samples_list(traffic_direction="ul", ue_id=ue_id, interval=interval,
                                                               samples=samples)
        _check_if_deviation_is_within_margin(throughput_samples_list=ul_thr_samples_list, ue_id=ue_id,
                                             traffic_direction="ul", samples=samples, margin=margin)


def _get_ues_throughput_samples_list(traffic_direction="dl", ue_id=1, interval=5, samples=3):
    """
    The function for getting throughput values list

    :param traffic_direction: (str) Traffic direction
    :parma ue_id: (int) UE ID
    :parma interval: (int) Period of time between subsequent checks of the throughput value
    :param samples: (int) Number of subsequent throughput value checks
    """
    throughput_samples_list = []
    for sample in range(samples):
        try:
            throughput_value = ta5g_throughput.get_throughput_for_ue(ue_id=ue_id, direction=traffic_direction,
                                                                     selection_type="current", retry=2)
            throughput_samples_list.append(throughput_value)
            time.sleep(interval)
        except KeyError:
            raise ThroughputException(
                f"Cannot get UE throughput information by ue_stats_nr command in {sample} attempt")
    return throughput_samples_list


def _check_if_throughput_is_within_margin(expected_throughput, traffic_direction="dl", ue_id=1, margin="10%"):
    """
    The function for checking if reached throughput value is within specified margin

    :param expected_throughput: (str) Expected throughput in Mbps
    :param traffic_direction: Traffic direction
    :param ue_id: UE ID
    :param margin: Margin by which the reached value may differ from the expected value
    """
    if isinstance(margin, str) and "%" in margin:
        margin = margin.replace("%", "")
        margin = float(margin) * 0.01 * float(expected_throughput)
    else:
        margin = float(margin)

    throughput_value = (ta5g_throughput.get_throughput_for_ue(ue_id=ue_id, direction=traffic_direction,
                                                              selection_type="average", retry=2)) / 2
    expected_throughput = float(expected_throughput)
    if expected_throughput - margin <= throughput_value <= expected_throughput + margin:
        logger_console_info(f"The average {traffic_direction.upper()} throughput for UE{ue_id} "
                            f"({int(throughput_value)} Mbps) is within {margin} margin of the expected throughout "
                            f"({expected_throughput} Mbps)")
    else:
        raise ThroughputException(
            f"The average {traffic_direction.upper()} throughput for UE{ue_id} ({int(throughput_value)} Mbps) is not "
            f"within the margin of error ({margin}) of the expected throughput ({expected_throughput} Mbps)"
        )


def _check_if_deviation_is_within_margin(throughput_samples_list, ue_id=1, traffic_direction="dl", samples=3,
                                         margin="10%"):
    """
    The function for checking if throughput coefficient of variation is within specified margin

    :param throughput_samples_list: List of throughput values
    :param ue_id: (int) UE ID
    :param traffic_direction: (str) Traffic direction
    :param samples: (int) Number of subsequent throughput value checks
    :param margin: (str) Margin that cannot be exceeded
    """
    if isinstance(margin, str) and "%" in margin:
        margin = margin.replace("%", "")
    margin = float(margin)

    thr_standard_deviation = statistics.stdev(throughput_samples_list)
    thr_mean = statistics.mean(throughput_samples_list)
    coefficient_of_variation = thr_standard_deviation / thr_mean * 100

    if coefficient_of_variation <= margin:
        logger_console_info(f"{traffic_direction.upper()} throughput coefficient of variation "
                            f"({round(coefficient_of_variation, 2)}%) for UE{ue_id} from {samples} samples is within "
                            f"specified {margin}% margin")
    else:
        raise ThroughputException(
            f"{traffic_direction.upper()} throughput coefficient of variation ({round(coefficient_of_variation, 2)}%) "
            f"for UE{ue_id} from {samples} samples is higher than specified {margin}% margin")
