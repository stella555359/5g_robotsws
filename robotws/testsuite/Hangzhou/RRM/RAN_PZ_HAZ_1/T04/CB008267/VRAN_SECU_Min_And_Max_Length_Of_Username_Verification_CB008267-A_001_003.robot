*** Settings ***
Documentation
...   Author: yuan.1.gao@nokia-sbell.com
...   Description: This robot cases is for VRAN_SECU_Min And Max Length Of Username Verification CB008267-A_001_003

Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
@{EXPECED_PDL_ERROR_DEFINITION}
...    Incorrect value of maxUserNameLength: '17' not in required range: [4..16 step 1]
...    Incorrect value of minUserNameLength: '3' not in required range: [4..16 step 1]
@{EXPECED_PDL_ERROR_RELATION}
...    It is required that LUAC-1.maxUserNameLength (value: 5) greater/equal to LUAC-1.minUserNameLength (value: 15)
${origin_username}    ${tl.gnbs[0].dus[0].oam_http_connection_details.username}
${orogin_password}    ${tl.gnbs[0].dus[0].oam_http_connection_details.password}
${new_username}     Nokia_123
${need_recover}    ${False}

*** Keywords ***
TC__VRAN_SECU_Min_And_Max_Length_Of_Username_Verification_CB008267-A_001_003
    [Documentation]
    ...    Author: yuan.1.gao@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    03.07.2023, yuan.1.gao@nokia-sbell.com, draft
    Log To Console    TC__VRAN_CM_CB008267-A_001_003
    Step 1: TC Parameters Check For vDU
    Step 2: Validate Error Check For vDU
    Step 3: Local User Account Update Check For vDU

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Run Keyword And Ignore Error    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword If    ${need_recover}    Recovery Parameter
    Run Keyword And Ignore Error    vDU Logout By Rest
    Common Test Teardown For AIC

Step ${index}: TC Parameters Check For vDU
    Log    Step ${index}: TC parameters check started    console=True
    &{para_dic}    Create Dictionary
    ${Initial_minUsernameLen}    Online Get VDU Parameter Value
    ...    mo_dn=MRBTS-${MRBTS_ID_vDU}/MNL-1/AMGR-1/LUAC-1     para_name=minUserNameLength
    ${Initial_maxUsernameLen}    Online Get VDU Parameter Value
    ...    mo_dn=MRBTS-${MRBTS_ID_vDU}/MNL-1/AMGR-1/LUAC-1     para_name=maxUserNameLength
    Set Test Variable    ${Initial_minUsernameLen}
    Set Test Variable    ${Initial_maxUsernameLen}
    Run Keyword If    '${Initial_minUsernameLen}'!='5'    Set To Dictionary    ${para_dic}    minUserNameLength=5
    Run Keyword If    '${Initial_maxUsernameLen}'!='15'    Set To Dictionary    ${para_dic}    maxUserNameLength=15
    ${is_empty}     Run Keyword And Return Status    Should Be Empty     ${para_dic}
    Return From Keyword If    ${is_empty}==True
    ${condition_plan_id}    ${condition_action_id}    Generate Delta Plan In vDU     plan_name=delta_plan_condition
    Update Parameter By Delta Plan In vDU     plan_id=${condition_plan_id}     mo_dn=MRBTS-${MRBTS_ID_vDU}/MNL-1/AMGR-1/LUAC-1
    ...    updated_paras_dict=${para_dic}
    Activate Delta Plan By REST In vDU     plan_id=${condition_plan_id}    force_reset=${False}
    ...    auto_lock_cells=${False}    wait_vdu_up=${True}
    Set Test Variable    ${need_recover}    ${True}

Step ${index}: Validate Error Check For vDU
    Log    Step ${index}: Validate Error Check For vDU    console=True
    &{para_dic_validate1}=    Create Dictionary    minUserNameLength=3    maxUserNameLength=17
    &{para_dic_validate2}=    Create Dictionary    minUserNameLength=15    maxUserNameLength=5
    vDU Login By Rest
    ${length_plan_id}    ${length_action_id}    Generate Delta Plan In vDU     plan_name=delta_plan_lengh
    Update Parameter By Delta Plan In vDU    plan_id=${length_plan_id}      mo_dn=MRBTS-${MRBTS_ID_vDU}/MNL-1/AMGR-1/LUAC-1
    ...    updated_paras_dict=${para_dic_validate1}     operation=replace
    ${Actual_Definition_PDLError}    ${Actual_Relation_PDLError}    ${Actual_occurrenceDefinitionError}
    ...    ${Actual_topologyDefinitionError}    ${Actual_topologyRelationError}
    ...    Validate Delta Plan By REST In vDU With Error
    ...    plan_id=${length_plan_id}
    Lists Should Be Equal     ${Actual_Definition_PDLError}    ${EXPECED_PDL_ERROR_DEFINITION}
    Should Be Empty    ${Actual_Relation_PDLError}
    Should Be Empty    ${Actual_occurrenceDefinitionError}
    Should Be Empty    ${Actual_topologyDefinitionError}
    Should Be Empty    ${Actual_topologyRelationError}
    ${length_plan_id}    ${length_action_id}    Generate Delta Plan In vDU     plan_name=delta_plan_lengh
    Update Parameter By Delta Plan In vDU    plan_id=${length_plan_id}      mo_dn=MRBTS-${MRBTS_ID_vDU}/MNL-1/AMGR-1/LUAC-1
    ...    updated_paras_dict=${para_dic_validate2}     operation=replace
    ${Actual_Definition_PDLError}    ${Actual_Relation_PDLError}    ${Actual_occurrenceDefinitionError}
    ...    ${Actual_topologyDefinitionError}    ${Actual_topologyRelationError}
    ...    Validate Delta Plan By REST In vDU With Error
    ...    plan_id=${length_plan_id}
    Lists Should Be Equal     ${Actual_Relation_PDLError}    ${EXPECED_PDL_ERROR_RELATION}
    Should Be Empty    ${Actual_Definition_PDLError}
    Should Be Empty    ${Actual_occurrenceDefinitionError}
    Should Be Empty    ${Actual_topologyDefinitionError}
    Should Be Empty    ${Actual_topologyRelationError}
    Delete Delta Plan By Plan Id In vDU    plan_id=${length_plan_id}
    Run Keyword And Ignore Error    vDU Logout By Rest

Step ${index}: Local User Account Update Check For vDU
    Log    Step ${index}: Local User Account Update Check For vDU    console=True
    vDU Login By Rest
    Update Local User Account Username By REST In vDU
    ...    username=${origin_username}    new_username=${new_username}    password=${orogin_password}
    Update Local User Account Username By REST In vDU    username=${new_username}     new_username=${origin_username}
    ...    password=${orogin_password}
    ${update_result}    ${exception_rtn}    Run Keyword And Ignore Error    Update Local User Account Username By REST In vDU
    ...    username=${origin_username}    new_username=N1    password=${orogin_password}
    Should Be True    '${update_result}'=='FAIL'
    Should Contain    ${exception_rtn}    Change username failed(Invalid username)
    ${update_result}    ${exception_rtn}    Run Keyword And Ignore Error    Update Local User Account Username By REST In vDU
    ...    username=${origin_username}    new_username=Nokia_1234567890_12345    password=${orogin_password}
    Should Be True    '${update_result}'=='FAIL'
    Should Contain    ${exception_rtn}    Change username failed(Invalid username)

Validate Delta Plan By REST In vDU With Error
    [Arguments]    ${plan_id}
    ${out}    vdu.Validate_Delta_Plan    delta_plan_id=${plan_id}
    ${action_id}    Set Variable    ${out["action_id"]}
    ${rtn}    Wait Until Keyword Succeeds    20    2
    ...    _Check Validate Delta Plan Status Should Be Expected    action_id=${action_id}    plan_id=${plan_id}
    ...    expected_status=success
    ${validation_id}  Set Variable   ${rtn["validation_id"]}
    ${errors}  vdu.get_delta_plan_validation_results   plan_id=${plan_id}  validation_id=${validation_id}
    ${Definition_PDLError}    Create List
    ${Relation_PDLError}    Create List
    ${occurrenceDefinitionError}    Create List
    ${topologyDefinitionError}    Create List
    ${topologyRelationError}    Create List
    ${Initial_parameterDefinitionError}    Set Variable     ${errors["parameterDefinitionError"]}
    FOR    ${item}    IN    @{Initial_parameterDefinitionError}
        ${error_description_Definition}    Set Variable     ${item["error_description"]}
        Append To List    ${Definition_PDLError}     ${error_description_Definition}
    END
    ${Initial_parameterRelationError}    Set Variable     ${errors["parameterRelationError"]}
    FOR    ${item}    IN    @{Initial_parameterRelationError}
        ${error_description_Relation}    Set Variable     ${item["error_description"]}
        Append To List    ${Relation_PDLError}     ${error_description_Relation}
    END
    ${Initial_occurrenceError}    Set Variable     ${errors["occurrenceDefinitionError"]}
    FOR    ${item}    IN    @{Initial_occurrenceError}
        ${error_description_occurrence}    Set Variable     ${item["error_description"]}
        Append To List    ${occurrenceDefinitionError}     ${error_description_occurrence}
    END
    ${Initial_topologyDefinitionError}    Set Variable     ${errors["topologyDefinitionError"]}
    FOR    ${item}    IN    @{Initial_topologyDefinitionError}
        ${error_description_topologyDefinition}    Set Variable     ${item["error_description"]}
        Append To List    ${topologyDefinitionError}     ${error_description_topologyDefinition}
    END
    ${Initial_topologyRelationError}    Set Variable     ${errors["topologyRelationError"]}
    FOR    ${item}    IN    @{Initial_topologyRelationError}
        ${error_description_topologyRelation}    Set Variable     ${item["error_description"]}
        Append To List    ${topologyRelationError}     ${error_description_topologyRelation}
    END
    [Return]    ${Definition_PDLError}    ${Relation_PDLError}    ${occurrenceDefinitionError}    ${topologyDefinitionError}
    ...    ${topologyRelationError}

Update Local User Account Username By REST In vDU
    [Arguments]    ${username}    ${new_username}    ${password}
    ${out}    vdu.account_users_system_patch    username=${username}    new_username=${new_username}
    ...    password=${password}    timeout=60
    Should Be True     "${out["content"]}"=="Success"

Recovery Parameter
    vDU Login By Rest
    &{recover_paras_dict}    Create Dictionary
    Set To Dictionary    ${recover_paras_dict}    minUserNameLength=${Initial_minUsernameLen}    maxUserNameLength=${Initial_maxUsernameLen}
    ${recover_plan_id}    ${recover_action_id}    Generate Delta Plan In vDU     plan_name=delta_plan_recover
    Update Parameter By Delta Plan In vDU     plan_id=${recover_plan_id}
    ...    mo_dn=MRBTS-${MRBTS_ID_vDU}/MNL-1/AMGR-1/LUAC-1    updated_paras_dict=${recover_paras_dict}
    Activate Delta Plan By REST In vDU     plan_id=${recover_plan_id}    force_reset=${False}
    ...    auto_lock_cells=${False}    wait_vdu_up=${True}
    [Teardown]    Run Keyword And Ignore Error    vDU Logout By Rest