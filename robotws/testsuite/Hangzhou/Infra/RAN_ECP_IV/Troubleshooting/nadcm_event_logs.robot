*** Settings ***
Documentation     The purpose of this test suite is to verify that read event logs via NADCM should be succeed.
Suite Setup       common_suite_setup_for_infra
Suite Teardown    common_suite_teardown_for_infra
Test Setup        common_test_setup_for_infra
Test Teardown     common_test_teardown_for_infra
Resource          ../resources/infra_common_resources.robot
Library           taf.sw.nadcm    WITH NAME    inadcm
Library           resources/nadcm_event_logs.py    WITH NAME    NEL

*** Variables ***

*** Test Cases ***
Cloud_General_Logging_Event_logs_of_HW_devices_can_be_got_by_NADCM
    [Documentation]    = Cloud_General_Logging_Event_logs_of_HW_devices_can_be_got_by_NADCM =
    ...
    ...    == Test procedure ==
    ...    - 1. Get NADCM token.
    ...    - 2. Get the devices list via NADCM .
    ...    - 3. Reset BMC to generate event logs for them one by one.
    ...    - 4. Wait until all the BMC reset tasks finished.
    ...    - 5. Get the event logs information of the HW devices operated in step 3 one by one via NADCM.
    ...
    ...    == Expected result ==
    ...    - 1. Get NADCM token succeeds.
    ...    - 2. Get BMC list succeeds.
    ...    - 3. Get BMC reset task id list succeeds.
    ...    - 4. All the BMC reset task finished succeeds.
    ...    - 5. All the BMC reset event aseerted.
    inadcm.connect_to    ${NADCM_REST_ACCESS}[ip]    ${NADCM_REST_ACCESS}[username]    ${NADCM_REST_ACCESS}[password]    alias=mynadcm
    ${node_id2ip_dic}    NEL.get_bmc_node_id_and_ip_via_neat    mynadcm
    ${task_dic}    NEL.reset_bmc_to_generate_event_logs_for_them_one_by_one    ${node_id2ip_dic}    mynadcm
    NEL.wait_until_all_the_bmc_reset_tasks_finished    ${task_dic}    connection=mynadcm
    NEL.check_bmc_reset_event_log_is_asserted    ${node_id2ip_dic}    mynadcm
