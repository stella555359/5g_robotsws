*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource    ./resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Force Tags      CA_VRF_WRO2

Suite Setup         Activate CB009010 Feature For Both GNBs
Test Teardown       Teardown

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
${TL_CONFIG}             /home/ute/testline_configuration/7_16_UTE5GCLOUDT302
${CELL_1_ALIAS}          GNB_1_CELL_1
${CELL_2_ALIAS}          GNB_1_CELL_2
${CELL_3_ALIAS}          GNB_2_CELL_1
${CELL_4_ALIAS}          GNB_2_CELL_2

*** Test Cases ***
[1][1.0] CB009010_A_TC01_Feature_Activation_Deactivation_and_SIB1_transmission_with_cellReservedForOperatorUse_2PLMNs
    [Setup]    Test Setup    ELT=${TRUE}    ACTIVATE_FEATURE=${TRUE}
    TC01_Feature_Activation_Deactivation_and_SIB1_transmission_with_cellReservedForOperatorUse_2PLMNs

[1][1.0] CB009010_A_TC05_Intra-Freq_NSA_ANR_reportCGI_reception_and_populating_ADJ_NRPLMNSET_NSA_for_inter-gNB_neighbors
    [Setup]    Test Setup    ELT=${TRUE}
    TC05_Intra-Freq_NSA_ANR_reportCGI_reception_and_populating_ADJ_NRPLMNSET_NSA_for_inter-gNB_neighbors

[1][1.0] CB009010_A_TC07_Handover_restriction_on_the_source_when_UE_using_PLMN_that_is_reserved_on_the_Target_cell_ADJ_NRPLMNSET_NSA
    [Setup]    Test Setup    ELT=${TRUE}
    TC07_Handover_restriction_on_the_source_when_UE_using_PLMN_that_is_reserved_on_the_Target_cell_ADJ_NRPLMNSET_NSA

[1][1.0] CB009010_A_TC09_Handover_restriction_on_the_Target_for_UEs_using_PLMN_that_is_reserved_on_the_Target_cell_NRPLMNSET_NSA
    [Setup]    Test Setup    ELT=${TRUE}    DELETE_NRPLMNSET=${TRUE}    CREATE_NRPLMNSET=${TRUE}
    TC09_Handover_restriction_on_the_Target_for_UEs_using_PLMN_that_is_reserved_on_the_Target_cell_NRPLMNSET_NSA

[1][1.0] CB009010_A_TC13_Inter-Freq_NSA_ANR_ADJ_NRPLMNSET_NSA_update_during_re-check_2PLMNs
    [Setup]    Test Setup    ELT=${TRUE}    CREATE_TARGET_NRPLMNSET=${TRUE}
    TC13_Intra-Freq_NSA_ANR_reportCGI_reception_and_populating_ADJ_NRPLMNSET_NSA_for_inter-gNB_neighbors

[1][1.0] CB009010_A_TC06_Access_restriction_for_UE_for_reserved_PLMN_and_handover_restrictions_ADJ_NRPLMNSET_NSA
    [Setup]    Test Setup    ELT=${TRUE}    UPLOAD_SCF=${TRUE}
    TC06_Access_restriction_for_UE_for_reserved_PLMN_and_handover_restrictions_ADJ_NRPLMNSET_NSA
