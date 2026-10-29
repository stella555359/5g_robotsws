from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRDRB15name = _NRBTSname+'/NRDRB-15'

NRCELLname = _NRBTSname+'/NRCELL-1'

PATH_TO_SCF = ''

PARAM_8200_B_001 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_DELETE_8200_B_001 = [
    dict(dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname, parameter='t310VoNR')
]
PARAM_8200_recover_B_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_ADD_8200_B_001 = [
    dict(value='n10', dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELLname, parameter='t310VoNR')
]

PARAM_8200_B_003 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='false', dist_name=_NRCELLname, parameter='actCDrxVoNR')
]
PARAM_DELETE_8200_B_003 = [
    dict(dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(dist_name=_NRCELLname, parameter='t310VoNR')
]
PARAM_8200_recover_B_003 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR')
]
PARAM_ADD_8200_B_003 = [
    dict(value='n10', dist_name=_NRCELLname, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELLname, parameter='t310VoNR')
]

PARAM_8200_B_007 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]
PARAM_8200_recover_B_007 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]

PARAM_8200_B_011 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA')
]
PARAM_8200_recover_B_011 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA')
]

PARAM_8200_B_013 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='300', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='300', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]
PARAM_8200_recover_B_013 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
]


PARAM_8200_C_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUl256Qam')
]
PARAM_8200_recover_C_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRCELLname, parameter='actDl256Qam'),
    dict(value='false', dist_name=_NRCELLname, parameter='actUl256Qam')
]


PARAM_8200_D_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward')
]
PARAM_8200_recover_D_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSADlDataForward')
]

PARAM_8200_D_003 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actGnbInitRlf')
]
PARAM_8200_recover_D_003 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actGnbInitRlf')
]


PARAM_8200_E_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]
PARAM_8200_recover_E_001 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall')
]


_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path4 = 'BTS/CELLS/NRCELL-3/NNGCC'
_ho_path5 = 'BTS/CELLS/NRCELL-3/NRPMQAP-1/NGCCQ'
_ho_path6 = 'BTS/CELLS/NRCELL-1/NDLSQ'
NG_FLOW_SETUP_FAIL_FALLBACK = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09519'}
NR_RRC_RELEASE_REDIR_VFB_LTE = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55124C02501'}

NG_FLOW_REL_GNB_UE_INACTIVITY = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09004'}
NG_FLOW_SETUP_FAIL_FALLBACK_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09519'}

NG_FLOW_SETUP_FAIL_WRONG_MSG = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09012'}
NG_FLOW_STP_FAIL_WRG_MSG_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09523'}
NG_FLOW_STP_FAIL_WRG_MSG_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00512'}

NG_FLOW_SETUP_FAIL_UNSPECIFIED = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09011'}
NG_FLOW_SETUP_FAIL_UNSPC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00511'}
NG_FLOW_SETUP_FAIL_UNSPC_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09522'}

NG_FLOW_STP_ATT_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09014'}

NG_FLOW_STP_ATT_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}

NG_FLOW_REL_IRAT_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00516'}
NG_FLOW_REL_IRAT_SUC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09016'}

NG_FLOW_STP_ATT_RES_IADU_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00530'}
NG_FLOW_STP_ATT_RES_IADU_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09531'}
NG_FLOW_STP_SUC_RES_IADU_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00531'}
NG_FLOW_STP_SUC_RES_IADU_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09532'}
NG_FLOW_STP_ATT_REEST_IADU = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09023'}
NG_FLOW_STP_SUC_REEST_IADU = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09024'}

NG_FLOW_CON_SESSION_TIME_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00521'}
NG_FLOW_SETUP_ATT_TOT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08501'}
NG_FLOW_SETUP_ATT_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09517'}
NG_FLOW_SETUP_SUCC = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08502'}
NG_FLOW_SETUP_SUCC_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09518'}
NG_FLOW_SETUP_SUCC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00002'}
NG_FLOW_SETUP_ATT_TOT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00001'}
NG_FLOW_REL_AMF_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09512'}
NG_FLOW_REL_AMF_NORMAL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00519'}
NG_FLOW_REL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00003'}
NG_FLOW_REL_NORMAL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00004'}
NG_FLOW_REL_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09514'}
NG_FLOW_REL_AMF_NORMAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09019'}
NG_FLOW_REL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08503'}
NG_FLOW_REL_NORMAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08504'}
NG_FLOW_CONNECTED_SESSION_TIME = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09516'}
NG_FLOW_SESSION_DUR_NORM_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09526'}

WB_CQI_64TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21000'}
WB_CQI_64TBL_5QI1_CQI1 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21001'}
WB_CQI_64TBL_5QI1_CQI2 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21002'}
WB_CQI_64TBL_5QI1_CQI3 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21003'}
WB_CQI_64TBL_5QI1_CQI4 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21004'}
WB_CQI_64TBL_5QI1_CQI5 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21005'}
WB_CQI_64TBL_5QI1_CQI6 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21006'}
WB_CQI_64TBL_5QI1_CQI7 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21007'}
WB_CQI_64TBL_5QI1_CQI8 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21008'}
WB_CQI_64TBL_5QI1_CQI9 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21009'}
WB_CQI_64TBL_5QI1_CQI10 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21010'}
WB_CQI_64TBL_5QI1_CQI11 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21011'}
WB_CQI_64TBL_5QI1_CQI12 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21012'}
WB_CQI_64TBL_5QI1_CQI13 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21013'}
WB_CQI_64TBL_5QI1_CQI14 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21014'}
WB_CQI_64TBL_5QI1_CQI15 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21015'}

WB_CQI_256TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22000'}
WB_CQI_256TBL_5QI1_CQI1 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22001'}
WB_CQI_256TBL_5QI1_CQI2 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22002'}
WB_CQI_256TBL_5QI1_CQI3 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22003'}
WB_CQI_256TBL_5QI1_CQI4 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22004'}
WB_CQI_256TBL_5QI1_CQI5 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22005'}
WB_CQI_256TBL_5QI1_CQI6 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22006'}
WB_CQI_256TBL_5QI1_CQI7 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22007'}
WB_CQI_256TBL_5QI1_CQI8 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22008'}
WB_CQI_256TBL_5QI1_CQI9 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22009'}
WB_CQI_256TBL_5QI1_CQI10 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22010'}
WB_CQI_256TBL_5QI1_CQI11 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22011'}
WB_CQI_256TBL_5QI1_CQI12 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22012'}
WB_CQI_256TBL_5QI1_CQI13 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22013'}
WB_CQI_256TBL_5QI1_CQI14 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22014'}
WB_CQI_256TBL_5QI1_CQI15 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22015'}

WB_CQI_64TBL_5QI1_CQI = [
    WB_CQI_64TBL_5QI1_CQI0, WB_CQI_64TBL_5QI1_CQI1, WB_CQI_64TBL_5QI1_CQI2, WB_CQI_64TBL_5QI1_CQI3,
    WB_CQI_64TBL_5QI1_CQI4, WB_CQI_64TBL_5QI1_CQI5, WB_CQI_64TBL_5QI1_CQI6, WB_CQI_64TBL_5QI1_CQI7,
    WB_CQI_64TBL_5QI1_CQI8, WB_CQI_64TBL_5QI1_CQI9, WB_CQI_64TBL_5QI1_CQI10, WB_CQI_64TBL_5QI1_CQI1,
    WB_CQI_64TBL_5QI1_CQI12, WB_CQI_64TBL_5QI1_CQI13, WB_CQI_64TBL_5QI1_CQI14, WB_CQI_64TBL_5QI1_CQI15
]

WB_CQI_256TBL_5QI1_CQI = [
    WB_CQI_256TBL_5QI1_CQI0, WB_CQI_256TBL_5QI1_CQI1, WB_CQI_256TBL_5QI1_CQI2, WB_CQI_256TBL_5QI1_CQI3,
    WB_CQI_256TBL_5QI1_CQI4, WB_CQI_256TBL_5QI1_CQI5, WB_CQI_256TBL_5QI1_CQI6, WB_CQI_256TBL_5QI1_CQI7,
    WB_CQI_256TBL_5QI1_CQI8, WB_CQI_256TBL_5QI1_CQI9, WB_CQI_256TBL_5QI1_CQI10, WB_CQI_256TBL_5QI1_CQI11,
    WB_CQI_256TBL_5QI1_CQI12, WB_CQI_256TBL_5QI1_CQI13, WB_CQI_256TBL_5QI1_CQI14, WB_CQI_256TBL_5QI1_CQI15
]

NG_FLOW_REL_GNB_REDIRECT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09002'}
NG_FLOW_REL_GNB_REDIRECT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09502'}
NG_FLOW_REL_GNB_REDIRECT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00503'}

NG_FLOW_REL_GNB_RLF = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09003'}
NG_FLOW_REL_GNB_RLF_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09503'}
NG_FLOW_REL_GNB_RLF_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00504'}

PEAK_NUMBER_OF_UE_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09530'}
AVE_NUMBER_OF_UE_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09528'}
AVE_NUMBER_OF_UE_5QI1_DENOM = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09529'}

AMOUNT_OF_CELLS = 1
