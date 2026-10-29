*** Settings ***
Documentation
...   NFTA
...   Author: amy.wu@nokia-sbell.com
...   Description: This robot cases is for
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${SRNCLAB}      SRNCLAB2002    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
@{PREDEFINED_RADIOS}    DH231442010
${RECOVERY_FLAG}    ${False}
&{alarm1}    fault_id=4592    alarm_id=7115
@{IGNORE_ALARMS}    ${alarm1}

*** Keywords ***
VRAN_SyVe_CB007518-B_006_CM_CR_Changing RU to non-predefined when the RU is not connected in BTS runtime
    [Documentation]
    ...    Author: amy.wu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.7.2025, amy.wu@nokia-sbell.com, draft,
    ...    New case, This case checks that RU can be detected and on air in runtime after it connects to BTS
    ...    when autoInstallOfPredefinedRu as true.
#    Step 1: Precondition: Provision Delta Plan SyVe With Delete RMODs And Associated Cells And autoInstallOfPredefinedRu As False
#    Step 2: Provision Delta Plan With Add RMODs With Predefined True And Relative Cells
    Step 1: Precondition: Perform Parameters Change
    Step 2: Perform Delta Plan To Change RMOD.Predefined As False And Check Status
    Step 3: Connect This Predefined RMOD And Check Status
    Step 4: Check All RMODs And Cells And Alarm Status On vDU

Step ${index}: Precondition: Perform Parameters Change
    Log To Console    \nStep ${index}: Precondition: Perform Parameters Change
    Set Test Variable    ${rmod_product_code}    ${PREDEFINED_RMODS[0]}
    Set Test Variable    ${rmod_sn}    ${PREDEFINED_RMODS[1]}
    ${para_list}    Create List    autoInstallOfPredefinedRu
    ${mo_list}    Create List    MRBTS-${vDU_id}/MNL-1
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
    ...   para_list=${para_list}    mo_list=${mo_list}
    IF    "${out["MRBTS-${vDU_id}/MNL-1"]['autoInstallOfPredefinedRu']}" == "true"
        @{value_list}    Create List    false
        ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
        ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}
        ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
        ...   para_list=${para_list}    mo_list=${mo_list}
    END
    Should Be True    "${out["MRBTS-${vDU_id}/MNL-1"]['autoInstallOfPredefinedRu']}" == "false"
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        ${port_status_needs_change}    Power Off Predefined Radio    ${ru_sn}
        Run Keyword If    ${port_status_needs_change}    Log To Console  \nPower off predefined radio ${ru_sn} PDU port
        ...    ELSE    Log To Console    \nPredefined radio ${ru_sn} PDU port is already off
    END
    Perform Delta Plan To Change Connected RMOD.Predefined    ${PREDEFINED_RMODS}    true
    Wait Until Keyword Succeeds    2 min    10 sec    Check All RMODs And Cells Status On vDU
    Wait Until Keyword Succeeds    2 min    10 sec    Check vDU Alarms

Step ${index}: Perform Delta Plan To Change RMOD.Predefined As ${value} And Check Status
    Log To Console    \nStep ${index}: Perform Delta Plan To Change RMOD.Predefined As ${value} And Check Status
    ${value_lower}    Convert To Lower Case    ${value}
    Perform Delta Plan To Change Connected RMOD.Predefined    ${PREDEFINED_RMODS}    ${value_lower}
    ${cell_ids}    Check Specified RMODs Status On vDU    ${PREDEFINED_RMODS}    operational_state=disabled
    Check Specified Cells Status On vDU    ${cell_ids}    operational_state=disabled
    Wait Until Keyword Succeeds    20 min    10 sec    Check Expected Alarms Is Appear    expected_fault_id=10

Step ${index}: Connect ${which} Predefined RMOD And Check Status
    Log To Console    \nStep ${index}: Connect ${which} Predefined RMOD And Check Status
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        Power On Predefined Radio    ${ru_sn}
    END
    ${cell_ids}    Wait Until Keyword Succeeds    10 min    5 sec    Check Specified RMODs Status On vDU
    ...    ${PREDEFINED_RMODS}    operational_state=enabled
    Wait Until Keyword Succeeds    5 min    5 sec    Check Specified Cells Status On vDU    ${cell_ids}
    ...    operational_state=enabled
    Check Expected Alarms Is Not Appear    expected_fault_id=10

