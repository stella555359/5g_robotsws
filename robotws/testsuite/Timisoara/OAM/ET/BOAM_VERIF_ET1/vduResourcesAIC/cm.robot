*** Settings ***
Documentation
...   author: fen.huang@nokia-sbell.com

#Resource          aic_common_resources.robot

#*** Variables ***


*** Keywords ***
All Cells Status Should Be Onair
    log to console  *** tbd ***

############################## CU CM Start ##############################
====== CU CM Start ======
     log to console  \n*** only used for readable ***

CU Full Commission
    [Arguments]    ${path_of_commission_file}   ${plan_name}=default_plan_name   ${solution}=rest   ${gnb_index}=0
    [Documentation]   Send BTS commission via rest or webui.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <15-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  path_of_commission_file | Yes. | Path of commission file |
        ...	   |  plan_name  | No. |  Plan file name displayed on weebui after scf load |
        ...	   |  solution  |  No. |  Solution for sending plan, can be rest or webui |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    | CU Full Commission  |  /tmp/commission.xml  |    3219_plan_file   |  rest  |
    run keyword if  "${solution}"=="rest"    CU Full Commssion By Rest     ${path_of_commission_file}   ${plan_name}  ${gnb_index}
    ...   ELSE    CU Full Commission By Webui    ${path_of_commission_file}   ${plan_name}   ${gnb_index}

CU Full Commssion By Rest
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
    [Documentation]   Send BTS commission via rest.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  path_of_commission_file  | Yes. | Path of commission file |
        ...	   |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commssion By Rest  |   /tmp/commission.xml  |    3219_plan_file   |
     CU Login  ${gnb_index}
     log to console   \n*** Start plan upload operation ***
     ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
     log to console   \n*** Wait plan upload operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
     ...    ${upload_operation_info["action_id"]}    success
     log to console   \n*** Start plan validate operation ***
     ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan validate operation success ***
     wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
     log to console   \n*** Start plan activate operation ***
     ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
     log to console   \n*** Wait plan activate operation success in 5 mins ***
     wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
     ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
     [Teardown]    run keyword and ignore error   CU Logout

CU Check Plan Upload Status Should Be As Expected
   [Arguments]  ${operation_id}   ${expected_status}
   [Documentation]   Check plan upload status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  operation_id  | Yes. |  Operation id for uploading plan file  |
        ...	   |  expected_status  | Yes. |  Expected upload status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Upload Status Should Be As Expected   |  a_6cfa594f-0938-4732-a78c-16afdbd214d2 |    success   |
   ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan validate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id  | Yes. |  Plan file id  |
        ...	   |  operation_id  | Yes. |  Operation id for validating plan file  |
        ...	   |  expected_status  | Yes. |  Expected validate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Validate Status Should Be As Expected  |  sp_39d02514-e65b-46db-9ad7  |  a_0c7769bd-78ae-4505-9ce1 |  success  |
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Activate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan activate status should be as expected.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <16-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id  | Yes. |  Plan file id  |
        ...	   |  operation_id  | Yes. |  Operation id for activating plan file  |
        ...	   |  expected_status  | Yes. |  Expected activate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Activate Status Should Be As Expected   |  sp_39d02514-e65b-46db-9ad7 |  o_c1ca0de5-3225-46e4-86bd  |  success  |
   ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Full Commission By Webui
    #[Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
    [Documentation]   Send BTS commission via webui.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...    |  path_of_commission_file  | Yes |  Path of plan file  |
        ...	   |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commission By Webui  |  /tmp/commission.xml  |   3219_plan_file   |   0  |
     Log    Send commission by webui not ready!    WARN

CU Backup SCF
    [Arguments]    ${stored_path}=${EMPTY}  ${gnb_index}=0
    [Documentation]   Save current plan file on CU.
        ...    author: fen.huang@nokia-sbell.com
        ...   modified by:        <24-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  stored_path | No. | where to store saved plan file  |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    Stored path of commission file.

        ...    Example
        ...    |  CU Backup SCF  |    |
    # ${oam_conn}=    CU SSH To OAM
    ${time_stamp}=  Get Time   exclude_millis=yes
    ${time_stamp}=  replace string  ${time_stamp}  ${SPACE}  \
    ${time_stamp}=  replace string  ${time_stamp}  -   \
    ${time_stamp}=  replace string  ${time_stamp}  :   \
    ${plan_file_path}=    Get A File    SCF    scf_${time_stamp}.xml
    CU Login  ${gnb_index}
    ${where_to_store_plan_file}=    run keyword if   "${stored_path}"=="${EMPTY}"   set variable    ${plan_file_path}
    ...  ELSE    set variable    ${stored_path}
    cu.get_current_plan_file    ${where_to_store_plan_file}   timeout=60
    [Return]     ${where_to_store_plan_file}
    [Teardown]   run keyword and ignore error   CU Logout

CU Delete Plan
    [Arguments]     ${plan_id}  ${gnb_index}=0
    [Documentation]   Delete stage plan on CU.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <23-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id | Yes. | Plan id |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Delete Plan  |  sp_d211beda-246f-40e2-97ec-57e9961fc094   |
    ${plan_exist_flag}=    CU Check Stage Plan Exist    ${plan_id}    ${gnb_index}
    CU Login  ${gnb_index}
    run keyword if     ${plan_exist_flag}==${True}    cu.plan_delete    ${plan_id}
    ...  ELSE  run keywords   log  Plan id ${plan_id} is not exist before deletion!  WARN   AND  return from keyword
    ${plan_exist_flag}=    CU Check Stage Plan Exist    ${plan_id}     ${gnb_index}
    should be true     ${plan_exist_flag}!=${True}     Plan delete operation failed and plan id ${plan_id} is still exist after deletion!
    [Teardown]   run keyword and ignore error   CU Logout

CU Check Stage Plan Exist
     [Arguments]     ${plan_id}  ${gnb_index}=0
    [Documentation]   Check stage plan exist or not by plan id.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:        <23-Apr-2020>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id | Yes. | Plan id |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Stage Plan Exist  |  sp_d211beda-246f-40e2-97ec-57e9961fc094   |
    CU Login  ${gnb_index}
    ${initial_stage_plans}=    cu.get_plan_info
    FOR    ${plan}    IN    @{initial_stage_plans}
         return from keyword if    "${plan["plan_id"]}"=="${plan_id}"   ${True}
    END
    [Teardown]    run keyword and ignore error   CU logout

CU Online Parameter Change
    #[Arguments]   ${modify_list}   #${gnb_index}=0
    [Documentation]   Online change parameter
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...	   | commission_file_path | Yes. | Path of commission file |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    | CU Online Parameter Change  |     |
        Log    CU Online Parameter Change not ready!     WARN

CU Delta Commission
    #[Arguments]   ${delta_commission_file_path}
    [Documentation]   Send BTS delta commission via rest.
        ...    author: fen.huang@nokia-sbell.com
        ...    modified by:   <19-Nov-2019>, <f2huang>, <e.g. PR-Number, feature number>
        ...    | Input Parameters | Man. | Description |
        ...	   | delta_commission_file_path | Yes. | Delta commission file path |
        ...
        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Delta Commission	 | F:/tmp/commission.xml |
     Log    CU Online Parameter Change not ready!     WARN

CU Online Change Single Mo Parameters via rest
    [Arguments]     ${para_list}    ${mo_dn}     ${delta_plan_name}=delta_plan
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...    *RETURN VALUE*  None
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | CU Online Change Single Mo Parameters via rest | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |

    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
	run keyword and continue on failure   Wait until keyword succeeds  3x  2s
	...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
	...  _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}
	${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}
    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure   Wait until keyword succeeds  3x  30s
	...  _Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}   operation_id=${active_res['operation_id']}

_Get CU Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}
    [Documentation]   _Get CU Specifical MO UUID
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _Get CU Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|

    @{name_list}=   split_string    ${mo_dn}   /
    set test variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _Get CU Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}

_Get CU Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _Get CU Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|

    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'  run keywords
    ...  set test variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

_Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}
    [Documentation]   _Generating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Generating Delta Plan Operation Should Be Successful | action_id=xxx |
	${res}   cu.get_action_state_of_generating_delta_plan   ${action_id}
	should be equal as strings  ${res['status']}  success

_Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   CU Online Parameter Change By Rest
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	should be equal as strings  ${res['status']}  success

_Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   _Validating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
	should be equal as strings  ${res['status']}  success

_Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   _Activating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
	should be equal as strings  ${res['status']}  success

CU Online Change Single Mo Parameters Via Rest Failed
    [Arguments]     ${para_list}    ${mo_dn}     ${delta_plan_name}=delta_plan
    [Documentation]   CU Online Change Single Mo Parameters via rest.
    ...  author: alisha.wu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...    *RETURN VALUE*  None
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | CU Online Change Single Mo Parameters Via Rest Failed | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |

    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
	run keyword and continue on failure   Wait until keyword succeeds  3x  2s
	...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
	...  _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}
	${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}
    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure   Wait until keyword succeeds  3x  30s
	...  _Activating Delta Plan Operation Should Be Failed   plan_id=${delta_plan_id}   operation_id=${active_res['operation_id']}

_Activating Delta Plan Operation Should Be Failed
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   _Activating Delta Plan Operation Should Be Failed
    ...  author: alisha.wu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _Activating Delta Plan Operation Should Be Failed | plan_id=xxx | operation_id=xxx |
	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
	should be equal as strings  ${res['status']}  failure



CU Update Delta Plan Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${parameter_change_list}
	[Documentation]   CU Update Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | managed object dist name |
    ...    | parameter_change_list | yes | parameter change list |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | &{gnbPlmn} | create dictionary  operation_type=add | parameter_path=/gnbPlmn |
    ...    | @{gnbPlmn_Para_list}= | Create List | ${gnbPlmn} |
    ...    | Update Delta Plan Should Be Successful | plan_id=${delta_plan_id} |
    ...    | ...  mo_dn=MRBTS-xxxx/NRBTS-xxxx/NRCELL-1/NRREL-1 | parameter_change_list=${gnbPlmn_Para_list} |
    ...    | &{mcc} | create dictionary | operation_type=add | parameter_path=/gnbPlmn/0/mcc | value=262 |
    ...    | @{mcc_Para_list}= | Create List | ${mcc} |
    ...    | CU Update Delta Plan Should Be Successful | plan_id=${delta_plan_id}  |
    ...    | ...  mo_dn=MRBTS-xxxx/NRBTS-xxxx/NRCELL-1/NRREL-1 | parameter_change_list=${mcc_Para_list} |
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${parameter_change_list}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Update Parameters Operation Should Be Successful	plan_id=${plan_id}  action_id=${update_res['action_id']}

