*** Settings ***
Documentation    This is for some action of ca.
...              Please do not modify the file without notification to author
...              Author: jun.8.chen@nokia-sbell.com


*** Keywords ***
Change cellBarred Parameter Value On Gnb
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...    Keep only Pcell to notBarred status, and set all other cells to barred status, just for 5G cell
    ...    step1: get pcell id and scell id from current configuration.
    ...    step2: bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${pcell_index}    ${exp_status}=notBarred    ${connection}=GNB_OAM    ${gnb_id}=${0}    ${timeout}=${600}
    ${pcell_index_type}    Evaluate    type(${pcell_index}).__name__
    @{convert_pcell_list}    Create List    ${pcell_index}
    ${expected_pcell_list}    Set Variable If    'list' in '${pcell_index_type}'    ${pcell_index}    ${convert_pcell_list}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    Change status for parameter cellBarred on GNB    exp_status=${exp_status}
    ...                                              list_cell_ids=${expected_pcell_list}
    ...                                              connection=${connection}
    ...                                              gnb_index=${gnb_id}
    ...                                              timeout=${timeout}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Change cellBarred Parameter Value Of Lte Cells
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...    Keep only Pcell to notBarred status, and set all other cells to barred status, just for 4G cell
    ...    bar all other cells, and set pcell notbarred before ue attach
    [Arguments]    ${exp_status}=notBarred    ${list_cell_ids}=all    ${cell_type}=lte    ${timeout}=${600}
    ...            ${gnb_id}=${0}    ${gnb_connection}=GNB_OAM    ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${4g_whether_in_gnb}    Check LTE Whether In Gnb    gnb_id=${gnb_id}    gnb_connection=${gnb_connection}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
    Run Keyword If    ${4g_whether_in_gnb}==${False}
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${4g_whether_in_gnb}==${False}    ${enb_connection}    ${gnb_connection}
    ${cell_info}   coam.get_cells_info    cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    &{cell_list_info}    Create Dictionary
    FOR    ${item}    IN    @{cell_info}
        Set To Dictionary    ${cell_list_info}    ${item['id']['configuration']}=${item['status']}
    END
    ${cell_list}    Get Dictionary Keys    ${cell_list_info}
    @{all_cell_ids}    Create List
    FOR    ${cell}    IN    @{cell_list}
        ${cell_idx}    Set Variable    ${cell.split('-')[-1]}
        Append To List    ${all_cell_ids}    ${cell_idx}
    END
    ${mrbts_id}    Set Variable    ${cell_list[0].split('/')[0].split('-')[-1]}
    ${lnbts_id}    Set Variable    ${cell_list[0].split('/')[1].split('-')[-1]}
    ${is_all_cellls_entered}    Run Keyword And Return Status    Should contain    ${list_cell_ids}    all
    ${list_cell_ids}    Set Variable If    ${is_all_cellls_entered}    ${all_cell_ids}    ${list_cell_ids}
    ${list_cell_ids}    Convert Data Type To A List    input_data=${list_cell_ids}
    ${all_cell_ids}    Evaluate    list(map(lambda x: int(x), ${all_cell_ids}))
    ${list_cell_ids}    Evaluate    list(map(lambda x: int(x), ${list_cell_ids}))
    ${rest_cell_ids}    Evaluate    list(set(${all_cell_ids})-set(${list_cell_ids}))
    ${rest_cell_barred_status}    Set Variable If    '${exp_status}'=='barred'    notBarred    barred
    @{params_for_update}    Create List
    Log To Console    ${\n}Change status to ${exp_status} for expected cells: ${list_cell_ids}
    FOR    ${cell_index}    IN    @{list_cell_ids}
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${cell_index}/SIB-0
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${exp_status}
        Append To List    ${params_for_update}    ${param}
    END
    Log To Console    ${\n}Change status to ${rest_cell_barred_status} for rest cells: ${rest_cell_ids} on GNB: ${gnb_id}
    FOR    ${cell_index}    IN    @{rest_cell_ids}
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${cell_index}/SIB-0
        ${param}    Create Dictionary    dist_name=${dist_name}    parameter=cellBarred    value=${rest_cell_barred_status}
        Append To List    ${params_for_update}    ${param}
    END
    Log To Console    ${\n}Parameters for update cellBarred status are: ${params_for_update}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${params_for_update}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}   AND
    ...    Run Keyword If    ${4g_whether_in_gnb}==${False}
    ...                          Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Update Param b1ThresholdNrRsrp Value In ENDCDMEASCONF
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Update the b1ThresholdNrRsrp in ENDCDMEASCONF
    [Arguments]    ${b1ThresholdNrRsrp_value}=-50
    ...            ${class_name}=ENDCDMEASCONF_A    ${timeout}=300
    ...            ${gnb_connection}=GNB_OAM    ${gnb_index}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${LTE_WHETHER_IN_GNB}     Check LTE Whether In Gnb
    ${enb_length}    Get Length    ${tl.enbs}
    ${b1ThresholdNrRsrp_value}    Evaluate    ${b1ThresholdNrRsrp_value}+156
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${MOs}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}    timeout=${timeout}
    @{param_list}    Create List
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${lnbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrdcdpr_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${endcdmeasconf_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/NRDCDPR-${nrdcdpr_id}/ENDCDMEASCONF-${endcdmeasconf_id}
        ${b1ThresholdNrRsrp}    Create Dictionary    dist_name=${dist_name}    parameter=b1ThresholdNrRsrp    value=${b1ThresholdNrRsrp_value}
        Append To List    ${param_list}    ${b1ThresholdNrRsrp}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
	[Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}
	...                   AND    Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Update Target Param b1ThresholdNrRsrp Value In ENDCDMEASCONF
    [Documentation]    Author: tingting.1.liu@nokia-sbell.com
    ...                Update the b1ThresholdNrRsrp in ENDCDMEASCONF
    [Arguments]    ${cell_index}=None
    ...            ${b1ThresholdNrRsrp_value}=-114
    ...            ${class_name}=ENDCDMEASCONF_A    ${timeout}=300
    ...            ${gnb_connection}=GNB_OAM    ${gnb_index}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${LTE_WHETHER_IN_GNB}     Check LTE Whether In Gnb
    ${b1ThresholdNrRsrp_value}    Evaluate    ${b1ThresholdNrRsrp_value}+156
#    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${cell_index}    gnb_index=${gnb_index}    timeout=${timeout}
    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell Via Rest Api    cell_index=${cell_index}    gnb_index=${gnb_index}
    ${enb_length}    Get Length    ${tl.enbs}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${MOs}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}    timeout=${timeout}
    @{param_list}    Create List
    ${b1ThresholdNrRsrp}    Create Dictionary
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${lnbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrdcdpr_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${endcdmeasconf_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${carrierFreqNrCell}    Set Variable    ${mo['parameters']['carrierFreqNrCell']}
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/NRDCDPR-${nrdcdpr_id}/ENDCDMEASCONF-${endcdmeasconf_id}
        Run Keyword If     '${carrierFreqNrCell}'=='${arfcnSsbPbch}'     Set To Dictionary     ${b1ThresholdNrRsrp}
        ...    dist_name=${dist_name}    parameter=b1ThresholdNrRsrp    value=${b1ThresholdNrRsrp_value}
        Append To List    ${param_list}    ${b1ThresholdNrRsrp}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
	[Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}
	...                   AND    Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Update Priority Of NR Frequency Band In ENDCDMEASCONF
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    ...                Modify the mapping b1ThresholdNrRsrp of pcell is -114, other is -40
    ...                b1ThresholdNrRsrp=-114 is the higher the frequency band priority
    [Arguments]    ${cell_index}    ${b1_value}=-114
    ...            ${class_name}=ENDCDMEASCONF_A    ${timeout}=300
    ...            ${gnb_connection}=GNB_OAM    ${gnb_index}=0
    ...            ${enb_index}=${1}    ${enb_connection}=enblte_${enb_index}
    ${LTE_WHETHER_IN_GNB}     Check LTE Whether In Gnb
#    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell    cell_index=${cell_index}    gnb_index=${gnb_index}    timeout=${timeout}
    ${arfcnSsbPbch}    Get The ArfcnSsbPbch Value Of Cell Via Rest Api    cell_index=${cell_index}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_index}
    ${enb_length}    Get Length    ${tl.enbs}
    Run Keyword If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    Wait Until Keyword Succeeds    1 min    5 sec    Connect to eNB via ssl    enb_index=${enb_index}    connection=${enb_connection}
    ${connection}    Set Variable If    ${LTE_WHETHER_IN_GNB}==${False} and '${enb_length}'!='${0}'
    ...    ${enb_connection}    ${gnb_connection}
    ${MOs}    coam.get_managed_objects    class_name=${class_name}    connection=${connection}    timeout=${timeout}
    @{param_list}    Create List
    FOR    ${mo}    IN    @{MOs}
        ${mrbts_id}    Set Variable    ${mo['distName'].split('/')[-4].split('-')[-1]}
        ${lnbts_id}    Set Variable    ${mo['distName'].split('/')[-3].split('-')[-1]}
        ${nrdcdpr_id}    Set Variable    ${mo['distName'].split('/')[-2].split('-')[-1]}
        ${endcdmeasconf_id}    Set Variable    ${mo['distName'].split('/')[-1].split('-')[-1]}
        ${carrierFreqNrCell}    Set Variable    ${mo['parameters']['carrierFreqNrCell']}
        ${value}    Set Variable If    '${carrierFreqNrCell}'=='${arfcnSsbPbch}'    ${b1_value}    -40
        ${b1ThresholdNrRsrp_value}    Evaluate    ${value}+156
        ${dist_name}    Set Variable    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/NRDCDPR-${nrdcdpr_id}/ENDCDMEASCONF-${endcdmeasconf_id}
        ${b1ThresholdNrRsrp}    Create Dictionary    dist_name=${dist_name}    parameter=b1ThresholdNrRsrp    value=${b1ThresholdNrRsrp_value}
        Append To List    ${param_list}    ${b1ThresholdNrRsrp}
    END
    COAM Update several parameters via rest api    parameters_to_update_via_api=${param_list}    connection=${connection}    timeout=${timeout}
	[Teardown]    Run Keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}
	...                   AND    Run Keyword And Ignore Error    Enblte close down    connection=${enb_connection}

Get The ArfcnSsbPbch Value Of Cell
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}    ${gnb_index}=${0}    ${timeout}=300
    Wait Until Keyword Succeeds    5 min    5 sec    COAM Navigate to login page via webUI    gnb_index=${gnb_index}
    ...                                                                                       timeout=${timeout}
    ${arfcnSsbPbch}    selenium_coam.get_parameter_value
    ...    dist_name=MRBTS-${tl.gnbs[${gnb_index}].instance_id}/NRBTS-${tl.gnbs[${gnb_index}].global_bts_id}/NRCELL-${cell_index}
	...    abbr=arfcnSsbPbch
	...    filter_param=Absolute radio frequency channel number of SSB PBCH
	...    timeout=${timeout}
	[Return]    ${arfcnSsbPbch}
    [Teardown]    Run Keyword And Ignore Error    COAM selenium logout

Get The ArfcnSsbPbch Value Of Cell Via Rest Api
    [Documentation]    Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}=301    ${gnb_index}=0    ${timeout}=20 min    ${connection}=GNB_OAM_for_get
    Wait Until Keyword Succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    @{MOs}    coam.get_managed_objects    class_name=NRCELL_R    connection=${connection}
    FOR    ${mo}    IN    @{MOs}
        ${nrcell_id}    Set Variable    ${mo['distName'].split('/')[-1]}
        Run Keyword If    '${nrcell_id}'=='NRCELL_R-${cell_index}'
        ...    Run Keywords    Set Test Variable    ${arfcnSsbPbch}    ${mo['parameters']['arfcnSsbPbch']}    AND    Exit For Loop
    END
    [Return]    ${arfcnSsbPbch}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check LTE Whether In Gnb
    [Arguments]    ${gnb_id}=0    ${gnb_connection}=GNB_OAM
    Log to console    ${\n}----Check lte Whether In Gnb----
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl    connection=${gnb_connection}    gnb_index=${gnb_id}
	${output}    coam.get_bts_info    connection=${gnb_connection}
    ${value}    Get From Dictionary    ${output['ratState']}    lte
    ${lte_whether_in_gnb}    Set Variable If    '${value}' != 'NO_CELLS'    ${True}    ${False}
    [Return]    ${lte_whether_in_gnb}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${gnb_connection}

