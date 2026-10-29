*** Settings ***
Documentation  Suite description

Resource  ./fault_signature_common.robot



*** Keywords ***
RF Fault Signature FID1981
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FPB-930035
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check correct raise of fault 1981 "FR module reset requested"
    ...  and if faultSignature part of alarm response contains correct values.
    ...  Fault ID name according to NIDD: EFaultId_FrResetRequestedAl.
    ...  Triggering:
    ...  File in FRMON is decoded to JSON. (syscon_node0.bin)
    ...  Decoded JSON is downloaded to SMOD and edited.
    ...  RU reboot is performed.
    ...  Fault is trigger if process with port::0 will be killed.
    ...  Terminating of three processes generate single faults with severity warning,
    ...  fourth will generate fault with severity critical.
    ...  Recovering:
    ...  Removing runtime config.
    ...
    ...  It is necessary to add path to the file: variables.robot in the testsuite, in the ***Settings*** section:
    ...  Resource  ../../../resources/variables.robot.
    ...
    ...  TC works with RU family: 6.2*, tested on AHPMDG.
    ...  *RU must be supported by the library radio_operations.py
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  02.11.2023 - Initial creation - https://jiradc.ext.net.nokia.com/browse/FPB-930035

    Set Tags  OWNER-malgorzata.piecyk-celuch@nokia.com  AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...  MAINTAINER-malgorzata.piecyk-celuch@nokia.com  PHASE-CRT
    ...  FEATURE-CB008782
    Common Test Setup
    Logging With Timestamp
    ...  message=Execute Recommissioning On Every Node on list : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING

    ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
    ${RF_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}

    FOR  ${ru_sn}  IN  @{rf_list}
       ${ru_bts_id}  ${ru_dist_name}=  Get RU Node Data  ${ru_sn}
       Set Test Variable  ${RU_DIST_NAME}
       Set Test Variable  ${RU_BTS_ID}

       ${hw_release}=  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${ru_sn}']['scf_release_code']}').group(0)  re
       ${status_hw_release}=  Run Keyword And Return Status  Should Be True  '${hw_release}'=='6.2'
       Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
       Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
       ${alarm_info}  ${critical_alarm_info}  ${fid1981_warning_timestamp}  ${fid1981_critical_timestamp}  Run Keyword If  ${status_hw_release}
       ...  Generate RU Fault FID1981
       ...  ru_sn=${ru_sn}  alias=${RU_BTS_ID}  faultId=1981
       ...  ELSE  Run Keywords  Log  RMOD family is not 6.2, radio module does not support fault 1981${\n}  console=True
       ...  AND  Fail  RMOD family is not 6.2, radio module does not support fault 1981${\n}

    Log  ${\n}-----Checking fault signature data of Fault 1981-----${\n}  console=True

       Analyze Alarm List For Fault Signature
       ...  alarm_info=${alarm_info}
       ...  faultId=1981
       ...  fault_signature_scheme=${FID1981_FAULT_SIGNATURE_SCHEME}
       ...  alarm_details_scheme=${FID_1981_ALARM_INFO}
       ...  fault_signature_timestamp=${fid1981_warning_timestamp}
       ...  timestamp_timeout=${FID_1981_WARNING_TIMEOUT}
       ...  ru_sn=${ru_sn}
       ...  forbidden_severities='Critical'
       ...  allowed_severities=${None}
       ...  alias=${RU_BTS_ID}

       Analyze Alarm List For Fault Signature
       ...  alarm_info=${critical_alarm_info}
       ...  faultId=1981
       ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
       ...  alarm_details_scheme=${FID_1981_ALARM_INFO}
       ...  fault_signature_timestamp=${fid1981_critical_timestamp}
       ...  timestamp_timeout=${FID_1981_CRITICAL_TIMEOUT}
       ...  ru_sn=${ru_sn}
       ...  forbidden_severities=${None}
       ...  allowed_severities=Critical
       ...  alias=${RU_BTS_ID}
    END

    [Teardown]  Run Keywords
    ...  Recover RU Fault FID1981  alias=${RU_BTS_ID}  ru_sn=${ru_sn}  distname=${RU_DIST_NAME}
    ...  AND  Common Test Teardown

