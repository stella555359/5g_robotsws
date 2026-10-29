*** Settings ***
Documentation       Test suite for SyVe_CM_CB009829_007
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${TEST_DATA_FILE_5G_RAT_Reset}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
${TEST_DATA_FILE_4G_RAT_Reset}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTERatReset/CM_LTERatReset_para.yaml
${TEST_DATA_FILE_Site_Reset}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
@{SELECTED_TYPE_1}    NR_RAT_RESET
@{SELECTED_TYPE_2}    LTE_RAT_RESET
@{SELECTED_TYPE_3}    SBTS_SITE_RESET


*** Keywords ***
SyVe_CM_CB009829_007_Provision_Plan_Containing_Modifications_of_RAT_Reset_and_Site_Reset_Triggering_Parameters
    [Documentation]
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    This case is mainly to verify RAT reset and BTS reset at the same time when MantaRay NM user creates a plan that modifies
    ...    parameters. Some modified parameters causes 5G or 4G RAT reset, some BTS reset.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 12.12.2024 - Modified by Kang Lixin - Add time kpi for CB012145
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com
    Step 1: Check initial BTS state
    Step 2: Check initial alarms status from WebEM
    Step 3: Check initial alarms status from Netact
    Step 4: Get initial BTS RESET info from blackbox file
    Step 5: Random Select Parameters
    Step 6: Create Plan With Reset Triggering Parameters
    Step 7: Provision the plan SyVe
    Step 8: Check Modified Parameter from Netact after Provision
    Step 9: Check Modified Parameter from Admin after Provision
    Step 10: Provision the backup plan
    Step 11: Get final BTS RESET info from blackbox file
    Step 12: Check BTS RESET behavior
    Step 13: Check final alarms status from WebEM
    Step 14: Check final alarms status from Netact

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

Step ${index}: Random Select Parameters
    Log To Console    Step ${index}: Random Select Parameters
    ${plan_info_1}    ${plan_info_ui_1}    ${expect_status_1}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE_5G_RAT_Reset}    ${SELECTED_TYPE_1}
    ${plan_info_2}    ${plan_info_ui_2}    ${expect_status_2}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE_4G_RAT_Reset}    ${SELECTED_TYPE_2}
    ${plan_info_3}    ${plan_info_ui_3}    ${expect_status_3}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE_Site_Reset}      ${SELECTED_TYPE_3}
    Set Test Variable    ${plan_info_1}
    Set Test Variable    ${plan_info_2}
    Set Test Variable    ${plan_info_3}
    Set Test Variable    ${plan_info_ui_1}
    Set Test Variable    ${plan_info_ui_2}
    Set Test Variable    ${plan_info_ui_3}

Step ${index}: Create Plan With Reset Triggering Parameters
    Log To Console    Step ${index}: Create Plan With Reset Triggering Parameters
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    ${timestamp}    Generate Formatted Timestamp
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${mrbts_id}_${timestamp}
    ${plan}    NetAct Create Plan     ${plan_name}    Automation SyVe for MRBTS-${mrbts_id}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info_1['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info_1['mo_id']}
    ...    &{plan_info_1['parameter']}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info_2['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info_2['mo_id']}
    ...    &{plan_info_2['parameter']}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${plan_info_3['scf_distName']}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}
    ...    meta_version=${MO_items['version']}    mo_id=${plan_info_3['mo_id']}
    ...    &{plan_info_3['parameter']}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${plan_name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${plan_name}    operation_type=plan
    Set Test Variable    ${plan}
    Set Test Variable    ${mrbts_id}

Step ${index}: Provision the plan SyVe
    Log    Step ${index}: Provision the plan SyVe    console=True
    NetAct Provision Plan    plan_name=${plan_name}   dist_names=${MRBTS_DN}    backup_plan_name=${plan_name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    30s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Modified Parameter from Netact after Provision
    Log    Step ${index}: Check Modified Parameter from Netact after Provision   console=True
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info_1['mo_id']}    &{plan_info_1['parameter']}
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info_2['mo_id']}    &{plan_info_2['parameter']}
    NetAct Check Actual Configuration Parameters    dist_name=${plan_info_3['mo_id']}    &{plan_info_3['parameter']}

Step ${index}: Check Modified Parameter from Admin after Provision
    Log    Step ${index}: Check Modified Parameter from Admin after Provision   console=True
    Check WebEM After Modify Parameters    ${plan_info_ui_1['scf_distName']}    &{plan_info_ui_1['parameter']}
    Check WebEM After Modify Parameters    ${plan_info_ui_2['scf_distName']}    &{plan_info_ui_2['parameter']}
    Check WebEM After Modify Parameters    ${plan_info_ui_3['scf_distName']}    &{plan_info_ui_3['parameter']}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${plan_name}_backup.csv
    ...    dist_names=${MRBTS_DN}    plan_name=${plan_name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${plan_name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Wait Until Keyword Succeeds    3x    10 sec    Final Checks SyVe

Step ${index}: Get ${when} BTS RESET info from blackbox file
    [Documentation]    Get RESET info from blackbox file
    [Timeout]    15 min
    Log    Step ${index}: Get ${when} BTS RESET info from blackbox file    console=True
    Get BTS RESET info from blackbox file SyVe    when=${when}    target_ip=${SMOD1['TRS_IP']}

Step ${index}: Check BTS RESET behavior
    [Documentation]    Final RESET info is compared with initial RESET info: reset number is 0
    [Timeout]    10 min
    Log    Step ${index}: Check BTS RESET behavior    console=True
    Check BTS RESET behavior SyVe    1

Particular Teardown
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}_backup
    ${plan_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info['mo_id']}    &{plan_info['parameter']}
    Run Keyword If    ${plan_values}    Run Keywords
    ...    Log    Parameters were not reset to initial values! Probably backup plan was not provisioned!    level=WARN
    ...    AND    Log    Will perform commissioning with initial scf!    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=400
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown