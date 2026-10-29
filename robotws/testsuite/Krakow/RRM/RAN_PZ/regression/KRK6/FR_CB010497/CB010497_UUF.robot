*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010497
...   author: Mateusz Potoniec
...   contact: mateusz.potoniec@nokia.com
...   maintainer: mateusz.potoniec@nokia.com


Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            ./resources/qc_variables.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables          taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout        100h

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 increase_timeout_for_update_sw=2000
...                 increase_time_for_checking_cells=2000
...                 swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT4SK059/swconfig.txt
Suite Teardown      Common Suite Setup With OnAir Test Line Preparation Teardown

*** Variables ***
${SITE_RESET_TEST_ITERATION}               30
${ITERATION_SW_UPGRADE_ROLLBACK}           5

${SOURCE_SW}                               ${EMPTY}
${TARGET_SW}                               ${EMPTY}

${SITE_RESET_TEST_QC_ID}                   ${None}
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          ${None}
${SW_ACTIVATION_TEST_QC_ID}                ${None}

@{CRITICAL_ALARMS}                         0010  0016  1806  1868  4341  4352  4383
@{CUSTOM_ALLOWED_ALARMS}                   62003  4479
${SERIAL_CONSOLE}                          ${False}
@{IGNORED_PRINTS}                          is not defined in SysinfoQuota.xml. Please contact the owner

${REPORT}                                  ${True}
${QC_REPORT}                               ${True}
${STOP_TEST_AFTER_FAIL}                    ${False}

@{CUSTOMERS}                               Generic
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_SiSo

&{GNB}                                     node_alias=4SK059
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}
...                                        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                        syslog_ignored_prints=${IGNORED_PRINTS}
@{NODES}                                   ${GNB}


*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${GNB}    source_sw=${SOURCE_SW}   target_sw=${TARGET_SW}

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_UPGRADE_ROLLBACK}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h

    ${setup_sw_gnb}=    Get SW From BTS
    ${release}=    Get Release From SW    ${setup_sw_gnb}
    ${site_reset_test_qc_id}=    Get QC TAG From Release    test_name=E2E_TL_Activation_Reset_with_OAM_KPI
    ...                                                      release=${release}
    Set Suite Variable    ${SITE_RESET_TEST_QC_ID}    ${site_reset_test_qc_id}

    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
