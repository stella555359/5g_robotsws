*** Settings ***
Documentation      Author: jia-rebecca.liu@nokia-sbell.com
...                squad group: SG_03
...                CLOUD SISO CASE


Suite Setup    Run Keywords     get_test_round_info
...                 AND         get_cu_du_nums_from_init

Suite Teardown


Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009881-CR/Resources/CLOUD_SISO_common_keywords.robot



*** Test Cases ***
Case1_reset_rus_on_vdu
    [Timeout]    10 hours
    [Tags]    reset_ru
    [Setup]
    Create_test_case_log_path_for_cloud
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        ${current_time}    DateTime.Get Current Date    time_zone=UTC    result_format=epoch
        Rest_RU_and_check_alarm_action    current_time=${current_time}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect_all_vdus_snapshot

Case2_reset_vdus_on_vdu
    [Timeout]    10 hours
    [Tags]    reset_vdu
    [Setup]
    Create_test_case_log_path_for_cloud
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        ${current_time}    DateTime.Get Current Date    time_zone=UTC    result_format=epoch
        Rest_Vdu_and_check_alarm_action    current_time=${current_time}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect_all_vdus_snapshot




*** Keywords ***
Rest_RU_and_check_alarm_action
    [Timeout]    2 hours
    [Arguments]    ${current_time}
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        reset_ru_with_ids    cu_index=${cu_index}
        Wait Until Keyword Succeeds     15min    30s    get_ru_status_with_ids       cu_index=${cu_index}
        Wait Until Keyword Succeeds     15min    30s    get_cells_status_with_vdu    cu_index=${cu_index}
        get_active_alarms_on_vdu    cu_index=${cu_index}
        get_historical_alarms_on_vdu    cu_index=${cu_index}    current_time=${current_time}
    END

Rest_Vdu_and_check_alarm_action
    [Timeout]    2 hours
    [Arguments]    ${current_time}
    FOR    ${cu_index}    IN RANGE    ${cu_nums}
        reset_vdu_on_vdu    cu_index=${cu_index}
        Wait Until Keyword Succeeds     15min    30s    get_ru_status_with_ids       cu_index=${cu_index}
        Wait Until Keyword Succeeds     15min    30s    get_cells_status_with_vdu    cu_index=${cu_index}
        get_active_alarms_on_vdu    cu_index=${cu_index}
        get_historical_alarms_on_vdu    cu_index=${cu_index}    current_time=${current_time}
    END


