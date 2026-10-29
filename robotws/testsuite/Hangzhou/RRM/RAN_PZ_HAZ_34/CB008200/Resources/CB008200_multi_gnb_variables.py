from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Shi Ming'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'ming.shi@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_enb_id = str(tl.gnbs[0].instance_id + 10)
_MRBTSname = 'MRBTS-'+_gnb_id
_MRBTSname2 = 'MRBTS-'+_gnb_id2
_LNBTSname = _MRBTSname+'/LNBTS-'+_enb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb_id2
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-3'
_NRCELLname2 = _NRBTSname2+'/NRCELL-1'
_LTECELLname = _LNBTSname+'/LNCEL-4'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_NRPMRNL_1 = _NRBTSname+'/NRPMRNL-1'
_NRPMRNL2_1 = _NRBTSname2+'/NRPMRNL-1'

PATH_TO_SCF = ''


PARAM_8200_B_002 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='deactivated', dist_name=_NRCELL2name, parameter='actDataForwardingForVoNr'),
    dict(value='off', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='10', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_B_002_383 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='deactivated', dist_name=_NRCELL2name, parameter='actDataForwardingForVoNr'),
    dict(value='off', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actVoipPacketAggr'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actMaxInitDeltaCqiClampVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actPriorityAccess'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actTargetBlerVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actUlMinTbsForVoNR'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actVoNRIncCodingGain'),
    dict(value='Disabled', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='false', dist_name=_NRBTSname, parameter='actInterGnbRREPreparedCell'),
    dict(value='false', dist_name=_NRBTSname, parameter='actNormVCFallbackEnh'),
    dict(value='10', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='10', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_DELETE_8200_B_002 = [
    dict(dist_name=_NRCELL2name, parameter='n310VoNR'),
    dict(dist_name=_NRCELL2name, parameter='t310VoNR')
]
PARAM_8200_B_002_WA = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState')
]
PARAM_8200_recover_B_002 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='Xn_and_NG_activated', dist_name=_NRCELL2name, parameter='actDataForwardingForVoNr'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='sameGNB', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_recover_B_002_383 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRedirect'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='redirection', dist_name=_NRCELL2name, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='Xn_and_NG_activated', dist_name=_NRCELL2name, parameter='actDataForwardingForVoNr'),
    dict(value='EnhancedVoNR', dist_name=_NRCELL2name, parameter='actGBRAdmissionControl'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoipPacketAggr'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actMaxInitDeltaCqiClampVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPriorityAccess'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actTargetBlerVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlMinTbsForVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNRIncCodingGain'),
    dict(value='Enabled_VoNr', dist_name=_NRCELL2name, parameter='actUlSlotAgg'),
    dict(value='true', dist_name=_NRBTSname, parameter='actEmergencyFallback'),
    dict(value='true', dist_name=_NRBTSname, parameter='actInterGnbRREPreparedCell'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNormVCFallbackEnh'),
    dict(value='600', dist_name=_NRBTSname, parameter='srbInactivityTimerSA'),
    dict(value='600', dist_name=_NRBTSname, parameter='drbInactivityTimerSA'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRohc'),
    dict(value='sameGNB', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='redirection', dist_name=_NRCELLname, parameter='voiceFBMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_ADD_8200_B_002 = [
    dict(value='n20', dist_name=_NRCELL2name, parameter='n310VoNR'),
    dict(value='2000ms', dist_name=_NRCELL2name, parameter='t310VoNR')
]

PARAM_8200_B_009 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_recover_B_009 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]

PARAM_8200_B_010_1 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_recover_B_010_1 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_B_010_2 = [
    dict(value='false', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actIntraFreqHoSA'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actSaUeBasedAnrNr'),
    dict(value='false', dist_name=_NRBTSname2, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value='disabled', dist_name=_NRPMRNL2_1, parameter='miNrRelReportCu'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]
PARAM_8200_recover_B_010_2 = [
    dict(value='true', dist_name=_NRBTSname2, parameter='actInterFreqHoSA'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actIntraFreqHoSA'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actSaUeBasedAnrNr'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actSaUeBasedInterFreqAnrNr'),
    dict(value='5min', dist_name=_NRPMRNL2_1, parameter='miNrRelReportCu'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname2,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname2,
         parameter='integrityProtPrefL')
]

PARAM_8200_B_012 = [
    dict(value='locked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='sameGNB', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='9', nia2_128='0', nia3_128='0')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_recover_B_012 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='deactivated', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]
PARAM_8200_recover_B_012_383 = [
    dict(value='unlocked', dist_name=_LTECELLname, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELLname, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELLname, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRBTSname, parameter='actNrpmqapProfiles'),
    dict(value='true', dist_name=_NRCELLname, parameter='actEmergencyCall'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEnhancedVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actCDrxVoNR'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actEmergencyCall'),
    dict(value='sameGNB', dist_name=_NRBTSname, parameter='rrcReestabTypeSA'),
    dict(value=[dict(nea0='1', nea1_128='3', nea2_128='4', nea3_128='2')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    dict(value=[dict(nia0='0', nia1_128='3', nia2_128='4', nia3_128='2')], dist_name=_NRBTSname,
         parameter='integrityProtPrefL')
]


_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_ho_path1 = 'BTS/CELLS/NRCELL-1/NNGCC'
_ho_path2 = 'BTS/CELLS/NRCELL-1/NRPMQAP-1/NGCCQ'
_ho_path3 = 'BTS/CELLS/NRCELL-1/NRRCC'
_ho_path4 = 'BTS/CELLS/NRCELL-2/NNGCC'
_ho_path5 = 'BTS/CELLS/NRCELL-2/NRPMQAP-1/NGCCQ'
_ho_path6 = 'BTS/CELLS/NRCELL-1/NDLSQ'
NG_FLOW_SETUP_FAIL_FALLBACK = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09008'}
NG_FLOW_STP_FAIL_FALBACK_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00501'}
NG_FLOW_STP_FAIL_FALBACK_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09519'}
NR_RRC_RELEASE_REDIR_VFB_LTE = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55124C02501'}

NG_FLOW_REL_GNB_UE_INACTIVITY = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09004'}

NG_FLOW_SETUP_FAIL_WRONG_MSG = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09012'}
NG_FLOW_STP_FAIL_WRG_MSG_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09523'}
NG_FLOW_STP_FAIL_WRG_MSG_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00512'}

NG_FLOW_SETUP_FAIL_UNSPECIFIED = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09011'}
NG_FLOW_SETUP_FAIL_UNSPC_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00511'}
NG_FLOW_SETUP_FAIL_UNSPC_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09522'}

NG_FLOW_STP_ATT_INC_HO_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_1 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_2 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_2 = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55163C00514'}
NG_FLOW_STP_ATT_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09013'}
NG_FLOW_STP_SUC_INC_HO = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09014'}

NG_FLOW_STP_ATT_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09524'}
NG_FLOW_STP_SUC_INC_HO_5QI1_3 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09525'}
NG_FLOW_STP_ATT_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00513'}
NG_FLOW_STP_SUC_INC_HO_PMQAP_3 = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00514'}

NG_FLOW_REL_IRAT_SUC_HO_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09509'}
NG_FLOW_REL_IRAT_SUC_HO_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00516'}

NG_FLOW_STP_ATT_RES_IADU_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00530'}
NG_FLOW_STP_ATT_RES_IADU_5QI1 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09531'}
NG_FLOW_STP_SUC_RES_IADU_PMQAP = {'gnb_id': 2, 'dic_path': _ho_path2, 'counter_id': 'M55163C00531'}
NG_FLOW_STP_SUC_RES_IADU_5QI1 = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09532'}
NG_FLOW_STP_ATT_REEST_IADU = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09023'}
NG_FLOW_STP_SUC_REEST_IADU = {'gnb_id': 2, 'dic_path': _ho_path1, 'counter_id': 'M55125C09024'}

NG_FLOW_SETUP_ATT_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09517'}
NG_FLOW_SETUP_SUCC_TOT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09518'}
NG_FLOW_REL_AMF_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09512'}
NG_FLOW_REL_AMF_NORMAL_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00519'}
NG_FLOW_REL_NORMAL_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09514'}
NG_FLOW_REL_AMF_NORMAL = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09019'}

WB_CQI_64TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C21000'}
WB_CQI_256TBL_5QI1_CQI0 = {'gnb_id': 1, 'dic_path': _ho_path6, 'counter_id': 'M55301C22000'}

NG_FLOW_REL_GNB_REDIRECT = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09002'}
NG_FLOW_REL_GNB_REDIRECT_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09502'}
NG_FLOW_REL_GNB_REDIRECT_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00503'}

NG_FLOW_REL_GNB_RLF = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09003'}
NG_FLOW_REL_GNB_RLF_5QI1 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55125C09503'}
NG_FLOW_REL_GNB_RLF_PMQAP = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55163C00504'}

AMOUNT_OF_CELLS = 1
