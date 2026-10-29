*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         40 min

Resource    optical_switch.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot

Documentation
...    Author:Zhaojun Chen
...    contact:zhaojun.chen@nokia-sbell.com
...    squad group:SG_05
...    Feature: General_SiSo_CPRI_link_failure_triggered_RF_module_reset

Force Tags    5G_RAN_TDD
...   PY27

*** Variables ***

*** Test Cases ***
E2E_General_SiSo_CPRI_link_failure_triggered_RF_module_reset
    [Documentation]
    ...    **********************************************************************
    ...    operate RU optical link OFF/ON by fiber switch and check RU behaviours
    ...    **********************************************************************
    [Tags]    E2E_22R1
    optical_switch.General_SiSo_CPRI_link_failure_triggered_RF_module_reset   ru_index=1

*** Keywords ***
