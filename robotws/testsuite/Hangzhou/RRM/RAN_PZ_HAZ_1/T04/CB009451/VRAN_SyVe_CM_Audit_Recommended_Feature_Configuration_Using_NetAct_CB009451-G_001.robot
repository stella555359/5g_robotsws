*** Settings ***
Documentation       Test suite for SyVe_CM_CB009451_G
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Library           ../Resources/python/FCT_Excel.py

*** Variables ***
${parent_param}    pdcchIntent
${toolName}    PDCCH
${FCT_Folder_NetAct}    /d/oss/global/var/racprs/work/
@{ignore_param_list}    (rel >=24R1) bwpChBwSmallMin:    (rel >=24R1) bwpChBwDedicated3:   #can not be configured for Cloud BTS in this release

*** Keywords ***
TC__VRAN_SyVe_CM_Audit_Recommended_Feature_Configuration_Using_NetAct_CB009451-G_001
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.07.2023, lixin.kang@nokia-sbell.com, draft
    Log To Console    ${TEST_NAME} start.
    Step 1: Check FCE Installed On Netact
    Step 2: Start Audit And Check Results
    Step 3: Check Additional Param In Generated Plan
    Step 4: Check Audit Report Content Not Empty

Step ${index}: Check FCE Installed On Netact
    Log To Console    Step ${index}: Check FCE Installed On Netact
    ${filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${FCT_features}    Get FCT Features On NetAct    ${filter}
    Run Keyword If    '${FCT_features.__len__()}'=='${0}'    Install New FCT On NetAct

Step ${index}: Start Audit And Check Results
    Log To Console    Step ${index}: Start Audit And Check Results
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=bacup_plan.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}  plan_name=backup_plan   operation_type=actual
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/bacup_plan.csv
    ${MO_items}    L_XML.Get Element Attributes    ${xml_content}    .//managedObject[@class="NRBTS"]
    ${version}    Set Variable    ${MO_items['version']}
    ${nrbts_adap_version}    Fetch From Left     ${version}    _
    ${adaptationVersion}    Set Variable    com.nokia.srbts.nrbts:${nrbts_adap_version}
    ${addInputParamList}    Get FCT Metadata On NetAct    ${adaptationVersion}
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${MRBTS_ID}_${timestamp}
    Set Test Variable    ${outputPlanName}    outputPlan_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${inputPlanName}    inputPlan_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${auditReportName}    AuditReportFromInputPlan_MRBTS-${mrbts_id}_${timestamp}
    ${xml_content}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/bacup_plan.csv
    ${nrcell_list}    L_XML.Get Elements    ${xml_content}    .//managedObject[@class="NRCELL"]
    ${random}    Evaluate    random.randint(0,${nrcell_list.__len__()-1})    modules=random, sys
    ${targetObj}    L_XML.Get Element Attribute    ${nrcell_list[${random}]}    distName
    ${target_dn_list}    Create List    ${targetObj}
    ${addIn_params_list}    Generate Random FCT ADDIN Params For TargetDNs    ${target_dn_list}    ${addInputParamList}    ${ignore_param_list}
    ${str_additionalInputParameters}    Convert To String    ${addIn_params_list}
    ${str_additionalInputParameters}    Set Variable    ${str_additionalInputParameters.replace("u'","\"").replace("'","\"")}
    Set Test Variable    ${addIn_params_list}
    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}/  file_name=bacup_plan.csv   plan_name=${inputPlanName}    ui_values=${True}
    ${feedback}    Audit On NetAct And Check Results    ${targetObj}    ${str_additionalInputParameters}    ${adaptationVersion}
    ...    ${outputPlanName}    planName=${inputPlanName}    inputConfType=plan    compareExportDifferenceReport=${auditReportName}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${outputPlanName}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}  plan_name=${outputPlanName}   operation_type=plan    ui_values=true

Step ${index}: Check Additional Param In Generated Plan
    Log To Console    Step ${index}: Check Additional Param In Generated Plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${TEST_LOG_DIRECTORY}/${outputPlanName}.csv
    FOR    ${item}    IN    @{addIn_params_list}
        Check Actual Parameter Value From Output Plan    ${scf_content}    ${item['distName']}    ${item['parameters']}
    END

Step ${index}: Check Audit Report Content Not Empty
    Log To Console    Step ${index}: Check Audit Report Content Not Empty
    Get File From NetAct CMWAS Node    /d/oss/global/var/racops/export/${auditReportName}    ${TEST_LOG_DIRECTORY}/${auditReportName}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${auditReportName}
    Should Not Be Empty    ${file_content}
    Should Contain    ${file_content}    pdcchAutoConfig

Install New FCT On NetAct
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${TEST_LOG_DIRECTORY}/FCT_Files/${fct_name}    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx
    SSHLibrary.Close Connection
    Install FCT On NetAct    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx

Check Actual Parameter Value From Output Plan
    [Arguments]    ${scf_content}    ${nrcell_dn}    ${expected_value_dic}
    ${pdcchParams}   L_XML.Get Child Elements    ${scf_content}    .//managedObject[@distName="${nrcell_dn}"]/list[@name="pdcchAutoConfig"]/item
    FOR    ${item}    IN    @{pdcchParams}
        ${paramName}    L_XML.Get Element Attribute    ${item}    name
        ${paramValue}    L_XML.Get Element Text    ${item}
        Should Be Equal As Strings    ${paramValue}    ${expected_value_dic['${parent_param}.${paramName}']}
    END

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    ${fce_worker_f_name}    ${fct_file_f_name}    Download FCE Modules For Current SW    ${Trunk_Prefix}
    OperatingSystem.Run    mkdir ${TEST_LOG_DIRECTORY}/FCT_Files
    ${fct_name}    Unzip FCT    ${TEST_LOG_DIRECTORY}/${fct_file_f_name}    ${TEST_LOG_DIRECTORY}/FCT_Files/
    ${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    ...    Support Release(s) \\ NIDD adaptationId(s)
    ${FCT_Info}    FCT_Excel.get_FCT_info    ${TEST_LOG_DIRECTORY}/FCT_Files/${fct_name}    GENERAL-METADATA    ${ParmName_Excel_list}
    Set Test Variable    ${FCT_Info}
    Set Test Variable    ${fct_name}

Case Postcondition
    Log To Console    Case Postcondition
    Particular Teardown
    Common Test Teardown For AIC
    Teardown NetAct
    SSHLibrary.Close All Connections

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${outputPlanName}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${inputPlanName}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure
    ...    SSHLibrary.Execute Command    rm ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx

Unzip FCT
    [Arguments]    ${zip_file}    ${target_path}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${target_path}
    Should Be Equal As Integers    ${rc}    ${0}
    ${fct_name}    Should Match Regexp    ${out_put}    FCT_PDCCH_MultiRelease.xlsx
    OperatingSystem.File Should Exist    ${target_path}/${fct_name}
    [Return]    ${fct_name}