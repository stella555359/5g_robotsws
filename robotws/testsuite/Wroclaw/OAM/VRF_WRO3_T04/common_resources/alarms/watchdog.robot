*** Settings ***
Documentation    Classical alarms keywords using watchdog library.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Library     taf.ul.alarms_watchdog    WITH NAME    watchdog
Library    BuiltIn
Resource        ../scout/scout_operations.robot

*** Variables ***
&{ALLOWED_COMMON_FAULTS}=    61649=LMP access via port 443
...                          61652=R&D Service Port enabled
...                          61524=SSH Enabled
...                          61510=Automatic BTS Operator Certificate retrieval unsuccessful
...                          61618=Operator Certificate About to Expire or Expired
...                          61011=End Entity Certificate Update Time Mismatch
...                          4459=User Account has Default Password
...                          4655=Service account root access is enabled
...                          4654=Ethernet port security is disabled
...                          4122=GPS receiver alarm: not tracking satellites
...                          4125=GPS receiver alarm: position questionable
...                          4011=GPS Receiver alarm: control interface not available
...                          1898=PPS reference missing
...                          4385=PPS reference from backplane missing...
...                          4681=Sanity Check error
...                          4592=BTS booted at \### due to Power On
...                          7319=No X2 link available for a specific LTEENB
...                          7300=No X2 link available
...                          4297=NTP Server 0.0.0.0 unavailable
...                          61677=Wifi Repeated Authentications Failure
...                          61074=CRL Update failure or certificate revoked

*** Keywords ***
Start Watchdog
    [Documentation]    Description:    Start watching alarms using watchdog
    ...                Input:          interval = time interval between consecutive requests to BTS for active alarms
    ...                                bts_config = configuration object of BTS, by default ClassicalBts class
    ...                                add_common_alarms = True/False, if True then add alarms from
    ...                                                    &{ALLOWED_COMMON_FAULTS} to the list of allowed alarms
    ...                                                    before starting watchdog
    ...                                log_dir = path to local directory where additional logs will be stored
    ...                                reconnect = True/False, if True then reconnection to BTS will be attempted
    ...                                            after active alarms could not be read from BTS due to API error
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${interval}=2s        ${add_common_alarms}=${TRUE}
    ...                ${log_dir}=${EXECDIR}/watchdog/${TEST NAME}    ${reconnect}=${True}
    Run Keyword If     ${add_common_alarms}    Add Common Allowed Alarms to Watchdog
    ${TESTLINE_NAME}=  scout_operations.Get testline name
    Run Keyword If    '${TESTLINE_NAME}'=='7_16_UTE5G281' or '${TESTLINE_NAME}'=='7_16_UTE5G280'
    ...                Add Multiple Alarms to Watchdog List    8000    4291    7308    7324    6280    1934    6327   6278
    Run Keyword If    '${TESTLINE_NAME}'=='7_16_UTE5G278'
    ...                Add Multiple Alarms to Watchdog List    61675
    watchdog.watch_alarms    interval=${interval}
    ...                      bts_config=${bts_config}
    ...                      log_dir=${log_dir}
    ...                      reconnect=${reconnect}
Start Watchdog for Airphone
    [Documentation]    Description:    Start watching alarms using watchdog
    ...                Input:          interval = time interval between consecutive requests to BTS for active alarms
    ...                                bts_config = configuration object of BTS, by default ClassicalBts class
    ...                                add_common_alarms = True/False, if True then add alarms from
    ...                                                    &{ALLOWED_COMMON_FAULTS} to the list of allowed alarms
    ...                                                    before starting watchdog
    ...                                log_dir = path to local directory where additional logs will be stored
    ...                                reconnect = True/False, if True then reconnection to BTS will be attempted
    ...                                            after active alarms could not be read from BTS due to API error
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${interval}=2s        ${add_common_alarms}=${TRUE}
    ...                ${log_dir}=${EXECDIR}/watchdog/${TEST NAME}    ${reconnect}=${True}
    Run Keyword If     ${add_common_alarms}    Add Common Allowed Alarms to Watchdog
    watchdog.watch_alarms    interval=${interval}
    ...                      log_dir=${log_dir}
    ...                      reconnect=${reconnect}

Stop Watchdog
    [Documentation]    Description:    Stop watching alarms with watchdog
    ...                Author:         patryk.tatarek@nokia.com
    watchdog.stop_watching_alarms

Get Active Alarms List from Watchdog
    [Documentation]    Description:    Check currently active alarms on BTS for active watchdog session
    ...                Output:         Active alarms list
    ...                Author:         patryk.tatarek@nokia.com
    ${alarms}=         watchdog.get_active_alarms
    [Return]           ${alarms}

Get All Detected Alarms during Watchdog
    [Documentation]    Description:    Check every alarms on BTS that occurred during active watchdog session
    ...                Output:         Detected alarms list, including information when they were detected and
    ...                                when they disappeared
    ...                Author:         patryk.tatarek@nokia.com
    ${alarms}=         watchdog.get_detected_alarms
    [Return]           ${alarms}

Get List of Currently Allowed Alarms
    [Documentation]    Description:    Check list of currently allowed alarms
    ...                Output:         Current allowd alarms list
    ...                Author:         patryk.tatarek@nokia.com
    ${allowd}=         watchdog.get_allowed_alarms
    [Return]           ${allowd}

