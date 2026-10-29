*** Settings ***
Documentation     Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1013    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
@{SELECTED_TYPE}    NR_RAT_RESET
${REPEAT_TIME}    10


*** Keywords ***
SyVe_CM_Verify_Combined_Cell_Impacts_Parameters_Updating_with_NRCELL_Addition_Deletion
    [Documentation]    ST_OAM_Combine cell impacts parameters updating with cell addition deletion - EDA03153147
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for parallel nr cell impacting parameters updating with cell addition or deletion in one plan provision,
    ...    it is designed as robustness testing.
    ...
    ...    The main steps performed for the test are:
    ...
    ...
    ...    Pass criteria: delete and add NRCELL provision and parameter update operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.09.2023 - New Case
    ...    - 21.2.2025 - Xu Yuyan - Create Plan updated
    ...    - 15.4.2025 - Xu Yuyan - Add Repeat run
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    #Step 1: Check initial BTS state
    #Step 2: Check initial alarms status from WebEM
    #Step 3: Check initial alarms status from Netact
    Step 1: Upload configuration status
    Step 2: Random Select NRCELL
    Step 3: Random Select Parameter
    Log    ${REPEAT_TIME}
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        ##Teardown NetAct By TAF
        ##Setup NetAct By TAF
        ##${need_restart}    Evaluate    ${index}%${20}==0
        ##Run Keyword If     ${need_restart}    Restart Admin
        #Restart Infomodel And Syslog
        Step 4: Create and edit plan SyVe
        Step 5: Provision the plan SyVe
        Step 6: Check NRCELL be deleted
        Step 7: Check modified parameter in Netact after provision plan
        Step 8: Provision the backup plan
        Step 9: Check NRCELL be added
    END
    #Step 12: Check final alarms status from WebEM
    #Step 13: Check final alarms status from Netact
    #Step 14: Check final BTS state
    #Step 15: Check final number and state of Cells and RMs

Restart Admin
   Run Keyword And Continue On Failure    coam.Teardown Admin
   Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}

Restart Infomodel And Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1
    Run Keyword If  ${SMOD2_exists}
    ...    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD2

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${dic_bts_infor}    coam.Get Bts Info
    ${MRBTS_ID}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${NRCELL_list}    ${cell_list['cells']['nr']}
    ${NRBTS_RT_cell_num_initial}    Evaluate    len(${NRCELL_list})
    Set Test Variable    ${NRBTS_RT_cell_num_initial}
    ${selected_cell}    Evaluate    random.choice(${NRCELL_list})    modules=random, sys
    Set Test Variable    ${selected_nrcell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_nrcell_R}    ${selected_cell['id']['internal']}
    ${ALL_NRCELL_list}    Create List
    ${ALL_NRCELL_ID_list}    Create List
    FOR    ${item}    IN    @{NRCELL_list}
        ${nrcell_R}    Set Variable    ${item['id']['internal']}
        Append To List    ${ALL_NRCELL_list}    ${nrcell_R}
    END
    ${selected_nrcell_id}    Fetch From Right    ${selected_nrcell_DN}    -
    Set Test Variable    ${selected_nrcell_id}
    ${Initial_NRCELL_list_R}    Copy List    ${ALL_NRCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_NRCELL_list}    ${selected_nrcell_R}
    Set Test Variable    ${Other_NRCELL_list}    ${ALL_NRCELL_list}
    Set Test Variable    ${Initial_NRCELL_list_R}
    ${list_nrDU_infor}    Pop From Dictionary    ${dic_bts_infor}    nrDU
    Should Be Equal As Integers    ${list_nrDU_infor.__len__()}    ${1}
    ...    It must be one and only one NRDU for this test case.
    Set Test Variable    ${NRDU_NAME}    ${list_nrDU_infor[0]['id']['configuration']}
    Log To Console    Select cell:${selected_nrcell_DN}


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

