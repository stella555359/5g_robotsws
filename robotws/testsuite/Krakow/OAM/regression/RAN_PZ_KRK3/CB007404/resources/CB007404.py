# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Krzysztof Domino
:contact: krzysztof.domino@nokia.com
"""

from taf.gnb.oam.coam.admin import admin
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations, login_logout


class RunTime(GenericDuOperations):
    admin = admin()

    def __init__(self, bts_type="GNB"):
        super(RunTime, self).__init__(bts_type=bts_type)

    def get_runtime_info(self, bts_id=0, du_id=0):
        result = self.admin.get_bts_info()
        return result["id"]["internal"]
