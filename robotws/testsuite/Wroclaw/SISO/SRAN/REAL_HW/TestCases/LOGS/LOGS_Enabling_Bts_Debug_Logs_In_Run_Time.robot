*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/xxx
...
...  *****************
...  Basic information
...  *****************
...
...  Precondition For BTS debug logs, Force setup of swconfig to handle debug level logging.
...  Site reset to activate change.
...  • Modified flags: 0x1003F=1
...  • 0x10040=1
...  - OnAir state after reset.
...  Step 1 Get Current Debug Domains Value, Get RAD specific domain parameters with details.
...  Result should show details for specific RAD flag. In case of empty output step will fail.
...  Step 2 Change Debug Domain Parameter And Verify Its Value
...  Change requested domain parameter to specific value and verify this modification.
...  RAD debug flag should be changed and visible in output. In case flag after modification is not proper , step will fail.
...  Step 3 Reset selected R&D debug parameters’ new values back to default values
...  Reset previously modified RAD parameter to default value. Value is corrected using provided by user description.
...  In case after reset RAD flag is not valid, step will fail.
...  Step 4 Change Debug Domain Parameter And Verify Its Value.
...  Change requested domain parameter to specific value and verify this modification.
...  RAD debug flag should be changed and visible in output. In case flag after modification is not proper , step will fail.
...  Step 5 Reset BTS twice to confirm that selected R&D debug parameters’ type of persistency works properly,
...  RAD parameter is check against its behaviour after Site Reset.
...  • In case – OneReset, provided parameter should be not reset to default after first Site Reset,
...  Its default value should be visible after second Site reset
...  • In case – Persistent, RAD parameter should became the same after first and second Site Reset,
...  • NotPersistent – in this type RAD parameter should be revert to default after first Site Reset
...  Step 2-5 should be repeat for each defined by user RAD parameter		•
...  Step 6 Restore all Non-Default R&D Debug Parameters values left back to default values
...  RAD flags are change according to provided by user, this time all in one step.
...  After proper modification  Reset All Rad Debug Parameters Procedure is executed.
...  After RAD reset to default , all RAD parameters provided by user should revert to default value.
...
...  ******************
...  History of changes
...  ******************
...  - 25.02.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library  testsuite/Wroclaw/SISO/SRAN/REAL_HW/Resources/Python/zip_helpers.py


*** Variables ***
&{Legacy}=  name=FEAT_DBG_BTSOM_ALMAG  type=OneReset  value=1  value_reset=0
&{OamUri}=  name=PrintRuntime  type=Persistent  value=true  value_reset=false
&{OamFri}=  name=FriPrintLog  type=NotPersistent  value=true  value_reset=false
&{rd_parameters_dict}=
...  Legacy=${Legacy}
...  OamUri=${OamUri}
...  OamFri=${OamFri}


*** Keywords ***
LOGS_Enabling_Bts_Debug_Logs_In_Run_Time
  [Documentation]
  ...  Description:
  ...  .
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Common Test Setup  tools_to_setup=IM_ADMIN
  Logging With Timestamp
  ...  message=Enabling BTS debug logs in run-time will be executed
  ...  style=ONGOING
  FOR  ${bts_id}  IN  @{CFG.active_bts_list}
    Precondition For BTS debug logs  ${bts_id}
    FOR  ${rd_domain_name}  IN  @{rd_parameters_dict.keys()}
      Step 1 Get Current Debug Domains Values  ${bts_id}  ${rd_domain_name}  ${rd_parameters_dict['${rd_domain_name}']}
      Step 2 Change Debug Domain Parameter And Verify Its Value  ${bts_id}  ${rd_domain_name}  ${rd_parameters_dict['${rd_domain_name}']}
      Step 3 Reset selected R&D debug parameters’ new values back to default values
      ...  ${bts_id}  ${rd_domain_name}  ${rd_parameters_dict['${rd_domain_name}']}
      Step 4 Change Debug Domain Parameter And Verify Its Value
      ...  ${bts_id}  ${rd_domain_name}  ${rd_parameters_dict['${rd_domain_name}']}
      Step 5 Reset BTS twice to confirm that selected R&D debug parameters’ type of persistency works properly
      ...  ${bts_id}  ${rd_domain_name}  ${rd_parameters_dict['${rd_domain_name}']}
    END
    Step 6 Restore all Non-Default R&D Debug Parameters values left back to default values
    ...  ${bts_id}
    Postcondition For BTS debug logs  ${bts_id}
  END
  [Teardown]  Common Test Teardown

Precondition For BTS debug logs
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Description:
  ...  This keyword is used to enable BTS debug logs in run-time
  ...  It is used to force setup of swconfig to handle debug level logging.
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS_ID used as alias                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Append To List  ${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}  0x1003F=1  0x10040=1
  Logging With Timestamp
  ...  message=Mandatory RAD flag will be added: 0x1003F=1 0x10040=1 , Please wait...
  ...  style=STEP
  ...  frame=${TRUE}
  Start Taf Syslog Session  ${bts_id}  ${bts_id}  additional
  Compare And Upload Swconfig
  Logging With Timestamp
  ...  message=Mandatory RAD flag modification finished.
  ...  style=DONE
  Logging With Timestamp
  ...  message=Site Reset for BTS-${bts_id} will be executed. Please wait...
  ...  style=ONGOING
  ${reset_response}=  Run Keyword And Continue On Failure  admin.Reset Site
  ...  connection=${bts_id}
  ...  wait_for_reconnection=True
  ...  detailed_output=True
  ...  graceful_cell_shutdown=${False}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=Site Reset for BTS-${bts_id} finished. Response from API: ${reset_response}
  ...  style=DONE
  Run Keyword And Continue On Failure  Wait until keyword succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  20
  ...  STATE Verify BTS states
  ...  node_id=${bts_id}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=1200
  Logging With Timestamp
  ...  message=Site Reset for BTS-${bts_id} finished. Please wait...
  ...  style=DONE
  Logging With Timestamp
  ...  message=Precondition For BTS debug logs finished.
  ...  style=DONE

Postcondition For BTS debug logs
  [Arguments]  ${bts_id}
  Remove Values From List  ${CUSTOM_ADDITIONAL_SWCONFIG_FLAGS}  0x1003F=1  0x10040=1
  Logging With Timestamp
  ...  message=Mandatory RAD flag will reverted to default.
  ...  style=STEP
  ...  frame=${TRUE}
  Compare And Upload Swconfig
  Logging With Timestamp
  ...  message=Mandatory RAD flag modification finished.
  ...  style=DONE
  Logging With Timestamp
  ...  message=Site Reset for BTS-${bts_id} will be executed. Please wait...
  ...  style=ONGOING
  ${reset_response}=  Run Keyword And Continue On Failure  admin.Reset Site
  ...  connection=${bts_id}
  ...  wait_for_reconnection=True
  ...  detailed_output=True
  ...  graceful_cell_shutdown=${False}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=Site Reset for BTS-${bts_id} finished. Response from API: ${reset_response}
  ...  style=DONE
  Run Keyword And Continue On Failure  Wait until keyword succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  20
  ...  STATE Verify BTS states
  ...  node_id=${bts_id}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=1200
  Logging With Timestamp
  ...  message=Site Reset for BTS-${bts_id} finished. Please wait...
  ...  style=DONE
  Stop Taf Syslog Session  ${bts_id}  ${bts_id}

Step 1 Get Current Debug Domains Values
  [Arguments]  ${bts_id}  ${rd_domain_name}  ${rd_parameter_dict}
  [Documentation]
  ...  Description:
  ...  Get Current Debug Domains Value, Get RAD specific domain parameters with details.
  ...  Result should show details for specific RAD flag. In case of empty output step will fail.Gets the current debug domain values.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_domain_name         | yes  | The R&D domain name.                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_parameter_dict      | yes  | The R&D parameter dictionary.                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 1 Get Current Debug Domains Values
  ...  style=STEP
  ...  frame=${TRUE}
  @{domain_parameter}=  admin.Get Bts Rad Parameters
  ...  parameters_type=Applied
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name} = @{domain_parameter}.
  &{domain_parameter_details}=  admin.Get Rad Debug Parameter Details
  ...  domain=${rd_domain_name}
  ...  parameter_name=${rd_parameter_dict.name}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD details of domain ${rd_domain_name} = &{domain_parameter_details}.
  Run Keyword And Continue On Failure  Should Not Be Empty  ${domain_parameter_details}
  &{domain_values_details}=  admin.Get Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  detailed_output=${True}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name} = &{domain_values_details}.

Step 2 Change Debug Domain Parameter And Verify Its Value
  [Arguments]  ${bts_id}  ${rd_domain_name}  ${rd_parameter_dict}
  [Documentation]
  ...  Description:
  ...  Change requested domain parameter to specific value and verify this modification.
  ...  RAD debug flag should be changed and visible in output. In case flag after modification is not proper , step will fail.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_domain_name         | yes  | The R&D domain name.                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_parameter_dict      | yes  | The R&D parameter dictionary.                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 2 Change Debug Domain Parameter And Verify Its Value
  ...  style=STEP
  ...  frame=${TRUE}
  &{rad_tmp_dict}=  Create Dictionary  name=${rd_parameter_dict.name}  value=${rd_parameter_dict.value}
  @{rad_tmp_list}=  Create List  ${rad_tmp_dict}
  Logging With Timestamp
  ...  message=RAD parameter for ${rd_domain_name} is will be change with this values: @{rad_tmp_list}
  admin.Set Multiple Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  persistency=${rd_parameter_dict.type}
  ...  rad_parameters=${rad_tmp_list}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=RAD parameter for ${rd_domain_name} is being changed with this values: @{rad_tmp_list}
  &{domain_parameter_details}=  admin.Get Rad Debug Parameter Details
  ...  domain=${rd_domain_name}
  ...  parameter_name=${rd_parameter_dict.name}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD details of domain ${rd_domain_name} = &{domain_parameter_details}.
  &{domain_values_details}=  admin.Get Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  detailed_output=${True}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name} = &{domain_values_details}.
  FOR  ${item}  IN  @{domain_values_details.requestMessage.parameters}
    Exit For Loop If  '${item.name}'=='${rd_parameter_dict.name}'
    ${item}=  Set Variable  ${None}
  END
  Run Keyword And Continue On Failure
  ...  Should Be Equal  ${rd_parameter_dict.value}  ${item.value}
  ...  msg=RAD parameter expected: ${rd_parameter_dict.value} and available in BTS: ${item.value}.

#Change the actual value of selected R&D parameters to desired value
#  [Arguments]  ${bts_id}  ${rd_domain_name}  ${rd_parameter_dict}
#  [Documentation]
#  ...  Description:
#  ...  Changes the debug domain parameter and verifies its value.
#  ...  Arguments:
#  ...  +========================+======+============================================================================+
#  ...  | Argument               | Man. | Description                                                                |
#  ...  +========================+======+============================================================================+
#  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
#  ...  +------------------------+------+----------------------------------------------------------------------------+
#  ...  | rd_domain_name         | yes  | The R&D domain name.                                                       |
#  ...  +------------------------+------+----------------------------------------------------------------------------+
#  ...  | rd_parameter_dict      | yes  | The R&D parameter dictionary.                                              |
#  ...  +------------------------+------+----------------------------------------------------------------------------+
#  ...
#  ...  Author: piotr.korczynski@nokia.com
#  ...  Maintainer: piotr.korczynski@nokia.com

#  Log  ${rd_parameter_dict}
#  &{rad_tmp_dict}=  Create Dictionary  name=${rd_parameter_dict.name}  value=${rd_parameter_dict.value}
#  @{rad_tmp_list}=  Create List  ${rad_tmp_dict}
#  admin.Set Multiple Rad Debug Parameters
#  ...  domain=${rd_domain_name}
#  ...  persistency=${rd_parameter_dict.type}
#  ...  rad_parameters=${rad_tmp_list}
#  ...  connection=${bts_id}
#  admin.Get Rad Debug Parameter Details
#  ...  domain=${rd_domain_name}
#  ...  parameter_name=${rd_parameter_dict.name}
#  ...  connection=${bts_id}
#  admin.Get Rad Debug Parameters
#  ...  domain=${rd_domain_name}
#  ...  detailed_output=${True}
#  ...  connection=${bts_id}

