from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import NIDD_Modify_data_template as data_template

# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')
# Defined in CB008542_variables.robot
carrierAggregationSupportList_With_T_F = BuiltIn().get_variable_value('${carrierAggregationSupportList_With_T_F}')
# Defined in common_setup_teardown.robot
SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
# Defined in TLDelta.py
PARAMS_TO_ADD_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_ADD_GOLDEN}')
PARAMS_TO_ADD_GOLDEN = [] if PARAMS_TO_ADD_GOLDEN is None else PARAMS_TO_ADD_GOLDEN
PARAMS_TO_MODIFY_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_GOLDEN}')
PARAMS_TO_MODIFY_GOLDEN = [] if PARAMS_TO_MODIFY_GOLDEN is None else PARAMS_TO_MODIFY_GOLDEN

GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
NSA_T_F_ALLOCATION = BuiltIn().get_variable_value('${NSA_T_F_ALLOCATION}')
FDD_CELLS = NSA_T_F_ALLOCATION['FDD']
TDD_CELLS = NSA_T_F_ALLOCATION['TDD']

DELETE_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList')
]

DELETE_SCF_CA_NRREL = [dict(dist_name=DN_CA_REL)]

ADD_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=DN_NRBTS + '/NRDU-1',
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList_With_T_F),
]

ADD_SCF_CA_NRREL = param_modify_lib.generate_nrrel_with_cell_for_scf_add(
    program=program, dist_name=DN_CA_REL, cell_lcrid=SCELL_LIST[CA_GROUP_INDEX]['lcrId'],
    gNbIdLength=GNB_INFO['gNbIdLength'], mncLength=GNB_INFO['mncLength'])


MODIFY_8542_COUNTER_INTERVAL = [
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaDu'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrRacCu'),
    dict(
        value='5min',
        dist_name=DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrRacDu'),
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
]

ACT_K1_OPT = param_modify_lib.generate_actK1Opt_for_scf_modify(program=program, dist_name=DN_PCELL,
                                                               is_k1opt_enabled='true') + \
             param_modify_lib.generate_actK1Opt_for_scf_modify(program=program, dist_name=DN_SCELL,
                                                               is_k1opt_enabled='true')

MODIFY_SCF_8542_BASE = [
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actFdmScheduling'),
    dict(
        value='false',
        dist_name=DN_NRBTS,
        p_name='actLteNrDss'),
    dict(
        value='longPucch',
        dist_name=DN_PCELL,
        p_name='pucchModeSelect'),
    dict(
        value='longPucch',
        dist_name=DN_SCELL,
        p_name='pucchModeSelect'),
    dict(
        value='false',
        dist_name=DN_PCELL,
        p_name='actCDrx'),
    dict(
        value='false',
        dist_name=DN_SCELL,
        p_name='actCDrx'),
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actBeamforming'),
    dict(
        value='false',
        dist_name=DN_PCELL,
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='ConfigurationIndependent',
        dist_name=DN_NRBTS + '/NRDU-1',
        p_name='flexibleCAMode'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actMeasBasedSCellAdditionNsa'),
    dict(
        value='240',
        dist_name=DN_PCELL,
        p_name='reqMinNumPuschPrb'),
    dict(
        value='16',
        dist_name=DN_PCELL,
        p_name='msg1FrequencyStart'),
    dict(
        value='13',
        dist_name=DN_SCELL,
        p_name='msg1FrequencyStart'),
    dict(
        value='100MHz',
        dist_name=DN_PCELL,
        p_name='chBw'),
] + ACT_K1_OPT

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_8542_BASE = MODIFY_SCF_8542_BASE + [
        dict(value='A1-based', dist_name=param_modify_lib.DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_8542_BASE = MODIFY_SCF_8542_BASE + [
        dict(value='true', dist_name=param_modify_lib.DN_NRBTS, p_name='actMeasBasedSCellAddition')]

SCF_BWP_F20M_T100M_1116_0 = [
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-2',
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-24',
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='1'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-9',
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-91',
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='1'),
]

# SCF_BWP_F20M_T100M_1116_3 = [
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-2',
#         dist_name=DN_FDDCELLS,
#         p_name='bwpDN',
#         index='0'),
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-24',
#         dist_name=DN_FDDCELLS,
#         p_name='bwpDN',
#         index='1'),
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-10',
#         dist_name=DN_TDDCELLS,
#         p_name='bwpDN',
#         index='0'),
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-101',
#         dist_name=DN_TDDCELLS,
#         p_name='bwpDN',
#         index='1'),
# ]

# SCF_BWP_F10M_T60M_1208 = [
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-22',
#         dist_name=DN_FDDCELLS,
#         p_name='bwpDN',
#         index='0'),
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-23',
#         dist_name=DN_FDDCELLS,
#         p_name='bwpDN',
#         index='1'),
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-42',
#         dist_name=DN_TDDCELLS,
#         p_name='bwpDN',
#         index='0'),
#     dict(
#         value=DN_NRBTS + '/BWP_PROFILE-43',
#         dist_name=DN_TDDCELLS,
#         p_name='bwpDN',
#         index='1'),
# ]

# Default define in testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Variables
# Can be over-written in TLs under commission folder.
BWP_ID_MAPPING = BuiltIn().get_variable_value('${BWP_ID_MAPPING}')

MODIFY_SCF_T100M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_T100M_1116, list_cell_id=[TDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['TDD_1116_0_100M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['TDD_1116_0_100M']['dedicate'])

MODIFY_SCF_F20M = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_F20M, list_cell_id=[FDD_CELLS[0]],
    value=param_modify_lib.DN_NRBTS, bwp_id_initial=BWP_ID_MAPPING['FDD_20M']['initial'],
    bwp_id_dedicate=BWP_ID_MAPPING['FDD_20M']['dedicate'])

FLEXIBLE_CA_MODE = param_modify_lib.generate_flexible_ca_mode_for_scf_modify(program=program)

DELETE_SCF_DEFAULT = DELETE_SCF_CA_SUPPORT_LIST + DELETE_SCF_CA_NRREL

ADD_SCF_DEFAULT = ADD_SCF_CA_SUPPORT_LIST + ADD_SCF_CA_NRREL

MODIFY_SCF_DEFAULT = SCF_BUFFER_ACT_SCELL + MODIFY_SCF_8542_BASE + SCF_ENABLE_BF + MODIFY_8542_COUNTER_INTERVAL

MODIFY_SCF_DEFAULT_20M_100M_1116_0 = MODIFY_SCF_DEFAULT + SCF_FRAME_STRUCTURE_1116_0 + \
                            MODIFY_SCF_T100M + MODIFY_SCF_F20M
#
# MODIFY_SCF_DEFAULT_20M_100M_1116_3 = MODIFY_SCF_DEFAULT + SCF_CHBW_F20M_T100M + SCF_FRAME_STRUCTURE_1116_3 + \
#                             SCF_BWP_F20M_T100M_1116_3
#
# MODIFY_SCF_DEFAULT_10M_60M_1208 = MODIFY_SCF_DEFAULT + SCF_CHBW_F10M_T60M + SCF_FRAME_STRUCTURE_1208 + \
#                             SCF_BWP_F10M_T60M_1208