Step ${index}: Check All RMODs And Cells And Alarm Status On vDU
    Log To Console    \nStep ${index}: Check All RMODs And Cells And Alarm Status On vDU
    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Check vDU Alarms

NetAct Create Managed Object2
    [Arguments]    ${plan}    ${meta_class}    ${meta_version}    ${mo_id}    ${operation}=UPDATE    &{parameters_dict}
    [Documentation]    Create mo which not existed in plan, or edit/delete mo which existed in plan.
    ${status}    ${managed_object_get}    Run Keyword And Ignore Error    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    ${managed_object_create}     Run Keyword If    "${status}"!="PASS"    netact.Create Managed Object    plan=${plan}
    ...    meta_class=${meta_class}    meta_version=${meta_version}    mo_id=${mo_id}    operation=${operation}   &{parameters_dict}
    Run Keyword If    "${status}"=="PASS"    netact.Edit Managed Object    ${managed_object_get}     ${operation}    &{parameters_dict}
    ${status}=    Run Keyword And Return Status    netact.Get Managed Object    configuration=${plan}    mo_id=${mo_id}
    Run Keyword If    ${status}    Run Keywords    Log    MO successfully created or edit: ${mo_id}    console=True
    ...    AND    Log    Parameters were set with plan ${plan}    console=True
    ...    ELSE    Run Keywords    Log    MO creation failed!    level=ERROR
    ...    AND    Fail    MO creation failed!

Provision Delta Plan To Modify RMOD.Predefined Value
    [Arguments]    ${ru_sn}    ${plan}    ${value}
    ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['config']}
    ${rmod_mo_items}    L_XML.Get Element Attributes    ${BTS_initial_scf}
    ...    .//managedObject[@distName="${rmod_configuration}"]
    NetAct Create Managed Object2    plan=${plan}    meta_class=${rmod_mo_items['class']}
    ...    meta_version=${rmod_mo_items['version']}    mo_id=PLMN-PLMN/${rmod_configuration}   predefined=${value}


Perform Delta Plan To Change Connected RMOD.Predefined
    [Arguments]    ${rus_sn}    ${value}
    ${type}    Evaluate    type($rus_sn).__name__
    ${rus_sn}    Run keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${length}    Get Length    ${rus_sn}
    ${value_list}=    Evaluate    ["${value}"]*${length}
    ${para_list}    Evaluate    ["predefined"]*${length}
    ${mo_list}    create list
    FOR    ${ru_sn}    IN    @{rus_sn}
        Append To List    ${mo_list}    ${RMOD_CELL_CONFIG['${ru_sn}']['config']}
    END
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}

Check RMOD.predefined Value
    [Arguments]    ${rus_sn}    ${expected_value}=false
    ${type}    Evaluate    type($rus_sn).__name__
    ${rus_sn}    Run keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${length}    Get Length    ${rus_sn}
    ${value_list}=    Evaluate    ["${expected_value}"]*${length}
    ${para_list}    Evaluate    ["predefined"]*${length}
    ${mo_list}    Create List
    FOR    ${ru_sn}    IN    @{rus_sn}
        Append To List    ${mo_list}    ${RMOD_CELL_CONFIG["${ru_sn}"]['config']}
    END
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}
    FOR    ${mo}    IN    @{mo_list}
        Should Be Equal    ${out["${mo}"]['predefined']}    ${expected_value}
    END

Check vDU Alarms
    [Arguments]    ${ignore_alarms}=@{EMPTY}
    [Documentation]    ${ignore_alarms}    [{"fault_id": 4592, "alarm_id": 7115}]
    ${default_ignore_set}    Create List    4639_7115    4744_7115
    ${active_alarms}    ${output_lenth}    AIC_BTS.Get Active Alarms
    ${current_alarms}    Get From Dictionary    ${active_alarms}    alarms
    ${init_alarms}    Get From Dictionary    ${INITIAL_ALARMS}    alarms

    ${init_set}    Evaluate    set([f"{x['fault_id']}_{x['alarm_id']}" for x in ${init_alarms}])
    ${ignore_set}    Evaluate    set([f"{x['fault_id']}_{x['alarm_id']}" for x in ${ignore_alarms}])

    ${unexpected_alarms}    Create List
    FOR    ${curr_alarm}    IN    @{current_alarms}
        ${key}    Set Variable    ${curr_alarm['fault_id']}_${curr_alarm['alarm_id']}
        IF    "${key}" not in ${init_set} and "${key}" not in ${ignore_set} and "${key}" not in ${default_ignore_set}
            Append To List    ${unexpected_alarms}    ${curr_alarm}
        END
    END
    Should Be Empty    ${unexpected_alarms}


Get RMODs Status On vDU
    [Arguments]    ${vdu_index}=0
    vDU Login By Rest    vdu_index=${vdu_index}
    ${rmods_status}    vdu.get_rmods_status
    [Return]    ${rmods_status}
    [Teardown]    Run keyword and ignore error    vDU Logout By Rest

Check Specified Cells Status On vDU
    [Arguments]    ${cell_ids}    ${vdu_index}=0    &{kwargs}
    ${type}    Evaluate    type(${cell_ids})
    ${cell_ids}    Run Keyword If    "${type}" == "list"    Set Variable    ${cell_ids}
    ...    ELSE    Create List    ${cell_ids}

    vDU Login By Rest    vdu_index=${vdu_index}
    ${cells_status}    vdu.get_vdu_cells_status
    FOR    ${cell_status}    IN    @{cells_status}
        Continue For Loop If    "${cell_status['id']}" not in "${cell_ids}"
        ${keys}    Get Dictionary Keys    ${kwargs}
        FOR    ${key}    IN    @{keys}
            Should Be Equal    ${cell_status['${key}']}    ${kwargs['${key}']}
        END
    END
    [Teardown]    Run keyword and ignore error    vDU Logout By Rest

Check All RMODs And Cells Status On vDU
    [Arguments]    ${vdu_index}=0    ${predefined_rmods}=${PREDEFINED_RMODS}
    ${predefined_rmod_configs}    Create List
    FOR    ${ru_sn}    IN    @{predefined_rmods}
        Append To List    ${predefined_rmod_configs}    ${RMOD_CELL_CONFIG["${ru_sn}"]["config"]}
    END
    ${rmods_status}    Get RMODs Status On vDU    vdu_index=${vdu_index}
    FOR    ${rmod_status}    IN    @{rmods_status}
        IF    "${rmod_status['dist_names']['config']}" in "${predefined_rmod_configs}"
            Should Be Equal    ${rmod_status['operational_state']}     disabled
            Check Specified Cells Status On vDU    ${rmod_status['cell_ids']}    operational_state=disabled
        ELSE
            Should Be Equal    ${rmod_status['operational_state']}     enabled
            Check Specified Cells Status On vDU    ${rmod_status['cell_ids']}    operational_state=enabled
        END
    END

Check Specified RMODs Status On vDU
    [Arguments]    ${rus_sn}    ${vdu_index}=0    &{kwargs}
    ${type}    Evaluate    type(${rus_sn})
    ${rus_sn}    Run Keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${rmods_status}    Get RMODs Status On vDU    vdu_index=${vdu_index}
    ${cell_id_list}    Create List
    FOR    ${rmod_status}    IN    @{rmods_status}
        IF    "${rmod_status['serial_number']}" in "${rus_sn}"
            ${keys}    Get Dictionary Keys    ${kwargs}
            FOR    ${key}    IN    @{keys}
                Should Be Equal    ${rmod_status['${key}']}    ${kwargs['${key}']}
            END
            ${cell_id_list}    Combine Lists    ${cell_id_list}    ${rmod_status['cell_ids']}
        END
    END
    [Return]    ${cell_id_list}

Delete RMODs And Relative Cells
    [Arguments]    ${rus_sn}    ${plan}    ${bts_scf}=${BTS_initial_scf}
    ${all_delete_cells}    Delete RMODs    ${rus_sn}    ${plan}    bts_scf=${bts_scf}
    Delete Cells    ${all_delete_cells}    ${plan}    bts_scf=${bts_scf}

