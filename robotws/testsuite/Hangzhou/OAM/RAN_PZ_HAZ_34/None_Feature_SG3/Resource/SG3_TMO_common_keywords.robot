*** Settings ***
Documentation    This is for TMO common keywords.
...              Please do not modify the file without notification to author
...              Author: jack.zeng@nokia-sbell.com


Variables   ./TMO_Data.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    Common_setup_and_teardown.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${BASIC_SCF}    tmo_basic.xml


*** Keywords ***
#--- Setup And TearDown---#
TMO_Common_Suite_Setup
    [Documentation]    Author: jack.zeng@nokia-sbell.com
    ${stream_version}    gnb_classical_hangzhou.Get program version based on stream version
    Set Suite Variable    ${stream_version}
    # get how many UEs
    #${ue_length}    Get Length    ${tl.ues}
    Set Suite Variable    ${ue_length}     1
    # get tl_prefix, such as T813/T073
    Set Suite Variable    ${tl_prefix}    ${testline_name.split('_')[-1][-4:]}
    # get how many ENBs
    ${enb_length}    Get Length    ${tl.enbs}
    Set Suite Variable    ${enb_length}
    Verify TMO Gnb Ready And All Cell On Air
    #####no need to check enb individually due to there is enb, BTS is multi-rat currently#####
    #####and for LTE cell is checked on keyword Verify TMO Gnb Ready And All Cell On Air #####
#    Log to console    ${\n}----Verify all cells of enbs are on air----
#    FOR    ${enb_id}    IN RANGE    ${enb_length}
#        Wait until keyword succeeds    2 min    20 sec    Verify Enb All Cell On Air    enb_index=${enb_id}
#    END
    sleep    5s
    #Trun Off All PA Ports

TMO_Common_Case_Setup
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Common_setup_and_teardown.Common Case Setup
    Set Test Variable    ${test_case_id}    ${TEST NAME.split('_')[0]}
    Set Test Variable    ${PCELL_INDEX}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['pcell_idx']}
    Set Test Variable    ${attenuator_list}    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['attenuator']}
    Set Test Variable    ${scell_technology}
    ...                  ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['${tl_prefix}']['ca_technology'].split('+')[-1]}
    Get CA Related Infomation    pcell_index=${PCELL_INDEX}
    Set Case PA Or MCS Port Value    attenuator_list=${attenuator_list}    ue_index=${ue_index}

#    ${ho_port_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${CHANNELS_DIC}    ho_port_value_mapping
#    ${HO_PA_MAPPING}    Run Keyword If    ${ho_port_status}    Set Variable
#    ...    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['ho_port_value_mapping']}
#    Run Keyword If    ${ho_port_status}    Set Test Variable    ${HO_PA_MAPPING}
#    ${ho_pcell_status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${CHANNELS_DIC}    after_ho_pcell_idx
#    ${HO_PCELL_INDEX}    Run Keyword If    ${ho_pcell_status}    Set Variable
#    ...    ${GNB_INFO_MAPPING_TO_CASE_TABLE['${test_case_id}']['after_ho_pcell_idx']}
#    Run Keyword If    ${ho_pcell_status}    Set Test Variable    ${HO_PCELL_INDEX}

TMO_Common_Case_Teardown
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Run Keyword And Ignore Error    Spark_common_keywords.Start UE Detach    ue_index=${ue_index}
    Run Keyword And Ignore Error    Trun Off All PA Ports
#    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False


#--- Common keywords for tools---#
Trun Off All PA Ports
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    @{attenuator_num}    Set Variable    ${tl.attenuators}
    ${attenuator_length}    Get Length    ${attenuator_num}
    FOR    ${attenuator_id}    IN RANGE    ${attenuator_length}
        Initial PA Value Setting For Whole PA    attenuator_index=${attenuator_id}
    END

Modify Attenuation Vaule
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${attenuator_id}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING['${stream_version}'][${ue_index}]['${modify_ru_id}']}
    ${channels_dic}    Set Variable    ${${tl_prefix}_PA_VALUE_MAPPING['${stream_version}'][${ue_index}]['${modify_ru_id}'][${attenuator_id[0]}]}
    attenuator.setup_attenuator    attenuator=${tl.attenuators[${attenuator_id[0]}]}
    @{channels}    Get Dictionary Keys    ${channels_dic}
    @{ports}    Create List
    @{values}    Create List
    FOR    ${channel}    IN    @{channels}
        ${base_up_value}    Set Variable
        ...    ${${tl_prefix}_PA_VALUE_MAPPING['${stream_version}'][${ue_index}]['${modify_ru_id}'][${attenuator_id[0]}]['${channel}']}
        ${base_down_value}    Set Variable    ${pa_off_value}
        ${base_value}    Set Variable If    ${pa_off_value}==${None}    ${base_up_value}    ${base_down_value}
        ${channel}    Convert To Integer    ${channel}
        ${value}    Evaluate    float(${base_value})
        Append To List    ${ports}    ${channel}
        Append To List    ${values}    ${value}
    END
    Wait Until Keyword Succeeds   5min   5sec   attenuator.set_ports_attenuation   ports=${ports}   values=${values}   confirm=True
    @{new_values}    attenuator.read_ports_attenuation     ports=${ports}
    Lists Should Be Equal    ${new_values}    ${values}    msg=Attenuation set failed.
    Log To Console    \n change attenuation to ${value}

