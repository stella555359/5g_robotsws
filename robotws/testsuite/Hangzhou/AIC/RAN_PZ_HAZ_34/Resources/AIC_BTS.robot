*** Settings ***
Documentation
...    Author: Yang mengli
...    Email address: mengli.yang@nokia-sbell.com
...    Maintainer: Xiang Liangliang;    Cao Ge
...    Email address: liang.xiang@nokia-sbell.com;    ge.cao@nokia-sbell.com;
...    Common KWs related to some operation of AIC NE.
...    All the bugs/new keyword needs/improvement should be raised in Jira and assign to the Maintainer
...    Jira link: https://jiradc.ext.net.nokia.com/projects/PZ1HAZTA/issues
...    Guideline: https://confluence.ext.net.nokia.com/display/SRANPRODHZHTA/09.+AIC+Common+Resource+Supporting+Mode+Improvement





*** Keywords ***
#---------------------vDU--------------------------------------------------------------------------
Upload New SCF And Validate
    [Arguments]   ${NEW_PLAN_NAME}=plan_new
    [Documentation]    this kw is Upload New SCF And Validate
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Upload New SCF And Validate |
    ...
    Log To Console    Upload New SCF
    vDU Login By Rest    vdu_index=0
    Get Max Plan Number And Delete One If Reach Max Number
    ${scf_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=scf
    ${NEW_SCF}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}    filename=scf.xml
    ...                                        include_runtime_data=${False}
    set test variable   ${NEW_SCF}
    ${PLAN_ID}    ${ACTION_ID}    ${VALIDATION_ID}    Upload And Validate Plan    plan_file=${NEW_SCF}
    ...                                                                         plan_name=${NEW_PLAN_NAME}
    ...                                                                         validate=${True}
    Set Test Variable    ${PLAN_ID}
    Set Test Variable    ${ACTION_ID}
    set test variable    ${VALIDATION_ID}
    [Return]    ${PLAN_ID}    ${ACTION_ID}    ${VALIDATION_ID}
    [Teardown]    vDU Logout By Rest     vdu_index=0


Upload And Validate Plan
    [Arguments]   ${plan_file}  ${plan_name}=plan1  ${validate}=${True}
    [Documentation]   Upload Plan and validate
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
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
    ${out}=    vdu.upload_plan    ${plan_file}    ${plan_name}
    ${temp_plan_id}   Set Variable  ${out["plan_id"]}
    ${temp_action_id}   Set Variable  ${out["action_id"]}
    ${temp_validation_id}   Set Variable  ${EMPTY}
    wait until keyword succeeds    2min    5s    _Check Upload Plan Status Should Be Expected
    ...                                                        ${temp_action_id}
    Return From Keyword If  "${validate}"=="${False}"   ${temp_plan_id}   ${temp_action_id}  ${temp_validation_id}
    ${VALIDATION_ID}    Validate Plan By REST    plan_id=${temp_plan_id}
#    ${validate_plan_response}=    vdu.validate_plan    ${temp_plan_id}
#    ${out}    run keyword and continue on failure    wait until keyword succeeds    2min    5s
#    ...        _Check Validate Plan Status Should Be Expected    ${temp_plan_id}    ${temp_action_id}
    [Return]   ${temp_plan_id}   ${temp_action_id}    ${temp_validation_id}

Get Max Plan Number And Delete One If Reach Max Number
    [Documentation]   this kw is used to Get Max Plan Number And Delete One If Reach Max Number
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | None | NA |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Get Max Plan Number And Delete One If Reach Max Number |
    ...
    ${all_plans}   vdu.Get_Staged_Plans_Info_List
    Should Be True  ${all_plans.__len__()}<=3
    Run Keyword If  ${all_plans.__len__()}==3   Log To Console  ${all_plans[0]["plan_name"]}/${all_plans[0]["plan_id"]} will be deleted!
    Run Keyword If  ${all_plans.__len__()}==3   vdu.Delete_Staged_Plan_File   plan_id=${all_plans[0]["plan_id"]}


Modify Staged Parameters And Revalidate And Activate By Rest
    [Arguments]    ${mo_dn}    ${updated_paras_dict}
    [Documentation]    Modify Staged Parameters And Revalidate
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
    ...   |                      |    | {'drxProfile1/0/drxInactivityTimer':'MRBTS-5460/NRBTS-5460/','para1':'value1'} |
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | Modify Staged Parameters And Revalidate And Activate By Rest |
    ...   | ${mo} |  set variable |  MRBTS-5460/NRBTS-5460/NRDU-1 |
    ...   | ${updated_paras_dict} | create dictionary | drxProfile1/0/drxInactivityTimer=MRBTS-5460/NRBTS-5460/ |

    Log To Console    Modify Staged Parameters And Revalidate And Activate By Rest
    vDU Login By Rest
    ${out}    Update Staged Plan Parameter    plan_id=${PLAN_ID}    mo_dn=${mo_dn}
    ...                                       updated_paras_dict=${updated_paras_dict}
    ...                                       operation=add
    ${VALIDATION_ID}    Validate Plan By REST    plan_id=${PLAN_ID}
    Set test variable    ${VALIDATION_ID}
    Activate Plan By REST    ${PLAN_ID}
    [Teardown]    vDU Logout By Rest    vdu_index=0

Activate Plan By REST
    [Arguments]    ${plan_id}
    ${activate_plan_response}=    vdu.activate_plan    ${plan_id}
    ${action_id}   Set Variable  ${activate_plan_response["id"]}
    sleep    90s    reason=Wait for activate sucessful
    wait until keyword succeeds    10min    20s    _Check Activate Plan Status Should Be Expected
    ...    ${plan_id}
    ...    ${action_id}

Validate Plan By REST
    [Arguments]  ${plan_id}   ${retries}=5
    [Documentation]   this kw is used to Validate Plan By REST
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...
    ...   | Return Value | Description |
    ...   | ${validation_id} | return validation id |
    ...
    ...   Example
    ...  | vdu rest login |
    ...  | ${validation_id} | Validate Plan By REST | plan_id=<my_plan_id> |
    ...
    FOR   ${i}   IN RANGE   0   ${retries}
        ${out}   vdu.Validate_Plan   plan_id=${plan_id}
        ${action_id}   Set Variable  ${out["action_id"]}
        ${out}    run keyword and continue on failure    Wait Until Keyword Succeeds  20   3
        ...           _Check Validate Plan Status Should Be Expected    plan_id=${plan_id}    action_id=${action_id}
    END
    ${validation_id}  Set Variable   ${out["validation_id"]}
    [Return]   ${validation_id}

Update Staged Plan Parameter
    [Arguments]  ${plan_id}   ${mo_dn}   ${updated_paras_dict}  ${operation}=replace  ${mo_uuid}=${None}  ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id    | yes | plan_id |
    ...   | mo_dn      | yes | mo_dn   |
    ...   | updated_paras_dict | yes | updated_paras_dict   |
    ...   | operation          | no | operation: add, replace, remove, revert   |
    ...   | mo_uuid            | no | mo_uuid, default is ${None}  |
    ...   | timeout           | no | timeout, default is 30, unit is second   |
    ...
    ...   | Return Value | Description |
    ...   | ${out} | return this result |
    ...
    ...   Example
    ...  | Update Staged Plan Parameter | ${plan_id} | mo_dn=MRBTS-10766/NRBTS-10766 |
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}   convert to integer  ${timeout}
    ${out}  vdu.update_vdu_parameter_of_staged_plan   plan_id=${plan_id}  mo_dn=${mo_dn}
     ...   updated_paras_dict=${updated_paras_dict}   operation=${operation}   mo_uuid=${mo_uuid}  timeout=${timeout}
    ${action_id}  set variable  ${out["action_id"]}
    ${rtn}   wait until keyword succeeds  20   2   _Update Staged Plan Parameter Should Be Expected
     ...   plan_id=${plan_id}   action_id=${action_id}   expected_status=success
    [Return]  ${out}

_Update Staged Plan Parameter Should Be Expected
    [Arguments]   ${plan_id}   ${action_id}   ${expected_status}
    [Documentation]    _Update Staged Plan Parameter Should Be Expected
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   | Return Value | Description |
    ...   | ${out} | return this result |
    ...
    ...   Example
    ...  | _Update Staged Plan Parameter Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> | expected_status=success |
    ...

    ${out}   vdu.get_update_paras_action_status_of_staged_plan      plan_id=${plan_id}  action_id=${action_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

VDU Online Modify Staged Parameters By Rest
    [Arguments]    ${mo_dn}    ${updated_paras_dict}
    [Documentation]    VDU Online Modify Staged Parameters By Rest
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/NRCELL-1 |
    ...   | updated_paras_list   | yes | parameters values, type is dict,  e.g, |
    ...   |                      |     | {'drxProfile1/0/drxInactivityTimer':'MRBTS-5460/NRBTS-5460/','para1':'value1'} |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | VDU Online Modify Staged Parameters By Rest |
    ...   | ${mo} |  set variable |  MRBTS-5460/NRBTS-5460/NRDU-1 |
    ...   | ${updated_paras_dict} | create dictionary | drxProfile1/0/drxInactivityTimer=MRBTS-5460/NRBTS-5460/ |
    ...
    ${PLAN_ID}    ${ACTION_ID}    ${VALIDATION_ID}    Upload New SCF And Validate
    Set Test Variable    ${PLAN_ID}
    Set Test Variable    ${ACTION_ID}
    set test variable    ${VALIDATION_ID}
    Modify Staged Parameters And Revalidate And Activate By Rest    mo_dn=${mo_dn}
    ...                                                            updated_paras_dict=${updated_paras_dict}
    ...                                                            force_reset=${True}


Get vDU Scf File From Testline Configuration
    [Arguments]  ${gnb_index}=0   ${vdu_index}=0   ${file_name}=vDU_SCF_0.300.xml
    [Documentation]  Get vDU Scf File From Testline Configuration
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...   | Return Value | Description |
    ...   | ${vdu_scf_file_name} |  |
    ...
    ...    Example
    ...    | ${vdu_scf} | Get VDU Scf File From Test Line |
    ...
    ${cfg_dir}     set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.default_cfg_dir}
    ${vdu_scf_file_name}   OperatingSystem.Join Path    ${cfg_dir}
       ...   DEP_SCF_FILES/CU_${gnb_index}/vDU_${vdu_index}/${file_name}
    OperatingSystem.File Should Exist   ${vdu_scf_file_name}
    [Return]   ${vdu_scf_file_name}

Lock RU In vDU
    [Arguments]    ${rmod_id_list}    ${vdu_index}=${0}
    ...            ${restapi_version}=cuoam_21b    ${timeout}=${60}
    [Documentation]  this kw is used to lock cell in vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | restapi_version | yes | define rest api version |
    ...    | rmod_id_list | yes | define rmod list |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock RU In vDU | ${rmod_id_list} | gnb_index=${0} | vdu_index=${0} | restapi_version=cuoam_19b |
    ...
    vDU Login By Rest  restapi_version=${restapi_version}  vdu_index=${vdu_index}
    ${operation_result}    vdu.lock_rmods    rmod_id_list=${rmod_id_list}
    ...           timeout=${timeout}
    [Teardown]  Run keyword and ignore error    vDU Logout By Rest

Unlock RU In vDU
    [Arguments]    ${rmod_id_list}    ${vdu_index}=${0}
    ...            ${restapi_version}=cuoam_21b    ${timeout}=${60}
    [Documentation]  this kw is used to lock cell in vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | restapi_version | yes | define rest api version |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock Cell In vDU | gnb_index=${0} | vdu_index=${0} | restapi_version=cuoam_19b |
    ...
    vDU Login By Rest  restapi_version=${restapi_version}  vdu_index=${vdu_index}
    ${operation_result}    vdu.unlock_rmods    rmod_id_list=${rmod_id_list}
    ...           timeout=${timeout}
    [Teardown]  Run keyword and ignore error    vDU Logout By Rest

Lock RU And Check Status In vDU
    [Arguments]    ${rmod_id_list}
    [Documentation]  this kw is used to Lock RU And Check Status In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock RU And Check Status In vDU | ${rmod_id_list} |
    ...
    FOR    ${ru_id}   IN   @{rmod_id_list}
        wait until keyword succeeds  600s  5s    Check RU Status Should Be As Expected     ru_id=${ru_id}
        ...                                       expected_administrative_state=locked
        ...                                       expected_operational_state=disabled
        ...                                       vdu_index=0
    END

Lock All RU And Check Status In vDU
    [Documentation]  this kw is used to Lock RU And Check Status In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock RU And Check Status In vDU | gnb_index=${0} | vdu_index=${0} |
    ...
    ${rmod_id_list}  Get RMOD ID List
    Lock RU In vDU    rmod_id_list=${rmod_id_list}
    FOR    ${ru_id}   IN   @{rmod_id_list}
        wait until keyword succeeds  600s  5s    Check RU Status Should Be As Expected     ru_id=${ru_id}
        ...                                       expected_administrative_state=locked
        ...                                       expected_operational_state=disabled
        ...                                       vdu_index=0
    END

Lock RU With Ru Id And Check Status In vDU
    [Arguments]    ${rmod_id_list}
    [Documentation]  this kw is used to Lock RU And Check Status In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock RU And Check Status In vDU | gnb_index=${0} | vdu_index=${0} |
    ...
    Lock RU In vDU    rmod_id_list=${rmod_id_list}
    FOR    ${ru_id}   IN   @{rmod_id_list}
        wait until keyword succeeds  600s  5s    Check RU Status Should Be As Expected     ru_id=${ru_id}
        ...                                       expected_administrative_state=locked
        ...                                       expected_operational_state=disabled
        ...                                       vdu_index=0
    END

Get RMOD ID List
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]  this kw is used to get rmod id list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | rmod_id_list | return rmod id list |
    ...
    ...    Example
    ...    | Get RMOD ID List | gnb_index=${0} | vdu_index=${0} |
    ...
    vDU Login By Rest   vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${rmod_id_list}=  create list
    ${rmods_info}=   vdu.get_rmods_status
    FOR  ${rmod}  IN  @{rmods_info}
         append to list   ${rmod_id_list}   ${rmod["id"]}
    END
    log to console  ${rmod_id_list}
    [Return]   ${rmod_id_list}
    [Teardown]  vDU Logout By Rest

