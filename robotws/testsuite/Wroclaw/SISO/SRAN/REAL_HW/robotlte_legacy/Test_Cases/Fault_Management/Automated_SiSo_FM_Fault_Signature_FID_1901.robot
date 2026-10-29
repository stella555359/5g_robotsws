*** Settings ***
Documentation    Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...    Author:        daria.wronska@nokia.com
...    Maintainer:    Daria Wronska

Resource    ./fault_signature_common.robot

*** Variables ***
${ru_sn}

*** Keywords ***
RF Fault Signature FID1901
    [Documentation]
    ...  Triggers given FID1901 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com
    ...
    ...  The purpose of this Test Case is to check correct raise of fault 1901 "RF Module critical file not found"
    ...  and if faultSignature part of alarm response contains correct values.
    ...  Fault ID name according to NIDD: EFaultId_FrCriticalFileNotFound.
    ...
    ...  It is necessary to add path to the file: variables.robot in the testsuite, in the ***Settings*** section:
    ...  Resource    ../../../resources/variables.robot.
  Common Test Setup
  Logging With Timestamp
  ...  message=RF Fault Signature FID1901
  ...  style=ONGOING


    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    FOR   ${ru_sn}    IN    @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
      Set Test Variable  ${RU_DIST_NAME}  ${ru_dist_name}
      Set Test Variable  ${RU_BTS_ID}  ${ru_bts_id}
      ${hw_release}=         Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
      ${status_hw_release}=    Run Keyword And Return Status     Should Be True    '${hw_release}'=='5.1' or '6.2'
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
      ${alarm_info}  ${alarm_info_assert}  ${ru_off_timestamp}=     Run Keyword If    ${status_hw_release}==True
      ...     Generate RU_RRH5.1_6.2 Fault FID1901       ru_sn=${ru_sn}     alias=${ru_bts_id}
      ...     ELSE    Run Keywords    Log    \nRMOD family is not 5.1 or 6.2, radio module does not support fault 1901${\n}    console=True
      ...     AND    Fail    RMOD family is not 5.1 or 6.2, radio module does not support fault 1901${\n}
      Analyze Alarm List For Fault Signature
      ...  alarm_info=${alarm_info_assert}
      ...  faultId=1901
      ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1901_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  alias=${RU_BTS_ID}
      ...  timestamp_timeout=${FID_1901_TIMEOUT}
      ...  allowed_severities=Critical
      ...  forbidden_severities=${None}
      Analyze Alarm List For Fault Signature
      ...  alarm_info=${alarm_info}
      ...  faultId=1901
      ...  fault_signature_scheme=${FID1901_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1901_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  alias=${RU_BTS_ID}
      ...  timestamp_timeout=${FID_1901_TIMEOUT}
      ...  allowed_severities=${None}
      ...  forbidden_severities='Critical'
      Count Alarm List For Fault Signature 1901  ${alarm_info}
    END
  [Teardown]    Common Test Teardown

Generate RU_RRH5.1_6.2 Fault FID1901
    [Arguments]  ${ru_sn}  ${alias}
    Log  \nGenerate ${ru_sn} Fault FID1901  console=True
    radio.Generate Fault  fault_id=1901  ru_serial_number=${ru_sn}
    Set Test Variable  ${FAULTId}  1901
    ${ru_off_timestamp}=  site_operations.Verify RU Power Remove Insert State  bts_id=${RU_BTS_ID}
    ...  dist_name=${ru_dist_name}
    ...  state=Remove
    ...  timeout=${FID_1901_TIMEOUT} sec
    Log  \nWaiting for FID:1901 to appear on ${ru_sn}     console=True
    Sleep  350 sec

    ${alarm_info_assert}=  Run Keyword And Continue On Failure  Assert Alarm Active  faultId=1901, severity=Critical
    ...  timeout=600
    ...  connection=${alias}
    Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1901, severity=Critical  connection=${alias}
    Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=10  connection=${alias}
    FOR    ${alarm}    IN    @{alarm_info_assert}
      Run Keyword If    "${alarm['faultId']}"=="1901" and "${alarm['additionalFaultID']}"=="52"
        ...  admin.Assert Alarm Active  faultId=1901, severity=Critical, faultName="RF Module failure"
        ...  timeout=600
        ...  connection=${alias}
        ...  ELSE IF  "${alarm['faultId']}"=="1901" and "${alarm['additionalFaultID']}"=="3001"
        ...  admin.Assert Alarm Active  faultId=1901, severity=Critical, faultName="RF Module critical file not found"
        ...  timeout=600
        ...  connection=${alias}
    END
    ${alarm_info}=  Run Keyword And Continue On Failure   Get Historic Alarms  timeout=360
    ...  connection=${alias}
    ...  severity=Warning
    ...  load_history=True
    [Return]  ${alarm_info}  ${alarm_info_assert}     ${ru_off_timestamp}
    [Teardown]  Recover RU Fault FID1901  ru_sn=${ru_sn}  rmod_distname=${RU_DIST_NAME}

Recover RU Fault FID1901
    [Arguments]    ${ru_sn}    ${rmod_distname}
    radio.Recover Fault  fault_id=1901  ru_serial_number=${ru_sn}
    Log  \nRecover ${ru_sn} Fault FID1901  console=True
    site_operations.Verify RU Power Remove Insert State  bts_id=${RU_BTS_ID}
    ...  dist_name=${rmod_distname}
    ...  state=Insert
    ...  timeout=${FID_1901_TIMEOUT} sec

Count Alarm List For Fault Signature 1901
    [Arguments]    ${alarm_info}
    [Documentation]
    ...  Searches active alarms list for givend FID and check if is correct number of faults.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daria.wronska@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +---------------------------+------+------------------------------------------------------+
    ...  | Parameter                 | Man. | Description                                          |
    ...  +===========================+======+======================================================+
    ...  | alarm_info                | Yes  | list containing historic alarms info                 |
    ...  +---------------------------+------+------------------------------------------------------+

    ${alarms_list}=  Create List
    FOR  ${alarm}  IN  @{alarm_info}
      Append To List  ${alarms_list}  '${alarm['faultId']}'
    END
    ${count}=  Count Values In List  ${alarms_list}  '${FAULTId}'
    ${count_status}=    Run Keyword And Return Status  Should Be True  ${count}==3
    Run Keyword If  ${count_status}==True
    ...  Log   \nFault 1901 with severity Warning correctly appeared 3 times{\n}  console=True
    ...  ELSE  Fail  Fault 1901 with severity Warning only appeared only ${count} times, but it should appear 3 times. ${\n}
