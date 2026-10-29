import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.xing@nokia-sbell.com'


_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname_gnb = 'MRBTS-' + _gnb_id
_NRBTSname_gnb = _MRBTSname_gnb + '/NRBTS-' + _gnb_id
_NRCELLname_gnb = _NRBTSname_gnb + '/NRCELL-1'


PARAMS_TO_MODIFY_75911_06_1 = [
    dict(dist_name=_NRCELLname_gnb, parameter='arpPrioEmergencyCall', value='5'),
]

PARAMS_TO_MODIFY_75911_06_2 = [
    dict(dist_name=_NRCELLname_gnb, parameter='arpPrioEmergencyCall', value='4'),
]

PARAMS_TO_RECOVER_75911_06 = [
    dict(dist_name=_NRCELLname_gnb, parameter='arpPrioEmergencyCall', value='1'),
]
