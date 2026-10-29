*** Settings ***
Documentation
...   Migrate keywords from AIC
...   author:yixiang.x.wang@nokia-sbell.com

Resource          cloud_state.robot
Library           taf.gnb.oam.coam.vdu.interface.Vdu    WITH NAME    vdu
Library           taf.selenium.gnb.oam.coam.vdu         WITH NAME    svdu
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vdu_cli.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vdu_opeartion.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/AIC_common.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/global_variables.py
Library           taf.hw.fhgw.cli                       WITH NAME    issh


*** Keyword ***
vDU Login
    [Arguments]  ${login_type}=rest   ${restapi_version}=cuoam_19b   ${vdu_index}=0
    [Documentation]  Login to vdu via rest or webem.
    ...    author: calla.wang@nokia-sbell.com
    ...    modified by:        <13-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | Yes | the index of vdu, default value is 0 |
    ...    |  solution | Yes |  rest or webui, default value is 0 |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  vDU Login  |     |

    run keyword if  "${login_type}"=="rest"    vDU Rest Login   ${restapi_version}  ${vdu_index}
    ...   ELSE   vDU WebEM Login  ${vdu_index}

vDU Rest Login
    [Arguments]    ${restapi_version}=cuoam_19b    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  login vdu webem.
    ...    author: calla.wang@nokia-sbell.com
    run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    ${vdu_connection}=   Run Keyword If  '${restapi_version}'=='cuoam_19b'  vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  ELSE  vdu.connect to
    ...  host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}

vDU WebEM Login
    [Arguments]   ${vdu_index}=0
    [Documentation]  Login to vDU via WebEM.
    ...    author: calla.wang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  vdu_index  | Yes | the index of vdu, default value is 0 |
    Log    message=\nArgument vdu_index=${vdu_index} is not used and will be removed in the future.
    log to console   \n*** Start vDU webui login  ***
    log   Login to vdu WebEM function is not ready!     level=ERROR

vDU Logout
    [Arguments]   ${logout_type}=rest
    [Documentation]  Teardown login session to CU.
    ...    author: fen.huang@nokia-sbell.com
    ...    modified by:        <22-Nov-2019>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |

    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    |  CU Logout |   |
    run keyword if  "${logout_type}"=="rest"    vDU Rest Logout
    ...   ELSE    vDU WebEM Logout

vDU Rest Logout
    [Arguments]  ${vdu_index}=0
    [Documentation]  Teardown rest session to vdu.
    ...    author: calla.wang@nokia-sbell.com
    # log to console   \n*** Start vdu logout ***
    Log    message=\nArgument vdu_index=${vdu_index} is not used and will be removed in the future.
    vdu.disconnect

vDU WebEM Logout
      [Documentation]  Logout vDU webui.
    ...    author: calla.wang@nokia-sbell.com
    ...    modified by:        <26-Mar-2020>, <f2huang>, <Initial creation>
    ...    | Input Parameters | Man. | Description |
    ...    |  CU Webui Logout   |     |
    log to console   \n*** CU Webui Logout ***
    log   Logout vdu WebEM function is not ready!   level=ERROR

Online Get VDU Parameter Value
    [Arguments]    ${mo_dn}    ${para_name}    ${timeout}=60
    [Documentation]   Get VDU Parameter Value Online
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | mo_dn     | yes | the distname of given parameter |
    ...    | para_name | yes | parameter name   |
    ...    | timeout   | no | timeout, default is 60, unit is second   |
    ...
    ...    | Return Value | Description |
    ...    | ${out} | return the parameter value |
    ...
    ...    Example
    ...    | ${para_value} | Get VDU Parameter Value Online | mo_dn=MRBTS-10766/NRBTS-10766 | para_name=packetsLost |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.search_parameter_of_current_plan   mo_dn=${mo_dn}   para_name=${para_name}   timeout=${timeout}
    [Return]  ${out}

VDU Online Modify Parameters By Delta Plan REST
    [Arguments]    ${mo_dn}    ${updated_paras_list}    ${operation}=replace    ${activate}=${True}
    ...    ${force_reset}=${True}    ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   VDU Online Modify Parameters By Delta Plan REST
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn               | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list  | yes | parameters values, type is dict |
    ...   | operation         | no |  the operation - add, replace, remove, revert. The default is replace |
    ...   | activate         | no | if ${True} to activate plan, if ${False} not to activate it. The default is ${True} |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...
    ...   Without activate it:
    ...   | VDU Online Modify Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...
    ${timeout}    convert to integer    ${timeout}
    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
    #Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
    ${out}    Update Delta Plan Parameter    plan_id=${planid}    mo_dn=${mo_dn}
    ...                 updated_paras_dict=${updated_paras_list}    operation=${operation}
    ${validation_id}    Validate Delta Plan By REST    plan_id=${planid}
    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST    plan_id=${plan_id}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}    wait_vdu_up=${wait_vdu_up}

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

_Make Sure Delta Plan Is Deleted Once
    ${all_plans}   vdu.Get_Delta_Plan_Info_List
    Should Be True  ${all_plans.__len__()}==0

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
    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once

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
    Run Keyword If  ${all_plans.__len__()}==1   Delete Delta Plan By Plan Id   plan_id=${all_plans[0]["plan_id"]}

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
    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  20   vDU Verify All Cells Status Should Be Onair

Vdu Add Route
    [Arguments]   ${dist}   ${destIpAddr}  ${PrefixLength}  ${gateway}  ${preference}=8   ${wait_vdu_up}=False
    [Documentation]    Add static route for vdu
    ...    *AUTHOR* hongping.rao@nokia-sbell.com
    ...    Add static route for vdu
    ...    | Input Parameters | Man. | Description |
    ...    | dist    | yes | distname to add static route |
    ...    | destIpAddr   | yes | destIpAddr for static route |
    ...    | PrefixLength   | yes | PrefixLength for static route |
    ...    | gateway   | yes | gateway for static route |
    ...    | preference   | no | preference for static route, default is 8 |
    ...    | wait_vdu_up   | no | whether to wait for vdu up after static route configured |

    ...
    ...    *RETURN VALUE*
    ...   list of route info  [static route distname,  staticRoutes/index]
    ...
    ...    Example
    ...    | VDU Rest Login |
    ...    | ${route_info} | Vdu Add Route | dist  | 1.1.1.1 | 24 | 1.1.1.2 |
    ...    | VDU Logout |
    ...
    ${route_list_name}  Set Variable If  ':' in '''${destIpAddr}'''  staticIpv6Routes  staticRoutes
    ${route_dstip_name}  Set Variable If  ':' in '''${destIpAddr}'''  destIpv6Addr  destIpAddr
    ${route_prefix_name}  Set Variable If  ':' in '''${destIpAddr}'''  destinationIpv6PrefixLength
    ...  destinationIpPrefixLength
    ${route_gateway_name}  Set Variable If  ':' in '''${destIpAddr}'''  gatewayIpv6Addr  gateway

    ${uni_id}   Get Unique Id
    ${scf_path}  Get A Directory  SCF
    ${scf_full_path}=  vdu.Get Current Plan File  ${scf_path}  full_scf_${uni_id}.xml  include_runtime_data=${True}
    scf.Load Scf   ${scf_full_path}
    ${res}  Run Keyword And Ignore Error  scf.Get All Values From Scf   dist_name=${dist}
    ...  p_name=${route_gateway_name}
    ${length}   Run Keyword If  '${res[0]}'=='PASS'   Get Length   ${res[1]}
    ...  ELSE    Set Variable  0
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=add_route_${uni_id}
    ${prefix}   ${rest}   Split String From Right   ${dist}   /   1
    Run Keyword If  ${length}==0   Add Delta Plan MO   plan_id=${plan_id}   parent_mo_dn=${prefix}  mo_name=${rest}
    ${paras_list}    Create Dictionary   /${route_list_name}=${EMPTY}
    Run Keyword If   ${length}==0  Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}
    ...  updated_paras_dict=${paras_list}   operation=add
    Sleep  2sec

    ${paras}=   Create Dictionary   ${route_list_name}/${length}/${route_gateway_name}=${gateway}
    ...   ${route_list_name}/${length}/${route_dstip_name}=${destIpAddr}
    ...   ${route_list_name}/${length}/${route_prefix_name}=${PrefixLength}
    ...   ${route_list_name}/${length}/preference=${preference}
    Sleep   10sec
    Update Delta Plan Parameter   plan_id=${plan_id}   mo_dn=${dist}   updated_paras_dict=${paras}   operation=add
    Validate Delta Plan By REST   ${plan_id}
    ${scf_path}  Get A Directory  SCF
    ${delta_filename}  Set Variable   add_route_${uni_id}.xml
    ${delta_scf_fullpath}   vdu.Save Delta Plan File   local_path=${scf_path}   local_filename=${delta_filename}
    Activate Delta Plan By REST   ${plan_id}   wait_vdu_up=${wait_vdu_up}
    [Return]   ${dist}  ${route_list_name}/${length}

Connect To vDU Node Interactively
    [Arguments]   ${pod_abbr}=${EMPTY}   ${container_abbr}=${EMPTY}  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To vDU Node Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr        |  no | pod abbreviation, e.g, oam, cprt, up |
    ...    | container_abbr |  no | container abbreviation, e.g, oam, oamfh, cprt, l1hi |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | ${ns} | Get vDU Namespace From TestLine  |
    ...    | ${container_id} | Get Container ID From Docker Ps Command By POD Abbreviation Interactively | ns=${ns} |
    ...    |  ... | pod_abbr=oamcp | container=oamfh | alias=default |
    ...    | ${out} | Docker Exec By Container ID Interactively | container_id=${container_id} | command=ifconfig | alias=default |
    run keyword if  "${pod_abbr}"=="${EMPTY}" and "${container_abbr}"=="nwmgmt"  Fail  Can't use nwmgmt container, must use pod_abbr!
    run keyword if  "${pod_abbr}"=="${EMPTY}" and "${container_abbr}"=="${EMPTY}"  Fail  pod_abbr or container_abbr must be given!
    run keyword if  "${pod_abbr}"!="${EMPTY}" and "${container_abbr}"!="${EMPTY}"  Fail  pod_abbr and container_abbr can't be used at the same time!
    ${pod_abbr}  run keyword if  "${pod_abbr}"=="${EMPTY}"  Get Pod Abbreviation By Container Abbreviation    container_abbr=${container_abbr}
    ...   ELSE   set variable   ${pod_abbr}

    ${ip}    set variable   ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ${username}  set variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ${password}  set variable  ${tl.gnbs[0].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}

    #issh.connect_to   ip=${ip}    username=${username}   password=${password}
    #   ...   prompt=\\[cloudadmin@controller-\\d+\\s+\\S+\\]\\$|\\[cloudadmin@compute-\\d+\\s+\\S+\\]\\$
    #   ...   alias=${alias}   width=200
    connect to k8s master interactively     vdu_index=${vdu_index}   alias=${alias}

    #${master_node_hostname}  Get Host Name   alias=${alias}

    #${work_node_ip}    Get Work Node Ip By Pod Abbreviation Interactively   pod_abbr=${pod_abbr}   alias=${alias}   vdu_index=${vdu_index}
    #${ssh_command}  Set Variable  ssh -o BatchMode=yes -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${work_node_ip}
    #issh.Execute  command=${ssh_command}   alias=${alias}
    #${work_node_hostname}  Get Host Name   alias=${alias}

    #${out}  Run Keyword If  "${master_node_hostname}"=="${work_node_hostname}"   issh.Execute  command=exit   alias=${alias}
    [Return]  ${alias}




Connect To K8s Master Interactively
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   31.5.2021,chris.l.cao@nokia-sbell.com, support NCS
    ...   12.8.2021,chris.l.cao@nokia-sbell.com, support OCP by adding '[core@...]'
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection  |
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master Interactively   | alias=${alias} |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias}  |
    ...    | disconnect interactive connection     | alias=${alias} |
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${ip}   set variable   ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}   set variable   ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}   set variable   ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}  set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[core@\\S+\\s\\S+\\]\\$

    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200
       ...   timeout=150

#    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
#       ...   prompt=NetworkManager-wait-online.service
#       ...   alias=${alias}   width=200
#       ...   timeout=150
#    sleep  2
#    issh.set prompt    ${prompt}   alias=${alias}
#    Send CTRL_C Interactively   alias=${alias}
#    ${out}   issh.Execute   command=hostname     alias=${alias}



vDU Disconnect Interactive Connection
    [Arguments]  ${alias}=default
    [Documentation]   Disconnect Interactive Connection for specifical connection identified by alias name
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | alias      | no   | alias, default value is default |
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |
    ...    | Connect To vDU Node Interactively | pod_abbr=oamcp |  alias=alias2 |
    ...    | Disconnect Interactive Connection |               |
    ...    | Disconnect Interactive Connection | alias=alias2 |
    should not be empty   ${alias}
    issh.disconnect  alias=${alias}

vDU Begin K8s Log
    [Arguments]     ${gnb_index}=0  ${vdu_index}=0
    [Documentation]    Begin K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.9.2021, chris.l.cao@nokia-sbell.com, suppot non-CST timezone
    ...    |  Input Parameters | Man. | Description |
    ...    None
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ${alias}=  get unique id
    Connect To K8s Master Interactively   alias=${alias}  vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${date_info}=   issh.execute   command=date --rfc-3339=ns  check_result=${False}   alias=${alias}
    #${datetime}=    get regexp matches    ${date_info}      (\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+08:00)    1
    ${datetime}=    get regexp matches    ${date_info}      (\\d+-\\d+-\\d+ \\d+:\\d+:\\d+.\\d+\\+\\S+)    1
    ${k8s_master_datetime}=    set variable   ${datetime[0]}
    ${k8s_master_datetime}=    replace string  ${k8s_master_datetime}  ${SPACE}  T
    [Return]  ${k8s_master_datetime}
    [Teardown]   vDU Disconnect Interactive Connection   alias=${alias}


vDU End K8s Log
    [Arguments]   ${handle}  ${pod_abbr}  ${container}   ${gnb_index}=0  ${vdu_index}=0
    [Teardown]  run keyword and ignore error    vDU Disconnect Interactive Connection    alias=${alias}
    [Documentation]    End K8s Log
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change, <date>,<who>,<what and how>
    ...    13.09.2021, chris.l.cao@nokia-sbell.com, change login account from tenant to admin to better support in OCP
    ...    |  Input Parameters | Man. | Description |
    ...    | since_time |  Yes | it's returned from 'Begin K8s Log' |
    ...    | pod_abbr   |  Yes | pod abbreviation name, eg, oamcp, uprt |
    ...    | container  | Yes | container name, e.g. oam, oamfh, nwmgmt, cprt, rcpsdl, l2rt, l2hi, l1hi |
    ...	   | gnb_index  | no | gnb_index, default is 0 |
    ...	   | vdu_index  | no | vdu_index, default is 0 |
    ...    *RETURN VALUE*
    ...    Handle of 'Begin K8s Log', it will be used in 'End K8s Log'
    ...    Example
    ...    Capture in one POD and one container
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    Capture in two POD and two containers
    ...    | ${handle} | Begin K8s Log |
    ...    | sleep  | 30 |
    ...    | ${log_file} | End K8s Log | handle=${handle}  |  pod_name=up | container_name=l2rt |
    ...    | ${log_file2} | End K8s Log | handle=${handle}  |  pod_name=oamcp | container_name=cprt |
    ${alias}   get unique id
    vDU Connect To K8s Master Interactively    vdu_index=${vdu_index}   alias=${alias}   gnb_index=${gnb_index}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively    pod_abbr=${pod_abbr}   alias=${alias}
        ...  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${full_ctr_name}    Run Keyword If  '${container}'!='all'
        ...   Get Full Container Name By Container Abbreviation   ctr_abbr=${container}   gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${remote_file}   get a remote file  ${pod_abbr}_${container}.log     alias=${alias}
    ${unique_id}     get unique id   precise=LOW
    ${local_ute_file}   get a file  ${pod_abbr}_${container}_${unique_id}.log
    ${ns}   Get vDU Namespace From TestLine   gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${function_cmd}=   Run Keyword If  '${container}'=='all'
    ...  set variable  kubectl logs ${full_pod_name} --all-containers=true --since-time=${handle} -n ${ns}
    ...  ELSE  set variable  kubectl logs ${full_pod_name} -c ${full_ctr_name} --since-time=${handle} -n ${ns}
    ${old_timeout}    issh.set_timeout  600   alias=${alias}
    ${cmd}  set variable   ${function_cmd} > ${remote_file}
    ${out}  issh.Execute  command=${cmd}   alias=${alias}
    issh.set_timeout  ${old_timeout}   alias=${alias}
    ${out}  issh.Execute  command=sync  alias=${alias}
    ${out}  issh.downloadfile   remote_path=${remote_file}   local_path=${local_ute_file}   alias=${alias}
    [Return]  ${local_ute_file}

