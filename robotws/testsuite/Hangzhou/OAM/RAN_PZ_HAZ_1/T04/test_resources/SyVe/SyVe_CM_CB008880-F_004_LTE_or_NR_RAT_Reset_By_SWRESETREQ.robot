*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{BBMOD_NOT_SUPPORT}    ABIA    ABIL    ABIC
${NEED_TO_CHECK_5G_RAT_STATUS}    False
${NEED_TO_CHECK_LTE_RAT_STATUS}    True

*** Keywords ***
SyVe_CM_CB008880-F_004_LTE_or_NR_RAT_Reset_By_SWRESETREQ
    [Documentation]    [CASE]: RAN_SyVe_CB008880-F_004_ LTE or NR RAT reset manual operation by SWRESETREQ
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing CMD configuration changes from NetAct to reset LTE/NR rat.
    ...    The main steps performed for the test are:
    ...    - Prepare the Plan Info
    ...    - Random Select SwResetLevel
    ...    - TC parameters check
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Upload configuration status
    ...    - Create and edit plan SyVe
    ...    - Export the plan SyVe
    ...    - Provision the plan SyVe
    ...    - Check RAT Reset Behavior And BB RF Status
    ...    - Provision the backup plan
    ...    - Check final alarms status from WebEM
    ...    - Check final alarms status from Netact
    ...    Pass criteria: create, edit, export and provision operation works as expected; Selected rat reset as expected; related RF/BB not restart
    ...    states and alarms are as expected
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 16.11.2023 - New case add by Kang Lixin for RAN_SyVe_CB008880-F_005_ LTE or NR RAT hard reset manual operation by SWRESETREQ
    ...
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Step 0: Prepare the Plan Info
    Step 1: Random Select SwResetLevel
    Step 2: TC parameters check
    Step 3: Check initial BTS state
    Step 4: Check initial alarms status from WebEM
    Step 5: Check initial alarms status from Netact
    Step 6: Upload configuration status
    Step 7: Create and edit plan SyVe
    Step 8: Export the plan SyVe
    Step 9: Provision the plan SyVe
    Step 10: Check RAT Reset Behavior And BB RF Status
    Step 11: Provision the backup plan
    Step 12: Check final alarms status from WebEM
    Step 13: Check final alarms status from Netact
    Step 14: Check final BTS state
    Step 15: Check final number and state of Cells and RMs

Step ${index}: Prepare the Plan Info
    Log    Step ${index}: Prepare the Plan Infor    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    &{plan_info}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1    mo_id_CMD=${MRBTS_DN}/MNL-1/CMD-1
    ...    mo_id_SWRES=${MRBTS_DN}/MNL-1/CMD-1/SWRESETREQ-1    scf_distName_SWRES=MRBTS-${mrbts_id}/MNL-1/CMD-1/SWRESETREQ-1
    &{plan_info_feature_on}    Create Dictionary    scf_distName=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...    mo_id=${MRBTS_DN}/MNL-1/MNLENT-1/FEATCADM-1    param=actRatResetEnhancement   param_value=true
    Set Test Variable    ${plan_info}
    Set Test Variable    ${plan_info_feature_on}

Step ${index}: Random Select SwResetLevel
    [Documentation]    Step ${index}: Random Select SwResetLevel
    Log    Step ${index}: Random Select SwResetLevel    console=True
    ${techno_list}    Create List    GSM    WCDMA    LTE    GNB
    ${techno_under_test_list}    Create List    LTE    GNB
    Run Keyword If    len(${NRBTS_cell_ids})==0    Run Keywords    Remove Values From List    ${techno_list}    GNB
    ...    AND     Remove Values From List    ${techno_under_test_list}    GNB
    Run Keyword If    len(${LTE_cell_ids})==0   Run Keywords    Remove Values From List    ${techno_list}   LTE
    ...    AND    Remove Values From List    ${techno_under_test_list}   LTE
    Run Keyword If    len(${WCDMA_cell_ids})==0    Remove Values From List    ${techno_list}    WCDMA
    Run Keyword If    len(${GSM_cell_ids})==0    Remove Values From List    ${techno_list}    GSM
    &{Para_dic}    Create Dictionary    lteReset=1   gnbReset=5
    ${count}    Get Length   ${techno_under_test_list}
    Should Not Be Equal As Strings    '${count}'    '0'
    ${techno_under_test}    Evaluate    random.choice(${techno_under_test_list})    modules=random, sys
    Set Test Variable   ${techno_under_test}
    Remove Values From List    ${techno_list}    ${techno_under_test}
    Set Test Variable    ${techno_list}
    ${techno_lower}    String.Convert To Lower Case    ${techno_under_test}
    ${SwResetLevel_act}    Set Variable    ${techno_lower}Reset
    ${swResetLevel_set}    Get From Dictionary    ${Para_dic}    ${SwResetLevel_act}
    &{swResetLevel_set_dic}    Create Dictionary    swResetLevel=${swResetLevel_set}
    Set Test Variable    &{swResetLevel_set_dic}
    &{swResetLevel_act_dic}    Create Dictionary    swResetLevel=${swResetLevel_act}
    Set Test Variable    &{swResetLevel_act_dic}

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check started    console=True
    &{param_EMPTY}    Create Dictionary
    Set Test Variable    &{param_EMPTY}
    ${existed_CMD}   Run Keyword And Return Status   Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_CMD']}   &{param_EMPTY}
    ${existed_SWRES}   Run Keyword And Return Status   Check Actual Configuration Parameters   dist_name=${plan_info['mo_id_SWRES']}   &{param_EMPTY}
    Set Test Variable    ${existed_CMD}
    Set Test Variable    ${existed_SWRES}
    Run Keyword If    ${existed_SWRES}   Run Keywords    Log    TC parameters check failed: SWRESETREQ:will execute delta recommission!    level=WARN
    ...    AND    coam.Perform Delta Recommissioning    [{"distName": "${plan_info['scf_distName_SWRES']}", "operation": "delete", "parameters": []}]
    ...    True
    ...    ELSE    Log    TC parameters successfully checked    console=True
    ${mo}    Set Variable    ${plan_info_feature_on['scf_distName']}
    ${param}    Set Variable    ${plan_info_feature_on['param']}
    ${value}    Set Variable    ${plan_info_feature_on['param_value']}
    ${feature_on}   Run Keyword And Return Status   Check Actual Configuration Parameters    dist_name=${plan_info_feature_on['mo_id']}
    ...    actRatResetEnhancement=true
    Run Keyword If    not ${feature_on}    coam.Perform Delta Recommissioning
    ...    [{"distName": "${mo}", "operation": "update", "parameters": [{"parameterName": "${param}", "operation": "update", "value": "${value}"}]}]
    ...    True

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
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Create and edit plan SyVe
    [Documentation]    Create and edit plan SyVe based on selected PLAN_x define in netact_plan.yaml
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${status}    ${plan}=    Run Keyword And Ignore Error   netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${plan}    NetAct Create Plan    name=${name}    description=Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info['scf_distName']}"]
    ${mnl_class}    Fetch From Left    ${MO_items['class']}    :
    Set Test Variable    ${MO_items}
    Set Test Variable    ${mnl_class}
    Run Keyword If    not ${existed_CMD}     netact.Create Managed Object    operation=CREATE    plan=${plan}    meta_class=${mnl_class}:CMD
    ...    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_CMD']}    &{param_EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=${mnl_class}:SWRESETREQ    meta_version=${MO_items['version']}
    ...    mo_id=${plan_info['mo_id_SWRES']}    operation=CREATE    &{swResetLevel_set_dic}
    Set Test Variable    ${mrbts_id}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name_bu}    MRBTS-${mrbts_id}_${timestamp}_Backup
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name_bu}    create_backup_plan=True
    ...    provisioning_operation=activate

