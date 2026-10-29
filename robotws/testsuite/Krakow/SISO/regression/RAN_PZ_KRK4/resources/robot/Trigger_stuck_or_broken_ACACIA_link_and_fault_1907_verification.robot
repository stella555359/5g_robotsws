*** Settings ***
Documentation
...    Implementation of Trigger_stuck_or_broken_ACACIA_link_and_fault_1907_verification test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords


*** Keywords ***
Trigger_stuck_or_broken_ACACIA_link_and_fault_1907_verification
    [Documentation]    Test triggers stuck or broken ACACIA link and verifies fault 1907.
    ...                ARGS:
    ...                - ru_id (str, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...                - timeout_fault_trigger (str, optional): FID:1907 trigger timeout in seconds. Defaults to 60.
    ...                - timeout_ru_reset (str, optional): The RU reset timeout in seconds. Defaults to 3600.
    ...                - timeout_onair (str, optional): The BTS OnAir timeout in seconds. Defaults to 1200.
    [Arguments]    ${ru_id}=${0}
    ...            ${timeout_fault_trigger}=${60}
    ...            ${timeout_ru_reset}=${3600}
    ...            ${timeout_onair}=${1200}

    @{CMD_BREAK_ACACIA} =	Create List    sudo devmem2 0xfb94047c w 0x05005011
    ...                                    sudo devmem2 0xfb940480 w 0x05005011
    ...                                    sudo devmem2 0xfb940484 w 0x05005011
    ...                                    sudo devmem2 0xfb940488 w 0x05005011
    @{ALARMS_BROKEN_ACACIA} =	Create List    TX out of order
    ...                                        No connection to unit
    ...                                        Fault signature for crash or failure
    ...                                        Radio autonomous reset as recovery action
    ...                                        RF module configuring failed
    ...                                        BTS configuration error (not enough HW for LCR)
    ...                                        No X2 link available
    ...                                        No X2 link available for a specific LTEENB
   ${ru_config_id}=    radio_keywords.get_ru_configuration_id    ru_id=${ru_id}

    gnbalarm.allow alarm    alarm=${ALARMS_BROKEN_ACACIA}
    radio_keywords.verify_fault_history_log_empty    fault_type=active
    ...                                              ru_id=${ru_id}
    radio_keywords.execute_command    command=${CMD_BREAK_ACACIA}
    ...                               ru_id=${ru_id}
    Wait Until Keyword Succeeds    2x    15s    radio_keywords.check_fault_in_history_log
    ...                                         raw_fault_id=EFaultId_ParityError
    ...                                         fault_type=active
    ...                                         ru_id=${ru_id}
    gnbalarm.wait_for_alarm_activation    fault_id=1912
    ...                                   awaiting_time=${timeout_fault_trigger}
    gnbru.wait_for_radio_unit_to_be_online    ru_id=${ru_config_id}
    ...                                       timeout=${timeout_ru_reset}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout_onair}
    gnbalarm.disallow alarm    alarm=${ALARMS_BROKEN_ACACIA}
