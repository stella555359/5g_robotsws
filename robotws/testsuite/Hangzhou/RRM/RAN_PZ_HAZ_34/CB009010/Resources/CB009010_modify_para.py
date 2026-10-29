# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

GNB1_NRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB2_NRBTS = 'MRBTS-' + str(tl.gnbs[1].instance_id) + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)
NRPLMNSET = '/NRCELL-1/NRPLMNSET_NSA-1'
GNB1_NRPLMNSET = GNB1_NRBTS + NRPLMNSET
GNB2_NRPLMNSET = GNB2_NRBTS + NRPLMNSET

gnb1_para = [dict(dist_name=GNB1_NRBTS, parameter='actPlmnCellResForOpUse', value='true', operation='update'),
             dict(dist_name=GNB1_NRBTS, parameter='neutralPlmnEnabled', value='true', operation='update'),
             dict(dist_name=GNB1_NRBTS, parameter='hoForPlmnResForOpUseEnabled', value='true', operation='update'),
             dict(dist_name=GNB1_NRPLMNSET, parameter='cellReservedForOperatorUse', value='notReserved',
                  operation='update')
             ]

gnb2_para = [dict(dist_name=GNB2_NRBTS, parameter='actPlmnCellResForOpUse', value='true', operation='update'),
             dict(dist_name=GNB2_NRBTS, parameter='neutralPlmnEnabled', value='true', operation='update'),
             dict(dist_name=GNB2_NRBTS, parameter='hoForPlmnResForOpUseEnabled', value='true', operation='update'),
             dict(dist_name=GNB2_NRPLMNSET, parameter='cellReservedForOperatorUse', value='reserved',
                  operation='update')
             ]

tcpdump_check_para = [{'xpath': 'SgNBAdditionRequestAcknowledge/RRCReconfiguration/spCellConfig',
                       'expected_value': {'physCellId': '50'}, 'n': '1'},
                      {'xpath': 'SgNBAdditionRequestAcknowledge/RRCReconfiguration/spCellConfig',
                       'expected_value': {'physCellId': '70'}, 'n': '-1'},
                      {'xpath': 'CG-Config/reportCGI-RequestNR',
                       'expected_value': {'cellForWhichToReportCGI': '70'}}]

message_flow = dict(order_list=['measurementReport',
                                'SgNBModificationRequired',
                                'SgNBModificationRequest',
                                'SgNBModificationRequestAcknowledge',
                                'SgNBModificationConfirm',
                                'measurementReport',
                                'SgNBModificationRequired',
                                'SgNBModificationRequest',
                                'SgNBModificationRequestAcknowledge',
                                'SgNBModificationConfirm',
                                'SgNBModificationRequired',
                                'SgNBModificationConfirm',
                                'measurementReport',
                                'SgNBChangeRequired',
                                'SgNBAdditionRequest',
                                'SgNBAdditionRequestAcknowledge',
                                'SgNBChangeConfirm',
                                'SgNBReconfigurationComplete',
                                'SNStatusTransfer'])
