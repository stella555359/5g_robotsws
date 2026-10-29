*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         36h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_Module_Stability_test.robot

Documentation
...    Author:xuewen zhang
...    contact:xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CNI-89602 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_ASIBL_ABINB1_AQQY_ENB
...   PY36

*** Variables ***

*** Test Cases ***
[1]CNI-89602_General_SiSo_Auto_RF_Module_Stability_Run
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    [Timeout]    36h
    Set Log Level    INFO
    General_SiSo_RF_Module_Stability_test   times=${3}

[1]CNI-89602_General_SiSo_Auto_RF_Module_Stability_Run_test
    [Tags]    CRT_TRUNK    SBTS00    CRT_UTE
    General_SiSo_RF_Module_Stability_test

*** Keywords ***

