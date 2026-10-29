*** Settings ***
Documentation    Common keyword for all PZ robot cases.
...              Please do not modify the file without notification to author
...              Author: Civen Chen
...              Contact: civen.chen@nokia-sbell.com
Resource    ./alarm_checking.robot
Resource    ./configuration_id.robot
#Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.collect_ru_logs
Library    OperatingSystem

*** Keywords ***
Trigger start collect ru logs
    [Arguments]    ${enable}=${False}
    ${enable_ru_log}    Evaluate    '5G_PZ_HZ_4_SG' in '${CURDIR}' or ${enable}
    Run Keyword If    ${enable_ru_log}    Prepare and start ru serial log collection


Prepare and start ru serial log collection
    ${time_stamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${tc_name}=    Replace String    string=${TEST NAME}    search_for=${SPACE}    replace_with=_
    ${ru_log_path}    Join path    ${OUTPUT_DIR}    ru_series_log    TC_${tc_name}_${time_stamp}
    Create Directory    ${ru_log_path}
    Append To File    ${OUTPUT_DIR}/ru_serial_log_path.txt    ${TEST NAME}|${ru_log_path}\n
    start_to_collect_ru_logs    is_ru_log_collecting_enable=${True}    log_save_dir=${ru_log_path}
