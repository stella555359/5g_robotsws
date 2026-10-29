*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_5G_Lock_Unlock_NR_RAT_From_NetAct
    [Documentation]    [CASE LINK]:https://jira3.ext.net.nokia.com/browse/TAT-21571
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Automated testcase for Lock/Unlock LNCEL performed from NetAct.
    ...    Action: NetAct Monitor -> MRBTS-id -> LNBTS-id -> LNCEL-id -> Element Management -> State Management
    ...     -> Lock/Unlock LNCEL
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from NetactUpload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVend NetAct before and after Lock/Unlock NR RAT from NetAct
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan and after Lock/Unlock NR RAT from NetAct
    ...    - Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    ...    - Provision the backup plan
    ...    - Check recovered BTS state
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final number and state of Cells and RMs
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21571 - New case
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...     TAT-21571_SyVe_CM_Lock_Unlock_NR_RAT_From_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Provision the plan SyVe
    Step 8: Check modified parameter in Netact after provision plan
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    Step 11: Provision the backup plan
    Step 12: Check recovered BTS state
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final number and state of Cells and RMs

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

TC parameters check
    Log    TC parameters check started    console=True
    ${dic_bts_infor}    coam.Get Bts Info
    LOG Dictionary    ${dic_bts_infor}
    ${list_nrDU_infor}    Pop From Dictionary    ${dic_bts_infor}    nrDU
    Should Be Equal As Integers    ${list_nrDU_infor.__len__()}    ${1}
    ...    It must be one and only one NRDU for this test case.
    Set Test Variable    ${NRDU_NAME}    ${list_nrDU_infor[0]['id']['configuration']}
    Set Test Variable    ${MRBTS_DN}    PLMN-PLMN/${NRDU_NAME.split('/')[0]}
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Unlocked_}
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${NRDU_NAME}    ui_values=true    &{dic_param_value_checker}
    Should Be True    ${same_values}    TC parameters check failed: Parameters values to not equal to the existing ones!

Particular Teardown
    ${basic_status}    Set Variable
    ...    administrativeState=${_Com_Unlocked_},blockingState=${_Unblocked_},operationalState=${_Disabled_}
    ${are_nrcells_disabled}    ${cells}    Run Keyword And Ignore Error    coam.Assert Every    NRCEL
    ...    ${basic_status},availabilityStatus=${_Dependency_}
    Run Keyword If    '${are_nrcells_disabled}'=='PASS'    Step teardown: Provision the backup plan
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown    NO

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    TC parameters check
    Wait Until Keyword Succeeds    10x    10 sec    Check SBTS SMOD RMOD Cells Alarms
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    -
    Set Test Variable    ${mrbts_id}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${dic_param_value}    Create Dictionary    administrativeState    ${0}
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Locked_}
    Set Test Variable    ${dic_param_value_checker}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for lock ${NRDU_NAME}
    ...    mo_id=PLMN-PLMN/${NRDU_NAME}    scf_distName=${NRDU_NAME}    &{dic_param_value}
    Set Test Variable    ${plan}

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

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Locked_}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${NRDU_NAME}    ui_values=true
    ...    &{dic_param_value_checker}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${NRDU_NAME}    &{dic_param_value_checker}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin
    Log    Step ${index}: Check_RMOD_SMOD_Cell_Status_And_Alarms_After_NRDU_Locked_Via_Admin    console=True
    ${are_smods_online}     Check If All Objects Are Online    SMOD    10 sec
    ${are_rmods_online}     Check If All Objects Are Online    RMOD    10 sec
    ${are_gcells_online}     Check If All Objects Are Online    GNCEL    10 sec
    ...    administrativeState=${_Com_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ...    usageState=${_Active_}
    ${are_wcells_online}    Check If All Objects Are Online    WNCEL    10 sec
    ...    operationalState=${_Enabled_}    blockingState=${_Unblocked_}    usageState=${_Active_}
    ${are_lcells_online}    Check If All Objects Are Online    LNCEL    10 sec
    ...    administrativeState=${_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ...    proceduralState=${_OnAirDone_}
    ${basic_status}    Set Variable
    ...   administrativeState=${_Com_Unlocked_},blockingState=${_Unblocked_},operationalState=${_Disabled_},
    ${are_nrcells_disabled}    ${cells}    Run Keyword And Ignore Error    coam.Assert Every    NRCEL
    ...    ${basic_status}availabilityStatus=${_Dependency_}
    Admin Check Active Alarms TAF    print_alarms=${False}
    ${cell_online1}    Set Variable
    ...    "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS"
    ${cell_online2}   Set Variable
    ...    "${are_lcells_online}"=="PASS" and "${are_nrcells_disabled}"=="PASS"
    Should be true   "${are_smods_online}"=="PASS" and "${are_rmods_online}"=="PASS" and ${cell_online1} and ${cell_online2}
    ...    Not all conditions were satisfied!

Check Other Cells Onair
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every
    ...    GNCEL    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every
    ...    WNCEL    ${cells_WCDMA_expected_state}
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every
    ...    LNCEL    ${cells_LTE_expected_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}