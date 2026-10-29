*** Settings ***
Documentation
...  authors: Mateusz Bugaj, Pawel Grabania
...  contact: mateusz.bugaj@nokia.com, pawel.grabania@nokia.com

Library      taf.rfrl.utilities.logger.custom_logger                                                 WITH NAME    logger
Library      testsuite/Krakow/resources/RAN_VRF_KRK5/python/call_procedure/attenuator_operations.py
Library      testsuite/Krakow/resources/RAN_VRF_KRK5/python/call_procedure/bts_operations.py
Library      testsuite/Krakow/resources/RAN_VRF_KRK5/python/call_procedure/common_operations.py
Library      testsuite/Krakow/resources/RAN_VRF_KRK5/python/call_procedure/html_thput_table.py
Library      testsuite/Krakow/resources/RAN_VRF_KRK5/python/call_procedure/html_thput_graphs.py
Library      testsuite/Krakow/resources/RAN_VRF_KRK5/python/call_procedure/ue_proxy.py

*** Variables ***
${ue_operation_library}
...    testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.ue_operations.UeOperations

*** Keywords ***
Load ue_operations library
    [Arguments]    ${library_path}
    ${ue_operation_library}=    Set Variable If     '${library_path}'!='${None}'    ${library_path}
    ...    ${ue_operation_library}
    Import Library    ${ue_operation_library}    WITH NAME    ue_operations

Call To Selected Cells
    [Arguments]    ${cells_list}    ${duration}    ${traffic_matrix}    ${ue_capabilities}    ${deviation}=${None}
    ...            ${alias}=UE    ${run_num}=1    ${recall}=${True}    ${additional_action}=${None}
    ...            ${additional_action_params}=${None}    ${prepare_ue}=${True}    ${reboot_ue}=${True}
    ...            ${bidirect}=${False}    ${library_path}=${None}
    [Documentation]    Main keyword to perform call in cells listed in cells_list.
    ...    param cells_list: list of cells where call should be performed
    ...    param duration: duration of each call
    ...    param traffic_matrix: dictionary with parameters needed to perform call in cells defined in cells_list,
    ...                          example of dictionary located in
    ...                          testsuite/Krakow/resources/RAN_VRF_KRK5/examples/call_procedure/call_variables.py
    ...    param ue_capabilities: ue capabilities
    ...    param deviation: percentage of deviation for tput, e.g. 5%, if not specified 20% is used for LTE cells or
    ...                     40% for NR cells
    ...    param alias: ue alias
    ...    param run_num: iteration number of call
    ...    param recall: flag if recall in failed cells should be performed
    ...    param additional_action: dictionary with optional functions which should be performed before/during/after
    ...                             each call, contact KW authors for more details
    ...    param additional_action_params: dictionary with optional parameters for functions which should be
    ...                                    performed before/during/after each call, contact KW authors for more details
    ...    param prepare_ue: flag if ue should be prepared before calls are performed
    ...    param reboot_ue: flag if ue reboot should be performed during ue preparation
    ...    param bidirect: flag if bidirect throughput should be run during call
    ...    library_path: path to module with modified UeOperations class

    common_operations.traffic matrix validator    traffic_matrix=${traffic_matrix}    cells_list=${cells_list}
    ...                                           bidirect=${bidirect}

    Load ue_operations library    library_path=${library_path}
    Run Keyword If    '${library_path}'=='${None}'
    ...    Should Be True   '${additional_action}'=='${None}'
    ...       Contact KW owner because you have to add handling of additional action in `ue_operations` class
    ${raise_errors}=    Set Variable If      ${recall}==${True}    ${False}    ${True}

    Call Procedure    cells_list=${cells_list}    duration=${duration}    traffic_matrix=${traffic_matrix}
    ...               ue_capabilities=${ue_capabilities}    deviation=${deviation}    alias=${alias}
    ...               run_num=${run_num}    rerun=${False}    raise_errors=${raise_errors}
    ...               additional_action=${additional_action}    additional_action_params=${additional_action_params}
    ...               prepare_ue=${prepare_ue}    reboot_ue=${reboot_ue}    bidirect=${bidirect}

    ${recall}=    ue_operations.check_if_need_recall    recall=${recall}
    ${failed_cells}=    ue_operations.get_failed_cells_list
    Run Keyword If    ${recall}==${True}
    ...    Call Procedure    cells_list=${failed_cells}    duration=${duration}    traffic_matrix=${traffic_matrix}
    ...                      ue_capabilities=${ue_capabilities}    deviation=${deviation}    alias=${alias}
    ...                      run_num=${run_num}    rerun=${True}    raise_errors=${True}
    ...                      additional_action=${additional_action}
    ...                      additional_action_params=${additional_action_params}    prepare_ue=${prepare_ue}
    ...                      reboot_ue=${reboot_ue}    bidirect=${bidirect}    clear_data=failed_cells

    ${failed_cells}=    ue_operations.get_failed_cells_list
    ${cell_counter}=    Get length    ${failed_cells}
    Run Keyword If    ${cell_counter} > ${0}
    ...    logger.log_warn_to_console    Cells where throughput failed: ${failed_cells}
    ...    ELSE IF    ${recall}==${True}
    ...        logger.log_info_to_console    *********** All retest calls were PASSED !!! ***********

    Collect data transfer stats    run_num=${run_num}