Unlock RU And Check Status In vDU
    [Arguments]    ${rmod_id_list}
    [Documentation]  this kw is used to Unlock RU And Check Status In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unlock RU And Check Status In vDU | gnb_index=${0} | vdu_index=${0} |
    ...
    FOR    ${ru_id}   IN   @{rmod_id_list}
        wait until keyword succeeds  600s  5s    Check RU Status Should Be As Expected     ru_id=${ru_id}
        ...                                       expected_administrative_state=unlocked
        ...                                       expected_operational_state=enabled
        ...                                       vdu_index=0
    END


Unlock All RU And Check Status In vDU
    [Documentation]  this kw is used to Unlock RU And Check Status In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unlock RU And Check Status In vDU | gnb_index=${0} | vdu_index=${0} |
    ...
    ${rmod_id_list}  Get RMOD ID List
    Unlock RU In vDU    rmod_id_list=${rmod_id_list}
    FOR    ${ru_id}   IN   @{rmod_id_list}
        wait until keyword succeeds  600s  5s    Check RU Status Should Be As Expected     ru_id=${ru_id}
        ...                                       expected_administrative_state=unlocked
        ...                                       expected_operational_state=enabled
        ...                                       vdu_index=0
    END


Unlock RU With Ru Id And Check Status In vDU
    [Arguments]    ${rmod_id_list}
    [Documentation]  this kw is used to Unlock RU And Check Status In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unlock RU And Check Status In vDU | gnb_index=${0} | vdu_index=${0} |
    ...
    Unlock RU In vDU    rmod_id_list=${rmod_id_list}
    FOR    ${ru_id}   IN   @{rmod_id_list}
        wait until keyword succeeds  600s  5s    Check RU Status Should Be As Expected     ru_id=${ru_id}
        ...                                       expected_administrative_state=unlocked
        ...                                       expected_operational_state=enabled
        ...                                       vdu_index=0
    END


Check RU Status Should Be As Expected
    [Arguments]     ${ru_id}   ${expected_administrative_state}=unlocked
    ...    ${vdu_index}=0
    [Documentation]      Check specified cell status should be as expected.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  expected_administrative_state  | Yes |  Expected administrative state for cell  |
    ...	   |  expected_operational_state  | Yes |  Expected operational state for cell |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...    *RETURN VALUE*
    ...    None
    ...    Example
    ...    | Check RU Status Should Be As Expected  |  123  |   locked  |  disabled  | 0 |
    ${ru_administrativeState}  ${ru_operationalState}=    Get Specified RU Status In vDU   ${ru_id}  ${vdu_index}
    run keyword and continue on failure    should be true     "${ru_administrativeState}"=="${expected_administrative_state}"
    ...    Administrative state of ru ${ru_id} is not ${expected_administrative_state}!


Get Specified RU Status In vDU
   [Arguments]   ${ru_id}=${1}    ${vdu_index}=${0}
   [Documentation]      Get cell administrative state and operational state  by cell id.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | ru_id  | Yes |  ru_id  |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | administrativeState,operationalState | return administrativeState and operationalState |
    ...
    ...    Example
    ...    | ${cell_administrativeState}  ${cell_operationalState}= | Get Specified RU Status In vDU  | 111  | 0 |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${ru_info}=  vdu.get_rmods_status
    FOR    ${ru_info}    IN    @{ru_info}
      ${administrative_state}=    Convert To Lowercase   ${ru_info["administrative_state"]}
      ${operational_state}=    Convert To Lowercase     ${ru_info["operational_state"]}
       Return From Keyword If    '${ru_info["id"]}' == '${ru_id}'     ${administrative_state}    ${operational_state}
    END
   [Teardown]   Run keyword and ignore error    vDU Logout By Rest

Verify All RU Status In vDU
   [Arguments]      ${vdu_index}=${0}
   [Documentation]      Verify All RU Status should be normal
    ...    Author: Xiang Liang
    ...    Contact: liang.xiang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify All RU Status In vDU | vdu_index=${0} |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${ru_info}=  vdu.get_rmods_status
    FOR    ${ru_info}    IN    @{ru_info}
        ${administrative_state}=    Convert To Lowercase   ${ru_info["administrative_state"]}
        ${operational_state}=    Convert To Lowercase     ${ru_info["operational_state"]}
        Should Be Equal    ${administrative_state}    unlocked
        Should Be Equal    ${operational_state}    enabled
    END
   [Teardown]   Run Keyword And Ignore Error    vDU Logout By Rest

Verify RU State For Truck Roll
   [Arguments]    ${gnb_index}=${0}
   [Documentation]      Verify RU State in multi vDUs For Truck Roll
    ...    Author: Xiang Liang
    ...    Contact: liang.xiang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify RU State For Truck Roll | gnb_index=${0} |
    ...
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${du_number}
        Verify All RU Status In vDU    vdu_index=${i}
    END

Judge Whether The Parameter Needs To Be Modified
    [Arguments]    ${mo_dn}    ${mo_parameter_dict}    ${gnb_index}=${0}
    [Documentation]    Judge Whether The Parameter Needs To Be Modified
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/ |
    ...    | updated_paras_list | yes | parameters values, type is dict,  e.g, |
    ...    | ...                |     | {'drxProfile1/0/drxInactivityTimer':'MRBTS-5460/NRBTS-5460/','para1':'value1'} |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Judge Whether The Parameter Needs To Be Modified |
    ...    | ${mo} |  set variable |  MRBTS-5460/NRBTS-5460/NRDU-1 |
    ...    | ${mo_parameter_dict} | create dictionary | drxProfile1/0/drxInactivityTimer=MRBTS-5460/NRBTS-5460/NRCELL-1 |
    ...
    vDU Login By Rest    gnb_index=${gnb_index}
    &{parameter_dict}    Create Dictionary
    FOR    ${para_name}    IN    @{mo_parameter_dict}
        ${value}=    Online Get VDU Parameter Value     ${mo_dn}    ${para_name}
        run keyword if    "${value}" != "${mo_parameter_dict}[${para_name}]"
        ...    Set to Dictionary    ${parameter_dict}    ${para_name}    ${value}
    END
    [Return]    &{parameter_dict}
    [Teardown]    vDU Logout By Rest    vdu_index=0


Judge Whether The Mo Is Exist
    [Arguments]    ${mo_dn}    ${para_name}    ${gnb_index}=${0}
    [Documentation]    Judge Whether The Parameter Needs To Be Modified
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | mo_dn                | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/ |
    ...    | updated_paras_list | yes | parameters values, type is dict,  e.g, |
    ...    | ...                |     | {'drxProfile1/0/drxInactivityTimer':'MRBTS-5460/NRBTS-5460/','para1':'value1'} |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Judge Whether The Parameter Needs To Be Modified |
    ...    | ${mo} |  set variable |  MRBTS-5460/NRBTS-5460/NRDU-1 |
    ...    | ${mo_parameter_dict} | create dictionary | drxProfile1/0/drxInactivityTimer=MRBTS-5460/NRBTS-5460/NRCELL-1 |
    ...
    vDU Login By Rest    gnb_index=${gnb_index}
#    ${mo_exist}    Set Variable    false
    ${value}=    Online Get VDU Parameter Value     ${mo_dn}    ${para_name}
    ${value_length}    get length   ${value}
    ${mo_exist}    run keyword if   ${value_length}>=1    Set Variable    true
    [Return]    ${mo_exist}
    [Teardown]    vDU Logout By Rest    vdu_index=0


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
    ${plan_id}    ${action_id}    Generate Delta Plan In vDU    plan_name=${delta_plan_name}    plan_description=TA
    ${out}    Update Parameter By Delta Plan In vDU    plan_id=${planid}    mo_dn=${mo_dn}
    ...                 updated_paras_dict=${updated_paras_list}    operation=${operation}
    ${validation_id}    Validate Delta Plan By REST In vDU    plan_id=${planid}
    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST In vDU    plan_id=${plan_id}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}    wait_vdu_up=${wait_vdu_up}

vDU Online Create MO Via Rest
    [Arguments]    ${mo_name}=com.nokia.srbts.nrbts:SERVEDAMF    ${delta_plan_name}=delta_plan
    ...            ${mo_dn}=MRBTS-5460/NRBTS-5460
    [Documentation]    vDU Online Create MO Via Rest.
    ...    Author: Cao Ge
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Create Mo | Man. | Description |
    ...    | mo_name | yes | add mo_name |
    ...    | mo_dn | yes | mo dist name |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Online Create MO Via Rest | mo_name=SNSSAI-4 |
    ...    | ...                           | mo_dn= {mo_dn} |
    ...
    vDU Login By Rest
    ${all_plans}    vdu.Get_Delta_Plan_Info_List
    Run Keyword If    ${all_plans.__len__()}==1
    ...               Delete Delta Plan By Plan Id In vDU    plan_id=${all_plans[0]["plan_id"]}
    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
    ${out}    vdu.Generate_Delta_Plan    plan_name=${delta_plan_name}    plan_description=TA
    ${delta_plan_id}    Set Variable    ${out["plan_id"]}
    ${temp_action_id}    Set Variable    ${out["action_id"]}
    Wait Until Keyword Succeeds    30    3    _Check Delta Plan Status Should Be Expected    action_id=${temp_action_id}
    ...                                                                                expected_status=success
    ${plans}    vdu.Get_Delta_Plan_Info_List
    ${create_res}=   vdu.create_vdu_object_of_delta_plan   delta_plan_id=${plans[0]["plan_id"]}   parent_mo_dn=${mo_dn}
    ...  	mo_name=${mo_name}
    ${res}    run keyword and continue on failure  Wait until keyword succeeds  10x  60s
    ...                                     vdu.get_create_vdu_object_action_status_of_delta_plan
    ...                                     plan_id=${delta_plan_id}  action_id=${create_res['action_id']}
    should be equal as strings  ${res['status']}  success
    [Return]    ${delta_plan_id}


vDU Online Create MO With Modify Parameter Via Rest
    [Arguments]   ${updated_paras_dict}    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}    ${mo_dn1}=MRBTS-${MRBTS_ID}
    ...           ${mo_name}=SWRESETREQ-1    ${operation}=replace     ${activate}=${True}
    ...           ${force_reset}=${True}    ${auto_lock_cells}=${False}    ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   vDU Online Create MO With Modify Parameter Via Rest
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | vDU Online Create MO With Modify Parameter Via Rest |  ${updated_paras_dict} |
    ...
    ${delta_plan_id}    vDU Online Create MO Via Rest    mo_name=${mo_name}    mo_dn=${mo_dn}
    ${out}    Update Parameter By Delta Plan In vDU    plan_id=${delta_plan_id}    mo_dn=${mo_dn1}
    ...                 updated_paras_dict=${updated_paras_dict}    operation=${operation}
    ${validation_id}    Validate Delta Plan By REST In vDU    plan_id=${delta_plan_id}
    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST In vDU    plan_id=${delta_plan_id}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}    wait_vdu_up=${wait_vdu_up}
    [Teardown]   run keyword and ignore error  vDU Logout By Rest   vdu_index=${0}

vDU Online Delete MO Via Rest
    [Arguments]    ${mo_dn}=MRBTS-${MRBTS_ID}
    ...           ${activate}=${True}
    ...           ${force_reset}=${True}    ${auto_lock_cells}=${True}    ${wait_vdu_up}=${True}    ${timeout}=60
    [Documentation]    vDU Online Delete MO Via Rest.
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Online Delete MO Via Rest | mo_dn={mo_dn} |
    ...
    vDU Login By Rest
    ${all_plans}    vdu.Get_Delta_Plan_Info_List
    Run Keyword If    ${all_plans.__len__()}==1
    ...               Delete Delta Plan By Plan Id In vDU    plan_id=${all_plans[0]["plan_id"]}
    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
    ${out}    vdu.Generate_Delta_Plan    plan_name=${delta_plan_name}    plan_description=TA
    ${delta_plan_id}    Set Variable    ${out["plan_id"]}
    ${temp_action_id}    Set Variable    ${out["action_id"]}
    Wait Until Keyword Succeeds    30    3    _Check Delta Plan Status Should Be Expected    action_id=${temp_action_id}
    ...                                                                                expected_status=success
    ${plans}    vdu.Get_Delta_Plan_Info_List
    ${create_res}=   vdu.delete_mo_of_delta_plan   delta_plan_id=${plans[0]["plan_id"]}   mo_dn=${mo_dn}
    ${res}    run keyword and continue on failure  Wait until keyword succeeds  5x  60s
    ...                                     vdu.get_deleting_mo_action_state_of_delta_plan
    ...                                     delta_plan_id=${delta_plan_id}  action_id=${create_res['action_id']}
    should be equal as strings  ${res['status']}  success
    ${validation_id}    Validate Delta Plan By REST In vDU    plan_id=${delta_plan_id}
    run keyword if    "${activate}"=="${True}"
    ...    Activate Delta Plan By REST In vDU    plan_id=${delta_plan_id}    force_reset=${force_reset}
    ...    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}    wait_vdu_up=${wait_vdu_up}
    [Return]    ${delta_plan_id}
    [Teardown]   run keyword and ignore error  vDU Logout By Rest   vdu_index=${0}

Activate Delta Plan By REST In vDU
    [Arguments]    ${plan_id}    ${force_reset}=${True}    ${auto_lock_cells}=${True}
    ...            ${wait_vdu_up}=${False}    ${timeout}=60
    [Documentation]   Activate Delta Plan By REST
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id          | yes | delta plan id |
    ...   | force_reset      | no | default is ${True} |
    ...   | auto_lock_cells  | no | default is ${True} |
    ...   | wait_vdu_up      | no | if ${True}, will wait for VDU on-air, default is ${False} |
    ...   | timeout          | no | default is 60 (seconds) |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | Activate Delta Plan By REST In vDU |  ${plan_id} |
    ...
    ${temp_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=delta_plan
    ${tmp_file_id}    get unique id    precise=LOW
    ${delta_scf_fullpath}    vdu.save_delta_plan_file    local_path=${temp_path}    local_filename=${tmp_file_id}.xml
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
     ...   force_reset=${force_reset}    auto_lock_cells=${auto_lock_cells}    timeout=${timeout}
    ${rtn}    Wait until keyword succeeds    600    30s
     ...   _Check Activate Delta Plan Status Should Be Expected    operation_id=${out['id']}    plan_id=${plan_id}
     ...                                                        expected_status=success
    Run keyword if    "${wait_vdu_up}"=="${True}"    wait until keyword succeeds    600    20
    ...                                            vDU Check All Cells Status Should Be Onair For All DUs

vDU Check All Cells Status Should Be Onair For All DUs
    [Arguments]    ${gnb_index}=${0}
    [Documentation]    vDU Check All Cells Status Should Be Onair For All DUs
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | Yes. | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Check All Cells Status Should Be Onair For All DUs |
    ...
    ${du_number}    Get vDU Number    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${du_number}
        vDU Check All Cells Status Should Be Onair    vdu_index=${i}    gnb_index=${gnb_index}
    END

vDU Check All Cells Status Should Be Onair
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]    vDU Verify Cells Status Should Be Onair With Expected Cell Number
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...    | gnb_index | No. | specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Verify Cells Status Should Be Onair With Expected Cell Number |
    ...
    ${cell_number}    Get VDU Cell Number From SCF    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${alias}=    get unique id
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}    alias=${alias}
    ${vdu_cells_summary}=    vdu.get_vdu_cells_summary    vdu_connection=${alias}
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['operational_state']['disabled']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['locked']}    0
    Should Be Equal As Numbers    ${vdu_cells_summary['basic_cells_summary']['administrative_state']['shutting_down']}  0
    ${on_line}    set variable    ${vdu_cells_summary['availability_status']['on_line']}
    should be true    ${on_line}==${cell_number}
    [Teardown]  vdu.disconnect    ${alias}

