import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

__maintainer__ = 'Xing Jing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jing.1.Xing@nokia-sbell.com'


_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname_gnb2 = 'MRBTS-' + _gnb2_id
_NRBTSname_gnb2 = _MRBTSname_gnb2 + '/NRBTS-' + _gnb2_id
_NRCELLname_gnb2 = _NRBTSname_gnb2 + '/NRCELL-1'
_NRMOPRMA1_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-1'
_NRMOPRMA2_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-2'
_NRMOPRMA3_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-3'
_NRMOPRMA4_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPRMA_SA-4'
_NRMOPR1_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-1'
_NRMOPR2_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-2'
_NRMOPR3_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-3'
_NRMOPR4_SA_gnb2 = _NRBTSname_gnb2 + '/NRMOPR_SA-4'

_gnb1_id = str(tl.gnbs[0].instance_id)
_MRBTSname_gnb1 = 'MRBTS-' + _gnb1_id
_NRBTSname_gnb1 = _MRBTSname_gnb1 + '/NRBTS-' + _gnb1_id
_NRCELLname_gnb1 = _NRBTSname_gnb1 + '/NRCELL-1'
_NRCELLname2_gnb1 = _NRBTSname_gnb1 + '/NRCELL-2'
_NRCELLname3_gnb1 = _NRBTSname_gnb1 + '/NRCELL-3'
_NRMOPRMA31_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPRMA_SA-31'
_NRMOPR31_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPR_SA-31'
_NRMOPR32_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPR_SA-32'
_NRMOPR1_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPR_SA-1'
_NRMOPR2_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPR_SA-2'
_NRMOPR3_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPR_SA-3'
_NRMOPRMA2_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPRMA_SA-2'
_NRMOPRMA3_SA_gnb1 = _NRBTSname_gnb1 + '/NRMOPRMA_SA-3'

PARAMS_TO_MODIFY_710_C20_1 = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRfspIndex', value='false'),
]

PARAMS_TO_MODIFY_710_C20_2 = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRfspIndex', value='true'),
]

PARAMS_TO_MODIFY_710_C21_1_trunk = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMoRedDNList', value=_NRBTSname_gnb1 + '/NRMORED-2'),
]

PARAMS_TO_MODIFY_710_C21_2_trunk = [
    dict(dist_name=_NRMOPRMA1_SA_gnb2, parameter='rfspIndexLast', value='5'),
    dict(dist_name=_NRMOPRMA2_SA_gnb2, parameter='nrPlmnDNList', value=_NRBTSname_gnb2 + '/NRPLMN-2'),
    dict(dist_name=_NRMOPRMA3_SA_gnb2, parameter='nrPlmnDNList', value=_NRBTSname_gnb2 + '/NRPLMN-2'),
]

PARAMS_TO_MODIFY_710_C21_3_trunk = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMoRedDNList', value=_NRBTSname_gnb1 + '/NRMORED-1'),
]

PARAMS_TO_MODIFY_710_C21_4_trunk = [
    dict(dist_name=_NRMOPRMA1_SA_gnb2, parameter='rfspIndexLast', value='20'),
    dict(dist_name=_NRMOPRMA2_SA_gnb2, parameter='nrPlmnDNList', value=_NRBTSname_gnb2 + '/NRPLMN-1'),
    dict(dist_name=_NRMOPRMA3_SA_gnb2, parameter='nrPlmnDNList', value=_NRBTSname_gnb2 + '/NRPLMN-1'),
]

PARAMS_TO_MODIFY_710_C16_1 = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actMobilityProfile', value='false'),
]

PARAMS_TO_MODIFY_710_C16_2 = [
    dict(dist_name=_NRBTSname_gnb2, parameter='actRfspIndex', value='false'),
]

PARAMS_TO_MODIFY_710_C16_3 = [
    dict(dist_name=_NRMOPR1_SA_gnb2, parameter='a2MeasRedirectEnabled'),
    dict(dist_name=_NRMOPR2_SA_gnb2, parameter='a2MeasRedirectEnabled'),
    dict(dist_name=_NRMOPR3_SA_gnb2, parameter='a2MeasRedirectEnabled'),
    dict(dist_name=_NRMOPR4_SA_gnb2, parameter='a2MeasRedirectEnabled'),
    dict(dist_name=_NRMOPR1_SA_gnb2, parameter='nrMoRedDNList'),
    dict(dist_name=_NRMOPR2_SA_gnb2, parameter='nrMoRedDNList'),
    dict(dist_name=_NRMOPR3_SA_gnb2, parameter='nrMoRedDNList'),
    dict(dist_name=_NRMOPR4_SA_gnb2, parameter='nrMoRedDNList'),
]

