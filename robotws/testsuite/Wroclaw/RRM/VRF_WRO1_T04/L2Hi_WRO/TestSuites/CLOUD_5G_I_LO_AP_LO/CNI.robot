*** Settings ***
Documentation
...   CNI Test cases regression - CRT
...   Topology: CLOUD_5G_I_LO_AP_LO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   Author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-72046/CNI-72046.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-80040/CNI-80040_1CA_UE_Bler.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-87271/CNI-87271_UL_Buffer_Overload_Handling_At_RLC.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-97376/CNI-97376.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-97440/CNI-97440-A1.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-97440/CNI-97440-A2.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-103259/CNI-103259_Ng_Ho.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-103259/CNI-103259_NSA.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-103259/CNI-103259_Sa.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-103259/CNI-103259_Xn_Ho.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-106544/CNI-106544-SR.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure SA VM interfaces
...            AND             Configure NSA VM interfaces

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown     scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

*** Test Cases ***
[1][1.0] CNI-72046_Verify_that_no_Uplane_resources_are_used_before_ues_attach_and_after_ues_detach
    [Setup]    Run Keywords    Enable Vonr and Emergency Call For Gnb
    ...        AND             Modify Config To Emergency Call
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI-72046_Verify_that_no_Uplane_resources_are_used_before_ues_attach_and_after_ues_detach

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Modify Config To Default
    ...           AND             Common Test Teardown     scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

[1][1.0] CNI80040_Proactive_Resenting_Rlc_Pdus_From_Delayed_Ca_Cell_To_Other_Ca_Cell_One_Ca_Ue_With_Bler_For_Delay
    [Setup]    Run Keywords    Update Scf And Ap
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_2CC}

    CNI80040_Proactive_Resenting_Rlc_Pdus_From_Delayed_Ca_Cell_To_Other_Ca_Cell_One_Ca_Ue_With_Bler_For_Delay

    [Teardown]    Run Keywords    Send Configuration ID To Scout
    ...           AND             Update And Put Iphy Xml    input_filepath=${LO_AP_LO_GMC_IPHY_FILE}
    ...           AND             Common Test Teardown       scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

[1][1.0] CNI-87271_UL_Buffer_Overload_By_Filling_Descriptor_Memory
    [Setup]    Run Keywords    Set UL MCS 4
    ...        AND             Reduce Threshold Buffers
    ...        AND             Reset Testline And Wait For Rmods
    ...        AND             Increase RLC AM Values
    ...        AND             Set Counter Group 6
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI-87271_UL_Buffer_Overload_By_Filling_Descriptor_Memory

[1][1.0] CNI-97376-US1_Use_LTE_Leg_During_ENDC_Setup
    [Setup]    Run Keywords    Enable Split F1UX2U
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND             Prepare Msg Delay

    CNI-97376-US1_Use_LTE_Leg_During_ENDC_Setup

[1][1.0] CNI97440_Improve_Ping_Latency_In_Nsa_Calls_UlPrimaryPath_OverLte
    [Setup]    Run Keywords    Activate FlexibleIcmpRouting And X2 Ul Dl
    ...        AND             Modify Config For External Traffic For Ue14 In Nsa Call
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI97440_Improve_Ping_Latency_In_Nsa_Calls_UlPrimaryPath_OverLte

[1][1.0] CNI97440_Improve_Ping_Latency_In_Nsa_Calls_UlPrimaryPath_OverNr
    [Setup]    Run Keywords    Activate FlexibleIcmpRouting And F1 Ul Dl
    ...        AND             Modify Config For External Traffic For Ue14 In Nsa Call
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI97440_Improve_Ping_Latency_In_Nsa_Calls_UlPrimaryPath_OverNr

[1][1.0] CNI-103259_Transfer_Of_Data_Between_Upf_And_Gnb_For_Pdu_Type_0
    [Setup]    Run Keywords    Enable CNI-103259 Pm Counters
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI-103259_Transfer_Of_Data_Between_Upf_And_Gnb_For_Pdu_Type_0

[1][1.0] CNI-103259_Transfer_Of_Data_Between_Menb_And_Sgnb_Pdu_Type_1
    [Setup]    Run Keywords    Enable CNI-103259 Pm Counters
    ...        AND             Set Dldatasplit To X2U
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI-103259_Transfer_Of_Data_Between_Menb_And_Sgnb_Pdu_Type_1

[1][1.0] CNI-103259_Forwarding_Of_Data_During_Ng_Handover_For_Pdu_Type_0
    [Setup]    Run Keywords    Enable CNI-103259 Pm Counters
    ...        AND             Enable Ng Ho
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Common Test Setup    cfg_filepath=testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-103259/config/egate_for_Ng_HO_TDD.cfg

    CNI-103259_Forwarding_Of_Data_During_Ng_Handover_For_Pdu_Type_0

[1][1.0] CNI-103259_Forwarding_Of_Data_Packets_During_Xn_Handover_For_Pdu_Type_0
    [Setup]    Run Keywords    Enable CNI-103259 Pm Counters
    ...        AND             Enable Inter Gnb Ho
    ...        AND             Start Xn And Ng Interfaces For Second Gnb
    ...        AND             Common Test Setup    cfg_filepath=testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CNI-103259/config/egate_for_Xn_HO_TDD.lua

    CNI-103259_Forwarding_Of_Data_Packets_During_Xn_Handover_For_Pdu_Type_0

[1][1.0] CNI-106544-SR
    [Setup]    Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CNI-106544-SR
