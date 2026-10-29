*** Settings ***
Documentation
...   Test suite for regression testing of feature CNI-127409
...   author: Radoslaw Serafin, Szymon Skorupski
...   author/contact: radoslaw.serafin@nokia.com, damian.silkowski@nokia.com, szymon.skorupski@nokia.com

Library     taf.rfrl.csv4all.CSV4AllTestCases    WITH NAME    csv_tc
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations          WITH NAME    Cells
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    Alarms
Library     ./resources/resources.py
Resource    taf/rfrl/ue/robot/REAL_UE.robot
Resource    taf/rfrl/bts/robot/common/gnb_scf.robot
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Krakow/resources/UUF/uuf_with_upgrade_paths.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               prefix_tag=${prefix_tag}
...               increase_timeout_for_update_sw=${1800}
...               increase_time_for_checking_radios=${1800}
Suite Teardown    Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     Common Postconditions With Restore Configuration If Test Failed   collect_syslog=${False}

*** Variables ***
# RF Matrix
${RFS_ALIAS}                        Matrix
${RF_VENDOR}                        RFLIGHT
${RF_IP}                            10.255.41.40
${RF_MODEL}                         NT-4X64NS

# Commissioning
${prefix_tag}                       CNI127409

# UUF
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        50
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${BTS_HOST_IP}                      192.168.255.129
${SCOUT_HOSTNAME}                   7_7_UTE5GCLOUDT11SK054
${SERIAL_CONSOLE}=                  ${False}
&{NODE1}                            testline_object=${tl.gnbs[0]}
@{NODES}                            ${NODE1}
${QC_DOMAIN}=                       MN_RAN
${QC_PROJECT}=                      RAN_VRF
${QC_ID_UPGRADE}=                   103390
${QC_ID_RESET}=                     103393
${RP_CA}                            VRF_SiSo
${RP_ORGANIZATION}                  VRF_KRK_T01
${RP_LOCATION}                      VRF_KRK

@{BLOCKING_CELL_ID}     1               4              22
@{EXPECTED_DL_TPUT}     1410 Mbits/sec  92 Mbits/sec   107 Mbits/sec
@{EXPECTED_UL_TPUT}     225 Mbits/sec   44 Mbits/sec   102 Mbits/sec
@{RF_OUTPUT_PORTS}      1:2:3:4         17:18:19:20    25:0:27:0
@{allowed_alarms_during_cell_block}     Cell blocked
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False
${ENABLE_RACH_OBSERVER}                 False

*** Test Cases ***
CNI-127409_12_UUF4ALL_UPGRADE
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


CNI-127409_3_General_SISO_Auto_cell_block_and_unblock_with_L3call
    ${len}=     Get Length                      ${BLOCKING_CELL_ID}
    Prepare Ue for L3 Call
    FOR    ${cell_num}    IN RANGE    ${len}
        Set RF Switch Output Ports              rfs_alias=RF_SWITCH
        ...                                     vendor=${RF_VENDOR}
        ...                                     ip_addr=${RF_IP}
        ...                                     model=${RF_MODEL}
        ...                                     output_ports=${RF_OUTPUT_PORTS}[${cell_num}]
        gnbalarm.allow_alarm                    alarm=@{allowed_alarms_during_cell_block}
        Cells.Block Cell                        cell_id=${BLOCKING_CELL_ID}[${cell_num}]
        Cells.Wait For Cell Statuses            cell_id=${BLOCKING_CELL_ID}[${cell_num}]
        ...                                     blocking_state=blocked
        ...                                     operational_state=disabled
        Alarms.Wait For Alarm Activation        fault_id=49     awaiting_time=10
        Cells.Unblock Cell                      cell_id=${BLOCKING_CELL_ID}[${cell_num}]
        Cells.Wait For Cell To Be OnAir         cell_id=${BLOCKING_CELL_ID}[${cell_num}]
        Alarms.Verify Alarm Is Not Active       fault_name=Cell blocked
        gnbalarm.disallow_alarm                 alarm=@{allowed_alarms_during_cell_block}
        Wait For Unexpected Alarms Occur
        Run Keyword And Continue On Failure     Verify L3 Call Data Transfer DL&UL
        ...                                     duration=120s
        ...                                     tput_dl=${EXPECTED_DL_TPUT}[${cell_num}]
        ...                                     tput_ul=${EXPECTED_UL_TPUT}[${cell_num}]
        ...                                     deviation=20%
        ...                                     parallel_streams_dl=4
        ...                                     attach_timeout=120
    END

CNI-127409_14_E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]    48h
    Set Test Variable    @{CUSTOMERS_LIST}      Reliance India
    Set Test Variable    @{CRITICAL_FAULTS}     0010  0016  1806  1868  4341  4352  4383
    gnbbbu.Disconnect
    csv_tc.E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
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