Step ${index}: Check RAT Reset Behavior And BB RF Status
    Log    Step ${index}: Check ${techno_under_test} rat reset and BB RF status   console=True
    ${formatted_techno}    Set Variable If    '${techno_under_test}'=='GNB'    NR    LN
    FOR    ${idx}    IN RANGE    180
        Sleep  3s
        ${rat_status}    Check ${techno_under_test} RAT status
        ${cells_status}    Run Keyword And Return Status    coam.Assert Every    ${formatted_techno}CEL    operationalState=${_Disabled_}
        Check Cell Related BB And RF Status
        Check Other RAT Status Enabled
        ${reset}   Run Keyword And Return Status     Should Be Equal As Strings     ${rat_status}    ALL_DISABLED
        Exit For Loop If   ${cells_status} and ${reset}
    END
    Should Be Equal As Strings    ${reset}    True
    FOR    ${idx}    IN RANGE    180
        ${rat_status}    Check ${techno_under_test} RAT status
        ${cells_status}    Run Keyword And Return Status    coam.Assert Every    ${formatted_techno}CEL    operationalState=${_Enabled_}
        Check Cell Related BB And RF Status
        Check Other RAT Status Enabled
        ${recovered}   Run Keyword And Return Status     Should Be Equal As Strings     ${rat_status}    ALL_ENABLED
        Exit For Loop If    ${cells_status} and ${recovered}
    END
    Wait Until Keyword Succeeds    6x    10 sec    Check SWRESETRES result

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name_bu}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name_bu}    operation_type=plan
    NetAct Provision Plan    plan_name=${name_bu}    dist_names=${MRBTS_DN}    backup_plan_name=None    create_backup_plan=False
    ...    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Check Cell Related BB And RF Status
    ${formatted_techno_for_rf}    Set Variable If    '${techno_under_test}'=='GNB'    Nr    Lte
    ${formatted_techno_for_bb}    Set Variable If    '${techno_under_test}'=='GNB'    5G    LTE
    ${smod_info}    coam.Get Parameters For All     SMOD
    ${is_outdoor}    Run Keyword And Return Status    Should Start With    ${smod_info[0]['fcmVariant']}    ASO
    Run Keyword If    ${is_outdoor}    Check RAT Related RF Online    ${formatted_techno_for_rf}
    ...    ELSE    Run Keywords    Check RAT Related BBMOD Online    ${formatted_techno_for_bb}
    ...    AND    Check RAT Related RF Online    ${formatted_techno_for_rf}

Check RAT Related RF Online
    [Arguments]     ${rat_techno}
    ${rmod_cells_mapping}     Get Relationship Between RMODs And Cells
    ${rmod_list}    Get Dictionary Keys    ${rmod_cells_mapping}
    FOR    ${rmod}    IN    @{rmod_list}
        ${cell_list}    Set Variable    ${rmod_cells_mapping['${rmod}']['active${rat_techno}CellsList']}
        Run Keyword If    len(${cell_list}) != 0
        ...    coam.Assert    RMOD    ${rmod}    administrativeState=${_Com_Unlocked_}, operationalState=${_Enabled_}
    END

Check RAT Related BBMOD Online
    [Arguments]     ${rat_techno}
    ${support_bbmod_on_bts}    Create List
    ${bbmod_list}    coam.Get Parameters For All    BBMOD
    FOR    ${bbmod}    IN    @{bbmod_list}
        ${var}    Set Variable    ${bbmod['productName'].split(' ')[0].strip()}
        ${status}    Run Keyword And Return Status   List Should Not Contain Value    ${BBMOD_NOT_SUPPORT}    ${var}
        Run Keyword If    ${status}    Append To List    ${support_bbmod_on_bts}    ${bbmod['id']}
    END
    ${bbmods_cells_mapping}    Get Relationship Between BBMODs And Cells
    FOR    ${bbmod}    IN    @{support_bbmod_on_bts}
        ${cell_list}    Set Variable    ${bbmods_cells_mapping['${bbmod}']['${rat_techno}']}
        Run Keyword If    len(${cell_list}) != 0    coam.Assert    BBMOD    ${bbmod}    ${BBMOD_expected_state}
    END

Check Other RAT Status Enabled
    FOR    ${te}    IN    @{techno_list}
        ${state}    Check ${te} RAT status
        Should Be Equal As Strings    ${state}    ALL_ENABLED
    END

Check ${techno_under_test} RAT status
    ${rat_techno}    Run Keyword If  '${techno_under_test}'=='GNB'  Set Variable   NR
    ...     ELSE     Set Variable   ${techno_under_test}
    ${rat}    String.Convert To Lower Case    ${rat_techno}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    Set Variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Check SWRESETRES result
    ${BTS_scf_SWRESETRES}  coam.get scf    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_SWRESETRES}
    ${swResetResult}    L_XML.Get Element Text    ${scf_xml}
    ...    .//managedObject[@distName="${plan_info['scf_distName_SWRES']}/SWRESETRES-1"]/p[@name="swResetResult"]
    Should Be Equal As Strings  success   ${swResetResult}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name_bu}
    ${plan_values}    Run Keyword And Return Status     Check Actual Configuration Parameters    dist_name=${plan_info['mo_id_SWRES']}
    ...    ui_values=true    &{swResetLevel_act_dic}
    Run Keyword If    ${plan_values} and not ${existed_SWRES}    Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown

