*** Settings ***
Documentation    Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Resource    ./FM_Fault_Signature.resource

*** Keywords ***
TC__FM_Fault_Signature_FID_4589
  [Documentation]
  ...  Triggers given FID4589 and checks if faultSignature part of alarm response contains correct values
  ...
  ...  |  **Author:**      szymon.przybylak@nokia.com
  ...  |  **Maintainer:**  szymon.przybylak@nokia.com

  Common Test Setup
  ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
  ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_RADIO_UNIT_LIST}
  ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
  FOR  ${ru_sn}  IN  @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    SITE Get RU Node Data    ${ru_sn}
      ${alarm_info}  ${ru_off_timestamp}  Step 1 Generate Radio Fault FID 4589  ru_sn=${ru_sn}
      Step 2 Analyze Fault List For Fault Signature
      ...  alarm_info=${alarm_info}
      ...  ru_off_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  connection=${ru_bts_id}
  END
  STATE Verify Multi Node State  scf_check=${FALSE}  timeout=300
  [Teardown]  Common Test Teardown


Step 2 Analyze Fault List For Fault Signature
    [Arguments]    ${alarm_info}  ${ru_off_timestamp}  ${ru_sn}  ${connection}
    [Documentation]
    ...  Analyzes the alarm list for the given fault signature
    ...  and checks if the fault signature part of the alarm response contains correct values
    ...
    ...  +------------------+------+--------------------------------------------------+
    ...  | Parameter        | Man. | Description                                      |
    ...  +==================+======+==================================================+
    ...  | alarm_info       | Yes  | list containing active alarms info               |
    ...  +------------------+------+--------------------------------------------------+
    ...  | ru_off timestamp | Yes  | timestamp of the beginning of the radio reset    |
    ...  +------------------+------+--------------------------------------------------+
    ...  | ru_sn            | Yes  | serial number of radio unit under test           |
    ...  +------------------+------+--------------------------------------------------+
    ...  | connection       | Yes  | alias for active ssh connection to SMOD          |
    ...  +------------------+------+--------------------------------------------------+
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 2 Analyze Alarm List For Fault Signature
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Analyzing fault signature for FID 4589 on ${ru_sn}
    ...  style=ONGOING
    FM Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
    ...  faultId=4589
    ...  fault_signature_scheme=${FID4589_FAULT_SIGNATURE_SCHEME}
    ...  alarm_details_scheme=${FID_4589_ALARM_INFO}
    ...  fault_signature_timestamp=${ru_off_timestamp}
    ...  ru_sn=${ru_sn}
    ...  connection=${connection}
    ...  forbidden_severities='Critical'
    Logging With Timestamp
    ...  message=Analyzing fault signature for FID 4589 on ${ru_sn}
    ...  style=DONE


Step 1 Generate Radio Fault FID 4589
    [Arguments]    ${ru_sn}
    [Documentation]
    ...  Triggers FID4589 by powering off and on tested radios.
    ...  After that check if radio resets and goes back online and if FID4589 is reported
    ...  Fault ID name according to NIDD: EFaultID_UnitPowerResetAl
    ...
    ...  |  **Author:**      szynon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...
    ...  **Return parameters**
    ...
    ...  +------------------+--------------------------------------------------+
    ...  | Parameter        | Description                                      |
    ...  +==================+==================================================+
    ...  | alarm_info       | list containing active alarms info               |
    ...  +------------------+--------------------------------------------------+
    ...  | ru_off_timestamp | timestam of the begining of the radio reset      |
    ...  +------------------+--------------------------------------------------+
    ...  Triggers FID4589 by powering off and on tested radios.

    Logging With Timestamp
    ...  message=Step 1 Generate RU Fault FID 4589
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Generating FID 4589 on ${ru_sn}
    ...  style=ONGOING
    ${ru_bts_id}    ${ru_dist_name}=    SITE Get RU Node Data    ${ru_sn}
    ${alarm_info}  ${ru_off_timestamp}=  Generate Radio Fault FID4589  ru_sn=${ru_sn}  connection=${ru_bts_id}
    Logging With Timestamp
    ...  message=Generated FID 4589 on ${ru_sn}
    ...  style=DONE
    [Return]  ${alarm_info}  ${ru_off_timestamp}

Generate Radio Fault FID4589
    [Arguments]  ${ru_sn}  ${connection}
    [Documentation]
    ...  Triggers FID4589 by powering off and on tested radios.
    ...  After that check if radio resets and goes back online and if FID4589 is reported
    ...  Fault ID name according to NIDD: EFaultID_UnitPowerResetAl
    ...
    ...  |  **Author:**      szynon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | connection   | Yes  | alias for active ssh connection to SMOD          |
    ...  +--------------+------+--------------------------------------------------+
    ...
    ...  **Return parameters**
    ...
    ...  +------------------+--------------------------------------------------+
    ...  | Parameter        | Description                                      |
    ...  +==================+==================================================+
    ...  | alarm_info       | list containing active alarms info               |
    ...  +------------------+--------------------------------------------------+
    ...  | ru_off_timestamp | timestam of the begining of the radio reset      |
    ...  +------------------+--------------------------------------------------+

     ${ru_bts_id}    ${ru_dist_name}=    SITE Get RU Node Data    ${ru_sn}
     SITE Perform RU Power Remove  ${ru_sn}
     ${ru_off_timestamp}=  SITE Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
     ...  dist_name=${ru_dist_name}
     ...  state=Remove
     ...  timeout=${FAULT_10_TIMEOUT} sec
     SITE Perform RU Power Insert  ${ru_sn}
     SITE Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
     ...  dist_name=${ru_dist_name}
     ...  state=Insert
     ...  timeout=${RADIO_AVAILABILITY_TIMEOUT} sec
     Logging With Timestamp
     ...  message=Waiting for FID:4589 to appear on ${ru_sn}
     ${alarm_info}=    Run Keyword And Continue On Failure    admin.Assert Alarm Active
     ...    faultId=4589
     ...    connection=${connection}
     ...    timeout=${FID_4589_APPEAR_TIMEOUT}
     ...    faultName="Unit power reset"
     Logging With Timestamp
     ...  message=Waiting for FID:4589 to disappear
     Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=4589  connection=${connection}
     Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=10  connection=${connection}
     Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1815  connection=${connection}
     Run Keyword And Continue On Failure    admin.Assert Alarm Inactive
     ...    faultId=4589, severity=Warning
     ...    connection=${connection}
     ...    timeout=${FID_4589_DISAPPEAR_TIMEOUT}
     ...    faultName="Unit power reset"
     [Return]  ${alarm_info}  ${ru_off_timestamp}
