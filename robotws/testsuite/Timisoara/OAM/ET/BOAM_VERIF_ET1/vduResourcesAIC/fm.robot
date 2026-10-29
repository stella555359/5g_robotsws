*** Settings ***
Documentation     [PURPOSE] Fault management related


#*** Variables ***


*** Keywords ***
No New Active Alarm Should Be Generated
    #[Arguments]    ${active_alarm_list_before_cu}=None  ${active_alarm_list_before_du}=None  ${active_alarm_list_before_fhgw}=None
    log to console  *** tbd **

############################## CU FM Start ##############################
====== CU FM Start ======
     log to console  \n*** only used for readable ***
CU Get Active Alarms
    #[Arguments]  ${gnb_index}=0
    [Documentation]  Gets active alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |
        ...
        ...    *RETURN VALUE*
        ...    Active alarm list
        ...    Example
        ...    |  Get CU Active Alarm	 |    |
#     CU Rest Login  ${gnb_index}
     ${active_alarm_list}=  cu.get_active_alarms    page_number=${1}     items_per_page=${1000}
     ${num_of_alarms}=   get length     ${active_alarm_list["alarms"]}
     run keyword and continue on failure   should be equal as integers    ${num_of_alarms}    ${active_alarm_list["total"]}
     ...    There should be ${active_alarm_list["total"]} active alarms, but actually got ${num_of_alarms}
     [Return]     ${active_alarm_list["alarms"]}
     #[Teardown]  run keyword and ignore error   CU Rest Logout

CU Get Historical Alarms
    #[Arguments]  ${gnb_index}=0   #${use_m2m}=True
    [Documentation]   Gets historic alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |

        ...    *RETURN VALUE*
        ...    History alarm list
        ...    Example
        ...    |  Get CU History Alarm	 |    |
#    CU Login  ${gnb_index}
    ${historical_alarm_list}=  cu.get_historical_alarms    page_number=${1}     items_per_page=${10000}    #use_m2m=${use_m2m}
    ${num_of_alarms}=   get length     ${historical_alarm_list["alarms"]}
    run keyword and continue on failure   should be equal as integers    ${num_of_alarms}    ${historical_alarm_list["total"]}
     ...    There should be ${historical_alarm_list["total"]} historical alarms, but actually got ${num_of_alarms}
    [Return]    ${historical_alarm_list["alarms"]}
   #[Teardown]  run keyword and ignore error    CU Logout


VCU Active Alarm Should Contain Alarm ID
		[Arguments]  @{para_list}
		[Documentation]    VCU Active Alarm Should Contain Alarm ID
		...    author: winnie.su@nokia-sbell.com
		...    | Input Parameters | Man. | Description |
		...    | para_list  | yes | alarm id list or gnb_index, please see example |
		...
		...    *RETURN VALUE*
		...    None
		...
		...    Example
		...    | VCU Active Alarm Should Contain Alarm ID | 61652 |
		...    | VCU Active Alarm Should Contain Alarm ID | 61651 | 61652 |
		...    | VCU Active Alarm Should Contain Alarm ID | 61651 | 61652 | gnb_index=0 |
		...
		${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
		${key_value_dict_keys}   evaluate  list(${key_value_dict})
		${alarm_id_list}   set variable   ${non_key_value_pair_list}

		${gnb_index}  Run Keyword If  "gnb_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["gnb_index"]}
		...   ELSE   set variable  0

		${active_alarm_info}  VCU Get Active Alarm REST   gnb_index=${gnb_index}
		${active_alarm_keys}    evaluate  list(${active_alarm_info})


		${actual_alarmid_list}   Create List
		FOR    ${i}    IN    @{active_alarm_keys}
		   ${i}  convert to string  ${i}
		   ${i}   set variable  "${i}"
		   ${AlarmId}   Set Variable    '${active_alarm_info[${i}]['alarm_id']}'
		   Append To List   ${actual_alarmid_list}     ${AlarmId}
        END

		FOR    ${i}    IN    @{non_key_value_pair_list}
		    Run Keyword If    "${i}" not in """${actual_alarmid_list}"""   Run Keyword And Continue On Failure   Fail
		    ...    ${i} should appear, but actual alarm IDs are: ('${actual_alarmid_list}')!
        END


VCU Active Alarm Should Not Contain Alarm ID
		[Arguments]  @{para_list}
		[Documentation]    VCU Active Alarm Should Not Contain Alarm ID
		...    author: winnie.su@nokia-sbell.com
		...    | Input Parameters | Man. | Description |
		...    | para_list  | yes | alarm id list or gnb_index, please see example |
		...
		...    *RETURN VALUE*
		...    None
		...
		...    Example
		...    | VCU Active Alarm Should Not Contain Alarm ID | 61652 |
		...    | VCU Active Alarm Should Not Contain Alarm ID | 61651 | 61652 |
		...    | VCU Active Alarm Should Not Contain Alarm ID | 61651 | 61652 | gnb_indexx=0 |
		...
		${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
		${key_value_dict_keys}   evaluate  list(${key_value_dict})
		${alarm_id_list}   set variable   ${non_key_value_pair_list}

		${gnb_index}  Run Keyword If  "gnb_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["gnb_index"]}
		...   ELSE   set variable  0

		${active_alarm_info}  VCU Get Active Alarm REST   gnb_index=${gnb_index}
		#print a dictionary  ${active_alarm_info}
		${active_alarm_keys}    evaluate  list(${active_alarm_info})

		FOR    ${i}    IN    @{active_alarm_keys}
		   ${i}  convert to string  ${i}
		   ${i}   set variable  "${i}"
		   ${AlarmId}   Set Variable    '${active_alarm_info[${i}]['alarm_id']}'
		   ${prmpot}  Set Variable  failt_id:${AlarmId} should not appear(alarm_name:'${active_alarm_info[${i}]['alarm_name']}'
		   ${prmpot}  Set Variable  ${prmpot},alarm_id:${active_alarm_info[${i}]['alarm_id']}
		   ${prmpot}  Set Variable  ${prmpot},alarming_object:${active_alarm_info[${i}]['alarming_object']})
		   Run Keyword If    "${AlarmId}" in """${alarm_id_list}"""    Run Keyword And Continue On Failure   Fail   ${prmpot}
        END

VCU Get Active Alarm REST
    #[Arguments]  ${gnb_index}=0
    [Documentation]  VCU Get Active Alarm REST
    ...    author: winnie.su@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    dictionary contains alarm information, including 'FaultId', e.g,
    ...     {0: {
    ...         'fault_id':'61652',
    ...         'severity':'minor',
    ...         'alarm_name':'BASE STATION SECURITY PROBLEM',
    ...         'fault_name':'R&D Service Port enabled',
    ...         'last_updated_time':'2019-09-26 16:19:39',
    ...         'additional_info':'See Details window',
    ...         'alarm_id':'7220',
    ...         'alarming_object':'[5G19B_Classic_AEQA_DZR] MRBTS-3002/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1',
    ...         'event_type_name':'addfafd',
    ...         'probable_cause_name':'a354afdafd'

    ...         }
    ...      1: {
    ...
    ...         },
    ...      2: {
    ...
    ...         }
    ...     }
    ...

    ...    Example
    ...    | VCU Get Active Alarm REST |
    ...
    run keyword and ignore error  CU Rest Logout
#    CU Rest Login   gnb_index=${gnb_index}
    ${rtn}  Create Dictionary
    ${out}    cu.get_active_alarms  #use_m2m=${False}
    ${active_alarm_length}   set variable   ${out["total"]}
    ${active_alarm_info}   set variable    ${out["alarms"]}
    FOR    ${i}    IN RANGE    0     ${active_alarm_length}
       ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
        Set To Dictionary    ${tmp_dict}    additional_info   ${tmp_dict['additional_info']}
        Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarm_id']}
        Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarm_name']}
        Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['alarming_object']}
        Set To Dictionary    ${tmp_dict}    appear_time      ${tmp_dict['appear_time']}
        Set To Dictionary    ${tmp_dict}    event_type_name    ${tmp_dict['event_type_name']}
        Set To Dictionary    ${tmp_dict}    fault_id      ${tmp_dict['fault_id']}
        Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['fault_name']}
        Set To Dictionary    ${tmp_dict}    last_updated_time    ${tmp_dict['last_updated_time']}
        Set To Dictionary    ${tmp_dict}    probable_cause_name    ${tmp_dict['probable_cause_name']}
        Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['severity']}
        ${i}  convert to string  ${i}
        Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END
    log to console   ${rtn}
    [Return]   ${rtn}

VCU Get Active Alarm Fault by REST API
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  can be used on jenkins
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    alarms
    ...
    ...    Example
    ...    | ${alarms} | Get Active Alarm Fault by REST API |
    ${vcu_get_active_alarms}    cu.get_active_alarms
    Log To Console    Active alarms:
    ${alarms}    Get From Dictionary    ${vcu_get_active_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
        Log To Console   AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}

VCU Get Historical Alarm Fault By REST API
    [Documentation]  Login WebUI And Get Alarm Fault by Jenknis
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | OAM_IP | yes | e.g, 10.56.126.210 |
    ...    | USER | yes | e.g, Nemuadmin |
    ...    | PASSWORD | yes | e.g, nemuuser |
    ...
    ...    *RETURN VALUE*
    ...    alarms
    ...
    ...    Example
    ...   | alarms= Login WebUI And Get Historical Alarm Fault by Jenknis | OAM_IP=10.56.125.210 | USER=Nemuadmin | PASSWORD=nemuuser |
    ${vcu_get_historical_alarms}    cu.get_historical_alarms
    Log To Console    Historical alarms:
    ${alarms}    Get From Dictionary    ${vcu_get_historical_alarms}    alarms
    FOR    ${his_alarm}    IN    @{alarms}
        Log To Console   FaultId: ${his_alarm['fault_id']}; FaultName: ${his_alarm['fault_name']}; AlarmId: ${his_alarm['alarm_id']};
        Log To Console   AlarmName: ${his_alarm['alarm_name']}; AlarmingObject: ${his_alarm['alarming_object']}; Severity: ${his_alarm['severity']}
    END
    [Return]        ${alarms}

VCU Check Active Alarm Should Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  VCU Check Active Alarm Should contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Active Alarm Should contain Fault | FAULT_ID=23 |
    ${alarm_list}=  VCU Get Active Alarm Fault by REST API
    should contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'

VCU Check Active Alarm Should Not Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Active Alarm Should Not contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Active Alarm Should Not contain Fault | FAULT_ID=23 |
    ${alarm_list}=  VCU Get Active Alarm Fault by REST API
    should not contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'

VCU Check Active Alarm No Fault
    ${alarm_list}=  VCU Get Active Alarm Fault by REST API
    should not contain    '@{alarm_list}'    'fault_id'

VCU Check Historical Alarm Should Contain Fault
    [Arguments]     ${FAULT_ID}
    [Documentation]  Check Historical Alarm Should contain Fault
    ...  author: qixuan.zhang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...   | Check Historical Alarm Should contain Fault | FAULT_ID=23 |
    ${alarm_list}=  VCU Get Historical Alarm Fault By REST API
    should contain    '@{alarm_list}'    'fault_id': '${FAULT_ID}'

VCU History Alarm Should Contain Fault ID
    [Arguments]  @{para_list}
    [Documentation]   VDU History Alarm Should Contain Fault ID
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | aliase  | no | alias name, default is 'default' |
    ...    | fault_id_list  | no | the fault id to be checked, keyword return and do nothing if all fault IDs in para_fault_id_list list |
    ...    | | | do appear in webUI. Otherwise it will case case fails. The fault ID 9999 stands for alarm whose fault id is empty. |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU History Alarm Should Contain Fault ID | 1234 |
    ${non_key_value_pair_list}   ${key_value_dict}   cm._Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})
    ${out}   cu.get_historical_alarms    page_number=${1}     items_per_page=${10000}

CU Alarm Should Exist In Active Alarms
    [Arguments]   ${fault_id}=${None}    ${fault_name}=${None}   ${alarm_id}=${None}  ${alarm_name}=${None}    ${gnb_index}=0
    [Documentation]   Check specified alarm exists in active alarm list by alarm id or fault name or fault id or alarm name.
        ...    author:  fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  fault_id | No |  Fault id |
        ...    |  fault_name | No |  Fault name  |
        ...	   |  alarm_id | No | Alarm ID  |
        ...    |  alarm_name | No |  Alarm name  |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Alarm Should Exist In Active Alarms  |   alarm_id=7665  |
        ...    |  CU Alarm Should Exist In Active Alarms  |   fault_name=BB bus reception error (summing device1)  |
        ${alarm_info}=  run keyword and continue on failure   CU Get Active Alarms  ${gnb_index}
        ${result}=   check alarm   ${alarm_info}   ${fault_id}   ${fault_name}  ${alarm_id}  ${alarm_name}
        should be true   "${result}"=="True"   Expected active alarm is not found!

CU Alarm Should Exist In Historical Alarms
    [Arguments]   ${fault_id}=${None}  ${fault_name}=${None}   ${alarm_id}=${None}   ${alarm_name}=${None}  ${gnb_index}=0   #${use_m2m}=True
    [Documentation]  Check specified alarm exists in historical alarm list by alarm id or fault name or fault id or alarm name.
        ...    author:   fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  fault_id | No |  Fault id |
        ...    |  fault_name | No |  Fault name |
        ...	   |  alarm_id | No | Alarm ID |
        ...    |  alarm_name | No |  Alarm name |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
        ...    |  use_m2m  | No |  use_m2m to indicate whether enable m2m or not, True in default  |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Alarm Should Exist In Historical Alarms  |   alarm_id=7665  |
        ...    |  CU Alarm Should Exist In Historical Alarms  |   fault_name=BB bus reception error (summing device1)  |
     ${alarm_info}=   run keyword and continue on failure  CU Get Historical Alarms  ${gnb_index}   #use_m2m=${use_m2m}
     ${result}=    check alarm     ${alarm_info}    ${fault_id}   ${fault_name}   ${alarm_id}   ${alarm_name}
     should be true   "${result}"=="True"   Expected historical alarm is not found!

CU Alarm Should Not Exist In Active Alarms
    [Arguments]    ${fault_id}=${None}  ${fault_name}=${None}   ${alarm_id}=${None}   ${alarm_name}=${None}  ${gnb_index}=0
    [Documentation]  Check specified alarm doesn't exist in active alarm list by alarm id or fault name or fault id or alarm name.
        ...    author:  fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  fault_id | No |  Fault id |
        ...    |  fault_name | No |  Fault name  |
        ...	   |  alarm_id | No | Alarm ID |
        ...    |  alarm_name | No |  Alarm name |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Alarm Should Not Exist In Active Alarms  |   alarm_id=7107  |  alarm_name=ETHERNET LINK FAILURE |
        ...    |  CU Alarm Should Not Exist In Active Alarms  |   fault_name=BB bus reception error (summing device1)  |
        ${alarm_info}=  CU Get Active Alarms  ${gnb_index}
        ${result}=    check alarm     ${alarm_info}    ${fault_id}   ${fault_name}   ${alarm_id}   ${alarm_name}
        should be true   "${result}"=="False"   Active alarm should not be found!

CU Alarm Should Not Exist In Historical Alarms
    [Arguments]    ${fault_id}=${None}  ${fault_name}=${None}   ${alarm_id}=${None}   ${alarm_name}=${None}  ${gnb_index}=0
    [Documentation]   Check specified alarm doesn't exist in historical alarm list by alarm id or fault name or fault id or alarm name.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  fault_id | No |  Fault id |
        ...    |  fault_name | No |  Fault name |
        ...	   |  alarm_id | No | Alarm ID |
        ...    |  alarm_name | No |  Alarm name |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Alarm Should Not Exist In Historical Alarms  |   alarm_id=7665  |
        ...    |  CU Alarm Should Not Exist In Historical Alarms  |   fault_name=BB bus reception error (summing device1)  |
     ${alarm_info}=  CU Get Historical Alarms  ${gnb_index}
     ${result}=    check alarm     ${alarm_info}    ${fault_id}   ${fault_name}   ${alarm_id}   ${alarm_name}
     should be true   "${result}"=="False"   Historical alarm should not be found!

