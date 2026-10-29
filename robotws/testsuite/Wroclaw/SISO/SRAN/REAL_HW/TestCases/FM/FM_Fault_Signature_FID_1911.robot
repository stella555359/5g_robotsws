*** Settings ***
Documentation    Triggers [FID1911 - RX out of order] on RUs under test
...    and checks if faultSignature part of alarm response contains correct values.
...    TC supports radios between starting from 5.1 release
...
...    Fault generation steps are as fallows:
...    1. Files in FRMON are decoded to JSONS
...    2. RU Reboot is performed
...    3. Waiting for RU to restore connection.
...    4. Create RfSynthesizer Agent and force unlock.
...
...    NOTE. actFaultSignature parameter is set to true
...
...    Fault ID name according to NIDD: EFaultId_FrRxOutOfOrder
...
...    Author:        dawid.bak@nokia.com
...    Maintainer:    Dawid Bak

Resource  ./FM_Fault_Signature.resource

*** Variables ***
${RADIO_STARTUP_DELAY}     600         # Custom radio startup delay
${RECOVERY_SITE_RESET}     ${FALSE}    #Recovery site reset to clear radio counter and avoid improper fault generation in multiply iterations
                                       #To avoid impact for other Fault Signature TCs in same TS then set flag TRUE
#@{CUSTOM_RADIO_UNIT_LIST}             # Custom radio list
#${FID_1911_TIMEOUT}                   # timeout for faultsignature threshold, default 360s. Can be set by user if needed
                                       # only for radios family 6 and above
*** Keywords ***
TC__FM_Fault_Signature_FID_1911
    [Documentation]
    ...  Triggers FID1911 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=RF Fault Signature FID1911
    ...  style=STEP
    ...  frame=${TRUE}
    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=   Run Keyword And Return Status    Should Not Be Empty    ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    FOR   ${ru_sn}    IN    @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    SITE Get RU Node Data    ${ru_sn}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
      ${ru_family}=  IF  '${CFG['RF_INFO']['${ru_sn}']['scf_release_code']}'=='RRH-ORAN'
      ...  radio.Get Radio Module Hardware Family  ru_name=${CFG['RF_INFO']['${ru_sn}']['scf_variant']}
      ...  ELSE
      ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${CFG['RF_INFO']['${ru_sn}']['scf_release_code']}').group(0)  re
      IF  ${ru_family} > 6
        Logging With Timestamp
        ...  message=Testing FID1911 on radio release ${ru_family}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1907  connection=${ru_bts_id}
        ${warning_alarm_info}  ${fid1911_warning_timestamp}  ${critical_alarm_info}  ${fid1911_critical_timestamp}=  Generate RU6 Fault FID1911
        ...  ru_sn=${ru_sn}
        ...  ru_dist_name=${ru_dist_name}
        ...  connection=${ru_bts_id}
        FM Analyze Alarm List For Fault Signature  alarm_info=${critical_alarm_info}
        ...  faultId=1911
        ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
        ...  alarm_details_scheme=${FID_1911_ALARM_INFO}
        ...  fault_signature_timestamp=${fid1911_critical_timestamp}
        ...  timestamp_timeout=${FID_1911_TIMEOUT}
        ...  ru_sn=${ru_sn}
        ...  connection=${ru_bts_id}
        ...  allowed_severities=Critical
        FM Analyze Alarm List For Fault Signature  alarm_info=${warning_alarm_info}
        ...  faultId=1911
        ...  fault_signature_scheme=${FID1911_FAULT_SIGNATURE_SCHEME}
        ...  alarm_details_scheme=${FID_1911_ALARM_INFO}
        ...  fault_signature_timestamp=${fid1911_warning_timestamp}
        ...  timestamp_timeout=${FID_1911_TIMEOUT}
        ...  ru_sn=${ru_sn}
        ...  connection=${ru_bts_id}
        ...  forbidden_severities=Critical
      END
      IF  ${ru_family} == 5.1
        Logging With Timestamp
        ...  message=Testing FID1911 with severity Warning on RU release ${ru_family}
        ${alarm_info}  ${ru_off_timestamp}=  Generate RU5.1 Fault FID1911  ru_sn=${ru_sn}
        ...  ru_dist_name=${ru_dist_name}
        ...  connection=${ru_bts_id}
        FM Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
        ...  faultId=1911
        ...  fault_signature_scheme=${FID1911_FAULT_SIGNATURE_SCHEME}
        ...  alarm_details_scheme=${FID_1911_ALARM_INFO}
        ...  fault_signature_timestamp=${ru_off_timestamp}
        ...  ru_sn=${ru_sn}
        ...  connection=${ru_bts_id}
        ...  forbidden_severities=Critical
        Logging With Timestamp
        ...  message=Testing FID1911 with severity Critical on RU release ${ru_family}
        ${alarm_info}  ${ru_off_timestamp}=  Generate RU5.1 Fault FID1911 Critical  ru_sn=${ru_sn}
        ...  ru_dist_name=${ru_dist_name}
        ...  connection=${ru_bts_id}
        FM Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
        ...  faultId=1911
        ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
        ...  alarm_details_scheme=${FID_1911_ALARM_INFO}
        ...  fault_signature_timestamp=${ru_off_timestamp}
        ...  ru_sn=${ru_sn}
        ...  connection=${ru_bts_id}
        ...  allowed_severities=Critical
      END
      IF  ${ru_family} < 5.1
      ...  Fail  Radio ${ru_dist_name} is below 5.1 release. Not supported
    END
    Logging With Timestamp
    ...  message=Fault signature check. Passed
    [Teardown]  Run Keywords
    ...  Run Keyword If  ${RECOVERY_SITE_RESET}  FM Recovery Site Reset For Fault Signature
    ...  bts=${ru_bts_id}
    ...  ru_dist_name=${ru_dist_name}
    ...  timeout=${RADIO_STARTUP_DELAY}
    ...  AND  Common Test Teardown

