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
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB011041.resources.pagstra_pm_counters import (
    PAGSTRA_PM_COUNTERS,
    paging_attempt_counters,
)

SHARK_OPTIONS = [("-o", "pdcp-nr.default_integrity_algorithm:NIA2")]


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in PAGSTRA_PM_COUNTERS:
        if isinstance(PAGSTRA_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                PAGSTRA_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${PAGSTRA_PM_COUNTERS}", PAGSTRA_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(PAGSTRA_PM_COUNTERS[ne_abbr]["value"], dict):
            PAGSTRA_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            PAGSTRA_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${PAGSTRA_PM_COUNTERS}", PAGSTRA_PM_COUNTERS)


def increase_paging_counters_with_repetitions(paging_occurrences):
    i = int(paging_occurrences)
    for ne_abbr in paging_attempt_counters:
        if i > 0:
            PAGSTRA_PM_COUNTERS[ne_abbr]["value"] += 1
            i -= 1
    BuiltIn().set_test_variable("${PAGSTRA_PM_COUNTERS}", PAGSTRA_PM_COUNTERS)


def is_ue_in_inactive_state(pcap_file, msg_occurrence=1):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="e1ap.BearerContextModificationRequest_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=SHARK_OPTIONS,
        )
    filtered.find_exactly(
        int(msg_occurrence),
        pm("BearerContextModificationRequest", name_line_pattern="empty").containing(
            "BearerContextStatusChange", "suspend*"
        ),
    )
    logger.info("\n UE moved to INACTIVE state", also_console=True)


def check_paging_msg(pcap_file, paging_priority, ue_identity):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.Paging_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=SHARK_OPTIONS,
        )
    msg_counter = 0
    if ue_identity == "iRNTI":
        while (
            filtered.find_next(
                pm("Paging", name_line_pattern="empty")
                .containing("{}".format(ue_identity), "*")
                .containing("PagingDRX", "*")
                .containing("PagingPriority", "priolevel{}*".format(paging_priority))
            )
            is not None
        ):
            msg_counter += 1
    else:
        while (
            filtered.find_next(
                pm("Paging", name_line_pattern="empty").containing(
                    "{}".format(ue_identity), "*"
                )
            )
            is not None
        ):
            msg_counter += 1
    return msg_counter


def check_rna_update_msg(pcap_file, message, msg_occurrence=1):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.InitialULRRCMessageTransfer_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
            shark_options=SHARK_OPTIONS,
        )
    filtered.find_exactly(
        int(msg_occurrence),
        pm(message, name_line_pattern="empty").containing("resumeCause", "rna-Update*"),
    )


def change_ranac_for_serving_cell(action, cell, value=0):
    logger.info(
        "\n {}ing ranAC for cell id:{} in progress".format((action[:-1]).title(), cell),
        also_console=True,
    )
    with AdminSession() as admin:
        admin.perform_parameter_recommissioning(
            dist_name="{}/NRCELL-{}/NRPLMNSET_SA-1".format(bts_prefix, cell),
            parameter="ranAC",
            operation=action,
            value=value,
        )


def recalculate_time_delay_counter(counter_values):
    if counter_values["M55197C00003"] > 0:
        PAGSTRA_PM_COUNTERS["DELAY_PAG_RRC_INCT_CON_PAGSTRA"]["value"] = counter_values[
            "M55197C00003"
        ]
    BuiltIn().set_test_variable("${PAGSTRA_PM_COUNTERS}", PAGSTRA_PM_COUNTERS)


def block_nr_cell(cell_id):
    logger.info("\n Blocking cell id:{} in progress".format(cell_id), also_console=True)
    with AdminSession() as admin:
        admin.block_cell(
            dist_name="{}/NRCELL-{}".format(bts_prefix, cell_id),
        )


def unblock_nr_cell(cell_id):
    logger.info(
        "\n Unblocking cell id:{} in progress".format(cell_id), also_console=True
    )
    with AdminSession() as admin:
        admin.unblock_cell(
            dist_name="{}/NRCELL-{}".format(bts_prefix, cell_id),
        )
