*** Settings ***
Documentation
...   Author: mengli.yang@nokia-sbell.com
...   Contact: mengli.yang@nokia-sbell.com
...   Description: this robot case focus on MantaRay and webui


Suite Setup    Run keywords    Common Suite Setup For RRM
...            AND    Start DCAP Container    node_id=${0}   node_type=gnb
Suite Teardown    log to console    Common Suite Teardown For RRM

Force Tags
...      CRT             #Tag Item
...      TRUNK
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_SG03_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Library           Selenium2Library
Library           SSHLibrary
Library           taf.nms.netact    WITH NAME    netact
Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          RRM_Selenium.robot
#Resource          ../../../../OAM/RAN_PZ_HAZ_1/HAZ11/resources/hran_frame_taf_oam.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${desired_fct_feature}    PDCCH
${default_plan_name}    CURRENT_BTS_CONF-1
${expected_fct_file_name}    FCT_PDCCH_MultiRelease.xlsx
${NEED_RECOVERY}    False
${COMMISSIONING_PATH}    /home/ute/testline_configuration/7-5-UTESRAN002T11072/11042_scf.xml
${Trunk_Prefix}    SBTS24R2
${mplan_ip}    10.97.97.3
${instance_id}    11042
${global_bts_id}    11042
${TEST_LOG_DIRECTORY}    /home/ute/test_results/CB012125
&{NETACT}    was_host=10.82.44.57    fm_host=10.82.44.57    user=omc    password=Medsql!_1893
${MantaRay_FCT_File_Path}    /d/oss/global/var/racprs/work
#${exportfile}    /home/ute/testline_configuration/7-5-UTESRAN002T11072/FCE_Output_Calculate_Plan_1710844451.xml
&{PDCCH_Parameters}    searchSpaceType=Type2    periodicity=sl1    slotOffset=0    duration=1    monitoringSymbolWithinSlot=symbol_0
*** Test Cases ***
CB012125_11_Mix_audit_configure_feature_using_MantaRay_with_actual_configuration_conf14_conf15_conf18_24R3
    [Tags]    CRT    CB012125_11
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    MantaRay Case Precondition
    Log To Console    Case start.    console=${True}
    GetFceCapabilities And Check    FCT_Tool=PDCCH
    ${expect_output_non_NIDD_parameter}    Create Dictionary    pagingOccasionRate=25
    Calculate Configuration And Check    outputPlanName=${Calculate_Plan_Name}
    Export Delta Plan    PLAN_NAME=${Calculate_Plan_Name}
    Check Calculate PDCCH Parameters In Delta Plan    targetCell=NRCELL-1    PDCCH_Parameters_Checklist=${PDCCH_Parameters}
    ...                                               delta_plan=${exportfile}
    Audit Configuration And Check    outputPlanName=${Audit_Plan_Name}
    Export Delta Plan    PLAN_NAME=${Audit_Plan_Name}
    #Check PDCCH Parameters    targetCell=NRCELL-1    PDCCH_Parameters_Checklist=${PDCCH_Parameters}    exportfile=${exportfile}
    Provision the plan SyVe    PLAN_NAME=${Calculate_Plan_Name}
    Sleep    120s
    Check PDCCH Parameters In Full Plan    targetCell=NRCELL-1    PDCCH_Parameters_Checklist=${PDCCH_Parameters}
    #Check Additional Param In Actual Plan
    #Provision the backup plan
    [Teardown]    MantaRay Case Postcondition

CB012125_12_Mix_audit_calculate_feature_using_online_WEBEM_with_actual_configuration_conf14_conf15
    [Tags]    CRT    CB012125_12
    [Documentation]
    ...    Author: mengli.yang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Download FCE Package For Current BTS Version
    Install Valid FCE And Verify Result
    SBTS WEM Open Configuration Manager    CA
    Select Expected FCT From Droplist    expected_feature_name=PDCCH_Config_Recommendations_5.6.3
    Check Actual Full Configuration Selected As Default
    Start Calculate And Check Results
#    SBTS WEM Set Parameters
    COAM_Admin.set parameter value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
	...                               parameter=actInfTddFrameMuting
	...                               new_value=false
	...                               should_activate=${false}
    SBTS WEM Open Configuration Manager    CA
    Select Expected FCT From Droplist    expected_feature_name=PDCCH_Config_Recommendations_5.6.3
    Check Actual Full Configuration Selected As Default
    Audit and Check Result
    Save And Check Audit Report
    Start Calculate And Check Results
    Apply All Inputs Into Current Plan
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan
    [Teardown]    Case Postcondition

CB013289-A#EC1_TC12_Inter-RAT_handover_from_NR_to_LTE_without_data_forwarding_for_peer_eNodeB_not_support_direct_forwarding
    [Tags]    TC12    NFTA
    [Documentation]
    ...    Author: cici.wei@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Parameter Updated In Gnb For CB013289_TC12
    SetInitializePAValue    pa_port=1,2;    pa_value=0;
    Collect Wireshark Log    log_type=wireshark    product_type=gnb    bts_index=${0}
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0    capabilities=samsung23
    Trigger A2 By Modify PA Signal
    ${local_file_path}    Stop And Download Wireshark Log    log_type=wireshark   product_type=gnb    bts_index=${0}
    Check Wireshark Log For CB013289_TC12    wireshark_path=${local_file_path}
    [Teardown]    Case Postcondition for TC12

