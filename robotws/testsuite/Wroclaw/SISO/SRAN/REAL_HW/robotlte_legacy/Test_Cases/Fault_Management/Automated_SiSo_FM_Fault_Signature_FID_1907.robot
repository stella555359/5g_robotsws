*** Settings ***
Documentation    Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...    Author:        daria.wronska@nokia.com
...    Maintainer:    Daria Wronska

Resource    ./fault_signature_common.robot
Resource  ../../variables.robot
*** Variables ***
${ru_sn}


*** Keywords ***
RF Fault Signature FID1907
    [Documentation]    Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
    ...    Author:        daria.wronska@nokia.com
    ...    Maintainer:    Daria Wro?ska
    Common Test Setup
    Logging With Timestamp
    ...  message=RF Fault Signature FID1907
    ...  style=ONGOING

    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    FOR   ${ru_sn}    IN    @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
      Set Test Variable  ${RU_DIST_NAME}  ${ru_dist_name}
      Set Test Variable  ${RU_BTS_ID}  ${ru_bts_id}
      ${hw_release}=  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
      ${status_hw_release}=   Run Keyword And Return Status  Should Be True  '${hw_release}'=='5.1' or '6.2'
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1907  connection=${ru_bts_id}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1920  connection=${ru_bts_id}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
      Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
      ${alarm_info}  ${ru_off_timestamp}=  Run Keyword If  ${status_hw_release}==True  Run Keyword
      ...  Generate RU_RRH5.1_6.2 Fault FID1907
      ...  ru_sn=${ru_sn}
      ...  alias=${ru_bts_id}
      ...  ELSE  Run Keywords  Log  \nRMOD family is not 5.1 or 6.2, radio module does not support fault 1907${\n}  console=True
      ...  AND  Fail  RMOD family is not 5.1 or 6.2, radio module does not support fault 1907${\n}
      Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
      ...  faultId=1907
      ...  fault_signature_scheme=${FID1907_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1907_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  alias=${ru_bts_id}
      ...  timestamp_timeout=${FID_1907_TIMEOUT}
      ...  allowed_severities=${None}
      ...  forbidden_severities='Critical'
    END
    [Teardown]    Common Test Teardown

Generate RU_RRH5.1_6.2 Fault FID1907
    [Arguments]  ${ru_sn}  ${alias}
    [Documentation]
    ...  Triggers FID1907 by terminating event collector process on tested radio.
    ...  After that check if radio resets and goes back online and if FID1907 is reported
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com
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

    radio.Generate Fault  fault_id=1907  ru_serial_number=${ru_sn}
    Log  \nGenerate ${ru_sn} Fault FID1907  console=True
    ${ru_off_timestamp}=  site_operations.Verify RU Power Remove Insert State  bts_id=${ru_bts_id}
    ...  dist_name=${ru_dist_name}
    ...  state=Remove
    ...  timeout=${FID_1907_TIMEOUT} sec
    Log  \nWaiting for FID:1907 to appear on ${ru_sn}  console=True
    Sleep    1000
    ${alarm_info}=  Run Keyword And Continue On Failure  Get Historic Alarms  timeout=1200  connection=${alias}  severity=warning  load_history=True
    Should Not Be Empty  ${alarm_info}
    ${second_alarm_info}=  Run Keyword And Continue On Failure  Get Historic Alarms
    ...  timeout=1200  connection=${alias}  severity=warning  load_history=False
    [Return]  ${alarm_info}  ${ru_off_timestamp}
    [Teardown]  Recover RU Fault FID1907  ru_sn=${ru_sn}  alias=${ru_bts_id}    rmod_distname=${RU_DIST_NAME}

Recover RU Fault FID1907
    [Arguments]   ${ru_sn}    ${alias}    ${rmod_distname}
    Wait Until Keyword Succeeds  10x  30s  radio.Recover Fault  fault_id=1907  ru_serial_number=${ru_sn}
    Log  \nRecovery after ${ru_sn} Fault FID1907  console=True
    Log  Waiting for RMOD status disabled...  console=True
    Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${rmod_distname}
    ...  operationalState=regex"(?i)disabled"
    ...  alias=${alias}
    Log  Waiting for RMOD status enabled...  console=True
    Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${rmod_distname}
    ...  operationalState=regex"(?i)enabled"
    ...  alias=${alias}
    Verify Multi BTS State   60 sec
