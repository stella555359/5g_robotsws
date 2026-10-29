from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_rel_name
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB009103.resources.interdlca_pm_counters import (
    INTERDLCA_PM_COUNTERS,
    INTERDLCA_INACTIVE_PM_COUNTERS,
    INTERDLCA_PCELL_SWITCH_PM_COUNTERS,
    remote_vm_ip,
    country_codes,
)


def prepare_startup_values():
    cell_list_local = get_cells_identifiers(identifier="globalCellId")
    cell_list_remote = get_cells_identifiers(identifier="globalCellId", remote_host=remote_vm_ip)
    cell_list = cell_list_local + cell_list_remote
    rel_name = get_rel_name()
    if rel_name == "SBTS26R1" or rel_name == "SBTS26R2":
        del INTERDLCA_PM_COUNTERS["UE_SCELL_ACROSS_MULT_GNB_SA"]
    else:
        del INTERDLCA_PM_COUNTERS["UE_SCELL_ACROSS_2_GNB_SA"]
    for ne_abbr in INTERDLCA_PM_COUNTERS:
        if isinstance(INTERDLCA_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                INTERDLCA_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${INTERDLCA_PM_COUNTERS}", INTERDLCA_PM_COUNTERS)
    BuiltIn().set_test_variable("${rel_name}", rel_name)
    return cell_list


def prepare_startup_values_for_inactive():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in INTERDLCA_INACTIVE_PM_COUNTERS:
        if isinstance(INTERDLCA_INACTIVE_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                INTERDLCA_INACTIVE_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${INTERDLCA_INACTIVE_PM_COUNTERS}", INTERDLCA_INACTIVE_PM_COUNTERS)
    return cell_list


def prepare_startup_values_for_pcell_switch():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in INTERDLCA_PCELL_SWITCH_PM_COUNTERS:
        if INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["key"] == "NRCELL":
            for cell in cell_list:
                INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
        if INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["key"] == "MCC":
            for mcc in country_codes:
                INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["value"].update(
                    {"MCC-{}".format(mcc): 0}
                )
    BuiltIn().set_test_variable("${INTERDLCA_PCELL_SWITCH_PM_COUNTERS}", INTERDLCA_PCELL_SWITCH_PM_COUNTERS)
    return cell_list


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(INTERDLCA_PM_COUNTERS[ne_abbr]["value"], dict):
            INTERDLCA_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            INTERDLCA_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${INTERDLCA_PM_COUNTERS}", INTERDLCA_PM_COUNTERS)


def increase_inactive_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(INTERDLCA_INACTIVE_PM_COUNTERS[ne_abbr]["value"], dict):
            INTERDLCA_INACTIVE_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            INTERDLCA_INACTIVE_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${INTERDLCA_INACTIVE_PM_COUNTERS}", INTERDLCA_INACTIVE_PM_COUNTERS)


def increase_pcellswitch_counters(*args, cell_or_mcc=None, multiplier=1):
    for ne_abbr in args:
        if INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["key"] == "NRCELL":
            INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell_or_mcc)] += 1 * int(
                multiplier
            )
        else:
            INTERDLCA_PCELL_SWITCH_PM_COUNTERS[ne_abbr]["value"]["MCC-{}".format(cell_or_mcc)] += 1 * int(
                multiplier
            )
    BuiltIn().set_test_variable("${INTERDLCA_PCELL_SWITCH_PM_COUNTERS}", INTERDLCA_PCELL_SWITCH_PM_COUNTERS)


def merge_two_dictionaries(pm_local, pm_remote):
    pm_merged = {}
    for key in set(pm_local) | set(pm_remote):
        merged = {}
        if key in pm_local:
            merged.update(pm_local[key])
        if key in pm_remote:
            for cell, value in pm_remote[key].items():
                if cell in merged:
                    merged[cell] += value
                else:
                    merged[cell] = value
        pm_merged[key] = merged
    return pm_merged
