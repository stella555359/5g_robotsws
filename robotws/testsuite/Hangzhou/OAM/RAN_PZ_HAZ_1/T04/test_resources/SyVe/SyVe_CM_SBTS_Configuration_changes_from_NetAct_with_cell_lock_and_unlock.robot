*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_info}      PLAN_3    # selected plan infomation defined in netact_plan.yaml file;

*** Keywords ***
SyVe_CM_SBTS_Configuration_changes_from_NetAct_with_cell_lock_and_unlock
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12723
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct with cell lock unlock
    ...    based on selected PLAN_x
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial BTS MEDIATOR Connection status
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from NetAct
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in NetAct after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Lock cells using CM Editor without creating a plan
    ...    - Provision the backup plan
    ...    - Unlock cells using CM Editor without creating a plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from NetAct
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    - Check final BTS MEDIATOR Connection status
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; lock/unlock LNCEL work as expected;
    ...    states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-12723 - SyVe_CM_Configuration changes from NetAct with cell lock and unlock
    ...    - 08.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14416 - Use static Firefox profile for the Jnlp download
    ...    - 13.02.2019 - https://jira3.int.net.nokia.com/browse/TAT-14548
    ...    - NetAct Download JNLP file KW argument jnlp_download_dir not needed anymore
    ...    - 13.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14317 - Switch to new Robot Framework-Selenium2 library
    ...    - 20.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15310
    ...    - Add extra check in all TCs involving plan provisioning to alert when same parameters values are provisioned
    ...    - 03.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15603 - Remove backup plans from NetAct after test is done
    ...    - 14.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-15962 - New expected alarmId for "LMP access via port xxxxx" alarm
    ...    - 27.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16262 - [SyVe] Jnlp MRBTS 520 path not found
    ...    - 27.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16639 - Adapt and check Syve test running on FlatOAM, no BTS MED usage
    ...    - 19.09.2019 - https://jira3.int.net.nokia.com/browse/TAT-17475 - Update ignored alarms list.
    ...    - 18.11.2019 - https://jira3.int.net.nokia.com/browse/TAT-18205 - LNBTS ID need to be user configurable and different from MRBTS ID
    ...    - 09.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18208 - Need wait "Actual Configuration|PLMN-PLMN" on CM Editor Tree Node
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    Add cell locking status checking in Step 8. Add check status in teardwon after fullcommission.
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-12723_CM__SyVe_SBTS_Configuration_changes_from_NetAct_with_cell_lock_and_unlock.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Set Test Variable    ${plan_info}    ${NETACT_PLAN['${plan_info}']}
    TC parameters check
    Step 1: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check modified parameter in Netact after provision plan
    Step 10: Check modified parameter in Admin after provision plan
    Step 11: Lock cells using CM Editor without creating a plan
    Step 12: Provision the backup plan
    Step 13: Unlock cells using CM Editor without creating a plan
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}
    ${tmp}    Fetch From Right    ${plan_info['scf_distName']}    /
    ${LNCELL_config}    Fetch From Left    ${plan_info['scf_distName']}    /${tmp}
    ${LNCELL_id_mapping}    Fetch ID Mapping From Admin For Cells    LTE    ${LNCell_config}
    ${LNCELL_RT_DN}    Get From Dictionary    ${LNCELL_id_mapping}    internal
    Set Test Variable    ${LNCELL_RT_DN}
    ${LNCELL_all_mapping}    Fetch ID Mapping From Admin For Cells    LTE
    ${LNCELL_list}    Create List
    FOR    ${item}    IN    @{LNCELL_all_mapping}
        ${RT_DN}    Get From Dictionary    ${item}    internal
        Append To List    ${LNCELL_list}    ${RT_DN}
    END
    Remove Values From List    ${LNCELL_list}    ${LNCELL_RT_DN}
    Set Test Variable    ${LNCELL_Unlock_RTDN_list}    ${LNCELL_list}

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

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
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    ...    mo_id=${plan_info['mo_id']}    scf_distName=${plan_info['scf_distName']}    &{plan_info['parameter']}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    Log    Provision Plan    console=True
    ${cmd_str1}    Set Variable    racclimx.sh -planName ${name} -DN ${MRBTS_DN} -createBackupPlan true -backupPlanName ${name}_backup
    ${cmd_str2}    Set Variable    -v -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    SSHLibrary.Start Command      ${cmd_str1} ${cmd_str2}
    Log    Check Action    console=True
    ${result}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    20
        Sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    LNCEL    ${LNCELL_RT_DN}
        ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}"
        ${result}    Set Variable If    ${result}    ${result}    ${result_tmp}
        Check Other Objects On Air
    END
    Should Be True    ${result}
    FOR    ${index}    IN RANGE    0    20
        Sleep    3s
        ${result_tmp}    Run Keyword and Return Status    coam.Assert    LNCEL    ${LNCELL_RT_DN}    ${cells_LTE_expected_state}
        ${result}    Set Variable    ${result_tmp}
        Check Other Objects On Air
        Exit For Loop If    ${result_tmp}
    END
    Should Be True    ${result}
    ${result_Activate}    SSHLibrary.Read Command Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{plan_info['parameter']}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Lock cells using CM Editor without creating a plan
    Log    Step ${index}: Lock cells using CM Editor without creating a plan    console=True
    Navigate To Tree Node To Perform Operation
    Perform Lock On LNCEL Tree Node

Step ${index}: Unlock cells using CM Editor without creating a plan
    Log    Step ${index}: Unlock cells using CM Editor without creating a plan    console=True
    Perform Unlock On LNCEL Tree Node

Get First LNCEL ID
    ${lncel_id_matches}=    String.Get Regexp Matches    ${LTE_cell_ids[0]}    LNCEL_R-(\\d+)    1
    Set Test Variable    ${lncel_id}    ${lncel_id_matches[0]}
    Log    First LNCEL ID detected: ${lncel_id}    console=True

Get First Cell Admin State
    ${LNCEL_parameters_list}    ${WNCEL_parameters_list}    ${GNCEL_parameters_list}=    Admin Get BTS CELL parameters list
    Should Not Be Empty    ${LNCEL_parameters_list}
    ${first_cell_param_list}=    coam.Get Parameters For    LNCEL    ${LNCEL_parameters_list[0][0]}
    ${admin_state}=    Get From Dictionary    ${first_cell_param_list}    administrativeState
    [Return]    ${admin_state}

Admin Check Cell Administrative State is ${desired_admin_state_status}
    ${actual_admin_state_status}=    Get First Cell Admin State
#    Run Keyword Unless    '${actual_admin_state_status}' == '${desired_admin_state_status}'
    Run Keyword If    '${actual_admin_state_status}' != '${desired_admin_state_status}'
    ...    Fail    Wrong administrative state! Actual:${actual_admin_state_status}:/Expected:${desired_admin_state_status}
    [Return]    ${actual_admin_state_status}

Perform ${operation} On LNCEL Tree Node
    [Documentation]    Keyword used to perform lock or unlock on LNCEL tree node and wait for confirmation from WebEM
    Log    Perform ${operation} on LNCEL-${lncel_id}    console=True
    NetAct GUI Perform Tree Node Popup Menu Operation    tree_id=navigationTree    node_path=${jnlp_full_path}    operation=${operation}...
    ...    confirmation_dialog=CM Editor    confirmation_btn_name=defaultBtnOK
    Wait Until Keyword Succeeds    5min    5s    Admin Check Cell Administrative State is ${_${operation}ed_}
    Log    LNCEL-${lncel_id} administrative state confirmed from WebEM: ${operation}ed    console=True
    Wait Until Keyword Succeeds    10s    2s    Close Provision Dialog Window

Navigate To Tree Node To Perform Operation
    [Documentation]    Keyword used to perform all actions before starting to apply the NetAct GUI operation:
    ...               Download and open jnlp, expand tree nodes to reach
    ...    the tree node on which the operations will be performed
    Get First LNCEL ID
    NetAct GUI Prepare Environment
    NetAct Download JNLP file    start_page_url=https://${NETACT['web_url']}    user=${NETACT['user']}    pass=${NETACT['password']}
    ...    application_name=CM Editor    application_location=netact/public/jws/cm3apps/cmedit.jnlp    jnlp_name=cmedit.jnlp
    NetAct GUI Start Application    alias=CM Editor    jnlp_file=${jnlp_location}    window_name=CM Editor.*    timeout=600
    Sleep    120s
    ${jnlp_plmn_path}=    Set Variable    Actual Configuration|PLMN-PLMN
    ${jnlp_full_path}=    NetAct GUI Go To Tree Node    tree_id=navigationTree    path=${jnlp_plmn_path}
    ${plmn_childs}=    Wait Until Keyword Succeeds    10s    2s    NetAct GUI Tree Node Should Contain Child Nodes    navigationTree
    ...    ${jnlp_plmn_path}
    Set Test Variable    ${jnlp_mrbts_path}    ${jnlp_plmn_path}|MRBTS-${mrbts_id}
    FOR    ${plmn_child}    IN    @{plmn_childs}
        ${is_MRBTS}=    Run Keyword And Return Status    Should Contain    ${plmn_child}    MRBTS-
        Run Keyword If    ${is_MRBTS}    NetAct GUI Expand Tree Node    navigationTree    ${jnlp_plmn_path}|${plmn_child}
        ${mrbts_childs_exist}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    10s    2s
        ...    NetAct GUI Tree Node Should Contain Child Nodes    navigationTree
        ...    ${jnlp_plmn_path}|${plmn_child}
        ${mrbts_childs}=    Run Keyword If    ${mrbts_childs_exist} and ${is_MRBTS}    RemoteSwingLibrary.Get Tree Node Child Names    navigationTree
        ...    ${jnlp_plmn_path}|${plmn_child}
        ${desired_mrbts_node_found}=    Run Keyword And Return Status    List Should Contain Value    ${mrbts_childs}    MRBTS-${mrbts_id}
        Run Keyword If    ${desired_mrbts_node_found}    Run Keywords    Set Test Variable    ${jnlp_mrbts_path}
        ...    ${jnlp_plmn_path}|${plmn_child}|MRBTS-${mrbts_id}
        ...    AND    NetAct GUI Expand Tree Node    navigationTree    ${jnlp_mrbts_path}
        ...    AND    Exit For Loop
    END
    Run Keyword If    '${jnlp_mrbts_path}' == 'None'    Fail    Jnlp MRBTS ${mrbts_id} path not found!
    ...    ELSE    Log    Jnlp MRBTS path found: ${jnlp_mrbts_path}    console=True
    ${current_lnbts_id}=    Get Id For Current    LNBTS
    ${match}    ${lnbts_id}=    Should Match Regexp    ${current_lnbts_id}    (\\d+)\\D*\\Z
    Set Test Variable    ${lnbts_id}
    ${rest_of_path}=    Set Variable    LNBTS-${lnbts_id}|LNCEL-${lncel_id}
    ${jnlp_full_path}=    NetAct GUI Go To Tree Node    tree_id=navigationTree    path=${rest_of_path}    relative_path=${jnlp_mrbts_path}
    Set Test Variable    ${jnlp_full_path}
    Log    Identified full path to the desired object: ${jnlp_full_path}    console=True

Check Other Objects On Air
    FOR    ${item}    IN    @{LNCELL_Unlock_RTDN_list}
        coam.Assert    LNCEL    ${item}    ${cells_LTE_expected_state}
    END
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every    NRCEL    ${cells_NR_expected_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}

Close Provision Dialog Window
    RemoteSwingLibrary.Select Window    regexp=Provision.*
    Screenshot.Take Screenshot
    RemoteSwingLibrary.Close Window    regexp=Provision.*
    Screenshot.Take Screenshot
    RemoteSwingLibrary.Select Window    regexp=CM Editor.*
    RemoteSwingLibrary.Close All Dialogs

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Run Keyword If    ${plan_values} and not ${same_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    ${cell_locked}=    Run Keyword And Return Status    Admin Check Cell Administrative State is ${_Locked_}
    Run Keyword If    ${cell_locked}    Perform ${_Unlocked_} On LNCEL Tree Node
    SeleniumLibrary.Close Browser
    NetAct GUI Close Application    alias=CM Editor
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown