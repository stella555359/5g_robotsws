*** Settings ***
Documentation     SyVe_CM_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET_RP002956_5G
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_5G_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20727
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset BBMOD which connect to NRCELL.
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - Random Select NRCELL
    ...    - Random Select BBMOD with selected NRCELL
    ...    - TC parameters check
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Reset BBMOD Behavior
    ...    - Check final number and state of Cells and RMs
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Create and edit backup Plan SyVe
    ...    - Provision the backup plan
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; BBMOD reset as expected;
    ...    states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 13.01.2021 - https://jira3.int.net.nokia.com/browse/TAT-20727 -
    ...    SyVe_CM_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET_RP002956_5G
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking and add step 16
    ...    - 15.10.2021 - Bug fix by bin.7.liu@nokia-sbell.com - https://jira3.ext.net.nokia.com/browse/TAT-22051 -
    ...    Should select NRCELL_R from random item of NRCELL_R list
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 -
    ...    Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> Get Plan Configuration
    ...    - 23.03.2023 - Modified by YuaGao:Discard using netact_plan.yaml
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20727_SyVe_CM_Verify_BBMOD_Reset_For_5G_HW_Objects_Via_HWRESET_RP002956_5G.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Prepare the Plan Infor
    Step 2: Random select NRCELL
    Step 3: Random select BBMOD with selected NRCELL
    Step 4: TC parameters check
    Step 5: Check initial alarms status from WebEM
    Step 6: Check initial alarms status from Netact
    Step 7: Upload configuration status
    Step 8: Create and edit plan SyVe
    Step 9: Export the plan SyVe
    Step 10: Provision the plan SyVe
    Step 11: Check Reset BBMOD Behavior
    Step 12: Check final number and state of Cells and RMs
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact
    Step 15: Create and edit backup Plan SyVe
    Step 16: Provision the backup plan
    Step 17: Check final BTS state
    Step 18: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_HWRES=${MRBTS_DN}/MNL-1/CMD-1/HWRESETREQ-1
    Set Test Variable    ${plan_info}

Step ${index}: Random select NRCELL
    Log    Step ${index}: Random select NRCELL    console=True
    ${nrcell_num} =    Query Infomodel    get count //NRCELL_R-* is [operationalState=enabled]
    set test variable    ${nrcell_num}
    ${nrcell_expect}    run keyword and return status    should be true    ${nrcell_num}>0
#    Run Keyword Unless    ${nrcell_expect}    Log    Can not find NRCELL!    level=ERROR
    Run Keyword If   not ${nrcell_expect}   Log    Can not find NRCELL!    level=ERROR
    ${idx_nrcell}    Evaluate    random.randint(0,${nrcell_num-1})    modules=random, sys
    set test variable    ${idx_nrcell}

Step ${index}: Random select BBMOD with selected NRCELL
    Log    Step ${index}: Random select BBMOD mapping to selected NRCELL    console=True
    ${nrcell_list} =    Query Infomodel    get list //NRCELL_R-*
    set test variable    ${modDNList}    ${nrcell_list[${idx_nrcell}]}[modDNList]
    ${modDN_num}    Get Length    ${modDNList}
    ${idx}    Evaluate    random.randint(0,${modDN_num-1})    modules=random, sys
    set test variable    ${modDN}    ${modDNList[${idx}]}
    ${modDN_id}    Get Regexp Matches    ${modDN}    BBMOD-(\\d+)    1
    set test variable    ${modDN_id}
    ${targetHwResetUDN}    Set Variable    targetHwResetUDN
    &{param}    Create Dictionary
    set to dictionary    ${param}    ${targetHwResetUDN}=${modDN}
    set test variable    &{para_dic}    &{param}

Step ${index}: TC parameters check
    Log    Step ${index}:TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    ${existed_HWRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    &{param_EMPTY}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_HWRES}
    Run Keyword If    ${existed_HWRES}    Log    TC parameters check failed: Object HWRESETREQ should not be existed!    level=ERROR
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
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

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
    ${MO_items}=    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    ${mnl_class}    Fetch From Left    ${MO_items['class']}    :
    Set Test Variable    ${MO_items}
    Set Test Variable    ${mnl_class}
    Run Keyword If    not ${existed_CMD}    netact.create_managed_object    operation=CREATE    plan=${plan}    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:HWRESETREQ    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_HWRES']}    &{para_dic}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check Reset ${mod} Behavior
    Log    Step ${index}: Check Reset ${mod} Behavior    console=True
    ${mods_list} =    Query Infomodel    get list //${mod}_R-*
    FOR    ${item}    IN    @{mods_list}
        ${mod_id}    Get Regexp Matches    ${item["configDN"]}    ${mod}_A-(\\d+)    1
        ${mod_r_id}    Get Regexp Matches    ${item["dist_name"]}    ${mod}_R-(\\d+)    1
        exit for loop if    ${modDN_id[0]}==${mod_id[0]}
    END
    Wait Until Keyword Succeeds    5 min    2 sec    query infomodel    check //${mod}_R-${mod_r_id[0]} is [operationalState=disabled]
    Wait Until Keyword Succeeds    5 min    2 sec    query infomodel    check //${mod}_R-${mod_r_id[0]} is [operationalState=enabled]
    Wait Until Keyword Succeeds    3 min    3 sec    query infomodel    check //MNL_CONF_M-1//HWRESETRES_R-1 is [hwResetResult=success]
    Wait Until Keyword Succeeds    5 min    3 sec    query infomodel    every //NRCELL_R-* is [operationalState=enabled]

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Create and edit backup Plan SyVe
    Log    Step ${index}: Create and edit backup Plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_Backup
    ${status}    ${plan_bu}=    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name_bu}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name_bu}    ${plan_bu}
    ${plan_bu}=    NetAct Create Plan    name=${name_bu}    description=Automation SyVe BackUp for MRBTS-${mrbts_id}
    ${mo_HWRES}=    netact.create_managed_object    operation=DELETE    plan=${plan_bu}    meta_class=${mnl_class}:HWRESETREQ
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_HWRES']}
    ...    &{param_EMPTY}
    ${mo_CMD}=    Run Keyword If    not ${existed_CMD}    netact.create_managed_object    operation=DELETE    plan=${plan_bu}
    ...    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan_bu}    mo_id=${plan_info['mo_id_HWRES']}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created: ${mo_HWRES}    console=True
    ...    AND    Log    Parameters were set with plan ${plan_bu}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name_bu}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    ui_values=true    &{para_dic}
    Run Keyword If    ${plan_values} and not ${existed_HWRES}    Run Keywords
    ...    Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
