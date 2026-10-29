*** Settings ***
Documentation    author: Chen Yanfen
...              Group: RAN_PZ_HAZ3_SG02
...              contact: helen.1.chen@nokia-sbell.com

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot

*** Variables ***
${if_commissioning}    False
${CASE_LOG_PATH}    ${logPath}

*** Test Cases ***
[1][1.0] CNI-103138-SR-A_2_check cell status with 19bits and 48 PRB on top of CB006991
    [Setup]    CNI_103138 Case Setup
    Connect to gnb coam via ssl    connection=GNB_OAM
    Sleep    10s
    Wait Until Keyword Succeeds    30 min    5 sec    Verify all cells should be onair
    COAM Teardown gnb connections    connection=GNB_OAM
    [Teardown]    CNI_103138 Case Teardown

[1][1.0] CNI-103138-SR-A_6_check RIM-RS receiving with 19bits and 48 PRB on top of CB006991
    [Setup]    CNI_103138 Case Setup
    log to console  \n***Check fault 7525***
    Wait Until Keyword Succeeds    30 min    5 sec    Check_Alarm_Appeared     faultId=${7525}
    log to console  \n***Check fault 7527***
    Wait Until Keyword Succeeds    10 min    5 sec    Check_Alarm_Appeared     faultId=${7527}
    Sleep    3s
    [Teardown]    CNI_103138 Case Teardown

*** Keywords ***
Check_Alarm_Appeared
    [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
    ...            ${configObjectName}=${None}
    Connect to gnb coam via ssl    connection=${connection}
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=${connection}
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
       Exit For Loop If    ${alarm_num}==${0}
       ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...                      Run Keyword If    '${source}'!='${None}'
                  ...                      Should Contain     ${alarm['notifier']}    ${source}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${severity}'!='${None}'
                  ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
                  ...                      Run Keyword If    '${alarmId}'!='${None}'
                  ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}    AND
                  ...                      Run Keyword If    '${config_object_name}'!='${None}'
                  ...                      Should Contain    ${alarm['configObjectName']}    ${config_object_name}
      Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

CNI_103138 Case Setup
    [Arguments]    ${gnb_index}=0
    robot_common_operations.Common Case Setup
    ...    gnb_index=${gnb_index}
    ...    allowed_faults_ids=7525,7535,7527,61675

CNI_103138 Case Teardown
    robot_common_operations.Common Case Teardown
    CI interface.Common Case Teardown