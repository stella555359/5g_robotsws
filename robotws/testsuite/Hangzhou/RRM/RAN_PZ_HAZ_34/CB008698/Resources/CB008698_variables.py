from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_NRBTSDUname = _NRBTSname+'/NRDU-1'
_NRCELLname2 = _NRBTSname2+'/NRCELL-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname+'/NRCELLGRP-0'
_NRBTSDUnameGRPgNB1cell2 = _NRBTSname+'/NRCELLGRP-1'
_NRRELLnamegnb1 = _NRCELL2name+'/NRREL-0'
_NRRELLnamegnb11 = _NRCELL2name+'/NRREL-1'
_NRRELLnamegnb2 = _NRCELLname2+'/NRREL-2'
_NRRELLnamegnb20 = _NRCELLname2+'/NRREL-1'
_NRDU = _NRBTSname+'/NRDU-1'
_LTEENB = _NRBTSname+'/LTEENB-0'
_LTEENB2 = _NRBTSname2+'/LTEENB-0'
_NRRELL2NRREDRT = _NRCELL2name+'/NRREDRT-0'
_NRRELL1NRREDRT = _NRCELLname+'/NRREDRT-1'
_SERVEDAMF2 = _NRBTSname+'/SERVEDAMF-2'
_SERVEDAMF1 = _NRBTSname+'/SERVEDAMF-1'

PATH_TO_SCF = ''

PARAM_8698_Sourcegnb2_B_005 = [
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Sourcegnb2_B_005 = [
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8698_Targetgnb1_B_005 = [
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Targetgnb1_B_005 = [
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_Sourcegnb2_B_012 = [
    dict(value='false', dist_name=_NRCELLname2, parameter='preferNsaPreemption'),
    dict(value='0', dist_name=_NRCELLname2, parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name=_NRCELLname2, parameter='allowEmergencyReservForTempUse'),
    dict(value='1', dist_name=_NRCELLname2, parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname2, parameter='tNgRelocExecDeltN'),
    dict(value='2000', dist_name=_NRBTSname2, parameter='tNgRelocCancelN'),
    dict(value='2000', dist_name=_NRBTSname2, parameter='tNgRelocOverallN'),
    dict(value='2000', dist_name=_NRBTSname2, parameter='tNgRelocPrepN'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELLnamegnb2, parameter='handoverAllowedSA'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELLnamegnb20, parameter='handoverAllowedSA'),
    dict(value=[dict(a3HysteresisSsbRsrp='1', a3OffsetSsbRsrp='1', a3TimeToTriggerSsbRsrp='ms128')],
         dist_name=_NRCELLname2, parameter='a3MeasSsbRsrp'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Sourcegnb2_B_012 = [
    dict(value='true', dist_name=_NRCELLname2, parameter='preferNsaPreemption'),
    dict(value='30', dist_name=_NRCELLname2, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELLname2, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELLname2, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='disabled', dist_name=_NRBTSname2, parameter='actIntraNrNgHo'),
    dict(value='allowed', dist_name=_NRRELLnamegnb2, parameter='handoverAllowedSA'),
    dict(value='allowed', dist_name=_NRRELLnamegnb20, parameter='handoverAllowedSA'),
    dict(value=[dict(a3HysteresisSsbRsrp='1', a3OffsetSsbRsrp='1', a3TimeToTriggerSsbRsrp='ms128')],
         dist_name=_NRCELLname2, parameter='a3MeasSsbRsrp'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8698_Targetgnb1_B_012 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='preferNsaPreemption'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='1', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='1', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='1', dist_name=_NRBTSDUnameGRPgNB1cell2, parameter='maxNumOfRrcCGRPSA'),
    dict(value='XnHoNotAllowed', dist_name=_NRRELLnamegnb11, parameter='handoverAllowedSA'),
    dict(value='sourceAndTarget', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='3000', dist_name=_NRBTSname, parameter='tNgRelocExecDeltN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocCancelN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocOverallN'),
    dict(value='2000', dist_name=_NRBTSname, parameter='tNgRelocPrepN'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Targetgnb1_B_012 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='preferNsaPreemption'),
    dict(value='30', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='275', dist_name=_NRBTSDUnameGRPgNB1cell2, parameter='maxNumOfRrcCGRPSA'),
    dict(value='allowed', dist_name=_NRRELLnamegnb11, parameter='handoverAllowedSA'),
    dict(value='disabled', dist_name=_NRBTSname, parameter='actIntraNrNgHo'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_ADD_8698_A_004_for_precondition = [
    dict(value='1350', dist_name=_NRRELL2NRREDRT, parameter='redirFreqEutra'),
]

PARAM_DELETE_8698_A_004 = [
    dict(dist_name=_NRRELL2NRREDRT, parameter='redirFreqNr'),
    dict(dist_name=_NRRELL2NRREDRT, parameter='redirSsbScs'),
    dict(dist_name=_NRRELL2NRREDRT, parameter='redirSsbSmtcDuration'),
    dict(dist_name=_NRRELL2NRREDRT, parameter='redirSsbSmtcOffset'),
    dict(dist_name=_NRRELL2NRREDRT, parameter='redirSsbSmtcPeriodicity')
]

PARAM_8698_A_004 = [
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='eutra', dist_name=_NRRELL2NRREDRT, parameter='redirRat'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='none', dist_name=_NRCELL2name, parameter='a2MeashoEnabledSA'),
    dict(value='oneSixteenthT', dist_name=_NRCELL2name, parameter='numOfPagingFrames'),
    # dict(value='oneT', dist_name=_NRCELL2name, parameter='numOfPagingFrames'),
    # dict(value='0', dist_name=_NRCELL2name, parameter='pagingOffset'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_A_004_2 = [
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_DELETE_8698_A_004_for_postconditions = [
    dict(dist_name=_NRRELL2NRREDRT, parameter='redirFreqEutra'),
]

PARAM_ADD_8698_A_004 = [
    dict(value='522030', dist_name=_NRRELL2NRREDRT, parameter='redirFreqNr'),
    dict(value='30 KHz', dist_name=_NRRELL2NRREDRT, parameter='redirSsbScs'),
    dict(value='sf5', dist_name=_NRRELL2NRREDRT, parameter='redirSsbSmtcDuration'),
    dict(value='0', dist_name=_NRRELL2NRREDRT, parameter='redirSsbSmtcOffset'),
    dict(value='sf20', dist_name=_NRRELL2NRREDRT, parameter='redirSsbSmtcPeriodicity'),
]

PARAM_8698_recover_A_004 = [
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value='disabled', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='viaRRCSetup', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='nr', dist_name=_NRRELL2NRREDRT, parameter='redirRat'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='rsrp', dist_name=_NRCELL2name, parameter='a2MeashoEnabledSA'),
    dict(value='quaterT', dist_name=_NRCELL2name, parameter='numOfPagingFrames'),
    # dict(value='1', dist_name=_NRCELL2name, parameter='pagingOffset'),
    dict(value='60', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_A_004_2 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_8698_A_006 = [
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_A_006_2 = [
    dict(value='locked', dist_name=_LTEENB2, parameter='x2LinkLock'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_8698_recover_A_006 = [
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_A_006_2 = [
    dict(value='unlocked', dist_name=_LTEENB2, parameter='x2LinkLock'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_ADD_8698_C_003 = [
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRDU, parameter='numOfDrbsReservForTempUse'),
]

PARAM_8698_C_003 = [
    dict(value='2', dist_name=_NRBTSname, parameter='numOfDRBReservedPerEmergency'),
    dict(value='10', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='3', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='7', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='10', dist_name=_NRDU, parameter='numOfDrbsReservForEmergency'),
    dict(value='none', dist_name=_NRCELL2name, parameter='a2MeashoEnabledSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_C_003_2 = [
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
]

PARAM_ADD_8698_C_003_2 = [
    dict(value='75', dist_name=_NRCELL2name, parameter='maxGBRTrafficLimit'),
]

PARAM_8698_C_003_GNB2 = [
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_DELETE_8698_C_003 = [
    dict(dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(dist_name=_NRDU, parameter='numOfDrbsReservForTempUse')
]

PARAM_8698_recover_C_003 = [
    dict(value='2', dist_name=_NRBTSname, parameter='numOfDRBReservedPerEmergency'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='550', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRDU, parameter='numOfDrbsReservForEmergency'),
    dict(value='rsrp', dist_name=_NRCELL2name, parameter='a2MeashoEnabledSA'),
    dict(value='60', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_C_003_2 = [
    dict(value='off', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
]

PARAM_DELETE_8698_C_003_2 = [
    dict(dist_name=_NRCELL2name, parameter='maxGBRTrafficLimit'),
]

PARAM_8698_recover_C_003_GNB2 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_ADD_8698_C_005 = [
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRDU, parameter='numOfDrbsReservForTempUse'),
]

PARAM_8698_C_005 = [
    # dict(value='true', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    # dict(value='true', dist_name=_NRBTSname, parameter='actScheUePooling'),
    # dict(value='2', dist_name=_NRBTSname, parameter='numOfDRBReservedPerEmergency'),
    # dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    # dict(value='0', dist_name=_NRDU, parameter='numOfDrbsReservForEmergency'),
    dict(value='30', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    # dict(value='on', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='7', dist_name=_NRBTSDUnameGRPgNB1cell, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='7', dist_name=_NRBTSDUnameGRPgNB1cell2, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='none', dist_name=_NRCELL2name, parameter='a2MeashoEnabledSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_C_005_GNB2 = [
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_DELETE_8698_C_005 = [
    dict(dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(dist_name=_NRDU, parameter='numOfDrbsReservForTempUse')
]

PARAM_8698_recover_C_005 = [
    # dict(value='false', dist_name=_NRBTSname, parameter='actConnRrcPooling'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actScheUePooling'),
    # dict(value='2', dist_name=_NRBTSname, parameter='numOfDRBReservedPerEmergency'),
    # dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    # dict(value='0', dist_name=_NRDU, parameter='numOfDrbsReservForEmergency'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    # dict(value='off', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='550', dist_name=_NRBTSDUnameGRPgNB1cell, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='550', dist_name=_NRBTSDUnameGRPgNB1cell2, parameter='maxNumOfNonGBRBearersCGRPSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='viaRRCSetup', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='rsrp', dist_name=_NRCELL2name, parameter='a2MeashoEnabledSA'),
    dict(value='60', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_C_005_GNB2 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
]

PARAM_ADD_8698_F_006 = [
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRDU, parameter='numOfDrbsReservForTempUse'),
]

PARAM_8698_F_006_2 = [
    dict(value='0', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA')
]

PARAM_8698_F_006 = [
    dict(value='on', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='on', dist_name=_NRCELL2name, parameter='actARPBasedAC'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='3', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='550', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value='true', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='2', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='2', dist_name=_NRBTSname, parameter='numOfDRBReservedPerEmergency'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_DELETE_8698_F_006 = [
    dict(dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(dist_name=_NRDU, parameter='numOfDrbsReservForTempUse')
]
PARAM_8698_recover_F_006 = [
    dict(value='off', dist_name=_NRCELLname, parameter='actARPBasedAC'),
    dict(value='off', dist_name=_NRCELL2name, parameter='actARPBasedAC'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='550', dist_name=_NRCELLname, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='550', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='false', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='2', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='2', dist_name=_NRBTSname, parameter='numOfDRBReservedPerEmergency'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_Targetgnb1_D_001_maxNumOfUsersPerNRCell = [
    dict(value='Unlocked', dist_name=_SERVEDAMF2, parameter='administrativeState'),
    dict(value='Locked', dist_name=_SERVEDAMF1, parameter='administrativeState'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
    # dict(value='3', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='GBRService', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='addNumOfGBRBearers'),
    dict(value='10', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfSCellAlloc'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersPerNRCell = [
    dict(value='Unlocked', dist_name=_SERVEDAMF1, parameter='administrativeState'),
    dict(value='Locked', dist_name=_SERVEDAMF2, parameter='administrativeState'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    # dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='550', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='addNumOfGBRBearers'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerNRCell'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfSCellAlloc'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_Targetgnb1_D_001_maxNumOfUsersPerNRCell_382 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
    # dict(value='3', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='GBRService', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='addNumOfGBRBearers'),
    dict(value='10', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfSCellAlloc'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersPerNRCell_382 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    # dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='550', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='addNumOfGBRBearers'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    # dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerNRCell'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfSCellAlloc'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_Targetgnb1_D_001_maxNumOfUsersNRCell = [
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
    # dict(value='3', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='2', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='GBRService', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='addNumOfGBRBearers'),
    dict(value='10', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    # dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    dict(value='1', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_Targetgnb1_D_001_maxNumOfUsersNRCell = [
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    # dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    dict(value='550', dist_name=_NRCELL2name, parameter='maxNumOfNonGBRBearersSA'),
    dict(value='10', dist_name=_NRCELL2name, parameter='maxNumOfGBRBearersSA'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actNonVoNRGbrService'),
    dict(value='off', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='0', dist_name=_NRCELL2name, parameter='addNumOfGBRBearers'),
    dict(value='2', dist_name=_NRCELL2name, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELL2name, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELL2name, parameter='numOfRadioResReservForEmergency'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfRrcSA'),
    # dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersNRCell'),
    dict(value='250', dist_name=_NRCELL2name, parameter='maxNumOfCaUsersNRCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfUsersPerCell'),
    dict(value='275', dist_name=_NRCELL2name, parameter='maxNumOfNrDcSnUsers'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_Sourcegnb2_D_001 = [
    dict(value=[dict(nea0='9', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='true', dist_name=_NRBTSname, parameter='actMobilityProfile'),
]

PARAM_8698_recover_Sourcegnb2_D_001 = [
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL'),
    dict(value='false', dist_name=_NRBTSname, parameter='actMobilityProfile'),
]

PARAM_8698_gnb1_D_010 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='20', dist_name=_NRBTSname, parameter='maxNumOfPreemptions'),
    dict(value='120', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForTempUse'),
    dict(value='3', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(value='1', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='GBRService', dist_name=_NRCELLname, parameter='actGBRAdmissionControl'),
    dict(value='true', dist_name=_NRCELLname, parameter='actNonVoNRGbrService'),
    dict(value='0', dist_name=_NRCELLname, parameter='addNumOfGBRBearers'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value='1', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='10', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='1', dist_name=_NRRELL1NRREDRT, parameter='redirPrio'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8698_recover_gnb1_D_010 = [
    dict(value='false', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='false', dist_name=_NRBTSname, parameter='actDrbPreemption'),
    dict(value='275', dist_name=_NRCELLname, parameter='maxNumOfRrcSA'),
    dict(value='10', dist_name=_NRCELLname, parameter='maxNumOfGBRBearersSA'),
    dict(value='off', dist_name=_NRCELLname, parameter='actGBRAdmissionControl'),
    dict(value='false', dist_name=_NRCELLname, parameter='actNonVoNRGbrService'),
    dict(value='0', dist_name=_NRCELLname, parameter='addNumOfGBRBearers'),
    dict(value='2', dist_name=_NRCELLname, parameter='numOfRadioResReservForTempUse'),
    dict(value='false', dist_name=_NRCELLname, parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name=_NRCELLname, parameter='numOfRadioResReservForEmergency'),
    dict(value='10', dist_name=_NRBTSDUname, parameter='numOfDrbsReservForEmergency'),
    dict(value='3', dist_name=_NRRELL1NRREDRT, parameter='redirPrio'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

# _mcc = str(tl.core.mcc)
# _mnc = str(tl.core.mnc)
_Trunk_ho_path1 = f'BTS/{_NRBTSname}/NRCELL-1/NNGCC'
_Trunk_ho_path2 = f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/NGCCQ'
_Trunk_ho_path3 = f'BTS/{_NRBTSname}/NRCELL-1/NX2CC'
_Trunk_ho_path4 = f'BTS/{_NRBTSname}/NRCELL-1/NRPMQAP-1/X2CCQ'
_Trunk_ho_path5 = f'BTS/{_NRBTSname}/NRCELL-1/RSADU'
_Trunk_ho_path6 = f'BTS/{_NRBTSname}/NRCELL-1/RSACU'
_Trunk_ho_path12 = f'BTS/{_NRBTSname}/NRCELL-2/NNGCC'
_Trunk_ho_path22 = f'BTS/{_NRBTSname}/NRCELL-2/NRPMQAP-1/NGCCQ'
_Trunk_ho_path32 = f'BTS/{_NRBTSname}/NRCELL-2/NX2CC'
_Trunk_ho_path42 = f'BTS/{_NRBTSname}/NRCELL-2/NRPMQAP-1/X2CCQ'
_Trunk_ho_path52 = f'BTS/{_NRBTSname}/NRCELL-2/RSADU'
_Trunk_ho_path53 = f'BTS/{_NRBTSname}/NRCELL-2/RSACU'
_Trunk_ho_path54 = f'BTS/{_NRBTSname}/NRCELL-2/NRRCC'
_Trunk_ho_path55 = f'BTS/{_NRBTSname}/NRCELL-1/NRRCC'
_Trunk_ho_path56 = f'BTS/{_NRBTSname2}/NRCELL-1/NRMOP'
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NX2CC'
_ho_path4 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/X2CCQ'
_ho_path5 = 'BTS/CELLS/NRCELL-1/RSADU'
_ho_path6 = 'BTS/CELLS/NRCELL-1/RSACU'
_ho_path12 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path22 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path32 = 'BTS/CELLS/NRCELL-2/NX2CC'
_ho_path42 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/X2CCQ'
_ho_path52 = 'BTS/CELLS/NRCELL-2/RSADU'
_ho_path53 = 'BTS/CELLS/NRCELL-2/RSACU'
_ho_path54 = 'BTS/CELLS/NRCELL-2/NRRCC'
_ho_path55 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path56 = 'BTS/CELLS/NRCELL-1/NRMOP'

SA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11501'}
SA_UE_CTX_REL_PREEM_REDIR = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11502'}
NG_FLOW_REL_GNB_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11504'}
NG_FLOW_REL_GNB_PREEM_RE = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11506'}
NG_FLOW_REL_GNB_PREEM_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11505'}
NG_FLOW_REL_GNB_PREEM_RE_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11507'}
NG_FLOW_REL_GNB_PREEM_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C01001'}
NG_FLOW_REL_GNB_PREEM_RE_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C01002'}

Trunk_SA_UE_CTX_REL_PREEM_REDIR = {'gnb_id': 1, 'dic_path': _Trunk_ho_path12, 'counter_id': 'M55125C11502'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE = {'gnb_id': 1, 'dic_path': _Trunk_ho_path12, 'counter_id': 'M55125C11506'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path12, 'counter_id': 'M55125C11507'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path22, 'counter_id': 'M55163C01002'}
Trunk_NRRCC_RRC_RELEASE_REDIR_NR = {'gnb_id': 1, 'dic_path': _Trunk_ho_path54, 'counter_id': 'M55124C01501'}
Trunk_NRMOP_SA_PROFILE_SELECTED_01 = {'gnb_id': 2, 'dic_path': _Trunk_ho_path56, 'counter_id': 'M55157C00033'}

Trunk_SA_UE_CTX_REL_PREEM_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11501'}
Trunk_SA_UE_CTX_REL_PREEM_REDIR_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11502'}
Trunk_NG_FLOW_REL_GNB_PREEM_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11504'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11506'}
Trunk_NG_FLOW_REL_GNB_PREEM_5QI1_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11505'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11507'}
Trunk_NG_FLOW_REL_GNB_PREEM_PMQAP_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C01001'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C01002'}
Trunk_PEAK_NUM_UE_CTX_TEMP_POOL_1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path5, 'counter_id': 'M55139C05001'}
Trunk_NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09013'}
Trunk_NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09014'}
Trunk_NG_FLOW_REL_IANR_SUC_HO = {'gnb_id': 1, 'dic_path': _Trunk_ho_path12, 'counter_id': 'M55125C09015'}
Trunk_NG_FLOW_REL_IANR_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path12, 'counter_id': 'M55125C09508'}
Trunk_NG_FLOW_REL_PART_HO = {'gnb_id': 1, 'dic_path': _Trunk_ho_path12, 'counter_id': 'M55125C10504'}
Trunk_NG_FLOW_REL_IANR_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path22, 'counter_id': 'M55163C00515'}
Trunk_NG_FLOW_REL_PART_HO_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path22, 'counter_id': 'M55163C02001'}
Trunk_SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _Trunk_ho_path6, 'counter_id': 'M55138C02001'}
Trunk_NG_FLOW_STP_ATT_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09524'}
Trunk_NG_FLOW_STP_SUC_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C09525'}
Trunk_NG_FLOW_STP_ATT_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C00513'}
Trunk_NG_FLOW_STP_SUC_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C00514'}

SA_UE_CTX_REL_PREEM_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11501'}
SA_UE_CTX_REL_PREEM_REDIR_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11502'}
NG_FLOW_REL_GNB_PREEM_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11504'}
NG_FLOW_REL_GNB_PREEM_RE_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11506'}
NG_FLOW_REL_GNB_PREEM_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11505'}
NG_FLOW_REL_GNB_PREEM_RE_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11507'}
NG_FLOW_REL_GNB_PREEM_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C01001'}
NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C01002'}

NSA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11503'}
NX2CC_RAB_REL_PREEM_SGNB = {'gnb_id': 1, 'dic_path': _ho_path32, 'counter_id': 'M55112C07001'}
NX2CC_RAB_REL_PREEM_SGNB_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path42, 'counter_id': 'M55162C00501'}

PEAK_NUM_UE_CTX_TEMP_POOL = {'gnb_id': 1, 'dic_path': _ho_path52, 'counter_id': 'M55139C05001'}
PEAK_NUM_UE_CTX_TEMP_POOL_1 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55139C05001'}

PEAK_NUM_UE_CTX_TEMP_POOL = {'gnb_id': 1, 'dic_path': _ho_path52, 'counter_id': 'M55139C05001'}
NSA_UE_CTX_REL_PREEM = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C11503'}
NX2CC_RAB_REL_PREEM_SGNB = {'gnb_id': 1, 'dic_path': _ho_path32, 'counter_id': 'M55112C07001'}
NX2CC_RAB_REL_PREEM_SGNB_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path42, 'counter_id': 'M55162C00501'}
SGNB_SA_CU_HO_ADMISSION_REQ = {'gnb_id': 1, 'dic_path': _ho_path53, 'counter_id': 'M55138C00023'}

NRRCC_RRC_RELEASE_REDIR_NR = {'gnb_id': 1, 'dic_path': _ho_path54, 'counter_id': 'M55124C01501'}

Trunk_SA_UE_CTX_REL_PREEM_REDIR_D010 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11502'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_D010 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11506'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path1, 'counter_id': 'M55125C11507'}
Trunk_NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path2, 'counter_id': 'M55163C01002'}
Trunk_NRRCC_RRC_RELEASE_REDIR_NR_D010 = {'gnb_id': 1, 'dic_path': _Trunk_ho_path55, 'counter_id': 'M55124C01501'}

SA_UE_CTX_REL_PREEM_REDIR_D010 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11502'}
NG_FLOW_REL_GNB_PREEM_RE_D010 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11506'}
NG_FLOW_REL_GNB_PREEM_RE_5QI1_D010 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C11507'}
NG_FLOW_REL_GNB_PREEM_RE_PMQAP_D010 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C01002'}
NRRCC_RRC_RELEASE_REDIR_NR_D010 = {'gnb_id': 1, 'dic_path': _ho_path55, 'counter_id': 'M55124C01501'}

NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09014'}
NG_FLOW_REL_IANR_SUC_HO = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C09015'}
NG_FLOW_REL_IANR_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C09508'}
NG_FLOW_REL_PART_HO = {'gnb_id': 1, 'dic_path': _ho_path12, 'counter_id': 'M55125C10504'}
NG_FLOW_REL_IANR_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C00515'}
NG_FLOW_REL_PART_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path22, 'counter_id': 'M55163C02001'}
SA_PART_ADMISSION = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55138C02001'}
NG_FLOW_STP_ATT_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}

# 710###
NRMOP_SA_PROFILE_SELECTED_01 = {'gnb_id': 2, 'dic_path': _ho_path56, 'counter_id': 'M55157C00033'}

CB008698_F_006_kpi_names_value_cell1_zero = [
    "SA_UE_CTX_REL_PREEM_1",
    "NG_FLOW_REL_GNB_PREEM_1",
    "NG_FLOW_REL_GNB_PREEM_5QI1_1",
    "NG_FLOW_REL_GNB_PREEM_RE_5QI1_1",
    "NG_FLOW_REL_GNB_PREEM_PMQAP_1",
    "PEAK_NUM_UE_CTX_TEMP_POOL_1",
    "NG_FLOW_REL_IANR_SUC_HO_5QI1",
    "NG_FLOW_STP_ATT_INC_HO_5QI1",
    "NG_FLOW_STP_SUC_INC_HO_5QI1",
]
CB008698_F_006_kpi_names_value_cell1_one = [
    "SA_UE_CTX_REL_PREEM_REDIR_1",
    "SA_PART_ADMISSION",
]
CB008698_F_006_kpi_names_value_cell1_two = [
    "NG_FLOW_REL_GNB_PREEM_RE_1",
    "NG_FLOW_REL_GNB_PREEM_RE_PMQAP_1",
]
CB008698_F_006_kpi_names_value_cell1_three = [
    "NG_FLOW_STP_SUC_INC_HO",
    "NG_FLOW_STP_SUC_INC_HO_PMQAP",
]
CB008698_F_006_kpi_names_value_cell1_five = [
    "NG_FLOW_STP_ATT_INC_HO",
    "NG_FLOW_STP_ATT_INC_HO_PMQAP",
]
CB008698_F_006_kpi_names_value_cell2_zero = [
    "NG_FLOW_REL_IANR_SUC_HO_5QI1",
]
CB008698_F_006_kpi_names_value_cell2_two = [
    "NG_FLOW_REL_PART_HO",
    "NG_FLOW_REL_PART_HO_PMQAP",
]
CB008698_F_006_kpi_names_value_cell2_three = [
    "NG_FLOW_REL_IANR_SUC_HO",
    "NG_FLOW_REL_IANR_SUC_HO_PMQAP",
]

AMOUNT_OF_CELLS = 1
