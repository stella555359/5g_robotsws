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
@{ONE_NODE}               gNB50830
@{MULTI_NODE}             gNB50830      gNB50829
${ABSTRACT_LIB_CONFIG}    /home/ute/testline_configuration/7_16_UTE5GCLOUDT312/ue_config.yaml
${TL_CONFIG}              /home/ute/testline_configuration/7_16_UTE5GCLOUDT312
${CELL_1_1_ALIAS}         GNB_1_CELL_1
${CELL_1_2_ALIAS}         GNB_1_CELL_2
${CELL_2_1_ALIAS}         GNB_2_CELL_1
${CELL_2_2_ALIAS}         GNB_2_CELL_2
${CELL_2_3_ALIAS}         GNB_2_CELL_3
${remote_mplane_ip}       10.44.224.20

${UE_1_ATTACH_1}            f1ap.procedureCode == 12 && nr-rrc.firstActiveDownlinkBWP_Id == 0
${UE_1_ATTACH_2}            f1ap.procedureCode == 12 && nr-rrc.firstActiveDownlinkBWP_Id == 1 && nas-5gs
${UE_1_ATTACH_3}            f1ap.procedureCode == 5 && nr-rrc.locationAndBandwidth == 24199
${UE_2_ATTACH_3}            f1ap.procedureCode == 5 && nr-rrc.locationAndBandwidth == 36300
${UE_1_ATTACH_CA}           f1ap.procedureCode == 5 && nr-rrc.locationAndBandwidth == 16499


*** Test Cases ***
[1][1.0] CB007552_5G_7_CB007552-B_IWK.6.1.1 Successful Intra-frequency Intra-DU Intra-gNB handover
    [Setup]    Common CB007552 Test Setup    UE_2
    [1]CB007552_5G_7_CB007552-B_IWK.6.1.1_Successful_Intra-frequency_Intra-DU_Intra-gNB_Handover
    [Teardown]    Teardown    UE_2

[1][1.0] CB007552_5G_13_CB007552-B_IWK.8.2.1 Successful Inter-frequency Inter-gNB handover
    [Setup]    Common CB007552 Test Setup    UE_2
    [1]CB007552_5G_13_CB007552-B_IWK.8.2.1_Successful_Inter-Frequency_Inter-gNB_handover
    [Teardown]    Teardown    UE_2

[1][1.0] CB007552_5G_5_CB007552-B_B.5.1 Two or more UEs served with large and small BWP profiles in the cell simultanously
    [Setup]    Common CB007552 Test Setup    UE_1    UE_2
    [1]CB007552_5G_5_CB007552-BB.5.1_Two_Or_More_UEs_Served_With_Large_And_Small_BWP_Profiles_In_The_Cell_Simultanously
    [Teardown]    Teardown    UE_1    UE_2

[1][1.0] CB007552-F_IWK.1.4 SA TDD-TDD 2CC CA n78C (20MHz+100MHz) SCellA + ScellC band combination
    [Setup]    Common CB007552 Test Setup    UE_1
    [1]CB007552_F_IWK.1.4_SA_TDD-TDD_2CC_CA_n78C_20MHz+100MHz_SCellA_+_ScellC_Band_Combination_Adjusted_For_n41C_80MHz+100MHz
    [Teardown]    Teardown    UE_1

[1]CNI_78446_B_2_SA intra-gNB Handover after inital RRC Setup with dedicated config in initialDownlinkBWP to small BWP
    [Setup]    Common CB007552 Test Setup    UE_2
    [1]CNI_78446_B_2_SA_Intra-gNB_Handover_After_Inital_RRC_Setup_With_Dedicated_Config_In_InitialDownlinkBWP_To_Small_BWP
    [Teardown]    Teardown    UE_2

[1]CNI_78446_A_1_SA Inital RRC Setup with dedicated config in initialDownlinkBWP with large BWP
    [Setup]    Common CB007552 Test Setup    UE_1
    [1]CNI_78446_A_1_SA_Inital_RRC_Setup_With_Dedicated_Config_In_InitialDownlinkBWP_With_Large_BWP
    [Teardown]    Teardown    UE_1

[1]CNI_78446_B_5_2CC CA - scell setup after inital RRC Setup with dedicated config in initialDownlinkBWP to large BWP
    [Setup]    Common CB007552 Test Setup    UE_1
    [1]CNI_78446_B_5_2CC_CA-Scell_Setup_After_Inital_RRC_Setup_With_Dedicated_Config_In_InitialDownlinkBWP_To_Large_BWP
    [Teardown]    Teardown    UE_1
