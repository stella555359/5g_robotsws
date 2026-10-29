*** Settings ***
Documentation       Test case for CB013031_015
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${toolName}    PDCCH
${FCT_Folder_NetAct}    /d/oss/global/var/racprs/work/
${NEED_RECOVERY}    False
${nrcell_id}    1

*** Keywords ***
SyVe_CM_CB013031_064_015_CM_Feature_Configuration_Engine_Run_in_NMS_with_CACVAS
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for:RAN_ST_CB013031_015_CM_Feature Configuration Engine (Feature Configuration Tool) run in NMS with CACVAS for configure a feature
    ...    Only need to support case 015, 064 is not needed to support since related to PNP
    ...
    ...    Pass criteria: parameters are auto config correctly
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.08.2025 - New Case by Kang Lixin
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Prepare Env To Enable CB013031
    Step 2: Prepare Plan With Optional Params Removed Which Related To PDCCH
    Step 3: Check FCE Installed On Netact
    Step 4: Start Calculate With Delta Plan And Check Results
    Step 5: Check Additional Parameters In Generated Plan
    Step 6: Check Auto-Config Parameters In Generated Plan
    Step 7: Provision Plan And Check Site Status
    Step 8: Check Additional Parameters In Actual Plan
    Step 9: Check Auto-Config Parameters In Actual Plan
    Step 10: Provision Backup Plan

Step ${index}: Prepare Env To Enable CB013031
    Log To Console    Step ${index}: Prepare Env To Enable CB013031
    Modify Param Value From Admin   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    actCondAutoConfValCalc    true
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Prepare Plan With Optional Params Removed Which Related To PDCCH
    Log To Console    Step ${index}: Prepare Plan With Optional Params Removed Which Related To PDCCH
    ${timestamp}    Generate Formatted Timestamp
    ${target_plan_name}    Set Variable    CB013031_064_plan_with_param_change_${timestamp}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${param_dic}    Create Dictionary    actTddCsiRsOpt=${EMPTY}    #actBbPoolTddFr1=${EMPTY}
    ${plan}    NetAct Create Plan    ${target_plan_name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   &{param_dic}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}"]
    ${param_dic}    Create Dictionary    numOfPagingFrames=${EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}  &{param_dic}
    Set Test Variable    ${inputPlanName}    ${target_plan_name}

Modify Param Value From Admin
    [Arguments]    ${scf_dn}    ${param}    ${expect_value}
    [Documentation]    Helper keyword used for set parameter value to expect_value from admin.
    ${origin_value}    Run Keyword And Ignore Error    Get Parameter Value From WebEM    ${scf_dn}    ${param}
    Return From Keyword If    "${origin_value}"=="${expect_value}"    ${origin_value}
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${scf_dn}   parameter=${param}    value=${expect_value}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Check SBTS SMOD RMOD Cells Alarms
	Check WebEM After Modify Parameters    ${scf_dn}    ${param}=${expect_value}
    [Return]    ${origin_value}

Step ${index}: Check FCE Installed On Netact
    Log    Step ${index}: Check FCE Installed On Netact   console=True
    ${filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${FCT_features}    Get FCT Features On NetAct    ${filter}
    Run Keyword If    '${FCT_features.__len__()}'=='${0}'    Install New FCT On NetAct

Step ${index}: Start Calculate With Delta Plan And Check Results
    Log    Step ${index}: Start Caculate With Delta Plan And Check Results   console=True
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${outputPlanName}    outputPlan_MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${afterCalculateActualPlanName}    afterCalculate_actualPlanName_MRBTS-${mrbts_id}_${timestamp}
#    Set Test Variable    ${debugFileName}    DebugFile_MRBTS-${mrbts_id}_${timestamp}
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
    ${target_dn_list}    Create List    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ${addIn_params_list}    Generate Random FCT ADDIN Params For TargetDNs    ${target_dn_list}    ${addInputParamList}
    ${str_additionalInputParameters}    Convert To String    ${addIn_params_list}
    ${str_additionalInputParameters}    Replace String Using Regexp    ${str_additionalInputParameters}
    ...    'pdcchIntent.bwpChBwDedicated2': '\\d+MHz',   ${EMPTY}     # can't set bwpChBwDedicated2 in bts1894
    ${str_additionalInputParameters}    Set Variable    ${str_additionalInputParameters.replace("u'","\"").replace("'","\"")}
    Set Test Variable    ${addIn_params_list}
    Calculate And Check Results On NetAct    PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    ${str_additionalInputParameters}    ${adaptationVersion}    ${outputPlanName}    planName=${inputPlanName}    inputConfType=plan
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${outputPlanName}.csv
    ...    dist_names=${dn_list}    plan_name=${outputPlanName}    operation_type=plan    ui_values=true

Step ${index}: Check Additional Parameters In Generated Plan
    Log To Console    Step ${index}: Check Additional Parameter In Generated Plan
    ${scf_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/${outputPlanName}.csv
    FOR    ${item}    IN    @{addIn_params_list}
        Remove From Dictionary    ${item['parameters']}    pdcchIntent.bwpChBwDedicated2    # can't set bwpChBwDedicated2 in bts1894
        Check Parameter Value From SCF For PDCCH    ${scf_content}    PLMN-PLMN/${item['distName']}    ${item['parameters']}
    END

Step ${index}: Check Auto-Config Parameters In Generated Plan
    Log To Console    Step ${index}: Check Auto-Config Parameters In Generated Plan
    ${scf_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/${outputPlanName}.csv
    ${value}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}"]/p[@name="actTddCsiRsOpt"]
    Should Be Equal As Strings    ${value}    ${EMPTY}
    ${value}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}"]/p[@name="numOfPagingFrames"]
    Should Be Equal As Strings    ${value}    ${EMPTY}

Step ${index}: Check Additional Parameters In Actual Plan
    Log To Console    Step ${index}: Check Additional Parameter In Actual Plan
    FOR     ${item}    IN    @{addIn_params_list}
        ${objectDN}    Set Variable    ${item["distName"]}
        ${addInParameters_dic}    Set Variable    ${item["parameters"]}
        Log To Console    Check Additional Parameters For ${objectDN}
        ${scf_content}    L_XML.Parse Xml     ${Test Results Dir}/NetActLogs/${afterCalculateActualPlanName}.csv
        ${pdcchParams}   L_XML.Get Elements
        ...    ${scf_content}    .//managedObject[@distName="PLMN-PLMN/${objectDN}"]/list[@name="pdcchAutoConfig"]/item/p
        ${result_value_dict}    Create Dictionary
        FOR    ${item}    IN    @{pdcchParams}
           ${key}    L_XML.Get Element Attribute    ${item}    name
           ${value}    L_XML.Get Element Text    ${item}
           Set To Dictionary    ${result_value_dict}    pdcchIntent.${key}=${value}
        END
        Dictionary Should Contain Sub Dictionary    ${result_value_dict}    ${addInParameters_dic}
    END

Step ${index}: Check Auto-Config Parameters In Actual Plan
    Log To Console    Step ${index}: Check Auto-Config Parameters In Actual Plan
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${parameter}    Create Dictionary    actTddCsiRsOpt=false    #actBbPoolTddFr1=true
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}   ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    numOfPagingFrames=quaterT
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ...    ui_values=true    &{parameter}

#Step ${index}: Check Debug File Content Has Auto-Config Parameters
#    Log To Console    Step ${index}: Check Audit Report Content Not Empty
#    Get File From NetAct CMWAS Node    /d/oss/global/var/racprs/fce/tmp/MRBTS-${mrbts_id}*    ${Test Results Dir}/NetActLogs/${debugFileName}

Step ${index}: Provision Plan And Check Site Status
    Log    Step ${index}: Provision Plan And Check Site Status    console=True
    Set Test Variable    ${NEED_RECOVERY}    True
    NetAct Provision Plan    plan_name=${outputPlanName}    dist_names=${dn_list}    backup_plan_name=${outputPlanName}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${afterCalculateActualPlanName}.csv
    ...    dist_names=${dn_list}   plan_name=${afterCalculateActualPlanName}  operation_type=actual    ui_values=true

Step ${index}: Provision Backup Plan
    Log    Step ${index}: Provision Backup Plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${outputPlanName}_backup.csv
    ...    dist_names=${dn_list}   plan_name=${outputPlanName}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${outputPlanName}_backup    dist_names=${dn_list}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${NEED_RECOVERY}    False
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Install New FCT On NetAct
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${Test Results Dir}/TestFiles/FCT_Files/${fct_name}    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-13031_064.xlsx
    SSHLibrary.Close Connection
    Install FCT On NetAct    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-13031_064.xlsx

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
    Modify Param Value From Admin   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    actCondAutoConfValCalc    false
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms
    FOR    ${plan}    IN    @{Delete_Plan_list}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan}
    END
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-13031_064.xlsx
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure
    ...    SSHLibrary.Execute Command    rm ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-13031_064.xlsx
    Common Test Teardown
    SSHLibrary.Close All Connections
