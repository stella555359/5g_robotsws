from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Song Jiana'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jiana.song@nokia.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_enb_id = str(tl.enbs[0].instance_id)
_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_enb_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_LNBTSname = _MRBTSname+'/LNBTS-'+_enb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_LNCELLname = _LNBTSname+'/LNCEL-1'
_LNCELL1FDD = _LNCELLname+'/LNCEL_FDD-0'
_NRBTSDUname = _NRBTSname+'/NRDU-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname+'/NRCELLGRP-1'
_NRPRIOACC_1 = _NRBTSname+'/NRPRIOACC_PROFILE-1'
_SERVEDAMF = _NRBTSname+'/SERVEDAMF-1'

PATH_TO_SCF = ''

PARAMS_TO_MODIFY_CB0138571 = [
    dict(dist_name=_LNBTSname, parameter='actCoMp', value='fixedULCoMp'),
    dict(dist_name=_LNCELL1FDD, parameter='actDlMutedCell', value='false'),
]

PARAMS_TO_MODIFY_CB0138571_recover = [
    dict(dist_name=_LNBTSname, parameter='actCoMp', value='disabled'),
    dict(dist_name=_LNCELL1FDD, parameter='actDlMutedCell', value='false'),
]

PARAMS_TO_MODIFY_CB007564_01_1 = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n56'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_CB007564_01_1_recover = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n56'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Unlocked'),
]

PARAMS_TO_MODIFY_CB007564_05_1 = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n64'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Locked'),
]

PARAMS_TO_MODIFY_CB007564_05_1_recover = [
    dict(dist_name=_NRCELLname, parameter='cbraPreamblesPerSsb', value='n56'),
    dict(dist_name=_SERVEDAMF, parameter='administrativeState', value='Unlocked'),
]

PARAMETERS_TO_UPDATE_A01 = [
    dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
]

PARAMETERS_TO_UPDATE_A01_pre = [
    dict(value='10', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='0', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='EnhancedVoNR', dist_name=_NRCELLname, parameter='actGBRAdmissionControl'),
    dict(value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='emergencyCallFails'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    # dict(value='500', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    # dict(value='500', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value=[dict(nea1_128='9', nea2_128='3', nea3_128='3')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='9', nia2_128='3', nia3_128='3')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

PARAMETERS_TO_UPDATE_A01_pre_recover = [
    dict(value='550', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='10', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='off', dist_name=_NRCELLname, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='emergencyCallFails'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    # dict(value='500', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    # dict(value='500', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value=[dict(nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname, parameter='cipherPrefL'),
    dict(value=[dict(nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname, parameter='integrityProtPrefL')
]

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
    dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterRatHoSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEutranFreqBandFiltering'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8200_recover_B_011 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='false', dist_name=_NRBTSname, parameter='actEutranFreqBandFiltering'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
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
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA')
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

PARAM_8700_A_021 = [
    dict(value='on', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='3', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA')
]

PARAM_8700_recover_A_021 = [
    dict(value='off', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='550', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA')
]

PARAM_6112_A_13 = [
    dict(value='drb', dist_name=_NRBTSname, parameter='activityNotificationLevelSA'),
]

PARAM_6112_recover_A_13 = [
    dict(value='ue', dist_name=_NRBTSname, parameter='activityNotificationLevelSA'),
]

PARAM_8698_A_001 = [
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfUsersPerCell'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_A_001 = [
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfUsersPerCell'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_ADD_8698_C_004 = [
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
]
PARAM_8698_C_004 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='7', dist_name=_NRBTSDUnameGRPgNB1cell, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='false', dist_name=_NRCELLname, parameter='preferNsaPreemption'),
    dict(value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='10', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_DELETE_8698_C_004 = [
    dict(dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse')
]
PARAM_8698_recover_C_004 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    dict(value='false', dist_name=_NRBTSname, parameter='actScheUePooling'),
    dict(value='550', dist_name=_NRBTSDUnameGRPgNB1cell, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='true', dist_name=_NRCELLname, parameter='preferNsaPreemption'),
    dict(value='30', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='false', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

# _mcc = str(tl.core.mcc)
# _mnc = str(tl.core.mnc)
_Trunk_ho_path1 = f'BTS/{_NRBTSname}/NRCELL-1/NNGCC'
_Trunk_ho_path2 = f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ'
_Trunk_ho_path3 = f'BTS/{_NRBTSname}/NRCELL-1/NRRCC'
_Trunk_ho_path4 = f'BTS/{_NRBTSname}/NRCELL-3/NNGCC'
_Trunk_ho_path5 = f'BTS/{_NRBTSname}/NRCELL-3/NRPMQAP-1/NGCCQ'
_Trunk_ho_path6 = f'BTS/{_NRBTSname}/NRCELL-1/NDLSQ'
_Trunk_SA_path = f'BTS/{_NRBTSname}/NRCELL-1/RSACU'
_Trunk_RACH = f'BTS/{_NRBTSname}/NRCELL-1/NRACH'
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path1_348 = 'BTS/CELLS/NRCELL-400/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path2_348 = 'BTS/CELLS/NRCELL-400/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path4 = 'BTS/CELLS/NRCELL-3/NNGCC'
_ho_path4_348 = 'BTS/CELLS/NRCELL-700/NNGCC'
_ho_path4_383 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path5 = 'BTS/CELLS/NRCELL-3/NRPMQAP-1/NGCCQ'
_ho_path5_348 = 'BTS/CELLS/NRCELL-700/NRPMQAP-1/NGCCQ'
_ho_path5_383 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path6 = 'BTS/CELLS/NRCELL-1/NDLSQ'
_SA_path = 'BTS/CELLS/NRCELL-1/RSACU'
_RACH = 'BTS/CELLS/NRCELL-1/NRACH'


NG_FLOW_SETUP_FAIL_FALLBACK = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09519'}
NR_RRC_RELEASE_REDIR_VFB_LTE = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55124C02501'}

NG_FLOW_REL_GNB_UE_INACTIVITY = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09004'}
NG_FLOW_SETUP_FAIL_FALLBACK_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09519'}
NG_FLOW_SETUP_FAIL_FALLBACK_2_348 = {'gnb_id': 1, 'dic_path': _ho_path4_348, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_348 = {'gnb_id': 1, 'dic_path': _ho_path5_348, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2_348 = {'gnb_id': 1, 'dic_path': _ho_path4_348, 'counter_id': 'M55125C09519'}
NG_FLOW_SETUP_FAIL_FALLBACK_2_383 = {'gnb_id': 1, 'dic_path': _ho_path4_383, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP_2_383 = {'gnb_id': 1, 'dic_path': _ho_path5_383, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1_2_383 = {'gnb_id': 1, 'dic_path': _ho_path4_383, 'counter_id': 'M55125C09519'}

Trunk_NG_FLOW_SETUP_FAIL_WRONG_MSG = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09012'}
Trunk_NG_FLOW_STP_FAIL_WRG_MSG_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09523'}
Trunk_NG_FLOW_STP_FAIL_WRG_MSG_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C00512'}

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

NG_FLOW_STP_ATT_INC_HO_5QI1_3_348 = {'gnb_id': 2, 'dic_path': _ho_path1_348, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3_348 = {'gnb_id': 2, 'dic_path': _ho_path1_348, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3_348 = {'gnb_id': 2, 'dic_path': _ho_path2_348, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3_348 = {'gnb_id': 2, 'dic_path': _ho_path2_348, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}

NG_FLOW_REL_IRAT_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00516'}
NG_FLOW_REL_IRAT_SUC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09016'}

Trunk_NG_FLOW_REL_IRAT_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09509'}
Trunk_NG_FLOW_REL_IRAT_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C00516'}
Trunk_NG_FLOW_REL_IRAT_SUC_HO = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09016'}

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

Trunk_WB_CQI_256TBL_5QI1_CQI12 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path6, 'counter_id': 'M55301C22012'}
Trunk_WB_CQI_64TBL_5QI1_CQI12 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path6, 'counter_id': 'M55301C21012'}

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

Trunk_PEAK_NUMBER_OF_UE_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09530'}
Trunk_AVE_NUMBER_OF_UE_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09528'}
Trunk_AVE_NUMBER_OF_UE_5QI1_DENOM = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09529'}

SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _SA_path, 'counter_id': 'M55138C02001'}
NG_FLOW_SETUP_ATT_TOT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00001'}
NG_FLOW_SETUP_SUCC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00002'}
NG_FLOW_SETUP_FAIL_RRNA_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C02000'}
NG_FLOW_SETUP_ATT_TOT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08501'}
NG_FLOW_SETUP_SUCC = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C08502'}
NG_FLOW_SETUP_FAIL_RRNA = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C10501'}

Trunk_SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _Trunk_SA_path, 'counter_id': 'M55138C02001'}
Trunk_NG_FLOW_SETUP_ATT_TOT_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C00001'}
Trunk_NG_FLOW_SETUP_SUCC_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C00002'}
Trunk_NG_FLOW_SETUP_FAIL_RRNA_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C02000'}
Trunk_NG_FLOW_SETUP_ATT_TOT = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C08501'}
Trunk_NG_FLOW_SETUP_SUCC = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C08502'}
Trunk_NG_FLOW_SETUP_FAIL_RRNA = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C10501'}

AMOUNT_OF_CELLS = 1

# -------8232_A_021------ #
PARAM_8232_A_021 = [
    dict(
        value='true', dist_name=_NRCELLname, parameter='actPriorityAccess'),
    dict(
        value='0', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
]

PARAM_8232_A_021_ADD = [
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),
]

PARAM_8232_recover_A_021 = [
    dict(
        value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
]

PARAM_8232_delete_A_021 = [
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),
]

# -------8232_D_009------ #
D_009_Modify_Online = [

    dict(
        value='true', dist_name=_NRCELLname, parameter='actPriorityAccess'),
    dict(
        value='0', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
]

D_009_ADD_Para = [
    dict(
        value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),

]

PARAM_8232_recover_D_009 = [
    dict(
        value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
]

PARAM_8232_delete_D_009 = [
    dict(
        value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(
        value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForPa'),
]

# -------8232_counter------ #
counter_dic_path_mps_GNB1CELL1 = [
    'BTS/BTS/NRBTS-1342/NRDU-1/NRRCD',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/BTS/NRBTS-1342/NRDU-1/NRRCD',
]

Trunk_counter_dic_path_mps_GNB1CELL1 = [
    'BTS/{}/NRDU-1/NRRCD'.format(_NRBTSname),
    f'BTS/{_NRBTSname}/NRCELL-1/NRRCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NRRCC',
    'BTS/{}/NRDU-1/NRRCD'.format(_NRBTSname),
]

counter_id_mps = [
    'M55127C03003', 'M55124C09003', 'M55124C01015', 'M55127C00013'
]

Trunk_counter_dic_path_ICS_mps_GNB1CELL1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
]

counter_dic_path_ICS_mps_GNB1CELL1 = [
    'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC',
]

counter_id_ICS_mps = [
    'M55125C12502', 'M55125C12504'
]

# -------5GC00784-------- #
PARAMETERS_TO_UPDATE_A21_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actGBRAdmissionControl', 'value': 'EnhancedVoNR'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'arpPrioEmergencyCall', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '2'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '2'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A21_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A21_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'false'}
]

PARAM_784_recover_A21 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '550'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actGBRAdmissionControl', 'value': 'off'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '600'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '600'}
]

PARAMETERS_TO_UPDATE_COUNTER = [
    {'dist_name': '_MRBTSname/MNL-1/MNLENT-1/PMCADM-1', 'parameter': 'reportingIntervalPm', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrNGCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRRCC', 'value': '5min'},
    {'dist_name': '_NRBTSname/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '5min'}
]

PARAMETERS_TO_UPDATE_A11_preparation = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRMOPR_SA-1', 'parameter': 'emergencyCallFails', 'value': 'disabled'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actGBRAdmissionControl', 'value': 'EnhancedVoNR'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'arpPrioEmergencyCall', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '0'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '500'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '500'}
]

PARAMETERS_TO_UPDATE_A11_1 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '0'}
]

PARAMETERS_TO_UPDATE_A11_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRMOPR_SA-1', 'parameter': 'emergencyCallFails', 'value': 'redirection'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'}
]

PARAM_784_recover_A11 = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'emergencyCallFails', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRMOPR_SA-1', 'parameter': 'emergencyCallFails', 'value': 'disabled'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfNonGBRBearersSA', 'value': '550'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'maxNumOfGBRBearersSA', 'value': '10'},
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'numOfDrbsReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'numOfRadioResReservForEmergency', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'actEmergencyCall', 'value': 'true'},
    {'dist_name': '_NRBTSname', 'parameter': 'srbInactivityTimerSA', 'value': '600'},
    {'dist_name': '_NRBTSname', 'parameter': 'drbInactivityTimerSA', 'value': '600'}
]

counter_id_A11_1 = [
    'M55125C05509', 'M55125C05511', 'M55125C05512', 'M55125C03501', 'M55125C03503', 'M55125C03504', 'M55138C01001',
    'M55124C04002', 'M55124C01502'
]

counter_id_A11_0 = [
    'M55138C01002'
]

counter_dic_path_A11_1 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/RSACU',  'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC'
]

Trunk_counter_dic_path_A11_1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/RSACU', f'BTS/{_NRBTSname}/NRCELL-1/NRRCC', f'BTS/{_NRBTSname}/NRCELL-1/NRRCC'
]

counter_dic_path_A11_0 = [
    'BTS/CELLS/NRCELL-1/RSACU'
]

Trunk_counter_dic_path_A11_0 = [
    f'BTS/{_NRBTSname}/NRCELL-1/RSACU'
]

# -------5GC00784A01-------- #
counter_id_A01_should_be_1 = [
    'M55125C05505', 'M55125C05506', 'M55125C05513', 'M55125C05514'
]

counter_dic_path_A01_should_be_1 = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

Trunk_counter_dic_path_A01_should_be_1 = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC'
]

counter_id_A01_not_zero = [
    'M55125C02504', 'M55125C02505', 'M55149C01001', 'M55125C05509', 'M55125C05510'
]

counter_dic_path_A01_not_zero = [
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/BTS/NRBTS-1342/MCC-310_MNC-260/SST-1_SD-13714341/NSL',
    'BTS/CELLS/NRCELL-1/NNGCC', 'BTS/CELLS/NRCELL-1/NNGCC'
]

Trunk_counter_dic_path_A01_not_zero = [
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC',
    f'BTS/{_NRBTSname}/MCC-310/MNC-260/SST-1/SD-13714341/NSL',
    f'BTS/{_NRBTSname}/NRCELL-1/NNGCC', f'BTS/{_NRBTSname}/NRCELL-1/NNGCC'
]

# -------CB007564_C005-------- #
RA_CB_INIT_RESOLVED = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09006'}
RA_MSG3_RECEP_INIT = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09008'}

Trunk_RA_CB_INIT_RESOLVED = {'gnb_id': 1, 'dic_path': _Trunk_RACH, 'counter_id': 'M55306C09006'}
Trunk_RA_MSG3_RECEP_INIT = {'gnb_id': 1, 'dic_path': _Trunk_RACH, 'counter_id': 'M55306C09008'}

# -------CB007564_C001-------- #
DED_PREAMBL_SENT_CFRA_INIT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09021'}
INIT_MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09003'}
DED_PREAMBL_USED_CFRA_INIT = {'gnb_id': 1, 'dic_path': _RACH, 'counter_id': 'M55306C09000'}

Trunk_DED_PREAMBL_SENT_CFRA_INIT = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09021'}
Trunk_INIT_MSG2_ACK_CFRA = {'gnb_id': 1, 'dic_path': _Trunk_RACH, 'counter_id': 'M55306C09003'}
Trunk_DED_PREAMBL_USED_CFRA_INIT = {'gnb_id': 1, 'dic_path': _Trunk_RACH, 'counter_id': 'M55306C09000'}
