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

_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSnames2 = 'NRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_gnb3_id = str(tl.gnbs[2].instance_id)
_MRBTSname3 = 'MRBTS-'+_gnb3_id
_NRBTSnames3 = 'NRBTS-'+_gnb3_id
_NRBTSname3 = _MRBTSname3+'/NRBTS-'+_gnb3_id

_gnb4_id = str(tl.gnbs[3].instance_id)
_MRBTSname4 = 'MRBTS-'+_gnb4_id
_NRBTSnames4 = 'NRBTS-'+_gnb4_id
_NRBTSname4 = _MRBTSname4+'/NRBTS-'+_gnb4_id

_NRCELL11 = _NRBTSname+'/NRCELL-1'
_NRCELL12 = _NRBTSname+'/NRCELL-2'
_NRCELL13 = _NRBTSname+'/NRCELL-3'
_NRCELL111 = _NRBTSname+'/NRCELL-11'
_NRCELL131 = _NRBTSname+'/NRCELL-31'

_NRREL111 = _NRCELL11+'/NRREL-1'
_NRREL112 = _NRCELL11+'/NRREL-2'
_NRREL113 = _NRCELL11+'/NRREL-3'
_NRREL131 = _NRCELL13+'/NRREL-1'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL221 = _NRBTSname2+'/NRCELL-21'
_NRREL211 = _NRCELL21+'/NRREL-1'
_NRREL221 = _NRCELL22+'/NRREL-1'

_NRCELL31 = _NRBTSname3+'/NRCELL-1'
_NRCELL311 = _NRBTSname3+'/NRCELL-11'
_NRCELL32 = _NRBTSname3+'/NRCELL-2'
_NRCELL33 = _NRBTSname3+'/NRCELL-3'
_NRCELL331 = _NRBTSname3+'/NRCELL-31'
_NRCELL34 = _NRBTSname3+'/NRCELL-4'
_NRCELL341 = _NRBTSname3+'/NRCELL-41'
_NRREL311 = _NRCELL31+'/NRREL-1'
_NRREL321 = _NRCELL32+'/NRREL-1'
_NRREL322 = _NRCELL32+'/NRREL-2'
_NRREL331 = _NRCELL33+'/NRREL-1'
_NRREL332 = _NRCELL33+'/NRREL-2'
_NRREL3311 = _NRCELL331+'/NRREL-1'

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL42 = _NRBTSname4+'/NRCELL-2'
_NRCELL43 = _NRBTSname4+'/NRCELL-3'
_NRCELL431 = _NRBTSname4+'/NRCELL-31'
_NRREL411 = _NRCELL41+'/NRREL-1'
_CHANNELGROUP13_14 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-14'
_CHANNELGROUP13_13 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-13'
_CHANNELGROUP13_10 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-10'
_CHANNELGROUP13_9 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-9'
_CHANNELGROUP13_6 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-6'
_CHANNELGROUP13_5 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-5'
_CHANNELGROUP13_2 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-2'
_CHANNELGROUP13_1 = _MRBTSname + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1/CHANNEL-1'

MOS_ADD_GNB1_HA004 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL131, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB3_HA008 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL321, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB3_HA004 = [
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrSaAdjGnb'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrRSACU'),
    dict(value='Locked', dist_name=_NRCELL331, p_name='administrativeState'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname3, p_name='actBufferBasedSCellAddition'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname3, p_name='actSCellReleaseForInactiveSCell'),
]

LIST_TO_MODIFY_GNB3_HA004 = [
    dict(dist_name=_NRBTSname3, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)]),
    dict(dist_name=_NRCELL33, list_name='beamSet',
         elements=[dict(p_name='nrBtsBeamRefinementP2', value='true', index=0)]),
    dict(dist_name=_NRCELL33, list_name='periodicCsiAcquisition',
         elements=[dict(p_name='maxCsirsNumber', value='2', index=0)])
]

