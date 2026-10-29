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
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB006449.resources.ulca_pm_counters import (
    ULCA_PM_COUNTERS,
    ULCA_HO_PM_COUNTERS,
)


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in ULCA_PM_COUNTERS:
        if isinstance(ULCA_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                ULCA_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${ULCA_PM_COUNTERS}", ULCA_PM_COUNTERS)


def prepare_startup_values_for_ho_pm():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in ULCA_HO_PM_COUNTERS:
        if ULCA_HO_PM_COUNTERS[ne_abbr]["key"] == "NRCELL":
            for cell in cell_list:
                ULCA_HO_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
        if ULCA_HO_PM_COUNTERS[ne_abbr]["key"] == "SST":
            for sst in range(1, 5):
                ULCA_HO_PM_COUNTERS[ne_abbr]["value"].update(
                    {"SST-{}".format(sst): 0}
                )
    BuiltIn().set_test_variable("${ULCA_HO_PM_COUNTERS}", ULCA_HO_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(ULCA_PM_COUNTERS[ne_abbr]["value"], dict):
            ULCA_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            ULCA_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${ULCA_PM_COUNTERS}", ULCA_PM_COUNTERS)


def increase_ho_counters(*args, key=None, multiplier=1):
    for ne_abbr in args:
        if ULCA_HO_PM_COUNTERS[ne_abbr]["key"] == "NRCELL":
            ULCA_HO_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(key)] += 1 * int(multiplier)
        if ULCA_HO_PM_COUNTERS[ne_abbr]["key"] == "SST":
            ULCA_HO_PM_COUNTERS[ne_abbr]["value"]["SST-{}".format(key)] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${ULCA_HO_PM_COUNTERS}", ULCA_HO_PM_COUNTERS)
