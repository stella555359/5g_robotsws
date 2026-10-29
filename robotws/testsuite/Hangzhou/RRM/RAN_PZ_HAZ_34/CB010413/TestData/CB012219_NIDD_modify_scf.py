from robot.libraries.BuiltIn import BuiltIn
from NIDD_modify_scf import *
import NIDD_Modify_data_template as data_template
import CB012219_NIDD_data_template as CA_data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

# # CA related variables
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
SUPERCELLS = BuiltIn().get_variable_value('${SUPERCELLS}')
CA_GROUP_MAPPING = BuiltIn().get_variable_value('${CA_GROUP_COMMON}')
LIST_PCELL_ID = [CA_GROUP_MAPPING['pcell_id']]
LIST_PCELL_RMOD = CA_GROUP_MAPPING['pcell_ru_list']
LIST_SCELL_ID = CA_GROUP_MAPPING['verify_scell_add_dl']
LIST_SCELL_RMOD = CA_GROUP_MAPPING['scell_ru_list']
DU_PCELL_DN = vDU_DN_NRBTS + '/NRCELL-' + str(LIST_PCELL_ID[0])
CU_PCELL_DN = vCU_DN_NRBTS + '/NRCELL-' + str(LIST_PCELL_ID[0])
carrierAggregationSupportList = ['ca_Fr1Tdd_Sa', 'ca_Fr1Tdd_Nsa']


# # CU related variables
CU_SCF_DELETE_CA = [
    dict(
        dist_name=VCU_DN_NRDU1,
        list_name='carrierAggregationSupportList')
]

CU_SCF_MODIFY_CA = CU_SCF_MODIFY + \
    param_modify_lib.generate_data_based_on_template(
        data_template=CA_data_template.CU_SCF_MODIFY_CA_Mandatory_PARAMETERS,
        cu_nrdu_dist_name=VCU_DN_NRDU1, cu_nrbts_dist_name=vCU_DN_NRBTS) + \
    param_modify_lib.generate_data_based_on_template(
        data_template=CA_data_template.CU_MODIFY_SCF_NRBTS_IWK,
        cu_nrbts_dist_name=vCU_DN_NRBTS) + \
    param_modify_lib.get_parameter_list_for_update_for_cells(
        data_template=CA_data_template.CU_MODIFY_SCF_ALL_CELLS,
        dist_name=vCU_DN_NRBTS, list_cell_id=SUPERCELLS)

CU_SCF_ADD_CA = [
    dict(
        dist_name=VCU_DN_NRDU1,
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList)]


# # DU related
DU_SCF_DELETE_CA = [
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1'),
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2'),
]

DU_SCF_ADD_CHANNEL_PCELL = param_modify_lib.generate_parameters_for_channel_group_and_channels_for_scf_modify(
    lcr_id=LIST_PCELL_ID[0],
    list_ru_id=LIST_PCELL_RMOD,
    number_of_tx_channel=4,
    number_of_rx_channel=4
)

DU_SCF_ADD_CHANNEL_SCELL = param_modify_lib.generate_parameters_for_channel_group_and_channels_for_scf_modify(
    lcr_id=LIST_SCELL_ID[0],
    list_ru_id=LIST_SCELL_RMOD[0],
    number_of_tx_channel=4,
    number_of_rx_channel=4
)

DU_SCF_ADD_CA = DU_SCF_ADD_CHANNEL_PCELL + DU_SCF_ADD_CHANNEL_SCELL

DU_SCF_MODIFY_ALL_CELLS_CA = (param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_MODIFY_CELL, list_cell_id=SUPERCELLS, dist_name=vDU_DN_NRBTS) +
                              param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=CA_data_template.DU_MODIFY_SCF_CELL, list_cell_id=SUPERCELLS, dist_name=vDU_DN_NRBTS))

DU_SCF_MODIFY_CA = ([
    dict(
        dist_name=vDU_DN_NRBTS,
        p_name='actBbPoolTddFr1',
        value='true'),
    dict(
        dist_name=vDU_DN_NRBTS,
        p_name='actBbPoolTddFr1AlgEnh',
        value='true'),
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/AMGR-1/LUAC-1',
        p_name='jwtExpirationTime',
        value='60'),
    dict(
        dist_name=vDU_DN_MRBTS + '/MNL-1/MNLENT-1/PMCADM-1',
        p_name='reportingIntervalPm',
        value='5min'),
    dict(
        dist_name=vDU_DN_NRBTS + '/NRPMRNL-1',
        p_name='miNrBeamforming',
        value='5min')
] + (param_modify_lib.generate_data_based_on_template(
    data_template=CA_data_template.DU_MODIFY_SCF_NRBTS_IWK,
    du_nrdu_dist_name=VDU_DN_NRDU1, du_nrbts_dist_name=vDU_DN_NRBTS) +
    DU_SCF_MODIFY_ALL_CELLS_CA))
