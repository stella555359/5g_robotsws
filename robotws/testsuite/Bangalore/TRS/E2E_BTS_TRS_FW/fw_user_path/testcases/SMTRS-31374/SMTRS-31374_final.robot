*** Settings ***
Documentation
...    [Procedure] ""
...    [Date] "Date of creation"
...    [Author] "Vinay"
...    [QC_Path] "QC_Path in Test Plan"
...    [QC_ID] "QC_ID in Test Lab for reporting"
...    [Feature_ID] ""
...    [Function_Hash_Tags] ""
...    [Validation_status] "Validated and Passed"
...    [Validated_TestLine] 3603
...    [Validation Date]

Variables         ta_e2e_bts_trs_fw
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Library           Collections

Suite Setup       Run Keywords    Suite Setup Preconditions
...               AND    Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...               AND    Teardown Oamops


*** Test Cases ***
[1][1.0] SMTRS_31374_Verification_of_all_fronthaul_feature_CB005833_functionality_with_SoC_restart
    ${pre_execution_alarms}=    Get Current Alarm List

    Setup Remote Access    remote_device=bts    alias=session1

    ${stdout_1}=    Execute Interactive Remote Command
    ...    command=bsh ${bsh}
    ...    alias=session1

    ${stdout_2}=    Execute Interactive Remote Command
    ...    command=ip netns exec radions bash
    ...    alias=session1

    ${stdout_3}=    Execute Interactive Remote Command
    ...    command=ps aux | grep -i L1
    ...    alias=session1
    Log    ${stdout_3}

    ${text}    ${pid_1}=    Should Match Regexp
    ...    ${stdout_3}
    ...    root\\s+(\\d+).*nrt

    ${stdout_4}=    Execute Interactive Remote Command
    ...    command=ps aux | grep sfpd
    ...    alias=session1

    Log    ${stdout_4}
    Log    ${pid_1}

    ${text}    ${pid_2}=    Should Match Regexp
    ...    ${stdout_4}
    ...    sfp\\s+(\\d+).*sfpd
    Log    ${pid_2}

    ${stdout_4}=    Execute Interactive Remote Command
    ...    command=kill -11 ${pid_1}
    ...    alias=session1

    ${stdout_5}=    Execute Interactive Remote Command
    ...    command=kill -11 ${pid_2}
    ...    alias=session1

    Wait Until Keyword Succeeds    10x    3s    Check Soc restart fault id

    ${post_execution_alarms}=    Get Current Alarm List

    ${alarms_post_execution}=    Fault list after reset
    ...    ${pre_execution_alarms}
    ...    ${post_execution_alarms}

    Should Be Empty    ${alarms_post_execution}


*** Keywords ***
Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=     Create List

    FOR    ${i}    IN RANGE    ${length}
        ${fault_id}=    Convert To String    ${list[${i}]['faultId']}
        Append To List    ${list1}    ${fault_id}
    END

    [return]    ${list1}


Fault list after reset
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids}
    ${list}=    Create List

    FOR    ${i}    IN    @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END

    [return]    ${list}


Get Current Alarm List
    ${alarms}=    Verify Alarm    alarm_type=active
    ${alarm_faultids_list}=    Create List
    ${alarm_faultids_list}=    Create fault id List    ${alarms}
    [return]    ${alarm_faultids_list}


Check Soc restart fault id
    ${alarms}=    Verify Alarm    alarm_type=active

    ${pre_reset_length}=    Get Length    ${alarms}
    ${pre_alarm_faultids}=    Create List
    ${pre_alarm_faultids}=    Create fault id List    ${alarms}

    ${soc_fid}=    Convert To String    2087
    Should Contain    ${pre_alarm_faultids}    ${soc_fid}
