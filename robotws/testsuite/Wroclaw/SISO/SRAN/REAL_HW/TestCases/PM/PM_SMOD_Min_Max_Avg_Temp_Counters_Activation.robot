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
  ...  Step 1: Preconditions SMOD Min Max Avg Temperature Counters Activation
  ...  Checking if the given interval is correct.
  ...  Setting parameter temperatureSensor to front.
  ...  Checking if parameter mtSBTSCabiTempMonitoring is disabled.
  ...
  ...  Step 2: Enable SBTS SMOD Thermal Monitoring And Verify Counters
  ...  Setting measurement interval of mtSBTSCabiTempMonitoring.
  ...  Checking if all cells are onAir.
  ...  Getting counters after set interval.
  ...  Verify timestamps correctness and values of counters are in the range 20-50.
  ...
  ...  Step 3: Collect And Verify Counters For The Same Interval
  ...  Getting counters after actual interval.
  ...  Verify timestamps correctness and values of counters are in the range 20-50.
  ...
  ...  Step 4: Collect And Verify Counters For Another Interval
  ...  Setting another measurement interval of mtSBTSCabiTempMonitoring.
  ...  Checking if all cells are onAir.
  ...  Getting counters after set interval.
  ...  Verify timestamps correctness and values of counters are in the range 20-50.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 05.05.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot

*** Variables ***
${INTERVAL}  5

*** Keywords ***
TC__PM_SMOD_Min_Max_Avg_Temp_Counters_Activation
  Set Tags  AUTHOR-malgorzata.piecyk-celuch@nokia.com  MAINTAINER-malgorzata.piecyk-celuch@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Preconditions SMOD Min Max Avg Temperature Counters Activation  ${bts_id}
  Step 2: Enable SBTS Cabinet Thermal Monitoring And Verify Counters  ${bts_id}
  Step 3: Collect And Verify Counters For The Same Interval  ${bts_id}
  Step 4: Collect And Verify Counters For Another Interval  ${bts_id}
  [Teardown]  Common Test Teardown

Step 1: Preconditions SMOD Min Max Avg Temperature Counters Activation
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions SMOD Min Max Avg Temperature Counters Activation
    ...  style=STEP
    ...  frame=${TRUE}

    ${COUNTERS_LIST}  Create List  M40009C0  M40019C1  M40019C2
    Set Test Variable  ${COUNTERS_LIST}

    @{available_intervals}  Create List  5  15  30  60  360  720  1440
    IF  '${INTERVAL}' in ${available_intervals}
        Logging With Timestamp  message=Given interval ${INTERVAL} is correct.
    ELSE
        Fail  Given interval ${INTERVAL} doesn't meet condition. Allowed values: 5 15 30 60 360 720 1440.
    END

    Logging With Timestamp  message=Parameter temperatureSensor is setting to front !
    admin.Perform Parameter Recommissioning  MRBTS-${bts_id}/EQM-1/APEQM-1/CABINET-1  temperatureSensor  update  front  connection=${bts_id}
    Logging With Timestamp  message=Parameter temperatureSensor recommissioned to front !

    ${param_list}  Create List  mtSBTSCabiTempMonitoring
    Set Test Variable  ${PARAM_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${reference_param_dict}  admin.Get Parameter By Distname  ${PARAM_PATH}  ${param_list}  connection=${bts_id}
    IF  '${reference_param_dict[0]['parameters']['mtSBTSCabiTempMonitoring']}'!='disabled'
        Logging With Timestamp
        ...  message=mtSBTSCabiTempMonitoring parameter is other than disabled, feature have to be deactivated before test start !
        ...  style=ERROR
        Fail  Feature mtSBTSCabiTempMonitoring is not disabled, please deactivate it before test start !
    ELSE
        Logging With Timestamp  message=mtSBTSCabiTempMonitoring parameter is disabled, as expected.
    END

Step 2: Enable SBTS Cabinet Thermal Monitoring And Verify Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Enable SBTS Cabinet Thermal Monitoring And Verify Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSCabiTempMonitoring is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  ${INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSCabiTempMonitoring recommissioned to ${INTERVAL}min !\nNow check if cells are onAir...\n

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp
        ...  message=Cells are not onAir after recommissioning! Parameter restoring and set test failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Cells are not onAir after recommissioning! Parameter restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_verification}  ${counter_length_enabled}  Run Keyword And Ignore Error  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_LIST}
    ...  min_range=20
    ...  max_range=50
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

    IF  '${counter_verification}'=='Fail'
        Logging With Timestamp  message=Counter verification failed! Parameter restoring and set test failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Counter verification failed! Parameter restoring and set test failed !
    ELSE
        Logging With Timestamp  message=Counter verification succeeded !
        ...  style=PASS
    END

Step 3: Collect And Verify Counters For The Same Interval
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Collect And Verify Counters For The Same Interval
    ...  style=STEP
    ...  frame=${TRUE}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_verification}  ${counterLenght_lastTimestamp}  Run Keyword And Ignore Error  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_LIST}
    ...  min_range=20
    ...  max_range=50
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

    IF  '${counter_verification}'=='Fail'
        Logging With Timestamp  message=Counter verification failed! Parameter restoring and set test failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Counter verification failed! Parameter restoring and set test failed !
    ELSE
        Logging With Timestamp  message=Counter verification succeeded !
        ...  style=PASS
    END

Step 4: Collect And Verify Counters For Another Interval
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4: Collect And Verify Counters For Another Interval
    ...  style=STEP
    ...  frame=${TRUE}

    IF  ${INTERVAL}==5
        ${NEW_INTERVAL}  Set Variable  15
    ELSE
        ${NEW_INTERVAL}  Set Variable  5
    END
    Set Test Variable  ${NEW_INTERVAL}

    Logging With Timestamp  message=mtSBTSCabiTempMonitoring is setting to another interval: ${NEW_INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  ${NEW_INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSCabiTempMonitoring recommissioned to ${NEW_INTERVAL}min !\nNow check if cells are onAir...\n

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameter restoring and set test failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${NEW_INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_verification}  ${counterLenght_lastTimestamp}  Run Keyword And Ignore Error  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_LIST}
    ...  min_range=20
    ...  max_range=50
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

    IF  '${counter_verification}'=='Fail'
        Logging With Timestamp  message=Counter verification failed! Parameter restoring and set test failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
        Fail  Counter verification failed! Parameter restoring and set test failed !
    ELSE
        Logging With Timestamp  message=Counter verification succeeded !
        ...  style=PASS
    END

    Logging With Timestamp  message=Waiting for disabling mtSBTSCabiTempMonitoring
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiTempMonitoring  update  disabled  connection=${bts_id}
