*** Settings ***
Documentation
...   author: Rafal Kawa
...   contact: rafal.kawa@nokia.com
...   desctiption: CRT test suite of CB009408 Feature

Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Library     ./resources/CustomKeywords.py
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       Run Keywords
...               upload_custom_swconfig  path=${CURDIR}/resources/swconfig.txt  AND
...               Common Suite Setup With Commissioning  asir_hub=${True}  AND
...               gnb_cells.wait_for_all_cells_to_be_onair  cell_type=lte  timeout=${600}  AND
...               set_attenuation  attenuation_values=${attenuation_values}
Suite Teardown    Common Suite Teardown

*** Variables ***
${attached_nr_cell_id}=  1263124591
${attached_lte_global_cell_id}=  115
${attached_eutran_cell_id}=  19736435
@{attenuation_values}=  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}

*** Test Cases ***
CB009408-SR-A-B3_US09_Deactivation_of_CB009408_and_autonomous_removal_of_neighbor_relations_is_NOT_allowed_CB007334_on
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       set_cb007334_feature_flag  operation=enable  AND
    ...       Common Preconditions With Watching Alarms
    verify_internal_neighbouring_gnb_object
    create_custom_lte_neighbour_relation_to_cell  lnrelgnbcell_id=0  lncell_id=${attached_lte_global_cell_id}
    ...  nr_cell_id=${attached_nr_cell_id}  plmn=internal  gnb_id_length=internal
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    set_cb009408_feature_flag  operation=disable
    remove_lte_neighbor_relation_to_cells
    verify_internal_neighbouring_gnb_object
    gnb_cells.verify_all_cells_are_onair  cell_type=all
    [Teardown]   Common Postconditions With Watching Alarms

CB009408-SR-A-B3_US09_Deactivation_of_CB009408_and_autonomous_removal_of_neighbor_relations_is_NOT_allowed_CB007334_off
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       set_cb007334_feature_flag  operation=disable  AND
    ...       Common Preconditions With Watching Alarms
    verify_internal_neighbouring_gnb_object
    create_custom_lte_neighbour_relation_to_cell  lnrelgnbcell_id=0  lncell_id=${attached_lte_global_cell_id}
    ...  nr_cell_id=${attached_nr_cell_id}  plmn=internal  gnb_id_length=internal
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    set_cb009408_feature_flag  operation=disable
    remove_lte_neighbor_relation_to_cells
    verify_internal_neighbouring_gnb_object
    gnb_cells.verify_all_cells_are_onair  cell_type=all
    [Teardown]   Run Keywords
    ...       set_cb007334_feature_flag  operation=enable  AND
    ...       Common Postconditions With Watching Alarms
