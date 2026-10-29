# -*- coding: utf-8 -*
"""
This file defines the filters for checkpoints of control plane messages.
"""

xpath_x2ap_SgNBAdditionReq = 'x2ap//..//x2ap.SgNBAdditionRequest_element'
xpath_x2ap_candidateCellInfo = "//*[@showname='candidateCellInfoListMN: 2 items']"


TC01_ENABLE_CNI = [
    xpath_x2ap_SgNBAdditionReq,
    xpath_x2ap_candidateCellInfo
]

TC01_DISABLE_CNI = [
    xpath_x2ap_SgNBAdditionReq,
    xpath_x2ap_candidateCellInfo
]