CU Create Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}   ${name}  ${instance_id}
	[Documentation]   CU Create Delta Plan Managed Object Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | parent managed object dist name |
    ...    | name | yes | class name to be created |
    ...    | instance_id | yes | instance id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    |  CU Create Delta Plan Managed Object Should Be Successful | plan_id=${delta_plan_id} | mo_dn=MRBTS-xxxx/NRBTS-xxxx/NRCELL-1 |
    ...    | ...  name=com.nokia.srbts.nrbts:NRREL | instance_id=1 |
    ...    | Description | create one MO called NRREL-1 under MO MRBTS-xxxx/NRBTS-xxxx/NRCELL-1 |
    ${uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${nidd_id}   _Get CU Specifical NIDD ID    name=${name}

    ${nidd}  convert to string  ${nidd_id}
    ${instance}  convert to integer  ${instance_id}

    ${create_res}=   cu.create_managed_object_of_delta_plan   plan_id=${plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=False
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _CU Create Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${create_res['action_id']}


_CU Create Delta Plan Managed Object Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   _CU Create Delta Plan Managed Object Operation Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | action_id of create_managed_object_of_delta_plan |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Create Delta Plan Managed Object Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=  cu.get_create_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success



CU Generate Delta Plan Should Be Successful
    [Documentation]   CU Generate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    *RETURN VALUE*  ${delta_plan_id}
    ...    Example
    ...    | ${delta_plan_id}= | CU Generate Delta Plan Should Be Successful  |
    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    sleep  1s
    ${delta_res}=  cu.generate_delta_plan  plan_name=delta_plan
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
    run keyword and continue on failure   Wait until keyword succeeds  3x  2s
    ...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
    [Return]   ${delta_plan_id}


CU Validate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}
    [Documentation]   CU Validate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Validate Delta Plan Should Be Successful  | plan_id=${delta_plan_id}  |
    ${validate_res}=   cu.validate_delta_plan   plan_id=${plan_id}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful	 plan_id=${plan_id}  action_id=${validate_res['action_id']}

CU Activate Delta Plan Should Be Successful
    [Arguments]   ${plan_id}
    [Documentation]   CU Activate Delta Plan Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Activate Delta Plan Should Be Successful | plan_id=${delta_plan_id}  |
    ${active_res}=   cu.activate_delta_plan   plan_id=${plan_id}
    run keyword and continue on failure   Wait until keyword succeeds  3x  30s
    ...  _Activating Delta Plan Operation Should Be Successful   plan_id=${plan_id}   operation_id=${active_res['operation_id']}

CU Delete Delta Plan Managed Object Should Be Successful
    [Arguments]   ${plan_id}  ${mo_dn}
    [Documentation]   CU Delete Delta Plan Managed Object Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | mo_dn | yes | managed object dist name |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | CU Delete Delta Plan Managed Object Should Be Successful | plan_id=${delta_plan_id} | mo_dn=MRBTS-XXXX/NRBTS-XXXX/NRCELL-1/NRREL-1 |
    ${mo_uuid}   _Get CU Specifical MO UUID   plan_id=${plan_id}    mo_dn=${mo_dn}
    ${delete_res}=   cu.delete_managed_object_of_delta_plan  plan_id=${plan_id}  mo_uuid=${mo_uuid}
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _CU Delete Delta Plan Managed Object Operation Should Be Successful	plan_id=${plan_id}  action_id=${delete_res['action_id']}


_CU Delete Delta Plan Managed Object Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   _CU Delete Delta Plan Managed Object Operation Should Be Successful
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | action_id of delete_managed_object_of_delta_plan |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Delete Delta Plan Managed Object Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=  cu.get_delete_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success



_Get CU Specifical NIDD ID
    [Arguments]  ${name}
    [Documentation]   _Get CU Specifical NIDD ID
    ...  author: huilin.xu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | name | yes | class name |
    ...    *RETURN VALUE*  ${nidd_id}
    ...    Example
    ...    |  ${nidd_id} | _Get CU Specifical NIDD ID | name=com.nokia.srbts.nrbts:NRREL |
    @{all_nidd}   cu.get_nidd
    FOR    ${each_nidd}    IN    @{all_nidd}
      ${nidd_id}  set variable if  '${each_nidd["adaptation_id"]}'=='${name}'   ${each_nidd["nidd_id"]}
       exit for loop if    '${each_nidd["adaptation_id"]}'=='${name}'
    END
    [Return]   ${nidd_id}



############################## CU CM end ##############################
====== CU CM End ======
     log to console  \n*** only used for readable ***

############################## vDU CM Start ##############################
====== vDU CM Start ======
     log to console  \n*** only used for readable ***
All DUs Container Status Should Be Normal
    [Arguments]  ${vdu_index}=0
    log to console  *** tbd ***
    ${pod_abbr_list}   set variable  ${AIC_VDU_PODS.keys()}
    FOR   ${pod_abbr}  IN  @{pod_abbr_list}
       vDU Special Pod Status And Container Number Should Be Expected   pod_abbr=${pod_abbr}    status=Running  vdu_index=${vdu_index}
    END


Get BTS ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get BTS ID From vDU SCF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    list value, contains [<mrbts_id>, <nrbts_id>, <nrdu_id>]
    ...
    ...    Example
    ...    |  ${mrbts_id}  | ${nrbts_id} | ${nrdu_id} | Get BTS ID From vDU SCF | scf_path=/tmp/a.scf |
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRDU"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRDU-(\\d+)"\\s+.*   1  2  3
    ${mrbts_id}  Set Variable If  ${result}   ${result[0][0]}
    ${nrbts_id}  Set Variable If  ${result}   ${result[0][1]}
    ${nrdu_id}   Set Variable If  ${result}   ${result[0][2]}
    [Return]  ${mrbts_id}   ${nrbts_id}  ${nrdu_id}

Get CELL ID From vDU SCF
    [Arguments]  ${scf_path}    ${cell_index}=0
    [Documentation]   Get CELL ID From vDU SCF
    ...    *AUTHOR* zhijiang.shan@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    9.11.2020,zhijiang.shan@nokia-sbell.com, Create New
	...    10.11.2020,zhijiang.shan@nokia-sbell.com, Add ${cell_index} arguments
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    list value, contains [<nrcell_id>]
    ...
    ...    Example
    ...    |  ${nrcell_id}  | Get CELL ID From vDU SCF | scf_path=/tmp/a.scf |
    ...
    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${nrcell_id}  Set Variable   ${result[${cell_index}]}
    [Return]  ${nrcell_id}

Get vDU TNL ID
    [Arguments]  ${scf_path}  ${templateType}=OAM
    [Documentation]   Get vDU TNL ID
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    | templateType | no | templateType, valid value is OAM, 5GUserPlane, default is OAM |
    ...
    ...    *RETURN VALUE*
    ...    TNL id of given templateType.
    ...
    ...    Example
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=OAM |
    ...    |  ${tnl_id}  | Get vDU TNL ID | scf_path=/tmp/a.scf | templateType=5GUserPlane |
    ...
    ${distName}   Get MO distName    scf_path=${scf_path}  templateType=${templateType}

    scf.load_scf  file_path=${scf_path}
    ${tnlDN_val}   scf.get_all_values_from_scf   dist_name=${distName[0]}  p_name=tnlDN

    ${result}     Get Regexp Matches     ${tnlDN_val[0]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)   1
    ${tnl_id}  Set Variable If  ${result}   ${result[0]}
    should be true  ${tnl_id}>=1

    [Return]  ${tnl_id}


Get VDU Conf From SCF
    [Arguments]  ${scf_path}=${EMPTY}   ${vdu_index}=0
    [Documentation]  Get VDU Conf From SCF file.
    ...  author: chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  17.7.2020,chris.l.cao@nokia-sbell.com, Add support to automatically download scf file via REST if ${scf_path} is ${EMPTY}
    ...
    ...    | Input Parameters | Man. | Description |
    ...	   | scf_path  | no | abosolute path of scf file, if it's ${EMPTY} it will download scf from CURRENT plan, default is ${EMPTY} |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Dictionary of configuration in SCF file.
    ...    example: {'mrbts_id': '1234', 'nrbts_id': '5678', 'nrdu_id': '1', 'tnl_oam': '3',
    ...    'tnl_version': 'TNLVDU20B_2006_001' }
    ...
    ...    Example
    ...    | ${vdu_conf} | Get VDU Conf From SCF | scf_path=/home/ute/a.scf |
    ...    | ${vdu_conf} | Get VDU Conf From SCF |
    ...
    ${scf_path}   run keyword if  "${scf_path}"=="${EMPTY}"  Get Temporary Scf From Current Plan   vdu_index=${vdu_index}
       ...    ELSE    set variable  ${scf_path}

    ${mrbts_id}   ${nrbts_id}  ${nrdu_id}  Get BTS ID From vDU SCF    scf_path=${scf_path}
    ${tnl_oam}   Get vDU TNL ID   scf_path=${scf_path}  templateType=OAM
    ${tnl_version}   scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/TNLSVC-1   attribute=version
    ${nrbts_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-${nrdu_id}   attribute=version
    ${mnl_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/MNL-1   attribute=version
    ${eqm_version}  scf.get_mo_attribute   dist_name=MRBTS-${mrbts_id}/EQM-1  attribute=version
    ${conf}   create dictionary
    ...  mrbts_id=${mrbts_id}
    ...  nrbts_id=${nrbts_id}
    ...  nrdu_id=${nrdu_id}
    ...  tnl_oam=${tnl_oam}
    ...  tnl_version=${tnl_version}
    ...  nrbts_version=${nrbts_version}
    ...  mnl_version=${mnl_version}
	...  eqm_version=${eqm_version}
    [Return]  ${conf}


Get Temporary Scf From Current Plan
    #[Arguments]    ${vdu_index}=0
    [Documentation]  Get Temporary Scf From Current Plan
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    scf file full name
    ...
    ...    Example
    ...    | ${vdu_conf} | Get Temporary Scf From Current Plan |
    ...
    ${tmp_scf_path}=  Get A Directory  temp_scf
    ${file_name}   get unique id  prefix=scf_tmp_   suffix=.xml   precise=LOW
    VDU Rest Login
    ${tmp_scf_full_path}  vdu.get_current_plan_file  local_dir_path=${tmp_scf_path}  filename=${file_name}  include_runtime_data=${False}
    [Return]  ${tmp_scf_full_path}


Get MO distName
    [Arguments]   @{para_list}
    [Documentation]  Get MO distName.  It supports multi-parameters filtering and distName filtering.
    ...    When using key=value format, the '=' means 'contain',  e.g, distName=TNL-4 means 'distName' contain 'TNL-4',
    ...    sgwIpAddress=10.68  means 'sgwIpAddress' contain '10.68'
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes | key=value pair, scf_path key should be included! please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return distName list that matched the parameters filter and distName filter. Return type is list.
    ...
    ...    Example
    ...    Get distName according to mixed filter
    ...    | ${scf_path} | set variable | /tmp/scf.xml |
    ...    | scf.load_scf | file_path=${scf_path}      |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | btsName         |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=btsName |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | templateType=OAM |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=templateType |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=tnlDN |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO | icmpDscp |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=IPNO | icmpDscp=10 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=MRBTS-1234/TNLSVC-1/TNL-1/IPNO | icmpDscp=10 |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=icmpDscp |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=ndMldDscp |
    ...
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=TNL-4 |  destIpAddr=10.68 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | sgwIpAddress=10.68 | gtpuPathSupint=60 |
    ...    | ${distName} | Get MO distName | scf_path=${scf_path} | distName=GTPU | sgwIpAddress=10.68 | gtpuPathSupint |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=destIpAddr |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=sgwIpAddress |
    ...    | ${value}    | scf.get_all_values_from_scf | dist_name=${distName[0]} |  p_name=gtpuPathSupint |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{para_list}
    #${key_value_dict_keys}   set variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    Run Keyword If  "scf_path" not in "${key_value_dict_keys}"   Fail  Should give scf_path parameter value!!!
    ${scf_path}     Set Variable  ${key_value_dict["scf_path"]}
    Remove From Dictionary   ${key_value_dict}   scf_path

    Run Keyword If   """distName""" in """${non_key_value_pair_list}"""    Remove Values From List   ${non_key_value_pair_list}   distName

    ${scf_content}   OperatingSystem.Get File   ${scf_path}
    ${xpath}   _Create Xpath    ${non_key_value_pair_list}   ${key_value_dict}
    ${distName_list}   Get_Multi_DistName_By_Xpath_Filter   ${scf_content}   ${xpath}

    [Return]  ${distName_list}


Get VDU Cplane DSCP Value
    [Arguments]  ${vdu_index}=0
    [Documentation]  Get VDU Cplane DSCP Value
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | para_list  | Yes | key=value pair, scf_path key should be included! please see samples |
    ...
    ...    *RETURN VALUE*
    ...    Return distName list that matched the parameters filter and distName filter. Return type is list.
    ...
    ...    Example
    ...    Get distName according to mixed filter
    ...    | ${vdu_cplane_dscp} | Get VDU Cplane DSCP Value    |
    ...
    ${file_path}   Get Temporary Scf From Current Plan   vdu_index=${vdu_index}
    scf.Load_Scf  file_path=${file_path}
    ${vdu_conf}  Get VDU Conf From SCF   scf_path=${file_path}
    ${nrbts_distname}  Set Variable   MRBTS-${vdu_conf["mrbts_id"]}/NRBTS-${vdu_conf["nrbts_id"]}
    ${value}  scf.get_value_from_scf   dist_name=${nrbts_distname}   p_name=cPlaneDscp
    [Return]  ${value}


#_Parse Input Parameter According To Seperator
#    [Arguments]   ${seperator}    @{para_list}
#    [Documentation]    _Parse Input Parameter According To Seperator
#    ...    *AUTHOR* chris.l.cao
#    ...    | Input Parameters | Man. | Description |
#    ...    | seperator | yes | seperator, eg, '='  |
#    ...    | para_list | yes | dictionary, like 'key=value' pair format  |
#    ...    *RETURN VALUE*
#    ...    dictionary of parameter
#    ...
#    ...  Example
#    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | key1=value1 | key2=value2 | key3=value3 | ... |
#    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=500 |
#    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=5 | distName=TNL-3|
#
#    @{non_key_value_pair_list}    create list
#    &{key_value_dict}    Create Dictionary
#
#    ${len}    Get Length    ${para_list}
#    Run Keyword If   ${len}==0   Fail    There is no input parameter while calling this keyword!
#
#    : FOR    ${item}    IN    @{para_list}
#    \    ${out}    Split String    ${item}    ${seperator}    1
#    \    ${len}   Get Length   ${out}
#    \    ${first}    Set Variable    ${out[0]}
#    \    ${second}    Set Variable If    ${len}==1    ${EMPTY}
#        ...    ${len}>=2 and '${out[1]}'=='${EMPTY}'    ${EMPTY}
#        ...    ${len}>=2 and '${out[1]}'!='${EMPTY}'    ${out[1]}
#    \    Run Keyword If   '${second}'=='${EMPTY}'   Append To List   ${non_key_value_pair_list}   ${first}
#    \    Continue For Loop If   '${second}'=='${EMPTY}'
#    \    &{tempdict}    Create Dictionary    ${first}    ${second}
#    \    &{key_value_dict}    Create Dictionary    &{key_value_dict}    &{tempdict}
#
#    [Return]   ${non_key_value_pair_list}   ${key_value_dict}


_Create Xpath
    [Arguments]    ${non_key_value_pair_list}   ${key_value_dict}
    ${tmp_non_key_value_pair_list}   Copy List   ${non_key_value_pair_list}
    ${tmp_key_value_dict}   Copy Dictionary   ${key_value_dict}
    ${len1}   Get Length  ${tmp_non_key_value_pair_list}
    ${len2}   Get Length  ${key_value_dict}
    Should Not Be True  ${len1}==0 and ${len2}==0

    ${contain_list}   Create List

    #handle Non_Key_Value_Pair_List
    Run Keyword If   ${len1}>=1   _Create Xpath Contain List   ${contain_list}    ${tmp_non_key_value_pair_list}

    #handle Key_Value_Dict
    #@{key_list}   set variable    ${tmp_key_value_dict.keys()}
    @{key_list}   evaluate    list(${tmp_key_value_dict})
    FOR    ${i}   IN     @{key_list}
      Continue For Loop If   '${i}'=='distName'
      ${key}  Set Variable   ${i}
      ${value}   Set Variable   ${key_value_dict["${i}"]}
      Append To List  ${contain_list}  descendant::ns:*[local-name()='p' or local-name()='list'][@name="${key}" and contains(text(),"${value}")]
    END

    #handle 'distName' In Key_Value_Dict
    ${tmp_dict}  evaluate   list(${key_value_dict})
    #Run Keyword If    """distName""" in """${key_value_dict.keys()}"""
    Run Keyword If    """distName""" in """${tmp_dict}"""
    ...      append to list    ${contain_list}   contains(@distName, "${key_value_dict["distName"]}")

    ${xpath}   Catenate   SEPARATOR=${SPACE}and${SPACE}      @{contain_list}
    ${xpath}   Set Variable   .//ns:managedObject[${xpath}]
    [Return]   ${xpath}


_Create Xpath Contain List
    [Arguments]     ${contain_list}    ${para_list}
    For   ${i}   IN   @{para_list}
         Append To List    ${contain_list}    descendant::ns:*[local-name()='p' or local-name()='list']/@name="${i}"
    END


vDU Send Commission By RestApi
    [Arguments]  ${scf_path}    ${restapi_version}=cuoam_19b   ${vdu_index}=0
    [Documentation]   send commission on one vdu, including upload validate and activate scf
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.32021, calla.wang@nokia-sbell.com, add sleeping after activated plan file to ensure the restapi can be connected
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...    *RETURN VALUE*
    ...    None
    log to console  \n*** start send commission on vdu ***
    vDU Rest Login  ${restapi_version}  ${vdu_index}
    ${upload_plan_response}=  vdu.upload_plan    ${scf_path}
    wait until keyword succeeds  2min  5s  Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  2min  5s  Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    sleep  90s
    wait until keyword succeeds  10min  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}
    [Teardown]  vDU Rest Logout

Upload Plan Operation Should Be Successful
    [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success


Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}    #${vdu_index}=0   ${gnb_index}=0
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...  23.7.2020,chris.l.cao@nokia-sbell.com, add retry mechanism
    ...  13.8.2020,chris.l.cao@nokia-sbell.com, extend retry window from 20s to 240s
    ...  11.3.2021,calla.wang@nokia-sbell.com, restore the previous logic, no need to login vdu once again and nested wait until
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${activate_plan_response['status']}  success
#    ${rtn}  Wait Until Keyword Succeeds  600   20
#     ...   Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
#     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
#    [Return]  ${rtn}


vDU Send Commission By WebEM
    #[Arguments]    ${scf_file_path}  ${vdu_index}=0
    [Documentation]   Send BTS commission via vdu WebEM.
        ...    author: calla.wang@nokia-sbell.com
         ...   modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
        ...    | Input Parameters | Man. | Description |
        ...	   | scf_file_path | Yes. | Path of commission file |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  vDU Send Commission By WebEM  | c:/tmp/commission.xml |
    vDU WebEM Login
    Log    Send commission by webem not ready!    WARN
    [Teardown]  vDU WebEM Logout


vDU Get All Container Status From WebEM
    [Documentation]   get the vdu all container status from webui
    ...    firstly, use restapi to get container id list, then loop the list to get the specific container status
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...    dict
    ...
    log to console  \n*** get vdu all container status from webui ****


vDU Get RF Software Version
    [Documentation]   get the vdu RF from webui
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...
    log to console  \n*** get vdu RF from vDU WEBEM***


vDU Get All RMOD Information
    [Documentation]   get vdu all rmod information from webui
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...
    ...    *RETURN VALUE*
    ...
    log to console  \n***get vdu all rmod information from webui***


MO Clone
    [Arguments]  ${source_mo_dist_name}   ${target_mo_dist_name}
    [Documentation]    Clone MO with MO content
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | source_mo_dist_name | yes | source_mo_dist_name |
    ...   | target_mo_dist_name | yes | target_mo_dist_name |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | scf.load_scf | file_path=/tmp/a.scf |
    ...   | ${IPADDRESSV4_distname} | set variable | MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | ${IPADDRESSV6_distname} | set variable | MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1 |
    ...   | MO Clone     |  source_mo_dist_name=${IPADDRESSV4_distname} | target_mo_dist_name=${IPADDRESSV6_distname} |
    ...   | scf.save_scf | file_path=/tmp/new.scf |
    ...
    scf.Clone Mo With Descendant Mos     source_mo_dist_name=${source_mo_dist_name}   target_mo_dist_name=${target_mo_dist_name}
    ${old_class_full_value}   scf.Get Mo Attribute  dist_name=${source_mo_dist_name}   attribute=class
    ${old_class_abbr_value}   Set Variable  ${old_class_full_value.split(":")[-1]}
    ${new_class_abbr_value}   Set Variable  ${target_mo_dist_name.split("/")[-1].split("-")[0]}
    ${new_class_full_value}   Replace String  ${old_class_full_value}   ${old_class_abbr_value}  ${new_class_abbr_value}
    scf.Set Mo Attribute  dist_name=${target_mo_dist_name}   attribute=class   value=${new_class_full_value}


MO Replacememt In SCF File
    [Arguments]  ${scf_file}   ${new_mo_content}
    [Documentation]   replace with new MO in scf file.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | scf_file       | yes | scf_file |
    ...   | new_mo_content | yes | new_mo_content, string content of MO content|
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | ${MO} | Generate MO Message For Modifying List Parameters | scf_path=/tmp/scf.xml | action=add | operation=create |
    ...   | ... | distName=MRBTS-5240/NRBTS-2/NRDU-1 |
    ...   | ... | list_para_name=f1Cplane |
    ...   | ... | ipV6AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1 |
    ...   | MO Replacememt In SCF File | scf_file=/tmp/scf.xml | new_mo_content=${MO} |
    ...
    ${managedObject_1st_part}  ${new_content_without_managedObject}  ${dummy}   Fetch_String_With_Regexp   content=${new_mo_content}
    ...   g1_regexp=<managedObject\\s+\\S+.*?>
    ...   g2_regexp=.*
    ...   g3_regexp=</managedObject>

    ${matches}   Get Regexp Matches  ${managedObject_1st_part}   <managedObject\\s+.*?distName="(\\S+)"\\s+.*>   1
    Should Be True  ${matches}
    ${distName}  Set Variable  ${matches[0]}

    OperatingSystem.File Should Exist   ${scf_file}
    ${content}   OperatingSystem.Get File   ${scf_file}

    ${content}   Replace_String_With_Regexp   content=${content}
    ...   g1_regexp=<managedObject\\s+\\S+\\s+distName="${distName}"[^/>]+
    ...   g2_regexp=/
    ...   g3_regexp=>
    ...   g2_new_value=></managedObject

    ${content}   Replace_String_With_Regexp   content=${content}
    ...   g1_regexp=<managedObject\\s+\\S+\\s+distName="${distName}"[^>]+>
    ...   g2_regexp=.*?
    ...   g3_regexp=</managedObject>
    ...   g2_new_value=${new_content_without_managedObject}

    OperatingSystem.Create File   ${scf_file}   ${content}

    scf.Load_Scf  file_path=${scf_file}
    scf.Save_Scf  file_path=${scf_file}


Get MO Content
    [Arguments]  ${scf_path}   ${distname}   ${with_shell}=${True}
    [Documentation]   Get MO Content
    ...    *AUTHOR*chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path  | Yes | distname |
    ...    | distname  | Yes | distname, MRBTS-5240/NRBTS-2  |
    ...    | with_shell  | no | ${True} or ${False},  if ${true}, the returned content includes <managedObject ...> and </managedObject>, |
    ...    |             |    | otherwise they are not included, default value is ${True} |
    ...
    ...    *RETURN VALUE*
    ...    MO content
    ...
    ...    Example
    ...    | ${MO_content} | Get MO Content | scf_path=/tmp/a.scf | distname=MRBTS-5240/NRBTS-2 |
    ...    | ${MO_content} | Get MO Content | scf_path=/tmp/a.scf | distname=MRBTS-5240/NRBTS-2 | with_shell=${False} |
    ...
    ${content}  get file  ${scf_path}
    ${rtn}  run keyword if  "${with_shell}"=="${True}"   _Get MO Content With Shell   scf_path=${scf_path}   distname=${distname}
    ...   ELSE      _Get MO Content Without Shell   scf_path=${scf_path}   distname=${distname}
    [Return]  ${rtn}


_Get MO Content With Shell
    [Arguments]  ${scf_path}   ${distname}
    ${content}  get file  ${scf_path}
    ${o1}   ${o2}   ${o3}   fetch_string_with_regexp   content=${content}
      ...    g1_regexp=.*
      ...    g2_regexp=<managedObject\\s+class="\\S+"\\s+distName="${distname}".*?>.*?
      ...    g3_regexp=</managedObject>
    ${rtn}   catenate  SEPARATOR=\n   ${o2}   ${o3}
    [Return]  ${rtn}


_Get MO Content Without Shell
    [Arguments]  ${scf_path}   ${distname}
    ${content}  get file  ${scf_path}
    ${o1}   ${o2}   ${o3}   fetch_string_with_regexp   content=${content}
      ...    g1_regexp=.*<managedObject\\s+class="\\S+"\\s+distName="${distname}".*?>
      ...    g2_regexp=.*?
      ...    g3_regexp=</managedObject>
    [Return]  ${o2}


_Upload Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    [Documentation]    Upload Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success |
    ...
    ${out}   vdu.Get_Upload_Plan_Operation_Status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"


Upload Plan Status Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Upload Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> |
    ...
     Wait Until Keyword Succeeds  30   3  _Upload Plan Status Should Be Expected   operation_id=${operation_id}    expected_status=success


_Validate Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}   ${plan_id}
    [Documentation]    Validate Plan Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | set variable | sp_7bbfbd44-a3ca-4b22-b948-a0c8a6d3716a |
    ...  | ${out} | vdu.validate_plan | plan_id=${plan_id} |
    ...  | Validate Plan Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success | plan_id=<my_plan_id> |
    ...

    ${out}   vdu.Get_Validate_Plan_Operation_Status   operation_id=${operation_id}   plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Validate Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    [Documentation]   Validate Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | operation_id=<my_operation_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}  Wait Until Keyword Succeeds  20   3
    ...  _Validate Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Is Staged Plan Existed
    [Arguments]  ${plan_name}
    [Documentation]   Is Staged Plan Existed
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...
    ...   *RETURN VALUE*
    ...    Return (1, <real_plan_id>) if desired plan name exists, otherwise return (0, ${EMPTY})
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${bExsit} | ${plan_id} | Is Staged Plan Existed | plan_name=my_plan_name |
    ...
    ${existed}   Set Variable  0
    ${rtn_plan_id}   Set Test Variable  ${EMPTY}
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Return From Keyword If  ${all_plans.__len__()}==0   0   ${EMPTY}
    FOR   ${one_plan}   IN   @{all_plans}
        ${existed}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   1   0
        ${rtn_plan_id}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   ${one_plan["plan_id"]}  ${EMPTY}
        Exit For Loop If  "${one_plan["plan_name"]}"=="${plan_name}"
    END
    [Return]    ${existed}    ${rtn_plan_id}


