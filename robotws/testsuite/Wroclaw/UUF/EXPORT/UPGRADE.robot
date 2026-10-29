*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   modified by: Tomasz Szylkowski
...   contact: tomasz.szylkowski@nokia.com
...   Example test suite to perform 3 upgrade-rollbacks

Resource                        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource                        taf/rfrl/uuf4all/uuf4all_keywords.robot
Force Tags                      CA_VRF_WRO3  PY39

*** Variables ***
${TEST_ITERATION}=              3
@{CUSTOM_ALARMS}=               4694
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          ${False}
@{CUSTOMERS_LIST}=              Generic
${5G_SOURCE_SW}=                ${None}
${5G_TARGET_SW}=                ${None}
${5G_TARGET_SW_PATH}=           ${None}
${4G_SOURCE_SW}=                ${None}
${4G_TARGET_SW}=                ${None}
${4G_TARGET_SW_PATH}=           ${None}
${REMOTE_NODE_UPDATE}=          ${False}
${USE_REMOTE_NODE}=             ${False}
${DOWNLOAD_PATH}=               ${None}
${USE_BUILDS_STORAGE}=          ${False}
${USE_TEST_PACKAGES}=           ${False}
${RESTORE_TARGET_SW}=           ${False}
${PERFORM_UBOOT_DOWNGRADE}=     ${True}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              UUF_EXAMPLE
${QC_DOMAIN}=                   MN_RAN_ST
${TEST_QC_ID}=                  ${None}  # SHOULD BE DIFFERENT FOR EACH TEST CASE ACCORDING TO QC_ID OF EACH TEST
${QC_PROJECT}=                  RAN_ST
${ALARM_TIMEOUT}=               120
${HARDWARE_CHECK_TIMEOUT}=      900
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
${EMAIL_RECIPIENTS}=            ${None}  # email or emails separate by comma eg. name@nokia.com,name@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}  # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${SERIAL_CONSOLE}=              ${False}  # set to True if testing with serial console
${VIRTUALENV_DIR}=              ${None}  # path to virtual env used in starting syslog on remote vm

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_EXAMPLE
    [Timeout]   100h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    ${5G_SOURCE_SW}=    run keyword if  '${5G_SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    run keyword if  '${5G_TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${5G_TARGET_SW}
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION}
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
    ...          use_test_packages=${USE_TEST_PACKAGES}
    ...          download_path=${DOWNLOAD_PATH}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    ...          report_comment=${REPORT_COMMENT}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${TEST_QC_ID}
    ...          qc_project=${QC_PROJECT}

