from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'jack.zeng'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jack.zeng@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_gnb_id2 = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NNRBTSname = 'NRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_DRB_4 = _NRBTSname+"/NRDRB-4"
_PDCP_1 = _NRBTSname+"/NRDRB_PDCP-1"
_NEPMRNL = _NRBTSname+"/NRPMRNL-1"
_Cell1_name = _MRBTSname+'/NRBTS-'+_gnb_id+'/NRCELL-1'
_Cell2_name = _MRBTSname+'/NRBTS-'+_gnb_id+'/NRCELL-2'
_NRPLMNSET_NSA_1 = _MRBTSname+'/NRBTS-'+_gnb_id+'/NRCELL-1'+"/NRPLMNSET_NSA-1"
_NRPLMNSET_NSA_2 = _MRBTSname+'/NRBTS-'+_gnb_id+'/NRCELL-2'+"/NRPLMNSET_NSA-1"
_SERVEDAMF_1 = _MRBTSname+'/NRBTS-'+_gnb_id+'/SERVEDAMF-1'
_NRPMRNL_1 = _NRBTSname + '/NRPMRNL-1'
_NRPLMN_1 = _NRBTSname + '/NRPLMN-1'
_NRREL_1 = _Cell1_name+'/NRREL-1'
_NRPLMN_2 = _NRBTSname + '/NRPLMN-2'
_NRREL_2 = _Cell1_name+'/NRREL-2'
_DRB_4_gNB2 = 'MRBTS-'+_gnb_id2+'/NRBTS-'+_gnb_id2+"/NRDRB-4"

PARAMETERS_TO_UPDATE_B01 = [
    dict(new_value='true', dist_name=_DRB_4,
         filter_param='Activate duplicate PDCP PDU transmission over X2-U for NSA 3x DRB',
         abbr='actX2DuplicateTxNSA3x'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data Split buffer buildup threshold',
         abbr='dlDataSplitBufferBuildUpThreshold'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data Split buffer buildup threshold during X2-U prioritization',
         abbr='dlDataSplitBufferBuildUpThresholdPrioritizeX2'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data split gain threshold',
         abbr='dlDataSplitGainThreshold'),
    dict(new_value='500', dist_name=_DRB_4,
         filter_param='Inactivity duration over X2-U for PDCP duplication', abbr='inactPeriodX2PdcpDuplication')
]

PARAMETERS_TO_UPDATE_B01_gNB2 = [
    dict(new_value='true', dist_name=_DRB_4_gNB2,
         filter_param='Activate duplicate PDCP PDU transmission over X2-U for NSA 3x DRB',
         abbr='actX2DuplicateTxNSA3x'),
    dict(new_value='90', dist_name=_DRB_4_gNB2,
         filter_param='DL Data Split buffer buildup threshold',
         abbr='dlDataSplitBufferBuildUpThreshold'),
    dict(new_value='90', dist_name=_DRB_4_gNB2,
         filter_param='DL Data Split buffer buildup threshold during X2-U prioritization',
         abbr='dlDataSplitBufferBuildUpThresholdPrioritizeX2'),
    dict(new_value='90', dist_name=_DRB_4_gNB2,
         filter_param='DL Data split gain threshold',
         abbr='dlDataSplitGainThreshold'),
    dict(new_value='500', dist_name=_DRB_4_gNB2,
         filter_param='Inactivity duration over X2-U for PDCP duplication', abbr='inactPeriodX2PdcpDuplication')
]

PARAMETERS_TO_DELETE_B02 = [
    dict(dist_name=_DRB_4, parameter='inactPeriodX2PdcpDuplication')
]

PARAMETERS_TO_UPDATE_B02 = [
    dict(new_value='false', dist_name=_DRB_4,
         filter_param='Activate duplicate PDCP PDU transmission over X2-U for NSA 3x DRB',
         abbr='actX2DuplicateTxNSA3x'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data Split buffer buildup threshold',
         abbr='dlDataSplitBufferBuildUpThreshold'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data Split buffer buildup threshold during X2-U prioritization',
         abbr='dlDataSplitBufferBuildUpThresholdPrioritizeX2'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data split gain threshold',
         abbr='dlDataSplitGainThreshold')
]

