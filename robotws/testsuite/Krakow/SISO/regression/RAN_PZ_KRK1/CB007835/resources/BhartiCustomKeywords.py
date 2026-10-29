from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations


class BhartiCustomKeywords(GnbCellOperations):
    """
    Method `_get_cell_ids_in_specific_cell_group` is `private`.
    RF ignores all private methods.
    Using it directly in .robot file is impossible.
    """
    def get_cell_ids_in_specific_cell_group(self, cell_group_id=0, bts_id=0, du_id=0):
        return list(self._get_cell_ids_in_specific_cell_group(bts_id=bts_id, cell_group_id=cell_group_id, du_id=du_id))
