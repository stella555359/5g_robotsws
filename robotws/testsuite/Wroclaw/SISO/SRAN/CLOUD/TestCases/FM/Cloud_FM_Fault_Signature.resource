*** Settings ***
Documentation    Common keywords for fault signature testing
...    Author:        daniel.bartkowiak@nokia.com
...    Maintainer:    Daniel Bartkowiak

Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

*** Keywords ***
Cloud FM Analyze Alarm List For Fault Signature
    [Arguments]  ${faultId}  ${alarm_info}  ${allowed_severity}  ${expected_alarm_info}  ${occurence_rate}
    ...  ${ru_sn}=${EMPTY}  ${fault_trigger_timestamp}=${EMPTY}  ${fault_signature_scheme}=${EMPTY}
    ...  ${tolerance_timeout}=360  ${vdu_connection}=default
    [Documentation]
    ...  Searches active alarms list for given FID and triggers analysis of it's fault signature field
    ...
    ...  For parameter allowed_severities -> 'critical', no fault signature field is expected in alarm info.
    ...  For parameter allowed_severities -> 'warning' fault signature field is expected
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | alarm_info                | Yes  | list containing active alarms info                                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | faultId                   | Yes  | faultID under test                                                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test, default EMPTY              |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | allowed_severity          | Yes  | expected severity                                                  |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_trigger_timestamp   | Yes  | earliest possible timestamp of FID occurence, default EMPTY        |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_scheme    | Yes  | dict with structurized info on expected fault signature fields     |
    ...  |                           |      | default EMPTY                                                      |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | expected_alarm_info       | Yes  | alarm info as a list gathered from NIDD for faultId                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | occurence_rate            | Yes  | how many times fault should appear in history                      |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | tolerance_timeout         | No   | tolerance window lenght for all faults to appear                   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ${fault_counter}=  Set Variable  0
    Log  ${dots_prefix_green}Fault signature check started  console=${log_to_console}
    Log  ${info_prefix}Waiting for history fault ${faultId} with severity ${allowed_severity}. Should occur ${occurence_rate} times.
    ...  console=${log_to_console}
    FOR  ${alarm}  IN  @{alarm_info}
      IF  '${alarm['faultId']}'=='${faultId}' and '${alarm['severity']}'=='${allowed_severity}'
        ${fault_counter}=  Evaluate  ${fault_counter} + 1
        Log  ${info_prefix}${fault_counter} attempt:  console=${log_to_console}
        Cloud FM Check Alarm Details
        ...  fault_to_check=${alarm}
        ...  alarm_details_scheme=${expected_alarm_info}
        IF  '${allowed_severity}'=='critical'
          ${critical_status}=  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${alarm}  faultSignature
          IF  not ${critical_status}
            Log  ${failed_result} Fault ${alarm['faultId']} with severity ${alarm['severity']} contains faultSignature field. It should not.
            ...  console=${log_to_console}
            Fail  Fault ${faultId} with severity ${allowed_severity} contains faultSignature field. It should not.
          END
          Log  ${info_prefix}Fault ${alarm['faultId']} with severity ${alarm['severity']} does not contain faultSignature field as expected.
          ...  console=${log_to_console}
          CONTINUE
        END
        Cloud FM Check Fault Signature
        ...  fault_to_check=${alarm}
        ...  fault_signature_scheme=${fault_signature_scheme}
        ...  ru_sn=${ru_sn}
        ...  fault_trigger_timestamp=${fault_trigger_timestamp}
        ...  vdu_connection=${vdu_connection}
        ...  tolerance_timeout=${tolerance_timeout}
      END
    END
    IF  ${fault_counter} != ${occurence_rate}
      Log  ${failed_result}Fault ${faultId} severity ${allowed_severity} found ${fault_counter} times, expected ${occurence_rate} times.
      ...  console=${log_to_console}
      Fail  Fault ${faultId} severity ${allowed_severity} found ${fault_counter} times, expected ${occurence_rate} times.
    END
    Log  ${ok_prefix_green}Fault ${faultId} with severity ${allowed_severity} occurred ${fault_counter} times as expected.
    ...  console=${log_to_console}

