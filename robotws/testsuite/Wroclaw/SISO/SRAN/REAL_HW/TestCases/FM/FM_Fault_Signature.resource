*** Settings ***
Documentation    Common keywords for fault signature testing
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

*** Keywords ***
FM Analyze Alarm List For Fault Signature
    [Arguments]  ${alarm_info}  ${faultId}  ${fault_signature_scheme}  ${alarm_details_scheme}  ${ru_sn}  ${connection}
    ...  ${fault_signature_timestamp}=${None}  ${timestamp_timeout}=360  ${allowed_severities}=${None}
    ...  ${forbidden_severities}=${None}
    [Documentation]
    ...  Searches active alarms list for given FID and triggers analysis of it's fault signature field
    ...
    ...  Parameters allowed_severities and forbidden_severities can contain few possible values. In that case
    ...  they must be separated by | ex. allowed_severities=A|B|C when expected value is A, B or C.
    ...  Either allowed_severities OR forbidden_severities _MUST_ be provided but not both!
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
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
    ...  | ru_sn                     | Yes  | serial number of radio unit under test                             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | connection                | Yes  | alias for active ssh connection to SMOD                            |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_scheme    | No   | string with structurized info on expected fault signature fields   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | alarm_details_scheme      | Yes  | list with details for possible alarms reported with given FID      |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_timestamp | No   | earliest possible timestamp of FID occurence                       |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | timestamp_timeout         | No   | tolerance window lenght for fault signature timestamp in seconds   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | allowed_severities        | No   | string containing values that faultSeverity key can take           |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | forbidden_severities      | No   | string containing values that faultSeverity key can not take       |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    FOR  ${alarm}  IN  @{alarm_info}
      Run Keyword If  ${alarm['faultId']}==${faultId}  Run Keywords
      ...  FM Check Fault Severity  fault_to_check=${alarm}
           ...  allowed_severities=${allowed_severities}
           ...  forbidden_severities=${forbidden_severities}
      ...  AND  FM Check Alarm Details  fault_to_check=${alarm}
           ...  alarm_details_scheme=${alarm_details_scheme}
      ...  AND  FM Check Fault Signature  fault_to_check=${alarm}
           ...  fault_signature_scheme=${fault_signature_scheme}
           ...  ru_sn=${ru_sn}
           ...  connection=${connection}
           ...  fault_signature_timestamp=${fault_signature_timestamp}
           ...  timestamp_timeout=${timestamp_timeout}
      ...  AND  admin.Add Allowed Alarm  faultId=${faultId}  connection=${connection}
    END

