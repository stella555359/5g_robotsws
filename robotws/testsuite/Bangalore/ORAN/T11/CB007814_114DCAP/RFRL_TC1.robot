*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource       /home/ute/robotws/testsuite/Bangalore/ORAN/resources/rfrl/uuf4all/uuf4all_test_cases.robot
Resource       taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource       /home/ute/robotws/testsuite/Bangalore/ORAN/resources/rfrl/uuf4all/uuf4all_keywords.robot
Force Tags     VRF_BLR1_T08_VRF_RRM    CA_VRF_BLR1

*** Variables ***
${UPGRADE_ITERATION}=           5
${TEST_ITERATION}=              5
${SITE_RESET_ITERATION}=        15
${COMMISSIONING_ITERATION}=     5
@{CUSTOM_ALARMS}=               4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  8000    7420
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}                        ${None}
${HOSTNAME}                     10_2_BTS1236
@{CRITICAL_FAULTS}=             10    4383    6450
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              Generic
${5G_SOURCE_SW}                 SBTS25R2_ENB_9999_241028_000008
${5G_TARGET_SW}                 SBTS25R2_ENB_9999_241106_000006
${5G_TARGET_SW_PATH}=           /home/ute/Downloads/SBTS00_ENB_9999_241106_000006_release_BTSSM_downloadable_A54.zip
${4G_SOURCE_SW}=                ${None}
${4G_TARGET_SW}=                ${None}
${REMOTE_NODE_UPDATE}=          ${False}
${USE_REMOTE_NODE}=             ${False}
${DOWNLOAD_PATH}=               ${False}
${USE_BUILDS_STORAGE}=          ${False}
${RESTORE_TARGET_SW}=           ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ${None}
${ONLINE_PARAMETER_DELTA}      /home/ute/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/1036/Online.json
${SITE_RESET_DELTA}            /home/ute/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/1036/Site_Reset.json
${NR_RAT_RESET_DELTA}          /home/ute/robotws/testsuite/Wroclaw/RRM/WRO2_3/uuf/1036/NR_RAT.json
#&{RU1}                          model=GUDE  host=10.42.224.190  port=@{9, }  version=8221-1
#&{RU2}                          model=GUDE  host=10.42.224.190  port=@{7, }  version=8221-1
#&{RU3}                          model=GUDE  host=10.42.224.190  port=@{10, }  version=8221-1
#&{RU4}                          model=GUDE  host=10.42.224.190  port=@{5, }  version=8221-1
#&{RU5}                          model=GUDE  host=10.42.224.190  port=@{11, }  version=8221-1
#@{PDU_LIST}=                    &{RU1}  &{RU2}  &{RU3}  &{RU4}  &{RU5}
${ALARM_TIMEOUT}=               420
${HARDWARE_CHECK_TIMEOUT}=      800
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            konstantin.lileev@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}  # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${MUMIN}=                       ${None}  # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${VIRTUALENV_DIR}=              ${None}  # path to virtual env used in starting syslog on remote vm
#    EXAMPLE PATH: /home/ute/.pyenv/versions/3.6.10/envs/test_repo/
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF

*** Test Cases ***
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    [Timeout]   24h
#    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
#    ...                                       kpi2b=500
#    ...                                       kpi2c=500
#    ...                                       kpi2d=500
#    Set Test Variable  ${ALARM_TIMEOUT}  180
#    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
#    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
#    UUF4ALL_SW_UPGRADE_TEST
#    ...          test_iteration=${UPGRADE_ITERATION}
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

#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=${SITE_RESET_ITERATION}
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
#
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
#
#
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
#
#E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
#    ...          test_iteration=${COMMISSIONING_ITERATION}
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
#
#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
#    ...          test_iteration=${COMMISSIONING_ITERATION}
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
#
#E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
#    [Timeout]   24h
#    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
#    ...          test_iteration=${COMMISSIONING_ITERATION}
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
#

*** Keywords ***

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

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=${COMMISSIONING_ITERATION}
    ...          delta_file=${ONLINE_PARAMETER_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=${COMMISSIONING_ITERATION}
    ...          delta_file=${SITE_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=${COMMISSIONING_ITERATION}
    ...          delta_file=${NR_RAT_RESET_DELTA}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          remote_vm_ip=${REMOTE_VM_IP}
    ...          remote_mplane=${REMOTE_MPLANE}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          use_remote_node=${USE_REMOTE_NODE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          should_be_reported=${SHOULD_BE_REPORTED}

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

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    OAM_BBMOD_RESET
    ...          test_iteration=${TEST_ITERATION_BB_Reset}
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