PARAMETERS_TO_MODIFY_GNB1_HA004 = [
    dict(value='0dB', dist_name=_NRREL131, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL131, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL131, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL131, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL131, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL131, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL131, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL131, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL131, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL131, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL131, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL131, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL131, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL13, p_name='cellBarred'),
    dict(value='false', dist_name=_NRCELL13, p_name='actBeamforming'),
    dict(value='false', dist_name=_NRCELL13, p_name='actExternalAntennaBF'),
    dict(value='1 beam', dist_name=_NRBTSname+'/NRCELLGRP-3', p_name='numberOfTransmittedSsBlocks'),
    dict(value='5min', dist_name=_NRBTSname+'/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='5min', dist_name=_NRBTSname+'/NRPMRNL-1', p_name='miNrRSADU'),
    dict(value='4DL4UL', dist_name=_NRCELL13, p_name='nrCellType'),
    dict(value='oneShot_Dl_Fr1', dist_name=_NRBTSname, p_name='actBufferBasedSCellAddition'),
    dict(value='timer_based_Fr1', dist_name=_NRBTSname, p_name='actSCellReleaseForInactiveSCell'),
]

LIST_TO_MODIFY_GNB1_HA004 = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)]),
    dict(dist_name=_NRCELL13, list_name='beamSet',
         elements=[dict(p_name='basicBeamSet', value='beamSet_1', index=0)])
]

PARAMETERS_TO_DELETE_GNB1_HA004 = [
    dict(dist_name=_CHANNELGROUP13_14),
    dict(dist_name=_CHANNELGROUP13_13),
    dict(dist_name=_CHANNELGROUP13_10),
    dict(dist_name=_CHANNELGROUP13_9),
    dict(dist_name=_CHANNELGROUP13_6),
    dict(dist_name=_CHANNELGROUP13_5),
    dict(dist_name=_CHANNELGROUP13_1),
    dict(dist_name=_CHANNELGROUP13_2)
]

LIST_TO_ADD_GNB1_HA004 = [
    dict(
        dist_name=_NRREL131,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

PARAMETERS_TO_MODIFY_GNB3_HA008 = [
    dict(value='0dB', dist_name=_NRREL321, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL321, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL321, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL321, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL321, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL321, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL321, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL321, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL321, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL321, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL321, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL321, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL321, p_name='sCellOperationalMode'),
    dict(value='notBarred', dist_name=_NRCELL32, p_name='cellBarred'),
    dict(value='40', dist_name=_NRBTSname3+'/NRDRB_RLC_AM-1', p_name='dlTReassemblyIBCA'),
    dict(value='40', dist_name=_NRBTSname3+'/NRDRB_RLC_AM-2', p_name='dlTReassemblyIBCA'),
    dict(value='optimizedAllUe', dist_name=_NRCELL32, p_name='actOptimizedFlowControl'),
    dict(value='0', dist_name=_NRCELL32, p_name='bufferThesholdSCellDePrioritize'),
    dict(value='false', dist_name=_NRBTSname3, p_name='actLteNrDss'),
    dict(value='false', dist_name=_NRCELL32, p_name='actCDrx'),
    dict(value='blind', dist_name=_NRBTSname3, p_name='sCellActivationMethod'),
    dict(value='false', dist_name=_NRBTSname3, p_name='actOverheatingAssistance'),
]

LIST_TO_ADD_GNB3_HA008 = [
    dict(
        dist_name=_NRREL321,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_MODIFY_GNB3_HA008 = [
    dict(dist_name=_NRBTSname3, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

PARAMETERS_TO_MODIFY_GNB1_HA008 = [
    dict(value='false', dist_name=_NRCELL13, p_name='actBeamforming'),
    dict(value='false', dist_name=_NRCELL13, p_name='actExternalAntennaBF'),
    dict(value='1 beam', dist_name=_NRBTSname+'/NRCELLGRP-3', p_name='numberOfTransmittedSsBlocks'),
    dict(value='infinity', dist_name=_NRCELL13, p_name='sCellDeactivationTimerGNB'),
    dict(value='optimizedAllUe', dist_name=_NRCELL13, p_name='actOptimizedFlowControl'),
    dict(value='40', dist_name=_NRBTSname + '/NRDRB_RLC_AM-1', p_name='dlTReassemblyIBCA'),
    dict(value='40', dist_name=_NRBTSname + '/NRDRB_RLC_AM-2', p_name='dlTReassemblyIBCA'),
    dict(value='false', dist_name=_NRBTSname, p_name='actLteNrDss'),
    dict(value='false', dist_name=_NRCELL13, p_name='actCDrx'),
    dict(value='4DL4UL', dist_name=_NRCELL13, p_name='nrCellType')
]

MODIFY_PARA_ONLINE_GNB1_HA007 = [
    {'dist_name': _NRBTSname+'/NRDU-1', 'parameter': 'actNonBfAndBfCa', 'value': 'true'}
]

MODIFY_PARA_ONLINE_GNB1_HA007_1 = [
    {'dist_name': _NRCELL13, 'parameter': 'actBeamforming', 'value': 'true'},
    {'dist_name': _NRCELL13, 'parameter': 'actExternalAntennaBF', 'value': 'true'}
]

ADD_MO_ONLINE_GNB1_HA007_1 = [
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-1', dist_name=_CHANNELGROUP13_1, parameter='antlDN'),
    dict(value='1', dist_name=_CHANNELGROUP13_1, parameter='channelId'),
    dict(value='TX', dist_name=_CHANNELGROUP13_1, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-1', dist_name=_CHANNELGROUP13_2, parameter='antlDN'),
    dict(value='2', dist_name=_CHANNELGROUP13_2, parameter='channelId'),
    dict(value='RX', dist_name=_CHANNELGROUP13_2, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-5', dist_name=_CHANNELGROUP13_5, parameter='antlDN'),
    dict(value='5', dist_name=_CHANNELGROUP13_5, parameter='channelId'),
    dict(value='TX', dist_name=_CHANNELGROUP13_5, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-5', dist_name=_CHANNELGROUP13_6, parameter='antlDN'),
    dict(value='6', dist_name=_CHANNELGROUP13_6, parameter='channelId'),
    dict(value='RX', dist_name=_CHANNELGROUP13_6, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-3', dist_name=_CHANNELGROUP13_9, parameter='antlDN'),
    dict(value='9', dist_name=_CHANNELGROUP13_9, parameter='channelId'),
    dict(value='TX', dist_name=_CHANNELGROUP13_9, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-3', dist_name=_CHANNELGROUP13_10, parameter='antlDN'),
    dict(value='10', dist_name=_CHANNELGROUP13_10, parameter='channelId'),
    dict(value='RX', dist_name=_CHANNELGROUP13_10, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-7', dist_name=_CHANNELGROUP13_13, parameter='antlDN'),
    dict(value='13', dist_name=_CHANNELGROUP13_13, parameter='channelId'),
    dict(value='TX', dist_name=_CHANNELGROUP13_13, parameter='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-3/ANTL-7', dist_name=_CHANNELGROUP13_14, parameter='antlDN'),
    dict(value='14', dist_name=_CHANNELGROUP13_14, parameter='channelId'),
    dict(value='RX', dist_name=_CHANNELGROUP13_14, parameter='direction')
]

MODIFY_PARA_ONLINE_GNB1_HA007_2 = [
    {'dist_name': _NRBTSname + '/NRDU-1', 'parameter': 'actNonBfAndBfCa', 'value': 'false'},
    {'dist_name': _NRCELL13, 'parameter': 'nrCellType', 'value': '4DL2UL'}
]

MODIFY_PARA_ONLINE_GNB3_HA007_RECOVER = [
    {'dist_name': _NRCELL331, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

MOS_ADD_GNB1_HB = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL111, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL112, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL113, version="NRBTSCL22R4_2210_100")
]

LIST_TO_ADD_GNB1 = [
    dict(
        dist_name=_NRREL111,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL112,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRREL113,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(elements=dict(
        a1HysteresisSCellAddSsbRsrp='0',
        a1ThresholdSCellAddSsbRsrpFDD='80',
        a1ThresholdSCellAddSsbRsrpTDD='80',
        a1TimeToTriggerSCellAddSsbRsrp='64ms'),
        dist_name=_NRCELL11, list_name='a1MeasSCellAddSsbRsrp'),
    dict(elements=dict(
        a6HysteresisSCellSwapSsbRsrp='0',
        a6OffsetSCellSwapSsbRsrp='3',
        a6TimeToTrigSCellSwapSsbRsrp='ms480',
        useAllowedCellListRsrp='false'),
        dist_name=_NRCELL12, list_name='a6MeasSCellSwapSsbRsrp'),
    dict(elements=dict(
        a6HysteresisSCellSwapSsbRsrp='0',
        a6OffsetSCellSwapSsbRsrp='3',
        a6TimeToTrigSCellSwapSsbRsrp='ms480',
        useAllowedCellListRsrp='false'),
        dist_name=_NRCELL111, list_name='a6MeasSCellSwapSsbRsrp')
]

PARAMETERS_TO_MODIFY_GNB1_HB = [
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL111, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL111, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL111, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL111, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL111, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL111, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL111, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL111, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL111, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL111, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL111, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL111, p_name='sCellOperationalMode'),

    dict(value='0dB', dist_name=_NRREL112, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL112, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL112, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL112, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL112, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL112, p_name='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL112, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL112, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, p_name='sCellOperationalMode'),
    dict(value='2', dist_name=_NRREL112, p_name='sCellPrio'),

    dict(value='0dB', dist_name=_NRREL113, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL113, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL113, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL113, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL113, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL113, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL113, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL113, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL113, p_name='nrDcAllowed'),
    dict(value='3', dist_name=_NRREL113, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL113, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL113, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL113, p_name='sCellOperationalMode'),
    dict(value='1', dist_name=_NRREL113, p_name='sCellPrio'),

    dict(value='true', dist_name=_NRBTSname, p_name='actMeasBasedSCellAddition'),
    dict(value='rsrp', dist_name=_NRCELL11, p_name='a1MeasSCellAddEnabled'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),
    dict(value='a6BasedSa', dist_name=_NRBTSname, p_name='actSCellSwapFr1'),
    dict(value='rsrp', dist_name=_NRCELL12, p_name='a6MeasSCellSwapEnabled'),
    dict(value='86', dist_name=_NRCELL12, p_name='thresholdSCellSwapSourceRsrp'),
    dict(value='r4', dist_name=_NRCELL12, p_name='reportAmountA6MeasSCellSwap'),
    dict(value='ms1024', dist_name=_NRCELL12, p_name='reportIntervalA6MeasSCellSwap'),
    dict(value='rsrp', dist_name=_NRCELL111, p_name='a6MeasSCellSwapEnabled'),
    dict(value='76', dist_name=_NRCELL111, p_name='thresholdSCellSwapSourceRsrp'),
    dict(value='r4', dist_name=_NRCELL111, p_name='reportAmountA6MeasSCellSwap'),
    dict(value='ms1024', dist_name=_NRCELL111, p_name='reportIntervalA6MeasSCellSwap'),
    dict(value='5', dist_name=_NRBTSname, p_name='weightForIgnbCaSelection'),
    dict(value='9', dist_name=_NRBTSname+'/NRADJGNB-14', p_name='weightForIgnbCaSelection'),

    dict(value='424200', dist_name=_NRCELL12+'/NRCELL_FDD-1', p_name='nrarfcnDl')
]

LIST_TO_MODIFY_GNB1_HB = [
    dict(dist_name=_NRBTSname, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

PARAMETERS_TO_DELETE_GNB1_HB = [
    dict(dist_name=_NRCELL111, p_name='maxNumScellsDlFr1')
]

PARAMETERS_TO_MODIFY_GNB4_HB = [
    dict(value='true', dist_name=_NRBTSname4, p_name='actMeasBasedSCellAddition'),
    dict(value='a6BasedSa', dist_name=_NRBTSname4, p_name='actSCellSwapFr1'),
    dict(value='424200', dist_name=_NRCELL41+'/NRCELL_FDD-1', p_name='nrarfcnDl')
]

LIST_TO_ADD_GNB4 = [
    dict(elements=dict(
        a6HysteresisSCellSwapSsbRsrp='0',
        a6OffsetSCellSwapSsbRsrp='3',
        a6TimeToTrigSCellSwapSsbRsrp='ms480',
        useAllowedCellListRsrp='false'),
        dist_name=_NRCELL41, list_name='a6MeasSCellSwapSsbRsrp')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_HB001 = [
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRBTSname, 'parameter': 'weightForIgnbCaSelection', 'value': '5'},
    {'dist_name': _NRBTSname+'/NRADJGNB-14', 'parameter': 'weightForIgnbCaSelection', 'value': '1'}
]

# HB counter #
counter_id_HB002_gNB4 = [
    'M55139C01001', 'M55139C01002'
]

counter_dic_path_HB002_gNB4_Trunk = [
    'BTS/'+_NRBTSname4+'/NRCELL-1/RSADU',
    'BTS/'+_NRBTSname4+'/NRCELL-1/RSADU'
]

counter_dic_path_HB002_gNB4 = [
    'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/RSADU'
]

# HC #
PARAMETERS_TO_MODIFY_GNB1_HC001 = [
    dict(value='25MHz', dist_name=_NRCELL111 + '/NRCELL_FDD-1', p_name='chBwDl'),
    dict(value='25MHz', dist_name=_NRCELL111 + '/NRCELL_FDD-1', p_name='chBwUl'),
    dict(value='436000', dist_name=_NRCELL111 + '/NRCELL_FDD-1', p_name='nrarfcnDl'),
    dict(value='352000', dist_name=_NRCELL111 + '/NRCELL_FDD-1', p_name='nrarfcnUl'),
    dict(value='22', dist_name=_NRCELL111, p_name='msg1FrequencyStart')
]

PARAMETERS_TO_DELETE_GNB1_HC001 = [
    dict(dist_name=_NRCELL111, list_name='cellBwpList')
]

LIST_TO_ADD_GNB1_HC001_SBTS23R3_ENB_0000 = [
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_NRBTSname + '/BWP_PROFILE-5',
            cellBwpId='0')
    ),
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_NRBTSname + '/BWP_PROFILE-33',
            cellBwpId='1')
    ),
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            bwpDN=_NRBTSname + '/BWP_PROFILE-38',
            cellBwpId='2')
    )
]

LIST_TO_ADD_GNB1_HC001_SBTS24R2_ENB_9999 = [
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-5',
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
            bwpDN=_NRBTSname + '/BWP_PROFILE-33',
            cellBwpId='1',
            pdcchResourcePreference='peakRate')
    ),
    dict(
        dist_name=_NRCELL111,
        list_name='cellBwpList',
        elements=dict(
            actPdcchCceFragmentControl='false',
            actUpperThrAckNackFiltering='false',
            actUpperThrAckNackHrFiltering='false',
            bwpDN=_NRBTSname + '/BWP_PROFILE-38',
            cellBwpId='2',
            pdcchResourcePreference='peakRate')
    )
]

MOS_ADD_GNB3_HC001 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL311, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB3_HC001 = [
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL311, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL311, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='11', dist_name=_NRREL311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL311, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL311, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL311, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='notBarred', dist_name=_NRCELL31, p_name='cellBarred'),
    dict(value='436000', dist_name=_NRBTSname3 + '/NRADJNRCELL-111', p_name='nrarfcn')
]

LIST_TO_ADD_GNB3_HC001 = [
    dict(
        dist_name=_NRREL311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

# counter HA004
counter_id_HA004_gNB1 = [
    'M55139C01003', 'M55118C11001', 'M55118C11007'
]

counter_dic_path_HA004_gNB1_Trunk = [
    'BTS/'+_NRBTSname+'/NRCELL-3/RSADU',
    'BTS/'+_NRBTSname+'/NRCELL-3/NCAC',
    'BTS/'+_NRBTSname+'/NRCELL-3/NCAC'
]

counter_dic_path_HA004_gNB1 = [
    'BTS/CELLS/NRCELL-3/RSADU',
    'BTS/CELLS/NRCELL-3/NCAC',
    'BTS/CELLS/NRCELL-3/NCAC'
]

counter_id_HA004_gNB3_Trunk = [
    'M55199C00001', 'M55138C03501', 'M55138C03502', 'M55139C01001', 'M55199C00002'
]

counter_id_HA004_gNB3 = [
    'M55175C00001', 'M55138C03501', 'M55138C03502', 'M55139C01001', 'M55175C00002'
]

counter_dic_path_HA004_gNB3_Trunk = [
    'BTS/'+_NRBTSname3+'/NRADJGNB-11/MCC-310/MNC-260/AGNBM',
    'BTS/'+_NRBTSname3+'/NRCELL-3/RSACU',
    'BTS/'+_NRBTSname3+'/NRCELL-3/RSACU',
    'BTS/'+_NRBTSname3+'/NRCELL-3/RSADU',
    'BTS/'+_NRBTSname3+'/NRADJGNB-11/MCC-310/MNC-260/AGNBM'
]

counter_dic_path_HA004_gNB3 = [
    'BTS/BTS/'+_NRBTSnames+'/MCC-310_MNC-260/ADJNB',
    'BTS/CELLS/NRCELL-3/RSACU',
    'BTS/CELLS/NRCELL-3/RSACU',
    'BTS/CELLS/NRCELL-3/RSADU',
    'BTS/BTS/'+_NRBTSnames+'/MCC-310_MNC-260/ADJNB'
]
