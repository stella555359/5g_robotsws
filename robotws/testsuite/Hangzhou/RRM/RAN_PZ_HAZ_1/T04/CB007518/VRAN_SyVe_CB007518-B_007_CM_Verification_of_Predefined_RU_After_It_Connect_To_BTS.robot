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
@{PREDEFINED_RADIOS}    1M224359341    DH231442010
${ERROR_PRODUCTCODEPLANNED}    475243A.101
${PRODUCT_CODE}    475244A.101
${ERROR_SERIALNUMBERPLANNED}    1M204307184
${RECOVERY_FLAG}    ${False}
&{alarm1}    fault_id=4592    alarm_id=7115
@{IGNORE_ALARMS}    ${alarm1}

*** Keywords ***
VRAN_SyVe_CB007518-B_007_CM_CR_Verification of pre-defined RU after it connect to BTS
    [Documentation]
    ...    Author: amy.wu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    21.7.2025, amy.wu@nokia-sbell.com, draft,
    ...    New case, This case checks that RU can be detected and on air in runtime after it connects to BTS
    ...    when autoInstallOfPredefinedRu as true.
    # S1: A predefined RMOD with prodCodePlanned configured, connect a different prodCodePlanned RMOD, then change prodCodePlanned as matched value.
    Step 1: Precondition: Perform Parameters Change
    Step 2: Connect Predefined RMOD With Mismatch prodCodePlanned And Check Status
    Step 3: Perform One Delta Plan To Change The prodCodePlanned To Correct And Check Status
    # S3: Connect one predefined RU, prodCodePlanned is matched, while serialNumberPlanned id different.
    Step 4: Perform Delta Plan To Change autoInstallOfPredefinedRu As False
    Step 5: Connect One Predefined RMOD And Check Status
    Step 6: Perform Delta Plan To Change The serialNumberPlanned To Error And Check Status
    Step 7: Perform Delta Plan To Change The serialNumberPlanned To Correct And Check Status
    Step 8: Check All RMODs And Cells And Alarm Status On vDU

Step ${index}: Precondition: Perform Parameters Change
    Log To Console    \nStep ${index}: Precondition: Perform Parameters Change
    Set Test Variable    ${rmod_product_code}    ${PREDEFINED_RMODS[0]}
    Set Test Variable    ${rmod_sn}    ${PREDEFINED_RMODS[1]}
    ${para_list}    Create List    autoInstallOfPredefinedRu
    ${mo_list}    Create List    MRBTS-${vDU_id}/MNL-1
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
    ...   para_list=${para_list}    mo_list=${mo_list}
    IF    "${out["MRBTS-${vDU_id}/MNL-1"]['autoInstallOfPredefinedRu']}" == "false"
        @{value_list}    Create List    true
        ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
        ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}
        ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
        ...   para_list=${para_list}    mo_list=${mo_list}
    END
    Should Be True    "${out["MRBTS-${vDU_id}/MNL-1"]['autoInstallOfPredefinedRu']}" == "true"
    FOR    ${ru_sn}    IN    @{PREDEFINED_RMODS}
        ${port_status_needs_change}    Power Off Predefined Radio    ${ru_sn}
        Run Keyword If    ${port_status_needs_change}    Log To Console  \nPower off predefined radio ${ru_sn} PDU port
        ...    ELSE    Log To Console    \nPredefined radio ${ru_sn} PDU port is already off
    END
    Perform Delta Plan To Change Connected RMOD.Predefined    ${PREDEFINED_RMODS}    true
    ${dist_name}    Set Variable    ${RMOD_CELL_CONFIG["${rmod_product_code}"]["config"]}
    ${para_list}    Create List    prodCodePlanned
    ${mo_list}    Create List    ${dist_name}
    @{value_list}    Create List    ${ERROR_PRODUCTCODEPLANNED}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
    ...   para_list=${para_list}    mo_list=${mo_list}
    Should Be True    "${out["${dist_name}"]['prodCodePlanned']}" == "${ERROR_PRODUCTCODEPLANNED}"
    Wait Until Keyword Succeeds    1 min    10 sec    Check All RMODs And Cells Status On vDU
    Wait Until Keyword Succeeds    1 min    10 sec    Check vDU Alarms

Step ${index}: Connect Predefined RMOD With Mismatch prodCodePlanned And Check Status
    Log To Console    \nStep ${index}: Connect Predefined RMOD With Error prodCodePlanned And Check Status
    Power On Predefined Radio    ${rmod_product_code}
    Wait Until Keyword Succeeds    5 min    5 sec    Check Expected Alarms On Specific Alarm Object Is Appear
    ...    ${RMOD_CELL_CONFIG['${rmod_product_code}']['runtime']}    expected_fault_id=4282
    ${cell_ids}    Wait Until Keyword Succeeds    2 min    5 sec    Check Specified RMODs Status On vDU
    ...    ${rmod_product_code}    availability_status=failed    operational_state=disabled
    Check Specified Cells Status On vDU    ${cell_ids}    operational_state=disabled

Step ${index}: Perform One Delta Plan To Change The prodCodePlanned To Correct And Check Status
    Log To Console    \nStep ${index}: Perform One Delta Plan To Change The prodCodePlanned To Correct And Check Status
    ${value_list}=    Create List    ${PRODUCT_CODE}
    ${para_list}    Create List    prodCodePlanned
    ${mo_list}=    Create List    ${RMOD_CELL_CONFIG["${rmod_product_code}"]['config']}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}

    Wait Until Keyword Succeeds    5 min    5 sec    Check Expected Alarms Is Not Appear    expected_fault_id=4282
    ${cell_ids}    Wait Until Keyword Succeeds    5 min    5 sec    Check Specified RMODs Status On vDU
    ...    ${rmod_product_code}    availability_status=on line    operational_state=enabled
    Wait Until Keyword Succeeds    1 min    5 sec    Check Specified Cells Status On vDU    ${cell_ids}
    ...    operational_state=enabled
    Remove Values From List    ${PREDEFINED_RMODS}    ${rmod_product_code}

Step ${index}: Perform Delta Plan To Change autoInstallOfPredefinedRu As ${value}
    Log To Console    \nStep ${index}: Perform Delta Plan To Change autoInstallOfPredefinedRu As ${value}
    ${value_lower}    Convert To Lower Case    ${value}
    @{value_list}    Create List    ${value_lower}
    ${para_list}    Create List    autoInstallOfPredefinedRu
    ${mo_list}    Create List    MRBTS-${vDU_id}/MNL-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}

Step ${index}: Connect ${which} Predefined RMOD And Check Status
    Log To Console    \nStep ${index}: Connect ${which} Predefined RMOD And Check Status
    Power On Predefined Radio    ${rmod_sn}
    ${cell_ids}    Wait Until Keyword Succeeds    5 min    5 sec    Check Specified RMODs Status On vDU
    ...    ${rmod_sn}    operational_state=enabled
    Wait Until Keyword Succeeds    30 sec    5 sec    Check Specified Cells Status On vDU    ${cell_ids}
    ...    operational_state=disabled
    Check vDU Alarms    ignore_alarms=${IGNORE_ALARMS}

Step ${index}: Perform Delta Plan To Change The serialNumberPlanned To Error And Check Status
    Log To Console    \nStep ${index}: Perform Delta Plan To Change The serialNumberPlanned To Error And Check Status
    ${dist_name}    Set Variable    ${RMOD_CELL_CONFIG["${rmod_sn}"]["config"]}
    ${para_list}    Create List    serialNumberPlanned
    ${mo_list}    Create List    ${dist_name}
    @{value_list}    Create List    ${ERROR_SERIALNUMBERPLANNED}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
    ...   para_list=${para_list}    mo_list=${mo_list}
    Should Be True    "${out["${dist_name}"]['serialNumberPlanned']}" == "${ERROR_SERIALNUMBERPLANNED}"

    Wait Until Keyword Succeeds    5 min    5 sec    Check Expected Alarms On Specific Alarm Object Is Appear
    ...   ${RMOD_CELL_CONFIG["${rmod_sn}"]["runtime"]}    expected_fault_id=4282
    ${cell_ids}    Wait Until Keyword Succeeds    2 min    5 sec    Check Specified RMODs Status On vDU
    ...    ${rmod_sn}    availability_status=failed    operational_state=disabled
    Check Specified Cells Status On vDU    ${cell_ids}    operational_state=disabled

Step ${index}: Perform Delta Plan To Change The serialNumberPlanned To Correct And Check Status
    Log To Console    \nStep ${index}: Perform Delta Plan To Change The serialNumberPlanned To Correct And Check Status
    ${dist_name}    Set Variable    ${RMOD_CELL_CONFIG["${rmod_sn}"]["config"]}
    ${para_list}    Create List    serialNumberPlanned
    ${mo_list}    Create List    ${dist_name}
    @{value_list}    Create List    ${rmod_sn}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${True}
    ${out}    Parameter Operation    operation=parameter_value_check   product_type=vdu
    ...   para_list=${para_list}    mo_list=${mo_list}
    Should Be True    "${out["${dist_name}"]['serialNumberPlanned']}" == "${rmod_sn}"

    Wait Until Keyword Succeeds    5 min    5 sec    Check Expected Alarms Is Not Appear    expected_fault_id=4282
    ${cell_ids}    Wait Until Keyword Succeeds    5 min    5 sec    Check Specified RMODs Status On vDU
    ...    ${rmod_sn}    availability_status=on line    operational_state=enabled
    Perform Delta Plan To Change Connected RMOD.Predefined    ${rmod_sn}    false
    Wait Until Keyword Succeeds    5 min    5 sec    Check Specified Cells Status On vDU    ${cell_ids}
    ...    operational_state=enabled

Step ${index}: Check All RMODs And Cells And Alarm Status On vDU
    Log To Console    \nStep ${index}: Check All RMODs And Cells And Alarm Status On vDU
    Check All RMODs And Cells Status On vDU    predefined_rmods=@{EMPTY}
    Check VDU Alarms

