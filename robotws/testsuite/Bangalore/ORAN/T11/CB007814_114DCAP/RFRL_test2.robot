*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:
Library     taf.sbts.oam.coam.admin
Library     OperatingSystem
Library     Process
Library     Collections
Library     String
Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource       /home/ute/.pyenv/versions/3.9.14/lib/python3.9/site-packages/taf/rfrl/uuf4all/uuf4all_test_cases.robot

Force Tags      CA_VRF_BLR1     QCD_MN_RAN    QCP_RAN_VRF

*** Variables ***
${TEST_ITERATION}=              1
@{CUSTOM_ALARMS}=               4657 6304
${REMOTE_VM_IP}=                10.41.209.165
${REMOTE_MPLANE}=               10.63.48.81
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          True
@{CUSTOMERS_LIST}=              Generic
${5G_SOURCE_SW}=                ${None}
${5G_TARGET_SW}=                ${None}
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                SBTS00_ENB_9999_240923_000001
${4G_TARGET_SW}=                SBTS00_ENB_9999_240926_000007
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${False}
${USE_REMOTE_NODE}=             ${False}
${DOWNLOAD_PATH}=               /home/ute/Downloads
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${ONLINE_PARAMETER_DELTA}=      ${None}
${SITE_RESET_DELTA}=            ${None}
${NR_RAT_RESET_DELTA}=          ${None}
${LTE_RAT_RESET_DELTA}=         ${None}
${WCDMA_RAT_RESET_DELTA}=       ${None}
${GSM_RAT_RESET_DELTA}=         ${None}
${QC_DOMAIN}=  MN_RAN
${TEST_QC_ID}=  ${None}
${QC_PROJECT}=  RAN_VRF

*** Test Cases ***
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SW_UPGRADE_TEST
#    ...          test_iteration=${1}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          5g_source_sw=${5G_SOURCE_SW}
#    ...          5g_target_sw=${5G_TARGET_SW}
#    ...          5g_target_sw_path=${5G_TARGET_SW_PATH}
#    ...          4g_source_sw=${4G_SOURCE_SW}
#    ...          4g_target_sw=${4G_TARGET_SW}
#    ...          4g_target_sw_path=${4G_TARGET_SW_PATH}
#    ...          use_builds_storage=${USE_BUILDS_STORAGE}
#    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
#    ...          remote_node_update=${REMOTE_NODE_UPDATE}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          use_test_packages=${False}
#    ...          download_path=${DOWNLOAD_PATH}
#    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=MN_RAN
#    ...          qc_id=${None}
#    ...          qc_project=RAN_VRF

#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    OAM_RMOD_RESET
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

#
#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#    OAM_NRCEL_LOCK
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
#
#
#E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    OAM_LNCEL_LOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${TEST_QC_ID}
#    ...          qc_project=${QC_PROJECT}
#
#
#E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    OAM_LNCEL_BLOCK
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${TEST_QC_ID}
#    ...          qc_project=${QC_PROJECT}
#
#E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    [Timeout]   24h
#    OAM_NRCEL_BLOCK
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
#
#
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
#
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
#
#E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
#    ...          test_iteration=${TEST_ITERATION}
#    ...          delta_file=${ONLINE_PARAMETER_DELTA}
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
#
#
#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
#    ...          test_iteration=${TEST_ITERATION}
#    ...          delta_file=${SITE_RESET_DELTA}
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
#
#E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
#    ...          test_iteration=${TEST_ITERATION}
#    ...          delta_file=${NR_RAT_RESET_DELTA}
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
#
#E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_LTE_RAT_RESET
#    ...          test_iteration=${TEST_ITERATION}
#    ...          delta_file=${LTE_RAT_RESET_DELTA}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#
#E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_WCDMA_RAT_RESET
#    ...          test_iteration=${TEST_ITERATION}
#    ...          delta_file=${WCDMA_RAT_RESET_DELTA}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#
#E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_GSM_RAT_RESET
#    ...          test_iteration=${TEST_ITERATION}
#    ...          delta_file=${GSM_RAT_RESET_DELTA}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#
#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=${1}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          remote_vm_ip=${REMOTE_VM_IP}
#    ...          remote_mplane=${REMOTE_MPLANE}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          use_remote_node=${USE_REMOTE_NODE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    ...          report_comment=${REPORT_COMMENT}
#    ...          qc_domain=MN_RAN
##    ...          qc_id=31462
#    ...          qc_project=RAN_VRF

