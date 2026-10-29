*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_5G_Verify_Manual_Cell_Activation_From_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21280
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision 'actManualCellActivation' to value 'true', then 'administrativeState' of NR cells
    ...    should be 'locked' after SBTS reset.
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Information collection and status check
    ...    - Upload configuration status
    ...    - Create And Edit Plan SyVe For NRBTS
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Unlock All NR Cells
    ...    - Trigger Site Reset Via Admin
    ...    - Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    ...    - Unlock All NR Cells
    ...    - Provision the backup plan
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: delete and add NR RAT provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 29.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21280 - SyVe_CM_Verify_Manual_Cell_Activation_From_NetAct_RP002956_5G
    ...    - 08.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21837 - Remove the mandatory check that all rats must be online
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21280_SyVe_CM_Verify_Manual_Cell_Activation_From_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Information collection and status check
    Step 2: Upload configuration status
    Step 3: Create And Edit Plan SyVe For NRBTS
    Step 4: Export the plan SyVe
    Step 5: Provision the plan SyVe
    Step 6: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    Step 7: Check modified parameter in Netact after provision plan
    Step 8: Check modified parameter in Admin after provision plan
    Step 9: Unlock All NR Cells
    Step 10: Trigger Site Reset Via Admin
    Step 11: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    Step 12: Unlock All NR Cells
    Step 13: Provision the backup plan
    Step 14: Check final number and state of Cells and RMs

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

Particular Teardown
    ${dic_param_value}    Create Dictionary    administrativeState    ${_Com_Unlocked_}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${NRDU_NAME}    ui_values=true
    ...    &{dic_param_value}
    Run Keyword If    ${plan_values}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ${are_nrcells_online}    Check If All Objects Are Online    NRCEL    10 sec
    ...    administrativeState=${_Com_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    FOR    ${dn}    IN    @{LIST_NR_CELL_DN}
        Exit For Loop If    "${are_nrcells_online}"=="PASS"
        Run Keyword And Continue On Failure    coam.unlock    ${dn}
    END
    ${dic_param_value_checker}    Create Dictionary    actManualCellActivation    false
    ${same_values}    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${NRBTS_DN}    ui_values=true
    ...    &{dic_param_value_checker}
#    Run Keyword Unless    ${same_values}    Step teardown: Provision the backup plan
    Run Keyword If    not ${same_values}   Step teardown: Provision the backup plan
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${nrbts_plan}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${nrbts_plan}_backup
    Wait Until Keyword Succeeds    10x    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

Step ${index}: Information collection and status check
    Log    Step ${index}: Information collection and status check    console=True
    #Get information of MRBTS and NRBTS
    ${dic_bts_infor}    coam.Get Bts Info
    LOG Dictionary    ${dic_bts_infor}
    ${mrbtsID}    Pop From Dictionary    ${dic_bts_infor}    mrbtsID
    ${nrBtsId}    Pop From Dictionary    ${dic_bts_infor}    nrBtsId
    ${ratState}    Pop From Dictionary    ${dic_bts_infor}    ratState
    ${bts_status}    Pop From Dictionary    ${dic_bts_infor}    status
    Set Test Variable    ${MRBTS_ID}    ${mrbtsID}
    Set Test Variable    ${MRBTS_NAME}    MRBTS-${mrbtsID}
    Set Test Variable    ${NRBTS_NAME}    ${MRBTS_NAME}/NRBTS-${nrBtsId}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/${MRBTS_NAME}
    Set Test Variable    ${NRBTS_DN}    PLMN-PLMN/${NRBTS_NAME}
    #Get information of NR cells
    ${nr_cell_infor}    Set Variable    ${dic_bts_infor['cells']['nr']}
    ${list_nr_cell_name}    Create List
    ${list_nr_cell_dn}    Create List
    FOR    ${cell}    IN    @{nr_cell_infor}
        Append To List    ${list_nr_cell_name}    ${cell['id']['configuration']}
        Append To List    ${list_nr_cell_dn}    ${cell['id']['internal']}
    END
    Set Test Variable    ${LIST_NR_CELL_NAME}    ${list_nr_cell_name}
    Set Test Variable    ${LIST_NR_CELL_DN}    ${list_nr_cell_dn}
    #Check BTS status
    Should Be Equal As Strings    Unblocked    ${bts_status['blockingState']}
    Should Be Equal As Strings    Enabled    ${bts_status['operationalState']}
    Should Be Equal As Strings    OnAir    ${bts_status['proceduralState']}
    #Check key parameter(s)
    ${dic_param_value_checker}    Create Dictionary    actManualCellActivation    false
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${NRBTS_DN}
    ...    ui_values=true    &{dic_param_value_checker}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True

Step ${index}: Unlock All NR Cells
    Log    Step ${index}: Unlock All NR Cells    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${dic_param_value}    Create Dictionary    administrativeState    ${2}
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Unlocked_}
    FOR    ${cell_name}    IN    @{LIST_NR_CELL_NAME}
        ${nrcell_plan}    Set Variable    ${cell_name.split('/')[-1]}_${timestamp}
        ${plan}    NetAct Create And Edit Plan    name=${nrcell_plan}    description=Automation SyVe for ${cell_name.split('/')[-1]}
        ...    mo_id=PLMN-PLMN/${cell_name}    scf_distName=${cell_name}
        ...    &{dic_param_value}
        NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${nrcell_plan}.csv    dist_names=${MRBTS_DN}
        ...    plan_name=${nrcell_plan}    operation_type=plan
        NetAct Provision Plan    plan_name=${nrcell_plan}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
        ...    provisioning_operation=activate
        Check WebEM After Modify Parameters    ${cell_name}    &{dic_param_value_checker}
        Check If NetAct Plan Is Deleted    plan_name=${nrcell_plan}
    END

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create And Edit Plan SyVe For NRBTS
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create And Edit Plan SyVe For NRBTS    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${nrbts_plan}    ${NRBTS_NAME.split('/')[-1]}_${timestamp}
    ${dic_param_value_checker}    Create Dictionary    actManualCellActivation    true
    Set Test Variable    ${dic_param_value_checker}
    ${plan}=    NetAct Create And Edit Plan    name=${nrbts_plan}    description=Automation SyVe for ${NRBTS_NAME}    mo_id=${NRBTS_DN}
    ...    scf_distName=${NRBTS_NAME}    &{dic_param_value_checker}
    Set Test Variable    ${plan}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${nrbts_plan}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${nrbts_plan}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${nrbts_plan}    dist_names=${MRBTS_DN}    backup_plan_name=${nrbts_plan}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    ${dic_param_value_checker}    Create Dictionary    actManualCellActivation    true
    NetAct Check Actual Configuration Parameters    dist_name=${NRBTS_DN}    ui_values=true    &{dic_param_value_checker}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${NRBTS_NAME}    &{dic_param_value_checker}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${nrbts_plan}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${nrbts_plan}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${nrbts_plan}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    Log    Step ${index}: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin    console=True
    Wait Until Keyword Succeeds    20 min    30 sec    Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin

Step ${index}: Trigger Site Reset Via Admin
    Log    Step ${index}: Trigger Site Reset Via Admin    console=True
    coam.Reset Site

Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    ${are_smods_online}    Check If All Objects Are Online    SMOD    10 sec
    ${are_rmods_online}    Check If All Objects Are Online    RMOD    15 sec
    ${are_gcells_online}    Check If All Objects Are Online    GNCEL    10 sec
    ...    administrativeState=${_Com_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}   usageState=${_Active_}
    ${are_wcells_online}    Check If All Objects Are Online    WNCEL    10 sec    operationalState=${_Enabled_}
    ...    blockingState=${_Unblocked_}    usageState=${_Active_}
    ${are_lcells_online}    Check If All Objects Are Online    LNCEL    10 sec    administrativeState=${_Unlocked_}
    ...    operationalState=${_Enabled_}    blockingState=${_Unblocked_}    proceduralState=${_OnAirDone_}
    ${are_nrcells_disabled}    ${cells}    Run Keyword And Ignore Error    coam.Assert Every    NRCEL    ${cells_NR_locked_state}
    Admin Check Active Alarms TAF    print_alarms=${False}
    ${condition1}    Set Variable    "${are_smods_online}"=="PASS" and "${are_rmods_online}"=="PASS"
    ${condition2}    Set Variable    "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS"
    ${condition3}    Set Variable    "${are_lcells_online}"=="PASS" and "${are_nrcells_disabled}"=="PASS"
    Should be true    ${condition1} and ${condition2} and ${condition3}     Not all conditions were satisfied!
