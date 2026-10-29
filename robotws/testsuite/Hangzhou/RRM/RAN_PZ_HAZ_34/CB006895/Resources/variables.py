from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Jack Zeng'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jack.zeng@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_NRDRB_RLC_UM1name = _NRBTSname+'/NRDRB_RLC_UM-1'
_BBMOD2_name = _MRBTSname+'/EQM-1/APEQM-1/CABINET-1/BBMOD-2'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSgnb2name = 'MRBTS-'+_gnb2_id
_NRBTSgnb2name = _MRBTSgnb2name+'/NRBTS-'+_gnb2_id
_gnb2NRCELLname = _NRBTSgnb2name+'/NRCELL-1'
_gnb2NRDRB15name = _NRBTSgnb2name+'/NRDRB-15'
_gnb2NRDRB_RLC_UM1name = _NRBTSgnb2name+'/NRDRB_RLC_UM-1'

PATH_TO_SCF = ''

PARAM_6112_A_009_0 = [
    dict(new_value='slots80', dist_name=_NRCELLname,
         filter_param='Scheduling request periodicity', abbr='srPeriodicity')
]

PARAM_6112_A_009 = [
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate VoIP packet aggregation', abbr='actVoipPacketAggr')
]

PARAM_6112_A_009_1 = [
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate VoIP packet aggregation', abbr='actVoipPacketAggr')
]

PARAM_6112_A_010 = [
    dict(new_value='100ms', dist_name=_NRDRB15name,
         filter_param='Discard timer', abbr='discardTimer'),
    dict(new_value='slots40', dist_name=_NRCELLname,
         filter_param='CSI reporting periodicity', abbr='csiReportPeriodicity')
]

PARAM_6112_A_011 = [
    dict(new_value='slots80', dist_name=_NRCELLname,
         filter_param='CSI reporting periodicity', abbr='csiReportPeriodicity'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate connected DRX', abbr='actCDrx'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate connected DRX VoNR', abbr='actCDrxVoNR'),
    dict(new_value='none', dist_name=_NRCELLname,
         filter_param='A2 Measurement Configuration for Handover Enabled SA',
         abbr='a2MeashoEnabledSA'),
    dict(new_value='20ms', dist_name=_NRDRB15name,
         filter_param='Discard timer', abbr='discardTimer'),
    dict(new_value='rlcUm6bitSN', dist_name=_NRDRB_RLC_UM1name,
         filter_param='RLC UM mode DRB SN length', abbr='rlcUMDrbSNLength'),
    dict(new_value='44', dist_name=_NRDRB15name,
         filter_param='DSCP', abbr='dscp')
]

PARAM_6112_A_011_1 = [
    dict(new_value='100ms', dist_name=_NRDRB15name,
         filter_param='Discard timer', abbr='discardTimer')
]


PARAM_6112_A_013 = [
    dict(new_value='40ms', dist_name=_NRCELLname,
         filter_param='CSI-RS Tracking Period', abbr='csirsTrackingPeriod'),
    dict(new_value='slots40', dist_name=_NRCELLname,
         filter_param='Scheduling request periodicity', abbr='srPeriodicity'),
    dict(new_value='50ms', dist_name=_NRCELLname,
         filter_param='Timer t310 for VoNR', abbr='t310VoNR'),
    dict(new_value='n1', dist_name=_NRCELLname,
         filter_param='Timer t310 for VoNR', abbr='n310VoNR'),
    dict(new_value='1000ms', dist_name=_NRBTSname,
         filter_param='RLF indication timer for DU for VoNR', abbr='tRLFindForDUVoNR'),
    dict(new_value='15', dist_name=_NRBTSname,
         filter_param='Stand alone UE 5QI1 DRB inactivity timer', abbr='drbInactivityTimerSA5qi1'),
    dict(new_value='15', dist_name=_NRBTSname,
         filter_param='Stand alone UE 5QI5 DRB inactivity timer', abbr='drbInactivityTimerSA5qi5'),
    dict(new_value='rlcUm6bitSN', dist_name=_NRDRB_RLC_UM1name,
         filter_param='RLC UM mode DRB SN length', abbr='rlcUMDrbSNLength'),
    dict(new_value='44', dist_name=_NRDRB15name,
         filter_param='DSCP', abbr='dscp')
]

