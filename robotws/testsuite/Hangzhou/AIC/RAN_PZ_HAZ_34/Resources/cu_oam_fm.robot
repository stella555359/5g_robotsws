*** Settings ***
Documentation     [PURPOSE] Fault management related


*** Variables ***


*** Keywords ***
CU Get Active Alarms
    [Arguments]  ${gnb_index}=0
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
     CU Rest Login  ${gnb_index}
     ${active_alarm_list}=  cu.get_active_alarms    page_number=${1}     items_per_page=${1000}
     ${num_of_alarms}=   get length     ${active_alarm_list["alarms"]}
     run keyword and continue on failure   should be equal as integers    ${num_of_alarms}    ${active_alarm_list["total"]}
     ...    There should be ${active_alarm_list["total"]} active alarms, but actually got ${num_of_alarms}
     [Return]     ${active_alarm_list["alarms"]}
     #[Teardown]  run keyword and ignore error   CU Rest Logout

CU Get Historical Alarms
    [Arguments]  ${gnb_index}=0   ${use_m2m}={True}
    [Documentation]   Gets historic alarms including faults from BTS and alarms from RCP.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default  |
        ...    |  use_m2m  | No |  use_m2m to indicate whether enable m2m or not, True in default  |

        ...    *RETURN VALUE*
        ...    History alarm list
        ...    Example
        ...    |  Get CU History Alarm	 |    |
    CU Login  ${gnb_index}
    ${historical_alarm_list}=  cu.get_historical_alarms    page_number=${1}     items_per_page=${10000}   use_m2m=${use_m2m}
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


VCU Active Alarm Query
    [Arguments]  @{para_list}
    [Documentation]   Query desired alarm exists or not in VCU via REST
    ...    authoer: chris.l.cao@nokia-sbell.com
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
    ...    | ${result} | VCU Active Alarm Query | fault_id=61524 | alarm_name=Service Port enable |
    ...    | ${result} | VCU Active Alarm Query | fault_id=61524 | alarm_name=Service Port enable | vdu_index=0 |
    ...    | ${result} | VCU Active Alarm Query | alias=default | fault_id=61524 | alarm_name=Service Port enable |
    ...    | ${result} | VCU Active Alarm Query | fault_id=61524 | alarm_name=Port enable | severity=minor |
    ...    | ${result} | VCU Active Alarm Query | alarm_name=Service Port enable | alarming_object=EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1 |
    ...    | ${result} | VCU Active Alarm Query | fault_id=61524 | last_updated_time=2020-09-14T02:12:35+00:00 | time_operator=ge |
    ...    | Should Be True |  ${result.__len__()}==1 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})
    ${fault_id_list}   set variable   ${non_key_value_pair_list}

    ${gnb_index}  Run Keyword If  "gnb_index" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["gnb_index"]}
    ...   ELSE   set variable  0

    ${time_operator}  Run Keyword If  "time_operator" in "${key_value_dict_keys}"   Set Variable  ${key_value_dict["time_operator"]}
    ...   ELSE   set variable  ge

    Run Keyword If  "gnb_index" in "${key_value_dict_keys}"  Remove From Dictionary   ${key_value_dict}   gnb_index
    Run Keyword If  "time_operator" in "${key_value_dict_keys}"  Remove From Dictionary   ${key_value_dict}   time_operator

    ${active_alarm_info}  VCU Get Active Alarm REST   gnb_index=${gnb_index}
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


VCU Get Active Alarm REST
    [Arguments]  ${gnb_index}=0
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
    ${alias}  Get Unique Id 
    ${alias}  CU Rest Login   gnb_index=${gnb_index}  alias=${alias}
    ${rtn}  Create Dictionary
    ${out}    cu.get_active_alarms   connection=${alias}  #   use_m2m=${False}
    #${active_alarm_length}   set variable   ${out["total"]}
    ${active_alarm_info}   set variable    ${out["alarms"]}
    ${active_alarm_length}   get length  ${active_alarm_info}
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
    [Arguments]   ${fault_id}=${None}  ${fault_name}=${None}   ${alarm_id}=${None}
    ...   ${alarm_name}=${None}  ${gnb_index}=0   ${use_m2m}={True}
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
     ${alarm_info}=   run keyword and continue on failure  CU Get Historical Alarms  ${gnb_index}   use_m2m=${use_m2m}
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
    ${total_ignored_alarm_list}=    evaluate   list(set( ${total_ignored_alarm_list}))
    ${alarms}=  ignore known alarms   ${new_active_alarm_list}   ${total_ignored_alarm_list}
    ${number_of_new_alarms}=   get length    ${new_active_alarm_list}
    run keyword and continue on failure  should be equal as numbers
     ...  	${number_of_new_alarms}  ${0}   There are some unexpected active alarms raised!


