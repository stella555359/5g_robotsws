"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""
import logging
import re
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as GnbRu


class GnbCustomDu(GnbBbu):

    def __init__(self):
        super(GnbCustomDu, self).__init__()

        self.cell_interface = GnbCell()
        self.ru_interface = GnbRu()
        self.re_ru_dist_name = r'(?P<RU_DIST_NAME>MRBTS-\d+/EQM-\d+/APEQM-\d+/RMOD-{})'

    @login_logout
    def get_ru_dist_name(self, bts_id=0, ru_id=1, du_id=0):
        bts_runtime_info = self.admin.get_bts_info(connection=self.rest_alias.format(bts_id, du_id))
        _re_ru_dist_name = self.re_ru_dist_name.format(ru_id)
        determine_pattern = re.search(_re_ru_dist_name, str(bts_runtime_info))
        if not determine_pattern:
            raise IndexError("Radio Unit distName not found")
        else:
            return determine_pattern.group('RU_DIST_NAME')

    def verify_ru_is_operational(self, bts_id=0, du_id=0, ru_id=1):
        self.ru_interface.verify_statuses_on_ru(bts_id=bts_id, du_id=du_id, ru_id=ru_id)

    def verify_ru_restart_occurred_in_given_past_time(self, time_period=400, bts_id=0, du_id=0, ru_id=0):
        self.ru_interface.verify_ru_restart_occured(time=time_period, bts_id=bts_id, du_id=du_id, ru_id=ru_id)

    @login_logout
    def get_random_cell_id(self, mrbts, bts_id=0, du_id=0):
        random_cell = self.cell_interface.get_random_cell_dist_name(bts_id=bts_id, du_id=du_id)
        random_cell = random_cell.format(int(mrbts), int(mrbts))
        return random_cell

    @login_logout
    def verify_cell_is_locked(self, cell_dist_name, bts_id=0, du_id=0):
        cell_specific_info = self.admin.get_cell_specific_info(cell_id=cell_dist_name,
                                                               connection=self.rest_alias.format(bts_id, du_id))

        if cell_specific_info["status"]["administrativeState"] == "Locked":
            logging.info("Cell {} is locked".format(cell_dist_name))
            return True
        raise AttributeError("Cell {} is not locked: {}".format(cell_dist_name, cell_specific_info))

    @login_logout
    def verify_cell_is_unlocked(self, cell_dist_name, bts_id=0, du_id=0):
        cell_specific_info = self.admin.get_cell_specific_info(cell_id=cell_dist_name,
                                                               connection=self.rest_alias.format(bts_id, du_id))

        if cell_specific_info["status"]["administrativeState"] == "Unlocked":
            logging.info("Cell {} is locked".format(cell_dist_name))
            return True
        raise AttributeError("Cell {} is not locked: {}".format(cell_dist_name, cell_specific_info))
