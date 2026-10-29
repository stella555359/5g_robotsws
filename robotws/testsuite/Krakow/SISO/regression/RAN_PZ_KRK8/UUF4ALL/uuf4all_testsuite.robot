*** Settings ***
Documentation   Universal test suite for basic UUF OAM tests in loop dedicated for Cloud testlines in VRF KRK T08
...   author: Mateusz Iwankiewicz, Aleksander Gospodarczyk, Jacek Dziedzicki
...   contact: mateusz.iwankiewicz@nokia.com, aleksander.gospodarczyk@nokia.com, jacek.dziedzicki@nokia.com

Resource        resources/uuf_keywords.robot

Test Timeout    96 hours

Suite Setup          Test Suite Setup
Suite Teardown       Test Suite Teardown


*** Variables ***
${RP_CA}                            VRF_OAM
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T08

${UPDATE_TEST_ITERATION}=           0
${SITE_RESET_TEST_ITERATION}=       0
@{CUSTOMERS_LIST}=                  Generic
${SHOULD_BE_REPORTED}=              ${True}
@{CUSTOM_ALLOWED_ALARMS}=           @{EMPTY}
${BTS_HOST_IP}                      192.168.255.129
@{CRITICAL_FAULTS}=                 0010  0016  1806  1868  4341  4352  4383  4590
${5G_SOURCE_SW}                     ${None}
${DEFINED_5G_SOURCE_SW}             SBTS24R2_ENB_0000_000831_000003
${5G_TARGET_SW}=                    ${None}
${4G_SOURCE_SW}=                    ${None}
${4G_TARGET_SW}=                    ${None}
${5G_TARGET_SW_PATH}=               ${None}
${4G_TARGET_SW_PATH}=               ${None}
${USE_REMOTE_NODE}=                 ${False}
${REMOTE_VM_IP}=                    ${None}
${REMOTE_MPLANE}=                   ${None}
${RESTORE_TARGET_SW}=               ${True}
${USE_BUILDS_STORAGE}=              ${False}
${UPDATE_TEST_FAILED}=              ${False}
${PERFORM_UBOOT_DOWNGRADE}=         ${False}
${MUMIN_CONFIG_FILE}=               ${None}
${ALARM_TIMEOUT}=                   120
${HARDWARE_CHECK_TIMEOUT}=          900
${DISABLE_KPI}=                     ${False}
@{SYSLOG_IGNORED_PRINTS}=           INF
${DISABLE_SYSLOG_CHECK}=            ${False}
${REMOTE_NODE_UPDATE}=              ${False}

${SCF_PREFIX}                       UUF4ALL_main_gnb
${sw_config_path}                   testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/UUF4ALL/resources/swconfig.txt

*** Test Cases ***
SW_upgrade_rollback_with_OAM_KPI
    Run Keyword If    not '${UPDATE_TEST_ITERATION}' == '${0}'
    ...    Run Keywords
           ...     Test Setup For Upgrade Test    AND
           ...     UUF4ALL_SW_UPGRADE_TEST
                   ...          test_iteration=${UPDATE_TEST_ITERATION}
                   ...          customers_list=@{CUSTOMERS_LIST}
                   ...          critical_faults=@{CRITICAL_FAULTS}
                   ...          5g_source_sw=${5G_SOURCE_SW}
                   ...          5g_target_sw=${5G_TARGET_SW}
                   ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
                   ...          4g_source_sw=${4G_SOURCE_SW}
                   ...          4g_target_sw=${4G_TARGET_SW}
                   ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
                   ...          restore_to_target_sw=${RESTORE_TARGET_SW}
                   ...          should_be_reported=${SHOULD_BE_REPORTED}
                   ...          remote_node_update=${REMOTE_NODE_UPDATE}
                   ...          use_remote_node=${USE_REMOTE_NODE}
                   ...          remote_vm_ip=${REMOTE_VM_IP}
                   ...          remote_mplane=${REMOTE_MPLANE}
                   ...          use_builds_storage=${USE_BUILDS_STORAGE}
                   ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
                   ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
                   ...          custom_alarms=@{CUSTOM_ALLOWED_ALARMS}
    ...  ELSE
    ...     logger.log_info_to_console  -- No tc execution: UPDATE_TEST_ITERATION = ${UPDATE_TEST_ITERATION} --\n

Site_reset_without_HWF_with_OAM_KPI
    Run Keyword If    not '${SITE_RESET_TEST_ITERATION}' == '${0}'
    ...     UUF4ALL_SITE_RESET_TEST
            ...          test_iteration=${SITE_RESET_TEST_ITERATION}
            ...          customers_list=@{CUSTOMERS_LIST}
            ...          critical_faults=@{CRITICAL_FAULTS}
            ...          should_be_reported=${SHOULD_BE_REPORTED}
            ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
            ...          remote_vm_ip=${REMOTE_VM_IP}
            ...          remote_mplane=${REMOTE_MPLANE}
            ...          use_remote_node=${USE_REMOTE_NODE}
            ...          custom_alarms=@{CUSTOM_ALLOWED_ALARMS}
    ...  ELSE
    ...    logger.log_info_to_console  -- No tc execution: SITE_RESET_TEST_ITERATION = ${SITE_RESET_TEST_ITERATION} --\n
