*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Purpose of this test is to verify that SFP dynamic parameters are correctly displaed in WebEM.
  ...  SFP parameters are predefined in sfp.yaml file
  ...  TC compares values from sfp.yaml and WebEM, values must be the same
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 12.08.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${SFP_YAML_PATH}


*** Keywords ***
TC__PM_SFP_Dynamic_data_collection_and_display
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=PM_SFP_Dynamic_data_collection_and_display.robot will be executed
    ...  style=ONGOING
    Step 1: Preparing Variables For SFP Dynamic data collection and display
    Step 2: Check SFP Dynamic Data Parameters
    [Teardown]  Common Test Teardown

Step 1: Preparing Variables For SFP Dynamic data collection and display
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test. Check if mandatory file sfp.yaml exist and then imports variables from it
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 1: Preparing Variables For SFP Dynamic data collection and display
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    ${file_exists}  Run Keyword And Return Status
    ...  OperatingSystem.file should exist  ${SFP_YAML_PATH}
    Run Keyword If  '${file_exists}'!='True'
    ...  Fail  SFP.yaml doesn't exists, please create file first !
    ...  ELSE
    ...  Logging With Timestamp  message=File SFP.yaml found in path:${SFP_YAML_PATH} !
    Import Variables  ${SFP_YAML_PATH}
    ${links}  admin.Get SFP Links  connection=${BTS_ID}
    @{SFP_WEBEM_PARAMETERS}  Create List  moduleTemperature  TXSupplyVoltage  TXBiasCurrent  TXOpticalPowerUW  RXOpticalPowerUW
    @{SFP_RND_PARAMETERS}  Create List  sfpTecCurrent  laserTemp
    Set Test Variable  ${SFP_WEBEM_PARAMETERS}
    Set Test Variable  ${SFP_RND_PARAMETERS}
    ${rf_links}  Set Variable  ${links['connected']}
    Set Test Variable  ${RF_LINKS}

Step 2: Check SFP Dynamic Data Parameters
    [Documentation]
    ...  Description:
    ...  Checking if SFP dynamic parameters are in range in WebEM and in file sfp.yaml
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 2: Check SFP Dynamic Data Parameters
    ...  style=STEP
    ...  frame=${TRUE}
    ${sfps_yaml}  Get Dictionary Keys  ${SFP_DYNAMIC}
    FOR  ${sfp_yaml}  IN  @{sfps_yaml}
      ${sfp_serial_yaml}  Get From Dictionary  ${SFP_DYNAMIC['${sfp_yaml}']}  serialNumber
      Logging With Timestamp  message=Checking: ${sfp_yaml}
      FOR  ${sfp}  IN  @{RF_LINKS}
        ${sfp_serial}  Get From Dictionary  ${sfp['details']['hardwareParameters']['serialNumber']}  source
        ${sfp_serial}  Strip String  ${sfp_serial}
        Continue For Loop If  "${sfp_serial_yaml}"!="${sfp_serial}"
        Check If Dynamic WebEM Parameter Is In Range  ${sfp_yaml}  ${sfp['data']['measurements']}
        ${sfp_distname_l}  Get From Dictionary  ${sfp}  sourceConnectorL
        ${sfp_rnd}  Get Parameters  ${sfp_distname_l}/SFP_L-1/SFP_PARAMS_L-1  connection=${BTS_ID}
        Check If Dynamic RnD Parameter Is In Range  ${sfp_yaml}  ${sfp_rnd}
        Exit For Loop If  "${sfp_serial_yaml}"=="${sfp_serial}"
      END
    END

Check If Dynamic WebEM Parameter Is In Range
    [Documentation]
    ...  Description:
    ...  Checking if SFP dynamic parameters are in range in WebEM and in file sfp.yaml
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    [Arguments]  ${sfp_yaml}  ${sfp_webem}
    Logging With Timestamp  message=Checking If Dynamic WebEM Parameter Is In Range
    FOR  ${sfp_webem_parameter}  IN  @{SFP_WEBEM_PARAMETERS}
      ${status}  ${message}  Run Keyword And Ignore Error  Variable Should Exist  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}
      Run Keyword If  "${status}"=="PASS"
      ...  Logging With Timestamp  message=Checking ${sfp_webem_parameter} parameter
      ...  ELSE
      ...  Run Keyword And Continue on Failure
      ...  Fail  Missing variable ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']} for ${sfp_yaml} in file ${SFP_YAML_PATH}
      ${tested_value}  Get From Dictionary  ${sfp_webem['${sfp_webem_parameter}']}  source
      ${tested_value_type}  Evaluate  isinstance(${tested_value}, list)
      ${tested_value}  Set Variable If  ${tested_value_type}  ${tested_value[0]}  ${tested_value}
      Run Keyword IF  "${tested_value}"=="-" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}"=="-"  Run Keywords
      ...  Logging With Timestamp  message=${sfp_webem_parameter} parameter not suported.  AND
      ...  Continue For Loop
      ${status1}  Evaluate  "${tested_value}"=="-" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}"!="-"
      ${status2}  Evaluate  "${tested_value}"!="-" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}"=="-"
      Run Keyword IF  ${status1} or ${status2}  Run Keywords
      ...  Logging With Timestamp  message=Parameter ${sfp_webem_parameter} mismatch between SFP_YAML and WebEM !  AND
      ...  Run Keyword And Continue On Failure
      ...  Fail  Parameter ${sfp_webem_parameter} mismatch between SFP_YAML and WebEM !  AND
      ...  Continue For Loop
      ${min_value}  Get From List  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}  0
      ${max_value}  Get From List  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_webem_parameter}']}  1
      Run Keyword If  ${min_value}<=${tested_value} and ${max_value}>=${tested_value}
      ...  Logging With Timestamp
      ...  message=${sfp_webem_parameter} -> WebEM: ${tested_value} | is in range of SFP_YAML: <${min_value}:${max_value}> -> OK !
      ...  ELSE
      ...  Run Keywords
      ...  Logging With Timestamp
      ...  message=${sfp_webem_parameter} -> WebEM: ${tested_value} | is NOT in range of SFP_YAML: <${min_value}:${max_value}> -> NOK !
      ...  AND  Run Keyword And Continue On Failure
      ...  Fail  Parameter ${sfp_webem_parameter} mismatch between SFP_YAML and WebEM !
    END

Check If Dynamic RnD Parameter Is In Range
    [Documentation]
    ...  Description:
    ...  Checking if SFP dynamic parameters are in range in R&D and in file sfp.yaml
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    [Arguments]  ${sfp_yaml}  ${sfp_rnd}
    Logging With Timestamp  message=Checking If Dynamic R&D Parameter Is In Range
    FOR  ${sfp_rnd_parameter}  IN  @{SFP_RND_PARAMETERS}
      ${status}  ${message}  Run Keyword And Ignore Error  Variable Should Exist  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']}
      Run Keyword If  "${status}"=="PASS"
      ...  Logging With Timestamp  message=Checking ${sfp_rnd_parameter} parameter
      ...  ELSE
      ...  Run Keyword And Continue on Failure
      ...  Fail  Missing variable ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']} for ${sfp_yaml} in file ${SFP_YAML_PATH}
      ${tested_value}  Get From Dictionary  ${sfp_rnd}  ${sfp_rnd_parameter}
      ${tested_value_type}  Evaluate  isinstance(${tested_value}, list)
      ${tested_value}  Set Variable If  ${tested_value_type}  ${tested_value[0]}  ${tested_value}
      Run Keyword IF  "${tested_value}"=="None" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']}"=="None"  Run Keywords
      ...  Logging With Timestamp  message=${sfp_rnd_parameter} parameter not suported.  AND
      ...  Continue For Loop
      ${status1}  Evaluate  "${tested_value}"=="None" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']}"!="None"
      ${status2}  Evaluate  "${tested_value}"!="None" and "${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']}"=="None"
      Run Keyword IF  ${status1} or ${status2}  Run Keywords
      ...  Logging With Timestamp  message=Parameter ${sfp_rnd_parameter} mismatch between SFP_YAML and WebEM !  AND
      ...  Run Keyword And Continue On Failure
      ...  Fail  Parameter ${sfp_rnd_parameter} mismatch between SFP_YAML and WebEM !  AND
      ...  Continue For Loop
      ${min_value}  Get From List  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']}  0
      ${max_value}  Get From List  ${SFP_DYNAMIC['${sfp_yaml}']['${sfp_rnd_parameter}']}  1
      Run Keyword If  ${min_value}<=${tested_value} and ${max_value}>=${tested_value}
      ...  Logging With Timestamp
      ...  message=${sfp_rnd_parameter} -> WebEM: ${tested_value} | is in range of SFP_YAML: <${min_value}:${max_value}> -> OK !
      ...  ELSE
      ...  Run Keywords
      ...  Logging With Timestamp
      ...  message=${sfp_rnd_parameter} -> WebEM: ${tested_value} | is NOT in range of SFP_YAML: <${min_value}:${max_value}> -> NOK !
      ...  AND  Run Keyword And Continue On Failure
      ...  Fail  Parameter ${sfp_rnd_parameter} mismatch between SFP_YAML and WebEM !
    END