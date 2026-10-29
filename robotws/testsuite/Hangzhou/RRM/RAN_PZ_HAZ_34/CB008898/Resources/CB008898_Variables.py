from robot.libraries.BuiltIn import BuiltIn
import time
from datetime import datetime

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_mncLength = len(_mnc)
_MRBTSname = 'MRBTS-' + _global_id
# _MRBTSname = 'MRBTS-' + _gnb_id
_NRBTSnames = 'NRBTS-' + _gnb_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb_id

_NRCELL11 = _NRBTSname + '/NRCELL-1'
_NRCELL12 = _NRBTSname + '/NRCELL-2'
_NRREL11 = _NRCELL11 + '/NRREL-1'
_NRREL12 = _NRCELL12 + '/NRREL-1'
_NRCELL1_CHGP_2 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2'
_NRCELL2_CHGP_2 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2'
_RMOD1_PHYANT = _MRBTSname + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1'

year = time.localtime().tm_year
month = time.localtime().tm_mon
day = time.localtime().tm_mday
date = datetime.date(datetime(year=year, month=month, day=day))
weekday = date.strftime("%a")

ParamterToModify_8898_based = [
    dict(value='false', dist_name=_NRCELL11, p_name='actDlSrsForCA'),
    dict(value='false', dist_name=_NRCELL12, p_name='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL11, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL12, p_name='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL11, p_name='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL12, p_name='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrExtCellSOMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrLBmMimoRTXPowerSaving'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrMixedSOMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrLBPowerSaving'),
    dict(value='false', dist_name=_NRBTSname, p_name='actLbpsCtrlLogicEnh'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actCoordinated4g5gPowerSaving'),
    dict(value='TX switch off', dist_name=_NRBTSname + '/NRPGRP-1', p_name='lbpsSOMethod'),
    dict(value='MaxValueMethod', dist_name=_NRBTSname + '/NRPGRP-1', p_name='lbpsSOffTrRule'),
    dict(value='MaxValueMethod', dist_name=_NRBTSname + '/NRPGRP-2', p_name='lbpsSOffTrRule'),
    dict(value='MinValueMethod', dist_name=_NRBTSname + '/NRPGRP-1', p_name='lbpsSOnTrRule'),
    dict(value='MinValueMethod', dist_name=_NRBTSname + '/NRPGRP-2', p_name='lbpsSOnTrRule'),
    dict(value='intra-gNB', dist_name=_NRCELL11, p_name='actK1Opt'),
    dict(value='intra-gNB', dist_name=_NRCELL12, p_name='actK1Opt'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSname + '/NRDU-1', p_name='actConnectedModeMobilityCA'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSname + '/NRDU-1', p_name='flexibleCAMode'),
    dict(value='true', dist_name=_NRBTSname + '/NRDU-1', p_name='actInterNumerologyCa'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCellUtilization'),
    dict(value='barred', dist_name=_NRCELL12, p_name='cellBarred'),
]

ListToAdd_8898_based = [
    dict(
        dist_name=_NRCELL11,
        list_name='allowUnsuppBcOrBcs',
        elements=['complete BCS check']),
    dict(
        dist_name=_NRCELL12,
        list_name='allowUnsuppBcOrBcs',
        elements=['complete BCS check']),
    dict(
        dist_name=_NRBTSname + '/NRDU-1',
        list_name='carrierAggregationSupportList',
        elements=['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Fdd_Sa', 'ca_Fr1Tdd_Any_Sa']),
]

ParameterToDelete_8898_based = [
    dict(
        dist_name=_NRBTSname + '/NRDU-1',
        list_name='carrierAggregationSupportList'),
]

Modify_Para_Online_8898_A004 = [
    dict(value='true', dist_name=_NRCELL11, parameter='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL12, parameter='actDlSrsForCA'),
]

Add_Mo_Online_NRREL = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc=_mcc, mnc=_mnc, mncLength=_mncLength)],
         dist_name=_NRREL11, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc=_mcc, mnc=_mnc, mncLength=_mncLength)],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

Modify_Para_Online_2200_Open = [
    dict(value='8x4 Closed Loop Spatial Multiplexing', dist_name=_NRCELL12, parameter='dlMimoMode'),
]

Modify_Para_Online_2200_Close = [
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELL12, parameter='dlMimoMode'),
]

ParameterToDelete_2200_Close = [
    dict(dist_name=_NRCELL12, parameter='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL12, parameter='csirsResourceSet')
]

LIST_TO_ADD_2200_10175 = [
    dict(value=[dict(csirsNumberWithinReportPeriod_Set1='3', csirsPower='6', maxCsirsNumber='4')],
         dist_name=_NRCELL12, parameter='periodicCsiAcquisition'),
    dict(value=[dict(csirsResourceSetConfig1CRI='gNB SW default operation',
                     csirsResourceSetConfig2CRI='gNB SW default operation',
                     csirsResourceSetConfig4CRI='gNB SW default operation')],
         dist_name=_NRCELL12, parameter='csirsResourceSet')
]

LIST_TO_ADD_2200_36411 = [
    dict(value=[dict(csirsNumberWithinReportPeriod_Set1='1', csirsPower='18', maxCsirsNumber='4')],
         dist_name=_NRCELL12, parameter='periodicCsiAcquisition')
]

LIST_TO_ADD_2200_1_10175 = [
    dict(value=[dict(csirsNumberWithinReportPeriod_Set1='3', csirsPower='6', maxCsirsNumber='4')],
         dist_name=_NRCELL12, parameter='periodicCsiAcquisition'),
    dict(value=[dict(csirsResourceSetConfig1CRI='gNB SW default operation',
                     csirsResourceSetConfig2CRI='gNB SW default operation',
                     csirsResourceSetConfig4CRI='gNB SW default operation')],
         dist_name=_NRCELL12, parameter='csirsResourceSet')
]

LIST_TO_ADD_2200_1_36411 = [
    dict(value=[dict(csirsNumberWithinReportPeriod_Set1='1', csirsPower='18', maxCsirsNumber='4')],
         dist_name=_NRCELL12, parameter='periodicCsiAcquisition')
]

List_TO_ADD_2200_Close = [
    dict(
        dist_name=_NRCELL12,
        parameter='periodicCsiAcquisition',
        value=[dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3')])
]

List_TO_ADD_2200_Close_1 = [
    dict(
        dist_name=_NRCELL12,
        parameter='periodicCsiAcquisition',
        value=[dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3')])
]

Modify_Para_Online_L_R_EdgeAngle_10175 = [
    dict(value=[dict(leftEdgeAngle='45', rightEdgeAngle='45')], dist_name=_NRCELL12, parameter='beamSet'),
]

Modify_Para_Online_L_R_EdgeAngle_36411 = [
    dict(value=[dict(leftEdgeAngle='60', rightEdgeAngle='60')], dist_name=_NRCELL12, parameter='beamSet'),
]

Modify_Para_Online_up_lo_EdgeAngle_10175 = [
    dict(value=[dict(leftEdgeAngle='60', rightEdgeAngle='60', lowerEdgeAngle='100', upperEdgeAngle='59')],
         dist_name=_NRCELL12, parameter='beamSet'),
]

Modify_Para_Online_up_lo_EdgeAngle_36411 = [
    dict(value=[dict(leftEdgeAngle='45', rightEdgeAngle='45', lowerEdgeAngle='100', upperEdgeAngle='70')],
         dist_name=_NRCELL12, parameter='beamSet'),
]

Modify_Para_Online_Recover_EdgeAngle_10175 = [
    dict(value=[dict(leftEdgeAngle='60', rightEdgeAngle='60', lowerEdgeAngle='120', upperEdgeAngle='60')],
         dist_name=_NRCELL12, parameter='beamSet'),
]

Modify_Para_Online_Recover_EdgeAngle_36411 = [
    dict(value=[dict(leftEdgeAngle='45', rightEdgeAngle='45', lowerEdgeAngle='135', upperEdgeAngle='80')],
         dist_name=_NRCELL12, parameter='beamSet'),
]

Modify_Para_Online_8133 = [
    dict(value='true', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
    dict(value=[dict(lbpsDayOfWeek=weekday, lbpsDuration=1440)],
         dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsPeriodList'),
    dict(value=[dict(lbpsDayOfWeek=weekday, lbpsDuration=1440)],
         dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsPeriodList')
]

Modify_Para_Online_Pscell_EnergySaving = [
    dict(value=300, dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsRTXSOnTime'),
    dict(value=300, dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsRTXSOnTime'),
]

Modify_Para_Online_Pcell_exit_EnergySaving = [
    dict(value=30, dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsRTXSOnTime'),
]

Modify_Para_Online_Pcell_enter_EnergySaving = [
    dict(value=300, dist_name=_NRBTSname + '/NRPGRP-1', parameter='lbpsRTXSOnTime'),
    dict(value=30, dist_name=_NRBTSname + '/NRPGRP-2', parameter='lbpsRTXSOnTime')
]

Modify_Para_Online_8133_close = [
    dict(value='false', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
]

Delete_Mo_Online_8133 = [
    dict(dist_name=_NRBTSname + '/NRPGRP-2')
]

Modify_Para_Online_A001_Recover = [
    dict(value='false', dist_name=_NRBTSname, parameter='actNrLBmMimoRTXPowerSaving'),
]

Modify_Para_Online_A_B2_004 = [
    dict(value='false', dist_name=_NRCELL12, parameter='actDlSrsForCA'),
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
]

Modify_Para_Online_A_B2_004_1 = [
    dict(value='true', dist_name=_NRCELL12, parameter='actDlSrsForCA'),
]

Modify_Para_Online_A_B2_005_10175 = [
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value=[dict(srsPowerThresholdForDlBm='-1120')],
         dist_name=_NRCELL11, parameter='srsForBeamMgmt'),
    dict(value=[dict(srsPowerThresholdForDlBm='-1170')],
         dist_name=_NRCELL12, parameter='srsForBeamMgmt')
]

Modify_Para_Online_A_B2_005_36411 = [
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value=[dict(srsPowerThresholdForDlBm='-1050')],
         dist_name=_NRCELL11, parameter='srsForBeamMgmt'),
    dict(value=[dict(srsPowerThresholdForDlBm='-1050')],
         dist_name=_NRCELL12, parameter='srsForBeamMgmt')
]

counter_id_A004 = [
    'M55308C34004'
]

dic_path_A004_CELL1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NCELA',
]

dic_path_A004_CELL2 = [
    'BTS/' + _NRBTSname + '/NRCELL-2/NCELA',
]

ParamterToModify_8898_B001 = [
    dict(value='true', dist_name=_NRCELL11, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL12, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL11, p_name='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL12, p_name='actDlMuMimoEnh'),
    dict(value='true', dist_name=_NRCELL11, p_name='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL12, p_name='actDlSrsForCA'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrExtCellSOMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrLBmMimoRTXPowerSaving'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrMixedSOMethod'),
    dict(value='false', dist_name=_NRBTSname, p_name='actNrLBPowerSaving'),
    dict(value='false', dist_name=_NRBTSname, p_name='actLbpsCtrlLogicEnh'),
    dict(value='false', dist_name=_NRCELL11, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='false', dist_name=_NRCELL12, p_name='actUeCsirsCoexistCellCsirs'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actCoordinated4g5gPowerSaving'),
    dict(value='TX switch off', dist_name=_NRBTSname + '/NRPGRP-1', p_name='lbpsSOMethod'),
    dict(value='SlidingAverageMethod', dist_name=_NRBTSname + '/NRPGRP-1', p_name='lbpsSOffTrRule'),
    dict(value='SlidingAverageMethod', dist_name=_NRBTSname + '/NRPGRP-2', p_name='lbpsSOffTrRule'),
    dict(value='MinValueMethod', dist_name=_NRBTSname + '/NRPGRP-1', p_name='lbpsSOnTrRule'),
    dict(value='MinValueMethod', dist_name=_NRBTSname + '/NRPGRP-2', p_name='lbpsSOnTrRule'),
    dict(value='intra-gNB', dist_name=_NRCELL11, p_name='actK1Opt'),
    dict(value='intra-gNB', dist_name=_NRCELL12, p_name='actK1Opt'),
    dict(value='bufferBased', dist_name=_NRBTSname, p_name='sCellActivationMethod'),
    dict(value='true', dist_name=_NRBTSname + '/NRDU-1', p_name='actConnectedModeMobilityCA'),
    dict(value='ConfigurationIndependent', dist_name=_NRBTSname + '/NRDU-1', p_name='flexibleCAMode'),
    dict(value='true', dist_name=_NRBTSname + '/NRDU-1', p_name='actInterNumerologyCa'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCellUtilization'),
    dict(value='barred', dist_name=_NRCELL12, p_name='cellBarred'),

    dict(value='false', dist_name=_NRCELL11, p_name='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELL12, p_name='actRat1Alloc'),
    dict(value='false', dist_name=_NRCELL11, p_name='actPrbLimForVoNrRat1'),
    dict(value='false', dist_name=_NRCELL12, p_name='actPrbLimForVoNrRat1'),
    dict(value='disabled', dist_name=_NRCELL11, p_name='actExhaustiveScheduling'),
    dict(value='disabled', dist_name=_NRCELL12, p_name='actExhaustiveScheduling'),
    dict(value='false', dist_name=_NRCELL11, p_name='actPtpMetric'),
    dict(value='false', dist_name=_NRCELL12, p_name='actPtpMetric'),
    dict(value='false', dist_name=_NRCELL11, p_name='actLAForHiReliab'),
    dict(value='false', dist_name=_NRCELL12, p_name='actLAForHiReliab'),

    dict(value='TX',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-1',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-1',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-2',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-2',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-3',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-3',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-4',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-4',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-1',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-1',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-2',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-2',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-3',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-3',
         p_name='resourceDN'),
    dict(value='TX',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-4',
         p_name='direction'),
    dict(value=_RMOD1_PHYANT,
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-4',
         p_name='resourceDN'),
    dict(value='30MHz', dist_name=_NRCELL11, p_name='chBw'),
    dict(value='30MHz', dist_name=_NRCELL12, p_name='chBw'),
    dict(value='8DL4UL', dist_name=_NRCELL11, p_name='nrCellType'),
    dict(value='8DL4UL', dist_name=_NRCELL12, p_name='nrCellType'),
    dict(value='14', dist_name=_NRCELL11, p_name='ssPbchBlockPower'),
    dict(value='14', dist_name=_NRCELL12, p_name='ssPbchBlockPower'),
    dict(value='514998', dist_name=_NRCELL12, p_name='nrarfcn'),
]

ParameterToDelete_8898_new = [
    dict(dist_name=_NRCELL11, p_name='percRedSEDlRat1VoNR'),
    dict(dist_name=_NRCELL12, p_name='percRedSEDlRat1VoNR'),
    dict(dist_name=_NRCELL11, list_name='cellBwpList'),
    dict(dist_name=_NRCELL12, list_name='cellBwpList'),
]

counter_id_B001 = [
    'M55308C34005', 'M55308C34006', 'M55308C34007', 'M55308C34008', 'M55308C34009', 'M55308C34010', 'M55308C34011',
    'M55308C34013', 'M55308C34028', 'M55308C34029'
]

dic_path_B001_CELL1 = [
    'BTS/'+_NRBTSname+'/NRCELL-1/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-1/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-1/NCELA',
    'BTS/'+_NRBTSname+'/NRCELL-1/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-1/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-1/NCELA',
    'BTS/'+_NRBTSname+'/NRCELL-1/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-1/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-1/NCELA',
    'BTS/'+_NRBTSname+'/NRCELL-1/NCELA'
]

dic_path_B001_CELL2 = [
    'BTS/'+_NRBTSname+'/NRCELL-2/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-2/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-2/NCELA',
    'BTS/'+_NRBTSname+'/NRCELL-2/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-2/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-2/NCELA',
    'BTS/'+_NRBTSname+'/NRCELL-2/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-2/NCELA', 'BTS/'+_NRBTSname+'/NRCELL-2/NCELA',
    'BTS/'+_NRBTSname+'/NRCELL-2/NCELA'
]

Modify_Para_Online_cell1_attach_10175 = [
    dict(value='-52', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-22', dist_name=_NRCELL12, parameter='qRxLevMin'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred')
]

Modify_Para_Online_cell1_attach_36411 = [
    dict(value='-40', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-22', dist_name=_NRCELL12, parameter='qRxLevMin'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred')
]

Modify_Para_Online_cell2_attach_10175 = [
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value='-30', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-52', dist_name=_NRCELL12, parameter='qRxLevMin')
]

Modify_Para_Online_cell2_attach_36411 = [
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value='-39', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-52', dist_name=_NRCELL12, parameter='qRxLevMin')
]

Modify_Para_Online_attach_threshold_recover = [
    dict(value='-52', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-52', dist_name=_NRCELL12, parameter='qRxLevMin'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred')
]

Modify_Para_Online_attach_10175 = [
    dict(value='-31', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-52', dist_name=_NRCELL12, parameter='qRxLevMin'),
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value='notBarred', dist_name=_NRCELL11, parameter='cellBarred'),
]

Modify_Para_Online_attach_36411 = [
    dict(value='-36', dist_name=_NRCELL11, parameter='qRxLevMin'),
    dict(value='-52', dist_name=_NRCELL12, parameter='qRxLevMin'),
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value='notBarred', dist_name=_NRCELL11, parameter='cellBarred'),
]

Modify_Para_Online_B_B1_004 = [
    dict(value='true', dist_name=_NRCELL11, parameter='actDlSrsForCA'),
    dict(value='false', dist_name=_NRCELL12, parameter='actDlSrsForCA'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred'),
]

Modify_Para_Online_pcell_actDlSrsForCA_off = [
    dict(value='false', dist_name=_NRCELL11, parameter='actDlSrsForCA')
]

Modify_Para_Online_scell_actDlSrsForCA_on = [
    dict(value='true', dist_name=_NRCELL12, parameter='actDlSrsForCA'),
]

Modify_Para_Online_B_B1_004_recover = [
    dict(value='true', dist_name=_NRCELL11, parameter='actDlSrsForCA'),
    dict(value='true', dist_name=_NRCELL12, parameter='actDlSrsForCA'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred'),
]

Modify_Para_Online_B_B1_010 = [
    dict(value='NoTapering', dist_name=_NRCELL11 + '/NRDLMUMIMO-1', parameter='dlMuMimoTaperingV'),
    dict(value='20dB', dist_name=_NRCELL12 + '/NRDLMUMIMO-1', parameter='dlMuMimoTaperingV'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred'),
]

Modify_Para_enable_RTbeam = [
    dict(value='true', dist_name=_NRCELL11, parameter='actDlSrsSubbandBm'),
    dict(value='true', dist_name=_NRCELL12, parameter='actDlSrsSubbandBm'),
    dict(value='4DL4UL', dist_name=_NRCELL11, parameter='nrCellType'),
    dict(value='4DL4UL', dist_name=_NRCELL12, parameter='nrCellType'),
    dict(value='NoTapering', dist_name=_NRCELL11 + '/NRDLMUMIMO-1', parameter='dlMuMimoTaperingV'),
    dict(value='NoTapering', dist_name=_NRCELL12 + '/NRDLMUMIMO-1', parameter='dlMuMimoTaperingV'),
    dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred'),
]

Modify_Para_Online_B_B1_010_recover = [
    # dict(value='false', dist_name=_NRCELL11, parameter='actDlSrsSubbandBm'),
    # dict(value='false', dist_name=_NRCELL12, parameter='actDlSrsSubbandBm'),
    dict(value='NoTapering', dist_name=_NRCELL11 + '/NRDLMUMIMO-1', parameter='dlMuMimoTaperingV'),
    dict(value='NoTapering', dist_name=_NRCELL12 + '/NRDLMUMIMO-1', parameter='dlMuMimoTaperingV')
    # dict(value='barred', dist_name=_NRCELL12, parameter='cellBarred'),
]

MostoADD_8898 = [
    dict(class_name='com.nokia.srbts.mnl:CHANNELGROUP',
         dist_name=_NRCELL1_CHGP_2,),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-1',),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-2', ),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-3', ),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL1_CHGP_2 + '/CHANNEL-4', ),
    dict(class_name='com.nokia.srbts.mnl:CHANNELGROUP',
         dist_name=_NRCELL2_CHGP_2, ),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-1', ),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-2', ),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-3', ),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL',
         dist_name=_NRCELL2_CHGP_2 + '/CHANNEL-4', ),
]

ListToAdd_8898 = [
    dict(
        dist_name=_NRCELL11,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-184',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL11,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-202',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL12,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-184',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL12,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='true',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-202',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
]

ListToModify_8898 = [
    dict(dist_name=_NRCELL11, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsPower', value='17', index=0)]),
    dict(dist_name=_NRCELL12, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsPower', value='17', index=0)]),
    dict(dist_name=_NRBTSname + '/NRPGRP-1', list_name='lbpsCellList',
         elements=[dict(p_name='lbpsUseExtConfig', value='false', index=0)]),
    dict(dist_name=_NRBTSname + '/NRPGRP-2', list_name='lbpsCellList',
         elements=[dict(p_name='lbpsUseExtConfig', value='false', index=0)]),
]