Perform Call Without Cell Preparation
    [Arguments]    ${cell}    ${duration}    ${traffic_matrix}    ${ue_capabilities}    ${deviation}=${None}
    ...            ${alias}=UE    ${nr_of_iterations}=${1}    ${raise_errors}=${True}    ${prepare_ue}=${True}
    ...            ${reboot_ue}=${False}    ${bidirect}=${False}
    [Documentation]    Keyword to perform call in specific cell without any BTS and attenuator preparation.
    ...    param cell: cell where call should be performed
    ...    param duration: duration of call
    ...    param traffic_matrix: dictionary with parameters needed to perform call
    ...    param ue_capabilities: ue capabilities
    ...    param deviation: percentage of deviation for tput, e.g. 5%, if not specified 20% is used for LTE cells or
    ...                     40% for NR cells
    ...    param alias: ue alias
    ...    param nr_of_iterations: number of call iterations
    ...    param prepare_ue: flag if ue should be prepared before calls are performed
    ...    param reboot_ue: flag if ue reboot should be performed during ue preparation
    ...    param bidirect: flag if bidirect throughput should be run during call

    Load ue_operations library    library_path=${None}
    ${cells_list}    Create List   @{EMPTY}
    Repeat Keyword    ${nr_of_iterations} times
    ...    Append To List    ${cells_list}    ${cell}
    Call Procedure    cells_list=${cells_list}    duration=${duration}    traffic_matrix=${traffic_matrix}
    ...               ue_capabilities=${ue_capabilities}    deviation=${deviation}    alias=${alias}
    ...               rerun=${False}    raise_errors=${raise_errors}    prepare_ue=${prepare_ue}
    ...               reboot_ue=${reboot_ue}    prepare_bts=${False}    bidirect=${bidirect}
    Collect data transfer stats

