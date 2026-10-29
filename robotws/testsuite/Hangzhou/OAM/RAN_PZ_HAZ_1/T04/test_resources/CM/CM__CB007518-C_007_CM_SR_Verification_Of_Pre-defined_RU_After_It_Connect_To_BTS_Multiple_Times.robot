*** Settings ***
Documentation       Test case for NFTA
...                 Author: Wu Amy
...                 Contact: amy.wu@nokia-sbell.com

Resource     ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{PREDEFINED_RADIOS}    EA204457590    EA204457636
${RECOVERY_FLAG}    ${True}

*** Keywords ***
CM__CB007518-C_007_CM_SR_Verification_Of_Pre-defined_RU_After_It_Connect_To_BTS_Multiple_Times
    [Documentation]    Test case for SyVe_CB007518-A_001_CM_SR_Online configuring pre-defined RU and then connect to
    ...   BTS with automatic installation
    # S1: A predefined RMOD with prodCodePlanned configured, connect a different prodCodePlanned RMOD, then change prodCodePlanned as matched value.
    Step 1: Precondition Perform Parameter Change
    Step 2: Connect prodCodePlanned Mismatch Predefined RMOD
    Step 3: Perform RMOD Parameter prodCodePlanned Change To Correct
    # S3: Connect one predefined RU, prodCodePlanned is matched, while serialNumberPlanned id different
    Step 4: Perform Parameter Change For MNL.autoInstallOfPredefinedRu To False
    Step 5: Connect serialNumberPlanned Mismatch Predefined RMOD
    Step 6: Perform RMOD Parameter serialNumberPlanned Change To Correct

Step ${index}: Precondition Perform Parameter Change
    Log To Console    \nStep ${index}: Precondition Perform Parameter Change
    Set Test Variable    ${rmod_product_code}    ${PREDEFINED_RMODS[0]}
    Set Test Variable    ${rmod_sn}    ${PREDEFINED_RMODS[1]}
    ${parameters}    coam.get_parameters    ${RMOD_CELL_CONFIG["${rmod_product_code}"]["internal"]}
    Set Test Variable    ${product_code}    ${parameters["productCode"]}
    Set Test Variable    ${error_product_code}    1${product_code}
    ${parameters}    coam.get_parameters    ${RMOD_CELL_CONFIG["${rmod_sn}"]["internal"]}
    Set Test Variable    ${serial_number}    ${parameters["serialNumber"]}
    Set Test Variable    ${error_serial_number}    1${serial_number}
    ${distname}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    ${parameters}    coam.get_parameter_by_distname    ${distname}
    ${autoInstallOfPredefinedRu}    Convert To String    ${parameters[0]['parameters']['autoInstallOfPredefinedRu']}
    IF    "${autoInstallOfPredefinedRu}" == "False"
        coam.perform_parameter_recommissioning    ${dist_name}   autoInstallOfPredefinedRu    update    true
        ${parameters}    coam.get_parameter_by_distname    ${distname}
        ${autoInstallOfPredefinedRu}    Convert To String    ${parameters[0]['parameters']['autoInstallOfPredefinedRu']}
    END
    Should Be True    "${autoInstallOfPredefinedRu}" == "True"
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        ${port_status_needs_change}    Power Off Predefined Radio    ${ru_sn}
        Run Keyword If    ${port_status_needs_change}    Log To Console  \nPower off predefined radio ${ru_sn} PDU port
        ...    ELSE    Log To Console    \nPredefined radio ${ru_sn} PDU port is already off
        sleep    10 sec
        Perform RMOD Parameter Change    ${ru_sn}    predefined    true
    END
    Perform RMOD Parameter Change    ${rmod_product_code}    prodCodePlanned    ${error_product_code}
    Perform RMOD Parameter Change    ${rmod_sn}    serialNumberPlanned    ${error_serial_number}
    Wait Until Keyword Succeeds    5 min    10 sec    Verify All RMODs And Cells Status
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Wait Until Keyword Succeeds    2 min    10 sec    Get and Check Alarms SyVe    source=Bts
    ...    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Provision Delta Plan SyVe With Delete RMODs And Associated Cells And autoInstallOfPredefinedRu As True
    Log To Console    \nStep ${index}: Provision Delta Plan SyVe With Delete RMODs And Associated Cells
    Set Test Variable    ${rmod_product_code}    ${PREDEFINED_RMODS[0]}
    Set Test Variable    ${rmod_sn}    ${PREDEFINED_RMODS[1]}
    ${parameters}    coam.get_parameters    ${RMOD_CELL_CONFIG["${rmod_product_code}"]["internal"]}
    Set Test Variable    ${product_code}    ${parameters["productCode"]}
    Set Test Variable    ${error_product_code}    1${product_code}
    ${parameters}    coam.get_parameters    ${RMOD_CELL_CONFIG["${rmod_sn}"]["internal"]}
    Set Test Variable    ${serial_number}    ${parameters["serialNumber"]}
    Set Test Variable    ${error_serial_number}    1${serial_number}
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    ${mnl_parameters}    coam.get_parameter_by_distname    ${dist_name}
    IF    "${mnl_parameters[0]['parameters']['autoInstallOfPredefinedRu']}" == "False"
        coam.perform_parameter_recommissioning    ${dist_name}   autoInstallOfPredefinedRu    update    true
        ${mnl_parameters}    coam.get_parameter_by_distname    ${dist_name}
    END
    Should Be True    "${mnl_parameters[0]['parameters']['autoInstallOfPredefinedRu']}" == "True"
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

