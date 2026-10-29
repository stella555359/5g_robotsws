*** Settings ***
Documentation
...   CB008159 Test cases regression - CRT
...   Topology: CLOUD_5G_I_LO_AP_LO
...   Variant:  SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC
...   author:   Marcin Kotuła (marcin.kotula@nokia.com)

Variables   testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.py

Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_variables.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_configuration.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/feature_activation.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/logs_collection.robot

Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.py
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/pm_counters_validator.py

Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-1_Continuous_Qos_Flow_In_Session.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-2_Bursty_Qos_Flow_In_Session.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-3_Continuous_And_Bursty_Qos_Flow_In_Session_High_Data_Traffic_In_Both_Directions.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-4_Continuous_And_Bursty_Qos_Flow_In_Session_With_Pmqap_Profiles_Activated.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-5_Continuous_Flow_In_Session_With_Extended_Traffic_Duration.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-6_Continuous_And_Burst_Flow_In_Session_With_Bearer_Delete.robot
Resource    ../../CB008159_Additional_PM_Counter/CB008159-C-7_Continuous_And_Burst_Flow_In_Session_With_Inter_Cell_Handover.robot

Suite Setup    Run Keywords    Enable Syslog Info Level Prints
...            AND             Configure SA VM interfaces
...            AND             Configure NSA VM interfaces
...            AND             Get Current SCF    dir_path=${CURDIR}    file_name=Default_SCF.xml

Test Teardown    Run Keywords    Reset In Session Time
...              AND             Send Configuration ID To Scout
...              AND             Common Test Teardown    scf_filepath=${DEFAULT_SCF_FILEPATH}

*** Test Cases ***
[1][1.0] CB008159-C-1_The_Cumulative_Time_With_Continuous_Qos_Flow_In_Session
    [Setup]    Run Keywords     Enable PM Counters
    ...        AND              Enable Vonr
    ...        AND              Enable Vonr For Second Cell
    ...        AND              Enable ActNonVoNRGbrService
    ...        AND              Add Profiles For 5QI
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-1_The_Cumulative_Time_With_Continuous_Qos_Flow_In_Session

[1][1.0] CB008159-C-2_The_Cumulative_Time_With_Bursty_Qos_Flow_In_Session
    [Setup]    Run Keywords     Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Enable PM Counters
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-2_The_Cumulative_Time_With_Bursty_Qos_Flow_In_Session

[1][1.0] CB008159-C-3_The_Cumulative_Time_With_Continuous_And_Bursty_Qos_Flow_In_Session_High_Data_Traffic_In_Both_Directions
    [Setup]    Run Keywords     Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Enable PM Counters
    ...        AND              Enable Vonr
    ...        AND              Add Profiles For 5QI
    ...        AND              Enable ActNonVoNRGbrService
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-3_The_Cumulative_Time_With_Continuous_And_Bursty_Qos_Flow_In_Session_High_Data_Traffic_In_Both_Directions

[1][1.0] CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated
    [Setup]    Run Keywords     Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Enable PM Counters
    ...        AND              Enable PMQAP Counters And Set Profiles
    ...        AND              Enable Vonr
    ...        AND              Enable ActNonVoNRGbrService
    ...        AND              Add Profiles For 5QI
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated

[1][1.0] CB008159-C-5_The_Cumulative_Time_With_Continuous_Flow_In_Session_With_Extended_Traffic_Duration
    [Setup]    Run Keywords     Enable Rd Flag For C5
    ...        AND              Reset Testline And Wait For Rmods
    ...        AND              Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Enable PM Counters
    ...        AND              Enable Vonr
    ...        AND              Enable Vonr For Second Cell
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-5_The_Cumulative_Time_With_Continuous_Flow_In_Session_With_Extended_Traffic_Duration

    [Teardown]  Run Keywords    Reset In Session Time
    ...         AND             Send Configuration ID To Scout
    ...         AND             Set Default Rd Flag For C5
    ...         AND             Common Test Teardown    scf_filepath=${LO_AP_LO_GMC_SCF_FILE}

[1][1.0] CB008159-C-6_The_Cumulative_Time_With_Continuous_And_Burst_Flow_In_Session_With_Bearer_Delete
    [Setup]    Run Keywords     Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Enable PM Counters
    ...        AND              Enable Vonr
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-6_The_Cumulative_Time_With_Continuous_And_Burst_Flow_In_Session_With_Bearer_Delete

[1][1.0] CB008159-C-7_The_Cumulative_Time_With_Continuous_And_Burst_Flow_In_Session_With_Inter_Cell_Handover
    [Setup]    Run Keywords     Common Test Setup    cfg_filepath=${EPCSIM_CFG_PATH_SANSA_TDD_FDD}
    ...        AND              Enable PM Counters
    ...        AND              Enable Vonr
    ...        AND              Enable Vonr For Second Cell
    ...        AND              Activate Intra Gnb Ho And A3 Meas
    ...        AND              Set Internal Traffic Type To UEs
    ...        AND              Set Internal Traffic Type To UEs    ue_id=2

    CB008159-C-7_The_Cumulative_Time_With_Continuous_And_Burst_Flow_In_Session_With_Inter_Cell_Handover
