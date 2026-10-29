*** Settings ***
Documentation     Test case for SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_LTE3296_Verify_HWRESETREQ_With_RMOD_Reset
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19691
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset RMOD.
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - Random Select RMOD
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Reset RMOD Behavior
    ...    - Create and edit backup plan SyVe
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected;
    ...    RMOMD reset as expected; states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 07.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-19691
    ...    - SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296
    ...    - 03.03.2021 - change infomodel check to admin check
    ...    - 06.08.2021 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-21697
    ...    - Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking.
    ...    - 20.01.2022 - Modified by Xu Yuyan  - https://jira3.ext.net.nokia.com/browse/TAT-22476
    ...    - Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847
    ...    - Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      Add waiting time for RMOD enable; change the logic to select RMOD
    ...      Fix: Get Plan -> netact.Get Plan Configuration
    ...    - 28.03.2022 - Modified by YuaGao:Discard using netact_plan.yaml
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-19691_SyVe_CM_Verify_HWRESETREQ_With_RMOD_Reset_LTE3296.png
    Set Tags    AUTHOR-yiqing.yu@nokia-sbell.com    Maintainer–I_NSB_MN_SRAN_PROD_HZH_OPER1_VRF@internal.nsn.com
    Step 1: Prepare the Plan Infor
	Step 2: Random select RMOD
    Step 3: TC parameters check
    Step 4: Check initial BTS state
    Step 5: Check initial alarms status from WebEM
    Step 6: Check initial alarms status from Netact
    Step 7: Upload configuration status
    Step 8: Create and edit plan SyVe
    Step 9: Export the plan SyVe
    Step 10: Provision the plan SyVe
    Step 11: Check Reset RMOD Behavior
    Step 12: Create and edit backup Plan SyVe
    Step 13: Provision the backup plan
    Step 14: Check final alarms status from WebEM
    Step 15: Check final alarms status from Netact
    Step 16: Check final BTS state
    Step 17: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{targetHwResetUDNN}    Create Dictionary    targetHwResetUDN=MRBTS-${mrbts_id}/EQM-1/APEQM-1
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_HWRES=${MRBTS_DN}/MNL-1/CMD-1/HWRESETREQ-1    parameter1=${targetHwResetUDNN}
    Set Test Variable    ${plan_info}

Step ${index}: Random select ${mod}
    Log    Step ${index}:Random Select ${mod}    console=True
    ${mods_list}=    coam.Get Ids For All    ${mod}
    ${mods_num_tmp}=    Get Length    ${mods_list}
    Set Test Variable    ${mods_num}    ${mods_num_tmp}
    ${mod_expect}    Run Keyword And Return Status    should be true    ${mods_num}>0
#    Run Keyword Unless    ${mod_expect}    Log    ${mod} state are all disable!    level=ERROR
    Run Keyword If    not ${mod_expect}    Log    ${mod} state are all disable!    level=ERROR
    ${selected_mod}    Evaluate    random.choice(${mods_list})    modules=random, sys
    Set Test Variable    ${rmod_internal_id}    ${selected_mod}
    ${id_mapping}    Fetch ID Mapping From Admin For Module    ${selected_mod}    internal    ${mod}
    ${selected_mod_config}    Get From Dictionary    ${id_mapping}   configuration
    ${para}    Get Dictionary Keys    ${plan_info['parameter1']}
    ${para_dic}    Create Dictionary
    Set To Dictionary    ${para_dic}    ${para[0]}    ${selected_mod_config}
    Set Test Variable    ${para_dic}

Step ${index}: TC parameters check
    Log    Step ${index}:TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    ${existed_HWRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    &{para_dic}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_HWRES}
    Run Keyword If    ${existed_HWRES}    Log    TC parameters check failed: Object HWRESETREQ should not be existed!
    ...    level=ERROR
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${existed_HWRES}

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
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}=    NetAct Create Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}   .//managedObject[@distName="${plan_info['scf_distName']}"]
    ${mnl_class}    Fetch From Left    ${MO_items['class']}    :
    Set Test Variable    ${MO_items}
    Set Test Variable    ${mnl_class}
    Run Keyword If    not ${existed_CMD}    netact.Create Managed Object    operation=CREATE    plan=${plan}
    ...    meta_class=${mnl_class}:CMD    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:HWRESETREQ
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_HWRES']}    &{para_dic}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check Reset ${mod} Behavior
    Log    Step ${index}: Check Reset ${mod} Behavior    console=True
    Wait Until Keyword Succeeds    3 min    2 sec    coam.Assert   ${mod}   ${rmod_internal_id}   operationalState=${_Disabled_}
    Wait Until Keyword Succeeds    15 min    2 sec    coam.Assert   ${mod}   ${rmod_internal_id}   operationalState=${_Enabled_}
    Wait Until Keyword Succeeds    3 min    3 sec    Check HWRESETRES Result

Step ${index}: Create and edit backup Plan SyVe
    Log    Step ${index}: Create and edit backup Plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_Backup
    ${status}    ${plan_bu}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name_bu}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name_bu}    ${plan_bu}
    ${plan_bu}=    NetAct Create Plan    name=${name_bu}    description=Automation SyVe BackUp for MRBTS-${mrbts_id}
    ${mo_HWRES}=    netact.Create Managed Object    operation=DELETE    plan=${plan_bu}    meta_class=${mnl_class}:HWRESETREQ
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_HWRES']}
    ...    &{param_EMPTY}
    ${mo_CMD}=    Run Keyword If    not ${existed_CMD}    netact.Create Managed Object    operation=DELETE    plan=${plan_bu}
    ...    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan_bu}
    ...    mo_id=${plan_info['mo_id_HWRES']}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${mo_HWRES}    console=True
    ...    AND    Log    Parameters were set with plan ${plan_bu}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${name_bu}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check HWRESETRES Result
    ${BTS_scf_content}=    coam.Get SCF    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_content}
    ${HWRESETRES_Result}=    L_XML.Get Element Text    ${scf_xml}
    ...  .//managedObject[@distName="${plan_info['scf_distName']}/CMD-1/HWRESETREQ-1/HWRESETRES-1"]/p[@name="hwResetResult"]
    Should Be Equal As Strings    success    ${HWRESETRES_Result}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    &{para_dic}
    Run Keyword If    ${plan_values} and not ${existed_HWRES}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    Log     Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