Modify PA Value Setting For Required RU
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${modify_ru_id}=0    ${ue_index}=${0}    ${pa_off_value}=${None}
    ${modify_ru_id_type}    Evaluate    type(${modify_ru_id}).__name__
    ${convert_modify_ru_id_to_list}    Create List    ${modify_ru_id}
    ${modify_ru_id_list}    Set Variable If    'list' in '${modify_ru_id_type}'    ${modify_ru_id}    ${convert_modify_ru_id_to_list}
    FOR    ${ru_index}    IN    @{modify_ru_id_list}
        ${ru_index_list}    Get Dictionary Keys    ${${tl_prefix}_PA_VALUE_MAPPING['${stream_version}'][${ue_index}]}
        ${status}    Run Keyword And Return Status    List Should Contain Value    ${ru_index_list}    ${ru_index}
        Run Keyword If    ${status}    Modify Attenuation Vaule    modify_ru_id=${ru_index}
        ...                                                        ue_index=${ue_index}
        ...                                                        pa_off_value=${pa_off_value}
    END

Set Case Related PA Port Value
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ${pcell_ru_index}    Set Variable    ${PCELL_MAPPING['ru_index_mapping']}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_ru_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['ru_index_mapping']}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    Modify PA Value Setting For Required RU    modify_ru_id=${pcell_ru_index}    ue_index=${ue_index}
    Modify PA Value Setting For Required RU    modify_ru_id=${scell_ru_index_list}    ue_index=${ue_index}

Set Case Related MCS Port Value
    [Documentation]   jun.8.chen@nokia-sbell.com
    Log To Console     ${\n}INFO: -- Need to do


#--- Common keywords for gnb ---#
Verify TMO Gnb Ready And All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Check ALL cells on air include: "lte", "wcdma", "gsm", "nr".
    [Arguments]    ${connection}=GNB_OAM
    Wait until keyword succeeds    10 min    60 sec    Check the cells status on air
    ...    bts_host=${tl.gnbs[0].cu.oam_http_connection_details.addr}    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=lte    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=wcdma    connection=${connection}
    Wait until keyword succeeds    2 min    20 sec    Verify Gnb Type Cells Should Be Onair    cell_type=gsm    connection=${connection}

Verify Gnb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=lte    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=30
    Log to console    ${\n}----Verify all ${cell_type} cells are on air----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}
    ...     unlocked    ignore_case=True
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}
    ...     enabled    ignore_case=True
    END
    [Return]    ${cell_list}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Verify Enb All Cell On Air
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${enb_index}=${0}    ${connection}=enblte_${enb_index}    ${timeout}=30
    Connect to eNB via ssl    enb_index=${enb_index}    connection=${connection}
	${output}    enblte.get_bts_info    connection=${connection}
    @{rat_type_list}    Create List
    ${ratState_list}    Get Dictionary Keys    ${output['ratState']}
    FOR    ${item}    IN    @{ratState_list}
        ${value}    Get From Dictionary    ${output['ratState']}    ${item}
        Run Keyword If    '${value}' != 'NO_CELLS'    Append To List    ${rat_type_list}    ${item}
    END
    FOR    ${rat_type}    IN    @{rat_type_list}
        Verify Enb Type Cells Should Be Onair    cell_type=${rat_type}    connection=${connection}    timeout=${timeout}
    END
	[Teardown]    Run Keyword And Ignore Error    Enblte close down    connection=${connection}

Verify Enb Type Cells Should Be Onair
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm".
    [Arguments]    ${cell_type}    ${connection}    ${timeout}=30
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR    ${cell}    IN    @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}
    ...     unlocked    ignore_case=True
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}
    ...     enabled    ignore_case=True
    END

Get CA Related Infomation
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_index}=${PCELL_INDEX}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${300}
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    ${tdd_scell_list}    Get Dictionary Keys   ${TDD_SCELL_MAPPING}
    ${fdd_scell_list}    Get Dictionary Keys   ${FDD_SCELL_MAPPING}
    ${scell_list}    Set Variable If    '${scell_technology}'=='TDD'    ${tdd_scell_list}    ${fdd_scell_list}
    ${chbw_param_name}    Set Variable If    '${scell_technology}'=='TDD'    chBw    chBwDl
    ${scell_chbw_value}    Set Variable    ${0}
    ${scell_index}    Set Variable    ${0}
    FOR    ${scell}    IN    @{scell_list}
        ${scell_chbw}    Set Variable    ${scell_mapping[${scell}]['all_cell_info']['detail_cells_info']['${chbw_param_name}']}
        ${scell_chbw}    Set Variable    ${scell_chbw.split('M')[0]}
        ${scell_chbw}    Evaluate    int(${scell_chbw})
        ${scell_index}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell}    ${scell_index}
        ${scell_chbw_value}    Set Variable If     ${scell_chbw}>=${scell_chbw_value}    ${scell_chbw}    ${scell_chbw_value}
    END
    @{scell_index_list}    Create List    ${scell_index}
    Modify WeightForSCellSelection Parameter Value On Gnb    scell_list_used_in_fact=${scell_index_list}
    ...                                                      scell_list_supported=${scell_list}
    ...                                                      connection=${connection}
    ...                                                      gnb_id=${gnb_id}
    ...                                                      timeout=${timeout}
    @{scell_pci_list}    Create List
    FOR    ${item}    IN    @{scell_index_list}
        ${scell_pci}    Set Variable    ${SCELL_MAPPING[${item}]['all_cell_info']['physicalCellId']}
        ${scell_pci}    Convert To String    ${scell_pci}
        Append to List    ${scell_pci_list}    ${scell_pci}
    END
    Set Test Variable    ${SCELL_INDEX_LIST}    ${scell_index_list}
    Set Test Variable    ${SCELL_PCI_LIST}    ${scell_pci_list}

Modify WeightForSCellSelection Parameter Value On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${scell_list_used_in_fact}
    ...            ${scell_list_supported}
    ...            ${connection}=GNB_OAM0
    ...            ${gnb_id}=${0}
    ...            ${timeout}=${300}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_id}
    ${rest_scell_list}    Evaluate    list(set(${scell_list_supported})-set(${scell_list_used_in_fact}))
    @{params_for_update}    Create List
    Log To Console    ${\n}Modify weight value to 100 of ${scell_list_used_in_fact} on GNB: ${gnb_id}
    FOR    ${cell_index}    IN    @{scell_list_used_in_fact}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELL-${cell_index}
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=weightForSCellSelection    value=100
        Append To List    ${params_for_update}    ${param}
    END
    Log To Console    ${\n}Modify weight value to 10 of ${rest_scell_list} on GNB: ${gnb_id}
    FOR    ${cell_index}    IN    @{rest_scell_list}
        ${dist_name}    Set Variable    NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELL-${cell_index}
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=weightForSCellSelection    value=10
        Append To List    ${params_for_update}    ${param}
    END
    Log To Console    ${\n}Update weight value on GNB: ${gnb_id}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Get RU Index In Init Via Cell Index
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    Source COAM Login Page Via WebUI
    ${pcell_rmod_index}    Set Variable    ${PCELL_MAPPING['rmod_index']}
    ${serial_number}    Get Serial Number Via Rmod Index On Gnb    rmod_index=${pcell_rmod_index}
    ${pcell_ru_index}    Get RU Index In Init Via Serial Number Of RU On Gnb    serial_number=${serial_number}
    ${scell_ru_index_list}    Create List
    FOR  ${scell_index}  IN    @{SCELL_INDEX_LIST}
        ${scell_rmod_index}    Set Variable    ${SCELL_MAPPING[${scell_index}]['all_cell_info']['rmod_index']}
        ${serial_number}    Get Serial Number Via Rmod Index On Gnb    rmod_index=${scell_rmod_index}
        ${scell_ru_index}    Get RU Index In Init Via Serial Number Of RU On Gnb    serial_number=${serial_number}
        Append To List    ${scell_ru_index_list}    ${scell_ru_index}
    END
    [Return]    ${pcell_ru_index}    ${scell_ru_index_list}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Get Serial Number Via Rmod Index On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${rmod_index}
    ${output_ru}      selenium_coam.get_ru_info    ru_index=${rmod_index}
    ${serial_number}    Set Variable    ${output_ru['Serial number']}
    [Return]    ${serial_number}

Get RU Index In Init Via Serial Number Of RU On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${serial_number}
    ${all_ru_list_in_init}    Set Variable    ${tl.gnbs[0].dus[0].rus}
    FOR    ${ru_in_init}    IN    @{all_ru_list_in_init}
        ${ru_index}    Get Index From List    ${all_ru_list_in_init}    ${ru_in_init}
        ${sn_of_ru}    Set Variable    ${tl.gnbs[0].dus[0].rus[${ru_index}].serial_number}
        ${status}    Evaluate    "${serial_number}"=="${sn_of_ru}"
        Exit For Loop If    "${status}"=="True"
    END
    [Return]    ${ru_index}

Set Case PA Or MCS Port Value
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${attenuator_list}    ${ue_index}=${0}
    FOR    ${attenuator}    IN    @{attenuator_list}
        Run Keyword If    '${attenuator}'=='pa'    Set Case Related PA Port Value    ue_index=${ue_index}
        ...    ELSE IF    '${attenuator}'=='mcs'    Set Case Related MCS Port Value
        ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong attenuator type(${attenuator}), need to check TMO_Data.py--
    END