Cloud FM Check Alarm Details
    [Arguments]  ${fault_to_check}  ${alarm_details_scheme}
    [Documentation]
    ...  Checks if alarm reported with given fault is correct.
    ...  Reported pair of alarmId and alarmName must be one of defined in alarm_details_scheme list.
    ...  List alarm_details_scheme should contain information on alarm as defined in Reported Alarms section of NIDD.
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                        |
    ...  +======================+======+====================================================================+
    ...  | fault_to_check       | Yes  | fault info to be checked                                           |
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | alarm_details_scheme | Yes  | list with details for possible alarms reported with given FID      |
    ...  +----------------------+------+--------------------------------------------------------------------+

    ${alarmId}=  Get From Dictionary  dictionary=${fault_to_check}  key=alarmId
    ${alarmName}=  Get From Dictionary  dictionary=${fault_to_check}  key=alarmName
    ${alarm_status}=  Run Keyword And Return Status  List Should Contain Value  ${alarm_details_scheme}
    ...  value=${alarmId} ${alarmName}
    IF  not ${alarm_status}
      Log  ${failed_result} Fault ${fault_to_check['faultId']} has wrong alarmId/alarmName -> ${alarmId} ${alarmName}
      ...  console=${log_to_console}
      Log  ${info_prefix}Should be one of: ${alarm_details_scheme}  console=${log_to_console}
      Fail  Fault ${fault_to_check['faultId']} has wrong alarmId/alarmName -> ${alarmId} ${alarmName}. Should be one of: ${alarm_details_scheme}
    END
    Log  ${info_prefix}AlarmId/AlarmName is correct  console=${log_to_console}

Cloud FM Check Fault Signature
    [Arguments]  ${fault_to_check}  ${fault_signature_scheme}  ${ru_sn}  ${fault_trigger_timestamp}
    ...  ${vdu_connection}=default  ${tolerance_timeout}=360
    [Documentation]
    ...  Analyses fault info in context of fault signature fields existence and values
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_to_check            | Yes  | dictionary containing fault info                                   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_scheme    | Yes  | dict with structurized info on expected fault signature fields     |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_trigger_timestamp   | Yes  | earliest possible timestamp of FID occurence                       |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test                             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | tolerance_timeout         | No   | tolerance window length for fault signature timestamp in seconds   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    Should Not Be Empty  ${fault_signature_scheme}  Fault Signature scheme should not be empty
    Should Not Be Empty  ${fault_trigger_timestamp}  Fault trigger timestamp should not be empty
    Should Not Be Empty  ${ru_sn}  RU serial number should not be empty

    Cloud FM Check Category In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ref_category=${fault_signature_scheme['category']}
    Cloud FM Check Component In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ref_component=${fault_signature_scheme['component']}
    ...  ru_sn=${ru_sn}
    Cloud FM Check Date In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ref_date=${fault_signature_scheme['date']}
    ...  fault_trigger_timestamp=${fault_trigger_timestamp}
    ...  tolerance_timeout=${tolerance_timeout}
    Cloud FM Check Extra Info In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ref_extra_info=${fault_signature_scheme['extraInfo']}
    ...  ru_sn=${ru_sn}
    ...  vdu_connection=${vdu_connection}
    Cloud FM Check Load Name In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ru_sn=${ru_sn}
    ...  ref_load_name=${fault_signature_scheme['loadName']}
    ...  vdu_connection=${vdu_connection}
    Cloud FM Check Reset Counter In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ref_reset_counter=${fault_signature_scheme['resetCounter']}
    Cloud FM Check Scope In Fault Signature
    ...  fault_signature_to_check=${fault_to_check['faultSignature']}
    ...  ref_scope=${fault_signature_scheme['scope']}

Cloud FM Check Category In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ref_category}
    [Documentation]  Keyword to check 'category' field in fault signature. Should be "SW_FILURE"
    ...  If category validation mechanism will change, then this keyword should be updated and reference dictionary
    ...  in variables.robot should be modified accordingly. Use "_to_check" suffix in global 'FAULT_SIGNATURE_DICT'
    ...  to mark dynamic values and update this keyword to handle them.
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_category              | Yes  | reference category value taken from global variables               |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${cat_status}=  Run Keyword And Return Status  Should Be Equal As Strings
    ...  ${fault_signature_to_check['category']}  ${ref_category}
    IF  not ${cat_status}
      Log  ${failed_result} Fault Signature 'category' field is incorrect -> ${fault_signature_to_check['category']}
      ...  console=${log_to_console}
      Log  ${failed_result}Expected value: ${ref_category}  console=${log_to_console}
      Fail  Fault Signature 'category' field is incorrect -> ${fault_signature_to_check['category']}. Expected value: ${ref_category}
    END
    Log  ${info_prefix}Category in Fault Signature is correct  console=${log_to_console}

Cloud FM Check Component In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ref_component}  ${ru_sn}
    [Documentation]  Keyword to check 'component' field in fault signature. Should be sn of RU under test
    ...  If component validation mechanism will change, then this keyword should be updated and reference dictionary
    ...  in variables.robot should be modified accordingly. Use "_to_check" suffix in global 'FAULT_SIGNATURE_DICT'
    ...  to mark dynamic values and update this keyword to handle them.
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_component             | Yes  | reference component value taken from global variables              |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test                             |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    IF  '${ref_component}' == 'sn_to_check'
      ${expected_value}=  Set Variable  ${ru_sn}
      ${comp_status}=  Run Keyword And Return Status  Should Be Equal As Strings
      ...  ${fault_signature_to_check['component']}  ${expected_value}
    ELSE
      Fail  Fault Signature 'component' field check failed. Unsupported expected value: ${ref_component}
    END
    IF  not ${comp_status}
      Log  ${failed_result}Fault Signature 'component' field is incorrect. Wrong value -> ${fault_signature_to_check['component']}
      ...  console=${log_to_console}
      Log  ${failed_result}Expected value: ${expected_value}  console=${log_to_console}
      Fail  Fault Signature 'component' field is incorrect -> ${fault_signature_to_check['component']}. Expected value: ${ru_sn}
    END
    Log  ${info_prefix}Component in Fault Signature is correct  console=${log_to_console}

Cloud FM Check Date In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ref_date}  ${fault_trigger_timestamp}  ${tolerance_timeout}=360
    [Documentation]
    ...  Analyses 'date' field of fault signature. Timestamp in that field is expected
    ...  to be in fault_trigger_timestamp <-> fault_trigger_timestamp + tolerance_timeout window.
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_date                  | Yes  | fault signature date value taken from global variables             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_trigger_timestamp   | Yes  | earliest possible timestamp of FID occurence                       |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | tolerance_timeout         | No   | tolerance window lenght for fault signature timestamp in seconds   |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${fault_trigger_time_in_epoch}=  Convert Date  date=${fault_trigger_timestamp}
    ...  result_format=epoch
    ...  exclude_millis=False
    ${fs_date}=  Set Variable  ${fault_signature_to_check['date']}
    ${fs_date}=  Evaluate  "${fs_date}".replace("Z", "+00:00")
    ${fs_date_utc}=  Evaluate  datetime.datetime.fromisoformat("${fs_date}").astimezone(datetime.timezone.utc)  modules=datetime
    ${fault_signature_time_in_epoch}=  Convert Date  date=${fs_date_utc}
    ...  result_format=epoch
    ...  exclude_millis=False
    IF  '${ref_date}' == 'date_to_check'
      ${fault_signature_date_is_correct}=  Evaluate
      ...  ${fault_trigger_time_in_epoch} <= ${fault_signature_time_in_epoch} <= (${fault_trigger_time_in_epoch} + ${tolerance_timeout})
      ${date_status}=  Run Keyword And Return Status  Should Be True  ${fault_signature_date_is_correct}
    ELSE
      Fail  Fault Signature 'date' field check failed. Unsupported expected value: ${ref_date}
    END
    IF  not ${date_status}
      Log  ${failed_result}Fault Signature 'date' doesn't fit in tolerance window  console=${log_to_console}
      Log  ${failed_result}Expected tolerance window in sec is fault_trigger_timestamp <-> fault_trigger_timestamp + tolerance_timeout
      ...  console=${log_to_console}
      Fail  Fault Signature 'date' field is incorrect -> ${fault_signature_to_check['date']}. Doesn't fit tolerance window.
    END
    Log  ${info_prefix}Date in Fault Signature is correct  console=${log_to_console}

Cloud FM Check Extra Info In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ref_extra_info}  ${ru_sn}  ${vdu_connection}=default
    [Documentation]  Keyword to check 'extraInfo' field in fault signature. Should be list of affected cell IDs
    ...  If extraInfo validation mechanism will change, then this keyword should be updated and reference dictionary
    ...  in variables.robot should be modified accordingly. Use "_to_check" suffix in global 'FAULT_SIGNATURE_DICT'
    ...  to mark dynamic values and update this keyword to handle them.
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_extra_info            | Yes  | reference loadName value taken from global variables               |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test                             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ${rmod_cell_ids_list}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${ru_sn}  rmod_param=cell_ids
    Sort List  ${rmod_cell_ids_list}
    IF  '${ref_extra_info}' == 'nr_cells_to_check'
      ${expected_value}=  Set Variable  ${rmod_cell_ids_list}
      ${fault_signature_value}=  Get Regexp Matches  ${fault_signature_to_check['extraInfo']}  \\d+
      Sort List  ${fault_signature_value}
      ${extra_info_status}=  Run Keyword And Return Status  Lists Should Be Equal  ${fault_signature_value}  ${expected_value}
    ELSE
      ${expected_value}=  Set Variable  ${ref_extra_info}
      IF  '${ref_extra_info}' in '${fault_signature_to_check['extraInfo']}'
        ${extra_info_status}=  Set Variable  True
      ELSE
        ${extra_info_status}=  Set Variable  False
      END
    END
    IF  not ${extra_info_status}
      Log  ${failed_result}Fault Signature 'extraInfo' field is incorrect -> ${fault_signature_to_check['extraInfo']}
      ...  console=${log_to_console}
      Log  ${failed_result}Expected value: ${expected_value}  console=${log_to_console}
      Fail  Fault Signature 'extraInfo' field is incorrect -> ${fault_signature_to_check['extraInfo']}. Expected value: ${expected_value}
    END
    Log  ${info_prefix}Extra Info in Fault Signature is correct  console=${log_to_console}

Cloud FM Check Load Name In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ru_sn}  ${ref_load_name}  ${vdu_connection}=default
    [Documentation]  Keyword to check 'loadName' field in fault signature. Should be vdu_sw;rmod_sw version
    ...  If loadName validation mechanism will change, then this keyword should be updated and reference dictionary
    ...  in variables.robot should be modified accordingly. Use "_to_check" suffix in global 'FAULT_SIGNATURE_DICT'
    ...  to mark dynamic values and update this keyword to handle them.
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test                             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_load_name             | Yes  | reference loadName value taken from global variables               |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | vdu_connection            | No   | vDU connection object or string name alias if used                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ${rmod_sw}=  vDU RMOD Get Parameter Value Based On Serial Number
    ...  rmod_sn=${ru_sn}  rmod_param=active_sw_version
    ${vdu_state_date}=  vdu.Get Vdu State Data  vdu_connection=${vdu_connection}
    ${load_name}=  Set Variable  ${fault_signature_to_check['loadName']}
    IF  '${ref_load_name}' == 'loadname_to_check'
      IF  '${rmod_sw}' not in '${load_name}' or '${vdu_state_date['software_version']}' not in '${load_name}'
        ${load_name_status}=  Set Variable  False
      ELSE
        ${load_name_status}=  Set Variable  True
      END
    ELSE
      Fail  Fault Signature 'loadName' field check failed. Unsupported expected value: ${ref_load_name}
    END
    IF  not ${load_name_status}
      Log  ${failed_result}Fault Signature 'loadName' field is incorrect -> ${load_name}  console=${log_to_console}
      Log  ${failed_result}Expected value should contain radio and vdu software version:  console=${log_to_console}
      Log  ${failed_result}radio_sw -> ${rmod_sw} vdu_sw -> ${vdu_state_date['software_version']}  console=${log_to_console}
      Fail  Fault Signature 'loadName' field is incorrect -> ${load_name}. Expected value should contain radio and vdu software version
    END
    Log  ${info_prefix}Load Name in Fault Signature is correct  console=${log_to_console}

