*** Settings ***
Documentation
...    Implementation of Trigger_5G_RF_Alarm_and_verification_of_RU_and_BTS_fault test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords
Library     ../python/AlarmKeywords.py   WITH NAME    alarm_keywords


*** Keywords ***
Trigger_5G_RF_Alarm_and_verification_of_RU_and_BTS_fault
    [Documentation]    Test triggers 5G RF Alarm and verifies the RU and state of BTS.
    ...                ARGS:
    ...                - rf_alarm_data (dict): Dictionary containing the data related to 5G RF Alarm:
    ...                    - additional_allowed_alarms (list): List of allowed alarms to be triggered.
    ...                    - commands (list): List of commands to be executed to trigger 5G RF Alarm.
    ...                    - expected_alarms (dict): Dict containing data about the expected alarms to be triggered:
    ...                        - raw_fault_ids (list): List of raw fault IDs in regex format to check in history log.
    ...                        - bts_faults (list): Lists of expected BTS faults.
    ...                    - ignored_raw_fault_ids (list, optional): List of raw fault IDs to be ignored in history log.
    ...                      Example:
    ...                      {"additional_allowed_alarms": ["No X2 link available"],
    ...                      "commands": ["sudo devmem2 0xfb94047c w 0x05005011"],
    ...                      "expected_alarms": {
    ...                        "bts_faults": ["Radio autonomous reset as recovery action"],
    ...                        "raw_fault_ids": [r"EFaultId_ParityError\s\(1487\)"]},
    ...                      "ignored_raw_fault_ids": [r"EFaultId_BMUFault\s\(1461\)"]}
    ...                - ru_id (int, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...                - timeout_trigger_raw_fault (int, optional): The timeout for triggering the raw fault in RU fault
    ...                                                             history log in seconds. Defaults to 30.
    ...                - timeout_trigger_bts_alarm (int, optional): The BTS alarm timeout in seconds. Defaults to 300.
    ...                - timeout_onair (int, optional): The BTS OnAir timeout in seconds. Defaults to 1200.
    ...                - fault_verification_mode (str, optional): The mode for expected BTS fault verification.
    ...                                                           Can be 'any' or 'all'.  Defaults to 'any'.
    [Arguments]    ${rf_alarm_data}
    ...            ${ru_id}=${0}
    ...            ${timeout_trigger_raw_fault}=${30}
    ...            ${timeout_trigger_bts_alarm}=${300}
    ...            ${timeout_onair}=${1200}
    ...            ${fault_verification_mode}=any
    radio_keywords.verify_fault_history_log_empty    fault_type=active
    ...                                              ignored_faults=${rf_alarm_data['ignored_raw_fault_ids']}
    ...                                              ru_id=${ru_id}
    gnbalarm.allow alarm    alarm=${rf_alarm_data['additional_allowed_alarms']}
    Trigger 5G RF Alarm    commands=${rf_alarm_data['commands']}
    ...                    raw_fault_ids=${rf_alarm_data['expected_alarms']['raw_fault_ids']}
    ...                    ignored_fault_ids=${rf_alarm_data['ignored_raw_fault_ids']}
    ...                    ru_id=${ru_id}
    ...                    bts_fault_names=${rf_alarm_data['expected_alarms']['bts_faults']}
    ...                    timeout_trigger_raw_fault=${timeout_trigger_raw_fault}
    ...                    timeout_trigger_alarm=${timeout_trigger_bts_alarm}
    ...                    fault_verification_mode=${fault_verification_mode}
    [Teardown]    Run Keywords    Power Reset RU And Wait For OnAir    ru_id=${ru_id}
    ...                                                                timeout=${timeout_onair}    AND
    ...                           gnbalarm.disallow alarm    alarm=${rf_alarm_data['additional_allowed_alarms']}    AND
    ...                           gnbalarm.disallow alarm    alarm=${rf_alarm_data['expected_alarms']['bts_faults']}

Trigger 5G RF Alarm
    [Documentation]    Triggers 5G RF Alarm by executing commands and verifies the alarm activation.
    ...                ARGS:
    ...                - commands (list): List of commands to be executed to trigger 5G RF Alarm.
    ...                - raw_fault_ids (list): List of raw fault IDs to be checked in the history log.
    ...                - ignored_fault_ids (list, optional): List of raw fault IDs to be ignored in the history log.
    ...                - ru_id (int): The id of radio unit based on Test Line configuration.
    ...                - bts_fault_names (list): List of BTS fault names to be checked.
    ...                - timeout_trigger_raw_fault (int, optional): The timeout for triggering the raw fault in RU fault
    ...                                                             history log in seconds. Defaults to 30.
    ...                - timeout_trigger_alarm (str, optional): The timeout for triggering the BTS alarm in seconds.
    ...                                                         Defaults to 300.
    ...                - fault_verification_mode (str, optional): The mode for expected BTS fault verification.
    ...                                                           Can be 'any' or 'all'. Defaults to 'any'.
    [Arguments]    ${commands}
    ...            ${raw_fault_ids}
    ...            ${ignored_fault_ids}
    ...            ${bts_fault_names}
    ...            ${ru_id}
    ...            ${timeout_trigger_raw_fault}=${30}
    ...            ${timeout_trigger_alarm}=${300}
    ...            ${fault_verification_mode}=any

    gnbalarm.allow alarm    alarm=${bts_fault_names}
    radio_keywords.execute_command    command=${commands}
    ...                               ru_id=${ru_id}
    BuiltIn.Log To Console  \n5G RF Alarm triggered on RU${ru_id}
    Wait Until Keyword Succeeds    ${timeout_trigger_raw_fault}s    5s    radio_keywords.check_fault_in_history_log
    ...                                                                       raw_fault_id=${raw_fault_ids}
    ...                                                                       ignored_faults=${ignored_fault_ids}
    ...                                                                       fault_type=active
    ...                                                                       ru_id=${ru_id}
    Wait Until Keyword Succeeds    ${timeout_trigger_alarm}s    5s    alarm_keywords.verify_if_expected_faults_exist
    ...                                                                   fault_names=${bts_fault_names}
    ...                                                                   mode=${fault_verification_mode}

Power Reset RU And Wait For OnAir
    [Documentation]    Resets the RU and waits for all cells to be onair.
    ...                ARGS:
    ...                - ru_id (int, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...                - timeout (int, optional): The timeout for waiting for onair in seconds. Defaults to 1200.
    [Arguments]    ${ru_id}=${0}
    ...            ${timeout}=${1200}

    gnbru.power_reset_radio_unit  radio_unit_id=${ru_id}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout}
