*** Settings ***
Documentation       Test case for SyVe_CM_CB009451_F
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/python/FCT_Excel.py

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${FCT_Folder_NetAct}    /d/oss/global/var/racprs/work
${Need_Recover}    ${False}

*** Keywords ***
SyVe_CM_CB009451-F_001_Configure_Optimize_Recalculate_Feature_With_Multi_BTSs_In_NetAct
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    New case for TA_RAN_ST_CB009451-F_001_CM_Configure optimize recalculate feature with Multi BTSs using NetAct
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 11.08.2023 - New Case
    ...    - 21.02.2053 - kanglixin: Update code from multi bts to one bts
    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Download And Install FCT on NetAct
    Step 2: Get And Check FCT Features On NetAct
    Step 3: Get And Check FCT Metadata On NetAct
    Step 4: Calculate And Check Result With Actual Type
    Step 5: Provision Calculated Output Plan
    Step 6: Check Additional Paramemters In Actual Plan
    Step 7: Provsion The Backup Plan
    Step 8: Calculate And Check Result With Plan Type
    Step 9: Check Additional Paramemters In Planned Plan

Step ${index}: Download And Install FCT on NetAct
    Log To Console    Step ${index}: Download And Install FCT on NetAct
    ${fce_worker_name}    ${fct_file_name}    Download FCE Modules For Current SW
    Set Test Variable    ${fce_worker_name}
    Set Test Variable    ${fct_file_name}
    OperatingSystem.Run    mkdir ${Test Results Dir}/TestFiles/FCT_Files
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output
    ...    unzip ${Test Results Dir}/TestFiles/${fct_file_name} -d ${Test Results Dir}/TestFiles/FCT_Files
    Should Be Equal As Integers    ${rc}    ${0}
    OperatingSystem.File Should Exist    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    ${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    ...    Support Release(s) \\ NIDD adaptationId(s)
    Set Test Variable    ${ParmName_Excel_list}
    ${FCT_Info}    FCT_Excel.get_FCT_info
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    GENERAL-METADATA    ${ParmName_Excel_list}
    Set Test Variable   ${FCT_Info}
    ${feature_filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Run Keyword If    '${feature.__len__()}'=='${0}'    Install New FCT On NetAct

Install New FCT On NetAct
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx
    ...    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-F_001.xlsx
    SSHLibrary.Close Connection
    Install FCT On NetAct    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-F_001.xlsx

Step ${index}: Get And Check FCT Features On NetAct
    Log To Console    Step ${index}: Get And Check FCT Features On NetAct
    ${FCT_features}    Get FCT Features On NetAct
    ${match}    Set Variable    ${False}
    run keyword if    "${FCT_Info["Category"]}"== "None"    Set To Dictionary    ${FCT_Info}    Category=
    run keyword if    "${FCT_Info["Tool Name"]}"== "PDCCH_Config_Recommendations"
    ...    Set To Dictionary    ${FCT_Info}    Tool Name    ${FCT_Info["Abbreviated Tool Name"]}_Configuration
    FOR    ${feature}    IN    @{FCT_features}
        ${tmp1}    Set Variable    "${feature["fullToolName"]}"=="${FCT_Info["Tool Name"]}"
        ${tmp2}    Set Variable    "${feature["toolName"]}"=="${FCT_Info["Abbreviated Tool Name"]}"
        ${tmp3}    Set Variable    "${feature["toolDescription"]}"=="${FCT_Info["Description"]}"
        ${tmp4}    Set Variable    "${feature["toolVersion"]}"=="${FCT_Info["Version"]}"
        ${tmp5}    Set Variable    "${feature["toolCategory"]}"=="${FCT_Info["Category"]}"
        ${features_list}    Change Adaptation Format    ${feature["supportedAdaptationVersions"]}
        Sort List    ${features_list}
        Sort List    ${FCT_Info["Support Release(s) \\ NIDD adaptationId(s)"]}
        ${tmp6}    Run Keyword And Return Status    Lists Should Be Equal
        ...    ${features_list}    ${FCT_Info["Support Release(s) \\ NIDD adaptationId(s)"]}
        ${match}    Set Variable If    ${tmp1} and ${tmp2} and ${tmp3} and ${tmp4} and ${tmp5} and ${tmp6}   ${True}    ${match}
    END
    Should Be True    ${match}

Change Adaptation Format
    [Arguments]    ${features}
    ${features_list}    create list
    FOR    ${item}    IN    @{features}
        Append To List    ${features_list}    ${item[0]}
    END
    [Return]    ${features_list}

Step ${index}: Get And Check FCT Metadata On NetAct
    Log To Console    Step ${index}: Get And Check FCT Metadata On NetAct
    ${names}    Split String    ${object_DN1}    /
    ${nrbts_name}    Get Regexp Matches    ${object_DN1}    NRBTS-\\d*
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${BTS_scf_initial}
    ${nrbts_element}   L_XML.Get Elements    ${scf_content}    .//managedObject[@distName="MRBTS-${mrbts_id1}/${nrbts_name[0]}"]
    ${nrbts_class}    L_XML.Get Element Attribute    ${nrbts_element[0]}    class
    ${nrbts_version}    L_XML.Get Element Attribute    ${nrbts_element[0]}    version
    ${adapt_sub1}    Fetch From Left    ${nrbts_class}    :
    ${adapt_sub2}    Fetch From Left    ${nrbts_version}    _
    ${adaptationVersions}    Set Variable    ${adapt_sub1}:${adapt_sub2}
    Set Test Variable    ${adaptationVersions}
    ${addInParams_NetAct}    Get FCT Metadata On NetAct    ${adaptationVersions}
    log    ${addInParams_NetAct}
    Set Test Variable    ${addInParams_NetAct}
    ${addInParams_NetAct_len}    Get Length    ${addInParams_NetAct}
    ${addInParams_Excel}    FCT_Excel.get_default_value_ADDIN
    ...    ${Test Results Dir}/TestFiles/FCT_Files/FCT_PDCCH_MultiRelease.xlsx    PARAMETER-METADATA
    log    ${addInParams_Excel}
    ${addInParams_Excel_len}    Get Length    ${addInParams_Excel}
    Should Be Equal As Integers    ${addInParams_NetAct_len}    ${addInParams_Excel_len}
    FOR    ${param_NetAct}    IN    @{addInParams_NetAct}
        ${contain_res}    Check Excel Contain NetAct Params    ${param_NetAct}    ${addInParams_Excel}
        Should Be True    ${contain_res}
    END

Check Excel Contain NetAct Params
    [Arguments]    ${param_NetAct}    ${addInParams_Excel}
    ${contain_res}    Set Variable    ${False}
    FOR    ${param_Excel}    IN    @{addInParams_Excel}
        ${tmp1}    Set Variable    "${param_NetAct["objectClass"]}"=="${param_Excel["MOC Name"]}"
        ${tmp2}    Set Variable    "${param_NetAct["name"]}"=="pdcchIntent.${param_Excel["Abbreviation"]}"
        ${status}    run keyword and return status    Get From Dictionary    ${param_NetAct}    defaultValue
        ${tmp3}    Set Variable If    "${param_Excel["Default Value"]}"!="None"
        ...    "${param_NetAct["defaultValue"]}"=="${param_Excel["Default Value"]}"    ${status}==False
        ${contain_res}    Set Variable If    ${tmp1} and ${tmp2} and ${tmp3}    ${True}    ${contain_res}
        Exit For Loop If    ${contain_res}
    END
    [Return]    ${contain_res}

Step ${index}: Calculate And Check Result With ${ConfType} Type
    Log To Console    Step ${index}: Calculate And Check Result With ${ConfType} Type
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${outputPlanName}    outputPlan-F_001_MRBTS-${mrbts_id1}_${timestamp}
    ${target_DNs_list}    Create List    ${object_DN1}
    ${addIn_params_list}    Generate Random FCT AddIn Params For TargetDNs    ${target_DNs_list}    ${addInParams_NetAct}
    ${addInputParameters}    Convert To String    ${addIn_params_list}
    ${addInputParameters}    Set Variable    ${addInputParameters.replace("u'","\"").replace("'","\"")}
    Set Test Variable    ${addIn_params_list}
    Run Keyword If    "${ConfType}"=="Plan"    NetAct Import Plan
    ...    ${Test Results Dir}/NetActLogs    Multiple_SBTSs_initial_export_plan.xml    MultipleSBTSs_initial_plan_${timestamp}    ui_values=${True}
    Run Keyword If    "${ConfType}"=="Plan"    Calculate And Check Results On NetAct    PLMN-PLMN/${object_DN1}
    ...    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}    MultipleSBTSs_initial_plan_${timestamp}    plan
    Run Keyword If    "${ConfType}"=="Actual"    Calculate And Check Results On NetAct    PLMN-PLMN/${object_DN1}
    ...    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}
    Append To List    ${Delete_Plan_list}    ${outputPlanName}
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs    file_name=${outputPlanName}.xml
    ...    dist_names=${MRBTS_DN}    operation_type=plan    plan_name=${outputPlanName}    ui_values=true

