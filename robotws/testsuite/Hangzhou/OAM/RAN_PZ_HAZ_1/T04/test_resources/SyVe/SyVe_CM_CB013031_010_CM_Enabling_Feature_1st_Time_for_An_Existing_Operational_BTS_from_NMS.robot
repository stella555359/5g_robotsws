*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${REPEAT_TIME}    10

*** Keywords ***
SyVe_CM_CB013031_010_CM_Enabling_Feature_1st_Time_for_An_Existing_Operational_BTS_from_NMS
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for explains/verify what happens when Operator enables 1st time the CB013031-C/D feature during BTS runtime
    ...
    ...    Pass criteria: parameters are auto config correctly
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 14.08.2025 - New Case by Kang Lixin
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Prepare Delta Plan With Feature CB013031 Enable
    Step 2: Provision the plan
    Step 3: Check Auto-Config Parameters After Plan Provision
    Step 4: Disable Enable Feature CB013031 Multiple Times

Step ${index}: Prepare Delta Plan With Feature CB013031 Enable
    Log To Console    Step ${index}: Prepare Delta Plan With Feature CB013031 Enable
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=init_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=None    operation_type=actual
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${target_plan_name}    CB013031_010_delta_plan_with_param_change_${timestamp}
    ${plan}    NetAct Create Plan    ${target_plan_name}    CB013031_010_delta_plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1"]
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    operation=update    actCondAutoConfValCalc=true
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1"]
    #legacyopt-y cacv-n default-y -> cacv not working not assign value
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1   operation=update    alVoltHighThreshold=108
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1   operation=update    alVoltUnstableThreshold=10
    #legacyopt-y cacv-y default-y -> assign value
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1   operation=update    advanceTimeForRURestore=${EMPTY}
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:ALD   meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-255   operation=create
    NetAct Create Managed Object    plan=${plan}    meta_class=com.nokia.srbts.eqm:LNA   meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-255/LNA-1   operation=create    subunitNumber=1
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${target_plan_name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=${target_plan_name}    operation_type=plan

Step ${index}: Provision the plan
    Log To Console    Step ${index}: Provision the plan
    NetAct Provision Plan    plan_name=${target_plan_name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    backup_plan_name=${target_plan_name}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Auto-Config Parameters After Plan Provision
    Log To Console    Step ${index}: Check Auto-Config Parameters After Plan Provision
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${parameter}    Create Dictionary     controlProtocol=CWA    mhaType=WMHA
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/ALD-255    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    alVoltHighThreshold=108    alVoltUnstableThreshold=10    advanceTimeForRURestore=10
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1    ui_values=true    &{parameter}

Step ${index}: Disable Enable Feature CB013031 Multiple Times
    Log To Console    Step ${index}: Disable Enable Feature CB013031 Multiple Times
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    ${parameter}    Create Dictionary     actCondAutoConfValCalc=false   modeOfCondAutoConfValCalcDeact=1
    ${plan}    NetAct Create And Edit Plan    name=${name}    description=disable_feature_CB013031_MRBTS-${mrbts_id}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   scf_distName=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1   &{parameter}
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        NetAct Provision Plan    plan_name=${name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=${name}_backup
        ...    create_backup_plan=True    provisioning_operation=activate
        Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms
        NetAct Provision Plan    plan_name=${name}_backup   dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=None
        ...    create_backup_plan=False    provisioning_operation=activate
        Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms
    END

Particular Teardown
    NetAct Provision Plan    plan_name=${target_plan_name}_backup   dist_names=PLMN-PLMN/MRBTS-${mrbts_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${name}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${target_plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${target_plan_name} _backup
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
