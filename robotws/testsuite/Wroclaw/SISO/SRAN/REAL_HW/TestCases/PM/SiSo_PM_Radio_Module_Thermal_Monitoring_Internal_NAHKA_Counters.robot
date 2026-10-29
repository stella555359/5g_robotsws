*** Settings ***
Documentation
  ...  AUTHOR-mateusz-kawka@nokia.com  MAINTAINER-mateusz-kawka@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  Step 1: Preconditions For Radio Module Temperature Counters
  ...  Checking if RMOD with given serial number is present in HW configuration, if not test fail.
  ...  Checking if mtSBTSRMODTemperature parameter is disabled, if not test fail.
  ...  Getting RMOD distname.
  ...
  ...  Step 2: Enable Radio Module Temperature Counters
  ...  Setting mtSBTSRMODTemperature parameter to given interval.
  ...  Checking if cells are onAir after recommissioning.
  ...
  ...  Step 3: Read Temperatures From RF Logs
  ...  Waiting for given interval to start measurements.
  ...  Collecting temperature from RF logs for given interval.
  ...
  ...  Step 4: Compare Counter With RF Log Temperature
  ...  Collecting PM Counter M40008C1.
  ...  Comparing temperature from RF logs with PM counter.
  ...
  ...  Step 5: Check Temperature Range In RD BTS File
  ...  Downloading RD BTS file.
  ...  Checking if temperature ranges are correct and corresponds to given interval.
  ...
  ...  Step 6: Disable Radio Module Temperature Counters
  ...  Setting mtSBTSRMODTemperature parameter to disabled.
  ...  Checking if cells are onAir after disabling.
  ...  Waiting for given interval to Get PM Counters.
  ...  Checking if counter length and last timestamp are the same after disabling mtSBTSRMODTemperature.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 28.11.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PM.robot
Resource  ./../../../resources/common_kw.robot
Library   ./../../Resources/Python/xml_helpers.py  WITH NAME  xml_helpers

*** Variables ***

${RMOD_SERIAL_NUMBER}
${MTSBTSRMODTEMPERATURE_INTERVAL}  5
${TEMPERATURE_TOLERANCE}  1  # celsius degree

*** Keywords ***
TC__SiSo_PM_Radio_Module_Thermal_Monitoring_Internal_NAHKA_Counters
  Set Tags  AUTHOR-mateusz.kawka@nokia.com  MAINTAINER-mateusz.kawka@nokia.com
  Common Test Setup
  ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
  step 1: Preconditions For Radio Module Temperature Counters  ${bts_id}
  step 2: Enable Radio Module Temperature Counters  ${bts_id}
  step 3: Read Temperatures From RF Logs
  step 4: Compare Counter With RF Log Temperature  ${bts_id}
  step 5: Check Temperature Range In RD BTS File  ${bts_id}
  step 6: Disable Radio Module Temperature Counters  ${bts_id}

  [Teardown]  Common Test Teardown

Step 1: Preconditions For Radio Module Temperature Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step1: Preconditions For Radio Module Temperature Counters
    ...  style=STEP
    ...  frame=${TRUE}

    ${8_COUNTERS_LIST}  Create List  M40008C1
    Set Test Variable  ${8_COUNTERS_LIST}

    @{available_intervals}=  Create List  5  15  30  60  360  720  1440
    IF  '${MTSBTSRMODTEMPERATURE_INTERVAL}' in ${available_intervals}
        Logging With Timestamp  message=Given interval ${MTSBTSRMODTEMPERATURE_INTERVAL} is correct.
    ELSE
        Fail  Given interval ${MTSBTSRMODTEMPERATURE_INTERVAL} does't meet condition. Allowed values: 5 15 30 60 360 720 1440.
    END

    ${param_list}  Create List  mtSBTSRMODTemperature
    Set Test Variable  ${PARAM_PATH}  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1

    ${reference_param_dict}  admin.Get Parameter By Distname  ${PARAM_PATH}  ${param_list}  connection=${bts_id}
    IF  '${reference_param_dict[0]['parameters']['mtSBTSRMODTemperature']}'!='disabled'
        Logging With Timestamp
        ...  message=mtSBTSRMODTemperature parameter is other than disabled, feature have to be deactivated before test start !
        ...  style=ERROR
        Fail  Feature mtSBTSRMODTemperature is not disabled, please deactivate it before test start !
    ELSE
        Logging With Timestamp  message=mtSBTSRMODTemperature parameter is disabled.
    END

    ${frm_info}  admin.Get Frm  connection=${bts_id}
    FOR  ${rmod}  IN  @{frm_info}
        IF  '${RMOD_SERIAL_NUMBER}' in '${rmod['serialNumber']}'
            ${rmod_distname}  Evaluate  '${rmod['id']['configuration']}'.split('/')[-1]
        ELSE
            Continue For Loop
        END
    END

    Set Test Variable  ${RMOD_DISTNAME}

