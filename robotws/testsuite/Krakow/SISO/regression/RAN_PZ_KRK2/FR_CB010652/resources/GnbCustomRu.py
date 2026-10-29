"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
:contact: grzegorz.kaczor@nokia.com
"""

from taf.rfrl.bts.devices.ru.ru_operations import GenericRuOperations as GnbRu
from taf.rfrl.bts.devices.generic_bts import login_logout, login_logout_GUI


class GnbCustomRu(GnbRu):

    def __init__(self):
        super(GnbCustomRu, self).__init__()

    def reset_all_radio_unit_via_gui(self, bts_id=0, du_id=0, radio_type='all'):
        all_ru_ids = self._get_all_ru_ids(bts_id=bts_id, du_id=du_id, radio_type=radio_type)
        self._reset_all_rus_via_gui_loop(all_ru_ids=all_ru_ids, bts_id=bts_id, du_id=du_id)

    def reset_radio_unit_from_GUI(self, bts_id=0, radio_unit_id=1, du_id=0, radio_type='rmod'):
        self.gui_coam.reset_ru_from_site_view(ru_index=radio_unit_id, timeout=60, type_=radio_type.upper(),
                                              sbts=self.gui_alias.format(bts_id, du_id))

    @login_logout
    def _get_all_ru_ids(self, bts_id=0, du_id=0, radio_type='all'):
        return self._get_all_radio_ids(bts_id=bts_id, du_id=du_id, radio_type=radio_type)

    @login_logout_GUI
    def _reset_all_rus_via_gui_loop(self, all_ru_ids, bts_id=0, du_id=0):
        for ru_type in all_ru_ids:
            for ru_id in all_ru_ids[ru_type]:
                self.reset_radio_unit_from_GUI(radio_unit_id=ru_id, bts_id=bts_id, du_id=du_id, radio_type=ru_type)