vDU Get Container Name Prefix
    [Arguments]     ${vdu_index}=0
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    Example
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    Log    message=\nArgument vdu_index=${vdu_index} is not used and will be removed in the future.
    ${r}  ${out}  run keyword and ignore error   set variable   ${_G_CONTAINER_PREFIX}
    return from keyword if  "${r}"=="PASS"   ${_G_CONTAINER_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use
    set suite variable   ${_G_CONTAINER_PREFIX}

    [Return]  ${_G_CONTAINER_PREFIX}

_Get Container Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  fast_disconnect  alias=${alias}
#    [Teardown]  run keyword and ignore error   disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Container Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.8.2021,chris.l.cao@nokia-sbell.com, change from tenant to admin account to adapt OCP
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    Example
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use |
    ...    | ${container_prefix} | _Get Container Name Prefix Internal Use | vdu_index=0 |
    ${pod_prefix}   _Get Pod Name Prefix Internal Use
    ${alias}  get unique id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${command}  Set Variable  kubectl describe pod ${pod_prefix}up-0
    #${with_pipeline_command}  Set Variable  |grep l1hi:|head -n 1|awk -F l1hi '{print $1}'
	${with_pipeline_command}  Set Variable  |grep l2hi:|head -n 1|awk -F l2hi '{print $1}'
    ${container_prefix}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

    [Return]  ${container_prefix}
_Get Pod Name Prefix Internal Use
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0
#    [Teardown]  run keyword and ignore error   disconnect interactive connection   alias=${alias}
    [Teardown]  run keyword and ignore error  fast_disconnect  alias=${alias}
    [Documentation]   _Get Pod Name Prefix Internal Use
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.8.2021,chris.l.cao@nokia-sbell.com, change from tenant to admin account to adapt OCP
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Pod Name Prefix, e.g, po-cran1-
    ...    Example
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use |
    ...    | ${pod_prefix} | _Get Pod Name Prefix Internal Use | vdu_index=0 |
    ${alias}  get unique id
    fast_connect_to_k8s_master  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${command}  Set Variable  kubectl get pod
    ${with_pipeline_command}  Set Variable  |grep -E \"\\-oamext\\-\"|awk -F \"-oamext-\" '{print $1 }'
    ${pod_prefix}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${pod_prefix}   set variable if   ${pod_prefix.__len__()>0}   ${pod_prefix}-   ${EMPTY}
    [Return]  ${pod_prefix}
vDU Connect To K8s Master Interactively
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   15.10.2020,chris.l.cao@nokia-sbell.com, initialization version
    ...   31.5.2021,chris.l.cao@nokia-sbell.com, support NCS
    ...   12.8.2021,chris.l.cao@nokia-sbell.com, support OCP by adding '[core@...]'
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...    *RETURN VALUE*
    ...    None.
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${out} | issh.Execute | command=ls -l |
    ...    | disconnect interactive connection  |
    ...    | ${alias} | Get Unique Id |
    ...    | Connect To K8s Master Interactively   | alias=${alias} |
    ...    | ${out} | issh.Execute | command=ls -l | alias=${alias}  |
    ...    | disconnect interactive connection     | alias=${alias} |
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info  gnb_index=${gnb_index}   vdu_index=${vdu_index}

    ${ip}   set variable   ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}   set variable   ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}   set variable   ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}  set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[core@\\S+\\s\\S+\\]\\$

    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}   width=200
       ...   timeout=150

#    issh.Connect_To   ip=${ip}    username=${username}   password=${password}
#       ...   prompt=NetworkManager-wait-online.service
#       ...   alias=${alias}   width=200
#       ...   timeout=150
#    sleep  2
#    issh.set prompt    ${prompt}   alias=${alias}
#    Send CTRL_C Interactively   alias=${alias}
#    ${out}   issh.Execute   command=hostname     alias=${alias}
vDU Get Full Pod Name By Pod Abbreviation Interactively
    [Arguments]    ${pod_abbr}    ${alias}=default   ${vdu_index}=0     ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | disconnect interactive connection  |

    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}

    ${out}   issh.Execute   command=${cmd}   alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    [Return]  ${full_pod_name}
Get A Remote File
    [Arguments]   @{parameter_list}
    [Teardown]  run keyword and ignore error   vDU Disconnect Interactive Connection   alias=${alias_admin}
    [Documentation]   create a temparary file in remote server and return full file name,
    ...    this file will keep 3 hours then it will be removed automatically
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_list    | yes | including subfolder name or file name, and alias, please see examples  |
    ...    *RETURN VALUE*
    ...   Full temparary file name with folders name
    ...    Example
    ...   | ${alias}   | Get Unique Id |
    ...   | connect to k8s master with tenant interactively | alias=${alias} |
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/folder2/xxxxxxx_a.txt
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2 | a.txt | alias=${alias} |
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/a.log
    ...   | ${remote_file_name} | Get A Remote File | folder1 | xxxxxxx_a.log | alias=${alias} |
    ...
    ...   | Connect To vDU Node Interactively | pod_abbr=oam |
    ...   return /tmp/tmp_taic/<suitename>/<casename>/2020_08_06_04_58_01/folder1/folder2/xxxxxxx_c.txt
    ...   | ${remote_file_name} | Get A Remote File |  folder1 | folder2 | c.txt |

    ${non_key_value_pair_list}   ${key_value_dict}   run keyword if  ${parameter_list.__len__()}>0
       ...   _Parse Input Parameter According To Seperator   =   @{parameter_list}
    ${non_key_value_pair_list}  run keyword if  "${non_key_value_pair_list}"=="${None}"   create list
       ...   ELSE   set variable  ${non_key_value_pair_list}
    ${key_value_dict}  run keyword if  "${key_value_dict}"=="${None}"   create dictionary
       ...   ELSE   set variable  ${key_value_dict}

    ${key_value_dict_keys}   evaluate  list(${key_value_dict})

    ${alias}   set variable if   "alias" in "${key_value_dict_keys}"   ${key_value_dict["alias"]}   default
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove From Dictionary   ${key_value_dict}   alias
    Run Keyword If  "alias" in "${key_value_dict_keys}"   Remove Values From List   ${key_value_dict_keys}   alias

    #${base_folder0}  set variable   /tmp/tmp_taic
    ${ns}   get vdu namespace from testline
    ${cu_ns}=   Get CU Namespace From TestLine
    ${base_folder0}  set variable   /tmp/tmp_taic_${ns}_${cu_ns}

    #set full permission
    ${alias_admin}   get unique id
    connect to k8s master interactively  alias=${alias_admin}
    ${out}  issh.Execute  command=sudo mkdir -p ${base_folder0}    alias=${alias_admin}
    ${out}  issh.Execute  command=sudo chmod -R 777 ${base_folder0}    alias=${alias_admin}

    ${base_folder}  _Get Remote Log Path   base_folder=${base_folder0}

    ${subfolders_or_file_name}  set variable  ${non_key_value_pair_list}
    ${length}   Get Length  ${subfolders_or_file_name}
    issh.Execute  command=mkdir -p ${base_folder}   check_result=${False}   alias=${alias}

#    Clear Unused Remote Files    folder_name=${base_folder0}  time_window=10800   alias=${alias}

    ${tmp_file}   Get Unique ID   precise=FORMAT_DATETIME
    ${full_file_name}   Run Keyword If  ${length}>0   OperatingSystem.Join Path   ${base_folder}   @{subfolders_or_file_name}
    ...   ELSE   OperatingSystem.Join Path   ${base_folder}   ${tmp_file}

    ${path}  ${file}   OperatingSystem.Split Path   ${full_file_name}
    issh.Execute  command=mkdir -p ${path}   check_result=${False}   alias=${alias}

    ${full_file_name}   Run Keyword If  ${length}>0   Operatingsystem.Join Path   ${path}   ${tmp_file}_${file}
       ...   ELSE   set variable   ${full_file_name}
    issh.Execute  command=touch ${full_file_name}   check_result=${False}   alias=${alias}
    #issh.Execute  command=chmod -R 777 ${base_folder}  check_result=${False}   alias=${alias}
    _Get A Remote File Set Full Permission    folder_name=${base_folder}   alias=${alias}

    [Return]   ${full_file_name}