Change cellBarred Parameter Value On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...    Keep only Pcell to notBarred status, and set all other cells to barred status, just for 5G cell
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${pcell_index}    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=${300}
    @{expected_pcell_list}    Create List    ${pcell_index}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_id}
    Change status for parameter cellBarred on GNB    exp_status=notBarred
    ...                                              list_cell_ids=${expected_pcell_list}
    ...                                              connection=${connection}
    ...                                              gnb_index=${gnb_id}
    ...                                              timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Change cellBarred Parameter Value Of Lte Cells
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...    Keep only Pcell to notBarred status, and set all other cells to barred status, just for 4G cell
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${cell_list}    ${exp_status}=notBarred    ${list_cell_ids}=all    ${connection}=GNB_OAM
    ...            ${gnb_id}=${0}    ${timeout}=${300}
    @{expected_pcell_list}    Create List    ${exp_status}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${gnb_id}
    @{all_cell_ids}    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
        Append To List    ${all_cell_ids}    ${cell_idx}
    END
    ${lnbts_id}    Set Variable    ${cell.split('-')[-2].split('/')[0]}
    ${is_all_cellls_entered}    Run Keyword And Return Status    Should contain    ${list_cell_ids}    all
    ${list_cell_ids}    Set Variable If    ${is_all_cellls_entered}    ${all_cell_ids}    ${list_cell_ids}
    ${list_cell_ids}    Convert Data Type To A List    input_data=${list_cell_ids}
    ${all_cell_idss}    Evaluate    list(map(lambda x: int(x), ${all_cell_ids}))
    ${list_cell_ids}    Evaluate    list(map(lambda x: int(x), ${list_cell_ids}))
    ${rest_cell_ids}    Evaluate    list(set(${all_cell_idss})-set(${list_cell_ids}))
    ${rest_cell_barred_status}    Set Variable If    '${exp_status}'=='barred'    notBarred    barred
    @{params_for_update}    Create List
    Log To Console    ${\n}Change status to ${exp_status} for expected cells: ${list_cell_ids} on GNB: ${gnb_id}
    FOR    ${cell_index}    IN    @{list_cell_ids}
        ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/LNBTS-${lnbts_id}/LNCEL-${cell_index}/SIB-0
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${exp_status}
        Append To List    ${params_for_update}    ${param}
    END
    Log To Console    ${\n}Change status to ${rest_cell_barred_status} for rest cells: ${rest_cell_ids} on GNB: ${gnb_id}
    FOR    ${cell_index}    IN    @{rest_cell_ids}
        ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/LNBTS-${lnbts_id}/LNCEL-${cell_index}/SIB-0
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${rest_cell_barred_status}
        Append To List    ${params_for_update}    ${param}
    END
    Log To Console    ${\n}Parameters for update cellBarred status are: ${params_for_update} on GNB: ${gnb_id}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}    timeout=${timeout}
    ...    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Update The Prach Index
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                This keyword just for 5G cell.
    [Arguments]    ${cell_index}    ${prach_index}=158
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/NRCELL-${cell_index}
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=prachConfigurationIndex    value=${prach_index}
    @{param_list}    Create List    ${param}
    Common_keywords.Update Params Via RestApi    params_need_to_modify=${param_list}

Update AMF Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    [Arguments]    ${administrativeState}=Locked    ${connection}=GNB_OAM    ${gnb_index}=0    ${timeout}=300
    ${dist_name}    Set Variable    MRBTS-${tl.gnbs[${gnb_id}].instance_id}/NRBTS-${tl.gnbs[${gnb_id}].global_bts_id}/SERVEDAMF-1
    ${param}    Create Dictionary    dist_name=${dist_name}    parameter=administrativeState    value=${administrativeState}
    @{param_list}    Create List    ${param}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections

Verify SERVEDAMF Status On GNB
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                When AMF is lock, gnb and enb is no expect alarm, so need to check point is check unexpect alarm
    ...                ${administrativeState}: Value can be "Unlocked" or "Locked"
    ...                ${ngLinkStatus}: Value can be "Active" or "Inactive"
    [Arguments]    ${connection}=GNB_OAM
    ...            ${enb_connection}=enblte
    ...            ${gnb_index}=${0}
    ...            ${enb_index}=${0}
    ...            ${administrativeState}=Unlocked
    ...            ${ngLinkStatus}=Active
    Log To Console    ${\n}Check SERVEDAMF status from GNB
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Connect to eNB via ssl    connection=${enb_connection}    enb_index=${enb_index}
    @{SERVEDAMF_A}    coam.get_managed_objects    class_name=SERVEDAMF_A    connection=${connection}
    @{SERVEDAMF_L}    coam.get_managed_objects    class_name=SERVEDAMF_L    connection=${connection}
    &{dict_amfStatus}    coam.get_parameters    dist_name=${SERVEDAMF_A[0]['distName']}    pattern=administrativeState
    ...                                                                                    connection=${connection}
    &{dict_ngLinkStatus}    coam.get_parameters    dist_name=${SERVEDAMF_L[0]['distName']}    pattern=ngLinkStatus
    ...                                                                                       connection=${connection}
    Should Be Equal As Strings    ${dict_amfStatus['administrativeState']}    ${administrativeState}    msg=AMF is not ${administrativeState}
    ...                                                                                                 ignore_case=${True}
    Should Be Equal As Strings    ${dict_ngLinkStatus['ngLinkStatus']}    ${ngLinkStatus}    msg=AMF is not ${ngLinkStatus}
    ...                                                                                      ignore_case=${True}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_UUF}    connection=${connection}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT_UUF}    connection=${enb_connection}
    Wait Until Keyword Succeeds    10 min    20 sec    Verify TMO Gnb Ready And All Cell On Air    connection=${connection}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}    AND
    ...                           Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get Pcell And Scell Mapping Info After Handover
    [Documentation]   Author:jun.8.chen@nokia-sbell.com
    [Arguments]    ${ho_pcell_index}    ${source_gnb_id}=0    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                                                                             gnb_index=${source_gnb_id}
    mbca.set_pcell_index    value=${ho_pcell_index}
    mbca.set_gnb_id    value=${source_gnb_id}
    mbca.set_gnb_operation_object
    ${ho_pcell_mapping}    mbca.get_pcell_mapping
    ${ho_scell_mapping}    mbca.get_scell_mapping_for_pcell
    ${ho_tdd_scell_mapping}    mbca.get_tdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    ${ho_fdd_scell_mapping}    mbca.get_fdd_scell_mapping    all_scell_info=${ho_scell_mapping}
    Set Test Variable    ${HO_PCELL_MAPPING}     ${ho_pcell_mapping}
    Set Test Variable    ${HO_SCELL_MAPPING}    ${ho_scell_mapping}
    Set Test Variable    ${HO_TDD_SCELL_MAPPING}    ${ho_tdd_scell_mapping}
    Set Test Variable    ${HO_FDD_SCELL_MAPPING}    ${ho_fdd_scell_mapping}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Do All Type Cells Action And Verify Status
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    [Arguments]    ${cell_action}=locked    ${cell_type}=nr    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${is_connect_coam_needed}=${True}
    Do All Type Cells Lock Or Unlock    cell_action=${cell_action}
    ...                                 cell_type=${cell_type}
    ...                                 timeout=${timeout}
    ...                                 gnb_id=${gnb_id}
    ...                                 gnb_connection=${gnb_connection}
    ...                                 enb_index=${enb_index}
    ...                                 enb_connection=${enb_connection}
    ...                                 is_connect_coam_needed=${is_connect_coam_needed}
    Run Keyword If    '${cell_action}'=='locked'    Wait Until Keyword Succeeds    ${timeout} sec    10 sec
    ...                                             Verify All Type Cells Should Be locked    cell_type=${cell_type}
    ...                                                                                       timeout=${timeout}
    ...                                                                                       gnb_id=${gnb_id}
    ...                                                                                       gnb_connection=${gnb_connection}
    ...                                                                                       enb_index=${enb_index}
    ...                                                                                       enb_connection=${enb_connection}
    ...                                                                                       is_connect_coam_needed=${is_connect_coam_needed}
    ...    ELSE IF    '${cell_action}'=='unlocked'    Wait Until Keyword Succeeds    ${timeout} sec    10 sec
    ...                                               Verify All Type Cells Should Be unlocked    cell_type=${cell_type}
    ...                                                                                           timeout=${timeout}
    ...                                                                                           gnb_id=${gnb_id}
    ...                                                                                           gnb_connection=${gnb_connection}
    ...                                                                                           enb_index=${enb_index}
    ...                                                                                           enb_connection=${enb_connection}
    ...                                                                                           is_connect_coam_needed=${is_connect_coam_needed}
    ...    ELSE    Log To Console     ${\n}INFO: --Use the wrong cell action(${cell_action}), need to check--

Do All Type Cells Lock Or Unlock
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    ...                ${cell_action}:value can be "locked"  or "unlocked"
    [Arguments]    ${cell_action}=locked    ${cell_type}=nr    ${timeout}=300    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${is_connect_coam_needed}=${True}
    Log to console    ${\n}----Do all ${cell_type} cells ${cell_action}----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
	${output}    coam.get_bts_info    connection=${gnb_connection}
    ${value}    Get From Dictionary    ${output['ratState']}    ${cell_type}
    ${cell_type_whether_in_gnb}    Set Variable If    '${value}' != 'NO_CELLS'    ${True}    ${False}
    Run Keyword If    ${cell_type_whether_in_gnb}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${cell_type_whether_in_gnb}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{params_for_update}    Create List
    ${action}    Run Keyword If    '${cell_type}'=='nr' and '${cell_action}'=='locked'    Set Variable    Locked
    ...                 ELSE IF    '${cell_type}'=='nr' and '${cell_action}'=='unlocked'    Set Variable    Unlocked
    ...                 ELSE IF    '${cell_type}'=='lte' and '${cell_action}'=='locked'    Set Variable    locked
    ...                 ELSE IF    '${cell_type}'=='lte' and '${cell_action}'=='unlocked'    Set Variable    unlocked
    FOR   ${cell_dist_name}    IN     @{cell_list}
         ${param}    Create Dictionary    dist_name=${cell_dist_name}    parameter=administrativeState    value=${action}
         Append To List    ${params_for_update}    ${param}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${cell_type_whether_in_gnb}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify All Type Cells Should Be locked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${is_connect_coam_needed}=${True}
    Log to console    ${\n}----Verify all ${cell_type} cells are locked----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${offline}    Set Variable If    ${result}    Offline    off line
	${output}    coam.get_bts_info    connection=${gnb_connection}
    ${value}    Get From Dictionary    ${output['ratState']}    ${cell_type}
    ${cell_type_whether_in_gnb}    Set Variable If    '${value}' != 'NO_CELLS'    ${True}    ${False}
    Run Keyword If    ${cell_type_whether_in_gnb}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${cell_type_whether_in_gnb}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    ${offline}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}    ${disabled}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}    Locked
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${cell_type_whether_in_gnb}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Verify All Type Cells Should Be unlocked
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :param str cell_type: Cell type of given RAT: "lte", "wcdma", "gsm", "nr" (5G). Default: "nr".
    [Arguments]    ${cell_type}=nr    ${timeout}=300    ${gnb_connection}=GNB_OAM    ${gnb_id}=0
    ...            ${enb_index}=${0}    ${enb_connection}=enblte_${enb_index}    ${is_connect_coam_needed}=${True}
    Log to console    ${\n}----Verify all ${cell_type} cells are unlocked----
    Run Keyword If    ${is_connect_coam_needed}    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...                                                                                                connection=${gnb_connection}
    ...                                                                                                gnb_index=${gnb_id}
    ${result}    Run Keyword And Return Status    Should Contain Any    ${stream_version}    12.400    14.400    22R1    22R2    21B
    ${enabled}    Set Variable If    ${result}    Enabled    enabled
	${output}    coam.get_bts_info    connection=${gnb_connection}
    ${value}    Get From Dictionary    ${output['ratState']}    ${cell_type}
    ${cell_type_whether_in_gnb}    Set Variable If    '${value}' != 'NO_CELLS'    ${True}    ${False}
    Run Keyword If    ${cell_type_whether_in_gnb}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${cell_type_whether_in_gnb}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    FOR  ${cell}  IN   @{cell_list}
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['operationalState']}
    ...     ${enabled}    ignore_case=True
        Run Keyword And Continue On Failure    Should Be Equal As Strings    ${cell_list_info['${cell}']['administrativeState']}
    ...     unlocked    ignore_case=True
        run keyword if    ${result}    Run Keyword And Continue On Failure
        ...    Should Be Equal As Strings    ${cell_list_info['${cell}']['availabilityStatus']}    Online    ignore_case=True
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    ${is_connect_coam_needed}
    ...                          Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${cell_type_whether_in_gnb}==${False} and ${is_connect_coam_needed} and '${enb_length}'!='${0}'
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}


