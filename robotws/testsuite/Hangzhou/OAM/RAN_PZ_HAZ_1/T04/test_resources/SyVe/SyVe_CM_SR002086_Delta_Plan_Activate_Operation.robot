*** Settings ***
Documentation     Test case for xx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${plan_info}      PLAN_4    # selected plan infomation define in netact_plan.yaml file;


*** Keywords ***
SyVe_CM_SR002086_Delta_Plan_Activate_Operation
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-18449
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing plan activation from NetAct
    ...    based on selected PLAN_4
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Download the plan SyVe
    ...    - Check the plan stored in SBTS local
    ...    - Activate the plan SyVe
    ...    - Check the downloaded plan removed in SBTS local
    ...    - Check modified parameter in Netact after provision plan
    ...    - Check modified parameter in Admin after provision plan
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export, download and activation operation works as expected; states and alarms are as expected.
    ...    Plan file generated or deletet from SBTS local as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18449 - SyVe_CM_Delta_Plan_Activate_Operation_SR002086
    ...    - 02.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-18449_SyVe_CM_Delta_Plan_Activate_Operation_SR002086.png


    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_MN_SRAN_HZ_PROD_SRAN_SQUAD3@internal.nsn.com

    Set Test Variable    ${plan_info}    ${NETACT_PLAN['${plan_info}']}
    TC parameters check
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Upload configuration status
    Step 5: Create and edit plan SyVe
    Step 6: Export the plan SyVe
    Step 7: Download the plan SyVe
    Step 8: Check the plan stored in SBTS local
    Step 9: Activate the plan SyVe
    Step 10: Check the downloaded plan removed in SBTS local
    Step 11: Check modified parameter in Netact after provision plan
    Step 12: Check modified parameter in Admin after provision plan
    Step 13: Provision the backup plan
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

TC parameters check
    Log    TC parameters check started    console=True
    ${same_values}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True     ${same_values}

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

Step ${index}: Download the plan SyVe
    Log    Step ${index}: Download the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=preactivate

Step ${index}: Activate the plan SyVe
    Log    Step ${index}: Activate the plan SyVe    console=True
    NetAct Activate Plan    plan_name=${name}    dist_names=${MRBTS_DN}

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}

Step ${index}: Check modified parameter in Admin after provision plan
    Log    Step ${index}: Check modified parameter in Admin after provision plan   console=True
    Check WebEM After Modify Parameters    ${plan_info['scf_distName']}    &{plan_info['parameter']}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check the plan stored in SBTS local
    Log    Step ${index}: Check the plan stored in SBTS local
    ${bts_SW_list}=    Admin Get BTS SW Version
    ${activate_SW}    Set Variable    ${bts_SW_list[0]}
    Set Test Variable    ${activate_SW}
    ${plan_str}=    Convert To String    ${plan}
    ${plan_str}=    Fetch From Right    ${plan_str}    conf_id =
    ${plan_str}=    Fetch From Left    ${plan_str}    ): Automation SyVe
    ${conf_id}=    Strip String    ${plan_str}
    Set Test Variable    ${conf_id}
    Check File Exist From SBTS Local    file_path=/rom/config/ne3sadapt/plans/${activate_SW}    file_name=${conf_id}.xml
    ...    flag=${True}

Step ${index}: Check the downloaded plan removed in SBTS local
    Log    Step ${index}: Check the downloaded plan stored in SBTS local
    Check File Exist From SBTS Local    file_path=/rom/config/ne3sadapt/plans/${activate_SW}    file_name=${conf_id}.xml
    ...    flag=${False}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    ${plan_values}=    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id']}
    ...    &{plan_info['parameter']}
    Run Keyword If    ${plan_values} and not ${same_values}    Run Keywords    Log
    ...  Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400    AND    Wait Until Keyword Succeeds  20min   60s     Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown


TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown


