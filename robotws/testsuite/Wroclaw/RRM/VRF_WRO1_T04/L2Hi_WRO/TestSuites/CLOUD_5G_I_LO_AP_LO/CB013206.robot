*** Settings ***
Documentation
...   CB013206 Test cases regression - CRT
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

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206/CB013206-B-B1_Norm_Menb_Insession_Release.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206/CB013206-B-B2_Norm_Menb_Inactivity_Cause_Release.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206/CB013206-B-B3_Abnorm_Menb_Insession_Release_Non_Pmqap.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206/CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206/CB013206-C_Abnormal_Initiated_By_SgNB.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/CB013206/CB013206-C_Abnormal_Initiated_By_SgNB_PMQAP.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

*** Test Cases ***
[1][1.0] CB013206-B-B1_Norm_Menb_Insession_Release
    [Setup]     Run Keywords    Enable In Session Counters And Set Pmqap Profiles
    ...         AND             Enable NSA HO
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013206-B-B1_Norm_Menb_Insession_Release

[1][1.0] CB013206-B-B2_Norm_Menb_Inactivity_Cause_Release
    [Setup]     Run Keywords    Enable In Session Counters And Set Pmqap Profiles
    ...         AND             Enable NSA HO
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013206-B-B2_Norm_Menb_Inactivity_Cause_Release

[1][1.0] CB013206-B-B3_Abnorm_Menb_Insession_Release_Non_Pmqap
    [Setup]     Run Keywords    Enable In Session Counters And Set Pmqap Profiles
    ...         AND             Enable NSA HO
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013206-B-B3_Abnorm_Menb_Insession_Release_Non_Pmqap

[1][1.0] CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap
    [Setup]     Run Keywords    Enable In Session Counters And Set Pmqap Profiles
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013206-B-B4_Abnorm_Menb_Insession_Release_Pmqap

[1][1.0] CB013206-C_Abnorm_Sgnb_Insession_Release_Non_Pmqap
    [Setup]     Run Keywords    Enable Minrneighborltenrcunsa
    ...         AND             Enable X2 Measurments
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013206-C_Abnorm_Sgnb_Insession_Release_Non_Pmqap

[1][1.0] CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap
    [Setup]     Run Keywords    Enable Minrneighborltenrcunsa
    ...         AND             Enable X2 Measurments
    ...         AND             Enable Pmqap Moc Nsa Qci6
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}

    CB013206-C_Abnorm_Sgnb_Insession_Release_Pmqap