Delete RMODs
    [Arguments]    ${rus_sn}    ${plan}    ${bts_scf}=${BTS_initial_scf}
    ${type}    Evaluate    type($rus_sn).__name__
    ${rus_sn}    Run keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${rmods_config}    Create List
    ${all_delete_cells}    Create List
    FOR    ${ru_sn}    IN    @{rus_sn}
        ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['config']}
        ${rmod_cablinks}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['cablinks']}
        ${rmod_related_distnames}    L_XML.Evaluate Xpath    ${bts_scf}
        ...    .//managedObject[@distName[contains(., '${rmod_configuration}/')]]/@distName
        Append To List    ${rmod_related_distnames}    ${rmod_configuration}
        Append To List    ${rmods_config}    ${rmod_configuration}
        ${distnames}    Combine Lists    ${rmod_related_distnames}    ${rmod_cablinks}
        FOR    ${distname}    IN    @{distnames}
            ${mo_items}    L_XML.Get Element Attributes    ${bts_scf}
            ...    .//managedObject[@distName="${distname}"]
            NetAct Create Managed Object2    plan=${plan}    meta_class=${mo_items['class']}
            ...  meta_version=${mo_items['version']}  mo_id=PLMN-PLMN/${distname}  operation=DELETE  &{EMPTY}
        END
        ${all_delete_cells}    Combine Lists    ${all_delete_cells}    ${RMOD_CELL_CONFIG['${ru_sn}']['cells']}
    END
    ${sync_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${vDU_id}/MNL-1/MNLENT-1/SYNC-2"]
    ${targetDNList}    L_XML.get_elements_texts    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${vDU_id}/MNL-1/MNLENT-1/SYNC-2"]/list[@name="targetDNList"]/p
    Remove Values From List    ${targetDNList}    @{rmods_config}
    NetAct Create Managed Object2    plan=${plan}    meta_class=${sync_mo_items['class']}
    ...    meta_version=${sync_mo_items['version']}    mo_id=PLMN-PLMN/${sync_mo_items["distName"]}   targetDNList=${targetDNList}
    [Return]    ${all_delete_cells}


Delete Cells
    [Arguments]    ${cells}    ${plan}    ${bts_scf}=${BTS_initial_scf}
    ${type}    Evaluate    type($cells).__name__
    ${cells}    Run Keyword If    "${type}" == "list"    Set Variable    ${cells}
    ...    ELSE    Create List    ${cells}
    ${cellgrp_ids}    Create List
    FOR    ${cell_id}    IN    @{cells}
        ${nrcellgrp_config}    Set Variable    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        ${nrCellGrp_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
        ...    .//managedObject[@distName="${nrcellgrp_config}"]
        NetAct Create Managed Object2    plan=${plan}    meta_class=${nrCellGrp_mo_items['class']}
        ...  meta_version=${nrCellGrp_mo_items['version']}  mo_id=PLMN-PLMN/${nrcellgrp_config}  operation=DELETE  &{EMPTY}

        ${lcelnr_related_distnames}    L_XML.Evaluate Xpath    ${bts_scf}
        ...    .//managedObject[@distName[contains(., 'LCELNR-${cell_id}/')]]/@distName
        Append To List    ${lcelnr_related_distnames}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}

        ${cell_config}    Set Variable    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ${nrcell_related_distnames}    L_XML.Evaluate Xpath    ${bts_scf}
        ...    .//managedObject[@distName[contains(., '${cell_config}/')]]/@distName
        Append To List    ${nrcell_related_distnames}    ${cell_config}
        ${distnames}    Combine Lists    ${lcelnr_related_distnames}    ${nrcell_related_distnames}
        FOR    ${distname}    IN    @{distnames}
            ${mo_items}    L_XML.Get Element Attributes    ${bts_scf}
            ...    .//managedObject[@distName="${distname}"]
            NetAct Create Managed Object2    plan=${plan}    meta_class=${mo_items['class']}
            ...  meta_version=${mo_items['version']}  mo_id=PLMN-PLMN/${distname}  operation=DELETE  &{EMPTY}
        END
    END
    ${nrdu_mo_items}    L_XML.Get Element Attributes    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${vDU_id}/NRBTS-${nrbts_id}/NRDU-1"]
    ${refNrCellGroup}    L_XML.get_elements_texts    ${bts_scf}
    ...    .//managedObject[@distName="MRBTS-${vDU_id}/NRBTS-${nrbts_id}/NRDU-1"]/list[@name="refNrCellGroup"]/p
    Remove Values From List    ${refNrCellGroup}    @{cells}
    NetAct Create Managed Object2    plan=${plan}    meta_class=${nrdu_mo_items['class']}    meta_version=${nrdu_mo_items['version']}
    ...    mo_id=PLMN-PLMN/${nrdu_mo_items["distName"]}   refNrCellGroup=${refNrCellGroup}

Get RMOD CELL Mapping Info
    [Arguments]    ${vdu_index}=0
    ${rus_info}=  Get Rmods Status On vDU    vdu_index=${vdu_index}
    ${rmod_cell_config}    Create Dictionary
    FOR    ${ru_info}    IN    @{rus_info}
        ${ru_sn}    Set Variable    ${ru_info['serial_number']}
        ${rmod_config_id}    Set Variable    ${ru_info['dist_names']['config']}
        ${cells}    Set Variable    ${ru_info['cell_ids']}
        ${cablinks}    L_XML.get_elements    ${BTS_initial_scf}
        ...  .//managedObject[@class="com.nokia.srbts.eqm:CABLINK"]/p[@name='secondEndpointDN' and text()='${rmod_config_id}']/../@distName
        ${rmod_info}    Create Dictionary    config=${rmod_config_id}    cells=${cells}    cablinks=${cablinks}
        Set To Dictionary    ${rmod_cell_config}    ${ru_sn}=${rmod_info}
    END
    FOR    ${ru_info}    IN    @{tl.gnbs[0].dus[0].fhgws[0].rus}
        Continue For Loop If    "${ru_info.serial_number}" not in "${rmod_cell_config}"
        ${pdu_addr}    Set Variable    ${ru_info.pdu_port.pdu.addr}
        ${pdu_port}    Set Variable    ${ru_info.pdu_port.port_no}
        ${pdu_vendor}    Set Variable    ${ru_info.pdu_port.pdu.vendor}
        ${pdu}    Create Dictionary    IP=${pdu_addr}    TYPE=${pdu_vendor}    OUTLET=${pdu_port}
        Set To Dictionary    ${rmod_cell_config["${ru_info.serial_number}"]}    pdu=${pdu}
    END
    [Return]    ${rmod_cell_config}

Power Off Predefined Radio
    [Arguments]    ${ru_sn}
    ${pdu_ip}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['pdu']['IP']}
    ${pdu_type}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['pdu']['TYPE']}
    ${pdu_port}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['pdu']['OUTLET']}
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
    ${pdu_ip}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['pdu']['IP']}
    ${pdu_type}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['pdu']['TYPE']}
    ${pdu_port}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['pdu']['OUTLET']}
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

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
#    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Common Test Setup For AIC
    vDU Login By Rest
