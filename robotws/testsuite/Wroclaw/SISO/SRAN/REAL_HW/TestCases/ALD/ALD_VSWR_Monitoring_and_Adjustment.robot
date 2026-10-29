*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...
...  *****************
...  Basic information
...  *****************
...  This test case verifies the VSWR (Voltage Standing Wave Ratio) monitoring and alarm threshold adjustment functionalities.
...  It performs the following actions for each specified radio unit:
...  Step 1: Artificial Load activation
...  Step 2: Monitor VSWR values Site View
...  Step 3: Antenna Online Monitoring and monitor VSWR values in Antenna Online Monitoring
...  Step 4: Adjust VSWR parameters for alarms’ thresholds
...  Step 5: Restore VSWR parameters for alarms’ thresholds
...  Step 6: Modify vswrAlarmTxPwrThreshold parameter
...  Step 7: Remove vswrAlarmTxPwrThreshold parameter
...  Step 8: Artificial Load deactivation
...
...  ******************
...  History of changes
...  ******************
...  - 04.10.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot


*** Variables ***
${vswr_allowed_max_value}=  3.5  # Maximum allowed VSWR value during monitoring.
${vswr_allowed_min_value}=  1.5  # Minimum allowed VSWR value for generating new alarm thresholds.
${vswr_alarm_minor_step}=  0.1  # Step increment for generating new VSWR alarm thresholds.
${vswrAlarmTxPwrThreshold_min_value}=  25  # Minimum value for the vswrAlarmTxPwrThreshold parameter.
${vswrAlarmTxPwrThreshold_max_value}=  48  # Maximum value for the vswrAlarmTxPwrThreshold parameter.
${vswrAlarmTxPwrThreshold_step}=  0.1  # Step increment for generating a new vswrAlarmTxPwrThreshold value.
${vswrMajorThreshold}=  29  # Default major threshold value for VSWR.


*** Keywords ***
ALD_VSWR_Monitoring_and_Adjustment
  Common Test Setup  tools_to_setup=syslog_ADMIN
  Logging With Timestamp
  ...  message=PM_VSWR handling will be executed
  ...  style=TC
  FOR  ${radio_unit}  IN  @{CUSTOM_RADIO_UNIT_LIST}
    Precondition For PM_VSWR handling Test  ${radio_unit}
    Step 1 Artificial Load activation
    Step 2 Monitor VSWR values Site View
    Step 3 Antenna Online Monitoring and monitor VSWR values in Antenna Online Monitoring
    Step 4 Adjust VSWR parameters for alarms’ thresholds
    Step 5 Restore VSWR parameters for alarms’ thresholds
    Step 6 Modify vswrAlarmTxPwrThreshold parameter
    Step 7 Remove vswrAlarmTxPwrThreshold parameter
    Step 8 Artificial Load deactivation
  END
  [Teardown]  Common Test Teardown

