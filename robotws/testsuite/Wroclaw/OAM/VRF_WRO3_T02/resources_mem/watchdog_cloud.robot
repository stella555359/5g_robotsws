*** Settings ***
Documentation
...    Author: marek.starzyk@nokia.com
...    Description: Resource designed to manage the watchdog functionality for vDU/vCU in cloud-based test cases.
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>

Library         Collections

Resource        ../../cloud_common_resources/alarms/watchdog.robot

*** Variables ***
@{vCU_TEMPORARY_ALLOWED_FAULTS}=  7104
@{vCU_ALLOWED_FAULTS}=            ${EMPTY}
@{vDU_TEMPORARY_ALLOWED_FAULTS}=  7504  7505  23  4675  61030  61645
@{vDU_ALLOWED_FAULTS}=            ${EMPTY}

*** Keywords ***
Start Cloud Watchdog
    [Documentation]
    ...    Description:    Start watching alarms using watchdog based on the device type.
    ...                    This keyword adds allowed faults defined in the Variables section as vCU_ALLOWED_FAULTS or vDU_ALLOWED_FAULTS.
    ...                    If add_temporary_allowed_faults is set to True, temporary allowed faults defined as vCU_TEMPORARY_ALLOWED_FAULTS
    ...                    or vDU_TEMPORARY_ALLOWED_FAULTS will also be added to the allowed watchdog alarms.
    ...    Input:          hw_type = vCU/vDU
    ...                    add_temporary_allowed_faults = True/False
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]    ${hw_type}=${None}    ${add_temporary_allowed_faults}=${False}
    Log To Console    ${hw_type}: starting watchdog...
    ${allowed_faults}=    Run Keyword If  '${hw_type}'=='vDU'
    ...                   Convert Fault List To List Of Alarm Objects  ${vDU_ALLOWED_FAULTS}  ${hw_type}
    ...                   ELSE IF         '${hw_type}'=='vCU'
    ...                   Convert Fault List To List Of Alarm Objects  ${vCU_ALLOWED_FAULTS}  ${hw_type}
    ...                   ELSE  Fail      Incalid value for hw_type: ${hw_type}
    Run Keyword If  ${add_temporary_allowed_faults}  Add Temporary Alowed Alarms To Watchdog  ${hw_type}
    watchdog.Start Watchdog  allowed_alarms=${allowed_faults}  log_dir=${RESULTS}/${hw_type}
    ...                      hw_type=${hw_type}
    Log To Console  ${hw_type}: the watchdog has started successfully
    Set To Dictionary    ${WDOG_START_STATUS}    ${hw_type}=${True}

Stop Cloud Watchdog And Get Faults
    [Documentation]
    ...    Description:    Get all detected alarms while the watchdog was active and stop watching alarms.
    ...    Input:          hw_type = vCU/vDU
    ...    Output:         List of alarms detected while the watchdog was active.
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]    ${hw_type}
    Log To Console  Checking if unexpected alarms occured during test execution
    ${wdog_status}=    Get From Dictionary    ${WDOG_START_STATUS}    ${hw_type}
    ${empty_list}=    Create List
    ${alarms}   Run Keyword If    ${wdog_status}    watchdog.Get All Detected Alarms During Watchdog  ${hw_type}    ELSE
    ...         Set Variable    ${empty_list}
    Run Keyword If  ${alarms}  Run Keywords
    ...  Log   Unexpected faults were detected on the ${hw_type} during test execution  level=ERROR  console=${True}
    ...  AND   Log Unexpected Faults Found During Execution  ${alarms}
    ...  ELSE  Log To Console  No unexpected alarms have occurred.
    [Return]  ${alarms}
    [Teardown]  Run Keywords
    ...    Run Keyword And Ignore Error  watchdog.Stop Watchdog  ${hw_type}    AND
    ...    Set To Dictionary    ${WDOG_START_STATUS}    ${hw_type}=${False}

Add Temporary Alowed Alarms To Watchdog
    [Documentation]
    ...    Description:    This keyword, based on hw_type, adds faults defined in the Variables section
    ...                    as vCU_TEMPORARY_ALLOWED_FAULTS or vDU_TEMPORARY_ALLOWED_FAULTS to the watchdog's allowed alarms.
    ...    Input:          hw_type = vCU/vDU
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]  ${hw_type}
    ${temporary_allowed_alarms}=  Set Variable If  '${hw_type}'=='vCU'   ${vCU_TEMPORARY_ALLOWED_FAULTS}  ${vDU_TEMPORARY_ALLOWED_FAULTS}
    Run Keyword If  ${temporary_allowed_alarms}!=['']
    ...    Add Alarms To Watchdog  alarms_list=${temporary_allowed_alarms}  hw_type=${hw_type}