PARAM_6112_A_014 = [
    dict(new_value='slots320', dist_name=_NRCELLname,
         filter_param='CSI reporting periodicity', abbr='csiReportPeriodicity'),
    dict(new_value='80ms', dist_name=_NRCELLname,
         filter_param='CSI-RS Tracking Period', abbr='csirsTrackingPeriod'),
    dict(new_value='10', dist_name=_NRCELLname,
         filter_param='Threshold for consecutive nonDTX for CSI', abbr='rlpRecCsiBsiThreshold'),
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate connected DRX', abbr='actCDrx'),
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate connected DRX VoNR', abbr='actCDrxVoNR'),
    dict(new_value='slots80', dist_name=_NRCELLname,
         filter_param='Scheduling request periodicity', abbr='srPeriodicity'),
    dict(new_value='1000ms', dist_name=_NRCELLname,
         filter_param='Timer t310 for VoNR', abbr='t310VoNR'),
    dict(new_value='n10', dist_name=_NRCELLname,
         filter_param='Timer t310 for VoNR', abbr='n310VoNR'),
    dict(new_value='1000ms', dist_name=_NRBTSname,
         filter_param='RLF indication timer for DU for VoNR', abbr='tRLFindForDUVoNR'),
    dict(new_value='0', dist_name=_NRBTSname,
         filter_param='Stand alone UE 5QI1 DRB inactivity timer', abbr='drbInactivityTimerSA5qi1'),
    dict(new_value='0', dist_name=_NRBTSname,
         filter_param='Stand alone UE 5QI5 DRB inactivity timer', abbr='drbInactivityTimerSA5qi5'),
    dict(new_value='rlcUm6bitSN', dist_name=_NRDRB_RLC_UM1name,
         filter_param='RLC UM mode DRB SN length', abbr='rlcUMDrbSNLength'),
    dict(new_value='44', dist_name=_NRDRB15name,
         filter_param='DSCP', abbr='dscp')
]

PARAMS_TO_MODIFY_6112_A16 = [
    dict(new_value='60', dist_name=_NRBTSname,
         filter_param='Stand alone UE 5QI5 DRB inactivity timer', abbr='drbInactivityTimerSA5qi5')
]

PARAMS_TO_MODIFY_6112_B16_1 = [
    dict(new_value='Locked', dist_name=_BBMOD2_name,
         filter_param='Administrative state', abbr='administrativeState')
]

PARAMS_TO_MODIFY_6112_B16_2 = [
    dict(new_value='Unlocked', dist_name=_BBMOD2_name,
         filter_param='Administrative state', abbr='administrativeState')
]

PARAMS_TO_MODIFY_6112_A16_2 = [
    dict(new_value='15', dist_name=_NRBTSname,
         filter_param='Stand alone UE 5QI5 DRB inactivity timer', abbr='drbInactivityTimerSA5qi5')
]

PARAMS_TO_MODIFY_6112_C01_1 = [
    dict(new_value='EnhancedVoNR', dist_name=_NRCELLname,
         filter_param='Activation of radio admission control for GBR data radio bearers',
         abbr='actGBRAdmissionControl'),
    dict(new_value='70', dist_name=_NRCELLname, filter_param='Maximum GBR traffic limit',
         abbr='maxGBRTrafficLimit'),
    dict(new_value='40', dist_name=_NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers'),
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate normal voice call fallback to LTE', abbr='actNormVCFallback'),
    dict(new_value='disabled', dist_name=_NRCELLname,
         filter_param='Voice fallback mode', abbr='voiceFBMode')
]

PARAMS_TO_MODIFY_6112_C01_2 = [
    dict(new_value='off', dist_name=_NRCELLname,
         filter_param='Activation of radio admission control for GBR data radio bearers',
         abbr='actGBRAdmissionControl'),
    dict(new_value='0', dist_name=_NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers')
]


PARAMS_TO_MODIFY_6112_C03_1 = [
    dict(new_value='off', dist_name=_NRCELLname,
         filter_param='Activation of radio admission control for GBR data radio bearers',
         abbr='actGBRAdmissionControl'),
    dict(new_value='0', dist_name=_NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers'),
    dict(new_value='10', dist_name=_NRCELLname,
         filter_param='Maximum number of GBR data radio bearers in a New Radio cell for SA',
         abbr='maxNumOfGBRBearersSA'),
    dict(new_value='true', dist_name=_NRCELLname,
         filter_param='Activate adaptive VoIP TBS',
         abbr='actAdaptVoipTbs'),
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='false', dist_name=_NRBTSname,
         filter_param='Activate normal voice call fallback to LTE', abbr='actNormVCFallback'),
    dict(new_value='disabled', dist_name=_NRCELLname,
         filter_param='Voice fallback mode', abbr='voiceFBMode')
]

PARAMS_TO_MODIFY_6112_C09_1 = [
    dict(new_value='EnhancedVoNR', dist_name=_NRCELLname,
         filter_param='Activation of radio admission control for GBR data radio bearers',
         abbr='actGBRAdmissionControl'),
    dict(new_value='0', dist_name=_NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers'),
    dict(new_value='50', dist_name=_NRCELLname, filter_param='Maximum GBR traffic limit',
         abbr='maxGBRTrafficLimit'),
    dict(new_value='1', dist_name=_NRCELLname,
         filter_param='Maximum number of GBR data radio bearers in a New Radio cell for SA',
         abbr='maxNumOfGBRBearersSA'),
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate adaptive VoIP TBS',
         abbr='actAdaptVoipTbs'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate normal voice call fallback to LTE', abbr='actNormVCFallback'),
    dict(new_value='redirection', dist_name=_NRCELLname,
         filter_param='Voice fallback mode', abbr='voiceFBMode')
]

PARAMS_TO_MODIFY_6112_C09_2 = [
    dict(new_value='EnhancedVoNR', dist_name=_NRCELLname,
         filter_param='Activation of radio admission control for GBR data radio bearers',
         abbr='actGBRAdmissionControl'),
    dict(new_value='40', dist_name=_NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers'),
    dict(new_value='70', dist_name=_NRCELLname, filter_param='Maximum GBR traffic limit',
         abbr='maxGBRTrafficLimit'),
    dict(new_value='200', dist_name=_NRCELLname,
         filter_param='Maximum number of GBR data radio bearers in a New Radio cell for SA',
         abbr='maxNumOfGBRBearersSA'),
    dict(new_value='false', dist_name=_NRCELLname,
         filter_param='Activate adaptive VoIP TBS',
         abbr='actAdaptVoipTbs'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate RRC Connection Release with redirection', abbr='actRedirect'),
    dict(new_value='true', dist_name=_NRBTSname,
         filter_param='Activate normal voice call fallback to LTE', abbr='actNormVCFallback'),
    dict(new_value='redirection', dist_name=_NRCELLname,
         filter_param='Voice fallback mode', abbr='voiceFBMode')
]

PARAMS_TO_MODIFY_6112_C16_1 = [
    dict(new_value='none', dist_name=_NRCELLname+'/NRHOIF-1',
         filter_param='A3 measurement configuration enabled',
         abbr='a3MeasEnabled'),
    dict(new_value='rsrp', dist_name=_NRCELLname+'/NRHOIF-1',
         filter_param='A5 measurement configuration enabled',
         abbr='a5MeasEnabled')
]

PARAMS_TO_MODIFY_6112_C17_1 = [
    dict(new_value='rsrp', dist_name=_NRCELLname+'/NRHOIF-1',
         filter_param='A3 measurement configuration enabled',
         abbr='a3MeasEnabled'),
    dict(new_value='none', dist_name=_NRCELLname+'/NRHOIF-1',
         filter_param='A5 measurement configuration enabled',
         abbr='a5MeasEnabled')
]

PARAMS_TO_MODIFY_6112_C17_2 = [
    dict(new_value='0', dist_name=_gnb2NRCELLname,
         filter_param='Maximum number of GBR data radio bearers in a New Radio cell for SA',
         abbr='maxNumOfGBRBearersSA'),
    dict(new_value='0', dist_name=_gnb2NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers')
]

PARAMS_TO_MODIFY_6112_C17_3 = [
    dict(new_value='10', dist_name=_gnb2NRCELLname,
         filter_param='Maximum number of GBR data radio bearers in a New Radio cell for SA',
         abbr='maxNumOfGBRBearersSA'),
    dict(new_value='0', dist_name=_gnb2NRCELLname,
         filter_param='Additional number of GBR DRB resources for handovers',
         abbr='addNumOfGBRBearers')
]

AMOUNT_OF_CELLS = 1
