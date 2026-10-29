import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# #gnb###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
GNB_CELL_NAME = GNB_NR_BTS_NAME + '/NRCELL-'
GNB_NRDRB_NAME = GNB_NR_BTS_NAME + '/NRDRB-'

# # CU ##
CU_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id)
CU_NR_BTS_NAME = CU_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].cu.global_bts_id)
CU_NRDRB_NAME = CU_NR_BTS_NAME + '/NRDRB-'
CU_CELL_NAME = CU_NR_BTS_NAME + '/NRCELL-'

# # ENB  ##
ENB_LNBTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id) + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
ENB_CELL2_NAME = ENB_LNBTS_NAME + '/LNCEL-2'

filter1 = '(nr-rrc) && (nr-rrc.cellIdentity =='
filter2 = '(((dldata_pdschsendreql1sw) && (3gpp.rnti == 65535))) && (3gpp.dmrsScramblingSequenceInt =='
filter3 = ('(dldata_csirssendreql1sw) && (DlData_CsiRsResourceL1sw_t.trsInfo == 1) &&'
           ' (DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt ==')
filter4 = '(dldata_ssblocksendreql1sw) && (3gpp.subcellid =='

rrc_cellIdentity_list = ['02:49:04:00:20', '02:49:04:00:50', '02:49:04:00:60']
nr_cell_list = ['82', '85', '86']
subcellid_list = ['0', '1', '2']

field_name_list1 = ['nr-rrc.ss_PBCH_BlockPower']
field_name_list2 = ['DlData_PdschGrantL1sw.i2Codebook4AntPorts', 'DlData_PdschGrantL1sw.numStreamIndex',
                    'DlData_PdschGrantL1sw.openLoopScheme', 'DlData_PdschGrantL1sw.closedLoop3gppCodebook']
field_name_list4 = ['DlData_SsBlockSendReqL1sw_t.precodingVectorIndex', 'DlData_SsBlockSendReqL1sw_t.numCeAxcIndex',
                    'DlData_SsBlockSendReqL1sw_t.enhTransScheme']

check_value_list1 = [dict(ss_PBCH_BlockPower='13'),
                     dict(ss_PBCH_BlockPower='-12'),
                     dict(ss_PBCH_BlockPower='-17'),]

check_value_list2 = [{'i1Codebook4AntPorts_item[1]': '255', 'i1Codebook4AntPorts_item[2]': '255',
                      'i1Codebook4AntPorts_item[3]': '255', 'i2Codebook4AntPorts': '255',
                      'numStreamIndex': '4', 'openLoopScheme': '3', 'closedLoop3gppCodebook': '255'},
                     {'i1Codebook4AntPorts_item[1]': '255', 'i1Codebook4AntPorts_item[2]': '255',
                      'i1Codebook4AntPorts_item[3]': '255', 'i2Codebook4AntPorts': '255',
                      'numStreamIndex': '4', 'openLoopScheme': '3', 'closedLoop3gppCodebook': '255'},
                     {'i1Codebook4AntPorts_item[1]': '255', 'i1Codebook4AntPorts_item[2]': '255',
                      'i1Codebook4AntPorts_item[3]': '255', 'i2Codebook4AntPorts': '255',
                      'numStreamIndex': '4', 'openLoopScheme': '3', 'closedLoop3gppCodebook': '255'},]

check_value_list3 = [dict(antennaStream='15', numCeAxCIndex='4', enhTransScheme='1'),
                     dict(antennaStream='15', numCeAxCIndex='4', enhTransScheme='1'),
                     dict(antennaStream='15', numCeAxCIndex='4', enhTransScheme='1'),]

check_value_list4 = [dict(precodingVectorIndex='255', numCeAxcIndex='4', enhTransScheme='1'),
                     dict(precodingVectorIndex='255', numCeAxcIndex='4', enhTransScheme='1'),
                     dict(precodingVectorIndex='255', numCeAxcIndex='4', enhTransScheme='1'),]

