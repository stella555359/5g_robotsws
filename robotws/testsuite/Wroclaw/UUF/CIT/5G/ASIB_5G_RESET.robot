*** Settings ***
Documentation
...   author: Lukasz Klosinski
...   modified by: Tomasz Szylkowski
...   contact: lukasz.klosinski@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Force Tags  CIT  QCD_MN_RAN  QCP_RAN_VRF  QC_43302  CA_VRF_WRO3  PY39

Resource         taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource         taf/rfrl/uuf4all/uuf4all_keywords.robot
Library          ../../resources/common/additional.py
Variables        ../../resources/common/mail_list.py

*** Variables ***
${TEST_ITERATION}=              5
@{CUSTOM_ALARMS}=               4681
${REMOTE_VM_IP}=                ${None}
${REMOTE_MPLANE}=               ${None}
${LABEL}=                       ${None}
${HOSTNAME}=                    ${None}
@{CRITICAL_FAULTS}=             @{EMPTY}
${SHOULD_BE_REPORTED}=          ${True}
@{CUSTOMERS_LIST}=              Generic
${USE_REMOTE_NODE}=             ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
@{USER_SUSPICIOUS_PRINTS}=      @{EMPTY}
${REPORT_COMMENT}=              ASIB_5G_RESET_UUFWRO3
${QC_DOMAIN}=                   MN_RAN
${TEST_QC_ID}=                  43302
${QC_PROJECT}=                  RAN_VRF
${ALARM_TIMEOUT}=               180
${HARDWARE_CHECK_TIMEOUT}=      1200
${DISABLE_KPI}=                 ${False}
@{SYSLOG_IGNORED_PRINTS}=       INF
${FORCE_FAIL}=                  ${False}
${EMAIL_RECIPIENTS}=            ${UUF_EMAIL_RECIPIENTS}  #email or emails separate by comma eg. name@nokia.com,name@nokia.com
${MUMIN_CONFIG_FILE}=           ${None}  # PATH TO MUMIN/LMI BOARD CONFIG YAML FILE
${SERIAL_CONSOLE}=              ${False}  # set to True if testing with serial console

*** Test Cases ***
E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_ASIB_5G_RESET
    [Timeout]   100h
    run keyword if  '${FORCE_FAIL}'=='${True}'  Fail  forced to fail
    ${HOSTNAME}=       additional.get_scout_hostname
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
