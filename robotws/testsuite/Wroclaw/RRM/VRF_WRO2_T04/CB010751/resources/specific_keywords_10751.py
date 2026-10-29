from robot.libraries.BuiltIn import BuiltIn
import re
import json
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.kpi import (
    download_scf,
    get_parameter_value_from_scf,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB010751.resources.variables import (
    timers,
    inactive_redcap_timers,
    PM_COUNTERS,
)

real_ue = False
SHARK_OPTIONS = [("-o", "pdcp-nr.default_integrity_algorithm:NIA2")]
assert_msg = '\n'.join(["{message}", "Expected: {expected}", "But was: {current}"])


def are_cells_configured():
    with AdminApi() as web_api:
        cells_info = web_api.get_cells_info(cell_type='nr')
        for cell in cells_info:
            assert cell['status'].get('proceduralStatus') in \
                ['configured', 'not initialized'], assert_msg.format(
                message='Not all cells are configured', expected='proceduralStatus: configured (or not initialized)',
                current=cell['status'].get('proceduralStatus'))


def create_delta(distname, parameter_name, parameter_value, operation):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": operation,
            }
        ],
    }
    return parameter_delta


def configure_inactivity_timers(set_redcap_timers):
    delta_list = []
    distname = "{}".format(bts_prefix) if real_ue is True else "MRBTS-1/NRBTS-1"
    for p in timers:
        operation = (
            "delete"
            if p in inactive_redcap_timers and set_redcap_timers is False
            else "update"
        )
        delta_list.append(create_delta(distname, p, timers[p], operation))
        delta = json.dumps(delta_list)
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(delta_file=delta)


def verify_inactive_state_for_all_ues(expected_occurrence, pcap_file):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.UEContextReleaseCommand_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=SHARK_OPTIONS,
        )
        msg_occurrence = 0
    while (
        filtered.find_next(
            pm("rrcRelease", name_line_pattern="empty").containing("suspendConfig")
        )
        is not None
    ):
        msg_occurrence += 1
    assert (
        int(expected_occurrence) == msg_occurrence
    ), "Verification failed, \n  expected val: {} \n  current val: {}".format(
        expected_occurrence, msg_occurrence
    )
    logger.info(" \nAll UEs are in INACTIVE state\n", also_console=True)


def increase_counters_based_on_msgs_in_pcap_file(serving_cell, pcap_file):
    prepare_startup_values()
    for ne_abbr in PM_COUNTERS:
        if PM_COUNTERS[ne_abbr]["shark_filter"] is not None:
            count_message(pcap_file, ne_abbr, serving_cell)
    recalculate_counters_that_depend_on_each_other(serving_cell)
    return PM_COUNTERS


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in PM_COUNTERS:
        if isinstance(PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                PM_COUNTERS[ne_abbr]["value"].update({cell: 0})


def count_message(pcap_file, ne_abbr, serving_cell):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=PM_COUNTERS[ne_abbr]["shark_filter"],
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    msg_counter = 0
    if "multiplier" in PM_COUNTERS[ne_abbr]:
        multiplier = PM_COUNTERS[ne_abbr]["multiplier"]
    else:
        multiplier = 1
    if "cause" in PM_COUNTERS[ne_abbr]:
        while (
            filtered.find_next(
                pm(
                    PM_COUNTERS[ne_abbr]["shark_msg"], name_line_pattern="empty"
                ).containing(
                    PM_COUNTERS[ne_abbr]["cause"][0], PM_COUNTERS[ne_abbr]["cause"][1]
                )
            )
            is not None
        ):
            msg_counter += 1 * multiplier
    else:
        while (
            filtered.find_next(
                pm(PM_COUNTERS[ne_abbr]["shark_msg"], name_line_pattern="empty")
            )
            is not None
        ):
            msg_counter += 1 * multiplier
    if isinstance(PM_COUNTERS[ne_abbr]["value"], dict):
        if PM_COUNTERS[ne_abbr]["redcap_ue_recalculation"] is True:
            PM_COUNTERS[ne_abbr]["value"][serving_cell] += (
                msg_counter
                * len(get_robot_variable("@{redcap_ue_ids}"))
                / len(get_robot_variable("@{all_ue_ids}"))
            )
        else:
            PM_COUNTERS[ne_abbr]["value"][serving_cell] += msg_counter
    else:
        if PM_COUNTERS[ne_abbr]["redcap_ue_recalculation"] is True:
            PM_COUNTERS[ne_abbr]["value"] += (
                msg_counter
                * len(get_robot_variable("@{redcap_ue_ids}"))
                / len(get_robot_variable("@{all_ue_ids}"))
            )
        else:
            PM_COUNTERS[ne_abbr]["value"] += msg_counter


def recalculate_counters_that_depend_on_each_other(serving_cell):
    PM_COUNTERS["REDCAP_RRC_REL_WITH_SUSP_NRNAU"]["value"][serving_cell] -= PM_COUNTERS[
        "REDCAP_RRC_REL_WITH_SUSP_RNAU"
    ]["value"][serving_cell]
    PM_COUNTERS["NRRCC_RRC_REL_WITH_SUSP_NRNAU"]["value"][serving_cell] -= PM_COUNTERS[
        "NRRCC_RRC_REL_WITH_SUSP_RNAU"
    ]["value"][serving_cell]
    PM_COUNTERS["PEAK_SA_REDCAP_RRC_INA"]["value"][serving_cell] = len(
        get_robot_variable("@{redcap_ue_ids}")
    ) * get_robot_variable("${pm_intervals_number}")
    PM_COUNTERS["REDCAP_UE_RRC_STP_SUCC"]["value"][serving_cell] -= PM_COUNTERS[
        "REDCAP_RRC_RESUME_FALBK_SUCC"
    ]["value"][serving_cell]
    PM_COUNTERS["AVG_SA_REDCAP_RRC_INA_NOM"]["value"][serving_cell] = (
        get_robot_variable("${inact_time_for_redcap_ues}")
    )
