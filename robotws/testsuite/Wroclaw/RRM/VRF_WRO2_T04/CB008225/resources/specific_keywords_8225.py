from robot.libraries.BuiltIn import BuiltIn
import re
import os
import subprocess
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.kpi import (
    download_scf,
    get_parameter_value_from_scf,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB008225.resources.variables import PM_COUNTERS

SHARK_OPTIONS = [("-o", "pdcp-nr.default_integrity_algorithm:NIA2")]


def is_ue_in_state(expected_state, pcap_file):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.UEContextReleaseCommand_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=SHARK_OPTIONS,
        )
    if expected_state == "inactive":
        last_msg = filtered.find_all(pm("rrcRelease", name_line_pattern="empty"))[-1]
        assert last_msg.find("*suspendConfig*")
    if expected_state == "idle":
        last_msg = filtered.find_all(pm("rrcRelease", name_line_pattern="empty"))[-1]
        assert not last_msg.find("*suspendConfig*")


def set_rrc_inactive_feature(action):
    distname = "{}".format(bts_prefix)
    if action == "activate":
        value = "intra-gNB"
    else:
        value = "none"
    with AdminApi() as web_api:
        web_api.perform_parameter_recommissioning(
            dist_name=distname,
            parameter="actRrcInactState",
            operation="update",
            value=value,
        )


def get_timers_value_from_scf(*args):
    distname = "{}".format(bts_prefix)
    scf_file = download_scf()
    dict = {}
    logger.info("\nTimers settings in scf/webui:", also_console=True)
    for p in args:
        p_value = get_parameter_value_from_scf(
            path=scf_file, parameter_abbreviation=p, parameter_dist_name=distname
        )
        dict.update({p: p_value})
        if p == "maxUeRrcInactTime":
            time_format = "minutes"
        else:
            time_format = "seconds"
        logger.info("  {}: {} {}".format(p, p_value, time_format), also_console=True)
    return dict


def calculate_rrc_inactivity_timer(timers_settings):
    if int(timers_settings["drbRrcInactInactivityTimerSA"]) >= int(
        timers_settings["srbInactivityTimerSA"]
    ):
        inactivity_timer = timers_settings["drbRrcInactInactivityTimerSA"]
    else:
        inactivity_timer = timers_settings["srbInactivityTimerSA"]
    return inactivity_timer


def calculate_rrc_idle_timer(timers_settings):
    if int(timers_settings["drbInactivityTimerSA"]) >= int(
        timers_settings["srbInactivityTimerSA"]
    ):
        idle_timer = timers_settings["drbInactivityTimerSA"]
    else:
        idle_timer = timers_settings["srbInactivityTimerSA"]
    return idle_timer


def compare_tputs(idle_tput, inactive_tput, deviation):
    difference = abs(float(idle_tput) - float(inactive_tput)) / float(idle_tput)
    diff_percent = format(difference, ".1%")
    deviation = float(deviation.strip("%")) / 100
    assert (
        difference <= deviation
    ), "The difference is greater than the assumed: {}".format(diff_percent)
    logger.info(
        "Comparison successful, measured difference: {}".format(diff_percent),
        also_console=True,
    )


def check_rrc_resume_msg_in_pcap_file(pcap_file, direction, msg_occurence):
    cause = "mt-Access*" if direction == "DL" else "mo-Data*"
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.InitialULRRCMessageTransfer_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=SHARK_OPTIONS,
        )
    rrc_resume = filtered.find_exactly(
        int(msg_occurence),
        pm("rrcResumeRequest1", name_line_pattern="empty").containing(
            "resumeCause", cause
        ),
    )
    assert rrc_resume, "UE not moved to CONNECTED state with rrcResumeRequest1 msg"
    logger.info(
        "UE resumed from INACTIVE to CONNECTED state properly", also_console=True
    )


def increase_counters_based_on_msgs_in_pcap_file(serving_cell, pcap_file):
    prepare_startup_values()
    for ne_abbr in PM_COUNTERS:
        if PM_COUNTERS[ne_abbr]["shark_filter"] is not None:
            count_message(pcap_file, ne_abbr, serving_cell)
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
        PM_COUNTERS[ne_abbr]["value"][serving_cell] += msg_counter
    else:
        PM_COUNTERS[ne_abbr]["value"] += msg_counter


def verify_feature_is_activated(pci):
    nci_expected = calculate_nr_cell_identity(pci)
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path="/home/ute/MN/UTE/robotws/8225_AB2_LTE_block.pcap",
            lua=None,
            shark_filter="f1ap.sIB1_message",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    ranac = filtered.find_all(
        pm("SIB1", name_line_pattern="empty").containing("ranac", "0")
    )
    assert ranac, "RRC Inactive Sate feature is not configured"
    tac = filtered.find_all(
        pm("SIB1", name_line_pattern="empty").containing("trackingAreaCode", "*7151")
    )
    assert tac, "RRC Inactive Sate feature is not configured, tac"
    resume_id = filtered.find_all(
        pm("SIB1", name_line_pattern="empty").containing("useFullResumeID", "true*")
    )
    assert resume_id, "RRC Inactive Sate feature is not configured"


def filter_pcap(input_pcap, output_pcap="/home/ute/test_results/filtered_trace.pcap", filter_expression="f1ap"):
    try:
        output_dir = os.path.dirname(output_pcap)
        os.makedirs(output_dir, exist_ok=True)
        command = [
            'tshark',
            '-r', input_pcap,
            '-Y', filter_expression,
            '-w', output_pcap
        ]
        subprocess.run(command, check=True)
        print(f"Filtered file written in: {output_pcap}")
    except subprocess.CalledProcessError as e:
        print(f"Error during tshark prrocessing: {e}")
    return output_pcap
