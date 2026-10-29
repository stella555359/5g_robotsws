*** Settings ***
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.gnb.oam.commissioning    WITH NAME    commissioning
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py
Resource    5GC000561_common_keyword.robot

Documentation
...   author: Chen Tong
...   contact: tong.chen@nokia-sbell.com
...   squad group: SG_02

*** Variables ***
${COAM_ADDR}    ${CU_ADDR}
${COAM_URL}    ${WEBUI_OAM}
${COAM_URL_NAME}    ${WEBUI_NAME}
${COAM_URL_PWD}    ${WEBUI_PWD}

#${scf_file_path}    /home/ute/Downloads/SCF/scf_gNB_cOAM.xml
${scf_file_path}    /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/5GC000561/scf_gNB_cOAM.xml

*** Keywords ***
COAM Create log directory for 561
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}

COAM Get Alarms Info From WebUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...                    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...                    download_dir=${download_dir}

    ${alarms}    selenium_coam.get_active_alarm_info
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display
    [Return]    ${alarms}

COAM Check GNB Sync status
    [Arguments]    ${connection}=GNB_OAM
    Log to console    Check GNB Sync status
    ${sync_info}    coam.get_bts_sync_source_status    connection=${connection}
    @{sync_status}    Set variable    ${sync_info['syncSourceInfo']}
    &{sync_status}    Set variable    ${sync_status[0]}
    Run keyword and continue on failure    Should be equal as strings    ${sync_info['syncMode']}    PhaseSync
    ...                                    msg=Current synchronization mode is not PhaseSync mode    ignore_case=${True}
    Run keyword and continue on failure    Should be equal as strings    ${sync_status['status']['availability']}    Available
    ...                                    msg=Current synchronization status is not available    ignore_case=${True}
    Run keyword and continue on failure    Should contain any    ${sync_info['tuningMode']}    Normal tuning    Normal
    ...                                    msg=Current synchronization tuning mode is abnormal    ignore_case=${True}

COAM Wait for gnb ready and cell setup and sync status
    COAM Wait for gnb ready and cell setup
    Wait until keyword succeeds    10min    20 sec    COAM Check GNB Sync status
    COAM Teardown gnb connections

COAM commission scf and wait cell setup
    [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    Run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf_file_path}
    COAM Teardown gnb connections
    COAM Wait for gnb ready and cell setup and sync status

COAM Rest Site via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    selenium_coam.reset_site
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display
    Sleep    5min
    COAM Wait for gnb ready and cell setup and sync status

COAM Get Transport Counters via webUI
    [Arguments]    ${counter_id}
    Sleep    5
    COAM Navigate to login page via webUI    download_dir=${TS_CASE_LOG_PATH}
    ${counters}    selenium_coam.get_transport_counters    counter_id=${counter_id}
    ${curr_data}    DateTime.Get Current Date    UTC    + 8 hours    result_format=%Y-%m-%d-%H_%M_%S
    selenium_coam.save_screenshot   filename=Screen_${curr_data}.png    screenshot_dir=${TS_CASE_LOG_PATH}
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display
    [Return]    ${counters}

Coam Get Parameter via webUI
    [Arguments]    ${dist_name}    ${filter_param}    ${p_name}    ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ...                                                      timeout=${120}
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display
    [Return]    ${current_val}

Coam Check Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}    ${download_dir}=${TS_CASE_LOG_PATH}
    ${current_val}    Coam Get Parameter via webUI    dist_name=${dist_name}
    ...                                               filter_param=${filter_param}
    ...                                               p_name=${p_name}
    ...                                               download_dir=${download_dir}
    should be equal    ${current_val}    ${expected_val}

Coam Check Parameter via webUI when lowercase
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}    ${download_dir}=${TS_CASE_LOG_PATH}
    ${current_val}    Coam Get Parameter via webUI    dist_name=${dist_name}
    ...                                               filter_param=${filter_param}
    ...                                               p_name=${p_name}
    ...                                               download_dir=${download_dir}
    ${lower_val}    Convert To Lower Case     ${current_val}
    should be equal    ${lower_val}    ${expected_val}

Coam Get Validate error
    ${defination_errors}    selenium_coam.get_definition_errors    timeout=${120}
    ${relation_errors}      selenium_coam.get_relation_errors    timeout=${120}
    ${errors}    Catenate    ${defination_errors}   ${relation_errors}
    [Return]    ${errors}

Coam Change Parameter via webUI
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}    ${download_dir}=${TS_CASE_LOG_PATH}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    Wait until keyword succeeds    10min    20 sec    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    ${errors}    run keyword if  not '${current_val}'=='${expected_val}'
    ...                  Coam Set Parameter value via webUI   expected_val=${expected_val}
    ...                                                       dist_name=${dist_name}
    ...                                                       filter_param=${filter_param}
    ...                                                       p_name=${p_name}
    ...                                                       is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    ...                                                       need_active=${need_active}
    ${current_val}    Run Keyword And Continue On Failure    selenium_coam.get_parameter_value
    ...                                                      dist_name=${dist_name}
    ...                                                      filter_param=${filter_param}
    ...                                                      abbr=${p_name}
    Run keyword and ignore error    selenium_coam.logout
    Run keyword and ignore error    selenium_coam.disable_virtual_display
    Run keyword if    ${need_active}==${True}
    ...    should be equal    ${current_val}    ${expected_val}
    [Return]    ${errors}

Coam Set Parameter value via webUI
    [Documentation]    Author: Tong Chen
    ...    [PRIVATE]
    [Arguments]    ${expected_val}    ${dist_name}    ${filter_param}    ${p_name}
    ...            ${is_need_to_check_validation_errors}=${False}    ${need_active}=${True}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                                  filter_param=${filter_param}
    ...                                  new_value=${expected_val}
    ...                                  abbr=${p_name}
    ...                                  timeout=${120}
    selenium_coam.validate_plan
    ${errors}    Coam Get Validate error
    Run keyword if    ${is_need_to_check_validation_errors}==${True}
    ...    Should be empty    ${errors}
    Run keyword if    ${need_active}==${True}
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}
    [Return]    ${errors}
