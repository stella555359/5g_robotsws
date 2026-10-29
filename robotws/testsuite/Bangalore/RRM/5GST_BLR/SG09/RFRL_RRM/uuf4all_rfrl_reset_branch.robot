*** Settings ***
Documentation
...   author: Sreekumar Narimuri Kumaran
...   contact: sreekumar.narimuri_kumaran@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource       taf/rfrl/uuf4all/uuf4all_keywords.robot
Library	       taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Force Tags     CA_RAN_PZ_WRO_2  PY36
Library		   String


*** Variables ***
${UPGRADE_ITERATION}=           1
${COMMISSIONING_ITERATION}=     2
${TEST_ITERATION}=              1
@{CUSTOM_ALARMS}=               4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  8000
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}                        ${None}
${HOSTNAME}                     7_2_UTE5GCLOUD1042  
@{CRITICAL_FAULTS}=             1850
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              TEST
${5G_SOURCE_SW}                 ${None}
${5G_TARGET_SW}                 ${None}
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                ${None}
${4G_TARGET_SW}=                ${None}
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${False}
${USE_REMOTE_NODE}=             ${False}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
${VIRTUALENV_DIR}=              ${None}
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_ST
${QC_ID_SITE_RESET}=            774296


*** TEST CASES ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${QC_ID_SITE_RESET}