CU No New Active Alarm Should Be Generated
    [Arguments]    ${initial_active_alarm_list}=${ACTIVE_ALARM_LST_PRE_CU}  ${gnb_index}=0
    [Documentation]    Check no new active alarms raised  by comparing current and initial alarm list.
    ...    author:  fen.huang@nokia-sbell.com
    ...    modified by:   <19-Nov-2019>, <f2huang>, <Initial creation>
    ...    |    Input Parameters    | Man. |    Description    |
    ...    | ${initial_active_alarm_list} | YES  | Acitve alarm list before operation |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | No New Active Alarm Should Be Generated | ${active_alarm_list_before} |
    log to console   \n*** Check no new active alarms raised ***
    ${current_active_alarm_list}=   run keyword and continue on failure  CU Get Active Alarms   ${gnb_index}
    remove values from list    ${current_active_alarm_list}   @{initial_active_alarm_list}
    ${new_active_alarm_list}=    set variable   ${current_active_alarm_list}
    ${case_level_ignored_alarms}=   get variable value  ${CASE_LEVEL_IGNORED_ALARM_LIST}
    @{total_ignored_alarm_list}=   run keyword if    "${case_level_ignored_alarms}"!="None"
    ...  combine lists    ${IGNORED_ALARM_LIST}    ${case_level_ignored_alarms}
    ...  ELSE   set variable   ${IGNORED_ALARM_LIST}
    sort list   ${total_ignored_alarm_list}
    #${total_ignored_alarm_list}=    evaluate   list(set( ${total_ignored_alarm_list}))
    ${alarms}=  ignore known alarms   ${new_active_alarm_list}   ${total_ignored_alarm_list}
    ${number_of_new_alarms}=   get length    ${new_active_alarm_list}
    run keyword and continue on failure  should be equal as numbers
     ...  	${number_of_new_alarms}  ${0}   There are some unexpected active alarms raised!

CU No New Historical Alarm Should Be Generated
    [Arguments]    ${initial_history_alarm_list}=${HISTORICAL_ALARM_LST_PRE_CU}   ${gnb_index}=0
    [Documentation]    Check no new history alarms raised  by comparing current and initial alarm list.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <Initial creation>
        ...    |  initial_history_alarm_list | No |  Initial history alarm list |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU No New History Alarm Should Be Generated |   ${initial_history_alarm_list}  |
    log to console   \n*** Check no new historical alarms raised ***
    ${current_history_alarm_list}=   run keyword and continue on failure  CU Get Historical Alarms   ${gnb_index}
    remove values from list    ${current_history_alarm_list}   @{INITIAL_HISTORY_ALARM_LIST}
    ${new_history_alarm_list}=    set variable   ${current_history_alarm_list}
    ${case_level_ignored_alarms}=   get variable value  ${CASE_LEVEL_IGNORED_ALARM_LIST}
    @{total_ignored_alarm_list}=   run keyword if    "${case_level_ignored_alarms}"!="None"
    ...    combine lists    ${IGNORED_ALARM_LIST}    ${case_level_ignored_alarms}
    ...  ELSE   set variable   ${IGNORED_ALARM_LIST}
    sort list   ${total_ignored_alarm_list}
    #${total_ignored_alarm_list}=    evaluate   list(set( ${total_ignored_alarm_list}))
    ${alarms}=  ignore known alarms    ${new_history_alarm_list}   ${total_ignored_alarm_list}
    ${number_of_new_alarms}=   get length    ${new_history_alarm_list}
    run keyword and continue on failure  should be equal as numbers
     ...  	${number_of_new_alarms}  ${0}   There are some unexpected history alarms raised!

Trigger Container Crash via kill process
    [Arguments]    ${container}    ${pod_name}    ${vdu_index}=0    ${alias}=default
    [Documentation]  crash the container by kill the process.
        ...    author: rita.feng@nokia-sbell.com
        ...    modified by:   <3-Sep-2020>, <rifeng>, <e.g. PR-Number, feature number>
        ...    modified by:   <4-Dec-2020>, <rifeng>, <e.g. kill pid>
        ...    | Input Parameters | Man. | Description |
        ...    | pod_name   |  yes | pod abbreviation, e.g, oamcp, up |
        ...    | vdu_index  |  no  | VDU index, default is 0 |
        ...    | alias      | no   | alias, default value is default |
        ...    | container | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
        ...    *RETURN VALUE*
        ...    connection instance to k8s
        ...    Example
        ...    |  Trigger Container Crash via kill process    |  pod_name=oamcp  | container=oamfh |
    Connect To VDU Node Interactively   pod_abbr=${pod_name}   vdu_index=${vdu_index}   alias=${alias}
    ${pod_name}   Get Full Pod Name By Pod Abbreviation   ${pod_name}
    ${container}   Get Full Container Name By Container Abbreviation   ${container}
    ${ns}   Get VDU Namespace From TestLine    vdu_index=${vdu_index}
    ${cmd}    set variable    kubectl exec -it ${pod_name} -c ${container} -n ${ns} -- ps aux |grep mini | awk '{print $2}'
    ${out}    issh.Execute    ${cmd}   alias=${alias}
    ${out}    Split String     ${out}
    ${kill_cmd}    set variable    kubectl exec -it ${pod_name} -c ${container} -n ${ns} -- bash -c "kill ${out[0]}"
    issh.Execute    ${kill_cmd}    alias=${alias}
    [Return]  ${alias}

############################## CU FM End ##############################
====== CU FM End ======
     log to console  \n*** only used for readable ***


