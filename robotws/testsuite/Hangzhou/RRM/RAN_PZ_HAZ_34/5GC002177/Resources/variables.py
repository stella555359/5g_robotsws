import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.Xing@nokia-sbell.com'


# _gnb2_id = str(tl.gnbs[1].instance_id)
# _MRBTSname_gnb2 = 'MRBTS-' + _gnb2_id
# _NRBTSname_gnb2 = _MRBTSname_gnb2 + '/NRBTS-' + _gnb2_id
# _NRCELLname_gnb2 = _NRBTSname_gnb2 + '/NRCELL-1'
# _NRMOPRMA1_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-1'
# _NRMOPRMA2_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-2'
# _NRMOPRMA3_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-3'
# _NRMOPRMA4_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-4'
# _NRMOPR1_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-1'
# _NRMOPR2_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-2'
# _NRMOPR3_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-3'
# _NRMOPR4_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-4'

_gnb1_id = str(tl.gnbs[0].instance_id)
_MRBTSname_gnb1 = 'MRBTS-' + _gnb1_id
_NRBTSname_gnb1 = _MRBTSname_gnb1 + '/NRBTS-' + _gnb1_id
_NRBTSname_gnb236 = _MRBTSname_gnb1 + '/NRBTS-' + '1'
_NRCELLname_gnb1 = _NRBTSname_gnb1 + '/NRCELL-1'
_NRCELLname_gnb_236 = _NRBTSname_gnb236 + '/NRCELL-1'
_NRCELLname2_gnb1 = _NRBTSname_gnb1 + '/NRCELL-2'
_NRCELLname3_gnb1 = _NRBTSname_gnb1 + '/NRCELL-3'


PARAMS_TO_MODIFY_2177_A_03_1 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='a2MeasReleaseEnabled', value='rsrpAndRsrq'),
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='none'),
]

PARAMS_TO_MODIFY_2177_A_03_1_236 = [
    dict(dist_name=_NRCELLname_gnb_236, parameter='a2MeasReleaseEnabled', value='rsrpAndRsrq'),
]

PARAMS_TO_MODIFY_2177_A_03_2 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='a2MeasReleaseEnabled', value='none'),
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='rsrp'),
]
PARAMS_TO_MODIFY_710_D14_2 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='actVoNR', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actGBRAdmissionControl', value='off'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEnhancedVoNR', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='maxNumOfGBRBearersSA', value='10'),
]
