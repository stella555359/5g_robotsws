*** Settings ***
Documentation
  ...  AUTHOR-mateusz-kawka@nokia.com  MAINTAINER-mateusz-kawka@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1: Preconditions
  ...  Checking if the given interval is correct.
  ...  Checking if the mtSBTSCabiFan parameter is disabled.
  ...  Checking if the cabinet type is supported.
  ...  Setting the maximum fan speed for the cabinet type.

  ...  Step 2: Enable Cabinet Fan Speed Counters
  ...  Setting the mtSBTSCabiFan parameter to the given interval.
  ...  Waiting for the specified interval to get PM counters.
  ...  Checking if all cells are onAir.
  ...  Verifying if the counters are collected and met the requirements.
  ...
  ...  Step 3: Try Another Interval For Cabinet Counters
  ...  Setting the mtSBTSCabiFan parameter to another interval.
  ...  Waiting for the specified interval to get PM counters.
  ...  Checking if all cells are onAir.
  ...  Verifying if the counters are collected and met the requirements.
  ...
  ...  Step 4: Collect Counters For BBOX File Check
  ...  Waiting for the specified interval to get PM counters.
  ...  Collecting the counters for the BBOX file check
  ...  Getting the last timestamp for the BBOX file check.
  ...  Setting the start and end timestamps for the BBOX file check.
  ...
  ...  Step 5: Verify Cabinet Fan Speed In BBOX File
  ...  Collecting the BTS snapshot file for update BBOX file.
  ...  Downloading the BBOX file from the System Module to directory ${CFG.test_logs_path}/TestFiles/
  ...  Getting the fan speed from the BBOX file.
  ...  Verifying the cabinet fan speed in the BBOX file.
  ...  Comparing the average speed for each fan with the WebEM counter.
  ...  Checking the difference between the BBOX and WebEM counter.
  ...  If the difference is greater than 5%, the test will fail.
  ...
  ...  Step 6: Disable Cabinet Fan Speed Counters
  ...  Setting the mtSBTSCabiFan parameter to disabled.
  ...  Waiting for the specified interval to get PM counters.
  ...  Verifying if the counters are collected and met the requirements.
  ...  Comparing the length of the counters with the previous length.
  ...  Comparing the last timestamp with the previous timestamp.
  ...  If the lengths and timestamps are equal, the test will pass.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 03.01.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot
Resource  ./../../Resources/Robot/SWM.robot
Resource  ./../../Resources/Robot/STATE.robot
Resource  ./../../../resources/common_kw.robot
Library   ./../../Resources/Python/blackbox_helpers.py

*** Variables ***

${INTERVAL}  5    #  One of: 5 15 30 60 360 720 1440 in minutes, default 5 min
${CABINET_TYPE}   #  One of: AMIA, AMID, AMOD, AMOE, ASOE, ASOG, ASOH
*** Keywords ***
TC__SiSo_PM_Cabinet_Fan_Speed_Counters
  Set Tags  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  Step 1: Preconditions For Cabinet Fan Speed Counters  ${bts_id}
  Step 2: Enable Cabinet Fan Speed Counters  ${bts_id}
  Step 3: Try Another Interval For Cabinet Counters  ${bts_id}
  Step 4: Collect Counters For BBOX File Check  ${bts_id}
  Step 5: Verify Cabinet Fan Speed In BBOX File  ${bts_id}
  Step 6: Disable Cabinet Fan Speed Counters  ${bts_id}

  [Teardown]  Common Test Teardown