############################## vDU FM Start ##############################
====== vDU FM Start ======
     log to console  \n*** only used for readable ***
vDU Get Active Alarms In Typical Object
    #[Arguments]  ${alarm_object}
    [Documentation]  Gets active alarms in typical object like cell/du/rmod
    ...    author: calla.wang@nokia-sbell.com
    ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
    ...    | Input Parameters | Man. | Description |
    ...    | alarm_object | alarm objects category-Available values : cells, dus, vnfcs, x2links, rmods |
    ...    *RETURN VALUE*
    ...    alarm list
    log to console  \n*** get active alarm in given object ***


VDU Active Alarm Should Contain Fault ID
    [Arguments]  @{para_list}
    [Documentation]    VDU Active Alarm Should Contain Fault ID
    ...    author: chris.l.cao@nokia-sbell.com
    ...    20.10.2021,shubin.Ren@nokia-sbell.com, support username and password
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | yes | fauld id list or vdu_index, please see example |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Active Alarm Should Contain Fault ID | 61652 |
    ...    | VDU Active Alarm Should Contain Fault ID | 61651 | 61652 |
    ...    | VDU Active Alarm Should Contain Fault ID | 61651 | 61652 | vdu_index=0 |
    ...    | VDU Active Alarm Should Contain Fault ID | 61651 | 61652 | password=nemuuser | vdu_index=0 |
    ...    | VDU Active Alarm Should Contain Fault ID | 61651 | 61652 | username= Nemuadmin | password=nemuuser | vdu_index=0 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})
    ${fault_id_list}   set variable   ${non_key_value_pair_list}
    ${http_username}  Run Keyword If  "username" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["username"]}
    ...  ELSE  set variable  ${Empty}
    ${http_password}  Run Keyword If  "password" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["password"]}
    ...  ELSE  set variable  ${Empty}
    ${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
    ...   ELSE   set variable  0

    ${active_alarm_info}  VDU Get Active Alarm REST   vdu_index=${vdu_index}   username=${http_username}  password=${http_password}
    ${active_alarm_keys}    evaluate  list(${active_alarm_info})


    ${actual_faultid_list}   Create List
    FOR    ${i}    IN    @{active_alarm_keys}
       ${i}  convert to string  ${i}
       ${i}   set variable  "${i}"
       ${FaultId}   Set Variable    '${active_alarm_info[${i}]['fault_id']}'
       Append To List   ${actual_faultid_list}     ${FaultId}
    END

    FOR    ${i}    IN    @{non_key_value_pair_list}
        Run Keyword If    "${i}" not in """${actual_faultid_list}"""   Run Keyword And Continue On Failure   Fail
        ...    ${i} should appear, but actual fault IDs are: ('${actual_faultid_list}')!
    END


VDU Active Alarm Should Not Contain Fault ID
    [Arguments]  @{para_list}
    [Documentation]    VDU Active Alarm Should Not Contain Fault ID
    ...    author: chris.l.cao@nokia-sbell.com
    ...    20.10.2021,shubin.Ren@nokia-sbell.com, support username and password
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | yes | fauld id list or vdu_index, please see example |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU Active Alarm Should Not Contain Fault ID | 61652 |
    ...    | VDU Active Alarm Should Not Contain Fault ID | 61651 | 61652 |
    ...    | VDU Active Alarm Should Not Contain Fault ID | 61651 | 61652 | vdu_index=0 |
    ...    | VDU Active Alarm Should Not Contain Fault ID | 61651 | 61652 | password=nemuuser | vdu_index=0 |
    ...    | VDU Active Alarm Should Not Contain Fault ID | 61651 | 61652 | username= Nemuadmin | password=nemuuser | vdu_index=0 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})
    ${fault_id_list}   set variable   ${non_key_value_pair_list}

    ${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
    ...   ELSE   set variable  0
    ${http_username}  Run Keyword If  "username" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["username"]}
    ...  ELSE  set variable  ${Empty}
    ${http_password}  Run Keyword If  "password" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["password"]}
    ...  ELSE  set variable  ${Empty}
    ${active_alarm_info}  VDU Get Active Alarm REST   vdu_index=${vdu_index}  username=${http_username}  password=${http_password}
    #print a dictionary  ${active_alarm_info}
    ${active_alarm_keys}    evaluate  list(${active_alarm_info})

    FOR    ${i}    IN    @{active_alarm_keys}
       ${i}  convert to string  ${i}
       ${i}   set variable  "${i}"
       ${FaultId}   Set Variable    '${active_alarm_info[${i}]['fault_id']}'
       ${prmpot}  Set Variable  failt_id:${FaultId} should not appear(fault_name:'${active_alarm_info[${i}]['fault_name']}'
       ${prmpot}  Set Variable  ${prmpot},alarm_id:${active_alarm_info[${i}]['alarm_id']}
       ${prmpot}  Set Variable  ${prmpot},alarming_object:${active_alarm_info[${i}]['alarming_object']})
       Run Keyword If    "${FaultId}" in """${fault_id_list}"""    Run Keyword And Continue On Failure   Fail   ${prmpot}
    END


VDU Active Alarm Should Contain Alarm ID
		[Arguments]  @{para_list}
		[Documentation]    VDU Active Alarm Should Contain Alarm ID
		...    author: shubin.ren@nokia-sbell.com
                ...    history change: <date>,<who>,<what and how>
                ...    20.10.2021,shubin.Ren@nokia-sbell.com, add username
                ...    | Input Parameters | Man. | Description |
		...    | para_list  | yes | fauld id list or vdu_index, please see example |
		...
		...    *RETURN VALUE*
		...    None
		...
		...    Example
		...    | VDU Active Alarm Should Contain Alarm ID | 61652 |
		...    | VDU Active Alarm Should Contain Alarm ID | 61651 | 61652 |
		...    | VDU Active Alarm Should Contain Alarm ID | 61651 | 61652 | vdu_index=0 |
                ...    | VDU Active Alarm Should Contain Alarm ID | 61651 | 61652 | username= Nemuadmin | password=nemuuser | vdu_index=0 |
		...
		${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
		${key_value_dict_keys}   evaluate  list(${key_value_dict})
		${alarm_id_list}   set variable   ${non_key_value_pair_list}

		${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
		...   ELSE   set variable  0
                ${http_username}  Run Keyword If  "username" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["username"]}
                ...  ELSE  set variable  ${Empty}
                 ${http_password}  Run Keyword If  "password" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["password"]}
                ...  ELSE  set variable  ${Empty}
		${active_alarm_info}  VDU Get Active Alarm REST   vdu_index=${vdu_index}  username=${http_username}  password=${http_password}
		${active_alarm_keys}    evaluate  list(${active_alarm_info})


		${actual_alarmid_list}   Create List
		FOR    ${i}    IN    @{active_alarm_keys}
		   ${i}  convert to string  ${i}
		   ${i}   set variable  "${i}"
		   ${AlarmId}   Set Variable    '${active_alarm_info[${i}]['alarm_id']}'
		   Append To List   ${actual_alarmid_list}     ${AlarmId}
        END

		FOR    ${i}    IN    @{non_key_value_pair_list}
		    Run Keyword If    "${i}" not in """${actual_alarmid_list}"""   Run Keyword And Continue On Failure   Fail
		    ...    ${i} should appear, but actual alarm IDs are: ('${actual_alarmid_list}')!
        END