Generate RU5.1 Fault FID1911 Critical
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${connection}
    [Documentation]
    ...  Triggers 1911 with severity Critical on tested radio. After that check if FID1911 is reported
    ...
    ...  |  **Author:**      dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | ru_dist_name | Yes  | internal id of radio unit under test             |
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

  FOR  ${i}  IN RANGE  0  2
    Logging With Timestamp
    ...  message=Generating FID1911...
    radio.Generate Fault  ru_serial_number=${ru_sn}
    ...  fault_id=1911
    ${fid1911_status}  ${alarm_info}=  Run Keyword And Ignore Error  Assert Alarm Active  faultId=1911
    ...  faultName="Radio autonomous reset as recovery action"
    ...  connection=${connection}
    ...  timeout=120
    IF  '${fid1911_status}'=='PASS'
    ...        Logging With Timestamp
    ...        message=FID1911 reported!
    ...  ELSE  Run Keywords
    ...        Logging With Timestamp
    ...        message=FID1911 not reported! Recovering...
    ...        AND  Fail   FID1911 was not reported!
    Logging With Timestamp
    ...  message=Waiting for RMOD status disabled...
    admin.Assert
    ...  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)disabled"
    ...  timeout=300
    ...  connection=${connection}
    Logging With Timestamp
    ...  message=Waiting for RMOD status enabled...
    admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  timeout=300
    ...  connection=${connection}
  END

  Logging With Timestamp
  ...  message=Generating FID1911...
  radio.Generate Fault  ru_serial_number=${ru_sn}
  ...  fault_id=1911
  ${ru_off_timestamp}=  Get Current Date      UTC
  ${fid1911_status}  ${alarm_info}=  Run Keyword And Ignore Error  admin.Assert Alarm Active  faultId=1911
  ...  faultName="RX out of order"
  ...  connection=${connection}
  ...  timeout=600
  IF  '${fid1911_status}'=='PASS'
  ...        Logging With Timestamp
  ...        message=FID1911 reported!
  ...  ELSE  Run Keywords
  ...        Logging With Timestamp
  ...        message=FID1911 not reported! Recovering...
  ...        AND  Fail   FID1911 was not reported!

  Logging With Timestamp
  ...  message=Waiting for RMOD status degraded...
  admin.Assert
  ...  class_name=RMOD
  ...  id=${ru_dist_name}
  ...  operationalState=regex"(?i)enabled"
  ...  availabilityStatus=regex"(?i)degraded"
  ...  timeout=300
  ...  connection=${connection}
  [Return]  ${alarm_info}  ${ru_off_timestamp}
  [Teardown]  Recover Fault FID1911  ru_sn=${ru_sn}
  ...  ru_dist_name=${ru_dist_name}
  ...  connection=${connection}

Generate RU5.1 Fault FID1911
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${connection}
    [Documentation]
    ...  Triggers 1911 on tested radio. After that check if FID1911 is reported
    ...
    ...  |  **Author:**      dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | ru_dist_name | Yes  | internal id of radio unit under test             |
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

  Logging With Timestamp
  ...  message=Generating FID1911...
  radio.Generate Fault  ru_serial_number=${ru_sn}
  ...  fault_id=1911
  ${ru_off_timestamp}=  Get Current Date  UTC
  Logging With Timestamp
  ...  message=Waiting for FID1911...
  Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1911  connection=${connection}
  ${fid1911_status}  ${alarm_info}=  Run Keyword And Ignore Error  Assert Alarm Active  faultId=1911
  ...  faultName="Radio autonomous reset as recovery action"
  ...  connection=${connection}
  ...  timeout=600
  IF  '${fid1911_status}'=='PASS'
  ...        Logging With Timestamp
  ...        message=FID1911 reported! Try to set RECOVERY_SITE_RESET to TRUE
  ...  ELSE  Run Keywords
  ...        Logging With Timestamp
  ...        message=FID1911 not reported! Try to set RECOVERY_SITE_RESET to TRUE
  ...        AND  Fail   FID1911 was not reported!

  Logging With Timestamp
  ...  message=Waiting for RMOD status disabled...
  admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)disabled"
    ...  timeout=300
    ...  connection=${connection}
  Logging With Timestamp
  ...  message=Waiting for RMOD status enabled...
  admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  timeout=300
    ...  connection=${connection}
  [Return]  ${alarm_info}  ${ru_off_timestamp}
  [Teardown]  Recover Fault FID1911  ru_sn=${ru_sn}
  ...  ru_dist_name=${ru_dist_name}
  ...  connection=${connection}

Generate RU6 Fault FID1911
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${connection}
    [Documentation]
    ...  Triggers 1911 with severity Warning/Critical on tested radio. After that check if FID1911 is reported
    ...
    ...  |  **Author:**      daniel.bartkowiak@nokia.com
    ...  |  **Maintainer:**  daniel.bartkowiak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | ru_dist_name | Yes  | internal id of radio unit under test             |
    ...  +--------------+------+--------------------------------------------------+
    ...  | alias        | Yes  | alias for active ssh connection to SMOD          |
    ...  +--------------+------+--------------------------------------------------+
    ...
    ...  **Return parameters**
    ...
    ...  +-----------------------------+--------------------------------------------------+
    ...  | Parameter                   | Description                                      |
    ...  +=============================+==================================================+
    ...  | warning_alarm_info          | list containing active alarms info               |
    ...  +-----------------------------+--------------------------------------------------+
    ...  | fid1911_warning_timestamp   | timestam of the begining of the radio reset      |
    ...  +-----------------------------+--------------------------------------------------+
    ...  | critical_alarm_info         | list containing active alarms info               |
    ...  +-----------------------------+--------------------------------------------------+
    ...  | fid1911_critical_timestamp  | timestam of the begining of the radio reset      |
    ...  +-----------------------------+--------------------------------------------------+

    Logging With Timestamp
    ...  message=Generating fault 1911 Warning. Should appear three times.
    ${fid1911_warning_timestamp}=  Get Current Date  UTC
    radio.Generate Fault  fault_id=1911  ru_serial_number=${ru_sn}
    FOR  ${index}  IN RANGE  1  4
      ${warning}  Run Keyword And Return Status  admin.Assert Alarm Active
      ...  parameters=faultId=1911, severity=Warning
      ...  timeout=${RADIO_STARTUP_DELAY}
      ...  connection=${connection}
      admin.Add Allowed Alarm  faultId=1911, severity=Warning  connection=${connection}
      Run Keyword If  '${warning}'=='True'
      ...  Logging With Timestamp
      ...  message=Fault 1911 with severity warning appeared ! Attempt ${index} succeeded
      ...  ELSE  Run Keyword And Continue On Failure
      ...  Fail  Fault 1911 with severity warning did not appear ! Try to set RECOVERY_SITE_RESET to TRUE
      admin.Assert Alarm Inactive
      ...  parameters=faultId=1911, severity=Warning
      ...  timeout=100
      ...  connection=${connection}
    END

    ${warning_alarm_info}=  admin.Get Alarm History  timeout=60  detailed_output=False  connection=${connection}

    Logging With Timestamp
    ...  message=---Waiting for fault 1911 with severity critical---
    ${fid1911_critical_timestamp}=  Get Current Date  UTC
    ${critical_alarm_info}  Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active  faultId=1911, severity=Critical
    ...  connection=${connection}  timeout=${RADIO_STARTUP_DELAY}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1911, severity=Critical  connection=${connection}
    ${critical_alarm_status}  Run Keyword And Return Status
    ...  admin.Assert Alarm Active  faultId=1911, severity=Critical
    ...  timeout=30  connection=${connection}
    Run Keyword If  '${critical_alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=Fault 1911 with severity critical appeared !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 1911 with severity critical did not appear !

    [Return]  ${warning_alarm_info}  ${fid1911_warning_timestamp}  ${critical_alarm_info}  ${fid1911_critical_timestamp}
    [Teardown]  Recover Fault FID1911  ru_sn=${ru_sn}
    ...  ru_dist_name=${ru_dist_name}
    ...  connection=${connection}

Recover Fault FID1911
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${connection}
    [Documentation]
    ...  KW is recovering radio after fault detection.
    ...
    ...  |  **Author:**      dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    ...
    ...  **Input Parameters:**
    ...
    ...  +--------------+------+--------------------------------------------------+
    ...  | Parameter    | Man. | Description                                      |
    ...  +==============+======+==================================================+
    ...  | ru_sn        | Yes  | serial number of radio unit under test           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | ru_dist_name | Yes  | radio runtime distname                           |
    ...  +--------------+------+--------------------------------------------------+
    ...  | connection   | Yes  | aliast to BTS, BTS_ID                            |
    ...  +--------------+------+--------------------------------------------------+
    Logging With Timestamp
    ...  message=Recovering FID1911...
    radio.Recover Fault  ru_serial_number=${ru_sn}
    ...  fault_id=1911
    Logging With Timestamp
    ...  message=Waiting for RMOD status disabled...
    Run Keyword And Ignore Error  admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)disabled"
    ...  timeout=300
    ...  connection=${connection}
    Logging With Timestamp
    ...  message=Waiting for RMOD status enabled...
    Run Keyword And Ignore Error  admin.Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  timeout=${RADIO_STARTUP_DELAY}
    ...  connection=${connection}
    Run Keyword And Ignore Error  STATE Verify Multi Node State  scf_check=${FALSE}  timeout=400
