*** Settings ***
Documentation
...   Test suite for CB008490 UUF tests
...   author: Piotr Brzezicki piotr.brzezicki@nokia.com
...   maintainer: Piotr Brzezicki piotr.brzezicki@nokia.com

Library    taf.rfrl.csv4all.CSV4AllTestCases
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.software.Software      WITH NAME    sw
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.setups.Setups          WITH NAME    st
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK6.FR_CB008490.resources.teardowns.Teardowns    WITH NAME    td

Variables          ./resources/variables/uuf.py

Suite Setup        st.cb008490_suite_setup    ue_in_use=${False}
Suite Teardown     td.cb008490_suite_teardown

Test Setup         st.run_common_preconditions
Test Teardown      td.run_common_postconditions    collect_mandatory_logs=never

Test Timeout       84h

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    sw.set_src_and_tgt_sw_to_nodes    nodes=${NODES}    sw_type=cm_artifacts
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_UPGRADE}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...    use_testpackage=${USE_TESTPACKAGE}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Activation_Reset_Test
    sw.set_src_and_tgt_sw_to_nodes    nodes=${NODES}    sw_type=target_sw
    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_RESET}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
