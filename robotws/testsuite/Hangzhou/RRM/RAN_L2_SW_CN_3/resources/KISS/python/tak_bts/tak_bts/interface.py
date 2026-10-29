# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Lily Xu
:contact: lily.l.xu@nokia.com
:maintainer: I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS
:contact: i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com
"""
from .enbfsm import Enbfsm
from .counter_control import CounterControl
from .infomodel_control import InfomodelControl
from .pscli_control import Pscli_Control
from .emil_log import EmilLog


class tak_bts(CounterControl, InfomodelControl, Enbfsm, Pscli_Control, EmilLog):
    ''' kiss bts '''
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    def __init__(self):
        InfomodelControl.__init__(self)
        CounterControl.__init__(self)
        Enbfsm.__init__(self)
        Pscli_Control.__init__(self)
        EmilLog.__init__(self)


if __name__ == "__main__":
    pass
