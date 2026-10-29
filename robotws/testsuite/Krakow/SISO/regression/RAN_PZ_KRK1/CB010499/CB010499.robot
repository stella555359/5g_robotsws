*** Settings ***
Documentation
...   Test suite for regression testing of feature CB019499
...   author/contact: jaroslaw.lezon@nokia.com, damian.silkowski@nokia.com

Library      taf.ue    WITH NAME    ue
Library      taf.rfrl.ue.helpers.data_transfer    WITH NAME    data_transfer
Library      taf.rfrl.bts.devices.ru.ru_operations.EnbRuOperations    WITH NAME    ru_operations
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    cell_operations
Library      testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.CB010499.resources.attenuator.Attenuator    WITH NAME    attenuator
Library      testsuite.Krakow.SISO.regression.RAN_PZ_KRK1.CB010499.resources.python_resources_10499    WITH NAME    pyt_res_10499
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Variables    testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB010499/resources/ru_matrix.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        common_setups_and_teardowns.Common Preconditions With Watching Alarms
Test Teardown     common_setups_and_teardowns.Common Postconditions With Watching Alarms and Restore Configuration If Test Failed

*** Variables ***
#tput
${capabilities}                                     REAL_UE
${duration}                                         180s
${parallel_streams_dl}                              4
${parallel_streams_ul}                              4
${size_packet}                                      1400B
${deviation}                                        50%
${size_packet_dl}                                   1400B
${size_packet_ul}                                   1400B
${interval}                                         1
${omit}                                             60
${alias}                                            UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}                False
#attach
${reboot_ue}                                        False
${timeout_reboot_ue}                                100
@{CUSTOM_ALLOWED_ALARMS}                            Unit synchronization failed
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}      Failure detected on assigned antennas

*** Test Cases ***
# SC5GAUTO-1020
CB010499_t12max_190_LTE_Fault4256_EFaultIdMaximumDelayExceededAl_TSN
    ${alarm_4256} = 	Create Dictionary 	alarm_id=7116
    ...                                     fault_id=4256
    ...                                     fault_name=Fiber delay and antenna round trip delay exceeded
    ...                                     severity=Major

    ${expected_alarms} =	Create List  ${alarm_4256}

    pyt_res_10499.set_param_t12_min_max    ru_id=1    t12Min_value=60    t12Max_value=30
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    pyt_res_10499.reset_radio    ru_id=1
    Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.check_alarm_is_active    fault_to_verify=${alarm_4256}
    pyt_res_10499.set_param_t12_min_max    ru_id=1    t12Min_value=130    t12Max_value=190
    pyt_res_10499.reset_radio    ru_id=1
    Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.vefify_all_cells_onair
    Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.check_alarm_is_not_active    fault_to_verify=${alarm_4256}
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}


CB010499_Fault4706_4707_EcpriOutOfTimingWindow_delay_over_t12max_LTE_TSN
    &{alarm_4707} = 	Create Dictionary   alarm_id=7114
    ...                                     fault_id=4707
    ...                                     fault_name=eCPRI Out Of Timing Window Major Alarm
    ...                                     severity=Major

    ${expected_alarms} =	Create List  ${alarm_4707}

    pyt_res_10499.set_param_t12_min_max    ru_id=1    t12Min_value=0    t12Max_value=0
    gnbalarm.Allow Alarm    alarm=${expected_alarms}
    pyt_res_10499.reset_radio    ru_id=1
    Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.check_alarm_is_active    fault_to_verify=${alarm_4707}
    pyt_res_10499.set_param_t12_min_max    ru_id=1    t12Min_value=130    t12Max_value=190
    pyt_res_10499.reset_radio   ru_id=1
    Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.vefify_all_cells_onair
    Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.check_alarm_is_not_active    fault_to_verify=${alarm_4707}
    gnbalarm.Disallow Alarm    alarm=${expected_alarms}


# SC5GAUTO-1021
CB010499_t12max_190_LTE_E2E_TCP_TSN
    attenuator.init_attenuator
    attenuator.set_ports_state    state=off
    Prepare UE
    FOR    ${ru}    IN    @{ru_matrix}
        attenuator.set_ports_state    ports_to_change=${ru}[active_cell][ports]    state=on
        Run Bi Directional tput TCP    112 Mbits/sec    12 Mbits/sec
        attenuator.set_ports_state    ports_to_change=${ru}[active_cell][ports]    state=off
    END


