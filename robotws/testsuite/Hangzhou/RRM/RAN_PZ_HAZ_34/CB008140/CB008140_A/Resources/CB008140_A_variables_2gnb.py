from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Li Xiaodan'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_id = str(tl.gnbs[0].global_bts_id)
_MRBTSname = 'MRBTS-'+_global_id
_NRBTSnames = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_gnb2_id = str(tl.gnbs[1].instance_id)
_global2_id = str(tl.gnbs[1].global_bts_id)
_MRBTSname2 = 'MRBTS-'+_global2_id
_NRBTSnames2 = 'NRBTS-'+_gnb2_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id

_gnb3_id = str(tl.gnbs[2].instance_id)
_MRBTSname3 = 'MRBTS-'+_gnb3_id
_NRBTSnames3 = 'NRBTS-'+_gnb3_id
_NRBTSname3 = _MRBTSname3+'/NRBTS-'+_gnb3_id
_XPIP3 = _MRBTSname3+'/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3'
_XPIP_gnb3 = str(tl.gnbs[2].dus[0].f1_c_ip_addr)

_gnb4_id = str(tl.gnbs[3].instance_id)
_MRBTSname4 = 'MRBTS-'+_gnb4_id
_NRBTSnames4 = 'NRBTS-'+_gnb4_id
_NRBTSname4 = _MRBTSname4+'/NRBTS-'+_gnb4_id
_XPIP_gnb4 = str(tl.gnbs[3].dus[0].f1_c_ip_addr)

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
_NRREL12 = _NRCELL12+'/NRREL-1'
_NRREL122 = _NRCELL12+'/NRREL-2'
_NRREL13 = _NRCELL13+'/NRREL-1'
_NRREL131 = _NRCELL131+'/NRREL-1'

_NRCELL21 = _NRBTSname2+'/NRCELL-1'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL221 = _NRBTSname2+'/NRCELL-21'
_NRCELL23 = _NRBTSname2+'/NRCELL-3'
_NRCELL231 = _NRBTSname2+'/NRCELL-31'
_NRREL21 = _NRCELL21+'/NRREL-1'
_NRREL22 = _NRCELL22+'/NRREL-1'

_NRCELL31 = _NRBTSname3+'/NRCELL-1'
_NRCELL311 = _NRBTSname3+'/NRCELL-11'
_NRCELL32 = _NRBTSname3+'/NRCELL-2'
_NRCELL33 = _NRBTSname3+'/NRCELL-3'
_NRCELL331 = _NRBTSname3+'/NRCELL-31'
_NRREL31 = _NRCELL31+'/NRREL-1'
_NRREL32 = _NRCELL32+'/NRREL-1'
_NRREL33 = _NRCELL33+'/NRREL-1'
_NRREL331 = _NRCELL331+'/NRREL-1'

_NRCELL41 = _NRBTSname4+'/NRCELL-1'
_NRCELL42 = _NRBTSname4+'/NRCELL-2'
_NRCELL421 = _NRBTSname4+'/NRCELL-21'
_NRCELL43 = _NRBTSname4+'/NRCELL-3'
_NRCELL431 = _NRBTSname4+'/NRCELL-31'
_NRREL41 = _NRCELL41+'/NRREL-1'
_NRREL431 = _NRCELL431+'/NRREL-1'


parameters_to_update_disable8927_14474_GNB1 = [
    {'dist_name': _NRCELL11, 'parameter': 'actRat1Alloc', 'value': 'false'},
    {'dist_name': _NRCELL111, 'parameter': 'actRat1Alloc', 'value': 'false'},
    {'dist_name': _NRCELL12, 'parameter': 'actRat1Alloc', 'value': 'false'},
    {'dist_name': _NRCELL13, 'parameter': 'actRat1Alloc', 'value': 'false'},
    {'dist_name': _NRCELL11, 'parameter': 'actPrbLimForVoNrRat1', 'value': 'false'},
    {'dist_name': _NRCELL111, 'parameter': 'actPrbLimForVoNrRat1', 'value': 'false'},
    {'dist_name': _NRCELL12, 'parameter': 'actPrbLimForVoNrRat1', 'value': 'false'},
    {'dist_name': _NRCELL13, 'parameter': 'actPrbLimForVoNrRat1', 'value': 'false'},
]

parameters_to_delete_disable8927_14474_GNB1 = [
    {'dist_name': _NRCELL11, 'parameter': 'percRedSEDlRat1VoNR'},
    {'dist_name': _NRCELL111, 'parameter': 'percRedSEDlRat1VoNR'},
    {'dist_name': _NRCELL12, 'parameter': 'percRedSEDlRat1VoNR'},
    {'dist_name': _NRCELL13, 'parameter': 'percRedSEDlRat1VoNR'},
]


PARAMETERS_TO_DELETE_GNB1_CELL3 = [
    {'dist_name': _NRREL13}
]

PARAMETERS_TO_DELETE_GNB1_CELL1 = [
    {'dist_name': _NRREL11}
]

parameters_to_update_AE_003 = [
    dict(value='0dB', dist_name=_NRREL13, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL13, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL13, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL13, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL13, parameter='handoverAllowedSA'),
    dict(value='3', dist_name=_NRREL13, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL13, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL13, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL13, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL13, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL13, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL13, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL13, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL13, parameter='gnbPlmn')
]

parameters_to_update_AE_003_pre_GNB1 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL13, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL13, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

parameters_to_update_AE_003_pre_GNB2 = [
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL231, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL231, 'parameter': 'administrativeState', 'value': 'Locked'}
]

parameters_to_update_AE_003_recover_GNB2 = [
    {'dist_name': _NRCELL231, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

parameters_to_update_AE_003_recover_GNB1 = [
    {'dist_name': _NRCELL13, 'parameter': 'cellBarred', 'value': 'barred'}
]

parameters_to_update_AE_005 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

parameters_to_update_AE_005_pre_GNB1 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferAndRLQualityBased'},
    {'dist_name': _NRCELL11, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRBTSnames + '/NRPMRNL-1', 'parameter': 'miNrCaDu', 'value': '5min'},
    {'dist_name': _NRBTSnames + '/NRPMRNL-1', 'parameter': 'miNrLowRlcReport', 'value': '5min'},
    {'dist_name': _NRCELL111, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

parameters_to_update_AE_005_pre_GNB2 = [
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'bufferAndRLQualityBased'},
    {'dist_name': _NRCELL22, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRBTSnames2 + '/NRPMRNL-1', 'parameter': 'miNrLowRlcReport', 'value': '5min'},
    {'dist_name': _NRBTSnames2 + '/NRPMRNL-1', 'parameter': 'miNrCaDu', 'value': '5min'}
]

parameters_to_update_AE_005_recover_GNB1 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL111, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'}
]

parameters_to_update_AE_005_recover_GNB2 = [
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'}
]

LIST_TO_ADD_GNB1_GG001 = [
    dict(value=[dict(ipV4AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
                     ipV6AddressDN1=_MRBTSname + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname + '/SNSSAI-1', parameter='xgUplane')
]

PARAMETERS_TO_DELETE_GNB2_GG001 = [
    dict(dist_name=_NRBTSname2+'/NRDU-9999', parameter='xgUplane')
]

LIST_TO_ADD_GNB2_GG001 = [
    {'dist_name': _NRBTSname2 + '/NRDU-9999', 'parameter': 'xgUplane',
     'value': [{'ipV6AddressDN1': _MRBTSname2 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}]},
    dict(value=[dict(ipV4AddressDN1=_MRBTSname2 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
                     ipV6AddressDN1=_MRBTSname2 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname2 + '/SNSSAI-1', parameter='xgUplane')
]

counter_id_AE005_gNB1 = [
    'M55316C03001', 'M55310C01022', 'M55310C20001'
]

counter_id_AE005_gNB1_M55316C05001 = [
    'M55316C05001'
]

counter_dic_path_AE005_gNB1 = [
    'BTS/CELLS/NRCELL-1/NCADU', 'BTS/CELLS/NRCELL-1/NLRLC', 'BTS/CELLS/NRCELL-1/NLRLC'
]

counter_dic_path_AE005_gNB1_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NCADU', 'BTS/' + _NRBTSname + '/NRCELL-1/NLRLC',
    'BTS/' + _NRBTSname + '/NRCELL-1/NLRLC'
]

counter_dic_path_AE005_gNB1_M55316C05001 = [
    'BTS/CELLS/NRCELL-1/NCADU'
]

counter_dic_path_AE005_gNB1_M55316C05001_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NCADU'
]

counter_id_AE005_gNB2_M55316C09001 = [
    'M55316C09001'
]

counter_dic_path_AE005_gNB2_M55316C09001 = [
    'BTS/CELLS/NRCELL-2/NCADU'
]

counter_dic_path_AE005_gNB2_M55316C09001_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/NCADU'
]

counter_id_AE005_gNB2 = [
    'M55310C01021', 'M55310C20000'
]


counter_dic_path_AE005_gNB2 = [
    'BTS/CELLS/NRCELL-2/NLRLC', 'BTS/CELLS/NRCELL-2/NLRLC'
]

counter_dic_path_AE005_gNB2_trunk = [
    'BTS/' + _NRBTSname2 + '/NRCELL-2/NLRLC', 'BTS/' + _NRBTSname2 + '/NRCELL-2/NLRLC'
]


parameters_to_update_AE_007 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='31', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_Parametre_GNB1_AE007 = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '87',
                'a1ThresholdSCellAddSsbRsrpTDD': '87', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
    ]

parameters_to_update_AE_007_pre_GNB1 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRBTSname, 'parameter': 'actBufferBasedSCellAddition', 'value': 'oneShot_Dl_Fr1'},
    {'dist_name': _NRBTSname, 'parameter': 'actSCellReleaseForInactiveSCell', 'value': 'timer_based_Fr1'},
    {'dist_name': _NRCELL11, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL111, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

parameters_to_update_actOptimizedFlowControl_GNB1 = [
    {'dist_name': _NRCELL11, 'parameter': 'actOptimizedFlowControl', 'value': 'optimizedAllUe'}
]


parameters_to_update_AE_007_pre_GNB2 = [
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRBTSname2, 'parameter': 'actBufferBasedSCellAddition', 'value': 'oneShot_Dl_Fr1'},
    {'dist_name': _NRBTSname2, 'parameter': 'actSCellReleaseForInactiveSCell', 'value': 'timer_based_Fr1'},
    {'dist_name': _NRCELL231, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'}
]

parameters_to_update_actOptimizedFlowControl_GNB2 = [
    {'dist_name': _NRCELL231, 'parameter': 'actOptimizedFlowControl', 'value': 'optimizedAllUe'}
]

parameters_to_update_AE_007_recover_GNB1 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL11, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL111, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'}
]

parameters_to_update_AE_007_recover_GNB2 = [
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL231, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'}
]

PARAMETERS_TO_UPDATE_AB_B2_pre = [
    # {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
    {'dist_name': _NRBTSname, 'parameter': 'actBufferBasedSCellAddition', 'value': 'disabled'},
    {'dist_name': _NRBTSname, 'parameter': 'actSCellReleaseForInactiveSCell', 'value': 'disabled'},
    {'dist_name': _NRCELL12, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ADD_AB_B2_pre = [
    {'dist_name': _NRCELL12, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL12, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '87',
                'a1ThresholdSCellAddSsbRsrpTDD': '87', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]},
]

PARAMETERS_TO_UPDATE_AB_B3_005 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL122, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL122, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL122, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL122, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL122, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL122, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL122, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL122, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL122, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL122, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL122, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_005_23R2 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL122, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL122, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL122, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL122, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL122, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL122, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL122, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL122, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL122, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL122, parameter='gnbPlmn')
]

PARAMETERS_TO_DELETE_NRREL_GNB1_AB_B3 = [
    {'dist_name': _NRREL12},
    {'dist_name': _NRREL122}
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL12_trunk = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL11_23R2 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL12_23R2 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL11 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_NRREL12 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='32', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B2_LOCKG1 = [
    dict(value='Locked', dist_name=_NRCELL11, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG1 = [
    dict(value='Unlocked', dist_name=_NRCELL11, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_LOCKG2 = [
    dict(value='Locked', dist_name=_NRCELL111, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B2_UNLOCKG2 = [
    dict(value='Unlocked', dist_name=_NRCELL111, parameter='administrativeState')
]

PARAMETERS_TO_UPDATE_AB_B3_002 = [
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL12, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL12, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL12, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL12, parameter='handoverAllowedSA'),
    dict(value='1', dist_name=_NRREL12, parameter='lcrId'),
    dict(value='1', dist_name=_NRREL12, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL12, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL12, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL12, parameter='handoverAllowedSARedCap'),
    dict(value='blind', dist_name=_NRREL12, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL12, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL12, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL12, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_AB_B3_002_1 = [
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL122, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL122, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL122, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL122, parameter='handoverAllowedSA'),
    dict(value='11', dist_name=_NRREL122, parameter='lcrId'),
    dict(value='2', dist_name=_NRREL122, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL122, parameter='removeNotAllowed'),
    dict(value='false', dist_name=_NRREL122, parameter='nrDcAllowed'),
    dict(value='forbidden', dist_name=_NRREL122, parameter='handoverAllowedSARedCap'),
    dict(value='blind', dist_name=_NRREL122, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL122, parameter='sCellOperationalMode'),
    dict(value='true', dist_name=_NRREL122, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL122, parameter='gnbPlmn')
]

PARAMETERS_TO_ONLINE_MODIFY_GNB1_DSS = [
    dict(value='notBarred', dist_name=_NRCELL12, parameter='cellBarred'),
    dict(value='DSS_Phase_3', dist_name=_NRCELL12, parameter='lteNrDssMode'),
    dict(value='15', dist_name=_NRCELL12, parameter='type0SearchSpaceConfigurationIndex'),
    dict(value='true', dist_name=_NRCELL12+'/NRDSSLTE-1', parameter='actLteNrDssFastAlloc'),
    dict(value=[dict(dlResourceSharingAlgo='DL PRB load based', maxNrDssRatio='100', minNrDssRatio='5')],
         dist_name=_NRCELL12+'/NRDSSLTE-1', parameter='lteNrDssDlRatio'),
    dict(value=[dict(bwpDN=_NRBTSname + '/BWP_PROFILE-131', cellBwpId='0'),
                dict(bwpDN=_NRBTSname + '/BWP_PROFILE-222', cellBwpId='1')],
         dist_name=_NRCELL12, parameter='cellBwpList'),
    dict(value=_NRBTSname + '/NRSYSINFO_PROFILE-22', dist_name=_NRCELL12, parameter='nrSysInfoProfileDN')
]

PARAMETERS_TO_UPDATE_AD_B1_03_pre = [
    {'dist_name': '_NRBTSname/NRDU-9999', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'}
]
