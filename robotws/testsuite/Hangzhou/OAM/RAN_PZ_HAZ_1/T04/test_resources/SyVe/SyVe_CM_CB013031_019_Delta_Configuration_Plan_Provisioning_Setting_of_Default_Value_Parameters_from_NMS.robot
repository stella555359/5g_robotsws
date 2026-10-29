*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${nrcell_id}    1

*** Keywords ***
SyVe_CM_CB013031_019_Delta_Configuration_Plan_Provisioning_Setting_of_Default_Value_Parameters_from_NMS
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing configuration plan provisioning changes from the Network Element perspective with processing of
    ...    setting default values parameters
    ...
    ...    Pass criteria: parameters are auto config correctly
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.08.2025 - New Case by Kang Lixin
    ...    *******************
    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Prepare Env To Delete NRCELL And Enable CB013031
    Step 2: Prepare Delta Plan For NRCELL Creation With Optional Params Has Default Value
    Step 3: Provision the plan
    Step 4: Check Auto-Config Parameters After MO Creation
    Step 5: Prepare Delta Plan For Delete And Modify Optional Params Has Default Value
    Step 6: Provision the plan
    Step 7: Check Auto-Config Parameters After MO Modification

Step ${index}: Prepare Env To Delete NRCELL And Enable CB013031
    Log To Console    Step ${index}: Prepare Env To Delete NRCELL And Enable CB013031
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${NRCELL_list}    ${cell_list['cells']['nr']}
    ${NRBTS_RT_cell_num_initial}    Evaluate    len(${NRCELL_list})
    Set Test Variable    ${NRBTS_RT_cell_num_initial}
    Set Test Variable    ${selected_nrcell_DN}    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_id}
    ${plan_name}    Create Plan To Delete NRCELL Via NetAct    ${selected_nrcell_DN}
    Set Test Variable    ${plan_name}
    NetAct Provision Plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   backup_plan_name=${plan_name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Check NRCELL be deleted
    Set Test Variable    ${lcelnr_dn}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    Set Test Variable    ${nrcellgp_dn}    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELLGRP-0
    Modify Param Value From Admin   MRBTS-${mrbts_id}/MNL-1    fallbackOnFailedOnlineUpgrade    Disabled
    Log To Console    Modify actCondAutoConfValCalc to true
    Modify Param Value From Admin   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    actCondAutoConfValCalc    true
    Wait Until Keyword Succeeds    20m    60s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Prepare Delta Plan For NRCELL Creation With Optional Params Has Default Value
    Log To Console    Step ${index}: Prepare Delta Plan For NRCELL Creation With Optional Params Has Default Value
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=${plan_name}_backup    operation_type=plan
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${target_plan_name}    CB013031_019_delta_plan_with_param_change_${timestamp}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${xml_content}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${plan_name}_backup.csv
    #legacyopt-y cacv-y default-y -> conditional value #PR847504
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="a1MeashoEnabled"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="a1MeashoEnabledSA"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="actPdschAllocAroundSsb"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="adaptiveSrBlockingMinimization"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="upperMcsPowerBackoff"]
    #legacyopt-y cacv-n default-y -> set empty
    L_XML.Remove Elements    ${xml_content}    .//managedObject/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2ThresholdHoSsbRsrpVoNr"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2TimeToTriggerHoSsbRsrpVoNr"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2HysteresisHoSsbRsrpVoNr"]
    #legacyopt-n cacv-n default-y -> set default
    L_XML.Remove Elements    ${xml_content}    .//managedObject/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2HysteresishoSsbRsrpSA"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/list[@name="a2MeashoSsbRsrpSA"]/item/p[@name="a2TimeToTriggerhoSsbRsrpSA"]
    #legacyopt-n cacv-n default-y -> set default
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="actSimplChConfMAA"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="actAsiDistMimoNr"]
    #legacyopt-n cacv-y default-y -> condition value or default
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="actPucchBeamConstraintFR2"]
    L_XML.Remove Elements    ${xml_content}    .//managedObject/p[@name="cellBarred"]
    L_XML.Save XML    ${xml_content}    ${Test Results Dir}/NetActLogs/${target_plan_name}.csv
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${target_plan_name}.csv    plan_name=${target_plan_name}