Add Alarms To Watchdog
    [Documentation]
    ...    Description:    This keyword, based on hw_type, adds received alarms to the watchdog's allowed alarms.
    ...    Input:          alarms_list = list of allowed fault IDs
    ...                    hw_type = vCU/vDU
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]  ${alarms_list}  ${hw_type}
    FOR  ${alarm}  IN  @{alarms_list}
        watchdog.Add Alarm to the Allowed List    fault_id=${alarm}  hw_type=${hw_type}
    END
    Log To Console  Alarms temporarily added to the ${hw_type} watchdog's allowed list: ${alarms_list}
    ${currently_allowed_alarms}  watchdog.Get List of Currently Allowed Alarms  ${hw_type}
    Log  currently_allowed_alarms: ${currently_allowed_alarms}  level=DEBUG

Delete Temporary Allowed Alarms From Watchdog
    [Documentation]
    ...    Description:    This keyword, based on hw_type, removes faults defined in the Variables section
    ...                    as vCU_TEMPORARY_ALLOWED_FAULTS or vDU_TEMPORARY_ALLOWED_FAULTS from the watchdog's allowed alarms.
    ...    Input:          hw_type = vCU/vDU
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]  ${hw_type}
    ${temporary_allowed_alarms}=  Set Variable If  '${hw_type}'=='vCU'  ${vCU_TEMPORARY_ALLOWED_FAULTS}  ${vDU_TEMPORARY_ALLOWED_FAULTS}
    Run Keyword If  ${temporary_allowed_alarms}!=['']
    ...    Delete Alarms From Watchdog  alarms_list=${temporary_allowed_alarms}  hw_type=${hw_type}

Delete Alarms From Watchdog
    [Documentation]
    ...    Description:    This keyword, based on hw_type, removes the received alarms from the watchdog's allowed alarms.
    ...    Input:          alarms_list = list of fault IDs
    ...                    hw_type = vCU/vDU
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]  ${alarms_list}  ${hw_type}
    FOR  ${alarm}  IN  @{alarms_list}
        watchdog.Remove Alarm from Allowed List    fault_id=${alarm}  hw_type=${hw_type}
    END
    Log To Console  Alarms deleted from the ${hw_type} watchdog's allowed list: ${alarms_list}
    ${currently_allowed_alarms}  watchdog.Get List of Currently Allowed Alarms  ${hw_type}
    Log  currently_allowed_alarms: ${currently_allowed_alarms}  level=DEBUG

Convert Fault List To List Of Alarm Objects
    [Documentation]
    ...    Description:    Convert a list of fault IDs to a list of Alarm class objects.
    ...    Input:          list_to_convert = list of fault IDs
    ...                    hw_type = vCU/vDU
    ...    Output:         List of Alarm class objects, or None if list_to_convert is empty.
    ...    Author:         marek.starzyk@nokia.com
    [Arguments]  ${list_to_convert}  ${hw_type}
    ${converted_list}    Run Keyword If  ${list_to_convert}!=['']  Convert Faults  ${list_to_convert}  ${hw_type}
    Run Keyword If  ${list_to_convert}!=['']  Log To Console  Alarms added to the ${hw_type} watchdog's allowed list: ${list_to_convert}
    [Return]  ${converted_list}

Convert Faults
    [Arguments]  ${list}  ${hw_type}
    ${new_list}  Create List
    FOR  ${fault_id}  IN  @{list}
        ${alarm}  watchdog.Create Allowed Alarm Instance  fault_id=${fault_id}  hw_type=${hw_type}
        Append To List    ${new_list}    ${alarm}
    END
    [Return]  ${new_list}

Log Unexpected Faults Found During Execution
    [Arguments]  ${faults_list}
    Log  ${\n}Unexpected faults occurred during test execution:  level=WARN  console=True
    FOR  ${fault}  IN  @{faults_list}
        Log  ${fault}  level=WARN  console=True
    END

Get Non Upgraded CNF
    [Arguments]  ${hw_type}
    ${non_upgraded_cnf}=  Set Variable If  '${hw_type}'=='vCU'  vDU  vCU
    [Return]  ${non_upgraded_cnf}
