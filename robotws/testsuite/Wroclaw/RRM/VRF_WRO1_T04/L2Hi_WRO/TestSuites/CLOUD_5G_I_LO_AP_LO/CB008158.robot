*** Settings ***
Documentation
...   CB008158 Test cases regression - CRT
...   Topology: CLOUD_5G_I_LO_AP_LO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   Author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008158_NR_Latency_PM_Counters/CB008158-A_Average_DL_Air-Interface_delay_for_AM_RLC.robot
Resource    ../../CB008158_NR_Latency_PM_Counters/CB008158-A_Percentile_of_Average_DL_Air-Interface_delay_for_AM_RLC.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008158_NR_Latency_PM_Counters/CB008158-B_PDCP_Delay_DL.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008158_NR_Latency_PM_Counters/CB008158-C_1_Average_PDCP_re-ordering_delay_in_the_UL.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008158_NR_Latency_PM_Counters/CB008158-D_Average_Initial_Burst_scheduling_delay_in_DL.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008158_NR_Latency_PM_Counters/CB008158-E_Number_of_PDCP_Bursts_in_UL.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB008158_NR_Latency_PM_Counters/CB008158-Online_flag_modification.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure SA VM interfaces
...            AND             Configure NSA VM interfaces
...            AND             Get Current SCF    dir_path=${CURDIR}    file_name=Default_SCF.xml

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${DEFAULT_SCF_FILEPATH}

*** Test Cases ***
[1][1.0] CB008158-A_1_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_SA_UE_PMQAP
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Enable Intra Gnb Ho And A3 Meas
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Dl

    CB008158-A_1_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_SA_UE_PMQAP

[1][1.0] CB008158-A_2_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_NSA_UE_PMQAP
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Enable Intra Gnb Ho And A3 Meas
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Dl

    CB008158-A_2_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_NSA_UE_PMQAP

[1][1.0] CB008158-A_3_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_SA_UE
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Dl

    CB008158-A_3_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_SA_UE

[1][1.0] CB008158-A_4_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_NSA_UE
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Dl

    CB008158-A_4_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_NSA_UE

[1][1.0] CB008158-B_1_Average_DL_PDCP_SDU_delay_in_CU-UP_with_PMQAP_and_SA_UE
    [Setup]    Run Keywords     Disable Uplane Ciphering
    ...        AND              Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare MCS Bler Testmode In Dl

    CB008158-B_1_Average_DL_PDCP_SDU_delay_in_CU-UP_with_PMQAP_and_SA_UE

[1][1.0] CB008158-B_2_Average_GTP_packet_delay_over_F1-U_interface_with_PMQAP_and_SANSA_UE
    [Setup]    Run Keywords     Disable Uplane Ciphering
    ...        AND              Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare MCS Bler Testmode In Dl

    CB008158-B_2_Average_GTP_packet_delay_over_F1-U_interface_with_PMQAP_and_SANSA_UE

[1][1.0] CB008158-C_1_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_SA_UE
    [Setup]    Run Keywords     Disable Uplane Ciphering
    ...        AND              Set tReorderingUl To 3000ms PDCP 2 Profile
    ...        AND              Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Ul

    CB008158-C_1_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_SA_UE

[1][1.0] CB008158-C_2_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_NSA_UE
    [Setup]    Run Keywords     Disable Uplane Ciphering
    ...        AND              Set tReorderingUl To 3000ms PDCP 2 Profile
    ...        AND              Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Ul

    CB008158-C_2_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_NSA_UE

[1][1.0] CB008158-D_1_Average_Initial_Burst_Scheduling_Delay_In_DL_With_PMQAP_And_SA_UE
    [Setup]    Run Keywords     Disable Uplane Ciphering
    ...        AND              Enable Latency Pm Counters
    ...        AND              Enable Sansa Pmqap
    ...        AND              Enable ActNonVoNRGbrService
    ...        AND              Add Profiles For 5QI
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB008158-D_1_Average_Initial_Burst_Scheduling_Delay_In_DL_With_PMQAP_And_SA_UE

[1][1.0] CB008158-D_2_Average_Initial_Burst_Scheduling_Delay_In_DL_With_PMQAP_And_NSA_UE
    [Setup]    Run Keywords     Disable Uplane Ciphering
    ...        AND              Enable Latency Pm Counters
    ...        AND              Enable Sansa Pmqap
    ...        AND              Enable ActNonVoNRGbrService
    ...        AND              Add Profiles For 5QI
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB008158-D_2_Average_Initial_Burst_Scheduling_Delay_In_DL_With_PMQAP_And_NSA_UE

[1][1.0] CB008158-E_1_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_SA_UE
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Ul

    CB008158-E_1_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_SA_UE

[1][1.0] CB008158-E_2_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_NSA_UE
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Ul

    CB008158-E_2_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_NSA_UE

[1][1.0] CB008158_Online_flag_modification
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Prepare Bler Testmode In Dl And Ul

    CB008158_Online_flag_modification
