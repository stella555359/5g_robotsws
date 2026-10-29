from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
import frame_structure_data_template as frame_data_template

# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')
# Defined in 5GC002329_variables.robot
carrierAggregationSupportList_With_T_F = BuiltIn().get_variable_value('${carrierAggregationSupportList_With_T_F}')
# Defined in common_setup_teardown.robot
SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
# Defined in TLDelta.py
PARAMS_TO_ADD_GOLDEN_2329 = BuiltIn().get_variable_value('${PARAMS_TO_ADD_GOLDEN}')
PARAMS_TO_ADD_GOLDEN_2329 = [] if PARAMS_TO_ADD_GOLDEN_2329 is None else PARAMS_TO_ADD_GOLDEN_2329
PARAMS_TO_MODIFY_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_GOLDEN}')
PARAMS_TO_MODIFY_GOLDEN = [] if PARAMS_TO_MODIFY_GOLDEN is None else PARAMS_TO_MODIFY_GOLDEN

# Default define in testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Variables
# Can be over-written in TLs under commission folder.
BWP_ID_MAPPING = BuiltIn().get_variable_value('${BWP_ID_MAPPING}')

GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)
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

ACT_K1_OPT = param_modify_lib.generate_actK1Opt_for_scf_modify(program=program, dist_name=DN_PCELL,
                                                               is_k1opt_enabled='true') + \
             param_modify_lib.generate_actK1Opt_for_scf_modify(program=program, dist_name=DN_SCELL,
                                                               is_k1opt_enabled='true')

MODIFY_SCF_2329_BASE = [
    dict(
        value='19',
        dist_name=DN_PCELL,
        p_name='reqMinNumPuschPrb'),
    dict(
        value='true',
        dist_name=DN_NRBTS,
        p_name='actFdmScheduling'),
    dict(
        value='slots160',
        dist_name=DN_PCELL,
        p_name='srPeriodicity'),
    dict(
        value='slots320',
        dist_name=DN_PCELL,
        p_name='csiReportPeriodicity'),
] + ACT_K1_OPT

MODIFY_SCF_2329_D = [
    dict(
        value='pi2bpsk',
        dist_name=DN_PCELL,
        p_name='pucchF3ModulationScheme'),
    dict(
        value='zeroDot15',
        dist_name=DN_PCELL,
        p_name='pucchF3MaxCodeRate'),
    dict(
        value='false',
        dist_name=DN_PCELL,
        p_name='actPerCsiReportBundlingTddFr1'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name=DN_PCELL,
        p_name='dlMimoMode'),
    dict(
        dist_name=DN_PCELL,
        p_name='nrCellType',
        value='4DL2UL'),
    dict(
        value='true',
        dist_name=DN_PCELL,
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name=DN_PCELL,
        p_name='basicBeamSet',
        list_name='beamSet'),
    dict(
        value='60',
        dist_name=DN_PCELL,
        p_name='leftEdgeAngle',
        list_name='beamSet'),
    dict(
        value='60',
        dist_name=DN_PCELL,
        p_name='rightEdgeAngle',
        list_name='beamSet'),
    dict(
        value='false',
        dist_name=DN_PCELL,
        p_name='nrBtsBeamRefinementP2',
        list_name='beamSet'),
    dict(
        value='2 beams',
        dist_name=DN_PCELL_GRP,
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='0',
        dist_name=DN_TDDCELLS,
        list_name='fPdcchMonOccsnPo',
        index=0),
]

SCF_BWP_F20M_T100M_1116_0 = [
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['FDD_20M_2329']['initial'],
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['FDD_20M_2329']['dedicate'],
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='1'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['TDD_1116_0_100M']['initial'],
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['TDD_1116_0_100M']['dedicate'],
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='1'),
]

SCF_BWP_F20M_T100M_1116_3 = [
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['FDD_20M_2329']['initial'],
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['FDD_20M_2329']['dedicate'],
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='1'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['TDD_1116_3_100M']['initial'],
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-' + BWP_ID_MAPPING['TDD_1116_3_100M']['dedicate'],
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='1'),
]

SCF_BWP_F10M_T60M_1208 = [
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-22',
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-23',
        dist_name=DN_FDDCELLS,
        p_name='bwpDN',
        index='1'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-42',
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='0'),
    dict(
        value=DN_NRBTS + '/BWP_PROFILE-43',
        dist_name=DN_TDDCELLS,
        p_name='bwpDN',
        index='1'),
]

DELETE_SCF_UNUSED_CELL_5_UNDER_TDD_CELL = [
    # Nrcell
    dict(dist_name=DN_NRBTS + '/NRCELL-5'),
    # nrcell group
    dict(dist_name=DN_NRBTS + '/NRCELLGRP-4'),
    # refNrCellGroup
    dict(dist_name=DN_NRBTS + '/NRDU-1', list_name='refNrCellGroup', index='4'),
    # cellmapping
    dict(dist_name=DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-5')
]

FLEXIBLE_CA_MODE = param_modify_lib.generate_flexible_ca_mode_for_scf_modify(program=program)

DELETE_SCF_DEFAULT = DELETE_SCF_CA_SUPPORT_LIST + DELETE_SCF_CA_NRREL + DELETE_SCF_UNUSED_CELL_5_UNDER_TDD_CELL

ADD_SCF_DEFAULT = ADD_SCF_CA_SUPPORT_LIST + ADD_SCF_CA_NRREL + PARAMS_TO_ADD_GOLDEN_2329

MODIFY_SCF_DEFAULT = MODIFY_SCF_DEFAULT_BASE + SCF_BUFFER_ACT_SCELL + SCF_DISABLE_CIPHER + MODIFY_SCF_2329_BASE\
                     + FLEXIBLE_CA_MODE + SCF_ENABLE_BF + PARAMS_TO_MODIFY_GOLDEN

MODIFY_SCF_FRAME_STRUCTURE_1116_0_TEMPLATE = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=frame_data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_0, list_cell_id=[PCELL_ID])

MODIFY_SCF_FRAME_STRUCTURE_1116_3_TEMPLATE = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=frame_data_template.SCF_MODIFY_TEMPLATE_FRAME_STRUCTURE_1116_3, list_cell_id=[PCELL_ID])

MODIFY_SCF_DEFAULT_20M_100M_1116_0 = MODIFY_SCF_DEFAULT + SCF_CHBW_F20M_T100M + \
                                     MODIFY_SCF_FRAME_STRUCTURE_1116_0_TEMPLATE + SCF_BWP_F20M_T100M_1116_0

MODIFY_SCF_DEFAULT_20M_100M_1116_3 = MODIFY_SCF_DEFAULT + SCF_CHBW_F20M_T100M + \
                                     MODIFY_SCF_FRAME_STRUCTURE_1116_3_TEMPLATE + SCF_BWP_F20M_T100M_1116_3
