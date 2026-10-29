*** Settings ***
Documentation
...   Test cases regression - CRT
...   Topology: CLOUD_5GC_dRNIC_1vDU_P_AP_LOO_DC
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords_vran.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords_vran.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables_vran.py
Library      testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator_vran.py

Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001465_Cloud/5GC001465-A_Cloud.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354_Cloud/5GC001354-C-B1-High-Tput-Cloud.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008159_Additional_PM_Counter_Cloud/CB008159-C-3_Cloud.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008159_Additional_PM_Counter_Cloud/CB008159-C-4_Cloud.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008828_Cloud/CB008828_Counters_From_8204_Cloud.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206_vRAN/CB013206-B-B1_Norm_Menb_Insession_Release.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206_vRAN/CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206_vRAN/CB013206-C_Abnormal_Initiated_By_SgNB_PMQAP.robot

Suite Setup    Run Keywords    Enable Cloud
...            AND             Configure SA VM interfaces AiC

Test Teardown    Common Rinline Test Teardown

*** Test Cases ***
[1][1.0] 5GC001465-A 30Mhz_TC30-3_cell bandwidth for cmWave Cell_setup With LA NSA call OK Heavy Traffic UL_DL n78
    [Setup]      Run Keywords      Enable AiC 1465 Delta
    ...          AND               Common Rinline Test Setup

    5GC001465-A 30Mhz_TC30-3_cell bandwidth for cmWave Cell_setup With LA NSA call OK Heavy Traffic UL_DL n78

[1][1.0] 5GC001465-A 30Mhz_TC30-4_cell bandwidth for cmWave Cell_setup With LA NSA call OK Traffic UL_DL 2mbps 30mn n78
    [Setup]      Run Keywords      Enable AiC 1465 Delta
    ...          AND               Common Rinline Test Setup

    5GC001465-A 30Mhz_TC30-4_cell bandwidth for cmWave Cell_setup With LA NSA call OK Traffic UL_DL 2mbps 30mn n78

[1][1.0] 5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_High_Tput_Cloud
    [Setup]      Run Keywords      Enable AiC X2 And F1 Measurements
    ...          AND               Enable AiC 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...          AND               Common Rinline Test Setup

    5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_High_Tput_Cloud

[1][1.0] CB008159-C-3_Continuous_And_Bursty_Qos_Flow_Traffic_In_Both_Directions_Cloud
    [Setup]      Run Keywords      Enable AiC Vonr And Rohc
    ...          AND               Send 8159-C-3 Delta Commissioning
    ...          AND               Common Rinline Test Setup

    CB008159-C-3_Continuous_And_Bursty_Qos_Flow_Traffic_In_Both_Directions_Cloud

[1][1.0] CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated
    [Setup]      Run Keywords      Enable AiC Vonr And Rohc
    ...          AND               Send 8159-C-3 Delta Commissioning
    ...          AND               Common Rinline Test Setup

    CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated

[1][1.0] CB008828_Counters_From_CB008204_Should_Be_Incremented_Cloud
    [Setup]      Run Keywords      Enable miNrNGCC
    ...          AND               Enable 25 Snssai and Slicing
    ...          AND               Common Rinline Test Setup

    CB008828_Counters_From_CB008204_Should_Be_Incremented_Cloud

[1][1.0] CB013206-B-B1_Norm_Menb_Insession_Release_Cloud
    [Setup]      Run Keywords      Enable AiC A3 Measurements
    ...          AND               Enable AiC NSA Mobility
    ...          AND               Enable In Session Counters And Set Pmqap Profiles
    ...          AND               Common Rinline Test Setup

    CB013206-B-B1_Norm_Menb_Insession_Release_Cloud

[1][1.0] CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap_Cloud
    [Setup]      Run Keywords      Enable In Session Counters And Set Pmqap Profiles
    ...          AND               Common Rinline Test Setup

    CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap_Cloud

[1][1.0] CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap_Cloud
    [Setup]      Run Keywords      Set X2datafwdguard To 10
    ...          AND               Enable Minrx2ccnrpmqap
    ...          AND               Enable Counters And Profiles
    ...          AND               Common Rinline Test Setup

    CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap_Cloud
