from robot.libraries.BuiltIn import BuiltIn
import NIDD_Modify_data_template as data_template
import testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.Parameters_modify_lib \
    as param_modify_lib

tl = BuiltIn().get_variable_value('${tl}')
vDU_DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
vDU_DN_NRBTS = vDU_DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
VDU_DN_NRDU1 = vDU_DN_NRBTS + '/NRDU-1'

vCU_DN_MRBTS = 'MRBTS-' + str(tl.gnbs[0].cu.instance_id)
vCU_DN_NRBTS = vCU_DN_MRBTS + '/NRBTS-' + str(tl.gnbs[0].cu.global_bts_id)
VCU_DN_NRDU1 = vCU_DN_NRBTS + '/NRDU-1'

# Params defined in init file under commissioning folder
ALL_CELLS = BuiltIn().get_variable_value('${ALL_CELLS}')
F_T_ALLOCATION = BuiltIn().get_variable_value('${F_T_ALLOCATION}')
FDD_CELLS = F_T_ALLOCATION['FDD']
TDD_CELLS = F_T_ALLOCATION['TDD']

# CA Related
# Defined in commissionings/HGZ/${testline_name}/__init_10411__.py
# ${CA_GROUP_MAPPING} is defined at suite level or case level by kw 'Decode CA group mapping and set global variable'
CA_GROUP_MAPPING = BuiltIn().get_variable_value('${CA_GROUP_MAPPING}')
LIST_PCELL_ID = [CA_GROUP_MAPPING['pcell_id']]
LIST_SCELL_ID = CA_GROUP_MAPPING['verify_scell_add_dl']
DU_PCELL_DN = vDU_DN_NRBTS + '/NRCELL-' + str(LIST_PCELL_ID[0])
CU_PCELL_DN = vCU_DN_NRBTS + '/NRCELL-' + str(LIST_PCELL_ID[0])

carrierAggregationSupportList_elements = BuiltIn().get_variable_value('${carrierAggregationSupportList_F_T_UL_DL}')
DL_TO_UL_CONTRIBUTION_RATIO = BuiltIn().get_variable_value('${DL_TO_UL_CONTRIBUTION_RATIO}')

#  For DU SCF part
# CA Related
DU_SCF_DELETE = [dict(
        dist_name=VDU_DN_NRDU1,
        p_name='fr1UlCaPreferred',
        value='ulCaPreferred')] + \
                param_modify_lib.generate_data_based_on_template(
                                data_template=data_template.SCF_PARAM_DELETE_CA_SUPPORT_LIST, dist_name=VDU_DN_NRDU1) +\
                param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_DELETE_NIDD_OPTIONAL_ALL_CELL,
    dist_name=vDU_DN_NRBTS, list_cell_id=ALL_CELLS)
# actHighestEstNrTputBcSel is set to True by default and UL CA exist,
# then fr1UlCaPreferred better to config to ulCaPreferred
DU_SCF_ADD = [
    dict(
        dist_name=VDU_DN_NRDU1,
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList_elements),
    dict(
        dist_name=VDU_DN_NRDU1,
        p_name='fr1UlCaPreferred',
        value='ulCaPreferred')
] + param_modify_lib.generate_data_based_on_template(
                                data_template=data_template.DU_SCF_PARAM_ADD_ULCA_RLC,
                                du_nrbts_dist_name=vDU_DN_NRBTS) +\
             param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_PARAM_ADD_8311_OPTIONAL_NIDD_ALL,
    dist_name=vDU_DN_NRBTS, list_cell_id=ALL_CELLS)

