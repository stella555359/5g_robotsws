

import logging
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_wrapper

from robot.libraries.BuiltIn import BuiltIn

logger = logging.getLogger(__name__)
rbi = BuiltIn()


def verify_number_of_active_ues_in_cells(ue_per_cell: int,
                                         num_cells: int,
                                         cell_max_ue: list = None,
                                         active_cells: list = None,
                                         cells: list = None) -> bool:
    is_pass = True
    num_cells = int(num_cells)
    if cells is None:
        cells = wts_wrapper.get_ue_count_per_cell(num_cells=num_cells)
    if cell_max_ue in [None, "None", ["null"]]:
        cell_max_ue = [ue_per_cell] * num_cells
    for cell_index in range(1, num_cells + 1):
        if not wts_manager.is_cell_included(cell_index, active_cells):
            continue
        logger.debug("cell_max_ue: %s", cell_max_ue)
        logger.debug("ue_count_per_cell: %s", cells)
        expect_ue = int(cell_max_ue[cell_index - 1])
        cell_ue = int(cells[cell_index - 1])
        if expect_ue > cell_ue:
            is_pass = False
            logger.warning("  Cell-%s : Expected %s Ues Attached, (%s)",
                           f"{cell_index:0>2}", expect_ue, cell_ue)
    if not is_pass:
        rbi.fail("Insufficient UE!")
    return is_pass
