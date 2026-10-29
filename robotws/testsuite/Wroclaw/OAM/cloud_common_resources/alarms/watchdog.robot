*** Settings ***
Documentation    Cloud alarms keywords using watchdog library.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Library     taf.ul.alarms_watchdog    WITH NAME    watchdog_vcu
Library     taf.ul.alarms_watchdog    WITH NAME    watchdog_vdu

*** Keywords ***
Start Watchdog
    [Documentation]    Description:    Start watching alarms using watchdog
    ...                Input:          hw_type = vCU/vDU
    ...                                allowed_alarms = list of alarms which will be skipped during active alarms check
    ...                                interval = time interval between consecutive requests to BTS for active alarms
    ...                                bts_config = configuration object of BTS, by default CloudBts class
    ...                                log_dir = path to local directory where additional logs will be stored
    ...                                reconnect = True/False, if True then reconnection to BTS will be attempted
    ...                                            after active alarms could not be read from BTS due to API error
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${allowed_alarms}=${None}    ${interval}=2s    ${bts_config}=${tl.gnbs[0]}
    ...                ${log_dir}=${EXECDIR}/watchdog/${TEST NAME}    ${reconnect}=${True}    ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.watch_alarms
    ...                allowed_alarms=${allowed_alarms}
    ...                interval=${interval}
    ...                bts_config=${bts_config}
    ...                log_dir=${log_dir}
    ...                reconnect=${reconnect}
    ...                cu_id=${0}
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.watch_alarms
    ...                allowed_alarms=${allowed_alarms}
    ...                interval=${interval}
    ...                bts_config=${bts_config}
    ...                log_dir=${log_dir}
    ...                reconnect=${reconnect}
    ...                du_id=${0}
    ...    ELSE        FAIL    hw_type doesn't exist

Stop Watchdog
    [Documentation]    Description:    Stop watching alarms with watchdog
    ...                Input:          hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.stop_watching_alarms
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.stop_watching_alarms
    ...    ELSE        FAIL    hw_type doesn't exist

Get Active Alarms List from Watchdog
    [Documentation]    Description:    Check currently active alarms on BTS for active watchdog session
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Active alarms list
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${None}
    IF                 '${hw_type}'=='vCU'
                       ${alarms}=    watchdog_vcu.get_active_alarms
    ELSE IF            '${hw_type}'=='vDU'
                       ${alarms}=    watchdog_vdu.get_active_alarms
    ELSE
                       FAIL    hw_type doesn't exist
    END
    [Return]           ${alarms}

Get All Detected Alarms during Watchdog
    [Documentation]    Description:    Check every alarms on BTS that occurred during active watchdog session
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Detected alarms list, including information when they were detected and
    ...                                when they disappeared
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${None}
    IF                 '${hw_type}'=='vCU'
                       ${alarms}=    watchdog_vcu.get_detected_alarms
    ELSE IF            '${hw_type}'=='vDU'
                       ${alarms}=    watchdog_vdu.get_detected_alarms
    ELSE
                       FAIL    hw_type doesn't exist
    END
    [Return]           ${alarms}

Get List of Currently Allowed Alarms
    [Documentation]    Description:    Check list of currently allowed alarms
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Current allowd alarms list
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${None}
    IF                 '${hw_type}'=='vCU'
                       ${allowed}=    watchdog_vcu.get_allowed_alarms
    ELSE IF            '${hw_type}'=='vDU'
                       ${allowed}=    watchdog_vdu.get_allowed_alarms
    ELSE
                       FAIL    hw_type doesn't exist
    END
    [Return]           ${allowed}

Check if Alarm is Active
    [Documentation]    Description:    Check if given alarm is currently active
    ...                Input:          At least one of the possible info about seeken alarm
    ...                                hw_type = vCU/vDU
    ...                Output:         True/False
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ...                ${hw_type}=${None}
    IF                 '${hw_type}'=='vCU'
                       ${result}=    watchdog_vcu.is_alarm_active    alarm_id=${alarm_id}    fault_id=${fault_id}
        ...            hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
        ...            reason=${reason}    impacted_cells_count=${impacted_cells_count}
        ...            fault_signature=${fault_signature}
    ELSE IF            '${hw_type}'=='vDU'
                       ${result}=    watchdog_vdu.is_alarm_active    alarm_id=${alarm_id}    fault_id=${fault_id}
        ...            hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
        ...            reason=${reason}    impacted_cells_count=${impacted_cells_count}
        ...            fault_signature=${fault_signature}
    ELSE
                       FAIL    hw_type doesn't exist
    END
    [Return]           ${result}

Check if Alarm was Detected during Watchdog
    [Documentation]    Description:    Check if choosen alarm was detected during active watchdog session
    ...                Input:          At least one of the possible info about seeken alarm
    ...                                hw_type = vCU/vDU
    ...                Output:         True/False
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ...                ${hw_type}=${None}
    IF                 '${hw_type}'=='vCU'
                       ${result}=    watchdog_vcu.was_alarm_detected    alarm_id=${alarm_id}    fault_id=${fault_id}
        ...            hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
        ...            reason=${reason}    impacted_cells_count=${impacted_cells_count}
        ...            fault_signature=${fault_signature}
    ELSE IF            '${hw_type}'=='vDU'
                       ${result}=    watchdog_vdu.was_alarm_detected    alarm_id=${alarm_id}    fault_id=${fault_id}
        ...            hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
        ...            reason=${reason}    impacted_cells_count=${impacted_cells_count}
        ...            fault_signature=${fault_signature}
    ELSE
                       FAIL    hw_type doesn't exist
    END
    [Return]           ${result}

Add Alarm to the Allowed List
    [Documentation]    Description:    Add alarm to the list of allowed alarms
    ...                Input:          At least one of the possible info about choosen alarm
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ...                ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.allow_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                reason=${reason}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.allow_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                reason=${reason}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    ...    ELSE        FAIL    hw_type doesn't exist

Remove Alarm from Allowed List
    [Documentation]    Description:    Remove choosen alarm from the list of allowed alarms
    ...                Input:          At least one of the possible info about choosen alarm
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ...                ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.disallow_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                reason=${reason}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.disallow_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                reason=${reason}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    ...    ELSE        FAIL    hw_type doesn't exist

Remove All Alarms from Allowed List
    [Documentation]    Description:    Remove all alarms from the list of allowed alarms
    ...                Input:          hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.disallow_all_alarms
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.disallow_all_alarms
    ...    ELSE        FAIL    hw_type doesn't exist

Check if Disallowed Alarm was Detected during Watchdog
    [Documentation]    Description:    Check if any of the disallowed alarms was detected during active watchdog session
    ...                Input:          hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.check_detected_alarms
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.check_detected_alarms
    ...    ELSE        FAIL    hw_type doesn't exist

Create Allowed Alarm Instance
    [Documentation]    Description:    Create instance of allowed alarm to be used with 'Start Watchdog' keyword
    ...                Input:          At least one of the possible info about choosen alarm
    ...                                hw_type = vCU/vDU
    ...                Output:         Instance of allowed alarm (in form of a list)
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ...                ${hw_type}=${None}
    IF                 '${hw_type}'=='vCU'
                       ${list}=    watchdog_vcu.create_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}
        ...            hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
        ...            reason=${reason}    impacted_cells_count=${impacted_cells_count}
        ...            fault_signature=${fault_signature}
    ELSE IF            '${hw_type}'=='vDU'
                       ${list}=    watchdog_vdu.create_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}
        ...            hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
        ...            reason=${reason}    impacted_cells_count=${impacted_cells_count}
        ...            fault_signature=${fault_signature}
    ELSE
                       FAIL    hw_type doesn't exist
    END
    [Return]           ${list}

Wait Until Alarm Appears
    [Documentation]    Description:    Wait until choosen alarm becomes active
    ...                Input:          timeout = total time to wait
    ...                                all others = At least one of the possible info about choosen alarm
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${timeout}              ${alarm_id}=${None}     ${fault_id}=${None}    ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}     ${reason}=${None}      ${unit_path}=${None}
    ...                ${impacted_cells_count}=${None}    ${fault_signature}=${None}    ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.wait_for_active_alarm    timeout=${timeout}    alarm_id=${alarm_id}
    ...                fault_id=${fault_id}    hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}
    ...                severity=${severity}    reason=${reason}    impacted_cells_count=${impacted_cells_count}
    ...                fault_signature=${fault_signature}
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.wait_for_active_alarm    timeout=${timeout}    alarm_id=${alarm_id}
    ...                fault_id=${fault_id}    hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}
    ...                severity=${severity}    reason=${reason}    impacted_cells_count=${impacted_cells_count}
    ...                fault_signature=${fault_signature}
    ...    ELSE        FAIL    hw_type doesn't exist

Wait Until Alarm Disappears
    [Documentation]    Description:    Wait until choosen alarm becomes not active
    ...                Input:          timeout = total time to wait
    ...                                all others = At least one of the possible info about choosen alarm
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${timeout}              ${alarm_id}=${None}     ${fault_id}=${None}    ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}     ${reason}=${None}      ${unit_path}=${None}
    ...                ${impacted_cells_count}=${None}    ${fault_signature}=${None}    ${hw_type}=${None}
    Run Keyword If    '${hw_type}'=='vCU'
    ...                watchdog_vcu.wait_for_inactive_alarm    timeout=${timeout}    alarm_id=${alarm_id}
    ...                fault_id=${fault_id}    hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}
    ...                severity=${severity}    reason=${reason}    impacted_cells_count=${impacted_cells_count}
    ...                fault_signature=${fault_signature}
    ...    ELSE IF    '${hw_type}'=='vDU'
    ...                watchdog_vdu.wait_for_inactive_alarm    timeout=${timeout}    alarm_id=${alarm_id}
    ...                fault_id=${fault_id}    hw_path=${hw_path}    fault_name=${fault_name}    unit_path=${unit_path}
    ...                severity=${severity}    reason=${reason}    impacted_cells_count=${impacted_cells_count}
    ...                fault_signature=${fault_signature}
    ...    ELSE        FAIL    hw_type doesn't exist

Add Allowed Alarms To Watchdog
     [Documentation]    Description:    Adds a list of allowed alarms for the watchdog.
     ...                Input:          alarms_list = list of dictionaries containing fault_id, fault_name and severity
     ...                                hw_type = vDU / vCU. Information to which unit allowed alarms should be added.
    ...                Author:          damian.kotula@nokia.com
     [Arguments]    ${alarms_list}    ${hw_type}
     FOR    ${alarm}    IN    @{alarms_list}
         watchdog.Add Alarm to the Allowed List    fault_id=${alarm.fault_id}    fault_name=${alarm.fault_name}
         ...                                       severity=${alarm.severity}    hw_type=${hw_type}
     END
