from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
Cell_ALLOCATION = BuiltIn().get_variable_value('${Cell_ALLOCATION}')
TDD_CELLS = Cell_ALLOCATION['TDD']

carrierAggregationSupportList_T_T = BuiltIn().get_variable_value('${carrierAggregationSupportList_T_T}')
# Defined in common_setup_teardown.robot
SCF_DEFAULT_FILE_PATH = BuiltIn().get_variable_value('${SCF_DEFAULT_FILE_PATH}')
# Defined in TLDelta.py
PARAMS_TO_ADD_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_ADD_GOLDEN}')
PARAMS_TO_ADD_GOLDEN = [] if PARAMS_TO_ADD_GOLDEN is None else PARAMS_TO_ADD_GOLDEN
PARAMS_TO_MODIFY_GOLDEN = BuiltIn().get_variable_value('${PARAMS_TO_MODIFY_GOLDEN}')
PARAMS_TO_MODIFY_GOLDEN = [] if PARAMS_TO_MODIFY_GOLDEN is None else PARAMS_TO_MODIFY_GOLDEN

DELETE_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList')
]

ADD_SCF_CA_SUPPORT_LIST = [
    dict(
        dist_name=param_modify_lib.DN_NRDU1,
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList_T_T),
]

# Modify parameters for multiple cells
DELETE_SCF_DEFAULT = DELETE_SCF_CA_SUPPORT_LIST

ADD_SCF_DEFAULT = ADD_SCF_CA_SUPPORT_LIST + PARAMS_TO_ADD_GOLDEN + PARAMS_TO_ADD_GOLDEN

# Modify ca parameters
MODIFY_SCF_CA_BASE = [
    dict(
        value='ConfigurationIndependent',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='flexibleCAMode'),
    dict(
        value='true',
        dist_name=param_modify_lib.DN_NRDU1,
        p_name='actInterNumerologyCa')
]

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
        p_name='miNrBeamforming')
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

MODIFY_SCF_COMMON_DEFAULT = MODIFY_SCF_COUNTER_RP_INT + MODIFY_SCF_DISABLE_CIPHER + PARAMS_TO_MODIFY_GOLDEN

MODIFY_SCF_CA_DEFAULT = MODIFY_SCF_CA_BASE + MODIFY_SCF_COMMON_DEFAULT

GNB_INFO = param_modify_lib.get_bts_info_from_scf_file(local_scf_file_path=SCF_DEFAULT_FILE_PATH)
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)

# Prepare for 6xSubcell
TL_PARAMS_TO_DELETE_Second_Cell = [
    # NRCELL
    dict(dist_name=param_modify_lib.DN_NRBTS + '/NRCELL-2'),
    # cellmapping
    dict(dist_name=param_modify_lib.DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
    # nrcell group
    dict(dist_name=param_modify_lib.DN_NRBTS + '/NRCELLGRP-2'),
    # refNrCellGroup
    dict(dist_name=param_modify_lib.DN_NRBTS + '/NRDU-1', list_name='refNrCellGroup', index='-1'),
    dict(dist_name=param_modify_lib.DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1')
]

ALL_RMODS = BuiltIn().get_variable_value('${ALL_RMODS}')
# 4DL 4UL
DU_SCF_ADD_6xSubcell = param_modify_lib.generate_parameters_for_channel_group_and_channels_for_scf_modify(
    lcr_id=1,
    list_ru_id=ALL_RMODS,
    number_of_tx_channel=4,
    number_of_rx_channel=4
)
