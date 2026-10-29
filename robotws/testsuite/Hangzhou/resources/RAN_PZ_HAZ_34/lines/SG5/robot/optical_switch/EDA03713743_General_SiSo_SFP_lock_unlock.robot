*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2 hours

Resource    optical_switch.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Documentation
...    Author:Zhaojun Chen
...    contact:zhaojun.chen@nokia-sbell.com
...    squad group:SG_05
...    Feature: General_SiSo_SFP_lock_unlock_for_configuration_testing
...    Configuration: 1S-2CC-16DL8UL; 3 fibers; recommends to disable deepsleep (<p name="energySavingMode">NORMAL</p>)

Force Tags    5G_RAN_TDD
...   PY310

*** Test Cases ***
[1][1.0] General_SiSo_SFP_lock_unlock_for_configuration_testing
#    [Tags]    1S-2CC-16D8U_3fibers    CRT_TRUNK
    optical_switch.General_SiSo_SFP_lock_unlock_for_configuration_testing    is_optical_switch=${False}
