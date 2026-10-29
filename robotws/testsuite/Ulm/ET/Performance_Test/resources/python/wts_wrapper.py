
import re
import logging
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_manager
from testsuite.Ulm.ET.Performance_Test.resources.python import wts_multivm_helper


logger = logging.getLogger(__name__)


def get_ue_count_per_cell_table(num_cells: int = 24,
                                active_cells: list = None,
                                expected: int | list = None,
                                cells: list = None,
                                **_) -> str:
    num_cells = int(num_cells)
    if cells is None:
        cells = get_ue_count_per_cell(num_cells=num_cells)
    output = ""
    logger.debug("===== start get_ue_count_per_cell_table")
    logger.debug("num_cells: %s, active_cells: %s, expected: %s",
                 num_cells, active_cells, expected)
    for cell in range(1, num_cells + 1):
        if active_cells not in [None, ["all"]] and cell not in [int(x) for x in active_cells]:
            continue
        logger.debug("Processing Cell %s", cell)
        percent = "( - %)"
        if expected not in [None, "None", "null"]:
            if not isinstance(expected, list) and expected is not None:
                expected = [int(expected)] * num_cells
            try:
                if int(expected[cell - 1]) > 0:
                    rounded = round(((int(cells[cell - 1])/int(expected[cell - 1])) * 100), 2)
                    percent = f"( {rounded} %)"
            except (IndexError, ZeroDivisionError) as e:
                percent = f"( {e} %)"
        try:
            output = f"{output}Cell {cell:0>2}: {cells[cell - 1]} / {int(expected[cell - 1])} {percent}\n"
        except (IndexError, TypeError) as e:
            output = f"{output}Cell {cell:0>2}: {e}\n"
    total = sum([int(i) for i in cells])
    output = f"{output}  Total: {total}\n"
    logger.debug("===== end get_ue_count_per_cell_table")
    return output


def get_ue_count_per_cell(num_cells: int = 24,
                          ue_summary_output: str = None) -> list:
    if ue_summary_output is None:
        ue_summary_output = _ue_summary_output()
    cells = []
    for _ in range(1, int(num_cells) + 1):
        cells.append(0)
    try:
        filtered = re.findall(r'Active.*-----.*Active.*-----',
                              ue_summary_output, re.MULTILINE | re.DOTALL)[0]
        filtered = re.findall(r'Active.*-----.*Active',
                              filtered, re.MULTILINE | re.DOTALL)[0]
        results = re.findall(r'Cell-([0-9]+) *([0-9]+) ', filtered)
    except IndexError as e:
        logger.debug("[error] get_ue_count_per_cell: %s", e)
        return cells
    for cell, ue in results:
        logger.debug("cell: %s, ue_count: %s", cell, ue)
        cells[int(cell) - 1] = int(ue)
    logger.debug("ue_count_per_cell: %s", cells)
    return cells


def _ue_summary_output():
    return wts_manager.send_command_to_egate("ue_summary", wait_for_data=True, pass_regexp="Active")
