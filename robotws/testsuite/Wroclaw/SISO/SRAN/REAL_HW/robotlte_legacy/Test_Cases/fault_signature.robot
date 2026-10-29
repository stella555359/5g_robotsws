*** Settings ***
Documentation  Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...  Author:  dawid.bak@nokia.com
...  Maintainer:  Dawid Bak
...

*** Keywords ***
Generate RU Fault FID4590
  [Arguments]  ${ru_sn}  ${alias}
  [Documentation]
  ...  Triggers FID4590 by terminating event collector process on tested radio.
  ...  After that check if radio resets and goes back online and if FID4590 is reported
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+==================================================+
  ...  | ru_sn  | Yes  | serial number of radio unit under test  |
  ...  +--------------+------+--------------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +--------------+------+--------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +==================+==================================================+
  ...  | alarm_info  | list containing active alarms info  |
  ...  +------------------+--------------------------------------------------+
  ...  | ru_off_timestamp | timestam of the begining of the radio reset  |
  ...  +------------------+--------------------------------------------------+

  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
  radio.Kill Process On Radio Module By Name  ru_serial_number=${ru_sn}
  ...  process_name=eventcollector
  ${ru_off_timestamp}=  Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
  ...  dist_name=${ru_dist_name}
  ...  state=Remove
  ...  timeout=${FID_4590_TIMEOUT} sec
  Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
  ...  dist_name=${ru_dist_name}
  ...  state=Insert
  ...  timeout=${FID_4590_TIMEOUT} sec
  ${alarm_info}=  admin.Assert Alarm Active  faultId=4590  alias=${alias}  timeout=600
  [Return]  ${alarm_info}  ${ru_off_timestamp}

Analyze Alarm List For Fault Signature
  [Arguments]
  ...  ${alarm_info}
  ...  ${faultId}
  ...  ${fault_signature_scheme}
  ...  ${fault_signature_timestamp}
  ...  ${reset_counter}
  ...  ${ru_sn}
  ...  ${alias}
  [Documentation]
  ...  Searches active alarms list for givend FID and triggers analysis of it's fault signature field
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +===========================+======+======================================================+
  ...  | alarm_info  | Yes  | list containing active alarms info  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | faultId  | Yes  | faultID under test  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | fault_signature_scheme  | Yes  | dictionary of fault signature static fields to check |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | fault_signature_timestamp | Yes  | earliest possible timestamp of FID occurence  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | reset_counter  | Yes  | radio unit reset counter from before fault trigger  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | ru_sn  | Yes  | serial number of radio unit under test  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +---------------------------+------+------------------------------------------------------+

  FOR  ${alarm}  IN  @{alarm_info}
    Run Keyword If  ${alarm['faultId']}==${faultId}
    ...  Check Fault Signature  fault_to_check=${alarm}
    ...  fault_signature_scheme=${fault_signature_scheme}
    ...  fault_signature_timestamp=${fault_signature_timestamp}
    ...  reset_counter=${reset_counter}
    ...  ru_sn=${ru_sn}
    ...  alias=${alias}
  END

Check Fault Signature
  [Arguments]
  ...  ${fault_to_check}
  ...  ${fault_signature_scheme}
  ...  ${fault_signature_timestamp}
  ...  ${reset_counter}
  ...  ${ru_sn}
  ...  ${alias}
  [Documentation]
  ...  Analyses fault info in context of fault signature fields exsistence and values
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +===========================+======+======================================================+
  ...  | fault_to_check  | Yes  | dictionary containing fault info  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | fault_signature_scheme  | Yes  | dictionary of fault signature static fields to check |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | fault_signature_timestamp | Yes  | earliest possible timestamp of FID occurence  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | reset_counter  | Yes  | radio unit reset counter from before fault trigger  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | ru_sn  | Yes  | serial number of radio unit under test  |
  ...  +---------------------------+------+------------------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +---------------------------+------+------------------------------------------------------+

  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
  ${fault_signature_to_check}=  Set Variable  ${fault_to_check['faultSignature']}
  ${fault_scheme_keys}=  Get Dictionary Keys  dictionary=${fault_signature_scheme}  sort_keys=False
  FOR  ${key}  IN  @{fault_scheme_keys}
    Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
    ...  key=${key}
    ...  value=${fault_signature_scheme.${key}}
  END
  Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
  ...  key=component
  ...  value=${ru_sn}
  Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
  ...  key=loadName
  ...  value=${cfg}[NODES][${ru_bts_id}][software_active]
  Dictionary Should Contain Key  dictionary=${fault_signature_to_check}
  ...  key=date
  ${fault_signature_date_in_epoch}=  Format Timestamp To Epoch  timestamp_to_format=${fault_signature_to_check['date']}
  ${fault_signature_timestamp}=  Convert Date  date=${fault_signature_timestamp}
  ...  result_format=epoch
  ...  exclude_millis=False
  ${fault_signature_date_is_correct}=  Evaluate
  ...  ${fault_signature_timestamp} <= ${fault_signature_date_in_epoch} <= (${fault_signature_timestamp} + ${FID_4590_TIMEOUT})
  Should Be True  ${fault_signature_date_is_correct}
  ${reset_counter}=  Evaluate  ${reset_counter}+1
  Dictionary Should Contain Item  dictionary=${fault_signature_to_check}
  ...  key=resetCounter
  ...  value=${reset_counter}

Check RU reset counter
  [Arguments]  ${ru_sn}
  [Documentation]
  ...  Retrieves reset counter value from radio unit
  ...
  ...  |  **Author:**  dawid.bak@nokia.com
  ...  |  **Maintainer:**  dawid.bak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+---------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+===================================================+
  ...  | ru_sn  | Yes  | serial number of radio unit under test  |
  ...  +--------------+------+---------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +---------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +=====================+==================================================+
  ...  | reset_counter  | radio unit reset counter value  |
  ...  +---------------------+--------------------------------------------------+

  radio.Open Connection To Radio Module  ru_serial_number=${ru_sn}
  radio.Send Command  cat /mnt/runtime/BBOX5 | grep -A 6 'Item type: resets'
  ...  delay=0
  ${reset_counter_response}=  radio.Read Until Prompt  prompt=$|#|>
  ...  timeout=30
  ${reset_counter}=  Get Lines Containing String  string=${reset_counter_response}  pattern=Reset Counter:
  ${reset_counter}=  Strip String  string=${reset_counter}
  ...  mode=left
  ${reset_counter}=  Fetch From Right  string=${reset_counter}
  ...  marker=${SPACE}
  ${reset_counter}=  Convert To Integer  item=${reset_counter}  base=10
  [Teardown]  radio.Close SSH Connection
  [Return]  ${reset_counter}


Generate RU Fault FID4589
  [Arguments]  ${ru_sn}  ${alias}
  [Documentation]
  ...  Triggers FID4589 by powering off and on tested radios.
  ...  After that check if radio resets and goes back online and if FID4589 is reported
  ...
  ...  |  **Author:**  szynon.przybylak@nokia.com
  ...  |  **Maintainer:**  szymon.przybylak@nokia.com
  ...
  ...  **Input Parameters:**
  ...
  ...  +--------------+------+--------------------------------------------------+
  ...  | Parameter  | Man. | Description  |
  ...  +==============+======+==================================================+
  ...  | ru_sn  | Yes  | serial number of radio unit under test  |
  ...  +--------------+------+--------------------------------------------------+
  ...  | alias  | Yes  | alias for active ssh connection to SMOD  |
  ...  +--------------+------+--------------------------------------------------+
  ...
  ...  **Return parameters**
  ...
  ...  +------------------+--------------------------------------------------+
  ...  | Parameter  | Description  |
  ...  +==================+==================================================+
  ...  | alarm_info  | list containing active alarms info  |
  ...  +------------------+--------------------------------------------------+
  ...  | ru_off_timestamp | timestam of the begining of the radio reset  |
  ...  +------------------+--------------------------------------------------+

  ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
  Perform RU Power Remove  ${ru_sn}  ${FAULT_10_TIMEOUT} sec
  ${ru_off_timestamp}=  Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
  ...  dist_name=${ru_dist_name}
  ...  state=Remove
  ...  timeout=${FAULT_10_TIMEOUT} sec
  Perform RU Power Insert  ${ru_sn}  ${FR_AVAILABILITY_TIMEOUT} sec
  Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
  ...  dist_name=${ru_dist_name}
  ...  state=Insert
  ...  timeout=${FR_AVAILABILITY_TIMEOUT} sec
  Log  \nWaiting for FID:4589 to appear on ${ru_sn}  console=True
  ${alarm_info}=  Run Keyword And Continue On Failure
  ...  admin.Assert Alarm Active
  ...  faultId=4589
  ...  alias=${alias}
  ...  timeout=${FID_4589_APPEAR_TIMEOUT}
  Log  \nWaiting for FID:4589 to disappear  console=True
  Run Keyword And Continue On Failure
  ...  admin.Assert Alarm Inactive
  ...  faultId=4589, severity=Warning
  ...  alias=${alias}
  ...  timeout=${FID_4589_DISAPPEAR_TIMEOUT}
  [Return]  ${alarm_info}  ${ru_off_timestamp}