CACaseSetup.Common Initialization
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${ue_index}=0
    ...            ${running_gnb}=0
    ...            ${specific_testcase_id}=${None}
    ...            ${extract_testcase_id_from_testcase_name}=${True}
    ...            ${extract_index}=1:3
    ...            ${specific_scf_file_path}=${None}
    ...            ${specific_scf_file_path_for_target_gnb}=${None}
    ...            ${handover_gnb_type}=${None}
    ...            ${extract_case_info_from_data_file}=${False}
    ...            ${specific_update_params_dict}=&{EMPTY}
    ...            ${specific_update_params_dict_for_target_gnb}=&{EMPTY}
    ...            ${is_all_pa_port_need_to_set}=${False}
    ...            ${specific_ru_pa_port_on}=${None}
    ...            ${initial_pcell_pa_value}=${None}
    ...            ${initial_scell_pa_value}=${None}
    ...            ${TESTCASE_INFO_MAPPING_TABLE}=${None}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Set Test Variable    ${ue_type}
    Log to console    ue index is ${ue_index} , ue type is ${ue_type}
    ${tl_prefix}    Set Variable    ${testline_name.split('_')[-1][-4:]}
    Set Test Variable    ${TL_NAME}    ${tl_prefix}
    Log to console    testline is ${TL_NAME}
    ${test_case_id}    Run Keyword If    ${extract_testcase_id_from_testcase_name}    Evaluate
    ...    '_'.join(${TEST NAME.split('_')[${extract_index}]})
    ${test_case_id}    Set Variable If    '${specific_testcase_id}'!='${None}'     ${specific_testcase_id}    ${test_case_id}
    Set Test Variable    ${TESTCASE_ID}    ${test_case_id}
    ${running_gnb}    Set Variable If    ${extract_case_info_from_data_file}
    ...    ${TESTCASE_INFO_MAPPING_TABLE['${TESTCASE_ID}']['${tl_prefix}']['running_gnb']}
    ...    ${running_gnb}
    Set Test Variable    ${RUNNING_GNB_ID}    ${running_gnb}
    Log to console    running gnb is: gnb${RUNNING_GNB_ID}
    ${scf_file_path}    Set Variable If    '${specific_scf_file_path}'=='${None}'
    ...                                    /home/ute/SCF/GNB${RUNNING_GNB_ID}_BASIC_GOLDEN_SCF_${STREAM_VERSION}.xml
    ...                                    ${specific_scf_file_path}
    Log to console    commission scf file path is : ${scf_file_path}
    ${case_update_params_dict}   Set Variable If    ${extract_case_info_from_data_file}
    ...    ${TESTCASE_INFO_MAPPING_TABLE['${TESTCASE_ID}']['${tl_prefix}']}
    ...    ${specific_update_params_dict}
    Log to console    update params:${case_update_params_dict}
