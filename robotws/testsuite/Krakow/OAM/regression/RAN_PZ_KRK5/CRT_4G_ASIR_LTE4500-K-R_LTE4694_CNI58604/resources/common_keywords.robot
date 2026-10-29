*** Settings ***
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Library      OperatingSystem
Library      taf.rfrl.utilities.logger.custom_logger                              WITH NAME    logger
Library      taf.rfrl.procedures.resources.python.common_allowed_alarms           WITH NAME    alarm
Library      ./resources.py                                                       WITH NAME    local_resources

Variables    ./common_variables.py

*** Variables ***
${tl_config}     /home/ute/auto/testline_configuration/`uname -n | sed -r 's/(.*)-[0-9]$/\1/' | tr "-" "_"`/__init__.py

*** Keywords ***
Modify_ASi_Manager_login_banner_text
    ${dist_name}     Set Variable     ASI-1/SECPRM-1
    ${parameter_name}     Set Variable     appLoginBannerText
    local_resources.change_and_activate_asirhub_parameter     dn=${dist_name}    name=${parameter_name}
    ...                                                       value=${CUSTOM_BANNER}
    local_resources.verify_asirhub_parameter     dist_name=${dist_name}     parameter=${parameter_name}
    ...                                          expected_value=${CUSTOM_BANNER}
    local_resources.change_and_activate_asirhub_parameter     dn=${dist_name}     name=${parameter_name}
    ...                                                       value=${DEFAULT_BANNER}
    local_resources.verify_asirhub_parameter     dist_name=${dist_name}     parameter=${parameter_name}
    ...                                          expected_value=${DEFAULT_BANNER}

Modify_state_of_LMTPORT_on_ASi_HUB
    [Arguments]     ${state}
    ${dist_name}     Set Variable     ASI-1/HUBMOD-1/LMTPORT-1
    ${parameter_name}     Set Variable     administrativeState
    local_resources.change_and_activate_asirhub_parameter     dn=${dist_name}     name=${parameter_name}
    ...                                                       value=${state}
    local_resources.verify_asirhub_parameter     dist_name=${dist_name}     parameter=${parameter_name}
    ...                                          expected_value=${state}

Verify_alarm_is_active_on_AsirWebem
    [Arguments]     ${fault_id}     ${fault_name}=${None}
    local_resources.verify_alarm_is_active_on_asir     fault_id=${fault_id}     fault_name=${fault_name}

Verify_alarm_is_not_active_on_AsirWebem
    [Arguments]     ${fault_id}
    local_resources.verify_alarm_is_not_active_on_asir     fault_id=${fault_id}

Verify_hub_lmp_is_pingable
    local_resources.verify_is_hub_lmp_pingable

Verify_hub_lmp_is_not_pingable
    local_resources.verify_is_hub_lmp_not_pingable

Lock_user
    [Arguments]     ${user}=toor4nsn
    local_resources.ssh_hub_with_incorrect_password     user=${user}

Verify_ssh_info_banner
    local_resources.verify_ssh_info_banner_content

Load_delta_gNB_from_file
    [Arguments]    ${delta_json_file}
    local_resources.load_gnb_delta_from_file     delta_json_file=${delta_json_file}

Load_delta_asir_from_file
    [Arguments]     ${delta_xml_file}
    local_resources.replace_nidd_version     xml_file=${delta_xml_file}
    local_resources.load_asir_delta_from_file     delta_xml_file=${delta_xml_file}

Verify_actAsiDistMimo_in_AsirWebem
    [Arguments]     ${cells}     ${value}
    FOR     ${cell}      IN      @{cells}
        ${cell_id}=     local_resources.get_id_from_cell_name     cell=${cell}
        ${hub_dist_name}     Set Variable     ASI-1/ASI_R-1/BTS_R-1/CELL_R-${cell_id}
        ${parameter_name}     Set Variable     actAsiDistMimo
        local_resources.verify_asirhub_parameter     dist_name=${hub_dist_name}     parameter=${parameter_name}
        ...                                          expected_value=${value}
    END

Modify_actAsiDistMimo_in_Webem
    [Arguments]     ${cells}     ${value}
    FOR     ${cell}      IN      @{cells}
        ${cell_id}=     local_resources.get_id_from_cell_name     cell=${cell}
        ${gnb_dist_name}     Set Variable     MRBTS-76079/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${cell_id}
        ${parameter_name}     Set Variable     actAsiDistMimo
        local_resources.update_gnb_param     dist_name=${gnb_dist_name}     parameter=${parameter_name}
        ...                                  value=${value}
    END

Verify_DL_MIMO_in_Webem
    [Arguments]     ${cells}     ${mimo_value}
    FOR     ${cell}      IN      @{cells}
        ${cell_id}=     local_resources.get_id_from_cell_name     cell=${cell}
        local_resources.verify_dl_mimo     cell=${cell}     mimo_value=${mimo_value}
    END

Modify_oamTLS_in_Webem
    [Arguments]     ${value}
    ${gnb_dist_name}     Set Variable     MRBTS-76079/MNL-1/MNLENT-1/MPLANENW-1
    ${parameter_name}     Set Variable     oamTls
    local_resources.update_gnb_param     dist_name=${gnb_dist_name}     parameter=${parameter_name}
    ...                                  value=${value}

Set additional alarms
    [Arguments]    ${alarms_for_test}
    Set Test Variable    ${CUSTOM_ALLOWED_ALARMS}    ${alarms_for_test}

Actions before test
    [Arguments]    ${alarms_for_test}=${None}
    ${default_alarms}=    alarm.get_variables
    Set Test Variable    ${allowed_alarms}    ${default_alarms}[allowed_alarms]
    Set Test Variable    ${ASIR_ALLOWED_ALARMS}    ${default_alarms}[ASIR_ALLOWED_ALARMS]
    Run keyword if    "${alarms_for_test}!=${None}"    Set additional alarms    ${alarms_for_test}
    Common Preconditions With Watching Alarms

Actions after test
    Remove custom allowed alarms if defined
    Common Postconditions With Watching Alarms
    local_resources.check_scout_scf_id_is_present

Turn test line on
    ${power_on_cmd}=     Set Variable     ecolab_cli power_on -c ${tl_config}
    ${output}=     Run     ${power_on_cmd}
    logger.log_info_to_console     ${output}

Turn test line off
    ${power_off_cmd}=     Set Variable     ecolab_cli power_off -c ${tl_config}
    ${output}=     Run     ${power_off_cmd}
    logger.log_info_to_console     ${output}
