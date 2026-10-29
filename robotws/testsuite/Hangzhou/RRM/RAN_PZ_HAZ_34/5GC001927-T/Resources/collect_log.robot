*** Settings ***
Library           taf.gnb.oam.megazone_client    WITH NAME    oam
Library           taf.transport.ssh    WITH NAME    csn
Library           Process
Library           OperatingSystem
Library           Collections
Library           DateTime
Library           String

*** Variables ***
${TESTLINE_NAME}    7_5_CLOUD402T038
${WEBUI_URL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}

*** Keywords ***
Common Suite Teardown for COAM
    [Documentation]    Do some common thing for every postcondition of cases for COAM BTS
    [Timeout]  15 min
    Backup SCF file for COAM
    Collect snapshot for COAM

Collect snapshot for COAM
    selenium_coam.enable_virtual_display
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ...                    download_dir=${epc_log_path}
    selenium_coam.snapshot_collection_settings    coverage=All log files
    ...                                           save_location=Local
    selenium_coam.collect_snapshot
    selenium_coam.logout

Backup SCF file for COAM
    selenium_coam.enable_virtual_display
    selenium_coam.login    ${WEBUI_URL}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ...                    download_dir=${epc_log_path}
    selenium_coam.save_bts_configuration    save_configuration_type=${1}
    selenium_coam.logout

Common Suite Setup for COAM
    [Documentation]    this keyword create suite name directory path as ${OUTPUT_DIR}//logs//
# // common setup
    run process    taskkill /f /im chromedriver.exe    shell=True
    run process    ps -ef|grep chrome | awk '{print $2}' |xargs kill -9    shell=True
    set suite variable      ${tl.test_pc.default_ssh_connection_details.addr}
	set suite variable      ${tl.test_pc.default_ssh_connection_details.username}
	set suite variable      ${tl.test_pc.default_ssh_connection_details.password}
    set suite variable      ${OUTPUT_PATH}    /opt/workspace/CIT/Master/Case_logs
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    selenium_coam.enable_virtual_display
    selenium_coam.login    ${WEBUI_COAM}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ${is_startup_window_exist} =      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${BTS_Version} =    selenium_coam.check_current_software_version
    selenium_coam.logout
    ${SW_version} =   get from dictionary    ${BTS_Version}   Active
    set suite variable    ${Active_SW_version}      ${SW_version}
    ${OUTPUT_PATH_ADD_SW}=    join path     ${OUTPUT_PATH}     ${TESTLINE_NAME}_${Active_SW_version}
    set suite variable     ${OUTPUT_PATH_ADD_SW}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_DIRECTORY}
    Set Suite Variable    ${epc_log_path}    ${SUITE_LOG_DIRECTORY}/

Common Test Setup
    [Documentation]    this keyword create case name directory path as ${OUTPUT_DIR}//logs//${SUITE_LOG_DIRECTORY}//
    ${TEST_LOG_DIR}=    Get A Directory
    Set Test Variable    ${TEST_LOG_DIR}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TEST_LOG_DIR}

Get A Directory
    [Arguments]    @{paths}
    [Documentation]    Create a specific directory under suite log directory and ${dir_name}
    ${log_path}=    _Get Log Path
    ${directory_path}=    OperatingSystem.Join Path    ${log_path}    @{paths}
    ${directory_path}=    Replace String    ${directory_path}    ${SPACE}    _
    Create Directory    ${directory_path}
    [Return]    ${directory_path}

_Get Log Path
    ${result}=    Run Keyword And Ignore Error    Variable Should Exist    ${TEST NAME}
    ${log_path}=    Run Keyword If    "${result[0]}"=="PASS"    _Get Case Log Path
    ...    ELSE    _Get Suite Log Path
    [Return]    ${log_path}

_Get Suite Log Path
    ${concated_suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${suite_log_path}=    OperatingSystem.Join Path    ${OUTPUT_PATH_ADD_SW}    ${timestamp}    TESTSUITE__${concated_suite_name}
    [Return]    ${suite_log_path}

_Get Case Log Path
    ${concated_suite_name}=    Replace String    ${SUITE NAME}    ${SPACE}    _
    ${concated_test_name}=    Replace String    ${TEST NAME}    ${SPACE}    _
    ${timestamp}=    Set Variable    ${START_TIME.replace(" ", "_").replace("-", "_").replace(":", "_")}
    ${case_log_path}=    OperatingSystem.Join Path    ${OUTPUT_PATH_ADD_SW}    ${timestamp}
    ...    TESTSUITE__${concated_suite_name}    TESTCASE__${concated_test_name}
    [Return]    ${case_log_path}