CB013289-A_US#B3_TC30_PCMD_Monitoring_of_patial_QoS_Flow_forwarding_status_during_IRAT_HO_to_LTE_at_gNB-CU-CP_indirect_forwarding
    [Tags]    TC30    NFTA
    [Documentation]
    ...    Author: sudi.lou@nokia-sbell.com
    [Setup]    Case Precondition
    Parameter Updated In Gnb For CB013289_TC30
    SetInitializePAValue    pa_port=1,2;    pa_value=0;
    ${oam_web_ip}    Set Variable    ${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    &{webem_info}=    create dictionary    host=${oam_web_ip}    username=Nemuadmin    password=nemuuser    port=443
    Set Test Variable    ${webem_info}
    ${gnb_profile}    Create List    Tracer_5g
    #    ${gnb_profile}    Create List    cp_5g   Tracer_5g
    ${gnb_trace_id}    Start Capture Log By Dcap    webem_info=${webem_info}    gnb_custom_profile=@{gnb_profile}
    Prepare And Attach UE    ue_index=0
    Start DL and UL Call For UE    ue_index=${0}
    Start VONR Call For UE    ue_index=0    capabilities=samsung23
    sleep    5s    reason=wait call stable
    Trigger A2 By Modify PA Signal for TC30
    Trigger B2 By Modify PA Signal for TC30
    sleep    5s    reason=wait call stable
    Detach UE    ue_index=${0}
    Stop Trace In DCAP    btsip=${webem_info['host']}
    ${trace_file_path}    Get Trace Log    btsip=${webem_info['host']}
    ${flag}    Set Variable    False
    FOR    ${trace_file}    IN    @{trace_file_path}
        ${flag}    Check Emil Log for TC30    ${trace_file}    ${flag}    dcap-master
        exit for loop if    '${flag}'=='True'
    END
    should be equal    ${flag}    True    Check emil log failed!
    [Teardown]    Case Postcondition for TC30

*** Keywords ***
Common Suite Setup For RRM
    _Create Suite Directory

Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM

Common Test Setup For RRM
    ${timestamp}=    DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    ${TEST_NAME}    ${SPACE}    _
    ${case_log_path}    Join path    ${SUITE_LOG_DIRECTORY}    ${tc_name}_${timestamp}
    Set Suite Variable    ${TEST_LOG_DIRECTORY}    ${case_log_path}
    Create directory    ${TEST_LOG_DIRECTORY}

Case Postcondition
    log to console    Case Postcondition
    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Logout

Case Postcondition for TC12
    log to console    Case Postcondition
    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False
    Common Test Teardown For RRM

Case Postcondition for TC30
    log to console    Case Postcondition
    Run Keyword And Ignore Error    Stop Trace In DCAP    btsip=${webem_info['host']}
    HAZ TC02 Get SCF Internal Id By Scout    no_ute=False
    Common Test Teardown For RRM

Download FCE Package For Current BTS Version
    Log    Download FCE Package For Current BTS Version    console=True
    COAM_Admin.Login    bts_host=10.97.97.3
    ${win_index}    SBTS WEM Logon    https://${mplan_ip}    skip_error=${True}
    ${fce_worker_name}    ${fct_files_name}    Download FCE Modules For Current SW
	${PDCCH_fct_name}    Unzip FCT    ${TEST_LOG_DIRECTORY}/TestFiles/${fct_files_name}
    Set Test Variable    ${fce_worker_name}
	Set Test Variable    ${PDCCH_fct_name}

Install Valid FCE And Verify Result
    Log    Install Valid FCE And Verify Result   console=True
    ${error_messege}   Install FCE From WebEM CA    ${TEST_LOG_DIRECTORY}/TestFiles/${fce_worker_name}
    Should Be Empty    ${error_messege}
    Check FCE Feature List Not Empty

Check FCE Feature List Not Empty
    ${list_FCE_features}    Get Feature List From WebEM CA
    Should Not Be Empty    ${list_FCE_features}

Select Expected FCT From Droplist
    [Arguments]    ${expected_feature_name}
    Log    Select Desired FCT From Droplist    console=True
    ${fce_list_objects}    SBTS WEM Select Feature On CA    ${expected_feature_name}
    Set Test Variable    ${fce_list_objects}

SBTS WEM Set Parameters
    SBTS WEM Open Configuration Manager    PE
    ${is_modified}    SBTS WEM Modify Parameters In PE Table    target_object=target_object=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1
    ...                                                         full_name=actInfTddFrameMuting
    ...                                                         param_value_to_set=false

Check Actual Full Configuration Selected As Default
    Log    Check Actual Full Configuration Selected As Default   console=True
    ${list_plan}    ${current_plan}    Get Plan Options From WebEM CA
    Should Be Equal As Strings    ${current_plan}    ${default_plan_name}
    SBTS WEM Select Plan On CA    ${default_plan_name}

Start Calculate And Check Results
    Log    Start Calculate And Check Results  console=True
    ${calculate_result}    ${table_head_list}    ${validation_result}    SBTS WEM Calculate On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Object name    Severity    Checked condition
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${calculate_result}    Calculate operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
    Should Not Be Equal As Strings    ${item['Severity']}    error
    END

Apply All Inputs Into Current Plan
    Log    Apply All Inputs Into Current Plan  console=True
    ${apply_result}    SBTS WEM Apply All On CA
    Should Be Equal As Strings    ${apply_result}    Success

Audit and Check Result
    Log    Audit And Check Results  console=True
    ${calculate_result}    ${table_head_list}    ${validation_result}    SBTS WEM Audit On CA Page And Get Results
    ${result_properties}    Create List    Check ID    Object name    Severity    Checked condition
    Lists Should Be Equal    ${result_properties}    ${table_head_list}    ignore_order=True
    Run Keyword If    "${validation_result[0]}"=="No data"    Run Keywords
    ...    Should Be Equal As Strings    ${calculate_result}    Audit operation successful
    ...    AND    Return From Keyword
    FOR    ${item}    IN    @{validation_result}
    Should Not Be Equal As Strings    ${item['Severity']}    error
    END

Save And Check Audit Report
    Log    Save And Check Audit Report  console=True
    ${audit_report_filename}    SBTS WEM Save Audit Report On CA    ${TEST_LOG_DIRECTORY}
    Log    ${audit_report_filename}    console=True

Apply All Success And Check Result Into Planned Configuration
    Log    Apply All Into Planned Configuration  console=True
    ${apply_result}    Compare And Apply Success And Check Result On CA

Provision Planned Plan And Check Site Status
    Log    Provision Planned Plan And Check Site Status    console=True
    Set Test Variable    ${NEED_RECOVERY}    ${True}
    SBTS WEM Activate Planed BTS Configuration    ${planned_plan_name} - ${planned_plan_file}
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Provision Plan And Check Site Status
    [Arguments]    ${tl_allowed_faults_file_path}=${testline_configuration_path}${/}${TestLine_Name}${/}${tl_allow_faults_file_name}
    SBTS WEM Validate Plan
    Set Test Variable    ${NEED_RECOVERY}    ${True}
    SBTS WEM Activate Plan
    Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair
    ${combined_allow_fault_alarms}    Get All Allow Faults    tl_allowed_faults_file_path=${tl_allowed_faults_file_path}
    Run Keyword And Return Status    Check Unexpect Alarm Should Not Exist    allowed_faults=${combined_allow_fault_alarms}
    ...                                                                       file_path=${TEST_LOG_DIRECTORY}
Get Nrcell Name
    ${nrcell_name_list}  Create List
    COAM_Admin.Login    bts_host=10.97.97.3
    ${cell_list}    Get All Cell Id    connection=COAM
    FOR    ${cell_id}    IN    @{cell_list}
        append to list    ${nrcell_name_list}    NRCELL-${cell_id}
    END
    Set Test Variable    ${nrcell_name_list}
    [Teardown]    COAM_Admin.Logout
    [Return]    ${nrcell_name_list}

Select Objects And Define Additional Params
    [Arguments]    ${fct_file_name}=SBTS00_ENB_9999_240219_000012_fct-files.zip
    Log    Select Objects And Define Additional Params   console=True
    ${obj}    Evaluate    random.choice(${fce_list_objects})    modules=random, sys
    ${selected_object_instance}    ${dic_init_param_value}     SBTS WEM Select Object On CA   ${obj}
    ${sub_obj_list}    ${dic_all_param_value}    Get All Additional Param Value And Object Instance    ${obj}
    ${selected_obj_list}    Split String    ${selected_object_instance}    ,${SPACE}
    # validate selected sub objects match the objects in current plan
    ${nrcell_name_list}    Get Nrcell Name
#    Lists Should Be Equal    ${sub_obj_list}    ${nrcell_name_list}    ignore_order=True
    Lists Should Be Equal    ${selected_obj_list}    ${sub_obj_list}    ignore_order=True
    # validate default add param value
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output
    ...    unzip ${TEST_LOG_DIRECTORY}/TestFiles/${fct_file_name} -d ${TEST_LOG_DIRECTORY}/TestFiles
    Should Be Equal As Integers    ${rc}    ${0}
    ${addition_param}    FCT_Excel.get_default_value_ADDIN    ${TEST_LOG_DIRECTORY}/TestFiles/${expected_fct_file_name}  PARAMETER-METADATA
    ${addition_param_abbreviation_mapping}    Create Dictionary
    ${addition_param_value_for_set}    Create Dictionary
    ${addition_param_value_for_check}    Create Dictionary
    ${addition_param_name_to_display}    Create List
    FOR    ${item}    IN    @{addition_param}
    Append To List    ${addition_param_name_to_display}    ${item['Parameter Name']}:
    Run Keyword If    '${item['Default Value']}'!='None'    Run Keywords
    ...    Should Be Equal As Strings    ${item['Default Value']}    ${dic_init_param_value['${item['Parameter Name']}:']}
    ...    AND    Set To Dictionary    ${addition_param_value_for_check}    ${item['Abbreviation']}=${item['Default Value']}
    Set To Dictionary    ${addition_param_abbreviation_mapping}    ${item['Parameter Name']}:=${item['Abbreviation']}
    END
    # validate additional input parameters required for feature configuration calculation shall be all displayed
    ${displayed_addition_params}    Get Dictionary Keys    ${dic_init_param_value}
    Sort List    ${addition_param_name_to_display}
    Lists Should Be Equal    ${displayed_addition_params}    ${addition_param_name_to_display}
    Set Test Variable    ${addition_param_abbreviation_mapping}
    ${params_list}    Get Dictionary Keys    ${dic_all_param_value}
    FOR    ${param}    IN    @{params_list}
    Run Keyword If    '${dic_init_param_value['${param}']}' != '<Select value>'    Remove Values From List    ${params_list}    ${param}
    END
    FOR    ${key}    IN    @{params_list}
    ${value_list}    Set Variable    ${dic_all_param_value['${key}']}
    ${value}    Evaluate    random.choice(${value_list})    modules=random, sys
    Set To Dictionary    ${addition_param_value_for_set}    ${key}=${value}
    ${key_abbr}    Set Variable    ${addition_param_abbreviation_mapping['${key}']}
    Set To Dictionary    ${addition_param_value_for_check}    ${key_abbr}=${value}
    END
    Set Param Value Of Feature Object    ${addition_param_value_for_set}
    Capture Page Screenshot
    Set Test Variable    ${addtional_param_value_dic}    ${addition_param_value_for_check}


Check FCE Installed On Netact
    Log    Step ${index}: Check FCE Installed On Netact   console=True
    ${filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${FCT_features}    Get FCT Features On NetAct    ${filter}
    Run Keyword If    '${FCT_features.__len__()}'=='${0}'    Install New FCT On NetAct

Start Audit With ${inputType} Plan And Check Results
    Log    Step ${index}: Start Audit With ${inputType} Plan And Check Results   console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    -
    ${second_mrbts_id}    Fetch From Right    ${MRBTS2_DN}    -
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${second_mrbts_id}
    Should Be String    MRBTS-${mrbts_id}_${second_mrbts_id}_${timestamp}
    Set Test Variable    ${outputPlanName}    outputPlan_MRBTS-${mrbts_id}_${second_mrbts_id}_${timestamp}
    Set Test Variable    ${inputPlanName}    inputPlan_MRBTS-${mrbts_id}_${second_mrbts_id}_${timestamp}
    Set Test Variable    ${afterAuditActualPlanName}    afterAudit_actualPlanName_MRBTS-${mrbts_id}_${second_mrbts_id}_${timestamp}
    Set Test Variable    ${auditReportName}    AuditReportFromInputPlan_MRBTS-${mrbts_id}_${timestamp}
    Append To List    ${Delete_Plan_list}    ${inputPlanName}    ${outputPlanName}    ${outputPlanName}_backup
    ${dn_list}    Create List    ${MRBTS_DN}    ${MRBTS2_DN}
    Set Test Variable    ${dn_list}
    NetAct CM Upload    dist_names=${dn_list}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=bacup_plan.csv
    ...    dist_names=${dn_list}    plan_name=bacup_plan    operation_type=actual
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${xml_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    ${version}    Set Variable    ${MO_items['version']}
    ${nrbts_adap_version}    Fetch From Left     ${version}    _
    ${adaptationVersion}    Set Variable    com.nokia.srbts.nrbts:${nrbts_adap_version}
    ${addInputParamList}    Get FCT Metadata On NetAct    ${adaptationVersion}
    ${xml_content}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/NetActLogs/bacup_plan.csv
    ${nrcell_list}    L_XML.Get Elements    ${xml_content}    .//managedObject[@class="NRCELL"][contains(@distName,"${MRBTS_DN}")]
    ${second_nrcell_list}    L_XML.Get Elements    ${xml_content}    .//managedObject[@class="NRCELL"][contains(@distName,"${MRBTS2_DN}")]
    ${random1}    Evaluate    random.randint(0,${nrcell_list.__len__()-1})    modules=random, sys
    ${random2}    Evaluate    random.randint(0,${second_nrcell_list.__len__()-1})  modules=random, sys
    ${targetObj1}    L_XML.Get Element Attribute    ${nrcell_list[${random1}]}    distName
    ${targetObj2}    L_XML.Get Element Attribute    ${second_nrcell_list[${random2}]}    distName
    ${target_dn_list}    Create List    ${targetObj1}     ${targetObj2}
    ${addIn_params_list}    Generate Random FCT ADDIN Params For TargetDNs    ${target_dn_list}    ${addInputParamList}
    ${str_additionalInputParameters}    Convert To String    ${addIn_params_list}
    ${str_additionalInputParameters}    Set Variable    ${str_additionalInputParameters.replace("u'","\"").replace("'","\"")}
    Set Test Variable    ${addIn_params_list}
    ${inputConfType}    Set Variable If    "${inputType}"=="Actual"    actual    plan
    ${inputPlanName}    Set Variable If    "${inputType}"=="Actual"    ${None}    ${inputPlanName}
    Run Keyword If    "${inputType}"=="Imported"    NetAct Import Plan
    ...    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs/   file_name=bacup_plan.csv    plan_name=${inputPlanName}    ui_values=${True}
    Run Keyword If    "${inputType}"=="Delta"    NetAct Create Delta Plan For Two BTS    ${inputPlanName}
    ${feedback}    Audit On NetAct And Check Results    ${targetObj1},${targetObj2}    ${str_additionalInputParameters}   ${adaptationVersion}
    ...    ${outputPlanName}   planName=${inputPlanName}    inputConfType=${inputConfType}   compareExportDifferenceReport=${auditReportName}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${outputPlanName}.csv
    ...    dist_names=${dn_list}    plan_name=${outputPlanName}    operation_type=plan    ui_values=true

Calculate For Multi BTSs And Check Result With ${ConfType} Type
    Log To Console    Step ${index}: Calculate For Multi BTSs And Check Result With Plan Type
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${outputPlanName}    outputPlan-F_001_MRBTS-${mrbts_id1}_${mrbts_id2}_${timestamp}
    ${target_DNs_list}    Create List    ${object_DN1}    ${object_DN2}
    ${addIn_params_list}    Generate Random FCT AddIn Params For TargetDNs    ${target_DNs_list}    ${addInParams_NetAct}
    ${addInputParameters}    Convert To String    ${addIn_params_list}
    ${addInputParameters}    Set Variable    ${addInputParameters.replace("u'","\"").replace("'","\"")}
    Set Test Variable    ${addIn_params_list}
    Run Keyword If    "${ConfType}"=="Plan"    NetAct Import Plan
    ...    ${TEST_LOG_DIRECTORY}/NetActLogs    Multiple_SBTSs_initial_export_plan.xml    MultipleSBTSs_initial_plan_${timestamp}
    ...                                                                                  ui_values=${True}
    Run Keyword If    "${ConfType}"=="Plan"    Calculate And Check Results On NetAct    PLMN-PLMN/${object_DN1},PLMN-PLMN/${object_DN2}
    ...    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}    MultipleSBTSs_initial_plan_${timestamp}    plan
    Run Keyword If    "${ConfType}"=="Actual"    Calculate And Check Results On NetAct    PLMN-PLMN/${object_DN1},PLMN-PLMN/${object_DN2}
    ...    ${addInputParameters}    ${adaptationVersions}    ${outputPlanName}
    Append To List    ${Delete_Plan_list}    ${outputPlanName}
    netact.Export Configuration    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${outputPlanName}.xml
    ...    dist_names=${MRBTS_DN},PLMN-PLMN/${MRBTS2}    operation_type=plan    plan_name=${outputPlanName}    ui_values=true

MantaRay Case Precondition
    Log To Console    Case Precondition
    #Set Test Variable    ${NEED_RECOVER}    ${False}
    Setup NetAct    ${NETACT}
    ${fce_worker_name}    ${fct_files_name}    RRM_Selenium.Download FCE And FCT    target_version=SBTS00_ENB_9999_240219_000012
    ...    target_download_path=${TEST_LOG_DIRECTORY}/TestFiles    release_name=SBTS00   clean_folder=${TRUE}
	${PDCCH_FCT_NAME}    ${PUCCH_FCT_NAME}    Unzip FCT    ${TEST_LOG_DIRECTORY}/TestFiles/${fct_files_name}
	Set Test Variable    ${PDCCH_FCT_NAME}
	Set Test Variable    ${PUCCH_FCT_NAME}
	#Set Test Variable    ${PAGING_FCT_NAME}
    ${time}    Get Time    epoch
    #Set Test Variable    ${REMOTE_FCT_FILE}    /d/oss/global/var/racprs/work/${time}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${COMMISSIONING_PATH}
    ${NRBTS_RELEASE}    L_XML.Get Element Attribute    ${scf_content}    version    .//managedObject[@class="com.nokia.srbts.nrbts:NRBTS"]
    Set Test Variable    ${NRBTS_RELEASE}    com.nokia.srbts.nrbts:${NRBTS_RELEASE.split("_")[0]}
    ${elements_nrcell}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]
    ${LIST_NRCELL_DN}    Create List
    FOR    ${element}    IN    @{elements_nrcell}
    ${dn}    L_XML.Get Element Attribute    ${element}    distName
    Append To List    ${LIST_NRCELL_DN}    ${dn}
    END
    Set Test Variable    ${LIST_NRCELL_DN}
    Set Test Variable    ${Calculate_Plan_Name}    FCE_Output_Calculate_Plan_${time}
    Set Test Variable    ${Audit_Plan_Name}    FCE_Output_Audit_Plan_${time}

MantaRay Case Postcondition
    Log To Console    \n Case Postcondition
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${Calculate_Plan_Name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${Audit_Plan_Name}
    #Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PLAN_NAME}_backup
    #Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    #${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${REMOTE_FCT_FILE}
    #Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${REMOTE_FCT_FILE}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PDCCH_FCT_NAME}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PUCCH_FCT_NAME}
    #Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PAGING_FCT_NAME}
    #Teardown NetAct
    SSHLibrary.Close All Connections

GetFceCapabilities And Check
    [Arguments]    ${FCT_Tool}=PDCCH
    Log To Console    Step 1 : GetFceCapabilities And Check
    ${param_name_mapping}    Create Dictionary    Tool Name=fullToolName    Abbreviated Tool Name=toolName
    ...    Description=toolDescription    Version=toolVersion    Category=toolCategory
    ...    Support Release(s) \\ NIDD adaptationId(s)=supportedAdaptationVersions
    ${ParmName_Excel_list}    Get Dictionary Keys    ${param_name_mapping}
    ${FCT_Tool_Name}    Set Variable If    '${FCT_Tool}' == 'PDCCH'    ${PDCCH_FCT_NAME}
    ...    '${FCT_Tool}' == 'PUCCH'    ${PUCCH_FCT_NAME}    ${PAGING_FCT_NAME}
    ${FCT_Info}    FCT_Excel.get_FCT_info    ${TEST_LOG_DIRECTORY}/TestFiles/${FCT_Tool_Name}    GENERAL-METADATA    ${ParmName_Excel_list}
    ${feature_filter}    Create Dictionary    toolName=${FCT_Info["Abbreviated Tool Name"]}    toolVersion=${FCT_Info["Version"]}
    ${feature}    Get FCT Features On NetAct    ${feature_filter}
    Run Keyword If    '${feature.__len__()}'=='${0}'    Install New FCT To NetAct    ${FCT_Tool_Name}
    #${feature}    Get FCT Features On NetAct    ${feature_filter}
    #Should Be Equal As Integers    ${feature.__len__()}    ${1}
    #${feature_netact}    Set Variable    ${feature[0]}
    #${ParmName_Excel_list}    Create List    Abbreviated Tool Name    Version    Description    Tool Name    Category
    #${multi_supportedAdaptationVersions}    Pop From Dictionary    ${feature_netact}    supportedAdaptationVersions
    #${supportedAdaptationVersions}    Create List
    #FOR    ${sub_list}    IN    @{multi_supportedAdaptationVersions}
    #Append To List    ${supportedAdaptationVersions}    @{sub_list}
    #END
    #${excel_supportedAdaptationVersions}    Pop From Dictionary    ${FCT_Info}    Support Release(s) \\ NIDD adaptationId(s)
    #Sort List    ${excel_supportedAdaptationVersions}
    #Sort List    ${supportedAdaptationVersions}
    #Lists Should Be Equal    ${supportedAdaptationVersions}    ${excel_supportedAdaptationVersions}
    #${Category}    Pop From Dictionary    ${FCT_Info}    Category
    #${Category}    Set Variable If    '${Category}'=='None'    ${EMPTY}    ${Category}
    #Set To Dictionary    ${FCT_Info}    Category    ${Category}
    #FOR    ${param}    IN    @{ParmName_Excel_list}
    #${netact_param_name}    Get From Dictionary    ${param_name_mapping}    ${param}
    #Should Be Equal As Strings    ${FCT_Info["${param}"]}    ${feature_netact["${netact_param_name}"]}
    #END

GetFctMetadata And Check
    Log To Console    Step 2: GetFctMetadata And Check
    ${additionalInputParameters}    Get Fct Metadata On NetAct    ${NRBTS_RELEASE}
    ${ADDIN_Param}    FCT_Excel.get_default_value_ADDIN    ${TEST_LOG_DIRECTORY}/${FCT_FILE_NAME}    PARAMETER-METADATA
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

Calculate Configuration And Check
    [Arguments]    ${targetCell}=NRCELL-1    ${additionalInputParameters}=${EMPTY}    ${inputConfigurationType}=actual    ${toolName}=PDCCH
    ...    ${inputPlanName}=${EMPTY}    ${outputPlanName}=FCEoutputDeltaPlan
    Log To Console    Step 2: CalculateConfiguration And Check
	${list_target_DN}    Create List
	${cell_list}    Split String    ${targetCell}    ,
	FOR    ${nrcell}    IN    @{cell_list}
	${list_target_DN}    Create Target DN List For NRCell      ${nrcell}    ${list_target_DN}
	END
    ${str_targetObjects}    Catenate    SEPARATOR=,    @{list_target_DN}
    ${additionalInputParameters}    Set Variable If    '${inputPlanName}' == ''   []
    ${adaptationVersions}    Set Variable    ${NRBTS_RELEASE}
    ${cmd}    Create FCT Create Configuration Command    ${str_targetObjects}   ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
	${calculation_detail_line}    Should Match Regexp    ${stdout}    \\{.*\\}
	Log    ${calculation_detail_line}
    ${calculation_result}    Evaluate    ${calculation_detail_line}
    Log    ${calculation_result}
    ${additionalOutputParameters}    Set Variable    ${calculation_result['additionalOutputParameters']}
    Log    ${additionalOutputParameters}
    #Run Keyword If    '${toolName}' == 'Paging'    Dictionary Should Be Equal
    [Teardown]     SSHLibrary.Close Connection

Audit Configuration And Check
    [Arguments]    ${targetCell}=NRCELL-1    ${additionalInputParameters}=${EMPTY}    ${inputConfigurationType}=actual    ${toolName}=PDCCH
    ...    ${inputPlanName}=${EMPTY}    ${outputPlanName}=FCEoutputDeltaPlan
    Log To Console    Start Audit Configuration And Check
	${list_target_DN}    Create List
    ${cell_list}    Split String    ${targetCell}    ,
	FOR    ${nrcell}    IN    @{cell_list}
	${list_target_DN}    Create Target DN List For NRCell      ${nrcell}    ${list_target_DN}
	END
    ${str_targetObjects}    Catenate    SEPARATOR=,    @{list_target_DN}
    ${additionalInputParameters}    Set Variable If    '${inputPlanName}' == ''   []
    ${adaptationVersions}    Set Variable    ${NRBTS_RELEASE}
    ${cmd}    Create FCT Audit Configuration Command    ${str_targetObjects}   ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Execute Command    rm -rf /d/oss/global/var/racops/export/AuditReportFromActual.csv
    SSHLibrary.File Should Not Exist    /d/oss/global/var/racops/export/AuditReportFromActual.csv
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    SSHLibrary.File Should Exist    /d/oss/global/var/racops/export/AuditReportFromActual.csv
    SSHLibrary.Get File    /d/oss/global/var/racops/export/AuditReportFromActual.csv    ${TEST_LOG_DIRECTORY}/NetActLogs/
	${audit_detail_line}    Should Match Regexp    ${stdout}    \\{.*\\}
	Log    ${audit_detail_line}
    ${audit_result}    Evaluate    ${audit_detail_line}
    Log    ${audit_result}
    ${additionalOutputParameters}    Set Variable    ${audit_result['additionalOutputParameters']}
    Log    ${additionalOutputParameters}
    #Run Keyword If    '${toolName}' == 'Paging'    Dictionary Should Be Equal
    [Teardown]     SSHLibrary.Close Connection

Export Delta Plan
    [Arguments]    ${PLAN_NAME}
    Log    Export Delta Plan    console=True
    ${exportfile}    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${PLAN_NAME}.xml
    ...    dist_names=PLMN-PLMN/MRBTS-11042    plan_name=${PLAN_NAME}    operation_type=plan    ui_values=true
    Set Test Variable    ${exportfile}
    [Return]    ${exportfile}

Check Calculate PDCCH Parameters In Delta Plan
    [Arguments]    ${targetCell}    ${PDCCH_Parameters_Checklist}    ${delta_plan}
    ${scf_content}    L_XML.Parse Xml    ${delta_plan}
    ${distName_cell}    Set Variable    PLMN-PLMN/MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${Text_bwpDN}    L_XML.Get Elements Texts    ${scf_content}
    ...                         .//managedObject[@distName="${distName_cell}"]/list[@name="cellBwpList"]/item/p[@name="bwpDN"]
    ${element_PDCCH_CONFIG_COMMON}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="PDCCH_CONFIG_COMMON"]
    ${distName_PDCCH_CONFIG_COMMON}    Create List
    FOR    ${element}    IN    @{element_PDCCH_CONFIG_COMMON}
    ${dn}    L_XML.Get Element Attribute    ${element}    distName
    Append To List    ${distName_PDCCH_CONFIG_COMMON}    ${dn}
    END
    Log To Console    ${distName_PDCCH_CONFIG_COMMON}
    FOR    ${bwpDN}    IN    @{Text_bwpDN}
    Check Parameters Of PDCCH    ${scf_content}    ${PDCCH_Parameters_Checklist}    ${distName_PDCCH_CONFIG_COMMON}    ${bwpDN}
    END

Check PDCCH Parameters In Full Plan
    [Arguments]    ${targetCell}    ${PDCCH_Parameters_Checklist}
    ${backup_scf_file}    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=scf_recommended.xml
    ${scf_content}    L_XML.Parse Xml    ${backup_scf_file}
    ${distName_cell}    Set Variable    MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${Text_bwpDN}    L_XML.Get Elements Texts    ${scf_content}
    ...                       .//managedObject[@distName="${distName_cell}"]/list[@name="cellBwpList"]/item/p[@name="bwpDN"]
    ${element_PDCCH_CONFIG_COMMON}    L_XML.Get Elements    ${scf_content}    .//managedObject[@class="PDCCH_CONFIG_COMMON"]
    ${distName_PDCCH_CONFIG_COMMON}    Create List
    FOR    ${element}    IN    @{element_PDCCH_CONFIG_COMMON}
    ${dn}    L_XML.Get Element Attribute    ${element}    distName
    Append To List    ${distName_PDCCH_CONFIG_COMMON}    ${dn}
    END
    Log To Console    ${distName_PDCCH_CONFIG_COMMON}
    FOR    ${bwpDN}    IN    @{Text_bwpDN}
    Check Parameters Of PDCCH    ${scf_content}    ${PDCCH_Parameters_Checklist}    ${distName_PDCCH_CONFIG_COMMON}    ${bwpDN}
    END

Check Calculate PAGING Parameters In Delta Plan
    [Arguments]    ${targetCell}    ${delta_plan}
    ${scf_content}    L_XML.Parse Xml    ${delta_plan}
    ${distName_cell}    Set Variable    PLMN-PLMN/MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${list_param_names}    Get Dictionary Keys    ${PDCCH_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
    ${p_value}    Run Keyword If    '${p_name}' == 'fPdcchMonOccsnPo'    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/list[@name="fPdcchMonOccsnPo"]/p
    ...       ELSE IF     L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/p[@name="${p_name}"]
    Log To Console    ${p_value}
    Should Be Equal As Strings    ${p_value}    ${PDCCH_Parameters_Checklist["${p_name}"]}
    END

Check PAGING Parameters In Full Plan
    [Arguments]    ${targetCell}
    ${backup_scf_file}    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=scf_recommended.xml
    ${scf_content}    L_XML.Parse Xml    ${backup_scf_file}
    ${distName_cell}    Set Variable    MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${list_param_names}    Get Dictionary Keys    ${PDCCH_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
    ${p_value}    Run Keyword If    '${p_name}' == 'fPdcchMonOccsnPo'    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/list[@name="fPdcchMonOccsnPo"]/p
    ...       ELSE IF     L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/p[@name="${p_name}"]
    Log To Console    ${p_value}
    Should Be Equal As Strings    ${p_value}    ${PDCCH_Parameters_Checklist["${p_name}"]}
    END

Provision the plan SyVe
    [Arguments]    ${PLAN_NAME}
    Log    Provision the plan SyVe    console=True
    Set Test Variable    ${NEED_RECOVER}    ${True}
    NetAct Provision Plan    plan_name=${PLAN_NAME}    dist_names=PLMN-PLMN/MRBTS-11042
    ...    backup_plan_name=${PLAN_NAME}_backup    create_backup_plan=True    provisioning_operation=activate
    #Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    #Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair

Unzip FCT
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}/TestFiles
    Should Be Equal As Integers    ${rc}    ${0}
    ${PDCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PDCCH\\w+\\.xlsx
	${PUCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PUCCH\\w+\\.xlsx
	#${Paging_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+Paging\\w+\\.xlsx
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${PDCCH_FCT_NAME}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${PUCCH_FCT_NAME}
    [Return]    ${PDCCH_FCT_NAME}    ${PUCCH_FCT_NAME}

Install New FCT To NetAct
    [Arguments]    ${fct_tool_name}
    ${MantaRay_FCT_File}    Set Variable    ${MantaRay_FCT_File_Path}/${fct_tool_name}
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Put File    ${TEST_LOG_DIRECTORY}/TestFiles/${fct_tool_name}    ${MantaRay_FCT_File}
    Install FCT On NetAct    ${MantaRay_FCT_File}

Install FCT On NetAct
    [Arguments]    ${mantaray_fct_file}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command
    ...    racclimx.sh -op FCT_Install -inputFile ${mantaray_fct_file} -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Install FCT Operation finished.
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${stdout}

Get FCT Features On NetAct
    [Arguments]    ${filter}=${EMPTY}
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    racclimx.sh -op FCT_List -v    return_stderr=${True}    return_rc=${True}
    Should Be Equal As Integers    ${rc}    ${0}
    ${detail_line}    Should Match Regexp    ${stdout}    \\[.*\\]
    ${FCT_features}    Evaluate    ${detail_line}
    Return From Keyword If    "${filter}"==""    ${FCT_features}
    FOR    ${feature}    IN    @{FCT_features}
    ${is_match}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${feature}    ${filter}
    Continue For Loop If    ${is_match}
    ${feature_version}    Remove String    ${feature}[toolVersion]    .
    ${filter_version}    Remove String    ${filter}[toolVersion]    .
    ${feature_version_num}    Convert To Integer    ${feature_version}
    ${filter_version_num}    Convert To Integer    ${filter_version}
    Run Keyword If    '${feature}[toolName]' != '${filter}[toolName]' or ${feature_version_num} < ${filter_version_num}
    ...    Remove Values From List    ${FCT_features}    ${feature}
    END
    [Teardown]     SSHLibrary.Close Connection
    [Return]    ${FCT_features}

Create Target DN List For NRCELL
    [Arguments]    ${nrcell}    ${list_target_DN}
    FOR    ${nrcell_dn}    IN    @{LIST_NRCELL_DN}
	${nrcell_id}    Should Match Regexp    ${nrcell_dn}     NRCELL-\\d
	Run Keyword If    '${nrcell}' == '${nrcell_id}'    Append To List    ${list_target_DN}    PLMN-PLMN/${nrcell_dn}
	Exit For Loop If    '${nrcell}' == '${nrcell_id}'
	END
	[Return]    ${list_target_DN}

Create FCT Create Configuration Command
    [Arguments]    ${targetObjects}    ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    ${cmd}    Run Keyword If    '${inputConfigurationType}' == 'actual'    Catenate
    ...    racclimx.sh -op FCT_Create_Configuration_Plan -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -outputPlanName ${outputPlanName} -v
    ...       ELSE IF    '${inputConfigurationType}' == 'plan'    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -planName ${inputPlanName}
    ...    -outputPlanName ${outputPlanName} -v
    [Return]    ${cmd}

Create FCT Audit Configuration Command
    [Arguments]    ${targetObjects}    ${inputConfigurationType}    ${toolName}
    ...    ${additionalInputParameters}    ${adaptationVersions}   ${inputPlanName}    ${outputPlanName}
    ${cmd}    Run Keyword If    '${inputConfigurationType}' == 'actual'    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -outputPlanName ${outputPlanName}
    ...    -compareFeedbackLevel parameterLevel -compareExportDifferenceReport AuditReportFromActual.csv -v
    ...       ELSE IF    '${inputConfigurationType}' == 'plan'    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${targetObjects}"
    ...    -inputConfigurationType "${inputConfigurationType}" -toolName "${toolName}" -additionalInputParameters
    ...    "${additionalInputParameters}" -adaptationVersions ${adaptationVersions} -planName ${inputPlanName}
    ...    -outputPlanName ${outputPlanName} -compareFeedbackLevel parameterLevel
    ...    -compareExportDifferenceReport AuditReportFromActual.csv -v
    [Return]    ${cmd}

Check If Netact Plan Is Deleted
    [Arguments]    ${plan_name}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    netact.Delete Plan    ${plan_name}

NetAct Import Plan
    [Arguments]    ${local_dir}    ${file_name}    ${plan_name}    ${ui_values}=false
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    ${status}=    Run Keyword And Return Status    netact.Import Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    plan_name=${plan_name}    ui_values=${ui_values}
    Run Keyword If    ${status}    Log    Plan ${plan_name} at ${local_dir}/${file_name} import success.    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} at ${local_dir}/${file_name} is fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} at ${local_dir}/${file_name} is fail.

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan    ${ui_values}=None
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    ${status}    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    operation_type=${operation_type}    dist_names=${dist_names}
    ...    plan_name=${plan_name}    ui_values=${ui_values}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}
    ${exportfile}=    Join Path    ${local_dir}    ${file_name}
    [Return]    ${exportfile}

NetAct Provision Plan
    [Arguments]    ${plan_name}    ${dist_names}    ${backup_plan_name}    ${create_backup_plan}
    ...    ${provisioning_operation}    ${ignore_errors}=False
    log    ${backup_plan_name}    console=True
    ${status}=    Run Keyword And Return Status    netact.Provision Plan    plan_name=${plan_name}    dist_names=${dist_names}
    ...    backup_plan_name=${backup_plan_name}    create_backup_plan=${create_backup_plan}
    ...    provisioning_operation=${provisioning_operation}    ignore_errors=${ignore_errors}
    Run Keyword If    ${status}    Log    Provision plan ${plan_name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Provision plan ${plan_name} failed!    level=ERROR
    ...    AND    Fail    Provision plan ${plan_name} failed!


Check Parameters Of PDCCH
    [Arguments]    ${scf_content}    ${PDCCH_Parameters_Checklist}    ${distName_PDCCH_CONFIG_COMMON}    ${bwpDN}
    FOR    ${distName}    IN    @{distName_PDCCH_CONFIG_COMMON}
    ${result}    Run Keyword And Return Status    Should Contain    ${distName}    ${bwpDN}
    Exit For Loop If    ${result}
    END
    ${element_searchSpaceCommon_item}    L_XML.Get Elements    ${scf_content}
    ...    .//managedObject[@distName="${distName}"]/list[@name="searchSpaceCommon"]/item
    FOR    ${element}    IN    @{element_searchSpaceCommon_item}
    ${text_p}    L_XML.Get Element Text    ${element}    .//p[@name="searchSpaceType"]
    Exit For Loop If    '${text_p}' == 'Type2'
    END
    Log To Console    ${element}
    ${list_param_names}    Get Dictionary Keys    ${PDCCH_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
    ${p_value}    L_XML.Get Element Text    ${element}    .//p[@name="${p_name}"]
    Log To Console    ${p_value}
    Should Be Equal As Strings    ${p_value}    ${PDCCH_Parameters_Checklist["${p_name}"]}
    END




NetAct CM Upload
    [Arguments]    ${dist_names}    ${parameters}=None    ${check_feedback}=${False}
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Upload Configuration    dist_names=${dist_names}
    ...                                                                                        parameters=${parameters}
    Run Keyword If    '${status}'=='PASS'    Log    CM Upload operation succesfully finished for ${dist_names}    console=True
    ...    ELSE    Run Keywords    Log    CM Upload operation failed for ${dist_names}    level=ERROR
    ...    AND    Fail    CM Upload operation failed for ${dist_names}
    Return From Keyword If    not ${check_feedback}
    ${feedback}    Replace String Using Regexp    ${feedback}    \\n\\t    ${EMPTY}
    ${feedback_list}    Split String    ${feedback}    \n
    Should Not Contain    ${feedback}     Content mismatch with metadata detected
    FOR    ${item}    IN     @{feedback_list}
    ${status}    Run Keyword And Return Status    Should Contain    ${item}    Feedback received:DN: ${dist_names}
    Run Keyword If    not ${status}    Remove Values From List    ${feedback_list}    ${item}
    END
    ${feedback}   Convert To String    ${feedback_list}
    Should Contain    ${feedback}    5G/LTE/SRAN upload finished
    Should Contain    ${feedback}    5G/LTE/SRAN HW upload finished
    Should Not Contain    ${feedback}    Error
    Should Not Contain    ${feedback}    Warning


Setup NetAct
    [Arguments]     ${NETACT}
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    netact.Detect Web Url
    netact.Add Web Url    ${web_url}    ${NETACT['user']}    ${NETACT['password']}


Teardown NetAct
    netact.Delete Node    cmwas
    netact.Delete Node    fmwas
    netact.Clean All

Parameter Updated In Gnb For CB013289_TC12
    @{para_list}          Create List    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod
    @{mo_list_vdu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJECELL-1
    @{value_list_true}    Create List    IRATDirectDataFwdOnNg    directDataFwd
    Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vdu}    product_type=gnb

Prepare And Attach UE
    [Arguments]    ${ue_index}=${0}    ${ui_version}=S21
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_${ue_index}_type}    ${ue_type}
    Log to Console    \n***Prepare UE***
    Prepare UE    ${ue_${ue_index}_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_${ue_index}_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_${ue_index}_type}

Trigger A2 By Modify PA Signal
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     0    127
    ${target_pa_port_list}     Create List    7    8
    ${target_pa_value_list}    Create List    127    0
    Modify PA    source_pa_port_list=${source_pa_port_list}
    ...          source_pa_value_list=${source_pa_value_list}
    ...          target_pa_port_list=${target_pa_port_list}
    ...          target_pa_value_list=${target_pa_value_list}
    ...          step=${10}

Check Wireshark Log For CB013289_TC12
    [Arguments]    ${wireshark_path}=${wireshark_local_file_path_vCU}
    &{analysis_dict}       Create Dictionary    filter_conditions=f1ap.procedureCode==11
    ${expect_message}=    Set Variable    RRC Setup Request
    ${result}=    Log Analysis    operation=filter    log_type=wireshark    log_path=${wireshark_path}
    ...                           analysis_dict=${analysis_dict}
    Should Contain    ${result}    ${expect_message}

Parameter Updated In Gnb For CB013289_TC30
    @{para_list}          Create List    actInterRatHoSADlDataForward    actInterRatHoDirectDlDataFwd    iRatDataForwardingMethod
	...                                  dataForwarding    dataForwarding    dataForwarding
    @{mo_list_vcu}        Create List    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}    MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...                                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRADJECELL-1
	...                                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_5QI-1
	...                                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_5QI-6
	...                                  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRDRB_5QI-3
    @{value_list_true}    Create List    true    IRATDirectDataFwdOnX2    indirectDataFwd    IRATDataFwd
	...                                  IRATDataFwd    IRATDataFwd
	Parameter Updated    para_list=@{para_list}    value_list_true=@{value_list_true}
    ...                  mo_list_vdu=@{mo_list_vcu}    product_type=gnb

Start Capture Log By Dcap
    [Arguments]    ${webem_info}=${None}      ${gnb_custom_profile}=${None}
    Connect To DCAP    ${tl.test_pcs[0].default_ssh_connection_details.addr}    9443    ${None}    ${None}    dcapv3
    ...    ${TRUE}    dcap-master
    Make Sure BTS Integrated In DCAP    bts_dic=${webem_info}

    ${trace_id}    Start Trace In DCAP    ${webem_info}    gnb_custom_profile_list=${gnb_custom_profile}
    Log To Console     Trace Collection start on DCAP
    [Return]    ${trace_id}

Trigger A2 By Modify PA Signal for TC30
    ${source_pa_port_list}     Create List     1    2
    ${source_pa_value_list}    Create List     0    40
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${5}

Trigger B2 By Modify PA Signal for TC30
    ${source_pa_port_list}     Create List    7    8
    ${source_pa_value_list}    Create List     120    0
    Modify PA Only In Source    source_pa_port_list=${source_pa_port_list}
    ...                         source_pa_value_list=${source_pa_value_list}
    ...                         step=${60}

Stop VONR Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}
    Log To Console    \n*** Stop VONR Call***
    Stop VONR Call    ue_type=${ue_type}      vc_alias=VC_1

