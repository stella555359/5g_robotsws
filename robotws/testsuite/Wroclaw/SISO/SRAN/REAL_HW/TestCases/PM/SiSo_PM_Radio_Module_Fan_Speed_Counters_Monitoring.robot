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
  ...  Checking if the mtSBTSRmodFan parameter is disabled.
  ...  Checking if all fans are found in measurements.
  ...
  ...  Step 2: Enable RMOD Fan Speed Counters
  ...  Setting mtSBTSRmodFan parameter to the given interval.
  ...  Checking if cells are onAir after recommissioning.
  ...  Waiting for full interval to start measurements.
  ...  Getting fan real-time measurements.
  ...  Comparing counters with real-time measurements.
  ...
  ...  Step 3: Try Another Interval
  ...  Setting mtSBTSRmodFan parameter to another interval.
  ...  Checking if cells are onAir after recommissioning.
  ...  Waiting for full interval to start measurements.
  ...  Getting fan real-time measurements.
  ...  Comparing counters with real-time measurements.
  ...
  ...  Step 4: Disable RMOD Fan Speed Counters
  ...  Setting mtSBTSRmodFan parameter to disabled.
  ...  Checking if cells are onAir after recommissioning.
  ...  Waiting interval to get PM counters.
  ...  Check if counter length and last timestamp are the same after disabling mtSBTSRmodFan.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 03.01.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot
Resource  ./../../Resources/Robot/STATE.robot
Resource  ./../../../resources/common_kw.robot

*** Variables ***

${INTERVAL}  5
&{RMOD_FAN_DICT}
${MEASUREMENT_TOLERANCE}  3    #  tolerance for measurements in %

*** Keywords ***
TC__SiSo_PM_Radio_Module_Fan_Speed_Counters_Monitoring
  Set Tags  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  step 1: Preconditions For RU Fan Speed Counters  ${bts_id}
  step 2: Enable RMOD Fan Speed Counters  ${bts_id}
  step 3: Try Another Interval For RMOD Fan Speed Counters  ${bts_id}
  step 4: Disable RMOD Fan Speed Counters  ${bts_id}

  [Teardown]  Common Test Teardown

