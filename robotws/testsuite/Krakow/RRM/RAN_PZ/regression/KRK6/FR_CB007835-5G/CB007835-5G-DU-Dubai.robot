*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Mateusz Potoniec
...   contact: mateusz.potoniec@nokia.com
...   maintainer: mateusz.potoniec@nokia.com


Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables          taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout        100h

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 increase_timeout_for_update_sw=1800
...                 increase_time_for_checking_cells=1800
...                 swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT8SK150/swconfig.txt
Suite Teardown      Common Suite Setup With OnAir Test Line Preparation Teardown

*** Variables ***
${ITERATION_SITE_RESET}                    10
${ITERATION_SW_UPGRADE_ROLLBACK}           5
${ITERATION_SW_ACTIVATION}                 10

${SOURCE_SW}                               ${None}
${TARGET_SW}                               ${None}

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

@{CUSTOMERS}                               DU Dubai
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_SiSo

&{GNB}                                     node_alias=11SK150
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}
...                                        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                        syslog_ignored_prints=${IGNORED_PRINTS}
@{NODES}                                   ${GNB}


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
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

E2E_TL_Site_Reset_with_OAM_KPI
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_SW_ACTIVATION
    e2e_tl_sw_activation_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SW_ACTIVATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SW_ACTIVATION_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