Step 3 Reset selected R&D debug parameters’ new values back to default values
  [Arguments]  ${bts_id}  ${rd_domain_name}  ${rd_parameter_dict}
  [Documentation]
  ...  Description:
  ...  Reset previously modified RAD parameter to default value. Value is corrected using provided by user description.
  ...  In case after reset RAD flag is not valid, step will fail.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_domain_name         | yes  | The R&D domain name.                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_parameter_dict      | yes  | The R&D parameter dictionary.                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Step 3 Reset selected R&D debug parameters’ new values back to default values.
  ...  style=STEP
  ...  frame=${TRUE}
  admin.Reset Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  name=${rd_parameter_dict.name}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name} reset to default finished.
  &{domain_parameter_details}=  admin.Get Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  detailed_output=${True}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name} = &{domain_parameter_details}.
  FOR  ${item}  IN  @{domain_parameter_details.requestMessage.parameters}
    Exit For Loop If  '${item.name}'=='${rd_parameter_dict.name}'
    ${item}=  Set Variable  ${None}
  END
  Run Keyword And Continue On Failure
  ...  Should Be Equal  ${rd_parameter_dict.value_reset}  ${item.value}
  ...  msg=RAD parameter expected: ${rd_parameter_dict.value_reset} and available in BTS: ${item.value}.

Step 4 Change Debug Domain Parameter And Verify Its Value
  [Arguments]  ${bts_id}  ${rd_domain_name}  ${rd_parameter_dict}
  [Documentation]
  ...  Description:
  ...  Change requested domain parameter to specific value and verify this modification.
  ...  RAD debug flag should be changed and visible in output. In case flag after modification is not proper , step will fail.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_domain_name         | yes  | The R&D domain name.                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_parameter_dict      | yes  | The R&D parameter dictionary.                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Step 4 Change Debug Domain Parameter And Verify Its Value
  ...  style=STEP
  ...  frame=${TRUE}
  &{rad_tmp_dict}=  Create Dictionary  name=${rd_parameter_dict.name}  value=${rd_parameter_dict.value}
  @{rad_tmp_list}=  Create List  ${rad_tmp_dict}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name} will be change with this value :@{rad_tmp_list}.
  admin.Set Multiple Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  persistency=${rd_parameter_dict.type}
  ...  rad_parameters=${rad_tmp_list}
  ...  connection=${bts_id}
  admin.Get Rad Debug Parameter Details
  ...  domain=${rd_domain_name}
  ...  parameter_name=${rd_parameter_dict.name}
  ...  connection=${bts_id}
  &{domain_parameter_details}=  admin.Get Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  detailed_output=${True}
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Current RAD value of domain ${rd_domain_name}: &{domain_parameter_details}
  FOR  ${item}  IN  @{domain_parameter_details.requestMessage.parameters}
    Exit For Loop If  '${item.name}'=='${rd_parameter_dict.name}'
    ${item}=  Set Variable  ${None}
  END
  Run Keyword And Continue On Failure
  ...  Should Be Equal  ${rd_parameter_dict.value}  ${item.value}

Step 5 Reset BTS twice to confirm that selected R&D debug parameters’ type of persistency works properly
  [Arguments]  ${bts_id}  ${rd_domain_name}  ${rd_parameter_dict}
  [Documentation]
  ...  Description:
  ...  RAD parameter is check against its behaviour after Site Reset.
  ...  • In case – OneReset, provided parameter should be not reset to default after first Site Reset,
  ...  Its default value should be visible after second Site reset
  ...  • In case – Persistent, RAD parameter should became the same after first and second Site Reset,
  ...  • NotPersistent – in this type RAD parameter should be revert to default after first Site Reset
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_domain_name         | yes  | The R&D domain name.                                                       |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | rd_parameter_dict      | yes  | The R&D parameter dictionary.                                              |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  Logging With Timestamp
  ...  message=Step 5 Reset BTS twice to confirm that selected R&D debug parameters’ type of persistency works properly.
  ...  style=STEP
  ...  frame=${TRUE}
  ${reset_response}=  Run Keyword And Continue On Failure  admin.Reset Site
  ...  connection=${bts_id}
  ...  wait_for_reconnection=True
  ...  detailed_output=True
  ...  graceful_cell_shutdown=${False}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=First Site Reset for BTS-${bts_id} finished. Response from API: ${reset_response}
  ...  style=DONE
  Run Keyword And Continue On Failure  Wait until keyword succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  120
  ...  STATE Verify BTS states
  ...  node_id=${bts_id}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${FALSE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=1200
  &{domain_parameter_details}=  admin.Get Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  detailed_output=${True}
  ...  connection=${bts_id}
  FOR  ${item}  IN  @{domain_parameter_details.requestMessage.parameters}
    Exit For Loop If  '${item.name}'=='${rd_parameter_dict.name}'
    ${item}=  Set Variable  ${None}
  END
  IF  '${rd_parameter_dict.type}'=='NotPersistent'
    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${rd_parameter_dict.value_reset}  ${item.value}
  ELSE
    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${rd_parameter_dict.value}  ${item.value}
  END
  Return From Keyword If  '${rd_parameter_dict.type}'=='NotPersistent'
  ${reset_response}=  Run Keyword And Continue On Failure  admin.Reset Site
  ...  connection=${bts_id}
  ...  wait_for_reconnection=True
  ...  detailed_output=True
  ...  graceful_cell_shutdown=${False}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp
  ...  message=Second Site Reset for BTS-${bts_id} finished. Response from API: ${reset_response}
  ...  style=DONE
  Run Keyword And Continue On Failure  Wait until keyword succeeds  ${CONFIGURATION_STARTUP_TIMEOUT}  120
  ...  STATE Verify BTS states
  ...  node_id=${bts_id}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${FALSE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=1200
  &{domain_parameter_details}=  admin.Get Rad Debug Parameters
  ...  domain=${rd_domain_name}
  ...  detailed_output=${True}
  ...  connection=${bts_id}
  FOR  ${item}  IN  @{domain_parameter_details.requestMessage.parameters}
    Exit For Loop If  '${item.name}'=='${rd_parameter_dict.name}'
    ${item}=  Set Variable  ${None}
  END
  IF  '${rd_parameter_dict['type']}'=='OneReset'
    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${rd_parameter_dict.value_reset}  ${item.value}
  ELSE
    Run Keyword And Continue On Failure
    ...  Should Be Equal  ${rd_parameter_dict.value}  ${item.value}
  END

Step 6 Restore all Non-Default R&D Debug Parameters values left back to default values
  [Arguments]  ${bts_id}
  [Documentation]
  ...  Description:
  ...  Restore all Non-Default R&D Debug Parameters values left back to default values
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | The BTS identifier.                                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Step 6 Restore all Non-Default R&D Debug Parameters values left back to default values
  ...  style=STEP
  ...  frame=${TRUE}
  &{rad_tmp_dict}=  Create Dictionary  &{EMPTY}
  FOR  ${rd_domain_name}  IN  @{rd_parameters_dict.keys()}
    &{rad_tmp_dict}=  Set To Dictionary
    ...  ${rad_tmp_dict}  name=${rd_parameters_dict.${rd_domain_name}.name}  value=${rd_parameters_dict.${rd_domain_name}.value}
    @{rad_tmp_list}=  Create List  ${rad_tmp_dict}
    Logging With Timestamp
    ...  message=RAD parameter for all provided will be change with this values: &{rad_tmp_dict}
    admin.Set Multiple Rad Debug Parameters
    ...  domain=${rd_domain_name}
    ...  persistency=${rd_parameters_dict.${rd_domain_name}.type}
    ...  rad_parameters=${rad_tmp_list}
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=RAD parameter for ${rd_domain_name} is being changed with this values: &{rad_tmp_dict}
    &{domain_values_details}=  admin.Get Rad Debug Parameters
    ...  domain=${rd_domain_name}
    ...  detailed_output=${True}
    ...  connection=${bts_id}
  END
  Logging With Timestamp
  ...  message=Reset All Rad Debug Parameters will be performed.
  admin.Reset All Rad Debug Parameters
  ...  connection=${bts_id}
  Logging With Timestamp
  ...  message=Reset All Rad Debug Parameters finished.
  FOR  ${rd_domain_name}  IN  @{rd_parameters_dict.keys()}
    &{domain_values_details}=  admin.Get Rad Debug Parameters
    ...  domain=${rd_domain_name}
    ...  detailed_output=${True}
    ...  connection=${bts_id}
    Logging With Timestamp
    ...  message=Current RAD value of domain ${rd_domain_name} = &{domain_values_details}.
  END
