import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Yishuang Wang'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yishuang.wang@nokia-sbell.com'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname_gnb2 = 'MRBTS-' + _gnb2_id
_NRBTSname_gnb2 = _MRBTSname_gnb2 + '/NRBTS-' + _gnb2_id
_NRCELLname_gnb2 = _NRBTSname_gnb2 + '/NRCELL-1'
_NRRELE_1_gnb2 = _NRCELLname_gnb2 + '/NRRELE-1'
_NRRELE_2_gnb2 = _NRCELLname_gnb2 + '/NRRELE-2'
_NRRELE_3_gnb2 = _NRCELLname_gnb2 + '/NRRELE-3'
_NRHOIR_gnb2 = _NRBTSname_gnb2 + '/NRHOIR-1'

_gnb1_id = str(tl.gnbs[0].instance_id)
_MRBTSname_gnb1 = 'MRBTS-' + _gnb1_id
_NRBTSname_gnb1 = _MRBTSname_gnb1 + '/NRBTS-' + _gnb1_id
_NRCELLname_gnb1 = _NRBTSname_gnb1 + '/NRCELL-1'
_NRRELE1name_gnb1 = _NRCELLname_gnb1 + '/NRRELE-1'
_NRRELE2name_gnb1 = _NRCELLname_gnb1 + '/NRRELE-2'
_NRMEASCFG_IF2_gnb1 = _NRBTSname_gnb1 + '/NRMEASCFG_IF-2'
_NRMEASCFG_IF1_gnb1 = _NRBTSname_gnb1 + '/NRMEASCFG_IF-1'
_NRMOPR_NSA_gnb32 = _NRBTSname_gnb1 + '/NRMOPR_NSA-32'
_NRMOPRMA_NSA2_gnb1 = _NRBTSname_gnb1 + '/NRMOPRMA_NSA-2'
_NRMOPRMA_NSA31_gnb1 = _NRBTSname_gnb1 + '/NRMOPRMA_NSA-31'

PARAMS_TO_MODIFY_710_A15_1_trunk = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actMobilityProfile', value='true'),
]
PARAMS_TO_MODIFY_710_A15_2_trunk = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actMobilityProfile', value='false'),
]
PARAMS_TO_MODIFY_710_A16_1_trunk = [
    dict(dist_name=_NRMOPRMA_NSA2_gnb1, parameter='spidLast', value='256'),
]
PARAMS_TO_MODIFY_710_A16_2_trunk = [
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='a3MeasEnabled', value='rsrpAndRsrq'),
]
PARAMS_TO_MODIFY_710_A16_3_trunk = [
    dict(dist_name=_NRMOPRMA_NSA2_gnb1, parameter='spidLast', value='10'),
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='a3MeasEnabled', value='rsrpCombined'),
]
PARAMS_TO_MODIFY_710_A10_1_trunk = [
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='a3MeasEnabled', value='rsrp'),
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='a5MeasEnabled', value='none'),
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='ssbFrequency', value='518910'),
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='freqBandIndicatorNR', value='41'),
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='freqBandIndicatorNR', value='71'),
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='ssbFrequency', value='126270'),
]
PARAMS_TO_MODIFY_710_A10_2_trunk = [
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='a3MeasEnabled', value='none'),
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='a5MeasEnabled', value='rsrp'),
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='ssbFrequency', value='126270'),
    dict(dist_name=_NRMEASCFG_IF2_gnb1, parameter='freqBandIndicatorNR', value='71'),
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='freqBandIndicatorNR', value='41'),
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='ssbFrequency', value='518910'),
]
PARAMS_TO_MODIFY_710_A13_1_trunk = [
    dict(dist_name=_NRMOPRMA_NSA31_gnb1, parameter='spidLast', value='60'),
    dict(
        value=[dict(a1ThresholdhoSsbRsrp='80')],
        dist_name=_NRCELLname_gnb1,
        parameter='a1MeashoSsbRsrp'),
]
PARAMS_TO_MODIFY_710_A13_2_trunk = [
    dict(dist_name=_NRMOPRMA_NSA31_gnb1, parameter='spidLast', value='256'),
    dict(
        value=[dict(a1ThresholdhoSsbRsrp='100')],
        dist_name=_NRCELLname_gnb1,
        parameter='a1MeashoSsbRsrp'),
]
PARAMS_TO_MODIFY_710_B02_1_trunk = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actRfspIndex', value='true'),
]
PARAMS_TO_MODIFY_710_A12_1_trunk = [
    dict(dist_name=_NRMOPRMA_NSA31_gnb1),
    dict(dist_name=_NRMOPR_NSA_gnb32),
]

PARAMS_TO_MODIFY_710_A12_2_trunk = [
    dict(dist_name=_NRMEASCFG_IF1_gnb1, parameter='a3MeasEnabled', value='rsrp'),
]
