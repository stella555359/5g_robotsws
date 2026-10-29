*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI-120690
...   author: Marcin Bereznicki, Szymon Skorupski
...   author/contact: marcin.bereznicki.com, szymon.skorupski@nokia.com


Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations       WITH NAME    Cells
Library     taf.rfrl.csv4all.CSV4AllTestCases    WITH NAME    csv_tc
Library     taf.rfrl.utilities.cloud_manager.artifacts
Library     testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library     ../resources/python/common.py
Library     testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CNI-134800/resources/resources.py
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/common.robot
Resource    ../resources/robot/tput.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Run Keywords    Common Suite Setup With OnAir Test Line Preparation     prefix_tag=CNI120690
...                               AND
...                               Load RU Matrix    CNI120690_L3_call_matrix
Suite Teardown    Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     Common Postconditions With Restore Configuration If Test Failed   collect_syslog=${False}


*** Variables ***
#TEST CONFIGURATION
${UPDATE_TEST_ITERATION}                1
${SITE_RESET_TEST_ITERATION}            3
${SOURCE_SW}                            ${None}
${TARGET_SW}                            ${None}
@{CUSTOMERS_LIST}                       Reliance India
${RP_CA}                                VRF_SiSo
${RP_ORGANIZATION}                      VRF_KRK_T01
${RP_LOCATION}                          VRF_KRK
@{CUSTOM_ALARMS}                        @{EMPTY}
${SYSLOG_IGNORED_PRINTS}                ${None}
&{NODE1}                                testline_object=${tl.gnbs[0]}
...                                     source_sw=${SOURCE_SW}
...                                     target_sw=${TARGET_SW}
...                                     custom_allowed_alarms=${CUSTOM_ALARMS}
...                                     syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
@{NODES}                                ${NODE1}

${smodBoardConfigType_before_update}    NRFDD_NRTDD
${smodBoardConfigType_after_update}     NRFDD_NRTDD_1

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
CNI-120690_19_Migration_from_temporary_to_final_solution_for_CNI_120690_activation_during_SW_upgrade_to_25R1
    [Timeout]    20h
    [Setup]      Custom Test Setup
    Prepare Ue
    Set To Dictionary     ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary     ${NODE1}    target_sw    ${TARGET_SW}
    Verify Smodboardconfigtype Value  ${smodBoardConfigType_before_update}  ${smodBoardConfigType_after_update}
    csv_tc.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    ...                                     l3_call_method=Custom parameter check and L3 call
    [Teardown]    Custom Test Teardown


CNI-120690_4_Manual_SISO_SM_BTS_Site_Reset
    [Timeout]    160h
    Set Test Variable    @{CRITICAL_FAULTS}     0010  0016  1806  1868  4341  4352  4383
    gnbbbu.Disconnect
    csv_tc.E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
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

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}

Custom Test Teardown
    gnbbbu.connect          force=${True}
    Common Postconditions   collect_snapshot_from_ru=${False}