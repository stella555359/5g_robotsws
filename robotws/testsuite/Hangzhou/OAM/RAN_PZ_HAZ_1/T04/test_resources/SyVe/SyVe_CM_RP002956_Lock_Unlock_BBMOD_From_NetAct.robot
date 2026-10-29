*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_Lock_Unlock_BBMOD_From_NetAct
    [Documentation]    [CASE LINK]:https://jira3.ext.net.nokia.com/browse/TAT-21570
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Select BBMOD and check parameters
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
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 08.07.2021 - https://jira3.int.net.nokia.com/browse/TAT-21570 - New case
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
    ...    TAT-21570_SyVe_CM_Lock_Unlock_BBMOD_From_NetAct_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Select BBMOD and check parameters
    Step 2: Check initial BTS state
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Check modified parameter in Netact after provision plan
    Step 11: Provision the backup plan
    Step 12: Check recovered BTS state
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${dic_param_value_checker}    Create Dictionary    administrativeState    ${_Com_Unlocked_}
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${BBMOD_TO_OPER}
    ...    ui_values=true    &{dic_param_value_checker}
    Set Test Variable    ${same_values}
    Should Be True    ${same_values}    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!

Step ${index}: Select BBMOD and check parameters
    Log    Step ${index}: Select BBMOD and check parameters    console=True
    Select One BBMOD Randomly
    TC parameters check

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Get BTS Key MOs Status Duration Until All Online

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
    ${plan}=    NetAct Create And Edit Plan    name=${name}    description=Automation SyVe for lock ${BBMOD_TO_OPER}
    ...    mo_id=PLMN-PLMN/${BBMOD_TO_OPER}    scf_distName=${BBMOD_TO_OPER}    &{dic_param_value}
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
    Wait Until Keyword Succeeds    10x    30 sec    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${BBMOD_TO_OPER}
    ...    ui_values=true    &{dic_param_value_checker}

Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}
    Log    Step ${index}: Check modified parameter in Admin ${when} provision ${plan_type}    console=True
    Wait Until Keyword Succeeds    10x    30 sec    Check WebEM After Modify Parameters    ${BBMOD_TO_OPER}    &{dic_param_value_checker}

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

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

Particular Teardown
    ${dic_param_value}    Create Dictionary    administrativeState    ${_Com_Unlocked_}
    ${plan_values}    Run Keyword And Return Status    Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${BBMOD_TO_OPER}
    ...    ui_values=true    &{dic_param_value}
#    Run Keyword Unless    ${plan_values}    Step teardown: Provision the backup plan
    Run Keyword If    not ${plan_values}    Step teardown: Provision the backup plan
    Wait Until Keyword Succeeds    10x    30 sec    Check BTS RAT Procedural State
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

Select One BBMOD Randomly
    ${bbmod_list}    coam.get_parameters_for_all    BBMOD
    ${count}    Get Length    ${bbmod_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${BBMOD_R_to_oper}    Set Variable    ${bbmod_list[${index}]['id']}
    ${BBMOD_TO_OPER}    Get MO Name Of MO_R    ${BBMOD_R_to_oper}
    Set Test Variable    ${BBMOD_TO_OPER}

