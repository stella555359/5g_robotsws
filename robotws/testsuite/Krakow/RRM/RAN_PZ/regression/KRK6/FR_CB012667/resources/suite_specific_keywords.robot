*** Settings ***
Documentation
...  Common keywords for CB012667 feature testing

Library      CB012667_keywords.py
Library      taf/rfrl/procedures/resources/python/OAM_KPI/oam_kpi_runner.py
Library      taf.rfrl.utilities.logger.custom_logger                                  WITH NAME    logger

*** Keywords ***
Calculate Site Reset KPI With and Without CB012667
    [Arguments]    ${ru_configs}    ${iterations}=20    ${kpi_target}=&{KPI_1a_1b_1c_target}
    ${robot_log_path_without_CB012667}=    Set Variable    ${LOG_PATH}/Site_Reset_Without_CB012667
    ${robot_log_path_with_CB012667}=    Set Variable    ${LOG_PATH}/Site_Reset_With_CB012667

    Create Directory    ${robot_log_path_without_CB012667}
    Create Directory    ${robot_log_path_with_CB012667}

    FOR    ${ru_config}    IN    @{ru_configs}
        ${ru_id}=    Set Variable    ${ru_config}[0]
        ${ru_bts_id}=    Set Variable    ${ru_config}[1]
        CB012667_keywords.turn_off_cb012667_feature    ru_id=${ru_id}    ru_bts_id=${ru_bts_id}
    END

    logger.Log Info to Console    Calculating Site Reset KPI with CB012667 feature disabled.
    oam_kpi_runner.run_site_reset_in_loop    iterations=${iterations}
    ...                                      target=${kpi_target}
    ...                                      collect_passed_snapshot=False
    ...                                      additional_allowed_alarms=${additional_allowed_alarms}
    ...                                      _robot_log_path=${robot_log_path_without_CB012667}
    ${kpi_avg_without_feature}    CB012667_keywords.get_avg_kpi_value_from_json_file
    ...                           kpi=kpi1a
    ...                           json_file=${robot_log_path_without_CB012667}/GNB0_DU0_Kpi_results.json

    FOR    ${ru_config}    IN    @{ru_configs}
        ${ru_id}=    Set Variable    ${ru_config}[0]
        ${ru_bts_id}=    Set Variable    ${ru_config}[1]
        CB012667_keywords.turn_on_cb012667_feature    ru_id=${ru_id}    ru_bts_id=${ru_bts_id}
    END

    logger.Log Info to Console    Calculating Site Reset KPI with CB012667 feature enabled.
    oam_kpi_runner.run_site_reset_in_loop    iterations=${iterations}
    ...                                      target=${kpi_target}
    ...                                      collect_passed_snapshot=False
    ...                                      additional_allowed_alarms=${additional_allowed_alarms}
    ...                                      _robot_log_path=${robot_log_path_with_CB012667}
    ${kpi_avg_with_feature}    CB012667_keywords.get_avg_kpi_value_from_json_file
    ...                        kpi=kpi1a
    ...                        json_file=${robot_log_path_with_CB012667}/GNB0_DU0_Kpi_results.json

    ${diff}=    Evaluate    ${kpi_avg_without_feature} - ${kpi_avg_with_feature}
    logger.Log Info to Console    KPI without CB012667: ${kpi_avg_without_feature}s
    logger.Log Info to Console    KPI with CB012667: ${kpi_avg_with_feature}s
    logger.Log Info to Console    Difference: ${diff}s
    Should Be True    ${kpi_avg_without_feature} > ${kpi_avg_with_feature}
    ...               CB012667 feature should improve KPI

Calculate RU Reset KPI With and Without CB012667
    [Arguments]    ${ru_id}    ${ru_bts_id}    ${kpi_target}    ${ru_name}    ${iterations}=20
    ${robot_log_path_without_CB012667}=    Set Variable    ${LOG_PATH}/${ru_name}_Reset_Without_CB012667
    ${robot_log_path_with_CB012667}=    Set Variable    ${LOG_PATH}/${ru_name}_Reset_With_CB012667

    Create Directory    ${robot_log_path_without_CB012667}
    Create Directory    ${robot_log_path_with_CB012667}

    CB012667_keywords.turn_off_cb012667_feature    ru_id=${ru_id}    ru_bts_id=${ru_bts_id}

    logger.Log Info to Console    Calculating RU Reset KPI for ${ru_name} with CB012667 feature disabled.
    oam_kpi_runner.run_reset_rmod_in_loop    iterations=${iterations}
    ...                                      target=${kpi_target}
    ...                                      ru_id=${ru_bts_id}
    ...                                      collect_passed_snapshot=False
    ...                                      additional_allowed_alarms=${additional_allowed_alarms}
    ...                                      _robot_log_path=${robot_log_path_without_CB012667}
    ${kpi_avg_without_feature}    CB012667_keywords.get_avg_kpi_value_from_json_file
    ...                           kpi=kpi51a
    ...                           json_file=${robot_log_path_without_CB012667}/GNB0_DU0_Kpi_results.json

    CB012667_keywords.turn_on_cb012667_feature    ru_id=${ru_id}    ru_bts_id=${ru_bts_id}

    logger.Log Info to Console    Calculating RU Reset KPI for ${ru_name} with CB012667 feature enabled.
    oam_kpi_runner.run_reset_rmod_in_loop    iterations=${iterations}
    ...                                      target=${kpi_target}
    ...                                      ru_id=${ru_bts_id}
    ...                                      collect_passed_snapshot=False
    ...                                      additional_allowed_alarms=${additional_allowed_alarms}
    ...                                      _robot_log_path=${robot_log_path_with_CB012667}

    ${kpi_avg_with_feature}    CB012667_keywords.get_avg_kpi_value_from_json_file
    ...                        kpi=kpi51a
    ...                        json_file=${robot_log_path_with_CB012667}/GNB0_DU0_Kpi_results.json

    ${diff}=    Evaluate    ${kpi_avg_without_feature} - ${kpi_avg_with_feature}
    logger.Log Info to Console    KPI without CB012667 (${ru_name}): ${kpi_avg_without_feature}s
    logger.Log Info to Console    KPI with CB012667 (${ru_name}): ${kpi_avg_with_feature}s
    logger.Log Info to Console    Difference: ${diff}s
    Should Be True    ${kpi_avg_without_feature} > ${kpi_avg_with_feature}
    ...               CB012667 feature should improve KPI
