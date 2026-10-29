*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
Force Tags     CA_VRF_BLR1

*** Variables ***
${TEST_ITERATION_UPG}=          3
${TEST_ITERATION_RST}=		20
@{CUSTOM_ALARMS}=               4694,4297
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              Generic
${5G_SOURCE_SW}=                SBTS00_ENB_9999_241122_000014
${5G_TARGET_SW}=                SBTS00_ENB_9999_241122_000016
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                ${None}
${4G_TARGET_SW}=                ${None}
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${True}
${USE_REMOTE_NODE}=             ${True}
${DOWNLOAD_PATH}=               /home/ute/UUF_SW
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${ONLINE_PARAMETER_DELTA}=      ${None}
${SITE_RESET_DELTA}=            ${None}
${NR_RAT_RESET_DELTA}=          ${None}
${LTE_RAT_RESET_DELTA}=         ${None}
${WCDMA_RAT_RESET_DELTA}=       ${None}
${GSM_RAT_RESET_DELTA}=         ${None}
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID}=                  qc_id  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${QC_PROJECT}=                  RAN_VRF
#    EXAMPLE PDU Variable
#    &{RU1}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{3, }  version=8221-1
#    &{RU2}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{4, }  version=8221-1
#    &{RU3}                     model=GUDE  host=10.XXX.XXX.XXX  port=@{5, }  version=8221-1
#    @{PDU_LIST}=               &{RU1}  &{RU2}  &{RU3}
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            ${None}  # email or emails separate by comma eg. name@nokia.com,name@nokia.com
#${MUMIN_CONFIG_FILE}=           ${None}  # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${VIRTUALENV_DIR}=              ${None}  # path to virtual env used in starting syslog on remote vm
#    EXAMPLE PATH: /home/ute/.pyenv/versions/3.6.10/envs/test_repo/



*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION_UPG}
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
    ...          qc_id=${69846}
    ...          qc_project=${QC_PROJECT}


E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=650
    ...                                       kpi2b=650
    ...                                       kpi2c=620
    ...                                       kpi2d=650
    ...                                       kpi51a=650
    ...                                       kpi51b=650
    ...                                       kpi16a=650
    ...                                       kpi16b=650
    ...                                       kpi1a=650
    ...                                       kpi1b=650
    ...                                       kpi1c=650
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${TEST_ITERATION_RST}
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
    ...          qc_id=${69796}
    ...          qc_project=${QC_PROJECT}

#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=630
#    ...                                       kpi2b=500
#    ...                                       kpi2c=620
#    ...                                       kpi2d=500
#    ...                                       kpi51a=500
#    ...                                       kpi51b=500
#    ...                                       kpi16a=500
#    ...                                       kpi16b=500
#    Set Test Variable  ${ALARM_TIMEOUT}  180
#    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
#    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
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
#    ...          qc_id=${852716}
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=650
#    ...                                       kpi2b=650
#    ...                                       kpi2c=620
#    ...                                       kpi2d=500
#    ...                                       kpi51a=500
#    ...                                       kpi51b=500
#    ...                                       kpi16a=500
#    ...                                       kpi16b=500
#    Set Test Variable  ${ALARM_TIMEOUT}  180
#    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
#    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
#    OAM_RMOD_RESET
#    ...          test_iteration=${2}
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
##    ...          qc_id=${852718}
#    ...          qc_id=${31491}
#    ...          qc_project=${QC_PROJECT}

#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=630
#    ...                                       kpi2b=500
#    ...                                       kpi2c=620
#    ...                                       kpi2d=500
#    ...                                       kpi51a=500
#    ...                                       kpi51b=500
#    ...                                       kpi16a=500
#    ...                                       kpi16b=500
#    OAM_NRCEL_LOCK
#    ...          test_iteration=${10}
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
# #   ...          qc_id=${852717}
#    ...          qc_id=${31490}
#    ...          qc_project=${QC_PROJECT}



#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    OAM_BBMOD_RESET
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





#E2E_TL_BTS_Block_Unblock
#    [Timeout]   24h
#    BTS_BLOCK_UNBLOCK
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

#E2E_TL_RU_Lock_Unlock
#    [Timeout]   24h
#    RMOD_LOCK_UNLOCK
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


#E2E_TL_RU_Power_Reset
#    [Timeout]   24h
#    RMOD_POWER_RESET
#    ...          pdu_list=${pdu_list}
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
