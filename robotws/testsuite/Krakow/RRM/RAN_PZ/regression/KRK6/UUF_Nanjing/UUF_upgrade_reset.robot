*** Settings ***
Documentation
...   Test suite for regression testing of UUF
...   author: Mateusz Potoniec
...   contact: mateusz.potoniec@nokia.com
...   maintainer: mateusz.potoniec@nokia.com


Library            taf/rfrl/csv4all/CSV4AllTestCases.py


Test Timeout       100h


*** Variables ***
${ITERATION_SITE_RESET}                    30
${ITERATION_SW_UPGRADE_ROLLBACK}           5

${SOURCE_SW}                               SBTS25R1_ENB_0000_000242_000000
${TARGET_SW}                               SBTS00_ENB_9999_241127_000004

${SITE_RESET_TEST_QC_ID}                   None
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}          None

@{CRITICAL_ALARMS}                         0010  0016  1806  1868  4341  4352  4383
@{CUSTOM_ALLOWED_ALARMS}                   ${None}
${SERIAL_CONSOLE}                          ${False}

${REPORT}                                  ${True}
${QC_REPORT}                               ${True}
${STOP_TEST_AFTER_FAIL}                    ${False}

@{CUSTOMERS}                               Generic
${QC_DOMAIN}                               MN_RAN
${QC_PROJECT}                              RAN_VRF
${RP_LOCATION}                             VRF_KRK
${RP_ORGANIZATION}                         VRF_KRK_T06
${RP_CA}                                   VRF_RRM

&{GNB}                                     node_alias=9SK022
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        critical_alarms=${CRITICAL_ALARMS}
...                                        custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
@{NODES}                                   ${GNB}


*** Test Cases ***
SW_upgrade_rollback_with_OAM_KPI
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

E2E_TL_Activation_Reset_Test
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

Site_reset_without_HWF_with_OAM_KPI
    e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATION_SITE_RESET}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}