import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'

PARAMS_TO_MODIFY_FEATURE1070_GP1_A3 = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='3/7', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='98', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
]

PARAMS_TO_MODIFY_CDrx_NSA = [
    dict(value='true', dist_name=_NRCELLname, p_name='actCDrx'),
    dict(value='40ms', dist_name=_NRCELLname, p_name='drxLongCycle'),

]

PARAMS_TO_MODIFY_CDrx_SA = [
    dict(value='true', dist_name=_NRCELLname, p_name='actCDrx'),
    dict(value='40ms', dist_name=_NRCELLname, p_name='drxLongCycle'),

]