Precondition For PM_VSWR handling Test
  [Arguments]  ${radio_unit}
  [Documentation]
  ...  Description:
  ...  Precondition setup for RU resiliency test.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | radio_unit             | yes  | Radio unit serial number                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Precondition For PM_VSWR handling Test
  ...  style=STEP
  ...  frame=${TRUE}
  Set Test Variable  ${RADIO_UNIT}  ${radio_unit}
  ${bts_id}=  Get From Dictionary  ${CFG.RF_INFO['${radio_unit}']}  scf_btsid_primary
  ${scf_dist_name_primary}=  Get From Dictionary  ${CFG.RF_INFO['${radio_unit}']}  scf_dist_name_primary
  Set Test Variable  ${BTS_ID}  ${bts_id}
  Set Test Variable  ${RU_UNIT_DISTNAME}  ${scf_dist_name_primary}
  &{antennas}=  admin.Get Antennas  connection=${BTS_ID}
  &{rmods_list}=  admin.Get Radio List  connection=${BTS_ID}
  ${ru_runtime_number}=  Split String From Right
  ...  string=${RU_UNIT_DISTNAME}
  ...  separator=/
  ...  max_split=1
  FOR  ${rmod_type}  IN  @{rmods_list.radioModules}
    FOR  ${rmod_id}  IN  @{rmods_list.radioModules.${rmod_type}}
      ${status}=  Run Keyword And Return Status  Evaluate  '${ru_runtime_number[1]}' in '${rmod_id.id.configuration}'
      Logging With Timestamp
      ...  message=Found RU runtime id: ${rmod_id.id.runtime}
      Log  ${rmod_id.id.configuration}
      Log  ${rmod_id}
      IF  ${status}
        @{RU_ID}=  Evaluate  [subdict['id']['runtime'] for subdict in $rmod_id.antenaUsageInfo]
        @{RU_ID_CONFIGURATION}=  Evaluate  [subdict['id']['configuration'] for subdict in $rmod_id.antenaUsageInfo]
        Set Test Variable  ${RU_ID}  ${RU_ID}
        Set Test Variable  ${RU_ID_CONFIGURATION}  ${RU_ID_CONFIGURATION}
      END
      Exit For Loop If  ${status}
    END
    Exit For Loop If  ${status}
  END
  Logging With Timestamp
  ...  message=Tested RU internal id: ${RU_ID} , configuration id:${RU_ID_CONFIGURATION}
  ${scf_node_file}=  admin.Get Current Scf File
  ...  local_dir_path=${TEST_LOGS_DIR_PATH}/BTSFiles/${bts_id}/
  ...  file_name=pretest_scf.xml
  ...  export_type=configurationAndRuntimeObjects
  ...  connection=${BTS_ID}
  ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
  Logging With Timestamp
  ...  message=SCF before testcase file saved to: ${scf_node_file}
  ...  style=DONE
  Set Test Variable  ${SCF_NODE_FILE}  ${scf_node_file}
  Logging With Timestamp
  ...  message=Precondition For PM_VSWR handling Test finished
  ...  style=DONE
  ...  frame=${TRUE}

Step 1 Artificial Load activation
  [Documentation]  Description: Activates an artificial load on cells related to the specified radio unit.
  ...  ...  This is done by setting the 'targetTotalLoad' parameter to 100 for all related NRCELLs.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Step 1 Artificial Load activation started
  ...  style=STEP
  ...  frame=${TRUE}
  ${ru_unit_distname}=  Get From Dictionary  ${CFG.RF_INFO['${RADIO_UNIT}']}  scf_dist_name_primary
  @{nrcel_cell_list}=  Get From Dictionary  ${CFG.RF_INFO['${RADIO_UNIT}']['NRCEL']}  scf_cellid_primary
  &{nrcell_targetTotalLoad_dict}=  Create Dictionary
  FOR  ${cell}  IN  @{nrcel_cell_list}
    ${cell_value}=  Run Keyword And Ignore Error    xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'NRCELL') and contains (@distName, 'NRCELL-${cell}')]/p[@name="targetTotalLoad"]
    IF  '${cell_value[0]}'=='PASS'
      Set To Dictionary  ${nrcell_targetTotalLoad_dict}  ${cell}=${cell_value[1]}
      Logging With Timestamp  message=Preconfigured targetTotalLoad parameter value is: ${cell_value[1]}.
    ELSE
      Set To Dictionary  ${nrcell_targetTotalLoad_dict}  ${cell}=${None}
    END
    Logging With Timestamp  message=Updating targetTotalLoad parameter to 100.
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell}
    ...  parameter=targetTotalLoad
    ...  operation=update
    ...  value=100
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Logging With Timestamp  message=Updating targetTotalLoad parameter to 100.
    ...  style=DONE
  END
  Logging With Timestamp
  ...  message=Artificial Load activation completed, wait for parameter activation.
  ...  style=ONGOING
  sleep  65s
  Logging With Timestamp
  ...  message=Artificial Load activation wait time finished.
  ...  style=DONE
  Logging With Timestamp
  ...  message=Step 1 Artificial Load activation finished
  ...  style=DONE
  ...  frame=${TRUE}