check_value_list5 = [{'i1Codebook4AntPorts_item[1]': '255', 'i1Codebook4AntPorts_item[2]': '255',
                      'i1Codebook4AntPorts_item[3]': '255', 'i2Codebook4AntPorts': '255',
                      'numStreamIndex': '4', 'openLoopScheme': '255', 'closedLoop3gppCodebook': '3'},
                     {'i1Codebook4AntPorts_item[1]': '255', 'i1Codebook4AntPorts_item[2]': '255',
                      'i1Codebook4AntPorts_item[3]': '255', 'i2Codebook4AntPorts': '255',
                      'numStreamIndex': '4', 'openLoopScheme': '255', 'closedLoop3gppCodebook': '3'},
                     {'i1Codebook4AntPorts_item[1]': '255', 'i1Codebook4AntPorts_item[2]': '255',
                      'i1Codebook4AntPorts_item[3]': '255', 'i2Codebook4AntPorts': '255',
                      'numStreamIndex': '4', 'openLoopScheme': '255', 'closedLoop3gppCodebook': '3'},]

legacy_value_list1 = [dict(ss_PBCH_BlockPower='16'),
                      dict(ss_PBCH_BlockPower='-9'),
                      dict(ss_PBCH_BlockPower='-14'),]

legacy_value_list2 = [dict(openLoopScheme='255', closedLoop3gppCodebook='1'),
                      dict(openLoopScheme='255', closedLoop3gppCodebook='1'),
                      dict(openLoopScheme='255', closedLoop3gppCodebook='1'),]

legacy_value_list3 = [dict(enhTransScheme='0'),
                      dict(enhTransScheme='0'),
                      dict(enhTransScheme='0'),]

legacy_field_name_list2 = ['DlData_PdschGrantL1sw.openLoopScheme', 'DlData_PdschGrantL1sw.closedLoop3gppCodebook']

legacy_field_name_list4 = ['DlData_SsBlockSendReqL1sw_t.enhTransScheme']

filter_list_2tx = [filter1, filter2, filter3, filter4]
cell_info_list_2tx = [rrc_cellIdentity_list, nr_cell_list, nr_cell_list, subcellid_list]
field_name_list_2tx = [field_name_list1, field_name_list2, '', field_name_list4]
pdml_name_list_2tx = ['cellIdentity', 'pdschsendreql1sw', 'csirssendreql1sw', 'ssblocksendreql1sw']
check_value_open_2tx = [check_value_list1, check_value_list2, check_value_list3, check_value_list4]
normal_field_list_2tx = [True, True, False, True]
abnormal_field_list_2tx = [False, True, True, False]

check_value_close_2tx = [check_value_list1, check_value_list5, check_value_list3, check_value_list4]


field_name_list_legacy = [field_name_list1, legacy_field_name_list2, '', legacy_field_name_list4]
check_value_list_legacy = [legacy_value_list1, legacy_value_list2, legacy_value_list3, legacy_value_list3]
normal_field_list_legacy = [True, True, False, True]
abnormal_field_list_legacy = [False, False, True, False]

para_dlMimoMode1 = {'parameterName': 'dlMimoMode', 'value': '4x4 or 4x2 Open Loop Spatial Multiplexing',
                    'operation': 'update'}
para_dlMimoMode2 = {'parameterName': 'dlMimoMode', 'value': '4x4 or 4x2 Closed Loop Spatial Multiplexing',
                    'operation': 'update'}
para_actEnhCtrlChannelTrans1 = {'parameterName': 'actEnhCtrlChannelTrans', 'value': 'true',
                                'operation': 'update'}
para_enhCtrlChannelTransMode1 = {'parameterName': 'enhCtrlChannelTransMode', 'value': '2TX_trans',
                                 'operation': 'update'}
para_enhCtrlChannelTransMode2 = {'parameterName': 'enhCtrlChannelTransMode', 'value': 'Legacy_trans',
                                 'operation': 'update'}
para_enhCtrlChannelTransMode3 = {'parameterName': 'enhCtrlChannelTransMode', 'value': 'PMI_based_trans',
                                 'operation': 'update'}
para_enhCtrlChannelTransMode4 = {'parameterName': 'enhCtrlChannelTransMode', 'value': '2TX_PMI_trans',
                                 'operation': 'update'}
para_actAntPortMap = {'parameterName': 'actAntPortMap', 'value': 'true', 'operation': 'update'}
para_actAntPortMap1 = {'parameterName': 'actAntPortMap', 'value': 'false', 'operation': 'update'}
qrx_22 = {'parameterName': 'qRxLevMin', 'value': '-22', 'operation': 'update'}
qrx_65 = {'parameterName': 'qRxLevMin', 'value': '-65', 'operation': 'update'}
ssb_power_00 = {'parameterName': 'ssPbchBlockPower', 'value': '0', 'operation': 'update'}
ssb_power_10 = {'parameterName': 'ssPbchBlockPower', 'value': '10', 'operation': 'update'}

case15_du_para1 = [dict(distName=GNB_CELL_NAME + '2', operation='update',
                        parameters=[para_dlMimoMode1, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   dict(distName=GNB_CELL_NAME + '5', operation='update',
                        parameters=[para_dlMimoMode1, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   dict(distName=GNB_CELL_NAME + '6', operation='update',
                        parameters=[para_dlMimoMode1, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        )]

case15_cu_para1 = [dict(distName=CU_CELL_NAME + '2', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1]
                        ),
                   dict(distName=CU_CELL_NAME + '5', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1]
                        ),
                   dict(distName=CU_CELL_NAME + '6', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1]
                        ),
                   ]

case15_du_para2 = [dict(distName=GNB_CELL_NAME + '2', operation='update',
                        parameters=[para_dlMimoMode2, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   dict(distName=GNB_CELL_NAME + '5', operation='update',
                        parameters=[para_dlMimoMode2, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   dict(distName=GNB_CELL_NAME + '6', operation='update',
                        parameters=[para_dlMimoMode2, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   ]

case15_du_para3 = [dict(distName=GNB_CELL_NAME + '2', operation='update',
                        parameters=[para_dlMimoMode2, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode2],
                        ),
                   dict(distName=GNB_CELL_NAME + '5', operation='update',
                        parameters=[para_dlMimoMode2, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode2],
                        ),
                   dict(distName=GNB_CELL_NAME + '6', operation='update',
                        parameters=[para_dlMimoMode2, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode2],
                        ),
                   ]

case15_cu_para3 = [dict(distName=CU_CELL_NAME + '2', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode2],
                        ),
                   dict(distName=CU_CELL_NAME + '5', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode2],
                        ),
                   dict(distName=CU_CELL_NAME + '6', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode2],
                        ),
                   ]

case10_du_para1 = [dict(distName=GNB_CELL_NAME + '6', operation='update',
                        parameters=[para_actAntPortMap, para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   dict(distName=GNB_CELL_NAME + '2', operation='update',
                        parameters=[para_actAntPortMap, para_actEnhCtrlChannelTrans1,
                                    para_enhCtrlChannelTransMode1, qrx_22, ssb_power_00],
                        ),
                   ]

case10_cu_para1 = [dict(distName=CU_CELL_NAME + '6', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   dict(distName=CU_CELL_NAME + '2', operation='update',
                        parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode1],
                        ),
                   ]

case10_enb_para1 = [dict(dist_name=ENB_LNBTS_NAME, parameter='actDynTrigLteNrDualConnectivity',
                         value='false', operation='update'),
                    dict(dist_name=ENB_CELL2_NAME, parameter='defaultLnRelGnbCellId',
                         value='8', operation='update')]

case10_enb_para2 = [dict(dist_name=ENB_CELL2_NAME, parameter='defaultLnRelGnbCellId',
                         value='5', operation='update')]

case10_du_para3 = [dict(distName=GNB_CELL_NAME + '6', operation='update', parameters=[para_actAntPortMap1]),
                   dict(distName=GNB_CELL_NAME + '2', operation='update',
                        parameters=[para_actAntPortMap1, qrx_65, ssb_power_10]),
                   ]

case10_counter1 = {'M55112C00007': [CU_CELL_NAME + '6']}
case10_counter2 = {'M55112C00007': [CU_CELL_NAME + '2']}

case7_du_para1 = [dict(distName=GNB_CELL_NAME + '2', operation='update',
                       parameters=[para_dlMimoMode1, para_enhCtrlChannelTransMode1]),]

case7_cu_para1 = [dict(distName=CU_CELL_NAME + '2', operation='update', parameters=[para_enhCtrlChannelTransMode1]),]

case7_enb_para1 = [dict(dist_name=ENB_CELL2_NAME, parameter='defaultLnRelGnbCellId', value='5', operation='update')]

case8_du_para1 = [dict(distName=GNB_CELL_NAME + '5', operation='update',
                       parameters=[para_dlMimoMode2, para_enhCtrlChannelTransMode1]),]

case8_cu_para1 = [dict(distName=CU_CELL_NAME + '5', operation='update',
                       parameters=[para_enhCtrlChannelTransMode1]),]

filter_B_1 = ('(((dldata_csirssendreql1sw) && (DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt == 85)) )'
              ' && (DlData_CsiRsResourceL1sw_t.trsInfo == 1)')

filter_B_2 = '(dldata_pdschsendreql1sw) && (3gpp.dmrsScramblingSequenceInt == 85)'

filter_B_3 = ('((dldata_pdcchsendreql1sw) && !(3gpp.rnti == 65535)) && !(3gpp.dmrsScramblingSequenceInt == 82)'
              ' && !(3gpp.dmrsScramblingSequenceInt == 86)')

filter_B_4 = '((dldata_pdschsendreql1sw) && (3gpp.dmrsScramblingSequenceInt == 85)) && !(3gpp.rnti == 65535)'

filter_name_list_case4_B1 = [filter_B_1, filter_B_2, filter_B_3]
filter_name_list_case4_B2 = [filter_B_1, filter_B_4, filter_B_3]
pdml_name_list_case4_B = ['csirssendreql1sw', 'pdschsendreql1sw', 'dmrsScramblingSequenceInt']

field_name_case4_B_2 = ['DlData_PdschGrantL1sw.closedLoop3gppCodebook', 'DlData_PdschGrantL1sw.polarizationSelection']
field_name_case4_B_3 = ['DlData_DciInfoL1sw.pdcchPrecodingOption4x4', 'DlData_DciInfoL1sw.polarizationSelection',
                        'DlData_DciInfoL1sw.columnIndexOfEnhPrecodingMatrix']
cell_info_list_case4_B = [['85'], ['85'], ['85']]

normal_field_case4_B = [False, True, True]
abnormal_field_case4_B = [True, False, False]

field_name_list_case4_B = ['', field_name_case4_B_2, field_name_case4_B_3]

check_value_case4_B_1 = [[dict(enhTransScheme='0')], [dict(closedLoop3gppCodebook='1', polarizationSelection='2')],
                         [dict(columnIndexOfEnhPrecodingMatrix='64', pdcchPrecodingOption4x4='4',
                               polarizationSelection='2')]]

check_value_case4_B_2 = [[dict(enhTransScheme='1')], [dict(closedLoop3gppCodebook='1', polarizationSelection='2')],
                         [dict(columnIndexOfEnhPrecodingMatrix='64', pdcchPrecodingOption4x4='4',
                               polarizationSelection='2')]]

case4_B_du_para1 = [dict(distName=GNB_CELL_NAME + '5', operation='update',
                         parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode3],
                         )
                    ]

case4_B_cu_para1 = [dict(distName=CU_CELL_NAME + '5', operation='update',
                         parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode3],
                         )
                    ]

case4_B_du_para2 = [dict(distName=GNB_CELL_NAME + '5', operation='update',
                         parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode4],
                         )
                    ]

case4_B_cu_para2 = [dict(distName=CU_CELL_NAME + '5', operation='update',
                         parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode4],
                         )
                    ]

case3_B_du_para1 = [dict(distName=GNB_CELL_NAME + '2', operation='update',
                         parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode4, para_dlMimoMode2],
                         )
                    ]

case3_B_cu_para1 = [dict(distName=CU_CELL_NAME + '2', operation='update',
                         parameters=[para_actEnhCtrlChannelTrans1, para_enhCtrlChannelTransMode4],
                         )
                    ]