VCU Save Active Alarm To A File
    [Arguments]  ${file_name}=${EMPTY}  ${gnb_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | file name, default is EMPTY will create a file|
    ...    | gnb_index  | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...

    ...    Example
    ...    | VCU Save Active Alarm To A File |
    ...
    ${temp_id}   get unique id  precise=LOW
    ${file_name}  run keyword if   "${file_name}"=="${EMPTY}"  get a file  VCU_Save_Active_Alarm_To_A_File  ${temp_id}.txt
    ...   ELSE  set variable  ${file_name}
    CU Rest Login   gnb_index=${gnb_index}

    ${out}    cu.get_active_alarms
    ${out}  convert to string  ${out}
    dictionary_to_yaml_file    ${out}   ${file_name}
    [Return]   ${file_name}
    [Teardown]   CU Rest Logout


VCU Save Historical Alarm To A File
    [Arguments]  ${file_name}=${EMPTY}  ${gnb_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    author: rui.3.li@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | file name, default is EMPTY will create a file|
    ...    | gnb_index  | no | gnb_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    None
    ...

    ...    Example
    ...    | VCU Save Historical Alarm To A File |
    ...
    ${temp_id}   get unique id  precise=LOW
    ${file_name}  run keyword if   "${file_name}"=="${EMPTY}"  get a file  VCU_Save_historical_Alarm_To_A_File  ${temp_id}.txt
    ...   ELSE  set variable  ${file_name}
    CU Rest Login   gnb_index=${gnb_index}

    ${out}    cu.get_historical_alarms
    ${out}  convert to string  ${out}
    dictionary_to_yaml_file    dict_values=${out}   file_path=${file_name}
    [Return]   ${file_name}
    [Teardown]   CU Rest Logout

CU Count Specfic Fault ID Number From Alarm Historical
    [Arguments]     ${Specfic_fault_id}
    [Documentation]  Get Target Fault ID From Restful Interface
    ...    Current State : Done 
    ...    author:  shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Specfic_fault_id | Yes | fault_id need to be checked |
    ...    *RETURN VALUE*
    ...    Numbers Of Specfic Fault ID
    ...    Example
    ...    ${number}=  CU Count Specfic Fault ID Number From Alarm Historical  Specfic_fault_id= 4592
    log to console  CU Count Specfic Fault ID ${Specfic_fault_id} Number From Alarm Historical
    ${total_Alarm}=  CU Get Historical Alarms
    ${fault_alarm_num}=  Set Variable  ${0}
    FOR  ${d}  In  @{total_Alarm}
        ${fault_alarm_num}=  Run Keyword If  '${d["fault_id"]}'=='${Specfic_fault_id}'   Evaluate   ${fault_alarm_num}+1
        ...  ELSE  Set Variable  ${fault_alarm_num}
    END
    log to console  \nCurrently fault_id ${Specfic_fault_id} Num is ${fault_alarm_num}
    [Return]  ${fault_alarm_num}

CU Specific Fault ID Counter Should Be Increased
    [Arguments]   ${Specfic_fault_id}   ${last_alarm_number}   ${expect_increased_number}=${0}
    [Documentation]  Compare Alarm With last count
    ...    Current State : Done 
    ...    author:  shouxiang.jiao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | Specfic_fault_id | Yes | fault_id need to be check |
    ...    | last_alarm_number | Yes |number from "Get Specfic Historical Alarm Number From CU Restful" |
    ...    | expect_increased_number | No | times your want to check the cu raised 
    ...    *RETURN VALUE*
    ...    Compare Result True | False  
    ...    Example
    ...    ${number}=  Get Specfic Historical Alarm Number From CU Restful  Specfic_fault_id= 4592
    ...    Operation to Trigger Traget alarm 
    ...    CU Specific Fault ID Counter Should Be Increased  Specfic_fault_id= 4592  last_alarm_number=${number}
    ...    it will check the alarm increased from last alarm check
    ...    ${number}=  Get Specfic Historical Alarm Number From CU Restful  Specfic_fault_id= 4592
    ...    Operation to Trigger Traget alarm 
    ...    CU Specific Fault ID Counter Should Be Increased  Specfic_fault_id= 4592  last_alarm_number=${number}
    ...    ...  expect_increased_number  3 
    ...    it will check the alarm increased 3 times from last alarm check 
    log to console  CU Specific Fault ID Counter Should Be Increased
    ${alarm_number}=    CU Count Specfic Fault ID Number From Alarm Historical  ${Specfic_fault_id}
    ${increased_number}=   Evaluate  ${alarm_number}-${last_alarm_number}
    Run Keyword If  ${expect_increased_number}==${0}  Should Be True  "${alarm_number}">"${last_alarm_number}"
    ...  ELSE  Should Be True  "${increased_number}"=="${expect_increased_number}"
