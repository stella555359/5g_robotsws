*** Settings ***
Documentation       Test case for SyVe_CM_CB009451_G
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${parent_param}    pdcchIntent
${toolName}    PDCCH
${FCT_Folder_NetAct}    /d/oss/global/var/racprs/work/
${NEED_RECOVERY}    False
&{modify_parameter_dic}   btsName=Test-9451-G

*** Keywords ***
SyVe_CM_CB009451-G_001_Audit_Recommended_Feature_Configuration_Using_NetAct
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for TA_RAN_ST_CB009451-A_001_CM_Installing Feature Configuration Engine in the online WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.08.2023 - New Case
    ...  - 21.02.2053 - kanglixin: Update code from multi bts to one bts
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    Author-lixin.kang@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Check FCE Installed On Netact
    Step 2: Start Audit With Actual Plan And Check Results
    Step 3: Provision Plan And Check Site Status
    Step 4: Check Additional Param In Actual Plan
    Step 5: Check Audit Report Content Not Empty
    Step 6: Provision Backup Plan
    Step 7: Start Audit With Delta Plan And Check Results
    Step 8: Provision Plan And Check Site Status
    Step 9: Check Additional Param In Actual Plan
    Step 10: Check Modified Parameter in Netact
    Step 11: Check Audit Report Content Not Empty
    Step 12: Provision Backup Plan
    Step 13: Start Audit With Imported Plan And Check Results
    Step 14: Check Additional Param In Generated Plan
    Step 15: Check Audit Report Content Not Empty

Step ${index}: Check FCE Installed On Netact
    Log    Step ${index}: Check FCE Installed On Netact   console=True
    ${filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${FCT_features}    Get FCT Features On NetAct    ${filter}
    Run Keyword If    '${FCT_features.__len__()}'=='${0}'    Install New FCT On NetAct

Step ${index}: Start Audit With ${inputType} Plan And Check Results
    Log    Step ${index}: Start Audit With ${inputType} Plan And Check Results   console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    -
    Set Test Variable    ${mrbts_id}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${outputPlanName}    outputPlan_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${inputPlanName}    inputPlan_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${afterAuditActualPlanName}    afterAudit_actualPlanName_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${auditReportName}    AuditReportFromInputPlan_MRBTS-${mrbts_id}_${timestamp}
    Append To List    ${Delete_Plan_list}    ${inputPlanName}    ${outputPlanName}    ${outputPlanName}_backup
    ${dn_list}    Create List    ${MRBTS_DN}
    Set Test Variable    ${dn_list}
    NetAct CM Upload    dist_names=${dn_list}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=bacup_plan.csv
    ...    dist_names=${dn_list}    plan_name=bacup_plan    operation_type=actual
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${xml_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    ${version}    Set Variable    ${MO_items['version']}
    ${nrbts_adap_version}    Fetch From Left     ${version}    _
    ${adaptationVersion}    Set Variable    com.nokia.srbts.nrbts:${nrbts_adap_version}
    ${addInputParamList}    Get FCT Metadata On NetAct    ${adaptationVersion}
    ${xml_content}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/bacup_plan.csv
    ${nrcell_list}    L_XML.Get Elements    ${xml_content}    .//managedObject[@class="NRCELL"][contains(@distName,"${MRBTS_DN}")]
    ${random1}    Evaluate    random.randint(0,${nrcell_list.__len__()-1})    modules=random, sys
    ${targetObj1}    L_XML.Get Element Attribute    ${nrcell_list[${random1}]}    distName
    ${target_dn_list}    Create List    ${targetObj1}
    ${addIn_params_list}    Generate Random FCT ADDIN Params For TargetDNs    ${target_dn_list}    ${addInputParamList}
    ${str_additionalInputParameters}    Convert To String    ${addIn_params_list}
    ${str_additionalInputParameters}    Set Variable    ${str_additionalInputParameters.replace("u'","\"").replace("'","\"")}
    Set Test Variable    ${addIn_params_list}
    ${inputConfType}    Set Variable If    "${inputType}"=="Actual"    actual    plan
    ${inputPlanName}    Set Variable If    "${inputType}"=="Actual"    ${None}    ${inputPlanName}
    Run Keyword If    "${inputType}"=="Imported"    NetAct Import Plan
    ...    local_dir=${Test Results Dir}/NetActLogs/   file_name=bacup_plan.csv    plan_name=${inputPlanName}    ui_values=${True}
    Run Keyword If    "${inputType}"=="Delta"    NetAct Create Delta Plan For Two BTS    ${inputPlanName}
    ${feedback}    Audit On NetAct And Check Results    ${targetObj1}   ${str_additionalInputParameters}   ${adaptationVersion}
    ...    ${outputPlanName}   planName=${inputPlanName}    inputConfType=${inputConfType}   compareExportDifferenceReport=${auditReportName}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${outputPlanName}.csv
    ...    dist_names=${dn_list}    plan_name=${outputPlanName}    operation_type=plan    ui_values=true

Step ${index}: Check Additional Param In Generated Plan
    Log To Console    Step ${index}: Check Additional Param In Generated Plan
    ${scf_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/${outputPlanName}.csv
    FOR    ${item}    IN    @{addIn_params_list}
        Check Parameter Value From SCF For PDCCH    ${scf_content}    ${item['distName']}    ${item['parameters']}
    END

Step ${index}: Check Additional Param In Actual Plan
    Log To Console    Step ${index}: Check Additional Param In Actual Plan
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${afterAuditActualPlanName}.csv
    ...    dist_names=${dn_list}    plan_name=${afterAuditActualPlanName}    operation_type=actual    ui_values=true
    ${scf_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/${afterAuditActualPlanName}.csv
    FOR    ${item}    IN    @{addIn_params_list}
        Check Parameter Value From SCF For PDCCH    ${scf_content}    ${item['distName']}    ${item['parameters']}
    END

Step ${index}: Check Audit Report Content Not Empty
    Log To Console    Step ${index}: Check Audit Report Content Not Empty
    Get File From NetAct CMWAS Node    /d/oss/global/var/racops/export/${auditReportName}    ${Test Results Dir}/NetActLogs/${auditReportName}
    ${file_content}    OperatingSystem.Get File    ${Test Results Dir}/NetActLogs/${auditReportName}
    Should Not Be Empty    ${file_content}
    Should Contain    ${file_content}    pdcchAutoConfig
    ${columns_not_empty}    check_columns_not_empty_csv    ${Test Results Dir}/NetActLogs/${auditReportName}
    Should Be True    ${columns_not_empty}

Step ${index}: Provision Plan And Check Site Status
    Log    Step ${index}: Provision Plan And Check Site Status    console=True
    Set Test Variable    ${NEED_RECOVERY}    True
    NetAct Provision Plan    plan_name=${outputPlanName}    dist_names=${dn_list}    backup_plan_name=${outputPlanName}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Provision Backup Plan
    Log    Step ${index}: Provision Backup Plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${outputPlanName}_backup.csv
    ...    dist_names=${dn_list}   plan_name=${outputPlanName}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${outputPlanName}_backup    dist_names=${dn_list}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${NEED_RECOVERY}    False
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Modified Parameter in Netact
    Log    Step ${index}: Check Modified Parameter in Netact    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${MRBTS_DN}    ui_values=false    &{modify_parameter_dic}

Install New FCT On NetAct
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${Test Results Dir}/TestFiles/FCT_Files/${fct_name}    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx
    SSHLibrary.Close Connection
    Install FCT On NetAct    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx

NetAct Create Delta Plan For Two BTS
    [Arguments]     ${planName}
    ${plan}    NetAct Create Plan    ${planName}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${MRBTS_DN}    &{modify_parameter_dic}

Check Objects Status
    [Arguments]    ${path}    ${expected_status}    ${timeout}=60    ${connection}=None
    ${all_status}    ${all_objects}    Run Keyword And Ignore Error    coam.Assert Any    class_name=${path}    connection=${connection}
    Return From Keyword If    "${all_status}"=="FAIL"    PASS
    coam.Assert Every    ${path}    ${expected_status}    timeout=${timeout}    connection=${connection}

Unzip FCT
    [Arguments]    ${zip_file}    ${target_path}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${target_path}
    Should Be Equal As Integers    ${rc}    ${0}
    ${fct_name}    Should Match Regexp    ${out_put}    \\w+\\.xlsx
    OperatingSystem.File Should Exist    ${target_path}/${fct_name}
    [Return]    ${fct_name}

TC Setup
    Log    TC Setup    console=True
    Common Test Setup
    ${fce_worker_name}    ${fct_file_name}    Download FCE Modules For Current SW
    OperatingSystem.Run    mkdir ${Test Results Dir}/TestFiles/FCT_Files
    ${fct_name}    Unzip FCT    ${Test Results Dir}/TestFiles/${fct_file_name}    ${Test Results Dir}/TestFiles/FCT_Files/
	${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    ...    Support Release(s) \\ NIDD adaptationId(s)
    ${FCT_Info}    FCT_Excel.get_FCT_info    ${Test Results Dir}/TestFiles/FCT_Files/${fct_name}    GENERAL-METADATA    ${ParmName_Excel_list}
    Set Test Variable    ${FCT_Info}
    Set Test Variable    ${fct_name}
    ${Delete_Plan_list}    Create List
    Set Test Variable    ${Delete_Plan_list}
    Cleanup pdcchAutoConfig via Delta Recomission

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown

Particular Teardown
    Run Keyword If    ${NEED_RECOVERY}    NetAct Provision Plan    plan_name=${outputPlanName}_backup    dist_names=${dn_list}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    FOR    ${plan}    IN    @{Delete_Plan_list}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan}
    END
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure
    ...    SSHLibrary.Execute Command    rm ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-G_001.xlsx
    Common Test Teardown
    SSHLibrary.Close All Connections
