import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Yishuang Wang'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yishuang.wang@nokia-sbell.com'

_gnb_id_20B = str(tl.gnbs[0].global_bts_id)
_MRBTSname_20B = 'MRBTS-' + _gnb_id_20B
_NRBTSname_20B = _MRBTSname_20B + '/NRBTS-' + _gnb_id_20B
_NRCELLname_20B = _NRBTSname_20B + '/NRCELL-1'
_NRRELE_1_20B = _NRCELLname_20B + '/NRRELE-1'
_NRRELE_2_20B = _NRCELLname_20B + '/NRRELE-2'
_NRRELE_3_20B = _NRCELLname_20B + '/NRRELE-3'
_NRHOIR_20B = _NRBTSname_20B + '/NRHOIR-1'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname_gnb2 = 'MRBTS-' + _gnb2_id
_NRBTSname_gnb2 = _MRBTSname_gnb2 + '/NRBTS-' + _gnb2_id
_NRCELLname_gnb2 = _NRBTSname_gnb2 + '/NRCELL-1'
_NRRELE_1_gnb2 = _NRCELLname_gnb2 + '/NRRELE-1'
_NRRELE_2_gnb2 = _NRCELLname_gnb2 + '/NRRELE-2'
_NRRELE_3_gnb2 = _NRCELLname_gnb2 + '/NRRELE-3'
_NRHOIR_gnb2 = _NRBTSname_gnb2 + '/NRHOIR-1'

_gnb1_id = str(tl.gnbs[1].instance_id)
_MRBTSname_gnb1 = 'MRBTS-' + _gnb1_id
_NRBTSname_gnb1 = _MRBTSname_gnb1 + '/NRBTS-' + _gnb1_id
_NRCELLname_gnb1 = _NRBTSname_gnb1 + '/NRCELL-1'
_NRRELE1name_gnb1 = _NRCELLname_gnb1 + '/NRRELE-1'
_NRRELE2name_gnb1 = _NRCELLname_gnb1 + '/NRRELE-2'
_NRHOIR1_gnb1 = _NRBTSname_gnb1 + '/NRHOIR-1'


PARAMS_TO_MODIFY_707_FD31_Trunk = [
    dict(dist_name=_NRCELLname_gnb2, parameter='cellDepType', value='SA+NSA'),
    dict(dist_name=_NRCELLname_gnb2, parameter='configuredEpsTac', value='0'),
]

PARAMS_TO_MODIFY_707_A30_1_Trunk = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actRedirect', value='true'),
    dict(
        value=[dict(b2Threshold2hoRsrp='90')],
        dist_name=_NRHOIR1_gnb1,
        parameter='eutraB2MeashoRsrp'),
    dict(
        value=[dict(a2ThresholdRedirectSsbRsrp='67')],
        dist_name=_NRCELLname_gnb1,
        parameter='a2MeasRedirectSsbRsrp'),
]
PARAMS_TO_MODIFY_707_A30_2_Trunk = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actRedirect', value='false'),
    dict(
        value=[dict(b2Threshold2hoRsrp='35')],
        dist_name=_NRHOIR1_gnb1,
        parameter='eutraB2MeashoRsrp'),
    dict(
        value=[dict(a2ThresholdRedirectSsbRsrp='77')],
        dist_name=_NRCELLname_gnb1,
        parameter='a2MeasRedirectSsbRsrp'),
]
PARAMS_TO_MODIFY_707_A30_1_21A = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actRedirect', value='true'),
    dict(
        value=[dict(b2Threshold2hoRsrp='80')],
        dist_name=_NRHOIR1_gnb1,
        parameter='eutraB2MeashoRsrp'),
]

PARAMS_TO_MODIFY_707_A30_2_21A = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actRedirect', value='false'),
    dict(
        value=[dict(b2Threshold2hoRsrp='10')],
        dist_name=_NRHOIR1_gnb1,
        parameter='eutraB2MeashoRsrp'),
]
PARAMS_TO_MODIFY_707_D01_1_Trunk = [
    dict(dist_name=_NRRELE1name_gnb1, parameter='eutranCellBlacklisted', value='true'),
    dict(dist_name=_NRRELE2name_gnb1, parameter='eutranCellBlacklisted', value='false'),
]

PARAMS_TO_MODIFY_707_D01_2_Trunk = [
    dict(dist_name=_NRRELE1name_gnb1, parameter='eutranCellBlacklisted', value='false'),
    dict(dist_name=_NRRELE2name_gnb1, parameter='eutranCellBlacklisted', value='true'),
]
PARAMS_TO_MODIFY_707_D01_1_21A = [
    dict(dist_name=_NRRELE1name_gnb1, parameter='eutranCellBlacklisted', value='true'),
    dict(dist_name=_NRRELE2name_gnb1, parameter='eutranCellBlacklisted', value='false'),
]

PARAMS_TO_MODIFY_707_D01_2_21A = [
    dict(dist_name=_NRRELE1name_gnb1, parameter='eutranCellBlacklisted', value='false'),
    dict(dist_name=_NRRELE2name_gnb1, parameter='eutranCellBlacklisted', value='true'),
]
PARAMS_TO_MODIFY_707_FD17_1_Trunk = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRedirect', value='true'),
]

PARAMS_TO_MODIFY_707_FD17_2_Trunk = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRedirect', value='false'),
]

PARAMS_TO_MODIFY_707_FD31_21A = [
    dict(dist_name=_NRCELLname_gnb2, parameter='cellDepType', value='both'),
    dict(dist_name=_NRCELLname_gnb2, parameter='configuredEpsTac', value='0'),
]

PARAMS_TO_MODIFY_707_FD17_1_21A = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRedirect', value='true'),
]

PARAMS_TO_MODIFY_707_FD17_2_21A = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRedirect', value='false'),
]

PARAMS_TO_MODIFY_707_E07_21A = [
    dict(dist_name=_NRCELLname_gnb2, parameter='cellDepType', value='both'),
    dict(dist_name=_NRCELLname_gnb2, parameter='configuredEpsTac', value='0'),
    dict(dist_name=_NRHOIR_gnb2, parameter='eutraFreqQOffsetRange', value='-3dB'),
    dict(dist_name=_NRRELE_1_gnb2, parameter='cellIndividualOffset', value='6dB'),
    dict(dist_name=_NRRELE_3_gnb2, parameter='eutranCellBlacklisted', value='false'),
]

PARAMS_TO_MODIFY_707_FD31_21B = [
    dict(dist_name=_NRCELLname_gnb2, parameter='cellDepType', value='SA+NSA'),
    dict(dist_name=_NRCELLname_gnb2, parameter='configuredEpsTac', value='0'),
]

PARAMS_TO_MODIFY_707_FD17_1_21B = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRedirect', value='true'),
]

PARAMS_TO_MODIFY_707_FD17_2_21B = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRedirect', value='false'),
]

PARAMS_TO_MODIFY_707_E07 = [
    dict(dist_name=_NRCELLname_gnb2, parameter='cellDepType', value='SA+NSA'),
    dict(dist_name=_NRCELLname_gnb2, parameter='configuredEpsTac', value='0'),
    dict(dist_name=_NRHOIR_gnb2, parameter='eutraFreqQOffsetRange', value='-3dB'),
    dict(dist_name=_NRRELE_1_gnb2, parameter='cellIndividualOffset', value='6dB'),
    dict(dist_name=_NRRELE_3_gnb2, parameter='eutranCellBlacklisted', value='false'),
]
