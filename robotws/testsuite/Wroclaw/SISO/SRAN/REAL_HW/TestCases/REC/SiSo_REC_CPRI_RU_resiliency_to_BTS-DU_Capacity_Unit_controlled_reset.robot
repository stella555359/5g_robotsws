*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/36575
...
...  *****************
...  Basic information
...  *****************
...
...  Step 1: Check Uptime For Specific Radio Unit
...  Checking the uptime for the specified radio unit.
...
...  Step 2: L3 Call
...  Performing L3 call.
...
...  Step 3: Activate CPRI RU reset resiliency
...  Activating the CPRI RU reset resiliency.
...
...  Step 4: Verify value of cntrldResetMplaneBreakTime
...  Verifying the value of cntrldResetMplaneBreakTime.
...
...  Step 5: Trigger BBMOD Reset And Verify Result
...  Triggering BBMOD reset and verifying the result.
...
...  Step 6: Verify RU State After Reset Recovery
...  Verifying the RU state after reset recovery.
...
...  Step 7: L3 Call
...  Performing L3 call.
...
...  Step 8: Deactivate CPRI RU reset resiliency
...  Deactivating the CPRI RU reset resiliency.
...  ******************
...  History of changes
...  ******************
...  - 04.10.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot


*** Variables ***

${prompt}=  >|$|@|#


*** Keywords ***
SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset
  [Documentation]
  ...  Description:
  ...  Executes the resiliency test for CPRI RU to BTS-DU with controlled reset.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Common Test Setup  tools_to_setup=syslog_ADMIN
  Logging With Timestamp
  ...  message=SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset will be executed
  ...  style=ONGOING
  ${ru_uptime}=  Create Dictionary  &{EMPTY}
  Set Test Variable  ${RU_UPTIME}
  FOR  ${radio_unit}  IN  @{CUSTOM_RADIO_UNIT_LIST}
    ${bts_id}=  Precondition For RU Resiliency Test  ${radio_unit}
    Step 1 Check Uptime For Specific Radio Unit  ${bts_id}  ${radio_unit}
    Step 2 L3 Call
    Step 3 Activate CPRI RU reset resiliency  ${bts_id}
    Step 4 Verify value of cntrldResetMplaneBreakTime  ${bts_id}
    Step 5 Trigger BBMOD Reset And Verify Result  ${bts_id}  ${radio_unit}
    Step 6 Verify RU State After Reset Recovery
    Step 7 L3 Call
    Step 8 Deactivate CPRI RU reset resiliency
  END
  [Teardown]  Common Test Teardown

Precondition For RU Resiliency Test
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
  ${bts_id}=  Get From Dictionary  ${CFG.RF_INFO['${radio_unit}']}  scf_btsid_primary
  Set Test Variable  ${BTS_ID}  ${bts_id}
  Set Test Variable  ${RADIO_UNIT}  ${radio_unit}
#  Start Taf Syslog Session  ${bts_id}  ${bts_id}  additional
  [Return]  ${bts_id}

Step 1 Check Uptime For Specific Radio Unit
  [Arguments]  ${bts_id}  ${radio_unit}
  [Documentation]
  ...  Description:
  ...  Checks the uptime for the specified radio unit.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | radio_unit             | yes  | Radio unit serial_number                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 1 Check Uptime For Specific Radio Unit
  ...  style=STEP
  ...  frame=${TRUE}
  IF  '${CFG.NODES['${bts_id}']['bts_alias_type']}'=='localhost'
    Open Connection To Radio Module  ru_serial_number=${radio_unit}
  ELSE IF  '${CFG.configuration_setup_type}'=='mplane'
    Open Connection To Radio Module  ru_serial_number=${radio_unit}  via_mplane=${cfg.NODES['${bts_id}']['bts_ip_address']}
  ELSE
    Open Connection To Radio Module  ru_serial_number=${radio_unit}  remote_host=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
  END
  radio.Send Command
  ...  command=uptime
  ...  delay=3
  ${radio_uptime}=  radio.Read Until Prompt
  ...  prompt=>|$|@|#
  ...  timeout=10
  @{radio_uptime_values}=  Split To Lines  ${radio_uptime}
  @{radio_uptime_values}=  Split String  ${radio_uptime_values[2]}  ,
  @{radio_uptime_values}=  Split String  ${radio_uptime_values[0]}  ${SPACE}
  Remove Values From List  ${radio_uptime_values}  ${EMPTY}
  ${radio_uptime}=  Uptime Radio Convert Time To Seconds  ${radio_uptime_values[2]}
  Logging With Timestamp
  ...  message=Uptime read from RU ${radio_unit} is: ${radio_uptime} seconds before Reset.
  Set To Dictionary  ${ru_uptime}  ${radio_unit}_start=${radio_uptime}
  [Teardown]  radio.Close SSH Connection

Step ${step_number} L3 Call
  [Documentation]
  ...  Description:
  ...  Performs an L3 call.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Step ${step_number} L3 Call
  ...  style=STEP
  ...  frame=${TRUE}
  ${call_status}=  Run Keyword And Return Status  Should Not Be Empty  ${SELECTED_CELLS}
  Return From Keyword If  not ${call_status}
  Logging With Timestamp
  ...  message=L3 call for requested cells will be executed.
  SiSo Convert Id to Runtime Distname
  SiSo L3 Call  cells_input=${SELECTED_CELLS}  # deviation=50%

Step 3 Activate CPRI RU reset resiliency
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Description:
  ...  Activates the CPRI RU reset resiliency.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 3 Activate CPRI RU reset resiliency
  ...  style=STEP
  ...  frame=${TRUE}
  ${initial_scf}=  admin.Get Scf
  ...  export_type=configurationAndRuntimeObjects
  ...  parameters_save_variant=actualValues
  ...  alias=${bts_id}
  ${delta_id}=  Set Variable  activate_CB010846
  admin.Create Delta  delta_id=${delta_id}
  admin.Append Parameter Update To Delta
  ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
  ...  parameter=actRuResetResiliency
  ...  value=true
  ...  delta_id=${delta_id}
  ${delta}=  admin.Get Delta  delta_id=${delta_id}
  admin.Perform Delta Recommissioning  delta_file=${delta}
  ...  alias=${bts_id}
  Logging With Timestamp
  ...  message=Delta commissioning with "actRuResetResiliency" parameter finished.
  admin.Remove Delta  delta_id=${delta_id}

Step 4 Verify value of cntrldResetMplaneBreakTime
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Description:
  ...  Verifies the value of cntrldResetMplaneBreakTime.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${optional_parametr_status}=  Get Variable Value  ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}  ${False}
  Return From Keyword If  not ${optional_parametr_status}
  Logging With Timestamp
  ...  message=Step 4 Verify value of cntrldResetMplaneBreakTime
  ...  style=STEP
  ...  frame=${TRUE}
  ${scf_node_file}=  admin.Get Current Scf File
  ...  local_dir_path=${CFG.test_logs_path}/TestFiles/${bts_id}/
  ...  file_name=step_3_scf_${bts_id}_commissioning.xml
  ...  export_type=configuration
  ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
  ...  connection=${bts_id}
  ${scf_parameter_status}=  Run Keyword And Ignore Error
  ...  Get Element Text  ${CFG.test_logs_path}/TestFiles/${bts_id}/step_3_scf_${bts_id}_commissioning.xml
  ...  xpath=//managedObject[contains (@class,'FEATCADM')]/p[@name="cntrldResetMplaneBreakTime"]/text()
  IF  '${scf_parameter_status[0]}'=='PASS'
    Run Keyword And Continue On Failure
    ...  Should Be Equal As Integers
    ...  first=${scf_parameter_status[1]}
    ...  second=${cntrldResetMplaneBreakTime_EXPECTED_VALUE}
    ...  msg=Value is not properly set to expected - ${cntrldResetMplaneBreakTime_EXPECTED_VALUE}
    ...  values=True
  ELSE
    Logging With Timestamp  message=BTS ${bts_id} is not configured with "cntrldResetMplaneBreakTime" parameter.
  END
  [Return]  ${scf_parameter_status[0]}

Step 5 Trigger BBMOD Reset And Verify Result
  [Arguments]  ${bts_id}  ${radio_unit}  ${timeout}=240
  [Documentation]
  ...  Description:
  ...  Triggers BBMOD reset and verifies the result.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | radio_unit             | yes  | Radio unit serial number                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | no   | Timeout for the reset operation                                            |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 5 Trigger BBMOD Reset And Verify Result
  ...  style=STEP
  ...  frame=${TRUE}
  ${scf_cablink_primary}=  Get From Dictionary  ${CFG.RF_INFO['${radio_unit}']}  scf_cablink_primary
  ${bts_info}=  admin.Get Bts Info  connection=${bts_id}
  ${basebandModules}=  Get From Dictionary  ${bts_info}  basebandModules
  ${cables}=  Get From Dictionary  ${bts_info}  cables
  FOR  ${cable}  IN  @{cables}
#  Continue For Loop If  '${cable['linkMode']['configuration']}' == 'False'
    ${bbmod_id}=  Set Variable  ${False}
    Continue For Loop If  not '${cable['id']['configuration']}' == '${scf_cablink_primary[0]}'
    ${bbmod_first_status}=  Run Keyword And Return Status  Should Match Regexp  ${cable['firstEndPointId']['internal']}  BBMOD
    IF  ${bbmod_first_status}
      ${bbmod_cablink}=  Set Variable  ${cable['firstEndPointId']['internal']}
    ELSE
      ${bbmod_cablink}=  Should Match Regexp  ${cable['secondEndPointId']['internal']}  BBMOD
    END
    ${bbmod_id}=  split_string_from_right  ${bbmod_cablink}  /  max_split=1
    Exit For Loop If  ${bbmod_id}
  END
  FOR  ${baseBand}  IN  @{basebandModules}
    Continue For Loop If  not '${baseBand['id']['internal']}' == '${bbmod_id[0]}'
    ${baseBandId}=  Get From Dictionary  ${baseBand}  id
    ${baseBandStatus}=  Get From Dictionary  ${baseBand}  status
    Exit For Loop
  END
  Logging With Timestamp
  ...  message=Reset BBMOD ${baseBandId['internal']} is being made, please wait to recovery.
  ${status}=  Run Keyword And Continue On Failure  admin.Reset Unit
  ...  dist_name=${baseBandId['internal']}
  ...  reset_type=Warm
  ...  timeout=${timeout}
  ...  detailed_output=True
  ...  alias=${bts_id}
  Logging With Timestamp
  ...  message=Reset BBMOD ${baseBandId['internal']} finished. Wait for OnAir state.
  Run Keyword And Continue On Failure  STATE Verify BTS states
  ...  node_id=${bts_id}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}

Step ${step_number} Verify RU State After Reset Recovery
  [Documentation]
  ...  Description:
  ...  Verifies the RU state after reset recovery.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | radio_unit             | yes  | Radio unit serial number                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step ${step_number} Verify RU State After Reset Recovery
  ...  style=STEP
  ...  frame=${TRUE}
  IF  '${CFG.NODES['${bts_id}']['bts_alias_type']}'=='localhost'
    Open Connection To Radio Module  ru_serial_number=${radio_unit}
  ELSE IF  '${CFG.configuration_setup_type}'=='mplane'
    Open Connection To Radio Module  ru_serial_number=${radio_unit}  via_mplane=${cfg.NODES['${bts_id}']['bts_ip_address']}
  ELSE
    Open Connection To Radio Module  ru_serial_number=${radio_unit}  remote_host=${cfg.NODES['${bts_id}']['vm_ip_LMP_address']}
  END
  radio.Send Command
  ...  command=uptime
  ...  delay=3
  ${radio_uptime}=  radio.Read Until Prompt
  ...  prompt=>|$|@|#
  ...  timeout=10
  @{radio_uptime_values}=  Split To Lines  ${radio_uptime}
  @{radio_uptime_values}=  Split String  ${radio_uptime_values[2]}  ,
  @{radio_uptime_values}=  Split String  ${radio_uptime_values[0]}  ${SPACE}
  Remove Values From List  ${radio_uptime_values}  ${EMPTY}
  ${radio_uptime}=  Uptime Radio Convert Time To Seconds  ${radio_uptime_values[2]}
  Logging With Timestamp
  ...  message=Uptime read from RU ${radio_unit} is: ${radio_uptime} seconds after Reset.
  Set To Dictionary  ${ru_uptime}  ${radio_unit}_end=${radio_uptime}
  ${start_value}=  Get From Dictionary  ${ru_uptime}  ${radio_unit}_start
  ${end_value}=  Get From Dictionary  ${ru_uptime}  ${radio_unit}_end
  ${radio_unit_uptime_difference}=  Run Keyword And Continue On Failure  Evaluate  ${end_value} > ${start_value}
  ${uptime_verification_status}=  Run Keyword And Continue On Failure  Should Be True  ${radio_unit_uptime_difference}
  IF  ${radio_unit_uptime_difference}
    Logging With Timestamp
    ...  message=Difference between startup uptime value and end uptime value for RU ${radio_unit} is correct - ${end_value} > ${start_value}.
    ...  style=PASS
  ELSE
    Logging With Timestamp
    ...  message=Difference between startup uptime value and end uptime value for RU ${radio_unit} is not correct - ${end_value} > ${start_value} !!
    ...  style=FAIL
  END
#  Verify Syslog Communication For CB010846-SR Feature  ${bts_id}  ${radio_unit}  15
  [Teardown]  radio.Close SSH Connection

Verify Syslog Communication For CB010846-SR Feature
  [Arguments]  ${bts_id}  ${radio_unit}  ${timeout}
  [Documentation]
  ...  Description:
  ...  Verifies syslog communication for CB010846-SR feature.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | radio_unit             | yes  | Radio unit serial number                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | timeout                | yes  | Timeout for the verification                                               |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Verification in syslog meassages start.
  ${result}=  Wait until keyword succeeds  ${timeout}  5s  taf_syslog.Message should exist in syslog file
  ...  isReadyToCloseVirtualConnection() cntrldResetMplaneBreakTime
  ...  alias=${bts_id}_primary
  ${result}=  Wait until keyword succeeds  ${timeout}  5s  taf_syslog.Message should exist in syslog file
  ...  isReadyToCloseVirtualConnection(): isReadyCloseVirtualCon = 1
  ...  alias=${bts_id}_primary
  ${ru_unit_distname}=  Get From Dictionary  ${CFG.RF_INFO.['${radio_unit}']}  scf_dist_name_primary
  ${_tmp}  ${ru_logical_number}=  Split String From Right  ${ru_unit_distname}  -
  ${result}=  Wait until keyword succeeds  ${timeout}  5s  taf_syslog.Message should exist in syslog file
  ...  [/RMOD_L_${ru_logical_number}/RU_L_1 RP1RadioAgent] teardown(): begin... terminationReason = CloseVirtualConnection
  ...  alias=${bts_id}_primary
  ${result}=  Wait until keyword succeeds  ${timeout}  5s  taf_syslog.Message should exist in syslog file
  ...  [SoapConverter] sendWithAdditionalTimeout: /RMOD_L_${ru_logical_number}/RU_L_1 send soap_id = 1182 type closeVirtualConnectionReq
  ...  alias=${bts_id}_primary
  Logging With Timestamp
  ...  message=Verification in syslog meassages finished.

Step ${number} Deactivate CPRI RU reset resiliency
  [Documentation]
  ...  Description:
  ...  Deactivates the CPRI RU reset resiliency.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step ${number} Deactivate CPRI RU reset resiliency
  ...  style=STEP
  ...  frame=${TRUE}
  ${initial_scf}=  admin.Get Scf
  ...  export_type=configurationAndRuntimeObjects
  ...  parameters_save_variant=actualValues
  ...  alias=${bts_id}
  ${delta_id}=  Set Variable  deactivate_CB010846
  admin.Create Delta  delta_id=${delta_id}
  admin.Append Parameter Update To Delta
  ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
  ...  parameter=actRuResetResiliency
  ...  value=false
  ...  delta_id=${delta_id}
  ${delta}=  admin.Get Delta  delta_id=${delta_id}
  admin.Perform Delta Recommissioning  delta_file=${delta}
  ...  alias=${bts_id}
  admin.Remove Delta  delta_id=${delta_id}
  Logging With Timestamp
  ...  message=Delta commissioning with "actRuResetResiliency" parameter finished.
