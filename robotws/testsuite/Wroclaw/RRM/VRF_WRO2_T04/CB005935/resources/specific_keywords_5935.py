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
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB006449.resources.ulca_pm_counters import ULCA_PM_COUNTERS
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB005935.resources.oh_pm_counters import OH_PM_COUNTERS


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    del ULCA_PM_COUNTERS["SCELL_UL_SUSPEND_PCEL_POWLM_SA"]
    for ne_abbr in ULCA_PM_COUNTERS:
        if isinstance(ULCA_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                ULCA_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${ULCA_PM_COUNTERS}", ULCA_PM_COUNTERS)


def prepare_startup_values_for_oh_pm():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in OH_PM_COUNTERS:
        if isinstance(OH_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                OH_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${OH_PM_COUNTERS}", OH_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(OH_PM_COUNTERS[ne_abbr]["value"], dict):
            OH_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            OH_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${OH_PM_COUNTERS}", OH_PM_COUNTERS)


def verify_ue_assistance_information(
    pcap_file,
    oh_op="enter",
    expected_CCsDL=None,
    expected_CCsUL=None,
):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.UEContextModificationRequest_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    if oh_op == "leave":
        msg = filtered.find_one(pm("overheatingAssistance", name_line_pattern="empty"))
    else:
        msg = filtered.find_one(
            pm("overheatingAssistance", name_line_pattern="empty")
            .containing("reducedCCsDL-r16", expected_CCsDL)
            .containing("reducedCCsUL-r16", expected_CCsUL)
        )
    logger.info("\n UE Assistance Information message verified correctly", also_console=True)
