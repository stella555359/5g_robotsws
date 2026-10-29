*** Settings ***
Documentation
...  Triggers given RU fault and checks if faultSignature part of alarm response contains correct values
...
...
...
...  Author:        daria.wronska@nokia.com
...  Maintainer:    daniel.bartkowiak@nokia.com

Resource    ./FM_Fault_Signature.resource

*** Variables ***
${RADIO_STARTUP_DELAY}     600         # Custom radio startup delay
${RECOVERY_SITE_RESET}     ${FALSE}    #Recovery site reset to clear radio counter and avoid improper fault generation in multiply iterations
                                       #To avoid impact for other Fault Signature TCs in same TS then set flag TRUE
#@{CUSTOM_RADIO_UNIT_LIST}             - Custom radio list
#{FID_1901_TIMEOUT}                    - timeout for faultsignature threshold, default 540s. Can be set by user if needed

*** Keywords ***
TC__FM_Fault_Signature_FID_1901
    [Documentation]
    ...  Triggers given FID1901 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  The purpose of this Test Case is to check correct raise of fault 1901 "RF Module critical file not found"
    ...  and if faultSignature part of alarm response contains correct values.
    ...  Fault ID name according to NIDD: EFaultId_FrCriticalFileNotFound.
    ...  Fault 1901 is supported for radios 5.1 and higher
    ...

    Common Test Setup
    Logging With Timestamp
    ...  message=RF Fault Signature FID1901
    ...  style=STEP
    ...  frame=${TRUE}
    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    FOR   ${ru_sn}    IN    @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    SITE Get RU Node Data    ${ru_sn}
      Set Test Variable  ${RU_DIST_NAME}  ${ru_dist_name}
      Set Test Variable  ${RU_BTS_ID}  ${ru_bts_id}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
      ${alarm_info}  ${alarm_info_assert}  ${ru_off_timestamp}=  Generate Fault FID1901  ru_sn=${ru_sn}  connection=${ru_bts_id}
      FM Analyze Alarm List For Fault Signature
      ...  alarm_info=${alarm_info_assert}
      ...  faultId=1901
      ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1901_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  connection=${RU_BTS_ID}
      ...  timestamp_timeout=${FID_1901_TIMEOUT}
      ...  allowed_severities=Critical
      ...  forbidden_severities=${None}
      FM Analyze Alarm List For Fault Signature
      ...  alarm_info=${alarm_info}
      ...  faultId=1901
      ...  fault_signature_scheme=${FID1901_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1901_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  connection=${RU_BTS_ID}
      ...  timestamp_timeout=${FID_1901_TIMEOUT}
      ...  allowed_severities=${None}
      ...  forbidden_severities='Critical'
      Count Alarm List When Fault Signature 1901  ${alarm_info}
    END
    [Teardown]  Run Keywords
    ...  Run Keyword If  ${RECOVERY_SITE_RESET}  FM Recovery Site Reset For Fault Signature
    ...  bts=${RU_BTS_ID}
    ...  ru_dist_name=${RU_DIST_NAME}
    ...  timeout=${RADIO_STARTUP_DELAY}
    ...  AND  Common Test Teardown

Generate Fault FID1901
    [Arguments]  ${ru_sn}  ${connection}
    Logging With Timestamp
    ...  message=Generate Fault FID1901 on RU: ${ru_sn}
    ${ru_off_timestamp}=  Get Current Date  UTC
    radio.Generate Fault  fault_id=1901  ru_serial_number=${ru_sn}
    Set Test Variable  ${FAULTId}  1901
    SITE Verify RU Power Remove Insert State  bts_id=${RU_BTS_ID}
    ...  dist_name=${RU_DIST_NAME}
    ...  state=Remove
    ...  timeout=${FID_1901_TIMEOUT} sec
    Logging With Timestamp
    ...  message=Waiting for FID:1901 to appear on ${ru_sn}
    Sleep  350 sec
    ${alarm_info_assert}=  Run Keyword And Continue On Failure  admin.Assert Alarm Active
    ...  faultId=1901, severity=Critical
    ...  timeout=${FID_1901_TIMEOUT}
    ...  connection=${connection}
    Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1901, severity=Critical  connection=${connection}
    Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=10  connection=${connection}
    FOR    ${alarm}    IN    @{alarm_info_assert}
      Run Keyword If    "${alarm['faultId']}"=="1901" and "${alarm['additionalFaultID']}"=="52"
        ...  admin.Assert Alarm Active  faultId=1901, severity=Critical, faultName="RF Module failure"
        ...  timeout=600
        ...  connection=${connection}
        ...  ELSE IF  "${alarm['faultId']}"=="1901" and "${alarm['additionalFaultID']}"=="3001"
        ...  admin.Assert Alarm Active  faultId=1901, severity=Critical, faultName="RF Module critical file not found"
        ...  timeout=600
        ...  connection=${connection}
    END
    ${alarm_info}=  Run Keyword And Continue On Failure   admin.Get Historic Alarms  timeout=360
    ...  connection=${connection}
    ...  severity=Warning
    ...  load_history=True
    [Return]  ${alarm_info}  ${alarm_info_assert}  ${ru_off_timestamp}
    [Teardown]  Recover Fault FID1901  ru_sn=${ru_sn}

Recover Fault FID1901
    [Arguments]  ${ru_sn}
    radio.Recover Fault  fault_id=1901  ru_serial_number=${ru_sn}
    Logging With Timestamp
    ...  message=Recover Fault FID1901 on RU: ${ru_sn}. Waiting For BTS Onair
    STATE Verify Multi Node State  scf_check=${FALSE}  timeout=${RADIO_STARTUP_DELAY}
    Logging With Timestamp
    ...  message=Fault 1901 recovered successfuly. BTS is Onair.

Count Alarm List When Fault Signature 1901
    [Arguments]    ${alarm_info}
    [Documentation]
    ...  Searches active alarms list for givend FID and check if is correct number of faults.
    ...
    ...  |  **Author:**      daria.wronska@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
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
    ...  Logging With Timestamp
    ...  message=Fault 1901 with severity Warning correctly appeared 3 times
    ...  ELSE  Fail  Fault 1901 Warning appeared ${count} times, but should appear 3 times. Try to set RECOVERY_SITE_RESET to TRUE ${\n}