#    COAM Create log directory
    Common_setup_and_teardown.Case Common SetUp   gnb_index=${RUNNING_GNB_ID}
    ...                                           update_param_name=${case_update_params_dict}
    ...                                           scf_file_path=${scf_file_path}
    ${target_gnb_id}    Set Variable If    ${RUNNING_GNB_ID}==${0}    1    0
    ${target_scf_file_path}    Set Variable If    '${specific_scf_file_path_for_target_gnb}'=='${None}'
    ...                                           /home/ute/SCF/GNB${target_gnb_id}_BASIC_GOLDEN_SCF_${stream_version}.xml
    ...                                           ${specific_scf_file_path_for_target_gnb}
    ${is_commission_for_second_gnb}    Set Variable If    '${handover_gnb_type}'=='Inter'    ${True}    ${False}
    ${target_case_update_params_dict}   Set Variable If     ${is_commission_for_second_gnb}
    ...    ${TESTCASE_INFO_MAPPING_TABLE_HO_GNB['${TESTCASE_ID}']['${tl_prefix}']}
    ...    ${specific_update_params_dict_for_target_gnb}
    Log to console    update params for target gnb:${target_case_update_params_dict}
    run keyword if    ${is_commission_for_second_gnb}    Common_setup_and_teardown.Case Common SetUp
    ...                                                  gnb_index=${target_gnb_id}
    ...                                                  scf_file_path=${target_scf_file_path}
    ...                                                  update_param_name=${target_case_update_params_dict}
    Connect To Multi gNb Coam
    mbca.set_gnb_id    value=${RUNNING_GNB_ID}
    mbca.set_gnb_operation_object
    ${all_neighbor_cell_config_info}    mbca.get_all_neighbor_cell_config_info
    Run Keyword If    ${is_all_pa_port_need_to_set}    Initial PA Value Setting For Required RU    gnb_id=${RUNNING_GNB_ID}
    ...                                                                                            all_ru_need_to_modify=${True}
    ...    ELSE IF    ${specific_ru_pa_port_on}!=${None}    Initial PA Value Setting For Required RU
    ...                                                         modify_ru_id=${specific_ru_pa_port_on}
    ...    ELSE    Initial PA Port Up For Basic Case
    ...    pcell_index=${TESTCASE_INFO_MAPPING_TABLE['${TESTCASE_ID}']['${tl_prefix}']['pcell_index']}
    ...    source_gnb_id=${RUNNING_GNB_ID}
    ...    initial_pcell_pa_value=${initial_pcell_pa_value}
    ...    initial_scell_pa_value=${initial_scell_pa_value}
    Run Keyword If    '${is_all_pa_port_need_to_set}'=='${False}'
    ...               Change status for parameter cellBarred on GNB
    ...               exp_status=notBarred
    ...               list_cell_ids=${TESTCASE_INFO_MAPPING_TABLE['${TESTCASE_ID}']['${tl_prefix}']['pcell_index']}
    ...               connection=GNB_OAM${RUNNING_GNB_ID}
    ...               gnb_index=${RUNNING_GNB_ID}
    ...               timeout=300
    [Teardown]    Teardown Multi gNb Connections