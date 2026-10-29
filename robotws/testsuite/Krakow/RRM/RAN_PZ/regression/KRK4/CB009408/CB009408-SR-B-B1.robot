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
${GNB_ID}=  ${tl.gnbs[0].global_bts_id}
${attached_nr_cell_id}=  1263124591
${attached_lte_global_cell_id}=  115
${attached_eutran_cell_id}=  19736435
@{attenuation_values}=  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}  ${20}

*** Test Cases ***
CB009408-SR-B-B1_US03_Automatic_update_of_the_LNADJGNB_instance--change_of_the_X2_C-Plane_IP_of_the_neighbour_gNB
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms
    ${default_cplane_distanme} =  get_x2cplane_distname
    verify_internal_neighbouring_gnb_object
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    modify_x2cplane_addr  distname=MRBTS-${GNB_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-1
    verify_internal_neighbouring_gnb_object  wait_for_x2_availability=${True}
    perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    [Teardown]   Run Keywords
    ...       modify_x2cplane_addr  distname=${default_cplane_distanme}  AND
    ...       gnb_cells.wait_for_all_cells_to_be_onair  timeout=${600}  AND
    ...       Common Postconditions With Watching Alarms

CB009408-SR-B-B1_US12_An_enbControlled_LNADJGNB_instance_with_conflicting_parameter_Case1
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms  AND
    ...       disable_feature_flag_and_verify_lte_cells_setup
    create_custom_neighbouring_gnb_object  lnadjgnb_id=0  gnb_id=77094  cplane_ctrl=enbControlled
    ...                                    cplane_addr=internal  mcc=244  mnc=8  mnc_length=2
    create_custom_lte_neighbour_relation_to_cell  lnrelgnbcell_id=0  lncell_id=${attached_lte_global_cell_id}
    ...                                           nr_cell_id=1263108207  mcc=244  mnc=8  mnc_length=2
    enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    verify_if_lte_neighbor_relation_to_cell_not_exist  lnrelgnbcell_id=0
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    [Teardown]   Common Postconditions With Watching Alarms

CB009408-SR-B-B1_US12_An_enbControlled_LNADJGNB_instance_with_conflicting_parameter_Case2
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms  AND
    ...       disable_feature_flag_and_verify_lte_cells_setup
    create_custom_neighbouring_gnb_object  lnadjgnb_id=0  gnb_id=${GNB_ID}  cplane_ctrl=enbControlled
    ...  cplane_addr=1.1.1.5  plmn=internal  gnb_id_length=internal
    create_custom_lte_neighbour_relation_to_cell  lnrelgnbcell_id=0  lncell_id=${attached_lte_global_cell_id}
    ...  nr_cell_id=${attached_nr_cell_id}  plmn=internal  gnb_id_length=internal
    enable_feature_flag_and_check_automatic_neighbouring_gnb_addition
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    [Teardown]   Common Postconditions With Watching Alarms

CB009408-SR-B-B1_US04_Automatic_update_of_the_LNADJGNB_instance--change_of_PLMN_ID_and_or_gNB_ID_of_the_neighbour_gNB
    [Setup]   Run Keywords
    ...       clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup  AND
    ...       Common Preconditions With Watching Alarms
    modify_plmn_and_check_automatic_neighbouring_gnb_addition  mcc=244  mnc=8  mnc_length=2
    modify_plmn_and_check_automatic_neighbouring_gnb_addition  mcc=1  mnc=1  mnc_length=2
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    modify_gnb_id_length_and_check_automatic_neighbouring_gnb_addition  gnb_id_length=23
    modify_gnb_id_length_and_check_automatic_neighbouring_gnb_addition  gnb_id_length=22
    Wait Until Keyword Succeeds  5x  10 sec  perform_ue_attach_and_verify_lte_neighbor_relation_to_cells
    ...  cell_type=LTE  cell_id=${attached_eutran_cell_id}  check_endc_call=${True}
    [Teardown]   Common Postconditions With Watching Alarms