Get VDU Cell Number From SCF
    [Arguments]  ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   Get VCU Cell Number From SCF
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index | no | gnb index to indicate which gnb will be used, default is 0  |
    ...
    ...    | Return Value | Description |
    ...    | ${cell_number} | return cell number |
    ...
    ...    Example
    ...    | ${cell_number} | Get VCU Cell Number From TestLine |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${tmpid1}    get unique id    precise=LOW    prefix=Get_VDU_Cell_Number_From_SCF
    ${tmp_scf_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=${tmpid1}
    ${tmp_scf_file}    vdu.get_current_plan_file    local_dir_path=${tmp_scf_path}   filename=scf.xml  include_runtime_data=${False}
    ${scf_content}    OperatingSystem.Get File    ${tmp_scf_file}
    ${result}    Get Regexp Matches    ${scf_content}    .*NRCELL"\\s+distName="MRBTS-(\\d+)/NRBTS-(\\d+)/NRCELL-(\\d+)"\\s+.*   3
    ${cell_number}    Set Variable    ${result.__len__()}
    [Return]   ${cell_number}
    [Teardown]   run keyword and ignore error  vDU Logout By Rest   vdu_index=${vdu_index}

_Check Activate Delta Plan Status Should Be Expected
    [Arguments]    ${operation_id}    ${plan_id}    ${expected_status}
    ${out}    vdu.Get_Activate_Delta_Plan_Operation_Status    operation_id=${operation_id}    delta_plan_id=${plan_id}
    Should Be True  "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

_Check Activate Plan Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}
    ${activate_plan_response}=    vdu.get_activate_plan_operation_status    ${plan_id}    ${action_id}
    should be equal as strings    ${activate_plan_response['status']}    success

Validate Delta Plan By REST In vDU
    [Arguments]    ${plan_id}
    [Documentation]    Validate Delta Plan By REST
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters | Man. | Description |
    ...   | plan_id  | yes | plan_id |
    ...
    ...   | Return Value | Description |
    ...   | validation_id | Return validation_id |
    ...
    ...   Example
    ...   | Validate Delta Plan By REST In vDU | ${plan_id} |
    ...
    ${out}    vdu.Validate_Delta_Plan    delta_plan_id=${plan_id}
    ${action_id}    Set Variable    ${out["action_id"]}
    ${rtn}    Wait Until Keyword Succeeds    20    2
    ...   _Check Validate Delta Plan Status Should Be Expected    action_id=${action_id}    plan_id=${plan_id}
    ...                                                           expected_status=success
    ${validation_id}  Set Variable   ${rtn["validation_id"]}
    ${errors}  vdu.get_delta_plan_validation_results   plan_id=${plan_id}  validation_id=${validation_id}
    ${error_num}  Set Variable  ${errors["total"]}
    should be true    ${error_num}<=0
    [Return]    ${validation_id}

_Check Validate Delta Plan Status Should Be Expected
    [Arguments]    ${action_id}    ${expected_status}    ${plan_id}
    ${out}    vdu.Get_Validate_Delta_Plan_Operation_Status    action_id=${action_id}    delta_plan_id=${plan_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

Generate Delta Plan In vDU
    [Arguments]    ${plan_name}    ${plan_description}=${EMPTY}
    [Documentation]   Generate Delta Plan In vDU
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_name    | yes | plan_name |
    ...   | plan_description | no | plan_description, default is ${EMPTY} |
    ...   | delete_old_one   | no | delete_old_one , if ${true}, old delta plan will be deleted, default is ${True} |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | vDU Login By Rest |
    ...  | ${plan_id} | ${action_id} | Generate Delta Plan In vDU | plan_name=my_plan_name |
    ...
    Get Delta Plan Number And Delete One If Reach Max Number
    ${out}    vdu.Generate_Delta_Plan    plan_name=${plan_name}    plan_description=${plan_description}
    ${temp_plan_id}    Set Variable    ${out["plan_id"]}
    ${temp_action_id}    Set Variable    ${out["action_id"]}
    Wait Until Keyword Succeeds    30    3    _Check Delta Plan Status Should Be Expected    action_id=${temp_action_id}
    ...                                                                                expected_status=success
    [Return]    ${temp_plan_id}    ${temp_action_id}

Update Parameter By Delta Plan In vDU
    [Arguments]    ${plan_id}    ${mo_dn}    ${updated_paras_dict}    ${operation}=replace
    ...            ${mo_uuid}=${None}    ${timeout}=30
    [Documentation]   Update Staged Plan Parameter, it support multiple parameters change for one MO
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
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
    ...  | ${validation_id} | Update Delta Plan Parameter | plan_id=<my_plan_id> | mo_dn=MRBTS-5240/MNL-1|
    ...  | ... | updated_paras_dict=${added_dict} | operation=replace |
    ...
    ${timeout}    convert to integer    ${timeout}
    ${out}    vdu.update_vdu_parameter_of_delta_plan    plan_id=${plan_id}    mo_dn=${mo_dn}
     ...    updated_paras_dict=${updated_paras_dict}    operation=${operation}    mo_uuid=${mo_uuid}
     ...    timeout=${timeout}
    ${action_id}    set variable    ${out["action_id"]}
    ${rtn}    wait until keyword succeeds    20    2
    ...   _Check Delta Plan Parameter Should Be Expected    plan_id=${plan_id}    action_id=${action_id}
    ...   expected_status=success
    [Return]  ${out}

_Check Delta Plan Parameter Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}    ${expected_status}
    [Documentation]    _Update Delta Plan Parameter Should Be Expected
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | expected_status | yes | expected_status |
    ...   | plan_id         | yes | plan_id |
    ...   | action_id    | yes | action_id |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | vDU Login By Rest |
    ...  | Validate Plan Status Should Be Expected | plan_id=<my_plan_id> | action_id=<my_action_id> |
    ...  | ...                                     | expected_status=success |
    ...
    ${out}    vdu.get_update_paras_action_status_of_delta_plan    plan_id=${plan_id}    action_id=${action_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]  ${out}

_Check Delta Plan Status Should Be Expected
    [Arguments]    ${action_id}    ${expected_status}
    [Documentation]   this kw is used to Generate Delta Status Should Be Expected
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | action_id       | yes | operation_id |
    ...   | expected_status | yes | expected_status |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | _Check Delta Plan Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...
    ${out}    vdu.Get_Delta_Plan_Generated_Action_Status    action_id=${action_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Upload Plan Status Should Be Expected
    [Arguments]    ${upload_action_id}
    [Documentation]    checking upload plan operation status should be successful
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | _Check Upload Plan Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...
    ${upload_operation_response}=    vdu.get_upload_plan_operation_status    ${upload_action_id}
    should be equal as strings    ${upload_operation_response['status']}    success

_Check Validate Plan Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from validate_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | _Check Validate Plan Status Should Be Expected | action_id=<my_operation_id> | expected_status=success |
    ...
    ${validate_plan_response}=    vdu.get_validate_plan_operation_status    ${plan_id}    ${action_id}
    should be equal as strings    ${validate_plan_response['status']}    success
    [Return]    ${validate_plan_response}

Fix Errors and Get Plan Validation Result
    [Arguments]    ${plan_id}
    [Documentation]   fix errors and get plan validation result
    ...    Author: sudi lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...
    ...    | Return Value | Description |
    ...    | errors | the result of staged plan validation |
    ...
    ...   Example
    ...  | Fix Errors and Get Plan Validation Result | plan_id=<my_plan_id>|
    ...
    ${fix_error_response}=    vdu.fix_vdu_staged_plan_error    stage_plan_id=${plan_id}
    ${action_id}    Set Variable    ${fix_error_response['action_id']}
    wait until keyword succeeds    2min    5s    _Check Fix Errors Status Should Be Expected
    ...                                          ${plan_id}    ${action_id}

    ${validate_plan_response}=    vdu.validate_plan    ${plan_id}
    ${action_id}    Set Variable    ${validate_plan_response['action_id']}
    ${validate_plan_response}=    wait until keyword succeeds    2min    5s    _Check Validate Plan Status Should Be Expected
    ...                                          ${plan_id}    ${action_id}

    ${validation_id}    Set Variable    ${validate_plan_response['validation_id']}
    ${errors}=    vdu.get_staged_plan_validation_results
    ...           ${plan_id}    ${validation_id}
    [Return]    ${errors}

_Check Fix Errors Status Should Be Expected
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]   checking fix errors operation status should be successful
    ...    Author: sudi lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | the plan file id, get from upload_plan |
    ...    | action_id | Yes | the validate action id, get from fix_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | _Check Fix Errors Status Should Be Expected | plan_id=<my_plan_id>| action_id=<my_operation_id>|
    ...
    ${fix_error_response}=    vdu.get_fix_vdu_staged_plan_operation_status    ${plan_id}    ${action_id}
    should be equal as strings    ${fix_error_response['status']}    success
    [Return]    ${fix_error_response}

Get Delta Plan Number And Delete One If Reach Max Number
    [Documentation]    Check Maximum Delta Plan Number And delete one if reach Maximum number
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...  | vDU Login By Rest |
    ...  | Check Maximum Delta Plan Number And delete one if reach Maximum number |
    ...
    ${all_plans}    vdu.Get_Delta_Plan_Info_List
    Should Be True    ${all_plans.__len__()}<=1
    Run Keyword If    ${all_plans.__len__()}==1    Delete Delta Plan By Plan Id In vDU    plan_id=${all_plans[0]["plan_id"]}

Delete Delta Plan By Plan Id In vDU
    [Arguments]    ${plan_id}
    [Documentation]    Delete Delta Plan By Plan Id In vDU
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   | plan_id            | yes | delta plan id |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...   Example
    ...   | Delete Delta Plan By Plan Id In vDU | plan_id=my_plan_id |
    ...
    ${out}    vdu.delete_delta_plan_file    plan_id=${plan_id}
    log to console    ${out}
    print a dictionary    ${out}
    wait until keyword succeeds    60    5    _Make Sure Delta Plan Is Deleted In vDU

Print A Dictionary
    [Arguments]  ${one_dict}
    [Documentation]   Print A Dictionary's keys/values
    ...   Author: mengli yang
    ...   Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | one_dict | yes | print a dictionary |
    ...
    ...   | Return Value | Description |
    ...   | None | NA |
    ...
    ...    Example
    ...    | Print A Dictionary | ${my_dict_var} |
    ...
    ${debug_flag}    Set Variable    1
    Return From Keyword If    ${debug_flag}!=1
    Evaluate    pprint.pprint(${one_dict})    modules=pprint

_Make Sure Delta Plan Is Deleted In vDU
    ${all_plans}    vdu.Get_Delta_Plan_Info_List
    Should Be True    ${all_plans.__len__()}==0

vDU Update Full SCF By Rest
    [Arguments]    ${scf_path}    ${restapi_version}=cuoam_21b    ${vdu_index}=0    ${fix_errors}=false
    [Documentation]   send commission on one vdu, including upload validate and activate scf
    ...    Author: mengli yang
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | scf_path | yes | scf file with absolute path, it's vDU scf file. |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Update Full SCF By Rest | scf_path=${NEW_SCF} | restapi_version=cuoam_21b | vdu_index=0 |
    ...
    log to console    \n*** start send commission on vdu ***
    vDU Login By Rest    ${restapi_version}    ${vdu_index}
    ${upload_plan_response}=    vdu.upload_plan    ${scf_path}
    wait until keyword succeeds    2min    5s    _Check Upload Plan Status Should Be Expected
    ...                                                        ${upload_plan_response['action_id']}
    ${validate_plan_response}=    vdu.validate_plan    ${upload_plan_response['plan_id']}
    ${validate_plan_response}=    wait until keyword succeeds    2min    5s    _Check Validate Plan Status Should Be Expected
    ...                           ${upload_plan_response['plan_id']}
    ...                           ${validate_plan_response['action_id']}

    ${errors}=    vdu.get_staged_plan_validation_results
    ...           ${upload_plan_response['plan_id']}
    ...           ${validate_plan_response['validation_id']}

    ${errors}=    Run Keyword If    ${errors['total']}>0 and '${fix_errors}'=='true'
        ...           Fix Errors and Get Plan Validation Result
        ...                            ${upload_plan_response['plan_id']}
    ...    ELSE
        ...     Set Variable     ${errors}

    Should Be True    ${errors['total']}==0

    ${activate_plan_response}=    vdu.activate_plan    ${upload_plan_response['plan_id']}
    sleep    90s    reason=Wait for activate sucessful
    wait until keyword succeeds    10min    20s    _Check Activate Plan Status Should Be Expected
    ...    ${upload_plan_response['plan_id']}
    ...    ${activate_plan_response['id']}
    [Teardown]    vDU Logout By Rest

Get vDU Version
    [Documentation]    Get vDU Version by rest api and return the vDU version
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  None  |  NO  |  NA  |
    ...
    ...    | Return Value | Description |
    ...    | ${vdu_version} | return vdu version |
    ...
    ...    Example
    ...    |  Get VDU version |
    vDU Login By Rest
    ${vdu_data}=    get_vdu_state_data
    ${vdu_version}    set variable    ${vdu_data['software_version']}
    [Return]    ${vdu_version}
    [Teardown]    vDU Logout By Rest

