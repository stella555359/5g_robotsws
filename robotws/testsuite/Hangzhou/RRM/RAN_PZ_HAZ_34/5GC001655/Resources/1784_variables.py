import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_NR_CELL_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-1/NRCELL-1'

MR_NR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRBTS-1'

PARAMS_TO_MODIFY_SCF_CASE_01 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]

PARAMS_TO_MODIFY_SCF_CASE_03 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1UX2U', dist_name=MR_NR_BTS_NAME, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='false', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]

PARAMS_TO_MODIFY_SCF_CASE_07 = [
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='dlDMRSAdditionalPosition'),
    dict(value='One additional DMRS', dist_name=MR_NR_CELL_NAME, p_name='ulDMRSAdditionalPosition'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab6Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab5Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab69Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab70Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab79Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab7Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab8Nsa3x', p_name='dlDataSplitMode'),
    dict(value='dlOverF1U', dist_name=MR_NR_BTS_NAME, list_name='qciTab9Nsa3x', p_name='dlDataSplitMode'),
    dict(value='true', dist_name=MR_NR_CELL_NAME, p_name='actDl256Qam')
]
