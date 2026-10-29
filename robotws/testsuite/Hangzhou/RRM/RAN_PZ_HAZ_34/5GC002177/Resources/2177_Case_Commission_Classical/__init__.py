import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-1'
_NRCELLname = _MRBTSname+'/NRBTS-1/NRCELL-1'
_NRCELL1REL1 = _MRBTSname+'/NRBTS-1/NRCELL-1/NRREL-0'
_NRCELLname2 = _MRBTSname+'/NRBTS-1/NRCELL-2'
_MRBTSname_3 = 'MRBTS-'+_gnb_id
_NRBTSname_3 = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname_3 = _NRBTSname_3+'/NRCELL-1'

PARAMS_TO_MODIFY_FEATURE001 = [
    dict(value='false', dist_name=_NRBTSname, p_name='actA2SgnbRelease'),
]

PARAMS_TO_MODIFY_FEATURE001_trunk = [
    dict(value='false', dist_name=_NRBTSname_3, p_name='actA2SgnbRelease'),
]

PARAMS_TO_MODIFY_FEATURE001_20A = [
    dict(value='false', dist_name=_NRBTSname, p_name='actA2SgnbRelease'),
]

PARAMS_TO_MODIFY_FEATURE001_20B = [
    dict(value='false', dist_name=_NRBTSname, p_name='actA2SgnbRelease'),
    dict(value='rsrp', dist_name=_NRCELLname, p_name='a2MeasReleaseEnabled'),
]

PARAMS_TO_MODIFY_FEATURE002 = [
    dict(value='none', dist_name=_NRCELLname, p_name='a2MeasReleaseEnabled'),
]

PARAMS_TO_MODIFY_FEATURE002_trunk = [
    dict(value='none', dist_name=_NRCELLname_3, p_name='a2MeasReleaseEnabled'),
]

PARAMS_TO_MODIFY_FEATURE003 = [
    dict(value='false', dist_name=_NRBTSname, p_name='srb3SupportEnabled'),
    dict(value='rsrp', dist_name=_NRCELLname, p_name='a2MeasReleaseEnabled'),
]

PARAMS_TO_MODIFY_FEATURE003_trunk = [
    dict(value='false', dist_name=_NRBTSname_3, p_name='srb3SupportEnabled'),
    dict(value='rsrp', dist_name=_NRCELLname_3, p_name='a2MeasReleaseEnabled'),
    dict(value='false', dist_name=_NRBTSname_3, p_name='actIntraFreqIntraGnbMobilityNSA'),
]

PARAMS_TO_MODIFY_FEATURE003_20A = [
    dict(value='rsrp', dist_name=_NRCELLname2, p_name='a2MeasReleaseEnabled'),
    dict(value='false', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA')
]

PARAMS_TO_MODIFY_FEATURE003_20B = [
    dict(value='rsrpAndRsrq', dist_name=_NRCELLname, p_name='a2MeasReleaseEnabled'),
]

PARAMS_TO_MODIFY_FEATURE004 = [
    dict(value='true', dist_name=_NRBTSname, p_name='srb3SupportEnabled'),
    dict(value='rsrp', dist_name=_NRCELLname, p_name='a2MeasReleaseEnabled'),
]
PARAMS_TO_MODIFY_FEATURE010 = [
    dict(value='false', dist_name=_NRBTSname, p_name='srb3SupportEnabled')
]

PARAMS_TO_MODIFY_FEATURE010_1 = [
    dict(value='true', dist_name=_NRBTSname, parameter='sgnbRelForNoHandoverEnabled')
]

PARAMS_TO_MODIFY_FEATURE010_trunk = [
    dict(value='false', dist_name=_NRBTSname_3, p_name='srb3SupportEnabled'),
    dict(value='false', dist_name=_NRBTSname_3, p_name='sgnbRelForNoHandoverEnabled'),
    dict(value='none', dist_name=_NRCELLname_3, p_name='a2MeasReleaseEnabled')
]

PARAMS_TO_MODIFY_FEATURE010_1_trunk = [
    dict(value='true', dist_name=_NRBTSname_3, parameter='sgnbRelForNoHandoverEnabled')
]

PARAMS_TO_MODIFY_FEATURE010_20A = [
    dict(value='none', dist_name=_NRCELLname2, p_name='a2MeasReleaseEnabled'),
]

PARAMS_TO_MODIFY_FEATURE010_1_20A = [
    dict(value='true', dist_name=_NRBTSname, parameter='sgnbRelForNoHandoverEnabled')
]

PARAMS_TO_MODIFY_FEATURE010_20B = [
    dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
]

PARAMS_TO_MODIFY_FEATURE010_1_20B = [
    dict(value='true', dist_name=_NRBTSname, parameter='sgnbRelForNoHandoverEnabled')
]

PARAMS_TO_DEL_FOR_NRREL = [
    dict(dist_name=_NRCELLname, p_name='NRREL-0'),
]

PARAMS_TO_DEL_FOR_NRREL_trunk = [
    dict(dist_name=_NRCELLname_3, p_name='NRREL-0'),
]

PARAMS_TO_MODIFY_FEATURE011 = [
    dict(value='true', dist_name=_NRBTSname, p_name='srb3SupportEnabled'),
]
PARAMS_TO_MODIFY_BandWidth = [
    dict(value='80MHz', dist_name=_NRCELLname, p_name='chBw'),
    dict(value='80MHz', dist_name=_NRCELLname2, p_name='chBw'),
]
