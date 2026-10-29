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

PARAMS_TO_MODIFY_A001_UL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='98', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actUlPtrs'),
    dict(value='Automatic', dist_name=_NRCELLname, p_name='ulDMRSAdditionalPosition'),
]

PARAMS_TO_MODIFY_A002_UL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='148', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actUlPtrs'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, p_name='ulDMRSAdditionalPosition'),
]

PARAMS_TO_MODIFY_A007_UL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='148', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actUlPtrs'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, p_name='ulDMRSAdditionalPosition'),
]

PARAMS_TO_MODIFY_B001_DL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='148', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actDlPtrs'),
    dict(value='Automatic', dist_name=_NRCELLname, p_name='dlDMRSAdditionalPosition'),
]

PARAMS_TO_MODIFY_B002_DL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='148', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actDlPtrs'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, p_name='dlDMRSAdditionalPosition'),
]

PARAMS_TO_MODIFY_B006_DL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='148', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actDlPtrs'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, p_name='dlDMRSAdditionalPosition'),
    dict(value='pos2', dist_name=_NRCELLname, p_name='dmrsTypeAPosition'),
]

PARAMS_TO_MODIFY_B008_DL_DMRS = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='148', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
    dict(value='false', dist_name=_NRCELLname, p_name='actDlPtrs'),
    dict(value='One additional DMRS', dist_name=_NRCELLname, p_name='dlDMRSAdditionalPosition'),
]


PARAMS_TO_MODIFY_FEATURE1116_3_GP2_A6 = [
    dict(value='tdLte', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='4Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='3ms', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='lteToNrFrameShift'),
    dict(value='2/8', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='98', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
]


PARAMS_TO_MODIFY_FEATURE1208_GP1_A1 = [
    dict(value='semiStatic', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='frameStructureType'),
    dict(value='2Symbols', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='guardPeriodLength'),
    dict(value='1/4', dist_name=_NRCELLname, list_name='tddFrameStructure', p_name='ulDlDataSlotRatio'),
    dict(value='98', dist_name=_NRCELLname, p_name='prachConfigurationIndex'),
]