Step ${index}: Random Select NRCELL
    Log    Step ${index}: Random Select NRCELL    console=True
    ${dic_bts_infor}    coam.Get Bts Info
    ${MRBTS_ID}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${NRCELL_list}    ${cell_list['cells']['nr']}
    ${NRBTS_RT_cell_num_initial}    Evaluate    len(${NRCELL_list})
    Set Test Variable    ${NRBTS_RT_cell_num_initial}
    ${selected_cell}    Evaluate    random.choice(${NRCELL_list})    modules=random, sys
    Set Test Variable    ${selected_nrcell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_nrcell_R}    ${selected_cell['id']['internal']}
    ${ALL_NRCELL_list}    Create List
    ${ALL_NRCELL_ID_list}    Create List
    FOR    ${item}    IN    @{NRCELL_list}
        ${nrcell_R}    Set Variable    ${item['id']['internal']}
        Append To List    ${ALL_NRCELL_list}    ${nrcell_R}
    END
    ${selected_nrcell_id}    Fetch From Right    ${selected_nrcell_DN}    -
    Set Test Variable    ${selected_nrcell_id}
    ${Initial_NRCELL_list_R}    Copy List    ${ALL_NRCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_NRCELL_list}    ${selected_nrcell_R}
    Set Test Variable    ${Other_NRCELL_list}    ${ALL_NRCELL_list}
    Set Test Variable    ${Initial_NRCELL_list_R}
    ${list_nrDU_infor}    Pop From Dictionary    ${dic_bts_infor}    nrDU
    Should Be Equal As Integers    ${list_nrDU_infor.__len__()}    ${1}
    ...    It must be one and only one NRDU for this test case.
    Set Test Variable    ${NRDU_NAME}    ${list_nrDU_infor[0]['id']['configuration']}
    Log To Console    Select cell:${selected_nrcell_DN}

Step ${index}: Random Select Parameter
    Log    Step ${index}: Random Select Parameter    console=True
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected NRCELL
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${name}    Create Plan To Delete NRCELL Via NetAct    ${selected_nrcell_DN}
    Set Test Variable   ${name}
    ${plan}    netact.Get Plan Configuration    ${name}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id']}     &{plan_info['parameter']}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1"]
#    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
#    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1    validatePlanAgainstDetectedHW=true
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Get Formatted NRCellList
    [Arguments]     ${nrCellList}
    ${formatedNRCellList}    Create List
    FOR    ${item}    IN    @{nrCellList}
        ${cellid}    Set Variable    ${item.strip()}
        Append To List    ${formatedNRCellList}    ${cellid}
    END
    [Return]     ${formatedNRCellList}

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    Wait Until Keyword Succeeds    5x    15s
    ...    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
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
    Wait Until Keyword Succeeds    20 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check NRCELL be deleted
    Log    Step ${index}: Check NRCELL be deleted    console=True
    ${after_deleted_nrcells}    coam.Get Ids For All    NRCEL
    Set Test Variable    ${after_deleted_nrcells}
    ${deleted_nrcells}    Copy List    ${Initial_NRCELL_list_R}
    Set Test Variable    ${deleted_nrcells}
    Remove Values From List    ${deleted_nrcells}    @{after_deleted_nrcells}
    Sort List    ${deleted_nrcells}
    ${after_deleted_nrcells_count}    Evaluate    len(${after_deleted_nrcells})
    Should Be Equal As Integers    ${NRBTS_RT_cell_num_initial}    ${after_deleted_nrcells_count+1}

Step ${index}: Check NRCELL be added
    Log    Step ${index}: Check NRCELL be added    console=True
    ${after_added_nrcells}    coam.Get Ids For All    NRCEL
    ${added_nrcells}    Copy List    ${after_added_nrcells}
    Remove Values From List    ${added_nrcells}    @{after_deleted_nrcells}
    Sort List    ${added_nrcells}
    Lists Should Be Equal    ${deleted_nrcells}    ${added_nrcells}
    ${after_added_nrcells_count}    Evaluate    len(${after_added_nrcells})
    Should Be Equal As Integers    ${NRBTS_RT_cell_num_initial}    ${after_added_nrcells_count}
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
    ${final_nrcells}    coam.Get Ids For All    NRCEL
    ${final_nrcells_count}    Evaluate    len(${final_nrcells})
    Run Keyword If    ${NRBTS_RT_cell_num_initial}!=${0} and ${NRBTS_RT_cell_num_initial}!=${final_nrcells_count}
    ...    Run Keywords    Wait Until Keyword Succeeds    5x    60s
    ...    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
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
    [Documentation]    Create and edit plan SyVe based on selected NRCELL
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${name}    ${TEST_NAME}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    #${elements_for_nrcell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${selected_nrcell_DN}")]
    ${elements_for_nrcell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@distName="${selected_nrcell_DN}"]
    ${selected_nrcell_lcrid}    Get CM Parameter Value From SCF    ${scf_path}    ${selected_nrcell_DN}    lcrId
    #${nrcell_cellmapping_str}    catenate    SEPARATOR=    LCELNR-    ${selected_nrcell_lcrid}
    ${nrcell_cellmapping_str}    catenate    SEPARATOR=    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-    ${selected_nrcell_lcrid}
    #${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    #...    .//managedObject[contains(@distName,"${nrcell_cellmapping_str}")]
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[@distName="${nrcell_cellmapping_str}"]
    Set Test Variable    ${nrcell_cellmapping_str}
    ${elements_for_nrcellGroup}    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.srbts.nrbts:NRCELLGRP"]
    ${cellgroup_dns}    Create List
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        Append To List    ${cellgroup_dns}    ${MO_items}
    END
    FOR    ${cellgroup}    IN    @{elements_for_nrcellGroup}
        ${MO_items}    L_XML.Get Element Attributes    ${cellgroup}
        ${nrCellList}    L_XML.Get Elements Texts    ${scf_xml}   .//managedObject[@distName="${MO_items['distName']}"]/list[@name="nrCellList"]
        ${formatedNRCellList}    Get Formatted NRCellList    ${nrCellList}
        ${isSlected_nrcell_cellgroup}    Run Keyword And Return Status    List Should Contain Value    ${formatedNRCellList}    ${selected_nrcell_id}
        Continue For Loop If    not ${isSlected_nrcell_cellgroup}
        Remove Values From List    ${formatedNRCellList}    ${selected_nrcell_id}
        Set Test Variable    ${formatedNRCellList}
        ${len}    Get Length    ${formatedNRCellList}
        ${nrcellgroup_operation}    Set Variable If    '${len}'=='0'   delete    update
        Set Test Variable    ${nrcellgroup_operation}
        Set Test Variable    ${selected_nrcellgroup}    ${MO_items}
        Exit For Loop
    END
    Remove Values From List    ${cellgroup_dns}    ${selected_nrcellgroup}
    ${other_cellgroup_ids}    Create List
    FOR    ${cellgroup}    IN    @{cellgroup_dns}
        ${distName}    Set Variable    ${cellgroup['distName']}
        ${grp_id}    Fetch From Right    ${distName}    -
        Append To List    ${other_cellgroup_ids}    ${grp_id}
    END
    ${elements_to_delete}    Combine Lists    ${elements_for_nrcell}    ${elements_for_cellMapping}
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
    ${element_nrdu}    L_XML.Get Elements    ${scf_xml}     .//managedObject[contains(@distName,"${NRDU_NAME}")]
    ${MO_NRDU}    L_XML.Get Element Attributes    ${element_nrdu[0]}
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_NRDU['class']}
    ...    meta_version=${MO_NRDU['version']}    mo_id=PLMN-PLMN/${MO_NRDU["distName"]}    refNrCellGroup=${other_cellgroup_ids}
    Run Keyword If    '${nrcellgroup_operation}'=='delete'    NetAct Create Managed Object    plan=${plan}
    ...    meta_class=${selected_nrcellgroup['class']}    meta_version=${selected_nrcellgroup['version']}
    ...    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}    operation=DELETE    &{EMPTY}
    ...    ELSE    NetAct Create Managed Object    plan=${plan}    meta_class=${selected_nrcellgroup['class']}
    ...    meta_version=${selected_nrcellgroup['version']}    mo_id=PLMN-PLMN/${selected_nrcellgroup["distName"]}   nrCellList=${formatedNRCellList}
    #NRPGRP
    ${element_nrpgrp}    L_XML.Get Elements    ${scf_xml}     .//managedObject[@class="com.nokia.srbts.nrbts:NRPGRP"]
    FOR    ${nrpgrp}    IN    @{element_nrpgrp}
        ${MO_NRPGRP}    L_XML.Get Element Attributes    ${nrpgrp}
        ${nrCellId}    L_XML.Get Element Text    ${nrpgrp}    .//list[@name="lbpsCellList"]//p[@name="nrCellId"]
        Run Keyword If    '${nrCellId}'=='${selected_nrcell_DN.split("-")[-1]}'     Run Keywords    NetAct Create Managed Object    plan=${plan}
        ...    meta_class=${MO_NRPGRP['class']}    meta_version=${MO_NRPGRP['version']}
        ...    mo_id=PLMN-PLMN/${MO_NRPGRP["distName"]}    operation=DELETE    &{EMPTY}
        ...    AND    Exit For Loop
    END
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id']}     &{plan_info['parameter']}
   ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${MRBTS_ID}/MNL-1"]
#    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
#    ...    meta_version=${MO_items['version']}    mo_id=PLMN-PLMN/MRBTS-${MRBTS_ID}/MNL-1    validatePlanAgainstDetectedHW=true
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan