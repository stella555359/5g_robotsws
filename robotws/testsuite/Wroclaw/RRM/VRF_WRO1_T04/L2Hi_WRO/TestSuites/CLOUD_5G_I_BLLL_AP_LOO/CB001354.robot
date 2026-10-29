*** Settings ***
Documentation
...   CB001354 Test cases regression - CRT
...   Topology: CLOUD_5G_I_BLLL_AP_LOO
...   Variant:  SANSA_FS_ECPRI_CMWV_FDD+TDD
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C_PR666688.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C_PR669934.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/5GC001354/5GC001354-C_PR669984.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure NSA VM interfaces

Test Teardown    Run Keywords    Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${BLL_AP_LOO_GMC_SCF_FILE}

*** Test Cases ***
[1][1.0] 5GC001354-C-PR666688_Lack_Of_Autonomous_Reset_Occurrence_After_Set_Dlmaxretx_Threshold_To_T1_And_Dltpollretr_To_Ms5_On_Tdd_Cell
    [Setup]     Run Keywords    Enable 1354-C
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_AND_FDD}

    5GC001354-C-PR666688_Lack_Of_Autonomous_Reset_Occurrence_After_Set_Dlmaxretx_Threshold_To_T1_And_Dltpollretr_To_Ms5_On_Tdd_Cell

[1][1.0] 5GC001354-C-PR669934_Check_Ue_Activity_After_Setting_Dlmaxretx_Threshold_To_T1_And_Dltpollretr_To_Ms5_On_Fdd_Cell
    [Setup]     Run Keywords    Enable 1354-C
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_AND_FDD}

    5GC001354-C-PR669934_Check_Ue_Activity_After_Setting_Dlmaxretx_Threshold_To_T1_And_Dltpollretr_To_Ms5_On_Fdd_Cell

[1][1.0] 5GC001354-C-PR669984_Check_Tput_Value_With_1354-C_Enabled
    [Setup]     Run Keywords    Enable 1354-C
    ...         AND             Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_AND_FDD}

    5GC001354-C-PR669984_Check_Tput_Value_With_1354-C_Enabled
