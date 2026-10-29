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

_NRCELL31 = _NRBTSname3+'/NRCELL-1'
_NRCELL311 = _NRBTSname3+'/NRCELL-11'
_NRCELL32 = _NRBTSname3+'/NRCELL-2'
_NRCELL33 = _NRBTSname3+'/NRCELL-3'
_NRCELL331 = _NRBTSname3+'/NRCELL-31'

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL42 = _NRBTSname4+'/NRCELL-2'
_NRCELL421 = _NRBTSname4+'/NRCELL-21'
_NRCELL43 = _NRBTSname4+'/NRCELL-3'
_NRCELL431 = _NRBTSname4+'/NRCELL-31'

_NRREL311 = _NRCELL31 + '/NRREL-1'
_NRREL4311 = _NRCELL431 + '/NRREL-1'

MOS_ADD_GNB4_BB001 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL311, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB3_BA002 = [
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL311, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL311, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL311, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL311, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL311, p_name='sCellOperationalMode'),
    dict(value='true', dist_name=_NRBTSname3, p_name='actMeasBasedSCellAddition'),
    dict(value='rsrpAndRsrq', dist_name=_NRCELL31, p_name='a1MeasSCellAddEnabled'),
    dict(value='true', dist_name=_NRBTSname3, p_name='actOverheatingAssistance'),
    dict(value='bufferBased', dist_name=_NRBTSname3, p_name='sCellActivationMethod'),
    dict(value='1s', dist_name=_NRBTSname3, p_name='timerOverheatIndProhibit'),
    dict(value='0', dist_name=_NRBTSname3, p_name='timerPostOverheating'),
    dict(value='5min', dist_name=_NRBTSnames3 + '/NRPMRNL-1', p_name='miNrRRCC'),
    dict(value='5min', dist_name=_NRBTSnames3 + '/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='5min', dist_name=_NRBTSnames3 + '/NRPMRNL-1', p_name='miNrRSADU'),
    dict(value='notBarred', dist_name=_NRCELL31, p_name='cellBarred')
]

LIST_TO_MODIFY_GNB3_BB001 = [
    dict(dist_name=_NRBTSname3, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB3_BB001 = [
    dict(
        dist_name=_NRREL311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL31,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='117',
            a1ThresholdSCellAddSsbRsrpTDD='117',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL31,
        list_name='a1MeasSCellAddSsbRsrq',
        elements=dict(
            a1HysteresisSCellAddSsbRsrq='0',
            a1ThresholdSCellAddSsbRsrq='64',
            a1TimeToTriggerSCellAddSsbRsrq='320ms')),

]

PARAMETERS_TO_MODIFY_GNB4_BB001 = [
    dict(value='true', dist_name=_NRBTSname4, p_name='actMeasBasedSCellAddition'),
    dict(value='rsrp', dist_name=_NRCELL42, p_name='a2MeasSCellRelEnabled')
]

LIST_TO_MODIFY_GNB4_BB001 = [
    dict(dist_name=_NRBTSname4, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB4_BB001 = [
    dict(
        dist_name=_NRCELL42,
        list_name='a2MeasSCellRelSsbRsrp',
        elements=dict(
            a2HysteresisSCellRelSsbRsrp='0',
            a2ThresholdSCellRelSsbRsrp='66',
            a2TimeToTriggerSCellRelSsbRsrp='2560ms')),
]

PARAMETERS_TO_MODIFY_GNB3_BA002_LOCK = [
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_MODIFY_GNB4_BA002_LOCK = [
    {'dist_name': _NRCELL421, 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_MODIFY_GNB3_BA002_UNLOCK = [
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_MODIFY_GNB4_BA002_UNLOCK = [
    {'dist_name': _NRCELL421, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_BA002_1 = [
    {'dist_name': _NRCELL31, 'parameter': 'cellBarred', 'value': 'notBarred'},
    dict(value=[dict(a1HysteresisSCellAddSsbRsrq='0', a1ThresholdSCellAddSsbRsrq='70',
                     a1TimeToTriggerSCellAddSsbRsrq='320ms')],
         dist_name=_NRCELL31, parameter='a1MeasSCellAddSsbRsrq'),
    dict(value=[dict(a1HysteresisSCellAddSsbRsrp='0', a1ThresholdSCellAddSsbRsrpFDD='90',
                     a1ThresholdSCellAddSsbRsrpTDD='90', a1TimeToTriggerSCellAddSsbRsrp='320ms')],
         dist_name=_NRCELL31, parameter='a1MeasSCellAddSsbRsrp')
]

PARAMETERS_TO_DELETE_GNB3 = [
    {'dist_name': _NRREL311}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_Overheating_false = [
    {'dist_name': _NRBTSname3, 'parameter': 'actOverheatingAssistance', 'value': 'false'},
    {'dist_name': _NRBTSname3, 'parameter': 'sCellActivationMethod', 'value': 'blind'}
]

PARAMETERS_TO_ONLINE_DELETE_GNB3_GE001 = [
    dict(dist_name=_NRBTSname3, parameter='timerOverheatIndProhibit'),
    dict(dist_name=_NRBTSname3, parameter='timerPostOverheating')
]

PARAMETERS_TO_DELETE_GNB4_BB001 = [
    dict(dist_name=_NRCELL42, parameter='a2MeasSCellRelSsbRsrp')
]

MOS_ADD_GNB4_BB003 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL4311, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB4_BA005_and_BB003_and_GK001 = [
    dict(value='0dB', dist_name=_NRREL4311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL4311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL4311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL4311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL4311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL4311, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL4311, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL4311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL4311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL4311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL4311, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL4311, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL4311, p_name='sCellOperationalMode'),
    dict(value='true', dist_name=_NRBTSname4, p_name='actMeasBasedSCellAddition'),
    dict(value='rsrqCombined', dist_name=_NRCELL431, p_name='a1MeasSCellAddEnabled'),
    dict(value='false', dist_name=_NRBTSname4, p_name='actOverheatingAssistance'),
    dict(value='blind', dist_name=_NRBTSname4, p_name='sCellActivationMethod'),
    dict(value='infinity', dist_name=_NRCELL431, p_name='sCellDeactivationTimerGNB'),
    dict(value='notBarred', dist_name=_NRCELL431, p_name='cellBarred'),
    dict(value='false', dist_name=_NRBTSname4, p_name='actOverheatingAssistance'),
    dict(value='5min', dist_name=_NRBTSname4 + '/NRPMRNL-1', p_name='miNrRRCC'),
]

LIST_TO_MODIFY_GNB4_BB003 = [
    dict(dist_name=_NRBTSname4, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB4_BB003 = [
    dict(
        dist_name=_NRREL4311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL431,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='92',
            a1ThresholdSCellAddSsbRsrpTDD='92',
            a1TimeToTriggerSCellAddSsbRsrp='320ms')),
    dict(
        dist_name=_NRCELL431,
        list_name='a1MeasSCellAddSsbRsrq',
        elements=dict(
            a1HysteresisSCellAddSsbRsrq='0',
            a1ThresholdSCellAddSsbRsrq='64',
            a1TimeToTriggerSCellAddSsbRsrq='320ms'))
]

PARAMETERS_TO_MODIFY_GNB3_BB003 = [
    dict(value='true', dist_name=_NRBTSname3, p_name='actMeasBasedSCellAddition'),
    dict(value='bufferBased', dist_name=_NRBTSname3, p_name='sCellActivationMethod'),
    dict(value='rsrq', dist_name=_NRCELL31, p_name='a2MeasSCellRelEnabled'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrCaDu'),
    dict(value='infinity', dist_name=_NRCELL31, p_name='sCellDeactivationTimerGNB')
]

LIST_TO_MODIFY_GNB3_BB003 = [
    dict(dist_name=_NRBTSname3, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB3_BB003 = [
    dict(
        dist_name=_NRCELL31,
        list_name='a2MeasSCellRelSsbRsrq',
        elements=dict(
            a2HysteresisSCellRelSsbRsrq='0',
            a2ThresholdSCellRelSsbRsrq='66',
            a2TimeToTriggerSCellRelSsbRsrq='2560ms'))
]

PARAMETERS_TO_MODIFY_GNB4_BB003_1 = [
    {'dist_name': _NRCELL431, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_GK001 = [
    {'dist_name': _NRCELL31, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'}
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_GK001 = [
    {'dist_name': _NRREL4311, 'parameter': 'sCellAdditionMethod', 'value': 'blind'},
    {'dist_name': _NRCELL431, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_RESTORE_GNB4_BB003 = [
    {'dist_name': _NRREL4311}
]

PARAMETERS_TO_DELETE_GNB4_BB003 = [
    dict(dist_name=_NRCELL431, parameter='a1MeasSCellAddSsbRsrp'),
    dict(dist_name=_NRCELL431, parameter='a1MeasSCellAddSsbRsrq')
]

PARAMETERS_TO_DELETE_GNB3_BB003 = [
    dict(dist_name=_NRCELL31, parameter='a2MeasSCellRelSsbRsrq')
]

PARAMETERS_TO_RESTORE_MODIFY_BB003 = [
    {'dist_name': _NRCELL31, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'}
]

MOS_ADD_GNB4_BB007 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL4311, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB4_BB007 = [
    dict(value='0dB', dist_name=_NRREL4311, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL4311, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL4311, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL4311, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL4311, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL4311, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL4311, p_name='isRplCellForPSCell'),
    dict(value='3', dist_name=_NRREL4311, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL4311, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL4311, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL4311, p_name='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL4311, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL4311, p_name='sCellOperationalMode'),
    dict(value='true', dist_name=_NRBTSname4, p_name='actMeasBasedSCellAddition'),
    dict(value='5min', dist_name=_NRBTSnames4 + '/NRPMRNL-1', p_name='miNrRRCC'),
    dict(value='5min', dist_name=_NRBTSnames4 + '/NRPMRNL-1', p_name='miNrCaDu'),
    dict(value='5min', dist_name=_NRBTSnames4 + '/NRPMRNL-1', p_name='miNrLowRlcReport'),
    dict(value='infinity', dist_name=_NRBTSname4, p_name='sCellDeactivationTimerGNB'),
    dict(value='notBarred', dist_name=_NRCELL431, p_name='cellBarred'),
    dict(value='rsrp', dist_name=_NRCELL431, p_name='a1MeasSCellAddEnabled')
]

LIST_TO_MODIFY_GNB4_BB007 = [
    dict(dist_name=_NRBTSname4, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB4_BB007 = [
    dict(
        dist_name=_NRREL4311,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3')),
    dict(
        dist_name=_NRCELL431,
        list_name='a1MeasSCellAddSsbRsrp',
        elements=dict(
            a1HysteresisSCellAddSsbRsrp='0',
            a1ThresholdSCellAddSsbRsrpFDD='97',
            a1ThresholdSCellAddSsbRsrpTDD='97',
            a1TimeToTriggerSCellAddSsbRsrp='320ms'))
]

PARAMETERS_TO_DELETE_GNB4_BB007 = [
    dict(dist_name=_NRCELL431, list_name='periodicCsiAcquisition')
]

PARAMETERS_TO_MODIFY_GNB3_BB007 = [
    dict(value='true', dist_name=_NRBTSname3, p_name='actMeasBasedSCellAddition'),
    dict(value='rsrp', dist_name=_NRCELL33, p_name='a2MeasSCellRelEnabled'),
    dict(value='ms1280', dist_name=_NRCELL33, p_name='sCellDeactivationTimerGNB'),
    dict(value='5min', dist_name=_NRBTSnames3 + '/NRPMRNL-1', p_name='miNrSaAdjGnb'),
    dict(value='5min', dist_name=_NRBTSnames3 + '/NRPMRNL-1', p_name='miNrCaDu'),
    dict(value='5min', dist_name=_NRBTSnames3 + '/NRPMRNL-1', p_name='miNrLowRlcReport'),
]

PARAMETERS_TO_DELETE_GNB3_BB007 = [
    dict(dist_name=_NRCELL33, list_name='periodicCsiAcquisition')
]

LIST_TO_MODIFY_GNB3_BB007 = [
    dict(dist_name=_NRBTSname3, list_name='cipherPrefL',
         elements=[dict(p_name='nea0', value='9', index=0),
                   dict(p_name='nea1_128', value='0', index=0),
                   dict(p_name='nea2_128', value='0', index=0),
                   dict(p_name='nea3_128', value='0', index=0)])
]

LIST_TO_ADD_GNB3_BB007 = [
    dict(
        dist_name=_NRCELL33,
        list_name='a2MeasSCellRelSsbRsrp',
        elements=dict(
            a2HysteresisSCellRelSsbRsrp='0',
            a2ThresholdSCellRelSsbRsrp='82',
            a2TimeToTriggerSCellRelSsbRsrp='2560ms'))
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_BA011 = [
    dict(value=[dict(a1HysteresisSCellAddSsbRsrp='0', a1ThresholdSCellAddSsbRsrpFDD='120',
                     a1ThresholdSCellAddSsbRsrpTDD='120', a1TimeToTriggerSCellAddSsbRsrp='320ms')],
         dist_name=_NRCELL431, parameter='a1MeasSCellAddSsbRsrp')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_BA011_1 = [
    dict(value=[dict(a1HysteresisSCellAddSsbRsrp='0', a1ThresholdSCellAddSsbRsrpFDD='97',
                     a1ThresholdSCellAddSsbRsrpTDD='97', a1TimeToTriggerSCellAddSsbRsrp='320ms')],
         dist_name=_NRCELL431, parameter='a1MeasSCellAddSsbRsrp')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_CELlLock = [
    dict(value='Locked',
         dist_name=_NRCELL331, parameter='administrativeState')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB3_CELlUnLock = [
    dict(value='Unlocked',
         dist_name=_NRCELL331, parameter='administrativeState')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_CELlLock = [
    dict(value='Locked',
         dist_name=_NRCELL43, parameter='administrativeState')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB4_CELlUnLock = [
    dict(value='Unlocked',
         dist_name=_NRCELL43, parameter='administrativeState')
]

counter_id_AC003_gNB4 = [
    'M55118C05505', 'M55118C05506'
]

counter_dic_path_AC003_gNB4_Trunk = [
    'BTS/'+_NRBTSname4+'/NRCELL-31/NCAC',
    'BTS/'+_NRBTSname4+'/NRCELL-31/NCAC'
]

counter_dic_path_AC003_gNB4 = [
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCAC'
]

counter_id_BA002_And_AE005_gNB4 = [
    'M55118C05507', 'M55316C03001', 'M55310C01022', 'M55310C20001'
]

counter_dic_path_BA002_And_AE005_gNB4_Trunk = [
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCADU',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NLRLC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NLRLC'
]

counter_dic_path_BA002_And_AE005_gNB4 = [
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCADU',
    'BTS/CELLS/NRCELL-31/NLRLC',
    'BTS/CELLS/NRCELL-31/NLRLC'
]

counter_id_AC003_and_BA002_and_AE005_gNB4 = [
    'M55139C01003', 'M55139C01004', 'M55138C00001', 'M55138C00002', 'M55118C05505', 'M55118C05506',
    'M55118C11001', 'M55118C11004',
    'M55316C05001'
]

counter_dic_path_AC003_and_BA002_and_AE005_gNB4_Trunk = [
    'BTS/' + _NRBTSname4 + '/NRCELL-31/RSADU',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/RSADU',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/RSACU',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/RSACU',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCADU',
]

counter_dic_path_AC003_and_BA002_and_AE005_gNB4 = [
    'BTS/CELLS/NRCELL-31/RSADU',
    'BTS/CELLS/NRCELL-31/RSADU',
    'BTS/CELLS/NRCELL-31/RSACU',
    'BTS/CELLS/NRCELL-31/RSACU',
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCADU'
]

counter_id_AE005_gNB3 = [
    'M55310C01021', 'M55310C20000'
]

counter_dic_path_AE005_gNB3_trunk = [
    'BTS/' + _NRBTSname3 + '/NRCELL-3/NLRLC',
    'BTS/' + _NRBTSname3 + '/NRCELL-3/NLRLC'
]

counter_dic_path_AE005_gNB3 = [
    'BTS/CELLS/NRCELL-3/NLRLC',
    'BTS/CELLS/NRCELL-3/NLRLC'
]

counter_id_AC003_and_BA002_AE005_gNB3_Trunk = [
    'M55139C01001', 'M55139C01002', 'M55138C03501', 'M55138C03502', 'M55199C00001', 'M55316C09001'
]

counter_id_AC003_and_BA002_AE005_gNB3 = [
    'M55139C01001', 'M55139C01002', 'M55138C03501', 'M55138C03502', 'M55175C00001', 'M55316C09001'
]

counter_dic_path_AC003_and_BA002_AE005_gNB3_Trunk = [
    'BTS/' + _NRBTSname3 + '/NRCELL-3/RSADU',
    'BTS/' + _NRBTSname3 + '/NRCELL-3/RSADU',
    'BTS/' + _NRBTSname3 + '/NRCELL-3/RSACU',
    'BTS/' + _NRBTSname3 + '/NRCELL-3/RSACU',
    'BTS/' + _NRBTSname3 + '/NRADJGNB-14/MCC-310/MNC-260/AGNBM',
    'BTS/' + _NRBTSname3 + '/NRCELL-3/NCADU',
]

counter_dic_path_AC003_and_BA002_AE005_gNB3 = [
    'BTS/CELLS/NRCELL-3/RSADU',
    'BTS/CELLS/NRCELL-3/RSADU',
    'BTS/CELLS/NRCELL-3/RSACU',
    'BTS/CELLS/NRCELL-3/RSACU',
    'BTS/BTS/'+_NRBTSnames4+'/MCC-310_MNC-260/ADJNB',
    'BTS/CELLS/NRCELL-3/NCADU',
]

counter_id_BB001_And_AD001_gNB4 = [
    'M55118C11008', 'M55118C06501', 'M55118C06502', 'M55124C03001', 'M55124C03002', 'M55118C11012'
]

counter_dic_path_BB001_And_AD001_gNB4_Trunk = [
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NRRCC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NRRCC',
    'BTS/' + _NRBTSname4 + '/NRCELL-31/NCAC'
]

counter_dic_path_BB001_And_AD001_gNB4 = [
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NCAC',
    'BTS/CELLS/NRCELL-31/NRRCC',
    'BTS/CELLS/NRCELL-31/NRRCC',
    'BTS/CELLS/NRCELL-31/NCAC'
]

counter_id_GK001_gNB3 = [
    'M55316C09001'
]

counter_dic_path_GK001_gNB3_Trunk = [
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCADU'
]

counter_dic_path_GK001_gNB3 = [
    'BTS/CELLS/NRCELL-1/NCADU'
]

counter_id_BA002_gNB3_M55118C05507 = [
    'M55118C05507'
]

counter_dic_path_gNB3_M55118C05507_Trunk = [
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC'
]

counter_dic_path_gNB3_M55118C05507 = [
    'BTS/CELLS/NRCELL-1/NCAC'
]

counter_dic_path_gNB4_M55118C05507_Trunk = [
    'BTS/'+_NRBTSname4+'/NRCELL-31/NCAC'
]

counter_dic_path_gNB4_M55118C05507 = [
    'BTS/CELLS/NRCELL-31/NCAC'
]

counter_id_BA002_and_AC003_and_AD001_gNB3 = [
    'M55118C11001', 'M55118C11004', 'M55139C01003', 'M55139C01004',
    'M55118C05505', 'M55118C05506', 'M55138C00001', 'M55138C00002',
    'M55118C11012',
]

counter_dic_path_BA002_and_AC003_and_AD001_gNB3_Trunk = [
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/RSADU',
    'BTS/'+_NRBTSname3+'/NRCELL-1/RSADU',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/RSACU',
    'BTS/'+_NRBTSname3+'/NRCELL-1/RSACU',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC'
]

counter_dic_path_BA002_and_AC003_and_AD001_gNB3 = [
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/RSACU',
    'BTS/CELLS/NRCELL-1/RSACU',
    'BTS/CELLS/NRCELL-1/NCAC'
]

counter_id_BA002_and_AC003_gNB4 = [
    'M55139C01001', 'M55138C03501', 'M55138C03502', 'M55175C00001',
    'M55139C01002'
]

counter_dic_path_BA002_and_AC003_gNB4_Trunk = [
    'BTS/'+_NRBTSname4+'/NRCELL-2/RSADU',
    'BTS/'+_NRBTSname4+'/NRCELL-2/RSACU',
    'BTS/'+_NRBTSname4+'/NRCELL-2/RSACU',
    'BTS/'+_MRBTSname4+'/'+_NRBTSnames3+'/MCC-310/MNC-260/ADJNB',
    'BTS/'+_NRBTSname4+'/NRCELL-2/RSADU'
]

counter_dic_path_BA002_and_AC003_gNB4 = [
    'BTS/CELLS/NRCELL-2/RSADU',
    'BTS/CELLS/NRCELL-2/RSACU',
    'BTS/CELLS/NRCELL-2/RSACU',
    'BTS/BTS/'+_NRBTSnames3+'/MCC-310_MNC-260/ADJNB',
    'BTS/CELLS/NRCELL-2/RSADU'
]

counter_id_gNB3_M55118C05507_and_M55118C07507 = [
    'M55118C05507', 'M55118C07507'
]

counter_dic_path_gNB3_M55118C05507_and_M55118C07507_Trunk = [
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC'
]


counter_dic_path_gNB3_M55118C05507_and_M55118C07507 = [
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC'
]

counter_id_BA002_and_BB001_gNB3 = [
    'M55118C11001', 'M55118C11004', 'M55139C01003', 'M55139C01004',
    'M55118C11008', 'M55118C06501', 'M55118C06502', 'M55124C03001', 'M55124C03002'
]

counter_dic_path_BA002_and_BB001_gNB3_Trunk = [
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/RSADU',
    'BTS/'+_NRBTSname3+'/NRCELL-1/RSADU',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NCAC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NRRCC',
    'BTS/'+_NRBTSname3+'/NRCELL-1/NRRCC'
]

counter_dic_path_BA002_and_BB001_gNB3 = [
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/RSADU',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NRRCC',
    'BTS/CELLS/NRCELL-1/NRRCC'
]