Generate RU Fault FID1981
    [Arguments]  ${ru_sn}  ${alias}  ${faultId}

    Log  -----Generating Fault 1981 on RMOD-----${\n}  console=True

    radio.Generate Fault  ru_serial_number=${ru_sn}  fault_id=1981
    Log  Waiting until the RMOD reaches disabled state  console=True
    ${disabled_state}  Wait Until Keyword Succeeds
    ...  300s  20s  Assert  RMOD  ${RU_DIST_NAME}  operationalState=regex"(?i)disabled"  alias=${alias}
    Log  Waiting until the RMOD reaches enabled state  console=True
    ${enabled_state}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300s  20s  Assert  RMOD  ${RU_DIST_NAME}  operationalState=regex"(?i)enabled"  alias=${alias}
    Run Keyword If  '${enabled_state}'=='True'
    ...  Log  RMOD is enabled !${\n}  console=True
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  RMOD did not reach enabled state after generating fault 1981 !

    ${fid1981_warning_timestamp}=  Get Current Date  UTC

    ${status}  Run Keyword And Return Status
    ...  Repeat Keyword  3x  Generate FID1981 With Severity Warning  alias=${RU_BTS_ID}  ru_sn=${ru_sn}  distname=${RU_DIST_NAME}
    Run Keyword If  '${status}'=='True'
    ...  Log  FID 1981 with severity warning appeared corretly !  console=True
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  At least one of warning 1981 did not appear, check logs !

    ${alarm_info}  Run Keyword And Continue On Failure  Get Historic Alarms  timeout=360  connection=${alias}
    ...  severity=Warning  load_history=True

    Log  ${\n}---Checking correct quantity of fault 1981---  console=True
    ${alarms_list}  Create List
    FOR  ${alarm}  IN  @{alarm_info}
       Append To List  ${alarms_list}  '${alarm['faultId']}'
    END
    ${count}=  Count Values In List  ${alarms_list}  '${faultId}'
    ${count_status}  Run Keyword And Return Status  Should Be True  ${count}==3
    Run Keyword If  '${count_status}'=='True'
    ...  Log  Fault 1981 with severity Warning correctly appeared 3 times  console=True
    ...  ELSE  Run Keywords
    ...  Log  Fault 1981 with severity Warning appeared only ${count} times, but it should appear 3 times.  console=True
    ...  AND  Fail  Fault 1981 with severity Warning appeared only ${count} times, but it should appear 3 times.

    Log  ${\n}---Waiting for fault 1981 with severity critical---  console=True
    ${fid1981_critical_timestamp}=  Get Current Date  UTC
    radio.Kill Process On Radio Module By Name  ru_serial_number=${ru_sn}  process_name=port::0
    ${critical_alarm_info}  Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active  faultId=1981, severity=Critical,
    ...  faultName="FR module reset requested"  alias=${alias}  timeout=300
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1981, severity=Critical  connection=${alias}
    ${critical_alarm_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120s  5s  admin.Assert Alarm Active  faultId=1981, severity=Critical,
    ...  faultName="FR module reset requested"  alias=${alias}
    Run Keyword If  '${critical_alarm_status}'=='True'
    ...  Log  Fault 1981 with severity critical appeared !${\n}  console=True
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 1981 with severity critical did not appear !

    [Return]  ${alarm_info}  ${critical_alarm_info}  ${fid1981_warning_timestamp}  ${fid1981_critical_timestamp}

Generate FID1981 With Severity Warning
    [Arguments]  ${ru_sn}  ${alias}  ${distname}

    Log  ---Waiting for appearance of fault 1981 with severity warning---  console=True

    radio.Kill Process On Radio Module By Name  ru_serial_number=${ru_sn}  process_name=port::0
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1981, severity=Warning  connection=${alias}
    ${warning}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  240s  5s  admin.Assert Alarm Active  faultId=1981, severity=Warning,
    ...  faultName="Radio autonomous reset as recovery action"  alias=${alias}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1981, severity=Warning  connection=${alias}
    Run Keyword If  '${warning}'=='True'
    ...  Log  Fault 1981 with severity warning appeared !  console=True
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 1981 with severity warning did not appear !

    Log  Wait until the RMOD reaches enabled state  console=True
    ${rmod_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300s  20s  Assert  RMOD  ${distname}  operationalState=regex"(?i)enabled"  alias=${alias}
    Run Keyword If  '${rmod_status}'=='True'
    ...  Log  RMOD is enabled !${\n}  console=True
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  After fault 1981 appears RMOD is not enabled as it should be !

Recover RU Fault FID1981
    [Arguments]  ${alias}  ${ru_sn}  ${distname}

    Log  -----Recovering Fault 1981 on RMOD-----${\n}  console=True

    radio.Recover Fault  ru_serial_number=${ru_sn}  fault_id=1981
    Log  Wait until the RMOD reaches enabled state  console=True
    ${rmod_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300s  20s  Assert  RMOD  ${distname}  operationalState=regex"(?i)enabled"  alias=${alias}
    Run Keyword If  '${rmod_status}'=='True'
    ...  Log  RMOD is fully recovered !  console=True
    ...  ELSE  Run Keywords
    ...  Log  RMOD is not enabled !  console=True
    ...  AND  Fail  RMOD has not been fully recovered and can not reach enabled state !
    Verify Multi BTS State   60 sec
