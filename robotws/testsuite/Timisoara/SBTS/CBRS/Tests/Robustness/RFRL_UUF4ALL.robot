*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:


Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    ./../../Resources/cbrs_common_keywords.robot
Force Tags     CA_RAN_PZ_WRO_3

*** Variables ***
${TEST_ITERATION}             1
${TEST_ITERATION_UPGRADE}     1
@{CUSTOM_ALARMS}              6823    6825    6826    6829
${REMOTE_VM_IP}               ${None}
${REMOTE_MPLANE}              ${None}
${LABEL}                      ${None}
${HOSTNAME}                   ${None}
@{CRITICAL_FAULTS}            @{EMPTY}
${SHOULD_BE_REPORTED}         ${False}
@{CUSTOMERS_LIST}             Generic
${5G_SOURCE_SW}               SBTS22R1_ENB_0000_001850_000000
${5G_TARGET_SW}               SBTS23R1_ENB_0000_001186_000000
${5G_TARGET_SW_PATH}          ${None}
${4G_SOURCE_SW}               ${None}
${4G_TARGET_SW}               ${None}
${4G_TARGET_SW_PATH}          ${None}
${REMOTE_NODE_UPDATE}         ${False}
${USE_REMOTE_NODE}            ${False}
${DOWNLOAD_PATH}              ${None}
${USE_BUILDS_STORAGE}         ${True}
${RESTORE_TARGET_SW}          ${True}
${PERFORM_UBOOT_DOWNGRADE}    ${False}
${DISABLE_SYSLOG_CHECK}       ${False}
@{USER_SUSPICIOUS_PRINTS}     @{EMPTY}
${REPORT_COMMENT}             ${None}
${QC_DOMAIN} MN_RAN_ST
${TEST_QC_ID} ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${QC_PROJECT} RAN_ST

*** Test Cases ***
SAS Simulator Setup
    [Timeout]    30m
    Kill All SAS Processes
    Add CBRS Certificates
    ${sas_pid}    ${sas_logs_dir} =    Start SAS Process
    log to console    ${sas_pid}
    log to console  'SAS location' ${sas_logs_dir}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION_UPGRADE}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          remote_node_update=${REMOTE_NODE_UPDATE}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          use_test_packages=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

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
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_RMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_BBMOD_RESET
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_NRCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    OAM_LNCEL_LOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    OAM_LNCEL_BLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    OAM_NRCEL_BLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_BTS_Block_Unblock
    [Timeout]   24h
    BTS_BLOCK_UNBLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${False}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    RMOD_LOCK_UNLOCK
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${False}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

E2E_TL_RU_Power_Reset
    [Timeout]   24h
    RMOD_POWER_RESET
    ...          pdu_list=${pdu_list}
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${False}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

#E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
#    [Timeout]   24h
#    OAM_GNCEL_BLOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${TEST_QC_ID}
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
#    [Timeout]   24h
#    OAM_WNCEL_BLOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${TEST_QC_ID}
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Capacity_Module_Lock_Unlock
#    [Timeout]   24h
#    BBMOD_LOCK_UNLOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${False}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${TEST_QC_ID}
#    ...          qc_project=${QC_PROJECT}