Lock Cell In vDU
    [Arguments]    ${cell_id_list}    ${vdu_index}=${0}
    ...            ${restapi_version}=cuoam_21b
    [Documentation]  this kw is used to lock cell in vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | restapi_version | yes | define rest api version |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock Cell In vDU | gnb_index=${0} | vdu_index=${0} | restapi_version=cuoam_19b |
    ...
    vDU Login By Rest    restapi_version=${restapi_version}    vdu_index=${vdu_index}
    ${out}    vdu.lock_cells    ${cell_id_list}
    sleep    120s    reason=Wait for lock cell sucessful
    ${cell_numbel}    Get Length    ${cell_id_list}
    FOR    ${index}    IN RANGE    ${cell_numbel}
        Set test variable    ${cell_id}    ${cell_id_list[${index}]}
        wait until keyword succeeds    60s    5s    Check Specified Cell Status Should Be As Expected In vDU
        ...      cell_id=${cell_id}
        ...      expected_administrative_state=locked
        ...      expected_operational_state=disabled
        ...      vdu_index=${vdu_index}
    END
    [Teardown]    Run keyword and ignore error    vDU Logout By Rest


Get Cell ID List
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  this kw is used to get Cell ID List
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Cell ID List | gnb_index=${0} | vdu_index=${0} |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_id_list}=    create list
    ${cell_info}=    vdu.get_vdu_cells_status
    FOR    ${cell}    IN    @{cell_info}
        append to list    ${cell_id_list}    ${cell["id"]}
    END
    log to console    ${cell_id_list}
    [Return]    ${cell_id_list}
    [Teardown]    vDU Logout By Rest

Get NR Cell Identity Dict
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]  this kw is used to get NR Cell Identity Dict
    ...    Author: Lou Sudi
    ...    Contact: sudi.lou@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get NR Cell Identity Dict | gnb_index=${0} | vdu_index=${0} |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    &{nr_cell_identity_dict}=    Create Dictionary
    ${cell_info}=    vdu.get_vdu_cells_status
    FOR    ${cell}    IN    @{cell_info}
        Set To Dictionary    ${nr_cell_identity_dict}    ${cell["name"]}=${cell["nr_cell_identity"]}
    END
    log to console    ${nr_cell_identity_dict}
    [Return]    ${nr_cell_identity_dict}
    [Teardown]    vDU Logout By Rest

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

Get vCU Number
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
    ${vCU_number}    get length    ${tl.gnbs}
    [Return]    ${vCU_number}

Unlock Cell In vDU
    [Arguments]    ${cell_id_list}    ${vdu_index}=${0}
    ...            ${restapi_version}=cuoam_21b
    [Documentation]  this kw is used to unlock cell in vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | restapi_version | yes | define rest api version |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unlock Cell In vDU | gnb_index=${0} | vdu_index=${0} | restapi_version=cuoam_19b |
    ...
    vDU Login By Rest    restapi_version=${restapi_version}    vdu_index=${vdu_index}
    ${out}    vdu.unlock_cells    ${cell_id_list}
    sleep    120s    reason=Wait for unlock cell sucessful
    ${cell_numbel}    Get Length    ${cell_id_list}
    FOR    ${index}    IN RANGE    ${cell_numbel}
      Set test variable    ${cell_id}    ${cell_id_list[${index}]}
      wait until keyword succeeds    180s    10s    Check Specified Cell Status Should Be As Expected In vDU
      ...      cell_id=${cell_id}
      ...      expected_administrative_state=unlocked
      ...      expected_operational_state=enabled
      ...      vdu_index=${vdu_index}
    END
    [Teardown]    Run keyword and ignore error    vDU Logout By Rest

Check Specified Cell Status Should Be As Expected In vDU
    [Arguments]    ${cell_id}    ${expected_administrative_state}=unlocked
    ...    ${expected_operational_state}=enabled    ${vdu_index}=0
    [Documentation]      this kw is used to Check specified cell status should be as expected.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...	   |  expected_administrative_state  | Yes |  Expected administrative state for cell  |
    ...	   |  expected_operational_state  | Yes |  Expected operational state for cell |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Check Cell Status Should Be As Expected  |  123  |   locked  |  disabled  | 0 |
    ...
    ${cell_administrativeState}  ${cell_operationalState}=    vDU Get Specified Cell Status   ${cell_id}  ${vdu_index}
    run keyword and continue on failure    should be true     "${cell_administrativeState}"=="${expected_administrative_state}"
    ...    Administrative state of cell ${cell_id} is not ${expected_administrative_state}!
    run keyword and continue on failure    should be true     "${cell_operationalState}"=="${expected_operational_state}"
    ...    Operational state of cell ${cell_id} is not ${expected_operational_state}!

vDU Get Specified Cell Status
   [Arguments]    ${cell_id}    ${vdu_index}=0
   [Documentation]    this kw is used to Get cell administrative state and operational state by cell id.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   |  cell_id  | Yes |  cell id   |
    ...    | vdu_index | Yes. |specify which vdu needs to be check if the testline configed multi vdus |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  ${cell_administrativeState}  ${cell_operationalState}= |  CU Get Specified Cell Status  |  111  |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${cells_info}=  vdu.get_vdu_cells_status
   FOR    ${cell_info}    IN    @{cells_info}
     ${administrative_state}=    Convert To Lowercase   ${cell_info["administrative_state"]}
     ${operational_state}=    Convert To Lowercase     ${cell_info["operational_state"]}
      Return From Keyword If    '${cell_info["id"]}' == '${cell_id}'     ${administrative_state}    ${operational_state}
    END
   [Teardown]   vDU Logout By Rest

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

vDU Backup SCF From Test Line
    [Arguments]    ${scf_file_name}=scf_backup.xml    ${vdu_index}=0
    [Documentation]  this kw is used to vDU Backup SCF From Test Line
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | scf_file_name | yes | define scf file name |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Backup SCF From Test Line | scf_file_name=scf_backup.xml | vdu_index=${0} |
    ...
    log to console  *** Backup SCF From Test Line Before Case Excution ***
    vDU Login By Rest    vdu_index=${vdu_index}
    ${backup_scf_path}    basic.create_a_directory    log_path=${TEST_LOG_DIRECTORY}    directory_name=backup_scf
    ${backup_scf_file}=    vdu.get_current_plan_file    local_dir_path=${backup_scf_path}    filename=${scf_file_name}
    ...                                                include_runtime_data=${False}
    [Return]    ${backup_scf_file}
    [Teardown]    vDU Logout By Rest

Check Expected Alarms Is Appear
    [Arguments]  ${vdu_index}=0    ${expected_fault_id}=49
    [Documentation]  this kw is used to Check Expected Alarms Appear
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...    | expected_fault_id  | no | define expected fault id|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check Expected Alarms Appear | vdu_index=0 | expected_fault_id=49 |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_active_alarms
    ${output_lenth}=    set variable    ${out['total']}
    ${status}=   set variable   False
    FOR    ${index}    IN RANGE    ${output_lenth}
        ${fault_id}    Set Variable    ${out['alarms'][${index}]['fault_id']}
        ${status}=    set variable if    ${fault_id}==${expected_fault_id}    True
        exit for loop if    ${fault_id}==${expected_fault_id}
    END
    should be equal    ${status}    True    expected fault id is not appear!


Check Expected Alarms Is Not Appear
    [Arguments]  ${vdu_index}=0    ${expected_fault_id}=49
    [Documentation]  this kw is used to Check Expected Alarms Appear
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...    | expected_fault_id  | no | define expected fault id|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check Expected Alarms Is Not Appear | vdu_index=0 | expected_fault_id=49 |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_active_alarms
    ${output_lenth}=    set variable    ${out['total']}
    ${status}=   set variable   False
    FOR    ${index}    IN RANGE    ${output_lenth}
        ${fault_id}    Set Variable    ${out['alarms'][${index}]['fault_id']}
        ${status}=    set variable if    "${fault_id}" == "${expected_fault_id}"    True
        exit for loop if    "${fault_id}" == "${expected_fault_id}"
    END
    Should Not Be Equal    ${status}    True    expected fault id is not appear!


Check Anomalous Alarms Is Appear
    [Arguments]
    [Documentation]  this kw is used to Check Expected Alarms not Appear
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check Expected Alarms Not Appear | vdu_index=0 | expected_fault_id=49 |
    ...
    ${expected_fault_list}    Create List    0010     1806    4341    4352    4383
    ${active_alarms}    ${output_lenth}    Get Active Alarms
    ${status}=   set variable   False
    FOR    ${index}    IN RANGE    ${output_lenth}
        ${actual_fault_id}    Set Variable    ${active_alarms['alarms'][${index}]['fault_id']}
        ${status}=    Check Anomalous Alarms    ${actual_fault_id}    ${output_lenth}    ${expected_fault_list}
    END
    [Return]    ${status}


Check Anomalous Alarms
    [Arguments]  ${actual_fault_id}=0010    ${expected_fault_list}=0010
    [Documentation]  this kw is used to Check Expected Alarms not Appear
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...    | expected_fault_id  | no | define expected fault id|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check Expected Alarms Not Appear | vdu_index=0 | expected_fault_id=49 |
    ...
    ${status}=   set variable   False
    FOR    ${fault_id}    IN   @{expected_fault_list}
        set variable if    '${actual_fault_id}'=='${fault_id}'    ${status}    True
        exit for loop if    '${actual_fault_id}'=='${fault_id}'
    END
    [Return]    ${status}

Get Active Alarms
    [Arguments]  ${vdu_index}=0
    [Documentation]  this kw is used to get active Alarms
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...    | expected_fault_id  | no | define expected fault id|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check Expected Alarms Not Appear | vdu_index=0 | expected_fault_id=49 |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${active_alarms}    vdu.vdu_get_active_alarms
    ${output_lenth}=    set variable    ${active_alarms['total']}
    [Return]    ${active_alarms}    ${output_lenth}
    [Teardown]    vDU Logout By Rest


Save vDU Active Alarm
    [Arguments]  ${file_name}=active_alarm  ${vdu_index}=0
    [Documentation]  VDU Save Historical Alarm To A File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | file_name, default is active_alarm|
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save vDU Active Alarm |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_active_alarms
    aic_param.store_alarms_to_csvfile    alarm_data=${out}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    vDU Logout By Rest


Save vDU Historical Alarm
    [Arguments]    ${file_name}=Historical_Alarm    ${vdu_index}=0
    [Documentation]    VDU Save Historical Alarm To A File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | file_name  | no | file_name, default is 0 |
    ...    | vdu_index  | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Save vDU Historical Alarm |
    ...
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_historical_alarms
    aic_param.store_alarms_to_csvfile    alarm_data=${out}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    vDU Logout By Rest

vDU Login By Rest
    [Arguments]    ${restapi_version}=cuoam_21b    ${vdu_index}=0    ${gnb_index}=0    ${alias}=default
    [Documentation]    this kw is used to Login vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | restapi_version | yes | define api version |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Login By Rest |
    ...
    ${oam_httpaddr}    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ${oam_web_ip}    set variable if    ':' in '''${oam_httpaddr}'''   [${oam_httpaddr}]    ${oam_httpaddr}
    Run keyword and ignore error    vDU Logout By Rest    vdu_index=${vdu_index}
    ${vdu_connection}=    Run Keyword If    '${restapi_version}'=='cuoam_21b'    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=${EMPTY}
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...  secure=True
    ...  connection_name=${alias}
    ...  ELSE    vdu.connect to
    ...  host=${oam_web_ip}
    ...  port=8081
    ...  username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...  password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}

vDU Logout By Rest
    [Arguments]    ${alias}=default
    [Documentation]  this kw is used to Logout vDU By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vDU Logout By Rest  |
    ...
    vdu.disconnect    ${alias}

Get vDU K8s Master SSH Connection Info
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    [Documentation]    this kw is used to Get vDU K8s Master SSH Connection Info
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...	   | vdu_index | no | vdu_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${du_info} | return addr/usename/password/port |
    ...
    ...    Example
    ...    | ${du_info} | Get vDU K8s Master SSH Connection Info |
    ...
    ${result}    ${addr}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH ip in __init__.py for vdu_index=${vdu_index}

    ${result}    ${username}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH username in __init__.py for vdu_index=${vdu_index}

    ${result}    ${password}    Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}
    Should Be True  "${result}"=="PASS"    Please give K8s Master SSH password in __init__.py for vdu_index=${vdu_index}

    ${result}    ${port}        Run Keyword And Ignore Error
    ...   set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.port}
    Should Be True    "${result}"=="PASS"    Please give K8s Master SSH port in __init__.py for vdu_index=${vdu_index}

    ${du_info}    create dictionary    addr=${addr}    username=${username}    password=${password}    port=${port}
    [Return]  ${du_info}

Get vDU Namespace From Config File
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]    this kw is used to Get vDU Namespace From Config File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vdu_namespace} | return vdu namespace|
    ...
    ...    Example
    ...    | ${vdu_namespace} | Get vDU Namespace From Config File |
    ...
    ${vdu_namespace}=    set variable    ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]    ${vdu_namespace}

Connect To K8s Master In vDU
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    [Documentation]   Connect To K8s Master In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    |  Input Parameters | Man. | Description |
    ...    | gnb_index  |  no  | gnb index, default is 0 |
    ...    | vdu_index  |  no  | VDU index, default is 0 |
    ...    | alias      | no   | alias, default value is default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Connect To K8s Master In vDU  | alias=${alias} |
    ...
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info    gnb_index=${gnb_index}
    ...                                                                             vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}

    ${prompt}    set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}    set variable    ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}    set variable    ${prompt}|\\[core@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To    ip=${ip}    username=${username}    password=${password}
       ...   prompt=${prompt}
       ...   alias=${alias}
       ...   width=200
       ...   timeout=150


Reset Rmod By Rest
    [Arguments]   ${rmods_list}   ${vdu_index}=0   ${gnb_index}=0
    [Documentation]   this KW is used for Reset Rmod By Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...   | Input Parameters    | Man. | Description |
    ...   None
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...
    ...   Example
    ...  |  Reset Rmod By Rest | ${rmods_list} |
    ...
    log to console   Reset RUs ${rmods_list} by REST...
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}   vdu.reset_rmods     ${rmods_list}
    Wait Until Keyword Succeeds  60   3   _Check Reset RUs Status Should Be Expected   operation_id=${out["operation_id"]}
    ...                                                                                expected_status=ongoing
    [Teardown]    vDU Logout By Rest

