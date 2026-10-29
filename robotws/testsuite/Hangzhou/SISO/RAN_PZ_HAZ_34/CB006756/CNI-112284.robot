*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource     Resources/CB006756_common_keywords.robot



Documentation
...    Author:jiangjing lin
...    contact:jiangjing.lin@nokia-sbell.com
...    squad group:SG_08
...    Feature CNI-112284 in 5G00 program

Force Tags            5G_RAN_TDD    SBTS00    CRT_22R4    CRT_23R1
...    PY36

*** Variables ***

*** Test Cases ***
[1]CB012469_Static_DVM_Check_With_Multiple_Pmax_Change
    PAPSU check with SDVM

*** Keywords ***
