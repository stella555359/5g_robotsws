*** Settings ***
Documentation
...    Implementation of Faults_4590_EFaultId_CrashOrFailureSignatureAl test case
...    author: Rafal Kawa
...    contact: rafal.kawa@nokia.com

Library     taf.rfrl.bts.devices.du.commissioning.GnbCommissioning    WITH NAME      gnbscf
Library     taf.rfrl.bts.devices.du.du_operations.GnbDuOperations    WITH NAME      gnbbbu
Library     taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME      gnbcell
Library     taf.rfrl.bts.devices.du.alarm_verification.GnbAlarmVerification    WITH NAME    gnbalarm
Library     taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations    WITH NAME      gnbru
Library     ../python/RadioOperations.py   WITH NAME    radio_keywords


*** Keywords ***
RF_Module_Trigger_Faults_4590_EFaultId_CrashOrFailureSignatureAl
    [Documentation]
    ...    Test triggers fault 4590 on RF Module and verifies BTS behaviour.
    ...    ARGS:
    ...    - ru_id (str, optional): The id of radio unit based on Test Line configuration. Defaults to 0.
    ...    - timeout_fault_trigger (str, optional): The fault trigger timeout in seconds. Defaults to 180.
    ...    - timeout_onair (str, optional): The BTS OnAir timeout in seconds. Defaults to 600.
    ...    - delta_act_category_alarms_and_signatures (list, optional): List containing delta file to activate
    ...      category alarms and fault signatures. If None delta commissioning skipped. Defaults to None.
    ...      Example:
    ...      [{'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FMCADM-1',
    ...      'operation': 'update',
    ...      'parameters': [{'operation': 'update',
    ...      'parameterName': 'actCategoryAlarms',
    ...      'value': 'true'}]},
    ...      {'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    ...      'operation': 'update',
    ...      'parameters': [{'operation': 'update',
    ...      'parameterName': 'actFaultSignature',
    ...      'value': 'true'}]}]
    [Arguments]
    ...    ${ru_id}=${0}
    ...    ${timeout_fault_trigger}=${180}
    ...    ${timeout_onair}=${600}
    ...    ${delta_act_category_alarms_and_signatures}=${None}
    Run Keyword If    ${delta_act_category_alarms_and_signatures}
    ...    Activate Category Alarms And Fault Signatures
    ...    delta=${delta_act_category_alarms_and_signatures}
    ...    timeout=${timeout_onair}
    Allow RF Module Crash Alarms
    radio_keywords.kill_radio_unit_process
    ...    process_name=eventcollector
    ...    signal=SIGSEGV
    ...    ru_id=${ru_id}
    Wait For Fault And Check Signatures
    ...    fault_id=4590
    ...    category=SW_FAILURE
    ...    scope=RFM
    ...    ru_id=${ru_id}
    ...    timeout=${timeout_fault_trigger}
    gnbru.wait_for_all_radio_units_to_be_online
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout_onair}
    Disallow RF Module Crash Alarms

Wait For Fault And Check Signatures
    [Arguments]
    ...    ${ru_id}
    ...    ${fault_id}
    ...    ${category}
    ...    ${scope}
    ...    ${timeout}
    ${ru_serial}=    taf.rfrl.utilities.tl_config.get_radio_serial_number   ru_id=${ru_id}
    ${fault_signature_pattern}=    Generate Fault Signature Pattern
    ...    component=${ru_serial}
    ...    scope=${scope}
    ...    category=${category}
    gnbalarm.wait_for_alarm_and_verify_fault_signature_not_empty
    ...    fault_id=${fault_id}
    ...    signature_params_patterns=${fault_signature_pattern}
    ...    timeout=${timeout}

Generate Fault Signature Pattern
    [Arguments]
    ...    ${component}=^[a-zA-Z]
    ...    ${scope}=^[a-zA-Z]
    ...    ${category}=^[a-zA-Z]
    ...    ${resetCounter}=^\\d
    ...    ${date}=^\\d

    ${bts_sw}=    gnbbbu.get_bts_sw_version
    &{fault_signature_pattern}=    Create Dictionary
    ...    date=${date}
    ...    resetCounter=${resetCounter}
    ...    category=${category}
    ...    loadName=${bts_sw}
    ...    scope=${scope}
    ...    component=${component}
    [Return]    &{fault_signature_pattern}

Activate Category Alarms And Fault Signatures
    [Arguments]
    ...    ${delta}
    ...    ${timeout}
    gnbscf.Perform BTS Delta Commissioning    delta=${delta}
    gnbcell.wait_for_all_cells_to_be_onair    timeout=${timeout}

Allow RF Module Crash Alarms
    gnbalarm.allow alarm    alarm=Fault signature for crash or failure
    gnbalarm.allow alarm    alarm=No connection to unit
    gnbalarm.allow alarm    alarm=No X2 link available
    gnbalarm.allow alarm    alarm=No X2 link available for a specific LTEENB

Disallow RF Module Crash Alarms
    gnbalarm.disallow alarm    alarm=Fault signature for crash or failure
    gnbalarm.disallow alarm    alarm=No connection to unit
    gnbalarm.disallow alarm    alarm=No X2 link available
    gnbalarm.disallow alarm    alarm=No X2 link available for a specific LTEENB
