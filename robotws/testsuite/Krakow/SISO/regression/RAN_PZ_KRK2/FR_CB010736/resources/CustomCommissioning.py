"""
:copyright: Nokia Networks
:author: Grzegorz Kaczor
"""

import logging
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


class CustomCommissioning(GenericBts):

    @login_logout
    def get_build_release(self, bts_id=0, du_id=0):
        active_software_version = self.admin.get_sw_version(timeout=60,
                                                            connection=self.rest_alias.format(bts_id, du_id))
        logging.info("Detected Software: {}".format(active_software_version))
        active_sw_version = SbtsSwVersion(active_software_version)
        return active_sw_version.release
