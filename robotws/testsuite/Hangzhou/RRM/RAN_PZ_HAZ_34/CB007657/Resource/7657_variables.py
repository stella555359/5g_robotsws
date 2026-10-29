from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'xiaodan.li'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'xiaodan.li@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRREDRTname = _NRCELLname+'/NRREDRT-0'
_AMF1GNB1 = _NRBTSname+'/SERVEDAMF-1'
_DRB_4 = _NRBTSname+"/NRDRB-4"
_PDCP_1 = _NRBTSname+"/NRDRB_PDCP-1"
_NEPMRNL = _NRBTSname+"/NRPMRNL-1"
_Cell1_name = _MRBTSname+'/NRBTS-'+_gnb_id+'/NRCELL-1'

# _gnb2_id = str(tl.gnbs[1].instance_id)
# _MRBTSname2 = 'MRBTS-'+_gnb2_id
# _NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
# _AMF1GNB2 = _NRBTSname2+'/SERVEDAMF-1'
# _AMF2GNB2 = _NRBTSname2+'/SERVEDAMF-2'
# _AMF3GNB2 = _NRBTSname2+'/SERVEDAMF-3'
# _NRBTS2_ID = 'NRBTS-'+_gnb2_id

PATH_TO_SCF = ''

# Lock_gnb2_AMF1 = [
#     dict(value='Locked', dist_name=_AMF1GNB2, parameter='administrativeState'),
# ]

Lock_gnb1_AMF1 = [
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLowPAPRoptimizedPrecoding'),
]

Unlock_gnb1_AMF1 = [
    dict(value='Unlocked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='true', dist_name=_NRCELLname, parameter='actDlLowPAPRoptimizedPrecoding'),
]

PARAMS_TO_MODIFY_UNLOCKG1 = [
    dict(
        value='Unlocked',
        dist_name=_NRCELLname,
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_LOCKG2 = [
    dict(
        value='Locked',
        dist_name='_NRBTSname/NRCELL-2',
        parameter='administrativeState')
]

PARAMS_TO_MODIFY_UNLOCKG2 = [
    dict(
        value='Unlocked',
        dist_name='_NRBTSname/NRCELL-2',
        parameter='administrativeState')
]

PARAMS_TO_RU_LOCKED1 = [
    dict(
        value='Locked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-1',
        parameter='administrativeState')
]

PARAMS_TO_RU_UNLOCKED1 = [
    dict(
        value='Unlocked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-1',
        parameter='administrativeState')
]

PARAMS_TO_RU_LOCKED2 = [
    dict(
        value='Locked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-2',
        parameter='administrativeState')
]

PARAMS_TO_RU_UNLOCKED2 = [
    dict(
        value='Unlocked',
        dist_name='_MRBTSname/EQM-1/APEQM-1/RMOD-2',
        parameter='administrativeState')
]

PARAMS_TO_actDlLowPAPRoptimizedPrecoding_True = [
    dict(
        value='true',
        dist_name=_NRCELLname,
        parameter='actDlLowPAPRoptimizedPrecoding')
]

PARAMS_TO_actDlLowPAPRoptimizedPrecoding_False = [
    dict(
        value='false',
        dist_name=_NRCELLname,
        parameter='actDlLowPAPRoptimizedPrecoding')
]

PARAMS_TO_dlMimoMode_open = [
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=_NRCELLname,
        parameter='dlMimoMode')
]

PARAMS_TO_dlMimoMode_close = [
    dict(
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing',
        dist_name=_NRCELLname,
        parameter='dlMimoMode')
]

PARAM_7326_pmax_43 = [
    dict(value='430', dist_name=_NRCELLname,
         filter_param='Maximum output power', parameter='pMax')
]

PARAMS_TO_dlQam256PowerBackoffSub6 = [
    dict(
        value='15',
        dist_name=_NRCELLname,
        parameter='dlQam256PowerBackoffSub6')
]

PARAM_7326_pmax_37 = [
    dict(value='370', dist_name=_NRCELLname,
         filter_param='Maximum output power', parameter='pMax')
]

AMOUNT_OF_CELLS = 1

Modify_Para_Online_A005 = [
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UCInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UDInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterfacepmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UInterfaceCUpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1CC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1CD', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UU', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2ccNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2CC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2CB', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCP1Report', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCP2Report', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPdcpC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCPCell', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPdcpCellNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcCell', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcCellNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcReport', 'value': '5min'},
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
    'BTS/'+_NRBTSname+'/NX2UB', 'BTS/'+_NRBTSname+'/NX2UB',
    'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/X2UB1', 'BTS/'+_NRBTSname+'/NX2UB'
]

# counter_dic_path_A005 = [
#     'BTS/BTS/NRBTS-356111/NX2UB', 'BTS/BTS/NRBTS-356111/NX2UB',
#     'BTS/BTS/NRBTS-356111/X2UB1', 'BTS/BTS/NRBTS-356111/X2UB1', 'BTS/BTS/NRBTS-356111/NX2UB'
# ]

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
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2',
                'dlPreferredPath': 'F1-U'}]}
]

PARAMS_TO_add_nsaDrbParam1 = [
    {'dist_name': _DRB_4, 'parameter': 'nsaDrbParam',
     'value': [{'actPrioritizeX2AfterInactivity': 'false', 'actX2DuplicateTxNSA3x': 'false',
                'dlDataSplitBufferBuildUpThreshold': '90', 'dlDataSplitBufferBuildUpThresholdPrioritizeX2': '90',
                'dlDataSplitGainThreshold': '90', 'initialDLTrafficRouting': 'initDLoverF1U',
                'inactivityThresholdForPrioritizeX2': '300', 'inactivityThresholdForRestartPrioritizeX2': '100',
                'nsa3xBearerAllowed': 'true', 'prioritizeX2Period': '500', 'ulDataPath': 'ulOverNr',
                'ulDataSplitThreshold': 'infinity', 'dlDataSplitMode': 'dlOverF1UX2U', 'dlNumOfCongOrGainDdds': '2',
                'dlPreferredPath': 'F1-U'}]}
]

Modify_Para_Online_C001 = [
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UCInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UDInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterfacepmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UInterfaceCUpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1CC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1CD', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UU', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2ccNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2CC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2CB', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCP1Report', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCP2Report', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPdcpC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCPCell', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPdcpCellNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcCell', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcCellNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcReport', 'value': '5min'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThreshRetxMode', 'value': 'delayThresh1and2Enabled'},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpBufDiscardEnabled', 'value': 'true'},
    {'dist_name': _PDCP_1, 'parameter': 'tReorderingDl', 'value': 'ms100'},
    {'dist_name': _Cell1_name, 'parameter': 'actCDrx', 'value': 'false'},
    {'dist_name': _DRB_4, 'parameter': 'actLostPduFastRetx', 'value': 'false'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverF1U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='90', dlDataSplitGainThreshold='90',
                     dlDataSplitBufferBuildUpThresholdPrioritizeX2='90', dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_C001_002 = [
    {'dist_name': _PDCP_1, 'parameter': 'pdcpDelayThresh1TrigType', 'value': "transmittedPdcpSnTrig"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpMaxNumRetxPdu', 'value': "500"},
    {'dist_name': _PDCP_1, 'parameter': 'pdcpPduRetxDelayThresh1', 'value': "ms40"},
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

# counter_dic_path_C003 = [
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2',
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2',
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2',
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2',
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2',
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/PDCP2',
#     'BTS/BTS/NRBTS-356111/PDCP2', 'BTS/BTS/NRBTS-356111/F1UB1', 'BTS/BTS/NRBTS-356111/F1UB1',
#     'BTS/BTS/NRBTS-356111/F1UB1', 'BTS/BTS/NRBTS-356111/F1UB1', 'BTS/BTS/NRBTS-356111/X2UB1',
#     'BTS/BTS/NRBTS-356111/X2UB1', 'BTS/BTS/NRBTS-356111/X2UB1', 'BTS/BTS/NRBTS-356111/X2UB1',
#     'BTS/BTS/NRBTS-356111/NRDU-1/NHRLC', 'BTS/BTS/NRBTS-356111/NRDU-1/NHRLC', 'BTS/BTS/NRBTS-356111/NX2UB',
#     'BTS/BTS/NRBTS-356111/NRDU-1/NF1UD'
# ]

Modify_Para_Online_B001 = [
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UCInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UDInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UB1Interface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterface', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2UInterfacepmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UInterfaceCUpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1CC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1CD', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrF1UU', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2ccNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2CC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrX2CB', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCP1Report', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCP2Report', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPdcpC', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPDCPCell', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrPdcpCellNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcCell', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcCellNrpmqap', 'value': '5min'},
    {'dist_name': _NEPMRNL, 'parameter': 'miNrHighRlcReport', 'value': '5min'},
    {'dist_name': _DRB_4, 'parameter': 'dlFlowControlAlgo', 'value': '3gppFlowControl'},
    dict(value=[dict(initialDLTrafficRouting='initDLoverF1U', actX2DuplicateTxNSA3x='false',
                     dlDataSplitBufferBuildUpThreshold='90', dlDataSplitGainThreshold='90',
                     dlDataSplitBufferBuildUpThresholdPrioritizeX2='90',
                     dlDataSplitMode='dlOverF1UX2U')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]


Modify_Para_actX2DuplicateTxNSA3x_true = [
    dict(value=[dict(actX2DuplicateTxNSA3x='true')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]

PARAMS_TO_Para_Online_B001_X2PdcpDuplication = [
    dict(value=[dict(inactPeriodX2PdcpDuplication='500')],
         dist_name=_DRB_4, parameter='nsaDrbParam')
]
