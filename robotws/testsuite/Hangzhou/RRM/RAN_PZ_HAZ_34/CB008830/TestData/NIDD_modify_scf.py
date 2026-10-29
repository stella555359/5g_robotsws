from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
T_F_ALLOCATION = BuiltIn().get_variable_value('${T_F_ALLOCATION}')
FDD_CELLS = T_F_ALLOCATION['FDD']
TDD_CELLS = T_F_ALLOCATION['TDD']

# Defined in commissionings/HGZ/${testline_name}/__init_8830__.py
PCELL_DN = param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[0])
CELL5_AEHC_DN = param_modify_lib.DN_NRBTS + '/NRCELL-' + str(TDD_CELLS[2])

# Defined in CB008830_variables.robot
carrierAggregationSupportList_T_F_UL_DL = BuiltIn().get_variable_value('${carrierAggregationSupportList_T_F_UL_DL}')
# # Defined in common_setup_teardown.robot
SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
# Defined in TLDelta.py
PARAMS_TO_ADD_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_ADD_GOLDEN}')
PARAMS_TO_ADD_GOLDEN = [] if PARAMS_TO_ADD_GOLDEN is None else PARAMS_TO_ADD_GOLDEN
PARAMS_TO_MODIFY_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_GOLDEN}')
PARAMS_TO_MODIFY_GOLDEN = [] if PARAMS_TO_MODIFY_GOLDEN is None else PARAMS_TO_MODIFY_GOLDEN
#
GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)

# Default define in testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Variables
# Can be over-written in TLs under commission folder.
BWP_ID_MAPPING = BuiltIn().get_variable_value('${BWP_ID_MAPPING}')

DELETE_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList')
]

ADD_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList_T_F_UL_DL),
]

DELETE_SCF_DEFAULT = DELETE_SCF_CA_SUPPORT_LIST

ADD_SCF_DEFAULT = ADD_SCF_CA_SUPPORT_LIST + PARAMS_TO_ADD_GOLDEN


# ################################### For SCF modification part
# # Disable cipher as it will affect parse for messages
MODIFY_SCF_DISABLE_CIPHER = [
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='nea0',
        value='9'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='nea1_128',
        value='0'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='nea2_128',
        value='0'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='nea3_128',
        value='0')
]

# Disable IWK related parameters under NRBTS for subfeature-A
MODIFY_SCF_DISABLE_IWK_NRBTS = [
    dict(
        value='0',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='sCellDeactivationBadRlqCount'),
    dict(
        value='false',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actE2CA'),
    dict(
        value='false',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actMultipleDedicatedBWPs'),
    dict(
        value='false',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actSliceAwareScheduler'),
    dict(
        value='false',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actConnRrcPooling'),
    dict(
        value='false',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actOverheatingAssistance'),
]

# Modify parameters for multiple cells
MODIFY_SCF_BASE_ALL_CELLS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS, list_cell_id=ALL_CELLS)

MODIFY_SCF_BASE_TDD_CELLS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_TDD_CELLS, list_cell_id=TDD_CELLS)

MODIFY_SCF_DISABLE_IWK_ALL_CELLS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_DEACT_IWK_ALL_CELL, list_cell_id=ALL_CELLS)

ACT_BEAMFORMING = [
    dict(
        value='true',
        dist_name=PCELL_DN,
        p_name='actBeamforming'),
    dict(
        value='true',
        dist_name=CELL5_AEHC_DN,
        p_name='actBeamforming'),
]

# Modify parameters
MODIFY_SCF_BASE = [
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actFdmScheduling'),

    dict(
        value='sf10',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='periodicBSRTimer'),
    dict(
        value='50',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='dlToUlContributionRatio'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='actInterNumerologyCa'),
    dict(
        value='40',
        dist_name=param_modify_lib.DN_NRBTS + '/NRDRB_RLC_AM-1',
        p_name='ulTReassemblyIBCA'),
    dict(
        value='40',
        dist_name=param_modify_lib.DN_NRBTS + '/NRDRB_RLC_AM-2',
        p_name='ulTReassemblyIBCA'),
    dict(
        dist_name=PCELL_DN,
        p_name='iniNumSCellsToActivate',
        value='0'),
] + MODIFY_SCF_DISABLE_CIPHER + ACT_BEAMFORMING

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_BASE = MODIFY_SCF_BASE + [
        dict(value='A1-based', dist_name=param_modify_lib.DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_BASE = MODIFY_SCF_BASE + [
        dict(value='true', dist_name=param_modify_lib.DN_NRBTS, p_name='actMeasBasedSCellAddition')]

MODIFY_SCF_DEFAULT = MODIFY_SCF_BASE + MODIFY_SCF_BASE_ALL_CELLS \
                     + MODIFY_SCF_BASE_TDD_CELLS + PARAMS_TO_MODIFY_GOLDEN \
                     + MODIFY_SCF_DISABLE_IWK_ALL_CELLS + MODIFY_SCF_DISABLE_IWK_NRBTS
