from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'zhang qingqing'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'qingqing.zhang@nokia-sbell.com'

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
_NRADJ2 = _NRBTSname2 + '/NRADJGNB-1'
_NRTAC_20200_2 = _NRBTSname2 + '/TRACKINGAREA-20200'

_gnb3_id = str(tl.gnbs[2].instance_id)
_MRBTSname3 = 'MRBTS-'+_gnb3_id
_NRBTSnames3 = 'NRBTS-'+_gnb3_id
_NRBTSname3 = _MRBTSname3+'/NRBTS-'+_gnb3_id
_NRPLMN_31 = _NRBTSname3 + '/NRPLMN-1'
_NRPLMN_32 = _NRBTSname3 + '/NRPLMN-2'
_NRADJ11 = _NRBTSname3 + '/NRADJGNB-11'

_gnb4_id = str(tl.gnbs[3].instance_id)
_MRBTSname4 = 'MRBTS-'+_gnb4_id
_NRBTSnames4 = 'NRBTS-'+_gnb4_id
_NRBTSname4 = _MRBTSname4 + '/NRBTS-' + _gnb4_id

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
_NRCELL231 = _NRBTSname2+'/NRCELL-31'
_NRCELL22 = _NRBTSname2+'/NRCELL-2'
_NRCELL23 = _NRBTSname2+'/NRCELL-3'
_NRREL211 = _NRCELL211+'/NRREL-1'
_NRREL22 = _NRCELL22+'/NRREL-1'
_NRREL221 = _NRCELL22+'/NRREL-2'
_NRHOIF131 = _NRCELL131+'/NRHOIF-1'
_NRPLMNSET_SA_21 = _NRCELL21+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_21 = _NRCELL21+'/NRPLMNSET_NSA-1'
_NRPLMNSET_SA_22 = _NRCELL22+'/NRPLMNSET_SA-1'
_NRPLMNSET_NSA_22 = _NRCELL22+'/NRPLMNSET_NSA-1'

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

_XPIP = _MRBTSname+'/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-2'
_XPIP_gnb1 = str(tl.gnbs[0].dus[0].f1_c_ip_addr)
_XPIP_gnb2 = str(tl.gnbs[1].dus[0].f1_c_ip_addr)
_XPIP_gnb4 = str(tl.gnbs[3].dus[0].f1_c_ip_addr)

PARAMETERS_TO_UPDATE_GNB1_CELL1_SHUTDOWN = [
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Shutting Down'}
]

PARAMETERS_TO_UPDATE_GNB1_CELL1_LOCK = [
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_GNB1_CELL1_UNLOCK = [
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_GNB2_CELL11_LOCK = [
    {'dist_name': _NRCELL211, 'parameter': 'administrativeState', 'value': 'Locked'}
]

PARAMETERS_TO_UPDATE_GNB2_CELL11_UNLOCK = [
    {'dist_name': _NRCELL211, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_UPDATE_GNB3_CELL2_SHUTDOWN = [
    {'dist_name': _NRCELL32, 'parameter': 'administrativeState', 'value': 'Shutting Down'}
]

PARAMETERS_TO_ADD_GNB1_K001 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_Parametre_GNB1_K001 = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL11, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '87',
                'a1ThresholdSCellAddSsbRsrpTDD': '87', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]},
    {'dist_name': _NRCELL11, 'parameter': 'a1MeashoSsbRsrpSA',
     'value': [{'a1HysteresishoSsbRsrpSA': '0', 'a1ThresholdhoSsbRsrpSA': '98',
                'a1TimeToTriggerhoSsbRsrpSA': 'ms480'}]},
    {'dist_name': _NRCELL11, 'parameter': 'a2MeashoSsbRsrpSA',
     'value': [{'a2HysteresishoSsbRsrpSA': '0', 'a2ThresholdhoSsbRsrpSA': '97',
                'a2TimeToTriggerhoSsbRsrpSA': 'ms480'}]}
]

PARAMETERS_TO_DElETE_GNB1_K001 = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeashoSsbRsrpSA'},
    {'dist_name': _NRCELL11, 'parameter': 'a2MeashoSsbRsrpSA'}
]

PARAMETERS_TO_UPDATE_GNB1_K001 = [
    {'dist_name': _NRBTSname, 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ADD_GNB3_K001 = [
    dict(value='0dB', dist_name=_NRREL321, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL321, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL321, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL321, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL321, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL321, parameter='handoverAllowedSARedCap'),
    dict(value='11', dist_name=_NRREL321, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL321, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL321, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL321, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL321, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL321, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL321, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL321, parameter='gnbPlmn'),
]

PARAMETERS_TO_ADD_Parametre_GNB3_K001 = [
    {'dist_name': _NRCELL32, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL32, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '87',
                'a1ThresholdSCellAddSsbRsrpTDD': '87', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]}
]

PARAMETERS_TO_UPDATE_GNB3_K001 = [
    {'dist_name': _NRBTSname3, 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': _NRCELL32, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_UPDATE_GNB1_K001_1 = [
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRREL11, 'parameter': 'sCellAdditionMethod', 'value': 'blind'}
]

PARAMETERS_TO_ADD_GNB1_K001_1 = [
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_DELETE_GNB1_K001_1 = [
    {'dist_name': _NRCELL11, 'parameter': 'a2MeashoSsbRsrpSA'}
]

PARAMETERS_TO_ADD_Parametre_GNB1_K001_1 = [
    {'dist_name': _NRCELL11, 'parameter': 'a2MeashoSsbRsrpSA',
     'value': [{'a2HysteresishoSsbRsrpSA': '0', 'a2ThresholdhoSsbRsrpSA': '60',
                'a2TimeToTriggerhoSsbRsrpSA': 'ms480'}]}
]

PARAMETERS_TO_ADD_Parametre_GNB1_K001_recover = [
    {'dist_name': _NRCELL11, 'parameter': 'a1MeashoSsbRsrpSA',
     'value': [{'a1HysteresishoSsbRsrpSA': '0', 'a1ThresholdhoSsbRsrpSA': '81',
                'a1TimeToTriggerhoSsbRsrpSA': 'ms480'}]},
    {'dist_name': _NRCELL11, 'parameter': 'a2MeashoSsbRsrpSA',
     'value': [{'a2HysteresishoSsbRsrpSA': '0', 'a2ThresholdhoSsbRsrpSA': '80',
                'a2TimeToTriggerhoSsbRsrpSA': 'ms480'}]}
]

PARAMETERS_TO_DELETE_NRREL_GNB1_K001 = [
    {'dist_name': _NRREL11},
    {'dist_name': _NRREL112}
]

PARAMETERS_TO_DElETE_Recover_GNB3_K001 = [
    {'dist_name': _NRCELL32, 'parameter': 'a1MeasSCellAddEnabled'},
    {'dist_name': _NRCELL32, 'parameter': 'a1MeasSCellAddSsbRsrp'}
]

PARAMETERS_TO_DELETE_NRREL_GNB2_K007 = [
    {'dist_name': _NRREL211}
]

PARAMETERS_TO_ADD_GNB1_K007 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='11', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_GNB2_K007 = [
    dict(value='0dB', dist_name=_NRREL211, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL211, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL211, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL211, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL211, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL211, parameter='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL211, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL211, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL211, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL211, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL211, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL211, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL211, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL211, parameter='gnbPlmn'),
]

PARAMETERS_TO_UPDATE_GNB1_K007 = [
    {'dist_name': _NRBTSname, 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': _NRBTSname + 'NRADJGNB-13', 'parameter': 'weightForIgnbCaSelection', 'value': '2'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_UPDATE_GNB2_K007 = [
    {'dist_name': _NRBTSname2, 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': _NRCELL211, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL23, 'parameter': 'weightForSCellSelection', 'value': '25'}
]

PARAMETERS_TO_DELETE_NRREL_GNB1_K007 = [
    {'dist_name': _NRREL112}
]

PARAMETERS_TO_DELETE_NRREL_GNB1_K007_1 = [
    {'dist_name': _NRREL11}
]

PARAMETERS_TO_ADD_Parametre_GNB1_K008 = [
    {'dist_name': _NRCELL11, 'parameter': 'a2MeasSCellRelEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL11, 'parameter': 'a2MeasSCellRelSsbRsrp',
     'value': [{'a2HysteresisSCellRelSsbRsrp': '0', 'a2ThresholdSCellRelSsbRsrp': '93',
                'a2TimeToTriggerSCellRelSsbRsrp': '2560ms'}]}
]

PARAMETERS_TO_UPDATE_GNB1_K008 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'blind'},
    {'dist_name': _NRBTSname, 'parameter': 'actGrflShdn', 'value': 'true'}
]

PARAMETERS_TO_UPDATE_GNB2_K008 = [
    {'dist_name': _NRBTSname2, 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'blind'},
    # {'dist_name': _NRCELL32, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    # {'dist_name': _NRCELL31, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    # {'dist_name': _NRCELL311, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    # {'dist_name': _NRCELL33, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    # {'dist_name': _NRCELL331, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'infinity'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_ADD_Parametre_GNB2_K008 = [
    {'dist_name': _NRCELL22, 'parameter': 'a1MeasSCellAddEnabled', 'value': 'rsrp'},
    {'dist_name': _NRCELL22, 'parameter': 'a1MeasSCellAddSsbRsrp',
     'value': [{'a1HysteresisSCellAddSsbRsrp': '0', 'a1ThresholdSCellAddSsbRsrpFDD': '87',
                'a1ThresholdSCellAddSsbRsrpTDD': '87', 'a1TimeToTriggerSCellAddSsbRsrp': '320ms'}]},
]

PARAMETERS_TO_ADD_GNB2_K008 = [
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL22, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL22, parameter='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL22, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL22, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL22, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL22, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL22, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL22, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL22, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL22, parameter='gnbPlmn'),
]

PARAMETERS_TO_UPDATE_GNB2_K008_1 = [
    dict(value='blind', dist_name=_NRREL22, parameter='sCellAdditionMethod')
]

PARAMETERS_TO_UPDATE_GNB2_K008_2 = [
    dict(value='covBasedA1', dist_name=_NRREL22, parameter='sCellAdditionMethod')
]

PARAMETERS_TO_ADD_Parametre_GNB1_K008_2 = [
    {'dist_name': _NRCELL11, 'parameter': 'a2MeasSCellRelSsbRsrp',
     'value': [{'a2HysteresisSCellRelSsbRsrp': '0', 'a2ThresholdSCellRelSsbRsrp': '40',
                'a2TimeToTriggerSCellRelSsbRsrp': '2560ms'}]}
]

PARAMETERS_TO_DElETE_GNB1_K008_2 = [
    {'dist_name': _NRCELL11, 'parameter': 'a2MeasSCellRelSsbRsrp'}
]

PARAMETERS_TO_ADD_GNB2_K008_2 = [
    dict(value='0dB', dist_name=_NRREL221, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL221, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL221, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL221, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL221, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL221, parameter='handoverAllowedSARedCap'),
    dict(value='11', dist_name=_NRREL221, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL221, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL221, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL221, parameter='removeNotAllowed'),
    dict(value='covBasedA1', dist_name=_NRREL221, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL221, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL221, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL221, parameter='gnbPlmn'),
]

PARAMETERS_TO_recover_GNB1_K008 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL11, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_DELETE_GNB1_K008 = [
    {'dist_name': _NRCELL11, 'parameter': 'a2MeasSCellRelEnabled'},
    {'dist_name': _NRCELL11, 'parameter': 'a2MeasSCellRelSsbRsrp'}
]

PARAMETERS_TO_DELETE_GNB2_K008 = [
    {'dist_name': _NRCELL22, 'parameter': 'a1MeasSCellAddEnabled'},
    {'dist_name': _NRCELL22, 'parameter': 'a1MeasSCellAddSsbRsrp'}
]

PARAMETERS_TO_DELETE_NRREL_GNB2_K008 = [
    {'dist_name': _NRREL22},
    {'dist_name': _NRREL221}
]

PARAMETERS_TO_recover_GNB2_K008 = [
    {'dist_name': _NRBTSname2, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'barred'}
    # {'dist_name': _NRCELL32, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
]

PARAMETERS_TO_ADD_GNB1_K017 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL112, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL112, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL112, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL112, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL112, parameter='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL112, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL112, parameter='nrDcAllowed'),
    dict(value='2', dist_name=_NRREL112, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL112, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL112, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL112, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL112, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL112, parameter='gnbPlmn')
]

PARAMETERS_TO_UPDATE_GNB1_K017 = [
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

PARAMETERS_TO_UPDATE_GNB2_K017 = [
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'barred'},
    {'dist_name': _NRCELL231, 'parameter': 'cellBarred', 'value': 'barred'}
]

PARAMETERS_TO_DELETE_NRREL_GNB1_K017 = [
    {'dist_name': _NRREL112}
]

PARAMETERS_TO_DELETE_Parameter_GNB1_K017 = [
    {'dist_name': _NRREL11, 'parameter': 'sCellAdditionMethod'},
]

PARAMETERS_TO_ADD_GNB1_K027 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb2_id, dist_name=_NRREL11, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL11, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, parameter='handoverAllowedSARedCap'),
    dict(value='31', dist_name=_NRREL11, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL11, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL11, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL11, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL11, parameter='gnbPlmn')
]

PARAMETERS_TO_ADD_GNB2_K027 = [
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL22, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL22, parameter='gNbId'),
    dict(value='24', dist_name=_NRREL22, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL22, parameter='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL22, parameter='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL22, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL22, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL22, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL22, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL22, parameter='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL22, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL22, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL22, parameter='gnbPlmn'),
]

PARAMETERS_TO_UPDATE_GNB2_K027 = [
    {'dist_name': _NRBTSname2, 'parameter': 'actGrflShdn', 'value': 'true'},
    {'dist_name': _NRCELL22, 'parameter': 'cellBarred', 'value': 'notBarred'},
    {'dist_name': _NRCELL23, 'parameter': 'weightForSCellSelection', 'value': '25'}
]

PARAMETERS_TO_MODIFY_XP_Wrong = [
    {'dist_name': _XPIP, 'parameter': 'ipAddress', 'value': '1.1.1.1'}
]

PARAMETERS_TO_DELETE_GNB1_K027 = [
    {'dist_name': _NRREL11, 'parameter': 'sCellAdditionMethod'},
    {'dist_name': _NRREL11, 'parameter': 'sCellOperationalMode'}
]

PARAMETERS_TO_ADD_GNB1_K021 = [
    {'dist_name': _NRREL11, 'parameter': 'sCellAdditionMethod', 'value': 'blind'},
    {'dist_name': _NRREL11, 'parameter': 'sCellOperationalMode', 'value': 'dlOnly'}
]

PARAMETERS_TO_MODIFY_XP_true = [
    {'dist_name': _XPIP, 'parameter': 'ipAddress', 'value': _XPIP_gnb2},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'notBarred'}
]
