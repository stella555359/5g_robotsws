from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb1_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-' + _gnb1_id
_NRBTSnames = 'NRBTS-' + _gnb1_id
_NRBTSname = _MRBTSname + '/NRBTS-' + _gnb1_id
_NRCELL11 = _NRBTSname + '/NRCELL-1'
_NRCELL12 = _NRBTSname + '/NRCELL-2'
_NRCELL13 = _NRBTSname + '/NRCELL-3'
_NRREL5 = _NRCELL12 + '/NRREL-1'

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-' + _gnb2_id
_NRBTSnames2 = 'NRBTS-' + _gnb2_id
_NRBTSname2 = _MRBTSname2 + '/NRBTS-' + _gnb2_id

_NRCELL21 = _NRBTSname2 + '/NRCELL-1'
_NRCELL22 = _NRBTSname2 + '/NRCELL-2'
_NRREL1 = _NRCELL21 + '/NRREL-1'
_NRREL2 = _NRCELL21 + '/NRREL-2'
_NRCELL211 = _NRBTSname2 + '/NRCELL-11'

_NRCELL23 = _NRBTSname2+'/NRCELL-3'
_NRCELL231 = _NRBTSname2+'/NRCELL-31'
_NRREL3 = _NRCELL231 + '/NRREL-1'
_NRREL4 = _NRCELL231 + '/NRREL-2'

Modify_Para_Online_CB010701_open = [
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', parameter='actUlCaWith3Tx'),
]

Modify_Para_Online_CB010701_close = [
    dict(value='false', dist_name=_NRBTSname2 + '/NRDU-1', parameter='actUlCaWith3Tx'),
]

parameters_to_update_GNB1_prepare = [
    dict(value='Locked', dist_name=_NRCELL11, parameter='administrativeState'),
]

parameters_to_update_GNB1_recover = [
    dict(value='Unlocked', dist_name=_NRCELL11, parameter='administrativeState'),
]

MOS_ADD_GNB1 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL5, version="NRBTSCL22R4_2210_100"),
]

MOS_ADD_GNB2 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL1, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL3, version="NRBTSCL22R4_2210_100"),
]

PARAMETERS_ONLINE_MODIFY_GNB1_AA_B3_001 = [
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL1, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL1, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL1, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL3, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL3, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL3, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL3, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL3, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL3, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL3, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL3, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL3, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL3, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='false', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='notBarred', dist_name=_NRCELL21, p_name='cellBarred'),
    dict(value='196', dist_name=_NRCELL231, p_name='prachConfigurationIndex'),
    dict(value='196', dist_name=_NRCELL23, p_name='prachConfigurationIndex'),
    dict(value='36', dist_name=_NRCELL231, p_name='pucchSize'),
]

LIST_TO_ADD_AA_B3_001 = [
    dict(
        dist_name=_NRREL1,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL3,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL23,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=_NRCELL231,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
]

PARAMS_TO_delete_AA_B3_001 = [
    dict(dist_name=_NRCELL231, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL23, list_name='tddFrameStructure'),
]

counter_id_AA_B3_001_attach = [
    'M55181C00013', 'M55181C00003', 'M55165C00039', 'M55118C00054'
]

dic_path_AA_B3_001_Pcell_attach = [
    'BTS/'+_NRCELL21+'/NUEQN', 'BTS/'+_NRCELL21+'/NUEQN', 'BTS/'+_NRCELL21+'/NRUC', 'BTS/'+_NRCELL21+'/NCAC'
]

dic_path_AB_B4_001_Pcell_attach = [
    'BTS/'+_NRCELL231+'/NUEQN', 'BTS/'+_NRCELL231+'/NUEQN', 'BTS/'+_NRCELL231+'/NRUC', 'BTS/'+_NRCELL231+'/NCAC'
]

dic_path_AB_B5_004_Pcell_attach = [
    'BTS/'+_NRCELL23+'/NUEQN', 'BTS/'+_NRCELL23+'/NUEQN', 'BTS/'+_NRCELL23+'/NRUC', 'BTS/'+_NRCELL23+'/NCAC'
]

counter_id_AA_B3_001_with_traffic = [
    'M55370C00038', 'M55370C00039', 'M55370C00040', 'M55302C15112', 'M55302C15113'
]

dic_path_AA_B3_001_with_traffic_TDD = [
    'BTS/'+_NRCELL231+'/NULH', 'BTS/'+_NRCELL231+'/NULH', 'BTS/'+_NRCELL231+'/NULH'
]

dic_path_AA_B3_001_with_traffic_FDD = [
    'BTS/'+_NRCELL21+'/NULH', 'BTS/'+_NRCELL21+'/NULH', 'BTS/'+_NRCELL21+'/NULH'
]

dic_path_AA_B3_001_with_traffic_TDD_gnb1 = [
    'BTS/'+_NRCELL13+'/NULH', 'BTS/'+_NRCELL13+'/NULH', 'BTS/'+_NRCELL13+'/NULH', 'BTS/'+_NRCELL13+'/NULHQ',
    'BTS/'+_NRCELL13+'/NULHQ'
]

dic_path_AA_B3_001_with_traffic_FDD_gnb1 = [
    'BTS/'+_NRCELL12+'/NULH', 'BTS/'+_NRCELL12+'/NULH', 'BTS/'+_NRCELL12+'/NULH', 'BTS/'+_NRCELL12+'/NULHQ',
    'BTS/'+_NRCELL12+'/NULHQ'
]

PARAMETERS_ONLINE_MODIFY_GNB1_AB_B4_001 = [
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL1, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL1, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL1, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL3, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL3, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL3, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL3, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL3, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL3, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL3, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL3, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL3, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL3, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='notBarred', dist_name=_NRCELL231, p_name='cellBarred'),
    dict(value='true', dist_name=_NRCELL231, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL231, p_name='actUlSrsBm'),
    dict(value='TypeB', dist_name=_NRCELL231, p_name='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL21, p_name='puschMappingType'),
    dict(value='0', dist_name=_NRCELL231, p_name='addExtDelayCompensation'),
    dict(value='157', dist_name=_NRCELL231, p_name='prachConfigurationIndex'),
    dict(value='0', dist_name=_NRCELL23, p_name='addExtDelayCompensation'),
    dict(value='157', dist_name=_NRCELL23, p_name='prachConfigurationIndex'),
    dict(value='rsrp', dist_name=_NRCELL231, p_name='a1MeasSCellAddEnabled'),
]

LIST_TO_ADD_AB_B4_001 = [
    dict(
        dist_name=_NRREL1,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL3,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL231,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=_NRCELL23,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=_NRCELL23,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-6',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL23,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-60',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL231,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-8',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL231,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-80',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL231,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='87',
            a1ThresholdSCellAddSsbRsrpTDD='87',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')
    )
]

PARAMETERS_ONLINE_MODIFY_GNB1_AA_B4_001 = [
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL1, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL1, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL1, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL3, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL3, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL3, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL3, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL3, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL3, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL3, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL3, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL3, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL3, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='notBarred', dist_name=_NRCELL21, p_name='cellBarred'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='true', dist_name=_NRCELL231, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL231, p_name='actUlSrsBm'),
    dict(value='TypeB', dist_name=_NRCELL23, p_name='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL231, p_name='puschMappingType'),
    dict(value='194', dist_name=_NRCELL23, p_name='prachConfigurationIndex'),
    dict(value='194', dist_name=_NRCELL231, p_name='prachConfigurationIndex'),
    dict(value='10', dist_name=_NRCELL231, p_name='msg1FrequencyStart'),
    dict(value='200', dist_name=_NRCELL231, p_name='maxNumOfCaUsersNRCell'),
]

LIST_TO_ADD_AA_B4_001 = [
    dict(
        dist_name=_NRREL1,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL3,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL231,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
    dict(
        dist_name=_NRCELL23,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='1/4')),
]

PARAMS_TO_delete_AA_B4_001 = [
    dict(dist_name=_NRCELL231, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL23, list_name='tddFrameStructure'),
]

PARAMETERS_ONLINE_MODIFY_GNB1_AA_B5_001 = [
    dict(value='0dB', dist_name=_NRREL5, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL5, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb1_id, dist_name=_NRREL5, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL5, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL5, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL5, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL5, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL5, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL5, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL5, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL5, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL5, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL5, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL12, p_name='cellBarred'),
    dict(value='true', dist_name=_NRBTSname + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='true', dist_name=_NRCELL13, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL13, p_name='actUlSrsBm'),
    dict(value='TypeB', dist_name=_NRCELL13, p_name='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL12, p_name='puschMappingType'),
    dict(value='196', dist_name=_NRCELL13, p_name='prachConfigurationIndex'),
    dict(value='10', dist_name=_NRCELL13, p_name='msg1FrequencyStart'),
    dict(value='200', dist_name=_NRCELL13, p_name='maxNumOfCaUsersNRCell'),
    dict(value='34', dist_name=_NRCELL13, p_name='pucchSize'),
    dict(value='10', dist_name=_NRCELL12, p_name='pucchSize'),
    dict(value='false', dist_name=_NRCELL12, p_name='actAdaptiveSr'),
    dict(value='false', dist_name=_NRCELL13, p_name='actAdaptiveSr'),
    dict(value='rsrp', dist_name=_NRCELL12, p_name='a1MeasSCellAddEnabled'),
    dict(value='77', dist_name=_NRCELL13, p_name='freqBandIndicatorNR'),
    dict(value='370', dist_name=_NRCELL13, p_name='pMax'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='disabled', dist_name=_NRBTSname, p_name='actSCellReleaseForInactiveSCell'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrUeQuan'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrResourceUtilizationPerCell'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrUlHarqOne'),
]

LIST_TO_ADD_AA_B5_001 = [
    dict(
        dist_name=_NRREL5,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL13,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='3ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=_NRCELL12,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='87',
            a1ThresholdSCellAddSsbRsrpTDD='87',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')
    )
]

PARAMS_TO_delete_AA_B5_001 = [
    dict(dist_name=_NRCELL13, list_name='tddFrameStructure'),
    # dict(dist_name=_NRCELL231, list_name='cellBwpList'),
]

PARAMETERS_MODIFY_GNB2_FOR_UL = [
    # dict(value=[dict(pucchSize='34')], dist_name=_NRCELL11, parameter='pdcchAutoConfig'),
    # dict(value=[dict(pucchSize='10')], dist_name=_NRCELL13, parameter='pdcchAutoConfig'),
    dict(value=[dict(p0NominalPusch='-82', p0NominalSrs='-80')],
         dist_name=_NRCELL21, parameter='ulPowerControlCommon'),
    dict(value='5', dist_name=_NRBTSname2 + '/NRDU-1', parameter='dlToUlContributionRatio'),
    dict(value=[dict(p0NominalPusch='-82', p0NominalSrs='-80')],
         dist_name=_NRCELL231, parameter='ulPowerControlCommon'),
]

PARAMETERS_MODIFY_GNB1_FOR_UL = [
    dict(value=[dict(p0NominalPusch='-82', p0NominalSrs='-80')],
         dist_name=_NRCELL12, parameter='ulPowerControlCommon'),
    dict(value='5', dist_name=_NRBTSname + '/NRDU-1', parameter='dlToUlContributionRatio'),
    dict(value=[dict(p0NominalPusch='-82', p0NominalSrs='-80')],
         dist_name=_NRCELL13, parameter='ulPowerControlCommon'),
]

PARAMETERS_ONLINE_MODIFY_B_B3_003 = [
    dict(value='notBarred', dist_name=_NRCELL23, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL21, p_name='cellBarred'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='true', dist_name=_NRCELL23, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL23, p_name='actUlSrsBm'),
    dict(value='TypeA', dist_name=_NRCELL23, p_name='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL21, p_name='puschMappingType'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrUeQuan'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrResourceUtilizationPerCell'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrUlHarqOne'),
    dict(value='9', dist_name=_NRCELL21, p_name='prachConfigurationIndex'),
    dict(value='194', dist_name=_NRCELL23, p_name='prachConfigurationIndex'),
    dict(value='194', dist_name=_NRCELL231, p_name='prachConfigurationIndex'),
    dict(value='6', dist_name=_NRCELL21, p_name='type0CoresetConfigurationIndex'),
    dict(value='4', dist_name=_NRCELL21, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='true', dist_name=_NRBTSname2, p_name='actCoverageNonCoherentUes'),
    dict(value='10MHz', dist_name=_NRCELL21, p_name='chBwDl'),
    dict(value='10MHz', dist_name=_NRCELL21, p_name='chBwUl'),
]

LIST_TO_ADD_B_B3_003 = [
    dict(
        dist_name=_NRCELL23,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=_NRCELL23,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-184',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL23,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-209',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL231,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=_NRCELL231,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-184',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL231,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-209',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL21,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-4',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL21,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-31',
            cellBwpId='1',
            pdcchResourcePreference='peakRate'))
]

counter_id_B_B3_003 = [
    'M55370C00038', 'M55370C00040',
]

dic_path_B_B3_003 = [
    'BTS/' + _NRCELL23 + '/NULH', 'BTS/' + _NRCELL23 + '/NULH'
]

counter_id_B_B3_003_1 = [
    'M55370C00039', 'M55370C00040'
]

dic_path_B_B3_003_1 = [
    'BTS/' + _NRCELL23 + '/NULH', 'BTS/' + _NRCELL21 + '/NULH'
]

counter_id_B_B3_003_1layer = [
    'M55370C00038', 'M55370C00039'
]

dic_path_B_B3_003_1layer = [
    'BTS/' + _NRCELL23 + '/NULH', 'BTS/' + _NRCELL23 + '/NULH'
]

counter_id_B_B3_003_1_1layer = [
    'M55370C00040', 'M55370C00040'
]

dic_path_B_B3_003_1_1layer = [
    'BTS/' + _NRCELL23 + '/NULH', 'BTS/' + _NRCELL21 + '/NULH'
]

PARAMS_TO_delete_AB_B5_004 = [
    dict(dist_name=_NRCELL21, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL21, list_name='cellBwpList')
]

PARAMETERS_ONLINE_MODIFY_AB_B5_004 = [
    dict(value='notBarred', dist_name=_NRCELL23, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL21, p_name='cellBarred'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='true', dist_name=_NRCELL23, p_name='actDlSrsBm'),
    dict(value='true', dist_name=_NRCELL23, p_name='actUlSrsBm'),
    dict(value='TypeB', dist_name=_NRCELL23, p_name='puschMappingType'),
    dict(value='TypeA', dist_name=_NRCELL21, p_name='puschMappingType'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrUeQuan'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrResourceUtilizationPerCell'),
    dict(value='5min', dist_name=_NRBTSname2 + '/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='280', dist_name=_NRCELL23, p_name='pMax'),
]

LIST_TO_MODIFY_AB_B5_004 = [
    dict(dist_name=_NRCELL23, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='3', index=0)]),
]

PARAMETERS_ONLINE_MODIFY_B_B4_004 = [
    dict(value='notBarred', dist_name=_NRCELL23, p_name='cellBarred'),
    dict(value='barred', dist_name=_NRCELL21, p_name='cellBarred'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='false', dist_name=_NRCELL23, p_name='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL231, p_name='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL23, p_name='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL231, p_name='actDlMuMimoEnh'),
    dict(value='false', dist_name=_NRCELL23, p_name='actUlSrsBm'),
    dict(value='false', dist_name=_NRCELL23, p_name='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL23, p_name='actAdaptiveReTxResMcsEnh'),
    dict(value='false', dist_name=_NRCELL231, p_name='actUlSrsBm'),
    dict(value='false', dist_name=_NRCELL231, p_name='actUlMuMimo'),
    dict(value='false', dist_name=_NRCELL231, p_name='actAdaptiveReTxResMcsEnh'),
    dict(value='TypeB', dist_name=_NRCELL23, p_name='puschMappingType'),
    dict(value='TypeB', dist_name=_NRCELL21, p_name='puschMappingType'),
    dict(value='9', dist_name=_NRCELL21, p_name='prachConfigurationIndex'),
    dict(value='194', dist_name=_NRCELL23, p_name='prachConfigurationIndex'),
    dict(value='194', dist_name=_NRCELL231, p_name='prachConfigurationIndex'),
    dict(value='6', dist_name=_NRCELL21, p_name='type0CoresetConfigurationIndex'),
    dict(value='4', dist_name=_NRCELL21, p_name='type0SearchSpaceConfigurationIndex'),
    dict(value='10MHz', dist_name=_NRCELL21 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='10MHz', dist_name=_NRCELL21 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='8', dist_name=_NRCELL23, p_name='ssPbchBlockPower'),
    dict(value='8', dist_name=_NRCELL231, p_name='ssPbchBlockPower'),
]

LIST_TO_MODIFY_B_B4_004 = [
    dict(dist_name=_NRCELL23, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='4', index=0),
                   dict(p_name='csirsPower', value='11', index=0),]),
    dict(dist_name=_NRCELL231, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='csirsNumberWithinReportPeriod_Set1', value='4', index=0),
                   dict(p_name='csirsPower', value='11', index=0), ])
]

