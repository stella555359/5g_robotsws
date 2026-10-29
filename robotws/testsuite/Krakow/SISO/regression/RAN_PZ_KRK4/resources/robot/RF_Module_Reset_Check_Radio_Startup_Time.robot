*** Settings ***
Documentation
...    Implementation of NonCooled-SFP_Common_SiSo_Recovery_RF module reset_Check_Radio_Startup_Time test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     ../../../../../resources/RAN_PZ_KRK4/SyslogEventObserver.py   WITH NAME    event_observer
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords


*** Keywords ***
RF_Module_Reset_Check_Radio_Startup_Time
    [Documentation]
    ...    Check startup time of radio unit after reset
    ...    ARGS:
    ...    - target_startup_time (int, optional): Target max radio unit startup time in seconds. Defaults to 130.
    ...    - ru_id (int, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    [Arguments]    ${target_startup_time}=${130}    ${ru_id}=${0}
    gnbalarm.Allow Alarm    alarm=No X2 link available
    gnbalarm.Allow Alarm    alarm=No X2 link available for a specific LTEENB
    ${ru_config_id}=    radio_keywords.get_ru_configuration_id    ru_id=${ru_id}
    ${ru_serial_number}=  radio_keywords.get radio unit serial number  ru_id=${ru_config_id}
    event_observer.start syslog event observer
    ...    event_name=radio_reset
    ...    success_regex=\\[ResetTaskHandler\\] handleResetTask.*RESET_TASK has been created:.*RMOD
    gnbru.reset_radio_unit_from_GUI    radio_unit_id=${ru_config_id}
    gnbru.wait_for_radio_unit_statuses
    ...    operational_state=disabled
    ...    ru_id=${ru_config_id}
    event_observer.verify syslog event succeeded    event_name=radio_reset
    event_observer.start syslog event observer
    ...    event_name=radio_readiness
    ...    success_regex=\\[RadioEquipment::Controller \\] onModuleReadyInd.*SN = ${ru_serial_number}
    gnbru.wait_for_radio_unit_to_be_online
    ...    timeout=600
    ...    ru_id=${ru_config_id}
    event_observer.verify syslog event succeeded    event_name=radio_readiness
    ${time_reset}=  event_observer.get attribute of event observer result
    ...    event_name=radio_reset
    ...    attribute_name=time
    ${time_readiness}=  event_observer.get attribute of event observer result
    ...    event_name=radio_readiness
    ...    attribute_name=time
    radio_keywords.verify radio startup time
    ...    time_radio_readiness=${time_readiness}
    ...    time_radio_reset=${time_reset}
    ...    target_startup_time=${target_startup_time}
    [Teardown]   Run Keywords
    ...    gnbcell.wait_for_all_cells_to_be_onair    timeout=600
    ...    AND    gnbalarm.disallow alarm    alarm=No X2 link available
    ...    AND    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB
