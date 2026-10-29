*** Settings ***
Documentation       Test case for SyVe_CB007518-A_004_CM_SR_BTS_Startup_With_Pre-defined_RU_And_Then_Connect_To_BTS_With_Manual_Installation
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com

Resource     ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{PREDEFINED_RADIOS}      EA204457590    EA204457636
${RECOVERY_FLAG}    ${True}

*** Keywords ***
SRAN_SyVe_CB007518-A_004_CM_SR_BTS_Startup_With_Pre-defined_RU_And_Then_Connect_To_BTS_With_Manual_Installation
    [Documentation]    Test case for SyVe_CB007518-A_001_CM_SR_Online configuring pre-defined RU and then connect to
    ...   BTS with automatic installation
    Step 1: Precondition: Provision Delta Plan SyVe With Delete RMODs And Associated Cells And autoInstallOfPredefinedRu As False
    Step 2: Provision Delta Plan With Add RMODs With Predefine True And Relative Cells With Parameter Reset Site
    Step 3: Wait For WebEM Display For RMODs
    Step 4: Connect First Predefined RMOD
    Step 5: Check Other RMODs And Relative Cells Status
    Step 6: Connect Second Predefined RMOD
    Step 7: Perform Parameter Change For RMOD.predefined To False
    Step 8: Perform Parameter Change For MNL.autoInstallOfPredefinedRu To True
    Step 9: Check All RMODs Cells And Alarms Status

Step ${index}: Provision Delta Plan SyVe With Delete RMODs And Associated Cells And autoInstallOfPredefinedRu As ${value}
    Log To Console    \nStep ${index}: Provision Delta Plan SyVe With Delete RMODs And Associated Cells
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    ${mnl_parameters}    coam.get_parameter_by_distname    ${dist_name}
    ${value_lower}    Convert To Lower Case    ${value}
    ${need_modify}    Set Variable If    "${value_lower}" == "true"    False    True
    IF    "${mnl_parameters[0]['parameters']['autoInstallOfPredefinedRu']}" == "${need_modify}"
        coam.perform_parameter_recommissioning    ${dist_name}   autoInstallOfPredefinedRu    update    ${value_lower}
        ${mnl_parameters}    coam.get_parameter_by_distname    ${dist_name}
    END
    Should Be True    "${mnl_parameters[0]['parameters']['autoInstallOfPredefinedRu']}" == "${value}"
    NetAct CM Upload    dist_names=${MRBTS_DN}
    Set Test Variable    ${name}    CB007518_001-Delete_MOC
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${status}    ${plan_backup}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}_backup
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}_backup    ${plan_backup}
    ${plan}    NetAct Create Plan    ${name}    Automation for ${TEST_NAME}
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        ${port_status_needs_change}    Power Off Predefined Radio    ${ru_sn}
        Run Keyword If    ${port_status_needs_change}    Log To Console  \nPower off predefined radio ${ru_sn} PDU port
        ...    ELSE    Log To Console    \nPredefined radio ${ru_sn} PDU port is already off
    END
    Delete RMODs And Relative Cells    ${PREDEFINED_RMODS}    ${plan}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=plan
    NetAct Provision Plan    plan_name=${name}    dist_names=${MRBTS_DN}    backup_plan_name=${name}_backup
    ...    create_backup_plan=True    provisioning_operation=activate
    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Provision Delta Plan With Add RMODs With Predefine True And Relative Cells With Parameter Reset Site
    Log To Console  \nStep ${index}: Provision Delta Plan SyVe With Add RMODs with RMOD.predefined as true And Relative Cells
    ${plan_backup}    netact.Get Plan Configuration    ${name}_backup
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        Provision Delta Plan To Modify RMOD.Predefined Value    ${ru_sn}    ${plan_backup}    true
    END
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${featcadm_parameters}    coam.get_parameter_by_distname    ${dist_name}
    ${value}    Set Variable IF    "${featcadm_parameters[0]['parameters']['actMplaneFronthaulFirewall']}" == "True"
    ...    false    true
    ${featcadm_mo_items}    L_XML.Get Element Attributes    ${BTS_scf_initial}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1"]
    NetAct Create Managed Object    plan=${plan_backup}    meta_class=${featcadm_mo_items['class']}
    ...    meta_version=${featcadm_mo_items['version']}    mo_id=PLMN-PLMN/MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...   actMplaneFronthaulFirewall=${value}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Wait For WebEM Display For RMODs
    Log To Console    \nStep ${index}: Wait For WebEM Display For RMODs
    ${values}    Get Dictionary Values    ${RMOD_CELL_CONFIG}
    ${rmod_internal_ids}    Create List
    FOR    ${value}    IN    @{values}
        Append To List    ${rmod_internal_ids}    ${value['internal']}
    END
    Wait Until Keyword Succeeds    10 min    10 sec    Verify Specific Objects Status    ${rmod_internal_ids}
    ...    operationalState=disabled

