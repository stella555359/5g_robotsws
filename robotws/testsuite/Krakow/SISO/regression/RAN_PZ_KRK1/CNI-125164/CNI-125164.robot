*** Settings ***
Documentation
...   Test suite for regression testing of CNI-125164
...   author: Marcin Bereznicki
...   contact: marcin.bereznicki@nokia.com

Library         taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations          WITH NAME    Cells
Library         taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    Alarms
Library         ./resources/resources.py
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Resource        taf/rfrl/bts/robot/common/gnb_scf.robot
Variables       taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables       ./resources/variables.py


Force Tags    CA_VRF_KRK

Suite Setup     Common Suite Setup With OnAir Test Line Preparation
...             prefix_tag=CNI125164
Suite Teardown  Common Suite Teardown

Test Setup      Common Preconditions With Watching Alarms
Test Teardown   Common Postconditions With Watching Alarms

*** Variables ***
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}
${ENABLE_RACH_OBSERVER}                 ${False}
${RF_VENDOR}                            RFLIGHT
${RF_MODEL}                             NT-4X64NS
${RF_IP}                                10.255.27.71
@{BLOCKING_CELL_ID}                     1               16
@{EXPECTED_DL_TPUT}                     1410 Mbits/sec  200 Mbits/sec
@{EXPECTED_UL_TPUT}                     225 Mbits/sec   102 Mbits/sec
@{RF_OUTPUT_PORTS}                      25:26:27:28     1:2:7:8
@{allowed_alarms_during_cell_block}     Cell blocked
@{CRITICAL_FAULTS}                      0010  0016  1806  1868  4341  4352  4383
@{CUSTOMERS_LIST}                       Reliance India
${RP_CA}                                VRF_OAM
${RP_ORGANIZATION}                      VRF_KRK_T01
${RP_LOCATION}                          VRF_KRK

*** Test Cases ***
[1]CNI-125164_4_General_SISO_Auto_cell_block_and_unblock_with_L3call
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

[1]CNI-125164_16_E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]    96h
    [Setup]      Common Preconditions     collect_syslog=${False}
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=50
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          customers_list=@{CUSTOMERS_LIST}
    [Teardown]   Common Postconditions     collect_syslog=${False}

[1]CNI-125164_9_General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    Alarms.Allow Alarm                      alarm=RF module configuring failed
    Perform Delta Commissioning On gNB      delta=${delta_wrong_nrarfcn}
    ...                                     skip_parameter_relation_errors=${True}
    Alarms.Wait For Alarm Activation        fault_id=1900     awaiting_time=180
    Perform Delta Commissioning On gNB      delta=${delta_correct_nrarfcn}
    Cells.Wait For All Cells To Be OnAir    timeout=300
    Alarms.Verify Alarm Is Not Active       fault_name=RF module configuring failed
    Alarms.Disallow Alarm                   alarm=RF module configuring failed
    [Teardown]    Common Postconditions With Watching Alarms and Restore Configuration If Test Failed
