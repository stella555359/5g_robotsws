from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Hu Yifan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'yifan.hu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_NRCELL1 = _NRBTSname+'/NRCELL-1'
_NRCELL2 = _NRBTSname+'/NRCELL-2'
_NRCELL3 = _NRBTSname+'/NRCELL-3'
_NRCELL4 = _NRBTSname+'/NRCELL-4'
_NRCELL5 = _NRBTSname+'/NRCELL-5'
_NRCELL11 = _NRBTSname+'/NRCELL-11'
_NRCELL14 = _NRBTSname+'/NRCELL-14'
_NRREL11 = _NRCELL1+'/NRREL-1'
_NRREL12 = _NRCELL1+'/NRREL-2'
_NRREL21 = _NRCELL2+'/NRREL-1'
_NRREL22 = _NRCELL2+'/NRREL-2'
_NRREL23 = _NRCELL2+'/NRREL-3'
_NRREL31 = _NRCELL3+'/NRREL-1'
_NRREL32 = _NRCELL3+'/NRREL-2'
_NRREL41 = _NRCELL4+'/NRREL-1'
_NRREL42 = _NRCELL4+'/NRREL-2'
_NRREL51 = _NRCELL5+'/NRREL-1'
_NRREL52 = _NRCELL5+'/NRREL-2'


PARAMETERS_TO_UPDATE_DMRS_pre = [
    # {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname', 'parameter': 'actGrflShdn', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'cellBarred', 'value': 'barred'}
    # {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
]

PARAMETERS_TO_UPDATE_DMRS_modify = [
    # {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'ulDMRSAdditionalPosition', 'value': 'Automatic'}
    # {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
]

PARAMETERS_TO_UPDATE_DMRS_NRREL12 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_DMRS_NRREL14 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_DMRS_NRREL12_trunk = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL11, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL11, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_DMRS_NRREL12_23R2 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_DMRS_NRREL14_trunk = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL12, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL12, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_DMRS_NRREL14_23R2 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_DMRS_recover = [
    # {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname', 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'cellBarred', 'value': 'unbarred'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'ulDMRSAdditionalPosition', 'value': 'No additional DMRS'}
    # {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
]

PARAMETERS_TO_UPDATE_DMRS_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-11'},
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-12'}
]

PARAMETERS_TO_UPDATE_A_B3_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'}
]

PARAMETERS_TO_UPDATE_A_B3_NRREL1 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='3', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_A_B3_2 = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-1', 'parameter': 'lcrId', 'value': '2'}
]

counter_id_scell_act = [
    'M55316C09000'
]

counter_dic_path_cell2 = [
    'BTS/CELLS/NRCELL-2/NCADU'
]

counter_dic_path_cell3 = [
    'BTS/CELLS/NRCELL-3/NCADU'
]

PARAMETERS_TO_UPDATE_A_B3_recover = [
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_A_B3_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-1'}
]

PARAMETERS_TO_UPDATE_AB_B1_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'MixedCAMode'}
]

PARAMETERS_TO_UPDATE_AB_B1_NRREL1 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B1_NRREL2 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='3', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B1_1 = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'}
]

PARAMETERS_TO_UPDATE_AB_B1_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AB_B2_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '6'}
]