Step ${index}: Provision Delta Plan With Add RMODs With Predefine True And Relative Cells And Check Status
    Log To Console  \nStep ${index}: Provision Delta Plan SyVe With Add RMODs with RMOD.predefined as true And Relative Cells
    ${plan_backup}    netact.Get Plan Configuration    ${name}_backup
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        Provision Delta Plan To Modify Rmod.Predefined    ${ru_sn}    ${plan_backup}
    END
    Provision Delta Plan To Modify prodCodePlanned To Error    ${rmod_product_code}    ${plan_backup}
    Provision Delta Plan To Modify serialNumberPlanned To Error    ${rmod_sn}    ${plan_backup}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}_backup.csv    dist_names=${MRBTS_DN}
    ...    plan_name=${name}_backup    operation_type=plan
    NetAct Provision Plan    plan_name=${name}_backup    dist_names=${MRBTS_DN}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    5 min    10 sec    Verify All RMODs And Cells Status
    Log To Console    \nSleep 20 min then check fault
    Sleep    20 min
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Connect prodCodePlanned Mismatch Predefined RMOD
    Log To Console    \nStep ${index}: Connect prodCodePlanned Mismatch Predefined RMOD
    Power On Predefined Radio    ${rmod_product_code}
    coam.assert_alarm_active    parameters=faultId=4282    timeout=60
    Wait Until Keyword Succeeds    1 min    10 sec    Verify Specific Objects Status
    ...    ${RMOD_CELL_CONFIG['${rmod_product_code}']['internal']}
    ...    operationalState=disabled    availabilityStatus=failed
    Verify Cells Status    ${RMOD_CELL_CONFIG['${rmod_product_code}']['cells']}    operationalState=disabled

Step ${index}: Perform RMOD Parameter prodCodePlanned Change To Correct
    Log To Console    \nStep ${index}: Perform RMOD Parameter prodCodePlanned Change To Correct
    Perform RMOD Parameter Change    ${rmod_product_code}    prodCodePlanned    ${product_code}
    coam.assert alarm inactive    parameters=faultId=4282    timeout=120
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Specific Objects Status
    ...    ${RMOD_CELL_CONFIG['${rmod_product_code}']['internal']}
    ...    operationalState=enabled
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Cells Status
    ...    ${RMOD_CELL_CONFIG['${rmod_product_code}']['cells']}    operationalState=enabled
    Wait Until Keyword Succeeds    5 min    10 sec    Check RMOD.Predefined Value    ${rmod_product_code}    false

Step ${index}: Connect serialNumberPlanned Mismatch Predefined RMOD
    Log To Console    \nStep ${index}: Connect serialNumberPlanned Mismatch Predefined RMOD
    Power On Predefined Radio    ${rmod_sn}
    coam.assert_alarm_active    parameters=faultId=4282    timeout=60
    Wait Until Keyword Succeeds    1 min    10 sec    Verify Specific Objects Status
    ...    ${RMOD_CELL_CONFIG['${rmod_sn}']['internal']}
    ...    operationalState=disabled    availabilityStatus=failed
    Verify Cells Status    ${RMOD_CELL_CONFIG['${rmod_sn}']['cells']}    operationalState=disabled

Step ${index}: Perform RMOD Parameter serialNumberPlanned Change To Correct
    Log To Console    \nStep ${index}: Perform RMOD Parameter serialNumberPlanned Change To Correct
    Perform RMOD Parameter Change    ${rmod_sn}    serialNumberPlanned    ${serial_number}
    coam.assert alarm inactive    parameters=faultId=4282    timeout=120
    Perform RMOD Parameter Change    ${rmod_sn}    predefined    false
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Specific Objects Status
    ...    ${RMOD_CELL_CONFIG['${rmod_sn}']['internal']}
    ...    operationalState=enabled
    Wait Until Keyword Succeeds    5 min    10 sec    Verify Cells Status
    ...    ${RMOD_CELL_CONFIG['${rmod_sn}']['cells']}    operationalState=enabled
    Wait Until Keyword Succeeds    5 min    10 sec    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Perform Parameter Change For MNL.autoInstallOfPredefinedRu To ${value}
    Log To Console    \nStep ${index}: Perform Parameter Change For MNL.autoInstallOfPredefinedRu To ${value}
    ${value}    Convert To Lower Case    ${value}
    ${dist_name}    Set Variable    MRBTS-${mrbts_id}/MNL-1
    coam.perform_parameter_recommissioning    ${dist_name}   autoInstallOfPredefinedRu    update    ${value}

Step ${index}: Check RMODs Cells And Alarms Status
    Log To Console    \nStep ${index}: Check rmods cells and alarms status
    Wait Until Keyword Succeeds    5 min    10 sec    Verify All RMODs And Cells Status
    Append To List    ${IGNORED_ALARMS}    {'alarmId': 7115, 'faultId': 2002}
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Verify Rmod.Predefined False
    Log To Console    \nStep ${index}: Verify Rmod.Predefined False
    Check Rmod.Predefined Value    ${RU_Selection}

Provision Delta Plan To Modify Rmod.Predefined
    [Arguments]    ${ru_sn}    ${plan}
    ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
    ${rmod_mo_items}    L_XML.Get Element Attributes    ${BTS_scf_initial}
    ...    .//managedObject[@distName="${rmod_configuration}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${rmod_mo_items['class']}
    ...    meta_version=${rmod_mo_items['version']}    mo_id=PLMN-PLMN/${rmod_configuration}   predefined=true

Provision Delta Plan To Modify prodCodePlanned To Error
    [Arguments]    ${ru_sn}    ${plan}
    ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
    ${rmod_mo_items}    L_XML.Get Element Attributes    ${BTS_scf_initial}
    ...    .//managedObject[@distName="${rmod_configuration}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${rmod_mo_items['class']}
    ...    meta_version=${rmod_mo_items['version']}    mo_id=PLMN-PLMN/${rmod_configuration}
    ...   prodCodePlanned=${error_product_code}

Provision Delta Plan To Modify serialNumberPlanned To Error
    [Arguments]    ${ru_sn}    ${plan}
    ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['configuration']}
    ${rmod_mo_items}    L_XML.Get Element Attributes    ${BTS_scf_initial}
    ...    .//managedObject[@distName="${rmod_configuration}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${rmod_mo_items['class']}
    ...    meta_version=${rmod_mo_items['version']}    mo_id=PLMN-PLMN/${rmod_configuration}
    ...   serialNumberPlanned=${error_serial_number}

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

Perform RMOD Parameter Change
    [Arguments]    ${ru_sn}    ${parameter}    ${value}
    coam.perform_parameter_recommissioning    ${RMOD_CELL_CONFIG["${ru_sn}"]["configuration"]}   ${parameter}
    ...    update    ${value}

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
    [Arguments]    ${predefined_rmods}=${PREDEFINED_RMODS}
    Log To Console    \nVerify All RMODs And Cells Status, predefined rmods is ${predefined_rmods}
    ${rus_sn}    Get Dictionary Keys    ${RMOD_CELL_CONFIG}
    FOR    ${ru_sn}    IN    @{rus_sn}
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
    Common Test Setup SBTS
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
    Common Test Teardown SBTS