Step ${index}: Connect First Predefined RMOD
    Log To Console    \nStep ${index}: Connect First Predefined RMOD
    ${first_rmod}    Remove From List    ${PREDEFINED_RMODS}    0
    Power On Predefined Radio    ${first_rmod}
    Set Test Variable    ${first_rmod}
    ${rmod_internal_id}     Set Variable    ${RMOD_CELL_CONFIG['${first_rmod}']['internal']}
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Specific Objects Status    ${rmod_internal_id}
    ...    operationalState=enabled
    Verify Cells Status    ${RMOD_CELL_CONFIG['${first_rmod}']['cells']}    operationalState=disabled
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 4589}
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check Other RMODs And Relative Cells Status
    Log To Console    \nStep ${index}: Check Other RMODs And Relative Cells Status
    ${exclude_rmods}    Create List    ${first_rmod}
    Wait Until Keyword Succeeds    10 min    10 sec    Verify All RMODs And Cells Status    exclude_rmods=${exclude_rmods}
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Connect Second Predefined RMOD
    Log To Console    \nStep ${index}: Connect Second Predefined RMOD
    ${second_rmod}    Remove From List    ${PREDEFINED_RMODS}    0
    Power On Predefined Radio    ${second_rmod}
    Set Test Variable    ${second_rmod}
    ${rmod_internal_id}     Set Variable    ${RMOD_CELL_CONFIG['${second_rmod}']['internal']}
    Wait Until Keyword Succeeds    2 min    10 sec    Verify Specific Objects Status    ${rmod_internal_id}
    ...    operationalState=enabled
    Verify Cells Status    ${RMOD_CELL_CONFIG['${first_rmod}']['cells']}    operationalState=disabled
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 4589}
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Perform Parameter Change For RMOD.predefined To ${value}
    Log To Console    \nStep ${index}: Perform Parameter Change For Predefined RMOD To ${value}
    ${value}    Convert To Lower Case    ${value}
    Perform Parameter Change For RMOD.predefined    ${first_rmod}    ${value}
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Cells Status
    ...    ${RMOD_CELL_CONFIG['${first_rmod}']['cells']}    operationalState=enabled

Step ${index}: Perform Parameter Change For MNL.autoInstallOfPredefinedRu To ${value}
    Log To Console    \nStep ${index}: Perform Parameter Change For MNL.autoInstallOfPredefinedRu To ${value}
    ${value}    Convert To Lower Case    ${value}
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    coam.perform_parameter_recommissioning    ${dist_name}   autoInstallOfPredefinedRu    update    ${value}
    ${start_time_str}    Get Time
    ${start_time}    Get Time    epoch
    ${length}    Get Length    ${PREDEFINED_RMODS}
    IF    ${length} > 0
        Log To Console    \n1 min timer start at ${start_time_str}
        Wait Until Keyword Succeeds    70 sec    10 sec    Check RMOD.Predefined Value    ${second_rmod}    false
        ${current_time}    Get Time    epoch
        ${elapsed}=    Evaluate    ${current_time} - ${start_time}
        Log To Console    RMOD.predefined has changed from true to false, it takes ${elapsed}sec.
        Should Be True    50 < ${elapsed} < 70
    ELSE
        Wait Until Keyword Succeeds    10 sec    1 sec    Check RMOD.Predefined Value    ${second_rmod}    false
    END
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Cells Status
    ...    ${RMOD_CELL_CONFIG['${second_rmod}']['cells']}    operationalState=enabled

Step ${index}: Check All RMODs Cells And Alarms Status
    Log To Console    \nStep ${index}: Check rmods cells and alarms status
    Verify All RMODs And Cells Status
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Check RMOD.Predefined Value
    [Arguments]    ${rus_sn}    ${expected_value}=false
    ${type}    Evaluate    type($rus_sn).__name__
    ${rus_sn}    Run keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${scf_path}    Admin Collect scf.xml with timestamp TAF
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_path}
    FOR    ${ru_sn}    IN    @{rus_sn}
        ${rmod_distname}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
        ${actual_value}   L_XML.Get Element Text    ${scf_xml}
        ...    .//managedObject[@distName="${rmod_distname}"]/p[@name="predefined"]
        Should Be Equal As Strings    ${actual_value}    ${expected_value}
    END

Perform Parameter Change For RMOD.predefined
    [Arguments]    ${ru_sn}    ${value}
    ${value}    Convert To Lower Case    ${value}
    ${dist_name}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
    coam.perform_parameter_recommissioning    ${dist_name}   predefined    update    ${value}

Verify Specific Objects Status
    [Arguments]    ${internal_ids}    &{kwargs}
    ${type}    Evaluate    type($internal_ids).__name__
    ${internal_ids}    Run keyword If   "${type}" == "list"    Set Variable    ${internal_ids}
    ...    ELSE    Create List    ${internal_ids}
    FOR    ${internal_id}    IN    @{internal_ids}
        ${info}    coam.get_parameters    ${internal_id}
        ${keys}    Get Dictionary Keys    ${kwargs}
        FOR    ${key}    IN    @{keys}
            Should Be Equal    ${info['${key}']}    ${kwargs['${key}']}
        END
    END

Verify Cells Status
    [Arguments]    ${cells}    &{kwargs}
    FOR    ${cell}    IN    @{cells}
        Verify Specific Objects Status      ${cell['internal']}    &{kwargs}
    END

Power Off Predefined Radio
    [Arguments]    ${ru_sn}
    ${pdu_ip}    Set Variable    ${INTERFACES['RMOD_${ru_sn}']['IP']}
    ${pdu_type}    Set Variable    ${INTERFACES['RMOD_${ru_sn}']['TYPE']}
    ${pdu_port}    Set Variable    ${INTERFACES['RMOD_${ru_sn}']['OUTLET']}
    pdu.Setup Pdu         host=${pdu_ip}    model=${pdu_type}
    ${port_status}=                pdu.Get Port Status    port=${pdu_port}
    ${port_status_needs_change}=   Evaluate   "${port_status}"=="on"
    Return From Keyword If   not ${port_status_needs_change}  ${port_status_needs_change}
    ${out_action_status}=    Run Keyword And Return Status    pdu.Power Off   port=${pdu_port}
    Sleep  2 seconds
    ${out_port_status}=    pdu.Get Port Status    port=${pdu_port}
    Run Keyword If    not ${out_action_status}
    ...    Should Be Equal    ${out_port_status}    off
    [Return]      ${port_status_needs_change}

Power On Predefined Radio
    [Arguments]    ${ru_sn}
    ${pdu_ip}    Set Variable    ${INTERFACES['RMOD_${ru_sn}']['IP']}
    ${pdu_type}    Set Variable    ${INTERFACES['RMOD_${ru_sn}']['TYPE']}
    ${pdu_port}    Set Variable    ${INTERFACES['RMOD_${ru_sn}']['OUTLET']}
    pdu.Setup Pdu        host=${pdu_ip}    model=${pdu_type}
    ${port_status}=                pdu.Get Port Status    port=${pdu_port}
    ${port_status_needs_change}=   Evaluate   "${port_status}"=="off"
    Return From Keyword If   not ${port_status_needs_change}  ${port_status_needs_change}
    ${out_action_status}=    Run Keyword And Return Status    pdu.Power On    port=${pdu_port}
    Sleep  2 seconds
    ${out_port_status}=    pdu.Get Port Status    port=${pdu_port}
    Run Keyword If    not ${out_action_status}
    ...     Should Be Equal    ${out_port_status}    on
    [Return]      ${port_status_needs_change}

Verify All RMODs And Cells Status
    [Arguments]    ${predefined_rmods}=${PREDEFINED_RMODS}    ${exclude_rmods}=${EMPTY}
    ${rus_sn}    Get Dictionary Keys    ${RMOD_CELL_CONFIG}
    FOR    ${ru_sn}    IN    @{rus_sn}
        IF    "${ru_sn}" in "${exclude_rmods}"
            Log    rmod ${ru_sn} and relative cells not check!
            Continue For Loop
        END
        ${rmod_internal_id}     Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['internal']}
        ${cells}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['cells']}
        IF    "${ru_sn}" in "${predefined_rmods}"
            Verify Specific Objects Status    ${rmod_internal_id}    operationalState=disabled
            Verify Cells Status    ${cells}    operationalState=disabled
        ELSE
            Verify Specific Objects Status    ${rmod_internal_id}    operationalState=enabled
            Verify Cells Status    ${cells}    operationalState=enabled
        END
    END

Provision Delta Plan To Modify RMOD.Predefined Value
    [Arguments]    ${ru_sn}    ${plan}    ${value}
    ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
    ${rmod_mo_items}    L_XML.Get Element Attributes    ${BTS_scf_initial}
    ...    .//managedObject[@distName="${rmod_configuration}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${rmod_mo_items['class']}
    ...    meta_version=${rmod_mo_items['version']}    mo_id=PLMN-PLMN/${rmod_configuration}   predefined=${value}

Delete RMODs And Relative Cells
    [Arguments]    ${rus_sn}    ${plan}    ${bts_scf}=${BTS_scf_initial}
    ${all_delete_cells}    Delete RMODs    ${rus_sn}    ${plan}    bts_scf=${bts_scf}
    Delete Cells    ${all_delete_cells}    ${plan}    bts_scf=${bts_scf}