Get Pod Abbreviation By Container Abbreviation
    [Arguments]    ${container_abbr}=oamfh
    [Documentation]   Get Pod Abbreviation By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   15.12.2021,chris.l.cao@nokia-sbell.com, Fix problem that some PODs have multiple containers whose name are simular,
    ...                                e.g, in oamconfig pod, there are two containers oamconfig and appsecretinitoamconfig.
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container_abbr, eg, oamfh, l1hi |
    ...    *RETURN VALUE*
    ...    pod abbreviation, e.g, oam, cprt, up.
    ...    Example
    ...    | ${pod_abbr} | Get Pod Abbreviation By Container Abbreviation | container_abbr=oamfh |
    ${container_prefix}  vDU Get Container Name Prefix
    ${start_with_prefix}   set variable  ${container_abbr.startswith("${container_prefix}")}
    ${container_abbr}  run keyword if   "${start_with_prefix}"=="${True}"   set variable  ${container_abbr.replace("${container_prefix}","")}
        ...   ELSE   set variable    ${container_abbr}

    ${pod_keys}   Evaluate    list(${AIC_VDU_PODS})

    ${pod_abbr}   set variable   ${EMPTY}
    FOR   ${pod}  IN   @{pod_keys}
#        ${containers_list}    set variable    ${AIC_VDU_PODS["${pod}"]}
#        ${number}   count_string_in_list   ${containers_list}    ${container_abbr}
        ${containers_list}    set variable    ${AIC_VDU_PODS_CONTAINER_ABBR["${pod}"]}
        ${number}   Collections.Count Values In List   ${containers_list}    ${container_abbr}
        run keyword if   ${number}>=2   Fail   There are two container whose names are same !
        Return From keyword if   ${number}==1   ${pod}
    END

    [Return]  ${pod_abbr}


Get Full Pod Name By Pod Abbreviation Interactively
    [Arguments]    ${pod_abbr}    ${alias}=default   ${vdu_index}=0     ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...    Example
    ...    | Connect To K8s Master Interactively |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | disconnect interactive connection  |

    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}

    ${out}   issh.Execute   command=${cmd}   alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'

    ${out}   issh.Execute  command=${cmd}   alias=${alias}
    ${out}   strip prompt  ${out}
    ${full_pod_name}   Set Variable  ${out.strip()}
    [Return]  ${full_pod_name}


Get Full Pod Name By Pod Abbreviation Interactively In Python
    [Arguments]    ${pod_abbr}    ${alias}=default   ${vdu_index}=0     ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbreviation Interactively In Python
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...  modified by:       <06-23-2021>, <calwang>, <initial created>
    ...    28.7.2021,chris.l.cao@nokia-sbell.com, add to check "No resources found" not in ${out}
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | alias             | No | alias. Default value is default |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...    Example
    ...    |  ${alias} |  get unique id |
    ...    | fast_connect_to_k8s_master |   alias=${alias} |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation Interactively In Python | pod_abbr=up | vdu_index=0 | alias=myalias |
    ...    | fast_disconnect  alias=${alias}

    ${command}  Set Variable  kubectl get pod

    ${out}  fast_execute   command=${command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    should be true   "No resources found" not in """${out}"""

    ${with_pipeline_command}  Set Variable  |egrep "(-${pod_abbr}-)" |awk '{print $1}'
    ${full_pod_name}  fast_execute   command=${command}  with_pipeline_command=${with_pipeline_command}
     ...   gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}

#    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}
#    ${cmd}   set variable  kubectl get pods -n ${ns}
#
#    ${out}   issh.Execute   command=${cmd}   alias=${alias}
#    should be true   "No resources found" not in """${out}"""
#
#    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'
#
#    ${out}   issh.Execute  command=${cmd}   alias=${alias}
#    ${out}   strip prompt  ${out}
#    ${full_pod_name}   Set Variable  ${out.strip()}
    [Return]  ${full_pod_name}
Get Full Container Name By Container Abbreviation
    [Arguments]    ${ctr_abbr}       ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Get Full Container Name By Container Abbreviation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | ctr_abbr          |  Yes | container name abbreviation, eg, oamfh, oam, cprt, nwmgmt,etc |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Full Container name, e.g, ctr_cran1_oamfh
    ...    Example
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=oamfh |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=nwmgmt | vdu_index=0 |
    ...    | ${full_ctr_name} | Get Full Container Name By Container Abbreviation | ctr_abbr=cprt | vdu_index=0 |

    #@{ctr_list}  create list   appsecretinithttpd  appsecretinitne3sagent  appsecretinitprovidercontroller  httpdstunnel
    #...  ne3sagentstunnel  providercontrollerstunnel  httpdcredmediator  ne3sagentcredmediator  providercontrollercredmediator
    #: FOR    ${ctr}    IN    @{ctr_list}
    #\   return from keyword if   "${ctr_abbr}"=="${ctr}"   ${ctr_abbr}
    Log    message=\nArgument gnb_index=${gnb_index} is not used and will be removed in the future.

    ${container_prefix}  Get Container Name Prefix   vdu_index=${vdu_index}
    ${start_with_prefix}   set variable  ${ctr_abbr.startswith("${container_prefix}")}
    return from keyword if   "${start_with_prefix}"=="${True}"      ${ctr_abbr}

    ${full_ctr_name}   set variable  ${container_prefix}${ctr_abbr}
    [Return]  ${full_ctr_name}

Get Full Pod Name By Container Abbreviation Interactively
    [Arguments]    ${container_abbr}    ${alias}=default   ${vdu_index}=0     ${gnb_index}=0
    [Teardown]  run keyword and ignore error   vDU Disconnect Interactive Connection   alias=${alias_tmp}
    [Documentation]   Get Full Pod Name By Container Abbreviation Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | container_abbr    |  No | container name appreviation, eg, oamfh, l1hi |
    ...    | alias             | No | alias. Default value is default. Now this parameter can be omitted! |
    ...    | gnb_index         | No | gnb_index. Default value is 0 |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...    Example
    ...    | ${full_pod_name} | Get Full Pod Name By Container Abbreviation Interactively | container_abbr=oamfh |
    Log    message=\nArgument alias=${alias} is not used and will be removed in the future.
    run keyword if   "${container_abbr}"=="nwmgmt"   Fail  This KW can't be used for container nwmgmt !

    ${pod_abbr}   Get Pod Abbreviation By Container Abbreviation   container_abbr=${container_abbr}
    ${alias_tmp}   get unique id
    connect to k8s master interactively  alias=${alias_tmp}
    ${full_pod_name}   Get Full Pod Name By Pod Abbreviation Interactively
    ...   pod_abbr=${pod_abbr}   alias=${alias_tmp}   vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${full_pod_name}
Get Container Name Prefix
    [Arguments]     ${vdu_index}=0
    [Documentation]   Get Container Name Prefix
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...    *RETURN VALUE*
    ...    Container Name Prefix, e.g, ctr-cran1-
    ...    Example
    ...    | ${container_prefix} | Get Container Name Prefix |
    ...    | ${container_prefix} | Get Container Name Prefix | vdu_index=0 |
    Log    message=\nArgument vdu_index=${vdu_index} is not used and will be removed in the future.
    ${r}  ${out}  run keyword and ignore error   set variable   ${_G_CONTAINER_PREFIX}
    return from keyword if  "${r}"=="PASS"   ${_G_CONTAINER_PREFIX}

    ${_G_CONTAINER_PREFIX}   _Get Container Name Prefix Internal Use
    set suite variable   ${_G_CONTAINER_PREFIX}

    [Return]  ${_G_CONTAINER_PREFIX}




