import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELL-' + str(tl.gnbs[0].instance_id)

MR_NR_CELLGRP_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + \
    '/NRCELLGRP-0'

MODIFY_SCF_2015_C_1116_01_pre_condition = [
    dict(p_name='dlMimoMode', dist_name=MR_NR_CELL_NAME, value='2x2 Open Loop Spatial Multiplexing'),
    dict(p_name='actDlDataDmrsFdm', dist_name=MR_NR_CELL_NAME, value='false'),
    dict(p_name='dmrsTypeAPosition', dist_name=MR_NR_CELL_NAME, value='pos3'),
    dict(p_name='dlDMRSAdditionalPosition', dist_name=MR_NR_CELL_NAME, value='No additional DMRS'),
    dict(p_name='actDl256Qam', dist_name=MR_NR_CELL_NAME, value='false')
]
MODIFY_SCF_2015_C_1116_01_Step3 = [
     dict(
         abbr='actDlDataDmrsFdm',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Activate downlink data and DMRS FDM',
         new_value='true'),
     dict(
         abbr='dlDataDmrsFdmThres64QamMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink data and DMRS FDM threshold 64QAM MCS',
         new_value='20')
]
MODIFY_SCF_2015_C_1116_01_Step5 = [
     dict(
         abbr='dlDataDmrsFdmThres64QamMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink data and DMRS FDM threshold 64QAM MCS',
         new_value='6')
]
MODIFY_SCF_2015_C_1116_01_Step6 = [
    dict(
         abbr='dmrsTypeAPosition',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Dmrs-TypeA position',
         new_value='pos2'),
]
MODIFY_SCF_2015_C_1116_01_Step7 = [
    dict(
        abbr='dlDMRSAdditionalPosition',
        dist_name=MR_NR_CELL_NAME,
        filter_param='Downlink DMRS additional position',
        new_value='One additional DMRS')
]
MODIFY_SCF_2015_C_1116_04_pre_condition = [
    dict(p_name='dlMimoMode', dist_name=MR_NR_CELL_NAME, value='2x2 Open Loop Spatial Multiplexing'),
    dict(p_name='actDlDataDmrsFdm', dist_name=MR_NR_CELL_NAME, value='false'),
    dict(p_name='dmrsTypeAPosition', dist_name=MR_NR_CELL_NAME, value='pos3'),
    dict(p_name='dlDMRSAdditionalPosition', dist_name=MR_NR_CELL_NAME, value='No additional DMRS'),
    dict(p_name='actDl256Qam', dist_name=MR_NR_CELL_NAME, value='true')
]
MODIFY_SCF_2015_C_1116_04_Step5 = [
     dict(
         abbr='dlDataDmrsFdmThres64QamMcs',
         dist_name=MR_NR_CELL_NAME,
         filter_param='Downlink data and DMRS FDM threshold 64QAM MCS',
         new_value='19')
]
MODIFY_SCF_2015_C_1116_15_pre_condition = [
    dict(p_name='dlMimoMode', dist_name=MR_NR_CELL_NAME, value='4x4 or 4x2 Open Loop Spatial Multiplexing'),
    dict(p_name='actDlDataDmrsFdm', dist_name=MR_NR_CELL_NAME, value='true'),
    dict(p_name='dlDataDmrsFdmThres256QamMcs', dist_name=MR_NR_CELL_NAME, value='20'),
    dict(p_name='dmrsTypeAPosition', dist_name=MR_NR_CELL_NAME, value='pos2'),
    dict(p_name='dlDMRSAdditionalPosition', dist_name=MR_NR_CELL_NAME, value='One additional DMRS'),
    dict(p_name='actDl256Qam', dist_name=MR_NR_CELL_NAME, value='true')
]
MODIFY_SCF_2015_C_1116_18_pre_condition = [
    dict(p_name='dlMimoMode', dist_name=MR_NR_CELL_NAME, value='2x2 Open Loop Spatial Multiplexing'),
    dict(p_name='actDlDataDmrsFdm', dist_name=MR_NR_CELL_NAME, value='false'),
    dict(p_name='dlDataDmrsFdmThres256QamMcs', dist_name=MR_NR_CELL_NAME, value='20'),
    dict(p_name='dmrsTypeAPosition', dist_name=MR_NR_CELL_NAME, value='pos3'),
    dict(p_name='dlDMRSAdditionalPosition', dist_name=MR_NR_CELL_NAME, value='No additional DMRS'),
    dict(p_name='actDl256Qam', dist_name=MR_NR_CELL_NAME, value='false')
]