DU_SCF_MODIFY = param_modify_lib.generate_data_based_on_template(
    data_template=data_template.DU_SCF_MODIFY_COUNTER_NIDD,
    du_mrbts_distname=vDU_DN_MRBTS,
    du_nrbts_dist_name=vDU_DN_NRBTS) +\
                param_modify_lib.generate_data_based_on_template(
    data_template=data_template.DU_SCF_MODIFY_IWK_CA_Pooling_NIDD,
    du_nrbts_dn=vDU_DN_NRBTS, du_nrdu_dn=VDU_DN_NRDU1, dl_to_ul_ratio_value=DL_TO_UL_CONTRIBUTION_RATIO) +\
                param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.SCF_MODIFY_TEMPLATE_PARAMETERS_EXIST_ON_CU_DU_ALL_CELLS,
    dist_name=vDU_DN_NRBTS, list_cell_id=ALL_CELLS) +\
                param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_MODIFY_TEMPLATE_BASE_ALL_CELLS,
    dist_name=vDU_DN_NRBTS, list_cell_id=ALL_CELLS) +\
                param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_MODIFY_CELL_FDD_PARAMETERS,
    dist_name=vDU_DN_NRBTS, list_cell_id=FDD_CELLS) +\
                param_modify_lib.get_parameter_list_for_update_for_cells(
    data_template=data_template.DU_SCF_MODIFY_CELL_TDD_PARAMETERS,
    dist_name=vDU_DN_NRBTS, list_cell_id=TDD_CELLS) +\
                param_modify_lib.generate_data_based_on_template(
    data_template=data_template.DU_SCF_MODIFY_GRACEFUL_SHUTDOWN,
    dist_name=vDU_DN_NRBTS) +\
                param_modify_lib.generate_data_based_on_template(
    data_template=data_template.DU_SCF_MODIFY_COUNTER_NIDD_9267,
    dist_name=vDU_DN_NRBTS)

# For CU SCF part
CU_SCF_DELETE = param_modify_lib.generate_data_based_on_template(
            data_template=data_template.SCF_PARAM_DELETE_CA_SUPPORT_LIST, dist_name=VCU_DN_NRDU1) +\
                param_modify_lib.get_parameter_list_for_update_for_cells(
            data_template=data_template.CU_SCF_DELETE_MAX_NUM_SCELLS_DL,
            dist_name=vCU_DN_NRBTS, list_cell_id=ALL_CELLS)
CU_SCF_ADD = [
    dict(
        dist_name=VCU_DN_NRDU1,
        list_name='carrierAggregationSupportList',
        elements=carrierAggregationSupportList_elements),
] + param_modify_lib.get_parameter_list_for_update_for_cells(
                    data_template=data_template.CU_SCF_ADD_FOR_MAX_SCELL_NUM,
                    dist_name=vCU_DN_NRBTS, list_cell_id=ALL_CELLS)

CU_SCF_MODIFY = param_modify_lib.generate_data_based_on_template(
                    data_template=data_template.CU_SCF_MODIFY_CA_Mandatory_PARAMETERS,
                    cu_nrdu_dn=VCU_DN_NRDU1, dl_to_ul_ratio_value=DL_TO_UL_CONTRIBUTION_RATIO,
                    cu_nrbts_dn=vCU_DN_NRBTS, pcell_dn=CU_PCELL_DN) +\
                 param_modify_lib.generate_data_based_on_template(
                     data_template=data_template.CU_SCF_MODIFY_COUNTER_NIDD,
                     cu_mrbts_distname=vCU_DN_MRBTS,  cu_nrbts_dist_name=vCU_DN_NRBTS) +\
                 param_modify_lib.generate_data_based_on_template(
                     data_template=data_template.CU_MODIFY_SCF_DISABLE_CIPHER,
                     cu_nrbts_dist_name=vCU_DN_NRBTS) +\
                 param_modify_lib.generate_data_based_on_template(
                      data_template=data_template.CU_MODIFY_SCF_NRBTS_NIDD_IWK, cu_nrbts_dist_name=vCU_DN_NRBTS) +\
                 param_modify_lib.get_parameter_list_for_update_for_cells(
                     data_template=data_template.SCF_MODIFY_TEMPLATE_PARAMETERS_EXIST_ON_CU_DU_ALL_CELLS,
                     dist_name=vCU_DN_NRBTS, list_cell_id=ALL_CELLS) + \
                 param_modify_lib.get_parameter_list_for_update_for_cells(
                     data_template=data_template.CU_SCF_MODIFY_TEMPLATE_DEACT_IWK_ALL_CELL,
                     dist_name=vCU_DN_NRBTS, list_cell_id=ALL_CELLS) +\
                 param_modify_lib.generate_data_based_on_template(
                     data_template=data_template.CU_SCF_MODIFY_COUNTER_NIDD_9267,
                     cu_nrbts_dist_name=vCU_DN_NRBTS)
