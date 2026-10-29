import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELL1name = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRBTSname1 = _MRBTSname+'/NRBTS-1'
_NRCELL1name1 = _NRBTSname1+'/NRCELL-1'
_NRCELL2name1 = _NRBTSname1+'/NRCELL-2'
_NRCELL3name1 = _NRBTSname1+'/NRCELL-3'
_NRCELL1REL1 = _NRCELL1name1+'/NRREL-0'

PARAMS_TO_MODIFY_FEATURE01 = [
    {'dist_name': _NRBTSname1, 'parameter': 'actIntraFreqIntraGnbMobilityNSA', 'value': 'false'},
    {'dist_name': _NRBTSname1, 'parameter': 'actIntraFreqInterGnbMobilityNSA3x', 'value': 'false'},
]

PARAMS_TO_MODIFY_FEATURE02 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'none'},
]

PARAMS_TO_MODIFY_FEATURE011 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'none'},
]

PARAMS_TO_MODIFY_FEATURE103 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'rsrpAndRsrq'},
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'none'},
]

PARAMS_TO_MODIFY_FEATURE016 = [
    {'dist_name': _NRCELL2name1, 'parameter': 'a3MeasEnabled', 'value': 'none'},
    {'dist_name': _NRCELL2name1, 'parameter': 'a5MeasEnabled', 'value': 'rsrp'},
]

PARAMS_TO_MODIFY_FEATURE301 = [
   dict(
        value=[dict(physCellId='70', range='n8')],
        dist_name=_NRCELL1name1,
        parameter='pciBlackList')
]

PARAMS_TO_MODIFY_FEATURE302 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'none'},
]

PARAMS_TO_MODIFY_FEATURE501 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'none'},
    {'dist_name': _NRCELL1name1, 'parameter': 'blockHoTimer', 'value': '10'},
    {'dist_name': _NRCELL2name1, 'parameter': 'blockHoTimer', 'value': '10'},
    {'dist_name': _NRBTSname1+'/NRCELLGRP-1', 'parameter': 'maxNumOfUsers', 'value': '0'},
]

PARAMS_TO_MODIFY_FEATURE303 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'none'},
]

PARAMS_TO_MODIFY_FEATURE303_2 = [
    dict(
        value=[dict(mcc='265', mnc='3', mncLength='2')],
        dist_name=_NRCELL1REL1,
        parameter='gnbPlmn')
]

PARAMS_TO_MODIFY_FEATURE105_1 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'rsrpCombined'},
]

PARAMS_TO_MODIFY_FEATURE105_2 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'rsrqCombined'},
]

PARAMS_TO_MODIFY_FEATURE113 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'none'},
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'rsrp'},
]

PARAMS_TO_MODIFY_FEATURE115_1 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a3MeasEnabled', 'value': 'none'},
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'rsrpCombined'},
]

PARAMS_TO_MODIFY_FEATURE115_2 = [
    {'dist_name': _NRCELL1name1, 'parameter': 'a5MeasEnabled', 'value': 'rsrqCombined'},
]

PARAMS_TO_MODIFY_FEATURE409 = [
    {'dist_name': _NRCELL2name1, 'parameter': 'cbraPreamblesPerSsb', 'value': 'n32'},
]

PARAMS_TO_MODIFY_FEATURE409_REG = [
    dict(value='n32', dist_name=_NRCELL2name, p_name='cbraPreamblesPerSsb'),
]

PARAMS_TO_MODIFY_FEATURE301_REG = [
    dict(value='80', dist_name=_NRCELL1name, list_name='pciBlackList', p_name='physCellId'),
    dict(value='n8', dist_name=_NRCELL1name, list_name='pciBlackList', p_name='range'),
]

PARAMS_TO_MODIFY_FEATURE016_REG = [
    dict(value='none', dist_name=_NRCELL2name, p_name='a3MeasEnabled'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a5MeasEnabled'),
]

PARAMS_TO_MODIFY_FEATURE501_REG = [
    dict(value='0', dist_name=_NRBTSname+'/NRCELLGRP-1', p_name='maxNumOfUsers'),
]

PARAMS_TO_MODIFY_FEATURE707_REG = [
    dict(value='false', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
]

PARAMS_TO_MODIFY_FEATURE301_REG_19B = [
    dict(value='391', dist_name=_NRCELL1name, list_name='pciBlackList', p_name='physCellId'),
    dict(value='n8', dist_name=_NRCELL1name, list_name='pciBlackList', p_name='range'),
]

PARAMS_TO_MODIFY_FEATURE409_REG_19B = [
    dict(value='n32', dist_name=_NRCELL2name, p_name='cbraPreamblesPerSsb'),
]

PARAMS_TO_MODIFY_FEATURE016_REG_19B = [
    dict(value='none', dist_name=_NRCELL2name, p_name='a3MeasEnabled'),
    dict(value='rsrp', dist_name=_NRCELL2name, p_name='a5MeasEnabled'),
]

PARAMS_TO_MODIFY_FEATURE501_REG_19B = [
    dict(value='0', dist_name=_NRBTSname+'/NRCELLGRP-1', p_name='maxNumOfUsers'),
]

PARAMS_TO_MODIFY_FEATURE707_REG_19B = [
]

PARAMS_TO_MODIFY_FEATURE301_REG_20A = [
    dict(value='233', dist_name=_NRCELL2name1, list_name='pciBlackList', p_name='physCellId'),
    dict(value='n8', dist_name=_NRCELL2name1, list_name='pciBlackList', p_name='range'),
]

PARAMS_TO_MODIFY_FEATURE409_REG_20A = [
    dict(value='n32', dist_name=_NRCELL3name1, p_name='cbraPreamblesPerSsb'),
]

PARAMS_TO_MODIFY_FEATURE016_REG_20A = [
    dict(value='none', dist_name=_NRCELL3name1, p_name='a3MeasEnabled'),
    dict(value='rsrp', dist_name=_NRCELL3name1, p_name='a5MeasEnabled'),
]

PARAMS_TO_MODIFY_FEATURE301_REG_20B = [
    dict(value='935', dist_name=_NRCELL1name1, list_name='pciBlackList', p_name='physCellId'),
    dict(value='n8', dist_name=_NRCELL1name1, list_name='pciBlackList', p_name='range'),
]

PARAMS_TO_MODIFY_FEATURE409_REG_20B = [
    dict(value='n32', dist_name=_NRCELL2name1, p_name='cbraPreamblesPerSsb'),
]

PARAMS_TO_MODIFY_FEATURE016_REG_20B = [
    dict(value='none', dist_name=_NRCELL2name1, p_name='a3MeasEnabled'),
    dict(value='rsrp', dist_name=_NRCELL2name1, p_name='a5MeasEnabled'),
]