PARAMETERS_TO_UPDATE_AB_B2_NRREL1 = [
    dict(value='0dB', dist_name=_NRREL31, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL31, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL31, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL31, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL31, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL31, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL31, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL31, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL31, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL31, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B2_NRREL2 = [
    dict(value='0dB', dist_name=_NRREL32, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL32, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL32, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL32, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL32, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL32, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL32, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL32, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL32, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL32, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B2_LOCKG1 = [
    dict(value='Locked', dist_name=_NRCELL1, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG1 = [
    dict(value='Unlocked', dist_name=_NRCELL1, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_LOCKG2 = [
    dict(value='Locked', dist_name=_NRCELL11, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG2 = [
    dict(value='Unlocked', dist_name=_NRCELL11, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_1 = [
    {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_AB_B2_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AB_B3_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '6'}
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL21_trunk = [
    dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL21, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL21, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL21, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL21, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL21, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL21, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL21, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL21, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL21, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL21, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL21, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL21, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL21, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL21, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL22_trunk = [
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL22, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL22, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL22, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL22, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL22, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL22, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL22, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL22, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL22, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL22, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL22, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL22, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL21_23R2 = [
    dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL21, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL21, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL21, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL21, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL21, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL21, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL21, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL21, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL21, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL21, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL21, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL22_23R2 = [
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL22, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL22, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL22, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL22, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL22, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL22, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL22, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL22, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL22, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL21 = [
    dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL21, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL21, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL21, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL21, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL21, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL21, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL21, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL21, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL21, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL22 = [
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL22, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL22, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL22, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL22, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL22, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL22, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL22, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL51 = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL52 = [
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL52, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL52, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL51_trunk = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL51, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL51, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL51, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL52_trunk = [
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL52, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL52, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL52, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL52, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL52, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL52, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL52, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL51_23R2 = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL52_23R2 = [
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL52, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL52, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL52, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL52, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL23_HO = [
    dict(value='0dB', dist_name=_NRREL23, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL23, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL23, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL23, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL23, parameter='handoverAllowedSA'),
    dict(value='5', dist_name=_NRREL23, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL23, parameter='nrDcAllowed'),
    dict(value='3', dist_name=_NRREL23, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL23, parameter='removeNotAllowed'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL23, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL23_HO_trunk = [
    dict(value='0dB', dist_name=_NRREL23, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL23, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL23, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL23, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL23, parameter='handoverAllowedSA'),
    dict(value='5', dist_name=_NRREL23, parameter='lcrId'),
    dict(value='3', dist_name=_NRREL23, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL23, parameter='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL23, parameter='removeNotAllowed'),
    dict(value='forbidden', dist_name=_NRREL23, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL23, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL23, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL23, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL23, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL23, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL23_HO_23R2 = [
    dict(value='0dB', dist_name=_NRREL23, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL23, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL23, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL23, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL23, parameter='handoverAllowedSA'),
    dict(value='5', dist_name=_NRREL23, parameter='lcrId'),
    dict(value='3', dist_name=_NRREL23, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL23, parameter='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL23, parameter='removeNotAllowed'),
    dict(value='forbidden', dist_name=_NRREL23, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL23, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL23, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_1 = [
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_AB_B3_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-2'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-2'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-3'}
]

PARAMETERS_TO_UPDATE_AC_B3_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
]

PARAMETERS_TO_UPDATE_AC_B3_NRREL1 = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AC_B3_NRREL1_trunk = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL51, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL51, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL51, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AC_B3_NRREL1_23R2 = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AC_B3_1 = [
    {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

counter_dic_path_cell5 = [
    'BTS/CELLS/NRCELL-5/NCADU'
]

counter_dic_path_cell14 = [
    'BTS/CELLS/NRCELL-14/NCADU'
]

PARAMETERS_TO_UPDATE_AC_B3_3 = [
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-1', 'parameter': 'lcrId', 'value': '14'}
]

PARAMETERS_TO_UPDATE_AC_B3_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-1'}
]

# PARAMETERS_TO_UPDATE_AD_B1_NRREL1_trunk = [
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL41, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL41, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL41, parameter='handoverAllowedSA'),
#     dict(value='5', dist_name=_NRREL41, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL41, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL41, parameter='removeNotAllowed'),
#     dict(value='false', dist_name=_NRREL41, parameter='nrDcAllowed'),
#     dict(value='forbidden', dist_name=_NRREL41, parameter='handoverAllowedSARedCap'),
#     dict(value='dlOnly', dist_name=_NRREL41, parameter='sCellOperationalMode'),
#     dict(value='blind', dist_name=_NRREL41, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL41, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B1_NRREL1 = [
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL41, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL41, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL41, parameter='handoverAllowedSA'),
#     dict(value='5', dist_name=_NRREL41, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL41, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL41, parameter='removeNotAllowed'),
#     dict(value='blind', dist_name=_NRREL41, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL41, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B1_NRREL2_trunk = [
#     dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL42, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL42, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL42, parameter='handoverAllowedSA'),
#     dict(value='14', dist_name=_NRREL42, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL42, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL42, parameter='removeNotAllowed'),
#     dict(value='false', dist_name=_NRREL42, parameter='nrDcAllowed'),
#     dict(value='blind', dist_name=_NRREL42, parameter='sCellAdditionMethod'),
#     dict(value='forbidden', dist_name=_NRREL42, parameter='handoverAllowedSARedCap'),
#     dict(value='dlOnly', dist_name=_NRREL42, parameter='sCellOperationalMode'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL42, parameter='gnbPlmn')
# ]

PARAMETERS_TO_UPDATE_AD_B1_NRREL2 = [
    dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL42, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL42, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL42, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL42, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL42, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL42, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL42, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL42, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-4/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-4/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AD_B2_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'}
    # {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '6'},
    # {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'administrativeState', 'value': 'Locked'}
]

# PARAMETERS_TO_UPDATE_AD_B2_NRREL1 = [
#     dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
#     dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL51, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B2_NRREL2 = [
#     dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
#     dict(value='14', dist_name=_NRREL52, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL52, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B2_NRREL1_trunk = [
#     dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
#     dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
#     dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
#     dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
#     dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL51, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B2_NRREL2_trunk = [
#     dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
#     dict(value='14', dist_name=_NRREL52, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
#     dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
#     dict(value='forbidden', dist_name=_NRREL52, parameter='handoverAllowedSARedCap'),
#     dict(value='dlOnly', dist_name=_NRREL52, parameter='sCellOperationalMode'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL52, parameter='gnbPlmn')
# ]

PARAMETERS_TO_UPDATE_AD_B2_LOCKG1 = [
    dict(value='Locked', dist_name=_NRCELL4, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AD_B2_UNLOCKG1 = [
    dict(value='Unlocked', dist_name=_NRCELL4, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AD_B2_LOCKG2 = [
    dict(value='Locked', dist_name=_NRCELL14, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AD_B2_UNLOCKG2 = [
    dict(value='Unlocked', dist_name=_NRCELL14, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AD_B2_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AD_B3_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'}
]

# PARAMETERS_TO_UPDATE_AD_B3_NRREL41 = [
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL41, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL41, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL41, parameter='handoverAllowedSA'),
#     dict(value='5', dist_name=_NRREL41, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL41, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL41, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL41, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL41, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B3_NRREL42 = [
#     dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL42, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL42, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL42, parameter='handoverAllowedSA'),
#     dict(value='14', dist_name=_NRREL42, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL42, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL42, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL42, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL42, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B3_NRREL41_trunk = [
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL41, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL41, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL41, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL41, parameter='handoverAllowedSA'),
#     dict(value='5', dist_name=_NRREL41, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL41, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL41, parameter='removeNotAllowed'),
#     dict(value='false', dist_name=_NRREL41, parameter='nrDcAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL41, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL41, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B3_NRREL42_trunk = [
#     dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL42, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL42, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL42, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL42, parameter='handoverAllowedSA'),
#     dict(value='14', dist_name=_NRREL42, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL42, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL42, parameter='removeNotAllowed'),
#     dict(value='false', dist_name=_NRREL42, parameter='nrDcAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL42, parameter='sCellAdditionMethod'),
#     dict(value='forbidden', dist_name=_NRREL42, parameter='handoverAllowedSARedCap'),
#     dict(value='dlOnly', dist_name=_NRREL42, parameter='sCellOperationalMode'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL42, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B3_NRREL51 = [
#     dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
#     dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL51, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AD_B3_NRREL52 = [
#     dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
#     dict(value='14', dist_name=_NRREL52, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL52, parameter='gnbPlmn')
# ]

PARAMETERS_TO_UPDATE_AD_B3_1 = [
    {'dist_name': '_NRBTSname', 'parameter': 'actInterFreqHoSA', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_AD_B3_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-4/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-4/NRREL-2'},
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AE_B3_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    # {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '6'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_AE_B3_NRREL1 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AE_B3_NRREL1_trunk = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL11, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL11, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AE_B3_NRREL1_23R2 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

# PARAMETERS_TO_UPDATE_AE_B3_NRREL2 = [
#     dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
#     dict(value='2', dist_name=_NRREL12, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL12, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AE_B3_NRREL2_trunk = [
#     dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
#     dict(value='2', dist_name=_NRREL12, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
#     dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
#     dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
#     dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
#     dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL12, parameter='gnbPlmn')
# ]

PARAMETERS_TO_UPDATE_AE_B3_unlock = [
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_AE_B3_teardown1 = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-1'}
]

PARAMETERS_TO_UPDATE_AE_B3_teardown2 = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AE_B3_02_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    # {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '10'},
    # {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '8'},
    # {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'secondaryPathMaxQueueingDelay', 'value': '6'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_AE_B3_02_NRREL2 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AE_B3_02_NRREL2_trunk = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL12, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL12, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AE_B3_02_NRREL2_23R2 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AE_B3_02_teardown1 = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-1'}
]

PARAMETERS_TO_UPDATE_AE_B3_02_teardown2 = [
    {'dist_name': '_NRBTSname/NRCELL-1/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AB_B1_03_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'administrativeState', 'value': 'Locked'}
]

# PARAMETERS_TO_UPDATE_AB_B1_03_NRREL1 = [
#     dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL21, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL21, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL21, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL21, parameter='handoverAllowedSA'),
#     dict(value='1', dist_name=_NRREL21, parameter='lcrId'),
#     dict(value='1', dist_name=_NRREL21, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL21, parameter='removeNotAllowed'),
#     dict(value='blind', dist_name=_NRREL21, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL21, parameter='gnbPlmn')
# ]
#
# PARAMETERS_TO_UPDATE_AB_B1_03_NRREL2 = [
#     dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrpOffset'),
#     dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrqOffset'),
#     dict(value=_gnb_id, dist_name=_NRREL22, parameter='gNbId'),
#     dict(value='32', dist_name=_NRREL22, parameter='gNbIdLength'),
#     dict(value='allowed', dist_name=_NRREL22, parameter='handoverAllowedSA'),
#     dict(value='3', dist_name=_NRREL22, parameter='lcrId'),
#     dict(value='2', dist_name=_NRREL22, parameter='nrRelId'),
#     dict(value='false', dist_name=_NRREL22, parameter='removeNotAllowed'),
#     dict(value='blind', dist_name=_NRREL22, parameter='sCellAdditionMethod'),
#     dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
#          dist_name=_NRREL22, parameter='gnbPlmn')
# ]

PARAMETERS_TO_UPDATE_AB_B1_03_unlock = [
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': '_NRBTSname/NRCELL-14', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_AB_B1_03_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-2/NRREL-2'}
]

PARAMETERS_TO_UPDATE_AD_B1_03_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'administrativeState', 'value': 'Locked'},
    # {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_AD_B1_03_NRREL1 = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_03_NRREL2 = [
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL52, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL52, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_03_NRREL1_trunk = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL51, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL51, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL51, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_03_NRREL2_trunk = [
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL52, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL52, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL52, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL52, parameter='isRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL52, parameter='rsrpOffsetRplCellForPSCell'),
    dict(value='0dB', dist_name=_NRREL52, parameter='rsrqOffsetRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL52, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_03_NRREL1_23R2 = [
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL51, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL51, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL51, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL51, parameter='handoverAllowedSA'),
    dict(value='4', dist_name=_NRREL51, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL51, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL51, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL51, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL51, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL51, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL51, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL51, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_03_NRREL2_23R2 = [
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL52, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL52, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL52, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL52, parameter='handoverAllowedSA'),
    dict(value='14', dist_name=_NRREL52, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL52, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL52, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL52, parameter='nrDcAllowed'),
    dict(value='blind', dist_name=_NRREL52, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL52, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL52, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL52, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AD_B1_03_unlock = [
    {'dist_name': '_NRBTSname/NRCELL-1', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': '_NRBTSname/NRCELL-2', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    # {'dist_name': '_NRBTSname/NRCELL-3', 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': '_NRBTSname/NRCELL-11', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_AD_B1_03_teardown = [
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-1'},
    {'dist_name': '_NRBTSname/NRCELL-5/NRREL-2'}
]

PARAMETERS_TO_UPDATE_gnb_DSS_close = [
    {'dist_name': '_NRBTSname', 'parameter': 'actLteNrDss', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'lteNrDssMode', 'value': 'none'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'lteNrDssMode', 'value': 'none'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'actPRBBlanking', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-4/NRDSSLTE-1', 'parameter': 'actRateMatchedCsiIm', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-5/NRDSSLTE-1', 'parameter': 'actRateMatchedCsiIm', 'value': 'false'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nbrOfBlankedPRBsHighEdgeDL', 'value': '0'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nbrOfBlankedPRBsHighEdgeUL', 'value': '0'},
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='65', minNrDssRatio='65')],
         dist_name=_NRBTSname+'/NRCELL-4'+'/NRDSSLTE-1', parameter='lteNrDssDlRatio'),
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='65', minNrDssRatio='65')],
         dist_name=_NRBTSname+'/NRCELL-5'+'/NRDSSLTE-1', parameter='lteNrDssDlRatio')
]

PARAMETERS_TO_UPDATE_gnb_DSS_open = [
    {'dist_name': '_NRBTSname', 'parameter': 'actLteNrDss', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'lteNrDssMode', 'value': 'DSS_Phase_3'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'lteNrDssMode', 'value': 'DSS_Phase_3'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'actPRBBlanking', 'value': 'true'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nbrOfBlankedPRBsHighEdgeDL', 'value': '1'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nbrOfBlankedPRBsHighEdgeUL', 'value': '1'},
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='95', minNrDssRatio='95')],
         dist_name=_NRBTSname+'/NRCELL-4'+'/NRDSSLTE-1', parameter='lteNrDssDlRatio'),
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='95', minNrDssRatio='95')],
         dist_name=_NRBTSname+'/NRCELL-5'+'/NRDSSLTE-1', parameter='lteNrDssDlRatio')
]

PARAMETERS_TO_UPDATE_gnb_DSS_close_361 = [
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-36111/NRBTS-36111/NRSYSINFO_PROFILE-1'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-36111/NRBTS-36111/NRSYSINFO_PROFILE-1'},
    dict(value=[dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-4', parameter='cellBwpList'),
    dict(value=[dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-5', parameter='cellBwpList')
]

PARAMETERS_TO_UPDATE_gnb_DSS_close_371 = [
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-37111/NRBTS-37111/NRSYSINFO_PROFILE-1'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-37111/NRBTS-37111/NRSYSINFO_PROFILE-1'},
    dict(value=[dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-4', parameter='cellBwpList'),
    dict(value=[dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-5', parameter='cellBwpList')
]

PARAMETERS_TO_UPDATE_gnb_DSS_close_380 = [
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-38011/NRBTS-38011/NRSYSINFO_PROFILE-1'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-38011/NRBTS-38011/NRSYSINFO_PROFILE-1'},
    dict(value=[dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-4', parameter='cellBwpList'),
    dict(value=[dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-20', cellBwpId='0'),
                dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-21', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-5', parameter='cellBwpList')
]

PARAMETERS_TO_UPDATE_gnb_DSS_open_361 = [
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-36111/NRBTS-36111/NRSYSINFO_PROFILE-2'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-36111/NRBTS-36111/NRSYSINFO_PROFILE-2'},
    dict(value=[dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-200', cellBwpId='0'),
                dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-201', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-4', parameter='cellBwpList'),
    dict(value=[dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-200', cellBwpId='0'),
                dict(bwpDN='MRBTS-36111/NRBTS-36111/BWP_PROFILE-201', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-5', parameter='cellBwpList')
]

PARAMETERS_TO_UPDATE_gnb_DSS_open_371 = [
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-37111/NRBTS-37111/NRSYSINFO_PROFILE-2'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-37111/NRBTS-37111/NRSYSINFO_PROFILE-2'},
    dict(value=[dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-200', cellBwpId='0'),
                dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-201', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-4', parameter='cellBwpList'),
    dict(value=[dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-200', cellBwpId='0'),
                dict(bwpDN='MRBTS-37111/NRBTS-37111/BWP_PROFILE-201', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-5', parameter='cellBwpList')
]

PARAMETERS_TO_UPDATE_gnb_DSS_open_380 = [
    {'dist_name': '_NRBTSname/NRCELL-4', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-38011/NRBTS-38011/NRSYSINFO_PROFILE-2'},
    {'dist_name': '_NRBTSname/NRCELL-5', 'parameter': 'nrSysInfoProfileDN',
     'value': 'MRBTS-38011/NRBTS-38011/NRSYSINFO_PROFILE-2'},
    dict(value=[dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-200', cellBwpId='0'),
                dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-201', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-4', parameter='cellBwpList'),
    dict(value=[dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-200', cellBwpId='0'),
                dict(bwpDN='MRBTS-38011/NRBTS-38011/BWP_PROFILE-201', cellBwpId='1')],
         dist_name=_NRBTSname + '/NRCELL-5', parameter='cellBwpList')
]

PARAMETERS_TO_UPDATE_XP_delete = [
    {'dist_name': 'MRBTS-37111/MNL-1/MNLENT-1/XPAP-1'}
]