_Check Reset RUs Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_reset_rmods_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"

Reset vDU With Check Cell On Air
    [Arguments]    ${need_check_on_air}=${False}    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   Reset VDU By REST
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | need_check_on_air | no | if need to check cell on air |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Reset vDU With Check Cell On Air | need_check_on_air=${False} |
    ...
    log to console  Reset VDU By REST...
    vDU Login By Rest  vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_vdu
    ${error_msg}    set variable  ${out["error_message"]}
    should contain    ${error_msg}    No error
    ${out}    Wait Until Keyword Succeeds  60   10   _Check Reset VDU Status Should Be Expected    operation_id=${out["id"]}
    ...                                                                                expected_status=ongoing
    Sleep    100s
    Run Keyword If    ${need_check_on_air}   Wait Until Keyword Succeeds  800s   30s
    ...                            vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest


_Check Reset VDU Status Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}
    ${out}    vdu.get_reset_vdu_operation_status    operation_id=${operation_id}
    Should Be True    "${out["status"]}"=="${expected_status}"
    [Return]    ${out}

Reset RU With Check Cell On Air
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=${0}
    [Documentation]   this kw is used to Reset RU With Check Cell On Air
    ...     Author: Yang Mengli
    ...     Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    None
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...   | vdu rest login |
    ...   | Reset RU With Check Cell On Air |
    ...
    ${rmod_id_list}=    Get RMOD ID List
    ${rmod_number}=    get length    ${rmod_id_list}
    vDU Login By Rest    vdu_index=${vdu_index}
    FOR    ${index}    IN RANGE    ${rmod_number}
      Reset RUs By Rest In vDU    ${rmod_id_list}
      sleep  120    reason=Wait for reset ru sucessful
      ${verdict}=   run keyword and return status    wait until keyword succeeds    10min    15s
      ...     vDU Check All Cells Status Should Be Onair    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

Reset RUs By Rest In vDU
    [Arguments]    ${rmods_list}    ${vdu_index}=0    ${gnb_index}=0
    [Documentation]   Reset RUs by rmod id list.
    ...     Author: Yang Mengli
    ...     Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    None
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...   | vdu rest login |
    ...   | Reset RUs By Rest In vDU |
    ...
    log to console    Reset RUs ${rmods_list} by REST...
    vDU Login By Rest    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${out}    vdu.reset_rmods    ${rmods_list}
    Wait Until Keyword Succeeds  120   5   _Check Reset RUs Status Should Be Expected    operation_id=${out["operation_id"]}
    ...                                                                                 expected_status=ongoing
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest


#---------------------vCU--------------------------------------------------------------------------
Login To vCU By Rest
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_23r1
   [Documentation]  Create rest session to vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given |
    ...    | ...             |     'cuoam_21b' other senarios should be use default value - cuoam_21b |
    ...    | alias | No. | alias that identifies this connection, if the argument is given, |
    ...    | ...   |      the alias must be given to the Logout To vCU By Rest keyword as connection argumument. |
	...
    ...    | Return Value | Description |
    ...    | ${alias} | return the connection alias |
    ...
    ...    the connection alias
    ...    Example
    ...    | Login To vCU By Rest | gnb_index=0 |
    ...
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    Logout To vCU By Rest
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

Logout To vCU By Rest
    [Arguments]    ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Logout To vCU By Rest | connection=${None} |
    ...
    cu.disconnect    connection=${connection}

Connect To CU K8S Master
    [Arguments]
    [Documentation]    connect to CU K8S cluster with admin permission
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | No. | the gnb index, default value is 0. |
    ...
    ...    | Return Value | Description |
    ...    | ${alias} | return to the alias |
    ...
    ...    Example
    ...    |  Connect To CU K8S Master With Admin  |
    ...
    ${prompt}  set variable    \\[cloudadmin@\\S+\\s\\S+\\]\\$|\\[root@\\S+\\s\\S+\\s+\\S+\\]\\#|\\[root@\\S+\\s\\S+\\]\\#
    ${prompt}  set variable   ${prompt}|\\[cbis-admin@\\S+\\s\\S+\\s+\\S+\\]\\$|\\[cbis-admin@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[core@\\S+\\s\\S+\\]\\$|\\[${cu_master_username}@\\S+\\s\\S+\\]\\$
    ${prompt}  set variable   ${prompt}|\\[cranuser\\d+@\\S+\\s+\\S+\\]\\$|\\[cranuser\\d+@\\S+\\s+\\S+\\s+\\S+\\]\\$
    issh.Connect_To   ip=${VCU_HOSTNAME}    username=${VCU_USERNAME}   password=${VCU_PASSWORD}
       ...   prompt=${prompt}
       ...   alias=vcu_master   width=200
       ...   timeout=150
    Set Test Variable    ${alias}    vcu_master
    [Return]  ${alias}

Get vCU Namespace From Config File
    [Arguments]    ${gnb_index}=0
    [Documentation]    this kw is used to Get vCU Namespace From Config File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | gnb_index | no | gnb_index, default is 0 |
    ...
    ...    | Return Value | Description |
    ...    | ${vcu_namespace} | return vcu namespace|
    ...
    ...    Example
    ...    | ${vcu_namespace} | Get vCU Namespace From Config File |
    ...
    ${vcu_namespace}=    set variable    ${tl.gnbs[${gnb_index}].cloud_deployment.cloud_hosting.namespace}
    [Return]    ${vcu_namespace}

Generate Delta Plan In vCU
    [Arguments]    ${delta_plan_name}=delta_plan
    [Documentation]   this kw is used to Generate Delta Plan In vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | ${delta_plan_id} | return delta plan id |
    ...
    ...    Example
    ...    | Generate Delta Plan In vCU | delta_plan_name=delta_plan |
    ...
    ${delta_plan_list}    cu.get_delta_plan_list
    Run Keyword If    ${delta_plan_list}    cu.delete_delta_plan    ${delta_plan_list[0]['plan_id']}
    ${delta_res}=    cu.generate_delta_plan    plan_name=${delta_plan_name}
    ${delta_plan_id}=    set variable    ${delta_res['plan_id']}
    Run keyword and continue on failure    Wait until keyword succeeds    3x    2s
    ...  _Check Delta Plan Operation Should Be Successful    ${delta_res['action_id']}
    [Return]    ${delta_plan_id}

vCU Online Get Parameters Of Current Plan Via Rest
   [Arguments]    ${parameter_name}
   [Documentation]    this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | vCU Online Get Parameters Of Current Plan Via Rest | parameter_name=actIntraFreqHoSA |
    ...
    ${para_result}=    cu.search_parameters_of_current_plan    parameter_name=${parameter_name}
    ...                                                        items_per_page=${30}
    [Return]    ${para_result}


vCU Online Get All Parameters Of Distname
   [Arguments]    ${dist_name}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRADJGNB-1
   [Documentation]    this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | vCU Online Get Parameters Of Current Plan Via Rest | parameter_name=actIntraFreqHoSA |
    ...
    ${para_result}=    cu.get_parameters    dist_name=${dist_name}
    [Return]    ${para_result}


Get Parameters Of Current Plan Via Rest
   [Arguments]    ${parameter_name}=administrativeState    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}
   [Documentation]    this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | vCU Online Get Parameters Of Current Plan Via Rest | parameter_name=actIntraFreqHoSA |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${para_result}    vCU Online Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}
    ${result_length}    get length    ${para_result['items']}
    Should be True    ${result_length}>0
    ${result_fault_length}    Evaluate    ${result_length} - ${1}
    FOR    ${index}    IN RANGE    ${result_length}
        ${distname}    set variable    ${para_result['items'][${index}]['distname']}
        ${para}    set variable    ${para_result['items'][${index}]['parameter_name']}
         ${index}    Run Keyword If    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        ...                set variable    ${index}
        exit for loop if    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        Run Keyword If    ${index}==${result_fault_length}    fail    get parameter is failed
    END
    ${para_data}    set variable    ${para_result['items'][${index}]['parameter']}
    ${check_value_whether_is_none}    aic_param.check_param_value_whether_none    ${para_data}
    ${para_value}    run keyword if     ${check_value_whether_is_none}!=${True}
    ...    set variable    ${para_result['items'][${index}]['parameter']['simple_parameter']['value']}
    ...    ELSE    set variable    ${None}
    [Return]    ${para_value}

Check NG link Operation Should Be Successful
   [Arguments]    ${parameter_name}=administrativeState    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}
   ...            ${expected_value}=Locked
   [Documentation]   this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | Check NG link Operation Should Be Successful | parameter_name=actIntraFreqHoSA |
    ...
    ${para_value}    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}
    ...              gnb_index=${gnb_index}    mo_dn=${mo_dn}
    Should Be True    "${para_value}" == "${expected_value}"

vCU Online Get Parameters Via Rest
    [Arguments]    ${delta_plan_id}    ${parameter_name}=actIntraFreqHoSA
    [Documentation]   vCU Online Get Parameters Via Rest.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | delta_plan_id | yes | define delta plan id |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | vCU Online Get Parameters Via Rest | delta_plan_id=${delta_plan_id} | parameter_name=actIntraFreqHoSA |
    ...
    ${para_result}    cu.search_parameters_of_delta_plan    plan_id=${delta_plan_id}    parameter_name=${parameter_name}
    [Return]    ${para_result}

vCU Online modify Parameters Via Rest
    [Arguments]    ${delta_plan_id}    ${para_list}    ${mo_dn}=MRBTS-5460/NRBTS-5460   ${force_reset}=${True}
    [Documentation]   vCU Online modify Parameters Via Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Parameters Via Rest | delta_plan_id=${delta_plan_id} | para_list=${para_list} |
    ...    | mo_dn=MRBTS-5460/NRBTS-5460 |
    ...
    ${uuid}    _Get CU Specifical MO UUID    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=    cu.update_parameters_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
    run keyword and continue on failure    Wait until keyword succeeds    5x    5s
    ...  _Update Parameters Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                     action_id=${update_res['action_id']}
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    Run keyword and continue on failure    Wait until keyword succeeds  5x  5s
    ...  _Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                          action_id=${validate_res['action_id']}
    ${errors}  cu.get_latest_validation_result_of_delta_plan   plan_id=${delta_plan_id}
    ${error_num}  Set Variable  ${errors["total"]}
    should be true    ${error_num}<=0
    ${active_res}=    cu.activate_delta_plan    plan_id=${delta_plan_id}    force_reset=${force_reset}
    run keyword and continue on failure    Wait until keyword succeeds    3x    30s
    ...  _Activating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                          operation_id=${active_res['operation_id']}

vCU Online modify Simple Parameters Via Rest With Compare
    [Arguments]    ${parameter_name}    ${updated_paras_dict}    ${compare_value}=true
    ...            ${mo_dn}=MRBTS-5460/NRBTS-5460    ${gnb_index}=${0}
    [Documentation]    vCU Online modify Simple Parameters Via Rest With Compare.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Parameters Via Rest With Compare | parameter_name=actIntraFreqHoSA |
    ...    | ...                                                | updated_paras_dict=${updated_paras_dict} |
    ...    | ...                                                | compare_value=true |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${para_value}=    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}    gnb_index=${gnb_index}
    ...                                        mo_dn=${mo_dn}
    Run Keyword If    "${para_value}"!="${compare_value}"    Online Modify Single Mo Parameters Via Rest In vCU
    ...                                                            para_list=${updated_paras_dict}
    ...                                                            mo_dn=${mo_dn}
    [Teardown]    Logout To vCU By Rest

vCU Online modify Simple Parameters Via Rest Without Validate And Activate
    [Arguments]    ${parameter_name}    ${updated_paras_dict}    ${delta_plan_id}    ${compare_value}=true
    ...            ${mo_dn}=MRBTS-5460/NRBTS-5460    ${gnb_index}=${0}
    [Documentation]    vCU Online modify Simple Parameters Via Rest With Compare.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Simple Parameters Via Rest Without Validate And Activate | parameter_name=actCMAS |
    ...    | ...                            | ${delta_plan_id} | updated_paras_dict=${updated_paras_dict} |
    ...    | ...                            | compare_value=true |
    ...
    ${para_value}=    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}    gnb_index=${gnb_index}
    ...                                                          mo_dn=${mo_dn}
    Set Test Variable    ${para_value}
    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    Run Keyword If    "${para_value}"!="${compare_value}"    Online Update Single Mo Parameters Via Rest without Get UUID In vCU
    ...                                                       para_list=${updated_paras_dict}
    ...                                                       mo_dn=${mo_dn}
    ...                                                       delta_plan_id=${delta_plan_id}
    ...                                                       uuid=${uuid}
    [Return]    ${para_value}

vCU Online Check Whether MO Exists Via Rest
    [Arguments]    ${mo_dn}=MRBTS-5460/NRBTS-5460
    [Documentation]    vCU Online Check Whether MO Exists Via Rest.
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | mo_dn | yes | need checked modn |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online Check Whether MO Exists Via Rest | mo_dn=MRBTS-5460/NRBTS-5460/NRCELL-1/NRREL-256 |
    ...
    Login To vCU By Rest
    ${para_result}   vCU Online Get All Parameters Of Distname    dist_name=${mo_dn}
    ${params_list}    set Variable    ${para_result['parameters']}
    ${params}    Set Variable   ${params_list}[0]
    log to console     ${params}
    ${result_length}    get length   ${params}
    should be true   ${result_length}>=1    ${mo_dn} is exist
    [Teardown]   Logout To vCU By Rest

vCU Online Delete MO Via Rest
    [Arguments]    ${mo_dn}=MRBTS-5460/NRBTS-5460    ${delta_plan_name}=delta_plan    ${gnb_index}=${0}
    [Documentation]    vCU Online Delete MO Via Rest.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Parameters Via Rest With Compare | parameter_name=actIntraFreqHoSA |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${delta_plan_list}    cu.get_delta_plan_list
    Run Keyword If    ${delta_plan_list}    cu.delete_delta_plan    ${delta_plan_list[0]['plan_id']}
    ${delta_res}=    cu.generate_delta_plan    plan_name=${delta_plan_name}
    ${delta_plan_id}=    set variable    ${delta_res['plan_id']}
    run keyword and continue on failure    Wait until keyword succeeds    6x    2s
    ...  _Check Delta Plan Operation Should Be Successful    ${delta_res['action_id']}
    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.delete_managed_object_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Delete Mo Parameters Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                            action_id=${update_res['action_id']}
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                              action_id=${validate_res['action_id']}
    ${errors}  cu.get_latest_validation_result_of_delta_plan   plan_id=${delta_plan_id}
    ${error_num}  Set Variable  ${errors["total"]}
    should be true    ${error_num}<=0
    ${active_res}=    cu.activate_delta_plan    plan_id=${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    9x    30s
    ...  _Check Activating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                                operation_id=${active_res['operation_id']}
    [Teardown]   Logout To vCU By Rest

vCU Online Create MO Via Rest
    [Arguments]    ${name}=com.nokia.srbts.nrbts:SERVEDAMF    ${instance_id}=${1}    ${delta_plan_name}=delta_plan
    ...            ${mo_dn}=MRBTS-5460/NRBTS-5460    ${gnb_index}=${0}
    [Documentation]    vCU Online Create MO Via Rest.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Parameters Via Rest With Compare | parameter_name=actIntraFreqHoSA |
    ...    | ...                                                | updated_paras_dict=${updated_paras_dict} |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${delta_plan_list}    cu.get_delta_plan_list
    Run Keyword If    ${delta_plan_list}    cu.delete_delta_plan    ${delta_plan_list[0]['plan_id']}
    ${delta_res}=    cu.generate_delta_plan    plan_name=${delta_plan_name}
    ${delta_plan_id}=    set variable    ${delta_res['plan_id']}
    Set Test Variable    ${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    6x    2s
    ...  _Check Delta Plan Operation Should Be Successful    ${delta_res['action_id']}
    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    Set Test Variable    ${uuid}
    ${nidd_id}   _Get CU Specifical NIDD ID    name=${name}
    ${nidd}  convert to string  ${nidd_id}
    ${instance}  convert to integer  ${instance_id}
    ${create_res}=   cu.create_managed_object_of_delta_plan   plan_id=${delta_plan_id}   parent_mo_uuid=${uuid}
    ...  	nidd_id=${nidd}   instance_id=${instance}  include_defaults=true
    run keyword and continue on failure  Wait until keyword succeeds  5x  5s
    ...  _Check CU Create MO Operation Should Be Successful    plan_id=${delta_plan_id}  action_id=${create_res['action_id']}
    [Return]    ${delta_plan_id}



vCU Online Create MO With Modify Parameter Via Rest
    [Arguments]    ${para_list}    ${name}=com.nokia.srbts.nrbts:SERVEDAMF    ${instance_id}=${1}
    ...            ${gnb_index}=${0}    ${mo_dn}=MRBTS-10766/NRBTS-10766
    [Documentation]    vCU Online Create MO With Modify Parameter Via Rest
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Parameters Via Rest With Compare | parameter_name=actIntraFreqHoSA |
    ...    | ...                                                | updated_paras_dict=${updated_paras_dict} |
    ...
    ${delta_plan_id}    vCU Online Create MO Via Rest    name=${name}    instance_id=${instance_id}
    ...                              mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}    gnb_index=${gnb_index}
    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=    cu.update_parameters_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
    run keyword and continue on failure    Wait until keyword succeeds    5x    5s
    ...  _Check Update Parameters Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                     action_id=${update_res['action_id']}
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                              action_id=${validate_res['action_id']}
    ${errors}  cu.get_latest_validation_result_of_delta_plan   plan_id=${delta_plan_id}
    ${error_num}  Set Variable  ${errors["total"]}
    should be true    ${error_num}<=0
    ${active_res}=    cu.activate_delta_plan    plan_id=${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    9x    30s
    ...  _Check Activating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                                operation_id=${active_res['operation_id']}
    [Teardown]   Logout To vCU By Rest

vCU Online Modify Complex Parameter Via Rest
    [Arguments]    ${updated_paras_dict}    ${parameter_name}=a1ThresholdhoSsbRsrpSA    ${compare_value}=true
    ...            ${mo_dn}=MRBTS-5460/NRBTS-5460    ${gnb_index}=${0}
    [Documentation]    vCU Online Modify Complex Parameter Via Rest.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | vCU Online modify Parameters Via Rest With Compare | parameter_name=actIntraFreqHoSA |
    ...    | ...                                                | updated_paras_dict=${updated_paras_dict} |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${sub_para_value}=    Get Sub Parameter Of Current Plan Via Rest    parameter_name=${parameter_name}    gnb_index=${gnb_index}
    ...                                        mo_dn=${mo_dn}
    Run Keyword If    "${sub_para_value}"!="${compare_value}"    Online Modify Single Mo Parameters Via Rest In vCU
    ...                                                            para_list=${updated_paras_dict}
    ...                                                            mo_dn=${mo_dn}
    [Teardown]   Logout To vCU By Rest

Online Modify Single Mo Parameters Via Rest In vCU
    [Arguments]    ${para_list}    ${mo_dn}    ${delta_plan_name}=delta_plan
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | Online Modify Single Mo Parameters Via Rest In vCU | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |
    ...
    ${delta_plan_id}=    Online Generate Delta Plan Via Rest In vCU    delta_plan_name=${delta_plan_name}
    Online Update Single Mo Parameters Via Rest In vCU    para_list=${para_list}    mo_dn=${mo_dn}
    ...                                                   delta_plan_id=${delta_plan_id}
    Validate and Activate Delata Plan For vCU    delta_plan_id=${delta_plan_id}

Online Generate Delta Plan Via Rest In vCU
    [Arguments]    ${delta_plan_name}=delta_plan
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | Online Modify Single Mo Parameters Via Rest In vCU | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |
    ...
    ${delta_plan_list}    cu.get_delta_plan_list
    Run Keyword If    ${delta_plan_list}    cu.delete_delta_plan    ${delta_plan_list[0]['plan_id']}
    ${delta_res}=    cu.generate_delta_plan    plan_name=${delta_plan_name}
    ${delta_plan_id}=    set variable    ${delta_res['plan_id']}
    run keyword and continue on failure    Wait until keyword succeeds    6x    2s
    ...  _Check Delta Plan Operation Should Be Successful    ${delta_res['action_id']}
    [Return]    ${delta_plan_id}

Online Update Single Mo Parameters Via Rest without Get UUID In vCU
    [Arguments]    ${para_list}    ${delta_plan_id}    ${uuid}
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | Online Modify Single Mo Parameters Via Rest In vCU | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |
    ...
    ${update_res}=  cu.update_parameters_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Update Parameters Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                            action_id=${update_res['action_id']}


Online Update Single Mo Parameters Via Rest In vCU
    [Arguments]    ${para_list}    ${mo_dn}    ${delta_plan_id}
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | Online Modify Single Mo Parameters Via Rest In vCU | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |
    ...
    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Update Parameters Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                            action_id=${update_res['action_id']}

Validate and Activate Delata Plan For vCU
    [Arguments]    ${delta_plan_id}
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | para_list | yes | modify parameters list |
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...    | delta_plan_name | no | create delta name, default is delta_plan |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | &{gNbCuName} | operation_type=replace    parameter_path=/gNbCuName   value=cu_8 |
    ...    | &{para_nsaInactivityTimer} |  operation_type=replace    parameter_path=/nsaInactivityTimer   value=100 |
    ...    | @{NRBTS_Para_list} |  ${para_nsaInactivityTimer}  ${para_nsaInactivityTimer}  |
    ...    | Online Modify Single Mo Parameters Via Rest In vCU | para_list=${NRBTS_Para_list} | mo_dn=MRBTS-1/NRBTS-1 |
    ...
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    Wait until keyword succeeds    9x    5s
    ...  _Check Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                              action_id=${validate_res['action_id']}
    ${errors}  cu.get_latest_validation_result_of_delta_plan   plan_id=${delta_plan_id}
    ${error_num}  Set Variable  ${errors["total"]}
    should be true    ${error_num}<=0
    ${active_res}=    cu.activate_delta_plan    plan_id=${delta_plan_id}
    Wait until keyword succeeds    9x    30s
    ...  _Check Activating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                                operation_id=${active_res['operation_id']}

_Check Delta Plan Operation Should Be Successful
    [Arguments]    ${action_id}
    [Documentation]    Check Validating Delta Plan Operation Should Be Successful
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | action_id | yes | Generating delta plan's action id|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Check Delta Plan Operation Should Be Successful | action_id=xxx |
    ...
    ${res}    cu.get_action_state_of_generating_delta_plan    ${action_id}
    should be equal as strings    ${res['status']}    success

vCU Full Commssion By Rest
    [Arguments]    ${path_of_commission_file}   ${plan_name}
    [Documentation]   Send BTS commission via rest.
        ...    Author: Xiang Liang
        ...    Contact: liang.xiang@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...	   |  path_of_commission_file  | Yes. | Path of commission file |
        ...	   |  plan_name  | Yes. |   Plan file name displayed on weebui after scf load   |
        ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Full Commssion By Rest  |   /tmp/commission.xml  |    TA_plan_file   |
    Login To vCU By Rest
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    180s   10s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan activate operation success in 10 mins ***
    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
    [Teardown]    run keyword and ignore error    Logout To vCU By Rest

CU Check Plan Upload Status Should Be As Expected
    [Arguments]  ${operation_id}   ${expected_status}
    [Documentation]   Check plan upload status should be as expected.
        ...    Author: Xiang Liang
        ...    Contact: liang.xiang@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...	   |  operation_id  | Yes. |  Operation id for uploading plan file  |
        ...	   |  expected_status  | Yes. |  Expected upload status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Upload Status Should Be As Expected   |
        ...    | ...                                | a_6cfa594f-0938-4732-a78c-16afdbd214d2 |    success  |
    ${operation_response}=  cu.get_operation_state_of_uploading_plan    ${operation_id}
    should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Validate Status Should Be As Expected
   [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
   [Documentation]   Check plan validate status should be as expected.
        ...    Author: Xiang Liang
        ...    Contact: liang.xiang@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id  | Yes. |  Plan file id  |
        ...	   |  operation_id  | Yes. |  Operation id for validating plan file  |
        ...	   |  expected_status  | Yes. |  Expected validate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Validate Status Should Be As Expected  |
        ...    |  sp_39d02514-e65b-46db-9ad7  |  a_0c7769bd-78ae-4505-9ce1 |  success  |
   ${operation_response}=  cu.get_operation_state_of_validating_plan     ${plan_id}    ${operation_id}
   should be true    "${operation_response["status"]}"=="${expected_status}"

CU Check Plan Activate Status Should Be As Expected
    [Arguments]   ${plan_id}  ${operation_id}  ${expected_status}
    [Documentation]   Check plan activate status should be as expected.
        ...    Author: Xiang Liang
        ...    Contact: liang.xiang@nokia-sbell.com
        ...    | Input Parameters | Man. | Description |
        ...	   |  plan_id  | Yes. |  Plan file id  |
        ...	   |  operation_id  | Yes. |  Operation id for activating plan file  |
        ...	   |  expected_status  | Yes. |  Expected activate status, can be success, ongoing or failure   |

        ...    *RETURN VALUE*
        ...    None
        ...    Example
        ...    |  CU Check Plan Activate Status Should Be As Expected   |
        ...    |  ...                       |sp_39d02514-e65b-46db-9ad7 |  o_c1ca0de5-3225-46e4-86bd  |  success  |
    ${operation_response}=  cu.get_operation_state_of_activating_plan    ${plan_id}   ${operation_id}
    should be true    "${operation_response["status"]}"=="${expected_status}"

_Get Specifical MO UUID In vCU
    [Arguments]    ${plan_id}    ${mo_dn}
    [Documentation]   _Get Specifical MO UUID In vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id|
    ...    | mo_dn | yes | needed modify parameters's modn |
    ...
    ...    | Return Value | Description |
    ...    | ${mouuid} | return mo uuid |
    ...
    ...    Example
    ...    |  ${mouuid} | _Get Specifical MO UUID In vCU | plan_id=${delta_plan_id} | mo_dn=MRBTS-1/NRBTS-1|
    ...
    @{name_list}=    split_string    ${mo_dn}    /
    ${parent_mouuid}    set variable    None
    FOR    ${name}    IN    @{name_list}
        ${parent_mouuid}    _Get Specifical MO UUID via Dn Name In vCU    ${plan_id}    ${name}    ${parent_mouuid}
    END
    [Return]    ${parent_mouuid}

_Get CU Specifical NIDD ID
    [Arguments]  ${name}=com.nokia.srbts.nrbts:NRREL
    [Documentation]   this kw is used to Get CU Specifical NIDD ID
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | name | yes | class name |
    ...
    ...    | Return Value | Description |
    ...    | ${nidd_id} | return mo nidd_id |
    ...
    ...    Example
    ...    |  ${nidd_id} | _Get CU Specifical NIDD ID | name=com.nokia.srbts.nrbts:NRREL |
    ...
    @{all_nidd}   cu.get_nidd
    FOR    ${each_nidd}    IN    @{all_nidd}
       ${nidd_id}  set variable if  '${each_nidd["adaptation_id"]}'=='${name}'   ${each_nidd["nidd_id"]}
        exit for loop if    '${each_nidd["adaptation_id"]}'=='${name}'
    END
    [Return]   ${nidd_id}


_Get Specifical MO UUID via Dn Name In vCU
    [Arguments]   ${plan_id}  ${name}  ${parent_mouuid}
    [Documentation]  this kw is used to get Specifical MO UUID via Dn Name In vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | modify parameters list |
    ...    | name | yes | needed modify parameters modn's name  |
    ...
    ...    | Return Value | Description |
    ...    | ${parent_mouuid} | return parent mo uuid |
    ...
    ...    Example
    ...    | ${parent_mouuid} | _Get Specifical MO UUID via Dn Name In vCU | plan_id=${delta_plan_id} | name=${name}| parent_mouuid
    ...
    &{delta_plan_tree}    cu.get_delta_plan_tree_diff    plan_id=${plan_id}
    @{plan_tree}=    set variable    ${delta_plan_tree["created"]}
    FOR    ${mo_info}    IN    @{plan_tree}
        ${parent_mouuid}    Run keyword if    '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
                            ...   set variable    ${mo_info["mo_uuid"]}
        ...    ELSE
                            ...   set variable    ${parent_mouuid}
        Run keyword if    '${mo_info["name"]}'=='${name}'
            ...   exit for loop
    END
    [Return]    ${parent_mouuid}

_Check CU Create MO Operation Should Be Successful
    [Arguments]   ${plan_id}  ${action_id}
    [Documentation]   this kw is used to Check CU Create MO Operation Should Be Successful
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Check CU Create MO Operation Should Be Successful | plan_id=xxx | action_id=xxx |
    ...
    ${res}=  cu.get_create_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success

_Check Delete Mo Parameters Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]    this kw is used to Check Delete Mo Parameters Operation Should Be Successful
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ...
    ${res}=  cu.get_delete_managed_object_action_result  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success

_Check Update Parameters Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]    this kw is used to Check Update Parameters Operation Should Be Successful
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Update Parameters Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ...
    ${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success

_Check Validating Delta Plan Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]   this kw is used to Check Validating Delta Plan Operation Should Be Successful
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | action_id | yes | Update parameter operation feedback action id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Check Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
    ...
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
    should be equal as strings  ${res['status']}  success

_Check Activating Delta Plan Operation Should Be Successful
    [Arguments]    ${plan_id}    ${operation_id}
    [Documentation]   this kw is used to Check Activating Delta Plan Operation Should Be Successful
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | plan_id | yes | delta plan id |
    ...    | operation_id | yes | active delta plan feedback id |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | _Activating Delta Plan Operation Should Be Successful | plan_id=xxx | operation_id=xxx |
    ...
    ${res}=    cu.get_operation_state_of_activating_delta_plan    ${plan_id}    ${operation_id}
    should be equal as strings    ${res['status']}    success

Get Active Alarm In vCU
    [Arguments]    ${file_name}=vcu_active_Alarm   ${gnb_index}=0
    [Documentation]   Get Active Alarm In CU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Active Alarm In CU | gnb_index=0 |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${active_alarm}=    cu.get_active_alarms    page_number=${1}    items_per_page=${1000}
    aic_param.store_alarms_to_csvfile    alarm_data=${active_alarm}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Get Historical Alarm In vCU
    [Arguments]    ${file_name}=vcu_historical_Alarm   ${gnb_index}=0
    [Documentation]   Get Active Alarm In CU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get Active Alarm In CU | gnb_index=0 |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${historical_alarm}=    cu.get_historical_alarms    page_number=${1}    items_per_page=${1000}
    aic_param.store_alarms_to_csvfile    alarm_data=${historical_alarm}    file_name=${file_name}
    [Return]    ${file_name}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Check All Cells On Air In vCU
    [Arguments]    ${gnb_index}=0
    [Documentation]    Check All Cells On Air IN vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check All Cells On Air In vCU | gnb_index=0 |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${cells_summary}=    cu.get_cells_summary
    run keyword and continue on failure    should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["shutting_down"]}    0    Some cells are shutting down!
    run keyword and continue on failure    should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["administrative_state"]["locked"]}    0    Some cells are locked!
    run keyword and continue on failure    should be equal as integers
    ...    ${cells_summary["basic_cells_summary"]["operational_state"]["disabled"]}    0    Some cells are disabled!
    [Teardown]   run keyword and ignore error    Logout To vCU By Rest


