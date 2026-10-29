*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         24h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_LTE.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/ue.robot

Documentation
...    Author:Wu Jerry
...    contact:jerry.wu@nokia-sbell.com
...    squad group:mmw02
...    Feature CB011040 in trunk program

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G    STATE_SW_UPLOADED
...   PY36

*** Variables ***
${if_commissioning}   False

*** Test Cases ***
[1]CB011040-SR-A_4_Manual_SiSo_SM_BTS_Site_Reset
    FOR	${i}	IN RANGE	50
        Connect to gnb coam via ssl    connection=GNB_OAM
        General_SiSo_Auto_BTS_site_reset
        &{fault_61675}     Create Dictionary     faultId=${61675}
        Append To List     ${ALLOWED_HISTORY_FAULT}   ${fault_61675}
        ${status}    run keyword and return status    Wait Until Keyword Succeeds    6min    30s    Check alarm
        log    ${status}
		${history_alarm_status}    run keyword and return status    Unexpect History Alarm Should Not Exist
		...    allowed_faults=@{ALLOWED_HISTORY_FAULT}    connection=GNB_OAM
        run keyword if    ${status} or ${history_alarm_status}==False    Collect all logs
        exit for loop if    ${status} or ${history_alarm_status}==False
    END

*** Keywords ***
Check alarm
    [Arguments]  ${connection}=GNB_OAM
    ${alarm_list}    create list    6450   10   1806    4341    4352    4383    4335    1868    4590    1907    7305    4019    69    2943
    ${status}    set variable    ${False}
    FOR    ${faultId}    IN    @{alarm_list}
        ${status}    run keyword and return status    Expect Fault Should Present    faultId=${faultId}    connection=${connection}
        log    ${status}
        exit for loop if    ${status}
    END
    should be true    ${status}

Collect all logs
    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM
    Save Coam im snapshot    target_dir=${SAVE LOG DIRECTORY}    connection=GNB_OAM