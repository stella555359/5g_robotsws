import glob
import os
import re
import json
from jinja2 import Template
from robot.libraries.BuiltIn import BuiltIn
import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.tl_configuration import tl
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import (
    TSharkCommandAssembler,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.resource.dcap.dcap import (
    find_value_by_key_dcap_json,
)
from taf.sbts.oam.coam.admin import admin
import taf.transport.ssh as ssh
from ta5g_enb import ta5g_enb
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.CB008950.resources.dcap_verifier import find_scell_phycellid_id_value

from robot.api import logger

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "delta_templates")
admin = admin()
mrbts_id = tl.gnbs[0].global_bts_id
UE_CELLS_DICT = {}


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


def delta_commisioning(
    json_delta,
):
    template = load_delta_template("{}.json".format(json_delta))
    delta = template.render(mrbts_id=mrbts_id)
    __perform_delta(delta)


def __perform_delta(delta_str):
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(
            delta_file=delta_str,
            skip_parameter_relation_errors=False,
            should_activate=True,
            timeout=300,
        )


def verify_all_cells_state_with_admin(lte_locked=False, is_db_201=False):
    expected_cell_state_nr = {
        "operationalState": "Enabled",
        "proceduralStatus": "configured",
        "blockingState": "Unblocked",
        "administrativeState": "Unlocked",
        "usageState": "Active",
        "barringStatus": "unbarred",
    }
    expected_cell_state_nr_db201 = {
        "operationalState": "Disabled",
        "proceduralStatus": "Initialization Required",
        "blockingState": "Unblocked",
        "administrativeState": "Locked",
        "usageState": "Idle",
        "barringStatus": "unbarred",
        "availabilityStatus": "Off Line",
    }
    if lte_locked:
        expected_cell_state_lte = {
            "operationalState": "Disabled",
            "administrativeState": "Locked",
            "usageState": "Idle",
            "blockingState": "Unblocked",
            "availabilityStatus": "Off Line",
        }
    else:
        expected_cell_state_lte = {
            "operationalState": "Enabled",
            "administrativeState": "Unlocked",
            "usageState": "Idle",
            "blockingState": "Unblocked",
        }
    expected_cell_state_lte_db201 = {
        "operationalState": "Enabled",
        "administrativeState": "Unlocked",
        "usageState": "Idle",
        "blockingState": "Unblocked",
    }
    expected_cell_state_gsm = {
        "operationalState": "Enabled",
        "administrativeState": "Unlocked",
        "usageState": "Active",
        "blockingState": "Unblocked",
    }
    expected_bts_status = {
        "operationalState": "Enabled",
        "proceduralState": "OnAir",
        "blockingState": "Unblocked",
    }
    cells_info_nr = admin.get_cells_info(cell_type="nr", timeout=30, connection="cOAM")
    cells_info_lte = admin.get_cells_info(
        cell_type="lte", timeout=30, connection="cOAM"
    )
    cells_info_gsm = admin.get_cells_info(
        cell_type="gsm", timeout=30, connection="cOAM"
    )
    cells_info_wcdma = admin.get_cells_info(
        cell_type="wcdma", timeout=30, connection="cOAM"
    )
    print("cell_info_nr", cells_info_nr)
    print("cell_info_lte", cells_info_lte)
    print("cell_info_gsm", cells_info_gsm)
    print("cell_info_wcdma", cells_info_wcdma)
    for cell in cells_info_nr:
        if is_db_201 and int(cell["physicalCellId"]) in [104, 106, 114, 115]:
            for key, val in cell["status"].items():
                if expected_cell_state_nr_db201[key].lower() != val.lower():
                    raise Exception(
                        "The cell {} status is not as expected. Current cell status : {} "
                        "and Expected Cell Status : {}".format(
                            cell["physicalCellId"],
                            cell["status"],
                            expected_cell_state_nr_db201,
                        )
                    )
            continue
        for key, val in cell["status"].items():
            if expected_cell_state_nr[key].lower() != val.lower():
                raise Exception(
                    "The cell {} status is not as expected. Current cell status : {} "
                    "and Expected Cell Status : {}".format(
                        cell["physicalCellId"], cell["status"], expected_cell_state_nr
                    )
                )
    for cell in cells_info_lte:
        if is_db_201 and int(cell["physicalCellId"]) == 214:
            for key, val in cell["status"].items():
                if expected_cell_state_lte_db201[key].lower() != val.lower():
                    raise Exception(
                        "The cell {} status is not as expected. Current cell status : {} "
                        "and Expected Cell Status : {}".format(
                            cell["physicalCellId"],
                            cell["status"],
                            expected_cell_state_lte_db201,
                        )
                    )
            continue
        for key, val in cell["status"].items():
            if expected_cell_state_lte[key].lower() != val.lower():
                raise Exception(
                    "The cell {} status is not as expected. Current cell status : {} "
                    "and Expected Cell Status : {}".format(
                        cell["physicalCellId"], cell["status"], expected_cell_state_lte
                    )
                )
    for cell in cells_info_gsm:
        for key, val in cell["status"].items():
            if expected_cell_state_gsm[key].lower() != val.lower():
                raise Exception(
                    "The cell status is not as expected. Current cell status : {} "
                    "and Expected Cell Status : {}".format(
                        cell["status"], expected_cell_state_gsm
                    )
                )
    for cell in cells_info_wcdma:
        for key, val in cell["status"].items():
            if expected_cell_state_gsm[key].lower() != val.lower():
                raise Exception(
                    "The cell status is not as expected. Current cell status : {} "
                    "and Expected Cell Status : {}".format(
                        cell["status"], expected_cell_state_gsm
                    )
                )
    bts_status = admin.get_bts_statuses(timeout=30, connection="cOAM")
    if bts_status != expected_bts_status:
        raise Exception(
            "The BTS status is not as expected. Current BTS status : {} and Expected BTS status : {}".format(
                bts_status, expected_bts_status
            )
        )
    return True


def _find_physCellId_value(dictionary):
    if not isinstance(dictionary, (dict, list)):
        return None

    if isinstance(dictionary, dict):
        if "sCellToAddModList" in dictionary:
            return [
                el["sCellConfigCommon"]["physCellId"]
                for el in dictionary["sCellToAddModList"]
            ]

        for value in dictionary.values():
            result = _find_physCellId_value(value)
            if result is not None:
                return result

    elif isinstance(dictionary, list):
        for item in dictionary:
            result = _find_physCellId_value(item)
            if result is not None:
                return result
    return None


def are_scellphycellid_equal(*scells_list):
    return len(set(scells_list)) == 1


def has_common_cell(cells: dict):
    """
    Checks if every cell list has at least one common cell id
    :param cells: dict, key: UE alias, value: cell ID list
    :return: bool, True if common cell exists, else False
    """
    if not cells:
        return False  # Brak UE

    sets = [set(cells) for cells in cells.values() if cells]
    if not sets:
        return False  # lack of cell ID

    common_cells = set.intersection(*sets)
    logger.console("Common scell for all UEs is: {}".format(common_cells))
    return bool(common_cells)


def add_scellphycellid(ue_alias, dcap_logs_dir, cells: dict):
    files_list = glob.glob(dcap_logs_dir + "/*full_part_*.json")
    for file in files_list:
        with open(file, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)
        scells = find_scell_phycellid_id_value(dcap_logs)
        if scells is not None:
            BuiltIn().log("Following SCells have been configured for {}: {}".format(ue_alias, scells), console=True)
            cells[ue_alias] = scells
        else:
            BuiltIn().log("No SCells found in {}".format(dcap_logs_dir), console=True)
            assert scells


def group_output_messages(output):
    """
    Group all lines from TSharkCommandAssembler output which belong to
    single message and put in separate list
    """
    result_list = []
    current_sublist = []
    pattern = re.compile(r"Frame \d+:")

    for item in output:
        if pattern.search(item):
            if current_sublist:
                result_list.append(current_sublist)
                current_sublist = []
        current_sublist.append(item)

    # Append the last sublist if the original list doesn't end with 'Frame'
    if current_sublist:
        result_list.append(current_sublist)
    return result_list


def _generated_pcap_data(pcap_path, filter):
    tshark = TSharkCommandAssembler()
    output = tshark.with_filter(filter).with_pcap_file(pcap_file=pcap_path).build()
    return group_output_messages(output)


def _find_correct_uecontextmodificationresponse_in_output(output):
    regex_spCellConfig = re.compile(r"spCellConfigCommon")
    regex_sCellToAddModList = re.compile(r"sCellToAddModList")
    index = [
        i
        for i, sublist in enumerate(output)
        if regex_spCellConfig.search(" ".join(sublist))
        and regex_sCellToAddModList.search(" ".join(sublist))
    ]
    print("index", index)
    if not index:
        raise Exception(
            "Lack of f1ap.UEContextModificationResponse msg with sCellToAddModList, please check logs"
        )
    print("Selected message Frame number:", output[index[-1]][0])
    return output[index[-1]]


def _find_scell_physCellId(proper_msg):
    regex_sCellConfigCommon = re.compile(r"sCellConfigCommon")
    scell_physCellId_index = [
                                 i
                                 for i, sublist in enumerate(proper_msg)
                                 if regex_sCellConfigCommon.search(sublist)
                             ][0] + 1
    return re.search(r"\b\d+\b", proper_msg[scell_physCellId_index]).group()


def get_scell_phycellid_from_pcap(pcap_path, tag):
    """find SCELL selected by UE in pcap file"""
    output = _generated_pcap_data(
        pcap_path, filter="f1ap.UEContextModificationResponse_element"
    )
    proper_msg = _find_correct_uecontextmodificationresponse_in_output(output)
    scell_physCellId = _find_scell_physCellId(proper_msg)
    print(f"scell_physCellId for {tag}", scell_physCellId)
    return scell_physCellId


def are_scellphycellid_equal_pcap(*physCellIds):
    """Check if each SCELLS selected by each UE are the same"""
    physCellIds_set = {physCellId for physCellId in physCellIds}
    print(physCellIds_set)
    return len(physCellIds_set) == 1


def _find_correct_sgnbadditionrequestacknowledge_in_output(output):
    regex_spCellConfig = re.compile(r"spCellConfigCommon")
    index = [
        i
        for i, sublist in enumerate(output)
        if regex_spCellConfig.search(" ".join(sublist))
    ]
    print("index", index)
    if not index:
        raise Exception(
            "Lack of x2ap.SgNBAdditionRequestAcknowledge msg, NSA setup failed, please check logs"
        )
    print("Selected message Frame number:", output[index[-1]][0])
    return output[index[-1]]


def _find_spcell_physCellId(proper_msg):
    regex_sCellConfigCommon = re.compile(r"spCellConfigCommon")
    scell_physCellId_index = [
                                 i
                                 for i, sublist in enumerate(proper_msg)
                                 if regex_sCellConfigCommon.search(sublist)
                             ][0] + 1
    return re.search(r"\b\d+\b", proper_msg[scell_physCellId_index]).group()


def check_NSA_addition(pcap_path, tag):
    """check NSA addition in particular if physCellId in SgNBAdditionRequestAcknowledge is equal to 100"""
    output = _generated_pcap_data(
        pcap_path, filter="x2ap.SgNBAdditionRequestAcknowledge_element"
    )
    proper_msg = _find_correct_sgnbadditionrequestacknowledge_in_output(output)
    spcell_physCellId = _find_spcell_physCellId(proper_msg)
    print(f"Found scell_physCellId for {tag} equal to {spcell_physCellId}")
    assert (
            int(spcell_physCellId) == 100
    ), f"Due to scf configuration selected NSA spcell should be equal to 100"


