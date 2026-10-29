*** Settings ***
Documentation
...   Test cases regression - CRT
...   Topology: CLOUD_5G_I_MP_AP_LO
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-A-B2_Udp_Low_Tput_Clasical.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC000782_Additional_security_algorithms/5GC000782_A/5GC000782_A.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB006898_PMQAP_profiles_for_NR/CB006898-B2_PDCP_And_RLC_PMQAP_Counters_With_NSA_UE.robot
Resource    ../../CB008158_NR_Latency_PM_Counters/CB008158-A_Percentile_of_Average_DL_Air-Interface_delay_for_AM_RLC.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008159_Additional_PM_Counter/CB008159-C-2_Bursty_Qos_Flow_In_Session.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces
...            AND             Update And Put Iphy Xml    input_filepath=${CURDIR}/config/NSA/Default_IPHY.xml
...            AND             Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${CURDIR}/config/NSA/Default_SCF.xml
...            AND             Wait For GNB Configured State
...            AND             Get Current SCF    dir_path=${CURDIR}/config/NSA    file_name=Modified_SCF.xml

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${DEFAULT_SCF_FILEPATH}

*** Test Cases ***
[1][1.0] 5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Udp_Low_Tput_Clasical
    [Setup]    Run Keywords     Enable X2 Measurments
    ...        AND              Enable 1354-A
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_NSA_TDD_MMWV}

    5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Udp_Low_Tput_Clasical

[1][1.0] 5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb
    [Setup]     Run Keywords    Perform Parameter Commissioning    parameter=srb3SupportEnabled    value=true
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_NSA_TDD_MMWV}

    5GC000782_A_11_Verfiy_SgNBAddReject_When_Ciphering_Algorithm_Mismatch_Between_Ue_And_Gnb

[1][1.0] CB006898-B2_PDCP_And_RLC_PMQAP_Counters_With_NSA_UE
    [Setup]     Run Keywords    Enable Tput Counters
    ...         AND             Enable NSA PMQAP Counters
    ...         AND             Set Flow Control to X2
    ...         AND             Set Data Volume Threshold for DL and UL
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_NSA_TDD_MMWV}

    CB006898-B2_PDCP_And_RLC_PMQAP_Counters_With_NSA_UE

[1][1.0] CB008158-A_4_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_NSA_UE
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_NSA_TDD_MMWV}
    ...        AND              Prepare Bler Testmode In Dl

    CB008158-A_4_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_NSA_UE

[1][1.0] CB008159-C-2_The_Cumulative_Time_With_Bursty_Qos_Flow_In_Session
    [Setup]    Run Keywords     Fix And Send Full Commissioning With Given Scf Filepath    scfc_filepath=${CURDIR}/config/SA/Default_SCF.xml
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SA_TDD_MMWV}
    ...        AND              Enable PM Counters
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-2_The_Cumulative_Time_With_Bursty_Qos_Flow_In_Session