Step 2 Monitor VSWR values Site View
  [Documentation]  Description: Monitors VSWR values from the Site View for a set period.
  ...  ...  It checks if the values are within the allowed maximum and fails if they are not supported or exceed the limit.
  ...  Variables Used:
  ...  | Variable                 | Description                                |
  ...  |--------------------------|--------------------------------------------|
  ...  | vswr_allowed_max_value   | Maximum allowed VSWR value during monitoring. |
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp  message=Step 2 Monitor VSWR values Site View started.
  ...  style=STEP
  ...  frame=${TRUE}
  &{Measurements_dict}=  Create Dictionary
  ${i}=  Set Variable  1
  WHILE  ${i} < 65
    &{vswr_Measurements}=  admin.Get Rmod Measurements By Id  id=${ru_unit_distname}  connection=${BTS_ID}
    sleep  1s
    ${i}=  Convert To String  ${i}
    Set To Dictionary  ${Measurements_dict}  ${i}=${vswr_Measurements.vswr}
    FOR  ${vswr_measurement}  IN  @{vswr_Measurements.vswr}
      Logging With Timestamp  message=VSWR measurement iteration number ${i}: ${vswr_measurement}
      ...  style=INFO
      ${vswr_value}=  Get Dictionary Values  ${vswr_measurement.vswr}
      Logging With Timestamp  message=VSWR value: ${vswr_value[0]}
      ...  style=INFO
      IF  '${vswr_value[0]}'=='-'
        Logging With Timestamp  message=VSWR value is not supported.
        ...  style=FAIL
        Run Keyword And Continue On Failure  Fail  VSWR value is not supported.
        Exit For Loop
      END
      ${status}=  Run Keyword And Continue On Failure  Evaluate  ${vswr_value[0]} < ${vswr_allowed_max_value}
      IF  not ${status}
        Logging With Timestamp  message=VSWR value is above ${vswr_allowed_max_value}, stopping monitoring and failing the test.
        ...  style=FAIL
        Run Keyword And Continue On Failure  Fail  VSWR value is not supported.
        Exit For Loop
      END
    END
    ${i}=  Evaluate  ${i} + 1
  END
  Logging With Timestamp  message=Step 2 Monitor VSWR values Site View finished.
  ...  style=DONE
  ...  frame=${TRUE}

Step 3 Antenna Online Monitoring and monitor VSWR values in Antenna Online Monitoring
  [Documentation]  Description: Enables Antenna Online Monitoring, monitors VSWR values, and then stops monitoring.
  ...  ...  It saves the collected data to a JSON file and analyzes it to ensure values are within the allowed maximum.
  ...  Variables Used:
  ...  | Variable                 | Description                                |
  ...  |--------------------------|--------------------------------------------|
  ...  | vswr_allowed_max_value   | Maximum allowed VSWR value during monitoring. |
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp  message=Step 3 Antenna Online Monitoring and monitor VSWR values in Antenna Online Monitoring started.
  ...  style=STEP
  ...  frame=${TRUE}
  Logging With Timestamp  message=Starting Antl Online Monitoring for ${RU_ID}.
  ...  style=ONGOING
  Run Keyword And Continue On Failure  admin.Start Antl Online Monitoring
  ...  target_dns=${RU_ID}  timeout=30  connection=${BTS_ID}
  &{Measurements_dict}=  Create Dictionary
  ${i}=  Set Variable  1
  WHILE  ${i} < 65
    &{vswr_Measurements}=  admin.Get Rmod Measurements By Id  id=${ru_unit_distname}  connection=${BTS_ID}
    sleep  1s
    Set To Dictionary  ${Measurements_dict}  ${i}=${vswr_Measurements.vswr}
    FOR  ${vswr_measurement}  IN  @{vswr_Measurements.vswr}
      Logging With Timestamp  message=VSWR measurement: ${vswr_measurement}
      ...  style=INFO
      ${vswr_value}=  Get Dictionary Values  ${vswr_measurement.vswr}
      Logging With Timestamp  message=VSWR value: ${vswr_value[0]}
      ...  style=INFO
      IF  '${vswr_value[0]}'=='-'
        Logging With Timestamp  message=VSWR value is not supported.
        ...  style=FAIL
        Run Keyword And Continue On Failure  Fail  VSWR value is not supported.
        Exit For Loop
      END
      Run Keyword And Continue On Failure  Evaluate  ${vswr_value[0]} < ${vswr_allowed_max_value}
    END
  ${i}=  Evaluate  ${i} + 1
  ${i}=  Convert To String  ${i}
  END
  Logging With Timestamp  message=Stopping Antl Online Monitoring for ${RU_ID} and saving data to file.
  ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Stop Antl Online Monitoring
    ...  output_file_name=${TEST_LOGS_DIR_PATH}/TestFiles/${BTS_ID}/vswr.json  connection=${BTS_ID}
    Logging With Timestamp  message=Start analyzing vswr mearuments data from file.
    ...  style=ONGOING
    Run Keyword And Continue On Failure  analyze_vswr_data  ${TEST_LOGS_DIR_PATH}/TestFiles/${BTS_ID}/vswr.json    ${vswr_allowed_max_value}
    Logging With Timestamp  message=VSWR values analysis finished.
    ...  style=DONE
    Logging With Timestamp  message=Step 3 Antenna Online Monitoring and monitor VSWR values in Antenna Online Monitoring finished.
    ...  style=DONE
    ...  frame=${TRUE}

Step 4 Adjust VSWR parameters for alarms’ thresholds
  [Documentation]  Description: Adjusts the VSWR minor and major alarm thresholds for each antenna line.
  ...  ...  It reads the current thresholds, calculates new random values within the allowed range,
  ...  ...  applies them, and verifies that the parameters have been updated correctly.
  ...  Variables Used:
  ...  | Variable                 | Description                                           |
  ...  |--------------------------|-------------------------------------------------------|
  ...  | vswr_allowed_min_value   | Minimum value for generating new alarm thresholds.    |
  ...  | vswr_allowed_max_value   | Maximum value for generating new alarm thresholds.    |
  ...  | vswr_alarm_minor_step    | Step increment for generating new alarm thresholds.   |
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp  message=Step 4 Adjust VSWR parameters for alarms’ thresholds started.
  ...  style=STEP
  ...  frame=${TRUE}
  &{vswr_alarm_minor_threshold_dict}=  Create Dictionary
  Set Test Variable  ${VSWR_ALARM_MINOR_THRESHOLD_DICT}  ${vswr_alarm_minor_threshold_dict}
  FOR  ${antl}  IN  @{RU_ID}
    ${configDN}=  xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'ANTL_R') and contains (@distName, '${antl}')]/p[@name="configDN"]
    ${vswrMinorThreshold}=  xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'ANTL_R') and contains (@distName, '${antl}')]/p[@name="vswrMinorThreshold"]
    ${vswrMajorThreshold}=  xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'ANTL_R') and contains (@distName, '${antl}')]/p[@name="vswrMajorThreshold"]
    Set To Dictionary  ${vswr_alarm_minor_threshold_dict}  ${antl}_major=${vswrMajorThreshold}  ${antl}_minor=${vswrMinorThreshold}
    Logging With Timestamp  message=Updating VSWR parameters for alarms’ thresholds.
    ...  style=ONGOING
    ${new_thrshld_vswr_minor_value}=  Get New Value From Range
    ...  min_value=${vswr_allowed_min_value}
    ...  max_value=${vswr_allowed_max_value}
    ...  step=${vswr_alarm_minor_step}
    ...  current_value=${vswrMinorThreshold}
    ${new_thrshld_vswr_minor_value}=  Evaluate  int(float($new_thrshld_vswr_minor_value) * 10)
    ${new_thrshld_vswr_major_value}=  Get New Value From Range
    ...  min_value=${vswr_allowed_min_value}
    ...  max_value=${vswr_allowed_max_value}
    ...  step=${vswr_alarm_minor_step}
    ...  current_value=${vswrMajorThreshold}
    ${new_thrshld_vswr_major_value}=  Evaluate  int(float($new_thrshld_vswr_major_value) * 10)
    Logging With Timestamp  message=New vswrMinorThreshold value: ${new_thrshld_vswr_minor_value}.
    Logging With Timestamp  message=New vswrMajorThreshold value: ${new_thrshld_vswr_major_value}.
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=${configDN}
    ...  parameter=vswrMinorThreshold
    ...  operation=update
    ...  value=${new_thrshld_vswr_minor_value}
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=${configDN}
    ...  parameter=vswrMajorThreshold
    ...  operation=update
    ...  value=${new_thrshld_vswr_major_value}
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=Updating vswrMinorThreshold parameter to max:${new_thrshld_vswr_major_value} and min:${new_thrshld_vswr_minor_value}.
    ...  style=DONE
    ${antl_parameters}=  Run Keyword And Ignore Error    admin.Get Parameter By Distname
    ...  dist_name=${configDN}
    ...  detailed_output=${True}
    ...  include_children=${True}
    ...  connection=${BTS_ID}
    ${new_thrshld_vswr_major_value}=    evaluate    $new_thrshld_vswr_major_value/10
    ${new_thrshld_vswr_minor_value}=    evaluate    $new_thrshld_vswr_minor_value/10
    ${tmp_dict}=    Get From Dictionary   ${antl_parameters[1]}    requestMessage
    Run Keyword And Continue On Failure  Should Be Equal As Integers
    ...  ${tmp_dict[0]['parameters']['vswrMajorThreshold']}
    ...  ${new_thrshld_vswr_major_value}
    ...  msg=vswrMinorThreshold parameter not updated correctly.
    Run Keyword And Continue On Failure  Should Be Equal As Integers
    ...  ${tmp_dict[0]['parameters']['vswrMinorThreshold']}
    ...  ${new_thrshld_vswr_minor_value}
    ...  msg=vswrMajorThreshold parameter not updated correctly.
    Logging With Timestamp  message=VSWR parameters adjusted.
    ...  style=DONE
  END
  Logging With Timestamp  message=Step 4 Adjust VSWR parameters for alarms’ thresholds finished.
  ...  style=DONE
  ...  frame=${TRUE}

Step 5 Restore VSWR parameters for alarms’ thresholds
  [Documentation]  Description: Restores the original VSWR minor and major alarm thresholds.
  ...  ...  It uses the values saved before the adjustment in Step 4.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp  message=Step 5 Restore VSWR parameters for alarms’ thresholds started.
  ...  style=STEP
  ...  frame=${TRUE}
  FOR  ${antl}  IN  @{RU_ID}
    ${configDN}=  xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'ANTL_R') and contains (@distName, '${antl}')]/p[@name="configDN"]
    Logging With Timestamp  message=Restoring VSWR parameters for alarms’ thresholds.
    ...  style=ONGOING
    ${vswr_minor_value}=  Get From Dictionary  ${VSWR_ALARM_MINOR_THRESHOLD_DICT}  ${antl}_minor
    ${vswr_major_value}=  Get From Dictionary  ${VSWR_ALARM_MINOR_THRESHOLD_DICT}  ${antl}_major
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=${configDN}
    ...  parameter=vswrMinorThreshold
    ...  operation=update
    ...  value=${vswr_minor_value}
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=${configDN}
    ...  parameter=vswrMajorThreshold
    ...  operation=update
    ...  value=${vswr_major_value}
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Logging With Timestamp
    ...  message=Restoring vswr Threshold parameter to max:${vswr_major_value} and min:${vswr_minor_value}.
    ...  style=DONE
    Logging With Timestamp  message=VSWR parameters adjusted.
    ...  style=DONE
  END
  Logging With Timestamp  message=Step 5 Restore VSWR parameters for alarms’ thresholds finished.
  ...  style=DONE
  ...  frame=${TRUE}

Step 6 Modify vswrAlarmTxPwrThreshold parameter
  [Documentation]  Description: Modifies the 'vswrAlarmTxPwrThreshold' parameter for each antenna line.
  ...  ...  It gets a new random value within a predefined range and applies it.
  ...  Variables Used:
  ...  | Variable                          | Description                                           |
  ...  |-----------------------------------|-------------------------------------------------------|
  ...  | vswrAlarmTxPwrThreshold_min_value | Minimum value for the vswrAlarmTxPwrThreshold parameter. |
  ...  | vswrAlarmTxPwrThreshold_max_value | Maximum value for the vswrAlarmTxPwrThreshold parameter. |
  ...  | vswrAlarmTxPwrThreshold_step      | Step increment for generating a new value.            |
  ...  | vswrMajorThreshold                | Used as the 'current_value' to be excluded.           |
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp  message=Step 6 Modify vswrAlarmTxPwrThreshold parameter started.
  ...  style=STEP
  ...  frame=${TRUE}
  FOR  ${antl}  IN  @{RU_ID}
    ${configDN}=  xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'ANTL_R') and contains (@distName, '${antl}')]/p[@name="configDN"]
    ${vswrAlarmTxPwrThreshold_list}=  Create List  vswrAlarmTxPwrThreshold
    Logging With Timestamp  message=Updating VSWR parameters for alarms’ thresholds.
    ...  style=ONGOING
    ${new_vswrAlarmTxPwrThreshold}=  Get New Value From Range
    ...  min_value=${vswrAlarmTxPwrThreshold_min_value}
    ...  max_value=${vswrAlarmTxPwrThreshold_max_value}
    ...  step=${vswrAlarmTxPwrThreshold_step}
    ...  current_value=${vswrMajorThreshold}
    ${new_vswrAlarmTxPwrThreshold}=  Evaluate  int(float($new_vswrAlarmTxPwrThreshold) * 10)
    Logging With Timestamp  message=New random vswrAlarmTxPwrThreshold value: ${new_vswrAlarmTxPwrThreshold}.
    Logging With Timestamp  message=Updating vswrAlarmTxPwrThreshold parameter to :${new_vswrAlarmTxPwrThreshold}.
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=${configDN}
    ...  parameter=vswrAlarmTxPwrThreshold
    ...  operation=update
    ...  value=${new_vswrAlarmTxPwrThreshold}
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    ${antl_parameters}=  Run Keyword And Ignore Error    admin.Get Parameter By Distname
    ...  dist_name=${configDN}
    ...  parameter_list=${vswrAlarmTxPwrThreshold_list}
    ...  detailed_output=${True}
    ...  include_children=${True}
    ...  connection=${BTS_ID}
    ${new_vswrAlarmTxPwrThreshold}=    evaluate    $new_vswrAlarmTxPwrThreshold/10
    ${tmp_dict}=    Get From Dictionary   ${antl_parameters[1]}    requestMessage
    Run Keyword And Continue On Failure  Should Be Equal As Integers
    ...  ${tmp_dict[0]['parameters']['vswrAlarmTxPwrThreshold']}
    ...  ${new_vswrAlarmTxPwrThreshold}
    Logging With Timestamp  message=VSWR parameters adjusted.
    ...  style=DONE
  END
  Logging With Timestamp  message=Step 6 Modify vswrAlarmTxPwrThreshold parameter finished.
  ...  style=DONE
  ...  frame=${TRUE}

Step 7 Remove vswrAlarmTxPwrThreshold parameter
  [Documentation]  Description: Removes the 'vswrAlarmTxPwrThreshold' parameter for each antenna line.
  ...  ...  This is done by performing a parameter recommissioning with the 'delete' operation.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp  message=Step 7 Remove vswrAlarmTxPwrThreshold parameter started.
  ...  style=STEP
  ...  frame=${TRUE}
  FOR  ${antl}  IN  @{RU_ID}
    ${configDN}=  xml.get element text  ${TEST_LOGS_DIR_PATH}/BTSFiles/${BTS_ID}/pretest_scf.xml
    ...  xpath=//managedObject[contains (@class,'ANTL_R') and contains (@distName, '${antl}')]/p[@name="configDN"]
    Logging With Timestamp  message=Updating VSWR parameters for alarms’ thresholds.
    ...  style=ONGOING

    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=${configDN}
    ...  parameter=vswrAlarmTxPwrThreshold
    ...  operation=delete
    ...  value=200
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}

    Logging With Timestamp  message=VSWR parameters adjusted.
    ...  style=DONE
  END
  Logging With Timestamp  message=Step 7 Restore vswrAlarmTxPwrThreshold parameter finished.
  ...  style=DONE
  ...  frame=${TRUE}

Step 8 Artificial Load deactivation
  [Documentation]  Description: Deactivates the artificial load on cells related to the specified radio unit.
  ...  ...  This is done by deleting the 'targetTotalLoad' parameter modification.
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 8 Artificial Load deactivation started
  ...  style=STEP
  ...  frame=${TRUE}
  @{nrcel_cell_list}=  Get From Dictionary  ${CFG.RF_INFO['${RADIO_UNIT}']['NRCEL']}  scf_cellid_primary
  @{lncel_cell_list}=  Get From Dictionary  ${CFG.RF_INFO['${RADIO_UNIT}']['LNCEL']}  scf_cellid_primary
  &{nrcell_targetTotalLoad_dict}=  Create Dictionary
  FOR  ${cell}  IN  @{nrcel_cell_list}
    Logging With Timestamp  message=Removing targetTotalLoad parameter.
    ...  style=ONGOING
    Run Keyword And Continue On Failure  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}/NRCELL-${cell}
    ...  parameter=targetTotalLoad
    ...  operation=delete
    ...  value=100
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Logging With Timestamp  message=Removing targetTotalLoad parameter.
    ...  style=DONE
  END
  Logging With Timestamp
  ...  message=Step 8 Artificial Load deactivation finished
  ...  style=DONE
  ...  frame=${TRUE}
