*** Settings ***
Documentation
  ...  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  TC is applicable only for AirScale sub-racks supporting ambient temperature monitoring functionality: AMID(L), AMOE.
  ...
  ...  Step 1: Preconditions SMOD High Low Temp Offset
  ...  Checking if the given interval is correct.
  ...  Checking if parameter mtSBTSCabiTempMonitoring is disabled.
  ...  Checking if all cells are onAir.
  ...
  ...  Step 2: Activate Cabinet Ambient Temperature Monitoring Alarms
  ...  Setting parameter actCabiTempMonAlarms to true.
  ...  Setting measurement interval of mtSBTSCabiTempMonitoring.
  ...  Checking if all cells are onAir.
  ...
  ...  Step 3: Set High Ambient Temperature Threshold Offset And Wait For Alarm
  ...  Setting tempHighOffset to given value.
  ...  Waiting for alarm 4343 (Ambient temperature is high) within 240 sec.
  ...  Removing parameter tempHighOffset for clear alarm.
  ...  Waiting for alarm 4343 to clear within 240 sec.
  ...
  ...  Step 4: Set Low Ambient Temperature Threshold Offset And Wait For Alarm
  ...  Setting tempLowOffset to given value.
  ...  Waiting for alarm 4792 (Ambient temperature is low) within 240 sec.
  ...  Removing parameter tempLowOffset for clear alarm.
  ...  Waiting for alarm 4792 to clear within 240 sec.
  ...  Disabling parameters actCabiTempMonAlarms and mtSBTSCabiTempMonitoring.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 05.05.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${INTERVAL}  5
${HIGH_OFFSET}  -25
${LOW_OFFSET}  35

*** Keywords ***
TC__FM_SMOD_High_Low_Temp_Offset
  Set Tags  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Preconditions SMOD High Low Temp Offset  ${bts_id}
  Step 2: Activate Cabinet Ambient Temperature Monitoring Alarms  ${bts_id}
  Step 3: Set High Ambient Temperature Threshold Offset And Wait For Alarm  ${bts_id}
  Step 4: Set Low Ambient Temperature Threshold Offset And Wait For Alarm  ${bts_id}
  [Teardown]  Common Test Teardown

Step 1: Preconditions SMOD High Low Temp Offset
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions SMOD High Low Temp Offset
    ...  style=STEP
    ...  frame=${TRUE}

    @{available_intervals}  Create List  5  15  30  60  360  720  1440
    IF  '${INTERVAL}' in ${available_intervals}
        Logging With Timestamp  message=Given interval ${INTERVAL} is correct.
    ELSE
        Fail  Given interval ${INTERVAL} doesn't meet condition. Allowed values: 5 15 30 60 360 720 1440.
    END

    ${mtCabiTemp_list}  Create List  mtSBTSCabiTempMonitoring
    Set Test Variable  ${MT_CABI_TEMP_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1
    Set Test Variable  ${ACT_CABI_TEMP_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/FMCADM-1
    Set Test Variable  ${TEMP_OFFSET_PATH}  MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1

    ${reference_param_dict}  admin.Get Parameter By Distname  ${MT_CABI_TEMP_PATH}  ${mtCabiTemp_list}  connection=${bts_id}
    IF  '${reference_param_dict[0]['parameters']['mtSBTSCabiTempMonitoring']}'!='disabled'
        admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
    ELSE
        Logging With Timestamp  message=mtSBTSCabiTempMonitoring parameter is disabled, as expected.
    END

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after recommissioning!
    ELSE
        Logging With Timestamp  message=All cells are onAir !\n
    END

    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=4743  connection=${bts_id}
    Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=4792  connection=${bts_id}

Step 2: Activate Cabinet Ambient Temperature Monitoring Alarms
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Activate Cabinet Ambient Temperature Monitoring Alarms
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=actCabiTempMonAlarms is setting to true !
    admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  true  connection=${bts_id}
    Logging With Timestamp  message=actCabiTempMonAlarms recommissioned to true !

    Logging With Timestamp  message=mtSBTSCabiTempMonitoring is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  ${INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSCabiTempMonitoring recommissioned to ${INTERVAL}min !\nNow check if cells are onAir...\n

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp
        ...  message=Cells are not onAir after recommissioning! Parameter restoring and set test failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  false  connection=${bts_id}
        admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Cells are not onAir after recommissioning! Parameter restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

Step 3: Set High Ambient Temperature Threshold Offset And Wait For Alarm
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Set High Ambient Temperature Threshold Offset And Wait For Alarm
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=tempHighOffset is setting to ${HIGH_OFFSET}°C !
    admin.Perform Parameter Recommissioning  ${TEMP_OFFSET_PATH}  tempHighOffset  update  ${HIGH_OFFSET}  connection=${bts_id}
    Logging With Timestamp  message=tempHighOffset recommissioned to ${HIGH_OFFSET}°C !

    Logging With Timestamp  message=Waiting for raise of FaultID 4743!
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4743  timeout=720  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp  message=FaultID 4743 RAISED !
        ...  style=PASS
    ELSE
        Logging With Timestamp
        ...  message=Fail, Fault 4743 NOT raised !
        admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  false  connection=${bts_id}
        admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Remove Temperature Threshold Offset Parameter  tempHighOffset
        Fail  Fault 4743 NOT raised !
    END

    Logging With Timestamp  message=Removing parameter tempHighOffset for clearing alarm !
    Remove Temperature Threshold Offset Parameter  tempHighOffset

    Logging With Timestamp  message=Waiting for clear FaultID 4743 !
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4743  timeout=240  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp  message=FaultID 4743 is cleared !
        ...  style=PASS
    ELSE
        Logging With Timestamp
        ...  message=Fail, Fault 4743 is still visible, but it should not be !
        admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  false  connection=${bts_id}
        admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Fault 4743 is still visible, but it should not be !
    END

Step 4: Set Low Ambient Temperature Threshold Offset And Wait For Alarm
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4: Set Low Ambient Temperature Threshold Offset And Wait For Alarm
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=tempLowOffset is setting to ${LOW_OFFSET}°C !
    admin.Perform Parameter Recommissioning  ${TEMP_OFFSET_PATH}  tempLowOffset  update  ${LOW_OFFSET}  connection=${bts_id}
    Logging With Timestamp  message=tempLowOffset recommissioned to ${LOW_OFFSET}°C !

    Logging With Timestamp  message=Waiting for raise of FaultID 4792!
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active  faultId=4792  timeout=720  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp  message=FaultID 4792 RAISED !
        ...  style=PASS
    ELSE
        Logging With Timestamp
        ...  message=Fail, Fault 4792 NOT raised !
        admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  false  connection=${bts_id}
        admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Remove Temperature Threshold Offset Parameter  tempLowOffset
        Fail  Fault 4792 NOT raised !
    END

    Logging With Timestamp  message=Removing parameter tempLowOffset for clearing alarm !
    Remove Temperature Threshold Offset Parameter  tempLowOffset

    Logging With Timestamp  message=Waiting for clear FaultID 4792 !
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive  faultId=4792  timeout=240  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp  message=FaultID 4792 is cleared !
        ...  style=PASS
    ELSE
        Logging With Timestamp
        ...  message=Fail, Fault 4792 is still visible, but it should not be !
        admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  false  connection=${bts_id}
        admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Fault 4792 is still visible, but it should not be !
    END

    Logging With Timestamp  message=Disabling parameters actCabiTempMonAlarms and mtSBTSCabiTempMonitoring !
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${ACT_CABI_TEMP_PATH}  actCabiTempMonAlarms  update  false  connection=${bts_id}
    admin.Perform Parameter Recommissioning  ${MT_CABI_TEMP_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}


Remove Temperature Threshold Offset Parameter
    [Arguments]  ${tempOffsetParamName}
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    admin.Create Delta
    admin.Append Parameter Delete To Delta  ${TEMP_OFFSET_PATH}  ${tempOffsetParamName}
    ${delta}  admin.Get Delta
    ${delta_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  5 min  30 s
    ...  admin.Perform Delta Recommissioning  ${delta}  timeout=600  connection=${bts_id}
    admin.Remove Delta

    IF  '${delta_status}'=='True'
        Logging With Timestamp  message=Recommissioning is done successfully
        ...  style=PASS
    ELSE
        Logging With Timestamp  message=Recommissioning is not done successfully
        ...  style=ERROR
        Fail  Recommissioning is not done successfully
    END
