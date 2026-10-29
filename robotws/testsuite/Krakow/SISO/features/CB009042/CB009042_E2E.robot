*** Settings ***
Documentation
...   Test suite for regression testing of feature CB009042 - test case E2E: SW upgrade, L3 call, rollback
...   author: Agnieszka Bylica
...   contact: agnieszka.bylica@nokia.com

Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/variables.py
Variables    ./resources/variables_imported_for_uuf.py

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Custom Test Teardown


*** Variables ***
${UPDATE_TEST_ITERATION}            1

${SHOULD_BE_REPORTED}=  ${False}
@{CUSTOMERS_LIST}=      USCC
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
${5G_SOURCE_SW}=        SBTS00_ENB_9999_240306_000006
${5G_TARGET_SW}=        SBTS00_ENB_9999_240306_000008
${4G_SOURCE_SW}=        ${None}
${4G_TARGET_SW}=        ${None}
${UPDATE_TEST_FAILED}   ${False}
@{CUSTOM_ALLOWED_ALARMS}    No X2 link available
...                         No X2 link available for a specific LTEENB
...                         Fault signature for crash or failure
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_ST
${restore_to_target_sw}    ${False}

# --------------------------L3 Call----------------------------------------------
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${alias}                   UE
${capabilities}            REAL_UE

${duration}                60s
${protocol}                tcp
${interval}                1
${reboot_ue}               True
${timeout_reboot_ue}       100

${tput_dl}                 3800 Mbits/sec
${deviation_dl}            90%
${size_packet_dl}          1400B
${buffer_client_dl}        8M
${buffer_server_dl}        8M
${parallel_streams_dl}     1

${tput_ul}                 490 Mbits/sec
${deviation_ul}            90%
${size_packet_ul}          1320B
${buffer_client_ul}        2M
${buffer_server_ul}        2M
${parallel_streams_ul}     2

# no idea what is it - to check with Radek
${qci_dl}                  ${None}
${qci_ul}                  ${None}
${linux_congestion_dl}     ${None}
${linux_congestion_ul}     ${None}


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${restore_to_target_sw}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${None}
    ...          qc_project=${QC_PROJECT}
    ...          local_node_attach_test_keyword=Verify L3 call
    ...          use_remote_node=${False}
    ...          should_be_reported=${False}


*** Keywords ***
Custom Test Teardown
    Run Keyword If Test Failed    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

Verify L3 call
    [Arguments]    ${cell_used_in_test}=${11}    ${remote}=${False}
    Prepare Ue for L3 Call    capabilities=${capabilities}    alias=${alias}
    ...                       reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
    ...                                   protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}    qci_dl=${qci_dl}    qci_ul=${qci_ul}    linux_congestion_dl=${linux_congestion_dl}
    ...    linux_congestion_ul=${linux_congestion_ul}
