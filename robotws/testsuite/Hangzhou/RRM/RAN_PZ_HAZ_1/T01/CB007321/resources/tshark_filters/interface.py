# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: DevWro1
:maintainer: 5GSWEngWro
:contact: I_TA5G_SUPPORT <I_TA5G_SUPPORT@internal.nsn.com>
"""
from .iphy import Iphy
from .misc import Misc
from .nas_eps import NasEps
from .s1ap import S1AP
from .x2ap import X2AP
from .lte_rrc import LteRrc
from .narrowband import Narrowband
from .ngap import NGAP
from .f1ap import F1AP
from .e1ap import E1AP
from .nr_rrc import NrRrc
from .nas_5gs import Nas5gs
from .xnap import XNAP


class tshark_filters(Iphy, LteRrc, Misc, NasEps, S1AP, X2AP, Narrowband, NGAP, F1AP, E1AP, NrRrc, XNAP, Nas5gs):
    def __init__(self):
        Iphy.__init__(self)
        LteRrc.__init__(self)
        Misc.__init__(self)
        NasEps.__init__(self)
        S1AP.__init__(self)
        X2AP.__init__(self)
        Narrowband.__init__(self)
        NGAP.__init__(self)
        F1AP.__init__(self)
        E1AP.__init__(self)
        NrRrc.__init__(self)
        Nas5gs.__init__(self)
        XNAP.__init__(self)
