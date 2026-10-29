*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${VALIDATE_DATA}    ${EMPTY}

*** Keywords ***
SyVe_CM_RP002459_Switch_From_SRAN_To_LTE_Only_Mode_From_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19317
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing plan validate from NetAct
    ...    based on selected one item of VALIDATE_INFO in SyVe_CM_Switch_From_SRAN_To_LTE_Only_Mode_From_NetAct_RP002459.py
    ...    The main steps performed for the test are:
    ...    - TC Parameters Conversion
    ...    - Check initial BTS state
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Validate the plan SyVe
    ...    Pass criteria: create, edit, export, validate operation works as expected; expected error MO and error message
    ...    contain in validate error info; states and alarms are as expected.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-19317 - SyVe_CM_Switch_From_SRAN_To_LTE_Only_Mode_From_NetAct_RP002459
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
	...    TAT-19317_SyVe_CM_Switch_From_SRAN_To_LTE_Only_Mode_From_NetAct_RP002459.png
    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    Maintainer–I_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Convert Variables Of VALIDATE_INFO
    Step 1: Check initial BTS state
    Step 2: Upload configuration status
    Step 3: Create and edit plan SyVe
    Step 4: Export the plan SyVe
    Step 5: Validate the plan SyVe and Expect error

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State

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
    ...    mo_id=${VALIDATE_DATA['mo_id']}    scf_distName=${VALIDATE_DATA['scf_distName']}    &{VALIDATE_DATA['parameter']}
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Validate the plan SyVe and Expect error
    Log    Step ${index}: Validate the plan SyVe and Expect error    console=True
    ${status}    ${error}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=preactivate
    Should Contain Error    ${error}    ${VALIDATE_DATA["scf_distName"]}    ${VALIDATE_DATA["error_msg"]}

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
