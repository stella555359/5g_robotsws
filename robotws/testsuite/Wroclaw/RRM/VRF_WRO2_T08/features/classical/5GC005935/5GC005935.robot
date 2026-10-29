*** Settings ***
Documentation
...   maintainer: Tomasz Sobania
...   contact: tomasz.sobania@nokia.com
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC005935/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup    CB005935 Suite Setup

Suite Teardown    Testsuite Teardown Recommissioning

*** Variables ***
${ABSTRACT_LIB_CONFIG}      /home/ute/testline_configuration/7_16_UTE5GCLOUDT192/ue_config.yaml
${CELL_190}                 GNB_1_CELL_190
${CELL_196}                 GNB_1_CELL_196
${CELL_193}                 GNB_1_CELL_193
${CELL_197}                 GNB_1_CELL_197
${CELL_999}                 GNB_1_CELL_999
${UE_ALIAS}                 UE_1

*** Test Cases ***
[1]USCB005935_AA_B4_TC01_Single_UE_call_buffer_based_SCell_activation_deactivation
    [Setup]    AA_B4 Setup
    USCB005935_AA_B4_TC01_Single_UE_call_buffer_based_SCell_activation_deactivation
    [Teardown]    AA_B4 Teardown

[1]USCB005935_AB_B6_TC02_Alternative_A6_based_SCell_swap_supports_for_UE_with_FDD_FR1_FDD_ULCA
    [Setup]    AB_B6 Setup
    USCB005935_AB_B6_TC02_Alternative_A6_based_SCell_swap_supports_for_UE_with_FDD_FR1_FDD_ULCA
    [Teardown]    AB_B6 Teardown

[1]USCB005935_AB_B8_TC03_Full_mobility_support_for_UE_with_FDD_FR1_FDD_UL_CA_configured
    [Setup]    AB_B8 Setup
    USCB005935_AB_B8_TC03_Full_mobility_support_for_UE_with_FDD_FR1_FDD_UL_CA_configured
    [Teardown]    AB_B8 Teardown

[1]CB005935_BD_B1_Interworking_with_CB008124_UL_Resource_Reservation_and_Scheduling_by_Configured_Grants_Type_2
    [Setup]    BD_B1 Setup
    CB005935_BD_B1_Interworking_with_CB008124_UL_Resource_Reservation_and_Scheduling_by_Configured_Grants_Type_2
    [Teardown]    BD_B1 Teardown