PARAMS_TO_MODIFY_710_C16_4 = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actMobilityProfile', value='true'),
]

PARAMS_TO_MODIFY_710_C14_1 = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMoRedDNList', value=_NRBTSname_gnb1 + '/NRMORED-4'),
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='none'),
]

PARAMS_TO_MODIFY_710_C14_2 = [
    dict(dist_name=_NRCELLname_gnb1 + '/NRREDRT-4'),
]

PARAMS_TO_MODIFY_710_C14_3 = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMoRedDNList', value=_NRBTSname_gnb1 + '/NRMORED-1'),
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='rsrp'),
]

PARAMS_TO_MODIFY_710_C13_1 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='none'),
]

PARAMS_TO_MODIFY_710_C13_2 = [
    dict(dist_name=_NRMOPRMA31_SA_gnb1),
    dict(dist_name=_NRMOPR31_SA_gnb1),
]

PARAMS_TO_MODIFY_710_D02_1 = [
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='voiceFBMode', value='disabled'),
]

PARAMS_TO_MODIFY_710_D02_2 = [
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='voiceFBMode', value='redirection'),
]

PARAMS_TO_MODIFY_710_D11_1 = [
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='emergencyCallFails'),
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='emergencyFBMode'),
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='voiceFBMode'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='emergencyCallFails'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='emergencyFBMode'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='voiceFBMode'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='emergencyCallFails'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='emergencyFBMode'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='voiceFBMode'),
]

PARAMS_TO_MODIFY_710_D11_2 = [
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='emergencyCallFails', value='disabled'),
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='emergencyFBMode', value='disabled'),
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='voiceFBMode', value='disabled'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='emergencyCallFails', value='disabled'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='emergencyFBMode', value='disabled'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='voiceFBMode', value='disabled'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='emergencyCallFails', value='redirection'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='emergencyFBMode', value='redirection'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='voiceFBMode', value='redirection'),
]

PARAMS_TO_MODIFY_710_D14_1 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='actVoNR', value='true'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actGBRAdmissionControl', value='EnhancedVoNR'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEnhancedVoNR', value='true'),
    dict(dist_name=_NRCELLname_gnb1, parameter='maxNumOfGBRBearersSA', value='0'),
]

PARAMS_TO_MODIFY_710_D14_2 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='actVoNR', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actGBRAdmissionControl', value='off'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEnhancedVoNR', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='maxNumOfGBRBearersSA', value='10'),
]

PARAMS_TO_MODIFY_710_D16_1 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='actVoNR', value='true'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actGBRAdmissionControl', value='EnhancedVoNR'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEnhancedVoNR', value='true'),
    dict(dist_name=_NRCELLname_gnb1, parameter='maxNumOfGBRBearersSA', value='0'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEmergencyCall', value='true'),
]

PARAMS_TO_MODIFY_710_D16_2 = [
    dict(dist_name=_NRCELLname_gnb1, parameter='actVoNR', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actGBRAdmissionControl', value='off'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEnhancedVoNR', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='maxNumOfGBRBearersSA', value='10'),
    dict(dist_name=_NRCELLname_gnb1, parameter='actEmergencyCall', value='false'),
]

PARAMS_TO_MODIFY_710_F07_01 = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMeasCfgIrDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IR-3'),
]

PARAMS_TO_MODIFY_710_F07_02 = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMeasCfgIrDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IR-1'),
]

PARAMS_TO_MODIFY_710_F10_01 = [
    dict(dist_name=_NRMOPRMA31_SA_gnb1, parameter='rfspIndexLast', value='5'),
]

PARAMS_TO_MODIFY_710_F10_02 = [
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a1MeashoEnabledSA', value='none'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a2MeashoEnabledSA', value='none'),
]

PARAMS_TO_MODIFY_710_F10_end = [
    dict(dist_name=_NRMOPRMA31_SA_gnb1, parameter='rfspIndexLast', value='20'),
]

PARAMS_TO_MODIFY_710_F13 = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMeasCfgIrDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IR-2'),
]

PARAMS_TO_MODIFY_710_F13_end = [
    dict(dist_name=_NRMOPR31_SA_gnb1, parameter='nrMeasCfgIrDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IR-1'),
]

PARAMS_TO_MODIFY_710_F15_01 = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actMobilityProfile', value='false'),
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='none'),
    dict(dist_name=_NRCELLname_gnb1 + '/NRHOIF-2', parameter='a3MeasEnabled', value='none'),
    dict(dist_name=_NRCELLname_gnb1 + '/NRHOIF-2', parameter='a5MeasEnabled', value='rsrp'),
]

PARAMS_TO_MODIFY_710_F15_02 = [
    dict(dist_name=_NRCELLname_gnb2, parameter='gscnOrSsPbchArfcn', value='1559'),
    dict(dist_name=_NRBTSname_gnb2 + '/NRMOPRMA_SA-1', parameter='rfspIndexLast', value='8'),
]

PARAMS_TO_MODIFY_710_F15_end = [
    dict(dist_name=_NRBTSname_gnb1, parameter='actMobilityProfile', value='true'),
    dict(dist_name=_NRCELLname_gnb1, parameter='a3MeasEnabled', value='rsrp'),
    dict(dist_name=_NRCELLname_gnb1 + '/NRHOIF-2', parameter='a3MeasEnabled', value='rsrp'),
    dict(dist_name=_NRCELLname_gnb1 + '/NRHOIF-2', parameter='a5MeasEnabled', value='none'),
]

PARAMS_TO_MODIFY_710_F08_1 = [
    dict(dist_name=_NRMOPR32_SA_gnb1, parameter='nrMeasCfgIrDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IR-1'),
]

PARAMS_TO_MODIFY_710_F08_2 = [
    dict(dist_name=_NRMOPRMA31_SA_gnb1),
    dict(dist_name=_NRMOPR31_SA_gnb1),
]

PARAMS_TO_MODIFY_710_E06_1 = [
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='a2MeashoEnabledSA'),
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='a1MeashoEnabledSA'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='a2MeashoEnabledSA'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='a1MeashoEnabledSA'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a2MeashoEnabledSA'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a1MeashoEnabledSA'),
]

PARAMS_TO_MODIFY_710_E06_2 = [
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR1_SA_gnb1, parameter='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a1MeashoEnabledSA', value='rsrp'),
]

PARAMS_TO_MODIFY_710_E03_1 = [
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IF-3'),
]

PARAMS_TO_MODIFY_710_E03_2 = [
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IF-1'),
]

PARAMS_TO_MODIFY_710_E09_1 = [
    dict(dist_name=_NRMOPRMA2_SA_gnb1, parameter='rfspIndexLast', value='15'),
]

PARAMS_TO_MODIFY_710_E09_2 = [
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IF-4'),
]

PARAMS_TO_MODIFY_710_E09_3 = [
    dict(dist_name=_NRMOPRMA2_SA_gnb1, parameter='rfspIndexLast', value='5'),
    dict(dist_name=_NRMOPR2_SA_gnb1, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IF-2'),
]

PARAMS_TO_MODIFY_710_E04_1 = [
    dict(dist_name=_NRMOPRMA3_SA_gnb1),
    dict(dist_name=_NRMOPR3_SA_gnb1),
]

PARAMS_TO_MODIFY_710_E04_2 = [
    dict(dist_name=_NRMOPR1_SA_gnb2, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb2 + '/NRMEASCFG_IF-4'),
]

PARAMS_TO_MODIFY_710_E04_3 = [
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a2MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a1MeashoEnabledSA', value='rsrp'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='a2MeasRedirectEnabled', value='rsrpAndRsrq'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb1 + '/NRMEASCFG_IF-1'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='nrMoPrSaId', value='3'),
    dict(dist_name=_NRMOPR3_SA_gnb1, parameter='nrMoRedDNList', value=_NRBTSname_gnb1 + '/NRMORED-1'),
    dict(dist_name=_NRMOPRMA3_SA_gnb1, parameter='mobilityProfilePriority', value='3'),
    dict(dist_name=_NRMOPRMA3_SA_gnb1, parameter='nrMoPrSaDN', value=_NRBTSname_gnb1 + '/NRMOPR_SA-3'),
    dict(dist_name=_NRMOPRMA3_SA_gnb1, parameter='sNSSAIDNList', value=_NRBTSname_gnb1 + '/SNSSAI-1'),
]

PARAMS_TO_MODIFY_710_E04_4 = [
    dict(dist_name=_NRMOPR1_SA_gnb2, parameter='nrMeasCfgIfDNList', value=_NRBTSname_gnb2 + '/NRMEASCFG_IF-1'),
]

PARAMS_TO_MODIFY_710_A12_1_lock = [
    dict(dist_name=_NRCELLname_gnb1, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELLname2_gnb1, parameter='administrativeState', value='Locked'),
    dict(dist_name=_NRCELLname3_gnb1, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_710_A12_1_unlock = [
    dict(dist_name=_NRCELLname_gnb1, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELLname2_gnb1, parameter='administrativeState', value='Unlocked'),
    dict(dist_name=_NRCELLname3_gnb1, parameter='administrativeState', value='Unlocked'),
]
