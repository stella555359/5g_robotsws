*** Settings ***
Documentation
...   Test suite for regression testing of UUF
...   author: Piotr Bacior
...   contact: piotr.bacior@nokia.com

Library      String
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30

${SHOULD_BE_REPORTED}=  True
${CUSTOMERS_LIST}=      ${None}      # Customer list separated by comma
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
${5G_SOURCE_SW}=        ${None}
${5G_TARGET_SW}=        ${None}
${4G_SOURCE_SW}=        ${None}
${4G_TARGET_SW}=        ${None}
${UPDATE_TEST_FAILED}   ${False}
${QC_DOMAIN}=           MN_RAN
${QC_PROJECT}=          RAN_VRF
${QC_ID_UPGRADE}=       ${None}
${QC_ID_RESET}=         ${None}
@{CUSTOM_ALARMS}=       @{EMPTY}
${BTS_HOST_IP}          192.168.255.129

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  ${None}
${RP_LOCATION}                      VRF_KRK

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

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
    ...          use_remote_node=${False}

    [Teardown]    Custom Test Teardown for UUF

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]    96h

    Run Keyword If  '${QC_ID_RESET}'!='${None}'    Set Tags    QC_${QC_ID_RESET}
    gnbbbu.Disconnect
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_RESET}
    ...          qc_project=${QC_PROJECT}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          use_remote_node=${False}

    [Teardown]    Custom Test Teardown

*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...               increase_timeout_for_update_sw=${900}

    ${5G_SOURCE_SW}=    Run Keyword If  '${5G_SOURCE_SW}'=='${None}'
    ...                     Get Source SW
    ...                 ELSE
    ...                     Set Test Variable  ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    Run Keyword If  '${5G_TARGET_SW}'=='${None}'
    ...                     Get Target SW
    ...                 ELSE
    ...                     Set Test Variable  ${5G_TARGET_SW}

    @{CUSTOMERS_LIST}=    Run Keyword If  '${CUSTOMERS_LIST}'!='${None}'
    ...                     Split String    ${CUSTOMERS_LIST}    ,
    ...                   ELSE
    ...                     Create List    Generic
    Set Suite Variable    ${5G_SOURCE_SW}
    Set Suite Variable    ${5G_TARGET_SW}
    Set Suite Variable    @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown for UUF
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed


Custom Test Teardown
    # In UUF4ALL swconfig is restored at the end of test case(without waiting to oan Air)
    # to delete when it will be implemented in UU4ALL
    Sleep    120    reason=Waiting for BTS to be up
    Wait Until Keyword Succeeds     600 sec     10 sec   gnbcell.Verify All Cells are OnAir
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
