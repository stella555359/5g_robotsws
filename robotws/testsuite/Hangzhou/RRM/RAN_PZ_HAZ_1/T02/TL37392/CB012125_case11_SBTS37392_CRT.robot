*** Settings ***
Documentation
...   Author: qianqian.guo@nokia-sbell.com
...   Contact: qianqian.guo@nokia-sbell.com
...   Description: this robot case focus on paging and PDCCH tools using in MantaRay


Suite Setup       Common Suite Setup For RRM
Suite Teardown    Common Suite Teardown For RRM


Force Tags
...      CRT             #Tag Item
...      TRUNK
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_TG02_ST_RRM  #Organization
...      TA_LEVEL_22              #Detailed Automation Level[TA_LEVEL_20，TA_LEVEL_21， TA_LEVEL_22]

Test Timeout    600 minutes

Library           Selenium2Library
Library           SSHLibrary
Library           taf.nms.netact    WITH NAME    netact
Library           taf.transport.ssh    WITH NAME    ssh
#Library           ../Resources/python/FCT_Excel.py
Library           ../../../../RRM/RAN_PZ_HAZ_1/T02/CB012125/FCT_Excel.py
Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Resource          ../../T02/CB012125/RRM_Selenium.robot
Resource          ../../T02/Common_Case/common_resource_new.robot


*** Variables ***
${desired_fct_feature}    PDCCH
${desired_fct_feature1}    Paging
${default_plan_name}    37392_scf_plan_for_CB012125_case11.xml
${expected_fct_file_name}    FCT_PDCCH_MultiRelease.xlsx
${expected_fct_file_name1}    FCT_PagingConfigurationGuide.xlsx
${NEED_RECOVERY}    False
${Trunk_Prefix}    SBTS00
${mplan_ip}    10.69.53.14
${instance_id}    37392
${global_bts_id}    37392
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_5_UTESRAN003T37392/37392_scf_plan_for_CB012125_case11.xml
${TEST_LOG_DIRECTORY}    /home/ute/test_results/CB012125
#NA3006
&{NETACT}    was_host=10.82.47.15    fm_host=10.82.47.15    user=omc    password=Medsql!_1893
${Test Results Dir}    /d/oss/global/var/racprs/work
${serials}    7TD5T21423000785
${dn_list}    PLMN-PLMN/MRBTS-37392
${dist_names}    PLMN-PLMN/MRBTS-37392
${MRBTS_cell1}    PLMN-PLMN/MRBTS-37392/NRBTS-37392/NRCELL-1
${MRBTS_cell2}    PLMN-PLMN/MRBTS-37392/NRBTS-37392/NRCELL-2
${MRBTS_cell3}    PLMN-PLMN/MRBTS-37392/NRBTS-37392/NRCELL-3
${FCE_release}    com.nokia.srbts.nrbts:NRBTSCL25R1

*** Test Cases ***
CB012125_11_Mix_audit_configure_feature_using_MantaRay_with_actual_configuration_conf11_conf12_conf13_24R3
    [Tags]    CRT    CB012125_11
    [Documentation]    check cells configured by case required scf_recommended
    ...    Author: qianqian.guo@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    [Setup]    Case Precondition
    Log To Console    step0: modify scf and upload SCF to NetAct
    Modify_parameters_for_paging_PDCCH
    Wait Until Keyword Succeeds    5min    1min    NetAct CM Upload    dist_names=${dn_list}

    Log To Console    step1: check FCE version in NetAct
	Check FCE Installed On Netact

    Log To Console    step2:paging for NRCELL-1, No delta plan created in NetAct    console=${True}
    Audit Configuration And Check

    Log To Console    step3:Paging for NRCELL-2 and NRCELL-3 with delta plan created in NetAct    console=${True}
    Create FCT Create Configuration Command for step3
    Wait Until Keyword Succeeds    5min    1min    Export Delta Plan
    ...    PLAN_NAME=37392-paging-FCEoutputfullPlan-cell2-cell3

    Log To Console    step4:PDCCH for NRCELL1, NRCELL-2 and NRCELL-3 With delta plan created in NetAct
    Create FCT Create Configuration Command for step4
    Wait Until Keyword Succeeds    5min    1min    Export Delta Plan
    ...    PLAN_NAME=37392-PDCCH-FCEoutputfullPlan-cell1-cell2-cell3

    Log To Console    step5: Activate delta plans
    Wait Until Keyword Succeeds    5min    1min    Provision the plan SyVe
    ...    PLAN_NAME=37392-paging-FCEoutputfullPlan-cell2-cell3
    Wait Until Keyword Succeeds    5min    1min    Provision the plan SyVe
    ...    PLAN_NAME=37392-PDCCH-FCEoutputfullPlan-cell1-cell2-cell3

    #Log To Console    step6: Check FCT results in NetAct
    #Check PDCCH Parameters In Full Plan

    Log To Console    step7:make voice call under NRCELL-3 and NRCELL-2    console=${True}
    Log To Console    lock/unlock cell3
    #BTS Operation    operation=cell_lock            product_type=gnb    bts_index=0    distname_id=NRCELL-2
    #...    need_verify=yes
    #BTS Operation    operation=cell_unlock            product_type=gnb    bts_index=0    distname_id=NRCELL-2
    #...    need_verify=yes
    BTS Operation    operation=cell_lock            product_type=gnb    bts_index=0    distname_id=NRCELL-3
    ...    need_verify=yes
    BTS Operation    operation=cell_unlock            product_type=gnb    bts_index=0    distname_id=NRCELL-3
    ...    need_verify=yes
    #Make Voice call under NRCELL-3 and NRCELL-2
    [Teardown]    Case Postcondition


*** Keywords ***
Case Precondition
    log to console    Case Precondition
    Common Test Setup For RRM
	Setup NetAct    ${NETACT}

Case Postcondition
    log to console    Case Postcondition
    Common Test Teardown For RRM
    Get SCF Internal Id By Scout    no_ute=False
	Teardown NetAct

Modify_parameters_for_paging_PDCCH
    [Arguments]    ${common}=/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/T02/
    ${delta_plan_file}    join path    ${common}    TL37392/Delta_scf_MRBTS37392_CB012125_Case11.json
    ${out}     Parameter Operation    operation=delta_plan_update   product_type=gnb
    ...        delta_file_path=${delta_plan_file}
    Log To Console    delta plan update result: ${out}

Make Voice call under NRCELL-3 and NRCELL-2
    Log To Console    setup PA for cell2
    Initialize PA Value
    PA Operation For cell2
    Log To Console    make call under cell2
    Prepare for UE
    Traffic UE Operation    attach    ue_index=0
    Sleep    60s
    Traffic UE Operation    start voice call    ue_index=0    dial=006688    duration=300s
    #Sleep    400s
    Traffic UE Operation    stop voice call    ue_index=0
    #Log To Console    check_cell2_counters     console=${True}
    #${rule}    Catenate
    #...         Distname: All;
    #...         Counter: M55119C01501;
    #...         Counter rule: delta_value(M55119C01501)>=1
    #Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=${global_bts_id}
    #...     counter_rule=${rule}
    #Sleep    60s
    #${result}    Counter Operation    operation=collect_counter

    Log To Console    setup PA for cell3
    PA Operation For cell3
    Log To Console    make call under cell3
    Traffic UE Operation    detach    ue_index=0
    Sleep    60s
    Traffic UE Operation    attach    ue_index=0
    Sleep    60s
    Traffic UE Operation    start voice call    ue_index=0    dial=006688    duration=200s
    #Sleep    400s
    Traffic UE Operation    stop voice call    ue_index=0
    #Log To Console    check_cell3_counters     console=${True}
    #Counter Operation    operation=start_collect_counter    product_type=gnb    bts_index=${global_bts_id}
    #...     counter_rule=${rule}
    #Sleep    60s
    #${result}    Counter Operation    operation=collect_counter

Initialize PA Value
    ${pa_port_list}    ${pa_value_list}    Split And Expand PA Parameters    pa_port=1-16;    pa_value=127;
    &{source}    Create Dictionary    att_index=${1}    pa_port=${pa_port_list}    pa_value=${pa_value_list}
    ...                               step=${2}
    PA Operation    operation=Initialize PA Value    source=&{source}

PA Operation For cell2
    ${source_pa_port_list}     Create List     5-8
    ${source_pa_value_list}    Create List     0    2
    &{source}    Create Dictionary    att_index=${1}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*16
    PA Operation    source=&{source}    target=none

PA Operation For cell3
    ${source_pa_port_list}     Create List     5-8
    ${source_pa_value_list}    Create List     120    127
    ${target_pa_port_list}     Create List     3-4
    ${target_pa_value_list}    Create List     0    2
    &{source}    Create Dictionary    att_index=${1}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*8
    &{target}    Create Dictionary    att_index=${1}    pa_port=${source_pa_port_list}    pa_value=${source_pa_value_list}
    ...                               step=${2}    pa_type=16*8
    PA Operation    source=&{source}    target=&{target}


Prepare for UE
    FOR    ${ue}    IN    @{uelist}
        ${ue.obj}=    Pet UE Setup    ue_type=android    host=${ue.info.pc}    serialno=${ue.info.serial}
        Run keyword and ignore error    Pet Ue Cancel Voice Call    ue=${ue.obj}
        Pet UE deattach    ue=${ue.obj}    points=${ue.info.attach_point}
    END

Apply All Success And Check Result Into Planned Configuration
    Log    Apply All Into Planned Configuration  console=True
    ${apply_result}    Compare And Apply Success And Check Result On CA


Get Nrcell Name
    ${nrcell_name_list}  Create List
    COAM_Admin.Login    bts_host=${mplan_ip}    username=Nemuadmin    password=nemuuser
    ${cell_list}    Get All Cell Id    connection=COAM
    FOR    ${cell_id}    IN    @{cell_list}
        append to list    ${nrcell_name_list}    NRCELL-${cell_id}
    END
    Set Test Variable    ${nrcell_name_list}
    [Teardown]    COAM_Admin.Logout
    [Return]    ${nrcell_name_list}


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


MantaRay Case Precondition
    Log To Console    Case Precondition
     Setup NetAct    ${NETACT}
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


MantaRay Case Postcondition
    Log To Console    \n Case Postcondition
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${Paging_Create_Plan_Name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PDCCH_Create_Plan_Name}
    #Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PDCCH_Cal_Plan_Name}
    #Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${PDCCH_Audit_Plan_Name}
    #Run Keyword If    ${NEED_RECOVER}    Full Commission SCF Via Rest    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    #${file_exist}    Run Keyword And Return Status    SSHLibrary.File Should Exist    ${REMOTE_FCT_FILE}
    #Run Keyword If    ${file_exist}    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${REMOTE_FCT_FILE}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PDCCH_FCT_NAME}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PUCCH_FCT_NAME}
    Run Keyword And Continue On Failure    SSHLibrary.Execute Command    rm ${MantaRay_FCT_File_Path}/${PAGING_FCT_NAME}
    Teardown NetAct
    SSHLibrary.Close All Connections


Check FCE Installed On Netact

    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    racclimx.sh -op FCT_List -v    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    Should Contain    ${stdout}    "toolName":"PDCCH"
	Should Contain    ${stdout}    "toolName":"Paging"
	Should Contain    ${stdout}	   "toolName":"PUCCH"



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


Audit Configuration And Check

    ${outputPlanName}    Set Variable    37392FCE-paging-outputDeltaPlan
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    ${cmd}    Catenate
    ...    racclimx.sh -op FCT_Audit_Configuration -targetObjects "${MRBTS_cell1}"
	...    -inputConfigurationType "actual" -toolName "Paging" -additionalInputParameters "[]"
    ...    -adaptationVersions "${FCE_release}" -outputPlanName ${outputPlanName}
    ...     -compareFeedbackLevel parameterLevel -compareExportDifferenceReport AuditReportFromActual.csv -v
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    SSHLibrary.Execute Command    rm -rf /d/oss/global/var/racops/export/AuditReportFromActual.csv
    SSHLibrary.File Should Not Exist    /d/oss/global/var/racops/export/AuditReportFromActual.csv
    ${stdout}    ${stderr}    ${rc}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}    return_rc=${True}
    Log    ${stdout}
    Should Be Equal As Integers    ${rc}    ${0}
    Should Contain    ${stdout}    Status received: Finished
    Should Contain    ${stdout}    "pagingOccasionRate":"25"
    SSHLibrary.File Should Exist    /d/oss/global/var/racops/export/AuditReportFromActual.csv
    SSHLibrary.Get File    /d/oss/global/var/racops/export/AuditReportFromActual.csv    ${TEST_LOG_DIRECTORY}/NetActLogs/
    SSHLibrary.Close Connection

Export Delta Plan
    [Arguments]    ${PLAN_NAME}
    Log    Export Delta Plan    console=True
    ${exportfile}    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${PLAN_NAME}.xml
    ...    dist_names=PLMN-PLMN/MRBTS-${instance_id}    plan_name=${PLAN_NAME}    operation_type=plan    ui_values=true
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
    log to console    check_parameters_for_paging_PDCCH
    @{para_list}    Create List   pagingOffset    pagingOffset    periodicity    periodicity
    @{mo_list}      Create List    MRBTS-37392/NRBTS-37392/NRCELL-2/    MRBTS-37392/NRBTS-37392/NRCELL-3
    ...    MRBTS-37392/NRBTS-37392/BWP_PROFILE-7/PDCCH-1/PDCCH_CONFIG_COMMON-1/Structure 3
    ...    MRBTS-37392/NRBTS-37392/BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_COMMON-1/Structure 3
    ${out}            Parameter Operation    operation=parameter_value_check    product_type=gnb
    ...                                      para_list=@{para_list}    mo_list=@{mo_list}
    Log To Console    Parameter Check Result: ${out}
    Should Contain    ${out}    pagingOffset.*1
    Should Contain    ${out}    periodicity.*sl10
    Should Not Contain    ${out}    pagingOffset.*0
    Should Not Contain    ${out}    periodicity.*sl5

Check Calculate PAGING Parameters In Delta Plan
    [Arguments]    ${targetCell}    ${PAGING_Parameters_Checklist}    ${delta_plan}
    ${scf_content}    L_XML.Parse Xml    ${delta_plan}
    ${distName_cell}    Set Variable    PLMN-PLMN/MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${list_param_names}    Get Dictionary Keys    ${PAGING_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
    ${p_value}    Run Keyword If    '${p_name}' == 'pagingOffset'    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/list[@name="pagingOffset"]/p
    ...    ELSE        L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/p[@name="${p_name}"]
    Log To Console    ${p_value}
    Should Be Equal As Strings    ${p_value}    ${PAGING_Parameters_Checklist["${p_name}"]}
    END

Check PAGING Parameters In Full Plan
    [Arguments]    ${targetCell}    ${PAGING_Parameters_Checklist}
    ${backup_scf_file}    COAM_Admin.BackupSCF    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=scf_recommended.xml
    ${scf_content}    L_XML.Parse Xml    ${backup_scf_file}
    ${distName_cell}    Set Variable    MRBTS-${instance_id}/NRBTS-${global_bts_id}/${targetCell}
    ${list_param_names}    Get Dictionary Keys    ${PAGING_Parameters_Checklist}
    FOR    ${p_name}    IN    @{list_param_names}
    ${p_value}    Run Keyword If    '${p_name}' == 'fPdcchMonOccsnPo'    L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/list[@name="fPdcchMonOccsnPo"]/p
    ...     ELSE        L_XML.Get Element Text
    ...    ${scf_content}    .//managedObject[@distName="${distName_cell}"]/p[@name="${p_name}"]
    Log To Console    ${p_value}
        Should Be Equal As Strings    ${p_value}    ${PAGING_Parameters_Checklist["${p_name}"]}
    END

Provision the plan SyVe
    [Arguments]    ${PLAN_NAME}
    Log    Provision the plan SyVe    console=True
    Set Test Variable    ${NEED_RECOVER}    ${True}
    NetAct Provision Plan    plan_name=${PLAN_NAME}    dist_names=PLMN-PLMN/MRBTS-${instance_id}
    ...    backup_plan_name=${PLAN_NAME}_backup    create_backup_plan=True    provisioning_operation=activate
    #Wait Until Keyword Succeeds    20min    2min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    #Wait until keyword succeeds    15m    1m    Verify bts and all cell status should be onair

Unzip FCT
    [Arguments]    ${zip_file}
    ${rc}    ${out_put}    OperatingSystem.Run and Return RC and Output    unzip -o ${zip_file} -d ${TEST_LOG_DIRECTORY}/TestFiles
    Should Be Equal As Integers    ${rc}    ${0}
    ${PDCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PDCCH\\w+\\.xlsx
	${PUCCH_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+PUCCH\\w+\\.xlsx
	${Paging_FCT_NAME}    Should Match Regexp    ${out_put}    \\w+Paging\\w+\\.xlsx
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${PDCCH_FCT_NAME}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${PUCCH_FCT_NAME}
    OperatingSystem.File Should Exist    ${TEST_LOG_DIRECTORY}/TestFiles/${Paging_FCT_NAME}
    [Return]    ${PDCCH_FCT_NAME}    ${PUCCH_FCT_NAME}    ${Paging_FCT_NAME}

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

Create FCT Create Configuration Command for step3
    ${cmd}    Catenate
    ...    racclimx.sh -op FCT_Create_Configuration_Plan
    ...    -targetObjects "${MRBTS_cell2},${MRBTS_cell3}"
    ...    -inputConfigurationType "actual" -toolName "Paging" -additionalInputParameters  "[]"
    ...    -adaptationVersions "${FCE_release}" -outputPlanName 37392-paging-FCEoutputfullPlan-cell2-cell3 -v
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}
    Log    ${stdout}
    Should Contain    ${stdout}    Status received: Finished
    Should Contain    ${stdout}    "pagingOccasionRate":"25"
    #SSHLibrary.Close Connection

Create FCT Create Configuration Command for step4
    ${cmd}    Catenate
    ...    racclimx.sh -op FCT_Create_Configuration_Plan
    ...    -targetObjects "${MRBTS_cell1},${MRBTS_cell2},${MRBTS_cell3}"
    ...    -inputConfigurationType "actual" -toolName "PDCCH" -additionalInputParameters  "[]"
    ...    -adaptationVersions "${FCE_release}"
    ...    -outputPlanName 37392-PDCCH-FCEoutputfullPlan-cell1-cell2-cell3 -v
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${stdout}    ${stderr}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}
    Log    ${stdout}
    Should Contain    ${stdout}    Status received: Finished
    #SSHLibrary.Close Connection

Check If Netact Plan Is Deleted
    [Arguments]    ${plan_name}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    netact.Delete Plan    ${plan_name}

NetAct Import Plan
    [Arguments]    ${local_dir}    ${file_name}    ${plan_name}    ${ui_values}=false
    ${status}    ${plan}=    Run Keyword And Ignore Error    Get Plan Configuration    ${plan_name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${plan_name}    ${plan}
    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    ${status}=    Run Keyword And Return Status    Import Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    plan_name=${plan_name}    ui_values=${ui_values}
    Run Keyword If    ${status}    Log    Plan ${plan_name} at ${local_dir}/${file_name} import success.    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} at ${local_dir}/${file_name} is fail.    level=ERROR
    ...    AND    Fail    Plan ${plan_name} at ${local_dir}/${file_name} is fail.

NetAct Export Plan
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan    ${ui_values}=None
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    '${status}' == 'False'    Create Directory    ${local_dir}
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

NetAct Export Plan test
    [Arguments]    ${local_dir}    ${file_name}    ${dist_names}    ${plan_name}    ${operation_type}=plan    ${ui_values}=None
    SSHLibrary.Open Connection    ${NETACT["was_host"]}
    SSHLibrary.Login    ${NETACT["user"]}    ${NETACT["password"]}
    ${cmd}    Catenate
    ...    racclimx.sh -v -op "Export" -type "plan" -DN "${dn_list}" -fileFormat "RAML2"
    ...    -fileName "37392-paging-FCEoutputfullPlan-cell2-celSl3.xml"
    ...    -planName "37392-PDCCH-FCEoutputfullPlan-cell1-cell2-cell3" -UIValues "true"
    ${stdout}    ${stderr}    SSHLibrary.Execute Command    ${cmd}    return_stderr=${True}
    Log    ${stdout}
    Should Contain    ${stdout}    Status received: Finished
    ${status}=    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${local_dir}
    Run Keyword If    '${status}' == 'False'    Create Directory    ${local_dir}
    ${status}=    Run Keyword And Return Status    netact.Export Configuration    local_dir=${local_dir}
    ...    file_name=${file_name}    operation_type=${operation_type}    dist_names=${dist_names}
    ...    plan_name=${plan_name}    ui_values=${ui_values}
    ${status}=    Run Keyword And Return Status    OperatingSystem.File Should Exist    ${local_dir}/${file_name}
    Run Keyword If    ${status}    Log    Plan ${plan_name} available at ${local_dir}/${file_name}    level=INFO
    ...    console=True
    ...    ELSE    Run Keywords    Log    Plan ${plan_name} not available at ${local_dir}/${file_name}    level=ERROR
    ...    AND    Fail    Plan ${plan_name} not available at ${local_dir}/${file_name}
    ${exportfile}=    Join Path    ${local_dir}    ${file_name}
    SSHLibrary.Close Connection
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
    [Arguments]    ${dist_names}
    ${status}=    Run Keyword And Return Status    netact.Upload Configuration    dist_names=${dist_names}
    Run Keyword If    ${status}    Log    CM Upload operation succesfully finished for ${dist_names}    console=True
    ...    ELSE    Run Keywords    Log    CM Upload operation failed for ${dist_names}    level=ERROR
    ...    AND    Fail    CM Upload operation failed for ${dist_names}


Setup NetAct
    [Arguments]     ${NETACT}
    netact.Add Node    cmwas    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    netact.Add Node    fmwas    ${NETACT['fm_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${web_url}=    netact.Detect WEB URL
    netact.Add WEB URL    ${web_url}    ${NETACT['user']}    ${NETACT['password']}


Teardown NetAct
    netact.Delete Node    cmwas
    netact.Delete Node    fmwas
    netact.Clean All