PARAMS_TO_delete_B_B4_004 = [
    dict(dist_name=_NRCELL23, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL231, list_name='tddFrameStructure'),
    dict(dist_name=_NRCELL23, list_name='cellBwpList'),
    dict(dist_name=_NRCELL231, list_name='cellBwpList'),
    dict(dist_name=_NRCELL21, list_name='cellBwpList')
]

LIST_TO_ADD_B_B4_004 = [
    dict(
        dist_name=_NRCELL23,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=_NRCELL23,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-185',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL23,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-210',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL231,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='tdLte',
            guardPeriodLength='4Symbols',
            lteToNrFrameShift='0ms',
            tdLteUlDlConfig='tdLteConfig2',
            ulDlDataSlotRatio='2/8')),
    dict(
        dist_name=_NRCELL231,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-185',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL231,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-210',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')),
    dict(
        dist_name=_NRCELL21,
        list_name='cellBwpList',
        elements=dict(
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            actPdcchCceFragmentControl='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-4',
            cellBwpId='0',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL21,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname2 + '/BWP_PROFILE-31',
            cellBwpId='1',
            pdcchResourcePreference='peakRate'))
]

PARAMETERS_ONLINE_MODIFY_GNB2_B = [
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL1, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL1, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL1, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL1, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL1, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL1, p_name='isRplCellForPSCell'),
    dict(value='31', dist_name=_NRREL1, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL1, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL1, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL1, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL1, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL1, p_name='sCellOperationalMode'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL3, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL3, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL3, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL3, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL3, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL3, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL3, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL3, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL3, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL3, p_name='sCellAdditionMethod'),
    dict(value='dlAndUl', dist_name=_NRREL3, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL3, p_name='isRplCellForPSCell'),
    dict(value='notBarred', dist_name=_NRCELL231, p_name='cellBarred'),
    dict(value='196', dist_name=_NRCELL231, p_name='prachConfigurationIndex'),
    dict(value='196', dist_name=_NRCELL23, p_name='prachConfigurationIndex'),
    dict(value='36', dist_name=_NRCELL231, p_name='pucchSize'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', p_name='actUlCaWith3Tx'),
    dict(value='false', dist_name=_NRCELL231, p_name='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL231, p_name='actUlSrsBm'),
]

PARAMETERS_ONLINE_ADD_GNB2_B_B1_001_pre = [
    dict(value='0dB', dist_name=_NRREL4, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL4, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL4, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL4, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL4, parameter='handoverAllowedSA'),
    dict(value='3', dist_name=_NRREL4, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL4, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL4, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL4, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL4, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL4, parameter='handoverAllowedSARedCap'),
    dict(value='dlAndUl', dist_name=_NRREL4, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL4, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL4, parameter='gnbPlmn')
]

PARAMETERS_ONLINE_MODIFY_GNB2_B_B1_001 = [
    dict(value='covBasedA1', dist_name=_NRREL3, parameter='sCellAdditionMethod'),
    dict(value='5', dist_name=_NRCELL21, parameter='weightForSCellSelection'),
    dict(value='70', dist_name=_NRCELL23, parameter='weightForSCellSelection'),
]

PARAMETERS_TO_ADD_Parametre_GNB2_B_B1_001 = [
    {'dist_name': _NRCELL231, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL231, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '80',
                'a1ThresholdSCellAddSsbRsrpTDD': '95', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
]

PARAMETERS_ONLINE_MODIFY_B_B1_001_weight = [
    dict(value='100', dist_name=_NRCELL23, parameter='weightForSCellSelection'),
]

PARAMETERS_ONLINE_MODIFY_GNB1_B_B3_001 = [
    dict(value='barred', dist_name=_NRCELL231, parameter='cellBarred'),
    dict(value='notBarred', dist_name=_NRCELL21, parameter='cellBarred'),
    dict(value='true', dist_name=_NRBTSname2 + '/NRDU-1', parameter='actUlCaWith3Tx'),
    dict(value='true', dist_name=_NRBTSname2, parameter='actCoverageNonCoherentUes'),
    dict(value='false', dist_name=_NRCELL231, parameter='actDlSrsBm'),
    dict(value='false', dist_name=_NRCELL231, parameter='actUlSrsBm'),
]
