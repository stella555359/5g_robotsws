from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')
# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
F_T_ALLOCATION = BuiltIn().get_variable_value('${F_T_ALLOCATION}')
FDD_CELLS = F_T_ALLOCATION['FDD']
TDD_CELLS = F_T_ALLOCATION['TDD']

# Defined in commissionings/HGZ/${testline_name}/__init_6137__.py
# ${CA_GROUP_MAPPING} is defined at suite level or case level by kw 'Decode CA group mapping and set global variable'
CA_GROUP_MAPPING = BuiltIn().get_variable_value('${CA_GROUP_MAPPING}')
LIST_PCELL_ID = [CA_GROUP_MAPPING['pcell_id']]
LIST_SCELL_ID = CA_GROUP_MAPPING['verify_scell_add_dl']
LIST_SCELL_UL_ID = CA_GROUP_MAPPING['verify_scell_add_ul']

PCELL_DN = param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_PCELL_ID[0])
SCELL_UL_DN = param_modify_lib.DN_NRBTS + '/NRCELL-' + str(LIST_SCELL_UL_ID[0])

# Defined in CB006137_variables.robot
carrierAggregationSupportList_F_T_UL_DL = BuiltIn().get_variable_value('${carrierAggregationSupportList_F_T_UL_DL}')
DL_TO_UL_CONTRIBUTION_RATIO = BuiltIn().get_variable_value('${DL_TO_UL_CONTRIBUTION_RATIO}')
# # Defined in common_setup_teardown.robot
SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
# Defined in TLDelta.py
PARAMS_TO_ADD_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_ADD_GOLDEN}')
PARAMS_TO_ADD_GOLDEN = [] if PARAMS_TO_ADD_GOLDEN is None else PARAMS_TO_ADD_GOLDEN
PARAMS_TO_MODIFY_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_GOLDEN}')
PARAMS_TO_MODIFY_GOLDEN = [] if PARAMS_TO_MODIFY_GOLDEN is None else PARAMS_TO_MODIFY_GOLDEN

# Default define in testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/Variables
# Can be over-written in TLs under commission folder.
BWP_ID_MAPPING = BuiltIn().get_variable_value('${BWP_ID_MAPPING}')
F2_ARFCN = BuiltIn().get_variable_value('${F2_ARFCN}')
GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)

DELETE_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList')
]

ADD_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList_F_T_UL_DL),
]

ADD_SCF_MAX_SCELLS_DL = [
    dict(
        value='3',
        dist_name=PCELL_DN,
        p_name='maxNumScellsDlFr1'),
]

DELETE_SCF_DEFAULT = DELETE_SCF_CA_SUPPORT_LIST
#
ADD_SCF_DEFAULT = ADD_SCF_CA_SUPPORT_LIST + ADD_SCF_MAX_SCELLS_DL + PARAMS_TO_ADD_GOLDEN


# ################################### For SCF modification part
# Set counter report period
MODIFY_SCF_COUNTER_RP_INT = [
    dict(
        value='5min',
        dist_name='MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaCu'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrCaDu'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrLowRlcReport'),
    dict(
        value='5min',
        dist_name=param_modify_lib.DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrRRCC')
]

# Disable cipher as it will affect parse for messages
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

# enable tdd bbpooling due to depend feature(CB009836) need open bbpooling
MODIFY_SCF_ENABLE_BBPOOLING = [
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actBbPoolTddFr1'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh'),
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

MODIFY_SCF_BASE_FDD_CELLS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_FDD_CELLS, list_cell_id=FDD_CELLS)

MODIFY_SCF_BASE_TDD_CELLS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_TDD_CELLS, list_cell_id=TDD_CELLS)

MODIFY_SCF_DISABLE_IWK_ALL_CELLS = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_DEACT_IWK_ALL_CELL, list_cell_id=ALL_CELLS)

MODIFY_SCF_CAMODE_IND = [
    dict(
        value='ConfigurationIndependent',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='flexibleCAMode')
    ]

MODIFY_SCF_CAMODE_NUM = [
    dict(
        value='NumberCellAmount',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='flexibleCAMode'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='actConnectedModeMobilityCA'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actSlowPrbPooling'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actConnRrcPooling'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actScheUePooling')
    ]

# Modify parameters
MODIFY_SCF_BASE = [
    dict(
        value=str(DL_TO_UL_CONTRIBUTION_RATIO),
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
        value='true',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='actConnectedModeMobilityCA'),
    dict(
        dist_name=param_modify_lib.DN_NRBTS,
        p_name='actHighestEstNrTputBcSel',  # CNI-81817, see detail in REX-14875
        value='true'),
] + MODIFY_SCF_DISABLE_CIPHER + MODIFY_SCF_COUNTER_RP_INT

if program not in ['23R3', '23R4', '24R1']:
    MODIFY_SCF_BASE = MODIFY_SCF_BASE + [
        dict(value='A1-based', dist_name=param_modify_lib.DN_NRBTS, list_name='actMeasBasedSCellAdditionSa')]
else:
    MODIFY_SCF_BASE = MODIFY_SCF_BASE + [
        dict(value='true', dist_name=param_modify_lib.DN_NRBTS, p_name='actMeasBasedSCellAddition')]

MODIFY_SCF_FDD_POOLING_ENABLE_PDSCH_PUSCH = param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_FDD_POOLING_ENABLE, list_cell_id=FDD_CELLS)


MODIFY_SCF_DEFAULT = MODIFY_SCF_BASE + MODIFY_SCF_BASE_ALL_CELLS + MODIFY_SCF_BASE_FDD_CELLS \
                     + MODIFY_SCF_BASE_TDD_CELLS + PARAMS_TO_MODIFY_GOLDEN \
                     + MODIFY_SCF_DISABLE_IWK_ALL_CELLS + MODIFY_SCF_DISABLE_IWK_NRBTS + MODIFY_SCF_CAMODE_IND
MODIFY_SCF_DEFAULT_CAMODE_NUM = MODIFY_SCF_BASE + MODIFY_SCF_BASE_ALL_CELLS + MODIFY_SCF_BASE_FDD_CELLS \
                     + MODIFY_SCF_BASE_TDD_CELLS + PARAMS_TO_MODIFY_GOLDEN \
                     + MODIFY_SCF_DISABLE_IWK_ALL_CELLS + MODIFY_SCF_DISABLE_IWK_NRBTS + MODIFY_SCF_CAMODE_NUM \
                     + MODIFY_SCF_FDD_POOLING_ENABLE_PDSCH_PUSCH
