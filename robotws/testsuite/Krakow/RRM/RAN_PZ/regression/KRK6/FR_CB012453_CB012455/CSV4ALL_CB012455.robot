*** Settings ***
Documentation
...   author: Sara Nowak
...   contact: sara.nowak@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      ./resources/qc_variables.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/l3_call_variables.py
Resource     ./resources/suite_specific_keywords.robot

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...                         increase_timeout_for_update_sw=${1800}
...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                         should_LTE_neighbour_be_changed=${True}
...                         check_truck_roll=${False}
...                         prefix_tag=25R3_N_CB012455_3a
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30
${REPORT}                           ${True}
${STOP_TEST_AFTER_FAIL}             ${False}
@{CUSTOMERS}                        General
@{CRITICAL_FAULTS}                  0010  0016  1806  1868  4341  4352  4383
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${UPDATE_TEST_FAILED}               ${False}
${RESTORE_TO_TARGET_SW}             ${False}
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_CA}                            VRF_RRM
${SITE_RESET_TEST_QC_ID}            None
${SW_UPGRADE_ROLLBACK_TEST_QC_ID}   None

@{TEMP_ALLOWED_ALARMS}              4479

@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7107  61673

&{BTS0}                                    node_alias=8SK042
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        temporary_allowed_alarms=${TEMP_ALLOWED_ALARMS}
@{NODES}                                   ${BTS0}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_with_L3_Call
    [Setup]      Prepare Ue for L3 Call    alias=UE2    capabilities=MTP_UE   reboot_ue=False
    [Timeout]    96h

    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${BTS0}    source_sw=${SOURCE_SW}    target_sw=${TARGET_SW}

    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=&{BTS0}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_UPGRADE}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...    l3_call_method=Attach and Verify DL&UL data transfer

    [Teardown]   Run Keyword and Ignore Error    ue.Detach Ue    UE2

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h

    ${setup_sw_gnb}=    Get SW From BTS
    ${release}=    Get Release From SW    ${setup_sw_gnb}
    ${site_reset_test_qc_id}=    Get QC TAG From Release    test_name=E2E_TL_Activation_Reset_with_OAM_KPI
    ...                                                      release=${release}
    Set Suite Variable    ${SITE_RESET_TEST_QC_ID}    ${site_reset_test_qc_id}


    e2e_tl_activation_reset_test
    ...    nodes_details=${NODES}
    ...    test_nodes_details=&{BTS0}
    ...    iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SITE_RESET_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
