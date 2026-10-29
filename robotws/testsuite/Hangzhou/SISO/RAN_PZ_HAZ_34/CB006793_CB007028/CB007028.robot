*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup
Test Teardown
Test Timeout         240 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot

Documentation
...    Author: shasha liu
...    Contact: shasha.liu@nokia-sbell.com
...    squad group:SG_05
...    Feature CB006793_CB007028 in 5G22R2 program

Force Tags    RAN_5G_TDD
...    PY36

*** Variables ***


*** Test Cases ***
[1]A1_General_SiSo_Cell_lock_and_unlock
    [Tags]    master_classicalbts_all    CIT_TRUNK
    [Setup]    SISO Coam Test Setup
    General_SiSo_Cell_lock_and_unlock    with_call=${False}    with_peak=${False}
    [Teardown]    SISO Coam Test Teardown

*** Keywords ***
