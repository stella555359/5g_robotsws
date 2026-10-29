*** Settings ***
Documentation
  ...  AUTHOR-malgorzata.piecyk-celuch.com  MAINTAINER-malgorzata.piecyk-celuch.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1: Preconditions SMOD Internal Temperature Counters
  ...  Checking if the given interval is correct.
  ...  Checking if parameter mtSBTSSMODTemperature is disabled.
  ...
  ...  Step 2: Enable SBTS SMOD Thermal Monitoring And Verify Counters
  ...  Setting measurement interval of mtSBTSSMODTemperature.
  ...  Checking if all cells are onAir.
  ...  Getting counters after set interval.
  ...  Verify timestamps correctness and values of counters are in the range 30-100.
  ...
  ...  Step 3: Collect And Verify Counters For Another Interval
  ...  Setting another measurement interval of mtSBTSSMODTemperature.
  ...  Check if all cells are onAir.
  ...  Getting counters after set interval.
  ...  Verify timestamps correctness and values of counters are in the range 30-100.
  ...
  ...  Step 4: Disable SBTS SMOD Thermal Monitoring And Verify Counters
  ...  Disable parameter mtSBTSSMODTemperature.
  ...  Check if all cells are onAir.
  ...  Getting counters after set interval in previous step.
  ...  Check new timestamp and counters values are reported.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 11.01.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot
Resource  ./../../../resources/common_kw.robot

*** Variables ***
${INTERVAL}  15

*** Keywords ***
TC__SiSo_PM_SMOD_Internal_Temperature_Counters
  Set Tags  AUTHOR-malgorzata.piecyk-celuch.com  MAINTAINER-malgorzata.piecyk-celuch.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Preconditions SMOD Internal Temperature Counters  ${bts_id}
  Step 2: Enable SBTS SMOD Thermal Monitoring And Verify Counters  ${bts_id}
  Step 3: Collect And Verify Counters For Another Interval  ${bts_id}
  Step 4: Disable SBTS SMOD Thermal Monitoring And Verify Counters  ${bts_id}
  [Teardown]  Common Test Teardown

Step 1: Preconditions SMOD Internal Temperature Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions SMOD Internal Temperature Counters
    ...  style=STEP
    ...  frame=${TRUE}

    ${COUNTERS_LIST}  Create List  M40009C0
    Set Test Variable  ${COUNTERS_LIST}

    @{available_intervals}  Create List  5  15  30  60  360  720  1440
    IF  '${INTERVAL}' in ${available_intervals}
        Logging With Timestamp  message=Given interval ${INTERVAL} is correct.
    ELSE
        Fail  Given interval ${INTERVAL} does't meet condition. Allowed values: 5 15 30 60 360 720 1440.
    END

    ${param_list}  Create List  mtSBTSSMODTemperature
    Set Test Variable  ${PARAM_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${reference_param_dict}  admin.Get Parameter By Distname  ${PARAM_PATH}  ${param_list}  connection=${bts_id}
    IF  '${reference_param_dict[0]['parameters']['mtSBTSSMODTemperature']}'!='disabled'
        Logging With Timestamp
        ...  message=mtSBTSSMODTemperature parameter is other than disabled, feature have to be deactivated before test start !
        ...  style=ERROR
        Fail  Feature mtSBTSSMODTemperature is not disabled, please deactivate it before test start !
    ELSE
        Logging With Timestamp  message=mtSBTSSMODTemperature parameter is disabled, as expected.
    END

Step 2: Enable SBTS SMOD Thermal Monitoring And Verify Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Enable SBTS SMOD Thermal Monitoring And Verify Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSSMODTemperature is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  ${INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSSMODTemperature recommissioned to ${INTERVAL}min !\nNow check if cells are onAir...\n

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp
        ...  message=Cells are not onAir after recommissioning! Parameter restoring and set test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after recommissioning! Parameter restoring and set test failed!
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  disabled  connection=${bts_id}
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
    ...  min_range=30
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

    IF  '${counter_verification}'=='Fail'
        Logging With Timestamp  message=Counter verification failed! Parameter restoring and set test failed !
        ...  style=ERROR
        Fail  Counter verification failed! Parameter restoring and set test failed !
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  disabled  connection=${bts_id}
    ELSE
        Logging With Timestamp  message=Counter verification succeeded !
        ...  style=PASS
    END

Step 3: Collect And Verify Counters For Another Interval
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Collect And Verify Counters For Another Interval
    ...  style=STEP
    ...  frame=${TRUE}

    IF  ${INTERVAL}==5
        ${NEW_INTERVAL}  Set Variable  15
    ELSE
        ${NEW_INTERVAL}  Set Variable  5
    END
    Set Test Variable  ${NEW_INTERVAL}

    Logging With Timestamp  message=mtSBTSSMODTemperature is setting to another interval: ${NEW_INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  ${NEW_INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSSMODTemperature recommissioned to ${NEW_INTERVAL}min !\nNow check if cells are onAir...\n

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameter restoring and set test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  disabled  connection=${bts_id}
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
    ...  min_range=30
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    Set Test Variable  ${PM_LENGTH_ENABLED}  ${counterLenght_lastTimestamp}[0]
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED}  ${counterLenght_lastTimestamp}[1]

    IF  '${counter_verification}'=='Fail'
        Logging With Timestamp  message=Counter verification failed! Parameter restoring and set test failed !
        ...  style=ERROR
        Fail  Counter verification failed! Parameter restoring and set test failed !
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  disabled  connection=${bts_id}
    ELSE
        Logging With Timestamp  message=Counter verification succeeded !
        ...  style=PASS
    END

Step 4: Disable SBTS SMOD Thermal Monitoring And Verify Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4: Disable SBTS SMOD Thermal Monitoring And Verify Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSSMODTemperature is setting to disabled !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSSMODTemperature  update  disabled  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSSMODTemperature recommissioned to disabled !\nNow check if cells are onAir...\n

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${onair_status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Test failed !
        ...  style=ERROR
        Fail  Cells are not onAir after recommissioning!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${NEW_INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_length_disabled}  ${last_timestamp_disabled}  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_LIST}
    ...  min_range=30
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    ${pm_length_compare}  Run Keyword And Return Status  Should Be Equal  ${PM_LENGTH_ENABLED}  ${counter_length_disabled}
    ${timestamp_compare}  Run Keyword And Return Status  Should Be Equal  ${LAST_TIMESTAMP_ENABLED}  ${last_timestamp_disabled}

    IF  ${pm_length_compare} and ${timestamp_compare}
        Logging With Timestamp  message=Counters length and timestamps have not changed, test passed !
        ...  style=PASS
    ELSE
        Logging With Timestamp
        ...  message=Counters length and timestamps have changed, test failed !
        ...  style=ERROR
        Fail  Counters length and timestamps have changed, test failed !
    END
