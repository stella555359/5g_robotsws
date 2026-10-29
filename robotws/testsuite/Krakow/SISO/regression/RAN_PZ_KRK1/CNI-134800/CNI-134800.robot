*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI-134800
...   author: Marcin Bereznicki
...   author/contact: marcin.bereznicki.com


Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME    Cells
Library     taf.rfrl.csv4all.CSV4AllTestCases
Library     taf.rfrl.utilities.cloud_manager.artifacts
Library     testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library     ../resources/python/common.py
Library     ./resources/resources.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/common.robot
Resource    ../resources/robot/tput.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Run Keywords    Common Suite Setup With OnAir Test Line Preparation     prefix_tag=CNI-134800_old_scf
...                               AND
...                               Load RU Matrix    CNI-134800_L3_call_matrix
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions With Watching Alarms
Test Teardown     Common Postconditions With Watching Alarms


*** Variables ***
#TEST CONFIGURATION
${UPDATE_TEST_ITERATION}                ${1}
${SOURCE_SW}                            ${None}
${TARGET_SW}                            ${None}
${CUSTOMERS_LIST}                       ${None}
@{CUSTOM_ALARMS}                        @{EMPTY}
${SYSLOG_IGNORED_PRINTS}                ${None}
&{NODE1}                                testline_object=${tl.gnbs[0]}
...                                     source_sw=${SOURCE_SW}
...                                     target_sw=${TARGET_SW}
...                                     custom_allowed_alarms=${CUSTOM_ALARMS}
...                                     syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
@{NODES}                                ${NODE1}

${smodBoardConfigType_before_update}    NRFDD_and_NRTDD_NRTDD
${smodBoardConfigType_after_update}     NRTDD_NRFDD_and_NRTDD

#L3 CALL
${reboot_ue}                            False
${capabilities}                         REAL_UE
${duration}                             180s
${parallel_streams_dl}                  4
${parallel_streams_ul}                  4
${size_packet}                          1400B
${deviation}                            20%
${size_packet_dl}                       1400B
${size_packet_ul}                       1400B
${interval}                             1
${omit}                                 5
${alias}                                UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
${timeout_reboot_ue}                    100

#RF MATRIX
${RFS_ALIAS}                            Matrix
${RF_VENDOR}                            RFLIGHT
${RF_IP}                                10.255.27.71
${RF_MODEL}                             NT-4X64NS


*** Test Cases ***
[1][1.0] CNI-134800_Commisioning_old_configuration
    [Timeout]    20h
    Cells.Verify All Cells Are onAiR
    Verify Smodboardconfigtype Value  ${smodBoardConfigType_before_update}  ${smodBoardConfigType_after_update}
    Verify SmodBoardConfigType Can Be Set Incorrectly      value=${smodBoardConfigType_before_update}
    Verify Smodboardconfigtype Value  ${smodBoardConfigType_before_update}  ${smodBoardConfigType_after_update}

[1][1.0] CNI-134800_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call_from_25R2_to_N
    [Timeout]    20h
    [Setup]      Custom Test Setup
    Prepare Ue
    Set To Dictionary     ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary     ${NODE1}    target_sw    ${TARGET_SW}
    Verify Smodboardconfigtype Value  ${smodBoardConfigType_before_update}  ${smodBoardConfigType_after_update}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    ...                                     l3_call_method=Custom parameter check and L3 call
    [Teardown]    Custom Test Teardown

*** Keywords ***
Custom parameter check and L3 call
    [Arguments]   ${cells}=None
    Set Test Variable    ${cells}
    Verify Smodboardconfigtype Value  ${smodBoardConfigType_before_update}  ${smodBoardConfigType_after_update}
    Run L3 call on all cells one by one and verify tput

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error   Remove Directory    path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Teardown
    gnbbbu.connect          force=${True}
    Common Postconditions   collect_snapshot_from_ru=${False}