Get vDU Container ID
    [Arguments]  ${container_name}  ${connection}  ${vdu_index}=0
    [Documentation]  get the vdu container id by the giving container name
    ...   *AUTHOR* author: calla.wang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   10.11.2020,chris.l.cao@nokia-sbell.com, add container name prefix
    ...   17.6.2021,chris.l.cao@nokia-sbell.com, add 'sudo' for cbis_admin user
    ...    | Input Parameters | Man. | Description |
    ...	   | container_name | Yes. | the container name |
    ...    | connection | Yes. | the connection of the node |
    ...    *RETURN VALUE*
    ...    the container id
    ...    Example
    ...    | ${node_alias} | Connect To vDU Node | node_ip=192.168.2.134 | vdu_index=0 |
    ...    | ${container_id} | Get vDU Container ID | container_name=oam | connection=${node_alias} |
    ...    | [Teardown]  tafssh.reset_cache |
    ${container_name}   get full container name by container abbreviation   ctr_abbr=${container_name}   vdu_index=${vdu_index}
    #${cmd}=  set variable  docker ps -q -f name=.*${container_name}_.*
    ${cmd}=  set variable   sudo docker ps -q -f name=.*${container_name}_.*

#    ${full_pod_name}    Run Keyword If  "${pod_abbr}"!="${EMPTY}"
#      ...   Get Full Pod Name By Pod Abbreviation    pod_abbr=${pod_abbr}    vdu_index=${vdu_index}    connection=${connection}
#
#    ${cmd}    Run Keyword If  "${pod_abbr}"!="${EMPTY}"     set variable   sudo docker ps -q -f name=.*${container_name}_${full_pod_name}.*
#    ...   ELSE   set variable   sudo docker ps -q -f name=.*${container_name}_.*

    ${output}=  tafssh.execute  command=${cmd}  connection=${connection}
    ${container_id}=  set variable  ${output.strip()}
    [Return]  ${container_id}
_Parse Input Parameter According To Seperator
    [Arguments]   ${seperator}    @{para_list}
    [Documentation]    _Parse Input Parameter According To Seperator
    ...    *AUTHOR* chris.l.cao
    ...    | Input Parameters | Man. | Description |
    ...    | seperator | yes | seperator, eg, '='  |
    ...    | para_list | yes | dictionary, like 'key=value' pair format  |
    ...    *RETURN VALUE*
    ...    dictionary of parameter
    ...  Example
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | key1=value1 | key2=value2 | key3=value3 | ... |
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=500 |
    ...  | ${para_list} | _Parse Input Parameter According To Seperator | = | ntpServerList=10.56.126.22 | ntpAlarmingThreshold=5 | distName=TNL-3 |

    @{non_key_value_pair_list}    create list
    &{key_value_dict}    Create Dictionary

    ${len}    Get Length    ${para_list}
    Run Keyword If   ${len}==0   Fail    There is no input parameter while calling this keyword!

    FOR    ${item}    IN    @{para_list}
        ${out}    Split String    ${item}    ${seperator}    1
        ${len}   Get Length   ${out}
        ${first}    Set Variable    ${out[0]}
        ${second}    Set Variable If    ${len}==1    ${EMPTY}
        ...    ${len}>=2 and '${out[1]}'=='${EMPTY}'    ${EMPTY}
        ...    ${len}>=2 and '${out[1]}'!='${EMPTY}'    ${out[1]}
        Run Keyword If   '${second}'=='${EMPTY}'   Append To List   ${non_key_value_pair_list}   ${first}
        Continue For Loop If   '${second}'=='${EMPTY}'
        &{tempdict}    Create Dictionary    ${first}    ${second}
        &{key_value_dict}    Create Dictionary    &{key_value_dict}    &{tempdict}
    END

    [Return]   ${non_key_value_pair_list}   ${key_value_dict}

_Get Remote Case Log Path
    [Arguments]  ${base_folder}
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${START_TIME}
    run keyword if  "${result[0]}"!="PASS"   Fail  START_TIME is not initialzed! Please call 'Aic Common Setup' firstly.

    ${concated_suite_name}    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_suite_name}    Set Variable    ${concated_suite_name.replace("(", "").replace(")", "").replace("&", "")}

    ${concated_test_name}    Replace String    ${TEST NAME}    ${SPACE}    _
    ${concated_test_name}    Set Variable    ${concated_test_name.replace("[1]", "")}
    ${concated_test_name}    Set Variable    ${concated_test_name.replace("(", "").replace(")", "").replace("&", "")}
    ${timestamp}    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    #${case_log_path}=    OperatingSystem.Join Path    ${base_folder}   ${concated_suite_name}    ${concated_test_name}   ${timestamp}
    ${case_log_path}=    OperatingSystem.Join Path    ${base_folder}     ${concated_test_name}   ${timestamp}
    [Return]    ${case_log_path}

Create Logs Folder For Test Case
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}

_Get Remote Log Path
    [Arguments]  ${base_folder}=/tmp/tmp_taic
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${TEST NAME}
    ${log_path}    Run Keyword If    "${result[0]}"=="PASS"    _Get Remote Case Log Path   base_folder=${base_folder}
    ...    ELSE    _Get Remote Suite Log Path     base_folder=${base_folder}
    [Return]    ${log_path}

_Get A Remote File Set Full Permission
    [Arguments]  ${folder_name}     ${alias}=default
    [Documentation]   Clear Unused Remote Files under specified folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | folder_name      | yes | folder_name to be scanned  |
    ...    | alias            | no | alias, default is default|
    ...    *RETURN VALUE*
    ...   None
    ${current_user_name}   Get Current User Name Interactively   alias=${alias}

    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info
    ${vdu_k8s_tenant_ssh_connection_info}   Get K8s Tenant SSH Connection Info

    ${host_type}  Get Host Type  alias=${alias}
    run keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_tenant_ssh_connection_info["username"]}"
    ...    _Get A Remote File Set Full Permission On OE Server With Admin   folder_name=${folder_name}
    return from keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_tenant_ssh_connection_info["username"]}"

    run keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_master_ssh_connection_info["username"]}"
    ...    _Get A Remote File Set Full Permission On OE Server With Admin   folder_name=${folder_name}  alias=${alias}
    return from keyword if  "${host_type}"=="OE_SERVER_CONTROLLER" and "${current_user_name}"=="${vdu_k8s_master_ssh_connection_info["username"]}"

    Fail   Unknown host type!

Get Current User Name Interactively
    [Arguments]  ${alias}=default
    [Documentation]  Get Current User Name Interactively
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    |  Input Parameters | Man. | Description |
    ...    | alias       |  no | alias, defaut is default |
    ...    *RETURN VALUE*
    ...    current user name who logins K8S node
    ...    Example
    ...    | ${current_user_name} | Get Current User Name Interactively |
    ${out}   issh.Execute   command=whoami   alias=${alias}
    ${whoami}   Strip Prompt  ${out}
    [Return]   ${whoami}
Get K8s Tenant SSH Connection Info
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get K8s Tenant SSH Connection Info
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...    *RETURN VALUE*
    ...    Dictionary of OE server K8s Master SSH Connection Info defined in __init__.py, dictionary keys are addr, username, password and port.
    ...    example: {'addr': '1.1.1.1', 'username': 'cranuser1', 'password': 'systeM!23'}
    ...    Example
    ...    | ${vdu_k8s_tenant_ssh_connection_info} | Get K8s Tenant SSH Connection Info |
    ...    | ${vdu_k8s_tenant_ssh_connection_info} | Get K8s Tenant SSH Connection Info | vdu_index=1 |
    ${result}   ${addr}       Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True  "${result}"=="PASS"    Please give K8s Tenant SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}   ${username}    Run Keyword And Ignore Error
     ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Tenant SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}   ${password}    Run Keyword And Ignore Error
      ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Tenant SSH password in __init__.py for vdu_index=${vdu_index}

    ${rtn}   create dictionary  addr=${addr}    username=${username}   password=${password}
    [Return]  ${rtn}