Cloud FM Check Reset Counter In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ref_reset_counter}
    [Documentation]  Keyword to check 'resetCounter' field in fault signature. Should be integer >=0
    ...  If resetCounter validation mechanism will change, then this keyword should be updated and reference dictionary
    ...  in variables.robot should be modified accordingly. Use "_to_check" suffix in global 'FAULT_SIGNATURE_DICT'
    ...  to mark dynamic values and update this keyword to handle them.
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_reset_counter         | Yes  | reference resetCounter value taken from global variables           |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    IF  '${ref_reset_counter}' == 'int_to_check'
      ${resetCounter}=  Convert To String  ${fault_signature_to_check['resetCounter']}
      ${reset_counter_status}=  Run Keyword And Return Status  Should Match Regexp
      ...  string=${resetCounter}
      ...  pattern=^\\d+$
    ELSE
      Fail  Fault Signature 'resetCounter' field check failed. Unsupported expected value: ${ref_reset_counter}
    END
    IF  not ${reset_counter_status}
      Log  ${failed_result}Fault Signature 'resetCounter' field is incorrect -> ${fault_signature_to_check['resetCounter']}
      ...  console=${log_to_console}
      Log  ${failed_result}Expected value: integer >= 0  console=${log_to_console}
      Fail  Fault Signature 'resetCounter' field is incorrect -> ${fault_signature_to_check['resetCounter']}. Expected value: integer >= 0
    END
    Log  ${info_prefix}Reset Counter in Fault Signature is correct  console=${log_to_console}

Cloud FM Check Scope In Fault Signature
    [Arguments]  ${fault_signature_to_check}  ${ref_scope}
    [Documentation]  Keyword to check 'scope' field in fault signature
    ...  If scope validation mechanism will change, then this keyword should be updated and reference dictionary
    ...  in variables.robot should be modified accordingly. Use "_to_check" suffix in global 'FAULT_SIGNATURE_DICT'
    ...  to mark dynamic values and update this keyword to handle them.
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info taken from API                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ref_scope                 | Yes  | reference scope value taken from global variables                  |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${scope_status}=  Run Keyword And Return Status  Should Be Equal As Strings
    ...  ${fault_signature_to_check['scope']}  ${ref_scope}
    IF  not ${scope_status}
      Log  ${failed_result}Fault Signature 'scope' field is incorrect -> ${fault_signature_to_check['scope']}
      ...  console=${log_to_console}
      Log  ${failed_result}Expected value: ${ref_scope}  console=${log_to_console}
      Fail  Fault Signature 'scope' field is incorrect -> ${fault_signature_to_check['scope']}. Expected value: ${ref_scope}
    END
    Log  ${info_prefix}Scope in Fault Signature is correct  console=${log_to_console}

Cloud FM Recover Fault
    [Arguments]  ${faultId}  ${ru_serial_number}  ${cloud_server_ip}
    [Documentation]
    ...  Recovers previously triggered fault on given RU
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | faultId                   | Yes  | faultId under test                                                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_serial_number          | Yes  | rradio serial number                                               |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | cloud_server_ip           | Yes  | vdu cloud server ip                                                |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    radio.Recover Fault  fault_id=${faultId}  ru_serial_number=${ru_serial_number}  cloud_server_ip=${cloud_server_ip}
    Log  ${ok_prefix_green}Recover Fault ${fault_id} on RU: ${ru_serial_number}  console=${log_to_console}

Teardown FM Fault Signature
    [Arguments]  ${tc_status}  ${vdu_connection}=default
    [Documentation]  Teardown procedures
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | tc_status              | Yes  | TC status                                                |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+

    IF  '${rec_vdu_reset}'=='${TRUE}'
      Log  ${info_prefix}Teardown: Performing vDU reset to clear OAM counters  console=${log_to_console}
      Run Keyword And Ignore Error  Cloud FM Perform VDU Recovery
      Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}
    ELSE
      Log  ${info_prefix}Teardown: Skipping vDU recovery reset  console=${log_to_console}
    END
    IF  '${tc_status}'=='FAIL' and '${rec_vdu_reset}'=='${FALSE}'
      Log  ${info_prefix}Teardown: TC failed. Ensuring vDU is onair after radio recovery  console=${log_to_console}
      Run Keyword And Ignore Error  Cloud FM Check Basic States Onair
      ...  timeout=${RADIO_STARTUP_DELAY}  vdu_connection=${vdu_connection}
    END
    Run Keyword And Ignore Error  vDU Rest Logout  vdu_connection=${vdu_connection}