Check VONR Call Status after HO
    [Arguments]      ${expected_status}=hold
    Log to Console    \n***Check VONR Call Status after HO***
    ${vc_status} =    Check VONR Call Status    vc_alias=VC_1
    should be equal    "${vc_status}"  "${expected_status}"   The status of Voice Call is not expected!

Get Trace Log
    [Arguments]    ${btsip}
    ${trace_file_path}    Download Trace File    btsip=${btsip}
    @{zip_file_name}    OperatingSystem.List Files In Directory    ${trace_file_path}    *.zip
    ${zip_file_path}    Set Variable    ${trace_file_path}/${zip_file_name[0]}
    ${target_dir}=    Join Path  ${trace_file_path}  unzip-files
    ${cell_trace_log_file_paths}    Extract log from trace file    tti_archive=${zip_file_path}    directory=${target_dir}    postfix=.lcbin
    [Return]    ${cell_trace_log_file_paths}

Check Emil Log for TC30
    [Arguments]    ${trace_file}    ${flag}    ${connection}
    ${message_filter}    Create List    User data=CU: PduSessionResourceInfoTraceRecord
    ${json_file_path}    Get Emil Decoded Data In Json    file_path=${trace_file}    connection=${connection}
        ...                filter=${message_filter}

    ${parsed_json}    OperatingSystem.Get File    ${json_file_path}
    ${context_dict}    json.Loads    ${parsed_json}
    ${trace_info}=    Set Variable    ${context_dict}[emil_data][rows]
    FOR    ${trace}    IN    @{trace_info}
        ${return_info}    Run Keyword And Ignore Error    Check Jsoncontent in Emil Log    ${trace}
        ${flag}=    set variable if    '${return_info[0]}'=='PASS'    True
        exit for loop if    '${flag}'=='True'
    END
    [Return]    ${flag}