Delete Plan
    [Arguments]  ${plan_name}
    [Documentation]   Delete Plan. Do nothing if desired plan does not exist.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name to be deleted |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Plan  | plan_name=my_plan_name |
    ...
    ${bExsit}   ${to_be_deleted_plan_id}   Is Staged Plan Existed   plan_name=${plan_name}
    Run Keyword If  ${bExsit}==1   vdu.Delete_Staged_Plan_File   plan_id=${to_be_deleted_plan_id}


Check Maximum Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Plan Number And delete one if reach Maximum number |
    ...
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}


Upload Plan And Validate
    [Arguments]   ${plan_file}  ${plan_name}  ${plan_description}=${EMPTY}  ${validate}=${True}
    [Documentation]   Upload Plan and validate
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_file    | yes | plan_file |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | validate         | no | validate, if ${True} will do validation, otherwise it will not do validation, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>, <validation_id>)
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan and validate | plan_file=/home/ute/scf.xml | plan_name=my_plan_name |
    ...  | ... | validate=${True} |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan and validate | plan_file=/home/ute/scf.xml | plan_name=my_plan_name |
    ...  | ... | validate=${False} |
    ...

    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}

    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}

    Return From Keyword If  "${validate}"=="${False}"   ${temp_plan_id}   ${temp_action_id}  ${temp_validation_id}

    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}
    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}


Validate Plan By REST
    [Arguments]  ${plan_id}   ${retries}=1
    [Documentation]   Validate Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Validate Plan By REST | plan_id=<my_plan_id> |
    ...
    FOR   ${i}   IN RANGE   0   ${retries}
      ${out}  vdu.Validate_Plan   plan_id=${plan_id}
      ${action_id}   Set Variable  ${out["action_id"]}
      ${out}   Validate Plan Status Should Be Successful   operation_id=${action_id}  plan_id=${plan_id}
      ${validation_id}  Set Variable   ${out["validation_id"]}
      sleep   2
    END
    [Return]   ${validation_id}


Upload Plan And Validate And Activate
    [Arguments]   ${plan_file}  ${plan_name}=TA_Upload_Plan_And_Validate_And_Activate  ${plan_description}=${EMPTY}  ${wait_vdu_up}=${False}
    ...   ${retries}=1
    [Documentation]   Upload Plan And Validate And Activate
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   13.8.2020,chris.l.cao@nokia-sbell.com, add sleep  8 second between validation and activation
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_file    | yes | plan_file |
    ...   | plan_name    | No | plan_name, default is TA_Upload_Plan_And_Validate_And_Activate |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | wait_vdu_up     | no | wait_vdu_up, if ${True} will wait until VDU up, otherwise it will not, default is ${False} |
    ...
    ...   *RETURN VALUE*
    ...    Return <plan_id>   <action_id>    <validation_id>
    ...
    ...   Example
    ...  | vdu rest login |
   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
   ...  | ... | wait_vdu_up=${True} |
   ...  | ${plan_id} | ${action_id} | ${validation_id} | l | plan_file=/home/ute/scf.xml | plan_name=plan_name |
   ...  | ... | wait_vdu_up=${False} |
    ...
    log to console  Upload Plan And Validate And Activate
    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}

    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
    sleep   2
    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}   retries=${retries}
    sleep   2
    ${out}   Activate Staged Plan By REST   plan_id=${temp_plan_id}
    run keyword if  "${wait_vdu_up}"=="${True}"   sleep   8
    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   1000  30   OAM Precondition Cell Should Be Onair

    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}


Vdu Pre Activate For Staged Plan
    [Arguments]   ${plan_id}
    [Documentation]   Vdu Pre Activate For Staged Plan
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    Information of pre-activated staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${scf} | set variable | /temp/Configuration_scf_vDU_MVP5238.xml |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate | plan_file=${scf} | plan_name=my_plan_name | validate=${True} |
    ...  | ${out}    | Vdu Pre Activate For Staged Plan | plan_id=${plan_id} |
    ...  | ${out}    | Vdu Activate Pre Activated Staged Plan | plan_id=${out["plan_id"]} |
    ...

    ${out}  vdu.vdu_pre_activate_for_staged_plan   plan_id=${plan_id}
    ${operation_id}   Set Variable  ${out["id"]}
    ${out}  Pre Activate For Staged Plan Status Should Be Successful   plan_id=${plan_id}   operation_id=${operation_id}

    [Return]   ${out}


Pre Activate For Staged Plan Status Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   Pre Activate For Staged Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    Information while pre-activating staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Pre Activate For Staged Plan Status Should Be Successful | plan_id=<plan_id> | operation_id=<my_operation_id> |
    ...
    ${out}   Wait Until Keyword Succeeds  10   3
     ...   _Pre Activate For Staged Plan Status Should Be Expected    plan_id=${plan_id}   operation_id=${operation_id}   expected_status=success
    [Return]  ${out}


_Pre Activate For Staged Plan Status Should Be Expected
    [Arguments]  ${plan_id}   ${operation_id}   ${expected_status}
    [Documentation]    _Pre Activate For Staged Plan Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id          | yes | plan_id |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    Information while pre-activating staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Pre Activate For Staged Plan Status Should Be Expected | plan_id=<plan_id> | operation_id=<operation_id> | expected_status=success |
    ...
    ${out}   vdu.vdu_get_pre_activate_operation_status_for_staged_plan    plan_id=${plan_id}  operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Vdu Activate Pre Activated Staged Plan
    [Arguments]   ${plan_id}
    [Documentation]   Vdu Activate Pre Activated Staged Plan
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...   ${True}  or  ${False}
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${scf} | set variable | /temp/Configuration_scf_vDU_MVP5238.xml |
    ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate | plan_file=${scf} | plan_name=my_plan_name | validate=${True} |
    ...  | ${out}    | Vdu Pre Activate For Staged Plan | plan_id=${plan_id} |
    ...  | ${out}    | Vdu Activate Pre Activated Staged Plan | plan_id=${out["plan_id"]} |
    ...
    ${operation_id}  vdu.vdu_activate_pre_activated_plan   plan_id=${plan_id}
    sleep  300
    ${out}  Vdu Activate Pre Activated Staged Plan Status Should Be Successful   plan_id=${plan_id}   operation_id=${operation_id}

    [Return]   ${out}


Vdu Activate Pre Activated Staged Plan Status Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   Vdu Activate Pre Activated Staged Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    activating result of staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Vdu Activate Pre Activated Staged Plan Status Should Be Successful | plan_id=<plan_id> | operation_id=<my_operation_id> |
    ...
    vdu rest login
    ${out}   Wait Until Keyword Succeeds  30  5
     ...   _Vdu Activate Pre Activated Staged Plan Status Should Be Should Be Expected
     ...   plan_id=${plan_id}   operation_id=${operation_id}   expected_status=${True}
    [Return]  ${out}


_Vdu Activate Pre Activated Staged Plan Status Should Be Should Be Expected
    [Arguments]  ${plan_id}   ${operation_id}   ${expected_status}
    [Documentation]    _Vdu Activate Pre Activated Staged Plan Status Should Be Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status, ${True} or ${False} |
    ...
    ...   *RETURN VALUE*
    ...    activating result of staged plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Pre Activate For Staged Plan Status Should Be Expected | plan_id=<plan_id> | operation_id=<operation_id> | expected_status=${True} |
    ...
    ${out}   vdu.get_activated_operation_status_for_preactivated_plan    plan_id=${plan_id}  operation_id=${operation_id}
    Should Be True  "${out}"=="${expected_status}"
    ${expected_result}   Set Variable  ok
    ${out1}   vdu.get_activated_operation_detail_status_for_preactivated_plan  plan_id=${plan_id}  operation_id=${operation_id}
    ${status}    Set Variable  ${out1['status']}
    Should Be True  "${status}"=="${expected_result}"
    [Return]  ${out}  ${out1}


Update Staged Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 |
    ...  | ${validation_id} | Update Staged Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
    ...  | ${validation_id} | Update Staged Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_staged_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}   Update Staged Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}


Update Staged Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Update Staged Plan Parameter Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Staged Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}   wait until keyword succeeds  20   2   _Update Staged Plan Parameter Should Be Expected
     ...   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Update Staged Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Update Staged Plan Parameter Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_update_paras_action_status_of_staged_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Delete Staged Plan MO
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=30
    [Documentation]   Delete Staged Plan MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | timeout    | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Delete Staged Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.delete_mo_of_staged_plan   staged_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Delete Staged Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}


Delete Staged Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Delete Staged Plan MO Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Staged Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Delete Staged Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Delete Staged Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Delete Staged Plan MO Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Staged Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_deleting_mo_action_state_of_staged_plan      staged_plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Delete Delta Plan
    [Arguments]  ${plan_name}
    [Documentation]   Delete Delta Plan. Do nothing if desired plan does not exist.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name to be deleted |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Plan  | plan_name=my_plan_name |
    ...
    ${bExsit}   ${to_be_deleted_plan_id}   Is Delta Plan Existed   plan_name=${plan_name}
    Run Keyword If  ${bExsit}==1   vdu.delete_delta_plan_file   plan_id=${to_be_deleted_plan_id}


Is Delta Plan Existed
    [Arguments]  ${plan_name}
    [Documentation]   Is Delta Plan Existed
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...
    ...   *RETURN VALUE*
    ...    Return (1, <real_plan_id>) if desired plan name exists, otherwise return (0, ${EMPTY})
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${bExsit} | ${plan_id} | Is Delta Plan Existed | plan_name=my_plan_name |
    ...
    ${existed}   Set Variable  0
    ${rtn_plan_id}   Set Test Variable  ${EMPTY}
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Return From Keyword If  ${all_plans.__len__()}==0   0   ${EMPTY}
    FOR   ${one_plan}   IN   @{all_plans}
        ${existed}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   1   0
        ${rtn_plan_id}   Set Variable If  "${one_plan["plan_name"]}"=="${plan_name}"   ${one_plan["plan_id"]}  ${EMPTY}
        Exit For Loop If  "${one_plan["plan_name"]}"=="${plan_name}"
    END
    [Return]    ${existed}    ${rtn_plan_id}


Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Delta Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Delta Plan Number And delete one if reach Maximum number |
    ...
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Should Be True  ${all_plans.__len__()}<=1
    Run Keyword If  ${all_plans.__len__()}==1   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    #Run Keyword If  ${all_plans.__len__()}==1   vdu.delete_delta_plan_file   plan_id=${all_plans[0]["plan_id"]}
    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}


Generate Delta Plan
    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}
    [Documentation]   Generate Delta Plan
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>)
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=my_plan_name |
    ...
    run keyword if  "${delete_old_one}"=="${True}"   Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}

    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}

    Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}
    [Return]   ${temp_plan_id}   ${temp_action_id}


_Generate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}
    [Documentation]   _Generate Delta Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id       | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...
    ${out}   vdu.Get_Delta_Plan_Generated_Action_Status   action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"


Generate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}
    [Documentation]   Generate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Generate Delta Plan Status Should Be Successful | action_id=<my_action_id> |
    ...
    Wait Until Keyword Succeeds  30   3  _Generate Delta Plan Status Should Be Expected   action_id=${action_id}    expected_status=success


Update Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
    ...
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}    Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}


Update Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Update Delta Plan Parameter Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Update Delta Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Update Delta Plan Parameter Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_update_paras_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


_Validate Delta Plan Status Should Be Expected
    [Arguments]  ${action_id}   ${expected_status}   ${plan_id}
    ${out}   vdu.Get_Validate_Delta_Plan_Operation_Status   action_id=${action_id}   delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Validate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}
    [Documentation]   Validate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Validate Delta Plan By REST
    [Arguments]  ${plan_id}
    [Documentation]   Validate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Delta Plan Number And Delete One If Reach Maximum Number |
    ...  | ${delta_plan_name} | get unique id | prefix=TA_delta_plan | precise=LOW |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=${delta_plan_name} | plan_description=TA |
    ...  | ${TCE_Info_1} | create dictionary | tceIpAddress=1.1.1.1 | tcePortNumber=5000 |
    ...  | ${mo} | set variable | MRBTS-5200/MNL-1/TCEADM-1/TCE-1 |
    ...  | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${mo} | updated_paras_dict=${TCE_Info_1} | operation=add |
    ...  |  ${validation_id} | Validate Delta Plan By REST | plan_id=${planid} |
    ...  | Activate Delta Plan By REST | ${plan_id} | wait_vdu_up=${True} |
    ...

    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}



_Activate Delta Plan Status Should Be Expected
    [Arguments]  ${operation_id}    ${plan_id}   ${expected_status}
    ${out}   vdu.Get_Activate_Delta_Plan_Operation_Status   operation_id=${operation_id}   delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Activate Delta Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    [Documentation]   Activate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Activate Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ...
    ${rtn}   Wait until keyword succeeds  600  30s
     ...   _Activate Delta Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Activate Delta Plan By REST
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${wait_vdu_up}=${False}   ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example of changing btsName
    ...   | VDU Rest Login |
    ...   | ${VDU_CONF} | Get VDU Conf From SCF |
    ...   | ${plan_id} |  ${action_id}  | Generate Delta Plan |  plan_name=changeBTSName |
    ...   | ${distname} |  Set Variable | MRBTS-${VDU_CONF["mrbts_id"]} |
    ...   | ${para_dict} | create dictionary |   btsName=btsName_new |
    ...   | Update Delta Plan Parameter | plan_id=${plan_id} | mo_dn=${distname} | updated_paras_dict=${para_dict} | operation=replace |
    ...   | Validate Delta Plan By REST |  ${plan_id} |
    ...   | Activate Delta Plan By REST |  ${plan_id} |
    ...   | VDU Rest Logout |
    ...
    ${temp_path}  Get A Directory  delta_plan
    ${tmp_file_id}   get unique id  precise=LOW
    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${temp_path}   local_filename=${tmp_file_id}.xml
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  20   OAM Precondition Cell Should Be Onair


Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}
    [Documentation]   Delete Delta Plan By Plan Id
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Delete Delta Plan By Plan Id | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ...
    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}
    log to console  ${out}
    print a dictionary  ${out}
    Make Sure Delta Plan Is Deleted


Make Sure Delta Plan Is Deleted
    [Documentation]   Make Sure Delta Plan Is Deleted
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Make Sure Delta Plan Is Deleted |
    ...   | VDU Rest Logout |
    ...
    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once


_Make Sure Delta Plan Is Deleted Once
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Should Be True  ${all_plans.__len__()}==0


VDU Online Change Parameters By Delta Plan REST
    [Arguments]     ${mo_dn}   ${updated_paras_list}   ${operation}=replace   ${activate}=${True}
    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   VDU Online Change Parameters By Delta Plan REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    modified by:   <1-Mar-2021>, <rifeng>, <e.g. add argument wait_vdu_up to wait vdu onair for parameter need reset vdu>
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
    ...   |                      |     | {'f1Cplane/0/ipV4AddressDN1':'MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1', 'para2':'value2'} |
    ...   | operation           | no |  the operation - add, replace, remove, revert. The default is replace |
    ...   | activate           | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | wait_vdu_up       | no | default is ${False} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...   | VDU Rest Logout |
    ...
    ...   Without activate it:
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
    ...
    ${timeout}   convert to integer  ${timeout}

    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${out}   Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}

    ${validation_id}  Validate Delta Plan By REST  plan_id=${planid}

    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST  plan_id=${plan_id}   force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    wait_vdu_up=${wait_vdu_up}



Generate MO Message For Modifying List Parameters
    [Arguments]     @{parameter_list}
    [Documentation]   Generate MO Message For Modifying List Parameters
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | action        | Yes | add, update or delete action for list content , default is add |
    ...    | operation     | Yes | create, update or delete for operation attribute of managedObject,|
    ...    | distName      | Yes | distName, e.g, MRBTS-2883/MNL-1/BTSSCL-1/TRSNW-1 |
    ...    | list_para_name | Yes | list parameter name under which you want to change parameters value |
    ...    | para_list  | Yes | key=value pair, it supports multi-parameters change. 'key' is the parameter where you want to change its value, |
    ...    |            |     | 'value' is the new value you want to assign. please see samples |
    ...
    ...    *RETURN VALUE*
    ...    MO message with modified parameters
    ...
    ...    Example
    ...    | ${MO} | Generate MO Message For Modifying List Parameters | scf_path=/tmp/scf.xml | action=update | operation=create |
    ...   | ... |  distName=MRBTS-5240/NRBTS-2/NRDU-1 |
    ...   | ... | list_para_name=f1Cplane |
    ...   | ... | ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | ... | ipV6AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1 |
    ...
    ${non_key_value_pair_list}   ${key_value_dict}   _Parse Input Parameter According To Seperator   =   @{parameter_list}
    #${key_value_dict_keys}   Set Variable  ${key_value_dict.keys()}
    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    Run Keyword If  "scf_path" not in "${key_value_dict_keys}"   Fail  Should give scf_path parameter value!!!
    Run Keyword If  "action" not in "${key_value_dict_keys}"   Fail  Should give action parameter value!!!
    Run Keyword If  "operation" not in "${key_value_dict_keys}"   Fail  Should give operation parameter value!!!
    Run Keyword If  "distName" not in "${key_value_dict_keys}"   Fail  Should give distName parameter value!!!
    Run Keyword If  "list_para_name" not in "${key_value_dict_keys}"   Fail  Should give list_para_name parameter value!!!

    ${scf_path}     Set Variable  ${key_value_dict["scf_path"]}
    ${action}     Set Variable  ${key_value_dict["action"]}
    ${operation}     Set Variable  ${key_value_dict["operation"]}
    ${distName}     Set Variable  ${key_value_dict["distName"]}
    ${list_para_name}     Set Variable  ${key_value_dict["list_para_name"]}

    Remove From Dictionary   ${key_value_dict}   scf_path
    Remove From Dictionary   ${key_value_dict}   action
    Remove From Dictionary   ${key_value_dict}   operation
    Remove From Dictionary   ${key_value_dict}   distName
    Remove From Dictionary   ${key_value_dict}   list_para_name

    Remove Values From List   ${key_value_dict_keys}   scf_path
    Remove Values From List   ${key_value_dict_keys}   action
    Remove Values From List   ${key_value_dict_keys}   operation
    Remove Values From List   ${key_value_dict_keys}   distName
    Remove Values From List   ${key_value_dict_keys}   list_para_name

    Run Keyword If   '${action}'!='add' and '${action}'!='update' and '${action}'!='delete'
    ...    Fail    action should be add, update or delete!

    ${version}   scf.Get_Mo_Attribute   dist_name=${distName}  attribute=version
    ${class_name}   scf.Get_Mo_Attribute   dist_name=${distName}  attribute=class

    ${xml_handler}  Parse Xml  ${scf_path}
    @{MachedNode}   XML.get element  ${xml_handler}  xpath=.//managedObject[@distName="${distName}"]
    ${len}   Get Length   ${MachedNode}

    ${msg}   Set Variable    ${EMPTY}
    #handle Every Parameter Under ${distName}
    For  ${onenode}   IN   @{MachedNode}
        ${name_attribute}   XML.Get Element Attribute   ${onenode}   name
        ${res}  Run Keyword If   '${name_attribute}'=='${list_para_name}'   _Get Modified List Parameter Value
        ...   xml_node=${onenode}   action=${action}   dict_keys=${key_value_dict_keys}   dict_para=${key_value_dict}
        ...   ELSE   XML.Element To String  ${onenode}
        ${res}   Prehandle XML Content  ${res}
        ${msg}   Catenate    SEPARATOR=\n    ${msg}    ${res}
    END

    ${MO}   Catenate   SEPARATOR=\n  <managedObject class="${class_name}" distName="${distName}" operation="${operation}" version="${version}">
    ...        ${msg}
    ...  </managedObject>
    [Return]  ${MO}


Activate Staged Plan By REST
    [Arguments]  ${plan_id}
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...
    ...   *RETURN VALUE*
    ...    Activate plan operation information.
    ...
    ...   Example
    ...   | VDU Rest Login |
    ...   | Activate Staged Plan By REST | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ...
    ${out}   vdu.activate_plan   plan_id=${plan_id}
    print a dictionary  ${out}
    ${action_id}  set variable   ${out['id']}

    ${out}   Activate Plan Operation Should Be Successful With Retry   action_id=${action_id}   plan_id=${plan_id}
    [Return]  ${out}


Activate Plan Operation Should Be Successful With Retry
    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    ${rtn}  Wait Until Keyword Succeeds  900   30
     ...   _Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${l}


_Activate Plan Operation Status Should Be Expected
    [Arguments]   ${plan_id}  ${operation_id}   ${expected_status}   ${vdu_index}=0   ${gnb_index}=0
    #vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    #${out}   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
    #Should Be True  "${out["status"]}"=="${expected_status}"

    ${r}  ${out}   run keyword and ignore error   vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    should be true    "${r}"=="PASS"
    return from keyword if   "${r}"!="PASS"

    ${r}  ${out}   run keyword and ignore error
       ...   vdu.get_activate_plan_operation_status   plan_id=${plan_id}   operation_id=${operation_id}
    run keyword if    "${r}"!="PASS"   run keyword and ignore error  Collect VDU Infrastructure Log
    should be true    "${r}"=="PASS"

    Should Be True    "${out["status"]}"=="${expected_status}"

    [Return]  ${out}


Full Commission SCF On VDU
    [Arguments]  ${scf_file}=${EMPTY}   ${build_number}=${EMPTY}
    [Documentation]   Full Commission SCF On VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.07.2020,chris.l.cao@nokia-sbell.com, initialize version
    ...   17.06.2021,chris.l.cao@nokia-sbell.com, change according to no scf file in S3 server
    ...
    ...   | Input Parameters   | Man. | Description |
    ...   | scf_file | no | scf_file  |
    ...   | build_number | no | build_number |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Full Commission SCF On VDU |
    ...
    log to console  Full Commission SCF On VDU
    ${testline_name}   Get TestLine Name From TestLine
    #${build_number}    Get Running Build Number
    #${scf_file}   Download SCF File From SCF File Server   tl_name=${testline_name}     build_number=${build_number}
    should be true  ${scf_file.__len__()>0}

    VDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    log to console  Begin to commission SCF file...
    ${out}  Upload Plan And Validate And Activate  plan_file=${scf_file}   plan_name=${testline_name}_${build_number}
    sleep   2


Restore Environment To Onair
    [Arguments]  ${build_number}   ${vdu_release_name_prefix}=aic  ${need_redeployment}=${False}   ${commission}=${True}
    ...    ${remote_yaml_file_info}=${EMPTY}   ${need_check_on_air}=${True}  ${check_on_air_timeout}=1000
    [Teardown]  Disconnect All SSH Connections
    [Documentation]   Restore Environment To Onair, it will fetch SCF file from SCF file server automatically.
    ...   It will fetch SCF file automatically from SCF file server.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.07.2020,chris.l.cao@nokia-sbell.com, add need_commission parameter
    ...   4.08.2020,chris.l.cao@nokia-sbell.com, add to call 'Make Sure Environment Is Ready From Transport Aspect'
    ...   13.08.2020,chris.l.cao@nokia-sbell.com, remove build number because it can be from vdu_chart_name
    ...   3.09.2020,chris.l.cao@nokia-sbell.com, adapt to single package for #1222 build
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | build_number      | no | build_number |
    ...   | ${vdu_release_name_prefix} | no | vdu_release_name prefix, default value is aic |
    ...   | need_redeployment   | no | need re-deployment if ${True}, otherwise need not re-deployment VDU, default is ${False} |
    ...   | need_commission    | no |  commission if ${True}, otherwise will not commission SCf file, default is ${True} |
    ...   | remote_yaml_file_info  | no | remote_yaml_file_info, default is ${EMPTY}, it means it will download remote_yaml file itself |
    ...   | need_check_on_air  | no | need_check_on_air, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Restore Environment To Onair | build_number=0.390.1222 |
    ...   | Restore Environment To Onair | build_number=0.390.1222 | ${vdu_release_name_prefix}=aic |
    ...  | Restore Environment To Onair | build_number=0.390.1222 | ${vdu_release_name_prefix}=aic | need_redeployment=${False} |
    ...   | Restore Environment To Onair | build_number=0.390.1222 | need_redeployment=${True} | commission=${True} |
    ...   | Restore Environment To Onair | build_number=0.390.1222 | need_redeployment=${True} |  commission=${False} |
    ...
    Log To Console  Restore Environment To Onair with ${build_number} need_redeployment:${need_redeployment} commission:${commission}

    ${conf_dict_vdu_pvc}     run keyword if  "${need_redeployment}"=="${True}"   Get VDU PVC Vnf Config Dictionary From TestLine
    ${conf_dict_vdu_network}     run keyword if  "${need_redeployment}"=="${True}"   Get VDU Network Vnf Config Dictionary From TestLine
    ${conf_dict_vdu}     run keyword if  "${need_redeployment}"=="${True}"   Get VDU Vnf Config Dictionary From TestLine

    ${remote_yaml_file_info}    run keyword if  "${need_redeployment}"=="${True}" and "${remote_yaml_file_info}"=="${EMPTY}"
          ...  Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster
          ...  override_dict_vdu_pvc=${conf_dict_vdu_pvc}
          ...  override_dict_vdu_network=${conf_dict_vdu_network}
          ...  override_dict_vdu=${conf_dict_vdu}
          ...  build_number=${build_number}
      ...   ELSE   set variable   ${remote_yaml_file_info}

    ${remote_yaml_file}   set variable if  "${need_redeployment}"=="${True}"    ${remote_yaml_file_info["remote_vdu_chart_yaml_file"]}

    run keyword if  "${need_redeployment}"=="${True}"   VDU Should Not Exist
    run keyword if  "${need_redeployment}"=="${True}"   Do Patch Before Deploy    ${remote_yaml_file_info}   build_number=${build_number}

    #deploy vDU
    ${r}   run keyword if  "${need_redeployment}"=="${True}"    run keyword and ignore error   Deploy VDU
         ...  yaml_file=${remote_yaml_file}    vdu_release_name_prefix=${vdu_release_name_prefix}
    run keyword if  "${need_redeployment}"=="${True}"    run keyword if  "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"
    ${flag}   _Get Flag for Restore Environment To Onair
    run keyword if   ${flag}==0   Fail   'deploy vDU':FAIL!

    #Check VDU Critical POD Should Be Good
    #${r}  run keyword and ignore error  wait until keyword succeeds  180  5   Check VDU Critical POD Should Be Good
    # ...   console_msg=Deploy VDU:Start to check pod status after deploy vdu(1)-(timeout:180)
    #run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    #return from keyword if  "${r[0]}"!="PASS"

    ${r}    Check VDU Critical POD Should Be Good And Return Immediately If Failed
     ...   retries_time=15   interval=10
     ...   console_msg=Deploy VDU:Start to check pod status after deploy vdu(1)-(retries:15)
    run keyword if   "${r}"!="${True}"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if  "${r}"!="${True}"

    #Check VDU Critical POD Should Be Good again
    sleep   30
    ${r}  run keyword and ignore error   wait until keyword succeeds  180  10   Check VDU Critical POD Should Be Good
     ...   console_msg=Deploy VDU:Start to check pod status after deploy vdu(2)-(timeout:180)
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if  "${r[0]}"!="PASS"

    #Do Patch After Deploy
    run keyword if  "${need_redeployment}"=="${True}"   Do Patch After Deploy   build_number=${build_number}

    # Check VDU Network To Gateway Connection Should Be OK
    #run keyword if  "${need_redeployment}"=="${True}"   sleep   30
    #${r}   run keyword if  "${need_redeployment}"=="${True}"   run keyword and ignore error   Check VDU Network To Gateway Connection Should Be OK
    #run keyword if  "${need_redeployment}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    #run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #add route for VDU OAMCP & UP
    #${branch_type}   Get Branch Type   build_number=${build_number}
    #${r}   run keyword if  "${branch_type}"=="PV_bad_branch" and "${need_redeployment}"=="${True}"   Add Route To Container Directly
    #run keyword if   "${branch_type}"=="PV_bad_branch" and "${need_redeployment}"=="${True}"   return from keyword if   "${r}"=="${False}"

    #====end of re-deployment====================================

    log to console  commission:${commission}
    #return directly if need not commission
    return from keyword if   "${commission}"=="${False}"

    #Redeploy RUPROXY
    run keyword if  "${commission}"=="${True}"   log to console  Redeploy RUPROXY
    ${r}   run keyword if  "${need_redeployment}"=="${True}"   run keyword and ignore error   Redeploy RUPROXY
    run keyword if  "${need_redeployment}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Redeploy rumoduleagent
    run keyword if  "${commission}"=="${True}"   log to console  Redeploy rumoduleagent
    ${r}   run keyword if  "${need_redeployment}"=="${True}"   run keyword and ignore error   Redeploy rumoduleagent
    run keyword if  "${need_redeployment}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Make Sure Environment Is Ready From Transport Aspect
    log to console  Make Sure Environment Is Ready From Transport Aspect(detection_time=300)
    ${r}   run keyword and ignore error  Make Sure Environment Is Ready From Transport Aspect   detection_time=300
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if   "${r[0]}"!="PASS"

    #Connection State Should Be Good Between VDU And RU:1
    #run keyword if  "${commission}"=="${True}"
    #...   log to console   Connection State Should Be Good Between RUPROXY And RU(timeout=300)
    #${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  1000  30
    # ...  Connection State Should Be Good Between VDU And RU   expected=1
    #run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    #run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    run keyword if  "${commission}"=="${True}"
    ...   log to console   Connection State Should Be Good Between RUPROXY And RU(timeout=240)
    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  240  30
     ...  Connection State Should Be Good Between VDU And RU   expected=1
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"   run keyword and ignore error   Plugout RU Cable
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"   run keyword and ignore error   sleep   120
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"   run keyword and ignore error   Plugin RU Cable
    run keyword if  "${commission}"=="${True}"
    ...   log to console   Connection State Should Be Good Between RUPROXY And RU(after plugout/plugin RU cable,timeout=600)
    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  600  30
     ...  Connection State Should Be Good Between VDU And RU   expected=1
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Check VDU Critical POD Should Be Good
    ${r}   run keyword and ignore error  Check VDU Critical POD Should Be Good
     ...   console_msg=Restore Environment To Onair:Start to check pod status after deploy vdu(3)
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if   "${r[0]}"!="PASS"

    #Wait FHGW syncStatus OK
    log to console  Wait FHGW syncStatus OK(timeout=300)...
    ${r}   run keyword and ignore error   wait until keyword succeeds   300  15
       ...  FHGW Sync State Should Be Locked
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if   "${r[0]}"!="PASS"
    run keyword if  "${commission}"=="${True}"   sleep   10

    # Full Commission SCF On VDU
    ${r}   run keyword if  "${commission}"=="${True}"   run keyword and ignore error   Full Commission SCF On VDU
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    run keyword if  "${commission}"=="${True}"   log to console   sleep 2m
    run keyword if  "${commission}"=="${True}"     sleep   2m

    #Connection State Should Be Good Between VDU And RU:2
    run keyword if  "${commission}"=="${True}"
    ...   log to console   Connection State Should Be Good Between VDU And RUPROXY(timeout=500)
    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  500  20
     ...  Connection State Should Be Good Between VDU And RU   expected=2
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    log to console  need_check_on_air:${need_check_on_air}
    #return directly if need not check on-air
    return from keyword if   "${need_check_on_air}"=="${False}"

    #OAM Precondition Cell Should Be Onair
    run keyword if  "${commission}"=="${True}"   log to console  OAM Precondition Cell Should Be Onair(timeout=${check_on_air_timeout})
    ${r}   run keyword if  "${commission}"=="${True}"  run keyword and ignore error
     ...   wait until keyword succeeds   ${check_on_air_timeout}  30   OAM Precondition Cell Should Be Onair For Deploy VDU
    run keyword if  "${commission}"=="${True}"   run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"   return from keyword if   "${r[0]}"!="PASS"

    #Should Have Power On All RUs


Restore Environment To Onair NCS
    [Arguments]  ${build_number}   ${vdu_release_name_prefix}=aic  ${need_redeployment}=${False}   ${commission}=${True}
    ...    ${remote_yaml_file_info}=${EMPTY}   ${need_check_on_air}=${True}  ${check_on_air_timeout}=1000
    ...    ${scf_file}=${EMPTY}
    [Teardown]  Disconnect All SSH Connections
    [Documentation]   Restore Environment To Onair NCS, it will fetch SCF file from SCF file server automatically.
    ...   It will fetch SCF file automatically from SCF file server.
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.07.2020,chris.l.cao@nokia-sbell.com, add need_commission parameter
    ...   4.08.2020,chris.l.cao@nokia-sbell.com, add to call 'Make Sure Environment Is Ready From Transport Aspect'
    ...   13.08.2020,chris.l.cao@nokia-sbell.com, remove build number because it can be from vdu_chart_name
    ...   3.09.2020,chris.l.cao@nokia-sbell.com, adapt to single package for #1222 build
    ...   17.06.2021,chris.l.cao@nokia-sbell.com, change according to no scf file in S3 server
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | build_number      | no | build_number |
    ...   | ${vdu_release_name_prefix} | no | vdu_release_name prefix, default value is aic |
    ...   | need_redeployment   | no | need re-deployment if ${True}, otherwise need not re-deployment VDU, default is ${False} |
    ...   | need_commission    | no |  commission if ${True}, otherwise will not commission SCf file, default is ${True} |
    ...   | remote_yaml_file_info  | no | remote_yaml_file_info, default is ${EMPTY}, it means it will download remote_yaml file itself |
    ...   | need_check_on_air  | no | need_check_on_air, default is ${True} |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Restore Environment To Onair | build_number=0.390.1222 |
    ...   | Restore Environment To Onair | build_number=0.390.1222 | ${vdu_release_name_prefix}=aic |
    ...  | Restore Environment To Onair | build_number=0.390.1222 | ${vdu_release_name_prefix}=aic | need_redeployment=${False} |
    ...   | Restore Environment To Onair | build_number=0.390.1222 | need_redeployment=${True} | commission=${True} |
    ...   | Restore Environment To Onair | build_number=0.390.1222 | need_redeployment=${True} |  commission=${False} |
    ...
    Log To Console  Restore Environment To Onair with ${build_number} need_redeployment:${need_redeployment} commission:${commission}

    should be true  "${scf_file}"!="${EMPTY}"

    #Wait FHGW syncStatus OK
    log to console  Wait FHGW syncStatus OK(timeout=300)...
    ${r}   run keyword and ignore error   wait until keyword succeeds   300  15
       ...  FHGW Sync State Should Be Locked
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if   "${r[0]}"!="PASS"
    run keyword if  "${commission}"=="${True}"   sleep   10

    ${conf_dict_vdu_pvc}     run keyword if  "${need_redeployment}"=="${True}"   Get VDU PVC Vnf Config Dictionary From TestLine
    ${conf_dict_vdu_network}     run keyword if  "${need_redeployment}"=="${True}"   Get VDU Network Vnf Config Dictionary From TestLine
    ${conf_dict_vdu}     run keyword if  "${need_redeployment}"=="${True}"   Get VDU Vnf Config Dictionary From TestLine

    ${remote_yaml_file_info}    run keyword if  "${need_redeployment}"=="${True}" and "${remote_yaml_file_info}"=="${EMPTY}"
          ...  Download VDU Chart To UTE Server And Override Value And Upload To K8s Cluster NCS
          ...  override_dict_vdu_pvc=${conf_dict_vdu_pvc}
          ...  override_dict_vdu_network=${conf_dict_vdu_network}
          ...  override_dict_vdu=${conf_dict_vdu}
          ...  build_number=${build_number}
      ...   ELSE   set variable   ${remote_yaml_file_info}

    ${remote_yaml_file}   set variable if  "${need_redeployment}"=="${True}"    ${remote_yaml_file_info["remote_vdu_chart_yaml_file"]}

    run keyword if  "${need_redeployment}"=="${True}"   VDU Should Not Exist
    run keyword if  "${need_redeployment}"=="${True}"   Do Patch Before Deploy    ${remote_yaml_file_info}   build_number=${build_number}

    #deploy vDU
    ${r}   run keyword if  "${need_redeployment}"=="${True}"    run keyword and ignore error   Deploy VDU NCS
         ...  yaml_file=${remote_yaml_file}    vdu_release_name_prefix=${vdu_release_name_prefix}
    run keyword if  "${need_redeployment}"=="${True}"    run keyword if  "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"
    ${flag}   _Get Flag for Restore Environment To Onair
    run keyword if   ${flag}==0   Fail   'deploy vDU':FAIL!

    #Check VDU Critical POD Should Be Good
    #${r}  run keyword and ignore error  wait until keyword succeeds  180  5   Check VDU Critical POD Should Be Good
    # ...   console_msg=Deploy VDU:Start to check pod status after deploy vdu(1)-(timeout:180)
    #run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    #return from keyword if  "${r[0]}"!="PASS"

    ${r}    Check VDU Critical POD Should Be Good And Return Immediately If Failed
     ...   retries_time=15   interval=10
     ...   console_msg=Deploy VDU:Start to check pod status after deploy vdu(1)-(retries:15)
    run keyword if   "${r}"!="${True}"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if  "${r}"!="${True}"

    #Check VDU Critical POD Should Be Good again
    sleep   15
    ${r}  run keyword and ignore error   wait until keyword succeeds  180  10   Check VDU Critical POD Should Be Good
     ...   console_msg=Deploy VDU:Start to check pod status after deploy vdu(2)-(timeout:180)
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if  "${r[0]}"!="PASS"

    #Do Patch After Deploy
    run keyword if  "${need_redeployment}"=="${True}"   Do Patch After Deploy   build_number=${build_number}

    # Check VDU Network To Gateway Connection Should Be OK
    #run keyword if  "${need_redeployment}"=="${True}"   sleep   30
    #${r}   run keyword if  "${need_redeployment}"=="${True}"   run keyword and ignore error   Check VDU Network To Gateway Connection Should Be OK
    #run keyword if  "${need_redeployment}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    #run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #====end of re-deployment====================================

    log to console  commission:${commission}
    #return directly if need not commission
    return from keyword if   "${commission}"=="${False}"

    #Redeploy RUPROXY
    run keyword if  "${commission}"=="${True}"   log to console  Redeploy RUPROXY
    ${r}   run keyword if  "${need_redeployment}"=="${True}"   run keyword and ignore error   Redeploy RUPROXY
    run keyword if  "${need_redeployment}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Redeploy rumoduleagent
    run keyword if  "${commission}"=="${True}"   log to console  Redeploy rumoduleagent
    ${r}   run keyword if  "${need_redeployment}"=="${True}"   run keyword and ignore error   Redeploy rumoduleagent
    run keyword if  "${need_redeployment}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${need_redeployment}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Make Sure Environment Is Ready From Transport Aspect
    log to console  Make Sure Environment Is Ready From Transport Aspect(detection_time=300)
    ${r}   run keyword and ignore error  Make Sure Environment Is Ready From Transport Aspect   detection_time=300
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if   "${r[0]}"!="PASS"

    #Connection State Should Be Good Between VDU And RU:1
#    run keyword if  "${commission}"=="${True}"
#    ...   log to console   Connection State Should Be Good Between RUPROXY And RU(timeout=300)
#    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  1000  30
#     ...  Connection State Should Be Good Between VDU And RU   expected=1
#    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
#    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    run keyword if  "${commission}"=="${True}"
    ...   log to console   Connection State Should Be Good Between RUPROXY And RU(timeout=240)
    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  240  30
     ...  Connection State Should Be Good Between VDU And RU   expected=1
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"   run keyword and ignore error   Plugout RU Cable
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"   run keyword and ignore error   sleep   120
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"   run keyword and ignore error   Plugin RU Cable
    run keyword if  "${commission}"=="${True}"
    ...   log to console   Connection State Should Be Good Between RUPROXY And RU(after plugout/plugin RU cable,timeout=600)
    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  600  30
     ...  Connection State Should Be Good Between VDU And RU   expected=1
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Check VDU Critical POD Should Be Good
    ${r}   run keyword and ignore error  Check VDU Critical POD Should Be Good
     ...   console_msg=Restore Environment To Onair:Start to check pod status after deploy vdu(3)
    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    return from keyword if   "${r[0]}"!="PASS"

    # Full Commission SCF On VDU
    ${r}   run keyword if  "${commission}"=="${True}"   run keyword and ignore error   Full Commission SCF On VDU
      ...   scf_file=${scf_file}   build_number=${build_number}
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    #Connection State Should Be Good Between VDU And RU:2
    run keyword if  "${commission}"=="${True}"
    ...   log to console   Connection State Should Be Good Between VDU And RUPROXY(timeout=500)
    ${r}  run keyword if  "${commission}"=="${True}"   run keyword and ignore error   wait until keyword succeeds  200  20
     ...  Connection State Should Be Good Between VDU And RU   expected=2
    run keyword if  "${commission}"=="${True}"    run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"    return from keyword if   "${r[0]}"!="PASS"

    log to console  need_check_on_air:${need_check_on_air}
    #return directly if need not check on-air
    return from keyword if   "${need_check_on_air}"=="${False}"

    #OAM Precondition Cell Should Be Onair
    run keyword if  "${commission}"=="${True}"   log to console  OAM Precondition Cell Should Be Onair(timeout=${check_on_air_timeout})
    ${r}   run keyword if  "${commission}"=="${True}"  run keyword and ignore error
     ...   wait until keyword succeeds   ${check_on_air_timeout}  30   OAM Precondition Cell Should Be Onair For Deploy VDU
    run keyword if  "${commission}"=="${True}"   run keyword if   "${r[0]}"!="PASS"    _Set Result Flag for Restore Environment To Onair   0
    run keyword if  "${commission}"=="${True}"   return from keyword if   "${r[0]}"!="PASS"

    #Should Have Power On All RUs


