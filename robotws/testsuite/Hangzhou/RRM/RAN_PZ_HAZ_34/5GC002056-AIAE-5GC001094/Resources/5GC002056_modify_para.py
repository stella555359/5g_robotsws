# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-1'
MR_NR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id) + '/NRCELL-2'
MR_NR_BTS_NAME3 = 'MRBTS-' + str(tl.gnbs[0].instance_id) + '/NRBTS-' + str(tl.gnbs[0].instance_id)

PARAMS_TO_MODIFY_DomainNumber0 = [dict(dist_name=MR_NR_BTS_NAME3,
                                       parameter='actIntraFreqIntraGnbMobilityNSA', value='true')]

PARAMS_TO_MODIFY_DomainNumber1 = [dict(dist_name=MR_NR_BTS_NAME1,
                                       parameter='a5MeasEnabled', value='rsrqCombined')]

PARAMS_TO_MODIFY_DomainNumber2 = [dict(dist_name=MR_NR_BTS_NAME2,
                                       parameter='a5MeasEnabled', value='rsrqCombined')]

PARAMS_TO_MODIFY_DomainNumber3 = [dict(dist_name=MR_NR_BTS_NAME1, parameter='reportOnLeave', value='true')]

PARAMS_TO_MODIFY_DomainNumber4 = [dict(dist_name=MR_NR_BTS_NAME2, parameter='reportOnLeave', value='true')]

PARAMS_TO_MODIFY_DomainNumber5 = [dict(dist_name=MR_NR_BTS_NAME1,
                                       parameter='a5MeasSsbRsrq', value={'a5Threshold1SsbRsrq': '68'})]

PARAMS_TO_MODIFY_DomainNumber6 = [dict(dist_name=MR_NR_BTS_NAME1,
                                       parameter='a5MeasSsbRsrq', value={'a5Threshold2SsbRsrq': '69'})]

PARAMS_TO_MODIFY_DomainNumber7 = [dict(dist_name=MR_NR_BTS_NAME2,
                                       parameter='a5MeasSsbRsrq', value={'a5Threshold1SsbRsrq': '68'})]

PARAMS_TO_MODIFY_DomainNumber8 = [dict(dist_name=MR_NR_BTS_NAME2,
                                       parameter='a5MeasSsbRsrq', value={'a5Threshold2SsbRsrq': '69'})]

keywords_list1 = ['NRCELL_A-1']