PARAMETERS_TO_UPDATE_AMF = [
    dict(new_value='Unlocked', dist_name=_SERVEDAMF_1,
         filter_param='Administrative state',
         abbr='administrativeState')
]
MOS_ADD_GNB1_B1 = [
    dict(class_name='com.nokia.srbts.nrbts:NRPLMNSET_NSA', dist_name=_NRPLMNSET_NSA_1, version="NRBTSCL22R4_2214_102"),
    dict(class_name='com.nokia.srbts.nrbts:NRREL', dist_name=_NRREL_1, version="NRBTSCL22R4_2214_102"),
    dict(class_name='com.nokia.srbts.nrbts:NRPLMNSET_NSA', dist_name=_NRPLMNSET_NSA_2, version="NRBTSCL22R4_2214_102")
]

MOS_ADD_GNB1_B1_NSA = [
    dict(class_name='com.nokia.srbts.nrbts:NRPLMNSET_NSA', dist_name=_NRPLMNSET_NSA_1, version="NRBTSCL22R4_2214_102"),
    dict(class_name='com.nokia.srbts.nrbts:NRPLMNSET_NSA', dist_name=_NRPLMNSET_NSA_2, version="NRBTSCL22R4_2214_102")
]

LIST_TO_ADD_GNB1_B1 = [
    dict(
        dist_name=_NRPLMNSET_NSA_1,
        list_name='nrPlmnDNList',
        elements=(
            _NRBTSname+'/NRPLMN-1',
            _NRBTSname + '/NRPLMN-2'
            )),
    dict(
        dist_name=_NRPLMNSET_NSA_2,
        list_name='nrPlmnDNList',
        elements=(
            _NRBTSname + '/NRPLMN-1',
            _NRBTSname + '/NRPLMN-2'
        )),
]

LIST_PARAMETERS_TO_MODIFY_GNB1_TL242 = [
    dict(dist_name=_NRREL_1, list_name='gnbPlmn',
         elements=[dict(p_name='mcc', value='1', index=0),
                   dict(p_name='mnc', value='1', index=0)])
]

PARAMETERS_TO_MODIFY_GNB1_B1_TL242 = [
    dict(value='true', dist_name=_NRBTSname, p_name='actMultiDrbNSA'),
    dict(value='SA+NSA', dist_name=_NRBTSname, p_name='gNbCuType'),
    dict(value='1', dist_name=_NRBTSname, p_name='mcc'),
    dict(value='1', dist_name=_NRBTSname, p_name='mnc'),
    dict(value='SA+NSA', dist_name=_Cell1_name, p_name='cellDepType'),
    dict(value='SA+NSA', dist_name=_Cell2_name, p_name='cellDepType'),
    dict(value='Locked', dist_name=_SERVEDAMF_1, p_name='administrativeState'),
    dict(value='20000', dist_name=_NRPLMNSET_NSA_1, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRPLMNSET_NSA_2, p_name='configuredEpsTac'),
    dict(value='1', dist_name=_NRPLMN_1, p_name='mcc'),
    dict(value='1', dist_name=_NRPLMN_1, p_name='mnc'),
    dict(value='460', dist_name=_NRPLMN_2, p_name='mcc'),
    dict(value='2', dist_name=_NRPLMN_2, p_name='mnc'),
    dict(value='TL_SG3_5GC1354_B01', dist_name=_MRBTSname, p_name='btsName'),
    dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
    dict(value='rsrp', dist_name=_Cell1_name, p_name='a2MeashoEnabled'),
    dict(value='true', dist_name=_Cell1_name, p_name='actK1OptForDPA'),
    dict(value='true', dist_name=_Cell2_name, p_name='actK1OptForDPA'),
    dict(value='0dB', dist_name=_NRREL_1, p_name='cellIndividualSsbRsrpOffset'),
    dict(value='0dB', dist_name=_NRREL_1, p_name='cellIndividualSsbRsrqOffset'),
    dict(value='24211', dist_name=_NRREL_1, p_name='gNbId'),
    dict(value='22', dist_name=_NRREL_1, p_name='gNbIdLength'),
    dict(value='allowed', dist_name=_NRREL_1, p_name='handoverAllowedSA'),
    dict(value='2', dist_name=_NRREL_1, p_name='lcrId'),
    dict(value='false', dist_name=_NRREL_1, p_name='nrDcAllowed'),
    dict(value='false', dist_name=_NRREL_1, p_name='removeNotAllowed'),
    dict(value='5min', dist_name=_NRPMRNL_1, p_name='miNrX2UB1Interface')
]

PARAMETERS_TO_MODIFY_GNB1_B1_Common = [
    dict(value='true', dist_name=_NRBTSname, p_name='actMultiDrbNSA'),
    dict(value='SA+NSA', dist_name=_NRBTSname, p_name='gNbCuType'),
    dict(value='SA+NSA', dist_name=_Cell1_name, p_name='cellDepType'),
    dict(value='SA+NSA', dist_name=_Cell2_name, p_name='cellDepType'),
    dict(value='Locked', dist_name=_SERVEDAMF_1, p_name='administrativeState'),
    dict(value='20000', dist_name=_NRPLMNSET_NSA_1, p_name='configuredEpsTac'),
    dict(value='20000', dist_name=_NRPLMNSET_NSA_2, p_name='configuredEpsTac'),
    dict(value='TL_SG3_5GC1354_B01', dist_name=_MRBTSname, p_name='btsName'),
    dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
    dict(value='rsrp', dist_name=_Cell1_name, p_name='a2MeashoEnabled'),
    dict(value='true', dist_name=_Cell1_name, p_name='actK1OptForDPA'),
    dict(value='true', dist_name=_Cell2_name, p_name='actK1OptForDPA'),
    dict(value='5min', dist_name=_NRPMRNL_1, p_name='miNrX2UB1Interface')
]

PARAMETERS_TO_UPDATE_A02 = [
    dict(new_value='true', dist_name=_DRB_4,
         filter_param='Activate duplicate PDCP PDU transmission over X2-U for NSA 3x DRB',
         abbr='actX2DuplicateTxNSA3x'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data Split buffer buildup threshold',
         abbr='dlDataSplitBufferBuildUpThreshold'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data Split buffer buildup threshold during X2-U prioritization',
         abbr='dlDataSplitBufferBuildUpThresholdPrioritizeX2'),
    dict(new_value='90', dist_name=_DRB_4,
         filter_param='DL Data split gain threshold',
         abbr='dlDataSplitGainThreshold'),
    dict(new_value='500', dist_name=_DRB_4,
         filter_param='Inactivity duration over X2-U for PDCP duplication', abbr='inactPeriodX2PdcpDuplication')
]

Modify_Para_counter = [
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1UCInterface'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1UDInterface'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1UB1Interface'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1UInterfaceCUpmqap'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1CC'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1CD'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrF1UU'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrX2UB1Interface'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrX2UInterface'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrX2ccNrpmqap'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrX2CB'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrX2CC'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrX2UInterfacepmqap'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrPDCP1Report'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrPDCP2Report'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrPdcpC'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrPDCPCell'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrPdcpCellNrpmqap'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrHighRlcCell'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrHighRlcCellNrpmqap'),
    dict(value='5min', dist_name=_NEPMRNL, p_name='miNrHighRlcReport'),
    dict(value='Locked', dist_name=_SERVEDAMF_1, p_name='administrativeState'),
    # dict(value='SA+NSA', dist_name=_NRBTSname, p_name='gNbCuType'),
    # dict(value='SA+NSA', dist_name=_Cell1_name, p_name='cellDepType'),
    # dict(value='20000', dist_name=_NRPLMNSET_NSA_1, p_name='configuredEpsTac'),
    # dict(value='notReserved', dist_name=_NRPLMNSET_NSA_1, p_name='cellReservedForOperatorUse'),
    # dict(value='SA+NSA', dist_name=_Cell2_name, p_name='cellDepType'),
    # dict(value='20000', dist_name=_NRPLMNSET_NSA_2, p_name='configuredEpsTac'),
    # dict(value='notReserved', dist_name=_NRPLMNSET_NSA_2, p_name='cellReservedForOperatorUse'),
    # dict(value='true', dist_name=_NRBTSname, p_name='actIntraMeNBMobility'),
    # dict(value='true', dist_name=_NRBTSname, p_name='actIntraFreqIntraGnbMobilityNSA'),
    # dict(value='synchronous', dist_name=_Cell2_name, p_name='enDcSyncStatus'),
    # dict(value='synchronous', dist_name=_Cell1_name, p_name='enDcSyncStatus')

]

MOS_ADD_NSA = [
    dict(class_name='com.nokia.srbts.nrbts:NRPLMNSET_NSA', dist_name=_NRPLMNSET_NSA_1, version="NRBTSCL22R4_2210_100"),
    dict(class_name='com.nokia.srbts.nrbts:NRPLMNSET_NSA', dist_name=_NRPLMNSET_NSA_2, version="NRBTSCL22R4_2210_100")
]

LIST_TO_ADD_PLMN = [
    dict(
        dist_name=_NRPLMNSET_NSA_1,
        list_name='nrPlmnDNList',
        elements=(_NRPLMN_1, _NRPLMN_2)
    ),
    dict(
        dist_name=_NRPLMNSET_NSA_2,
        list_name='nrPlmnDNList',
        elements=(_NRPLMN_1, _NRPLMN_2)
    )
]

Modify_Para_AMF_Unlock = [
    {'dist_name': _SERVEDAMF_1, 'parameter': 'administrativeState', 'value': 'Unlocked'},
    {'dist_name': _NRBTSname, 'parameter': 'gNbCuType', 'value': 'SA'},
    {'dist_name': _Cell1_name, 'parameter': 'cellDepType', 'value': 'SA'},
    {'dist_name': _Cell2_name, 'parameter': 'cellDepType', 'value': 'SA'}
]

LIST_TO_DELETE_PLMN = [
    {'dist_name': _NRPLMNSET_NSA_1},
    {'dist_name': _NRPLMNSET_NSA_2}
]

Modify_Para_Online_A001_trunk = [
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    {'dist_name': _DRB_4, 'parameter': 'reTxPrioritizationType', 'value': 'retxPrioSameLink'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverX2U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

Modify_Para_Online_A001 = [
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverX2U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_A001_002 = [
    dict(value=[dict(reTxPrioritizationType='retxPrioSameLink')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

counter_id_A001 = [
    'M55313C04007', 'M55355C02007', 'M55355C03007', 'M55354C02007', 'M55354C03007', 'M55313C08007'
]

counter_dic_path_A001 = [
    'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1',
    'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/NX2UB'
]

counter_dic_path_A001_341 = [
    'BTS/BTS/NRBTS-34111/NX2UB', 'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/X2UB1',
    'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/NX2UB'
]


Modify_Para_Online_A002 = [
    # {'dist_name': _NRBTSname, 'parameter': 'actIntraMeNBMobility', 'value': 'true'},
    # {'dist_name': _NRBTSname, 'parameter': 'actIntraFreqIntraGnbMobilityNSA', 'value': 'true'},
    # {'dist_name': _Cell1_name, 'parameter': 'enDcSyncStatus', 'value': 'synchronous'},
    # {'dist_name': _Cell2_name, 'parameter': 'enDcSyncStatus', 'value': 'synchronous'},
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    dict(value=[dict(actX2DuplicateTxNSA3x='false', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

Modify_Para_Online_A002_002 = [
    dict(value=[dict(reTxPrioritizationType='retxPrioSameLink')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

counter_id_A002 = [
     'M55354C00007', 'M55354C01007', 'M55355C00007', 'M55355C01007'
]

counter_dic_path_A002 = [
    'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1'
]

counter_dic_path_A002_341 = [
    'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/F1UB1',
    'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/X2UB1'
]

Modify_Para_Online_A003 = [
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverF1U', actX2DuplicateTxNSA3x='true',
                     dlDataSplitBufferBuildUpThreshold='90', dlDataSplitBufferBuildUpThresholdPrioritizeX2='90',
                     dlDataSplitGainThreshold='90', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_A003_002 = [
    dict(value=[dict(inactPeriodX2PdcpDuplication='0', reTxPrioritizationType='retxBasedOnFC')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

Modify_Para_Online_A003_trunk = [
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    {'dist_name': _DRB_4, 'parameter': 'reTxPrioritizationType', 'value': 'retxBasedOnFC'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverF1U', actX2DuplicateTxNSA3x='true',
                     dlDataSplitBufferBuildUpThreshold='90', dlDataSplitBufferBuildUpThresholdPrioritizeX2='90',
                     dlDataSplitGainThreshold='90', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_A003_002_trunk = [
    dict(value=[dict(inactPeriodX2PdcpDuplication='0')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

counter_id_A003 = [
      'M55355C04007', 'M55355C05007', 'M55354C02007', 'M55355C02007', 'M55313C08007', 'M55313C04007', 'M55314C02007',
      'M55313C13007', 'M55323C04007', 'M55311C46007', 'M55313C09007', 'M55311C47007'
]

counter_dic_path_A003 = [
    'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/F1UB1',
    'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/NX2UB', 'BTS/'+_NRBTSname+'/NX2UB',
    'BTS/'+_NRBTSname+'/NRDU-1/NF1UD', 'BTS/'+_NRBTSname+'/NX2UB', 'BTS/'+_NRBTSname+'/NF1UB',
    'BTS/'+_NRBTSname+'/NRDU-1/NHRLC', 'BTS/'+_NRBTSname+'/NX2UB', 'BTS/'+_NRBTSname+'/NRDU-1/NHRLC'
]

counter_dic_path_A003_branch = [
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NX2UB',
    'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NF1UD', 'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NF1UB',
    'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NHRLC', 'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NHRLC'
]

counter_dic_path_A003_341 = [
    'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/X2UB1',
    'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/NX2UB', 'BTS/BTS/NRBTS-34111/NX2UB'
]

Modify_Para_Online_A004 = [
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    dict(value=[dict(actX2DuplicateTxNSA3x='false', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

Modify_Para_Online_A004_002 = [
    dict(value=[dict(reTxPrioritizationType='retxBasedOnFC')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

Modify_Para_reTxPrioritizationType_delete = [
    {'dist_name': _DRB_4, 'parameter': 'reTxPrioritizationType'}
]

counter_id_A004 = [
    'M55323C04007', 'M55314C02007', 'M55313C04007', 'M55313C08007', 'M55313C13007', 'M55355C04007', 'M55355C05007',
    'M55354C02007', 'M55355C02007'
]

counter_dic_path_A004 = [
    'BTS/BTS/'+_NNRBTSname+'/NF1UB', 'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NF1UD', 'BTS/BTS/'+_NNRBTSname+'/NX2UB',
    'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/X2UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1'
]

counter_dic_path_A004_341 = [
    'BTS/BTS/'+_NNRBTSname+'/NF1UB', 'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NF1UD', 'BTS/BTS/'+_NNRBTSname+'/NX2UB',
    'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/X2UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1'
]

Modify_Para_Online_A005 = [
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UCInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UDInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterface', 'value': '5min'},
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverX2U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='90', dlDataSplitGainThreshold='90',
                     dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]


Modify_Para_actX2DuplicateTxNSA3x_true = [
    dict(value=[dict(actX2DuplicateTxNSA3x='true')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_A005_X2PdcpDuplication = [
    dict(value=[dict(inactPeriodX2PdcpDuplication='3000')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

counter_id_A005 = [
    'M55313C00007', 'M55313C04007', 'M55355C04007', 'M55355C05007', 'M55313C08007'
]

counter_dic_path_A005 = [
    'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NX2UB',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/NX2UB'
]

counter_dic_path_A005_341 = [
    'BTS/BTS/'+_MRBTSname+'/NX2UB', 'BTS/BTS/'+_MRBTSname+'/NX2UB',
    'BTS/BTS/'+_MRBTSname+'/X2UB1', 'BTS/BTS/'+_MRBTSname+'/X2UB1', 'BTS/BTS/'+_MRBTSname+'/NX2UB'
]

PARAMS_TO_actLostPduFastRetx_false = [
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'false'}
]

PARAMS_TO_delete_nsaDrbParam = [
    dict(dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_add_nsaDrbParam = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2'}]}
]

PARAMS_TO_add_nsaDrbParam = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2'}]}
]

PARAMS_TO_add_nsaDrbParam_trunk = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2',
                'dlPreferredPath': 'F1-U'}]}
]

PARAMS_TO_add_nsaDrbParam2 = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2'}]}
]

PARAMS_TO_add_nsaDrbParam3 = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2'}]}
]

PARAMS_TO_add_nsaDrbParam4 = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2'}]}
]

Modify_Para_Online_C001 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThreshRetxMode', 'value': 'delayThresh1and2Enabled'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardEnabled', 'value': 'true'},
    {'dist_name': _PDCP_1, 'parameter': 'tReorderingDl', 'value': 'ms100'},
    {'dist_name': _Cell1_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _Cell2_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'false'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverF1U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='90', dlDataSplitGainThreshold='90',
                     dlDataSplitBufferBuildUpThresholdPrioritizeX2='90', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_C001_002 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThresh1TrigType', 'value': "transmittedPdcpSnTrig"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpMaxNumRetxPdu', 'value': "500"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh1', 'value': "ms60"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh2', 'value': "ms40"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpRetxPduSendMaxDelay', 'value': "ms60"},
]

counter_id_C003 = [
     'M55320C21001', 'M55320C21002', 'M55320C21003', 'M55320C21004', 'M55320C21005', 'M55320C21006', 'M55320C21007',
     'M55320C21008', 'M55320C21009', 'M55320C22001', 'M55320C22002', 'M55320C22003', 'M55320C22004', 'M55320C22005',
     'M55320C22006', 'M55320C22007', 'M55320C22008', 'M55320C22009', 'M55320C23007', 'M55354C04007', 'M55354C05007',
     'M55354C06007', 'M55354C07007', 'M55355C06007', 'M55355C07007', 'M55355C08007', 'M55355C09007', 'M55311C46007',
     'M55311C47007', 'M55313C08007', 'M55314C02007'
]

counter_dic_path_C003 = [
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2',
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2',
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2',
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2',
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2',
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/PDCP2',
    'BTS/BTS/'+_NNRBTSname+'/PDCP2', 'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1',
    'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1',
    'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NHRLC', 'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NHRLC', 'BTS/BTS/'+_NNRBTSname+'/NX2UB',
    'BTS/BTS/'+_NNRBTSname+'/NRDU-1/NF1UD'
]

counter_dic_path_C003_trunk = [
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2',
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2',
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2',
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2',
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2',
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/PDCP2',
    'BTS/'+_NRBTSname+'/PDCP2', 'BTS/'+_NRBTSname+'/F1UB1', 'BTS/'+_NRBTSname+'/F1UB1',
    'BTS/'+_NRBTSname+'/F1UB1', 'BTS/'+_NRBTSname+'/F1UB1', 'BTS/'+_NRBTSname+'/X2UB1',
    'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/X2UB1',
    'BTS/'+_NRBTSname+'/NRDU-1/NHRLC', 'BTS/'+_NRBTSname+'/NRDU-1/NHRLC', 'BTS/'+_NRBTSname+'/NX2UB',
    'BTS/'+_NRBTSname+'/NRDU-1/NF1UD'
]

counter_dic_path_C003_341 = [
    'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2',
    'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2',
    'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2',
    'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2',
    'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/PDCP2', 'BTS/BTS/NRBTS-34111/F1UB1',
    'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/X2UB1',
    'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/X2UB1',
    'BTS/BTS/NRBTS-34111/NRDU-1/NHRLC', 'BTS/BTS/NRBTS-34111/NRDU-1/NHRLC', 'BTS/BTS/NRBTS-34111/NX2UB',
    'BTS/BTS/NRBTS-34111/NRDU-1/NF1UD'
]

Modify_Para_Online_C002_trunk = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThreshRetxMode', 'value': 'delayThresh1Enabled'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardEnabled', 'value': 'false'},
    {'dist_name': _PDCP_1, 'parameter': 'tReorderingDl', 'value': 'ms100'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardThreshold', 'value': '200'},
    {'dist_name': _Cell1_name, 'parameter': 'actCDrx', 'value': 'true'},
    {'dist_name': _Cell2_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    {'dist_name': _DRB_4, 'parameter': 'reTxPrioritizationType', 'value': 'retxPrioSameLink'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverX2U', actX2DuplicateTxNSA3x='true',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitGainThreshold='5',
                     dlDataSplitBufferBuildUpThresholdPrioritizeX2='5', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_C002_002_trunk = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThresh1TrigType', 'value': "pdcpPduSendTrig"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpMaxNumRetxPdu', 'value': "100"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh1', 'value': "ms20"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpRetxPduSendMaxDelay', 'value': "ms30"},
    dict(value=[dict(inactPeriodX2PdcpDuplication='300')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

Modify_Para_Online_C002 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThreshRetxMode', 'value': 'delayThresh1Enabled'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardEnabled', 'value': 'false'},
    {'dist_name': _PDCP_1, 'parameter': 'tReorderingDl', 'value': 'ms100'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardThreshold', 'value': '200'},
    {'dist_name': _Cell1_name, 'parameter': 'actCDrx', 'value': 'true'},
    {'dist_name': _Cell2_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverX2U', actX2DuplicateTxNSA3x='true',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitGainThreshold='5',
                     dlDataSplitBufferBuildUpThresholdPrioritizeX2='5', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_C002_002 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThresh1TrigType', 'value': "pdcpPduSendTrig"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpMaxNumRetxPdu', 'value': "50"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh1', 'value': "ms20"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpRetxPduSendMaxDelay', 'value': "ms20"},
    dict(value=[dict(inactPeriodX2PdcpDuplication='300', reTxPrioritizationType='retxPrioSameLink')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_delete_pdcpPduRetxDelayThresh2 = [
    dict(dist_name=_PDCP_1, parameter='pdcpPduRetxDelayThresh2')
]

counter_id_A_AND_B = [
    'M55313C04007', 'M55323C04007', 'M55355C02007', 'M55355C03007', 'M55354C02007', 'M55354C03007',
    'M55355C04007', 'M55355C05007'
]

counter_dic_path_A_AND_B = [
    'BTS/BTS/'+_NNRBTSname+'/NX2UB', 'BTS/BTS/'+_NNRBTSname+'/NF1UB', 'BTS/BTS/'+_NNRBTSname+'/X2UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1', 'BTS/BTS/'+_NNRBTSname+'/F1UB1',
    'BTS/BTS/'+_NNRBTSname+'/X2UB1', 'BTS/BTS/'+_NNRBTSname+'/X2UB1'
]

counter_dic_path_A_AND_B_trunk = [
    'BTS/'+_NRBTSname+'/NX2UB', 'BTS/'+_NRBTSname+'/NF1UB', 'BTS/'+_NRBTSname+'/X2UB1',
    'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/F1UB1', 'BTS/'+_NRBTSname+'/F1UB1',
    'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/X2UB1'
]

counter_dic_path_A_AND_B_341 = [
    'BTS/BTS/NRBTS-34111/NX2UB', 'BTS/BTS/NRBTS-34111/NF1UB', 'BTS/BTS/NRBTS-34111/X2UB1',
    'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/F1UB1', 'BTS/BTS/NRBTS-34111/F1UB1',
    'BTS/BTS/NRBTS-34111/X2UB1', 'BTS/BTS/NRBTS-34111/X2UB1'
]

Modify_Para_Online_C003 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThreshRetxMode', 'value': 'delayThresh1and2Enabled'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardEnabled', 'value': 'true'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardThreshold', 'value': '20000'},
    {'dist_name': _PDCP_1, 'parameter': 'tReorderingDl', 'value': 'ms100'},
    {'dist_name': _Cell1_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _Cell2_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'true'},
    # {'dist_name': _DRB_4, 'parameter': 'actDddsReduction', 'value': 'false'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverX2U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='5', dlDataSplitGainThreshold='5',
                     dlDataSplitBufferBuildUpThresholdPrioritizeX2='5', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_C003_002 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThresh1TrigType', 'value': "transmittedPdcpSnTrig"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpMaxNumRetxPdu', 'value': "500"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh1', 'value': "ms30"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh2', 'value': "ms30"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpRetxPduSendMaxDelay', 'value': "ms60"},
    dict(value=[dict(reTxPrioritizationType='retxPrioSameLink')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]
