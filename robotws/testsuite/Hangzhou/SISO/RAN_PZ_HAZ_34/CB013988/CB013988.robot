*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         60 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB013988_common_keyword.robot

Documentation
...    Author: Yang Di
...    Contact: di.yang@nokia-sbell.com
...    squad group: MMW_05
...    Feature CB013988 to regression AQQF and AQQQA in HAZ3_T05

*** Test Cases ***
CB013988_SR_006_A_Reset_Escalation_Strategy_AQQQA
    [Tags]    AQQQA
    Crash RU to Trigger POOR
    Run Keyword If    '${Active_SW_version[:8]}'=='SBTS26R1'
    ...    Check RU Reset Counter and BBOX Information    cause=RecoveryReset(13)    resetSignal=POR(24)
    ...    ELSE    Check RU Reset Counter and BBOX Information    cause=RecoveryReset_POR(26)    resetSignal=POR(24)
    Crash RU
    Check RU Reset Counter and BBOX Information    count_internal=3
    Crash RU
    Check RU Reset Counter and BBOX Information    count_internal=4

CB013988_SR_012_A_Reset_Escalation_Strategy_AQQF
    [Tags]    AQQF
    Crash RU to Trigger POOR
    Check RU Reset Counter and BBOX Information    resetSignal=POR(24)
    Crash RU
    Check RU Reset Counter and BBOX Information    count_internal=3
    Crash RU
    Check RU Reset Counter and BBOX Information    count_internal=4