Check if Alarm is Active via Watchdog
    [Documentation]    Description:    Check if given alarm is currently active
    ...                Input:          At least one of the possible info about seeken alarm
    ...                Output:         True/False
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ${result}=         watchdog.is_alarm_active    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}    reason=${reason}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    [Return]           ${result}

Check if Alarm was Detected during Watchdog
    [Documentation]    Description:    Check if choosen alarm was detected during active watchdog session
    ...                Input:          At least one of the possible info about seeken alarm
    ...                Output:         True/False
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ${result}=         watchdog.was_alarm_detected    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}    reason=${reason}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    [Return]           ${result}

Remove All Alarms from Allowed List
    [Documentation]    Description:    Remove all alarms from the list of allowed alarms
    ...                Author:         patryk.tatarek@nokia.com
    watchdog.disallow_all_alarms

Check if Disallowed Alarm was Detected during Watchdog
    [Documentation]    Description:    Check if any of the disallowed alarms was detected during active watchdog session
    ...                                If watchdog finds any of such alarms, test will be marked as fail.
    ...                Author:         patryk.tatarek@nokia.com
    watchdog.check_detected_alarms

Create Allowed Alarm Instance
    [Documentation]    Description:    Create instance of allowed alarm to be used with 'Start Watchdog' keyword
    ...                Input:          At least one of the possible info about choosen alarm
    ...                Output:         Instance of allowed alarm (in form of a list)
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    ${list}=           watchdog.create_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}
    ...                fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}    reason=${reason}
    ...                impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
    [Return]           ${list}

Wait Until Alarm Appears
    [Documentation]    Description:    Wait until choosen alarm becomes active
    ...                Input:          timeout = total time to wait
    ...                                all others = At least one of the possible info about choosen alarm
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${timeout}              ${alarm_id}=${None}     ${fault_id}=${None}    ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}     ${reason}=${None}      ${unit_path}=${None}
    ...                ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    watchdog.wait_for_active_alarm    timeout=${timeout}    alarm_id=${alarm_id}
    ...                               fault_id=${fault_id}    hw_path=${hw_path}
    ...                               fault_name=${fault_name}    unit_path=${unit_path}
    ...                               severity=${severity}    reason=${reason}
    ...                               impacted_cells_count=${impacted_cells_count}
    ...                               fault_signature=${fault_signature}

Wait Until Alarm Disappears
    [Documentation]    Description:    Wait until choosen alarm becomes not active
    ...                Input:          timeout = total time to wait
    ...                                all others = At least one of the possible info about choosen alarm
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${timeout}              ${alarm_id}=${None}     ${fault_id}=${None}    ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}     ${reason}=${None}      ${unit_path}=${None}
    ...                ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    watchdog.wait_for_inactive_alarm    timeout=${timeout}    alarm_id=${alarm_id}
    ...                                 fault_id=${fault_id}    hw_path=${hw_path}
    ...                                 fault_name=${fault_name}    unit_path=${unit_path}
    ...                                 severity=${severity}    reason=${reason}
    ...                                 impacted_cells_count=${impacted_cells_count}
    ...                                 fault_signature=${fault_signature}

Add Common Allowed Alarms to Watchdog
    [Documentation]    Description:    Add common alarms to the list of allowed alarms for watchdog
    ...                Input:          alarms = list of allowed alarms
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarms}=&{ALLOWED_COMMON_FAULTS}
    ${alarms}=         Remove Duplicates    ${alarms}
    FOR  ${id}   IN   @{alarms}
        _Add Alarm to the Allowed List    fault_id=${id}
    END

Add Multiple Alarms to Watchdog List
    [Documentation]    Description:    Add multiple alarms at once to the list of allowed alarms for watchdog
    ...                Input:          example: fault_id=4291    fault_id=6327    etc.
    [Arguments]    @{alarms_to_add}
    FOR    ${alarm}    IN    @{alarms_to_add}
        _Add Alarm to the Allowed List    fault_id=${alarm}
    END

Remove Multiple Alarms from Watchdog List
    [Documentation]    Description:    Remove multiple alarms from the list of allowed alarms for watchdog
    ...                Input:          example: fault_id=4291    fault_id=6327    etc.
    [Arguments]    @{alarms_to_add}
    FOR    ${alarm}    IN    @{alarms_to_add}
        _Remove Alarm from Allowed List    fault_id=${alarm}
    END

_Add Alarm to the Allowed List
    [Documentation]    Description:    Add alarm to the list of allowed alarms. This list can be changed dynamically,
    ...                                before and after starting watchdog.
    ...                Input:          At least one of the possible info about choosen alarm
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    watchdog.allow_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}    reason=${reason}
    ...                     fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
    ...                     impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}

_Remove Alarm from Allowed List
    [Documentation]    Description:    Remove choosen alarm from the list of allowed alarms
    ...                Input:          At least one of the possible info about choosen alarm
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${alarm_id}=${None}     ${fault_id}=${None}                ${fault_name}=${None}
    ...                ${hw_path}=${None}      ${severity}=${None}                ${reason}=${None}
    ...                ${unit_path}=${None}    ${impacted_cells_count}=${None}    ${fault_signature}=${None}
    watchdog.disallow_alarm    alarm_id=${alarm_id}    fault_id=${fault_id}    hw_path=${hw_path}    reason=${reason}
    ...                        fault_name=${fault_name}    unit_path=${unit_path}    severity=${severity}
    ...                        impacted_cells_count=${impacted_cells_count}    fault_signature=${fault_signature}