#--- Common Procedures KW ---#
Procedures.Verify CA Basic L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...            ${ue_mode}=SA
    ...            ${scell_addition_method}=A1
    ...            ${ul_throughput}=150M
    ...            ${dl_throughput}=2500MKbits/sec
    ...            ${start_keep_on_duration}=1200
    ...            ${tput_collect_duration}=180
    ...            ${whether_check_scell_addition}=${True}
    ...            ${whether_do_barred_action}=${True}
    ...            ${whether_check_on_air}=${True}
    ...            ${whether_do_ue_prepare}=${True}
    ...            ${whether_check_tupt}=${True}
    ...            ${expect_tp_percent}=1
    ...            ${notbarred_cell_index}=${PCELL_INDEX}
    ...            ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${whether_need_ue_log}=${True}
    ...            ${ignore_time}=1min
#    Change cellBarred Parameter Value Of Lte Cells    cell_list=${LTE_CELL_LIST}    list_cell_ids=${notbarred_cell_index}
    Run Keyword If    ${whether_do_barred_action}    Change cellBarred Parameter Value On Gnb    pcell_index=${notbarred_cell_index}
    Run Keyword If    ${whether_check_on_air}    Verify TMO Gnb Ready And All Cell On Air
    Run Keyword If    ${whether_do_ue_prepare}    Procedures.Start UE Prepare    ue_index=${ue_index}
    Run Keyword If    ${whether_need_ue_log}    Run Keyword And Continue On Failure
    ...    Spark_common_keywords.Spark Start UE Log    ue_index=${ue_index}
    ${attach_info}    Procedures.Start TMO Attach    ue_mode=${ue_mode}    ue_index=${ue_index}
    Run Keyword And Continue On Failure    Should Be Equal As Integers    ${attach_info['attach_cell_index']}    ${notbarred_cell_index}
    ${addition_scell_index_list}    Run Keyword If    ${whether_check_scell_addition}
    ...    Run Keyword And Continue On Failure    Procedures.Check TMO Scell Addition    attach_info=${attach_info}
    ...                                                                                  ue_mode=${ue_mode}
    ...                                                                                  expect_addition_scell_pci_list=${SCELL_PCI_LIST}
    ...                                                                                  scell_addition_method=${scell_addition_method}
    Run Keyword If    ${whether_check_scell_addition}    Run Keyword And Continue On Failure
    ...    Lists Should Be Equal    ${addition_scell_index_list}    ${SCELL_INDEX_LIST}
    Procedures.Start TMO L3 Call    ue_mode=${ue_mode}
    ...                             ue_index=${ue_index}
    ...                             start_keep_on_duration=${start_keep_on_duration}
    ...                             ul_throughput=${ul_throughput}
    ...                             dl_throughput=${dl_throughput}
    ...                             apn_address=${apn_address}
    Run Keyword If    ${whether_check_tupt}    Procedures.Check TMO Throughput    ue_index=${ue_index}
    ...                                                                           addition_scell_index_list=${addition_scell_index_list}
    ...                                                                           tput_collect_duration=${tput_collect_duration}
    ...                                                                           expect_tp_percent=${expect_tp_percent}
    ...                                                                           ignore_time=${ignore_time}
    [Teardown]    Run Keyword If    ${whether_need_ue_log}    Run Keyword And Ignore Error
    ...    Spark_common_keywords.Spark Stop UE Log    ue_index=${ue_index}


#--- Common keywords for L3 Call---#
Procedures.Start UE Prepare
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Spark_common_keywords.Start Prepare UE    ue_index=${ue_index}

Procedures.Start TMO Attach
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${wireshark_log_prefix}=cpif_attach    ${ue_mode}=SA
    ...            ${coam_connection}=GNB_OAM
    ...            ${ue_index}=${0}    ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    Run Keyword And Ignore Error    Spark_common_keywords.Start UE Detach    ue_index=${ue_index}
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=${wireshark_log_prefix}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38422)))' -s 0
    Log To Console    ${\n}INFO:-- start to attach --
    ${attach_status}    Run Keyword And Return Status    Spark_common_keywords.Start UE Attach And Enable Data Service    ue_index=${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    5sec
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${wireshark_log_prefix}
    run keyword if  not ${attach_status}    Fail    msg=attach failed!!!
    ${attach_cell_index}    Get Attach Cell Index From Wireshark    cpif_log_path=${cpif_attach_log_on_testPC}
    ...                                                             connection=${coam_connection}
    ...                                                             gnb_index=${gnb_index}
    ...                                                             mode=${ue_mode}
    ${attach_info}    Create Dictionary    cpif_log_path=${cpif_attach_log_on_testPC}    attach_cell_index=${attach_cell_index}
    [Return]    ${attach_info}
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    core.stop_collectors    names=${wireshark_log_prefix}    AND
    ...                           Run Keyword And Ignore Error    core.teardown_collectors    names=${wireshark_log_prefix}

Procedures.Check TMO Scell Addition
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${attach_info}
    ...            ${ue_mode}=SA
    ...            ${expect_addition_scell_pci_list}=${None}
    ...            ${scell_addition_method}=A1
    Log To Console    ${\n}INFO:-- start to check scell addition --
    ${addition_scell_index_list}    Run Keyword If    '${scell_addition_method}'=='A1'
    ...                                               Message_Flow_Check.A1 Addition Process
    ...                                               addition_cpif_log_path=${attach_info['cpif_log_path']}
    ...                                               mode=${ue_mode}
    ...                                               expect_addition_scell_pci_list=${expect_addition_scell_pci_list}
    ...    ELSE    Check Scell Addition Success    cpif_log_path=${attach_info['cpif_log_path']}
    ...                                            mode=${ue_mode}
    ...                                            expect_addition_scell_pci_list=${expect_addition_scell_pci_list}
    [Return]    ${addition_scell_index_list}

Procedures.Start TMO L3 Call
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_mode}=SA    ${ue_index}=${0}    ${apn_address}=${tl.core.pdns[0].apn}
    ...            ${ul_throughput}=150M    ${dl_throughput}=2500MKbits/sec    ${start_keep_on_duration}=1200
    ...            ${buffer_size}=1400B    ${appserver}=APPserver    ${protocol}=udp    ${iperf_path}=iperf
    Log To Console    ${\n}INFO:-- start to L3 call --
    Run Keyword And Continue On Failure    Spark_common_keywords.Start DL Traffic    dl_throughput=${dl_throughput}
    ...                                                                              duration=${start_keep_on_duration}
    ...                                                                              apn_address=${apn_address}
    ...                                                                              ue_mode=${ue_mode}
    ...                                                                              ue_index=${ue_index}
    ${ue_ul_port}    Set Variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Set Test Variable    ${UL_PORT}    ${ue_ul_port}
    traffic_via_iperf.Start UL traffic via iperf from andriod UE    ue_index=${ue_index}
    ...                                                             ul_time=${start_keep_on_duration}
    ...                                                             ul_port=${UL_PORT}
    ...                                                             ul_throughput=${ul_throughput}
    ...                                                             ul_length=${buffer_size}
    ...                                                             appserver=${appserver}
    ...                                                             protocol=${protocol}
    ...                                                             iperf_path=${iperf_path}

Procedures.Collect the Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    [Arguments]     ${ue_type}    ${tput_collect_duration}=180    ${ue_index}=${0}
    ...             ${gnb_index}=0    ${du_index}=0    ${ignore_time}=1min    ${check_source}=aasyslog
    Log To Console    ${\n}INFO:-- start to collect tupt --
    ${tput_file}    power_ue.Collect Tput    ue_type=${ue_type}
    ...                                      gnb_index=${gnb_index}
    ...                                      du_index=${du_index}
    ...                                      duration=${tput_collect_duration}
    ...                                      ignore_time=${ignore_time}
    ...                                      ue_index=${ue_index}
    ...                                      check_source=${check_source}
    [Return]    ${tput_file}

Procedures.Check TMO Throughput
    [Documentation]   jun.8.chen@nokia-sbell.com
    ...               If ${whether_collect_tput}=${False}, the parameter ${tput_file_use_collested} must not be ${None}
    ...               Need to collect tput first, then set the vlaue of ${tput_file_use_collested} is the existed file.
    [Arguments]    ${gnb_index}=${0}    ${addition_scell_index_list}=${None}
    ...            ${tput_collect_duration}=300    ${check_pcell_tput_type}=peak    ${check_scell_tput_type}=peak
    ...            ${target_DL_avg_percent}=0.9    ${target_UL_avg_percent}=0.9    ${check_ul_pcell_tput_type}=peak
    ...            ${min_DL_percent}=0.85    ${min_UL_percent}=0.85    ${expect_tp_percent}=1
    ...            ${pcell_mapping}=${PCELL_MAPPING}    ${scell_mapping}=${SCELL_MAPPING}
    ...            ${whether_collect_tput}=${True}    ${tput_file_use_collected}=${None}
    ...            ${check_source}=aasyslog    ${ignore_time}=1min
    Log To Console    ${\n}INFO:-- start to check CA tupt --
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        gnb_index=${gnb_index}
    ...                        duration=${tput_collect_duration}
    ...                        addition_scell_index_list=${addition_scell_index_list}
    ...                        check_pcell_tput_type=${check_pcell_tput_type}
    ...                        check_scell_tput_type=${check_scell_tput_type}
    ...                        target_DL_avg_percent=${target_DL_avg_percent}
    ...                        target_UL_avg_percent=${target_UL_avg_percent}
    ...                        min_DL_percent=${min_DL_percent}
    ...                        min_UL_percent=${min_UL_percent}
    ...                        expect_tp_percent=${expect_tp_percent}
    ...                        check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...                        pcell_mapping=${pcell_mapping}
    ...                        scell_mapping=${scell_mapping}
    ...                        whether_collect_tput=${whether_collect_tput}
    ...                        tput_file_use_collected=${tput_file_use_collected}
    ...                        check_source=${check_source}
    ...                        ignore_time=${ignore_time}

