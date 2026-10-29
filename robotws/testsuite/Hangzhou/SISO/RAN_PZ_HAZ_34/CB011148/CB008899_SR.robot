*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Case Setup for 8899
Test Teardown        Case Teardown for 8899
Test Timeout         100 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011148/resource/rfscan_common.robot
Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot

Documentation
...    Author:ruiyu han
...    contact:ruiyu.han@nokia.com
...    squad group:SG_04
...    Feature Owner: Chen Zhendong
...    Feature CB008899  AEHC in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED    PY310    HAZ4_T04

*** Test Cases ***
[1]CB008899_AEHC_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode
    Admin_General_SiSo_different_Capture_type_select_RF_scan_test_with_full_mode_in_online_mode    ru_type=AEHC
