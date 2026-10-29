*** Settings ***
Documentation
...   author: chris.l.cao@nokia-sbell.com
...   contact: chris.l.cao@nokia-sbell.com
...   common FM keyword

Resource    trans_comm.robot


*** Variables ***
@{FAULT_ID_WHITE_NAME_LIST}      61524   61649  4298
${EMPTY_FAULT_ID}     9999
@{ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}    #prevous existing fault id list, which is assigned before running test case
@{HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}    #prevous existing fault id list, which is assigned before running test case

*** Keyword ***
Alarm Should Contain Fault Message
    [Arguments]   ${message_list}    ${alias}=default
    [Documentation]    Alarm Should Contain Fault Message
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | message_list      | yes | the message to be checked, type is list. if the message is contained in system active alarm, |
    ...    | | | it will not cause the case failure, Otherwise it will cause the case failure. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${message_list} | create list | BFD-$BFDID down  | BFDGRP-$BFDGRPID down |
    ...    | ${robot_prompt_list} |  create list |  There is BFD session fault even all BFD sessions are up!!! |
    ...    | Alarm Should Contain Fault Message | ${message_list} |
    ${message_list_len}    Get Length    ${message_list}
    Should Be True   ${message_list_len}>0    To be checked fault message should be a list!

    ${active_alarmlist}   Get Active Alarm REST   alias=${alias}
    FOR  ${i}  IN   @{message_list}
        Should Be True     "${i}" in """${active_alarmlist}"""
    END


Alarm Should Contain Fault ID
    [Arguments]    ${para_list}
    [Documentation]    Alarm Should Contain Fault ID
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | aliase  | no | alias name, default is 'default' |
    ...    | fault_id_list  | no | the fault id to be checked, keyword return and do nothing if all fault IDs in para_fault_id_list list |
    ...    | | | do appear in webUI. Otherwise it will case case fails. The fault ID 9999 stands for alarm whose fault id is empty. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${para_list} | create list | alias=myalias | 6204 |
    ...    | ${para_list} | create list  | alias=myalias | 6204 | 62152 |
    ...    |${para_list} | create list  | 6204 |
    ...    | ${para_list} | create list  | 6204 | 62152 |
    ...    | Alarm Should Contain Fault ID | para_list=${para_list} |
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator     para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}

    ${alias}  Run Keyword If  "alias" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["alias"]}
    ...   ELSE   set variable  default

    ${active_alarm_info}   Get Active Alarm REST    alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}

    ${actual_faultid_list}   Create List
    FOR    ${i}    IN    @{active_alarm_keys}
         ${FaultId}   Set Variable    '${active_alarm_info[${i}]['fault_id']}'
         Append To List   ${actual_faultid_list}     ${FaultId}
    END

    FOR    ${i}    IN    @{non_key_value_pair_list}
         Run Keyword If    "${i}" not in """${actual_faultid_list}"""   Run Keyword And Continue On Failure   Fail
         ...    ${i} should appear, but actual fault IDs: ('${actual_faultid_list}')!
    END


Alarm Should Not Contain Fault Message
    [Arguments]   ${message_list}   ${alias}=default
    [Documentation]   Alarm Should Not Contain Fault Message
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | message      | yes | the message to be checked, type is list. if the message is contained in system active alarm, it will cause |
    ...    | | | the case failure, Otherwise it will not cause the case failure. |
    ...    | robot_prompt | No | prompt message when the specific message is found |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Alarm Should Not Contain Fault Message | 6204 S1 SCTP path failure | Actually there is no '6204 S1 SCTP path failure' |
    ${message_list_len}    Get Length    ${message_list}
    Should Be True   ${message_list_len}>0   To be checked fault message should be a list!

    ${active_alarmlist}   Get Active Alarm REST   alias=${alias}
    FOR  ${i}  IN    @{message_list}
        Should Be True     "${i}" not in """${active_alarmlist}"""
    END

Alarm Should Not Contain Fault ID
    [Arguments]    ${para_list}
    [Documentation]    Alarm Should Not Contain Fault ID
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | aliase  | no | alias name, default is 'default' |
    ...    | faultid_list  | yes | the fault id to be checked, keyword return and do nothing if all fault IDs in para_fault_id_list list do |
    ...    | | | not appear in webUI. Otherwise it will cause case fails. The fault ID 9999 stands for alarm whose fault id is empty. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${para_list} | create list | alias=myalias | 6204 |
    ...    | ${para_list} | create list | alias=myalias | 6204 | 4459 | 61652 |
    ...    | ${para_list} | create list | alias=myalias |
    ...    | ${para_list} | create list | 4459 |
    ...    | ${para_list} | create list | 4459 | 61652 |
    ...    | Alarm Should Not Contain Fault ID | para_list=${para_list} |

    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}

    ${alias}  Run Keyword If  "alias" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["alias"]}
    ...   ELSE   set variable  default

    ${active_alarm_info}   Get Active Alarm REST   alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}

    FOR    ${i}    IN    @{active_alarm_keys}
        ${FaultId}   Set Variable    '${active_alarm_info[${i}]['fault_id']}'
        ${prmpot}  Set Variable  failt_id:${FaultId} should not appear(fault_name:'${active_alarm_info[${i}]['fault_name']}'
        ${prmpot}  Set Variable  ${prmpot},alarm_id:${active_alarm_info[${i}]['alarm_id']}
        ${prmpot}  Set Variable  ${prmpot},alarming_object:${active_alarm_info[${i}]['alarming_object']})
        Run Keyword If    "${FaultId}" in """${non_key_value_pair_list}"""    Run Keyword And Continue On Failure   Fail   ${prmpot}
    END


Get Active Alarm REST
    [Arguments]  ${alias}=default
    [Documentation]   Get Active Alarm,
    ...   The fault id 9999 stands for alarm whose fault id is empty
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    dictionary contains alarm information, including 'FaultId', e.g,
    ...     {0: {
    ...         'Fault ID':'61652',
    ...         'Severity':'minor',
    ...         'Alarm name':'BASE STATION SECURITY PROBLEM',
    ...         'Fault name':'R&D Service Port enabled',
    ...         'Appeared':'2019-09-26 16:19:39',
    ...         'Number of impacted cells':'See Details window',
    ...         'Alarm ID':'7220',
    ...         'Alarming object':'[5G19B_Classic_AEQA_DZR] MRBTS-3002/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1'    
    ...         }
    ...      1: {
    ...         
    ...         },
    ...      2: {
    ...         
    ...         }
    ...     }

    ...    Example
    ...    | Get Active Alarm REST |
    ${rtn}  Create Dictionary
    ${active_alarm_info}     coam.Get_Active_Alarms   connection=${alias}
    ${active_alarm_length}   Get Length   ${active_alarm_info}
    FOR    ${i}    IN RANGE    0    ${active_alarm_length}
        ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
         ${str_faultId}  Evaluate   str(${tmp_dict['faultId']})
         Set To Dictionary    ${tmp_dict}    fault_id     ${str_faultId}
         #Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['Severity']}
         Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarmName']}
         Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['faultName']}
         Set To Dictionary    ${tmp_dict}    appeared      ${tmp_dict['btsObservationTime']}
         Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarmId']}
         Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['notifier']}
         Log To Console  ${tmp_dict}
         Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END

    [Return]   ${rtn}


Wait Until Alarm Should Not Contain Fault ID Except Known Ones
    [Arguments]    ${count}=60x   ${interval}=10s   ${para_list}=${EMPTY}
    [Documentation]    Wait Until Alarm Should Not Contain Fault ID Except Known Ones
    ...    except 'white name list' of fault id defined in para_known_fault_id
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | count    | yes | check times  |
    ...    | interval | yes | check interval  |
    ...    | para_known_fault_id  | no | the fult id in this list will not cause case to fail. The fault id(s) which is not in this list will |
    ...    | | | cause case failure. it will wait until given times are checked. the default value is defined in global |
    ...    | | | variable @{FAULT_ID_WHITE_NAME_LIST} and @{ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${para_list} | create list | 4459 |
    ...    | ${para_list} | create list | 4459 | 61652 |
    ...    | ${para_list} | create list | alias=myalias |
    ...    | ${para_list} | create list | alias=myalias | 4459 |
    ...    | ${para_list} | create list | alias=myalias | 4459 | 61652 |
    ...    | Wait Until Alarm Should Not Contain Fault ID Except Known Ones | 120s | 10s | para_list=${para_list} |
    ...   | Wait Until Alarm Should Not Contain Fault ID Except Known Ones |
    ...   | Wait Until Alarm Should Not Contain Fault ID Except Known Ones | 120s | 10s |

    ${empty_fault_list}  Run Keyword If   "${EMPTY_FAULT_ID}" not in ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}   Create List  ${EMPTY_FAULT_ID}
    Run Keyword If   "${EMPTY_FAULT_ID}" not in ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}    Wait Until Keyword Succeeds  ${count}   ${interval}
    ...   Alarm Should Not Contain Fault ID     para_list=${empty_fault_list}
    Wait Until Keyword Succeeds  ${count}   ${interval}   Alarm Should Not Contain Fault ID Except Known Ones      para_list=${para_list}


Alarm Should Not Contain Fault ID Except Known Ones
    [Arguments]   ${para_list}=${EMPTY}
    [Teardown]    Run Keyword And Ignore Error  Rest Logout DU
    [Documentation]   Alarm Should Not Contain Fault ID Except Known Ones
    ...    except 'white name list' of fault id defined in para_known_fault_id
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | para_known_fault_id  | no | the fult id in this list will not cause case to fail. The fault id(s) which is not in this list will |
    ...    | | | cause case failure. The default value is defined in global variable @{FAULT_ID_WHITE_NAME_LIST}
    ...    | | | and @{ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Alarm Should Not Contain Fault ID Except Known Ones |
    ...    | ${para_list} | create list | 4459 |
    ...    | ${para_list} | create list | 4459 | 61652 |
    ...    | ${para_list} | create list | alias=myalias |
    ...    | ${para_list} | create list | alias=myalias | 4459 |
    ...    | ${para_list} | create list | alias=myalias | 4459 | 61652 |
    ...    | Alarm Should Not Contain Fault ID Except Known Ones | para_list=${para_list} |
    #run Keyword If   "${EMPTY_FAULT_ID}" not in ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}    wait until keyword succeeds  30x   10s
    # ...   Alarm Should Not Contain Fault ID     ${EMPTY_FAULT_ID}
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator      para_list=${para_list}
    ${len}   Get Length    ${non_key_value_pair_list}
    ${default_para_list}   Run Keyword If  ${len}==0   Combine Lists   ${FAULT_ID_WHITE_NAME_LIST}    ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}
    ${default_para_list}   Run Keyword If  ${len}==0   Unique List  input_list=${default_para_list}
    Log To Console  ${default_para_list}
    Rest Login DU
    Run Keyword If   ${len}>0   _Alarm Should Not Contain Fault ID Except Known Ones_Internal    para_list=${para_list}
    ...   ELSE    _Alarm Should Not Contain Fault ID Except Known Ones_internal    para_list=${default_para_list}


_Alarm Should Not Contain Fault ID Except Known Ones_Internal
    [Arguments]   ${para_list}
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator      para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}

    ${alias}  Run Keyword If  "alias" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["alias"]}
    ...   ELSE   set variable  default

    ${active_alarm_info}   Get Active Alarm REST  alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}

    FOR    ${i}    IN   @{active_alarm_keys}
         ${FaultId}   Set Variable    ${active_alarm_info[${i}]['fault_id']}
         Continue For Loop If     "${FaultId}" in ${non_key_value_pair_list}
         ${prompt}  Set Variable   fault_name:${active_alarm_info[${i}]['fault_name']} and alarm_id:${active_alarm_info[${i}]['alarm_id']}
         ${prompt}  Set Variable  ${prompt} and fault_id:${active_alarm_info[${i}]['fault_id']}
         Run Keyword And Continue On Failure   Fail   '${prompt}' is unexpected!!!
    END


Get Existing Fault Id List
    [Arguments]   ${alias}=default
    #Run Keyword And Ignore Error   Wait Until Keyword Succeeds   1x   0s   Alarm Should Not Contain Fault ID   ${EMPTY_FAULT_ID}
    ${active_alarm_info}   Get Active Alarm REST  alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}
    ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}    Create List

    FOR    ${i}    IN    @{active_alarm_keys}
         ${FaultId}   Set Variable    ${active_alarm_info[${i}]['fault_id']}
         Append To List   ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}   ${FaultId}
    END

    Set Suite Variable     ${ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}


Get History Alarm REST
    [Arguments]  ${alias}=default
    [Documentation]   Get History Alarm REST
    ...   The fault id 9999 stands for alarm whose fault id is empty
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    dictionary contains alarm information, including 'FaultId', e.g,
    ...     {0: {
    ...         'Fault ID':'61652',
    ...         'severity':'minor',
    ...         'Alarm name':'BASE STATION SECURITY PROBLEM',
    ...         'Fault name':'R&D Service Port enabled',
    ...         'Appeared':'2019-09-26 16:19:39',
    ...         'Number of impacted cells':'See Details window',
    ...         'Alarm ID':'7220',
    ...         'Alarming object':'[5G19B_Classic_AEQA_DZR] MRBTS-3002/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1'
    ...         }
    ...      1: {
    ...         },
    ...      2: {
    ...         }
    ...     }

    ...    Example
    ...    | Get History Alarm REST |
    ${rtn}  Create Dictionary
    ${active_alarm_info}     coam.Get_Historic_Alarms  connection=${alias}   timeout=60
    ${active_alarm_length}   Get Length   ${active_alarm_info}
    FOR    ${i}    IN RANGE    0    ${active_alarm_length}
        ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
         ${str_faultId}  Evaluate   str(${tmp_dict['faultId']})
         Set To Dictionary    ${tmp_dict}    fault_id   ${str_faultId}
         Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarmName']}
         Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['faultName']}
         Set To Dictionary    ${tmp_dict}    appeared      ${tmp_dict['btsObservationTime']}
         Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarmId']}
         Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['notifier']}
         Set To Dictionary    ${tmp_dict}    btsLastUpdateTimezone    ${tmp_dict['btsLastUpdateTimezone']}
         Log To Console  ${tmp_dict}
         Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END

    [Return]   ${rtn}


History Alarm WebUI
    [Documentation]   History Alarm WebUI
    ...   The fault id 9999 stands for alarm whose fault id is empty
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    dictionary contains alarm information, including 'FaultId', e.g,
    ...     {0: {
    ...         'Fault ID':'61652',
    ...         'Severity':'minor',
    ...         'Alarm name':'BASE STATION SECURITY PROBLEM',
    ...         'Fault name':'R&D Service Port enabled',
    ...         'Appeared':'2019-09-26 16:19:39',
    ...         'Number of impacted cells':'See Details window',
    ...         'Alarm ID':'7220',
    ...         'Alarming object':'[5G19B_Classic_AEQA_DZR] MRBTS-3002/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1'
    ...         }
    ...      1: {
    ...         },
    ...      2: {
    ...         }
    ...     }

    ...    Example
    ...    | History Alarm WebUI|
    ${rtn}  Create Dictionary
    ${active_alarm_info}    selenium_coam.Get History Alarm Info
    ${active_alarm_length}   Get Length   ${active_alarm_info}
    FOR    ${i}    IN RANGE    0    ${active_alarm_length}
        ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
         Set To Dictionary    ${tmp_dict}    fault_id    ${tmp_dict['Fault ID']}
         Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['Severity']}
         Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['Alarm name']}
         Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['Fault name']}
         Set To Dictionary    ${tmp_dict}    appeared      ${tmp_dict['Appeared']}
         Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['Alarm ID']}
         Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['Alarming object']}
         Log To Console  ${tmp_dict}
         Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END
    [Return]   ${rtn}


