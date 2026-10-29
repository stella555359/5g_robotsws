*** Settings ***
Documentation       Test suite for CB013031_015 NFTA
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
# Test Timeout    3h
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Library           ../Resources/python/FCT_Excel.py

*** Variables ***
@{ignore_param_list_F}    pucchSize:    (rel >=24R1) bwpChBwDedicated3:
...    (rel >=24R1) bwpChBwDedicated2:    #can not be configured for Cloud BTS in this release

*** Keywords ***
VRAN_SyVe_CM_CB013031_015_CM_Feature_Configuration_Engine_Run_in_NMS_with_CACVAS
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for
    ...    RAN_ST_CB013031_015_CM_Feature Configuration Engine (Feature Configuration Tool) run in NMS with CACVAS for configure a feature.docx
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.09.2025 - New case.
    Log To Console    ${TEST_NAME} start.    console=${True}
    Step 1: Get PUCCH FCE Capabilities And Check
    Step 2: Get PDCCH FCE Capabilities And Check
    Step 3: Get PUCCH FctMetadata And Check
    Step 4: Get PDCCH FctMetadata And Check
    Step 5: PUCCH CalculateConfiguration And Check
    Step 6: PDCCH CalculateConfiguration And Check
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check Additional Param In Actual Plan
    Step 10: Provision the backup plan

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    Set Test Variable    ${CUR_LOCAL_SCF}    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Set Test Variable    ${NEED_RECOVER}    ${False}
    ${fce_worker_f_name}    ${fct_file_f_name}    Download FCE Modules For Current SW    ${Trunk_Prefix}
    ${pucch_fct_name}    ${pdcch_fct_name}    Unzip FCT    ${TEST_LOG_DIRECTORY}/${fct_file_f_name}
    Set Test Variable    ${PDCCH_FCT_FILE_NAME}    ${pdcch_fct_name}
    Set Test Variable    ${PUCCH_FCT_FILE_NAME}    ${pucch_fct_name}
    ${time}    Get Time    epoch
    Set Test Variable    ${REMOTE_PDCCH_FCT_FILE}    /d/oss/global/var/racprs/work/${time}_${pdcch_fct_name}
    Set Test Variable    ${REMOTE_PUCCH_FCT_FILE}    /d/oss/global/var/racprs/work/${time}_${pucch_fct_name}
    Set Test Variable    ${FEEDBACK_JSON_PATH}    /d/oss/global/var/racops/export
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${CUR_LOCAL_SCF}
    ${NRBTS_RELEASE}    L_XML.Get Element Attribute    ${scf_content}    version    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Set Test Variable    ${NRBTS_RELEASE}    com.nokia.srbts.nrbts:${NRBTS_RELEASE.split("_")[0]}
    ${elements_nrcell}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${LIST_NRCELL_DN}    Create List
    FOR    ${element}    IN    @{elements_nrcell}
        ${dn}    L_XML.Get Element Attribute    ${element}    distName
        Append To List    ${LIST_NRCELL_DN}    ${dn}
    END
    Set Test Variable    ${LIST_NRCELL_DN}
    Set Test Variable    ${PLAN_NAME}    TA_CB009451_F_1_${time}

Case Postcondition
    Log To Console    \n Case Postcondition
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PLAN_NAME}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PLAN_NAME}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PLAN_NAME}_PUCCH
    Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${REMOTE_PDCCH_FCT_FILE}
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${REMOTE_PDCCH_FCT_FILE}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${REMOTE_PUCCH_FCT_FILE}
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${REMOTE_PUCCH_FCT_FILE}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${FEEDBACK_JSON_PATH}/${FEEDBACK_JSON_NAME}
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure
    ...    SSHLibrary.Execute Command    rm ${FEEDBACK_JSON_PATH}/${FEEDBACK_JSON_NAME}
    Common Test Teardown For AIC
    Teardown NetAct
    SSHLibrary.Close All Connections

Step ${index}: Get PUCCH FCE Capabilities And Check
    Log To Console    Step ${index}: Get PUCCH FCE Capabilities And Check
    ${param_name_mapping}    Create Dictionary    Tool Name=fullToolName    Abbreviated Tool Name=toolName    Description=toolDescription
    ...    Version=toolVersion    Category=toolCategory    Support Release(s) \\ NIDD adaptationId(s)=supportedAdaptationVersions
    ${ParmName_Excel_list}    Get Dictionary Keys    ${param_name_mapping}
    ${FCT_Info}    FCT_Excel.get_FCT_info    ${TEST_LOG_DIRECTORY}/FCT_PUCCH_Configuration.xlsx    GENERAL-METADATA    ${ParmName_Excel_list}
    ${feature_filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Run Keyword If    '${feature.__len__()}'=='${0}'    Install New PUCCH FCT To NetAct
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}
    ${feature_netact}    Set Variable    ${feature[0]}
    ${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    ${multi_supportedAdaptationVersions}    Pop From Dictionary    ${feature_netact}    supportedAdaptationVersions
    ${supportedAdaptationVersions}    Create List
    FOR    ${sub_list}    IN    @{multi_supportedAdaptationVersions}
        Append To List    ${supportedAdaptationVersions}    @{sub_list}
    END
    ${excel_supportedAdaptationVersions}    Pop From Dictionary    ${FCT_Info}    Support Release(s) \\ NIDD adaptationId(s)
    Sort List    ${excel_supportedAdaptationVersions}
    Sort List    ${supportedAdaptationVersions}
    Lists Should Be Equal    ${supportedAdaptationVersions}    ${excel_supportedAdaptationVersions}
    ${Category}    Pop From Dictionary    ${FCT_Info}    Category
    ${Category}    Set Variable If    '${Category}'=='None'    ${EMPTY}    ${Category}
    Set To Dictionary    ${FCT_Info}    Tool Name    ${FCT_Info["Abbreviated Tool Name"]}_Configuration
    Set To Dictionary    ${FCT_Info}    Category    ${Category}
    FOR    ${param}    IN    @{ParmName_Excel_list}
        ${netact_param_name}    Get From Dictionary    ${param_name_mapping}    ${param}
        Should Be Equal As Strings    ${FCT_Info["${param}"]}    ${feature_netact["${netact_param_name}"]}
    END

Step ${index}: Get PDCCH FCE Capabilities And Check
    Log To Console    Step ${index}: Get PDCCH FCE Capabilities And Check
    ${param_name_mapping}    Create Dictionary    Tool Name=fullToolName    Abbreviated Tool Name=toolName    Description=toolDescription
    ...    Version=toolVersion    Category=toolCategory    Support Release(s) \\ NIDD adaptationId(s)=supportedAdaptationVersions
    ${ParmName_Excel_list}    Get Dictionary Keys    ${param_name_mapping}
    ${FCT_Info}    FCT_Excel.get_FCT_info    ${TEST_LOG_DIRECTORY}/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${ParmName_Excel_list}
    ${feature_filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Run Keyword If    '${feature.__len__()}'=='${0}'    Install New PDCCH FCT To NetAct
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Should Be Equal As Integers    ${feature.__len__()}    ${1}
    ${feature_netact}    Set Variable    ${feature[0]}
    ${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    ${multi_supportedAdaptationVersions}    Pop From Dictionary    ${feature_netact}    supportedAdaptationVersions
    ${supportedAdaptationVersions}    Create List
    FOR    ${sub_list}    IN    @{multi_supportedAdaptationVersions}
        Append To List    ${supportedAdaptationVersions}    @{sub_list}
    END
    ${excel_supportedAdaptationVersions}    Pop From Dictionary    ${FCT_Info}    Support Release(s) \\ NIDD adaptationId(s)
    Sort List    ${excel_supportedAdaptationVersions}
    Sort List    ${supportedAdaptationVersions}
    Lists Should Be Equal    ${supportedAdaptationVersions}    ${excel_supportedAdaptationVersions}
    ${Category}    Pop From Dictionary    ${FCT_Info}    Category
    ${Category}    Set Variable If    '${Category}'=='None'    ${EMPTY}    ${Category}
    Set To Dictionary    ${FCT_Info}    Tool Name    ${FCT_Info["Abbreviated Tool Name"]}_Configuration
    Set To Dictionary    ${FCT_Info}    Category    ${Category}
    FOR    ${param}    IN    @{ParmName_Excel_list}
        ${netact_param_name}    Get From Dictionary    ${param_name_mapping}    ${param}
        Should Be Equal As Strings    ${FCT_Info["${param}"]}    ${feature_netact["${netact_param_name}"]}
    END

Step ${index}: Get PUCCH FctMetadata And Check
    Log To Console    Step ${index}: Get PUCCH FctMetadata And Check
    ${additionalInputParameters}    Get Fct Metadata On NetAct    ${NRBTS_RELEASE}    type=additionalInputParameters    toolName=PUCCH
    ${ADDIN_Param}    FCT_Excel.get_default_value_ADDIN    ${TEST_LOG_DIRECTORY}/${PUCCH_FCT_FILE_NAME}    PARAMETER-METADATA
    ${param_dic_excel}    Create Dictionary
    ${param_dic_netact}    Create Dictionary
    FOR    ${param}    IN    @{ADDIN_Param}
        Set To Dictionary    ${param_dic_excel}    ${param["Parent Parameter"]}.${param["Abbreviation"]}    ${param["Default Value"]}
    END
    FOR    ${param}    IN    @{additionalInputParameters}
        ${defaultValue}    Pop From Dictionary    ${param}    defaultValue    ${None}
        Set To Dictionary    ${param_dic_netact}    ${param["name"]}    ${defaultValue}
    END
    Dictionaries Should Be Equal    ${param_dic_excel}    ${param_dic_netact}
    Set Test Variable    ${PUCCH_ADDIN_PARAMS_NETACT}    ${additionalInputParameters}

Step ${index}: Get PDCCH FctMetadata And Check
    Log To Console    Step ${index}: Get PDCCH FctMetadata And Check
    ${additionalInputParameters}    Get Fct Metadata On NetAct    ${NRBTS_RELEASE}
    ${ADDIN_Param}    FCT_Excel.get_default_value_ADDIN    ${TEST_LOG_DIRECTORY}/${PDCCH_FCT_FILE_NAME}    PARAMETER-METADATA
    ${param_dic_excel}    Create Dictionary
    ${param_dic_netact}    Create Dictionary
    FOR    ${param}    IN    @{ADDIN_Param}
        Set To Dictionary    ${param_dic_excel}    ${param["Parent Parameter"]}.${param["Abbreviation"]}    ${param["Default Value"]}
    END
    FOR    ${param}    IN    @{additionalInputParameters}
        ${defaultValue}    Pop From Dictionary    ${param}    defaultValue    ${None}
        Set To Dictionary    ${param_dic_netact}    ${param["name"]}    ${defaultValue}
    END
    Dictionaries Should Be Equal    ${param_dic_excel}    ${param_dic_netact}
    Set Test Variable    ${ADDIN_PARAMS_NETACT}    ${additionalInputParameters}

Step ${index}: PUCCH CalculateConfiguration And Check
    Log To Console    Step ${index}: PUCCH CalculateConfiguration And Check
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${f_list_before}    SSHLibrary.List Files In Directory    /d/oss/global/var/racprs/fce/tmp
    ${target_DN}    Evaluate    random.choice(${LIST_NRCELL_DN})    modules=random, sys
    ${list_target_DN}    Create List    ${target_DN}
    Set Test Variable    ${list_target_DN}
    ${cmd}    ${list_ADDIN_params}    Create PUCCH calculateConfiguration Command    ${list_target_DN}    ${PUCCH_ADDIN_PARAMS_NETACT}
    ...    ${NRBTS_RELEASE}    ${PLAN_NAME}_PUCCH
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    ${detail_ines}    Get Regexp Matches    ${stdout}    \\s+Details:\\s+\{.*\}
    ${list_detail}    Create List
    ${dic_modified_params}    Create Dictionary
    FOR    ${line}    IN    @{detail_ines}
        ${str_head}    Fetch From Left    ${line}    {
        ${dic_detail}    Evaluate    ${line.replace('${str_head.strip()}','').strip()}
        ${params}    Create Dictionary    additionalOutputParameters    ${dic_detail['additionalOutputParameters']}
        Set To Dictionary    ${dic_modified_params}    ${dic_detail['distName']}    ${params}
    END
    Check Feedback Json    ${dic_modified_params}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${PLAN_NAME}_PUCCH.xml    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    plan_name=${PLAN_NAME}_PUCCH    operation_type=plan    ui_values=${True}
    ${f_list_after}    SSHLibrary.List Files In Directory    /d/oss/global/var/racprs/fce/tmp
    Remove Values From List    ${f_list_after}    @{f_list_before}
    FOR    ${f}    IN    @{f_list_after}
        Continue For Loop If    not ${f.endswith(".zip")}
        SSHLibrary.Get File    /d/oss/global/var/racprs/fce/tmp/${f}    ${TEST_LOG_DIRECTORY}/${f}
        ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${TEST_LOG_DIRECTORY}/${f} -d ${TEST_LOG_DIRECTORY}/tmpFCT
        Should Be Equal As Integers    ${rc}    ${0}
    END
    ${cur_tmp_fct_files}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}/tmpFCT
    FOR    ${dn}    IN    @{list_target_DN}
        List Should Contain Value    ${cur_tmp_fct_files}    ${dn.replace('/','_')}.xlsx
    END

Step ${index}: PDCCH CalculateConfiguration And Check
    Log To Console    Step ${index}: PDCCH CalculateConfiguration And Check
    ${cmd}    ${list_ADDIN_params}    Create PDCCH calculateConfiguration Command    ${list_target_DN}    ${ADDIN_PARAMS_NETACT}
    ...    ${NRBTS_RELEASE}    ${PLAN_NAME}    ${PLAN_NAME}_PUCCH
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    Set Test Variable    ${MODIFIED_PARAMS}    ${list_ADDIN_params}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${PLAN_NAME}.xml    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    plan_name=${PLAN_NAME}    operation_type=plan    ui_values=${True}

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    Set Test Variable    ${NEED_RECOVER}    ${True}
    NetAct Provision Plan    plan_name=${PLAN_NAME}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${PLAN_NAME}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Provision Plan    plan_name=${PLAN_NAME}_backup    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Set Test Variable    ${NEED_RECOVER}    ${False}

Step ${index}: Check Additional Param In Actual Plan
    Log To Console    Step ${index}: Check Additional Param In Actual Plan
    vDU Backup SCF From Test Line    scf_after_apply.xml
    ${scf_content}    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_after_apply.xml
    FOR    ${params}    IN    @{MODIFIED_PARAMS}
        Check Params Of DN    ${scf_content}    ${params}
    END

Unzip FCT
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}
    Should Be Equal As Integers    ${rc}    ${0}
    ${pucch_fct_name}    Set Variable    FCT_PUCCH_Configuration.xlsx
    ${pdcch_fct_name}    Set Variable    FCT_PDCCH_MultiRelease.xlsx
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${pdcch_fct_name}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/${pucch_fct_name}
    [Return]    ${pucch_fct_name}    ${pdcch_fct_name}

Install New PUCCH FCT To NetAct
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${TEST_LOG_DIRECTORY}/FCT_PUCCH_Configuration.xlsx    ${REMOTE_PUCCH_FCT_FILE}
    Install FCT On NetAct    ${REMOTE_PUCCH_FCT_FILE}

Install New PDCCH FCT To NetAct
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${TEST_LOG_DIRECTORY}/FCT_PDCCH_MultiRelease.xlsx    ${REMOTE_PDCCH_FCT_FILE}
    Install FCT On NetAct    ${REMOTE_PDCCH_FCT_FILE}

Create PDCCH calculateConfiguration Command
    [Arguments]    ${list_target_DN}    ${params_NetAct}    ${adaptationVersions}    ${outputPlanName}    ${inputPlanName}
    ${list_ADDIN_params}    Generate Random FCT ADDIN Params For TargetDNs    ${list_target_DN}    ${params_NetAct}    ${ignore_param_list_F}
    ${str_additionalInputParameters}    Convert To String    ${list_ADDIN_params}
    ${str_additionalInputParameters}    Set Variable    ${str_additionalInputParameters.replace("u'","\"").replace("'","\"")}
    ${targetObjects}    Create List
    FOR    ${dn}    IN    @{list_target_DN}
        Append To List    ${targetObjects}    PLMN-PLMN/${dn}
    END
    ${str_targetObjects}    Catenate    SEPARATOR=,    @{targetObjects}
    ${cmd}    Catenate    racclimx.sh -op FCT_Create_Configuration_Plan -targetObjects "${str_targetObjects}"
    ...    -inputConfigurationType plan -toolName "PDCCH" -additionalInputParameters '${str_additionalInputParameters}'
    ...    -adaptationVersions ${adaptationVersions} -planName ${inputPlanName} -outputPlanName ${outputPlanName} -v
    [Return]    ${cmd}    ${list_ADDIN_params}

Create PUCCH calculateConfiguration Command
    [Arguments]    ${list_target_DN}    ${params_NetAct}    ${adaptationVersions}    ${outputPlanName}
    ${list_ADDIN_params}    Generate Random FCT ADDIN Params For TargetDNs    ${list_target_DN}    ${params_NetAct}    ${ignore_param_list_F}
    ${str_additionalInputParameters}    Convert To String    ${list_ADDIN_params}
    ${str_additionalInputParameters}    Set Variable    ${str_additionalInputParameters.replace("u'","\"").replace("'","\"")}
    ${targetObjects}    Create List
    FOR    ${dn}    IN    @{list_target_DN}
        Append To List    ${targetObjects}    PLMN-PLMN/${dn}
    END
    ${str_targetObjects}    Catenate    SEPARATOR=,    @{targetObjects}
    ${cmd}    Catenate    racclimx.sh -op FCT_Create_Configuration_Plan -targetObjects "${str_targetObjects}" -inputConfigurationType actual
    ...    -toolName "PUCCH" -saveFeedbackToFile feedBack_${outputPlanName}
    ...    -adaptationVersions ${adaptationVersions} -outputPlanName ${outputPlanName} -v
    Set Test Variable    ${FEEDBACK_JSON_NAME}    feedBack_${outputPlanName}.json
    [Return]    ${cmd}    ${list_ADDIN_params}

Check Params Of DN
    [Arguments]    ${scf_content}    ${params}
    ${distName}    Get From Dictionary    ${params}    distName
    ${parameters}    Get From Dictionary    ${params}    parameters
    ${list_param_names}    Get Dictionary Keys    ${parameters}
    FOR    ${p_name}    IN    @{list_param_names}
        ${cur_val}    L_XML.Get Element Text    ${scf_content}
        ...    .//managedObject[@distName="${distName}"]/list[@name="pdcchAutoConfig"]/item/p[@name="${p_name.split(".")[-1]}"]
        Should Be Equal As Strings    ${cur_val}    ${parameters["${p_name}"]}
    END

Full Commission SCF Via Rest
    [Arguments]    ${scf_path}
    ##-12840    vDU Login By Rest
    ##-12840    ${plan_id}    ${action_id}    ${validate_id}    Upload And Validate Plan
    ##-12840    ...    plan_file=${scf_path}    plan_name=back_up_plan    validate=${True}
    ##-12840    Activate Plan By REST    ${plan_id}
    ##-12840    vdu.disconnect
    ${out}   Parameter Operation    operation=full_commission   product_type=vdu    scf_path=${scf_path}
    Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Check Feedback Json
    [Arguments]    ${dic_modified_params}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.File Should Exist    ${FEEDBACK_JSON_PATH}/${FEEDBACK_JSON_NAME}
    SSHLibrary.Get File    ${FEEDBACK_JSON_PATH}/${FEEDBACK_JSON_NAME}    ${TEST_LOG_DIRECTORY}/${FEEDBACK_JSON_NAME}
    ${f_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${FEEDBACK_JSON_NAME}
    ${list_feedback}    Evaluate    ${f_content}
    ${list_dn_feedback}    Set Variable    ${list_feedback[0]["operationResults"]}
    FOR    ${dn_feedback}    IN    @{list_dn_feedback}
        Check Feedback of DN    ${dn_feedback}    ${dic_modified_params}
    END

Check Feedback of DN
    [Arguments]    ${dn_feedback}    ${dic_modified_params}
    Should Be Equal As Strings    ${dn_feedback['operationStatus']}    Finished    ignore_case=True
    ${checks}    Get From Dictionary    ${dn_feedback}    checks
    FOR    ${check}    IN    @{checks}
        Should Not Be Equal As Strings    ${check['result']}    error    ignore_case=True
    END
    Dictionary Should Contain Sub Dictionary    ${dn_feedback}    ${dic_modified_params["${dn_feedback['distName']}"]}