FM Check Fault Signature
    [Arguments]  ${fault_to_check}  ${fault_signature_scheme}  ${ru_sn}  ${connection}
    ...  ${fault_signature_timestamp}=${None}  ${timestamp_timeout}=360
    [Documentation]
    ...  Analyses fault info in context of fault signature fields exsistence and values
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_to_check            | Yes  | dictionary containing fault info                                   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_scheme    | Yes  | string with structurized info on expected fault signature fields   |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                     | Yes  | serial number of radio unit under test                             |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | connection                | Yes  | alias for active ssh connection to SMOD                            |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_timestamp | No   | earliest possible timestamp of FID occurence                       |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | timestamp_timeout         | No   | tolerance window lenght for fault signature timestamp in seconds   |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    ${ru_bts_id}    ${ru_dist_name}=    SITE Get RU Node Data    ${ru_sn}
    ${signature_stat}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${fault_to_check}  key=faultSignature
    ${fault_signature_to_check}=  Set Variable If  ${signature_stat}
    ...  ${fault_to_check['faultSignature']}
    ...  ${fault_to_check['alarmText']['alarmAdditionalInfo']['faultSignature']}
    ${fault_signature_scheme}=  Evaluate  json.loads('''${fault_signature_scheme}''')  json
    # Checking fields with single expected value
    ${fixed_value_scheme_keys}=  Get Dictionary Keys  dictionary=${fault_signature_scheme['fixed_value']}  sort_keys=False
    FOR  ${key}  IN  @{fixed_value_scheme_keys}
      Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
      ...  key=${key}
      ...  value=${fault_signature_scheme['fixed_value']['${key}']}
    END
    # Checking fields with multiple possible expected values
    ${alternative_value_scheme_keys}=  Get Dictionary Keys  dictionary=${fault_signature_scheme['alternative_value']}
    ...  sort_keys=False
    FOR  ${key}  IN  @{alternative_value_scheme_keys}
      ${alternative_values_list}=  Split String  string=${fault_signature_scheme['alternative_value']['${key}']}
      ...  separator=|
      Dictionary Should Contain Key  dictionary=${fault_signature_to_check}
      ...  key=${key}
      List Should Contain Value  ${alternative_values_list}
      ...  value=${fault_signature_to_check['${key}']}
    END
    # Checking fields with dynamic expected value
    ${dynamic_value_scheme_keys}=  Copy List  ${fault_signature_scheme['dynamic_value']}
    Run Keyword If  'component' in ${dynamic_value_scheme_keys}
    ...  Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
         ...  key=component
         ...  value=${ru_sn}
    Run Keyword If  'loadName' in ${dynamic_value_scheme_keys}
    ...  Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
         ...  key=loadName
         ...  value=${cfg}[NODES][${ru_bts_id}][software_active]
    Run Keyword If  'date' in ${dynamic_value_scheme_keys}
    ...  FM Check Fault Signature Timestamp  fault_signature_to_check=${fault_signature_to_check}
         ...  fault_signature_timestamp=${fault_signature_timestamp}
         ...  timestamp_timeout=${timestamp_timeout}
    Run Keyword If  'resetCounter' in ${dynamic_value_scheme_keys}
    ...  FM Check Fault Signature Reset Counter  fault_signature_to_check=${fault_signature_to_check}
    # Checking fields with not empty expected value
    ${not_empty_value_scheme_keys}=  Copy List  ${fault_signature_scheme['not_empty_value']}
    FOR  ${key}  IN  @{not_empty_value_scheme_keys}
      Dictionary Should Contain Key  dictionary=${fault_signature_to_check}
      ...  key=${key}
      Should Not Be Equal  first=${fault_signature_to_check}[${key}]
      ...  second=
      Should Not Be Equal  first=${fault_signature_to_check}[${key}]
      ...  second=-
    END

FM Check Fault Signature Reset Counter
    [Arguments]  ${fault_signature_to_check}
    [Documentation]
    ...  Analyses 'resetCounter' field of fault signature. Value in that field is expected to not be empty
    ...  and to be numerical
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info to be checked                                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    Dictionary Should Contain Key  dictionary=${fault_signature_to_check}
    ...  key=resetCounter
    ${resetCounter}  Convert To String  ${fault_signature_to_check}[resetCounter]
    Should Match Regexp  string=${resetCounter}
    ...  pattern=^\\d+$
    ...  msg=ERROR: resetCounter field value should not be empty and should be numerical!
    ...  values=True

FM Check Fault Signature Timestamp
    [Arguments]  ${fault_signature_to_check}  ${fault_signature_timestamp}  ${timestamp_timeout}
    [Documentation]
    ...  Analyses 'date' field of fault signature. Timestamp in that field is expected
    ...  to be in fault_signature_timestamp + timestamp_timeout window.
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                                        |
    ...  +===========================+======+====================================================================+
    ...  | fault_signature_to_check  | Yes  | fault signature info to be checked                                 |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | fault_signature_timestamp | Yes  | earliest possible timestamp of FID occurence                       |
    ...  +---------------------------+------+--------------------------------------------------------------------+
    ...  | timestamp_timeout         | Yes  | tolerance window lenght for fault signature timestamp in seconds   |
    ...  +---------------------------+------+--------------------------------------------------------------------+

    Dictionary Should Contain Key  dictionary=${fault_signature_to_check}
    ...  key=date
    ${fault_signature_date_in_epoch}=  SITE Format Timestamp To Epoch  timestamp_to_format=${fault_signature_to_check['date']}
    ${fault_signature_timestamp}=  Convert Date  date=${fault_signature_timestamp}
    ...  result_format=epoch
    ...  exclude_millis=False
    ${fault_signature_date_is_correct}=  Evaluate
    ...  ${fault_signature_timestamp} <= ${fault_signature_date_in_epoch} <= (${fault_signature_timestamp} + ${timestamp_timeout})
    Should Be True  ${fault_signature_date_is_correct}

FM Check Fault Severity
    [Arguments]  ${fault_to_check}  ${allowed_severities}=${None}  ${forbidden_severities}=${None}
    [Documentation]
    ...  Checks if given fault has right severity.
    ...  It is possible to provide allowed or forbidden severieties list but not both.
    ...  Either allowed_severities OR forbidden_severities _MUST_ be provided!
    ...  Parameters allowed_severities and forbidden_severities can contain few possible values. In that case
    ...  they must be separated by | ex. allowed_severities=A|B|C when expected value is A, B or C.
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                        |
    ...  +======================+======+====================================================================+
    ...  | fault_to_check       | Yes  | fault info to be checked                                           |
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | allowed_severities   | No   | string containing values that faultSeverity key can take           |
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | forbidden_severities | No   | string containing values that faultSeverity key can not take       |
    ...  +----------------------+------+--------------------------------------------------------------------+

    Should Be True  condition=($allowed_severities == $None) ^ ($forbidden_severities==$None)
    ...  msg=None or both severietes arguments provided. Use ONLY allowed_severities OR ONLY forbidden_severities argument.
    ${target_severities_list}  Run Keyword If  $allowed_severities != $None
    ...  Split String  string=${allowed_severities}
         ...  separator=|
    ...  ELSE IF  $forbidden_severities != $None
    ...  Split String  string=${forbidden_severities}
         ...  separator=|
    ${fault_severity}=  Get From Dictionary  dictionary=${fault_to_check}
    ...  key=faultSeverity
    Run Keyword If  $allowed_severities != $None
    ...  List Should Contain Value  ${target_severities_list}
    ...  value=${fault_severity}
    ...  ELSE IF  $forbidden_severities != $None
    ...  List Should Not Contain Value  ${target_severities_list}
    ...  value=${fault_severity}

FM Check Alarm Details
    [Arguments]  ${fault_to_check}  ${alarm_details_scheme}
    [Documentation]
    ...  Checks if alarm reported with given fault is correct.
    ...  Reported pair of alarmId and alarmName must be one of defined in alarm_details_scheme list.
    ...  List alarm_details_scheme should contain information on alarm as defined in Reported Alarms section of NIDD.
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
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
    List Should Contain Value  ${alarm_details_scheme}
    ...  value=${alarmId} ${alarmName}

FM Recovery Site Reset For Fault Signature
    [Arguments]  ${bts}  ${ru_dist_name}  ${timeout}
    [Documentation]  Keyword for reset site. Clears radio counter responsille for fault generating.
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | Parameter            | Man. | Description                                                        |
    ...  +======================+======+====================================================================+
    ...  | bts                  | Yes  | fault info to be checked                                           |
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | ru_dist_name         | Yes  | list with details for possible alarms reported with given FID      |
    ...  +----------------------+------+--------------------------------------------------------------------+
    ...  | timeout              | Yes  | list with details for possible alarms reported with given FID      |
    ...  +----------------------+------+--------------------------------------------------------------------+
    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts} will be executed. Please wait...
    Run Keyword And Ignore Error  admin.Reset Site
    ...  connection=${bts}
    ...  wait_for_reconnection=True
    ...  detailed_output=True
    CM BTS Admin Not Available  node=${bts}
    Logging With Timestamp
    ...  message=Waiting for Onair after site reset. Please wait...
    Run Keyword And Ignore Error  STATE Verify Multi Node State  scf_check=${FALSE}  timeout=${timeout}
    Logging With Timestamp
    ...  message=BTS-${bts} is Onair
