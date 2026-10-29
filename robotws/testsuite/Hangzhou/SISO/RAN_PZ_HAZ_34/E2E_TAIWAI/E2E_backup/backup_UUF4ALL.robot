*** Settings ***
Suite Setup        SISO Coam Suite Setup
Suite Teardown        SISO Coam Suite Teardown
Test Timeout         1200 min

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    taf/rfrl/uuf4all/resources/robot/uuf_rfrl_common_keywords.robot
Resource    ../Resource/e2e_common_cases.robot
Resource    ../Resource/e2e_step_keywords.robot
Resource    ../Resource/e2e_oam_kpi_keywords.robot
Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Variables   ../TestData/E2E_variables.py

Documentation
...    Author: kaihui fan
...    Contact: kaihui.fan@nokia-sbell.com
...    squad group:SG_04
...    Feature E2E CHT

Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED
...   PY36

*** Variables ***
${if_commissioning}    True
${runs_of_uuf_upgrade}         ${10}
${runs_of_uuf_reset}         ${20}
${target_version}       SBTS00_ENB_9999_230824_000011
${restore_to_target_sw}    True
@{critical_faults}       10    16    1806    1868    4341    4352    4383
@{customers}             Taiwan Mobile
@{custom_alarms}     4293   62003   61074   7509
${remote_node_update}   False
${is_enb_test}     False
${should_be_reported}       True
${L3_CALL}   Make Call With All UE for Sleepingcell
${disable_syslog_check}   True
${common_web_service_hz}    http://10.135.157.75:8081/artifactory/mn5gran_hzlog-local
${qc_domain}=                   MN_RAN_ST
${qc_id}=                      ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${qc_project}=                  RAN_ST
${LABEL}=                       ${None}

*** Test Cases ***

[1]E2E_gNB_Site_Reset_without_HWF_with_L3Call
    [Setup]    UUF4ALL NR Test Setup
    ${TEST_NAME}   Set Variable   [1]e2e_tl_site_reset_without_hwf_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    UUF4ALL_SITE_RESET_TEST
    ...    test_iteration=${runs_of_uuf_reset}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    custom_alarms=@{custom_alarms}
    ...    use_remote_node=${is_enb_test}
    ...    should_be_reported=${should_be_reported}
    ...    attach_test_keyword=${None}
    ...    disable_syslog_check=${disable_syslog_check}
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    label=${LABEL}
    [Teardown]    UUF4ALL NR Test Teardown

[1]E2E_gNB_SW_Upgrade_loops_with_WebUI_and_L3Call
    [Setup]    UUF4ALL NR Test Setup
    ${current_version}    E2E_Get_Current_Version  download_dir=${OUTPUT DIR}
    Set Test Variable    ${source_sw}    ${current_version}
    log to console   \nsource:${source_sw}
    ${package_path}   Download SW package to VM   ${ENB_BUILD}
    ${file_exist}   run keyword and return status  OperatingSystem.File Should Exist   ${package_path}
    ${target_sw_path}   Set Variable If   ${file_exist}   ${package_path}   ${None}
    ${TEST_NAME}   Set Variable   [1]e2e_tl_sw_upgrade_rollback_with_oam_kpi
    Set Global Variable   ${TEST_NAME}
    UUF4ALL_SW_UPGRADE_TEST
    ...    test_iteration=${runs_of_uuf_upgrade}
    ...    critical_faults=@{critical_faults}
    ...    customers_list=${customers}
    ...    5g_source_sw=${source_sw}
    ...    5g_target_sw=${target_version}
    ...    use_builds_storage=${False}
    ...    restore_to_target_sw=${restore_to_target_sw}
    ...    custom_alarms=@{custom_alarms}
    ...    use_remote_node=${is_enb_test}
    ...    remote_node_update=${remote_node_update}
    ...    should_be_reported=${should_be_reported}
    ...    local_node_attach_test_keyword=${None}
    ...    disable_syslog_check=${disable_syslog_check}
    ...    5g_target_sw_path=${target_sw_path}
    ...    qc_domain=${qc_domain}
    ...    qc_id=${qc_id}
    ...    qc_project=${qc_project}
    ...    label=${LABEL}
    [Teardown]    UUF4ALL NR Test Teardown