_Set Result Flag for Restore Environment To Onair
    [Arguments]  ${flag}
    set suite variable  ${RESTORE_ENVIRONMENT_TO_ONAIR_SUCCESS}    ${flag}


_Get Flag for Restore Environment To Onair
    log to console  RESTORE_ENVIRONMENT_TO_ONAIR_SUCCESS:${RESTORE_ENVIRONMENT_TO_ONAIR_SUCCESS}
    [Return]  ${RESTORE_ENVIRONMENT_TO_ONAIR_SUCCESS}


Get Connection State Between VDU and RU
    [Teardown]  run keyword and ignore error  disconnect interactive connection   alias=${alias}
    [Documentation]   Get Connection State Between VDU and RU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    1, or 2
    ...
    ...   Example
    ...   | ${state} | Get Connection State Between VDU and RU |
    ...
    ${alias}   get unique id
    connect to fhgw  alias=${alias}
    ${out}  issh.Execute   command=redis-cli -h redis -n 18 GET mriState   alias=${alias}
    ${out}   strip prompt  ${out}

    ${matches}   get regexp matches  ${out}   "(\\S+)"  1
    ${conn_state}   set variable if  ${matches}   ${matches[0][0]}
    [Return]  ${conn_state}


Connection State Should Be Good Between VDU And RU
    [Arguments]  ${expected}=2
    [Documentation]   Connection State Should Be Good Between VDU And RU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | Expected       | No | Expected, default is 2 |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Connection State Should Be Good Between VDU And RU |
    ...
    ${conn_state}   Get Connection State Between VDU and RU
    should be true  "${conn_state}"=="${expected}"


_Get Modified List Parameter Value
    [Arguments]   ${xml_node}   ${action}   ${dict_keys}  ${dict_para}
    #${dict_keys}  ${dict_para}   _Create Dictionary From List Parameter Precisely   @{para_list}

    ${action}   Set Variable   ${action.lower()}
    ${current_list_content}   Run Keyword If  '${action}'=='add'  _Get Modified List Parameter Value Add   ${xml_node}   ${dict_keys}  ${dict_para}
    ...   ELSE IF  '${action}'=='update'  _Get Modified List Parameter Value Update   ${xml_node}    ${dict_keys}   ${dict_para}
    ...   ELSE IF  '${action}'=='delete'  _Get Modified List Parameter Value Delete   ${xml_node}    ${dict_keys}   ${dict_para}
    ...   ELSE   Fail    action should be add, update or delete!
    [Return]   ${current_list_content}


_Get Modified List Parameter Value Add
    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
    ${res}   XML.Element To String  ${xml_node}

    FOR   ${item}  IN  @{dict_keys}
        ${res}   Replace String Using Regexp   ${res}   <item>    <item><p name="${item}">${dict_para["${item}"]}</p>    count=1
    END

    [Return]  ${res}


_Get Modified List Parameter Value Update
    [Arguments]  ${xml_node}   ${dict_keys}   ${dict_para}
    ${res}   XML.Element To String  ${xml_node}
    ${res}   Prehandle XML Content   ${res}

    ${new_content}   Set Variable  ${EMPTY}
    FOR   ${item}  IN  @{dict_keys}
       ${new_content}    Set Variable   ${new_content}<p name="${item}">${dict_para["${item}"]}</p>
    END

    ${new_content}    Set Variable   <item>${new_content}</item>
    ${res}   Replace_String_With_Regexp   content=${res}
    ...   g1_regexp=\<list\\s+name=\\S+\>
    ...   g2_regexp=.*
    ...   g3_regexp=\</list\>
    ...   g2_new_value=${new_content}

    [Return]  ${res}


_Get Modified List Parameter Value Delete
    [Arguments]  ${xml_node}   ${dict_keys}   #${dict_para}
    ${res}   XML.Element To String  ${xml_node}
    ${res}   Prehandle XML Content  ${res}

    FOR   ${item}  IN  @{dict_keys}
       ${res}  Run Keyword If   "${item}" in """${res}"""   Replace String Using Regexp   ${res}   <p\\s+name="${item}">.*?</p>    ${EMPTY}
       ...    ELSE   set variable   ${res}
    END

    [Return]  ${res}


Prehandle XML Content
    [Arguments]  ${xml_content}
    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | xml_content      | Yes | content with xmlns="raml21.xsd"  |
    ...
    ...    *RETURN VALUE*
    ...    Return content without xmlns="raml21.xsd"
    ...
    ...    Example
    ...    | ${res} | XML.Element To String     | ${xml_handler} |
    ...    | ${res} | Prehandle XML Content | ${res}    |
    ...
    ${xml_content}  Replace String  ${xml_content}  xmlns="raml21.xsd"  ${EMPTY}
    [Return]   ${xml_content}


Recommission vDU with new SCF
    [Arguments]   ${NEW_SCF}
    [Documentation]   It will replace xmlns="raml21.xsd" with ${EMPTY}
    ...    *AUTHOR* lijuan.1.wang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | NEW_SCF         | Yes | New SCF file  |
    ...
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...   | Recommission vDU with new SCF | NEW_SCF=my_NEW_SCF |

    Vdu Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    vDU Send Commission By RestApi    scf_path=${NEW_SCF}    restapi_version=cuoam_19b   vdu_index=0

Get RU ID From vDU SCF
    [Arguments]  ${scf_path}
    [Documentation]   Get RU ID and also EQM/APEQM ID from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path         | Yes | full path and file name  |
    ...   *RETURN VALUE*
    ...    EQM_ID, APEQM_ID, RU_ID
    ...   Example
    ...   | Get RU ID From vDU SCF | ${scf_file_with_fullpath} |

    ${scf_content}   OperatingSystem.Get File      ${scf_path}

    ${result}        Get Regexp Matches            ${scf_content}    /EQM_\\S{3}/APEQM_R-\\d+
    ${EQM_ID}        Remove String Using Regexp    ${result[0]}      /EQM_      /APEQM_R-\\d+

    ${result}        Get Regexp Matches            ${scf_content}    /APEQM_\\S{4}/RMOD_R-\\d+
    ${APEQM_ID}      Remove String Using Regexp    ${result[0]}      /APEQM_      /RMOD_R-\\d+

    ${result}        Get Regexp Matches            ${scf_content}    EQM_R-\\d+/APEQM_R-\\d+/RMOD_\\S{3}
    ${RU_ID}         Remove String Using Regexp    ${result[0]}      EQM_R-\\d+/APEQM_R-\\d+/RMOD_

    [Return]    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}


Get RU runtime HW information from runtime SCF
    [Arguments]
    [Documentation]   Get RU ID and also productName/productCode/serialNumber from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    productName, productCode, serialNumber, RU_ID
    ...   Example
    ...   | Get RU runtime HW information from runtime SCF |  |

    VDU Rest Login

    ${timestamp}    Get Timestamp
    ${scf_path}     Get A Directory    scf_${timestamp}

    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
    ...                                                       filename=scf_${timestamp}.xml
    ...                                                       include_runtime_data=${True}

    scf.Load_Scf    file_path=${scf_file_with_fullpath}

    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}    Get RU ID From vDU SCF    ${scf_file_with_fullpath}

    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_${EQM_ID}/APEQM_${APEQM_ID}/RMOD_${RU_ID}

    ${productName}     scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                          p_name=productName
    Log To Console     ${productName}
    ${productCode}     scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                          p_name=productCode
    Log To Console     ${productCode}
    ${serialNumber}    scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                          p_name=serialNumber
    Log To Console     ${serialNumber}

    vDU Rest Logout

    [Return]    ${productName}    ${productCode}     ${serialNumber}    ${RU_ID}


Get RU runtime Status from runtime SCF
    [Arguments]
    [Documentation]   Get administrativeState/operationalState/proceduralStatus from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    administrativeState, operationalState, proceduralStatus
    ...   Example
    ...   | Get RU runtime Status from runtime SCF |  |

    VDU Rest Login

    ${timestamp}    Get Timestamp
    ${scf_path}     Get A Directory    scf_${timestamp}

    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
    ...                                                       filename=scf_${timestamp}.xml
    ...                                                       include_runtime_data=${True}

    scf.Load_Scf    file_path=${scf_file_with_fullpath}

    ${mrbts_id}    Get BTS ID From vDU SCF    ${scf_file_with_fullpath}
    ${EQM_ID}    ${APEQM_ID}    ${RU_ID}    Get RU ID From vDU SCF    ${scf_file_with_fullpath}

    ${RMOD_DISTNAME}  Set Variable   MRBTS-${mrbts_id[0]}/EQM_${EQM_ID}/APEQM_${APEQM_ID}/RMOD_${RU_ID}

    ${administrativeState}    scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=administrativeState
    Log To Console     ${administrativeState}
    ${operationalState}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=operationalState
    Log To Console     ${operationalState}
    ${proceduralStatus}       scf.Get_Value_From_Scf    dist_name=${RMOD_DISTNAME}
    ...                                                 p_name=proceduralStatus
    Log To Console     ${proceduralStatus}

    vDU Rest Logout

    [Return]    ${administrativeState}    ${operationalState}     ${proceduralStatus}

Get vDU Instance TNL ID
    [Arguments]  ${scf_path}  ${podname}
    [Documentation]   Get vDU Instance TNL ID
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    TNL instance is generated by system, all the TNL runtime info is under TNL instance, for example TNL-1 is for OAMCP TNL template,
    ...    all the configuration is set under TNL-1, the OAMCP TNL instance maybe TNL-4, if we want to check set by system parameters value,
    ...    then we need to check it under TNL-4, so this KW is to get the pod TNL instance id.
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | podname | yes | the full pod name of OAMCP or UP pod |
    ...
    ...    *RETURN VALUE*
    ...    Instance TNL id of given podname.
    ...
    ...    Example
    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=po-cran1-oamcp-0 |
    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=po-cran1-up-0 |
    ...    |  ${tnl_id}  | Get vDU Instance TNL ID | scf_path=/tmp/a.scf | podname=up |
    ...

    ${distName}   Get MO distName    scf_path=${scf_path}  vmAllocated=${podname}
    ${result}     Get Regexp Matches     ${distName[0]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHLK-\\d+/ETHLK_R-\\d+   1
    ${tnl_id}  Set Variable If  ${result}   ${result[0]}
    should be true  ${tnl_id}>=1
    [Return]  ${tnl_id}

Get vDU IPADDRESS DN
    [Arguments]  ${scfpath}    ${uniqueIpId}    ${tnlid}    ${version}=4
    [Documentation]   Get vDU IPADDRESS DN
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Sometimes we need configure IPADDRESS DN for some application, such as f1c plane, some kind of source ip address DN,
    ...    and the ip address DN should be the DN of TNL template such as TNL-1 for OAMCP, we can get it automatically using
    ...    IPADDRESSV4/V6.uniqueIpAddressIdentifier to filter.
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | uniqueIpId | yes | the uniqueIpAddressIdentifier of the searched IPADDRESS DN |
    ...    | version    | no | the ip version default is 4 |
    ...    | tnlid    | yes | the template type TNL ID of the IP address DN located |
    ...    *RETURN VALUE*
    ...    IP address DN for given unique ip address id under TNL with template true type.
    ...
    ...    Example
    ...    |  ${oam_f1_IPDN}  | Get vDU IPADDRESS DN | scf_path=/tmp/a.scf | uniqueIpId=F1-C Xp | tnlid=1 |
    ...    |  ${up_f1_IPDN}  | Get vDU IPADDRESS DN | scf_path=/tmp/a.scf | uniqueIpId=F1-U |  tnlid=3  |
    ...
    ${distName}   Get MO distName    scf_path=${scfpath}  uniqueIpAddressIdentifier=${uniqueIpId}
    ${distName_length}=   get length   ${distName}
    ${ipaddressdn}=    set variable    ${None}
    ${index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${distName_length}
       ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/IPNO-\\d+/IPIF-\\d+/IPADDRESSV${version}-\\d+   1
       ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
       exit for loop if  '${result[0]}'=='${tnlid}'
    END
    ${ipaddressdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
    [Return]  ${ipaddressdn}

Get vDU ETHLK DN
    [Arguments]  ${scfpath}    ${underLyingIF}    ${tnlid}
    [Documentation]   Get vDU ETHLK DN
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Sometimes we need configure ETHLK DN for some application, such as linkSelectorDN of ETHIF, for configuration we need ETHLK
    ...    DN of TNL template such as TNL-1 for OAMCP, when we get TNL counter in TA scripts, we need the DN of TNL instance,
    ...    We can get it automatically using underLyingInterface to filter
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | underLyingIF | yes | the underLyingInterface of the searched ETHLK DN |
    ...    | tnlid    | yes | the template or instance type TNL ID of the ETHLK DN located |
    ...    *RETURN VALUE*
    ...    ETHLK DN for given underLyingInterface.
    ...
    ...    Example
    ...    |  ${oam_f1_ETHLKDN}  | Get vDU ETHLK DN | scf_path=/tmp/a.scf | underLyingIF=f1 | tnlid=1 |
    ...    |  ${up_f1_ETHLKDN}  | Get vDU ETHLK DN | scf_path=/tmp/a.scf | underLyingIF=f1 |  tnlid=3  |
    ...
    ${distName}   Get MO distName    scf_path=${scfpath}  underLyingInterface=${underLyingIF}
    ${distName_length}=   get length   ${distName}
    ${ethlkdn}=    set variable    ${None}
    ${index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${distName_length}
       ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHLK-\\d+   1
       ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
       exit for loop if  '${result[0]}'=='${tnlid}'
    END
    ${ethlkdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
    [Return]  ${ethlkdn}

Get vDU VLANIF DN
    [Arguments]  ${scfpath}    ${vlanIf}    ${tnlid}
    [Documentation]   Get vDU VLANIF DN
    ...    *AUTHOR* zhaori.deng@nokia-sbell.com
    ...    Sometimes we need configure ETHIF DN for some application, such as interfaceDN of IPIF, for configuration we need VLANIF
    ...    DN of TNL template such as TNL-1 for OAMCP, when we get TNL counter in TA scripts, we need the DN of TNL instance,
    ...    We can get it automatically using vlanIfName to filter
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file with runtime info. |
    ...    | vlanIf | yes | the vlanIfName of the searched VLANIF DN |
    ...    | tnlid    | yes | the template or instance type TNL ID of the VLANIF DN located |
    ...    *RETURN VALUE*
    ...    VLANIF DN for given underLyingInterface.
    ...
    ...    Example
    ...    |  ${oam_f1_VLANIFDN}  | Get vDU VLANIF DN | scf_path=/tmp/a.scf | vlanIf=f1cplane | tnlid=1 |
    ...    |  ${up_f1_VLANIFDN}  | Get vDU VLANIF DN | scf_path=/tmp/a.scf | vlanIf=f1uplane |  tnlid=3  |
    ...
    ${distName}   Get MO distName    scf_path=${scfpath}  vlanIfName=${vlanIf}
    ${distName_length}=   get length   ${distName}
    ${vlanifdn}=    set variable    ${None}
    ${index}=    set variable    ${None}
    FOR    ${i}    IN RANGE    0    ${distName_length}
       ${result}   Get Regexp Matches   ${distName[${i}]}   MRBTS-\\d+/TNLSVC-\\d+/TNL-(\\d+)/ETHSVC-\\d+/ETHIF-\\d+/VLANIF-\\d+   1
       ${index}=   Set Variable If   '${result[0]}'=='${tnlid}'   ${i}
       exit for loop if  '${result[0]}'=='${tnlid}'
    END
    ${vlanifdn}=  run keyword if  '${index}'!='None'  set variable  ${distName[${index}]}
    [Return]  ${vlanifdn}

Add Delta Plan MO
    [Arguments]  ${plan_id}   ${parent_mo_dn}   ${mo_name}    ${timeout}=60
    [Documentation]   Add Delta Plan MO
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   It can be used together with 'Update Delta Plan Parameter' to add new MO on delta plan, under this conditio,
    ...   'Update Delta Plan Parameter' operation should be set to 'add'.
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | parent_mo_dn | yes | parent_mo_dn   |
    ...   | mo_name | yes | mo_name   |
    ...   | timeout    | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Add Delta Plan MO | plan_id=<my_plan_id> | parent_mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1 | mo_name=PINGREQ-1
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.create_vdu_object_of_delta_plan   delta_plan_id=${plan_id}  parent_mo_dn=${parent_mo_dn}   mo_name=${mo_name}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Add Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

Add Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Add Delta Plan MO Should Be Successful
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Add Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Add Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Add Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Add Delta Plan MO Should Be Expected
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...
    ${out}   vdu.get_create_vdu_object_action_status_of_delta_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Delete Delta Plan MO
    [Arguments]  ${plan_id}   ${mo_dn}    ${timeout}=60
    [Documentation]   Delete Delta Plan MO
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | timeout    | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Delete Delta Plan MO | plan_id=<my_plan_id> | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1 |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.delete_mo_of_delta_plan   delta_plan_id=${plan_id}  mo_dn=${mo_dn}   timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${out}     Delete Delta Plan MO Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

Delete Delta Plan MO Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Delete Delta Plan MO Should Be Successful
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Delete Delta Plan MO Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ...
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Delete Delta Plan MO Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


_Delete Delta Plan MO Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Delete Delta Plan MO Should Be Expected
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | _Delete Delta Plan MO Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...
    ${out}   vdu.get_deleting_mo_action_state_of_delta_plan      delta_plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Get VDU Parameter Value Online
    [Arguments]  ${mo_dn}   ${para_name}    ${timeout}=60
    [Documentation]   Get VDU Parameter Value Online
    ...   *AUTHOR* zhaori.deng@nokia-sbell.com
    ...   If the searched parameter is under list/item, please set the para_name with something like 'list_name/item_number/parameter_name'
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn     | yes | the distname of given parameter |
    ...   | para_name | yes | parameter name   |
    ...   | timeout   | no | timeout, default is 60, unit is second   |
    ...
    ...   *RETURN VALUE*
    ...    the parameter value getting from current plan
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/PINGREQ-1/PINGRES-1 | para_name=packetsLost |
    ...  | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-5233/TNLSVC-1/TNL-1/IPNO-1/IPRT-1 | para_name=staticRoutes/0/gateway |
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}



Reset VDU By REST
    [Arguments]  ${need_check_on_air}=${False}
    [Documentation]   Reset VDU By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Reset VDU By REST |
    ...
    log to console  Reset VDU By REST...
    ${out}   vdu.reset_vdu
    ${error_msg}   set variable  ${out["error_message"]}
    should contain  ${error_msg}   No error

    ${out}   Reset VDU Status Should Be Successful   operation_id=${out["id"]}
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  600s   30s   OAM Precondition Cell Should Be Onair

Reset VDU Status Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Reset VDU Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...
    ...   *RETURN VALUE*
    ...    None
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | Reset VDU Status Should Be Successful | operation_id=<my_operation_id> |
    ...
    ${out}   Wait Until Keyword Succeeds  60   3   _Reset VDU Status Should Be Expected   operation_id=${operation_id}    expected_status=ongoing
    [Return]  ${out}


_Reset VDU Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    ${out}   vdu.get_reset_vdu_operation_status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Reset VDU By REST If Not On-air
    [Documentation]   Reset VDU By REST If Not On-air
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   *RETURN VALUE*
    ...
    ...
    ...   Example
    ...  | Reset VDU By REST If Not On-air |
    ...
    Disable RECOVER
    return from keyword if  ${RECOVER}==0

    log to console  Reset VDU By REST If Not On-air...

    ${redeploy_flag}    Need Redeploy VDU
    log to console  Need Reset VDU:${redeploy_flag}
    return from keyword if  "${redeploy_flag}"=="${False}"

    ${r}  ${out}   run keyword and ignore error   vdu rest login
    return from keyword if  "${r}"!="PASS"
    Reset VDU By REST
    sleep  2m
    wait until keyword succeeds   600    20   OAM Precondition Cell Should Be Onair


vDU Modify Parameters Online After Checking
    [Arguments]    ${para_list}   ${value_list}   ${mo}    ${vdu_index}=0
    [Documentation]   vDU Modify Parameters Online After Checking
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...   | status    | yes | if it is the same between the expect value  and the value in testlilne |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}    ${status}=    vDU Modify Parameters Online After Checking |
    ...   para_list=${para_list}    value_list=${value_list}    mo=${mo} |

    log to console    DU modify parameters online
    ${origin_para_value_dict}=    Get Current Parameters Dict    ${para_list}    ${mo}    ${vdu_index}
    ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict   ${para_list}  ${value_list}
    ${status}  run keyword and return status   dictionaries should be equal    ${origin_para_value_dict}  ${Updated_Paras_Dict}
    vDU Rest Login    vdu_index=${vdu_index}
    run keyword if     "${status}"== "${False}"    VDU Online Change Parameters By Delta Plan REST
    ...    mo_dn=${mo}    updated_paras_list=${Updated_Paras_Dict}
    [Return]    ${origin_para_value_dict}    ${status}
    [Teardown]  VDU Rest Logout    ${vdu_index}


Get Current Parameters Dict
    [Arguments]   ${para_list}    ${mo}    ${vdu_index}=0
    [Documentation]   Get Current Parameters Dict
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...  Change History
    ...  2021.07.11   Ren Shubin   If para is no exist in MO, will set as NULL.
    ...
    ...   | Input Parameters    | Man. | Description |
    ...   | para_list    | yes | the names of parameters list |
    ...   | mo    | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...
    ...   *RETURN VALUE*
    ...   | origin_para_value_dict    | yes | the parameters and value in testline |
    ...
    ...   Example
    ...  | ${origin_para_value_dict}=    Get Current Parameters Dict |
    ...   para_list=${para_list}    mo=${mo} |
    ...
    ${origin_para_value_dict}   create dictionary
    vDU Rest Login    vdu_index=${vdu_index}
    ${length}=    get length    ${para_list}
    FOR    ${i}    IN RANGE    0     ${length}
        ${status}  ${value}   Run Keyword And Ignore Error   Get VDU Parameter Value Online   ${mo}  ${para_list[${i}]}
        ${value_current}  Set Variable If  '${status}'=='PASS'   ${value}  ${null}
        Set to Dictionary  ${origin_para_value_dict}  ${para_list[${i}]}   ${value_current}
    END
    [Return]  &{origin_para_value_dict}
    [Teardown]    VDU REST LOGOUT    ${vdu_index}


Convert Updating Parameters From List To Dict
    [Arguments]   ${para_name_list}   ${values_list}
    [Documentation]   Convert Updating Parameters From List To Dict
    ...   *AUTHOR* tingting.xiao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_name_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...
    ...   *RETURN VALUE*
    ...   | Updated_Paras_Dict    | yes | the parameters and the expect value |
    ...
    ...   Example
    ...  | ${Updated_Paras_Dict}=    Convert Updating Parameters From List To Dict| para_list=${para_list}    value_list=${value_list}|

    ${Updated_Paras_Dict}   create dictionary
    ${length}=    get length    ${para_name_list}
    For  ${i}  IN RANGE    0     ${length}
      Set To Dictionary   ${Updated_Paras_Dict}   ${para_name_list[${i}]}  ${values_list[${i}]}
    END
    [Return]  ${Updated_Paras_Dict}

Get RU Type By SCF
    [Documentation]   Get RU Type By SCF
    ...   *AUTHOR* zhong.1.chen@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | para_name_list    | yes | the names of parameters list |
    ...   | value_list    | yes | the values of parameters list, must be one-to-one match between the parameter value
    ...   and the parameter name|
    ...
    ...   *RETURN VALUE*
    ...   | ${prodCodePlanned}  |  ${productName}  |
    ...
    ...   Example
    ...  | ${prodCodePlanned}  |  ${productName}  |  Get RU Type By SCF |

    VDU Rest Login
    ${scf_path}  Get A Directory  scf
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=${scf_path}  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${RMOD_DISTNAME}  Set Variable   MRBTS-${VDU_CONF["mrbts_id"]}/EQM-1/APEQM-1/RMOD-1
    ${prodCodePlanned}     scf.Get_Value_From_Scf
        ...      dist_name=${RMOD_DISTNAME}   p_name=prodCodePlanned

    ${productName}   Set Variable If
     ...   "${prodCodePlanned}"=="473966A.101"   AHCA
     ...   "${prodCodePlanned}"=="473966A"       AHCA
     ...   "${prodCodePlanned}"=="474341A"       AHBCC
     ...   "${prodCodePlanned}"=="474341A.101"   AHBCC

     [Return]     ${prodCodePlanned}   ${productName}


Online Enable actCli For CU
    [Documentation]   Enable actCli when it is false
    ...    *AUTHOR* lingting.sun@nokia-sbell.com
    ...    modified by:        <08-07-2020>, <lingtsun>, <Initial creation>
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | Online Enable actCli For CU |
    ...
    ${gnb_id}    set variable    ${tl.gnbs[0].instance_id}
    ${MO}    set variable     MRBTS-${gnb_id}/MNL-1/MNLENT-1/FEATCADM-1
    &{para_actCli}    Create Dictionary    operation_type=replace   parameter_path=/actCli  value=true
    @{para_list}     Create List    ${para_actCli}
    ${actCli}=    CU Get Online Parameter Value     ${MO}    actCli
    CU Login
    run keyword if  """${actCli}"""=="""false"""
    ...    CU Online Change Single Mo Parameters via rest    para_list=${Para_list}  mo_dn=${MO}
    [teardown]    CU Logout


############################## vDU CM end ##############################
====== vDU CM end ======
     log to console  \n*** only used for readable **
Get vDU Num
    [Documentation]      Get vDU Num
    ...  author:             chunding.d.zhu0@nokia-sbell.com
    ...  modified by:        <11-Feb-2020>, <chuzhuo>, <initial created>
    ...    | Input Parameters | Man. | Description |
    ...	   |   |
    ...    *RETURN VALUE*
    ...    vdu num
    ...    Example
    ...    |  Get vDU Num  |   |
    ${dus}    tl_info.get_du_list    ${tl}
    ${dus_num}    Get Length    ${dus}
    [Return]   ${dus_num}

############################## FHGW CM Start ##############################
====== FHGW CM Start ======
     log to console  \n*** only used for readable ***


############################## FHGW CM end ##############################
====== FHGW CM End ======
     log to console  \n*** only used for readable **
