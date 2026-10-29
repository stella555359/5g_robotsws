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
${attached_eutran_cell_id}=  19736435
@{additional_allowed_alarms}=  ${EMPTY}
@{attenuation_values}=  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}

*** Test Cases ***
CB009408-SR-A-B2_US01_feature_activation_for_SA_deployment
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms  AND
    ...       load_nr_cell_configuration  cell_type=SA  AND
    ...       disable_feature_flag_and_verify_lte_cells_setup  AND
    ...       verify_if_internal_neighbouring_gnb_object_not_exist
    perform_attach_procedure  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${False}
    enable_feature_flag_and_check_if_automatic_neighbouring_gnb_addition_not_triggered
    perform_attach_procedure  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${False}
    set_cb009408_feature_flag  operation=disable
    perform_attach_procedure  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${False}
    [Teardown]   Run Keywords
    ...       load_nr_cell_configuration  cell_type=SA+NSA  AND
    ...       Common Postconditions With Watching Alarms

CB009408-SR-A-B2_US07_No_automatic_creation_of_the_LNADJGNB--due_to_exceeding_the_maximum_number_of_allowed_neighbors
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Append To List  ${additional_allowed_alarms}  Setup of X2 connectivity to gNB failed  AND
    ...       Common Preconditions With Watching Alarms  AND
    ...       disable_feature_flag_and_verify_lte_cells_setup
    load_neighbouring_gnbs_objects  number_of_objects=32
    enable_feature_flag_and_catch_fault_5518_5515
    remove_neighbouring_gnb_object  neighbour_id=31
    disable_and_enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    disable_feature_flag_and_verify_lte_cells_setup
    load_neighbouring_gnbs_objects  number_of_objects=128
    enable_feature_flag_and_catch_fault_5518_5515
    remove_neighbouring_gnb_object  neighbour_id=127
    disable_and_enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    [Teardown]   Common Postconditions With Watching Alarms

CB009408-SR-A-B2_REQ03_Automatic_creation_of_the_LNADJGNB_representing_the_neighbor_gNB--gNB_in_ANR-glNbGnbIdBlackList
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms  AND
    ...       disable_feature_flag_and_verify_lte_cells_setup
    verify_if_internal_neighbouring_gnb_object_not_exist
    update_gnb_black_list_in_anr  operation=add_internal_gnb
    enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    perform_attach_procedure  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${False}
    Repeat Keyword   3x   Verify 5G NSA UE Attach Failure
    Run Keyword And Expect Error  NotFoundLteNeighborRelationException:*
    ...  check_if_internal_nr_cells_exists_in_lte_neighbor_relations
    verify_validation_errors_not_exists
    [Teardown]   Run Keywords
    ...       update_gnb_black_list_in_anr  operation=remove_internal_gnb  AND
    ...       Common Postconditions With Watching Alarms

CB009408-SR-A-B2_US01_Automatic_creation_of_the_LNADJGNB_representing_the_neighbor_gNB_in_SBTS_NSA--feature_activation
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms  AND
    ...       disable_feature_flag_and_verify_lte_cells_setup
    verify_if_internal_neighbouring_gnb_object_not_exist
    perform_attach_procedure  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${False}
    enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    verify validation errors not exists
    [Teardown]   Common Postconditions With Watching Alarms

CB009408-SR-A-B2_US05_No_automatic_creation_of_the_LNADJGNB_instance--after_it_was_removed_by_the_operator
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms
    verify_internal_neighbouring_gnb_object
    remove_all_neighbouring_gnb_and_check_fault_5518_activation
    disable_and_enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    remove_all_neighbouring_gnb_and_check_fault_5518_activation
    restart_bts_and_check_automatic_neighbouring_gnb_addition
    remove_all_neighbouring_gnb_and_check_fault_5518_activation
    modify_plmn_and_check_automatic_neighbouring_gnb_addition
    [Teardown]   Run Keywords
    ...       modify_public_land_mobile_network  AND
    ...       Common Postconditions With Watching Alarms

*** Keywords ***
Verify 5G NSA UE Attach Failure
    Run Keyword And Expect Error  Ue5gNsaAttachFailedException:*
    ...  perform_attach_procedure  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
