*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         25h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CNI98576_common_cases.robot

Documentation
...    Author:kaihui fan
...    contact:kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature CNI-98576 TL317   ASIB+ABIO+AVQL

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIBL_ABINB1_AQQY_ENB
...   PY310    HAZ4_T04


*** Test Cases ***
[1]CNI-98576-CB006519-SR_B1_01_ST-SFP_auto-configuration_after_BTS_reset
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    [Timeout]    25h
    General_SiSo_SFP_auto-configuration_monitoring_Diagnostic_data_after_BTS_reset

[1]CNI-98576-CB006519-SR_B1_03_ST-SFP_auto-configuration_after_RRU_reset
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE    RF50
    [Timeout]    25h
    General_SiSo_SFP_auto-configuration_monitoring_Diagnostic_data_after_RRU_reset
