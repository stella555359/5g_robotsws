*** Settings ***
Documentation
...   author: Aleksandra Zalewska
...   contact: aleksandra.zalewska@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Force Tags      CA_VRF_WRO4

*** Variables ***
${UPDATE_TEST_ITERATION}        10
${SITE_RESET_TEST_ITERATION}    10

@{CUSTOM_ALARMS}=               @{EMPTY}
@{CRITICAL_FAULTS}=             @{EMPTY}
@{CUSTOMERS_LIST}=              Generic
${LABEL}=                       CLOUD_10_16_UTESRANSISO062
${HOSTNAME}=                    10_16_UTESRANSISO062_1
${EMAIL_RECIPIENTS}=            aleksandra.zalewska@nokia.com
${5G_SOURCE_SW}=                SBTS24R3_ENB_0000_000034_000000
${5G_TARGET_SW}=                SBTS00_ENB_9999_240904_000009
${SHOULD_BE_REPORTED}=          ${True}
${RESTORE_TARGET_SW}=           ${True}

${USE_BUILDS_STORAGE}=          ${True}
${PERFORM_UBOOT_DOWNGRADE}=     ${False}
${DISABLE_SYSLOG_CHECK}=        ${False}
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          label=${LABEL}
    ...          hostname=${HOSTNAME}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TARGET_SW}
    ...          use_test_packages=${False}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${62394}
    ...          qc_project=${QC_PROJECT}

#prawodpodobnie do usunięcia
#E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    UUF4ALL_SITE_RESET_TEST
#    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          label=${LABEL}
#    ...          hostname=${HOSTNAME}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          qc_domain=${QC_DOMAIN}
#    ...          qc_id=${}
#    ...          qc_project=${QC_PROJECT}