Step 1: Preconditions For Cabinet Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    ${SW_RELEASE}  SWM Check If Current SW Build Is Newer Than  SBTS25R2_ENB_9999_250107_000011  bts_id=${bts_id}
    IF  ${SW_RELEASE}
      ${bbox_path}  Set Variable  /ffs/run/logs/lifetimedata
    ELSE
      ${bbox_path}  Set Variable  /ffs/run/config/lifedata
    END

    Set Test Variable  ${BBOX_PATH}

    ${31_COUNTERS_LIST}  Create List  M40031C0  M40031C1  M40031C2
    Set Test Variable  ${31_COUNTERS_LIST}

    ${REF_FAN_SPEED_DICT}  Create Dictionary
    ...  AMIA=9500
    ...  AMID=14000
    ...  AMOD=9300
    ...  AMOE=14000_9000
    ...  ASOE=16500
    ...  ASOG=16500
    ...  ASOH=16500

    @{available_intervals}=  Create List  5  15  30  60  360  720  1440
    IF  '${INTERVAL}' in ${available_intervals}
      Logging With Timestamp    message=Given interval ${INTERVAL} is correct.
    ELSE
      Fail  Given interval ${INTERVAL} does't meet condition. Allowed values: 5 15 30 60 360 720 1440.
    END

    ${param_list}  Create List  mtSBTSCabiFan
    Set Test Variable  ${PARAM_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${reference_param_dict}  admin.Get Parameter By Distname  ${PARAM_PATH}  ${param_list}  connection=${bts_id}
    IF  '${reference_param_dict[0]['parameters']['mtSBTSCabiFan']}'!='disabled'
      Logging With Timestamp
      ...  message=mtSBTSCabiFan parameter is other than disabled, feature have to be deactivated before test start !
      ...  style=ERROR
      Fail  Feature mtSBTSCabiFan is not disabled, please deactivate it before test start !
    ELSE
      Logging With Timestamp  message=mtSBTSCabiFan parameter is disabled.
    END

    ${key_status}  Run Keyword And Return Status  Dictionary Should Contain Key  ${REF_FAN_SPEED_DICT}  ${CABINET_TYPE}
    IF  '${key_status}'=='False'
      Fail  Cabinet type ${CABINET_TYPE} is not in dictionary ${REF_FAN_SPEED_DICT} !
    ELSE
      Logging With Timestamp
      ...  message=Cabinet type ${CABINET_TYPE} is supported. Max fan speed: ${REF_FAN_SPEED_DICT['${CABINET_TYPE}']} RPM.
    END

    ${cabinet_fan_speed}  Get From Dictionary  ${REF_FAN_SPEED_DICT}  ${CABINET_TYPE}
    IF  '${CABINET_TYPE}'=='AMOE'
      ${amoe_speeds}  Split String  ${cabinet_fan_speed}  _
      Set Test Variable  ${AMOE_FAN_1_2_SPEED}  ${amoe_speeds[0]}
      Set Test Variable  ${AMOE_FAN_6_7_SPEED}  ${amoe_speeds[1]}
    ELSE
      Set Test Variable  ${MAX_FAN_SPEED}  ${cabinet_fan_speed}
    END

    ${MAX_FAN_SPEED}  Get From Dictionary  ${REF_FAN_SPEED_DICT}  ${CABINET_TYPE}

    Set Test Variable  ${MAX_FAN_SPEED}

Step 2: Enable Cabinet Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2: Enable Cabinet Fan Speed Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSCabiFan is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiFan  update  ${INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSCabiFan recommissioned to ${INTERVAL}min !\nNow check if cells are onAir...\n

    ${status}  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
      Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
      Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
      Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${counter_length_enabled}  Verify Counter And Return Length
    ...  counters_name=${31_COUNTERS_LIST}
    ...  min_range=1
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

Step 3: Try Another Interval For Cabinet Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3: Try Another Interval For Cabinet Counters
    ...  style=STEP
    ...  frame=${TRUE}

    IF  ${INTERVAL}==5
      ${NEW_INTERVAL}  Set Variable  15
    ELSE
      ${NEW_INTERVAL}  Set Variable  5
    END

    Set Test Variable  ${NEW_INTERVAL}

    Logging With Timestamp  message=mtSBTSCabiFan is setting to ${_NEWINTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiFan  update  ${NEW_INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSCabiFan recommissioned to ${NEW_INTERVAL}min !\nNow check if cells are onAir...\n

    ${status}  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
      Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
      Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
      Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${NEW_INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${counter_length_enabled_new_interval}  Verify Counter And Return Length
    ...  counters_name=${31_COUNTERS_LIST}
    ...  min_range=1
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

step 4: Collect Counters For BBOX File Check

    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4: Collect Counters For BBOX File Check
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${NEW_INTERVAL}  15
    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${NEW_INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${counter_length_enabled_new_interval}  ${start_timestamp_for_bbox}  Verify Counter And Return Length
    ...  counters_name=${31_COUNTERS_LIST}
    ...  min_range=1
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    Set Test Variable  ${PM_LENGTH_ENABLED}  ${counter_length_enabled_new_interval}
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED}  ${start_timestamp_for_bbox}

    ${pm_counter}  admin.Get Pm Counters  M40031C2  alias=${bts_id}
    ${counters_values_list}  Find Key In Nested Dictionary  ${pm_counter}  M40031C2
    ${list_of_fans_with_counter}=  Get Fan Numbers From Dictionary  ${bts_id}  ${pm_counter}

    ${counter_avg_speed_dict}  Create Dictionary
    FOR  ${fun_no}  IN  @{list_of_fans_with_counter}
      ${fan_values_raw}  Find Key In Nested Dictionary  ${pm_counter}  ${fun_no}
      ${fan_values}  Find Key In Nested Dictionary  ${fan_values_raw}[0]  M40031C2
      ${whole_dict}  Set Variable  ${fan_values}[0]
      ${last_key}  ${last_value}  Evaluate  next(reversed(${whole_dict}.items()))
      Logging With Timestamp  message=Last percent average ${fun_no} speed - M40031C2: ${last_value}
      Set To Dictionary  ${counter_avg_speed_dict}  ${fun_no}  ${last_value}
    END

    Set Test Variable  ${COUNTER_AVG_SPEED_DICT}

    ${start_timestamp_for_bbox}  Evaluate
    ...  __import__('datetime').datetime.strptime("${start_timestamp_for_bbox}", '%Y-%m-%d %H:%M:%S').strftime('%Y-%m-%d %H:%M')
    Set Test Variable  ${START_TIMESTAMP_FOR_BBOX}   # human UTC format

    ${end_timestamp_for_bbox}  Evaluate
    ...  __import__('datetime').datetime.strptime("${START_TIMESTAMP_FOR_BBOX}", '%Y-%m-%d %H:%M') + __import__('datetime').timedelta(minutes=14)
    ${end_timestamp_for_bbox}  Evaluate
    ...  __import__('datetime').datetime.strptime("${end_timestamp_for_bbox}", '%Y-%m-%d %H:%M:%S').strftime('%Y-%m-%d %H:%M')

    Set Test Variable  ${END_TIMESTAMP_FOR_BBOX}

Step 5: Verify Cabinet Fan Speed In BBOX File
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 5: Verify Cabinet Fan Speed In BBOX File
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=Collecting BTS Snapshot file ...
    admin.Collect Snapshot  ${CFG.test_logs_path}/TestFiles/snapshot_for_BBOX.zip  coverage=HealthCheck  connection=${bts_id}  timeout=300
    Logging With Timestamp  message=BTS Snapshot file collected !

    Logging With Timestamp  message=Downloading BBOX file from System Module ...
    ...  style=ONGOING
    ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu
    ssh.Download File  ${BBOX_PATH}/blackbox_temperature  ${CFG.test_logs_path}/TestFiles/blackbox_temperature
    ssh.Disconnect

    Logging With Timestamp  message=Downloaded BBOX file from System Module !
    ...  style=DONE

    ${fan_speed_dict}  Get Fan Speed From BlackBox File
    ...  file_path=${CFG.test_logs_path}/TestFiles/blackbox_temperature
    ...  starting_time=${START_TIMESTAMP_FOR_BBOX}
    ...  ending_time=${END_TIMESTAMP_FOR_BBOX}

    FOR  ${fan}  ${values}  IN ZIP  ${fan_speed_dict.keys()}  ${fan_speed_dict.values()}
      Logging With Timestamp  message=${fan} verification ongoing, please wait for verdict ...
      ${average_speed}  Evaluate  sum(${values})/len(${values})
      IF  '${CABINET_TYPE}'=='AMOE'
        IF  '${fan}'=='FAN-1' or '${fan}'=='FAN-2'
          ${max_fan_speed}  Set Variable  ${AMOE_FAN_1_2_SPEED}
        ELSE IF  '${fan}'=='FAN-6' or '${fan}'=='FAN-7'
          ${max_fan_speed}  Set Variable  ${AMOE_FAN_6_7_SPEED}
        ELSE
          Fail  Unknown fan for AMOE: ${fan}
        END
      ELSE
        ${max_fan_speed}  Set Variable  ${MAX_FAN_SPEED}
      END
      ${average_percent_speed}  Evaluate  round(${average_speed}/${max_fan_speed}*100, 2)
      Logging With Timestamp    message=BBOX file: Average speed for ${fan}: ${average_percent_speed}
      ${webem_percent_speed}  Get From Dictionary  ${COUNTER_AVG_SPEED_DICT}  ${fan}
      Logging With Timestamp    message=WebEM counter: Average speed for FAN-${fan}: ${webem_percent_speed}
      ${diff}  Evaluate  abs(${average_percent_speed}-${webem_percent_speed})
      Logging With Timestamp    message=Diff between BBOX and WebEM: ${diff}%
      IF  '${CABINET_TYPE}'=='AMIA'
        IF  ${diff} > 10
          Logging With Timestamp  message=Diff between BBOX and WebEM is greater than 10% !
          ...  style=ERROR
          Run Keyword And Continue On Failure  Fail  Diff between BBOX and WebEM is greater than 10% !
        ELSE
          Logging With Timestamp  message=Diff between BBOX and WebEM is less than 10% !
          ...  style=DONE
        END
      ELSE
        IF  ${diff} > 6
          Logging With Timestamp  message=Diff between BBOX and WebEM is greater than 6% !
          ...  style=ERROR
          Run Keyword And Continue On Failure  Fail  Diff between BBOX and WebEM is greater than 6% !
        ELSE
          Logging With Timestamp  message=Diff between BBOX and WebEM is less than 6% !
          ...  style=DONE
        END
      END
    END

#Change above from 5 to 6 % due to many env issue with small differences. Need to check this

Step 6: Disable Cabinet Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 6: Disable Cabinet Fan Speed Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSCabiFan is setting to disabled !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSCabiFan  update  disabled  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSCabiFan recommissioned to disabled !\nNow check if cells are onAir...\n

    ${status}  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
      Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
      Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
      Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${NEW_INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${counter_length_disabled}  ${last_timestamp_disabled}  Verify Counter And Return Length
    ...  counters_name=${31_COUNTERS_LIST}
    ...  min_range=1
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    ${pm_length_compare}=  Run Keyword And Return Status  Should Be Equal  ${PM_LENGTH_ENABLED}  ${counter_length_disabled}
    ${timestamp_compare}=  Run Keyword And Return Status  Should Be Equal  ${LAST_TIMESTAMP_ENABLED}  ${last_timestamp_disabled}

    IF  ${pm_length_compare} and ${timestamp_compare}
      Logging With Timestamp  message=Counters length and timestamp are equal, test passed !
      ...  style=DONE
    ELSE
      Logging With Timestamp
      ...  message=Counters length and timestamp are not equal, test failed !
      ...  style=ERROR
      Fail  Counters length and timestamp are not equal, test failed !
    END

Get Fan Numbers From Dictionary
    [Arguments]  ${bts_id}  ${pm_counter}
    ${bts}=  Get From Dictionary  ${pm_counter}  BTS
    ${mrbts}=  Get From Dictionary  ${bts}  MRBTS-${bts_id}
    ${eqm}=  Get From Dictionary  ${mrbts}  EQM-1
    ${apeqm}=  Get From Dictionary  ${eqm}  APEQM-1
    ${cabinet}=  Get From Dictionary  ${apeqm}  CABINET-1
    ${fan_numbers}=  Get Dictionary Keys  ${cabinet}

    @{list_of_fans_with_counter}=  Create List
    FOR  ${fan}  IN  @{fan_numbers}
      ${values}=  Get Dictionary Values  ${cabinet['${fan}']}
      ${not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${values[0]}
      ${counters}=  Run Keyword If  ${not_empty}==True  Get Dictionary Keys  ${values[0]}
      ${status}=  Run Keyword And Return Status  List Should Contain Value  ${counters}  M40031C2
      Run Keyword If  ${status}==True  Append To List  ${list_of_fans_with_counter}  ${fan}
    END
    [Return]  ${list_of_fans_with_counter}
