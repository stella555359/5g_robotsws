*** Settings ***
Documentation
...   Migrate from AIC
...   author:yixiang.x.wang@nokia-sbell.com

Library           Collections
Library           DateTime
Library           OperatingSystem
Library           Process
Library           Screenshot
Library           String
Library           XML
Library           Telnet
Library           taf.transport.ssh                     WITH NAME    csn
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.analyzer.pcap                    WITH NAME    cap
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library           testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.cu_commission.cm    WITH NAME    cu_commi


*** Variables ***


*** Keyword ***
CU Login
    [Arguments]     ${gnb_index}=0   ${solution}=rest    ${cu_version}=cuoam_19b
    [Documentation]  Login to CU via rest or webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    |  solution | No |  rest or webui, rest in default |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Login  |     |
    run keyword if  "${solution}"=="rest"    CU Rest Login   ${gnb_index}    ${cu_version}
    ...   ELSE    CU Webui Login    ${gnb_index}

CU Rest Login
   [Arguments]   ${gnb_index}    ${cu_version}=cuoam_19b
   [Documentation]  Create rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Login   |    0   |
    cu.connect to    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${cu_version}
    ...    secure=${True}

CU Webui Login
    [Arguments]    ${gnb_index}
    [Documentation]  Login to CU via WebUI.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used  |
    log   Login to CU webui function is not ready!     level=ERROR

CU Logout
    [Arguments]   ${solution}=rest
    [Documentation]  Teardown login session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <22-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Logout |   |
    run keyword if  "${solution}"=="rest"    CU Rest Logout
    ...   ELSE    CU Webui Logout

CU Rest Logout
    [Documentation]  Teardown rest session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Rest Logout |   |
    cu.disconnect

CU Webui Logout
      [Documentation]  Logout CU webui.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  CU Webui Logout   |     |
    log   Logout CU WebUI function is not ready!   level=ERROR

CU Full Commission
    [Arguments]    ${path_of_commission_file}   ${plan_name}=default_plan_name   ${solution}=rest   ${gnb_index}=0    ${wait_active}=${True}
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
    run keyword if  "${solution}"=="rest"    CU Full Commsion By Rest
    ...   path_of_commission_file=${path_of_commission_file}   plan_name=${plan_name}  gnb_index=${gnb_index}   wait_active=${wait_active}
    ...   ELSE    CU Full Commission By Webui    path_of_commission_file=${path_of_commission_file}   plan_name=${plan_name}   gnb_index=${gnb_index}

CU Full Commsion By Rest
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0   ${wait_time}=300s    ${wait_active}=${True}
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
        ...    |  CU Full Commsion By Rest  |   /tmp/commission.xml  |    3219_plan_file   |
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
     run keyword if    ${wait_active}==${True}    log to console   \n*** Wait plan activate operation success in 5 mins ***
     run keyword if    ${wait_active}==${True}
     ...    wait until keyword succeeds    ${wait_time}   30s  CU Check Plan Activate Status Should Be As Expected
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
    [Arguments]    ${path_of_commission_file}   ${plan_name}  ${gnb_index}=0
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
    ${oam_conn}=    CU SSH To OAM
    ${time_stamp}=  Get Time   exclude_millis=yes
    ${time_stamp}=  replace string  ${time_stamp}  ${SPACE}  \
    ${time_stamp}=  replace string  ${time_stamp}  -   \
    ${time_stamp}=  replace string  ${time_stamp}  :   \
    ${plan_file_path}=    Get A File    SCF    scf_${time_stamp}.xml
    CU Login  ${gnb_index}
    ${where_to_store_plan_file}=    run keyword if   "${stored_path}"=="${EMPTY}"   set variable    ${plan_file_path}
    ...  ELSE    set variable    ${stored_path}
    cu.get_current_plan_file    ${where_to_store_plan_file}   60
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
    ...  ELSE  run keywords   BuiltIn.log  Plan id ${plan_id} is not exist before deletion!  WARN   AND  return from keyword
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
    [Arguments]   ${modify_list}   ${gnb_index}=0
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

CU Online Parameter Change by rest
    [Arguments]     ${para_list}    ${mo_dn}     ${delta_plan_name}=delta_plan
    [Documentation]   CU Online Parameter Change by rest.
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
    ...    | CU Online Parameter Change by rest | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |

    ${delta_plan_list}     cu.get_delta_plan_list
    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
	run keyword and continue on failure   Wait until keyword succeeds  3x  2s
	...  _CU Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
    ${uuid}   _CU Get Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
	...  _CU Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}  action_id=${update_res['action_id']}
	${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _CU Validating Delta Plan Operation Should Be Successful	 plan_id=${delta_plan_id}  action_id=${validate_res['action_id']}
    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
	run keyword and continue on failure   Wait until keyword succeeds  3x  30s
	...  _CU Activating Delta Plan Operation Should Be Successful   plan_id=${delta_plan_id}   operation_id=${active_res['operation_id']}

_CU Get Specifical MO UUID
    [Arguments]   ${plan_id}  ${mo_dn}
    [Documentation]   _CU Get Specifical MO UUID
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    *RETURN VALUE*  ${mouuid}
    ...    Example
    ...    |  ${mouuid} | _CU Get Specifical MO UUID | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|

    @{name_list}=   split_string    ${mo_dn}   /
    set suite variable  ${parent_mouuid}    ${EMPTY}
    FOR  ${name}  IN  @{name_list}
        ${mouuid}  _CU Get Specifical MO UUID via DN Name   ${plan_id}  ${name}
    END
    [Return]   ${mouuid}

_CU Get Specifical MO UUID via DN Name
    [Arguments]   ${plan_id}  ${name}
    [Documentation]  _Get CU Specifical MO UUID via DN Name
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...    *RETURN VALUE*   ${parent_mouuid}
    ...    Example
    ...    |  ${parent_mouuid} | _CU Get Specifical MO UUID via DN Name | plan_id=${delta_plan_id} | name=${name}|

    &{delta_plan_tree}   cu.get_delta_plan_tree_diff   plan_id=${plan_id}
    @{plan_tree}=  set variable  ${delta_plan_tree["created"]}
    FOR  ${mo_info}  IN  @{plan_tree}
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
    ...  run keywords  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
      run keyword if  '${mo_info["parent_mo_uuid"]}'=='None' and '${mo_info["name"]}'=='${name}'  run keywords
    ...  set suite variable  ${parent_mouuid}  ${mo_info["mo_uuid"]}  AND  exit for loop
    END
    [Return]   ${parent_mouuid}

_CU Generating Delta Plan Operation Should Be Successful
    [Arguments]   ${action_id}
    [Documentation]  _CU Generating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Generating Delta Plan Operation Should Be Successful | action_id=xxx |
	${res}   cu.get_action_state_of_generating_delta_plan   ${action_id}
	should be equal as strings  ${res['status']}  success

_CU Update Parameters Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]  _CU Update Parameters Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
	${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
	should be equal as strings  ${res['status']}  success

_CU Validating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   _CU Validating Delta Plan Operation Should Be Successful
    ...  author: luofei.tug@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...    *RETURN VALUE*  None
    ...    Example
    ...    | _CU Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
	should be equal as strings  ${res['status']}  success


_CU Activating Delta Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${operation_id}
    [Documentation]   _CU Activating Delta Plan Operation Should Be Successful
    ...   *Author*: luofei.tug@nokia-sbell.com
    ...   *Change History*
    ...    | Who | date | what or how |
    ...    | r3li | 2022-12-30 | Check successful status with delta plan missed |
    ...    *Parameter Description*
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...    *RETURN VALUE*  None
    ...    *Example*
    ...    | _CU Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
#    CU Rest Login    gnb_index=${gnb_index}
    ${res}=   cu.get_delta_plan_list
    FOR   ${r}   IN   @{res}
        ${r_plan_id}   Set Variable   ${r}[plan_id]
        Should Not Be Equal As Strings   ${r_plan_id}   ${plan_id}
    END

CU Delta Commission update
    [Arguments]   ${parameters}    ${gnb_index}=${0}
    ...    ${cu_ip}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    ${cu_username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${cu_password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${log_dir}=${TS_CASE_LOG_PATH}
    [Documentation]   cu delta parameter update
        ...    author: yixiang.x.wang@nokia-sbell.com
        ...    parameters = {'MRBTS-400/NRBTS-400/NRDRB_PDCP-1': {'tReorderingUl': 'ms100'}}

        ...    parameters = {'MRBTS-400/NRBTS-400/NRDRB_PDCP-1': {'tReorderingUl': 'ms80'},
        ...                 'MRBTS-400/MNL-1/MNLENT-1/PMCADM-1' : {'reportingIntervalPm': '15min'}
        ...                 }

        ...    parameters = {'MRBTS-417/NRBTS-1':{'cipherPrefL': [{'nea0': '0',
        ...                  'nea1_128': '3',
        ...                  'nea2_128': '4',
        ...                  'nea3_128': '2'}]}}
    cu_commi.delta_commission_online_update    parameters=${parameters}    cu_ip=${cu_ip}
    ...    cu_username=${cu_username}    cu_password=${cu_password}    log_dir=${log_dir}

CU Delta Commission Add MO
    [Arguments]   ${parameters}    ${gnb_index}=${0}
    ...    ${cu_ip}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    ${cu_username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${cu_password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${log_dir}=${TS_CASE_LOG_PATH}
    [Documentation]   cu delta add managed object, before add MO, please ensure the MO not exist in current plan.
    ...    author: yixiang.x.wang@nokia-sbell.com
    ...   parameters0 = {
    ...       'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-2': {'tacOverbookingLimit': '20'},
    ...       'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-3': {'tacOverbookingLimit': '30'}
    ...                  }
    ...   parameters1 = {
    ...       'MRBTS-400/MNL-1/TCEADM-1': {},
    ...       'MRBTS-400/MNL-1/TCEADM-1/TCE-1':{'tceIdentifier':'0', 'tceIpAddress':'10.57.167.186', 'tcePortNumber':'49151'}
    ...   }
    ...   parameters2 = {'MRBTS-400/NRBTS-400/NRDRB_QCI-9':
    ...                  {'nrDrbDN': 'MRBTS-1/NRBTS-1/NRDRB-9', 'qciValueList': ['79']}
    ...   }
    ...    parameters3 = {
    ...        'MRBTS-400/MNL-1/TCEADM-1': {},
    ...        'MRBTS-400/MNL-1/TCEADM-1/TCE-1': {'tceIdentifier': '1', 'tceIpAddress':
    ...                     '10.57.167.186', 'tcePortNumber': '49151'},
    ...        'MRBTS-400/NRBTS-400/NRCTRLTS-1': {},
    ...        'MRBTS-400/NRBTS-400/NRCTRLTS-1/NRMTRACECU-1': {'actCellTraceReportingCU': 'true', 'actPCMDReporting': 'true',
    ...                     'cellMaxActiveUEsTraced': '100', 'jobType': 'TraceOnly', 'nrMtraceCuId': '1',
    ...                     'nrRanTraceReference':[{'mcc':'262', 'mnc': '3', 'mncLength': '2', 'traceId': '1'}],
    ...                     'nrTceIdentifier': '1', 'scope': 'specificResources',
    ...                     'traceNGAPSetting': 'all', 'traceNRRRCSetting': 'all', 'traceX2Setting': 'all',
    ...                     'traceXNSetting': 'all'},
    ...        'MRBTS-400/NRBTS-400/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1': {'resourceDN': 'MRBTS-400/NRBTS-400/NRCELL-1',
    ...                                                                       'typeNrCu': 'cell', 'nrResourceCuId': '1'}
    ...    }
    cu_commi.delta_commission_online_add_mo    parameters=${parameters}    cu_ip=${cu_ip}
    ...    cu_username=${cu_username}    cu_password=${cu_password}    log_dir=${log_dir}

CU Delta Commission Delete MO
    [Arguments]   ${parameters}    ${gnb_index}=${0}
    ...    ${cu_ip}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    ${cu_username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${cu_password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${log_dir}=${TS_CASE_LOG_PATH}
    [Documentation]   cu delta delete managed object
        ...    author: yixiang.x.wang@nokia-sbell.com
        ...    parameters = {'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-2': {'tacOverbookingLimit': '10'}}
    cu_commi.delta_commission_online_delete_mo    parameters=${parameters}    cu_ip=${cu_ip}
    ...    cu_username=${cu_username}    cu_password=${cu_password}    log_dir=${log_dir}

CU Get Single Parameter Value
    [Arguments]   ${distname}    ${parameter}    ${gnb_index}=${0}
    ...    ${cu_ip}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    ${cu_username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${cu_password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    ${log_dir}=${TS_CASE_LOG_PATH}
    [Documentation]   get CU SCF parameter value online
        ...    author: yixiang.x.wang@nokia-sbell.com
        ...    CU Get Single Parameter Value    distname=MRBTS-400/NRBTS-400/NRPMRNL-1    parameter=miNrCaCu    cu_ip=10.57.177.6
    ${value}   cu_commi.get_cu_single_parameter_value    distname=${distname}   parameter=${parameter}    cu_ip=${cu_ip}
    ...    cu_username=${cu_username}    cu_password=${cu_password}    log_dir=${log_dir}
    [Return]    ${value}

CU Collect Snapshot
    [Documentation]    Gets local snapshot and saves it under given file path.
    ...    author: yixiang.x.wang@nokia-sbell.com
    [Arguments]     ${gnb_index}=0    ${log_path}=${TS_CASE_LOG_PATH}
    Log To Console   \n*** Start to save snapshot ***
    CU Login  ${gnb_index}
    cu.Get_Local_Snapshot  ${log_path}
    ${file_list}=   List_Directory   ${log_path}
    ${file_num}=   Get Length   ${file_list}
    Should Be True    ${file_num}>0   No snapshot files found in local after saving snapshot operation!
    [Return]  ${log_path}${/}${file_list[0]}
    [Teardown]  Run Keyword And Ignore Error   CU Logout

gett variable for para
    [Documentation]  Author: Wenwen Jiang
    ...              Description: create list for CU parameter need modify
    [Arguments]    ${paraname9}    ${value9}
    &{dict1}    Create Dictionary    operation_type=replace    parameter_path=${paraname9}    value=${value9}
    @{list2}    Create List    ${dict1}
    set suite variable    @{list2}

Get initial values for case
    [Documentation]  Author: Wenwen Jiang
    ...              Description: get target para uuid and initial value
    [Arguments]    ${para}
    CU Rest Login    gnb_index=0
    &{paralist2}    cu.search_parameters_of_current_plan    parameter_name=${para}
    ${para_2}    set variable    ${paralist2}[items]
    ${list_para2}    Evaluate    dict(${para_2}[0])
    ${uuid}    set variable    ${list_para2}[mo_uuid]
    ${para_3}    set variable    ${list_para2}[parameter]
    ${para_4}    set variable    ${para_3}[simple_parameter]
    ${ori_valueori}    set variable    ${para_4}[value]
    set suite variable    ${ori_valueori}
    @{list}    Create List    ${uuid}    ${ori_valueori}
    [teardown]    CU Rest Logout
    [return]    @{list}

Modify teardown
    [Documentation]  Author: Wenwen Jiang
    ...              Description: delete deltaplan if CU is not restart
    ${dunum}    Get DU State
    set suite variable    ${duactno}    ${dunum}
    ${deltaplanlist}    cu.get_delta_plan_list
    #set suite variable    ${deltaplanlist}
    sleep    2s
    Run Keyword And Ignore Error    cu.delete_delta_plan    plan_id=${plan_id}
    sleep    5s
    CU Rest Logout

verify modified value
    [Documentation]  Author: Wenwen Jiang
    ...    param: para2, target parameter name
    ...    param: value11, the target value
    [Arguments]    ${para2}    ${value11}
    Wait Until Keyword Succeeds    5min    15s    get value after modification     para23=${para2}
    ${finalvalue}    set variable    ${valueafter}[1]
    ${valuefinal}    convert to string    ${finalvalue}
    should be equal    ${valuefinal}    ${value11}

get value after modification
    [Arguments]    ${para23}
    @{valueafer}    Get initial values for case    para=${para23}
    set suite variable    @{valueafter}    @{valueafer}

Get restore list
    [Arguments]    ${paraname111}
    gett variable for para    paraname9=${paraname111}    value9=${value_ori11}

Begin restore
    [Documentation]  Author: Wenwen Jiang
    ...    param: parares, target parameter name
    [Arguments]    ${parares}
    ${ovalue77}    Get initial values for case    para=${parares}
    set suite variable    ${uuid}    ${ovalue77}[0]
    wait until CU configurable
    Modify parameters progress    planname=${planname1}     parao=${parares}
    sleep    5s
    verify modified value    para2=${parares}    value11=${value_ori11}        ######

Restore progress for CU deltaplan
    [Documentation]  Author: Wenwen Jiang
    ...              Description: restore one parameter value for CU
    ...    param: paraname14, target parameter name with '/' in first
    ...    param: paraname16, target parameter name
    [Arguments]    ${paraname14}    ${paraname16}
    Get restore list    paraname111=${paraname14}
    Run keyword if     ${duactno}==${0}    sleep    3min
    Run Keyword And Ignore Error    cu.delete_delta_plan    plan_id=${plan_id}
    Begin restore    parares=${paraname16}

main steps pri
    [Documentation]  Author: Wenwen Jiang
    ...              Description: convert para's value format
    [Arguments]    ${paraname11}    ${value11}    ${para2}
    ${value113}    convert to string    ${value11}
     set suite variable    ${value113}
    gett variable for para    paraname9=${paraname11}    value9=${value113}
    ${orivalue15}    Get initial values for case    para=${para2}
    set suite variable    ${orivalue15}
    set suite variable    ${uuid}    ${orivalue15}[0]
    set suite variable    ${value_ori17}    ${orivalue15}[1]
    set suite variable    ${value_ori18}    ${${value_ori17}}
    ${value_ori11}    convert to string    ${value_ori18}
    set suite variable    ${value_ori11}

Case main steps for CU deltaplan
    [Documentation]  Author: Wenwen Jiang
    ...              Description: modify one parameter value for CU
    ...    param: parameter11, parameter name with '/' in first
    ...    param: value11, target value
    ...    para2: para2, parameter name
    [Arguments]    ${paraname11}    ${value11}    ${para2}
    main steps pri    paraname11=${paraname11}    value11=${value11}    para2=${para2}
    Modify parameters progress    planname=${planname1}    parao=${para2}
    sleep    5s
    verify modified value    para2=${para2}    value11=${value113}

wait until CU configurable
    [Documentation]  Author: Wenwen Jiang
    CU Rest Login    gnb_index=0
    Wait Until Keyword Succeeds    5min    10s    Get CU Operation State
    [teardown]    CU Rest Logout

create deltaplan begin
    [Documentation]  Author: Wenwen Jiang
    [Arguments]    ${planname}
    &{planinfo}    cu.generate_delta_plan    plan_name=${planname}
    set suite variable    ${plan_id}    ${planinfo}[plan_id]
    set suite variable    ${createid}    ${planinfo}[action_id]

get deltaplan create status
    [Documentation]  Author: Wenwen Jiang
    &{deltastus21}    cu.get_action_state_of_generating_delta_plan    action_id=${createid}
    set suite variable    ${deltastus22}    ${deltastus21}[status]

deltaplan create succeed
    [Documentation]  Author: Wenwen Jiang
    get deltaplan create status
    Run keyword if    '${deltastus22}'=='failure'    create deltaplan begin    planname=${planname1}    ELSE
    ...    should be equal    ${deltastus22}    success

complete create deltaplan
    [Documentation]  Author: Wenwen Jiang
    Run keyword if    '${deltastus22}'=='ongoing'    Wait Until Keyword Succeeds    5min    5s    deltaplan create succeed
    Run keyword if    '${deltastus22}'=='failure'    create deltaplan begin    planname=${planname1}

create delta plan progress
    [Documentation]  Author: Wenwen Jiang
    create deltaplan begin    planname=${planname1}
    get deltaplan create status
    complete create deltaplan

update para begin
    [Documentation]  Author: Wenwen Jiang
    [Arguments]    ${uuidneed}    ${list222}
    sleep    2s
    &{plan2}    cu.update_parameters_of_delta_plan    plan_id=${plan_id}    mo_uuid=${uuidneed}    parameter_change_list=${list222}
    set suite variable    ${uppara22}    ${plan2}[action_id]

get updatepara status
    [Documentation]  Author: Wenwen Jiang
    sleep    2s
    &{plan7}    cu.get_action_state_of_updating_parameters_of_delta_plan    plan_id=${plan_id}    action_id=${uppara22}
    set suite variable    ${updatestau}    ${plan7}[status]

deltaplan update succeed
    [Documentation]  Author: Wenwen Jiang
    sleep    2s
    get updatepara status
    Run keyword if    '${updatestau}'=='failure'    update para begin    uuidneed=${uuid}    list222=${list2}    ELSE
    ...    should be equal    ${updatestau}    success

complete update deltaplan
    [Documentation]  Author: Wenwen Jiang
    Run keyword if    '${updatestau}'=='ongoing'    Wait Until Keyword Succeeds    3min    5s    deltaplan update succeed
    Run keyword if    '${updatestau}'=='failure'    update para begin    uuidneed=${uuid}    list222=${list2}

update para progress
    [Documentation]  Author: Wenwen Jiang
    [Arguments]     ${list21}
    update para begin    uuidneed=${uuid}    list222=${list21}
    get updatepara status
    complete update deltaplan

deltaplan validation begin
    [Documentation]  Author: Wenwen Jiang
    sleep    3s
    &{plan3}    cu.validate_delta_plan    plan_id=${plan_id}
    set suite variable    ${validateid}    ${plan3}[action_id]

get validation status
    [Documentation]  Author: Wenwen Jiang
    sleep    2s
    &{operstatus}    cu.get_action_state_of_validating_delta_plan     plan_id=${plan_id}    action_id=${validateid}
    set suite variable    ${validstau}    ${operstatus}[status]

deltaplan validation succeed
    [Documentation]  Author: Wenwen Jiang
    sleep    2s
    get validation status
    Run keyword if    '${validstau}'=='failure'    deltaplan validation begin    ELSE
    ...    should be equal    ${validstau}    success

complete validation
    [Documentation]  Author: Wenwen Jiang
    Run keyword if    '${validstau}'=='ongoing'    Wait Until Keyword Succeeds    3min    5s    deltaplan validation succeed
    Run keyword if    '${validstau}'=='failure'    deltaplan validation begin

validation progress
    [Documentation]  Author: Wenwen Jiang
    deltaplan validation begin
    get validation status
    complete validation

active deltaplan begin
    [Documentation]  Author: Wenwen Jiang
    sleep    5s
    &{plan4}    cu.activate_delta_plan    plan_id=${plan_id}
    set suite variable    ${activeid}    ${plan4}[operation_id]

get delataplan active status
    [Documentation]  Author: Wenwen Jiang
    sleep    5s
    &{operstatus}    cu.get_operation_state_of_activating_delta_plan    plan_id=${plan_id}    operation_id=${activeid}
    set suite variable    ${actstus}    ${operstatus}[status]

active deltaplan succeed
    [Documentation]  Author: Wenwen Jiang
    sleep    5s
    get delataplan active status
    Run keyword if    '${actstus}'=='failure'    active deltaplan begin    ELSE
    ...    should be equal    ${actstus}    success

complete deltaplan active
    [Documentation]  Author: Wenwen Jiang
    Run keyword if    '${actstus}'=='ongoing'    Wait Until Keyword Succeeds    8min    10s    active deltaplan succeed
    Run keyword if    '${actstus}'=='failure'    active deltaplan begin

activate progress
    [Documentation]  Author: Wenwen Jiang
    active deltaplan begin
    get delataplan active status
    complete deltaplan active

Modify parameters progress
    [Documentation]  Author: Wenwen Jiang
    ...    param: planname, deltaplan name to create
    ...    param: parao, parameter name
    [Arguments]    ${planname}    ${parao}
    CU Rest Login    gnb_index=0
    create delta plan progress
    update para progress    list21=${list2}
    validation progress
    activate progress
    [teardown]    Modify teardown

Get DU State
    [Documentation]  Author: Wenwen Jiang
    &{dusta1}    cu.get_du_state
    ${dusta2}    set variable    ${dusta1}[f1_link_status]
    ${dusta3}    Evaluate    dict(${dusta2})
    ${dusta4}    set variable    ${dusta3}[available]
    [return]    ${dusta4}

Get CU Operation State
    [Documentation]  Author: Wenwen Jiang
    &{custu1}    cu.get_cu_state
    ${custu2}    set variable    ${custu1}[operational_state]
    should be equal    ${custu2}    enabled
Get CU Namespace From Testline
    [Arguments]  ${gnb_index}=0
    [Documentation]    get cu namespace from testline
    ...    *AUTHOR* calla.wang@nokia-sbell.com
    ...  history change:
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  27.11.2021,chris.l.cao@nokia-sbell.com, add support to VCU NCIR
    ...   *RETURN VALUE*
    ...   namespace for CNF, tenant name for VNF
    ${r}  ${cu_namespace}   Run Keyword And Ignore Error
        ...   set variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    ${cu_namespace}   Run Keyword If  "${r}"=="FAIL"  Set Variable
              ...  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.control_nodes[0].default_ssh_connection_details.username}
       ...   ELSE  Set Variable   ${cu_namespace}
    [Return]   ${cu_namespace}

Connect To CU K8S Master With Admin
    [Arguments]  ${gnb_index}=0
    [Documentation]    connect to CU K8S cluster with admin permission
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: <date>,<who>,<what and how>
    ...    23.6.2020,calla.wang@nokia-sbell.comm, initialized version
    ...    9.7.2021,chris.l.cao@nokia-sbell.com, add support for cbis-admin user
    ...    14.7.2021,chris.l.cao@nokia-sbell.com, enhancement for root user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the connection alias used to execute command later.
    ...
    ...    Example
    ...    |  Connect To CU K8S Master With Admin  |
    ...
    ${host_ip}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ${username}=  Set Variable   ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}=  Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

    #${prompt}  set variable   ]#|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt}  set variable   \\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  Set Variable  ${prompt}|\\[${username}@\\S+\\s\\S+\\]\\$

    ${alias}=  get unique id
    issh.Connect_To
    ...   ip=${host_ip}
    ...   username=${username}
    ...   password=${password}
    ...   prompt=${prompt}
    ...   alias=${alias}
    [Return]  ${alias}

Get Host Name
    [Arguments]  ${alias}=default
    ${out}   issh.Execute   command=hostname   alias=${alias}
    ${lines}  Split To Lines  ${out}
    ${hostname}   Set Variable   ${lines[1].strip()}
    [Return]  ${hostname}

_Set CU Pod And Container Name Prefix
    [Arguments]  ${gnb_index}=0
    [Teardown]  Run Keyword And Ignore Error   Disconnect Interactive Connection   ${alias}
    [Documentation]    set cu pod and container name prefix, like po-cran1- and ctr-cran1-
    ...  *Author* calla.wang@nokia-sbell.com
    ...  *Change History*:
    ...  | Date | Who | What and How
    ...  | 06-23-2021 | calwang | initial created |
    ...  | 14.7.2021 | chris.l.cao@nokia-sbell.com | rename KW to private KW, and let it be called in 'aic common test setup' |
    ...  | 26.7.2021 | chris.l.cao@nokia-sbell.com | support sudo for cbis-admin user |
    ...  | 28.7.2021 | chris.l.cao@nokia-sbell.com | add to check "No resources found" not in ${out} |
    ...  | 20.1.2022 | rui.3.li@nokia-sbell.com | take sudo out, and change check_result to false when execute command |
    ...  *Arguments Description*
    ...  | Input Parameters | Man. | Description |
    ...  | gnb_index | No. | the gnb index, default value is 0. |
    ...  *RETURN VALUE*
    ...  - none, but will set test variable ${G_CU_POD_PREFIX} and ${G_CU_CONTAINER_PREFIX}
    ...
    ${ns}=  Get CU Namespace From Testline  ${gnb_index}
    ${alias}=    Connect To CU K8S Master With Admin    gnb_index=${gnb_index}
    sleep   1
    ${out}  issh.Execute   command=kubectl get pods -n ${ns}  alias=${alias}   check_result=${False}
    ${out}   strip prompt   ${out}
    should be true   "No resources found" not in """${out}"""
    ${out}  issh.Execute   command=kubectl get pods -n ${ns}|grep -E "\\-pm\\-"|awk -F "-pm-" '{print $1}'  alias=${alias}
    ...    check_result=${False}
    ${pod_prefix}  strip prompt  ${out}
    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}
    ${G_CU_POD_PREFIX}   set variable   ${pod_prefix}
    set suite variable   ${G_CU_POD_PREFIX}
    ${out}   issh.Execute
    ...   command=kubectl describe pod ${pod_prefix}pm-0 -n ${ns}|grep pmcore:|head -n 1|awk -F pmcore '{print $1}'
    ...    alias=${alias}    check_result=${False}
    ${out}   strip prompt  ${out}
    ${out}   set variable   ${out.strip()}
    ${container_prefix}   set variable   ${out}
    ${G_CU_CONTAINER_PREFIX}   set variable    ${container_prefix}
    set suite variable   ${G_CU_CONTAINER_PREFIX}

Get CU Container Name Prefix
    [Arguments]  ${gnb_index}=0
    [Documentation]    Get CU Container Name Prefix like ctr-cran1-
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, rename KW to 'Get CU Container Name Prefix' and optimize code
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    CU Pod Name Prefix
    ...
    ${r}  ${out}  run keyword and ignore error    set variable  ${G_CU_CONTAINER_PREFIX}
    return from keyword if   "${r}"=="PASS"   ${G_CU_CONTAINER_PREFIX}
    _Set CU Pod And Container Name Prefix
    [Return]  ${G_CU_CONTAINER_PREFIX}

Get CU Full Container Name By Container Abbreviation
    [Arguments]  ${ctr_abbr}
    [Documentation]  get the given cu container full name by the given container abbreviation,
    ...  You should call the keyword - Set CU Pod And Container Name Prefix firstly before using this keyword.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  modified by:       <07-29-2021>, <lutu>, <miss G_CU_CONTAINER_PREFIX>
    ...    | Input Parameters | Man. | Description |
    ...    | ctn_abbr | Yes. | the container name abbreviation. |

    ...    *RETURN VALUE*
    ...    the container full name
    ...  *Example*
    ...    | Set CU Pod And Container Name Prefix |
    ...    | ${ctr_name} | Get CU Full Container Name By Container Abbreviation | oamcm |
    ${G_CU_CONTAINER_PREFIX}=    Get CU Container Name Prefix
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${G_CU_CONTAINER_PREFIX}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${cu_full_ctr_name}   set variable  ${G_CU_CONTAINER_PREFIX}${ctr_abbr}
    [Return]  ${cu_full_ctr_name}

Get CU Full Pod Name By Pod Abbreviation
    [Arguments]  ${pod_abbr}  ${alias}=default  ${gnb_index}=0
    [Documentation]  get the full pod name by pod abbreviation using kubectl get pods command
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    2021.7.26,chris.l.cao@nokia-sbell.com, add sudo for cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation. |

    ...    *RETURN VALUE*
    ...    the pod full name
    ...  *Example*
    ...    | ${alias}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${pod_name} | Get CU Full Pod Name By Pod Abbreviation | oamcm | ${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${ns}   Get CU Namespace From Testline  ${gnb_index}
    ${cmd}   set variable   kubectl get pods -n ${ns}|egrep -w "(${pod_abbr})" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    [Return]  ${full_pod_name}

Get CU Pod Located Node
    [Arguments]  ${pod_abbr}   ${alias}=${EMPTY}   ${gnb_index}=0
    [Teardown]  run keyword and ignore error   run keyword if   "${alias}"=="${EMPTY}"
       ...   issh.disconnect  alias=${alias_new}
    [Documentation]    get the node which the pod located.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, add support for EMPTY alias
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the node name
    ...    Example
    ...    | ${node}= | Get CU Pod Located Node | oamcm  |
    ...    or
    ...    | ${alisa}= | Connect To CU K8S Master With Admin  |  |
    ...    | ${node}= | Get CU Pod Located Node | oamcm | ${alisa} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${ns}=  Get CU Namespace From Testline  ${gnb_index}
    ${alias_new}  run keyword if   "${alias}"=="${EMPTY}"      Connect To CU K8S Master With Admin   gnb_index=${gnb_index}
    ...   ELSE    set variable   ${alias}

    ${full_pod_name}  Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   alias=${alias_new}
    ${cmd}   set variable  kubectl get pod ${full_pod_name} -o yaml -n ${ns}|grep nodeName|awk -F ": " '{print $2}'

    ${pod_located_node}   issh.Execute  command=${cmd}   alias=${alias_new}
    ${pod_located_node}   Set Variable  ${pod_located_node.strip()}
    ${pod_located_node}   strip prompt  ${pod_located_node}
    should not be empty  ${pod_located_node}

    [Return]  ${pod_located_node}

Connect To CU Node
    [Arguments]  ${pod_abbr}=oamcm   ${gnb_index}=0
    [Documentation]    connect to CU node which the pod located.
    ...  author:            calla.wang@nokia-sbell.com
    ...  modified by:        <06-23-2021>, <calwang>, <initial created>
    ...    history change: 14.7.2021,chris.l.cao@nokia-sbell.com, add support to cbis-admin user
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the cluster connection alias used to execute command later.
    ...    Example
    ...    |  Connect To CU Node  | oamcm |
    ${master_conn_alias}=   Connect To CU K8S Master With Admin  ${gnb_index}
    ${master_node_hostname}  Get Host Name   alias=${master_conn_alias}
    ${pod_located_node}=   Get CU Pod Located Node  ${pod_abbr}  ${master_conn_alias}  ${gnb_index}
    ${ssh_command}  Set Variable  ssh -o StrictHostKeyChecking=no ${pod_located_node}

    ${old_prompt}   issh.Get Prompt   alias=${master_conn_alias}
    ${new_prompt}  set variable   ${old_prompt}|assword:
    issh.Set Prompt   ${new_prompt}  alias=${master_conn_alias}

    ${out}   issh.Execute  command=${ssh_command}  check_result=${False}  alias=${master_conn_alias}

    issh.Set Prompt   ${old_prompt}  alias=${master_conn_alias}

    run keyword if   "assword:" in """${out}"""   issh.Execute
    ...   command=${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    ...   check_result=${False}  alias=${master_conn_alias}

    ${pod_node_hostname}  Get Host Name   alias=${master_conn_alias}
    ${out}  Run Keyword If  "${master_node_hostname}"=="${pod_node_hostname}"   issh.Execute  command=exit   alias=${master_conn_alias}
    [Return]  ${master_conn_alias}

Get CU Container ID
    [Arguments]  ${pod_abbr}   ${ctr_abbr}  ${alias}=${EMPTY}  ${gnb_index}=0
    [Teardown]  Run Keyword If   "${alias}"=="${EMPTY}"  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${real_alias}
    [Documentation]  get the given cu container id
    ...  author:            calla.wang@nokia-sbell.com
    ...  history change:
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...  24.12.2021,chris.l.cao@nokia-sbell.com, add support to OCP
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | pod_abbr | Yes. | the pod name abbreviation, do not give the full pod name. |
    ...    | ctr_abbr | Yes. | the container name abbreviation. |
    ...    | alias | Yes. | the alias that connected to the CU cluster. |
    ...    | gnb_index | No. | the gnb index, default value is 0. |

    ...    *RETURN VALUE*
    ...    the container id
    ...
    ...  *Example*
    ...    Get container id without alias parameter:
    ...    | ${container_id} | Get CU Container ID | pod_abbr=upue |  ctr_abbr=l2hicu |
    ...
    ...    Get container id with alias parameter:
    ...    | ${alias} | Connect To CU Node  | ${pod_abbr}|
    ...    | ${container_id} | Get CU Container ID | pod_abbr=upue |  ctr_abbr=l2hicu | alias=${alias} |
    ...    | Disconnect Interactive Connection | ${alias} |
    ...
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   Connect To CU Node  pod_abbr=${pod_abbr}
       ...    ELSE   Set Variable   ${alias}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${ctr_abbr}
    ${ssh_command}   Set Variable   sudo crictl ps|grep "${full_container_name} "|awk '{print $1}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}
    ${out}  Strip Prompt  ${out}

    ${container_id}   Set Variable  ${out.strip()}

    [Return]  ${container_id}

Get PID For Container In VCU
    [Arguments]  ${pod_abbr}  ${ctr_abbr}   ${alias}=${EMPTY}
    [Teardown]  Run Keyword If   "${alias}"=="${EMPTY}"  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${real_alias}
    [Documentation]   Get PID For Container In VCU
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ns              | Yes | namespace |
    ...    | pod_abbr  | yes | pod abbr |
    ...    | ctr_abbr  | yes | container abbr |
    ...    | alias   | no | alias, default value is default |
    ...
    ...    *RETURN VALUE*
    ...    get container id for OCP
    ...
    ...    Example
    ...    | ${alias} |  Connect To CU K8S Master With Admin |
    ...    | ${pid} | Get PID For Container In VCU  | ctr_abbr=l2hicu | alias=${alias} |
    ...    | Disconnect Interactive Connection | alias=${alias} |
    ...
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   Connect To CU Node  pod_abbr=${pod_abbr}
       ...    ELSE   Set Variable   ${alias}
    ${container_id}   Get CU Container ID   pod_abbr=${pod_abbr}  ctr_abbr=${ctr_abbr}  alias=${real_alias}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${container_id}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}
    ${out}  Strip Prompt  ${out}

    ${pid}   Set Variable  ${out.strip()}
    [Return]  ${pid}

Get VCU NF Type
    [Arguments]  ${gnb_index}=0
    [Documentation]   Get VCU NF Type
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...	  | gnb_index | no | gnb_index, default is 0 |
    ...
    ...   *RETURN VALUE*
    ...    VNF or CNF
    ...
    ...   Example
    ...   | ${nf_type} | Get VCU NF Type |
    ...
    ${flavors}   Set Variable  ${tl.gnbs[${gnb_index}].cloud_deployment.flavors}
    ${nf_type}  set variable if   "${flavors}"=="${None}"   CNF   VNF
    [Return]  ${nf_type}

CU Get Master VM Index
    [Arguments]  ${gnb_index}=0   ${vm_type}=oam
    [Documentation]    CU Get Master VM Index
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...    | vm_type   | no | vm type, can be oam, cpif,cpcl,cpnb,cpnrt,cpue,db and upue, default is oam |
    ...
    ...    *RETURN VALUE*
    ...   None
    ...
    ...    Example
    ...    | ${master_vm_index} | CU Get Master VM Index| vm_type=oam |
    ...    | ${master_vm_index} | CU Get Master VM Index| gnb_index=0 | vm_type=cpif |
    ...
    ${vm_type}  Set Variable  ${vm_type.upper()}
    ${master_vm_index}   Set Variable  0
    [Return]  ${master_vm_index}
