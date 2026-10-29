from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRPLMN_11 = _NRBTSname + '/NRPLMN-1'
_NRPLMN_12 = _NRBTSname + '/NRPLMN-2'
_ADJ_NRPLMNSET_SA_31 = _NRBTSname + '/NRADJNRCELL-31/ADJ_NRPLMNSET_SA-1'
_NRTAC_20200_1 = _NRBTSname + '/TRACKINGAREA-20200'
_NRANRPR_1 = _NRBTSname + '/NRANRPR-1'
_NRANR_1 = _NRBTSname + '/NRANR-1'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSnames2 = 'NRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_NRPLMN_21 = _NRBTSname2 + '/NRPLMN-1'
_NRPLMN_22 = _NRBTSname2 + '/NRPLMN-2'
_NRADJ11 = _NRBTSname2 + '/NRADJGNB-11'
_NRADJNRCELL11 = _NRBTSname2 + '/NRADJNRCELL-11'
_NRTAC_20200_2 = _NRBTSname2 + '/TRACKINGAREA-20200'

_gnb3_id = str(tl.gnbs[2].instance_id)
_MRBTSname3 = 'MRBTS-'+_gnb3_id
_NRBTSnames3 = 'NRBTS-'+_gnb3_id
_NRBTSname3 = _MRBTSname3+'/NRBTS-'+_gnb3_id
_NRPLMN_31 = _NRBTSname3 + '/NRPLMN-1'
_NRPLMN_32 = _NRBTSname3 + '/NRPLMN-2'
_NRADJ14 = _NRBTSname3 + '/NRADJGNB-14'
_NRADJNRCELL42 = _NRBTSname3 + '/NRADJNRCELL-42'
_ADJ_NRPLMNSET_SA_42 = _NRBTSname3 + '/NRADJNRCELL-42/ADJ_NRPLMNSET_SA-1'
_NRTAC_20200_3 = _NRBTSname3 + '/TRACKINGAREA-20200'

_gnb4_id = str(tl.gnbs[3].instance_id)
_MRBTSname4 = 'MRBTS-'+_gnb4_id
_NRBTSnames4 = 'NRBTS-'+_gnb4_id
_NRBTSname4 = _MRBTSname4+'/NRBTS-'+_gnb4_id
_NRPLMN_41 = _NRBTSname4 + '/NRPLMN-1'
_NRPLMN_42 = _NRBTSname4 + '/NRPLMN-2'
_NRTAC_20200_4 = _NRBTSname4 + '/TRACKINGAREA-20200'

_enb_id = str(tl.enbs[0].instance_id)
_MRBTSname_enb = 'MRBTS-'+_enb_id
_NRBTSname_enb = _MRBTSname_enb+'/LNBTS-'+_enb_id

BTSnameEnb = [_NRBTSname_enb]

_NRCELL11 = _NRBTSname+'/NRCELL-1'
_NRCELL111 = _NRBTSname+'/NRCELL-11'
_NRCELL12 = _NRBTSname+'/NRCELL-2'
_NRCELL13 = _NRBTSname+'/NRCELL-3'
_NRCELL131 = _NRBTSname+'/NRCELL-31'
_NRCELL121 = _NRBTSname+'/NRCELL-21'
_NRREL11 = _NRCELL11+'/NRREL-1'
_NRREL112 = _NRCELL11+'/NRREL-2'
_NRREL113 = _NRCELL11+'/NRREL-3'
_NRREL1111 = _NRCELL111+'/NRREL-1'
_NRREL1112 = _NRCELL111+'/NRREL-2'
_NRREL1113 = _NRCELL111+'/NRREL-3'
_NRREL12 = _NRCELL12+'/NRREL-1'
_NRREL121 = _NRCELL12+'/NRREL-2'
_NRREL122 = _NRCELL12+'/NRREL-3'
_NRREL13 = _NRCELL13+'/NRREL-1'
_NRREL1311 = _NRCELL13+'/NRREL-2'
_NRREL1312 = _NRCELL13+'/NRREL-3'
_NRREL131 = _NRCELL131+'/NRREL-1'
_NRPLMNSET_SA_11 = _NRCELL11+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_11 = _NRCELL11+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_111 = _NRCELL111+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_111 = _NRCELL111+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_12 = _NRCELL12+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_12 = _NRCELL12+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_13 = _NRCELL13+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_13 = _NRCELL13+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_131 = _NRCELL131+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_131 = _NRCELL131+'/NRPLMNSET_NSA-1'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL211 = _NRBTSname2+'/NRCELL-11'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL23 = _NRBTSname2+'/NRCELL-3'
_NRCELL231 = _NRBTSname2+'/NRCELL-31'
_NRREL21 = _NRCELL21+'/NRREL-1'
_NRREL212 = _NRCELL21+'/NRREL-2'
_NRREL22 = _NRCELL22+'/NRREL-1'
_NRREL2111 = _NRCELL211 + '/NRREL-1'
_NRREL231 = _NRCELL231+'/NRREL-1'
_NRREL222 = _NRCELL22+'/NRREL-2'
_NRHOIF13 = _NRCELL13+'/NRHOIF-1'
_NRPLMNSET_SA_21 = _NRCELL21+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_21 = _NRCELL21+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_211 = _NRCELL211+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_211 = _NRCELL211+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_22 = _NRCELL22+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_22 = _NRCELL22+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_23 = _NRCELL23+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_23 = _NRCELL23+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_231 = _NRCELL231+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_231 = _NRCELL231+'/NRPLMNSET_NSA-1'

_NRCELL31 = _NRBTSname3+'/NRCELL-1'
_NRCELL311 = _NRBTSname3+'/NRCELL-11'
_NRCELL32 = _NRBTSname3+'/NRCELL-2'
_NRCELL33 = _NRBTSname3+'/NRCELL-3'
_NRCELL331 = _NRBTSname3+'/NRCELL-31'
_NRREL311 = _NRCELL31+'/NRREL-1'
_NRREL321 = _NRCELL32+'/NRREL-1'
_NRREL322 = _NRCELL32+'/NRREL-2'
_NRREL331 = _NRCELL33+'/NRREL-1'
_NRREL332 = _NRCELL33+'/NRREL-2'
_NRREL3311 = _NRCELL331+'/NRREL-1'
_NRPLMNSET_SA_31 = _NRCELL31+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_31 = _NRCELL31+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_311 = _NRCELL311+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_311 = _NRCELL311+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_32 = _NRCELL32+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_32 = _NRCELL32+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_33 = _NRCELL33+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_33 = _NRCELL33+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_331 = _NRCELL331+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_331 = _NRCELL331+'/NRPLMNSET_NSA-1'

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL42 = _NRBTSname4+'/NRCELL-2'
_NRCELL421 = _NRBTSname4+'/NRCELL-21'
_NRCELL43 = _NRBTSname4+'/NRCELL-3'
_NRCELL431 = _NRBTSname4+'/NRCELL-31'
_NRREL41 = _NRCELL41+'/NRREL-1'
_NRREL412 = _NRCELL41+'/NRREL-2'
_NRREL42 = _NRCELL42+'/NRREL-1'
_NRREL421 = _NRCELL421+'/NRREL-1'
_NRREL4212 = _NRCELL421+'/NRREL-2'
_NRREL431 = _NRCELL431+'/NRREL-1'
_NRPLMNSET_SA_41 = _NRCELL41+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_41 = _NRCELL41+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_42 = _NRCELL42+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_42 = _NRCELL42+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_421 = _NRCELL421+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_421 = _NRCELL421+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_43 = _NRCELL43+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_43 = _NRCELL43+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_431 = _NRCELL431+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_431 = _NRCELL431+'/NRPLMNSET_NSA-1'

PARAMETERS_TO_MODIFY_GNB1_GD003 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL112, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

ADD_MO_Online_GNB1_GD001 = [
    dict(value='true', dist_name=_NRHOIF13, parameter='a1BasedPCellSwitchEnabled'),
    dict(value='true', dist_name=_NRHOIF13, parameter='a2BasedPCellSwitchEnabled'),
    dict(value='1', dist_name=_NRHOIF13, parameter='a2BasedPCellSwitchPriority'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a3MeasEnabled'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasEnDcSteeringEnabled'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasHigherPrioFreqEnabled'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasNrDcEnabled'),
    dict(value=[dict(a4HysteresisNrDcSsbRsrp='0', a4ThresholdNrDcSsbRsrp='43', a4TimeToTriggerNrDcSsbRsrp='ms100')],
         dist_name=_NRHOIF13, parameter='a4MeasNrDcSsbRsrp'),
    dict(value=[dict(a4HysteresisNrDcSsbRsrq='0', a4ThresholdNrDcSsbRsrq='49', a4TimeToTriggerNrDcSsbRsrq='ms100')],
         dist_name=_NRHOIF13, parameter='a4MeasNrDcSsbRsrq'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasSCellAddEnabled'),
    dict(value=[dict(a4HysteresisSsbRsrp='0', a4ThresholdSsbRsrp='34', a4TimeToTriggerSsbRsrp='ms40')],
         dist_name=_NRHOIF13, parameter='a4MeasSsbRsrp'),
    dict(value=[dict(a4HysteresisSsbRsrq='0', a4ThresholdSsbRsrq='49', a4TimeToTriggerSsbRsrq='ms100')],
         dist_name=_NRHOIF13, parameter='a4MeasSsbRsrq'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a5MeasEnabled'),
    dict(value='SA+NSA', dist_name=_NRHOIF13, parameter='cellDepType'),
    dict(value='true', dist_name=_NRHOIF13, parameter='deriveSsbIndexFromCell'),
    dict(value='66', dist_name=_NRHOIF13, parameter='freqBandIndicatorNR'),
    dict(value='15KHz', dist_name=_NRHOIF13, parameter='ifhoSsbScs'),
    dict(value='sf5', dist_name=_NRHOIF13, parameter='ifhoSsbSmtcDuration'),
    dict(value='sf20', dist_name=_NRHOIF13, parameter='ifhoSsbSmtcPeriodicity'),
    dict(value='1', dist_name=_NRHOIF13, parameter='nrhoifId'),
    dict(value='1 beam', dist_name=_NRHOIF13, parameter='numberOfTransmittedSsBlocks'),
    dict(value='424850', dist_name=_NRHOIF13, parameter='ssbFrequency'),
    dict(value='20', dist_name=_NRHOIF13, parameter='ssBurstSetPeriod'),
    dict(value='20', dist_name=_NRHOIF13, parameter='thresholdPCellSwitchTargetRsrp'),
    dict(value='30', dist_name=_NRHOIF13, parameter='thresholdPCellSwitchTargetRsrq'),
    dict(value='0dB', dist_name=_NRREL13, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL13, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL13, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL13, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL13, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL13, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL13, parameter='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL13, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL13, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL13, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL13, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL13, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL13, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL13, parameter='gnbPlmn')
]

ADD_MO_Online_GNB1_GD001_SBTS23R3_ENB_0000 = [
    dict(value='true', dist_name=_NRHOIF13, parameter='a1BasedPCellSwitchEnabled'),
    dict(value='true', dist_name=_NRHOIF13, parameter='a2BasedPCellSwitchEnabled'),
    dict(value='1', dist_name=_NRHOIF13, parameter='a2BasedPCellSwitchPriority'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a3MeasEnabled'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasEnDcSteeringEnabled'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasHigherPrioFreqEnabled'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a4MeasNrDcEnabled'),
    dict(value=[dict(a4HysteresisNrDcSsbRsrp='0', a4ThresholdNrDcSsbRsrp='43', a4TimeToTriggerNrDcSsbRsrp='ms100')],
         dist_name=_NRHOIF13, parameter='a4MeasNrDcSsbRsrp'),
    dict(value=[dict(a4HysteresisNrDcSsbRsrq='0', a4ThresholdNrDcSsbRsrq='49', a4TimeToTriggerNrDcSsbRsrq='ms100')],
         dist_name=_NRHOIF13, parameter='a4MeasNrDcSsbRsrq'),
    dict(value=[dict(a4HysteresisSsbRsrp='0', a4ThresholdSsbRsrp='34', a4TimeToTriggerSsbRsrp='ms40')],
         dist_name=_NRHOIF13, parameter='a4MeasSsbRsrp'),
    dict(value=[dict(a4HysteresisSsbRsrq='0', a4ThresholdSsbRsrq='49', a4TimeToTriggerSsbRsrq='ms100')],
         dist_name=_NRHOIF13, parameter='a4MeasSsbRsrq'),
    dict(value='none', dist_name=_NRHOIF13, parameter='a5MeasEnabled'),
    dict(value='SA+NSA', dist_name=_NRHOIF13, parameter='cellDepType'),
    dict(value='true', dist_name=_NRHOIF13, parameter='deriveSsbIndexFromCell'),
    dict(value='66', dist_name=_NRHOIF13, parameter='freqBandIndicatorNR'),
    dict(value='15KHz', dist_name=_NRHOIF13, parameter='ifhoSsbScs'),
    dict(value='sf5', dist_name=_NRHOIF13, parameter='ifhoSsbSmtcDuration'),
    dict(value='sf20', dist_name=_NRHOIF13, parameter='ifhoSsbSmtcPeriodicity'),
    dict(value='1', dist_name=_NRHOIF13, parameter='nrhoifId'),
    dict(value='1 beam', dist_name=_NRHOIF13, parameter='numberOfTransmittedSsBlocks'),
    dict(value='424850', dist_name=_NRHOIF13, parameter='ssbFrequency'),
    dict(value='20', dist_name=_NRHOIF13, parameter='ssBurstSetPeriod'),
    dict(value='20', dist_name=_NRHOIF13, parameter='thresholdPCellSwitchTargetRsrp'),
    dict(value='30', dist_name=_NRHOIF13, parameter='thresholdPCellSwitchTargetRsrq'),
    dict(value='0dB', dist_name=_NRREL13, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL13, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL13, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL13, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL13, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL13, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL13, parameter='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL13, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL13, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL13, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL13, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL13, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL13, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL13, parameter='gnbPlmn')
]

PARAMETERS_TO_MODIFY_GNB1_GD009 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD001 = [
    {'dist_name': _NRBTSname, 'parameter': 'actMeasBasedSCellAdditionNsa', 'value': 'true'},
    {'dist_name': _NRCELL13, 'parameter': 'cellBarred', 'value': 'notBarred'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL')
]

PARAMETERS_TO_ADD_GNB1_GD001 = [
    {'dist_name': _NRCELL13, 'parameter': 'a2MeasPCellSwitchEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL13, 'parameter': 'a2MeasPCellSwitchSsbRsrp',
     'value': [{'a2HysteresisPCellSwitchSsbRsrp': '0', 'a2ThresholdPCellSwitchSsbRsrp': '20',
                'a2TimeToTriggerPCellSwitchSsbRsrp': '64ms', 'pCellSwitchOffsetSsbRsrp': '0'}]},
    {'dist_name': _NRCELL13, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL13, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '66',
                'a1ThresholdSCellAddSsbRsrpTDD': '66', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GD001 = [
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname4,
         parameter='cipherPrefL'),
    {'dist_name': _NRCELL41, 'parameter': 'a2MeasSCellRelEnabled', 'value': 'rsrp'}
]

PARAMETERS_TO_ONLINE_ADD_GNB4_GD001 = [
    {'dist_name': _NRCELL41, 'parameter': 'a2MeasSCellRelSsbRsrp',
     'value': [{'a2HysteresisSCellRelSsbRsrp': '0', 'a2ThresholdSCellRelSsbRsrp': '66',
                'a2TimeToTriggerSCellRelSsbRsrp': '2560ms'}]}
]

PARAMETERS_TO_DELETE_GNB1_GD001 = [
    {'dist_name': _NRREL13},
    {'dist_name': _NRHOIF13}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD003 = [
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'dlToUlContributionRatio', 'value': '50'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'carrierAggregationSupportList', 'value':
        ['ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Sa', 'ca_Fdd_Fr1Tdd_Sa_WithUl', 'ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa']},
    {'dist_name': _NRBTSname + '/NRDRB_RLC_AM-1', 'parameter': 'ulTReassemblyIBCA', 'value': '40'},
    {'dist_name': _NRBTSname + '/NRDRB_RLC_AM-2', 'parameter': 'ulTReassemblyIBCA', 'value': '40'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL13, 'parameter': 'increasePUSCHPrepTimeULCA', 'value': 'true'}
]

PARAMETERS_TO_ADD_GNB1_GD003 = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '66',
                'a1ThresholdSCellAddSsbRsrpTDD': '66', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD003_1 = [
    {'dist_name': _NRCELL11, 'parameter': 'timingAdvanceOffset', 'value': 'n39936'},
    {'dist_name': _NRCELL111, 'parameter': 'timingAdvanceOffset', 'value': 'n39936'},
    {'dist_name': _NRCELL12, 'parameter': 'timingAdvanceOffset', 'value': 'n39936'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GD003 = [
    {'dist_name': _NRBTSnames4 + '/NRDU-1', 'parameter': 'dlToUlContributionRatio', 'value': '50'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname4,
         parameter='cipherPrefL')
]

MO_TO_DELETE_GNB1_GD003 = [
    {'dist_name': _NRREL11},
    {'dist_name': _NRREL112}
]

PARAMETERS_TO_DELETE_GNB1_GD003 = [
    dict(dist_name=_NRCELL11, parameter='a1MeasSCellAddSsbRsrp'),
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled'},
    {'dist_name': _NRCELL13, 'parameter': 'increasePUSCHPrepTimeULCA'}
]

PARAMETERS_TO_RESTORE_GNB1_GD003 = [
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'dlToUlContributionRatio', 'value': '101'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'}
]

PARAMETERS_TO_RESTORE_GNB1_GD003_1 = [
    {'dist_name': _NRCELL11, 'parameter': 'timingAdvanceOffset', 'value': 'n0'},
    {'dist_name': _NRCELL111, 'parameter': 'timingAdvanceOffset', 'value': 'n0'},
    {'dist_name': _NRCELL12, 'parameter': 'timingAdvanceOffset', 'value': 'n0'}
]

PARAMETERS_TO_RESTORE_GNB4_GD003 = [
    {'dist_name': _NRBTSname4 + '/NRDU-1', 'parameter': 'dlToUlContributionRatio', 'value': '101'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GD009 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'blind'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL'),
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'carrierAggregationSupportList', 'value':
        ['ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Sa', 'ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fdd_Any_Sa']},
]

PARAMETERS_TO_ADD_GNB1_GD009 = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '90',
                'a1ThresholdSCellAddSsbRsrpTDD': '80', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GD009 = [
    {'dist_name': _NRCELL42, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    {'dist_name': _NRCELL43, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    {'dist_name': _NRCELL42, 'parameter': 'a2MeasSCellRelEnabled', 'value': 'rsrp'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname4,
         parameter='cipherPrefL')
]

PARAMETERS_TO_ONLINE_ADD_GNB4_GD009 = [
    {'dist_name': _NRCELL42, 'parameter': 'a2MeasSCellRelSsbRsrp',
     'value': [{'a2HysteresisSCellRelSsbRsrp': '0', 'a2ThresholdSCellRelSsbRsrp': '77',
                'a2TimeToTriggerSCellRelSsbRsrp': '2560ms'}]}
]

PARAMETERS_TO_RESTORE_GNB1_GD009 = [
    {'dist_name': _NRBTSnames + '/NRDU-1', 'parameter': 'carrierAggregationSupportList', 'value':
        ['ca_Fdd_Fdd', 'ca_Fdd_Fr1Tdd_Sa', 'ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa']}
]

PARAMETERS_TO_DELETE_GNB1_GD009 = [
    dict(dist_name=_NRCELL11, parameter='a1MeasSCellAddSsbRsrp'),
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled'}
]

PARAMETERS_TO_DELETE_GNB4_GD009 = [
    dict(value=[dict(a2HysteresisSCellRelSsbRsrp='0', a2ThresholdSCellRelSsbRsrp='66',
                     a2TimeToTriggerSCellRelSsbRsrp='320ms')], dist_name=_NRCELL43, parameter='a2MeasSCellRelSsbRsrp')
]

MO_TO_DELETE_GNB1_GD009 = [
    {'dist_name': _NRREL11},
    {'dist_name': _NRREL112}
]

MOS_ADD_GNB1_GC = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1112, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL12, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL121, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL122, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GC = [
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL1111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1111, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL1111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1111, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL1111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1111, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL1111, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL1112, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1112, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL1112, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL1112, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1112, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1112, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL1112, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1112, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1112, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1112, p_name='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL1112, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL12, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL12, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL12, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL12, p_name='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL12, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL12, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL12, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL12, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL12, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL121, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL121, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL121, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL121, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL121, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL121, p_name='nrDcAllowed'),
    dict(value='11', dist_name=_NRREL121, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL121, p_name='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL121, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL122, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL122, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL122, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL122, p_name='handoverAllowedSARedCap'),
    dict(value='11', dist_name=_NRREL122, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL122, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL122, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL122, p_name='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL122, p_name='isRplCellForPSCell'),
    dict(value='430000', dist_name=_NRCELL111+'/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='350000', dist_name=_NRCELL111+'/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='rsrp', dist_name=_NRCELL12, p_name='a1MeasSCellAddEnabled'),
    dict(value='rsrp', dist_name=_NRCELL111, p_name='a1MeasSCellAddEnabled'),
    dict(value='intraAndInter-gNB', dist_name=_NRCELL12, p_name='actK1Opt')
]

LIST_TO_ADD_GNB1_GC = [
    dict(
        dist_name=_NRREL1111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1112,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL12,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL121,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL122,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL111,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='86',
            a1ThresholdSCellAddSsbRsrpTDD='86',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL12,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='86',
            a1ThresholdSCellAddSsbRsrpTDD='86',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

MOS_ADD_GNB2_GC = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL22, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL222, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL231, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB2_GC = [
    dict(value='0dB', dist_name=_NRREL22, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL22, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL22, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL22, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL22, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL22, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL22, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL22, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL22, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL22, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL222, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL222, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL222, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL222, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL222, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL222, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL222, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL222, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL222, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL222, p_name='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL222, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL231, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL231, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL231, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL231, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL231, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL231, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL231, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL231, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL231, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL231, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL231, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL231, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL231, p_name='isRplCellForPSCell'),
    dict(value='rsrp', dist_name=_NRCELL22, p_name='a1MeasSCellAddEnabled'),
    dict(value='rsrp', dist_name=_NRCELL231, p_name='a1MeasSCellAddEnabled')
]

LIST_TO_ADD_GNB2_GC = [
    dict(
        dist_name=_NRREL22,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL222,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL231,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL22,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='86',
            a1ThresholdSCellAddSsbRsrpTDD='86',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL231,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='76',
            a1ThresholdSCellAddSsbRsrpTDD='76',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

PARAMETERS_TO_MODIFY_GNB1_GC_Lock = [
    dict(value='Locked', dist_name=_NRCELL111, parameter='administrativeState'),
]

PARAMETERS_TO_MODIFY_GNB1_recover_GC = [
    dict(value='Unlocked', dist_name=_NRCELL111, parameter='administrativeState'),
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GC002 = [
    {'dist_name': _NRBTSname2, 'parameter': 'rrcReestabTypeSA', 'value': 'sameGNB'},
    {'dist_name': _NRBTSname2, 'parameter': 'tWaitingRlRecoverSA', 'value': '60000ms'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL231, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

counter_xml_GC002_gNB1 = [
    'IGNB_CA_ATT_SA_REL'
]

counter_id_GG002_gNB1 = [
    'M55118C11008'
]

counter_dic_path_GG002_gNB1 = [
    'BTS/CELLS/NRCELL-31/NCAC'
]

counter_dic_path_GG002_gNB1_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-31/NCAC'
]

counter_dic_path_GG005_gNB1 = [
    'BTS/CELLS/NRCELL-2/NCAC'
]

counter_dic_path_GG005_gNB1_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-2/NCAC'
]

PARAMETERS_TO_DELETE_GNB1_GC002 = [
    {'dist_name': _NRREL11},
    {'dist_name': _NRREL12}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GC005 = [
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_GC005 = [
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL22, 'parameter': 'a3MeasEnabled', 'value': 'none'},
    {'dist_name': _NRCELL22, 'parameter': 'a5MeasEnabled', 'value': 'rsrp'},
]

PARAMETERS_TO_ONLINE_ADD_GNB2_GC005 = [
    {'dist_name': _NRCELL22, 'parameter': 'a5MeasSsbRsrp',
     'value': [{'a5HysteresisSsbRsrp': '0', 'a5Threshold1SsbRsrp': '90',
                'a5Threshold2SsbRsrp': '80', 'a5TimeToTriggerSsbRsrp': 'ms320'}]}
]

PARAMETERS_TO_UPDATE_GNB1_GC005_inter_HO = [
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL121, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL121, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, parameter='handoverAllowedSA'),
    dict(value='21', dist_name=_NRREL121, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL121, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL121, parameter='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL121, parameter='removeNotAllowed'),
    dict(value='forbidden', dist_name=_NRREL121, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL121, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL121, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_GNB4_GC005_inter_HO = [
    dict(value='0dB', dist_name=_NRREL4212, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL4212, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL4212, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL4212, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL4212, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL4212, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL4212, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL4212, parameter='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL4212, parameter='removeNotAllowed'),
    dict(value='forbidden', dist_name=_NRREL4212, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL4212, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL4212, parameter='gnbPlmn')
]

PARAMETERS_TO_DELETE_GNB1_GC005 = [
    {'dist_name': _NRREL12},
    {'dist_name': _NRREL121}
]

PARAMETERS_TO_DELETE_GNB2_GC005 = [
    {'dist_name': _NRREL22},
    {'dist_name': _NRREL222}
]

MOS_ADD_GNB1_GC008 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1112, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL12, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL121, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GC008 = [
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL1111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1111, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL1111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1111, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL1111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1111, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL12, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL12, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL12, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL12, p_name='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL12, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL12, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL12, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL12, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, p_name='sCellOperationalMode'),
    dict(value='424200', dist_name=_NRCELL12+'/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='344100', dist_name=_NRCELL12+'/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='rsrp', dist_name=_NRCELL12, p_name='a1MeasSCellAddEnabled'),
    dict(value='intraAndInter-gNB', dist_name=_NRCELL12, p_name='actK1Opt')
]

LIST_TO_ADD_GNB1_GC008 = [
    dict(
        dist_name=_NRREL1111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL12,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL12,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='90',
            a1ThresholdSCellAddSsbRsrpTDD='90',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

PARAMETERS_TO_ADD_GNB1_GC008_intra_HO = [
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GC008 = [
    {'dist_name': _NRCELL111, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL111, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL12, 'parameter': 'a1MeashoEnabledSA', 'value': 'none'},
    {'dist_name': _NRCELL12, 'parameter': 'a2MeashoEnabledSA', 'value': 'none'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname,
         parameter='cipherPrefL')
]

counter_dic_path_GC008_gNB1 = [
    'BTS/CELLS/NRCELL-11/NCAC'
]

counter_dic_path_GC008_gNB1_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-11/NCAC'
]

counter_id_GB007_gNB2_KPI = [
    'M55167C00001', 'M55167C00002'
]

counter_dic_path_GB007_gNB2_KPI_Trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-11/NCADC',
    'BTS/' + _NRBTSname2 + '/NRCELL-11/NCADC'
]

counter_dic_path_GB007_gNB2_KPI = [
    'BTS/CELLS/NRCELL-11/NCADC',
    'BTS/CELLS/NRCELL-11/NCADC'
]

counter_id_GB007_gnb2 = [
    'M55139C04001', 'M55139C02502', 'M55166C00002', 'M55166C00004'
]

counter_dic_path_GB007_gnb2_Trunk = [
    'BTS/'+_NRBTSname2+'/NRCELL-11/RSADU',
    'BTS/'+_NRBTSname2+'/NRCELL-11/RSADU',
    'BTS/'+_NRBTSname2+'/NRCELL-11/NRCCD',
    'BTS/'+_NRBTSname2+'/NRCELL-11/NRCCD'
]

counter_dic_path_GB007_gnb2 = [
    'BTS/CELLS/NRCELL-11/RSADU',
    'BTS/CELLS/NRCELL-11/RSADU',
    'BTS/CELLS/NRCELL-11/NRCCD',
    'BTS/CELLS/NRCELL-11/NRCCD'
]

PARAMETERS_TO_ONLINE_RECOVERY_GNB4_GB007 = [
    {'dist_name': _NRREL431}
]

MOS_ADD_GNB3_GG008 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL311, version="NRBTSCL23R3_2309_100")
]

LIST_TO_ADD_GNB3_GG008 = [
    dict(
        dist_name=_NRREL311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')
    ),
    dict(
        dist_name=_NRBTSname3 + '/SNSSAI-1',
        list_name='xgUplane',
        elements={'ipV6AddressDN1': _MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}
    ),
    dict(
        dist_name=_NRBTSname3 + '/SNSSAI-2',
        list_name='xgUplane',
        elements={'ipV6AddressDN1': _MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}
    )
]

PARAMETERS_TO_MODIFY_GNB3_GG008 = [
    dict(value='notBarred', dist_name=_NRCELL31, p_name='cellBarred'),
    dict(value='false', dist_name=_NRBTSname3, p_name='actRanSharing'),
    dict(value=_NRTAC_20200_3, dist_name=_NRCELL31, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_3, dist_name=_NRCELL311, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_3, dist_name=_NRCELL32, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_3, dist_name=_NRCELL33, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_3, dist_name=_NRCELL331, p_name='trackingAreaDN'),
    dict(value='20000', dist_name=_NRCELL31, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL311, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL32, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL33, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL331, p_name='configuredEpsTac'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL311, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL311, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL311, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL311, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
]

MO_TO_DELETE_GNB3_GG008 = [
    {'dist_name': _NRPLMNSET_SA_31},
    {'dist_name': _NRPLMNSET_SA_311},
    {'dist_name': _NRPLMNSET_SA_32},
    {'dist_name': _NRPLMNSET_SA_33},
    {'dist_name': _NRPLMNSET_SA_331},
    {'dist_name': _NRPLMNSET_NSA_31},
    {'dist_name': _NRPLMNSET_NSA_311},
    {'dist_name': _NRPLMNSET_NSA_32},
    {'dist_name': _NRPLMNSET_NSA_33},
    {'dist_name': _NRPLMNSET_NSA_331},
]

PARAMETERS_TO_MODIFY_GNB4_GG008 = [
    dict(value='false', dist_name=_NRBTSname4, p_name='actRanSharing'),
    dict(value=_NRTAC_20200_4, dist_name=_NRCELL41, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_4, dist_name=_NRCELL421, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_4, dist_name=_NRCELL42, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_4, dist_name=_NRCELL43, p_name='trackingAreaDN'),
    dict(value=_NRTAC_20200_4, dist_name=_NRCELL431, p_name='trackingAreaDN'),
    dict(value='20000', dist_name=_NRCELL41, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL421, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL42, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL43, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRCELL431, p_name='configuredEpsTac'),
]

PARAMETERS_TO_DELETE_GNB4_GG008 = [
    {'dist_name': _NRPLMNSET_SA_41},
    {'dist_name': _NRPLMNSET_SA_421},
    {'dist_name': _NRPLMNSET_SA_42},
    {'dist_name': _NRPLMNSET_SA_43},
    {'dist_name': _NRPLMNSET_SA_431},
    {'dist_name': _NRPLMNSET_NSA_41},
    {'dist_name': _NRPLMNSET_NSA_421},
    {'dist_name': _NRPLMNSET_NSA_42},
    {'dist_name': _NRPLMNSET_NSA_43},
    {'dist_name': _NRPLMNSET_NSA_431},
    dict(dist_name=_NRBTSname4+'/NRDU-1', list_name='xgUplane')
]

LIST_TO_ADD_GNB4_GG008 = [
    dict(
        dist_name=_NRBTSname4 + '/SNSSAI-1',
        list_name='xgUplane',
        elements={'ipV4AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'}
    ),
    dict(
        dist_name=_NRBTSname4 + '/SNSSAI-2',
        list_name='xgUplane',
        elements={'ipV4AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'}
    ),
    dict(
        dist_name=_NRBTSname4 + '/NRDU-1',
        list_name='xgUplane',
        elements={'ipV6AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}
    )
]

counter_id_GG008_gNB3 = [
    'M55139C01003', 'M55118C11001', 'M55118C11007'
]

counter_dic_path_GG008_gNB3 = [
    'BTS/CELLS/NRCELL-1/RSADU', 'BTS/CELLS/NRCELL-1/NCAC',  'BTS/CELLS/NRCELL-1/NCAC'
]

counter_dic_path_GG008_gNB3_trunk = [
    'BTS/' + _NRBTSname3 + '/NRCELL-1/RSADU', 'BTS/' + _NRBTSname3 + '/NRCELL-1/NCAC',
    'BTS/' + _NRBTSname3 + '/NRCELL-1/NCAC'
]

counter_id_GG008_gNB4 = [
    'M55139C01001', 'M55175C00001', 'M55138C03501', 'M55138C03502', 'M55175C00002'
]

counter_dic_path_GG008_gNB4 = [
    'BTS/CELLS/NRCELL-2/RSADU', 'BTS/BTS/'+_NRBTSnames3+'/MCC-310_MNC-260/ADJNB',
    'BTS/CELLS/NRCELL-2/RSACU', 'BTS/CELLS/NRCELL-2/RSACU', 'BTS/BTS/'+_NRBTSnames3+'/MCC-310_MNC-260/ADJNB'
]

counter_dic_path_GG008_gNB4_trunk = [
    'BTS/' + _NRBTSname4 + '/NRCELL-2/RSADU', 'BTS/'+_MRBTSname4+'/'+_NRBTSnames3+'/MCC-310/MNC-260/ADJNB',
    'BTS/' + _NRBTSname4 + '/NRCELL-2/RSACU', 'BTS/' + _NRBTSname4 + '/NRCELL-2/RSACU',
    'BTS/'+_MRBTSname4+'/'+_NRBTSnames3+'/MCC-310/MNC-260/ADJNB'
]

counter_xml_GG008_gNB1 = [
    'IGNB_CA_ATT_1_SCELL_SA', 'IGNB_CA_ATT_SA_REJ'
]

counter_xml_GG008_gNB2 = [
    'IGNB_CA_ADD_REQ_SA_REJ_NRADJ'
]


LIST_TO_ADD_GNB1_GG003 = [
    dict(
        dist_name=_NRPLMNSET_NSA_11,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_SA_11,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_NSA_12,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_SA_12,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_NSA_111,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_SA_111,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_NSA_13,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRPLMNSET_SA_13,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRBTSname + '/SNSSAI-2',
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_12]
    ),
    dict(
        dist_name=_NRBTSname + '/SNSSAI-1',
        list_name='xgUplane',
        elements={'ipV4AddressDN1': _MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'}
    ),
    dict(
        dist_name=_NRBTSname + '/SNSSAI-2',
        list_name='xgUplane',
        elements={'ipV4AddressDN1': _MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'}
    ),
    dict(
        dist_name=_NRBTSname + '/NRDU-1',
        list_name='xgUplane',
        elements=dict(
            ipV6AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1',
            nrPlmnDN=_NRPLMN_12)
    ),
    dict(
        dist_name=_NRBTSname,
        list_name='ngUplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            nrPlmnDN=_NRPLMN_12)
    ),
    dict(
        dist_name=_NRBTSname,
        list_name='ngUplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            nrPlmnDN=_NRPLMN_11)
    ),
    dict(
        dist_name=_NRBTSname,
        list_name='ngCplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            ngTnlId='1')
    ),
    dict(
        dist_name=_NRBTSname,
        list_name='xnUplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            nrPlmnDN=_NRPLMN_12)
    ),
    dict(
        dist_name=_NRBTSname,
        list_name='xnCplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            xnTnlId='1')
    ),
]

PARAMETERS_TO_MODIFY_GNB1_GG003 = [
    dict(value='460', dist_name=_NRPLMN_11, p_name='mcc'),
    dict(value='2', dist_name=_NRPLMN_11, p_name='mnc'),
    dict(value='2', dist_name=_NRPLMN_11, p_name='mncLength'),
    dict(value='460', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='2', dist_name=_NRBTSname, p_name='mncLength'),
    dict(value='310', dist_name=_NRPLMN_12, p_name='mcc'),
    dict(value='260', dist_name=_NRPLMN_12, p_name='mnc'),
    dict(value='3', dist_name=_NRPLMN_12, p_name='mncLength'),
    dict(value='2', dist_name=_NRPLMN_12, p_name='nrPlmnId'),
    dict(value='270', dist_name=_NRTAC_20200_1, p_name='fiveGsTac'),
    dict(value='true', dist_name=_NRBTSname, p_name='actTrsSepaSARanSharing'),
    dict(value='1', dist_name=_NRBTSname + '/SERVEDAMF-1', p_name='ngTnlId'),
    dict(value='1', dist_name=_NRBTSname, p_name='xnTnlId'),
    dict(value='1', dist_name=_NRBTSname + '/XNLINK-12', p_name='xnTnlId')
]

PARAMETERS_TO_DELETE_GNB1_GG003 = [
    dict(dist_name=_NRBTSname+'/NRDU-1', list_name='xgUplane'),
    dict(dist_name=_NRBTSname, list_name='ngUplane'),
    dict(dist_name=_NRBTSname, list_name='ngCplane'),
    dict(dist_name=_NRBTSname, list_name='xnUplane'),
    dict(dist_name=_NRBTSname, list_name='xnCplane'),
    dict(dist_name=_NRPLMNSET_NSA_11, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_NSA_12, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_NSA_13, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_NSA_111, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_SA_11, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_SA_12, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_SA_13, list_name='nrPlmnDNList'),
    dict(dist_name=_NRPLMNSET_SA_111, list_name='nrPlmnDNList'),
    dict(dist_name=_NRBTSname + '/SNSSAI-2', list_name='nrPlmnDNList')
]

MOS_ADD_GNB3_GG003_386 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL311, version="NRBTSCL23R3_2309_100"),
    dict(class_name='com.nokia.srbts.nrbts:ADJ_NRPLMNSET_SA-1',
         dist_name=_ADJ_NRPLMNSET_SA_42, version="NRBTSCL22R4_2210_100")
]

LIST_TO_ADD_GNB3_GG003_386 = [
    dict(
        dist_name=_NRREL311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='460',
            mnc='2',
            mncLength='2')
    ),
    dict(
        dist_name=_ADJ_NRPLMNSET_SA_42,
        list_name='nrPlmnDNList',
        elements=[_NRPLMN_31]
    )
]

PARAMETERS_TO_MODIFY_GNB3_GG003_386 = [
    dict(value='1', dist_name=_ADJ_NRPLMNSET_SA_42, p_name='adjNrPlmnSetSaId'),
    dict(value='270', dist_name=_ADJ_NRPLMNSET_SA_42, p_name='fiveGsTac'),
    dict(value='notReserved', dist_name=_ADJ_NRPLMNSET_SA_42, p_name='cellReservedForOperatorUse'),
    dict(value='notBarred', dist_name=_NRCELL31, p_name='cellBarred'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL311, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL311, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL311, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL311, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
]

MOS_ADD_GNB2_GG003 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL22, version="NRBTSCL23R3_2309_100")
]

LIST_TO_ADD_GNB2_GG003 = [
    dict(
        dist_name=_NRREL22,
        list_name='gnbPlmn',
        elements=dict(
            mcc='460',
            mnc='2',
            mncLength='2')
    )
]

PARAMETERS_TO_MODIFY_GNB2_GG003 = [
    dict(value='notBarred', dist_name=_NRCELL22, p_name='cellBarred'),
    dict(value='0dB', dist_name=_NRREL22, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL22, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL22, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL22, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL22, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL22, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL22, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL22, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL22, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL22, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL22, p_name='isRplCellForPSCell'),
]

PARAMETERS_TO_DELETE_GNB2_GG003 = [
    dict(dist_name=_NRADJNRCELL11, p_name='fiveGsTac')
]

LIST_TO_modify_GNB2_GG003 = [
    dict(dist_name=_NRADJ11, list_name='gnbPlmn',
         elements=[dict(p_name='mcc', value='460', index=0),
                   dict(p_name='mnc', value='2', index=0),
                   dict(p_name='mncLength', value='2', index=0)]),
    dict(dist_name=_NRADJNRCELL11, list_name='gnbPlmn',
         elements=[dict(p_name='mcc', value='460', index=0),
                   dict(p_name='mnc', value='2', index=0),
                   dict(p_name='mncLength', value='2', index=0)])
]

LIST_TO_ONLINE_ADD_GNB2_HD006 = [
    dict(value=[dict(ipV4AddressDN1=_MRBTSname2 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1')],
         dist_name=_NRBTSname2 + '/SNSSAI-1',
         parameter='xgUplane'),
    dict(value=[dict(ipV6AddressDN1=_MRBTSname2 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname2 + '/SNSSAI-2',
         parameter='xgUplane')
]

# parameters_to_update_GNB2_HD006 = [
#     {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
# ]

parameters_to_recover_GNB3_HD006 = [
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
]

LIST_TO_ONLINE_ADD_GNB1_HD006 = [
    dict(value=[dict(ipV6AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname + '/SNSSAI-2',
         parameter='xgUplane')
]

PARAMETERS_TO_DELETE_GNB1_HD006 = [
    dict(dist_name=_NRBTSname + '/SNSSAI-2', parameter='xgUplane')
]

MOS_ADD_GNB3_GG004 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL311, version="NRBTSCL22R4_2210_100"),
]

LIST_TO_ADD_GNB3_GG004 = [
    dict(
        dist_name=_NRREL311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')
    ),
    dict(
        dist_name=_NRBTSname3 + '/NRDU-1',
        list_name='xgUplane',
        elements=dict(
            ipV6AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')
    )
]


PARAMETERS_TO_MODIFY_GNB3_GG004 = [
    dict(value='notBarred', dist_name=_NRCELL31, p_name='cellBarred'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL311, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL311, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL311, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL311, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
]

PARAMETERS_TO_DELETE_GNB3_GG004 = [
    dict(dist_name=_NRBTSname3+'/NRDU-1', list_name='xgUplane')
]

LIST_TO_ADD_GNB4_GG004 = [
    dict(
        dist_name=_NRBTSname4 + '/NRDU-1',
        list_name='xgUplane',
        elements={'ipV6AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}
    ),
    dict(
        dist_name=_NRBTSname4 + '/SNSSAI-1',
        list_name='xgUplane',
        elements={'ipV6AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}
    ),
    dict(
        dist_name=_NRBTSname4 + '/SNSSAI-2',
        list_name='xgUplane',
        elements={'ipV6AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}
    )
]

PARAMETERS_TO_MODIFY_GNB3_GG004_2 = [
    dict(value='true', dist_name=_NRBTSname3, p_name='actTrsSepaSARanSharing'),
    dict(value='1', dist_name=_NRBTSname3 + '/SERVEDAMF-1', p_name='ngTnlId'),
    dict(value='1', dist_name=_NRBTSname3, p_name='xnTnlId'),
    dict(value='1', dist_name=_NRBTSname3 + '/XNLINK-11', p_name='xnTnlId'),
    dict(value='1', dist_name=_NRBTSname3 + '/XNLINK-14', p_name='xnTnlId'),
    dict(value='notBarred', dist_name=_NRCELL31, p_name='cellBarred'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL311, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL311, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL311, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL311, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
]

LIST_TO_ADD_GNB3_GG004_2 = [
    dict(
        dist_name=_NRREL311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')
    ),
    dict(
        dist_name=_NRBTSname3,
        list_name='ngUplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            nrPlmnDN=_NRPLMN_31)
    ),
    dict(
        dist_name=_NRBTSname3,
        list_name='ngUplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            nrPlmnDN=_NRPLMN_32)
    ),
    dict(
        dist_name=_NRBTSname3,
        list_name='ngCplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            ngTnlId='1')
    ),
    dict(
        dist_name=_NRBTSname3,
        list_name='xnCplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            xnTnlId='1')
    ),
    dict(
        dist_name=_NRBTSname3,
        list_name='xnUplane',
        elements=dict(
            ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
            nrPlmnDN=_NRPLMN_31)
    ),
    dict(
        dist_name=_NRBTSname3 + '/NRDU-1',
        list_name='xgUplane',
        elements=dict(
            ipV6AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1',
            nrPlmnDN=_NRPLMN_31)
    )
]

PARAMETERS_TO_DELETE_GNB3_GG004_2 = [
    dict(dist_name=_NRBTSname3, list_name='ngUplane'),
    dict(dist_name=_NRBTSname3, list_name='ngCplane'),
    dict(dist_name=_NRBTSname3, list_name='xnCplane'),
    dict(dist_name=_NRBTSname3, list_name='xnUplane'),
    dict(dist_name=_NRBTSname3 + '/NRDU-1', list_name='xgUplane')
]

PARAMETERS_TO_ADD_NRREL_GNB1_GF003 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_NRREL_GNB1_GF005 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='12', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003 = [
    {'dist_name': _NRBTSname, 'parameter': 'rejectSuppBcs', 'value': 'BCS4'},
    {'dist_name': _NRCELL11, 'parameter': 'allowUnsuppBcOrBcs', 'value':
        ['accept unknown band combinations', 'accept unknown BCSs']},
    {'dist_name': _NRBTSname, 'parameter': 'actBcsCheck', 'value': 'disabled'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB2_GF003 = [
    {'dist_name': _NRBTSname2, 'parameter': 'rejectSuppBcs', 'value': 'none'},
    {'dist_name': _NRBTSname2, 'parameter': 'actBcsCheck', 'value': 'enabled_FR1'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_1 = [
    {'dist_name': _NRBTSname, 'parameter': 'actBcsCheck', 'value': 'disabled'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_2 = [
    {'dist_name': _NRBTSname, 'parameter': 'actBcsCheck', 'value': 'enabled_FR1'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_3 = [
    {'dist_name': _NRBTSname, 'parameter': 'actBcsCheck', 'value': 'enabled_NRDC'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_GF003_4 = [
    {'dist_name': _NRBTSname, 'parameter': 'actBcsCheck', 'value': 'enabled_FR1+NRDC'}
]

PARAMETERS_TO_DELETE_GNB1_GF005 = [
    {'dist_name': _NRREL11},
    {'dist_name': _NRREL112}
]

MOS_ADD_GNB1_GJ001 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1112, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1113, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GJ001 = [
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL1111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1111, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL1111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1111, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL1111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1111, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL1111, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL1112, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1112, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL1112, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1112, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1112, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1112, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL1112, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1112, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1112, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1112, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL1112, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1112, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL1112, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL1113, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1113, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL1113, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1113, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1113, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1113, p_name='handoverAllowedSARedCap'),
    dict(value='11', dist_name=_NRREL1113, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1113, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1113, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1113, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL1113, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1113, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL1113, p_name='isRplCellForPSCell'),
    dict(value='rsrp', dist_name=_NRCELL111, p_name='a1MeasSCellAddEnabled'),
    dict(value='notBarred', dist_name=_NRCELL111, p_name='cellBarred')
]

LIST_TO_ADD_GNB1_GJ001 = [
    dict(
        dist_name=_NRREL1111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1112,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL1113,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL111,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='75',
            a1ThresholdSCellAddSsbRsrpTDD='75',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_GJ001 = [
    {'dist_name': _NRCELL311, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL311, 'parameter': 'a2MeasSCellRelEnabled', 'value': 'rsrp'},
    dict(value=[dict(nea0='9', nea1_128='0', nea2_128='0', nea3_128='0')], dist_name=_NRBTSname3,
         parameter='cipherPrefL')
]

PARAMETERS_TO_ONLINE_ADD_GNB3_GJ001 = [
    {'dist_name': _NRCELL311, 'parameter': 'a2MeasSCellRelSsbRsrp',
     'value': [{'a2HysteresisSCellRelSsbRsrp': '0', 'a2ThresholdSCellRelSsbRsrp': '56',
                'a2TimeToTriggerSCellRelSsbRsrp': '2560ms'}]}
]

MOS_ADD_GNB1_GH003 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL11, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB2_GH003 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL22, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GH003 = [
    dict(value='0dB', dist_name=_NRREL11, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL11, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, p_name='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL11, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL11, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL11, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, p_name='isRplCellForPSCell')
]

PARAMETERS_TO_MODIFY_GNB2_GH003 = [
    dict(value='0dB', dist_name=_NRREL22, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL22, p_name='gNbIdLength'),
    dict(value='XnHoNotAllowed', dist_name=_NRREL22, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL22, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL22, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL22, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL22, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL22, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL22, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL22, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL22, p_name='isRplCellForPSCell')
    # dict(value='Locked', dist_name=_NRCELL33, p_name='administrativeState')
]

LIST_TO_ADD_GNB1_GH003 = [
    dict(
        dist_name=_NRREL11,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_ADD_GNB2_GH003 = [
    dict(
        dist_name=_NRREL22,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

PARAMETERS_TO_UPDATE_GNB1_GH003_inter_HO = [
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRBTSname, 'parameter': 'actIntraNrNgHo', 'value': 'sourceAndTarget'},
    {'dist_name': _NRBTSname, 'parameter': 'suppCnPartialAdNgHo', 'value': 'true'},
    {'dist_name': _NRBTSname, 'parameter': 'actIntraFreqHoSA', 'value': 'true'},
    {'dist_name': _NRBTSname, 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': _NRBTSname, 'parameter': 'tNgRelocCancelN', 'value': '2000'},
    {'dist_name': _NRBTSname, 'parameter': 'tNgRelocExecDeltN', 'value': '3000'},
    {'dist_name': _NRBTSname, 'parameter': 'tNgRelocOverallN', 'value': '2000'},
    {'dist_name': _NRBTSname, 'parameter': 'tNgRelocPrepN', 'value': '3000'},
    # {'dist_name': _NRBTSname, 'parameter': 'actSliceSwitchToDefault', 'value': 'true'}
]

PARAMETERS_TO_ADD_GNB1_GH003_inter_HO = [
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='XnHoNotAllowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='3', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_GNB2_GH003_inter_HO = [
    {'dist_name': _NRBTSname2, 'parameter': 'actIntraNrNgHo', 'value': 'sourceAndTarget'},
    {'dist_name': _NRBTSname2, 'parameter': 'suppCnPartialAdNgHo', 'value': 'true'},
    {'dist_name': _NRBTSname2, 'parameter': 'actIntraFreqHoSA', 'value': 'true'},
    {'dist_name': _NRBTSname2, 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': _NRBTSname2, 'parameter': 'tNgRelocCancelN', 'value': '2000'},
    {'dist_name': _NRBTSname2, 'parameter': 'tNgRelocExecDeltN', 'value': '3000'},
    {'dist_name': _NRBTSname2, 'parameter': 'tNgRelocOverallN', 'value': '2000'},
    {'dist_name': _NRBTSname2, 'parameter': 'tNgRelocPrepN', 'value': '3000'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'notBarred'},
    # {'dist_name': _NRBTSname2, 'parameter': 'actSliceSwitchToDefault', 'value': 'true'}
]

PARAMETERS_TO_recover_GNB2_GH003 = [
    {'dist_name': _NRCELL33, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_DELETE_GNB2_CB0130552 = [
    dict(dist_name=_NRTAC_20200_2, parameter='snssaiList')
]

LIST_TO_ADD_GNB2_CB0130552 = [
    dict(value=[dict(snssaiDN=_NRBTSname2 + '/SNSSAI-3')],
         dist_name=_NRTAC_20200_2, parameter='snssaiList')
]

PARAMETERS_TO_enable_GNB2_CB0130552 = [
    {'dist_name': _NRBTSname2, 'parameter': 'actSliceSwitchToDefault', 'value': 'true'}
]

PARAMETERS_TO_enable_GNB1_CB0130552 = [
    {'dist_name': _NRBTSname, 'parameter': 'actSliceSwitchToDefault', 'value': 'true'}
]

MOS_ADD_GNB1_GH006 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL12, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL121, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GH006 = [
    dict(value='0dB', dist_name=_NRREL12, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL12, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL12, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL12, p_name='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL12, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL12, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL12, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL12, p_name='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL121, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL121, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL121, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL121, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL121, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL121, p_name='handoverAllowedSARedCap'),
    dict(value='3', dist_name=_NRREL121, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL121, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL121, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL121, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL121, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL121, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL121, p_name='isRplCellForPSCell')
]

LIST_TO_ADD_GNB1_GH006 = [
    dict(
        dist_name=_NRREL12,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL121,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

PARAMETERS_TO_MODIFY_GNB2_GH006 = [
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELL231, p_name='dlMimoMode')
]

Parameter_Delete_GNB2_GH006 = [
    dict(dist_name=_NRCELL231, list_name='periodicCsiAcquisition')
]

LIST_TO_ADD_GNB2_GH006 = [
    dict(
        dist_name=_NRCELL231,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

PARAMETERS_TO_ADD_GNB1_GH006_DRX = [
    dict(value=[dict(drxHarqRttTimerDl='0symbols', drxHarqRttTimerUl='0symbols', drxInactivityTimer='4ms',
                     drxLongCycle='40ms', drxOnDurationTimer='6ms', drxRetransTimerDl='0slot',
                     drxRetransTimerUl='0slot')],
         dist_name=_NRCELL12, parameter='drxProfile2')
]

PARAMETERS_TO_UPDATE_GNB1_GH006_DRX = [
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL12, 'parameter': 'actCDrxVoNR', 'value': 'true'},
    {'dist_name': _NRCELL12, 'parameter': 'voNRNrDrxDN', 'value': _NRBTSname + '/NRDRX-6'},
    {'dist_name': _NRCELL12, 'parameter': 'nonGbrNrDrxDN', 'value': _NRBTSname + '/NRDRX-4'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxInactivityTimer', 'value': '80ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxLongCycle', 'value': '160ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxOnDurationTimer', 'value': '10ms'},
    {'dist_name': _NRBTSname + '/NRDRX-6', 'parameter': 'drxInactivityTimer', 'value': '4ms'},
    {'dist_name': _NRBTSname + '/NRDRX-6', 'parameter': 'drxLongCycle', 'value': '40ms'},
    {'dist_name': _NRBTSname + '/NRDRX-6', 'parameter': 'drxOnDurationTimer', 'value': '6ms'}
]

PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_trunk = [
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL12, 'parameter': 'actCDrxVoNR', 'value': 'true'},
    {'dist_name': _NRCELL12, 'parameter': 'voNRNrDrxDN', 'value': _NRBTSname + '/NRDRX-4'},
    {'dist_name': _NRCELL12, 'parameter': 'nonGbrNrDrxDN', 'value': _NRBTSname + '/NRDRX-1'},
    {'dist_name': _NRBTSname + '/NRDRX-1', 'parameter': 'drxInactivityTimer', 'value': '80ms'},
    {'dist_name': _NRBTSname + '/NRDRX-1', 'parameter': 'drxLongCycle', 'value': '160ms'},
    {'dist_name': _NRBTSname + '/NRDRX-1', 'parameter': 'drxOnDurationTimer', 'value': '10ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxInactivityTimer', 'value': '4ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxLongCycle', 'value': '40ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxOnDurationTimer', 'value': '6ms'}
]

PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_HI = [
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxInactivityTimer', 'value': '3ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxLongCycle', 'value': '40ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxOnDurationTimer', 'value': '10ms'},
    {'dist_name': _NRBTSname + '/NRDRX-6', 'parameter': 'drxInactivityTimer', 'value': '3ms'},
    {'dist_name': _NRBTSname + '/NRDRX-6', 'parameter': 'drxLongCycle', 'value': '20ms'},
    {'dist_name': _NRBTSname + '/NRDRX-6', 'parameter': 'drxOnDurationTimer', 'value': '4ms'}
]

PARAMETERS_TO_UPDATE_GNB1_GH006_DRX_HI_trunk = [
    {'dist_name': _NRBTSname + '/NRDRX-1', 'parameter': 'drxInactivityTimer', 'value': '3ms'},
    {'dist_name': _NRBTSname + '/NRDRX-1', 'parameter': 'drxLongCycle', 'value': '40ms'},
    {'dist_name': _NRBTSname + '/NRDRX-1', 'parameter': 'drxOnDurationTimer', 'value': '10ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxInactivityTimer', 'value': '3ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxLongCycle', 'value': '20ms'},
    {'dist_name': _NRBTSname + '/NRDRX-4', 'parameter': 'drxOnDurationTimer', 'value': '4ms'}
]

MOS_ADD_GNB1_GF003 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL11, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GF003 = [
    dict(value='0dB', dist_name=_NRREL11, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL11, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL11, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL11, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL11, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL11, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL11, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),
    dict(value='BCS4', dist_name=_NRBTSname, p_name='rejectSuppBcs'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBcsCheck')
]

PARAMETERS_TO_DELETE_GNB1_GF003 = [
    dict(dist_name=_NRCELL11, list_name='allowUnsuppBcOrBcs')
]

LIST_TO_ADD_GNB1_GF003 = [
    dict(
        dist_name=_NRREL11,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(elements=['accept unknown band combinations', 'accept unknown BCSs'],
         dist_name=_NRCELL11, list_name='allowUnsuppBcOrBcs')
]

PARAMETERS_TO_MODIFY_GNB2_GF003 = [
     dict(value='none', dist_name=_NRBTSname4, p_name='rejectSuppBcs'),
     dict(value='enabled_FR1', dist_name=_NRBTSname4, p_name='actBcsCheck')
]

PARAMETERS_TO_MODIFY_GNB1_GF005 = [
    dict(value='424300', dist_name=_NRCELL12 + '/NRCELL_FDD-1', p_name='nrarfcnDl')
]

MOS_ADD_GNB4_GF005 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL41, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL412, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB4_GF005 = [
    dict(value='0dB', dist_name=_NRREL41, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL41, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL41, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL41, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL41, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL41, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL41, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL41, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL41, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL41, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL41, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL41, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL41, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL412, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL412, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL412, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL412, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL412, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL412, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL412, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL412, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL412, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL412, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL412, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL412, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL412, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL41, p_name='cellBarred'),
    dict(value='none', dist_name=_NRBTSname4, p_name='rejectSuppBcs'),
    dict(value='enabled_FR1', dist_name=_NRBTSname4, p_name='actBcsCheck'),
    dict(value='424300', dist_name=_NRBTSname4 + '/NRADJNRCELL-12', p_name='nrarfcn'),
    dict(value='428200', dist_name=_NRCELL41 + '/NRCELL_FDD-1', p_name='nrarfcnDl')
]

PARAMETERS_TO_DELETE_GNB4_GF005 = [
    dict(dist_name=_NRCELL41, list_name='allowUnsuppBcOrBcs')
]

LIST_TO_ADD_GNB4_GF005 = [
    dict(
        dist_name=_NRREL41,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL412,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(elements=['accept unknown band combinations', 'accept unknown BCSs'],
         dist_name=_NRCELL41, list_name='allowUnsuppBcOrBcs')
]

MOS_ADD_GNB1_GB006 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1111, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB2_GB006 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL2111, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB1_GB006 = [
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL1111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1111, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL1111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1111, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL1111, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL111, p_name='cellBarred'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCaDuCp'),
    dict(value='428100', dist_name=_NRBTSname + '/NRADJNRCELL-211', p_name='nrarfcn'),
    dict(value='true', dist_name=_NRCELL111, p_name='actEnhMultipleDedicatedBWPs'),
    dict(value='false', dist_name=_NRCELL111, p_name='actCaContCalcMaxAllowedScsFr1'),
    dict(value='24', dist_name=_NRCELL111, p_name='msg1FrequencyStart'),
]

PARAMETERS_TO_MODIFY_GNB2_GB006 = [
    dict(value='0dB', dist_name=_NRREL2111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL2111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL2111, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL2111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL2111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL2111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL2111, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL2111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL2111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL2111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL2111, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL2111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL2111, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL211, p_name='cellBarred'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrCaDuCp'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrCCD'),
    dict(value='true', dist_name=_NRCELL211, p_name='actEnhMultipleDedicatedBWPs'),
    dict(value='false', dist_name=_NRCELL211, p_name='actCaContCalcMaxAllowedScsFr1'),
    dict(value='14', dist_name=_NRCELL211, p_name='msg1FrequencyStart'),
    dict(value='428100', dist_name=_NRCELL211 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
]

PARAMETERS_TO_DELETE_GNB1_GB006 = [
    dict(dist_name=_NRCELL111, list_name='cellBwpList'),
    dict(dist_name=_NRCELL111, list_name='pdcchAutoConfig')
]

PARAMETERS_TO_DELETE_GNB2_GB006 = [
    dict(dist_name=_NRCELL211, list_name='cellBwpList'),
    dict(dist_name=_NRCELL211, list_name='pdcchAutoConfig')
]

LIST_TO_MODIFY_GNB1_GB006 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='3', index=0),
                   dict(p_name='nea2_128', value='4', index=0),
                   dict(p_name='nea3_128', value='3', index=0)])
]

LIST_TO_MODIFY_GNB2_GB006 = [
    dict(dist_name=_NRBTSname2, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='3', index=0),
                   dict(p_name='nea2_128', value='4', index=0),
                   dict(p_name='nea3_128', value='3', index=0)])
]

LIST_TO_ADD_GNB1_GB006 = [
    dict(
        dist_name=_NRREL1111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-200',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-211',
            cellBwpId='1',
            pdcchResourcePreference='peakRate'
        )
    ),
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-10300',
            cellBwpId='2',
            pdcchResourcePreference='peakRate'
        )
    ),
    dict(
        dist_name=_NRCELL111,
        list_name='pdcchAutoConfig',
        elements=dict(
            bwpChBwDedicated2='15MHz',
            cellCoverageLevel='normal',
            fineTuneMode='disabled',
            initialBWPMode='sameAsCoreset0',
            pucchSize='10'
        )
    ),
]

LIST_TO_ADD_GNB2_GB006 = [
    dict(
        dist_name=_NRREL2111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL211,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-44',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL211,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-377',
            cellBwpId='1',
            pdcchResourcePreference='peakRate'
        )
    ),
    dict(
        dist_name=_NRCELL211,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-10032',
            cellBwpId='2',
            pdcchResourcePreference='peakRate'
        )
    ),
    dict(
        dist_name=_NRCELL211,
        list_name='pdcchAutoConfig',
        elements=dict(
            bwpChBwDedicated2='15MHz',
            cellCoverageLevel='normal',
            fineTuneMode='disabled',
            initialBWPMode='sameAsCoreset0',
            pucchSize='10'
        )
    ),
]

MO_TO_ONLINE_ADD_GNB3_GB007 = [
    dict(value='0dB', dist_name=_NRREL131, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL131, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL131, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL131, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL131, parameter='handoverAllowedSA'),
    dict(value='31', dist_name=_NRREL131, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL131, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL131, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL131, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL131, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL131, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL131, parameter='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL131, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL131, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GB007 = [
    dict(value='notBarred', dist_name=_NRCELL431, parameter='cellBarred')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GB012 = [
    dict(value='notBarred', dist_name=_NRCELL41, parameter='cellBarred')
]

MO_TO_ONLINE_ADD_GNB4_GB012 = [
    dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL41, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL41, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL41, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL41, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL41, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL41, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL41, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL41, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL41, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL41, parameter='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL41, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL41, parameter='gnbPlmn')
]
