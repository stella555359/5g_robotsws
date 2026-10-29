*** Settings ***

Documentation     [Procedure] "SMTRS-31919"
...               [Date] "7-01-2024"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] ""
...               [Validation_status] "Validated and Passed"
...               [Validated_TestLine] "3063"

Resource      taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource      ${CURDIR}/../resources/Admin_Common_Library.robot
Library       SeleniumLibrary
Library       Collections
Library       SSHLibrary
Resource      taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource      ${CURDIR}/../resources/common_keywords.robot
Variables     ta_e2e_bts_trs_fw

Suite Setup        Run Keywords    Suite Setup Preconditions
...     AND     Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...     AND     Teardown Oamops

***Test Cases***
[1]SMTRS-31955 Mplane basic sanity need to be tested after modification of LSS IP with LTE trace MOC for IPv4 and IPv6 Mplane
    ${pre_execution_alarms}=    Get Current Alarm List
    Perform Commissioning       scf_file=${CURDIR}/LSS.xml       skip_parameter_relation_errors=true   verify_bts_status=${False}
    ...    timeout=600     alias=default
    Verify Bts Status   should_be_onair=${True}    rat=5g    wait_for=100    timeout=300
    ${post_execution_alarms}=    Get Current Alarm List
    ${alarms_post_execution}=    Fault list after reset    ${pre_execution_alarms}    ${post_execution_alarms}
    Should Be Empty     ${alarms_post_execution}
    Setup Oamops    bts_host=${mplane_ip_v4}   alias=initial_mplane
    Teardown Oamops    alias=initial_mplane
    ${pre_execution_alarms}=    Get Current Alarm List
    Perform Commissioning       scf_file=${CURDIR}/LSS_v6.xml       skip_parameter_relation_errors=true   verify_bts_status=${False}
    ...    rat=5g    timeout=600
    Verify Bts Status   should_be_onair=${True}    rat=5g    wait_for=100    timeout=300
    ${post_execution_alarms}=    Get Current Alarm List
    ${alarms_post_execution}=    Fault list after reset    ${pre_execution_alarms}    ${post_execution_alarms}
    Should Be Empty     ${alarms_post_execution}
    Setup Oamops    bts_host=${mplane_ip_v6}   alias=initial_mplane_v6
    Teardown Oamops    alias=initial_mplane_v6

*** keywords***

Create fault id List
    [Arguments]        ${list}
    ${length}=    Get Length    ${list}
    ${list1}=    Create List
    FOR    ${i}    IN RANGE    ${length}
        ${fault_id}    Convert To Integer    ${list[${i}]['faultId']}
        Append To List      ${list1}    ${fault_id}
    END
    [return]    ${list1}

Fault list after reset
    [Arguments]        ${pre_alarm_faultids}    ${post_alarm_faultids}
    ${list}=    Create List
    FOR    ${i}    IN        @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}      ${i}
    END
    [return]    ${list}

Get Current Alarm List
    ${alarms_dict}      Verify Alarm       alarm_type=active
    log    ${alarms_dict}
    ${alarms_list}     Create List
    FOR    ${i}    IN    @{alarms_dict}
        log    ${i['faultId']}
        Run Keyword If      ${i['faultId']}==None    Continue For Loop
        ${fault_id}    Convert To Integer    ${i['faultId']}
        Append To List     ${alarms_list}    ${fault_id}
    END
    log    ${alarms_list}
    [return]    ${alarms_list}

Pre-reset alarms
    ${pre_reset_alarms}=    Verify Alarm    alarm_type=active
    ${pre_reset_length}=    Get Length    ${pre_reset_alarms}
    ${pre_alarm_faultids}=    Create List
    ${pre_alarm_faultids}=    Create fault id List    ${pre_reset_alarms}
    Set Suite Variable      ${pre_alarm_faultids}       ${pre_alarm_faultids}

Post-reset alarms
    ${post_reset_alarms}=   Verify Alarm    alarm_type=active
    ${post_reset_length}=   Get Length    ${post_reset_alarms}
    ${post_alarm_faultids}=    Create List
    ${post_alarm_faultids}=    Create fault id List    ${post_reset_alarms}
    ${alarms_post_reset}=   Fault list after reset    ${pre_alarm_faultids}    ${post_alarm_faultids}
    Set Suite Variable      ${post_alarm_faultids}       ${post_alarm_faultids}
    Set Suite Variable      ${post_reset_length}        ${post_reset_length}