Get Host Type
    [Arguments]  ${alias}=default
    [Documentation]   Get Host Type
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | alias            | no | alias, default is default|
    ...    *RETURN VALUE*
    ...  OE_SERVER_CONTROLLER or GENERAL_LINUX_SERVER
    ${prompt_oe_server_NCS}  set variable   \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\s+\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|\\[cranuser\\d+@\\S+\\s\\S+\\]\\$

    ${prompt_oe_server_OCP}  set variable   \\[core@\\S+\\s\\S+\\]\\$
    ${prompt_oe_server_NCS}  set variable   ${prompt_oe_server_NCS}|${prompt_oe_server_OCP}

    ${out}   issh.Execute   command=hostname  alias=${alias}
    ${matches}   get regexp matches  ${out}   \\[root@controller\\(FHGW.*\\).*\\]
    return from keyword if  ${matches}   FHGW

    ${matches}   get regexp matches  ${out}   \\[cloudadmin@controller-\\d.*\\]|\\[cranuser\\d+@controller-\\d.*\\]
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    #NCS:  [root@hz25ah0533r-ah05-3-3r-singlenodecluster-0 ~ ]#    , [cbis-admin@ncs-chris-ac06-1-1l-allinone-0 ~ (Master)]$
    #${matches}   get regexp matches  ${out}
    #  ...   \\[root@\\S+\\s\\S+\\]|\\[cbis-admin@\\S+\\s\\S+\\s\\S+\\]|\\[cranuser\\d+@\\S+\\s\\S+\\]|\\[cranuser\\d+@\\S+\\s\\S+\\s\\S+\\]
    ${matches}   get regexp matches  ${out}   ${prompt_oe_server_NCS}
    return from keyword if  ${matches}   OE_SERVER_CONTROLLER

    ${matches}   get regexp matches  ${out}   \\[cloudadmin@compute-\\d+.*\\]
    return from keyword if  ${matches}   OE_SERVER_COMPUTER

    [Return]  GENERAL_LINUX_SERVER
_Get Remote Suite Log Path
    [Arguments]  ${base_folder}
    ${result}    Run Keyword And Ignore Error    Variable Should Exist    ${START_TIME}
    run keyword if  "${result[0]}"!="PASS"   Fail  START_TIME is not initialzed! Please call 'Aic Common Setup' firstly.

    ${concated_suite_name}    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_suite_name}    Set Variable    ${concated_suite_name.replace("(", "").replace(")", "").replace("&", "")}
    ${timestamp}     Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${suite_log_path}    OperatingSystem.Join Path    ${base_folder}    ${concated_suite_name}   ${timestamp}
    [Return]    ${suite_log_path}

_Get A Remote File Set Full Permission On OE Server With Admin
    [Arguments]  ${folder_name}    ${alias}=${EMPTY}
    [Teardown]  run keyword if   "${alias}"=="${EMPTY}"   vDU Disconnect Interactive Connection  alias=${alias_new}
    [Documentation]   Clear Unused Remote Files under specified folder
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | folder_name      | yes | folder_name to be scanned  |
    ...    | alias            | no | alias, default is default|
    ...    *RETURN VALUE*
    ...   None
    ${alias_new}   run keyword if   "${alias}"=="${EMPTY}"  get unique id
      ...   ELSE  set variable  ${alias}
    run keyword if   "${alias}"=="${EMPTY}"   connect to k8s master interactively  alias=${alias_new}
    ${vdu_k8s_master_ssh_connection_info}   Get K8s Admin SSH Connection Info
    ${admin_username}  set variable  ${vdu_k8s_master_ssh_connection_info["username"]}
    issh.Execute  command=sudo chmod -R 777 ${folder_name}  check_result=${False}   alias=${alias_new}
    issh.Execute  command=sudo chown -R ${admin_username}:${admin_username} ${folder_name}  check_result=${False}   alias=${alias_new}
vDU Validate Delta Plan Status Should Be Successful
    [Arguments]  ${action_id}   ${plan_id}
    [Documentation]   Validate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ${rtn}  Wait Until Keyword Succeeds  20   2
     ...   _Validate Delta Plan Status Should Be Expected   action_id=${action_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


vDU Full Commission SCF
    [Arguments]  ${scf_file}=${EMPTY}   ${build_number}=${EMPTY}    ${vdu_index}=0    ${gnb_index}=0
    ...    ${connection}=default    ${timeout_commission}=10 min
    [Documentation]   Full Commission SCF On VDU
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   31.07.2020,chris.l.cao@nokia-sbell.com, initialize version
    ...   17.06.2021,chris.l.cao@nokia-sbell.com, change according to no scf file in S3 server
    ...   | Input Parameters   | Man. | Description |
    ...   | scf_file | no | scf_file  |
    ...   | build_number | no | build_number |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | Full Commission SCF On VDU |
    Log    message=\nArgument build_number=${build_number} is not used and will be removed in the future.
    log to console  Full Commission SCF On VDU
    VDU Rest Login    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    vdu.perform_commissioning    scf_file=${scf_file}    timeout=${timeout_commission}    wait_for_completion=${True}    vdu_connection=${connection}
    log to console  Commission SCF file operation finished
    [Teardown]    run keyword and ignore error   vDU Rest Logout


Upload Plan And Validate And Activate
    [Arguments]   ${plan_file}  ${plan_name}=TA_Upload_Plan_And_Validate_And_Activate  ${plan_description}=${EMPTY}  ${wait_vdu_up}=${False}
    ...   ${retries}=1    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   Upload Plan And Validate And Activate
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   13.8.2020,chris.l.cao@nokia-sbell.com, add sleep  8 second between validation and activation
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_file    | yes | plan_file |
    ...   | plan_name    | No | plan_name, default is TA_Upload_Plan_And_Validate_And_Activate |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | wait_vdu_up     | no | wait_vdu_up, if ${True} will wait until VDU up, otherwise it will not, default is ${False} |
    ...   *RETURN VALUE*
    ...    Return <plan_id>   <action_id>    <validation_id>
    ...   Example
    ...  | vdu rest login |
   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
   ...  | ... | wait_vdu_up=${True} |
   ...  | ${plan_id} | ${action_id} | ${validation_id} | Upload Plan And Validate And Activate | plan_file=/home/ute/scf.xml | plan_name=plan_name |
   ...  | ... | wait_vdu_up=${False} |
    log to console  Upload Plan And Validate And Activate
    Log    message=\nArgument wait_vdu_up=${wait_vdu_up} is not used and will be removed in the future.
    ${out}  vdu.Upload Plan   path_to_plan_file=${plan_file}   plan_name=${plan_name}   plan_description=${plan_description}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}

    Upload Plan Status Should Be Successful  operation_id=${temp_action_id}
    sleep   2
    ${temp_validation_id}   Validate Plan By REST  plan_id=${temp_plan_id}   retries=${retries}
    sleep   2
    ${out}   Activate Staged Plan By REST   plan_id=${temp_plan_id}    vdu_index=${vdu_index}    gnb_index=${gnb_index}


    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}
Activate Staged Plan By REST
    [Arguments]  ${plan_id}    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   Activate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...   *RETURN VALUE*
    ...    Activate plan operation information.
    ...   Example
    ...   | VDU Rest Login |
    ...   | Activate Staged Plan By REST | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ${out}   vdu.activate_plan   plan_id=${plan_id}
    ${action_id}  set variable   ${out['id']}

    ${out}   Activate Plan Operation Should Be Successful With Retry
    ...    action_id=${action_id}   plan_id=${plan_id}    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    [Return]  ${out}
Activate Plan Operation Should Be Successful With Retry
    [Arguments]  ${plan_id}  ${action_id}    ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   checking activate plan operation status should be successful
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the activate action id, get from activate_plan |
    ...    *RETURN VALUE*
    ...    None
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    ${rtn}  Wait Until Keyword Succeeds  900   30
     ...   _Activate Plan Operation Status Should Be Expected   plan_id=${plan_id}    operation_id=${action_id}   expected_status=success
     ...    vdu_index=${vdu_index}   gnb_index=${gnb_index}
    [Return]  ${rtn}


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
    should be true    "${r}"=="PASS"

    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

Upload Plan Status Should Be Successful
    [Arguments]  ${operation_id}
    [Documentation]   Upload Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | action_id |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | action_id=<my_action_id> |
     Wait Until Keyword Succeeds  30   3  _Upload Plan Status Should Be Expected   operation_id=${operation_id}    expected_status=success

_Upload Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}
    [Documentation]    Upload Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | _Upload Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success |
    ${out}   vdu.Get_Upload_Plan_Operation_Status   operation_id=${operation_id}
    Should Be True  "${out["status"]}"=="${expected_status}"

Validate Plan By REST
    [Arguments]  ${plan_id}   ${retries}=1
    [Documentation]   Validate Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   *RETURN VALUE*
    ...    Return validation_id
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Validate Plan By REST | plan_id=<my_plan_id> |
    FOR   ${i}    IN RANGE    0   ${retries}
      ${out}  vdu.Validate_Plan   plan_id=${plan_id}
      ${action_id}   Set Variable  ${out["action_id"]}
      ${out}   Validate Plan Status Should Be Successful   operation_id=${action_id}  plan_id=${plan_id}
      ${validation_id}  Set Variable   ${out["validation_id"]}
      sleep   2
    END
    [Return]   ${validation_id}
Validate Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    [Documentation]   Validate Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Upload Plan Status Should Be Successful | operation_id=<my_operation_id> | plan_id=<my_plan_id> |
    ${rtn}  Wait Until Keyword Succeeds  20   3
    ...  _Validate Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}
_Validate Plan Status Should Be Expected
    [Arguments]  ${operation_id}   ${expected_status}   ${plan_id}
    [Documentation]    Validate Plan Status Should Be Expected
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | set variable | sp_7bbfbd44-a3ca-4b22-b948-a0c8a6d3716a |
    ...  | ${out} | vdu.validate_plan | plan_id=${plan_id} |
    ...  | Validate Plan Status Should Be Expected | operation_id=<my_operation_id> | expected_status=success | plan_id=<my_plan_id> |

    ${out}   vdu.Get_Validate_Plan_Operation_Status   operation_id=${operation_id}   plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}


Check Maximum Plan Number And Delete One If Reach Maximum Number
    [Documentation]   Check Maximum Plan Number And delete one if reach Maximum number
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Check Maximum Plan Number And delete one if reach Maximum number |
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}

vDU Generate Delta Plan
    [Arguments]    ${plan_name}  ${plan_description}=${EMPTY}  ${delete_old_one}=${True}
    [Documentation]   vDU Generate Delta Plan
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...   *RETURN VALUE*
    ...    Return (<plan_id>, <action_id>)
    ...   Example
    ...  | vdu rest login |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan | plan_name=my_plan_name |
    run keyword if  "${delete_old_one}"=="${True}"   Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${out}  vdu.Generate_Delta_Plan  plan_name=${plan_name}   plan_description=${plan_description}

    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    Generate Delta Plan Status Should Be Successful  action_id=${temp_action_id}
    [Return]   ${temp_plan_id}   ${temp_action_id}

vDU Update Delta Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...   *RETURN VALUE*
    ...    status dictionary of operation, its content as below,
    ...    {'status': 'success', 'error_message': None, 'revision': '1594282403383843372',
    ...     'links': None, 'action_id': 'a_0b884e65-83a3-445c-a1ff-1fadc26cd767'  }
    ...   Example
    ...  | vdu rest login |
    ...  | ${added_dict} |  create dictionary  | f1SctpProfileIdOfDu=5 | sctpProfile/0/sctpHeartbeatInterval=21 |
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=add |
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1/MNLENT-1/MPLANENW-2 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_delta_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}

    ${action_id}  set variable  ${out["action_id"]}
    ${out}    vDU Update Delta Plan Parameter Should Be Successful   plan_id=${plan_id}   action_id=${action_id}
    [Return]  ${out}

vDU Validate Delta Plan By REST
    [Arguments]  ${plan_id}
    [Documentation]   Validate Delta Plan By REST
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   *RETURN VALUE*
    ...    Return validation_id
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

    ${out}  vdu.Validate_Delta_Plan   delta_plan_id=${plan_id}
    ${action_id}   Set Variable  ${out["action_id"]}
    ${out}    vDU Validate Delta Plan Status Should Be Successful   action_id=${action_id}  plan_id=${plan_id}
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}

vDU Activate Delta Plan By REST
    [Arguments]  ${plan_id}   ${force_reset}=${True}   ${auto_lock_cells}=${True}   ${wait_vdu_up}=${False}   ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...   *RETURN VALUE*
    ...    None
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
    #${temp_path}  Get A Directory  delta_plan
    Log    message=\nArgument wait_vdu_up=${wait_vdu_up} is not used and will be removed in the future.
	${temp_path}    create_a_directory    log_path=${OUTPUT_DIR}    directory_name=delta_plan
    ${tmp_file_id}   get unique id  precise=LOW
    ${delta_scf_fullpath}   vdu.save_delta_plan_file   local_path=${temp_path}   local_filename=${tmp_file_id}.xml
    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}   auto_lock_cells=${auto_lock_cells}   timeout=${timeout}
    vDU Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
#    run keyword if  "${wait_vdu_up}"=="${True}"   wait until keyword succeeds   600  20   OAM Precondition Cell Should Be Onair
vDU Delete Delta Plan By Plan Id
    [Arguments]  ${plan_id}
    [Documentation]   Delete Delta Plan By Plan Id
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id             | yes | delta plan id |
    ...   | force_reset       | no | default is ${True} |
    ...   | auto_lock_cells   | no | default is ${True} |
    ...   | timeout           | no | default is 60 (seconds) |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | VDU Rest Login |
    ...   | Delete Delta Plan By Plan Id | plan_id=my_plan_id |
    ...   | VDU Rest Logout |
    ${out}    vdu.delete_delta_plan_file   plan_id=${plan_id}
    wait until keyword succeeds  60   5   _Make Sure Delta Plan Is Deleted Once

VDU Online Change Parameters By Delta Plan REST
    [Arguments]     ${mo_dn}   ${updated_paras_list}   ${operation}=replace   ${activate}=${True}
    ...   ${force_reset}=${True}   ${auto_lock_cells}=${True}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   VDU Online Change Parameters By Delta Plan REST

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
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...   | VDU Rest Login |
    ...   | ${mo} |  set variable |  MRBTS-5240/NRBTS-1/NRDU-1 |
    ...   | ${added_dict} | create dictionary | f1Cplane/0/ipV4AddressDN1=MRBTS-5240/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1 |
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} |
    ...   | VDU Rest Logout |
    ...   Without activate it:
    ...   | VDU Online Change Parameters By Delta Plan REST | mo_dn=${mo} | updated_paras_list=${added_dict} | activate=${False} |
    ${timeout}   convert to integer  ${timeout}
    VDU Rest Login
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number

    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   vDU Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA

    ${out}   vDU Update Delta Plan Parameter  plan_id=${planid}  mo_dn=${mo_dn}  updated_paras_dict=${updated_paras_list}   operation=${operation}

    ${validation_id}  vDU Validate Delta Plan By REST  plan_id=${planid}

    run keyword if    "${activate}"=="${True}"
    ...    vDU Activate Delta Plan By REST  plan_id=${plan_id}   force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}   timeout=${timeout}    wait_vdu_up=${wait_vdu_up}

	[Teardown]    run keywords
	...   run keyword and ignore error    vDU Delete Delta Plan By Plan Id    plan_id=${plan_id}
	...    AND    VDU Rest Logout


vDU Update Delta Plan Parameter Should Be Successful
    [Arguments]  ${plan_id}   ${action_id}
    [Documentation]   Update Delta Plan Parameter Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Update Delta Plan Parameter Should Be Successful | plan_id=<my_plan_id> | operation_id=<my_operation_id> |
    ${rtn}  wait until keyword succeeds  20   2
    ...   _Update Delta Plan Parameter Should Be Expected   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${rtn}


vDU Activate Delta Plan Status Should Be Successful
    [Arguments]  ${operation_id}   ${plan_id}
    [Documentation]   Activate Delta Plan Status Should Be Successful
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | operation_id    | yes | operation_id |
    ...   | plan_id         | yes | plan_id |
    ...   *RETURN VALUE*
    ...    None
    ...   Example
    ...  | vdu rest login |
    ...  | Activate Delta Plan Status Should Be Successful | action_id=<my_action_id> | plan_id=<my_plan_id> |
    ${rtn}   Wait until keyword succeeds  600  30s
     ...   _Activate Delta Plan Status Should Be Expected   operation_id=${operation_id}    plan_id=${plan_id}   expected_status=success
    [Return]  ${rtn}


