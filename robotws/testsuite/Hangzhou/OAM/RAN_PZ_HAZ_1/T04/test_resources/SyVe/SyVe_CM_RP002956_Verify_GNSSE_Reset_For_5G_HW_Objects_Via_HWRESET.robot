*** Settings ***
Documentation     SyVe_CM_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET_RP002956
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_RP002956_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-20766
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset GNSSE
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Infor
    ...    - TC parameters check
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check Reset GNSSE Behavior
    ...    - Check final number and state of Cells and RMs
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    - Create and edit backup Plan SyVe
    ...    - Provision the backup plan
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...    Pass criteria: create, edit, export and provision operation works as expected; GNSSE reset as expected;
    ...    states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-20766 -
    ...    SyVe_CM_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET_RP002956
    ...    - 31.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21121 -
    ...    Update to replace infomodel keywords to admin keywords
    ...    - 02.08.2021 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-21697 -
    ...    Switching ta_netact_* libraries to taf.nms.netact and NRBTS checking and add step 14
    ...    - 20.01.2022 - Modified by Xu Yuyan - https://jira3.ext.net.nokia.com/browse/TAT-22476 -
    ...    Update according to status changes in CNI-61110
    ...    - 23.03.2022 - Modified by Kang Lixin - https://jira3.ext.net.nokia.com/browse/TAT-22847 -
    ...    Update case for switching ute_admin to taf.sbts.oam.coam.admin
    ...      fix: Get Plan -> Get Plan Configuration
    ...    - 30.03.2023 - Modified by YuaGao:Discard using netact_plan.yaml
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    .. image:: http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SYVE/
    ...    TAT-20766_SyVe_CM_Verify_GNSSE_Reset_For_5G_HW_Objects_Via_HWRESET_RP002956.png
    Set Tags    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 1: Prepare the Plan Infor
    Step 2: TC parameters check
    Step 3: Check initial alarms status from WebEM
    Step 4: Check initial alarms status from Netact
    Step 5: Upload configuration status
    Step 6: Create and edit plan SyVe
    Step 7: Export the plan SyVe
    Step 8: Provision the plan SyVe
    Step 9: Check Reset GNSSE Behavior
    Step 10: Check final number and state of Cells and RMs
    Step 11: Check final alarms status from WebEM
    Step 12: Check final alarms status from Netact
    Step 13: Create and edit backup Plan SyVe
    Step 14: Provision the backup plan
    Step 15: Check final BTS state
    Step 16: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Infor
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}=    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{dic1_parameter1}    Create Dictionary    targetHwResetUDN=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_HWRES=${MRBTS_DN}/MNL-1/CMD-1/HWRESETREQ-1    mo_id_GNSSE=${MRBTS_DN}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
    ...    parameter1=${dic1_parameter1}
    Set Test Variable    ${plan_info}

Step ${index}: TC parameters check
    Log    Step ${index}:TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    ${existed_HWRES}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    &{param_EMPTY}
    ${existed_GNSSE}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_GNSSE']}    &{param_EMPTY}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_HWRES}
    Set Test Variable    ${existed_GNSSE}
    Run Keyword If    ${existed_HWRES} or not ${existed_GNSSE}    Log
    ...    TC parameters check failed: Object HWRESETREQ should not be existed or GNSSE should be existed!    level=ERROR
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${existed_HWRES}
    Should be true    ${existed_GNSSE}

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
    Wait Until Keyword Succeeds    10x    60 sec    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}     critical_alarms=${CRITICAL_ALARMS}

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
    Run Keyword If    not ${existed_CMD}    netact.create_managed_object    operation=CREATE    plan=${plan}
    ...    meta_class=${mnl_class}:CMD    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:HWRESETREQ    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_HWRES']}    &{plan_info['parameter1']}

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
    Wait Until Keyword Succeeds    5 min    3 sec    Check Current GNSSE State    operationalState    ${_Disabled_}
    Wait Until Keyword Succeeds    5 min    3 sec    Check Current GNSSE State    operationalState    ${_Enabled_}
    Wait Until Keyword Succeeds    3 min    3 sec    Check HWRESETRES Result
    Check All Cells On Air

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

Check Current GNSSE State
    [Arguments]    ${state_type}    ${expected_state}
    ${bts_info}    coam.Get Bts Info
    ${mod_info}    Get From Dictionary    ${bts_info}    gnsse
    ${id_dic}    Get From Dictionary    ${mod_info[0]}    id
    ${stateInfo}    Get From Dictionary    ${mod_info[0]}    stateInfo
    ${state}    Get From Dictionary    ${stateInfo}    ${state_type}
    Should Be Equal    ${state}    ${expected_state}

Check HWRESETRES Result
    ${BTS_scf_content}=    coam.Get SCF    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${BTS_scf_content}
    ${HWRESETRES_Result}=    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${plan_info['scf_distName']}/CMD-1/HWRESETREQ-1/HWRESETRES-1"]/p[@name="hwResetResult"]
    Should Be Equal As Strings    success    ${HWRESETRES_Result}

Check All Cells On Air
    ${gncell}    Run Keyword And Return Status    coam.Assert Any    GNCEL
    ${wncell}    Run Keyword And Return Status    coam.Assert Any    WNCEL
    ${lncell}    Run Keyword And Return Status    coam.Assert Any    LNCEL
    ${nrcell}    Run Keyword And Return Status    coam.Assert Any    NRCEL
    ${gncell_onair}    Run Keyword If    ${gncell}    Run Keyword And Return Status    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    ${wncell_onair}    Run Keyword If    ${wncell}    Run Keyword And Return Status    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    ${lncell_onair}    Run Keyword If    ${lncell}    Run Keyword And Return Status    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}
    ${nrcell_onair}    Run Keyword If    ${nrcell}    Run Keyword And Return Status    coam.Assert Every    NRCEL    ${cells_NR_expected_state}
    Run Keyword If    ${gncell}    Should Be True    ${gncell_onair}
    Run Keyword If    ${wncell}    Should Be True    ${wncell_onair}
    Run Keyword If    ${lncell}    Should Be True    ${lncell_onair}
    Run Keyword If    ${nrcell}    Should Be True    ${nrcell_onair}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id_HWRES']}    ui_values=true    &{plan_info['parameter1']}
    Run Keyword If    ${plan_values} and not ${existed_HWRES}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
