# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
Maintainer: Przemyslaw Kusa, przemyslaw.kusa@nokia.com
"""

from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI


class GnbDuCustom(GnbDuOperations):

    def __init__(self):
        super(GnbDuCustom, self).__init__()

    @login_logout_GUI
    def lock_lane_from_sfp_via_gui(self, hw_name, object_name, lane_id, bts_id=0, du_id=0):
        self.gui_coam.lock_lane_from_sfp(hw_name=hw_name, object_name=object_name, lane_id=lane_id,
                                         sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout_GUI
    def unlock_lane_from_sfp_via_gui(self, hw_name, object_name, lane_id, bts_id=0, du_id=0):
        self.gui_coam.unlock_lane_from_sfp(hw_name=hw_name, object_name=object_name, lane_id=lane_id,
                                           sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout_GUI
    def get_hw_info(self, hw_name, connector, bts_id=0, du_id=0):
        return self.gui_coam.get_hw_info(hw_name=hw_name, connector=connector,
                                         sbts=self.gui_alias.format(bts_id, du_id))