Check Jsoncontent in Emil Log
    [Arguments]    ${emil_data}
    ${trace_info}=    Set Variable    ${emil_data}[JsonContent][1]
    ${record_data}=    Set Variable    ${trace_info}[CuVendorExtensionRecordDataType][pduSessionResourceInfoRecord][data]

    ${trigger}=    Set Variable    ${record_data}[trigger]
    ${result}=    Set Variable    ${record_data}[result]
    ${modified_pdu_sessions}=    Set Variable    ${record_data}[modifiedPduSessionResources]
    ${forwardingTarget}=    Set Variable    ${record_data}[forwardingTarget]
    ${forwardingType}=    Set Variable    ${record_data}[forwardingType]

    Should Be Equal    ${trigger}    handover
    Should Be Equal    ${result}    success
    Should Be Equal    ${forwardingTarget}    eutran
    Should Be Equal    ${forwardingType}    indirect

#    ${pdu_session1_qfis}    Create List    ${1}
#    ${pdu_session1_eradids}    Create List    ${5}
#    ${pdu_session2_qfis}    Create List    ${2}
#    ${pdu_session2_eradids}    Create List    ${6}
    FOR    ${session}    IN    @{modified_pdu_sessions}
        ${pdu_session_id}=    Set Variable    ${session}[pduSessionId]
#        ${pdu_session_id}=    Get From Dictionary    ${session}    pduSessionId
#        ${snssai}=    Get From Dictionary    ${session}    snssai
#        ${sst}=    Get From Dictionary    ${snssai}    sst
        ${forwarding_qos_flows}=    Set Variable    ${session}[forwardingQosFlows]
        ${qfi_info}    ${erabId_info}    Get qfi and erabId in forwardingQosFlows list    ${forwarding_qos_flows}
#        Run Keyword If    ${pdu_session_id}==1    Should Be Equal    ${pdu_session1_qfis}    ${qfi_info}
#        ...    ELSE IF    ${pdu_session_id}==2    Should Be Equal    ${pdu_session2_qfis}    ${qfi_info}
    END

Get qfi and erabId in forwardingQosFlows list
    [Arguments]    ${forwarding_qos_flows}
    ${qfi_list}    Create List
    ${erabId_list}    Create List
    FOR    ${flow_info}    IN    @{forwarding_qos_flows}
        ${qfi}=    Set Variable    ${flow_info}[qfi]
        ${erabId}=    Set Variable    ${flow_info}[erabId]
        append to list    ${qfi_list}    ${qfi}
        append to list    ${erabId_list}    ${erabId}
    END
    [Return]   ${qfi_list}    ${erabId_list}