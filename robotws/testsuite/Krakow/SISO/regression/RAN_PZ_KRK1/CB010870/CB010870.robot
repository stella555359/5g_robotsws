*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010870
...   author: Szymon Skorupski
...   author/contact: szymon.skorupski@nokia.com


Library     taf.rfrl.csv4all.CSV4AllTestCases    WITH NAME    csv_tc
Resource    testsuite/Krakow/resources/UUF/uuf_with_upgrade_paths.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource    ../resources/robot/common.robot
Resource    ../resources/robot/tput.robot
Resource    ../resources/rjio_procedures/General_SiSo_Cell_block_and_unblock.robot
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables   ./resources/variables.py


Suite Setup       Run Keywords    Common Suite Setup With OnAir Test Line Preparation
...                               prefix_tag=${prefix_tag}
...                               increase_timeout_for_update_sw=${1800}
...                               increase_time_for_checking_radios=${1800}
...                               AND
...                               Run Keyword If  "7-7-UTE5GCLOUDT8SK134" in "${tl.test_pcs[0].default_ssh_connection_details.addr}"
...                               load_ru_matrix    ${prefix_tag_L3_call}
Suite Teardown    Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     Common Postconditions With Restore Configuration If Test Failed   collect_syslog=${False}


*** Variables ***
# RF Matrix
${RFS_ALIAS}            Matrix
${RF_VENDOR}            RFLIGHT
${RF_IP}                10.255.27.56
${RF_MODEL}             NT-4X64NS

# Commissioning
${prefix_tag}           CB010870_2xAVQA
${prefix_tag_L3_call}   CB010870_L3_call

# UUF
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        50
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${CRITICAL_ALARMS}                  ${None}
${BTS_HOST_IP}                      192.168.255.129
${SCOUT_HOSTNAME}                   7_7_UTE5GCLOUDT11SK054
${SERIAL_CONSOLE}=                  ${False}
&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 critical_alarms=${CRITICAL_ALARMS}

@{NODES}                            ${NODE1}
${QC_DOMAIN}=                       MN_RAN
${QC_PROJECT}=                      RAN_VRF
${QC_ID_UPGRADE}=                   125713
${QC_ID_RESET}=                     196387
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T01
${RP_LOCATION}                      VRF_KRK

# Throughput
${reboot_ue}                        False
${capabilities}                     REAL_UE
${duration}                         180s
${parallel_streams_dl}              4
${parallel_streams_ul}              4
${size_packet}                      1400B
${deviation}                        20%
${size_packet_dl}                   1400B
${size_packet_ul}                   1400B
${interval}                         1
${omit}                             5
${alias}                            UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False
#attach
${timeout_reboot_ue}                    100


*** Test Cases ***
CB010870_A_7_E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    48h
    ${SOURCE_SW} =    IF    '${SOURCE_SW}'=='${None}'  Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =    IF    '${TARGET_SW}'=='${None}'  Get Target Build   ELSE    Set Variable  ${TARGET_SW}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    Set Test Variable    @{CUSTOMERS_LIST}      Reliance India
    Set Test Variable    @{CRITICAL_FAULTS}     0010  0016  1806  1868  4341  4352  4383
    csv_tc.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    [Teardown]    Custom Test Teardown

CB010870_B_1_General_SiSo_Cell_block_and_unblock_with_L3_call
    [Timeout]    6h
    General_SiSo_Cell_block_and_unblock     attach_timeout=${180}

CB010870_C_3_E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    48h
    Set Test Variable    @{CUSTOMERS_LIST}      Reliance India
    Set Test Variable    @{CRITICAL_FAULTS}     0010  0016  1806  1868  4341  4352  4383
    gnbbbu.Disconnect
    csv_tc.E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}


*** Keywords ***
Custom Test Setup
    common_setups_and_teardowns.Common Preconditions        collect_syslog=${False}     collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}