*** Settings ***
Documentation  Faults management
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    Collections
Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    admin

*** Keywords ***
Admin Check Inactive FaultId Alarms
    [Arguments]  @{faultids}  ${timeout}=60
    [Documentation]
    ...  Description:
    ...  Keyword checks there is no active alarms given by fault id list.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | faultids               | Yes  | Fault id list of alarms that should be inactive.                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | timeout                |  No  | Time to wait for alarm deactivation.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${faultid}  IN  @{faultids}
      admin.Assert Alarm Inactive  parameters=faultId=${faultid}  timeout=${timeout}
    END

Admin Get And Check Active Alarms
    [Arguments]  ${allowed_alarms}  ${log_to_console}=no
    [Documentation]
    ...  Description:
    ...  Keyword gets the active alarms and checks if they are on the list of allowed alarms.
    ...  The 'alarmDetail' field is taken into account.
    ...  Example:
    ...  @{allowed_alarms}=  (?i)vendor bts certificate
    ...                      Synchronization lost
    ...                      .*BTS booted at.+
    ...
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${active_alarms}=  admin.Get Alarms
    Admin Check Active Alarms  allowed_alarms=${allowed_alarms}  active_alarms=${active_alarms}
    ...  log_to_console=${log_to_console}

Admin Check Active Alarms
    [Arguments]  ${allowed_alarms}=${EMPTY}  ${active_alarms}=${EMPTY}  ${log_to_console}=False
    [Documentation]
    ...  Description:
    ...  Keyword checks the active alarms if they are on the list of allowed alarms.
    ...  The 'alarmDetail' field is taken into account.
    ...  Example:
    ...  @{allowed_alarms}=  (?i)vendor bts certificate
    ...                      Synchronization lost
    ...                      .*BTS booted at.+
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | active_alarms          | Yes  | List of active alarms.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${active_alarms_count}=  Get Length  item=${active_alarms}
    Log  \n Active alarms count is ${active_alarms_count}
    Return From Keyword If  ${active_alarms_count}==0
    ${allowed_act_alarms}=  Create List
    ${allowed_act_alarms_match}=  Create List
    ${unexpected_act_alarms}=  Create List
    Log List  ${active_alarms}
    # The alarms were collected using for example "Get Alarms" keyword (ute_admin library)
    ${alarmInformation_key_exist}=  Run Keyword And Return Status
    ...  Set Variable  ${active_alarms[0]['alarmInformation']['alarmDetail']}
    # The alarms were collected from ims file. SCFC parameter "actCategoryAlarms" was set to True
    ${alarmText_key_exist}=  Run Keyword And Return Status
    ...  Set Variable  ${active_alarms[0]['alarmText']['alarmDetail']}
    # The alarms were collected from ims file. SCFC parameter "actCategoryAlarms" was set to False
    ${alarmInformation_alarmText_key_exist}=  Run Keyword And Return Status
    ...  Set Variable  ${active_alarms[0]['alarmInformation']['alarmText']['alarmDetail']}
    ${alarmDetail_key}  ${faultId_key}  ${faultSeverity_key}=  Run Keyword If  ${alarmInformation_key_exist}
    ...  Set Variable  ['alarmInformation']['alarmDetail']  ['faultId']  ['faultSeverity']
    ...  ELSE IF  ${alarmText_key_exist}
    ...  Set Variable  ['alarmText']['alarmDetail']  ['faultId']  ['faultSeverity']
    ...  ELSE IF  ${alarmInformation_alarmText_key_exist}
    ...  Set Variable  ['alarmInformation']['alarmText']['alarmDetail']  ['alarmInformation']['faultId']
    ...  ['alarmInformation']['faultSeverity']
    FOR  ${active_alarm}  IN  @{active_alarms}
      ${allowed_alarm_status}  ${allowed_alarm_match}=  Admin Check Allowed Alarm
      ...  allowed_alarms=${allowed_alarms}  active_alarm=${active_alarm${alarmDetail_key} }
      ${faultId}=  Set Variable  faultId=${active_alarm${faultId_key}}
      ${alarm Detail}=  Set Variable  alarmDetail=${active_alarm${alarmDetail_key}}
      ${faultSeverity}=  Set Variable  faultSeverity=${active_alarm${faultSeverity_key}}
      Run Keyword If  ${allowed_alarm_status}  Run Keywords
      ...  Append To List  ${allowed_act_alarms}  ${active_alarm${alarmDetail_key}}
      ...  AND
      ...  Append To List  ${allowed_act_alarms_match}  ${allowed_alarm_match}
      ...  ELSE
      ...  Append To List  ${unexpected_act_alarms}
      ...  ${faultId},${alarm Detail},${faultSeverity}
    END