History Alarm Should Contain Fault Message
    [Arguments]   ${message_list}   ${alias}=default
    [Documentation]    History Alarm Should Contain Fault Message
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | message_list      | yes | the message to be checked, type is list. if the message is contained in system active alarm, |
    ...    | | | it will not cause the case failure, Otherwise it will cause the case failure. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${message_list} | create list | BFD-$BFDID down  | BFDGRP-$BFDGRPID down |
    ...    | ${robot_prompt_list} |  create list |  There is BFD session fault even all BFD sessions are up!!! |
    ...    | History Alarm Should Contain Fault Message | ${message_list} |

    ${active_alarmlist}   Get History Alarm REST  alias=${alias}
    ${message_list_len}    Get Length    ${message_list}
    Should Be True   ${message_list_len}>0    To be checked fault message should be a list!

    FOR  ${i}  IN   @{message_list}
        Should Be True     "${i}" in """${active_alarmlist}"""
    END


History Alarm Should Not Contain Fault Message
    [Arguments]   ${message_list}  ${alias}=default
    [Documentation]   History Alarm Should Not Contain Fault Message
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | message      | yes | the message to be checked, type is list. if the message is contained in system active alarm, it will cause |
    ...    | | | the case failure, Otherwise it will not cause the case failure. |
    ...    | robot_prompt | No | prompt message when the specific message is found |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...   | History Alarm Should Not Contain Fault Message | 6204 S1 SCTP path failure | Actually there is no '6204 S1 SCTP path failure' |

    ${active_alarmlist}   Get History Alarm REST  alias=${alias}
    ${message_list_len}    Get Length    ${message_list}
    Should Be True   ${message_list_len}>0   To be checked fault message should be a list!

    FOR  ${i}    IN RANGE    ${message_list_len}
         Should Be True     "${message_list[${i}]}" not in """${active_alarmlist}"""
    END


History Alarm Should Not Contain Fault ID Except Known Ones
    [Arguments]   ${para_list}=${EMPTY}
    [Documentation]   History Alarm Should Not Contain Fault ID Except Known Ones
    ...    except 'white name list' of fault id defined in para_known_fault_id
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | para_known_fault_id  | no | the fult id in this list will not cause case to fail. The fault id(s) which is not in this list will |
    ...    | | | cause case failure. The default value is defined in global variable @{FAULT_ID_WHITE_NAME_LIST}
    ...    | | | and @{ACTIVE_FAULT_ID_PREVIOUS_EXISTING_LIST}. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Alarm Should Not Contain Fault ID Except Known Ones |
    ...    | ${para_list} | create list | 4459 |
    ...    | ${para_list} | create list | 4459 | 61652 |
    ...    | ${para_list} | create list | alias=myalias |
    ...    | ${para_list} | create list | alias=myalias | 4459 |
    ...    | ${para_list} | create list | alias=myalias | 4459 | 61652 |
    ...    | History Alarm Should Not Contain Fault ID Except Known Ones | para_list=${para_list} |
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator      para_list=${para_list}
    ${len}   Get Length    ${non_key_value_pair_list}
    ${default_para_list}   Run Keyword If  ${len}==0   Combine Lists   ${FAULT_ID_WHITE_NAME_LIST}    ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}
    ${default_para_list}   Run Keyword If  ${len}==0   Unique List  input_list=${default_para_list}
    Log To Console  ${default_para_list}

    Run Keyword If   ${len}>0   _History Alarm Should Not Contain Fault ID Except Known Ones_Internal    para_list=${para_list}
    ...   ELSE    _History Alarm Should Not Contain Fault ID Except Known Ones_internal    para_list=${default_para_list}


_History Alarm Should Not Contain Fault ID Except Known Ones_Internal
    [Arguments]   ${para_list}
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator      para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}

    ${alias}  Run Keyword If  "alias" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["alias"]}
    ...   ELSE   set variable  default

    ${active_alarm_info}   Get History Alarm REST   alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}

    FOR    ${i}    IN   @{active_alarm_keys}
         ${FaultId}   Set Variable    ${active_alarm_info[${i}]['fault_id']}
         Continue For Loop If     "${FaultId}" in ${non_key_value_pair_list}
         ${prompt}  Set Variable   fault_name:${active_alarm_info[${i}]['fault_name']} and alarm_id:${active_alarm_info[${i}]['alarm_id']}
         Run Keyword And Continue On Failure   Fail
         ...   '${prompt}' is unexpected!!!
    END


History Alarm Should Not Contain Fault ID
    [Arguments]    ${para_list}
    [Documentation]    History Alarm Should Not Contain Fault ID
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | para_fault_id_list  | yes | the fault id to be checked, keyword return and do nothing if all fault IDs in para_fault_id_list list do |
    ...    | | | not appear in webUI. Otherwise it will cause case fails. The fault ID 9999 stands for alarm whose fault id is empty. |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | ${para_list} | create list | alias=myalias | 6204 |
    ...    | ${para_list} | create list | alias=myalias | 6204 | 4459 | 61652 |
    ...    | ${para_list} | create list | alias=myalias |
    ...    | ${para_list} | create list | 4459 |
    ...    | ${para_list} | create list | 4459 | 61652 |
    ...    | History Alarm Should Not Contain Fault ID  | para_list=${para_list} |

    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator      para_list=${para_list}
    ${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}
    ${alias}  Run Keyword If  "alias" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["alias"]}
    ...   ELSE   set variable  default

    ${active_alarm_info}   Get History Alarm REST  alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}

    FOR    ${i}    IN    @{active_alarm_keys}
        ${FaultId}   Set Variable    '${active_alarm_info[${i}]['fault_id']}'
        ${prmpot}  Set Variable  failt_id:${FaultId} should not appear(fault_name:'${active_alarm_info[${i}]['fault_name']}'
        ${prmpot}  Set Variable  ${prmpot},alarm_id:${active_alarm_info[${i}]['alarm_id']}
        ${prmpot}  Set Variable  ${prmpot},alarming_object:${active_alarm_info[${i}]['alarming_object']})
        Run Keyword If    "${FaultId}" in """${non_key_value_pair_list}"""    Run Keyword And Continue On Failure   Fail   ${prmpot}
    END


Get Existing History Fault Id List
    [Arguments]   ${alias}=default
    ${active_alarm_info}   Get History Alarm REST  alias=${alias}
    ${active_alarm_keys}   Set Variable  ${active_alarm_info.keys()}
    ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}    Create List

    FOR    ${i}    IN    @{active_alarm_keys}
         Append To List   ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}   ${active_alarm_info[${i}]['fault_id']}
    END
    ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}   Unique List   input_list=${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}
    Set Suite Variable     ${HISTORY_FAULT_ID_PREVIOUS_EXISTING_LIST}


Confirm Alarm Is Normal
    [Teardown]   Run Keyword And Ignore Error  Rest Logout DU
    Rest Login DU
    Wait Until Alarm Should Not Contain Fault ID Except Known Ones
    Rest Login DU
    History Alarm Should Not Contain Fault ID Except Known Ones