Call Procedure
    [Arguments]    ${cells_list}    ${duration}    ${traffic_matrix}    ${ue_capabilities}    ${deviation}=${None}
    ...            ${alias}=UE    ${run_num}=1    ${rerun}=${False}    ${raise_errors}=${True}
    ...            ${additional_action}=${None}    ${additional_action_params}=${None}    ${prepare_ue}=${True}
    ...            ${reboot_ue}=${False}    ${prepare_bts}=${True}    ${bidirect}=${False}    ${clear_data}=all

    Run Keyword If    ${prepare_bts}==${True}
    ...    Prepare Setup Before Call Procedure    traffic_matrix=${traffic_matrix}

    Run Keyword If    ${prepare_ue}==${True}
    ...    ue_operations.prepare_ue_for_test    alias=${alias}    ue_capabilities=${ue_capabilities}
    ...                                         reboot_ue=${reboot_ue}    clear_data=${clear_data}

    Run Keyword If    ${rerun}==${True}
    ...    ue_operations.clear_failed_cells_list

    FOR    ${cell}    IN    @{cells_list}
        Run Keyword If    ${rerun}==${True}
        ...    logger.log_info_to_console    *** Call re-run for cell: ${cell} ***
        ...    ELSE    logger.log_info_to_console      *** Call for cell: ${cell} ***
        Run Keyword If    ${prepare_bts}==${True}
        ...    Prepare Cell Before Call Procedure    cell=${cell}    traffic_matrix=${traffic_matrix}

        ${attach_status}=    ue_operations.try_to_make_attach    cell_id=${cell}    traffic_matrix=${traffic_matrix}
        ...                                                      alias=${alias}

        Run Keyword And Continue On Failure
        ...    Should be Equal    ${attach_status}    succeed     Attach to ${cell}
        ${proper_deviation}=    ue_operations.get_proper_deviation    deviation=${deviation}    cell=${cell}

        Run Keyword If    '${attach_status}'=='succeed' and '${bidirect}'=='False'    Run Keyword And Continue On Failure
        ...    Perform Data Transfer In Specific Directions    duration=${duration}    deviation=${proper_deviation}
        ...                                                    traffic_matrix=${traffic_matrix}    cell_name=${cell}
        ...                                                    raise_errors=${raise_errors}    run_num=${run_num}
        ...                                                    rerun=${rerun}    additional_action=${additional_action}
        ...                                                    additional_action_params=${additional_action_params}
        ...                                                    prepare_bts=${prepare_bts}    alias=${alias}

        Run Keyword If    '${attach_status}'=='succeed' and '${bidirect}'=='True'    Run Keyword And Continue On Failure
        ...    Perform Bidirect Data Transfer    duration=${duration}    deviation=${proper_deviation}
        ...                                      traffic_matrix=${traffic_matrix}    cell_name=${cell}
        ...                                      raise_errors=${raise_errors}    run_num=${run_num}
        ...                                      rerun=${rerun}    additional_action=${additional_action}
        ...                                      additional_action_params=${additional_action_params}
        ...                                      prepare_bts=${prepare_bts}    alias=${alias}

        Wait Until Keyword Succeeds    5x    10s    ue_operations.try_to_make_detach    alias=${alias}
        Run Keyword If    ${prepare_bts}==${True}
        ...    Prepare Setup Before Next Call    cell=${cell}    traffic_matrix=${traffic_matrix}
    END
    [Teardown]    ue_operations.release_resources      ${alias}

Perform Data Transfer In Specific Directions
    [Arguments]     ${duration}    ${deviation}    ${traffic_matrix}    ${cell_name}    ${raise_errors}=${True}
    ...    ${run_num}=${1}    ${rerun}=${False}    ${additional_action}=${None}    ${additional_action_params}=${None}
    ...    ${prepare_bts}=${True}    ${alias}=UE

    ${cell_keys}=    Get Dictionary Keys    ${traffic_matrix}[${cell_name}]
    ${element_status}=    common_operations.verify_if_element_belongs_to_list    element=DL
    ...                                                                          elements_list=${cell_keys}
    Run Keyword If    ${element_status}==${True} and '${prepare_bts}'=='True'
    ...    Prepare Cell Before Data Transfer    cell=${cell_name}    traffic_matrix=${traffic_matrix}
    ...                                         attenuation_level=atten_dl
    Run Keyword If    ${element_status}==${True}    Run Keyword And Continue On Failure
    ...    ue_operations.perform_data_transfer    directions=DL    duration=${duration}    deviation=${deviation}
    ...                                      traffic_matrix=${traffic_matrix}    cell_name=${cell_name}
    ...                                      raise_errors=${raise_errors}    run_num=${run_num}    alias=${alias}
    ...                                      rerun=${rerun}    additional_action=${additional_action}
    ...                                      additional_action_params=${additional_action_params}
    BuiltIn.Sleep    10s
    ${cell_keys}=    Get Dictionary Keys    ${traffic_matrix}[${cell_name}]
    ${element_status}=    common_operations.verify_if_element_belongs_to_list    element=UL
    ...                                                                          elements_list=${cell_keys}
    Run Keyword If    ${element_status}==${True} and '${prepare_bts}'=='True'
    ...    Prepare Cell Before Data Transfer    cell=${cell_name}    traffic_matrix=${traffic_matrix}
    ...                                         attenuation_level=atten_ul
    Run Keyword If    ${element_status}==${True}    Run Keyword And Continue On Failure
    ...    ue_operations.perform_data_transfer    directions=UL    duration=${duration}    deviation=${deviation}
    ...                                      traffic_matrix=${traffic_matrix}    cell_name=${cell_name}
    ...                                      raise_errors=${raise_errors}    run_num=${run_num}    alias=${alias}
    ...                                      rerun=${rerun}    additional_action=${additional_action}
    ...                                      additional_action_params=${additional_action_params}

