*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Timeout         60 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB005763_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

Documentation
...    Author: Shi Jeffrey
...    Contact: jeffrey.shi@nokia-sbell.com
...    squad group:SG_05
...    Feature CB005763 to regression AKQJ in HAZ4_T05

Force Tags    RAN_5G_TDD

*** Test Cases ***
[1]CB005763_D_04_trigger_and_cancell_dying_gasp_alarm_on_eCPRI_with_RF_standalone
    [Tags]    6S-1CC_CB012196-A_CB010713-A    CRT_TRUNK
    [Setup]    SISO Coam Test Setup
    ${fault_list}    Create List    10    4589
    Allowed Watchdog additional alarms    fault_list=${fault_list}
    Power_off_radio    ru_index=${6}
    check_fault_addition_information
    [Teardown]    Run keywords    Power_on_radio    ru_index=${6}     AND
    ...    Wait Until Keyword Succeeds    6min    30s    RU Should Be Online    ru_index=${6}    AND
    ...    add fault to allowed history fault list    faultId=${10}   AND
    ...    add fault to allowed history fault list    faultId=${4589}   AND
    ...    SISO Coam Test Teardown