Step 2: Enable Radio Module Temperature Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step2: Enable Radio Module Temperature Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSRMODTemperature is setting to ${MTSBTSRMODTEMPERATURE_INTERVAL}min !
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODTemperature  update  ${MTSBTSRMODTEMPERATURE_INTERVAL}min
    ...  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSRMODTemperature recommissioned to ${MTSBTSRMODTEMPERATURE_INTERVAL}min !
    ...  style=DONE

    Logging With Timestamp  message=Now check if cells are onAir...
    ...  style=ONGOING
    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  not ${status}
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
        Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
        ...  style=DONE
    END

step 3: Read Temperatures From RF Logs
    Logging With Timestamp
    ...  message=Step3: Read Temperatures From RF Logs
    ...  style=STEP
    ...  frame=${TRUE}

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${MTSBTSRMODTEMPERATURE_INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep-3} minutes to start measurements!
    ...  style=ONGOING
    Sleep  ${time_to_sleep-3} minutes
    ${seconds}  Evaluate  60 - __import__('datetime').datetime.now().second
    Sleep  ${seconds+5}s

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${MTSBTSRMODTEMPERATURE_INTERVAL}
    Logging With Timestamp
    ...  message=Collecting temperature from RF logs for ${time_to_sleep} minutes !
    ...  style=ONGOING

    ${module_temperature_list}  Create List
    FOR  ${minute}  IN RANGE  1  ${time_to_sleep-1}
        Logging With Timestamp
        ...  message=RF logs temperature measurement number: ${minute} of ${time_to_sleep-2} ongoing...
        ...  style=ONGOING
        ${all_sensors_temperature_dict}  radio.Get Sensors Temperature From RF Logs
        ...  ru_serial_number=${RMOD_SERIAL_NUMBER}
        ${module_temp}  Get From Dictionary  ${all_sensors_temperature_dict}  MODULE
        Append To List  ${module_temperature_list}  ${module_temp}
        Logging With Timestamp
        ...  message=Temperature in ${minute} minute: ${module_temp} Celsius
        Sleep  1 minute
        Logging With Timestamp
        ...  message=Measurement number: ${minute} of ${time_to_sleep-2} done !
        ...  style=DONE
    END

    ${max_rflog_temperature}  Evaluate  max(${module_temperature_list})

    Logging With Timestamp  message=Collecting is done, maximum temperature: ${max_rflog_temperature} Celsius
    ...  style=DONE
    Set Test Variable  ${MAX_RFLOG_TEMPERATURE}

step 4: Compare Counter With RF Log Temperature
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step4: Compare Counter With RF Log Temperature
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=Collecting PM Counter M40008C1, please wait...
    ...  style=ONGOING
    Sleep  30s
    ${pm_counter}  admin.Get Pm Counters  ${8_COUNTERS_LIST}[0]  alias=${bts_id}
    ${counter_per_rmod}  Find Key In Nested Dictionary  ${pm_counter}  ${RMOD_DISTNAME}
    ${counter_per_rmod}  Find Key In Nested Dictionary  ${counter_per_rmod[0]}  ${8_COUNTERS_LIST}[0]
    ${last_counter_values}  Get Dictionary Values  ${counter_per_rmod[0]}

    ${max_counter_temperature}  Set Variable  ${last_counter_values[-1]}

    Logging With Timestamp  message=PM Counter M40008C1 collected ! Counter value: ${max_counter_temperature}
    ...  style=DONE

    ${is_temp_between}  Evaluate  abs(${max_counter_temperature} - ${MAX_RFLOG_TEMPERATURE}) <= ${TEMPERATURE_TOLERANCE}

    IF  not ${is_temp_between}
        Logging With Timestamp
        ...  message=Temperature difference between RF Logs and PM counter is too high !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODTemperature  update  disabled  connection=${bts_id}
        Fail  Temperature difference between RF Logs and PM counter is too high !
    ELSE
        Logging With Timestamp
        ...  message=Temperature difference between RF Logs and PM counter is in tolerance range: ${TEMPERATURE_TOLERANCE} Celsius
        ...  style=DONE
    END

    ${pm_length_enabled}  ${last_timestamp_enabled}  Verify Counter And Return Length
    ...  counters_name=${8_COUNTERS_LIST}
    ...  min_range=20
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    Set Test Variable  ${PM_LENGTH_ENABLED}
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED}

step 5: Check Temperature Range In RD BTS File
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step5: Check Temperature Range In RD BTS File
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=Downloading RD BTS file ...
    ...  style=ONGOING

