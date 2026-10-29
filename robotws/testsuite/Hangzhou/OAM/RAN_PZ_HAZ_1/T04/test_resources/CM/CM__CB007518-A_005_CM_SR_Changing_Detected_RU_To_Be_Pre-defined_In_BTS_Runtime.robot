*** Settings ***
Documentation       Test case for SyVe_CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com

Resource     ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${PREDEFINED_RADIO}    NQ232691556
${ERROR_PRODCODEPLANNED}    474699B.101
${RECOVERY_FLAG}    ${True}

*** Keywords ***
CM__CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    [Documentation]    Test case for SyVe_CB007518-A_005_CM_SR_Changing_Detected_RU_To_Be_Pre-defined_In_BTS_Runtime
    Step 1: Precondition Perform Parameter Change For MNL.autoInstallOfPredefinedRu To False
    Step 2: Perform Parameter Change For RMOD.predefined To True
    Step 3: Check RMOD Status With Reset And Cell Status Disabled
    Step 4: Perform Parameter Change For ProdCodePlanned To ${ERROR_PRODCODEPLANNED}
    Step 5: Disconnect RMOD From BTS
    Step 6: Check Other RMODs Cells Status

Step ${index}: Precondition Perform Parameter Change For MNL.autoInstallOfPredefinedRu To ${value}
    Log To Console    \nStep ${index}: Precondition Perform Parameter Change For MNL.autoInstallOfPredefinedRu To ${value}
    ${distname}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    ${parameters}    coam.get_parameter_by_distname    ${distname}
    ${value}    Convert To Lower Case    ${value}
    ${autoInstallOfPredefinedRu}    Convert To String    ${parameters[0]['parameters']['autoInstallOfPredefinedRu']}
    ${autoInstallOfPredefinedRu}    Convert To Lower Case    ${autoInstallOfPredefinedRu}
    Return From Keyword If    "${autoInstallOfPredefinedRu}" == "${value}"
    coam.perform_parameter_recommissioning    ${dist_name}   autoInstallOfPredefinedRu    update    ${value}
    ${parameters}    coam.get_parameter_by_distname    ${distname}
    ${autoInstallOfPredefinedRu}    Convert To String    ${parameters[0]['parameters']['autoInstallOfPredefinedRu']}
    ${autoInstallOfPredefinedRu}    Convert To Lower Case    ${autoInstallOfPredefinedRu}
    Should Be True    "${autoInstallOfPredefinedRu}" == "${value}"
    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Perform Parameter Change For RMOD.predefined To ${value}
    Log To Console    \nStep ${index}: Perform Parameter Change For Predefined RMOD To ${value}
    ${value}    Convert To Lower Case    ${value}
    Perform RMOD Parameter Change    ${PREDEFINED_RADIO}    predefined    ${value}

Step ${index}: Check RMOD Status With Reset And Cell Status Disabled
    Log To Console    \nStep ${index}: Check RMOD Status With Reset And Cell Status Disabled
    coam.assert any    class_name=RMOD
    ...    parameters=operationalState=regex"(?i)Disabled", serialNumber=${PREDEFINED_RADIO}    timeout=300s
    coam.assert any    class_name=RMOD
    ...    parameters=operationalState=regex"(?i)Enabled", serialNumber=${PREDEFINED_RADIO}    timeout=300s
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3 min    10 sec    Verify Cells Status
    ...    ${RMOD_CELL_CONFIG['${PREDEFINED_RADIO}']['cells']}    operationalState=enabled
    Should Not Be True    ${status}

Step ${index}: Perform Parameter Change For ProdCodePlanned To ${value}
    Log To Console    \nStep ${index}: Perform Parameter Change For ProdCodePlanned To ${value}
    Perform RMOD Parameter Change    ${PREDEFINED_RADIO}    prodCodePlanned    ${value}
    coam.assert_alarm_active    parameters=faultId=4282    timeout=60
    Wait Until Keyword Succeeds    1 min    10 sec    Verify Specific Objects Status
    ...    ${RMOD_CELL_CONFIG['${PREDEFINED_RADIO}']['internal']}
    ...    operationalState=disabled    availabilityStatus=failed

Step ${index}: Disconnect RMOD From BTS
    Log To Console    \nStep ${index}: Disconnect RMOD From BTS
    Power Off Predefined Radio    ${PREDEFINED_RADIO}
    Wait Until Keyword Succeeds    1 min    10 sec    Verify Specific Objects Status
    ...    ${RMOD_CELL_CONFIG['${PREDEFINED_RADIO}']['internal']}
    ...    operationalState=disabled    availabilityStatus=not installed
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Wait Until Keyword Succeeds    1 min    10 sec    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check Other RMODs Cells Status
    Log To Console    \nStep ${index}: Check Other RMODs Cells Status
    ${exclude_rmods}    Create List    ${PREDEFINED_RADIO}
    Verify All RMODs And Cells Status     predefined_rmods=@{EMPTY}    exclude_rmods=${exclude_rmods}


Perform RMOD Parameter Change
    [Arguments]    ${ru_sn}    ${parameter}    ${value}
    ${dist_name}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
    coam.perform_parameter_recommissioning    ${dist_name}   ${parameter}    update    ${value}

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
    Run Keyword And Ignore Error    Common Test Setup SBTS
    ${rmod_cell_config}    Get RMOD CELL Mapping Info
    Set Test Variable    ${RMOD_CELL_CONFIG}    ${rmod_cell_config}

Test Teardown
    IF    ${RECOVERY_FLAG}
        Power On Predefined Radio    ${PREDEFINED_RADIO}
        Log   Will perform commissioning with initial scf!    level=WARN
        coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
        ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
        Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    END
    Common Test Teardown SBTS
