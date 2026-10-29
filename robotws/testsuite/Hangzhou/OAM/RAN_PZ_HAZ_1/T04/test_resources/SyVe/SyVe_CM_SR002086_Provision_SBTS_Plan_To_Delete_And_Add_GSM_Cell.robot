*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_SR002086_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-xxxx
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision a random selected gncell delete and add from NetAct
    ...    Transfer from RmtOAM_CM_Provision_SBTS_Plan_To_Delete_And_Add_GSM_Cell_SR002086_042_Automated
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check gncell be deleted
    ...    - Check final BTS state
    ...    - Provision the backup plan
    ...    - Check gncell be added
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add gncell provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.04.2023 - New Case

    Set Tags    AUTHOR-yuan.1.gao@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe
    Step 8: Check gncell be deleted
    Step 9: Check final BTS state
    Step 10: Provision the backup plan
    Step 11: Check gncell be added
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs


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
    Set Test Variable    ${GNCELL_list}    ${cell_list['cells']['gsm']}
    ${selected_cell}    Evaluate    random.choice(${GNCELL_list})    modules=random, sys
    Set Test Variable    ${selected_gncell_DN}    ${selected_cell['id']['configuration']}
    ${Initial_GNCELL_list_DN}    Create List
    FOR    ${item}    IN    @{GNCELL_list} 
        ${GNCELL_DN}    Set Variable     ${item['id']['configuration']}
        Append To List    ${Initial_GNCELL_list_DN}    ${GNCELL_DN}
    END
    Set Test Variable    ${Initial_GNCELL_list_DN}

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
    ${elements_for_gncell}    L_XML.Get Elements    ${scf_xml}    .//managedObject[contains(@distName,"${selected_gncell_DN}")]
    ${selected_gncell_lcrid}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${selected_gncell_DN}")]/p[@name="lcelcId"]
    ${gncell_cellmapping_str}=    catenate    SEPARATOR=    LCELC-    ${selected_gncell_lcrid}
    ${elements_for_cellMapping}    L_XML.Get Elements    ${scf_xml}
    ...    .//managedObject[contains(@distName,"${gncell_cellmapping_str}")]
    ${elements_to_delete}    Combine Lists    ${elements_for_gncell}    ${elements_for_cellMapping}
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
    ${reset}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        Sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check GSM RAT status
        Check Other Cells Onair
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    Should Be True    ${reset}
    ${GNcells_Status}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${GNcells_Status}    Run Keyword And Return Status    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}    timeout=30
        Check Other Cells Onair
        exit for loop if    ${GNcells_Status}
    END
    Should Be True    ${GNcells_Status}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

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
    ${reset}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        Sleep    3s
        ${result}    ${rat_status}=    run keyword and ignore error    Check GSM RAT status
        Check Other Cells Onair
        ${reset}    run keyword and return status    Should Be Equal As Strings    ${rat_status}    ALL_DISABLED
        exit for loop if    ${reset}
    END
    Should Be True    ${reset}
    ${GNcells_Status}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    120
        sleep    3s
        ${GNcells_Status}    Run Keyword And Return Status    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}    timeout=30
        Check Other Cells Onair
        exit for loop if    ${GNcells_Status}
    END
    Should Be True    ${GNcells_Status}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check gncell be deleted
    Log    Step ${index}: Check gncell be deleted    console=True
    ${cell_list_afterdelete}    coam.Get Cell List
    ${GNCELL_list_delete}    Set Variable    ${cell_list_afterdelete['cells']['gsm']}
    ${GNCELL_list_delete_DN}    Create List
    FOR    ${item}    IN    @{GNCELL_list_delete} 
        ${Gncell_DN_DE}    Set Variable     ${item['id']['configuration']}
        Append To List    ${GNCELL_list_delete_DN}    ${Gncell_DN_DE}
    END
    List Should Not Contain Value    ${GNCELL_list_delete_DN}    ${selected_gncell_DN}

Step ${index}: Check gncell be added
    Log    Step ${index}: Check gncell be added    console=True
    ${cell_list_afteradd}    coam.Get Cell List
    ${GNCELL_list_add}    Set Variable    ${cell_list_afteradd['cells']['gsm']}
    ${GNCELL_list_add_DN}    Create List
    FOR    ${item}    IN    @{GNCELL_list_add} 
        ${Gncell_DN_ADD}    Set Variable     ${item['id']['configuration']}
        Append To List    ${GNCELL_list_add_DN}    ${Gncell_DN_ADD}
    END
    List Should Contain Value    ${GNCELL_list_add_DN}    ${selected_gncell_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check Other Cells Onair
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every
    ...    LNCEL    ${cells_LTE_expected_state}    timeout=30
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every
    ...    WNCEL    ${cells_WCDMA_expected_state}    timeout=30
    ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every
    ...    NRCEL    ${cells_NR_expected_state}    timeout=30
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${TearDown_cell_list}    coam.Get Cell List
    ${TearDown_GNCELL_list}    Set Variable    ${TearDown_cell_list['cells']['gsm']}
    ${TearDown_GNCELL_list_DN}    Create List
    FOR    ${item}    IN    @{TearDown_GNCELL_list} 
        ${GNCELL_DN}    Set Variable     ${item['id']['configuration']}
        Append To List    ${TearDown_GNCELL_list_DN}    ${GNCELL_DN}
    END
    Sort List    ${TearDown_GNCELL_list_DN}
    Sort List    ${Initial_GNCELL_list_DN}
    ${status}    Run Keyword And Return Status    Lists Should Be Equal    ${TearDown_GNCELL_list_DN}
    ...    ${Initial_GNCELL_list_DN}
#    Run Keyword Unless    ${status}
    Run Keyword If    '${status}' != '${True}'
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown