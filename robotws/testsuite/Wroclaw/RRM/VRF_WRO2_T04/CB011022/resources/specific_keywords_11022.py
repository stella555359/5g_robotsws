import json
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.kpi import (
    download_scf,
    get_parameter_value_from_scf,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.counters import (
    sync_to_next_reporting_interval,
    get_sum_of_n_last_pm_counters_values,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB011022.resources.mcs_dmrs_pm_counters import MCS_DMRS_PM_COUNTERS

rrc_reconfig_call_flow = {
    "UEContextModificationRequired": ["radioNetwork", "action-desirable-for-radio-reasons*"],
    "ULRRCMessageTransfer": [],
    "UEContextModificationConfirm": [],
    "UEContextModificationRequest": [],
    "UEContextModificationResponse": [],
}


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in MCS_DMRS_PM_COUNTERS:
        if isinstance(MCS_DMRS_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                MCS_DMRS_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${MCS_DMRS_PM_COUNTERS}", MCS_DMRS_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(MCS_DMRS_PM_COUNTERS[ne_abbr]["value"], dict):
            MCS_DMRS_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            MCS_DMRS_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${MCS_DMRS_PM_COUNTERS}", MCS_DMRS_PM_COUNTERS)


def verify_rrc_reconfiguration_call_flow(pcap_file, filter='f1ap'):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    logger.info("\n Call flow during mcs or/and dmrs switching", also_console=True)
    for msg, details in rrc_reconfig_call_flow.items():
        if details:
            occurrence = filtered.find_next(pm(msg, name_line_pattern='empty').containing(details[0], details[1]))
        else:
            occurrence = filtered.find_next(pm(msg, name_line_pattern='empty'))
        assert occurrence is not None, "  No message '{}' in pcap  file".format(msg)
        logger.info("   {}: OK".format(msg), also_console=True)


def verify_no_changes_in_mcs_table_and_type_of_dmrs(pcap_file, msg_occurrence=0):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.UEContextModificationRequired_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    filtered.find_exactly(
        int(msg_occurrence),
        pm("DUtoCURRCInformation", name_line_pattern="empty").containing("BWP-Downlink")
    )
    logger.info("\n There is no changes in MCS Table and Type of DMRS", also_console=True)


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "operation": "update",
                "value": parameter_value
            }
        ]
    }
    return parameter_delta


def change_a2_threshold(cell, value):
    delta_list = []
    list_elements = {
        "a2HysteresishoSsbRsrpSA": 0,
        "a2HysteresisHoSsbRsrpVoNr": 0,
        "a2ThresholdhoSsbRsrpSA": int(value),
        "a2ThresholdHoSsbRsrpVoNr": int(value),
        "a2TimeToTriggerhoSsbRsrpSA": "ms480",
        "a2TimeToTriggerHoSsbRsrpVoNr": "ms480",
    }
    distname = "{}/NRCELL-{}".format(bts_prefix, cell)
    delta_list.append(create_delta(distname, "a2MeashoSsbRsrpSA", [list_elements]))
    delta = json.dumps(delta_list)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta)


def change_a1_scell_add_threshold(cell, value_fdd=67, value_tdd=67):
    delta_list = []
    list_elements = {
        "a1HysteresisSCellAddSsbRsrp": 0,
        "a1ThresholdSCellAddSsbRsrpFDD": int(value_fdd),
        "a1ThresholdSCellAddSsbRsrpTDD": int(value_tdd),
        "a1TimeToTriggerSCellAddSsbRsrp": "320ms",
    }
    distname = "{}/NRCELL-{}".format(bts_prefix, cell)
    delta_list.append(create_delta(distname, "a1MeasSCellAddSsbRsrp", [list_elements]))
    delta = json.dumps(delta_list)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta)


def check_tput_on_pcell(pcell):
    counters_list = ["M55310C20001"]
    sync_to_next_reporting_interval(offset=45)
    values = get_sum_of_n_last_pm_counters_values(counters=counters_list)
    pcell_dl_tput = (values["M55310C20001"]["NRCELL-{}".format(pcell)] * 8 / 1000000) / 300
    return round(pcell_dl_tput, 1)


def verify_rrc_release(pcap_file, msg_occurrence=1):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.UEContextReleaseCommand_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    filtered.find_exactly(
        int(msg_occurrence),
        pm("UEContextReleaseCommand", name_line_pattern="empty").containing("radioNetwork", "normal-release*")
    )
    logger.info("\n UE moved to IDLE mode", also_console=True)