#    ${minutes}  Get Time  min
#    ${minutes}  Convert To Integer  ${minutes}
#    ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu
#    IF  ${minutes} > ${MTSBTSRMODTEMPERATURE_INTERVAL}
#        ssh.Send Command  command=ls -1 /tmp | grep -iE '^RD\.BTS.*\.raw\.gz$' | sort | tail -n 1
#    ELSE
#        ssh.Send Command  command=ls -1 /tmp | grep -iE '^RD\.BTS.*\.xml\.gz$' | sort | tail -n 1
#    END

    ssh.Connect To  192.168.255.1  toor4nsn  oZPS0POrRieRtu
    ssh.Send Command  command=ls -1 /tmp | grep -iE '^RD\.BTS.*\.gz$' | sort | tail -n 1

    ${file_name}  ssh.Read Output
    ${file_name}  Set Variable  ${file_name.strip()}
    ssh.Download File  /tmp/${file_name}  ${TEST_LOGS_PATH}/BTSFiles/${bts_id}/${file_name}
    ssh.Disconnect
    ${rc}  OperatingSystem.Run And Return Rc  gunzip -f ${TEST_LOGS_PATH}/BTSFiles/${bts_id}/${file_name}

    IF  ${rc} != 0
        Logging With Timestamp
        ...  message=File ${file_name} unzipping failed !
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODTemperature  update  disabled  connection=${bts_id}
        Fail  File ${file_name} unzipping failed !
    ELSE
        Logging With Timestamp
        ...  message=File ${file_name} unzipping done !
        ...  style=DONE
    END
    ${temp_ranges}  Xml_helpers.Find Temperature Range By Rmod DistName
    ...  file_path=${TEST_LOGS_PATH}/BTSFiles/${bts_id}/${file_name.removesuffix(".gz")}
    ...  dn_partial_value=${RMOD_DISTNAME}

    ${values}  Get Dictionary Values  ${temp_ranges}
    ${sum_of_values}  Evaluate  sum(${values})

    IF  ${sum_of_values} == ${MTSBTSRMODTEMPERATURE_INTERVAL}
        Logging With Timestamp
        ...  message=Temperature ranges are correct and corresponds to ${MTSBTSRMODTEMPERATURE_INTERVAL} minutes interval!
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Temperature ranges are incorrect and doesn't corresponds to ${MTSBTSRMODTEMPERATURE_INTERVAL} minutes interval!
        ...  style=ERROR
        admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODTemperature  update  disabled  connection=${bts_id}
        Fail  Temperature ranges are incorrect and doesn't corresponds to ${MTSBTSRMODTEMPERATURE_INTERVAL} minutes
    END

step 6: Disable Radio Module Temperature Counters
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=step 6: Disable Radio Module Temperature Counters
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  message=mtSBTSRMODTemperature is setting to disabled !
    admin.Perform Parameter Recommissioning  ${PARAM_PATH}  mtSBTSRMODTemperature  update  disabled  connection=${bts_id}
    Logging With Timestamp  message=mtSBTSRMODTemperature recommissioned to disabled !

    ${status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${bts_id}
    IF  not ${status}
        Logging With Timestamp  message=Cells are not onAir after recommissioning! Parameters restoring and set test failed !
        Fail  Cells are not onAir after recommissioning! Parameters restoring and set test failed!
    ELSE
        Logging With Timestamp  message=All cells are onAir !
    END

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${MTSBTSRMODTEMPERATURE_INTERVAL}
    Logging With Timestamp  message=Waiting for ${time_to_sleep} minutes to Get PM Counters ! ${\n}Verdict will be released at *${time_to_verdict}* !
    Sleep  ${time_to_sleep} minutes

    ${counter_length_disabled}  ${last_timestamp_disabled}  Verify Counter And Return Length
    ...  counters_name=${8_COUNTERS_LIST}
    ...  min_range=20
    ...  max_range=100
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    ${pm_length_compare}=  Run Keyword And Return Status  Should Be Equal  ${PM_LENGTH_ENABLED}  ${counter_length_disabled}
    ${timestamp_compare}=  Run Keyword And Return Status  Should Be Equal  ${LAST_TIMESTAMP_ENABLED}  ${last_timestamp_disabled}

    IF  ${pm_length_compare} and ${timestamp_compare}
        Logging With Timestamp
        ...  message=Counter length and last timestamp are the same after disabling mtSBTSRMODTemperature ! Feature disabled successfully !
        ...  style=DONE
    ELSE
        Logging With Timestamp
        ...  message=Counter length or last timestamp are different after disabling mtSBTSRMODTemperature ! Feature disabling failed !
        ...  style=ERROR
        Fail  Counter length or last timestamp are different after disabling mtSBTSRMODTemperature ! Feature disabling failed !
    END