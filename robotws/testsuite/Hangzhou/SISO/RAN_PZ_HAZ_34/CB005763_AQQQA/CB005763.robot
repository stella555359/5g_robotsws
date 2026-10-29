*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot


Documentation
...    Author: Chen Xu
...    Contact: xu.2.chen@nokia-sbell.com
...    squad group: MMW_05
...    Feature CB005763_AQQQA

*** Variables ***
${if_commissioning}   False


*** Test Cases ***
CB005763-SR-DH_01_Dying_Gasp_alarm_check_ecpri_AQQQA
  [Tags]    AQQQA
  Log To Console  CB005763-SR-DH_01_Dying_Gasp_alarm_check_ecpri_AQQQA
  CB005763-SR-DH_01  range_time=${1}


*** Keywords ***

CB005763-SR-DH_01
    [Arguments]      ${range_time}=${2}
    Connect to gnb coam via ssl
    Set test variable    ${Pass_time}    0
    AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    FOR	   ${i}    IN RANGE    ${range_time}
        Log To Console  Power_Off_RU_Round_${i}
        Perform RU Power Off    ru_index=1
        Perform RU Power Off    ru_index=2
        Sleep    90s
        CB005763_alarm_check
        Run Keyword If    ${present_status}==${False}    Fail    Fault-10 not contain 'RU power loss'.
        ${Pass_time}    Run Keyword If    ${present_status}==${True}    Evaluate    ${Pass_time} + 1
                ...    ELSE    Evaluate    ${Pass_time}
        Perform RU Power On    ru_index=1
        Perform RU Power On    ru_index=2
        Sleep    120s
        Wait until keyword succeeds    10min    30s    Check all NR cells should be onair
    END
    log to console   !!!Pass_time_${Pass_time}!!!


CB005763_alarm_check
    [Arguments]    ${faultId}=10    ${u_name}=RU power loss
    ${faultId}    Convert To Integer    ${faultId}
    @{alarms}    coam.get_active_alarms    connection=GNB_OAM
    ${alarm_num}    Get Length    ${alarms}
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        Exit For Loop If    ${alarm_num}==${0}
        ${present_status}    Run Keyword And Return Status    Run Keywords
                  ...      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
                  ...      Should Contain    ${alarm['supplAlarmInfo']}    ${u_name}
        Exit For Loop If    ${present_status}
    END
    Set test variable    ${present_status}


Check all NR cells should be onair
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=90
    Log to console    Check all NR cells should be onair
    ${nr_cells_info}   coam.get_cells_info  cell_type=nr    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{nr_cells_info}
        Should Be Equal As Strings    ${cell['status']['operationalState'].lower()}   enabled
        Should Be Equal As Strings    ${cell['status']['administrativeState'].lower()}     unlocked
        Should Be Equal As Strings    ${cell['status']['blockingState'].lower()}   unblocked
    END

