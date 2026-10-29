*** Settings ***
Documentation
...   author: XXX                                     # set your Name
...   contact: XXX                                    # set your email
...   Test suite for basic UUF OAM Tests in loop:

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Force Tags      CA_VRF_SiSo                           # Competence Area; for 24R3 TIs (or from older branch) set CA_VRF_WRO4

*** Variables ***
${UPDATE_TEST_ITERATION}        50          # set iteration count for SW_Upgrade_Rollback test
${SITE_RESET_TEST_ITERATION}    50          # set iteration count for Site_Reset_without_HWF test

@{CUSTOM_ALARMS}=               @{EMPTY}    # if expected alarms have appeared, add them as allowed alarms, e.g. 4003  4681  7107
@{CRITICAL_FAULTS}=             @{EMPTY}    # set FID's if any of given appears during test, test case will be stopped without any recovery action
@{CUSTOMERS_LIST}=              Generic     # list of customers e.g. TMO US, if no specific customer set Generic
${LABEL}=                       ${None}     # set label as in CM e.g. 10_16_UTESRANSISO083, in other case set name of BTS in Scout: 10_16_MRBTS-1198
${HOSTNAME}=                    ${None}     # set TL hostname like name of BTS in Scout e.g. 10_16_UTESRANSISO083_1, 10_16_MRBTS-1198
${EMAIL_RECIPIENTS}=            ${None}     # set your email if You want to be notified when a Scout SCF fetch fails
${SHOULD_BE_REPORTED}=          ${True}     # flag to enable reporting to Reporting Portal, UUF reports, KPI reports
${USE_BUILDS_STORAGE}=          ${True}     # flag to determine whether to mount external SW storage [Don't change]
${PERFORM_UBOOT_DOWNGRADE}=     ${False}    # flag to disable uboot downgrade [Don't change]
${DISABLE_SYSLOG_CHECK}=        ${False}    # flag to disable syslog verification [Don't change]
${QC_DOMAIN}=                   MN_RAN      # parameter to define under which QC Domain should be reported
${QC_PROJECT}=                  RAN_VRF     # Parameter to define under which QC project to report, e.g. RAN_VRF or RAN_ST

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          use_test_packages=${False}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${None}                      # parameter to define under which QC ID should be reported e.g. ${538552}
    ...          restore_to_target_sw=${True}       # flag to determine if Target SW should be downloaded to BTS after SW Update test [Don't change]
    ...          5g_source_sw=SBTS24R3_ENB_0000_000159_000000         # set source build. It should be loaded on eNB/gNB as precondition
    ...          5g_target_sw=SBTS00_ENB_9999_240805_000010           # set target build

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_project=${QC_PROJECT}
    ...          qc_id=${None}                      # parameter to define under which QC ID should be reported e.g. ${888321}