Step 1: Preconditions For RU Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    admin.Get Measurements  connection=${bts_id}
    ${30_COUNTERS_LIST}  Create List  M40030C0  M40030C1  M40030C2
    Set Test Variable  ${30_COUNTERS_LIST}

    @{available_intervals}=  Create List  5  15  30  60  360  720  1440
    IF  '${INTERVAL}' in ${available_intervals}
        Logging With Timestamp    message=Given interval ${INTERVAL} is correct.
    ELSE
        Fail  Given interval ${INTERVAL} does't meet condition. Allowed values: 5 15 30 60 360 720 1440.
    END

    ${sum_of_fans_values}  Get Dictionary Values    ${RMOD_FAN_DICT}
    ${sum_of_fans}  Evaluate  sum([int(x) for x in ${sum_of_fans_values}])

    ${frm_info}  admin.Get Frm  connection=${bts_id}
    ${rmod_distname_fan_dict}  Create Dictionary
    FOR  ${rmod_sn}  ${fans}  IN ZIP  ${RMOD_FAN_DICT.keys()}  ${RMOD_FAN_DICT.values()}
        FOR  ${rmod}  IN  @{frm_info}
            IF  '${rmod_sn}' == '${rmod['serialNumber']}'
                Set To Dictionary  ${rmod_distname_fan_dict}  ${rmod['id']['runtime'].split('/')[-1]}  ${fans}
            ELSE
                Continue For Loop
            END
        END
    END

    ${param_list}  Create List  mtSBTSRMODFan
    Set Test Variable  ${PARAM_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${reference_param_dict}  admin.Get Parameter By Distname  ${PARAM_PATH}  ${param_list}  connection=${bts_id}
    IF  '${reference_param_dict[0]['parameters']['mtSBTSRMODFan']}'!='disabled'
        Logging With Timestamp
        ...  message=mtSBTSRMODFan parameter is other than disabled, feature have to be deactivated before test start !
        ...  style=ERROR
        Fail  Feature mtSBTSRMODFan is not disabled, please deactivate it before test start !
    ELSE
        Logging With Timestamp  message=mtSBTSRMODFan parameter is disabled.
    END

    ${fans_list}  Create List
    ${wrong_flag}  Set Variable  ${FALSE}
    ${measurements_for_dict_prepare}  admin.Get Measurements  measurement_type=realTime  connection=${bts_id}
    ${supported_rmods_list}  Get Dictionary Keys  ${rmod_distname_fan_dict}
    FOR  ${measurement}  IN  @{measurements_for_dict_prepare}
        FOR  ${distname}  ${value}  IN ZIP  ${measurement.keys()}  ${measurement.values()}
            IF  "FAN_SPEED" in "${distname}"
                    ${extracted_key_with_fan_name}  Evaluate  '/'.join("${distname}".split('/')[2:])
                    ${rmod_name}  Evaluate  '${extracted_key_with_fan_name}'.split('/')[0]
                    IF  '${rmod_name}' in ${supported_rmods_list}
                        Logging With Timestamp    message=New FAN was found: ${extracted_key_with_fan_name}
                        Append To List  ${fans_list}  ${extracted_key_with_fan_name}
                        IF  not ${value.isdigit()} or ${value}==0
                            Logging With Timestamp
                            ...  message=${rmod_name} has wrong initial value for fan speed -> ${value} !
                            ...  style=ERROR
                            ${wrong_flag}  Set Variable  ${TRUE}
                        ELSE
                            Logging With Timestamp
                            ...  message=Initial fan speed value is correct, everything is fine !
                            ...  style=DONE
                        END
                    ELSE
                        Continue For Loop
                    END
            END
        END
    END

    IF  ${wrong_flag}
        Fail  At least one fan speed value is not correct, make sure that RMOD has FAN(s) installed! Check logs and Real-time measurements !
    END

    ${fan_speed_dict}  Evaluate  ({i:[] for i in ${fans_list}})
    Log Dictionary    ${fan_speed_dict}
    ${found_fans_length}  Get Length  ${fan_speed_dict}

    IF  ${found_fans_length}==${sum_of_fans}
        Logging With Timestamp
        ...  message=All given by user fans are found in measurements !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Not all given by user fans are found in measurements !
        ...  style=ERROR
        Fail  Not all fans are found in measurements ! ${found_fans_length} != ${sum_of_fans}
    END

    Set Test Variable  ${FRM_INFO}
    Set Test Variable  ${RMOD_FAN_DICT}  ${rmod_distname_fan_dict}
    Set Test Variable  ${FAN_SPEED_DICT}  ${fan_speed_dict}

Step 2: Enable RMOD Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step2: Enable RMOD Fan Speed Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSRMODFan is setting to ${INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODFan  update  ${INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSRMODFan recommissioned to ${INTERVAL}min !\nNow check if cells are onAir...\n

    ${status}  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
        Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep-2} minutes to start measurements!
    ...  style=ONGOING
    Sleep  ${time_to_sleep-2} minutes

    Get Fan Real Time Measurements  ${INTERVAL}  ${bts_id}
    Sleep  2 minute

    ${counter_length_enabled}  Verify Counter And Return Length
    ...  counters_name=${30_COUNTERS_LIST}
    ...  min_range=0
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

    Compare Counters With Real Time Measurements  ${bts_id}

Step 3: Try Another Interval For RMOD Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step3: Try Another Interval
    ...  style=STEP
    ...  frame=${TRUE}

    ${FAN_SPEED_DICT}  Evaluate  {key: [] for key in ${FAN_SPEED_DICT}}
    Set Test Variable  ${FAN_SPEED_DICT}

    IF  ${INTERVAL}==5
        ${NEW_INTERVAL}  Set Variable  15
    ELSE
        ${NEW_INTERVAL}  Set Variable  5
    END

    Set Test Variable  ${NEW_INTERVAL}

    Logging With Timestamp  message=mtSBTSRMODFan is setting to ${NEW_INTERVAL}min !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODFan  update  ${NEW_INTERVAL}min  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSRMODFan recommissioned to ${NEW_INTERVAL}min !\nNow check if cells are onAir...\n

    ${status}  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  '${status}'=='False'
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
        Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${NEW_INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep-2} minutes to start measurements!
    ...  style=ONGOING
    Sleep  ${time_to_sleep-2} minutes

    Get Fan Real Time Measurements  ${NEW_INTERVAL}  ${bts_id}
    Sleep  2 minute

    ${counter_length_enabled_new_interval}  ${timestamp_enabled}  Verify Counter And Return Length
    ...  counters_name=${30_COUNTERS_LIST}
    ...  min_range=0
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    Set Test Variable  ${PM_LENGTH_ENABLED}  ${counter_length_enabled_new_interval}
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED}  ${timestamp_enabled}

    Compare Counters With Real Time Measurements  ${bts_id}

step 4: Disable RMOD Fan Speed Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step4: Disable RMOD Fan Speed Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSRMODFan is setting to disabled !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODFan  update  disabled  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSRMODFan recommissioned to disabled !\nNow check if cells are onAir...\n

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
    ...  counters_name=${30_COUNTERS_LIST}
    ...  min_range=0
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    ${pm_length_compare}=  Run Keyword And Return Status  Should Be Equal  ${PM_LENGTH_ENABLED}  ${counter_length_disabled}
    ${timestamp_compare}=  Run Keyword And Return Status  Should Be Equal  ${LAST_TIMESTAMP_ENABLED}  ${last_timestamp_disabled}

    IF  ${pm_length_compare} and ${timestamp_compare}
        Logging With Timestamp
        ...  message=Counter length and last timestamp are the same after disabling mtSBTSRMODFan ! Feature disabled successfully !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Counter length or last timestamp are different after disabling mtSBTSRMODFan ! Feature disabling failed !
        ...  style=ERROR
        Fail  Counter length or last timestamp are different after disabling mtSBTSRMODFan ! Feature disabling failed !
    END

Get Fan Real Time Measurements
    [Arguments]  ${measurement_interval}  ${bts_id}
    ${seconds}  Evaluate  60 - __import__('datetime').datetime.now().second
    Logging With Timestamp
    ...  message=Waiting for ${seconds+5} seconds to get to the beginning of the minute to start measurements !
    ...  style=ONGOING
    Sleep  ${seconds+5}s
    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${measurement_interval}
    Logging With Timestamp
    ...  message=Collectiong measurements and waiting for ${time_to_sleep} minutes to Get PM Counters !
    ...  style=ONGOING
    Logging With Timestamp
    ...  message=Verdict will be released at *${time_to_verdict}* !

    FOR  ${minute}  IN RANGE    1  ${time_to_sleep-1}
        Logging With Timestamp
        ...  message=Measurement number: ${minute} of ${time_to_sleep-2} ongoing...
        ...  style=ONGOING
        ${list_of_measurements}  admin.Get Measurements  measurement_type=realTime  connection=${bts_id}
        FOR  ${name}  IN  @{FAN_SPEED_DICT.keys()}
            ${match_element}  Evaluate  [d for d in ${list_of_measurements} if any('${name}' in key for key in d)][0]
            ${value}  Get Dictionary Values  ${match_element}
            Append To List  ${FAN_SPEED_DICT['${name}']}  ${value}[0]
            Logging With Timestamp    message=Fan speed for ${name} is ${value}[0]% of max fan speed!
        END
        Sleep  1 minute
        Logging With Timestamp
        ...  message=Measurement number: ${minute} of ${time_to_sleep-2} done !
        ...  style=DONE
    END

Compare Counters With Real Time Measurements
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Checking if counter values corresponds to the Real-time measurement, please wait...
    ...  style=ONGOING
    ${counters_name_for_api}  Evaluate  ','.join(${30_COUNTERS_LIST})
    ${pm_counter}  admin.Get Pm Counters  ${counters_name_for_api}  alias=${bts_id}
    ${rmod_fan}  admin.Get Rmod Fan Info  connection=${bts_id}
    FOR  ${fan}  ${list_of_values}  IN ZIP  ${FAN_SPEED_DICT.keys()}  ${FAN_SPEED_DICT.values()}
        TRY
            ${numeric_values}  Evaluate  list(map(int, ${list_of_values}))
            ${min_value}  Evaluate  min(${numeric_values})
            ${max_value}  Evaluate  max(${numeric_values})
            ${avg_value}  Evaluate  math.floor(sum(${numeric_values})/len(${numeric_values}))  modules=math
        EXCEPT
            Logging With Timestamp    message=Error during calculating min, max and avg values for ${fan} !
            Run Keyword And Continue On Failure  Fail  Error during calculating min, max and avg values for ${fan} !
            Continue For Loop
        END
        ${rmod_runtime_name}  Evaluate  '${fan}'.split('/')[0]
        ${fan_number}  Evaluate  '${fan}'.split('-')[-1]
        FOR  ${rmod}  IN  @{frm_info}
            IF  '${rmod_runtime_name}' in '${rmod['id']['runtime']}'
                ${rmod_distname}  Evaluate  '${rmod['id']['configuration']}'.split('/')[-1]
            ELSE
                Continue For Loop
            END
        END
        ${counter_per_rmod}  Find Key In Nested Dictionary  ${pm_counter}  ${rmod_distname}
        ${fan_counter_dict}  Find Key In Nested Dictionary  ${counter_per_rmod}[0]  FAN-${fan_number}
        ${min_counter_dict}  Find Key In Nested Dictionary  ${fan_counter_dict}[0]  M40030C0
        ${min_counter_values}  Get Dictionary Values  ${min_counter_dict[0]}
        ${max_counter_dict}  Find Key In Nested Dictionary  ${fan_counter_dict}[0]  M40030C1
        ${max_counter_values}  Get Dictionary Values  ${max_counter_dict[0]}
        ${avg_counter_dict}  Find Key In Nested Dictionary  ${fan_counter_dict}[0]  M40030C2
        ${avg_counter_values}  Get Dictionary Values  ${avg_counter_dict[0]}
        ${min_status}  Evaluate  abs(${min_value} - ${min_counter_values[-1]}) <= ${MEASUREMENT_TOLERANCE}
        ${max_status}  Evaluate  abs(${max_value} - ${max_counter_values[-1]}) <= ${MEASUREMENT_TOLERANCE}
        ${avg_status}  Evaluate  abs(${avg_value} - ${avg_counter_values[-1]}) <= ${MEASUREMENT_TOLERANCE}
        IF  ${min_status} and ${max_status} and ${avg_status}
            Logging With Timestamp
            ...  message=Counter value corresponds to the Real-time measurement for ${fan} with tolerance ${MEASUREMENT_TOLERANCE}%
            ...  style=DONE
            Logging With Timestamp
            ...  message=Counter values: MIN=${min_counter_values[-1]}, MAX=${max_counter_values[-1]}, AVG=${avg_counter_values[-1]}
            Logging With Timestamp
            ...  message=Real-time measurements: MIN=${min_value}, MAX=${max_value}, AVG=${avg_value}
        ELSE
            Logging With Timestamp
            ...  message=Values for ${fan} with tolerance ${MEASUREMENT_TOLERANCE}% are incorrect !
            ...  style=ERROR
            Logging With Timestamp
            ...  message=Counter values: MIN=${min_counter_values[-1]}, MAX=${max_counter_values[-1]}, AVG=${avg_counter_values[-1]}
            Logging With Timestamp
            ...  message=Real-time measurements: MIN=${min_value}, MAX=${max_value}, AVG=${avg_value}

            Run Keyword And Continue On Failure    Fail  Values for ${fan} are incorrect !
        END
    END

