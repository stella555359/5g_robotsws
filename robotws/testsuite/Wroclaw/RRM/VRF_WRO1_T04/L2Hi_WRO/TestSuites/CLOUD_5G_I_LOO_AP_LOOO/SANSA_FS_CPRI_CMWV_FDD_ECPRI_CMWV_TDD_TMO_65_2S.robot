*** Settings ***
Documentation
...   Test cases regression - CRT
...   Topology: CLOUD_5G_I_LOO_AP_LOOO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65_2S
...   Author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    ${folder_path}/5GC002637_Throughput_counters/5GC002637-A-B1-3_PDCP_and_RLC_throughput_counters_with_NSA_UE.robot
Resource    ${folder_path}/CB006898_PMQAP_profiles_for_NR/CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue.robot
Resource    ${folder_path}/CB006898_PMQAP_profiles_for_NR/CB006898-B3_Reconfiguration_Of_20_PMQAP_Counters.robot
Resource    ${folder_path}/CB008158_NR_Latency_PM_Counters/CB008158-E_Number_of_PDCP_Bursts_in_UL.robot
Resource    ${folder_path}/CB013206/CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap.robot
Resource    ${folder_path}/CB013206/CB013206-C_Abnormal_Initiated_By_SgNB.robot
Resource    ${folder_path}/CB013206/CB013206-C_Abnormal_Initiated_By_SgNB_PMQAP.robot
Resource    ${folder_path}/CB013554/CB013554-A-B1_F1.robot
Resource    ${folder_path}/CB013554/CB013554-A-B1_X2.robot
Resource    ${folder_path}/CB013554/CB013554-B-B1_Endc_Specific_Counters.robot
Resource    ${folder_path}/CNI-103259/CNI-103259_Sa.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces
...            AND             Delete Profiles PMQAP
...            AND             Get Current SCF    dir_path=${CURDIR}   file_name=Default_SCF.xml

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${DEFAULT_SCF_FILEPATH}

*** Variables ***
${folder_path}=     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO

*** Test Cases ***
[1][1.0] 5GC002637-A-B1-3_PDCP_and_RLC_throughput_counters_with_NSA_UE
    [Setup]     Run Keywords    Enable Tput Counters
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    5GC002637-A-B1-3_PDCP_and_RLC_throughput_counters_with_NSA_UE

[1][1.0] CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue
    [Setup]     Run Keywords    Enable Tput Counters
    ...         AND             Add Qos Group
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue

[1][1.0] CB006898-B3_Reconfiguration_Of_20_PMQAP_Counters
    [Setup]     Run Keywords    Add Qos Group
    ...         AND             Enable Tput Counters
    ...         AND             Enable 20PMQAP Counters And Set Interval
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB006898-B3_Reconfiguration_Of_20_PMQAP_Counters

[1][1.0] CB008158-E_1_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_SA_UE
    [Setup]    Run Keywords     Enable Latency And PMQAP Counters
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}
    ...        AND              Prepare Bler Testmode In Ul

    CB008158-E_1_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_SA_UE

[1][1.0] CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap
    [Setup]     Run Keywords    Enable In Session Counters
    ...         AND             Enable PMQAP Counters NSA
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap

[1][1.0] CB013206-C_Abnorm_Sgnb_Insession_Release_Non_Pmqap
    [Setup]     Run Keywords    Enable Minrneighborltenrcunsa
    ...         AND             Enable X2 Measurments
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB013206-C_Abnorm_Sgnb_Insession_Release_Non_Pmqap

[1][1.0] CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap
    [Setup]     Run Keywords    Enable Minrneighborltenrcunsa
    ...         AND             Enable X2 Measurments
    ...         AND             Enable Pmqap Moc Nsa Qci6
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap

[1][1.0] CB013554-A-B1_1_F1-U_Pdu_And_Volume_Counters
    [Setup]     Run Keywords    Enable CB0013554-B1 Parameters
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB013554-A-B1_1_F1-U_Pdu_And_Volume_Counters

[1][1.0] CB013554-A-B1_2_X2-U_Pdu_And_Volume_Counters
    [Setup]     Run Keywords    Enable CB0013554-B1 Parameters
    ...         AND             Set Cfgqcirange To 9
    ...         AND             Enable Split F1UX2U And Set Paths Over X2
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB013554-A-B1_2_X2-U_Pdu_And_Volume_Counters

[1][1.0] CB013554-B-B1_ENDC_Specific_Counters_To_Calculate_The_DL_And_UL_ENDC_Split_Ratio
    [Setup]     Run Keywords    Enable CB0013554-ENDC Parameters
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CB013554-B-B1_ENDC_Specific_Counters_To_Calculate_The_DL_And_UL_ENDC_Split_Ratio

[1][1.0] CNI-103259_Transfer_Of_Data_Between_Upf_And_Gnb_For_Pdu_Type_0
    [Setup]    Run Keywords    Enable CNI-103259 Pm Counters
    ...        AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TMO}

    CNI-103259_Transfer_Of_Data_Between_Upf_And_Gnb_For_Pdu_Type_0