Perform Bidirect Data Transfer
    [Arguments]     ${duration}    ${deviation}    ${traffic_matrix}    ${cell_name}    ${raise_errors}=${True}
    ...    ${run_num}=${1}    ${rerun}=${False}    ${additional_action}=${None}    ${additional_action_params}=${None}
    ...    ${prepare_bts}=${True}    ${alias}=UE

    Run Keyword If    '${prepare_bts}'=='True'
    ...    Prepare Cell Before Data Transfer    cell=${cell_name}    traffic_matrix=${traffic_matrix}
    ...                                         attenuation_level=atten_both
    Run Keyword And Continue On Failure
    ...    ue_operations.perform_data_transfer    directions=DL,UL    duration=${duration}    deviation=${deviation}
    ...                                      traffic_matrix=${traffic_matrix}    cell_name=${cell_name}
    ...                                      raise_errors=${raise_errors}    run_num=${run_num}    alias=${alias}
    ...                                      rerun=${rerun}    additional_action=${additional_action}
    ...                                      additional_action_params=${additional_action_params}

Prepare Setup Before Call Procedure
    [Arguments]    ${traffic_matrix}

    bts_operations.prepare_bts_before_call
    ${matrix_keys}=    Get Dictionary Keys    ${traffic_matrix}
    ${element_status}=    common_operations.verify_if_element_belongs_to_list    element=atten_default_values
    ...                                                                          elements_list=${matrix_keys}
    Run Keyword If    ${element_status}==${True}
    ...    attenuator_operations.adjust_attenuation_for_cells    attenuator_matrix=${traffic_matrix}
    ...                                                          attenuation_level=max

Adjust Cell
    [Arguments]    ${cell}    ${traffic_matrix}    ${attenuation_level}    ${qrx_level}=${None}

    ${cell_params}=    Create Dictionary    cell_name=${cell}
    ...                                     global_cell_id=${traffic_matrix}[${cell}][global_cell_id]
    @{cell_to_adjust_qrxlev}    create list
    Append To List    ${cell_to_adjust_qrxlev}    ${cell_params}
    ${bts_id}=    Set Variable If    'bts_id' in ${traffic_matrix}[${cell}]    ${traffic_matrix}[${cell}][bts_id]    ${0}
    Run Keyword If    ${qrx_level}!=${None}
    ...    bts_operations.perform_qrxlev_recommissioning   cell_list=${cell_to_adjust_qrxlev}    bts_id=${bts_id}
    ...                                                    qrx_level=${qrx_level}
    @{cell_to_adjust_atten}    create list
    Append To List    ${cell_to_adjust_atten}    ${cell}
    ${cell_keys}=    Get Dictionary Keys    ${traffic_matrix}[${cell}]
    ${element_status}=    common_operations.verify_if_element_belongs_to_list    element=attenuators
    ...                                                                          elements_list=${cell_keys}
    Run Keyword If    ${element_status}==${True}
    ...    attenuator_operations.adjust_attenuation_for_cells    attenuator_matrix=${traffic_matrix}
    ...                                                          cell_ids=${cell_to_adjust_atten}
    ...                                                          attenuation_level=${attenuation_level}

Prepare Cell Before Call Procedure
    [Arguments]    ${cell}    ${traffic_matrix}

    Adjust Cell    cell=${cell}    traffic_matrix=${traffic_matrix}    attenuation_level=avg    qrx_level=min

Prepare Setup Before Next Call
    [Arguments]     ${cell}    ${traffic_matrix}

    Adjust Cell    cell=${cell}    traffic_matrix=${traffic_matrix}    attenuation_level=max    qrx_level=max

Prepare Cell Before Data Transfer
    [Arguments]    ${cell}    ${traffic_matrix}    ${attenuation_level}

    Adjust Cell    cell=${cell}    traffic_matrix=${traffic_matrix}    attenuation_level=${attenuation_level}

Collect data transfer stats
    [Arguments]   ${run_num}=1

    ${data_transfer_stats}=    ue_operations.get_data_transfer_statistics
    html_thput_table.generate_html_thput_table      data_transfer_stats=${data_transfer_stats}
    ...                                             run_num=${run_num}
    html_thput_graphs.generate_html_thput_graphs    data_transfer_stats=${data_transfer_stats}
    ...                                             run_num=${run_num}
    common_operations.generate_console_thput_table    data_transfer_stats=${data_transfer_stats}
    ...                                               run_num=${run_num}