Cloud FM Perform VDU Recovery
    [Arguments]  ${vdu_connection}=default
    [Documentation]  VDU recovery procedure
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+
    ${reset_result}=  vdu.Reset Vdu  vdu_connection=${vdu_connection}
    vDU Rest Logout  vdu_connection=${vdu_connection}
    Log  ${info_prefix}Teardown: vDU reset status ${reset_result['status']}  console=${log_to_console}
    ${oam_http_connection}=  Get vDU Oam Http Connection Parameters From Init File
    ${ip_addr}=  Set Variable  ${oam_http_connection["ip_addr"]}
    Ip Address Is Unavailable  ip_addr=${ip_addr}
    Log  ${info_prefix}Teardown: vDU is unavailable. Wait for vDU availability ...  console=${log_to_console}
    Wait Until Keyword Succeeds  180  5
    ...  vDU Rest Login  vdu_connection=${vdu_connection}
    Cloud FM Check Basic States Onair  timeout=${RADIO_STARTUP_DELAY}  vdu_connection=${vdu_connection}

Cloud FM Verify Oran Alarm On Radio
    [Arguments]  ${ru_sn}  ${oran_alarm_id}  ${oran_alarm_name}  ${cloud_server_ip}  ${status}
    [Documentation]   Verifies if ORAN fault is present in raw_alarm_history.txt on radio after triggering fault
    ...  Keyword checks inactive or active status of given ORAN fault
    ...  Arguments:
    ...  +========================+======+=================================================================+
    ...  | Argument               | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | ru_sn                  | Yes  | serial number of radio unit under test                          |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | oran_alarm_id          | Yes  | ORAN alarm ID to be verified                                    |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | oran_alarm_name        | Yes  | ORAN alarm name to be verified                                  |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | cloud_server_ip        | Yes  | vdu cloud server ip                                             |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | status                 | Yes  | oran alarm status to check, possible values: active, inactive   |
    ...  +------------------------+------+-----------------------------------------------------------------+

    IF  '${status}'=='active'
      ${alarm_status}=  Run Keyword And Return Status  radio.Assert Active Alarm In Fault History Log File
      ...  ru_serial_number=${ru_sn}
      ...  alarm_id=${oran_alarm_id}
      ...  alarm_name=${oran_alarm_name}
      ...  cloud_server_ip=${cloud_server_ip}
    ELSE IF  '${status}'=='inactive'
      ${alarm_status}=  Run Keyword And Return Status  radio.Assert Inactive Alarm In Fault History Log File
      ...  ru_serial_number=${ru_sn}
      ...  alarm_id=${oran_alarm_id}
      ...  alarm_name=${oran_alarm_name}
      ...  cloud_server_ip=${cloud_server_ip}
    ELSE
      Fail  Unsupported status value: ${status}. Supported values are: active, inactive
    END
    IF  not ${alarm_status}
      Log  ${failed_result}ORAN Alarm ID: ${oran_alarm_id} Name: ${oran_alarm_name} should be ${status}  console=${log_to_console}
      Log  ${failed_result}Check failed in fault history log on RU: ${ru_sn}  console=${log_to_console}
      Fail  ORAN Alarm ID: ${oran_alarm_id} Name: ${oran_alarm_name} with status: ${status} check failed
    END
    Log  ${ok_prefix_green}ORAN Alarm ID: ${oran_alarmid} Name: ${oran_alarm_name} is ${status}  console=${log_to_console}
    Log  ${ok_prefix_green}Check successful in fault history log on RU: ${ru_sn}  console=${log_to_console}

Cloud FM Verify Raw Fault On Radio
    [Arguments]  ${ru_sn}  ${raw_fault_id}  ${raw_fault_name}  ${cloud_server_ip}  ${status}
    [Documentation]   Verifies if raw fault is present in raw_alarm_history.txt on radio after triggering fault
    ...  Keyword checks inactive or active status of given raw fault
    ...  Arguments:
    ...  +========================+======+=================================================================+
    ...  | Argument               | Man. | Description                                                     |
    ...  +========================+======+=================================================================+
    ...  | ru_sn                  | Yes  | serial number of radio unit under test                          |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | raw_fault_id           | Yes  | Raw fault ID to be verified                                     |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | raw_fault_name         | Yes  | Raw fault name to be verified                                   |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | cloud_server_ip        | Yes  | vdu cloud server ip                                             |
    ...  +------------------------+------+-----------------------------------------------------------------+
    ...  | status                 | Yes  | Raw alarm status to check, possible values: active, inactive    |
    ...  +------------------------+------+-----------------------------------------------------------------+

    IF  '${status}'=='active'
      ${alarm_status}=  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
      ...  ru_serial_number=${ru_sn}
      ...  fault_id=${raw_fault_id}
      ...  fault_name=${raw_fault_name}
      ...  cloud_server_ip=${cloud_server_ip}
    ELSE IF  '${status}'=='inactive'
      ${alarm_status}=  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
      ...  ru_serial_number=${ru_sn}
      ...  fault_id=${raw_fault_id}
      ...  fault_name=${raw_fault_name}
      ...  cloud_server_ip=${cloud_server_ip}
    ELSE
      Fail  Unsupported status value: ${status}. Supported values are: active, inactive
    END
    IF  not ${alarm_status}
      Log  ${failed_result}Raw Alarm ID: ${raw_fault_id} Name: ${raw_fault_name} should be ${status}  console=${log_to_console}
      Log  ${failed_result}Check failed in fault history log on RU: ${ru_sn}  console=${log_to_console}
      Fail  Raw Alarm ID: ${raw_fault_id} Name: ${raw_fault_name} with status: ${status} check failed
    END
    Log  ${ok_prefix_green}Raw Alarm ID: ${raw_fault_id} Name: ${raw_fault_name} is ${status}  console=${log_to_console}
    Log  ${ok_prefix_green}Check successful in fault history log on RU: ${ru_sn}  console=${log_to_console}

Cloud FM Check Basic States Onair
    [Arguments]  ${timeout}=${RADIO_STARTUP_DELAY}  ${vdu_connection}=default
    [Documentation]  Checks if vDU and all its radio modules and cells are in onAir state
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | timeout                |  No  | time to wait for rmods and cells reach onair             |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+
    Log  ${info_prefix}vDU is available. Waiting for onair  console=${log_to_console}
    Wait Until All Radio Modules Are Online
    ...  rmods_count=${vdu_scfc_rmods_count}
    ...  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
    Wait Until All Cells Are OnAir
    ...  cells_count=${vdu_scfc_nrcells_count}
    ...  timeout=${timeout}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}All cells are OnAir  console=${log_to_console}
    vDU Wait For Expected Operational State
    ...  vdu_state_value=onAir
    ...  timeout=30s
    ...  vdu_check=${True}
    ...  lte_vdu_check=${False}
    ...  vdu_connection=${vdu_connection}
    Log  ${info_prefix}vDU operational state is onAir  console=${log_to_console}

Cloud FM Check Alarming Info In Active Alarm
    [Arguments]  ${faultId}  ${alarming_info}  ${vdu_connection}=default
    [Documentation]  Checks if alarming info fields in active alarm are correct
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | faultId                |  Yes | FaultId to search in active alarms                       |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | alarming_info          |  Yes | Alarming info specified in variables.robot               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...  | vdu_connection         |  No  | vDU connection object or string name alias if used.      |
    ...  +------------------------+------+----------------------------------------------------------+

    ${active_faults}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_connection}
    FOR  ${fault}  IN  @{active_faults['alarms']}
      Continue For Loop If  '${fault['fault_id']}' != '${faultId}'
      ${expected_alarming_info}=  Catenate  ${fault['alarm_id']}  ${fault['alarm_name']}
      ${alarming_status}=  Run Keyword And Return Status
      ...  List Should Contain Value  ${alarming_info}  ${expected_alarming_info}
        IF  not ${alarming_status}
          Log  ${failed_result}Fault ${faultId} has wrong alarming info -> ${expected_alarming_info}
          ...  console=${log_to_console}
          Log  ${failed_result}Should be one of: ${alarming_info}  console=${log_to_console}
          Fail  Fault ${faultId} has wrong alarming info -> ${expected_alarming_info}. Should be one of: ${alarming_info}
        END
    END