Check Expected Alarms On Specific Alarm Object Is Appear
    [Arguments]  ${alarm_object}    ${vdu_index}=0    ${expected_fault_id}=49
    vDU Login By Rest    vdu_index=${vdu_index}
    ${out}    vdu.vdu_get_active_alarms
    ${output_lenth}=    set variable    ${out['total']}
    ${status}=   set variable   False
    FOR    ${index}    IN RANGE    ${output_lenth}
        Continue For Loop If    "${out['alarms'][${index}]['alarming_object']}" != "${alarm_object}"
        ${fault_id}    Set Variable    ${out['alarms'][${index}]['fault_id']}
        ${status}=    set variable if    "${fault_id}" == "${expected_fault_id}"    True
        exit for loop if     "${fault_id}" == "${expected_fault_id}"
    END
    should be equal    ${status}    True    expected fault id is not appear!

Get RMOD Product Code Value
    [Arguments]    ${ru_sn}
    ${rmods_status}    Get RMODs Status On vDU
    FOR    ${rmod_status}    IN    @{rmods_status}
        Return From Keyword If    "${rmod_status['serial_number']}" == "${ru_sn}"    ${rmod_status['product_code']}
    END
    Fail

Provision Delta Plan To Modify Rmod.Predefined Value
    [Arguments]    ${ru_sn}    ${plan}    ${value}
    ${rmod_configuration}    Set Variable    ${RMOD_CELL_CONFIG['${ru_sn}']['config']}
    ${rmod_mo_items}    L_XML.Get Element Attributes    ${BTS_initial_scf}
    ...    .//managedObject[@distName="${rmod_configuration}"]
    NetAct Create Managed Object    plan=${plan}    meta_class=${rmod_mo_items['class']}
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
    ${active_alarms}    ${output_lenth}    AIC_BTS.Get Active Alarms
    ${current_alarms}    Get From Dictionary    ${active_alarms}    alarms
    ${init_alarms}    Get From Dictionary    ${INITIAL_ALARMS}    alarms

    ${init_set}    Evaluate    set([f"{x['fault_id']}_{x['alarm_id']}" for x in ${init_alarms}])
    ${ignore_set}    Evaluate    set([f"{x['fault_id']}_{x['alarm_id']}" for x in ${ignore_alarms}])

    ${unexpected_alarms}    Create List
    FOR    ${curr_alarm}    IN    @{current_alarms}
        ${key}    Set Variable    ${curr_alarm['fault_id']}_${curr_alarm['alarm_id']}
        IF    "${key}" not in ${init_set} and "${key}" not in ${ignore_set}
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
    ${type}    Evaluate    type($cell_ids).__name__
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
    ${type}    Evaluate    type($rus_sn).__name__
    ${rus_sn}    Run Keyword If    "${type}" == "list"    Set Variable    ${rus_sn}
    ...    ELSE    Create List    ${rus_sn}
    ${rmod_configs}    Create List
    FOR    ${ru_sn}    IN    @{rus_sn}
        Append To List    ${rmod_configs}    ${RMOD_CELL_CONFIG["${ru_sn}"]["config"]}
    END
    ${rmods_status}    Get RMODs Status On vDU    vdu_index=${vdu_index}
    ${cell_id_list}    Create List
    FOR    ${rmod_status}    IN    @{rmods_status}
        IF    "${rmod_status['dist_names']['config']}" in "${rmod_configs}"
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
        ${rmod_runtime}    Set Variable    ${ru_info['dist_names']['runtime']}
        ${cells}    Set Variable    ${ru_info['cell_ids']}
        ${cablinks}    L_XML.get_elements    ${BTS_initial_scf}
        ...  .//managedObject[@class="com.nokia.srbts.eqm:CABLINK"]/p[@name='secondEndpointDN' and text()='${rmod_config_id}']/../@distName
        ${rmod_info}    Create Dictionary    config=${rmod_config_id}    cells=${cells}    cablinks=${cablinks}
        ...    runtime=${rmod_runtime}
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
    Log Variables
#    Set Test Variable    ${RECOVERY_FLAG}    True
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
    Log To Console    ${RECOVERY_FLAG}
    IF    ${RECOVERY_FLAG} and "${TEST STATUS}" == "FAIL"
        FOR    ${ru_sn}    IN    @{PREDEFINED_RADIOS}
            Power On Predefined Radio    ${ru_sn}
        END
        Log   Will perform commissioning with initial scf!    level=WARN
        Parameter Operation    operation=full_commission    product_type=vdu
        ...    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
        Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    END
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}    ${plan}
    ${status}    ${plan}    Run Keyword And Ignore Error    netact.Get Plan Configuration    ${name}_backup
    Run Keyword If    '${status}' == 'PASS'    NetAct Delete Plan    ${name}_backup    ${plan}
    Common Test Teardown For AIC
#    Teardown NetAct
