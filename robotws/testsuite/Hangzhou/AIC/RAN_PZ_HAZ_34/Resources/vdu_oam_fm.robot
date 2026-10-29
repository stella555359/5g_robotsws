*** Settings ***
Documentation     [PURPOSE] Fault management related


*** Variables ***


*** Keywords ***

====== vDU Active Alarm Start ======
     log to console  \n*** only used for readable ***


VDU Active Alarm Query
    [Arguments]  @{para_list}
    [Documentation]   Check desired alarm exists or not via REST
    ...    authoer: chris.l.cao@nokia-sbell.com
    ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list       | yes | see exapmple, fielter includes  fault_id,alarm_id,alarm_name,additional_info,alarming_object,
    ...    |                 |     | event_type_name,fault_name,probable_cause_name,severity,last_updated_time |
    ...    |                 |     | for last_updated_time filter, the filter action is determined by time_operator which is lt, le, gt,ge |
    ...    |                 |     | lt-less than, le-less or equal than, gt-greater than, ge-greater or equal than, default value is 'ge' |
    ...
    ...    *RETURN VALUE*
    ...    dictionary of alarm that matches your filter
    ...
    ...    Example
    ...    | ${result} | VDU Active Alarm Query | fault_id=61524 | alarm_name=Service Port enable |
    ...    | ${result} | VDU Active Alarm Query | fault_id=61524 | alarm_name=Service Port enable | vdu_index=0 |
    ...    | ${result} | VDU Active Alarm Query | alias=default | fault_id=61524 | alarm_name=Service Port enable |
    ...    | ${result} | VDU Active Alarm Query | fault_id=61524 | alarm_name=Port enable | severity=minor |
    ...    | ${result} | VDU Active Alarm Query | alarm_name=Service Port enable | alarming_object=EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1 |
    ...    | ${result} | VDU Active Alarm Query | fault_id=61524 | last_updated_time=2020-09-14T02:12:35+00:00 | time_operator=ge |
    ...    | Should Be True |  ${result.__len__()}==1 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})
    ${fault_id_list}   set variable   ${non_key_value_pair_list}

    ${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
    ...   ELSE   set variable  0

    ${time_operator}  Run Keyword If  "time_operator" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["time_operator"]}
    ...   ELSE   set variable  ge

    Run Keyword If  "vdu_index" in "${key_value_dict_keys}"  Remove From Dictionary   ${key_value_dict}   vdu_index
    Run Keyword If  "time_operator" in "${key_value_dict_keys}"  Remove From Dictionary   ${key_value_dict}   time_operator

    ${active_alarm_info}  VDU Get Active Alarm REST   vdu_index=${vdu_index}
    ${active_alarm_keys}    evaluate  list(${active_alarm_info})

    ${alarm_index}       Set Variable    0
    ${rtn_dict}    create dictionary

    FOR    ${i}    IN   @{active_alarm_keys}
       ${tmp_dict}  Set Variable  ${active_alarm_info["${i}"]}

       #compare last_updated_time
       ${last_updated_time_compare_result}  Run Keyword If   """last_updated_time""" in """${key_value_dict_keys}"""
       ...    time compare   ${tmp_dict["last_updated_time"]}   ${key_value_dict["last_updated_time"]}   time_operator=${time_operator}
       Run Keyword If   """last_updated_time""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${last_updated_time_compare_result}""" != """${True}"""

       Run Keyword If   """fault_id""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["fault_id"]}""" != """${tmp_dict["fault_id"]}"""
       Run Keyword If   """alarm_id""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["alarm_id"]}""" != """${tmp_dict["alarm_id"]}"""
       Run Keyword If   """severity""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["severity"]}""" != """${tmp_dict["severity"]}"""

       ${ToBeFilterKeys}   Copy List   ${key_value_dict_keys}
       Run Keyword If   """fault_id""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  fault_id
       Run Keyword If   """alarm_id""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  alarm_id
       Run Keyword If   """severity""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  severity
       Run Keyword If   """last_updated_time""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  last_updated_time
       Run Keyword If   """time_operator""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  time_operator

       ${list_len}   Get Length  ${ToBeFilterKeys}
       ${matched}   Run Keyword If  ${list_len}>0   _Key Is Matched In Another Dictionary   para_key_value_dict=${key_value_dict}
           ...   list_to_be_filtered_keys=${ToBeFilterKeys}  alarm_dict=${tmp_dict}
          ...   ELSE   set variable  Found
       ${tmp_found_one_alarm}  run keyword if  '${matched}'!='${None}'   Copy Dictionary    ${active_alarm_info["${i}"]}
       run keyword if  '${matched}'!='${None}'   set to dictionary  ${rtn_dict}   ${alarm_index}   ${tmp_found_one_alarm}
       ${alarm_index}   evaluate  str(int(${alarm_index}+1))
    END

    [Return]   ${rtn_dict}


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
                ...    23.04.2023,hongping.rao@nokia-sbell.com, add waiting time
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

        ${wait_time}  Run Keyword If  "waiting_time" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["waiting_time"]}
		...   ELSE   set variable   10s
		${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
		...   ELSE   set variable  0
                ${http_username}  Run Keyword If  "username" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["username"]}
                ...  ELSE  set variable  ${Empty}
                 ${http_password}  Run Keyword If  "password" in "${key_value_dict_keys}"  Set Variable  ${key_value_dict["password"]}
                ...  ELSE  set variable  ${Empty}
		${active_alarm_info}  VDU Get Active Alarm REST   vdu_index=${vdu_index}  username=${http_username}
		...  password=${http_password}   waiting_time=${wait_time}
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
    [Arguments]  ${vdu_index}=0  ${username}=${EMPTY}  ${password}=${EMPTY}  ${waiting_time}=10s
    [Documentation]  VDU Get Active Alarm REST
    ...    author: chris.l.cao@nokia-sbell.com
    ...    25.04.2023, hongping.rao@nokia-sbell.com, waiting_time parameter, default is 30s
    ...    13.06.2023, chris.l.cao@nokia-sbell.com, add paging=${False}
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...    | waiting_time  | no | waiting_time, default is 30s |
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
    vDU Rest Login With Special Password   vdu_index=${vdu_index}  username=${http_username}  password=${http_password}
    ...   waiting_time=${waiting_time}
    ${rtn}  Create Dictionary
    ${out}    vdu.vdu_get_active_alarms   paging=${False}
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


====== vDU History Alarm Start ======
     log to console  \n*** only used for readable ***

VDU History Alarm Query
    [Arguments]  @{para_list}
    [Documentation]   Check desired history alarm exists or not via REST
    ...    authoer: chris.l.cao@nokia-sbell.com
    ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list       | yes | see exapmple, fielter includes  fault_id,alarm_id,alarm_name,additional_info,alarming_object,
    ...    |                 |     | event_type_name,fault_name,probable_cause_name,severity,last_updated_time |
    ...    |                 |     | for last_updated_time filter, the filter action is determined by time_operator which is lt, le, gt,ge |
    ...    |                 |     | lt-less than, le-less or equal than, gt-greater than, ge-greater or equal than, default value is 'ge' |
    ...
    ...    *RETURN VALUE*
    ...    dictionary of alarm that matches your filter
    ...
    ...    Example
    ...    | ${result} | VDU History Alarm Query | fault_id=61524 | alarm_name=Service Port enable |
    ...    | ${result} | VDU History Alarm Query | fault_id=61524 | alarm_name=Service Port enable | vdu_index=0 |
    ...    | ${result} | VDU History Alarm Query | alias=default | fault_id=61524 | alarm_name=Service Port enable |
    ...    | ${result} | VDU History Alarm Query | fault_id=61524 | alarm_name=Port enable | severity=minor |
    ...    | ${result} | VDU History Alarm Query | alarm_name=Service Port enable | alarming_object=EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1 |
    ...    | ${result} | VDU History Alarm Query | fault_id=61524 | last_updated_time=2020-09-14T02:12:35+00:00 | time_operator=ge |
    ...    | Should Be True |  ${result.__len__()}==1 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})
    ${fault_id_list}   set variable   ${non_key_value_pair_list}

    ${vdu_index}  Run Keyword If  "vdu_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["vdu_index"]}
    ...   ELSE   set variable  0

    ${time_operator}  Run Keyword If  "time_operator" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["time_operator"]}
    ...   ELSE   set variable  ge

    Run Keyword If  "vdu_index" in "${key_value_dict_keys}"  Remove From Dictionary   ${key_value_dict}   vdu_index
    Run Keyword If  "time_operator" in "${key_value_dict_keys}"  Remove From Dictionary   ${key_value_dict}   time_operator

    ${active_alarm_info}  VDU Get History Alarm REST   vdu_index=${vdu_index}
    ${active_alarm_keys}    evaluate  list(${active_alarm_info})

    ${alarm_index}       Set Variable    0
    ${rtn_dict}    create dictionary

    FOR    ${i}    IN   @{active_alarm_keys}
       ${tmp_dict}  Set Variable  ${active_alarm_info["${i}"]}

       #compare last_updated_time
       ${last_updated_time_compare_result}  Run Keyword If   """last_updated_time""" in """${key_value_dict_keys}"""
       ...    time compare   ${tmp_dict["last_updated_time"]}   ${key_value_dict["last_updated_time"]}   time_operator=${time_operator}
       Run Keyword If   """last_updated_time""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${last_updated_time_compare_result}""" != """${True}"""

       Run Keyword If   """fault_id""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["fault_id"]}""" != """${tmp_dict["fault_id"]}"""
       Run Keyword If   """alarm_id""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["alarm_id"]}""" != """${tmp_dict["alarm_id"]}"""
       Run Keyword If   """severity""" in """${key_value_dict_keys}"""
       ...   continue For Loop If  """${key_value_dict["severity"]}""" != """${tmp_dict["severity"]}"""

       ${ToBeFilterKeys}   Copy List   ${key_value_dict_keys}
       Run Keyword If   """fault_id""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  fault_id
       Run Keyword If   """alarm_id""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  alarm_id
       Run Keyword If   """severity""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  severity
       Run Keyword If   """last_updated_time""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  last_updated_time
       Run Keyword If   """time_operator""" in """${key_value_dict_keys}"""   Remove Values From List  ${ToBeFilterKeys}  time_operator

       ${list_len}   Get Length  ${ToBeFilterKeys}
       ${matched}   Run Keyword If  ${list_len}>0   _Key Is Matched In Another Dictionary   para_key_value_dict=${key_value_dict}
           ...   list_to_be_filtered_keys=${ToBeFilterKeys}  alarm_dict=${tmp_dict}
          ...   ELSE   set variable  Found
       ${tmp_found_one_alarm}  run keyword if  '${matched}'!='${None}'   Copy Dictionary    ${active_alarm_info["${i}"]}
       run keyword if  '${matched}'!='${None}'   set to dictionary  ${rtn_dict}   ${alarm_index}   ${tmp_found_one_alarm}
       ${alarm_index}   evaluate  str(int(${alarm_index}+1))
    END

    [Return]   ${rtn_dict}

_Key Is Matched In Another Dictionary
    [Arguments]   ${para_key_value_dict}   ${list_to_be_filtered_keys}   ${alarm_dict}
    [Documentation]  return 'Found' if specifised alarm is found, otherwise return '${None}'
    ...    It's 'AND' operation between all keys in ${para_key_value_dict}
    ...    authoer: chris.l.cao@nokia-sbell.com
    ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
    ${rtn}   Set Variable   Found
    FOR    ${j}    IN   @{list_to_be_filtered_keys}
        Continue For Loop If  """${para_key_value_dict["${j}"]}""" in """${alarm_dict["${j}"]}"""
       ${rtn}   Set Variable  ${None}
       Exit For Loop
    END
    [Return]  ${rtn}


VDU Get History Alarm REST
    [Arguments]  ${vdu_index}=0  ${username}=${EMPTY}  ${password}=${EMPTY}
    [Documentation]  VDU Get History Alarm REST
    ...    author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...    | username  | no | username, default is ${EMPTY} |
    ...    | password  | no | password, default is ${EMPTY} |
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
    ...    | ${history_alarm} | VDU Get History Alarm REST |
    ...
    run keyword and ignore error  vdu rest logout  vdu_index=${vdu_index}
    ${http_username}  Run Keyword If  "${username}"=="${EMPTY}"  set variable  ${Empty}
    ...  ELSE  set variable  ${username}
    ${http_password}  Run Keyword If  "${password}"=="${EMPTY}"   Set Variable  ${Empty}
    ...  ELSE  set variable  ${password}
    vDU Rest Login With Special Password   vdu_index=${vdu_index}  username=${http_username}  password=${http_password}
    ${rtn}  Create Dictionary
    ${out}    vdu.vdu_get_historical_alarms  paging=${False}

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
    [Arguments]  @{expect_alarm_fault_id_list}  ${vdu_rest_connection_alias}=default
    [Documentation]   VDU History Alarm Should Contain the given Fault ID.
    ...               vdu rest login is not included in this keyword, testers should call it by themselves.
    ...    author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expect_alarm_fault_id_list  | no | the fault id to be checked, keyword return and do nothing
    ...                                        if all fault IDs in para_fault_id_list list |
    ...    | vdu_rest_connection_alias  | no | rest login alias name, default is 'default' |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vdu rest login |
    ...    | VDU History Alarm Should Contain Fault ID | [1234, 23] |
    ...    | [Teardown]  vDU Rest Logout |
    ${alarm_history}   vdu.vdu_get_historical_alarms  paging=${False}
    log to console   There are ${alarm_history['total']} alarms in alarm history.
    Run keyword if  ${alarm_history['total']}==0   Fail   There are no historical alarms.
    ${current_fault_id_list}=   _Get Fault Id List    ${alarm_history['alarms']}
    list should contain sub list   ${current_fault_id_list}   ${expect_alarm_fault_id_list}


_Get Fault Id List
    [Arguments]   ${alarms_list}
    ${fault_id_list}   Create List
    FOR  ${alarm}   IN    @{alarms_list}
        append to list    ${fault_id_list}   ${alarm['fault_id']}
    END
    [Return]  ${fault_id_list}


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


====== vDU FM Misc ======
     log to console  \n*** only used for readable ***

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


vDU Get Active Alarms
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Gets active alarms including faults from BTS and alarms from RCP.
        ...    author: rui.3.li@nokia-sbell.com
        ...    modified by:   <16-Jan-2023>, <r3li>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    | gnb_index | No | gnb index to indicate which gnb will be used, 0 in default |
        ...    | vdu_index | No | vdu index |
        ...
        ...    *RETURN VALUE*
        ...    Active alarm list
        ...    Example
        ...    | vDU Get Active Alarm | 0 | 0 |
    vDU Rest Login  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${active_alarm_list}=  vdu.vdu_get_active_alarms    page_number=${1}     items_per_page=${1000}
    ${num_of_alarms}=   get length     ${active_alarm_list["alarms"]}
    run keyword and continue on failure   should be equal as integers    ${num_of_alarms}    ${active_alarm_list["total"]}
    ...    There should be ${active_alarm_list["total"]} active alarms, but actually got ${num_of_alarms}
    [Return]     ${active_alarm_list["alarms"]}
    [Teardown]  run keyword and ignore error   vDU Rest Logout


VDU Active Alarm Should Contain Fault ID List
    [Arguments]  @{expect_alarm_fault_id_list}  ${vdu_rest_connection_alias}=default
    [Documentation]   VDU Active Alarm Should Contain the given Fault ID.
    ...               vdu rest login is not included in this keyword, testers should call it by themselves.
    ...    author: calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | expect_alarm_fault_id_list  | no | the fault id to be checked, keyword return and do nothing
    ...                                        if all fault IDs in para_fault_id_list list |
    ...    | vdu_rest_connection_alias  | no | rest login alias name, default is 'default' |
    ...    *RETURN VALUE*
    ...    None
    ...
    ...    Example
    ...    | vdu rest login |
    ...    | VDU Active Alarm Should Contain Fault ID | [1234, 23] |
    ...    | [Teardown]  vDU Rest Logout |
    ${alarm_active}   vdu.vdu_get_active_alarms  paging=${False}
    ${current_fault_id_list}=   _Get Fault Id List    ${alarm_active['alarms']}
    log to console   There are ${current_fault_id_list} alarms in alarm active.
    list should contain sub list   ${current_fault_id_list}   ${expect_alarm_fault_id_list}
    
############################## FHGW FM Start ##############################
====== FHGW FM Start ======
     log to console  \n*** only used for readable ***

############################## FHGW FM End ##############################
====== FHGW FM End ======
     log to console  \n*** only used for readable **