Check All Cells On Air In Multiple vCU
    [Documentation]    Check All Cells On Air In Multiple vCU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | None | NA |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check All Cells On Air In Multiple vCU |
    ...
    ${vCU_number}=    Get vCU Number
    FOR    ${index}    IN RANGE    ${vCU_number}
        Check All Cells On Air In vCU    gnb_index=${index}
    END

Lock vDU In vCU
    [Arguments]   ${du_id_list}    ${gnb_index}=0    ${expected_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1
    ...           ${compare_value}=Locked
    [Documentation]      Lock vDU by du id.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | du_id  | Yes |  DU instance id   |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock vDU In vCU | ${du_id}  | gnb_index=0 |
    ...
    Login To vCU By Rest    ${gnb_index}
    ${return_info}=    cu.lock_du   ${du_id_list}
    ${operation_id}=    set variable    ${return_info["id"]}
    sleep    20s    reason=Wait for lock du sucessful
    wait until keyword succeeds  600s  30s   Get vDU Status In vCU    expected_dn=${expected_dn}
    ...                                                               compare_value=${compare_value}
    ...                                                               gnb_index=${gnb_index}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Get vDU Status In vCU
    [Arguments]  ${expected_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1    ${compare_value}=Unlocked
    ...          ${gnb_index}=0    ${parameter_name}=administrativeState
    [Documentation]  this kw is used to get rmod id list
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...
    ...    | Return Value | Description |
    ...    | rmod_id_list | return rmod id list |
    ...
    ...    Example
    ...    | Get RMOD ID List | gnb_index=${0} | vdu_index=${0} |
    ...
    Login To vCU By Rest    ${gnb_index}
    ${paras_info}=    cu.search_parameters_of_current_plan    parameter_name=${parameter_name}
    ${length}=    get length    ${paras_info['items']}
    FOR    ${index}    IN RANGE    ${length}
        ${fact_dn}    set variable    ${paras_info['items'][${index}]['distname']}
        Run keyword if    '${fact_dn}'=='${expected_dn}'    Set Test variable    ${para_value}
        ...                ${paras_info['items'][${index}]['parameter']['simple_parameter']['value']}
        exit for loop if    '${fact_dn}'=='${expected_dn}'
    END
    should be true    "${para_value}"=="${compare_value}"
    [Teardown]  Run keyword and ignore error    Logout To vCU By Rest

Unlock vDU In vCU
    [Arguments]    ${du_id_list}    ${gnb_index}=0     ${expected_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1
    ...           ${compare_value}=Unlocked
    [Documentation]    this kw is used to Unlock vdu by du id.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...	   | du_id  | Yes |  DU instance id   |
    ...    | gnb_index | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unlock vDU In vCU  | ${du_id_list} | gnb_index=0 |
    ...
    Login To vCU By Rest    ${gnb_index}
    ${return_info}=    cu.unlock_du   ${du_id_list}
    ${operation_id}=    set variable    ${return_info["id"]}
    wait until keyword succeeds  600s  30s   Get vDU Status In vCU    expected_dn=${expected_dn}
    ...                                                               compare_value=${compare_value}
    ...                                                               gnb_index=${gnb_index}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Reset vCU With Check Cell On Air
    [Arguments]    ${gnb_index}=0
    [Documentation]    this kw is used to Reset vCU With Check Cell On Air
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Reset vCU | gnb_index=0 |
    ...
    Login To vCU By Rest    ${gnb_index}
    ${out}    cu.reset_cu
    sleep    600s    reason=Wait for reset cu sucessful
    Wait until keyword succeeds  600s  30s    Check All Cells On Air In vCU
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest


Lock NG Links In vCU
    [Arguments]    ${ng_links_list}    ${gnb_index}=0    ${parameter_name}=administrativeState
    ...            ${mo_dn}=MRBTS-10766    ${expected_value}=Locked
    [Documentation]    this kw is used to Reset vCU With Check Cell On Air
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock NG Links In vCU | gnb_index=0 |
    ...
    Login To vCU By Rest    ${gnb_index}
    lock_ng_links    ng_links_ids=${ng_links_list}    connection=${None}
    wait until keyword succeeds  800s  15s    Check NG link Operation Should Be Successful    parameter_name=${parameter_name}
    ...                         gnb_index=${gnb_index}    mo_dn=${mo_dn}    expected_value=${expected_value}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest

Unlock NG Links In vCU
    [Arguments]    ${ng_links_list}    ${gnb_index}=0    ${parameter_name}=administrativeState
    ...            ${mo_dn}=MRBTS-10766    ${expected_value}=Unlocked
    [Documentation]    this kw is used to Reset vCU With Check Cell On Air
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  gnb_index  | No |  gnb index to indicate which gnb will be used, 0 in default |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Lock NG Links In vCU | gnb_index=0 |
    ...
    Login To vCU By Rest    ${gnb_index}
    unlock_ng_links    ng_links_ids=${ng_links_list}    connection=${None}
    wait until keyword succeeds  800s  15s    Check NG link Operation Should Be Successful    parameter_name=${parameter_name}
    ...                 gnb_index=${gnb_index}    mo_dn=${mo_dn}     expected_value=${expected_value}
    [Teardown]    Run keyword and ignore error    Logout To vCU By Rest


Block Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Block Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is blocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Block Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Login By Rest
    ${out}    vdu.block_cell    cell_id=${cell_id}
    ...                                                 timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Logout By Rest

_Check Block Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}
    ${out}    get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=default
    Should Be True    "${out["status"]}"=="${expected_status}"

_Check Unblock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}
    ${out}    get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...                                          vdu_connection=default
    Should Be True    "${out["status"]}"=="${expected_status}"

Unblock Cell In vDU
    [Arguments]    ${cell_id}=1    ${timeout}=${60}    ${alias}=default
    [Documentation]    this kw is used to Unblock Cell In vDU
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |  cell_id  | No | define which cell id is unblocked |
    ...    |  timeout  | No | define time of timeout |
    ...    |  alias  | No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Unblock Cell In vDU | cell_id=1 | timeout=${60} |
    ...
    vDU Login By Rest
    ${out}    vdu.unblock_cell    cell_id=${cell_id}
    ...                                                     timeout=${timeout}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   _Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...                                                                          expected_status=success
    [Teardown]    vDU Logout By Rest

Fix VDU Staged Plan Error
    [Arguments]   ${alias}=errfix
    [Documentation]  this kw is used to fix vdu staged plan error
    ...    Author: gcao
    ...    Contact: gcao@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | alias| No | define alias of connect to vDU |
    ...
    ...    | Return Value | Description |
    ...    |None|
    ...
    ...    Example
    ...    | Fix VDU Staged Plan Error | ${alias}=errfix|
    ...
    vdu login by rest    alias=${alias}
    ${staged_info_list}   vdu.get_staged_plans_info_list    vdu_connection=${alias}
    vdu.fix_vdu_staged_plan_error    stage_plan_id=${staged_info_list[0]['plan_id']}   vdu_connection=${alias}
    sleep  10
    [Teardown]   vdu logout by rest    alias=${alias}

Get Sub Parameter Of Current Plan Via Rest
    [Arguments]    ${parameter_name}=a2HysteresisRedirectSsbRsrp    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}
    [Documentation]    this kw is used to get sub_Parameter of current plan via rest
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...    | gnb_index | no | The list index from tl.cu[], it will use the index of gnb |
    ...    | mo_dn | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/ |
    ...
    ...    | Return Value | Description |
    ...    | ${sub_param_value} | return value for sub_parameter of staged paramter|
    ...
    ...    Example
    ...    | Get Sub Parameter Of Current Plan Via Rest | parameter_name=actIntraFreqHoSA |
    ...    | mo_dn=MRBTS-10868/NRBTS-10868/NRCELL-1 |
    ...
	Login To vCU By Rest    gnb_index=${gnb_index}
    ${para_result}    vCU Online Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}
    ${result_length}    get length    ${para_result['items']}
    ${result_fault_length}    Evaluate    ${result_length} - ${1}
    set test variable    ${sub_param_value}       ${EMPTY}
    FOR    ${index}    IN RANGE    ${result_length}
        set test variable    ${distname}    ${para_result['items'][${index}]['distname']}
        ${sub_param_dict}    aic_param.get_sub_param_value_of_current_plan    para_dict=${para_result}    i=${index}
		${sub_param_value}    _Find_Sub_Param_For_Single_MO    distname=${distname}    mo_dn=${mo_dn}
		...    sub_param_dict=${sub_param_dict}    parameter_name=${parameter_name}
        exit for loop if		"${sub_param_value}"!="${EMPTY}"
        Run Keyword If    ${index}==${result_fault_length}    fail    get parameter is failed
    END
    [Return]    ${sub_param_value}

_Find_Sub_Param_For_Single_MO
    [Arguments]    ${distname}    ${mo_dn}   ${sub_param_dict}    ${parameter_name}
    [Documentation]    this kw is used to get the value of sub_parameter of staged paramter for a single Mo
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | distname | yes | define parameter name |
    ...    | mo_dn | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/ |
    ...
    ...    | Return Value | Description |
    ...    | ${sub_param_value} | return value for sub_parameter of staged paramter|
    ...
    FOR    ${para}    IN    @{sub_param_dict.items()}
       Run Keyword If     "${distname}" == "${mo_dn}" and "${para[0]}" =="${parameter_name}"
       ...    run keywords    Set Test Variable    ${sub_param_value}   ${para[1]}
       ...	  AND    exit for loop
    END
    [Return]    ${sub_param_value}

Get Parameters Of Current Plan Via Rest for List Type Parameter On VCU
    [Arguments]    ${parameter_name}=refNrCellGroup    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/
    [Documentation]    this kw is used to get parameters of current plan via rest for list type parameter on VCU
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...    | gnb_index | yes | gnb_index, default is 0 |
    ...    | mo_dn | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/ |
    ...
    ...    | Return Value | Description |
    ...    | ${list_param_value} | return parameter result |
    ...
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${para_result}    vCU Online Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}
    ${result_length}    get length    ${para_result['items']}
    Should be True    ${result_length}>0
    ${result_fault_length}    Evaluate    ${result_length} - ${1}
    FOR    ${index}    IN RANGE    ${result_length}
        ${distname}    set variable    ${para_result['items'][${index}]['distname']}
        ${para}    set variable    ${para_result['items'][${index}]['parameter_name']}
        Run Keyword If    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        ...                Set Test Variable    ${index}    ${index}
        exit for loop if    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        Run Keyword If    ${index}==${result_fault_length}    fail    get parameter is failed
    END
    ${para_data}    set variable    ${para_result['items'][${index}]['parameter']}
    ${check_value_whether_is_none}    aic_param.check_param_value_whether_none    ${para_data}
    ${list_param_value}    set variable    ${para_result['items'][${index}]['parameter']['simple_list_parameter']['value']}
    [Return]    ${list_param_value}

Verify List Parameter whether Exist On VCU
    [Arguments]    ${parameter_name}=refNrCellGroup    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRDU-1
    ...             ${expected_param_value}=1
    [Documentation]    this kw is used to verify list parameter whether exist on VCU
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...    | gnb_index | yes | gnb_index, default is 0 |
    ...    | mo_dn | yes | the mo distname that contains the parameter like MRBTS-3218/NRBTS-1/ |
    ...    | expected_param_value | yes | List parameter values to verify|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Verify List Parameter whether Exist On VCU | parameter_name=refNrCellGroup |
    ...
   ${list_param_value}    Get Parameters Of Current Plan Via Rest for List Type Parameter On VCU    parameter_name=${parameter_name}
   ...    gnb_index=${gnb_index}    mo_dn=${mo_dn}
   ${param_value_actual}    set variable
   ${result_length}    get length    ${list_param_value}
   FOR    ${index}    IN RANGE    ${result_length}
      Run Keyword If    "${list_param_value[${index}]}" == "${expected_param_value}"
      ...    Run Keywords    Set Test Variable    ${param_value_actual}    ${list_param_value[${index}]}
      ...    AND     Exit For Loop
   END
   should not be empty     ${param_value_actual}

Delete Pod
    [Arguments]    ${hostname}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...            ${namespace}=${VCU_NAMESPACE}     ${pod_name}=up    ${alias}=vcu_master
    [Documentation]    This kw is used to delete pod
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name | no | set pod name by the parameter |
    ...    | namespace | yes | set namespace |
    ...    | username | yes | set username |
    ...    | hostname | yes | set hostname |
    ...    | password | yes | set password |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Delete Pod |  pod_name=up |
    ...
    ${conn}=    basic.master_connect    hostname=${hostname}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    ${cmd}=    Catenate     oc delete pod -n ${namespace} po-${namespace}-${pod_name}-0
    tafssh.execute    command=${cmd}    connection=${conn}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}


Get TestLine Name From UTE Cloud
    [Documentation]    This kw is used to get tl name
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
     ...    | Input Parameters | Man. | Description |
    ...    | NA | no | None|
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Get TestLine Name |
    ...
    ${status}    ${TestLine_Name}    Run Keyword And Ignore Error    get variable value    ${CONFIGURATION}
    ...    ${variablefile}
    ${key_list}    Create List    CM_RESOURCES    0    properties    name
    ${TestLine_Name}    Run Keyword If    '${status}'=='FAIL'
    ...    Get Info From UTE Reservation File    key_list=${key_list}
    ...    ELSE    Set Variable    ${TestLine_Name}
    Log to Console    \n***TestLine Name ${testline_name}***
    ${TestLine_Name_List}    Split String    ${TestLine_Name}    .
    Set Suite Variable    ${TESTLINE_NAME}    ${TestLine_Name_List[-1]}
    [Return]    ${TestLine_Name}

Get Info From UTE Reservation File
    [Arguments]    ${key_list}    ${file_path}=${UTE_RESERVATION_CONTEXT_JSON}
    [Documentation]    This kw is used to get Info From UTE Reservation File
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | ${key_list} | Yes | The keys list need to get from ute reservation file |
    ...    | ${file_path} | No | The UTE reservation file. Default is ${UTE_RESERVATION_CONTEXT_JSON} |
    ...
    ...    | Return Value | Description |
    ...    | ${dict} | The needed info for the keys in key list |
    ...
    ...    Example
    ...    |  ${key_list}            |  Create List                         |  CM_ARTIFACTS          |  0  |  name  |
    ...    |  ${Expect_Sw_Version}=  |  Get Info From UTE Reservation File  |  key_list=${key_list}  |     |        |
    ...
    ${context}    OperatingSystem.Get File    ${file_path}
    &{context_dict}    json.Loads    ${context}
    ${dict}    Set Variable    ${context_dict}
    FOR    ${k}    IN    @{key_list}
        ${k_convert}    Run Keyword If    ${k.isdigit()}
        ...    Convert To Integer    ${k}
        ...    ELSE    Set Variable    ${k}
        ${dict}    Run Keyword If    ${k.isdigit()}
        ...    Set Variable    ${dict}[${k_convert}]
        ...    ELSE    Collections.Get From Dictionary    ${dict}    ${k_convert}
    END
    [Return]    ${dict}

Check if vDU Use Rannic
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...            ${namespace}=ran-nic-sw-controller     ${alias}=vdu_master
    [Documentation]    This kw is used to check if RANNIC card is used in vDU.
    ...    Author: Liu Renhui
    ...    Contact: renhui-david.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index | yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | vdu_index | yes | The list index from tl.dus[], it will use the index of VDU |
    ...    | namespace | yes | vDU namespace |
    ...    | alias | yes | for connection |
    ...
    ...    | Return Value | Description |
    ...    | is_rannic | bool type |
    ...
    ...    Example
    ...    | Check if vDU Use Rannic |  ${gnb_index}=${0} |
    ...    | ...    | ${vdu_index}=${0} |
    ...
    ${vdu_k8s_master_ssh_connection_info}    Get vDU K8s Master SSH Connection Info
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${ip}    set variable    ${vdu_k8s_master_ssh_connection_info["addr"]}
    ${username}    set variable    ${vdu_k8s_master_ssh_connection_info["username"]}
    ${password}    set variable    ${vdu_k8s_master_ssh_connection_info["password"]}
    ${conn}=    basic.master_connect    hostname=${ip}
    ...                           username=${username}
    ...                           password=${password}
    ...                           alias=${alias}
    ${filter}    set variable    Running
    ${cmd}=    Catenate     kubectl get pod -n ${namespace}|grep ${filter}
    tafssh.send_command    command=${cmd}    connection=${alias}
    ${output}=    tafssh.Read Output    connection=${alias}
    ${output}=    Strip String    ${output}
    ${is_rannic}=    Run Keyword And Return Status
    ...              Should Contain    ${output}    ${filter}
    [Return]   ${is_rannic}
    [Teardown]    Run Keyword And Ignore Error    basic.master_close    alias=${alias}

Check Xn Link Status
    [Arguments]      ${gnb_index}=0    ${xn_index}=0
    ...              ${expected_admin_state}=unlocked      ${expected_link_status}=available
    [Documentation]  this kw is used to check xn link status
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index| Yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | xn_index| Yes | The list index xn links |
    ...    | expected_admin_state| Yes | The expected administrative state of Xn |
    ...    | expected_link_status| Yes | The expected link status of Xn |
    ...
    ...    | Return Value | Description |
    ...    |None|
    ...
    ...    Example
    ...    | Check Xn Link Status | gnb_index=0 | xn_index=0 | expected_admin_state=unlocked | expected_link_status=available
    Log to Console    \n***Get Xn Link Status***
    Login To vCU By Rest    gnb_index=${gnb_index}   alias=vcu_connection
    ${xn_link_info}    cu.get_xn_link_status    connection=vcu_connection

    ${xn_admin_state}    Convert To Lowercase    ${xn_link_info['created'][${xn_index}]['administrative_state']}
    ${xn_link_status}    Convert To Lowercase    ${xn_link_info['created'][${xn_index}]['xn_link_status']}
    should be equal    ${xn_admin_state}  ${expected_admin_state}   The administrative state of Xn is not expected!
    should be equal    ${xn_link_status}  ${expected_link_status}   The link status of Xn is not expected!
    [Teardown]    Logout To vCU By Rest    connection=vcu_connection

Check X2 Link Status
    [Arguments]    ${gnb_index}=0    ${expected_locking_status}=unlocked    ${expected_link_status}=available
    ...            ${x2_index}=0
    [Documentation]  this kw is used to check x2 status
    ...    Author: Liu Juan
    ...    Contact: juan.liu@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index| Yes | The list index from tl.cu[], it will use the index of gnb |
    ...    | x2_index| Yes | The list index x2 links |
    ...    | expected_locking_status | Yes | The expected administrative state of X2 |
    ...    | expected_link_status| Yes | The expected link status of X2 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Check X2 Link Status | gnb_index=0 | x2_index=0 | expected_locking_status=unlocked | expected_link_status=available |
    ...
    Login To Vcu By Rest    gnb_index=${gnb_index}    alias=vcu_connection
    ${x2_link_info}=    cu.get_x2_links_info    connection=vcu_connection
    ${x2_link_lock}     set variable   ${x2_link_info['created'][${x2_index}]['x2_link_lock']}
    ${x2_link_status}     set variable   ${x2_link_info['created'][${x2_index}]['x2_link_status']}
    Should Be True    "${x2_link_lock}" == "${expected_locking_status}"
    Should Be True    "${x2_link_status}" == "${expected_link_status}"
    [Teardown]    Logout To vCU By Rest    connection=vcu_connection

Change VDU WebUI Password
    [Arguments]   ${new_password}    ${curr_password}=Nokia@123    ${alias}=default
    [Documentation]    this kw is to Change VDU WebUI Password
    ...    Author: Xiang Liang
    ...    Contact: Liang.xiang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${new_password}     | yes | new password that you want to set |
    ...    | ${curr_password}    | no | current password |
    ...    |     ${alias}        | no | vdu connection alias |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Change VDU WebUI Password | Nokia@321
    ...    | Change VDU WebUI Password | new_password=Nokia@321    curr_password=Nokia123
    ...
    log to console  Change VDU WebUI Password To ${new_password}
    vdu.update_expired_password    new_password=${new_password}    curr_username=Nemuadmin
    ...        curr_password=${curr_password}    timeout=30    vdu_connection=${alias}

Change VCU WebUI Password
    [Arguments]   ${new_password}    ${curr_password}=Nokia@123
    ...           ${alias}=default
    [Documentation]    this kw is to Change VCU WebUI Password
    ...    Author: Xiang Liang
    ...    Contact: Liang.xiang@nokia-sbell.com
    ...    | Input Parameters    | Man. | Description |
    ...    | ${new_password}    | yes | new password that you want to set |
    ...    | ${curr_password}    | no | current password |
    ...    |     ${alias}        | no | vcu connection alias |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    | Change VCU WebUI Password | Nokia@321
    ...    | Change VCU WebUI Password | new_password=Nokia@321    curr_password=Nokia123
    ...
    log to console  Change VCU WebUI Password To ${new_password}
    cu.update_expired_password    new_password=${new_password}    curr_username=Nemuadmin
    ...        curr_password=${curr_password}    timeout=30    connection=${alias}

Helm Get Pod For VDU
    [Arguments]   ${master_ip}=${VDU_HOSTNAME}    ${username}=${VDU_USERNAME}    ${password}=${VDU_PASSWORD}
    ...           ${namespace}=${VDU_NAMESPACE}   ${pod_name_filter}=aic-vdu    ${timeout}=10
    [Documentation]    this kw is used to get pod for VDU via helm
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name_filter | no | set pod filter, such as: aic-vdu |
    ...    | timeout | no | define time of timeout |
    ...
    ...    | Return Value | Description |
    ...    | ${vdu_pod_dict} | return value for vdu pod dict|
    ...
    ...    Example
    ...    | Helm Get Pod For VDU | pod_name_filter=aic-vdu |
    ...
    ${vdu_pod_dict}    aic_param.helm_get_pod_for_vdu    master_ip=${master_ip}    username=${username}
    ...           password=${password}   namespace=${namespace}   pod_name_filter=${pod_name_filter}   timeout=${timeout}
    [Return]   ${vdu_pod_dict}

Helm Get Pod For VCU
    [Arguments]   ${master_ip}=${VCU_HOSTNAME}    ${username}=${VCU_USERNAME}    ${password}=${VCU_PASSWORD}
    ...           ${namespace}=${VCU_NAMESPACE}   ${pod_name_filter}=aic-vcu    ${timeout}=10
    [Documentation]    this kw is used to get pod for VCU via helm
    ...    Author: gcao
    ...    Contact: ge.cao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | pod_name_filter | no | set pod filter, such as: aic-vcu |
    ...    | timeout | no | define time of timeout |
    ...
    ...    | Return Value | Description |
    ...    | ${vcu_pod_dict} | return value for vcu pod dict|
    ...
    ...    Example
    ...    | Helm Get Pod For VCU | pod_name_filter=aic-vcu |
    ...
    ${vcu_pod_dict}   aic_param.helm_get_pod_for_vcu    master_ip=${master_ip}    username=${username}    password=${password}
    ...                       namespace=${namespace}   pod_name_filter=${pod_name_filter}   timeout=${timeout}
    [Return]   ${vcu_pod_dict}

Get Rannic Info By Rest Api
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${mrbts_id}=None
    [Documentation]   this kw is used to get rannic info by rest Api
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | Yes | gnb index to indicate which gnb will be used, 0 in default |
    ...   | vdu_index | Yes | vdu index to indicate which vdu will be used, 0 in default |
    ...   | mrbts_id | Yes | mrbts id, like 12345 |
    ...
    ...    | Return Value | Description |
    ...    | rannic_info | the list including ran nic info |
    ...
    ...   Example
    ...  | Get Rannic Info By Rest Api | mrbts_id=12345 |
    ...
    log to console  Get Rannic Info...
    vDU Login By Rest    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${rannic_info}    vdu.get_rnic_info_from_plan    mrbts_id=${mrbts_id}
    [Return]   ${rannic_info}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

Reset Rannic By Rest Api
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}    ${rannic_r_dn}=None
    [Documentation]   this kw is used to reset ran nic by rest Api
    ...    Author: Sudi Lou
    ...    Contact: sudi.lou@nokia-sbell.com
    ...
    ...   | Input Parameters | Man. | Description |
    ...   | gnb_index | Yes | gnb index to indicate which gnb will be used, 0 in default |
    ...   | vdu_index | Yes | vdu index to indicate which vdu will be used, 0 in default |
    ...   | rannic_r_dn | Yes | ranic r dn,like MRBTS-10778/EQM_R-1/APEQM_R-1/RNICMOD_R-1 |
    ...
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...   Example
    ...  | Reset Rannic By Rest Api | rannic_r_dn=MRBTS-10778/EQM_R-1/APEQM_R-1/RNICMOD_R-1 |
    ...
    log to console  Reset Rannic By Rest Api...
    vDU Login By Rest    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${output}    vdu.reset_rannic    rannic_r_dn=${rannic_r_dn}
    Wait Until Keyword Succeeds  60   3   _Check Rannic Reset Operation Status   operation_id=${output}[id]
    ...                                                                         expected_status=success
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest

_Check Rannic Reset Operation Status
    [Arguments]    ${operation_id}    ${expected_status}
    log to console  Check Rannic Reset Operation Status...
    ${operation_info}    vdu.get_rnic_reset_operation    operation_id=${operation_id}
    Should Be True    "${operation_info}[status]"=="${expected_status}"

Get Iperf Info
    [Arguments]   ${ue_index}=${0}
    [Documentation]    this kw is used to get iperf info
    ${ue_config}    get_common_ue_config    ue_info=${tl.ues[${ue_index}]}    index=${ue_index}
    Set Suite Variable    ${IPERF_ADDRESS}    ${ue_config['iperf_address']}
    Set Suite Variable    ${IPERF_USER}    ${ue_config['iperf_user']}
    Set Suite Variable    ${IPERF_PASSWORD}    ${ue_config['iperf_password']}
    Set Suite Variable    ${IPERF_PORT}    ${ue_config['iperf_port']}