Step ${index}: Provision Calculated Output Plan
    Log To Console    Step ${index}: Provision Calculated Ouput Plan
    Set Test Variable    ${Need_Recover}    ${True}
    NetAct Provision Plan    plan_name=${outputPlanName}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${outputPlanName}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Additional Paramemters In ${Type} Plan
    Log To Console    Step ${index}: Check Additional Paramemters In ${Type} Plan
    FOR     ${item}    IN    @{addIn_params_list}
        ${objectDN}    Set Variable    ${item["distName"]}
        ${addInParameters_dic}    Set Variable    ${item["parameters"]}
        Log To Console    Check Additional Parameters For ${objectDN}
        Wait Until Keyword Succeeds    3x    15s    Check Additional Parameters    ${Type}    ${objectDN}    ${addInParameters_dic}
    END

Check Additional Parameters
    [Arguments]    ${Type}    ${object_dn}    ${addParam_dic}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${mrbts_name}    Fetch From Left    ${object_dn}    /
    Run Keyword If    "${Type}"=="Actual"    Run Keywords
    ...    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=${mrbts_name}_After_Calculate.xml    dist_names=PLMN-PLMN/${mrbts_name}    ui_values=true
    ...    AND   Set Test Variable    ${fileName}    ${Test Results Dir}/NetActLogs/${mrbts_name}_After_Calculate.xml
    Run Keyword If    "${Type}"=="Planned"    Set Test Variable    ${fileName}    ${Test Results Dir}/NetActLogs/${outputPlanName}.xml
    ${scf_content}    L_XML.Parse Xml    ${fileName}    #${Test Results Dir}/NetActLogs/${mrbts_name}_After_Calculate.xml
    ${pdcchParams}   L_XML.Get Elements
    ...    ${scf_content}    .//managedObject[@distName="PLMN-PLMN/${object_dn}"]/list[@name="pdcchAutoConfig"]/item/p
    ${result_value_dict}=    Create dictionary
    FOR    ${item}    IN    @{pdcchParams}
        ${key}=    L_XML.Get Element Attribute    ${item}    name
        ${value}=    L_XML.Get Element Text    ${item}
        Set To Dictionary    ${result_value_dict}    pdcchIntent.${key}=${value}
    END
    Dictionary Should Contain Sub Dictionary    ${result_value_dict}    ${addParam_dic}

Step ${index}: Provsion The Backup Plan
    Log To Console    Step ${index}: Provsion The Backup Plan
    NetAct Provision Plan    plan_name=${outputPlanName}_backup    dist_names=${MRBTS_DN}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${Need_Recover}    ${False}
    Append To List    ${Delete_Plan_list}    ${outputPlanName}_backup
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms

Check Objects Status
    [Arguments]    ${path}    ${expected_status}    ${timeout}=60    ${connection}=None
    ${all_status}    ${all_objects}    Run Keyword And Ignore Error    coam.Assert Any    class_name=${path}    connection=${connection}
    Return From Keyword If    "${all_status}"=="FAIL"    PASS
    coam.assert_every    ${path}    ${expected_status}    timeout=${timeout}    connection=${connection}

TC Setup
    Log To Console    SetUp
    Common Test Setup
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${cell_list}    coam.Get Cell List
    ${nr_cell_list}    Set Variable    ${cell_list['cells']['nr']}
    ${nr_cell}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
    Set Test Variable    ${object_DN1}    ${nr_cell["id"]["configuration"]}
    netact.Export Configuration    local_dir=${Test Results Dir}/NetActLogs
    ...    file_name=Multiple_SBTSs_initial_export_plan.xml    dist_names=${MRBTS_DN}   ui_values=true
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${Test Results Dir}/NetActLogs/Multiple_SBTSs_initial_export_plan.xml
    ${result_value_dict}=    Create dictionary
    ${mrbts_id1}    Fetch From Right    ${MRBTS_DN}    -
    Set Test Variable    ${mrbts_id1}
    ${Delete_Plan_list}    Create List
    Set Test Variable    ${Delete_Plan_list}

TC TearDown
    Log To Console    TearDown
    Run Keyword If     ${Need_Recover}    Run Keywords    Log To Console    NetAct Provision Backup Plan
    ...    AND    NetAct Provision Plan    plan_name=${outputPlanName}_backup
    ...    dist_names=${MRBTS_DN}   backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    FOR    ${plan}    IN    @{Delete_Plan_list}
        Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan}
    END
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-F_001.xlsx
    Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure
    ...    SSHLibrary.Execute Command    rm ${FCT_Folder_NetAct}/FCT_PDCCH_MultiRelease-F_001.xlsx
    Common Test Teardown
    SSHLibrary.Close All Connections
