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

Suite Setup       Run Keywords   Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...               should_LTE_neighbour_be_changed=${False}   AND
...               Perform Commissioning On Gnb To Onair State    prefix_tag=CB008294    update_timeout=1800


Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions

*** Variables ***
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        60
${REPORT}                           ${True}
${STOP_TEST_AFTER_FAIL}             ${False}
@{CUSTOMERS}                        TMO US
@{CRITICAL_FAULTS}                  0010  0016  1806  1868  4341  4352  4383
${SOURCE_SW}                        ${EMPTY}
${TARGET_SW}                        ${EMPTY}
${UPDATE_TEST_FAILED}               ${False}
${RESTORE_TO_TARGET_SW}             ${False}
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T06
${RP_CA}                            VRF_RRM
${QC_ID_UPGRADE}                    183386
${QC_ID_RESET}=                     217203
@{TEMP_ALLOWED_ALARMS}              4479
# 4479 Failure detected on assigned antennas
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7107  61673
# 7107 Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
# 61673 Wifi Enabled Alarm in un-commissioned state


&{BTS0}                                    node_alias=4SK060
...                                        testline_object=${tl.gnbs[0]}
...                                        source_sw=${SOURCE_SW}
...                                        target_sw=${TARGET_SW}
...                                        temporary_allowed_alarms=${TEMP_ALLOWED_ALARMS}
@{NODES}                                   ${BTS0}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
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
    [Teardown]      Custom Test Teardown

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


*** Keywords ***
Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}