#    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Log    ${ReIntegrate_vCU}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    ${initial_alarms}    ${output_lenth}    AIC_BTS.Get Active Alarms
    Set Test Variable    ${BTS_initial_scf}    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${rmod_cell_config}    Get RMOD CELL Mapping Info
    Set Test Variable    ${RMOD_CELL_CONFIG}
    set test variable    ${vDU_id}    ${tl.gnbs[0].dus[0].instance_id}
    Set Test Variable    ${INITIAL_ALARMS}
    ${predefined_rmods}    Copy List    ${PREDEFINED_RADIOS}    deepcopy=True
    Set Test Variable    ${PREDEFINED_RMODS}    ${predefined_rmods}

Case Postcondition
    Log To Console    Case Postcondition
    IF    ${RECOVERY_FLAG} and "${TEST STATUS}" == "FAIL"
        FOR    ${ru_sn}    IN    @{PREDEFINED_RADIOS}
            Power On Predefined Radio    ${ru_sn}
        END
        Log   Will perform commissioning with initial scf!    level=WARN
        Parameter Operation    operation=full_commission    product_type=vdu
        ...    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
        Wait Until Keyword Succeeds    20min    30s    Check All RMODs And Cells Status On vDU    predefined_rmods=@{EMPTY}
        vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    END
#    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
#    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
#    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}_backup
#    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}_backup    ${plan}
    Common Test Teardown For AIC
#    Teardown NetAct