Delete RMODs
    [Arguments]    ${rus_sn}    ${plan}    ${bts_scf}=${BTS_scf_initial}
    ${type}    Evaluate    type($rus_sn).__name__
    ${rus_sn}    Run keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${rmods_config}    Create List
    ${all_delete_cells}    Create List
    FOR    ${ru_sn}    IN    @{rus_sn}
        ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
        ${rmod_cablinks}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['cablinks']}
        ${rmod_related_distnames}    L_XML.Evaluate Xpath    ${bts_scf}
        ...    .//managedObject[@distName[contains(., '${rmod_configuration}/')]]/@distName
        Append To List    ${rmod_related_distnames}    ${rmod_configuration}
        Append To List    ${rmods_config}    ${rmod_configuration}
        ${distnames}    Combine Lists    ${rmod_related_distnames}    ${rmod_cablinks}
        FOR    ${distname}    IN    @{distnames}
            ${mo_items}    L_XML.Get Element Attributes    ${bts_scf}
            ...    .//managedObject[@distName="${distname}"]
            NetAct Create Managed Object    plan=${plan}    meta_class=${mo_items['class']}
            ...  meta_version=${mo_items['version']}  mo_id=PLMN-PLMN/${distname}  operation=DELETE  &{EMPTY}
        END
        ${all_delete_cells}    Combine Lists    ${all_delete_cells}    ${RMOD_CELL_CONFIG['${ru_sn}']['cells']}
    END
    ${sync_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2"]
    ${targetDNList}    L_XML.get_elements_texts    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SYNC-2"]/list[@name="targetDNList"]/p
    Remove Values From List    ${targetDNList}    @{rmods_config}
    NetAct Create Managed Object    plan=${plan}    meta_class=${sync_mo_items['class']}
    ...    meta_version=${sync_mo_items['version']}    mo_id=PLMN-PLMN/${sync_mo_items["distName"]}   targetDNList=${targetDNList}
    [Return]    ${all_delete_cells}


Delete Cells
    [Arguments]    ${cells}    ${plan}    ${bts_scf}=${BTS_scf_initial}
    ${type}    Evaluate    type($cells).__name__
    ${cells}    Run Keyword If    "${type}" == "list"    Set Variable    ${cells}
    ...    ELSE    Create List    ${cells}
    ${cellgrp_ids}    Create List
    FOR    ${cell}    IN    @{cells}
        ${nrCellGrp_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
        ...    .//managedObject[@distName="${cell['nrCellGrp']}"]
        ${grp_id}    Fetch From Right    ${cell['nrCellGrp']}    -
        Append To List    ${cellgrp_ids}    ${grp_id}
        NetAct Create Managed Object    plan=${plan}    meta_class=${nrCellGrp_mo_items['class']}
        ...  meta_version=${nrCellGrp_mo_items['version']}  mo_id=PLMN-PLMN/${cell['nrCellGrp']}  operation=DELETE  &{EMPTY}

        ${lcelnr_related_distnames}    L_XML.Evaluate Xpath    ${bts_scf}
        ...    .//managedObject[@distName[contains(., 'LCELNR-${cell['lcrId']}/')]]/@distName
        Append To List    ${lcelnr_related_distnames}    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell['lcrId']}
        ${nrcell_related_distnames}    L_XML.Evaluate Xpath    ${bts_scf}
        ...    .//managedObject[@distName[contains(., '${cell['configuration']}/')]]/@distName
        Append To List    ${nrcell_related_distnames}    ${cell['configuration']}
        ${distnames}    Combine Lists    ${lcelnr_related_distnames}    ${nrcell_related_distnames}
        FOR    ${distname}    IN    @{distnames}
            ${mo_items}    L_XML.Get Element Attributes    ${bts_scf}
            ...    .//managedObject[@distName="${distname}"]
            NetAct Create Managed Object    plan=${plan}    meta_class=${mo_items['class']}
            ...  meta_version=${mo_items['version']}  mo_id=PLMN-PLMN/${distname}  operation=DELETE  &{EMPTY}
        END

        ${status}    ${nrpgrp_distname}    Run keyword And Ignore Error    L_XML.Get Element   ${bts_scf}
        ...   .//managedObject[list/item/p[@name="nrCellId"]="${cell['physCellId']}"]/@distName
        Continue For Loop If    "${status}" == "FAIL"
        ${nrpgrp_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
        ...    .//managedObject[@distName="${nrpgrp_distname}"]
        NetAct Create Managed Object    plan=${plan}    meta_class=${nrpgrp_mo_items['class']}
        ...  meta_version=${nrpgrp_mo_items['version']}  mo_id=PLMN-PLMN/${nrpgrp_distname}
        ...  operation=DELETE  &{EMPTY}
    END
    ${nrdu_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1"]
    ${refNrCellGroup}    L_XML.get_elements_texts    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1"]/list[@name="refNrCellGroup"]/p
    Remove Values From List    ${refNrCellGroup}    @{cellgrp_ids}
    NetAct Create Managed Object    plan=${plan}    meta_class=${nrdu_mo_items['class']}    meta_version=${nrdu_mo_items['version']}
    ...    mo_id=PLMN-PLMN/${nrdu_mo_items["distName"]}   refNrCellGroup=${refNrCellGroup}

Get RMOD CELL Mapping Info
    ${bts_info}    coam.get_bts_info
    ${rmods}    Set Variable    ${bts_info['radioModules']['rmod']}
    ${rmod_cell_mapping}    Create Dictionary
    FOR    ${rmod_info}    IN    @{rmods}
        ${rmod_serial_number}    Set Variable    ${rmod_info['serialNumber']}
        ${rmod_config_id}    Set Variable    ${rmod_info['id']['configuration']}
        ${rmod_internal_id}    Set Variable    ${rmod_info['id']['internal']}
        ${cablinks}    Get RMOD Cablink    ${rmod_config_id}    ${bts_info}
        ${cell_infos}    Get Cell Info Dictionary    ${rmod_internal_id}    ${bts_info}
        ${rmod_infos}    Create Dictionary    internal=${rmod_internal_id}    configuration=${rmod_config_id}
        ...    cablinks=${cablinks}    cells=${cell_infos}
        Set To Dictionary    ${rmod_cell_mapping}    ${rmod_serial_number}=${rmod_infos}
    END
    [Return]    ${rmod_cell_mapping}

Get RMOD Cablink
    [Arguments]    ${rmod_config_id}    ${bts_info}
    ${cables}    Set Variable    ${bts_info['cables']}
    ${cablinks}    Create List
    FOR    ${cable}    IN    @{cables}
        Run Keyword If    "${rmod_config_id}" in "${cable['secondEndPointId']['configuration']}"
        ...    Append To List    ${cablinks}    ${cable['id']['configuration']}
    END
    [Return]    ${cablinks}

Get Cell Info Dictionary
    [Arguments]    ${rmod_internal_id}    ${bts_info}
    ${cells_group}    Set Variable    ${bts_info['cellsGroup']}
    ${cell_mapping_internal_ids}    coam.get_cell_mapping_by_module_id    ${rmod_internal_id}
    ${cells}    Combine Lists    ${bts_info["cells"]["lte"]}    ${bts_info["cells"]["wcdma"]}
    ...    ${bts_info["cells"]["gsm"]}    ${bts_info["cells"]["nr"]}
    ${cell_infos}    Create List
    FOR    ${internal_id}    IN    @{cell_mapping_internal_ids}
        FOR    ${cell}    IN    @{cells}
            ${cell_internal_id}    Set Variable    ${cell['id']['internal']}
            ${cell_config_id}    Set Variable    ${cell['id']['configuration']}
            Exit For Loop If    "${cell_internal_id}" == "${internal_id}"
        END
        Should Be Equal    ${internal_id}    ${cell_internal_id}
        ${cell_parameter}    coam.get_parameter_by_distname    ${cell_config_id}
        ${lcrId}    Set Variable    ${cell_parameter[0]['parameters']['lcrId']}
        ${physCellId}    Set Variable    ${cell_parameter[0]['parameters']['physCellId']}
        ${parent_config_id}    ${cell_config_name}    Split String From Right    ${cell_config_id}    /    1
        FOR    ${cell_group}    IN    @{cells_group}
            ${cell_group_name}    Set Variable    ${cell_group['name']}
            Exit For Loop If    "${cell_config_name}" in "${cell_group['nrCellList']}"
        END
        Should Be Equal    ${cell_config_name}    ${cell_group['nrCellList'][0]}
        ${cell_info}    Create Dictionary    internal=${cell_internal_id}    configuration=${cell_config_id}
        ...    lcrId=${lcrId}    nrCellGrp=${parent_config_id}/${cell_group_name}    physCellId=${physCellId}
        Append To List    ${cell_infos}    ${cell_info}
    END
    [Return]    ${cell_infos}

Test Setup
    Common Test Setup
    ${rmod_cell_config}    Get RMOD CELL Mapping Info
    Set Test Variable    ${RMOD_CELL_CONFIG}    ${rmod_cell_config}
    ${predefined_rmods}    Copy List    ${PREDEFINED_RADIOS}    deepcopy=True
    Set Test Variable    ${PREDEFINED_RMODS}    ${predefined_rmods}

Test Teardown
    IF    ${RECOVERY_FLAG} and "${TEST STATUS}" == "FAIL"
        FOR    ${ru_sn}    IN    @{PREDEFINED_RADIOS}
            Power On Predefined Radio    ${ru_sn}
        END
        Log   Will perform commissioning with initial scf!    level=WARN
        coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
        ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
        Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    END
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}_backup
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}_backup    ${plan}
    Common Test Teardown






