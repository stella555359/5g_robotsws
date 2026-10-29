*** Settings ***
Documentation
...   author: Rafal Kaczmarski
...   contact: rafal.kaczmarski@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB007552/resources/test_specific_keywords_CB007552.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB007552/resources/test_specific_keywords_CB007552.py

Force Tags      CA_VRF_WRO2

Suite Setup         Run Keywords
...                 Prepare MCshark
...                 Setup Attenuator

Suite Teardown      Run Keywords
...                 Teardown Attenuator
...                 Clear Admin Logs

*** Variables ***
@{ONE_NODE}               gNB50829
@{MULTI_NODE}             gNB50830      gNB50829
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUDT308/ue_config.yaml
${TL_CONFIG}              /home/ute/testline_configuration/7_16_UTE5GCLOUDT308
${CELL_1_1_ALIAS}         GNB_1_CELL_1
${CELL_1_2_ALIAS}         GNB_1_CELL_2
${CELL_2_1_ALIAS}         GNB_2_CELL_1
${CELL_2_2_ALIAS}         GNB_2_CELL_2
${CELL_2_3_ALIAS}         GNB_2_CELL_3
${UE_1_ATTACH}            f1ap.procedureCode == 5 && nr-rrc.locationAndBandwidth == 24199 and nr-rrc.carrierBandwidth == 189
${UE_4_ATTACH}            f1ap.procedureCode == 5 && nr-rrc.locationAndBandwidth == 31624 and nr-rrc.carrierBandwidth == 162


*** Test Cases ***
[1][1.0] CB007552_5G_11_CB007552-A_IWK3.1.1 - Two or more UEs served with small BWP profiles in the cell simultanously (NSA 3x)
    [Setup]    Common CB007552 Test Setup    UE_3    UE_4
    [1]CB007552_5G_5_CB007552-A_IWK3.1.1_Two_Or_More_UEs_Served_With_Small_BWP_Profile_In_The_Cell_Simultaneously_NSA_3x
    [Teardown]    Teardown    UE_3    UE_4

[1][1.0] CB007552_5G_5_CB007552-A_IWK3.1.2_Two_Or_More_UEs_Served_With_Large_And_Small_BWP_Profile_In_The_Cell_Simultaneously_NSA_3x
    [Setup]    Common CB007552 Test Setup    UE_1    UE_3
    [1]CB007552_5G_5_CB007552-A_IWK3.1.2_Two_Or_More_UEs_Served_With_Large_And_Small_BWP_Profile_In_The_Cell_Simultaneously_NSA_3x
    [Teardown]    Teardown    UE_1    UE_3

[1][1.0] CB007552_5G_7_CB007552-A_IWK2.1.3 - Successful intra-gNB HO (PSCell change) with small BWP
    [Setup]    Common CB007552 Test Setup    UE_3
    [1]CB007552_5G_7_CB007552-A_IWK2.1.3 Successful_Intra-gNB_HO_PSCell_Change_Wth_Small_BWP
    [Teardown]    Teardown    UE_3

[1][1.0] CB007552-F_IWK.1.2 NSA TDD-TDD 2CC CA n41A+n78A (40MHz+90MHz) SCellA + ScellC band combination
    [Setup]    Common CB007552 Test Setup    UE_1
    [1]CB007552-F_IWK.1.1_NSA_TDD-TDD_2CC_CA_n41(2A)_SCellA+ScellC_Band_Combination
    [Teardown]    Teardown    UE_1
