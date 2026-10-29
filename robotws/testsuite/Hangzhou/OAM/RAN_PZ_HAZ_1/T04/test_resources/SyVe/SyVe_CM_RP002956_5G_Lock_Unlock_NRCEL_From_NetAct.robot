*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_5G_Lock_Unlock_NRCEL_From_NetAct
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21572
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration changes from NetAct lock/unlock NR cell by setting parameter
    ...    'administrativeState'
    ...
    ...    The main steps performed for the test are:
    ...    - Check NR Cell Status And Parameters
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check recovered BTS state
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21572 - New case
    ...    - 04.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...                                  - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking
    ...    - 20.01.2022 - Modified by Kang Lixn - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...                                        - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...                                          - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-21572_SyVe_CM_Lock_Unlock_NRCEL_From_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Check NR Cell Status And Parameters
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check modified parameter in Netact after provision plan
    Step 10: Check modified parameter in Admin after provision plan
    Step 11: Provision the backup plan
    Step 12: Check final BTS state
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Unlocked_}
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${CELL_TO_LOCK}    ui_values=true    &{dic_param_value_checker}
    Should Be True    ${same_values}    TC parameters check failed: Parameters values to not equal to the existing ones!

Step ${index}: Check NR Cell Status And Parameters
    Log    Step ${index}: Check NR Cell Status And Parameters    console=True
    Select One NR Cell Randomly
    TC parameters check

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
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
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for lock ${CELL_TO_LOCK}
    ...    mo_id=PLMN-PLMN/${CELL_TO_LOCK}    scf_distName=${CELL_TO_LOCK}    &{dic_param_value}
    Set Test Variable    ${plan}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate

Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Netact ${when} provision ${plan_type}    console=True
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Locked_}
    Wait Until Keyword Succeeds    3x    30s    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${CELL_TO_LOCK}    ui_values=true
    ...    &{dic_param_value_checker}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    Check WebEM After Modify Parameters    ${CELL_TO_LOCK}    &{dic_param_value_checker}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Wait Until Keyword Succeeds    3x   30s    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}   ignored_alarms=${IGNORED_ALARMS}
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

Particular Teardown
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Locked_}
    ${cell_locked}    Run Keyword And Return Status    NetAct Check Actual Configuration Parameters
    ...    dist_name=PLMN-PLMN/${CELL_TO_LOCK}    ui_values=true    &{dic_param_value_checker}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Set Test Variable    ${SnapshotTriggerEndTest}    NO
    Run Keyword If    ${cell_locked}    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

Select One NR Cell Randomly
    ${cell_list}    coam.Get Cell List
    ${count}    Get Length    ${cell_list['cells']['nr']}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${CELL_TO_LOCK}    ${cell_list['cells']['nr'][${index}]['id']['configuration']}
