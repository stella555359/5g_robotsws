from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from robot.api import logger
from idle_mode_pm_counters import IDLE_PM_COUNTERS


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in IDLE_PM_COUNTERS:
        if isinstance(IDLE_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                IDLE_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${IDLE_PM_COUNTERS}", IDLE_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(IDLE_PM_COUNTERS[ne_abbr]["value"], dict):
            IDLE_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            IDLE_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${IDLE_PM_COUNTERS}", IDLE_PM_COUNTERS)


def block_lte_cell(cell_id):
    logger.info("\n Blocking cell id:{} in progress".format(cell_id), also_console=True)
    with AdminSession() as admin:
        admin.block_cell(
            dist_name="MRBTS-{}/LNBTS-{}/LNCEL-{}".format(mrbts_id, nrbts_id, cell_id),
        )


def unblock_lte_cell(cell_id):
    logger.info("\n Unblocking cell id:{} in progress".format(cell_id), also_console=True)
    with AdminSession() as admin:
        admin.unblock_cell(
            dist_name="MRBTS-{}/LNBTS-{}/LNCEL-{}".format(mrbts_id, nrbts_id, cell_id),
        )