Step ${index}: Prepare Delta Plan For Delete And Modify Optional Params Has Default Value
    Log To Console    Step ${index}: Prepare Delta Plan For Delete And Modify Optional Params Has Default Value
    ${timestamp}    Generate Formatted Timestamp
    Set Test Variable    ${target_plan_name}    CB013031_019_delta_plan_with_param_change_${timestamp}
    ${plan}    NetAct Create Plan    ${target_plan_name}    CB013031_019_delta_plan
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1"]
    NetAct Create Managed Object    plan=${plan}   meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1   operation=update    fallbackOnFailedOnlineUpgrade=2
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${MO_items['class']}    meta_version=${MO_items['version']}
    ...    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1   operation=update    advanceTimeForRURestore=${EMPTY}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${target_plan_name}.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}   plan_name=${target_plan_name}    operation_type=plan

Modify Param Value From Admin
    [Arguments]    ${scf_dn}    ${param}    ${expect_value}
    [Documentation]    Helper keyword used for set parameter value to expect_value from admin.
    ${origin_value}    Run Keyword And Ignore Error    Get Parameter Value From WebEM    ${scf_dn}    ${param}
    Return From Keyword If    "${origin_value}"=="${expect_value}"    ${origin_value}
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${scf_dn}   parameter=${param}    value=${expect_value}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Check SBTS SMOD RMOD Cells Alarms
	Check WebEM After Modify Parameters    ${scf_dn}    ${param}=${expect_value}
    [Return]    ${origin_value}

Step ${index}: Provision the plan
    Log To Console    Step ${index}: Provision the plan
    NetAct Provision Plan    plan_name=${target_plan_name}    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ...    backup_plan_name=${target_plan_name}_backup    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    2m    10s    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword If    "${index}"=="${3}"    Check NRCELL be added

Step ${index}: Check Auto-Config Parameters After MO Creation
    Log To Console    Step ${index}: Check Auto-Config Parameters After MO Creation
    ${param_dic}    Create Dictionary    a2ThresholdhoSsbRsrpSA=60    a2HysteresishoSsbRsrpSA=0.0    a2TimeToTriggerhoSsbRsrpSA=ms480
    ${param_list}    Create List     ${param_dic}
    ${parameter}    Create Dictionary     a1MeashoEnabled=rsrp    a1MeashoEnabledSA=rsrp   actPdschAllocAroundSsb=true
    ...    adaptiveSrBlockingMinimization=20    upperMcsPowerBackoff=18    cellBarred=notBarred    a2MeashoSsbRsrpSA=${param_list}
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${selected_nrcell_DN}    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actSimplChConfMAA=false    actAsiDistMimoNr=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${lcelnr_dn}    ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    actPucchBeamConstraintFR2=false
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/${nrcellgp_dn}    ui_values=true    &{parameter}

Step ${index}: Check Auto-Config Parameters After MO Modification
    Log To Console    Step ${index}: Check Auto-Config Parameters After MO Modification
    ${parameter}    Create Dictionary    fallbackOnFailedOnlineUpgrade=WhenNoCellsActive
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1   ui_values=true    &{parameter}
    ${parameter}    Create Dictionary    advanceTimeForRURestore=10
    NetAct Check Actual Configuration Parameters    dist_name=PLMN-PLMN/MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-1   ui_values=true    &{parameter}

Check NRCELL be deleted
    Log To Console    Check NRCELL be deleted
    ${after_deleted_nrcells}    coam.Get Ids For All    NRCEL
    Set Test Variable    ${after_deleted_nrcells}
    ${after_deleted_nrcells_count}    Evaluate    len(${after_deleted_nrcells})
    Should Be Equal As Integers    ${NRBTS_RT_cell_num_initial}    ${after_deleted_nrcells_count+1}

Check NRCELL be added
    Log To Console    Check NRCELL be added
    ${after_added_nrcells}    coam.Get Ids For All    NRCEL
    ${after_added_nrcells_count}    Evaluate    len(${after_added_nrcells})
    Should Be Equal As Integers    ${NRBTS_RT_cell_num_initial}    ${after_added_nrcells_count}

Particular Teardown
    Modify Param Value From Admin   MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1    actCondAutoConfValCalc    false
    ${final_nrcells}    coam.Get Ids For All    NRCEL
    ${final_nrcells_count}    Evaluate    len(${final_nrcells})
    Run Keyword If    ${NRBTS_RT_cell_num_initial}!=${0} and ${NRBTS_RT_cell_num_initial}!=${final_nrcells_count}
    ...    Run Keywords    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}_backup
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${target_plan_name}
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Particular Teardown
