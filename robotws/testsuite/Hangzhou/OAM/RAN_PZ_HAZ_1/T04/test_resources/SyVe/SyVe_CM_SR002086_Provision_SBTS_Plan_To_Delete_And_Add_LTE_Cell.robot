*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-xxxx
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision a random selected lncell delete and add from NetAct
    ...    Transfer from RmtOAM_CM_Provision_SBTS_Plan_To_Delete_And_Add_LTE_Cell_SR002086_044_Automated
    ...    Update case due to cover RP002086_CM_038_Deletion of managed object and its child objects for cOAM SBTS
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Lncell be deleted
    ...    - Provision the backup plan
    ...    - Check Lncell be added
    ...    - Create and edit plan only with parent MO SyVe
    ...    - Export the parent plan SyVe
    ...    - Provision the parent plan SyVe
    ...    - Check Lncell be deleted
    ...    - Check the child MO be deleted
    ...    - Provision the backup plan
    ...    - Check Lncell be added
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add lncell provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 23.03.2023 - New Case
    ...    - 20.06.2023 - update due to RP002086_CM_038_Deletion of managed object and its child objects for cOAM SBTS

    Set Tags    AUTHOR-yuan.1.gao@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe
    Step 8: Check Lncell be deleted
    Step 9: Provision the backup plan
    Step 10: Check Lncell be added
    Step 11: Create and edit plan only with parent MO SyVe
    Step 12: Export the parent plan SyVe
    Step 13: Provision the parent plan SyVe
    Step 14: Check Lncell be deleted
    Step 15: Check the child MO be deleted
    Step 16: Provision the backup plan
    Step 17: Check Lncell be added
    Step 18: Check final alarms status from WebEM
    Step 19: Check final alarms status from Netact
    Step 20: Check final BTS state
    Step 21: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    5 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF
    Return From Keyword If    '${when}'!='initial'
    ${dic_bts_infor}    coam.Get Bts Info
    ${MRBTS_ID}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    Set Test Variable    ${MRBTS_ID}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${LNCELL_list}    ${cell_list['cells']['lte']}
    ${selected_cell}    Evaluate    random.choice(${LNCELL_list})    modules=random, sys
    Set Test Variable    ${selected_lncell_DN}    ${selected_cell['id']['configuration']}
    Set Test Variable    ${selected_lncell_R}    ${selected_cell['id']['internal']}
    ${ALL_LNCELL_list}    Create List
    FOR    ${item}    IN    @{LNCELL_list}
        ${Lncell_R}    Set Variable     ${item['id']['internal']}
        Append To List     ${ALL_LNCELL_list}     ${Lncell_R}
    END
    ${Initial_LNCELL_list_R}    Copy List    ${ALL_LNCELL_list}    deepcopy=True
    Remove Values From List    ${ALL_LNCELL_list}    ${selected_lncell_R}
    Set Test Variable    ${Other_LNCELL_list}    ${ALL_LNCELL_list}
    Set Test Variable    ${Initial_LNCELL_list_R}

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

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected LNCELL
    Log    Step ${index}: Create and edit plan SyVe    console=True
    Set Test Variable    ${name}    ${TEST_NAME}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${elements_for_lncell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${selected_lncell_DN}")]
    ${selected_lncell_lcrid}    Get CM Parameter Value From SCF    ${scf_path}    ${selected_lncell_DN}    lcrId
    ${lncell_cellmapping_str}    catenate    SEPARATOR=    LCELL-    ${selected_lncell_lcrid}
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${lncell_cellmapping_str}")]
    Set Test Variable    ${lncell_cellmapping_str}
    ${elements_list_for_nbiotLinkedCell}    Get NB-IOT Linked Cell Info    ${selected_lncell_DN}
    ${elements_to_delete}    Combine Lists    ${elements_for_lncell}    ${elements_for_cellMapping}    ${elements_list_for_nbiotLinkedCell}
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

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name}_backup -DN ${MRBTS_DN} -createBackupPlan false
    ${cmd2}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Check Lncell be deleted
    Log    Step ${index}: Check Lncell be deleted    console=True
    ${cell_list_afterdelete}    coam.Get Cell List
    ${LNCELL_list_delete}    Set Variable    ${cell_list_afterdelete['cells']['lte']}
    ${LNCELL_list_delete_DN}    Create List
    FOR    ${item}    IN    @{LNCELL_list_delete}
        ${Lncell_DN_DE}    Set Variable     ${item['id']['configuration']}
        Append To List    ${LNCELL_list_delete_DN}    ${Lncell_DN_DE}
    END
    List Should Not Contain Value    ${LNCELL_list_delete_DN}    ${selected_lncell_DN}

Step ${index}: Check Lncell be added
    Log    Step ${index}: Check Lncell be added    console=True
    ${cell_list_afteradd}    coam.Get Cell List
    ${LNCELL_list_add}    Set Variable    ${cell_list_afteradd['cells']['lte']}
    ${LNCELL_list_add_DN}    Create List
    FOR    ${item}    IN    @{LNCELL_list_add}
        ${Lncell_DN_ADD}    Set Variable     ${item['id']['configuration']}
        Append To List    ${LNCELL_list_add_DN}    ${Lncell_DN_ADD}
    END
    List Should Contain Value    ${LNCELL_list_add_DN}    ${selected_lncell_DN}

Step ${index}: Create and edit plan only with parent MO SyVe
    [Documentation]    Create and edit plan SyVe based on selected LNCELL with only parent MO
    Log    Step ${index}: Create and edit plan only with parent MO SyVe    console=True
    Set Test Variable    ${name_parent}    ${TEST_NAME}_parent
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name_parent}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name_parent}    ${plan}
    ${plan}    NetAct Create Plan    ${name_parent}    Automation for ${TEST_NAME}_parent
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${elements_for_lncell}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[@distName="${selected_lncell_DN}"]
    ${selected_lncell_lcrid}    Get CM Parameter Value From SCF    ${scf_path}    ${selected_lncell_DN}    lcrId
    ${lncell_cellmapping_str}    catenate    SEPARATOR=    LCELL-    ${selected_lncell_lcrid}
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[@distName="MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${lncell_cellmapping_str}"]
    ${elements_list_for_nbiotLinkedCell}    Get NB-IOT Linked Cell Info    ${selected_lncell_DN}    true
    ${elements_to_delete}    Combine Lists    ${elements_for_lncell}    ${elements_for_cellMapping}    ${elements_list_for_nbiotLinkedCell}
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

Step ${index}: Export the parent plan SyVe
    Log    Step ${index}: Export the parent plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_parent}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name_parent}    operation_type=plan

Step ${index}: Provision the parent plan SyVe
    Log    Step ${index}: Provision the parent plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd1}    Set Variable    racclimx.sh -planName ${name_parent} -DN ${MRBTS_DN} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${name_parent}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command    ${cmd1} ${cmd2} ${cmd3}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    40
        Sleep    3s
        Check Other Cells Onair
    END
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Step ${index}: Check the child MO be deleted
    Log    Step ${index}: Check the child MO be deleted    console=True
    ${scf_current}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_current}
    L_XML.Element Should Not Exist    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${selected_lncell_DN}")]    child MO for deleted cell still exist
    L_XML.Element Should Not Exist    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${lncell_cellmapping_str}")]    child MO for deleted cellmapping still exist

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe


Get NB-IOT Linked Cell Info
    [Arguments]     ${selected_lncell_dn}    ${only_parent}=False
    ${EMPTY_LIST}    Create List
    ${BTS_scf_content}     coam.Get SCF
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${status}    ${nbIotLinkedCellId}    Run Keyword And Ignore Error    L_XML.Get Element Text    ${BTS_scf_content}
    ...    .//managedObject[@distName="${selected_lncell_dn}"]/p[@name="nbIotLinkedCellId"]
    Return From Keyword If    '${status}'=='FAIL'    ${EMPTY_LIST}
    ${nbIotLinkedCellDn}    Set Variable    ${selected_lncell_dn.replace('${selected_lncell_dn.split('/')[-1].strip()}','LNCEL-${nbIotLinkedCellId}')}
    FOR    ${item}    IN    @{LNCELL_list}
        ${nbIotLinkedCellDn}    Set Variable If    "${item['cellName']}"=="${nbIotLinkedCellId}"
        ...    ${item['id']['configuration']}    ${nbIotLinkedCellDn}
        Exit For Loop If    "${item['cellName']}"=="${nbIotLinkedCellDn}"
    END
    ${cell_id_mapping}    Fetch ID Mapping From Admin For Cells    identifier=${nbIotLinkedCellDn}    identifier_type=configuration
    Remove Values From List    ${Other_LNCELL_list}    ${cell_id_mapping['internal']}
    ${filter}    Set Variable If    '${only_parent}'=='False'     .//managedObject[contains(@distName,"${nbIotLinkedCellDn}")]
    ...  .//managedObject[@distName="${nbIotLinkedCellDn}"]
    ${elements_for_nbiotLinkedCell}    L_XML.Get Elements    ${BTS_scf_content}    ${filter}
    ${nbiotLinkedCell_lcrid}    Get CM Parameter Value From SCF    ${scf_path}    ${nbIotLinkedCellDn}    lcrId
    ${nbiotLinkedCell_cellmapping_str}    catenate    SEPARATOR=    LCELL-    ${nbiotLinkedCell_lcrid}
    ${filter}    Set Variable If    '${only_parent}'=='False'     .//managedObject[contains(@distName,"${nbiotLinkedCell_cellmapping_str}")]
    ...  .//managedObject[@distName="MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${nbiotLinkedCell_cellmapping_str}"]
    ${elements_for_nbiotLinkedCellMapping}    L_XML.Get Elements    ${BTS_scf_content}    ${filter}
    ${elements_list_for_nbiotLinkedCell}    Combine Lists    ${elements_for_nbiotLinkedCell}    ${elements_for_nbiotLinkedCellMapping}
    [Return]    ${elements_list_for_nbiotLinkedCell}

Check Other Cells Onair
    FOR    ${item}    IN    @{Other_LNCELL_list}
        coam.Assert    LNCEL    ${item}    ${cells_LTE_expected_states}    timeout=30
    END
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every
    ...    GNCEL    ${cells_GSM_expected_state}    timeout=30
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every
    ...    WNCEL    ${cells_WCDMA_expected_state}    timeout=30
    ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every
    ...    NRCEL    ${cells_NR_expected_state}    timeout=30
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${cell_list_TearDown}    coam.Get Cell List
    ${LNCELL_list_TearDown}    Set Variable    ${cell_list_TearDown['cells']['lte']}
    ${LNCELL_list_TearDown_R}    Create List
    FOR    ${item}    IN    @{LNCELL_list_TearDown}
        ${Lncell_R_Tear}    Set Variable     ${item['id']['internal']}
        Append To List    ${LNCELL_list_TearDown_R}    ${Lncell_R_Tear}
    END
    Sort List    ${LNCELL_list_TearDown_R}
    Sort List    ${Initial_LNCELL_list_R}
    ${status}    Run Keyword And Return Status    Lists Should Be Equal    ${LNCELL_list_TearDown_R}
    ...    ${Initial_LNCELL_list_R}
#    Run Keyword Unless    ${status}
    Run Keyword If    '${status}' != '${True}'
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${scf_path}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown