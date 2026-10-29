# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NRCELL_DSS = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_BTS_NRCELL_NDSS = MR_NR_BTS_NAME + '/NRCELL-2'


GNB_Common_Parameter_DSS = [
    dict(dist_name=MR_NR_BTS_NRCELL_DSS, parameter='dlDMRSAdditionalPosition', value='One additional DMRS'),
    dict(dist_name=MR_NR_BTS_NRCELL_DSS, parameter='dmrsTypeAPosition', value='pos3'),
    dict(dist_name=MR_NR_BTS_NRCELL_DSS, parameter='actDl256Qam', value='true'),
    dict(dist_name=MR_NR_BTS_NRCELL_DSS, parameter='dlDataDmrsFdm',
         value=[{"actDlDataDmrsFdm": 'false',
                 "dlDataDmrsFdmThres64QamMcs": '20',
                 "dlDataDmrsFdmThres256QamMcs": '20'}])
    ]

GNB_Common_Parameter_DSS_2 = [
    dict(dist_name=MR_NR_BTS_NRCELL_DSS, parameter='dlDataDmrsFdm',
         value=[{"actDlDataDmrsFdm": 'true',
                 "dlDataDmrsFdmThres64QamMcs": '20',
                 "dlDataDmrsFdmThres256QamMcs": '20'}])
    ]

GNB_Common_Parameter_NDSS = [
    dict(dist_name=MR_NR_BTS_NRCELL_NDSS, parameter='dlDMRSAdditionalPosition', value='One additional DMRS'),
    dict(dist_name=MR_NR_BTS_NRCELL_NDSS, parameter='dmrsTypeAPosition', value='pos3'),
    dict(dist_name=MR_NR_BTS_NRCELL_NDSS, parameter='actDl256Qam', value='true'),
    dict(dist_name=MR_NR_BTS_NRCELL_NDSS, parameter='dlDataDmrsFdm',
         value=[{"actDlDataDmrsFdm": 'false',
                 "dlDataDmrsFdmThres64QamMcs": '20',
                 "dlDataDmrsFdmThres256QamMcs": '20'}])
    ]

GNB_Common_Parameter_NDSS_2 = [
    dict(dist_name=MR_NR_BTS_NRCELL_NDSS, parameter='dlDataDmrsFdm',
         value=[{"actDlDataDmrsFdm": 'true',
                 "dlDataDmrsFdmThres64QamMcs": '20',
                 "dlDataDmrsFdmThres256QamMcs": '20'}])
    ]
