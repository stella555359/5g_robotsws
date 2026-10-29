from robot.libraries.BuiltIn import BuiltIn
from NIDD_modify_scf import PCELL_DN, FDD_CELLS, TDD_CELLS
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
# from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')
# ININUMSCELLSTOACTIVATE = BuiltIn().get_variable_value('${ININUMSCELLSTOACTIVATE}')

# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value('${GNB_INFO}')

# NR_CELL_ID_MAPPING: Get from GNB online by method get_relation_mapping_between_cell_index_and_other_ids
NR_CELL_ID_MAPPING = BuiltIn().get_variable_value('${NR_CELL_ID_MAPPING}')

ONLINE_ENABLE_CB008830_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='dlDmrsType',
        value='Type2'),
]

ONLINE_DISABLE_CB008830_API = [
    dict(
        dist_name=PCELL_DN,
        parameter='dlDmrsType',
        value='Type1'),
]

ACTIVE_HIGH_RELIABILITY_DRB = [
    dict(
        dist_name=PCELL_DN,
        parameter='actLAForHiReliab',
        value='true'),
]

ACTIVE_VONR = [
    dict(
        dist_name=PCELL_DN,
        parameter='actVoNR',
        value='true'),
]

ACTIVE_HR_DRB_VONR_IWK_CBOO8830 = ACTIVE_HIGH_RELIABILITY_DRB + ONLINE_ENABLE_CB008830_API + ACTIVE_VONR
