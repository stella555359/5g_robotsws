*** Settings ***
Documentation       Test case for CB012098_001
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${wft_api_url}    https://wft.int.net.nokia.com:8091/ALL/api/v1/build_branch.json
#${targetMoc1}    MRBTS/NRBTS
${targetMoc1}    MRBTS/NRBTS/NRCELL
${targetMoc2}    MRBTS/NRBTS/NRCELL
#&{TARGETRELEASEPARAMVALUE_NIDD_ERROR}   targetParam=cuOvlHa()    targetValue=#DEL#
&{TARGETRELEASEPARAMVALUE_NIDD_ERROR}   targetParam=cellReselectionPriority    targetValue=#DEL#
&{TARGETRELEASEPARAMVALUE_PDL_ERROR}      targetParentParam=ulTransPrecodeCtl    targetParam=ulTransPrecodeOffSinrThresh    targetValue=10
&{TARGETRELEASEPARAMVALUE_WITHOUT_ERROR}   targetParentParam=ulTransPrecodeCtl    targetParam=ulTransPrecodeOffSinrThresh    targetValue=1
&{NRCELL_TARGETRELEASEPARAMVALUE_DIC1}    targetParentParam=ulTransPrecodeCtl    targetParam=ulTransPrecodeOffSinrThresh    targetValue=0
&{NRCELL_TARGETRELEASEPARAMVALUE_DIC2}    targetParam=actUlDftSOfdm    targetValue=true
&{NRCELL_TARGETRELEASEPARAMVALUE_WITHOUT_ERROR}    targetParentParam=ulTransPrecodeCtl    targetParam=ulTransPrecodeOffSinrThresh    targetValue=40
${nidd_error_msg}    Mandatory parameter 'cellReselectionPriority' missing
${tmp_msg1}    Whenever NRCELL-1 having NRCELL-1.actUlDftSOfdm (value: true) equal to true, for NRCELL-1.ulTransPrecodeCtl-1,
${tmp_msg2}    it is required that NRCELL-1.ulTransPrecodeCtl-1.ulTransPrecodeOnSinrThresh (value: 0 [dB])
${tmp_msg3}    less than NRCELL-1.ulTransPrecodeCtl-1.ulTransPrecodeOffSinrThresh (value: 0 [dB])
${pdl_error_msg}    ${tmp_msg1} ${tmp_msg2} ${tmp_msg3}
${sw_rollback}    ${False}

*** Keywords ***
CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    - Test Preparation
    ...    - Define Target Migration Rules With NIDD Error
    ...    - Upgrade SBTS SW And Check NIDD Validation Error
    ...    - Check Fault 30 Raised
    ...    - Define Target Migration Rules With PDL Error
    ...    - Upgrade SBTS SW And Check PDL Validation Error
    ...    - Check Fault 30 Raised
    ...    - Define Target Migration Rules Without Error
    ...    - Upgrade SBTS SW And Check Operation Success
    ...    - Check Fault 30 Not Raised
    ...    - Check Config Updated After Upgrade
    ...  Pass criteria:
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.07.2024 - Draft
    ...  - 23.09.2024 - change to nrcell-1 because of pdl error
    ...  - 15.05.2025 - update test data due to cb013033/13031
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 0: Prepare Common Variables
    Step 1: Enable Feature
    Step 2: Download Latest SBTS SW Build
    Step 3: Define Target Migration Rules With NIDD Error
    Step 4: Upgrade SBTS SW And Check NIDD Validation Error ${nidd_error_msg}
    Step 5: Check Fault 30 Raised
    Step 6: Define Target Migration Rules With PDL Error
    Step 7: Upgrade SBTS SW And Check PDL Validation Error ${pdl_error_msg}
    Step 8: Check Fault 30 Raised
    Step 9: Define Target Migration Rules Without Error
    Step 10: Upgrade SBTS SW And Check Operation Success
    Step 11: Check Fault 30 Not Raised
    Step 12: Check Config Updated After Upgrade
    Step 13: Rollback SBTS SW And Check Site Status

