*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
@{SELECTED_TYPE}    SBTS_SITE_RESET
${ACTIVE_SITE_OUTAGE_DURATION_STANDARD}    630   ##E2E Target: 10m
${PROVISION_SITE_OUTAGE_DURATION_STANDARD}    680   ##E2E Target: 11m

*** Keywords ***
TC__SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18772
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing plan activation from NetAct
    ...    based on SELECTED_TYPE
    ...    The main steps performed for the test are:
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Get initial BTS RESET info from blackbox file
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan and wait for BTS recovery
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Get final BTS RESET info from blackbox file
    ...    - Check BTS RESET behavior
    ...    - Provision the backup plan and wait for BTS recovery
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export, download and activation operation works as expected; states and alarms are as expected.
    ...    Plan file generated or deletet from SBTS local as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18772
    ...    - 09.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19535
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 02.23.2022 - Modified by Bin.7.Liu - https://jira3.ext.net.nokia.com/browse/TAT-22714 -
    ...    Select MOs and Parameters randomly
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-18772_SyVe_CM_Online_Modification_From_NetAct_Triggering_SBTS_Reset.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Random Select Parameter
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Get initial BTS RESET info from blackbox file
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan and wait for BTS recovery
    Step 9: Check modified parameter in Admin after provision plan
    Step 10: Check modified parameter in Netact after provision plan
    Step 11: Get final BTS RESET info from blackbox file
    Step 12: Check BTS RESET behavior
    Step 13: Provision the backup plan and wait for BTS recovery
    Step 14: Check final alarms status from Netact
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

Random Select Parameter
    Log    Random Select Parameter   console=True
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    Set Test Variable    ${plan_info_ui}
    Log    ${plan_info}    console=True

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    10 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Wait Until Keyword Succeeds    10x    60s      Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Get ${when} BTS RESET info from blackbox file
    [Documentation]    Get RESET info from blackbox file
    [Timeout]    15 min
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=${SMOD1['TRS_IP']}

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

Step ${index}: Provision the plan and wait for BTS recovery
    Log    Step ${index}: Provision the plan and wait for BTS recovery    console=True
    ${status}    Run Keyword And Return Status    netact.Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}
    ...    backup_plan_name=${name}_backup    create_backup_plan=True
    ...    provisioning_operation=preactivate    ignore_errors=True
    Should Be True    ${status}
    ${start_time}    Get Time
    ${status}    Run Keyword And Return Status    netact.Activate Preactivated Plan  plan_name=${name}    dist_names=${MRBTS_DN}
    Run Keyword If    ${status}    Log    Activate plan ${name} successfully done!    console=True
    ...    ELSE    Run Keywords    Log    Activate plan ${name} failed!    level=ERROR
    ...    AND    Fail    Activate plan ${name} failed!
    Wait Until Keyword Succeeds    20min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${ACTIVE_SITE_OUTAGE_DURATION_STANDARD}

Step ${index}: Check BTS RESET behavior
    [Documentation]    Final RESET info is compared with initial RESET info: reset number is 1
    [Timeout]    10 min
    Log    Step ${index}: Check BTS RESET behavior    console=True
    Check BTS RESET behavior SyVe    1

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan   console=True
    Wait Until Keyword Succeeds    20x    60s    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    ui_values=false    &{plan_info['parameter']}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan    console=True
    Check WebEM After Modify Parameters    ${plan_info_ui['scf_distName']}    &{plan_info_ui['parameter']}

Step ${index}: Provision the backup plan and wait for BTS recovery
    Log    Step ${index}: Provision the backup plan and wait for BTS recovery    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    ${start_time}    Get Time
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${end_time}    Get Time
    ${time}    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${time}<${PROVISION_SITE_OUTAGE_DURATION_STANDARD}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND   Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
