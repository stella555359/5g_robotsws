*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         25h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resource/CNI96032_common_cases.robot

Documentation
...    Author:kaihui fan
...    contact:kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature CNI-96032 in trunk program for AQQY

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIBL_ABINB1_AQQY_ENB
...   PY36

*** Variables ***

*** Test Cases ***
# TL580 1S-2CC-8D-4U
[1]CNI96032_General_SiSo_Auto_RF_Module_Factory_FDSW_Upgrade
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE    RF50
    [Timeout]    25h
    ${fault_list}    Create List    23  10
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    General_SiSo_RF_Factory_FDSW_SW_Upgrade

*** Keywords ***
