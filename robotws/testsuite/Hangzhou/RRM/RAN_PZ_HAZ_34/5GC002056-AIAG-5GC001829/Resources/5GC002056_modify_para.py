# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-1'
MR_NR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-2'

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='a3MeasEnabled', value='none')]
PARAMS_TO_MODIFY_DomainNumber1 = [dict(dist_name=MR_NR_BTS_NAME2, parameter='a3MeasEnabled', value='none')]
PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='a5MeasEnabled', value='rsrp')]
PARAMS_TO_MODIFY_DomainNumber3 = [dict(dist_name=MR_NR_BTS_NAME2, parameter='a5MeasEnabled', value='rsrp')]

GNB_MODIFY_Parameter_srb3 = [
    dict(dist_name=MR_NR_BTS, parameter='srb3SupportEnabled', value='true', operation='update'),
    dict(dist_name=MR_NR_BTS_NAME1, parameter='a3MeasEnabled', value='rsrp', operation='update'),
    dict(dist_name=MR_NR_BTS_NAME2, parameter='a3MeasEnabled', value='rsrp', operation='update'),
    dict(dist_name=MR_NR_BTS, parameter='actIntraFreqIntraGnbMobilityNSA', value='true', operation='update')]

message_flow = dict(order_list=['measurementreport',
                                'UEContextModificationRequest',
                                'UEContextModificationResponse',
                                'DLRRCMessageTransfer',
                                'UEContextModificationRequest',
                                'UEContextModificationResponse'],
                    should_not_include=['UEContextRelease'])