Step ${index}: Prepare Common Variables
    Log To Console    Step ${index}: Test Preparation
    Set Test Variable     ${mo_mrbtsdesc}    MRBTS-${mrbts_id}/MRBTSDESC-0
    Set Test Variable     ${mo_tarconfrep}    MRBTS-${mrbts_id}/MRBTSDESC-0/TARGETCONFIGPREP-1
#    ${cell_list}    coam.Get Cell List
#    ${selected_cell}    Evaluate    random.choice(${cell_list['cells']['nr']})    modules=random, sys
#    Set Test Variable    ${selected_nrcell}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_nrcell}    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-1
#   ${pdl_error_msg}    Replace String    ${pdl_error_msg}    NRCELL-1     ${selected_nrcell.split('/')[-1]}
#	Set Test Variable    ${pdl_error_msg}
    ${scf_content}    coam.Get SCF
    ${cur_value}   L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="${selected_nrcell}"]/list[@name="ulTransPrecodeCtl"]/item/p[@name="ulTransPrecodeOnSinrThresh"]
    ${cur_value}    Convert To String    ${${cur_value}/10}
    ${pdl_error_msg}    Replace String    ${pdl_error_msg}
    ...    ulTransPrecodeOnSinrThresh (value: 0 [dB]    ulTransPrecodeOnSinrThresh (value: ${cur_value.replace(".0","")} [dB]
	Set Test Variable    ${pdl_error_msg}
    ${targetReleaseParamValueList_With_NIDD_Error}    Create List    ${TARGETRELEASEPARAMVALUE_NIDD_ERROR}
    ${targetReleaseParamValueList_With_PDL_Error}    Create List    ${TARGETRELEASEPARAMVALUE_PDL_ERROR}
    ${nrcell_targetReleaseParamValueList_With_Error}    Create List    ${NRCELL_TARGETRELEASEPARAMVALUE_DIC2}
     ...    ${NRCELL_TARGETRELEASEPARAMVALUE_DIC1}
    Set Test Variable    ${targetReleaseParamValueList_With_NIDD_Error}
    Set Test Variable    ${targetReleaseParamValueList_With_PDL_Error}
    Set Test Variable    ${nrcell_targetReleaseParamValueList_With_Error}
    ${targetReleaseParamValueList_Without_Error}    Create List    ${TARGETRELEASEPARAMVALUE_WITHOUT_ERROR}
    ${nrcell_targetReleaseParamValueList_Without_Error}    Create List    ${NRCELL_TARGETRELEASEPARAMVALUE_DIC2}
    ...    ${NRCELL_TARGETRELEASEPARAMVALUE_WITHOUT_ERROR}
    Set Test Variable    ${targetReleaseParamValueList_Without_Error}
    Set Test Variable    ${nrcell_targetReleaseParamValueList_Without_Error}

Step ${index}: Enable Feature
    Log To Console    Step ${index}: Enable Feature
    #  FEATCADM::actTargetConfigPrep == true, FEATCADM::actValidationOnUpgrade == true
    ${timestamp}    Generate Formatted Timestamp
    ${delta_id}    Set Variable    preparation_${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    coam.Append Parameter Update To Delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1     actTargetConfigPrep    true   ${delta_id}
    coam.Append Parameter Update To Delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1     actValidationOnUpgrade    true   ${delta_id}
    ${delta_json}    coam.Get Delta    ${delta_id}
    coam.Perform Delta Recommissioning    ${delta_json}    True

Step ${index}: Download Latest SBTS SW Build
    Log To Console    Step ${index}: Download Latest SBTS SW Build
    ${target_build}    Fetch Latest SBTS SW Build
    Download SBTS SW Build    ${target_build}
    Set Test Variable    ${target_build}

Step ${index}: Define Target Migration Rules With ${type} Error
    Log To Console    Step ${index}: Define Target Migration Rules With ${type} Error
    ${timestamp}    Generate Formatted Timestamp
    ${delta_id}    Set Variable    ${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    ${cnt}    Get MO Count    ${mo_mrbtsdesc}
    Run Keyword If    '${cnt}'=='0'    coam.Append Managed Object To Delta    ${mo_mrbtsdesc}    create    ${delta_id}
    ${cnt}    Get MO Count    ${mo_tarconfrep}
    Run Keyword If    '${cnt}'=='0'     coam.Append Managed Object To Delta    ${mo_tarconfrep}    create    ${delta_id}
	${targetMoc}    Set Variable If    '${type}'=='NIDD'    ${targetMoc1}    ${targetMoc2}
    coam.Append Parameter Update To Delta    ${mo_tarconfrep}     targetMoc    ${targetMoc}    ${delta_id}
    coam.Append Parameter Update To Delta    ${mo_tarconfrep}     targetReleaseParamValueList
    ...    ${targetReleaseParamValueList_With_${type}_Error}    ${delta_id}
    coam.Append Parameter Update To Delta    ${selected_nrcell}   targetReleaseParamValueList
    ...    ${nrcell_targetReleaseParamValueList_With_Error}    ${delta_id}
    ${delta_json}    coam.Get Delta    ${delta_id}
    Log To Console     ${delta_json}
    coam.Perform Delta Recommissioning    ${delta_json}    True

Step ${index}: Upgrade SBTS SW And Check ${type} Validation Error ${msg}
    Log To Console    Step ${index}: Upgrade SBTS SW And Check ${type} Validation Error
    ${sw_update_result}    ${sw_update_msg}    Run Keyword And Ignore Error     Admin Upgrade SBTS SW     ${target_build}
    Should Contain   ${sw_update_msg}    Activation failed, ${type} validation error
    Should Contain   ${sw_update_msg}    ${msg}

Step ${index}: Check Fault 30 Raised
    Log To Console     Step ${index}: Check Fault 30 Raised
    Wait Until Keyword Succeeds    3x    5s    coam.Assert Alarm Active    alarmId=7115     faultId=30    severity=Minor

Step ${index}: Define Target Migration Rules Without Error
    Log To Console    Step ${index}: Define Target Migration Rules Without Error
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${timestamp}    Generate Formatted Timestamp
    ${delta_id}    Set Variable    ${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    ${cnt}    Get MO Count    ${mo_mrbtsdesc}
    Run Keyword If    '${cnt}'=='0'    coam.Append Managed Object To Delta    ${mo_mrbtsdesc}    create    ${delta_id}
    ${cnt}    Get MO Count    ${mo_tarconfrep}
    Run Keyword If    '${cnt}'=='0'     coam.Append Managed Object To Delta    ${mo_tarconfrep}    create    ${delta_id}
    coam.Append Parameter Update To Delta    ${mo_tarconfrep}     targetMoc    ${targetMoc2}    ${delta_id}
    coam.Append Parameter Update To Delta    ${mo_tarconfrep}     targetReleaseParamValueList
    ...    ${targetReleaseParamValueList_Without_Error}    ${delta_id}
    coam.Append Parameter Update To Delta    ${selected_nrcell}   targetReleaseParamValueList
    ...    ${nrcell_targetReleaseParamValueList_Without_Error}    ${delta_id}
    ${delta_json}    coam.Get Delta    ${delta_id}
    log to console     ${delta_json}
    coam.Perform Delta Recommissioning    ${delta_json}    True

Step ${index}: Check Fault 30 Not Raised
    Log To Console     Step ${index}: Check Fault 30 Not Raised
    Wait Until Keyword Succeeds    3x    5s    coam.Assert Alarm Inactive    alarmId=7115     faultId=30    severity=Minor

Step ${index}: Upgrade SBTS SW And Check Operation Success
    Log To Console    Step ${index}: Upgrade SBTS SW And Check Operation Success
    Admin Upgrade SBTS SW     ${target_build}
    ${current_sw}    Wait Until Keyword Succeeds    6x    10s    coam.Get SW Version
    ${active_prefix}    Fetch From Left    ${current_sw}    _
    ${current_build}    Run Keyword If    "${active_Prefix}" == "${Trunk_Prefix}"    Replace String    ${current_sw}    ${active_prefix}    SBTS00
    ...    ELSE    Set Variable    ${current_sw}
    Should Be Equal As Strings     ${current_build}    ${target_build}

Step ${index}: Check Config Updated After Upgrade
    Log To Console    Step ${index}: Check Config Updated After Upgrade
    ${scf_content}    coam.Get SCF
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    FOR    ${item}    IN    @{nrcell_targetReleaseParamValueList_Without_Error}
        ${actual_value}    L_XML.Get Element Text    ${scf_content}
        ...    .//managedObject[@distName="${selected_nrcell}"]//p[@name="${item['targetParam']}"]
        Should Be Equal As Strings    ${actual_value}   ${item['targetValue']}
    END

Step ${index}: Rollback SBTS SW And Check Site Status
    Log To Console    Step ${index}: Rollback SBTS SW And Check Site Status
    coam.Rollback Software
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    coam.Assert Alarm Inactive    alarmId=7115     faultId=30    severity=Minor

Get Structure Param Value
    [Arguments]    ${scf_content}    ${dist_name}    ${param_name}
    ${element_dic}    Create Dictionary
    ${tmp_dic}    Create Dictionary
    ${actual_items}    L_XML.Get Child Elements    ${scf_content}
    ...    .//managedObject[@distName="${dist_name}"]/list[@name="${param_name}"]/item
    FOR    ${item}    IN    @{actual_items}
        ${p_name}    L_XML.Get Element Attribute    ${item}    name
        ${p_value}    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${tmp_dic}    ${p_name}    ${p_value}
    END
   ${element_list}    Create List    ${tmp_dic}
    Set To Dictionary    ${element_dic}    ${param_name}    ${element_list}
    [Return]    ${element_dic}

Recover TargetRelease Objs
    ${timestamp}    Generate Formatted Timestamp
    ${delta_id}    Set Variable    ${mrbts_id}_${timestamp}
    coam.Create Delta    ${delta_id}
    coam.Append Managed Object To Delta    ${mo_tarconfrep}    delete    ${delta_id}
    coam.Append Parameter Delete To Delta    ${selected_nrcell}   targetReleaseParamValueList    ${delta_id}
    ${delta_json}    coam.Get Delta    ${delta_id}
    Log To Console     ${delta_json}
    coam.Perform Delta Recommissioning    ${delta_json}    True

Fetch Latest SBTS SW Build
    ${json_tmp1}    Set Variable    {"page": "1","items": "1","sorting_field": "created_at","sorting_direction": "DESC","group_by":
    ${json_tmp2}    Set Variable    "","group_by_processor": "","columns": {"0": {"id": "version"},"1": {"id": "delivery_date"},"2":{"id":
    ${json_tmp3}    Set Variable    "promotion_status_td"}},"projects": ["ALL"],"view_filters_attributes": {"0": {"column": "branch.title",
    ${json_tmp4}    Set Variable    "operation":"eq","value": "SBTS00","parameter": ""},"1": {"column": "quicktest.result","operation": "start",
    ${json_tmp5}    Set Variable    "value":"released","parameter": ""}},"access_key": "WoQ1OI0ImBDwwLUvNVVreWnJ34omNxqfvxs9Fdbi"}
    ${param_json}    Set Variable    ${json_tmp1}${json_tmp2}${json_tmp3}${json_tmp4}${json_tmp5}
    OperatingSystem.Create File    ${TestFiles}/params.json    ${param_json}
    ${output_json}    Set Variable    ${TestFiles}/response.json
    OperatingSystem.Run
    ...    curl -H 'Accept: application/json' -H 'Content-Type:application/json' -d@${TestFiles}/params.json ${wft_api_url} -o ${output_json}
    ${file_content}    OperatingSystem.Get File    ${output_json}
    ${file_content}    Replace String     ${file_content}    false    'false'
	${file_content}    Replace String     ${file_content}    true    'true'
    ${response_dic}    Evaluate     ${file_content}
    ${target_build}    Set Variable    ${response_dic['items'][0]['version']}
    [Return]    ${target_build}

Get MO Count
    [Arguments]     ${mo_dn}
    ${scf_content}    coam.Get SCF
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${elements}    L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="${mo_dn}"]
    ${element_cnt}    Get Length    ${elements}
    [Return]      ${element_cnt}

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${dic_bts_infor}    coam.Get Bts Info
    ${mrbts_id}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    ${nrbts_id}    Pop From Dictionary    ${dic_bts_infor}    nrBtsId
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}

CaseTearDown
    Log    CaseTearDown    console=True
    Run Keyword And Ignore Error    Recover TargetRelease Objs
    Common Test Teardown SBTS    never