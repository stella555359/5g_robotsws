*** Settings ***
Documentation
...    Implementation of CB010348_CB008502-SR-B_05_SFP56_AWKUC_Ethernet_mode_reconfiguration_during_BTS_runtime test
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME      gnbscf
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    gnbcell
Library     ../python/CellOperations.py   WITH NAME    cell_keywords


*** Keywords ***
Ethernet_mode_reconfiguration_during_BTS_runtime
    [Documentation]
    ...    Test verifies BTS behavior after Ethernet mode reconfiguration in runtime.
    ...    ARGS:
    ...    - delta_reconfigure_ethernet_mode (dict, mandatory): Dict containing deltas to reconfigure ethernet mode.
    ...        Example:
    ...        {'eCpri10': [{'distName': 'MRBTS-{}/EQM-1/HWTOP-1/CABLINK-6',
    ...                      'operation': 'update',
    ...                      'parameters': [{'operation': 'update',
    ...                                      'parameterName': 'linkSpeed',
    ...                                      'value': 'eCpri10'}]},
    ...                     {'distName': 'MRBTS-{}/EQM-1/HWTOP-1/CABLINK-6',
    ...                      'operation': 'update',
    ...                      'parameters': [{'operation': 'update',
    ...                                      'parameterName': 'radioProtocolType',
    ...                                      'value': 'eCPRI'}]}],
    ...        'eCpri25': [{'distName': 'MRBTS-{}/EQM-1/HWTOP-1/CABLINK-6',
    ...                      'operation': 'update',
    ...                      'parameters': [{'operation': 'update',
    ...                                      'parameterName': 'linkSpeed',
    ...                                      'value': 'eCpri25'}]},
    ...                     {'distName': 'MRBTS-{}/EQM-1/HWTOP-1/CABLINK-6',
    ...                      'operation': 'update',
    ...                      'parameters': [{'operation': 'update',
    ...                                      'parameterName': 'radioProtocolType',
    ...                                      'value': 'eCPRI'}]}]}
    ...    - online_cells_in_ethernet_mode (dict, mandatory): Dict containing expected number of online cells
    ...        in specific Ethernet mode provided in "delta_reconfigure_ethernet_mode".
    ...        Example:
    ...        {'eCpri10': 4,
    ...         'eCpri25': 12}
    ...    - delta_default_ethernet_mode (list, mandatory): List containing delta to restore default ethernet mode.
    [Arguments]    ${delta_reconfigure_ethernet_mode}
    ...            ${online_cells_in_ethernet_mode}
    ...            ${delta_default_ethernet_mode}

    FOR  ${ethernet_mode}  IN  @{delta_reconfigure_ethernet_mode}
        ${delta_ethernet_mode}=    Get From Dictionary    ${delta_reconfigure_ethernet_mode}    ${ethernet_mode}
        ${online_cells}=    Get From Dictionary    ${online_cells_in_ethernet_mode}    ${ethernet_mode}
        Reconfigure Ethernet Mode
        ...    delta_ethernet_mode=${delta_ethernet_mode}
        ...    expected_online_cells=${online_cells}
    END
    [Teardown]    Run Keywords
    ...           Reconfigure Ethernet Mode    delta_ethernet_mode=${delta_default_ethernet_mode}
    ...           AND    gnbalarm.disallow alarm    alarm=BTS configuration error (not enough HW for LCR)

Reconfigure Ethernet Mode
    [Arguments]    ${delta_ethernet_mode}    ${expected_online_cells}=ALL    ${timeout}=${1800}    ${interval}=${30}
    Allow BTS Reset Alarms
    Run Keyword If    '${expected_online_cells}' != 'ALL'
    ...    gnbalarm.allow alarm    alarm=BTS configuration error (not enough HW for LCR)
    gnbscf.Perform BTS Delta Commissioning    delta=${delta_ethernet_mode}
    gnbru.wait_for_all_radio_unit_statuses    availability_status=online    timeout=${timeout}    interval=${interval}
    gnbbbu.wait for site to be onair    timeout=${timeout}    interval=${interval}
    Run Keyword If    '${expected_online_cells}' != 'ALL'
    ...    Wait For Enabled Cells And Check FID 1868    expected_online_cells=${expected_online_cells}
    ...    ELSE
    ...    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout}    interval=${interval}
    Disallow BTS Reset Alarms

Count Expected Degraded Cells In Ethernet Mode
    [Arguments]    ${expected_online_cells}
    ${all_cells}=    gnbcell.get_number_of_cells
    ${degraded_cells}=    Evaluate    ${all_cells} - ${expected_online_cells}
    [Return]    ${degraded_cells}

Wait For Enabled Cells And Check FID 1868
    [Arguments]    ${expected_online_cells}
    Wait Until Keyword Succeeds    20x    30s    cell_keywords.check_number_of_enabled_cells
    ...    cell_number=${expected_online_cells}
    ${degraded_cells}=    Count Expected Degraded Cells In Ethernet Mode
    ...    expected_online_cells=${expected_online_cells}
    Wait Until Keyword Succeeds    20x    30s    gnbalarm.verify alarm occurrences
    ...    fault_name=BTS configuration error (not enough HW for LCR)
    ...    occurrences=${degraded_cells}

Allow BTS Reset Alarms
    gnbalarm.allow alarm    alarm=BTS Reset Cause
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB

Disallow BTS Reset Alarms
    gnbalarm.disallow alarm    alarm=BTS Reset Cause
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB
