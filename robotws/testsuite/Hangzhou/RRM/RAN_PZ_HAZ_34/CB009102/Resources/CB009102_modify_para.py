# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRBTS_ID = MRBTS_ID + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRCELL_1 = NRBTS_ID + '/NRCELL-1'

case4_str_para1 = [dict(dist_name=NRCELL_1, parameter='dlDataDmrsFdm', value=[{'actDlDataDmrsFdm': 'false'}])]

case4_kw = ['NRCELL_A-1']

case4_common = [dict(dist_name=NRCELL_1, parameter='actPdschAtSsbSlots', value='false'),
                dict(dist_name=NRCELL_1, parameter='actPdschRmCsirsForTracking', value='false'),
                dict(dist_name=NRCELL_1, parameter='prachConfigurationIndex', value='98')]

counter_id_list1 = ['M55143C00001', 'M55143C00004', 'M55145C00341', 'M55145C00342']
counter_id_list2 = ['M55143C00005', 'M55143C00006', 'M55145C00362', 'M55125C01501']


case14_port = [0, 1, 2, 3]
case17_port = [2, 3, 4]


com_attached_pci = ['UEContextModificationResponse', 'spCellConfig', 'spCellConfigCommon']
com_switched_pci = ['rrcReconfiguration', 'spCellConfig', 'spCellConfigCommon']


gnb_source_message_flow = dict(order_list=['measurementreport', 'rrcReconfiguration'],
                               should_not_include=['PDUSessionResourceModifyRequest'])

gnb_target_message_flow = dict(order_list=['PathSwitchRequest',
                                           'PathSwitchRequestAcknowledge',
                                           'UEContextModificationResponse'],
                               should_not_include=['PDUSessionResourceModifyRequest'])

gnb_same_message_flow = dict(order_list=['measurementreport',
                                         'rrcReconfiguration',
                                         'rrcReconfigurationComplete',
                                         'UEContextModificationResponse'])

case18_parameters_check = [dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' +
                                      'tdd-UL-DL-ConfigurationCommon/pattern1',
                                expected_value={'dl-UL-TransmissionPeriodicity': 'ms2p5 (5)',
                                                'nrofDownlinkSlots': '3',
                                                'nrofDownlinkSymbols': '10',
                                                'nrofUplinkSlots': '1',
                                                'nrofUplinkSymbols': '2'}),
                           dict(xpath='SgNBAdditionRequestAcknowledge/RRCReconfiguration/' +
                                      'tdd-UL-DL-ConfigurationCommon/pattern2',
                                expected_value={'dl-UL-TransmissionPeriodicity': 'ms2p5 (5)',
                                                'nrofDownlinkSlots': '2',
                                                'nrofDownlinkSymbols': '10',
                                                'nrofUplinkSlots': '2',
                                                'nrofUplinkSymbols': '2'})]
