*** Settings ***
Documentation
...   CB013554 Test cases regression - CRT
...   Topology: CLOUD_5G_I_LO_AP_LO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...   Author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013554/CB013554-A-B1_F1.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013554/CB013554-A-B1_X2.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013554/CB013554-A-B2-1_DL_PDU_retx_due_to_HO.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013554/CB013554-A-B2_2_DL_PDU_retx_due_to_thr_exceeding.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013554/CB013554-B-B1_Endc_Specific_Counters.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

*** Test Cases ***
[1][1.0] CB013554-A-B1_1_F1-U_Pdu_And_Volume_Counters
    [Setup]     Run Keywords    Enable BBPooling
    ...         AND             Enable CB0013554-B1 Parameters
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013554-A-B1_1_F1-U_Pdu_And_Volume_Counters

[1][1.0] CB013554-A-B1_2_X2-U_Pdu_And_Volume_Counters
    [Setup]     Run Keywords    Enable BBPooling
    ...         AND             Enable CB0013554-B1 Parameters
    ...         AND             Set Cfgqcirange To 9
    ...         AND             Enable Split F1UX2U And Set Paths Over X2
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013554-A-B1_2_X2-U_Pdu_And_Volume_Counters

[1][1.0] CB013554-A-B2-1_DL_PDU_Retx_Due_To_HO_And_Duplication
    [Setup]     Run Keywords    Enable CB0013554-B2 Parameters
    ...         AND             Enable HO
    ...         AND             Enable Duplication
    ...         AND             Disable actDlTxResumeOnPdcpStatRep
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013554-A-B2-1_DL_PDU_Retx_Due_To_HO_And_Duplication

[1][1.0] CB013554-A-B2_2_DL_PDU_Retx_Due_To_Thr_Exceeding
    [Setup]     Run Keywords    Enable CB0013554-B2 Parameters
    ...         AND             Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013554-A-B2_2_DL_PDU_Retx_Due_To_Thr_Exceeding

[1][1.0] CB013554-B-B1_ENDC_Specific_Counters_To_Calculate_The_DL_And_UL_ENDC_Split_Ratio
    [Setup]     Run Keywords    Enable CB0013554-ENDC Parameters
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013554-B-B1_ENDC_Specific_Counters_To_Calculate_The_DL_And_UL_ENDC_Split_Ratio
