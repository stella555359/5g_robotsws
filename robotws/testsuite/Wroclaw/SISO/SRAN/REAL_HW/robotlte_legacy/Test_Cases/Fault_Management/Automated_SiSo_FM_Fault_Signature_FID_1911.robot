*** Settings ***
Documentation    Triggers [FID1911 - RX out of order] on RUs under test
...    and checks if faultSignature part of alarm response contains correct values.
...
...    Fault generation steps are as fallows:
...    1. Files in FRMON are decoded to JSONS
...    2. RU Reboot is performed
...    3. Waiting for RU to restore connection.
...    4. Create RfSynthesizer Agent and force unlock.
...
...    NOTE: User must import /testsuite/WMP/GVe/Wroclaw/AiFSiteS/resources/variables.robot in their testsuite!
...
...    Fault ID name according to NIDD: EFaultId_FrRxOutOfOrder
...
...    Author:        dawid.bak@nokia.com
...    Maintainer:    Dawid Bak

Resource    ./fault_signature_common.robot


*** Keywords ***
RF Fault Signature FID1911
    [Documentation]
    ...  Triggers FID1911 and checks if faultSignature part of alarm response contains correct values
    ...
    ...  |  **Author:**      dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=RF Fault Signature FID1911
    ...  style=ONGOING
    ${rf_list}=    Get Dictionary Keys   ${cfg.RF_INFO}
    ${RF_status}=   Run Keyword And Return Status    Variable Should Exist    ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=    Set Variable If   ${RF_status}    ${CUSTOM_RADIO_UNIT_LIST}    ${rf_list}
    FOR   ${ru_sn}    IN    @{rf_list}
      ${ru_bts_id}    ${ru_dist_name}=    Get RU Node Data    ${ru_sn}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
      Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
      Log  Testing FID1911 with severity Warning  console=true
      ${alarm_info}  ${ru_off_timestamp}=  Generate RU Fault FID1911  ru_sn=${ru_sn}
      ...  ru_dist_name=${ru_dist_name}
      ...  alias=${ru_bts_id}
      Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
      ...  faultId=1911
      ...  fault_signature_scheme=${FID1911_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1911_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  alias=${ru_bts_id}
      ...  forbidden_severities=Critical
      Log  Testing FID1911 with severity Critical  console=true
      ${alarm_info}  ${ru_off_timestamp}=  Generate RU Fault FID1911 Critical  ru_sn=${ru_sn}
      ...  ru_dist_name=${ru_dist_name}
      ...  alias=${ru_bts_id}
      Analyze Alarm List For Fault Signature  alarm_info=${alarm_info}
      ...  faultId=1911
      ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
      ...  alarm_details_scheme=${FID_1911_ALARM_INFO}
      ...  fault_signature_timestamp=${ru_off_timestamp}
      ...  ru_sn=${ru_sn}
      ...  alias=${ru_bts_id}
      ...  allowed_severities=Critical
    END
    [Teardown]    Common Test Teardown

Generate RU Fault FID1911
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${alias}
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

  Log  Generating FID1911...  console=True
  radio.Generate Fault  ru_serial_number=${ru_sn}
  ...  fault_id=1911
  ${ru_off_timestamp}=  Get Current Date      UTC
  Log  Waiting for FID1911...  console=True
  Run Keyword And Ignore Error    admin.Add Allowed Alarm  faultId=1911  connection=${alias}
  ${fid1911_status}  ${alarm_info}=  Run Keyword And Ignore Error  Assert Alarm Active  faultId=1911
  ...  faultName="Radio autonomous reset as recovery action"
  ...  alias=${alias}
  ...  timeout=600
  Run Keyword If    '${fid1911_status}'=='PASS'
  ...        Log  FID1911 reported!  console=True
  ...  ELSE  Run Keywords
  ...        Log  FID1911 not reported! Recovering...  console=True
  ...        AND  Fail   FID1911 was not reported!

  Log  Waiting for RMOD status disabled...  console=True
  Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)disabled"
    ...  alias=${alias}
  Log  Waiting for RMOD status enabled...  console=True
  Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  alias=${alias}
  [Return]  ${alarm_info}  ${ru_off_timestamp}
  [Teardown]  Recover RU Fault FID1911  ru_sn=${ru_sn}
  ...  ru_dist_name=${ru_dist_name}
  ...  alias=${alias}

Generate RU Fault FID1911 Critical
    [Arguments]  ${ru_sn}  ${ru_dist_name}  ${alias}
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

  FOR  ${i}  IN RANGE  0  2
    Log  Generating FID1911...  console=True
    radio.Generate Fault  ru_serial_number=${ru_sn}
    ...  fault_id=1911
    Log  Waiting for FID1911...  console=True
    ${fid1911_status}  ${alarm_info}=  Run Keyword And Ignore Error  Assert Alarm Active  faultId=1911
    ...  faultName="Radio autonomous reset as recovery action"
    ...  alias=${alias}
    ...  timeout=120
    Run Keyword If    '${fid1911_status}'=='PASS'
    ...        Log  FID1911 reported!  console=True
    ...  ELSE  Run Keywords
    ...        Log  FID1911 not reported! Recovering...  console=True
    ...        AND  Fail   FID1911 was not reported!
    Log  Waiting for RMOD status disabled...  console=True
    Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
      ...  id=${ru_dist_name}
      ...  operationalState=regex"(?i)disabled"
      ...  alias=${alias}
    Log  Waiting for RMOD status enabled...  console=True
    Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
      ...  id=${ru_dist_name}
      ...  operationalState=regex"(?i)enabled"
      ...  alias=${alias}
  END

  Log  Generating FID1911...  console=True
  radio.Generate Fault  ru_serial_number=${ru_sn}
  ...  fault_id=1911
  ${ru_off_timestamp}=  Get Current Date      UTC
  Log  Waiting for FID1911...  console=True
  ${fid1911_status}  ${alarm_info}=  Run Keyword And Ignore Error  Assert Alarm Active  faultId=1911
  ...  faultName="RX out of order"
  ...  alias=${alias}
  ...  timeout=600
  Run Keyword If    '${fid1911_status}'=='PASS'
  ...        Log  FID1911 reported!  console=True
  ...  ELSE  Run Keywords
  ...        Log  FID1911 not reported! Recovering...  console=True
  ...        AND  Fail   FID1911 was not reported!

  Log  Waiting for RMOD status degraded...  console=True
  Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  availabilityStatus=regex"(?i)degraded"
    ...  alias=${alias}
  [Return]  ${alarm_info}  ${ru_off_timestamp}
  [Teardown]  Recover RU Fault FID1911  ru_sn=${ru_sn}
  ...  ru_dist_name=${ru_dist_name}
  ...  alias=${alias}

Recover RU Fault FID1911
  [Arguments]  ${ru_sn}  ${ru_dist_name}  ${alias}
  Log  Recovering FID1911...  console=True
  radio.Recover Fault  ru_serial_number=${ru_sn}
  ...  fault_id=1911
  Log  Waiting for RMOD status disabled...  console=True
  Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)disabled"
    ...  alias=${alias}
  Log  Waiting for RMOD status enabled...  console=True
  Wait Until Keyword Succeeds  300s  20s  Assert  class_name=RMOD
    ...  id=${ru_dist_name}
    ...  operationalState=regex"(?i)enabled"
    ...  alias=${alias}
