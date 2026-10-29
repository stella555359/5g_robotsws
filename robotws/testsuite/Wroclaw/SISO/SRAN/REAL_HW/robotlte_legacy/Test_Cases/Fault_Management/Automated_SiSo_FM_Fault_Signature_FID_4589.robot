*** Settings ***
Documentation    Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...    Author:        szymon.przybylak@nokia.com
...    Maintainer:    Szymon Przybylak

Resource    ./fault_signature_common.robot


*** Keywords ***
RF Fault Signature FID4589
    [Documentation]
    ...  Triggers given FID4589 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      szymon.przybylak@nokia.com
    ...  |  **Maintainer:**  szymon.przybylak@nokia.com
  Common Test Setup
  Logging With Timestamp
  ...  message=RF Fault Signature FID4589
  ...  style=ONGOING
    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    FOR   ${ru_sn}    IN    @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
      ${alarm_info}  ${ru_off_timestamp}=  Generate RU Fault FID4589  ru_sn=${ru_sn}
      ...  alias=${ru_bts_id}
      Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
      ...  faultId=4589
      ...  fault_signature_scheme=${FID4589_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_4589_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  alias=${ru_bts_id}
      ...  forbidden_severities='Critical'
    END
  [Teardown]    Common Test Teardown

Generate RU Fault FID4589
    [Arguments]  ${ru_sn}  ${alias}
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
    ...  | alias        | Yes  | alias for active ssh connection to SMOD          |
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

     ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
     Perform RU Power Remove        ${ru_sn}    ${FAULT_10_TIMEOUT} sec
    ${ru_off_timestamp}=  Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
    ...  dist_name=${ru_dist_name}
    ...  state=Remove
    ...  timeout=${FAULT_10_TIMEOUT} sec
    Perform RU Power Insert    ${ru_sn}    ${FR_AVAILABILITY_TIMEOUT} sec
    Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
    ...  dist_name=${ru_dist_name}
    ...  state=Insert
    ...  timeout=${FR_AVAILABILITY_TIMEOUT} sec
    Log    \nWaiting for FID:4589 to appear on ${ru_sn}    console=True
    ${alarm_info}=    Run Keyword And Continue On Failure    Assert Alarm Active
    ...    faultId=4589
    ...    alias=${alias}
    ...    timeout=${FID_4589_APPEAR_TIMEOUT}
    ...    faultName="Unit power reset"
    Log    \nWaiting for FID:4589 to disappear    console=True
    Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=4589  connection=${alias}
    Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=10  connection=${alias}
    Run Keyword And Continue On Failure    Assert Alarm Inactive
    ...    faultId=4589, severity=Warning
    ...    alias=${alias}
    ...    timeout=${FID_4589_DISAPPEAR_TIMEOUT}
    ...    faultName="Unit power reset"
    [Return]  ${alarm_info}  ${ru_off_timestamp}