Get vDU OAM Ip
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU OAM Ip
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    VDU OAM ip
    ...
    ...    Example
    ...    | ${vdu_oam_ip} | Get vDU OAM Ip |
    ...    | ${vcu_oam_http_connection_info} | Get vDU OAM Ip | vdu_index=1 |
    ...

    ${vdu_oam_http_connection_info}   Get vDU OAM Http Connection Info    gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${vdu_oam_ip}   set variable  ${vdu_oam_http_connection_info["addr"]}

    [Return]  ${vdu_oam_ip}


Get vDU One Click Config Yaml From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]  Get vDU One Click Config Yaml From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Yaml file of vDU One Click Config defined in __init__.py
    ...
    ...    Example
    ...    | ${yaml_file}     | Get vDU One Click Config Yaml From TestLine  |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${yaml_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/cnf_parameters.yaml

    [Return]   ${yaml_file_name}

Get vDU One Click Config Dictionary From TestLine
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    [Documentation]   Get vDU One Click Config Dictionary From TestLine
    ...  author: chris.l.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...   Dictionary of cnf_parameters.yaml . If there is no this file, return {}
    ...
    ...    Example
    ...    | ${conf_dict}     | Get vDU One Click Config Dictionary From TestLine |
    ...
    ${empty_dict}   create dictionary
    ${yaml_file}   Get vDU One Click Config Yaml From TestLine  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${r}   ${dummy}  run keyword and ignore error  OperatingSystem.File Should Exist   ${yaml_file}
    return from keyword if  "${r}"=="FAIL"   ${empty_dict}

    ${dictionary_content}   yaml_file_to_dictionary   ${yaml_file}
    [Return]   ${dictionary_content}

Get Platform Name
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0
    #[Teardown]  run keyword and ignore error    disconnect interactive connection    alias=${alias}
    [Documentation]   Get Platform Name for VDU, which is defined in one click config file
    ...   *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.9.2021,chris.l.cao@nokia-sbell.com, Fail the KW if platform is not NCIR/NCS/OCP
    ...
    ...   | Input Parameters    | Man. | Description |
    ...    | gnb_index     |  No | gnb_index, default value is 0 |
    ...    | vdu_index     |  No | vdu_index, default value is 0 |
    ...
    ...   *RETURN VALUE*
    ...    NCIR or NCS or OCP, otherwise KW fails.
    ...
    ...   Example
    ...   | ${platform} | Get Platform Name |
    ...
    ${conf}   Get vDU One Click Config Dictionary From TestLine  gnb_index=${gnb_index}   vdu_index=${vdu_index}
    ${platform}   set variable if  "NCIR" in "${conf["misc"]["platform_type"]}"    NCIR
     ...   "NCS" in "${conf["misc"]["platform_type"]}"   NCS
     ...   "OCP" in "${conf["misc"]["platform_type"]}"   OCP   UNKNOWN_PLATFORM

    Run Keyword If   "${platform}"=="UNKNOWN_PLATFORM"
         ...   Fail   VDU platform name should be NCIR, NCS, OCP, they are defined in one click config file.

    [Return]  ${platform}

Get Full Pod Name By Pod Abbreviation
    [Arguments]    ${pod_abbr}    ${connection}=default   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get Full Pod Name By Pod Abbrevation
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | pod_abbr          |  Yes | pod name appreviation, eg, oamcp, uprt |
    ...    | connection        | No | connection. Default value is default |
    ...    | vdu_index         | No | vdu_index. Default value is 0 |
    ...
    ...    *RETURN VALUE*
    ...    Full pod name.
    ...
    ...    Example
    ...    | Connect To K8s master |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=oamcp |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=up | vdu_index=0 |
    ...    | ${full_pod_name} | Get Full Pod Name By Pod Abbreviation | pod_abbr=up | vdu_index=0 | connection=myalias |
    ...    | Disconnect From K8s Master |
    ...
    ${ns}   Get vDU Namespace From TestLine   vdu_index=${vdu_index}  gnb_index=${gnb_index}
    ${cmd}   set variable  kubectl get pods -n ${ns}
    ${cmd}   set variable  ${cmd}|egrep "(-${pod_abbr}-)" |awk '{print $1}'
    ${full_pod_name}   tafssh.Execute    command=${cmd}   connection=${connection}
    ${full_pod_name}   Set Variable  ${full_pod_name.strip()}
    [Return]  ${full_pod_name}

_Get Running Build Number NCS
    [Arguments]   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Running Build Number NCS
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${alias}  get unique id
    Connect To K8s Master Interactively   vdu_index=${vdu_index}   alias=${alias}
    ${ns}   get vdu namespace from testline    vdu_index=${vdu_index}
    ${out}  issh.Execute   command=sudo helm3 list -n ${ns}|grep aic-vdu-|grep -v intnet|grep -v rbac|awk '{print $9}'   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}

_Get Running Build Number OCP
    [Arguments]   ${vdu_index}=0
    [Teardown]  run keyword and ignore error  disconnect interactive connection  alias=${alias}
    [Documentation]   _Get Running Build Number OCP
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | _Get Running Build Number OCP |
    ...
    ${alias}  get unique id

    Connect To K8s Master Interactively   vdu_index=${vdu_index}   alias=${alias}
    ${ns}   get vdu namespace from testline    vdu_index=${vdu_index}
    ${out}  issh.Execute   command=helm list -n ${ns}|grep aic-vdu-|grep -v aic-vdu-prerequisite|awk '{print $9}'   alias=${alias}
    ${out}  Strip Prompt  ${out}
    ${build_number}  set variable  ${out.split("-")[-1]}
    [Return]  ${build_number}

Get Running Build Number
    [Arguments]   ${vdu_index}=0
    [Documentation]   Get Running Build Number
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   27.11.2021,chris.l.cao@nokia-sbell.com, remove NCIR platform to shorten dryrun time
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | vdu_index      | No | vdu_index, default is 0 |
    ...
    ...    *RETURN VALUE*
    ...    vdu running build number, e.g, 0.390.928
    ...
    ...    Example
    ...    |  ${build_number}  | Get Running Build Number |
    ...
    ${platform_name}   Get Platform Name

    ${build_number}   run keyword if     "${platform_name}"=="NCS"    _Get Running Build Number NCS   vdu_index=${vdu_index}
    ...   ELSE IF    "${platform_name}"=="OCP"    _Get Running Build Number OCP   vdu_index=${vdu_index}
    ...   ELSE       Fail  Unknown platform name, it should be NCS, OCP, etc.
    [Return]  ${build_number}

All DUs Container Status Should Be Normal
    [Arguments]  ${vdu_index}=0
    [Teardown]  Run Keyword And Ignore Error   fast_disconnect  alias=${alias}
    ${pod_abbr_list}   set variable  ${AIC_VDU_PODS.keys()}
    ${alias}  Get Unique Id
    fast_connect_to_k8s_master   vdu_index=${vdu_index}    alias=${alias}
    FOR   ${pod_abbr}  IN  @{pod_abbr_list}
       vDU Special Pod Status And Container Number Should Be Expected   pod_abbr=${pod_abbr}    status=Running  vdu_index=${vdu_index}
    ...   alias=${alias}
    END

Get vDU Number
    [Arguments]   ${gnb_index}=0
    [Documentation]  Get vDU Number
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vDU_number}  | return vdu number |
    ...
    ...    Example
    ...    | ${vDU_number} | Get vDU Number |
    ...
    ${vDU_number}    get length    ${tl.gnbs[${gnb_index}].dus}
    [Return]    ${vDU_number}

Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Teardown]   run keyword and ignore error  vDU Rest Logout   vdu_index=${vdu_index}
    [Documentation]   Get VCU Cell Number From SCF
    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    *RETURN VALUE*
    ...  Cell number from test line configuration
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    vDU Rest Login   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${tmpid1}   get unique id  precise=LOW  prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}  Get A Directory  ${tmpid1}
    ${tmp_scf_file}  vdu.get_current_plan_file  local_dir_path=${tmp_scf_path}  filename=scf.xml  include_runtime_data=${False}
    ${scf_content}   OperatingSystem.Get File   ${tmp_scf_file}
    ${result}     Get Regexp Matches    ${scf_content}   .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}  Set Variable    ${result.__len__()}
    [Return]   ${cell_number}

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
