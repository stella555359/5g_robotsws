*** Settings ***
Documentation
...   Test cases regression - CRT
...   Topology: CLOUD_5G_O_H_AP_LOO
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    ../../5GC000774_ROHC/5GC000774-A_B1_Profile_0_ipv4.robot
Resource    ../../5GC000782_Additional_security_algorithms/5GC000782_A/5GC000782_A.robot
Resource    ../../5GC002637_Throughput_counters/5GC002637-A-B1-1_PDCP_and_RLC_throughput_counters_with_SA_UE.robot
Resource    ../../CB006898_PMQAP_profiles_for_NR/CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue.robot
Resource    ../../CB008158_NR_Latency_PM_Counters/CB008158-A_Average_DL_Air-Interface_delay_for_AM_RLC.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-4_Continuous_And_Bursty_Qos_Flow_In_Session_With_Pmqap_Profiles_Activated.robot
Resource    ../../CB009324_Traffic_shaping_at_gNB_L2_with_DL_data_over_X2-U/CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte.robot
Resource    ../../CB009576_Krk/CB009576-H-autorecovery.robot

Suite Setup      Run Keywords      Enable Syslog Info Level Prints
...              AND               Configure NSA VM interfaces
...              AND               Get Current SCF    dir_path=${CURDIR}   file_name=Default_SCF.xml

Test Teardown    Run Keywords      Send Configuration ID To Scout
...              AND               Common Test Teardown    scf_filepath=${DEFAULT_SCF_FILEPATH}

*** Test Cases ***
[1][1.0] 5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv4_TDD
    [Setup]      Run Keywords      Enable Vonr And Rohc TDD FDD
    ...          AND               Enable Syslog Debug Prints For Rohc
    ...          AND               Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv4_TDD

[1][1.0] 5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Setup]      Run Keywords      Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=true
    ...          AND               Modify Ciphering Algorithms
    ...          AND               Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb

    [Teardown]   Run Keywords      Send Configuration ID To Scout
    ...          AND               Common Test Teardown       scf_filepath=${DEFAULT_SCF_FILEPATH}
    ...          AND               Reset Ciphering Algorithms To Default

[1][1.0] 5GC002637-A-B1-1_PDCP_and_RLC_throughput_counters_with_SA_UE
    [Setup]      Run Keywords      Enable Tput Counters
    ...          AND               Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    5GC002637-A-B1-1_PDCP_and_RLC_throughput_counters_with_SA_UE

[1][1.0] CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue
    [Setup]      Run Keywords      Enable Tput Counters
    ...          AND               Add Qos Group
    ...          AND               Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue

[1][1.0] CB008158-A_2_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_NSA_UE_PMQAP
    [Setup]      Run Keywords      Enable Latency And PMQAP Counters
    ...          AND               Enable Intra Gnb Ho And A3 Meas
    ...          AND               Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...          AND               Prepare Bler Testmode In Dl

    CB008158-A_2_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_NSA_UE_PMQAP

[1][1.0] CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated
    [Setup]      Run Keywords      Enable PM Counters
    ...          AND               Enable PMQAP Counters And Set Profiles
    ...          AND               Enable Vonr
    ...          AND               Enable ActNonVoNRGbrService
    ...          AND               Add Profiles For 5QI
    ...          AND               Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...          AND               Set Internal Traffic Type To UEs
    ...          AND               Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated

[1][1.0] CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_TDD
    [Setup]       Run Keywords     Enable Burst Size Divider
    ...           AND              Enable Traffic Shaping TDD
    ...           AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...           AND              Enable FSTSCH Counters

    CB009324-A-US1_Single_Nsa_Ue_With_Higher_Throughput_Over_Lte_TDD

[1][1.0] CB009576-SR-H-B3_ASOH_11_auto_recovery_upon_Thor_platform_L1_fronthaul_failure
    [Setup]      Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB009576-SR-H-B3_ASOH_11_auto_recovery_upon_Thor_platform_L1_fronthaul_failure