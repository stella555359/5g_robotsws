import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
#  Common scf modify part quote 5GC002007_A_1796_E/__init__.py

#         1796_E_700 801 are the same which contains in MODIFY_SCF_1077_G_517_B_OLLA
#         ulla parameter:
#         ullaDeltaSinrMax = 15
#         ullaBlerTarget (0.1)
#         ullaDeltaSinrMin (-3.0)
#         ullaDeltaSinrStepDown (0.1)
#         ullaIniMcs (0)

#         dlla parameter:
#         dllaDeltaCqiMax = 15
#         dllaBlerTarget (0.1)
#         dllaDeltaCqiMin (-3.0)
#         dllaDeltaCqiStepDown (0.1)
#         dllaIniMcs (0)

#         1116 frame

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'

MODIFY_SCF_OLLA_64QAM = [
    dict(
        value='false',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    # 1077_G_517_B_UL_OLLA
    dict(
        value='150',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaDeltaSinrMax'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaIniMcs'),
    dict(
        value='10',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaBlerTarget'),
    dict(
        value='-30',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaDeltaSinrMin'),
    dict(
        value='100',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaDeltaSinrStepdown'),
    # 1077_G_517_B_DL_OLLA
    dict(
        value='150',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaDeltaCqiMax'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaIniMcs'),
    dict(
        value='10',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaBlerTarget'),
    dict(
        value='-30',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaDeltaCqiMin'),
    dict(
        value='100',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaDeltaCqiStepdown'),
    dict(
        value='One additional DMRS',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDMRSAdditionalPosition'),
    dict(
        value='One additional DMRS',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlDMRSAdditionalPosition')
]

FRAME_TO_11160ms_60MHz_6Symbols = {
    'framestructure': '11160ms',
    'cell_chbw': {
        '1': '60MHz'},
    'case_level_params':
        ['modify:NRCELL-1:prachConfigurationIndex=158',
         'modify:NRCELL-1:type0CoresetConfigurationIndex=12',
         'modify:NRCELL-1:tddFrameStructure:guardPeriodLength=6Symbols',
         'modify:NRCELL-1:tddFrameStructure:ulDlDataSlotRatio=2/8']
}

MODIFY_SCF_OLLA_256QAM = [
    dict(
        value='true',
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam'),
    # 1077_G_517_B_UL_OLLA
    dict(
        value='150',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaDeltaSinrMax'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaIniMcs'),
    dict(
        value='10',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaBlerTarget'),
    dict(
        value='-30',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaDeltaSinrMin'),
    dict(
        value='100',
        dist_name=MR_NR_CELL_NAME,
        p_name='ullaDeltaSinrStepdown'),
    # 1077_G_517_B_DL_OLLA
    dict(
        value='150',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaDeltaCqiMax'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaIniMcs'),
    dict(
        value='10',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaBlerTarget'),
    dict(
        value='-30',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaDeltaCqiMin'),
    dict(
        value='100',
        dist_name=MR_NR_CELL_NAME,
        p_name='dllaDeltaCqiStepdown'),
    dict(
        value='One additional DMRS',
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDMRSAdditionalPosition'),
    dict(
        value='One additional DMRS',
        dist_name=MR_NR_CELL_NAME,
        p_name='dlDMRSAdditionalPosition')
]
