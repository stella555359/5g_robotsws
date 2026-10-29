*** Settings ***
Documentation  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FPB-930035
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
...  TC works with RU family: 6.2*, tested on AHPMDG.
...  *RU must be supported by the library radio_operations.py
...
...
...  ******************
...  History of changes
...  ******************
...  02.11.2023 - Initial creation - https://jiradc.ext.net.nokia.com/browse/FPB-930035

Resource  ./FM_Fault_Signature.resource

*** Variables ***
${RADIO_STARTUP_DELAY}     600         # Custom radio startup delay
${RECOVERY_SITE_RESET}     ${FALSE}    #Recovery site reset to clear radio counter and avoid improper fault generation in multiply iterations
                                       #To avoid impact for other Fault Signature TCs in same TS then set flag TRUE
#@{CUSTOM_RADIO_UNIT_LIST}             - Custom radio list
#${FID_1981_WARNING_TIMEOUT}           - timeout for faultsignature threshold, default 900s. Can be set by user if needed
#${FID_1981_CRITICAL_TIMEOUT}          - timeout for faultsignature threshold, default 360s. Can be set by user if needed

*** Keywords ***
TC__FM_Fault_Signature_FID_1981
    Set Tags  OWNER-malgorzata.piecyk-celuch@nokia.com  AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...  MAINTAINER-malgorzata.piecyk-celuch@nokia.com  PHASE-CRT
    ...  FEATURE-CB008782
    Common Test Setup
    Logging With Timestamp
    ...  message=RF Fault Signature FID1981
    ...  style=STEP
    ...  frame=${TRUE}

    ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
    ${RF_status}=  Run Keyword And Return Status  Should Not Be Empty  ${CUSTOM_RADIO_UNIT_LIST}
    ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}

    FOR  ${ru_sn}  IN  @{rf_list}
       ${ru_bts_id}  ${ru_dist_name}=  SITE Get RU Node Data  ${ru_sn}
       Set Test Variable  ${RU_DIST_NAME}
       Set Test Variable  ${RU_BTS_ID}

       Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  connection=${ru_bts_id}
       Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1815  connection=${ru_bts_id}
       ${alarm_info}  ${critical_alarm_info}  ${fid1981_warning_timestamp}  ${fid1981_critical_timestamp}=  Generate Fault FID1981
       ...  ru_sn=${ru_sn}  connection=${RU_BTS_ID}  faultId=1981

       Logging With Timestamp
       ...  message=-----Checking fault signature data of Fault 1981-----

       FM Analyze Alarm List For Fault Signature
       ...  alarm_info=${alarm_info}
       ...  faultId=1981
       ...  fault_signature_scheme=${FID1981_FAULT_SIGNATURE_SCHEME}
       ...  alarm_details_scheme=${FID_1981_ALARM_INFO}
       ...  fault_signature_timestamp=${fid1981_warning_timestamp}
       ...  timestamp_timeout=${FID_1981_WARNING_TIMEOUT}
       ...  ru_sn=${ru_sn}
       ...  forbidden_severities='Critical'
       ...  allowed_severities=${None}
       ...  connection=${RU_BTS_ID}

       FM Analyze Alarm List For Fault Signature
       ...  alarm_info=${critical_alarm_info}
       ...  faultId=1981
       ...  fault_signature_scheme=${CRITICAL_FAULT_SIGNATURE_SCHEME}
       ...  alarm_details_scheme=${FID_1981_ALARM_INFO}
       ...  fault_signature_timestamp=${fid1981_critical_timestamp}
       ...  timestamp_timeout=${FID_1981_CRITICAL_TIMEOUT}
       ...  ru_sn=${ru_sn}
       ...  forbidden_severities=${None}
       ...  allowed_severities=Critical
       ...  connection=${RU_BTS_ID}
    END

    [Teardown]  Run Keywords
    ...  Run Keyword If  ${RECOVERY_SITE_RESET}  FM Recovery Site Reset For Fault Signature
    ...  bts=${RU_BTS_ID}
    ...  ru_dist_name=${RU_DIST_NAME}
    ...  timeout=${RADIO_STARTUP_DELAY}
    ...  AND  Common Test Teardown

Generate Fault FID1981
    [Arguments]  ${ru_sn}  ${connection}  ${faultId}

    Logging With Timestamp
    ...  message=-----Generating Fault 1981 on RMOD-----

    ${fid1981_warning_timestamp}=  Get Current Date  UTC
    radio.Generate Fault  ru_serial_number=${ru_sn}  fault_id=1981
    Logging With Timestamp
    ...  message=Waiting until the RMOD reaches disabled state
    admin.Assert  RMOD  ${RU_DIST_NAME}  operationalState=regex"(?i)disabled"  timeout=300  connection=${connection}
    Logging With Timestamp
    ...  message=Waiting until the RMOD reaches enabled state
    ${enabled_state}  Run Keyword And Return Status
    ...  admin.Assert  RMOD  ${RU_DIST_NAME}  operationalState=regex"(?i)enabled"  timeout=300  connection=${connection}
    Run Keyword If  '${enabled_state}'=='True'
    ...  Logging With Timestamp
    ...  message=RMOD is enabled !${\n}
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  RMOD did not reach enabled state after generating fault 1981 !

    ${status}  Run Keyword And Return Status
    ...  Repeat Keyword  3x  Generate Fault 1981 With Severity Warning  connection=${RU_BTS_ID}  ru_sn=${ru_sn}  distname=${RU_DIST_NAME}
    Run Keyword If  '${status}'=='True'
    ...  Logging With Timestamp
    ...  message=FID 1981 with severity warning appeared corretly ! Try to set RECOVERY_SITE_RESET to TRUE
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  At least one of warning 1981 did not appear, check logs ! Try to set RECOVERY_SITE_RESET to TRUE

    ${alarm_info}=   admin.Get Alarm History  timeout=60  detailed_output=False  connection=${connection}

    Logging With Timestamp
    ...  message=---Checking correct quantity of fault 1981---
    ${alarms_list}  Create List
    FOR  ${alarm}  IN  @{alarm_info}
       Append To List  ${alarms_list}  '${alarm['faultId']}'
    END
    ${count}=  Count Values In List  ${alarms_list}  '${faultId}'
    ${count_status}  Run Keyword And Return Status  Should Be True  ${count}==3
    Run Keyword If  '${count_status}'=='True'
    ...  Logging With Timestamp
    ...  message=Fault 1981 with severity Warning correctly appeared 3 times
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=Fault 1981 with severity Warning appeared only ${count} times, but it should appear 3 times.
    ...  AND  Fail  Fault 1981 with severity Warning appeared only ${count} times, but it should appear 3 times.

    Logging With Timestamp
    ...  message=---Waiting for fault 1981 with severity critical---
    ${fid1981_critical_timestamp}=  Get Current Date  UTC
    radio.Kill Process On Radio Module By Name  ru_serial_number=${ru_sn}  process_name=port::0
    ${critical_alarm_info}  Run Keyword And Continue On Failure
    ...  admin.Assert Alarm Active  faultId=1981, severity=Critical,
    ...  faultName="FR module reset requested"  connection=${connection}  timeout=300
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1981, severity=Critical  connection=${connection}
    ${critical_alarm_status}  Run Keyword And Return Status
    ...  admin.Assert Alarm Active  faultId=1981, severity=Critical,
    ...  faultName="FR module reset requested"  timeout=200  connection=${connection}
    Run Keyword If  '${critical_alarm_status}'=='True'
    ...  Logging With Timestamp
    ...  message=Fault 1981 with severity critical appeared !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 1981 with severity critical did not appear !

    [Return]  ${alarm_info}  ${critical_alarm_info}  ${fid1981_warning_timestamp}  ${fid1981_critical_timestamp}
    [Teardown]  Recover Fault FID1981  connection=${RU_BTS_ID}  ru_sn=${ru_sn}  distname=${RU_DIST_NAME}

Generate Fault 1981 With Severity Warning
    [Arguments]  ${ru_sn}  ${connection}  ${distname}

    Logging With Timestamp
    ...  message=---Waiting for appearance of fault 1981 with severity warning---

    radio.Kill Process On Radio Module By Name  ru_serial_number=${ru_sn}  process_name=port::0
    ${warning}  Run Keyword And Return Status
    ...  admin.Assert Alarm Active  faultId=1981, severity=Warning,
    ...  faultName="Radio autonomous reset as recovery action"  timeout=300  connection=${connection}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1981, severity=Warning  connection=${connection}
    Run Keyword If  '${warning}'=='True'
    ...  Logging With Timestamp
    ...  message=Fault 1981 with severity warning appeared !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  Fault 1981 with severity warning did not appear !

    Logging With Timestamp
    ...  message=Wait until the RMOD reaches enabled state
    admin.Assert  RMOD  ${distname}  operationalState=regex"(?i)disabled"  timeout=300  connection=${connection}
    ${rmod_status}  Run Keyword And Return Status
    ...  admin.Assert  RMOD  ${distname}  operationalState=regex"(?i)enabled"  timeout=300  connection=${connection}
    Run Keyword If  '${rmod_status}'=='True'
    ...  Logging With Timestamp
    ...  message=RMOD is enabled !
    ...  ELSE  Run Keyword And Continue On Failure
    ...  Fail  After fault 1981 appears RMOD is not enabled as it should be !

Recover Fault FID1981
    [Arguments]  ${connection}  ${ru_sn}  ${distname}

    Logging With Timestamp
    ...  message=-----Recovering Fault 1981 on RMOD-----
    radio.Recover Fault  ru_serial_number=${ru_sn}  fault_id=1981
    Logging With Timestamp
    ...  message=Wait until the RMOD reaches enabled state
    ${rmod_status}  Run Keyword And Return Status
    ...  admin.Assert  RMOD  ${distname}  operationalState=regex"(?i)enabled"  timeout=300  connection=${connection}
    Run Keyword If  '${rmod_status}'=='True'
    ...  Logging With Timestamp
    ...  message=RMOD is fully recovered !
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=RMOD is not enabled !
    ...  AND  Fail  RMOD has not been fully recovered and can not reach enabled state !
    STATE Verify Multi Node State  scf_check=${FALSE}  timeout=300
