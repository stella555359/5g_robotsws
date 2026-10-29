*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource   ${BASIC_PATH_5G}/RF/General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode.robot

Documentation
...    Author:kaihui fan
...    contact:kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature Owner: Chen Zhendong
...    Feature CB011148  AVQC in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    PY310    HAZ4_T04

*** Test Cases ***
[1]CB011148-SR_03_AVQC_1S2CC_16D8U_different Capture type select_RF scan test with full Mode in online mode
    General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode
