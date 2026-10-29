# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Artur Stepniak
:contact: I_UTE_CORE_5G@internal.nsn.com
"""
from cloud5g.commissioning import CustomCommissioningBase


class CustomCommissioning(CustomCommissioningBase):

    def __init__(self, scf_path):
        super(CustomCommissioning, self).__init__(scf_path)

    def modify_scf(self, _):
        nrbts = self.scf_handler.raml.cmData.MRBTS[0].NRBTS[0]
        nrbts.f1Cplane.remove()
        nrbts.f1Uplane.remove()
        nrbts.f1Mplane.remove()

        nrdu = nrbts.NRDU[0]
        nrdu.f1Cplane.remove()
        nrdu.f1Uplane.remove()
        nrdu.f1Mplane.remove()
