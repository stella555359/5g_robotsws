*** Settings ***
Documentation    This is for some action of alarm.
...              Please do not modify the file without notification to author
...              Author: jun.8.chen@nokia-sbell.com


*** Keywords ***
Get Active Alarms And Save Summary Infomation
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=alarm_check
    Log    ${gnb_index}
    ${has_enb}    testline_info.has_enb    ${tl}
    ${enb_oam_ip}    Run Keyword If    ${has_enb}    Set Variable If    ${tl.enbs[${enb_index}].airscale}
    ...    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}    ${tl.enbs[${enb_index}].oam_ip.v4}
    Run Keyword If    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    ${active_alarms}    coam.get_active_alarms    connection=${connection}    timeout=60
    ${history_alarms}    coam.get_historic_alarms    connection=${connection}    timeout=100    load_history=${True}
    &{summary_alarm_info}    Create Dictionary
    FOR    ${active_alarm}    IN    @{active_alarms}
        ${alarm_info}    Create Dictionary
        ${faultId}    Set Variable    ${active_alarm['faultId']}
        ${faultId}    Convert To String    ${faultId}
        ${configration_alarming_object}    Set Variable    ${active_alarm['configObjectName']}
        ${alarmDetail}    Set Variable    ${active_alarm['alarmDetail']}
        ${alarm_object_list}    Create List    ${configration_alarming_object.split('] ')[-1]}
        Set To Dictionary    ${alarm_info}    alarm_detail=${alarmDetail}    object_name=${alarm_object_list}
        ${alarm_id_keys}    Get Dictionary Keys   ${summary_alarm_info}
        ${whether_id_contain}    Run Keyword And Return Status    List Should Contain Value    ${alarm_id_keys}    ${faultId}
        ${whether_object_contain}    Run Keyword And Return Status
        ...    List Should Contain Value    ${summary_alarm_info['${faultId}']['object_name']}    ${configration_alarming_object.split('] ')[-1]}
        Run Keyword If    not ${whether_id_contain}    Set To Dictionary    ${summary_alarm_info}    ${faultId}=${alarm_info}
        ...    ELSE IF    ${whether_id_contain} and not ${whether_object_contain}
        ...               Append To List    ${summary_alarm_info['${faultId}']['object_name']}    ${configration_alarming_object.split('] ')[-1]}
    END
    [Return]    ${summary_alarm_info}
    [Teardown]  coam.teardown    connection=${connection}

Check Whether New Alarm Happened During Running Case
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${alarm_info_before}    ${gnb_index}=${0}
    ${alarm_info_after}    Get Active Alarms And Save Summary Infomation    gnb_index=${gnb_index}
    ${alarm_id_before}    Get Dictionary Keys    ${alarm_info_before}
    ${alarm_id_after}    Get Dictionary Keys    ${alarm_info_after}
    Remove Values From List    ${alarm_id_after}    8150
    Remove Values From List    ${alarm_id_after}    4681
    ${new_alarm_id_list}    Evaluate    list(set(${alarm_id_after})-set(${alarm_id_before}))
    ${old_alarm_id_list}    Evaluate    list(set(${alarm_id_before})-set(${alarm_id_after}))
    ${empty_list}    Create List
    ${new_alarm_result}    Run Keyword And Return Status    Lists Should Be Equal    ${new_alarm_id_list}    ${empty_list}
    ${old_alarm_result}    Run Keyword And Return Status    Lists Should Be Equal    ${old_alarm_id_list}    ${empty_list}
    Run Keyword If    not ${new_alarm_result} and '${TEST STATUS}'=='PASS'    Run Keyword And Ignore Error
    ...    Common_keywords.Collect Snapshot Log    timeout=${1800}
    Run Keyword If    not ${new_alarm_result}    Fail    msg=New fault ${new_alarm_id_list} happened, case failed!!!!!
    ...    ELSE IF    ${old_alarm_result} and ${new_alarm_result}    __Compare The Alarm Detail Between Two Alarm List
    ...                   alarm_dic1=${alarm_info_before}    alarm_dic2=${alarm_info_after}

__Compare The Alarm Detail Between Two Alarm List
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${alarm_dic1}    ${alarm_dic2}
    ${alarm_id_list}    Get Dictionary Keys    ${alarm_dic1}
    FOR   ${alarm_id_list}    IN   @{alarm_id_list}
        ${alarm_detail}    Run Keyword And Return Status    Lists Should Be Equal    ${alarm_dic1['${alarm_id_list}']['object_name']}
        ...                                                                          ${alarm_dic2['${alarm_id_list}']['object_name']}
        ${new_alarm_detail_list}    Evaluate
        ...    list(set(${alarm_dic2['${alarm_id_list}']['object_name']})-set(${alarm_dic1['${alarm_id_list}']['object_name']}))
        Run Keyword If    not ${alarm_detail} and '${TEST STATUS}'=='PASS'    Run Keyword And Ignore Error
        ...    Common_keywords.Collect Snapshot Log    timeout=${1800}
        Run Keyword If    not ${alarm_detail}    Fail    msg=New fault ${alarm_id_list}***${new_alarm_detail_list} happened, case failed!!!!!
    END

Combine Current Active Alarm With White List Alarm List
    [Documentation]    Author: stella.lin@nokia-sbell.com
    [Arguments]    ${gnb_index}=${0}    ${enb_index}=${0}    ${connection}=alarm_check   ${allowed_faults}=${ALLOWED_FAULT}
    Log Many    ${allowed_faults}    ${gnb_index}
    ${has_enb}    testline_info.has_enb    ${tl}
    ${enb_oam_ip}    Run Keyword If    ${has_enb}    Set Variable If    ${tl.enbs[${enb_index}].airscale}
    ...    ${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}    ${tl.enbs[${enb_index}].oam_ip.v4}
    Run Keyword If    ${tl.gnbs}    Connect to gnb coam via ssl    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl
    ...    bts_host=${enb_oam_ip}    connection=${connection}    username=Nemuadmin    password=nemuuser
    ${active_alarms}    coam.get_active_alarms    connection=${connection}
    ${active_alarms_list_with_faultId}    Evaluate    [{'faultId':x['faultId']} for x in ${active_alarms}]
    ${new_allowed_faults}    Combine Lists    ${active_alarms_list_with_faultId}    ${allowed_faults}
    ${new_allowed_faults}    Remove Duplicates    ${new_allowed_faults}
    [Return]    ${new_allowed_faults}
    [Teardown]  coam.teardown    connection=${connection}