VDU Active Alarm Should Not Contain Alarm ID
		[Arguments]  @{para_list}
		[Documentation]    VDU Active Alarm Should Not Contain Alarm ID
		...    author: shubin.ren@nokia-sbell.com
                ...  20.10.2021,shubin.Ren@nokia-sbell.com, add username
		...    | Input Parameters | Man. | Description |
		...    | para_list  | yes | fauld id list or vdu_index, please see example |
		...
		...    *RETURN VALUE*
		...    None
		...
		...    Example
		...    | VDU Active Alarm Should Not Contain Alarm ID | 61652 |
		...    | VDU Active Alarm Should Not Contain Alarm ID | 61651 | 61652 |
		...    | VDU Active Alarm Should Not Contain Alarm ID | 61651 | 61652 | vdu_index=0 |
		...   | VDU Active Alarm Should Not Contain Alarm ID | 61651 | 61652 | username= Nemuadmin | password=nemuuser | vdu_index=0 |
		...
		${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
		${key_value_dict_keys}   evaluate  list(${key_value_dict})
		${alarm_id_list}   set variable   ${non_key_value_pair_list}
        ${http_username}  Run Keyword If  "username" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["username"]}
        ...  ELSE  set variable  ${Empty}
        ${http_password}  Run Keyword If  "password" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["password"]}
        ...  ELSE  set variable  ${Empty}
 		${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
		...   ELSE   set variable  0

		${active_alarm_info}  VDU Get Active Alarm REST   vdu_index=${vdu_index}  username=${http_username}  password=${http_password}
		#print a dictionary  ${active_alarm_info}
		${active_alarm_keys}    evaluate  list(${active_alarm_info})

		FOR    ${i}    IN    @{active_alarm_keys}
		   ${i}  convert to string  ${i}
		   ${i}   set variable  "${i}"
		   ${AlarmId}   Set Variable    '${active_alarm_info[${i}]['alarm_id']}'
		   ${prmpot}  Set Variable  failt_id:${AlarmId} should not appear(alarm_name:'${active_alarm_info[${i}]['alarm_name']}'
		   ${prmpot}  Set Variable  ${prmpot},alarm_id:${active_alarm_info[${i}]['alarm_id']}
		   ${prmpot}  Set Variable  ${prmpot},alarming_object:${active_alarm_info[${i}]['alarming_object']})
		   Run Keyword If    "${AlarmId}" in """${alarm_id_list}"""    Run Keyword And Continue On Failure   Fail   ${prmpot}
        END


VDU Get Active Alarm REST
    [Arguments]  ${vdu_index}=0  ${username}=${EMPTY}  ${password}=${EMPTY}
    [Documentation]  VDU Get Active Alarm REST
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    dictionary contains alarm information, including 'FaultId', e.g,
    ...     {0: {
    ...         'fault_id':'61652',
    ...         'severity':'minor',
    ...         'alarm_name':'BASE STATION SECURITY PROBLEM',
    ...         'fault_name':'R&D Service Port enabled',
    ...         'last_updated_time':'2019-09-26 16:19:39',
    ...         'additional_info':'See Details window',
    ...         'alarm_id':'7220',
    ...         'alarming_object':'[5G19B_Classic_AEQA_DZR] MRBTS-3002/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1',
    ...         'event_type_name':'addfafd',
    ...         'probable_cause_name':'a354afdafd'

    ...         }
    ...      1: {
    ...
    ...         },
    ...      2: {
    ...
    ...         }
    ...     }
    ...

    ...    Example
    ...    | VDU Get Active Alarm REST |
    ...
    run keyword and ignore error  vdu rest logout  vdu_index=${vdu_index}
    ${http_username}  Run Keyword If  "${username}"=="${EMPTY}"  set variable  ${Empty}
    ...  ELSE  set variable  ${username}
    ${http_password}  Run Keyword If  "${password}"=="${EMPTY}"   Set Variable  ${Empty}
    ...  ELSE  set variable  ${password}
    vDU Rest Login
#    vDU Rest Login With Special Password   vdu_index=${vdu_index}  username=${http_username}  password=${http_password}
    ${rtn}  Create Dictionary
    ${out}    vdu.vdu_get_active_alarms
    ${active_alarm_length}   set variable   ${out["total"]}
    ${active_alarm_info}   set variable    ${out["alarms"]}
    FOR    ${i}    IN RANGE    0     ${active_alarm_length}
       ${tmp_dict}   Copy Dictionary   ${active_alarm_info[${i}]}
        Set To Dictionary    ${tmp_dict}    additional_info   ${tmp_dict['additional_info']}
        Set To Dictionary    ${tmp_dict}    alarm_id      ${tmp_dict['alarm_id']}
        Set To Dictionary    ${tmp_dict}    alarm_name    ${tmp_dict['alarm_name']}
        Set To Dictionary    ${tmp_dict}    alarming_object   ${tmp_dict['alarming_object']}
        Set To Dictionary    ${tmp_dict}    appear_time      ${tmp_dict['appear_time']}
        Set To Dictionary    ${tmp_dict}    event_type_name    ${tmp_dict['event_type_name']}
        Set To Dictionary    ${tmp_dict}    fault_id      ${tmp_dict['fault_id']}
        Set To Dictionary    ${tmp_dict}    fault_name    ${tmp_dict['fault_name']}
        Set To Dictionary    ${tmp_dict}    last_updated_time    ${tmp_dict['last_updated_time']}
        Set To Dictionary    ${tmp_dict}    probable_cause_name    ${tmp_dict['probable_cause_name']}
        Set To Dictionary    ${tmp_dict}    severity    ${tmp_dict['severity']}
        ${i}  convert to string  ${i}
        Set To Dictionary  ${rtn}   ${i}   ${tmp_dict}
    END

    [Return]   ${rtn}

VDU Save Active Alarm To A File
    [Arguments]  ${file_name}=${EMPTY}  ${vdu_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | vdu_index, default is 0 |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...

    ...    Example
    ...    | VDU Save Active Alarm To A File |
    ...
    ${temp_id}   get unique id  precise=LOW
    ${file_name}  run keyword if   "${file_name}"=="${EMPTY}"  get a file  VDU_Save_Active_Alarm_To_A_File  ${temp_id}.txt
    ...   ELSE  set variable  ${file_name}
    vdu rest login   vdu_index=${vdu_index}

    ${out}    vdu.vdu_get_active_alarms
    ${out}  convert to string  ${out}
    dictionary_to_yaml_file    ${out}   ${file_name}
    [Return]   ${file_name}


VDU Save Historical Alarm To A File
    [Arguments]  ${file_name}=${EMPTY}  ${vdu_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | vdu_index, default is 0 |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...

    ...    Example
    ...    | VDU Save Historical Alarm To A File |
    ...
    ${temp_id}   get unique id  precise=LOW
    ${file_name}  run keyword if   "${file_name}"=="${EMPTY}"  get a file  VDU_Save_historical_Alarm_To_A_File  ${temp_id}.txt
    ...   ELSE  set variable  ${file_name}
    vdu rest login   vdu_index=${vdu_index}

    ${out}    vdu.vdu_get_historical_alarms
    ${out}  convert to string  ${out}
    dictionary_to_yaml_file    dict_values=${out}   file_path=${file_name}
    [Return]   ${file_name}


VDU History Alarm Should Contain Fault ID
    [Arguments]  @{para_list}
    [Documentation]   VDU History Alarm Should Contain Fault ID
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | aliase  | no | alias name, default is 'default' |
    ...    | fault_id_list  | no | the fault id to be checked, keyword return and do nothing if all fault IDs in para_fault_id_list list |
    ...    | | | do appear in webUI. Otherwise it will case case fails. The fault ID 9999 stands for alarm whose fault id is empty. |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | VDU History Alarm Should Contain Fault ID | 1234 |
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    vdu rest login
    ${out}   vdu.vdu_get_historical_alarms
    log to console  ${out}
    #Fail   software is not ready


Time Compare
    [Arguments]  ${time1}    ${time2}   ${time_operator}
    [Documentation]   time compare
    ...    authoer: chris.l.cao@nokia-sbell.com
    ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | time1       | yes | time1, e.g, 2020-09-15T10:02:57+00:00  |
    ...    | time2       | yes | time2, e.g, 2020-09-15T10:02:58+00:00  |
    ...    | time_operator | yes | time_operator, it can be eq/gt/ge/lt/le/ne. The meaning is eq:==,gt:>,ge:>=,lt:<,le:<=,ne:!=,default is eq |
    ...    |             |    | eq:${time1}==${time2},gt:${time1}>${time2}, it's similar for ge/lt/le/ne |

    ...
    ...    *RETURN VALUE*
    ...    ${True}  or ${False}
    ...
    ...    Example
    ...    | ${t1} | set variable | 2020-09-14T02:12:35+00:00 |
    ...    | ${t2} | set variable | 2020-09-14T02:12:36+00:00 |
    ...    | ${r}  | time compare | ${t1}  |  ${t2} |  time_operator=lt |
    ...    | should be true |  "${r}"=="${True}" |
    ...
    ${tmp_time1}    Get Absolute Time From Time Stamp   ${time1}
    ${tmp_time2}    Get Absolute Time From Time Stamp   ${time2}

    ${time_operator}  Set Variable  ${time_operator.lower()}
    ${r}  Run Keyword If   "${time_operator}"=="eq"   evaluate   ${tmp_time1}==${tmp_time2}
    ...   ELSE IF    "${time_operator}"=="gt"   evaluate   ${tmp_time1}>${tmp_time2}
    ...   ELSE IF    "${time_operator}"=="ge"   evaluate   ${tmp_time1}>=${tmp_time2}
    ...   ELSE IF    "${time_operator}"=="lt"   evaluate   ${tmp_time1}<${tmp_time2}
    ...   ELSE IF    "${time_operator}"=="le"   evaluate   ${tmp_time1}<=${tmp_time2}
    ...   ELSE IF    "${time_operator}"=="ne"   evaluate   ${tmp_time1}!=${tmp_time2}
    ...   ELSE   Fail   Unknown time_operator:${time_operator}!

    [Return]  ${r}


Get Absolute Time From Time Stamp
    [Arguments]  ${timestamp}
    ${absolute_time}   evaluate  dateutil.parser.parse("${timestamp}").strftime("%s")   modules=dateutil
    [Return]  ${absolute_time}

Trigger Faults For Vdu
    [Arguments]  ${faultId}=${4298}  ${severity}=${1}  ${source}=MRBTS-1  ${alais}=k8s_tenant
    [Teardown]   tafssh.Disconnect  connection=${alais}
    [Documentation]    Trigger Faults For Vdu
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by: <25-11-2021> zhong.1.chen@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | faultId  | No | fauld id, default is 4289 |
    ...    | severity  | No | fauld severity, 1: critical, 2: major, 3: minor, default is 1|
    ...    | source  | No | fauld source, default is MRBTS-1 |
    ...    | alais  | No | alais to vdu, default is k8s_tenant |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Trigger Faults For Vdu | ${4298} | ${2} |
    ...
    Log To Console  Trigger Faults For Vdu, faultId=${faultId}, severity=${severity}, source=${source}
    Connect To K8s Master With Tenant  alias=${alais}
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=oamfm
    ${cmd}=  Catenate   curl --request POST
    ...  --url http://oam-faultmanagement:9004/api/fm/v1/faults
    ...  --header 'content-type: application/json'
    ...  --data "{\\"faultId\\":${faultId},
    ...  \\"state\\":1,\\"severity\\":${severity},
    ...  \\"source\\":\\"${source}\\",\\"sourceType\\":1,\\"extraInfo\\":\\"57360\\", \\"recoveryOverride\\":1}"
    Kubectl Exec   oamfm    ${container}   ${cmd}   ${alais}

Cancel Faults For Vdu
    [Arguments]  ${faultId}=${4298}  ${severity}=${1}  ${source}=MRBTS-1  ${alais}=k8s_tenant
    [Teardown]   tafssh.Disconnect  connection=${alais}
    [Documentation]    Cancel Faults For Vdu
    ...    author: hongping.rao@nokia-sbell.com
    ...    modified by: <25-11-2021> zhong.1.chen@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | faultId  | No | fauld id, default is 4289 |
    ...    | severity  | No | fauld severity, 1: critical, 2: major, 3: minor, default is 1|
    ...    | source  | No | fauld source, default is MRBTS-1 |
    ...    | alais  | No | alais to vdu, default is k8s_tenant |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | Cancel Faults For Vdu | ${4298} | ${2} |
    ...
    Log To Console  Cancel Faults For Vdu, faultId=${faultId}, severity=${severity}, source=${source}
    Connect To K8s Master With Tenant   alias=${alais}
    ${container}   Get Full Container Name By Container Abbreviation   ctr_abbr=oamfm
    ${cmd}=  Catenate  curl --request POST
    ...  --url http://oam-faultmanagement:9004/api/fm/v1/faults
    ...  --header 'content-type: application/json'
    ...  --data "{\\"faultId\\":${faultId},
    ...  \\"state\\":0,\\"severity\\":${severity},
    ...  \\"source\\":\\"${source}\\",\\"sourceType\\":1,\\"extraInfo\\":\\"57360\\"}"
    Kubectl Exec   oamfm    ${container}   ${cmd}   ${alais}


Trigger Fault Two Times
    [Arguments]  ${faultId}=${4298}
    [Documentation]    trigger fault two times
    ...    author: ling.2.zhao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | faultId  | No | fauld id, default is 4289 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | trigger fault two times | faultId=${4298} |
    ...
    Log To Console   trigger fault two times
    Cancel Faults For Vdu     faultId=${faultId}   severity=1   source=MRBTS-1
    sleep   10s
    Trigger Faults For Vdu    faultId=${faultId}   severity=1   source=MRBTS-1
    sleep   30s
    Cancel Faults For Vdu     faultId=${faultId}   severity=1   source=MRBTS-1
    sleep   10s
    Trigger Faults For Vdu    faultId=${faultId}   severity=1   source=MRBTS-1
    sleep   30s


############################## vDU FM End ##############################
====== vDU FM End ======
     log to console  \n*** only used for readable **

############################## FHGW FM Start ##############################
====== FHGW FM Start ======
     log to console  \n*** only used for readable ***

############################## FHGW FM End ##############################
====== FHGW FM End ======
     log to console  \n*** only used for readable **
