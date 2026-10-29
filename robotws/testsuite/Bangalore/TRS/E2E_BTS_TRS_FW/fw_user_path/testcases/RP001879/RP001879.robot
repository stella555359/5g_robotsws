*** Settings ***
Documentation
...    [Procedure]             "Abis Interface measurements"
...    [Date]                  "02-05-23"
...    [Author]                "Vinay"
...    [QC_Path]               "QC_Path in Test Plan"
...    [QC_ID]                 "QC_ID in Test Lab for reporting"
...    [Funtion_Hash_Tags]     "FIREWALL, COUNTERS, NETACT"
...    [Feature_ID]            "RP001879"
...    [Validation_status]     "Validated and Passed"
...    [Validated_TestLine]    "TL-2019"

Variables         ta_e2e_bts_trs_fw
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Admin_Common_Library.robot

Suite Setup       Run Keywords    Suite Setup Preconditions
...               AND    Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...               AND    Teardown Oamops


*** Test Cases ***
[1][1.0] TRS_RP001879_Verify_Abis_PS_data_traffic_for_IPv4
    Setup Ems    config_device=netact2005    alias=lab2005
    Cm Upload    config_device=netact2005    alias=lab2005

    ${pre_execution_alarms}=    Get Current Alarm List

    Configuration Manage
    ...    config_device=netact2005
    ...    config=${flag_actIpV6BasedPktAbTrs_true}
    ...    plan_name=iv_fw_plan
    ...    delete_plan=${True}
    ...    alias=lab2005
    ...    operation=edit

    Make GSM Call
    BuiltIn.Sleep    300
    Check gsm related counters

    ${post_execution_alarms}=    Get Current Alarm List
    ${alarms_post_execution}=    Fault list after reset
    ...    ${pre_execution_alarms}
    ...    ${post_execution_alarms}

    Should Be Empty    ${alarms_post_execution}

    Check gsm related counters

    [Teardown]    Teardown Ems    config_device=netact2005    alias=lab2005


*** Keywords ***
Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=     Create List

    FOR    ${i}    IN RANGE    ${length}
        ${fault_id}=    Convert To Integer    ${list[${i}]['faultId']}
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

Make GSM Call
    Call Setup    gsm=device_1:data    parallel=${False}    verify_attach=${False}

    Call Start    gsm=device_1:data
    ...    profile=udp_10K_ul
    ...    iperf_section=device1

    Call Start    gsm=device_1:data
    ...    profile=udp_10K_dl
    ...    iperf_section=device1

    BuiltIn.Sleep    900

    Call Stop    gsm=device_1:data    profile=udp_10K_ul
    Call Stop    gsm=device_1:data    profile=udp_10K_dl
    Call Teardown    gsm=device_1:data


Get Current Alarm List
    ${alarms}=    Verify Alarm    alarm_type=active
    ${alarm_faultids_list}=    Create List
    ${alarm_faultids_list}=    Create fault id List    ${alarms}
    [return]    ${alarm_faultids_list}


Check gsm related counters
    Setup Remote Access    remote_device=bts    alias=bts

    ${output}=    Execute Interactive Remote Command
    ...    command=trs-vppctl show gsm counters
    ...    alias=bts

    ${lines}=    Split To Lines    ${output}
    Log    ${lines}

    FOR    ${counter}    IN    @{gsm_verfication_counters}
        ${val}    ${counter_value}=    Should Match Regexp
        ...    ${output}
        ...    ${counter}\\D*(\\d+)

        ${bool}=    Evaluate    ${counter_value} > 0
        Should Be True    ${bool}
    END

    FOR    ${counter}    IN    @{gsm_error_counters}
        ${val}    ${counter_value}=    Should Match Regexp
        ...    ${output}
        ...    ${counter}\\D*(\\d+)

        ${bool}=    Evaluate    ${counter_value} == 0
        Should Be True    ${bool}
    END