# SC5GAUTO-1022
CB010499_RU_module_lock_unlock_from_GUI
    attenuator.init_attenuator
    attenuator.set_ports_state    state=off
    Prepare UE
    FOR    ${ru}    IN    @{ru_matrix}
        pyt_res_10499.lock_and_unlock_ru   ru_id=${ru}[ru_id]
        Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.vefify_all_cells_onair
        attenuator.set_ports_state    ports_to_change=${ru}[active_cell][ports]    state=on
        Run Bi Directional tput TCP    112 Mbits/sec    12 Mbits/sec
        attenuator.set_ports_state    ports_to_change=${ru}[active_cell][ports]    state=off
    END


# SC5GAUTO-1023
CB010499_RU_module_reset_from_GUI
    attenuator.init_attenuator
    attenuator.set_ports_state    state=off
    Prepare UE
    FOR    ${ru}    IN    @{ru_matrix}
        pyt_res_10499.reset_radio   ru_id=${ru}[ru_id]
        Wait Until Keyword Succeeds    300 sec     15 sec   pyt_res_10499.vefify_all_cells_onair
        attenuator.set_ports_state    ports_to_change=${ru}[active_cell][ports]    state=on
        Run Bi Directional tput TCP    112 Mbits/sec    12 Mbits/sec
        attenuator.set_ports_state    ports_to_change=${ru}[active_cell][ports]    state=off
    END


*** Keywords ***
Prepare UE
    REAL_UE.Prepare Ue for L3 Call
    ...  capabilities=${capabilities}
    ...  reboot_ue=${reboot_ue}
    ...  timeout_reboot_ue=${timeout_reboot_ue}


Run Bi Directional tput TCP
    [Arguments]    ${tput_dl}   ${tput_ul}
    Bi Directional Tput
    ...    duration=${duration}
    ...    tput_dl=${tput_dl}
    ...    tput_ul=${tput_ul}
    ...    parallel_streams_dl=${parallel_streams_dl}
    ...    parallel_streams_ul=${parallel_streams_ul}
    ...    deviation=${deviation}
    ...    protocol=tcp
    ...    size_packet_dl=${size_packet_dl}
    ...    size_packet_ul=${size_packet_ul}
    ...    interval=${interval}
    ...    deviation_dl=${deviation}
    ...    deviation_ul=${deviation}
    ...    qci_dl=${None}
    ...    qci_ul=${None}
    ...    linux_congestion_dl=${None}
    ...    linux_congestion_ul=${None}
    ...    alias=${alias}
    ...    omit=${omit}

Bi Directional Tput
    [Arguments]    ${duration}                       ${tput_dl}
    ...            ${tput_ul}                        ${parallel_streams_dl}            ${parallel_streams_ul}
    ...            ${deviation}                      ${protocol}
    ...            ${size_packet_dl}                 ${size_packet_ul}                 ${interval}
    ...            ${deviation_dl}=${deviation}      ${deviation_ul}=${deviation}      ${qci_dl}=${None}
    ...            ${qci_ul}=${None}                 ${linux_congestion_dl}=${None}    ${linux_congestion_ul}=${None}
    ...            ${alias}=${alias}                 ${omit}=${omit}
    REAL_UE.Perform Attach and Verify UE Properly Attached   alias=${alias}
    data_transfer.Start Data Transfer on Real UE    dt_name=DT_DL  ue_alias=${alias}  direction=dl  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_dl}  parallel_streams=${parallel_streams_dl}  size_packet=${size_packet_dl}    interval=${interval}  qci=${qci_dl}
    ...  linux_congestion=${linux_congestion_dl}
    data_transfer.Start Data Transfer on Real UE    dt_name=DT_UL  ue_alias=${alias}  direction=ul  protocol=${protocol}  duration=${duration}
    ...  tput=${tput_ul}  parallel_streams=${parallel_streams_ul}  size_packet=${size_packet_ul}    interval=${interval}  qci=${qci_ul}
    ...  linux_congestion=${linux_congestion_ul}
    REAL_UE.Wait for truput stabilization
    ue.Check Data Transfer is Alive     dt_name=DT_DL
    ue.Check Data Transfer is Alive     dt_name=DT_UL
    ue.Await Data Transfer Finish       dt_name=DT_DL
    ue.Await Data Transfer Finish       dt_name=DT_UL
    ue.Verify Average Throughput With Deviation   dt_name=DT_DL   tput=${tput_dl}   deviation=${deviation_dl}    omit=${omit}
    ue.Verify Average Throughput With Deviation   dt_name=DT_UL   tput=${tput_ul}   deviation=${deviation_ul}    omit=${omit}
    ue.Detach UE   ${alias}

