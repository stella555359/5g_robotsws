*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Marcin Flis
...                 Contact: marcin.1.flis@nokia.com

Library            DateTime                                        WITH NAME    dt
Library            taf/rfrl/csv4all/CSV4AllTestCases.py

Resource           taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource           taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot

Variables          taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Test Timeout        100h

Suite Setup         Common Suite Setup With OnAir Test Line Preparation
...                 increase_timeout_for_update_sw=1800
...                 increase_time_for_checking_cells=1800
...                 swconfig_from_path=commissionings/Krakow/7_7_UTE5GCLOUDT9SK057/swconfig.txt
...                 list_of_additional_allowed_alarms=WiFi Configuration Issue
Suite Teardown      UUF Suite Teardown


*** Variables ***
${QC_DOMAIN}                                            MN_RAN
${QC_PROJECT}                                           RAN_VRF
${RP_CA}                                                VRF_OAM
${RP_LOCATION}                                          VRF_KRK
${RP_ORGANIZATION}                                      VRF_KRK_T06
${EMAIL_RECIPIENTS}                                     None

${SOURCE_SW}                                            ${EMPTY}
${TARGET_SW}                                            ${EMPTY}

${SW_UPGRADE_ROLLBACK_TEST_QC_ID}                       41350
${SW_UPGRADE_ROLLBACK_MULTIPY_NODES_TEST_QC_ID}         None

${SERIAL_CONSOLE}                                       ${False}

${REPORT}                                               ${True}
${QC_REPORT}                                            ${True}
${STOP_TEST_AFTER_FAIL}                                 ${False}

${ITERATIONS}                                           10
@{CUSTOMERS}                                            Generic

@{ALLOWED_ALARMS_5G}                                    7513    62003    1898    7509    4478    4479
@{ALLOWED_ALARMS_4G}                                    6134    62003

&{BTS0}                                                 testline_object=${tl.gnbs[0]}
...                                                     source_sw=${SOURCE_SW}
...                                                     target_sw=${TARGET_SW}
...                                                     custom_allowed_alarms=${ALLOWED_ALARMS_5G}

@{NODES}                                                ${BTS0}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_multiple_node_upgrade
    [Timeout]   24h
    ${SOURCE_SW}=    Run Keyword If  '${SOURCE_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${SOURCE_SW}
    ${TARGET_SW}=    Run Keyword If  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${BTS0}    source_sw=${SOURCE_SW}   target_sw=${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=&{BTS0}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${SW_UPGRADE_ROLLBACK_TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    E2E PARALLEL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODES}  ${ITERATIONS}


*** Keywords ***
UUF Suite Teardown
    gnbbbu.connect    force=${True}
    Common Suite Setup With OnAir Test Line Preparation Teardown
