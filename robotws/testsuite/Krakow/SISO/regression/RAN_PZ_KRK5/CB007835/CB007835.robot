*** Settings ***
Documentation
...   Test suite for regression testing of UUF
...   author: Michal Zajac
...   contact: michal.zajac@nokia.com

Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               increase_timeout_for_update_sw=3600
...               list_of_additional_allowed_alarms=@{CUSTOM_ALARMS}

Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
...               collect_syslog=${False}

*** Variables ***
${UPDATE_TEST_ITERATION}            20
${SITE_RESET_TEST_ITERATION}        200

${SHOULD_BE_REPORTED}=  True
@{CUSTOMERS_LIST}=      Generic
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
${5G_SOURCE_SW}=        ${None}
${5G_TARGET_SW}=        ${None}
${4G_SOURCE_SW}=        ${None}
${4G_TARGET_SW}=        ${None}
${UPDATE_TEST_FAILED}   ${False}
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_VRF
${QC_ID_UPGRADE}=       41052
${QC_ID_RESET}=         41051
@{CUSTOM_ALARMS}=       6134  7509  6351
${RP_CA}                VRF_SiSo
${RP_LOCATION}          VRF_KRK
${RP_ORGANIZATION}      VRF_KRK_T06

${MUMIN}                ${True}
${MUMIN_CONFIG_FILE}=   /home/ute/testline_configuration/7_7_UTE5GCLOUDT9SK024/rmod_config.yaml

*** Test Cases ***
SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/
    ${5G_SOURCE_SW}=    run keyword if  '${5G_SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    run keyword if  '${5G_TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${5G_TARGET_SW}

    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          4g_source_sw=${4G_SOURCE_SW}
    ...          4g_target_sw=${4G_TARGET_SW}
    ...          use_builds_storage=${False}
    ...          restore_to_target_sw=${True}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_UPGRADE}
    ...          qc_project=${QC_PROJECT}
    ...          custom_alarms=${CUSTOM_ALARMS}

Site_reset_without_HWF_with_OAM_KPI
    [Timeout]    96h
    Remove Dirs       directory_path=/home/ute/UUF_SW/  /home/ute/.ute-ca/cache/bts/

    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_RESET}
    ...          qc_project=${QC_PROJECT}
    ...          custom_alarms=${CUSTOM_ALARMS}

*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END