def get_swconfig_path(active_sw_version, conn_ip="192.168.255.129"):
    class DeleteConfigException(Exception):
        pass

    try:
        conn = ssh.connect(
            hostname=conn_ip, username="toor4nsn", password="oZPS0POrRieRtu"
        )
        fs1_dir = conn.execute("cd /ffs/fs1 && ls")
        print("fs1_dir: ", fs1_dir)
        if active_sw_version in fs1_dir:
            return "/ffs/fs1/swconfig.txt"
        else:
            return "/ffs/fs2/swconfig.txt"
    except Exception as e:
        raise DeleteConfigException("Can not get swconfig path - {}".format(e))
    finally:
        conn.disconnect()


def verify_ca_sa_setup_CB008950_DB5(dcap_logs_path):
    scells = _get_sa_CA_physCellIds(dcap_logs_path)
    assert (
        len(set(scells)) == 3
    ), f"3 scells 100, 105, 108 should be found and configured. \
        Currently list contain: {scells}"
    return all(cell in scells for cell in (100, 105, 108))


def get_event_a6_reportconfigid(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "JsonContent" not in msg:
                continue
            is_eventA6 = find_value_by_key_dcap_json(msg["JsonContent"], "eventA6")
            if is_eventA6 is not None:
                reportConfigToAddModList = find_value_by_key_dcap_json(
                    msg["JsonContent"], "reportConfigToAddModList"
                )
                for reportConfigToAdd in reportConfigToAddModList:
                    is_eventA6 = find_value_by_key_dcap_json(
                        reportConfigToAdd, "eventA6"
                    )
                    if is_eventA6:
                        BuiltIn().log(
                            f'Found reportConfigId equal to {reportConfigToAdd["reportConfigId"]} \
                                      in message number: {msg["Order"]["VisibleID"]}', console=True)
                        return reportConfigToAdd["reportConfigId"]
    return False


def check_event_a6_phycellid(dcap_logs_path, report_config_id):
    all_files = os.listdir(dcap_logs_path)
    full_logs = [file for file in all_files if "full" in file]

    measurement_reports = []
    a6_event_counter = 0
    for log in full_logs:
        measurement_reports_tmp = []
        full_dcap_logs_path = f"{dcap_logs_path}/{log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "User_data" in msg and 'measurementReport' in msg["User_data"]:
                measurement_reports_tmp.append(msg)

        for msg in measurement_reports_tmp:
            measResults = find_value_by_key_dcap_json(msg["JsonContent"], "measResults")
            if measResults["measId"] == report_config_id and [
                cell["measResultServingCell"]["physCellId"]
                for cell in measResults["measResultServingMOList"]
            ] == [114, 105]:
                a6_event_counter += 1
                BuiltIn().log(
                    f'measResults_{a6_event_counter} in message number \
                              {msg["Order"]["VisibleID"]}: {measResults}', console=True)
                measurement_reports.append(msg)
    BuiltIn().log(f"Found {len(measurement_reports)} measurement reports.", console=True)
    assert (
        a6_event_counter > 0
    ), f"Lack of measurement reports with a6 event for cell 105. \
        Currently found: {a6_event_counter} valid measurement reports. Please check dcap logs."
    return a6_event_counter


def _get_sa_CA_physCellIds(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    scells = []
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "JsonContent" not in msg:
                continue
            sCellToAddModList = find_value_by_key_dcap_json(
                msg["JsonContent"], "sCellToAddModList"
            )
            if sCellToAddModList is not None:
                scells_physCellId = [
                    el["sCellConfigCommon"]["physCellId"] for el in sCellToAddModList
                ]
                BuiltIn().log(
                    f'Found sCellToAddModList with physCellId values equal to {scells_physCellId} \
                    in message number: {msg["Order"]["VisibleID"]} in {full_dcap_logs_path}', console=True)
                scells.extend(scells_physCellId)
    return scells


def verify_ca_sa_setup_CB008950_DB201(dcap_logs_path):
    scells = _get_sa_CA_physCellIds(dcap_logs_path)
    result = len(scells) >= 2 and all(item == 108 for item in scells)
    assert (result), f"2 scells equal to 108 should be found and configured. \
        Currently list contain: {scells}"
    return result


def verify_ca_sa_setup_CB008950_DB201_limited(dcap_logs_path):
    scells = _get_sa_CA_physCellIds(dcap_logs_path)
    result = len(scells) >= 2 and all(item == 108 or item == 209 for item in scells)
    assert (result), f"2 scells equal to 108 and 1 scell equal to 209 should be found and configured. \
        Currently list contain: {scells}"
    return result


def _get_nsa_spcell_id(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    specell_ids = []
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "JsonContent" not in msg:
                continue
            is_added = find_value_by_key_dcap_json(
                msg["JsonContent"], "SgNBAdditionRequestAcknowledge"
            )
            if is_added is not None:
                specell_id = find_value_by_key_dcap_json(
                    msg["JsonContent"], "physCellId"
                )
                BuiltIn().log(
                    f'Found spCellConfig with physCellId values equal to {specell_id} \
                    in message number: {msg["Order"]["VisibleID"]} in {full_dcap_logs_path}', console=True)
                if specell_id is not None:
                    specell_ids.append(specell_id)
    BuiltIn().log("SPcells found: {}".format(specell_ids), console=True)
    return specell_ids


def verify_nsa_setup_CB008950_DB201(dcap_logs_path):
    spcell_ids = _get_nsa_spcell_id(dcap_logs_path)
    result = len(spcell_ids) >= 1 and all(item == 101 for item in spcell_ids)
    assert result, f"1 specell equal to 101 should b found and configured. \
            Currently list contain: {spcell_ids}"
    return result


def verify_nsa_setup_CB008950_CB1(dcap_logs_path):
    specell_ids = _get_nsa_spcell_id(dcap_logs_path)
    assert (
        len(specell_ids) == 3
    ), f"3 specells equal to 100 should be found and configured. \
            Currently list contain: {specell_ids}"
    return all(cell in specell_ids for cell in [100])


def check_NSA_addition_json(dcap_logs_dir, ue_tag):
    """check NSA addition in particular if physCellId in SgNBAdditionRequestAcknowledge is equal to 100"""
    files_list = glob.glob(dcap_logs_dir + "/*.json")
    release_name = ta5g_enb().get_enb_active_release_name()
    phycellid = None

    for file in files_list:
        with open(file, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)
        if release_name == "SBTS24R3":
            for msg in dcap_logs["emil_data"]["rows"]:
                if "ZMQ_SCTP_name" in msg and msg["ZMQ_SCTP_name"] == "X2AP: SgNBAdditionRequestAcknowledge":
                    is_scelltoaddmodlist = find_value_by_key_dcap_json(
                        msg["JsonContent"], "spCellConfigCommon"
                    )
                    if is_scelltoaddmodlist is not None:
                        phycellid = find_value_by_key_dcap_json(
                            is_scelltoaddmodlist, "physCellId"
                        )
                    print(
                        f'Found X2AP: SgNBModificationRequired \
                            in message number: {msg["Order"]["VisibleID"]} in {dcap_logs_dir} \
                            with phycellid equal to {phycellid} for {ue_tag}'
                    )
                    return phycellid == 100
                else:
                    continue
        else:
            for msg in dcap_logs["emil_data"]["rows"]:
                if "User_data" in msg and "X2AP: SgNBAdditionRequestAcknowledge" in msg["User_data"]:
                    is_scelltoaddmodlist = find_value_by_key_dcap_json(
                        msg["JsonContent"], "spCellConfigCommon"
                    )
                    if is_scelltoaddmodlist is not None:
                        phycellid = find_value_by_key_dcap_json(
                            is_scelltoaddmodlist, "physCellId"
                        )
                    print(
                        f'Found X2AP: SgNBModificationRequired \
                        in message number: {msg["Order"]["VisibleID"]} in {dcap_logs_dir} \
                        with phycellid equal to {phycellid} for {ue_tag}'
                    )
                    return phycellid == 100
                else:
                    continue
    return phycellid == 100


def verify_nsa_ca_setup_CB008950_DB201(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    counter = 0
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "JsonContent" not in msg:
                continue
            if "User_data" in msg and "F1AP: UEContextModificationFailure" in msg["User_data"]:
                counter += 1
                BuiltIn().log(
                    f'Found F1AP: UEContextModificationFailure \
                    in message number: {msg["Order"]["VisibleID"]} in {full_dcap_logs_path}', console=True)
    return counter >= 4 and counter % 4 == 0


def verify_ca_nsa_setup_CB008950_DB201(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "filtered" in file]

    phycellids = []
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "JsonContent" not in msg:
                continue
            if msg["ZMQ_SCTP_name"] == "X2AP: SgNBModificationRequired":
                is_scelltoaddmodlist = find_value_by_key_dcap_json(
                    msg["JsonContent"], "sCellToAddModList"
                )
                if is_scelltoaddmodlist is not None:
                    phycellid = find_value_by_key_dcap_json(
                        is_scelltoaddmodlist, "physCellId"
                    )
                BuiltIn().log(
                    f'Found X2AP: SgNBModificationRequired \
                    in message number: {msg["Order"]["VisibleID"]} in {full_dcap_logs_path} \
                    with phycellid equal to {phycellid}', console=True)
                phycellids.append(phycellid)
    return all(cell in phycellids for cell in [108]) and len(phycellids) >= 1


def verify_ca_sa_setup_CB008950_DB101(dcap_logs_path):
    scells = _get_sa_CA_physCellIds(dcap_logs_path)
    assert (
            len(scells) == 2
    ), f"2 scells 311 should be found and configured. \
        Currently list contain: {scells}"
    return all(cell in scells for cell in [415])


def get_message_id_info_of_scell_addition_message_for_UE4(dcap_logs_path):
    """
    Return dict with message_id of scell addition message and filtered file number where message was found for UE4.
    UE4 scell addition is second after UE1 and also the last on tl410
    that is why it is last element taken from message_ids list
    """
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    message_ids = []
    filtered_file_counter = 1
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "User_data" not in msg:
                continue
            if "DuCaConfig, SetupSCellId: 208310276" in msg["User_data"] or \
                    r"DuBearer, BearerSetup: 5\nDuCaConfig, SetupSCellId: 208310276" in msg["User_data"]:
                message_ids.append(
                    {
                        "msg_id": msg["Order"]["VisibleID"],
                        "file_num": filtered_file_counter,
                    }
                )
                BuiltIn().log(
                    f'Found DuCaConfig, SetupCellId: 208310276 \
                    in message number: {msg["Order"]["VisibleID"]} in {full_dcap_logs_path}'
                )
        filtered_file_counter += 1
    id_of_scell_addition_message_for_UE4 = message_ids[-1]
    assert (
            len(message_ids) == 2
    ), f"2 message ids for scells 415 (NR CI: 208310276) should be found and configured. \
        Currently list contain: {message_ids}"
    return id_of_scell_addition_message_for_UE4


def get_message_id_info_of_UE1_detach(dcap_logs_path):
    """
    Return dict with message_id of NGAP: UEContextReleaseComplete message and filtered file number
    where message was found for UE1. Only UE1 is detached during this phase on tl410
    """
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    message_ids = []
    filtered_file_counter = 1
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "ZMQ_SCTP_name" not in msg:
                continue
            if msg["ZMQ_SCTP_name"] == "NGAP: UEContextReleaseComplete":
                message_ids.append(
                    {
                        "msg_id": msg["Order"]["VisibleID"],
                        "file_num": filtered_file_counter,
                    }
                )
                BuiltIn().log(
                    f'Found NGAP: UEContextReleaseComplete \
                    in message number: {msg["Order"]["VisibleID"]} in {full_dcap_logs_path}'
                )
        filtered_file_counter += 1
    assert (
            len(message_ids) == 1
    ), f"Only one UE1 should be detached. \
        Currently list contain: {message_ids}"
    return message_ids[0]


def _check_MaxIncomingLinksStatus_in_range_in_filtered_file(
        dcap_logs_path, expected_status, start_msg_id_info, end_msg_id_info
):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [
        file
        for file in all_files
        if f'full_part_{start_msg_id_info["file_num"]}' in file
    ]
    full_dcap_logs_path = f"{dcap_logs_path}/{filtered_logs[0]}"
    with open(full_dcap_logs_path, "r") as dcap_json:
        dcap_logs = json.load(dcap_json)
    link_statuses = []
    for msg in dcap_logs["emil_data"]["rows"]:
        if "ZMQ_SCTP_name" not in msg:
            continue
        if (
                msg["ZMQ_SCTP_name"] == "XnAP: IgNBCAResourceStatusUpdate"
                and msg["_____"] == "-->"
                and msg["Order"]["VisibleID"]
                in range(start_msg_id_info["msg_id"], end_msg_id_info["msg_id"])
        ):
            link_statuses.append(
                find_value_by_key_dcap_json(
                    msg["JsonContent"], "MaxIncomingLinksStatus"
                )
            )
    # hard to determine if tl send message IgNBCAResourceStatusUpdate after DL tput is actually started.
    # Just in case first value is removed
    del link_statuses[0]
    unique_statuses = tuple(set(link_statuses))
    assert expected_status in unique_statuses, f"Due to current configuration link status \
        should be equal to {expected_status} only in XnAP: IgNBCAResourceStatusUpdate \
        messages send between from Testline t410 to t186 \
        Currently list contain: {unique_statuses}.  \
        Check logs in {full_dcap_logs_path}"


def check_MaxIncomingLinksStatus_from_start_till_end_in_filtered_file(
        dcap_logs_path, expected_status, start_msg_id_info
):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [
        file
        for file in all_files
        if f'full_part_{start_msg_id_info["file_num"]}' in file
    ]
    full_dcap_logs_path = f"{dcap_logs_path}/{filtered_logs[0]}"
    with open(full_dcap_logs_path, "r") as dcap_json:
        dcap_logs = json.load(dcap_json)
    link_statuses = []
    end_msg_id = dcap_logs["emil_data"]["rows"][-1]["Order"]["VisibleID"]
    for msg in dcap_logs["emil_data"]["rows"]:
        if "ZMQ_SCTP_name" not in msg:
            continue
        if (
                msg["ZMQ_SCTP_name"] == "XnAP: IgNBCAResourceStatusUpdate"
                and msg["_____"] == "-->"
                and msg["Order"]["VisibleID"]
                in range(start_msg_id_info["msg_id"], end_msg_id)
        ):
            link_statuses.append(
                find_value_by_key_dcap_json(
                    msg["JsonContent"], "MaxIncomingLinksStatus"
                )
            )
    # Hard to determine if proper IgNBCAResourceStatusUpdate was sent after start point or it was related with
    # previous amount of active CA relations.Just in case first value is removed.
    del link_statuses[0]
    print(link_statuses)
    unique_statuses = tuple(set(link_statuses))
    assert expected_status in unique_statuses, f"Due to current configuration link status \
        should be equal to {expected_status} only in XnAP: IgNBCAResourceStatusUpdate \
        messages send between from Testline t410 to t186 \
        Currently list contain: {unique_statuses}.  \
        Check logs in {full_dcap_logs_path}"


def check_MaxIncomingLinksStatus_ue1_ue4_ca_setup(
        dcap_logs_path, expected_status, start_msg_id_info, end_msg_id_info
):
    if start_msg_id_info["file_num"] == end_msg_id_info["file_num"]:
        _check_MaxIncomingLinksStatus_in_range_in_filtered_file(
            dcap_logs_path, expected_status, start_msg_id_info, end_msg_id_info
        )
    else:
        check_MaxIncomingLinksStatus_from_start_till_end_in_filtered_file(
            dcap_logs_path, expected_status, start_msg_id_info
        )
    return True


def check_MaxIncomingLinksStatus(dcap_logs_path, expected_status):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    link_statuses = []
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"
        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "ZMQ_SCTP_name" not in msg:
                continue
            if (
                    msg["ZMQ_SCTP_name"] == "XnAP: IgNBCAResourceStatusUpdate"
                    and msg["_____"] == "-->"
            ):
                link_statuses.append(
                    find_value_by_key_dcap_json(
                        msg["JsonContent"], "MaxIncomingLinksStatus"
                    )
                )

    unique_statuses = tuple(set(link_statuses))
    assert expected_status in unique_statuses, f"Due to current configuration link status \
        should be equal to {expected_status} only in XnAP: IgNBCAResourceStatusUpdate \
        messages send between from Testline t410 to t186 \
        Currently list contain: {unique_statuses}.  \
        Check logs in {full_dcap_logs_path}"


def get_event_a1_reportconfigid(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "JsonContent" not in msg:
                continue
            is_eventA1 = find_value_by_key_dcap_json(msg["JsonContent"], "eventA1")
            if is_eventA1 is not None:
                reportConfigToAddModList = find_value_by_key_dcap_json(
                    msg["JsonContent"], "reportConfigToAddModList"
                )
                for reportConfigToAdd in reportConfigToAddModList:
                    is_eventA1 = find_value_by_key_dcap_json(
                        reportConfigToAdd, "eventA1"
                    )
                    if is_eventA1:
                        BuiltIn().log(
                            f'Found reportConfigId equal to {reportConfigToAdd["reportConfigId"]} \
                            in message number: {msg["Order"]["VisibleID"]}'
                        )
                        return reportConfigToAdd["reportConfigId"]
    return False


def check_event_a1_phycellid(dcap_logs_path, report_config_id):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    measurement_reports = []
    a1_event_counter = 0
    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)

        for msg in dcap_logs["emil_data"]["rows"]:
            if "User_data" not in msg:
                continue
            if "measurementReport" in msg["User_data"]:
                measurement_reports.append(msg)
        BuiltIn().log(f"Found {len(measurement_reports)} measurement reports.")
        for msg in measurement_reports:
            measResults = find_value_by_key_dcap_json(msg["JsonContent"], "measResults")
            if (
                    measResults["measId"] == report_config_id
                    and measResults["measResultServingMOList"][0]["measResultServingCell"][
                    "physCellId"
                    ]
                    == 561
            ):
                a1_event_counter += 1
                BuiltIn().log(
                    f'measResults_{a1_event_counter} in message number {msg["Order"]["VisibleID"]}: {measResults}'
                )
    assert (
            a1_event_counter > 0
    ), f"Lack of measurement reports with a1 event for cell 561. \
        Currently found: {a1_event_counter} valid measurement reports. Please check dcap logs."
    return str(a1_event_counter)


def verify_interca_sa_setup_UE3_CB008950_DB101(dcap_logs_path):
    all_files = os.listdir(dcap_logs_path)
    filtered_logs = [file for file in all_files if "full" in file]

    for filtered_log in filtered_logs:
        full_dcap_logs_path = f"{dcap_logs_path}/{filtered_log}"

        with open(full_dcap_logs_path, "r") as dcap_json:
            dcap_logs = json.load(dcap_json)
        for msg in dcap_logs["emil_data"]["rows"]:
            if "User_data" not in msg or "JsonContent" not in msg:
                continue
            isca = find_value_by_key_dcap_json(msg["JsonContent"], "sCellToAddModList")
            if not isca:
                continue
            if (
                    "F1AP: IgNBCAUeContextModificationResponse" in msg["User_data"]
                    and isca[0]["sCellConfigCommon"]["physCellId"] == 415
            ):
                BuiltIn().log(
                    f'Found F1AP: UEContextModificationResponse with pcell 561 and scell 415 \
                    in message number: {msg["Order"]["VisibleID"]}'
                )
                return True
    return False
