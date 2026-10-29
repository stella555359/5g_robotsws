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

MOS_ADD_GNB1 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL11, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB3_AF = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL32, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB3 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL31, version="NRBTSCL22R4_2210_100")
]

MOS_ADD_GNB4 = [
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL41, version="NRBTSCL22R4_2210_100")
]

PARAMETERS_TO_MODIFY_GNB3_AB003 = [
    dict(value='0dB', dist_name=_NRREL31, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL31, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL31, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL31, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL31, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL31, p_name='handoverAllowedSARedCap'),
    dict(value='2', dist_name=_NRREL31, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL31, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL31, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL31, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL31, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL31, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL31, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL31, p_name='isRplCellForPSCell'),
    dict(value='1.1.1.1', dist_name=_XPIP3, p_name='ipAddress'),
    dict(value='Locked', dist_name=_NRBTSname3 + '/NRADJGNB-11', p_name='administrativeState'),
    # dict(value='Locked', dist_name=_NRBTSname3 + '/NRADJGNB-12', p_name='administrativeState')
]

PARAMETERS_TO_MODIFY_GNB4_AB003 = [
    dict(value='0dB', dist_name=_NRREL41, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL41, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL41, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL41, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL41, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL41, p_name='handoverAllowedSARedCap'),
    dict(value='1', dist_name=_NRREL41, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL41, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL41, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL41, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL41, p_name='sCellAdditionMethod'),
    dict(value='false', dist_name=_NRREL41, p_name='isRplCellForPSCell'),
    dict(value='dlOnly', dist_name=_NRREL41, p_name='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL41, p_name='isRplCellForPSCell'),
    dict(value='Locked', dist_name=_NRBTSname4 + '/NRADJGNB-11', p_name='administrativeState'),
    # dict(value='Locked', dist_name=_NRBTSname4 + '/NRADJGNB-12', p_name='administrativeState')
]

Modify_Para_Online_GNB3_XP_IP = [
    {'dist_name': _MRBTSname3 + '/MNL-1/MNLENT-1/XPAP-1/XPIF-1/XPIFREMOTE-3',
     'parameter': 'ipAddress', 'value': _XPIP_gnb4}
]

PARAMETERS_TO_recover_GNB3_AB003 = [
    {'dist_name': _NRBTSname3 + '/NRADJGNB-11', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_recover_GNB4_AB003 = [
    {'dist_name': _NRBTSname4 + '/NRADJGNB-11', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_MODIFY_GNB1_AF006 = [
    dict(value='0dB', dist_name=_NRREL11, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL11, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL11, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL11, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL11, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL11, p_name='isRplCellForPSCell'),
    dict(value='2', dist_name=_NRREL11, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL11, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL11, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL11, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL11, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL11, p_name='sCellOperationalMode'),
    dict(value='10', dist_name=_NRBTSname, p_name='iGnbCaXnSetupReqTmr'),
    dict(value='notBarred', dist_name=_NRCELL11, p_name='cellBarred'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname + '/NRPMRNL-1', p_name='miNrCaCu'),
    dict(value='Locked', dist_name=_NRBTSname + '/NRADJGNB-14', p_name='administrativeState')
]

PARAMETERS_TO_MODIFY_GNB3_AF006 = [
    dict(value='0dB', dist_name=_NRREL32, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL32, p_name='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb_id, dist_name=_NRREL32, p_name='gNbId'),
    dict(value='24', dist_name=_NRREL32, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL32, p_name='handoverAllowedSA'),
    dict(value='forbidden', dist_name=_NRREL32, p_name='handoverAllowedSARedCap'),
    dict(value='false', dist_name=_NRREL32, p_name='isRplCellForPSCell'),
    dict(value='1', dist_name=_NRREL32, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL32, p_name='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL32, p_name='nrRelId'),
    dict(value='false', dist_name=_NRREL32, p_name='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL32, p_name='sCellAdditionMethod'),
    dict(value='dlOnly', dist_name=_NRREL32, p_name='sCellOperationalMode'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrSaAdjGnb'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrRSADU'),
    dict(value='5min', dist_name=_NRBTSname3 + '/NRPMRNL-1', p_name='miNrRSACU'),
    dict(value='notBarred', dist_name=_NRCELL32, p_name='cellBarred'),
]

PARAMETERS_TO_BE_DELETE_GNB3_AF006 = [
    dict(dist_name=_NRBTSname3+'/NRDU-1', parameter='xgUplane')
]

LIST_TO_ADD_GNB3_AF006 = [
    dict(value=[dict(ipV6AddressDN1=_MRBTSname3+'/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname3+'/NRDU-1',
         parameter='xgUplane')
]

LIST_TO_ADD_GNB1 = [
    dict(
        dist_name=_NRREL11,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_ADD_GNB3_AA002 = [
    dict(
        dist_name=_NRREL32,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_ADD_GNB3 = [
    dict(
        dist_name=_NRREL31,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]

LIST_TO_ADD_GNB4 = [
    dict(
        dist_name=_NRREL41,
        list_name='gnbPlmn',
        elements=dict(
            mcc='310',
            mnc='260',
            mncLength='3'))
]
# restore####
PARAMETERS_TO_GNB1_AF006_restore = [
    {'dist_name': _NRBTSname + '/NRADJGNB-14', 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

PARAMETERS_TO_GNB3_AF006_restore = [
    dict(value=[{'ipV4AddressDN1': _MRBTSname3+'/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'}],
         dist_name=_NRBTSname3+'/NRDU-1', parameter='xgUplane')
]

# delete NRREL####
PARAMETERS_TO_DELETE_GNB1 = [
    {'dist_name': _NRREL11}
]

PARAMETERS_TO_DELETE_GNB3 = [
    {'dist_name': _NRREL32}
]

PARAMETERS_TO_DELETE_GNB2_CELL1 = [
    {'dist_name': _NRREL11}
]

PARAMETERS_TO_DELETE_GNB3_CELL31 = [
    {'dist_name': _NRREL331}
]

PARAMETERS_TO_DELETE_GNB3_CELL1 = [
    {'dist_name': _NRREL31}
]

PARAMETERS_TO_DELETE_GNB4_CELL31 = [
    {'dist_name': _NRREL431}
]
# cases 8140_A_001####
counter_id_AF006_gNB1 = [
    'M55118C11001', 'M55118C11007', 'M55139C01003'
]

counter_dic_path_AF006_gNB1 = [
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/NCAC',
    'BTS/CELLS/NRCELL-1/RSADU'
]

counter_id_AF006_gNB3 = [
    'M55175C00002',
    'M55139C01001',
    'M55175C00001',
    'M55138C03501',
    'M55138C03502'
]
counter_dic_path_AF006_gNB3 = [
    'BTS/BTS/'+_NRBTSnames+'/MCC-310_MNC-260/ADJNB',
    'BTS/CELLS/NRCELL-2/RSADU',
    'BTS/BTS/'+_NRBTSnames+'/MCC-310_MNC-260/ADJNB',
    'BTS/CELLS/NRCELL-2/RSACU',
    'BTS/CELLS/NRCELL-2/RSACU'
]

# cases 8140_AE####
PARAMETERS_TO_MODIFY_GNB3_2200 = [
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELL33, p_name='dlMimoMode')
]

Parameter_Delete_GNB3_2200 = [
    dict(dist_name=_NRCELL33, list_name='periodicCsiAcquisition')
]

LIST_TO_ADD_GNB3_2200 = [
    dict(
        dist_name=_NRCELL33,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

PARAMETERS_TO_MODIFY_GNB4_2200 = [
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELL431, p_name='dlMimoMode'),
    dict(value='4x4 or 4x2 Closed Loop Spatial Multiplexing', dist_name=_NRCELL43, p_name='dlMimoMode')
]

Parameter_Delete_GNB4_2200 = [
    dict(dist_name=_NRCELL431, list_name='periodicCsiAcquisition'),
    dict(dist_name=_NRCELL43, list_name='periodicCsiAcquisition')
]

LIST_TO_ADD_GNB4_2200 = [
    dict(
        dist_name=_NRCELL431,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3')),
    dict(
        dist_name=_NRCELL43,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csiReportPeriodicity='slots320',
            scramblingIdStep='3'))
]

parameters_to_update_AE_003 = [
    dict(value='0dB', dist_name=_NRREL431, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL431, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb3_id, dist_name=_NRREL431, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL431, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL431, parameter='handoverAllowedSA'),
    dict(value='3', dist_name=_NRREL431, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL431, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL431, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL431, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL431, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL431, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL431, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL431, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL431, parameter='gnbPlmn')
]

parameters_to_update_AE_003_pre_GNB3 = [
    {'dist_name': _NRBTSname3, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL33, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL331, 'parameter': 'administrativeState', 'value': 'Locked'}
]

parameters_to_update_AE_003_pre_GNB4 = [
    {'dist_name': _NRBTSname4, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL431, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL431, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

parameters_to_update_AE_003_recover_GNB3 = [
    {'dist_name': _NRCELL331, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

parameters_to_update_AE_003_recover_GNB4 = [
    {'dist_name': _NRCELL43, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL431, 'parameter': 'cellBarred', 'value': 'barred'}
]

parameters_to_update_AE_005 = [
    dict(value='0dB', dist_name=_NRREL31, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL31, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL31, parameter='gNbId'),
    dict(value='22', dist_name=_NRREL31, parameter='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL31, parameter='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL31, parameter='lcrId'),
    dict(value='false', dist_name=_NRREL31, parameter='nrDcAllowed'),
    dict(value='1', dist_name=_NRREL31, parameter='nrRelId'),
    dict(value='false', dist_name=_NRREL31, parameter='removeNotAllowed'),
    dict(value='blind', dist_name=_NRREL31, parameter='sCellAdditionMethod'),
    dict(value='forbidden', dist_name=_NRREL31, parameter='handoverAllowedSARedCap'),
    dict(value='dlOnly', dist_name=_NRREL31, parameter='sCellOperationalMode'),
    dict(value='false', dist_name=_NRREL31, parameter='isRplCellForPSCell'),
    dict(value=[dict(mcc='310', mnc='260', mncLength='3')],
         dist_name=_NRREL31, parameter='gnbPlmn')
]

parameters_to_update_AE_005_pre_GNB3 = [
    {'dist_name': _NRBTSname3, 'parameter': 'sCellActivationMethod', 'value': 'bufferAndRLQualityBased'},
    {'dist_name': _NRCELL31, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRBTSnames3 + '/NRPMRNL-1', 'parameter': 'miNrCaDu', 'value': '5min'},
    {'dist_name': _NRBTSnames3 + '/NRPMRNL-1', 'parameter': 'miNrLowRlcReport', 'value': '5min'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRCELL31, 'parameter': 'cellBarred', 'value': 'notBarred'}
]

parameters_to_update_AE_005_pre_GNB4 = [
    {'dist_name': _NRBTSname4, 'parameter': 'sCellActivationMethod', 'value': 'bufferAndRLQualityBased'},
    {'dist_name': _NRCELL42, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL421, 'parameter': 'administrativeState', 'value': 'Locked'},
    {'dist_name': _NRBTSnames4 + '/NRPMRNL-1', 'parameter': 'miNrLowRlcReport', 'value': '5min'},
    {'dist_name': _NRBTSnames4 + '/NRPMRNL-1', 'parameter': 'miNrCaDu', 'value': '5min'}
]

parameters_to_update_AE_005_recover_GNB3 = [
    {'dist_name': _NRBTSname3, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL311, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL31, 'parameter': 'cellBarred', 'value': 'barred'}
]

parameters_to_update_AE_005_recover_GNB4 = [
    {'dist_name': _NRBTSname4, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL421, 'parameter': 'administrativeState', 'value': 'Unlocked'}
]

LIST_TO_ADD_GNB3_GG001 = [
    dict(value=[dict(ipV4AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
                     ipV6AddressDN1=_MRBTSname3 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname3 + '/SNSSAI-1', parameter='xgUplane')
]

PARAMETERS_TO_DELETE_GNB4_GG001 = [
    dict(dist_name=_NRBTSname4+'/NRDU-1', parameter='xgUplane')
]

LIST_TO_ADD_GNB4_GG001 = [
    {'dist_name': _NRBTSname4 + '/NRDU-1', 'parameter': 'xgUplane',
     'value': [{'ipV6AddressDN1': _MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1'}]},
    dict(value=[dict(ipV4AddressDN1=_MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1',
                     ipV6AddressDN1=_MRBTSname4 + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1')],
         dist_name=_NRBTSname4 + '/SNSSAI-1', parameter='xgUplane')
]

counter_id_AE005_gNB2 = [
    'M55316C03001', 'M55310C01022', 'M55310C20001'
]

counter_id_AE005_gNB2_M55316C05001 = [
    'M55316C05001'
]

counter_dic_path_AE005_gNB2 = [
    'BTS/CELLS/NRCELL-1/NCADU', 'BTS/CELLS/NRCELL-1/NLRLC', 'BTS/CELLS/NRCELL-1/NLRLC'
]

counter_dic_path_AE005_gNB2_trunk = [
    'BTS/' + _NRBTSname3 + '/NRCELL-1/NCADU', 'BTS/' + _NRBTSname3 + '/NRCELL-1/NLRLC',
    'BTS/' + _NRBTSname3 + '/NRCELL-1/NLRLC'
]

counter_dic_path_AE005_gNB2_M55316C05001 = [
    'BTS/CELLS/NRCELL-1/NCADU'
]

counter_dic_path_AE005_gNB2_M55316C05001_trunk = [
    'BTS/' + _NRBTSname3 + '/NRCELL-1/NCADU'
]

counter_id_AE005_gNB3_M55316C09001 = [
    'M55316C09001'
]

counter_dic_path_AE005_gNB3_M55316C09001 = [
    'BTS/CELLS/NRCELL-2/NCADU'
]

counter_dic_path_AE005_gNB3_M55316C09001_trunk = [
    'BTS/' + _NRBTSname4 + '/NRCELL-2/NCADU'
]

counter_id_AE005_gNB3 = [
    'M55310C01021', 'M55310C20000'
]


counter_dic_path_AE005_gNB3 = [
    'BTS/CELLS/NRCELL-2/NLRLC', 'BTS/CELLS/NRCELL-2/NLRLC'
]

counter_dic_path_AE005_gNB3_trunk = [
    'BTS/' + _NRBTSname4 + '/NRCELL-2/NLRLC', 'BTS/' + _NRBTSname4 + '/NRCELL-2/NLRLC'
]


parameters_to_update_AE_007 = [
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL11, parameter='cellIndividualSsbRsrqOffset'),
    dict(value=_gnb4_id, dist_name=_NRREL11, parameter='gNbId'),
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


parameters_to_update_AE_007_pre_GNB4 = [
    {'dist_name': _NRBTSname4, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRBTSname4, 'parameter': 'actBufferBasedSCellAddition', 'value': 'oneShot_Dl_Fr1'},
    {'dist_name': _NRBTSname4, 'parameter': 'actSCellReleaseForInactiveSCell', 'value': 'timer_based_Fr1'},
    {'dist_name': _NRCELL431, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'}
]

parameters_to_update_actOptimizedFlowControl_GNB4 = [
    {'dist_name': _NRCELL431, 'parameter': 'actOptimizedFlowControl', 'value': 'optimizedAllUe'}
]

parameters_to_update_AE_007_recover_GNB1 = [
    {'dist_name': _NRBTSname, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL11, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'},
    {'dist_name': _NRCELL111, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRCELL11, 'parameter': 'cellBarred', 'value': 'barred'}
]

parameters_to_update_AE_007_recover_GNB4 = [
    {'dist_name': _NRBTSname4, 'parameter': 'sCellActivationMethod', 'value': 'bufferBased'},
    {'dist_name': _NRCELL431, 'parameter': 'sCellDeactivationTimerGNB', 'value': 'ms1280'}
]

PARAMETERS_TO_UPDATE_AB_B2_pre = [
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'},
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
    {'dist_name': '_NRBTSname/NRDU-1', 'parameter': 'flexibleCAMode', 'value': 'ConfigurationIndependent'}
]