#ALLOW ACTIVE ALARMS LOG
    ${allowed_act_alarms_count}=  Get Length  item=${allowed_act_alarms}
    ${allowed_act_alarms_string}=  Set Variable  Admin allowed active alarms count is ${allowed_act_alarms_count}
    FOR  ${allowed_act_alarm}  ${allowed_act_alarm_match}  IN ZIP  ${allowed_act_alarms}  ${allowed_act_alarms_match}
      ${allowed_act_alarms_string}=  Catenate  ${allowed_act_alarms_string}
      ...  \nAllowed active alarm: alarmDetail=${allowed_act_alarm} (Alowed alarm regex: "${allowed_act_alarm_match}")
    END
    Log  \n${allowed_act_alarms_string}\n  console=${log_to_console}
#UNEXPECTED ACTIVE ALARMS LOG
    ${unexpected_act_alarms_count}=  Get Length  item=${unexpected_act_alarms}
    ${unexpected_act_alarms_string}=  Set Variable
    ...  Admin unexpected active alarms count is ${unexpected_act_alarms_count}
    FOR  ${unexpected_act_alarm}  IN  @{unexpected_act_alarms}
      ${unexpected_act_alarms_string}=  Catenate  ${unexpected_act_alarms_string}
      ...  \nAdmin unexpected alarm: ${unexpected_act_alarm}
    END
    Log  \n${unexpected_act_alarms_string}\n
    Run Keyword If  ${unexpected_act_alarms_count}>0  Fail  ${unexpected_act_alarms_string}

Admin Check Allowed Alarm
    [Arguments]  ${allowed_alarms}  ${active_alarm}
    [Documentation]
    ...  Description:
    ...  Keyword checks if the active alarm is on the list of allowed alarms.
    ...  Keyword returns information whether the active alarm is on the list of allowed alarms (True, False).
    ...  If the active alarm is on the list of allowed alarms, the regex of the allowed alarm is returned.
    ...  The 'alarmDetail' field is taken into account.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | active_alarms          | Yes  | List of active alarms.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    FOR  ${allowed_alarm}  IN  @{allowed_alarms}
      ${allowed_alarm_status}=  Run Keyword And Return Status
      ...  Should Be Equal  ${active_alarm}  ${allowed_alarm}
      Exit For Loop If  ${allowed_alarm_status}
    END
    [Return]  ${allowed_alarm_status}  ${allowed_alarm}

Verify Unexpected Active Alarms
    [Arguments]  ${allowed_alarms}  ${connection}=default  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks unexpected active alarms.
    ...  Allowed alarms are given by fault id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms given by fault id.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Alias of admin connection.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    admin.Clear Allowed Alarms List  connection=${connection}
    FOR  ${allow_alarm}  IN  @{allowed_alarms}
      admin.Add Allowed Alarm  parameters=${allow_alarm}  connection=${connection}
    END
    ${unexpected_alarms_status}  ${unexpected_alarms}=  Run Keyword And Ignore Error
    ...  admin.Assert No Unexpected Active Alarms  connection=${connection}
    Run Keyword If    "${unexpected_alarms_status}" == "FAIL"
    ...  Fail  msg=[!] Unexpected active alarms has been detected. Please check logs for details !!!
    ...  ELSE
    ...  Log  message=${log_prefix}No unexpected active alarms detected  console=${log_to_console}

Verify Unexpected Historical Alarms
    [Arguments]  ${allowed_alarms}  ${connection}=default  ${log_to_console}=True  ${log_prefix}=${EMPTY}
    [Documentation]
    ...  Description:
    ...  Keyword checks unexpected historical alarms.
    ...  Allowed alarms are given by fault id.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | allowed_alarms         | Yes  | List of allowed alarms given by fault id.                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Alias of admin connection.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    admin.Clear Allowed Alarms List  connection=${connection}
    FOR  ${allow_alarm}  IN  @{allowed_alarms}
      admin.Add Allowed Alarm  parameters=${allow_alarm}  connection=${connection}
    END
    ${historical_alarm_status}  ${unexpected_historical_alarms}=  Run Keyword And Ignore Error
    ...  admin.Assert No Unexpected Historical Alarms    connection=${connection}
    Run Keyword If    '${historical_alarm_status}'=='FAIL'
    ...  Fail  msg=[!] Unexpected historical alarms has been detected. Please check logs for details !!!
    ...  ELSE
    ...  Log  message=${log_prefix}No unexpected historical alarms detected  console=${log_to_console}

Check BTS Reset Cause Alarm
    [Arguments]  ${activation_timeout}  ${cancellation_timeout}  ${info_pattern}=${EMPTY}
    ...  ${admin_connection}=default  ${log_prefix}=${EMPTY}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether an alarm (FID=4592) has occurred.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | activation_timeout     | Yes  | Wait until alarm 4592 is active.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | cancellation_timeout   | Yes  | Wait until alarm 4592 is inactive.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | info_pattern           | Yes  | Additional information about the fault reason.                             |
    ...  |                        |      | Pattern matching is similar as matching files in a shell: `*`, `?', etc.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or string name alias if used.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

# Assert Alarm Active (FID=4592)
    ${info_below_prefix}=  Set Variable If  '${info_pattern}'=='${EMPTY}'  ${EMPTY}  \t${SPACE * 7}
    Log  ${log_prefix}Waiting for alarm (FID=4592) activation ...  console=${log_to_console}
    ${alarm_severity}=  Set Variable If  ${cancellation_timeout} > 30  Minor  Warning
    TRY
      ${active_alarms_list}=  admin.Assert Alarm Active
      ...  parameters=faultId=4592, severity=${alarm_severity}, faultName="BTS Reset Cause"
      ...  timeout=${activation_timeout}
      ...  connection=${admin_connection}
    EXCEPT
      Run Keyword And Continue On Failure
      ...  Fail  msg=Alarm (FID=4592) was not found within the specified time. Please check logs !
      Return From Keyword
    ELSE
      Log  ${log_prefix}Alarm (FID=4592) is active now  console=${log_to_console}
      ${alarm_info_list}=  Create List
      FOR  ${active_alarm}  IN  @{active_alarms_list}
        IF  '${active_alarm['faultId']}'=='4592'
          Log  ${log_prefix}Alarm (FID=4592) additional information:  console=${log_to_console}
          Log  ${info_below_prefix}Additional info: ${active_alarm['supplAlarmInfo']}  console=${log_to_console}
          Append To List  ${alarm_info_list}  ${active_alarm['supplAlarmInfo']}
        END
      END
      TRY
        Should Contain Match  list=${alarm_info_list}  pattern=${info_pattern}
      EXCEPT
        Run Keyword And Continue On Failure
        ...  Fail  msg=Unexpected alarm (FID=4592) reason. Please check logs !
      END
    END
    Sleep  10s  reason=Additional time to start alarm deactivation
# Assert Alarm Inactive (FID=4592)
    Log  ${log_prefix}Alarm (FID=4592) cancellation timer: ${cancellation_timeout}s  console=${log_to_console}
    Log  ${log_prefix}Waiting for alarm (FID=4592) deactivation (FID=4592) ...  console=${log_to_console}
    TRY
      admin.Assert Alarm Inactive
      ...  parameters=faultId=4592, severity=${alarm_severity}, faultName="BTS Reset Cause"
      ...  timeout=${cancellation_timeout}
      ...  connection=${admin_connection}
    EXCEPT
      Run Keyword And Continue On Failure
      ...  Fail  msg=Alarm (FID=4592) was not deactivated within the specified time. Please check logs !
    ELSE
      Log  ${log_prefix}Alarm (FID=4592) is inactive now  console=${log_to_console}
    END

Check BTS Reset Cause Historical Alarm
    [Arguments]  ${cancellation_timeout}=30  ${info_pattern}=${EMPTY}  ${admin_connection}=default
    ...  ${log_prefix}=${EMPTY}  ${log_to_console}=${True}
    [Documentation]
    ...  Description:
    ...  Keyword checks whether an alarm (FID=4592) has occurred.
    ...  Historical alarms are checked.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cancellation_timeout   | Yes  | Fault 4592 timeout.                                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | info_pattern           | Yes  | Additional information about the fault reason.                             |
    ...  |                        |      | Pattern matching is similar as matching files in a shell: `*`, `?', etc.   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | admin_connection       |  No  | Admin connection object or string name alias if used.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_prefix             |  No  | Show defined prefix in log console output.                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    ${info_below_prefix}=  Set Variable If  '${info_pattern}'=='${EMPTY}'  ${EMPTY}  \t${SPACE * 7}
    ${alarm_severity}=  Set Variable If  ${cancellation_timeout} > 30  Minor  Warning
    ${fault_exist}=  Set Variable  ${False}
    ${historical_alarms_list}=  admin.Get Historic Alarms
    ...  severity=${alarm_severity}
    ...  connection=${admin_connection}
    FOR  ${historical_alarm}  IN  @{historical_alarms_list}
      IF  '${historical_alarm['faultId']}'=='4592'
        Log  ${log_prefix}Alarm (FID=4592) additional information:  console=${log_to_console}
        Log  ${info_below_prefix}Additional info: ${historical_alarm['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']}
        ...  console=${log_to_console}
        TRY
          Should Match  string=${historical_alarm['alarmText']['alarmAdditionalInfo']['supplAlarmInfo']}
          ...  pattern=${info_pattern}
        EXCEPT
          Run Keyword And Continue On Failure
          ...  Fail  msg=Unexpected alarm (FID=4592) reason. Please check logs !
        END
        ${alarm_observation_time}=  Set Variable  ${historical_alarm['btsObservationTime']}
        ${alarm_cleared_time}=  Set Variable  ${historical_alarm['clearedTime']}
        ${alarm_observation_time}=  Fetch From Left  string=${alarm_observation_time}  marker=+
        ${alarm_cleared_time}=  Fetch From Left  string=${alarm_cleared_time}  marker=+
        ${alarm_observation_time}=  Fetch From Left  string=${alarm_observation_time}  marker=-
        ${alarm_cleared_time}=  Fetch From Left  string=${alarm_cleared_time}  marker=-
        ${alarm_duration_time}=  Subtract Date From Date  date1=${alarm_cleared_time}  date2=${alarm_observation_time}
        ${time_difference}=  Evaluate  expression=${alarm_duration_time}-${cancellation_timeout}
        IF  ${time_difference} > 5
          Run Keyword And Continue On Failure
          ...  Fail  msg=Alarm (FID=4592) was not deactivated within the specified time. Please check logs !
        END
        ${fault_exist}=  Set Variable  ${True}
      END
    END
    IF  not ${fault_exist}
      Run Keyword And Continue On Failure
      ...  Fail  msg=Alarm (FID=4592) was not found in historical alarms !
    END
