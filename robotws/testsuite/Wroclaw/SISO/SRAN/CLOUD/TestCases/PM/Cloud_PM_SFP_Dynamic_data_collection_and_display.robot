*** Settings ***
Documentation
  ...  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...

Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio
Library    BuiltIn
Library    OperatingSystem

*** Variables ***
${SFP_YAML_PATH}

*** Keywords ***
TC__Cloud_PM_SFP_Dynamic_data_collection_and_display
    [Arguments]  ${vdu_scfc_file_path}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Basic information
    ...  *****************
    ...  Purpose of this test is to verify that SFP dynamic parameters are correctly displayed in vDU WebEM.
    ...  SFP parameters are predefined in sfp.yaml file
    ...  TC compares values from sfp.yaml and vDU WebEM, values must be the same
    ...  ******************
    ...  Tester should prepare sfp.yaml (${SFP_YAML_PATH}) file with proper dynamic parameters ranges before test execution.
    ...  Example:
    ...  SFP_DYNAMIC  :
    ...     SFP_FR231333374:
    ...         serial_number       :    FR241010202
    ...         physical_port       :    RF1
    ...         module_temperature  :    [-50,95]
    ...         tx_supply_voltage    :    [3200,3400]
    ...         tx_bias_current      :    [6,8]
    ...         tx_optical_power_uw   :    [400,600]
    ...         tx_optical_power_dbm   :    [-1,-3]
    ...         rx_optical_power_dbm   :    [-1,-3]
    ...         rx_optical_power_uw    :    [400,500]
    ...
    ...  Test Steps
    ...  Step 1: Preparing Variables For SFP Dynamic data collection and display
    ...  Step 2: Check SFP Dynamic Data Parameters
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | vdu_scfc_file_path     | Yes  | Path to the vDU scfc file.                                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | vdu_connection         |  No  | Alias for vdu connection, sets to 'default                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | If True, logs will be printed to console. Default is True.                 |
    ...  +========================+======+============================================================================+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Set Tags  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
    Set Test Variable  ${vdu_scfc_file_path}
    Set Test Variable  ${vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: Cloud_PM_SFP_Dynamic_data_collection_and_display  console=${log_to_console}
    Step 1: Preparing Variables For SFP Dynamic data collection and display
    Step 2: Check SFP Dynamic Data Parameters

Step 1: Preparing Variables For SFP Dynamic data collection and display
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test. Check if mandatory file sfp.yaml exist and then imports variables from it
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_blue}Step 1: Preparing Variables For SFP Dynamic data collection and display  console=${log_to_console}
    vDU Rest Login  vdu_connection=${vdu_connection}
    ${file_exists}  Run Keyword And Return Status
    ...  OperatingSystem.file should exist  ${SFP_YAML_PATH}
    Run Keyword If  '${file_exists}'!='True'
    ...  Fail  SFP.yaml doesn't exists, please create file first !
    ...  ELSE
    ...  Log  ${info_prefix}File SFP.yaml found in path:${SFP_YAML_PATH} !  console=${log_to_console}
    Import Variables  ${SFP_YAML_PATH}
    ${rf_links}  vdu.Get Diagnostic Info From Sfp Connections  vdu_connection=${vdu_connection}
    @{SFP_WEBEM_PARAMETERS}  Create List  module_temperature  tx_supply_voltage
    ...  tx_bias_current  tx_optical_power_uw  tx_optical_power_dbm  rx_optical_power_uw  rx_optical_power_dbm
    Set Test Variable  ${SFP_WEBEM_PARAMETERS}
    Set Test Variable  ${RF_LINKS}  ${rf_links}
    Log  ${end_prefix_blue}Step 1: Preparing Variables For SFP Dynamic data collection and display  console=${log_to_console}

Step 2: Check SFP Dynamic Data Parameters
    [Documentation]
    ...  Description:
    ...  Checking if SFP dynamic parameters are in range in vDU WebEM and in file sfp.yaml
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Log  ${start_prefix_blue}Step 2: Check SFP Dynamic Data Parameters  console=${log_to_console}
    ${sfps_yaml}  Get Dictionary Keys  ${SFP_DYNAMIC}
    FOR  ${sfp_yaml}  IN  @{sfps_yaml}
      ${sfp_serial_yaml}  Get From Dictionary  ${SFP_DYNAMIC['${sfp_yaml}']}  serial_number
      Log  ${info_prefix}Checking: ${sfp_yaml}  console=${log_to_console}
      FOR  ${sfp}  IN  @{RF_LINKS}
        ${sfp_serial}  Get From Dictionary  ${sfp}  serial_number
        ${sfp_serial}  Strip String  ${sfp_serial}
        Continue For Loop If  "${sfp_serial_yaml}"!="${sfp_serial}"
        Check If Dynamic WebEM Parameter Is In Range  ${sfp_yaml}  ${sfp['dynamic_data_for_lane']}
        Exit For Loop If  "${sfp_serial_yaml}"=="${sfp_serial}"
      END
    END
    Log  ${end_prefix_blue}Step 2: Check SFP Dynamic Data Parameters  console=${log_to_console}


Check If Dynamic WebEM Parameter Is In Range
    [Documentation]
    ...  Description:
    ...  Checking if SFP dynamic parameters are in range in vDU WebEM and in file sfp.yaml
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    [Arguments]  ${sfp_yaml}  ${sfp_webem}
    Log  ${start_prefix_blue}Check If Dynamic WebEM Parameter Is In Range  console=${log_to_console}
    FOR  ${sfp_webem_parameter}  IN  @{SFP_WEBEM_PARAMETERS}
      ${status}  ${message}  Run Keyword And Ignore Error  Variable Should Exist  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}
      Run Keyword If  "${status}"=="PASS"
      ...  Log  ${info_prefix}Checking ${sfp_webem_parameter} parameter  console=${log_to_console}
      ...  ELSE
      ...  Run Keyword And Continue on Failure
      ...  Fail  Missing variable ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']} for ${sfp_yaml} in file ${SFP_YAML_PATH}
      ${tested_value}  Get From Dictionary  ${sfp_webem}[0]  ${sfp_webem_parameter}
      ${tested_value_type}  Evaluate  isinstance(${tested_value}, list)
      ${tested_value}  Set Variable If  ${tested_value_type}  ${tested_value[0]}  ${tested_value}
      Run Keyword IF  "${tested_value}"=="-" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}"=="-"  Run Keywords
      ...  Log  ${info_prefix}${sfp_webem_parameter} parameter not suported.  console=${log_to_console}
      ...  AND  Continue For Loop
      ${status1}  Evaluate  "${tested_value}"=="-" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}"!="-"
      ${status2}  Evaluate  "${tested_value}"!="-" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}"=="-"
      Run Keyword IF  ${status1} or ${status2}  Run Keywords
      ...  Log  ${info_prefix}Parameter ${sfp_webem_parameter} mismatch between SFP_YAML and WebEM !  AND
      ...  Run Keyword And Continue On Failure
      ...  Fail  Parameter ${sfp_webem_parameter} mismatch between SFP_YAML and WebEM !  AND
      ...  Continue For Loop
      ${min_value}  Get From List  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}  0
      ${max_value}  Get From List  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}  1
      Run Keyword If  ${min_value}<=${tested_value} and ${max_value}>=${tested_value}
      ...  Log  ${info_prefix}${sfp_webem_parameter} -> WebEM: ${tested_value} | is in range of SFP_YAML: <${min_value}:${max_value}> -> OK !
      ...  console=${log_to_console}
      ...  ELSE
      ...  Run Keywords
      ...  Log  ${info_prefix}${sfp_webem_parameter} -> WebEM: ${tested_value} | is NOT in range of SFP_YAML: <${min_value}:${max_value}> -> NOK !
      ...  console=${log_to_console}
      ...  AND  Run Keyword And Continue On Failure
      ...  Fail  Parameter ${sfp_webem_parameter} mismatch between SFP_YAML and WebEM !
    END
    Log  ${end_prefix_blue}Check If Dynamic WebEM Parameter Is In Range  console=${log_to_console}
