import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations


def action_with_cells(action, cell_id=None):
    gnb_cell = GnbCellOperations()
    if cell_id is None:
        all_cells_ids = gnb_cell.get_all_cells_id()
    else:
        all_cells_ids = []
        for cell in cell_id:
            all_cells_ids.append(int(cell))
    if action == "Block":
        for cell in all_cells_ids:
            gnb_cell.block_cell(cell_id=cell)
            gnb_cell.verify_cell_is_blocked(cell_id=cell)
            logger.log_info_to_console('Cell{} is blocked.'.format(cell))
    elif action == "Unblock":
        for cell in all_cells_ids:
            gnb_cell.unblock_cell(cell_id=cell)
            gnb_cell.verify_cell_is_unblocked(cell_id=cell)
            logger.log_info_to_console('Cell{} is unblocked.'.format(cell))
