*** Settings ***
Documentation
...   Testsuite for regression testing of feature CB013351
...   author: Maciej Russek, maciej.russek@nokia.com
...   maintainer: Maciej Russek, maciej.russek@nokia.com

Library      String
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf.rfrl.csv4all.CSV4AllTestCases    WITH NAME    csv_tc
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB012685/CB012685_resources.robot

Test Setup        Custom test setup
Test Teardown     Custom test teardown
Suite Setup       Custom suite setup
Suite Teardown    Common suite teardown

*** Variables ***
${SOURCE_SW}                              ${None}
${TARGET_SW}                              ${None}
@{CUSTOMERS_LIST}                         Generic
${REPORT}                                 ${True}
${RESTORE_TO_TARGET_SW}                   ${True}
&{NODE1}                                  testline_object=${tl.gnbs[0]}
@{NODES}                                  ${NODE1}
${UPDATE_TEST_ITERATION}                  5
${QC_DOMAIN}                              MN_RAN
${QC_PROJECT}                             RAN_VRF
${RP_CA}                                  VRF_OAM
${RP_ORGANIZATION}                        VRF_KRK_T02
${RP_LOCATION}                            VRF_KRK
${SCOUT_HOSTNAME}                         7_7_UTE5GCLOUDT11SK101
${SERIAL_CONSOLE}                         ${False}

*** Test Cases ***
[1][1.0] CB013351_Config1a_E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    Set to dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set to dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    E2E TL SW upgrade rollback with OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${UPDATE_TEST_ITERATION}
    ...    report=${REPORT}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    sw_build=${TARGET_SW}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}

*** Keywords ***
Custom Test Setup
    common_setups_and_teardowns.Common preconditions    collect_syslog=${False}
    Run keyword and ignore error    Remove directory    path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.Connect    force=${True}
    common_setups_and_teardowns.Common postconditions with restore configuration if test failed

Custom Suite Setup
    Common suite setup with OnAir Test Line preparation
    ...    prefix_tag=CB013351_UUF
    ${SOURCE_SW} =    IF    '${SOURCE_SW}'=='${None}'    Get CM source build    ELSE    Set variable    ${SOURCE_SW}
    ${TARGET_SW} =    IF    '${TARGET_SW}'=='${None}'    Get target Build       ELSE    Set variable    ${TARGET_SW}
    ${REPORT} =    Evaluate    '${REPORT}'=='True'
    ${RESTORE_TO_TARGET_SW} =    Evaluate    '${RESTORE_TO_TARGET_SW}'=='True'
    Set global variable    ${SOURCE_SW}
    Set global variable    ${TARGET_SW}
    Set global variable    @{CUSTOMERS_LIST}
    Set global variable    ${REPORT}
    Set global variable    ${RESTORE_TO_TARGET_SW}