Procedures.Stop TMO L3 Call And Detach
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${tl.ues[${ue_index}].iperf_details.port}
    Run Keyword And Ignore Error    Spark_common_keywords.Start UE Detach    ue_index=${ue_index}


#--- Common keywords for Spark Tupt via mac tp---#
Check Tupt Via Spark App
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                :Param:sleep_time---get tupt via keyword "get_mac_tp" every one sec.
    ...                :Param:get_times---how many times do get tupt via keyword "get_mac_tp"
    [Arguments]    ${ue_index}=${0}    ${ue_alias}=UE_${ue_index}    ${sleep_time}=1sec    ${get_times}=180
    ${ul_tupt_list}    Create List
    ${dl_tupt_list}    Create List
    FOR    ${i}    IN RANGE    ${get_times}
        ${tupt}    spark.check_throughput_on_ue    ue_alias=${ue_alias}
        Append To List    ${ul_tupt_list}    ${tupt[0]}
        Append To List    ${dl_tupt_list}    ${tupt[1]}
        Sleep    ${sleep_time}
    END
    ${ul_tupt_avg}    Evaluate    (sum(${ul_tupt_list})/len(${ul_tupt_list}))/1000/1000
    ${dl_tupt_avg}    Evaluate    (sum(${dl_tupt_list})/len(${dl_tupt_list}))/1000/1000
    ${avg_tupt}    Create List    ${ul_tupt_avg}    ${dl_tupt_avg}
    [Return]    ${avg_tupt}


#--- Common keywords for Cases---#
Start To Capture Aasyslog
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU
    ...            ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738
    ...            ${filter}=${EMPTY}    ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   aasyslog.Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                             host=${host}    username=${username}    password=${password}
    aasyslog.Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                               aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                               host=${host}    username=${username}    password=${password}
    aasyslog.Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                          gnb_path=${gnb_path}    log_name=${log_name}
    ...                                          host=${host}    username=${username}    password=${password}
    ...                                          log_ip=${log_ip}    timeout=${duration}
    [Return]    ${host}

Stop To Capture And Download Aasyslog
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${host}    ${gnb_index}=0    ${du_index}=0    ${Teardown_after_finished}=${True}
    ...            ${gnb_path}=/tmp/    ${log_name}=Aasys_CCS_MCU.txt
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    aasyslog.Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                         gnb_index=${gnb_index}    du_index=${du_index}
    ...                                         host=${host}    username=${username}    password=${password}
    [Return]    ${local_path}
    [Teardown]    Run Keyword If    '${Teardown_after_finished}'=='${True}'
    ...           aasyslog.Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                           host=${host}    username=${username}    password=${password}

Start UE Attach And Check Ciphering Algorithm
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cipheringAlgorithm}=2
    ...            ${wireshark_log_prefix}=cpif_attach
    ...            ${gnb_index}=${0}
    ...            ${asik_connection_alias}=ASIK Master
    ...            ${connection}=GNB_OAM
    ...            ${ue_index}=${0}
    ...            ${filter}=e1ap||f1ap||ngap||nr-rrc||xnap
    ...            ${alias}=parser
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Run Keyword And Ignore Error    Spark_common_keywords.Start UE Detach    ue_index=${ue_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Run Keyword And Continue On Failure    Start CP-IF Log Collection     tcpdump_collector_name=${wireshark_log_prefix}
    ...    asik_connection_alias=${asik_connection_alias}
    ...    gnb_index=${gnb_index}
    ...    options=-i any '((sctp) and ((port 38472) or (port 38412) or (port 38422)))' -s 0
    Bip Capture with gnbMirroring scripts with retry    syscom_mirroring=false    bb_slot_1=false    bb_slot_5=true
    Log To Console    ${\n}INFO:-- start to attach --
    ${attach_status}    Run Keyword And Return Status    Spark_common_keywords.Start UE Attach And Enable Data Service
    ...    ue_index=${ue_index}
    ${attach_time}    DateTime.Get Current Date    result_format=%Y-%m-%d%H:%M:%S
    Sleep    5sec
    ${bip_log_list}    Run Keyword And Continue On Failure
    ...    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_prefix=bip_log
    ...                                                                          asil_interface=nac_eth2
    ${cpif_attach_log_on_testPC}    Run Keyword And Continue On Failure    Stop tcpdump log collection
    ...    tcpdump_collector_name=${wireshark_log_prefix}
    Convert CPIF Pcap To Pdml    file_path=${cpif_attach_log_on_testPC}    filter=${filter}    alias=${alias}
    Filter Packets By Expression    filter_expression=nr-rrc.cipheringAlgorithm==${cipheringAlgorithm}   pcap_parser=${alias}
    ${values}    pcap.get_field_value_by_name    field_name=nr-rrc.cipheringAlgorithm    pcap_parser=${alias}
    Should Not Be Empty    ${values}
    run keyword if  not ${attach_status}    Fail    msg=attach failed!!!
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Connect and save snapshot for enb
    [Arguments]    ${connection}=enb     ${enb_index}=${0}
    Connect to eNB via ssl    connection=${connection}_${enb_index}     enb_index=${enb_index}
    COAM Save snapshot via rest api    connection=${connection}_${enb_index}    timeout=900
    [Teardown]    coam.teardown    connection=${connection}_${enb_index}
