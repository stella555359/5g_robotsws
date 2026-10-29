import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

ENB_MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
MR_NR_ENB_NAME = ENB_MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)

LNBTS_1 = MR_NR_ENB_NAME
LNCELL_1 = MR_NR_ENB_NAME + '/LNCEL-1'

NRBTS_1 = MR_NR_BTS_NAME
NRCELL_1 = MR_NR_BTS_NAME + '/NRCELL-1'
NRCELL_2 = MR_NR_BTS_NAME + '/NRCELL-2'

ENB_MODIFY_Parameter_001 = [dict(dist_name=LNCELL_1, parameter='defaultLnRelGnbCellId', value='3'),
                            dict(dist_name=LNBTS_1, parameter='actDynTrigLteNrDualConnectivity', value='false')]


GNB_MODIFY_Parameter_002 = [dict(dist_name=NRBTS_1, parameter='actIntraFreqIntraGnbMobilityNSA', value='true'),
                            dict(dist_name=NRBTS_1, parameter='srb3SupportEnabled', value='true'),
                            dict(dist_name=NRBTS_1, parameter='t304', value='ms2000'),
                            dict(dist_name=NRCELL_1, parameter='a3MeasEnabled', value='rsrpCombined'),
                            dict(dist_name=NRCELL_1, parameter='a5MeasEnabled', value='none'),
                            dict(dist_name=NRCELL_2, parameter='a3MeasEnabled', value='none'),
                            dict(dist_name=NRCELL_2, parameter='a5MeasEnabled', value='rsrp')]

GNB_MODIFY_Parameter_003 = [dict(dist_name=NRBTS_1, parameter='actIntraFreqIntraGnbMobilityNSA', value='true'),
                            dict(dist_name=NRBTS_1, parameter='srb3SupportEnabled', value='true'),
                            dict(dist_name=NRBTS_1, parameter='t304', value='ms2000'),
                            dict(dist_name=NRCELL_1, parameter='a3MeasEnabled', value='rsrq'),
                            dict(dist_name=NRCELL_1, parameter='a5MeasEnabled', value='none'),
                            dict(dist_name=NRCELL_2, parameter='a3MeasEnabled', value='none'),
                            dict(dist_name=NRCELL_2, parameter='a5MeasEnabled', value='rsrp')]

# check parameter dictionary
parameter_dic_case2 = [dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' +
                                  'spCellConfig/reconfigurationWithSync', expected_value={'physCellId': '50'}),
                       dict(xpath='F1 Application Protocol/ULRRCMessageTransfer',
                            expected_value={'SRBID': '3'}, n='2'),
                       dict(xpath='F1 Application Protocol/ULRRCMessageTransfer',
                            expected_value={'SRBID': '3'}, n='3'),
                       dict(xpath='spCellConfig/reconfigurationWithSync',
                            expected_value={'physCellId': '51', 't304': 'ms2000 (6)'}, n='6'),
                       dict(xpath='spCellConfig/reconfigurationWithSync/newUE-Identity', n='6'),
                       dict(xpath='spCellConfig/uplinkConfig/bwp-Common',
                            expected_value={'rach-ConfigCommon': 'setup (1)'}, n='6')]

parameter_dic_case3 = [dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' +
                                  'spCellConfig/reconfigurationWithSync', expected_value={'physCellId': '50'}),
                       dict(xpath='F1 Application Protocol/ULRRCMessageTransfer',
                            expected_value={'SRBID': '3'}, n='2'),
                       dict(xpath='spCellConfig/reconfigurationWithSync',
                            expected_value={'physCellId': '51', 't304': 'ms2000 (6)'}, n='6'),
                       dict(xpath='spCellConfig/reconfigurationWithSync/newUE-Identity', n='6'),
                       dict(xpath='spCellConfig/uplinkConfig/bwp-Common',
                            expected_value={'rach-ConfigCommon': 'setup (1)'}, n='6'),
                       dict(xpath='F1 Application Protocol/ULRRCMessageTransfer',
                            expected_value={'SRBID': '3'}, n='5'),
                       dict(xpath='spCellConfig/reconfigurationWithSync',
                            expected_value={'physCellId': '50', 't304': 'ms2000 (6)'}, n='10'),
                       dict(xpath='spCellConfig/reconfigurationWithSync/newUE-Identity', n='10'),
                       dict(xpath='spCellConfig/uplinkConfig/bwp-Common',
                            expected_value={'rach-ConfigCommon': 'setup (1)'}, n='10')]

# check message by or or not parameters    order_list/not_order_list/should_not_include
message_flow_case2 = dict(order_list=['SgNBAdditionRequest',
                                      'SgNBAdditionRequestAcknowledge',
                                      'RRCReconfigurationComplete',
                                      'drx-Config: setup (1)',
                                      'rrcReconfigurationComplete',
                                      'measurementreport',
                                      'measurementreport',
                                      'rrcReconfiguration',
                                      'rrcReconfigurationComplete',
                                      'SgNBModificationRequired',
                                      'SgNBModificationConfirm',
                                      'drx-Config: setup (1)',
                                      'rrcReconfigurationComplete'],
                          should_not_include=['SgNBReleaseRequest',
                                              'UEContextRelease',
                                              'SgNBReleaseRequestAcknowledge'])

message_flow_case3 = dict(order_list=['SgNBAdditionRequest',
                                      'SgNBAdditionRequestAcknowledge',
                                      'RRCReconfigurationComplete',
                                      'drx-Config: setup (1)',
                                      'rrcReconfigurationComplete',
                                      'measurementreport',
                                      'rrcReconfiguration',
                                      'rrcReconfigurationComplete',
                                      'SgNBModificationRequired',
                                      'SgNBModificationConfirm',
                                      'drx-Config: setup (1)',
                                      'rrcReconfigurationComplete',
                                      'measurementreport',
                                      'rrcReconfiguration',
                                      'rrcReconfigurationComplete',
                                      'SgNBModificationRequired',
                                      'SgNBModificationConfirm',
                                      'drx-Config: setup (1)',
                                      'rrcReconfigurationComplete'],
                          should_not_include=['SgNBReleaseRequest',
                                              'UEContextRelease',
                                              'SgNBReleaseRequestAcknowledge'])
