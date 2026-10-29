*** Settings ***
Documentation     Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1013    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTERatReset/CM_LTERatReset_para.yaml
@{SELECTED_TYPE}    LTE_RAT_RESET
${RECOVERY_FLAG}    ${False}
${REPEAT_TIME}    10

*** Keywords ***
SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_LNCELL_Addition_Deletion
    [Documentation]    ST_OAM_Combine cell impacts parameters updating with cell addition deletion - EDA03153147
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for parallel lte cell impacting parameters updating with cell addition or deletion in one plan provision,
    ...    it is designed as robustness testing.
    ...
    ...
    ...    Pass criteria: delete and add LNCEL provision and parameter update operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.09.2023 - New Case
    ...    - 24.2.2025 - Xu Yuyan - Update create Plan and related NBIOT cell need delete
    ...    - 15.4.2025 - Xu Yuyan - Add Repeat run

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    #Step 1: Check initial BTS state
    #Step 2: Check initial alarms status from WebEM
    #Step 3: Check initial alarms status from Netact
    Step 1: Upload configuration status
    Step 2: Random Select LNCELL
    Step 3: Random Select Parameter
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
#        Teardown NetAct By TAF
#        Setup NetAct By TAF
#        ${need_restart}    Evaluate    ${index}%${20}==0
#        Run Keyword If     ${need_restart}    Restart Admin
        Step 4: Create and edit plan SyVe
        Step 5: Provision the plan SyVe
        Step 6: Check LNCELL be deleted
        Step 7: Check modified parameter in Netact after provision plan
        Step 8: Provision the backup plan
        Step 9: Check LNCELL be added
    END
    #Step 12: Check final alarms status from WebEM
    #Step 13: Check final alarms status from Netact
    #Step 14: Check final BTS state
    #Step 15: Check final number and state of Cells and RMs

Restart Admin
   Run Keyword And Continue On Failure    coam.Teardown Admin
   Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}

Step ${index}: Check ${when} BTS state
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${dic_bts_infor}    coam.Get Bts Info
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${LNCELL_list}    ${cell_list['cells']['lte']}
    ${selected_cell}    Evaluate    random.choice(${LNCELL_list})    modules=random, sys
    Set Test Variable    ${selected_lncell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_lncell_R}    ${selected_cell['id']['internal']}
    ${ALL_LNCELL_list}    Create List
    FOR    ${item}    IN    @{LNCELL_list}
        ${Lncell_R}    Set Variable     ${item['id']['internal']}
        Append To List    ${ALL_LNCELL_list}    ${Lncell_R}
    END
    ${Initial_LNCELL_list_R}    Copy List    ${ALL_LNCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_LNCELL_list}    ${selected_lncell_R}
    Set Test Variable    ${Other_LNCELL_list}    ${ALL_LNCELL_list}
    Set Test Variable    ${Initial_LNCELL_list_R}
    #Check if NBIOT cell need delete
    ${LTE_IOTCell_mapping_dic}    Admin Get LTE CELL IOT mapping list
    log    ${LTE_IOTCell_mapping_dic}
    ${LTE_IOTCell_mapping_keys}    Get Dictionary Keys    ${LTE_IOTCell_mapping_dic}
    ${nbiot_cell_dn}    Set Variable    None
    ${host_cell_dn}    Set Variable    None
    FOR    ${host_cell}    IN    @{LTE_IOTCell_mapping_keys}
        ${nbiot_cell_rt}    Set Variable   ${LTE_IOTCell_mapping_dic["${host_cell}"]}
        Run Keyword If    "${nbiot_cell_rt}"!="None" and "${selected_lncell_DN.split("-")[-1]}"=="${host_cell.split("-")[-1]}"
        ...    Run Keywords    Set Test Variable    ${nbiot_cell_dn}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${nbiot_cell_rt.split("-")[-1]}
        ...    AND    Exit For Loop
        Run Keyword If    "${nbiot_cell_rt}"!="None" and "${selected_lncell_DN.split("-")[-1]}"=="${nbiot_cell_rt.split("-")[-1]}"
        ...    Run Keywords    Set Test Variable    ${host_cell_dn}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${host_cell.split("-")[-1]}
        ...    AND    Exit For Loop
    END
    Set Test Variable    ${nbiot_cell_dn}
    Set Test Variable    ${host_cell_dn}
    Log To Console    Select cell:${selected_lncell_DN}
    Log To Console    It's NBIOT cell:${nbiot_cell_dn}
    Log To Console    It's host cell:${host_cell_dn}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Random Select LNCELL
    Log    Step ${index}: Random Select LNCELL    console=True
    ${dic_bts_infor}    coam.Get Bts Info
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${LNCELL_list}    ${cell_list['cells']['lte']}
    ${selected_cell}    Evaluate    random.choice(${LNCELL_list})    modules=random, sys
    Set Test Variable    ${selected_lncell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_lncell_R}    ${selected_cell['id']['internal']}
    ${ALL_LNCELL_list}    Create List
    FOR    ${item}    IN    @{LNCELL_list}
        ${Lncell_R}    Set Variable     ${item['id']['internal']}
        Append To List    ${ALL_LNCELL_list}    ${Lncell_R}
    END
    ${Initial_LNCELL_list_R}    Copy List    ${ALL_LNCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_LNCELL_list}    ${selected_lncell_R}
    Set Test Variable    ${Other_LNCELL_list}    ${ALL_LNCELL_list}
    Set Test Variable    ${Initial_LNCELL_list_R}
    #Check if NBIOT cell need delete
    ${LTE_IOTCell_mapping_dic}    Admin Get LTE CELL IOT mapping list
    log    ${LTE_IOTCell_mapping_dic}
    ${LTE_IOTCell_mapping_keys}    Get Dictionary Keys    ${LTE_IOTCell_mapping_dic}
    ${nbiot_cell_dn}    Set Variable    None
    ${host_cell_dn}    Set Variable    None
    FOR    ${host_cell}    IN    @{LTE_IOTCell_mapping_keys}
        ${nbiot_cell_rt}    Set Variable   ${LTE_IOTCell_mapping_dic["${host_cell}"]}
        Run Keyword If    "${nbiot_cell_rt}"!="None" and "${selected_lncell_DN.split("-")[-1]}"=="${host_cell.split("-")[-1]}"
        ...    Run Keywords    Set Test Variable    ${nbiot_cell_dn}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${nbiot_cell_rt.split("-")[-1]}
        ...    AND    Exit For Loop
        Run Keyword If    "${nbiot_cell_rt}"!="None" and "${selected_lncell_DN.split("-")[-1]}"=="${nbiot_cell_rt.split("-")[-1]}"
        ...    Run Keywords    Set Test Variable    ${host_cell_dn}    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${host_cell.split("-")[-1]}
        ...    AND    Exit For Loop
    END
    Set Test Variable    ${nbiot_cell_dn}
    Set Test Variable    ${host_cell_dn}
    Log To Console    Select cell:${selected_lncell_DN}
    Log To Console    It's NBIOT cell:${nbiot_cell_dn}
    Log To Console    It's host cell:${host_cell_dn}

Step ${index}: Random Select Parameter
    Log    Step ${index}: Random Select Parameter    console=True
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected NRCELL
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${name}    Create Plan To Delete LNCELL Via NetAct    ${selected_lncell_DN}
    ${name}    Run Keyword If    "${nbiot_cell_dn}"!="None"    Create Plan To Delete LNCELL Via NetAct    ${nbiot_cell_dn}    ${name}
    ...    ELSE    Set Variable    ${name}
    Set Test Variable   ${name}
    ${plan}    netact.Get Plan Configuration    ${name}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${param_dic}    Create Dictionary    nbIoTMode=0
    ${MO_items}    Run Keyword If    "${host_cell_dn}"!="None"
    ...    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${host_cell_dn}"]
    Run Keyword If    "${host_cell_dn}"!="None"    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${MO_items['distName']}     &{param_dic}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id']}     &{plan_info['parameter']}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1"]
#    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
#    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1    validatePlanAgainstDetectedHW=true
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan



Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    Wait Until Keyword Succeeds    5x    15s
    ...    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    ${parameter_names}    Get Dictionary Keys    ${plan_info['parameter']}
    ${status}    ${current_param_value}    Run Keyword And Ignore Error    Get Actual Parameter Value From NetAct
    ...    ${plan_info['mo_id']}    ${parameter_names[0]}    ui_values=true
    Set Test Variable    &{parameter_ui}    ${parameter_names[0]}=${current_param_value}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    Wait Until Keyword Succeeds    5x    15s
    ...    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check LNCELL be deleted
    Log    Step ${index}: Check Lncell be deleted    console=True
    ${cell_list_afterdelete}    coam.Get Cell List
    ${LNCELL_list_delete}    Set Variable    ${cell_list_afterdelete['cells']['lte']}
    ${LNCELL_list_delete_DN}    Create List
    FOR    ${item}    IN    @{LNCELL_list_delete}
        ${Lncell_DN_DE}    Set Variable     ${item['id']['configuration']}
        Append To List    ${LNCELL_list_delete_DN}    ${Lncell_DN_DE}
    END
    List Should Not Contain Value    ${LNCELL_list_delete_DN}    ${selected_lncell_DN}

Step ${index}: Check LNCELL be added
    Log    Step ${index}: Check Lncell be added    console=True
    ${cell_list_afteradd}    coam.Get Cell List
    ${LNCELL_list_add}    Set Variable    ${cell_list_afteradd['cells']['lte']}
    ${LNCELL_list_add_DN}    Create List
    FOR    ${item}    IN    @{LNCELL_list_add}
        ${Lncell_DN_ADD}    Set Variable     ${item['id']['configuration']}
        Append To List    ${LNCELL_list_add_DN}    ${Lncell_DN_ADD}
    END
    List Should Contain Value    ${LNCELL_list_add_DN}    ${selected_lncell_DN}
    [Teardown]    Loop Teardown

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Loop Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup

Particular Teardown
    #Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    #Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword If Test Failed    coam.Collect Snapshot
    ...    ${Test Results Dir}/ADMIN_Snapshot_${timestamp}.zip    timeout=600
    Run Keyword If    ${RECOVERY_FLAG}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Log To Console    TC Setup
    Common Test Setup

TC Teardown
    Log To Console    TC Teardown
    Particular Teardown


Step ${index}: Create and edit plan SyVe-obsolete
    [Documentation]    Create and edit plan SyVe based on selected LNCELL
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${name}    ${TEST_NAME}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${elements_for_lncell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${selected_lncell_DN}")]
    ${selected_lncell_lcrid}    L_XML.Get Element Text    ${scf_xml}    .//managedObject[@distName="${selected_lncell_DN}"]/p[@name="lcrId"]
    ${lncell_cellmapping_str}=    catenate    SEPARATOR=    LCELL-    ${selected_lncell_lcrid}
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${lncell_cellmapping_str}")]
    ${elements_to_delete}    Combine Lists    ${elements_for_lncell}    ${elements_for_cellMapping}
    FOR    ${element}    IN    @{elements_to_delete}
        ${MO_items}    L_XML.Get Element Attributes    ${element}
        ${managed_object}    netact.create_managed_object    plan=${plan}    meta_class=${MO_items['class']}
        ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/${MO_items["distName"]}
        ...    operation=DELETE
        ${status}    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}
        ...    mo_id=PLMN-PLMN/${MO_items["distName"]}
        Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${managed_object}    console=True
        ...    AND    Log    Parameters were set with plan ${plan}    console=True
        ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
        ...    AND    Fail    MO creation failed!
    END
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id']}     &{plan_info['parameter']}
   ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${MRBTS_ID}/MNL-1"]
#    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
#    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1    validatePlanAgainstDetectedHW=true
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan