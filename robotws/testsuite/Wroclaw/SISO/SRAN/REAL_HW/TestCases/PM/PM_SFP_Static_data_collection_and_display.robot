*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Purpose of this test is to verify that SFP static parameters are correctly reported in WebEM.
  ...  SFP parameters are predefined in sfp.yaml file
  ...  TC compares values from sfp.yaml and WebEM, values must be the same
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 31.07.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${SFP_YAML_PATH}

*** Keywords ***
TC__PM_SFP_Static_data_collection_and_display
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=FM_PM_SFP_Static_data_collection_and_display.robot will be executed
    ...  style=ONGOING
    Precondition For SFP Static data collection and display
    Step 1: Collects Static Data
    Step 2: Check SFP Static Data Parameters
    [Teardown]  Common Test Teardown

Precondition For SFP Static data collection and display
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test. Check if mandatory file sfp.yaml exist and then imports variables from it
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Precondition For SFP Static data collection and display
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    ${file_exists}  Run Keyword And Return Status
    ...  OperatingSystem.file should exist  ${SFP_YAML_PATH}
    Run Keyword If  '${file_exists}'!='True'
    ...  Fail  SFP.yaml doesn't exists, please create file first !
    ...  ELSE
    ...  Logging With Timestamp  message=File SFP.yaml found in path:${\n}${SFP_YAML_PATH} !${\n}
    Import Variables  ${SFP_YAML_PATH}
    ${links}  admin.Get SFP Links  connection=${BTS_ID}
    ${rf_links}  Set Variable  ${links['connected']}
    Set Test Variable  ${RF_LINKS}

Step 1: Collects Static Data
    [Documentation]
    ...  Description:
    ...  If RRH is ORAN files from RRH (sfp_*.sffcap) are copied to logs
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com
    Logging With Timestamp
    ...  message=Step 1: Collects Static Data
    ...  style=STEP
    ...  frame=${TRUE}
    ${sfps_yaml}  Get Dictionary Keys  ${SFP_STATIC}
    FOR  ${sfp_yaml}  IN  @{sfps_yaml}
      ${sfp_serial_yaml}  Get From Dictionary  ${SFP_STATIC['${sfp_yaml}']}  serialNumber
      Log  ${SFP_STATIC['${sfp_yaml}']['serialNumber']}
      FOR  ${sfp}  IN  @{RF_LINKS}
        ${sfp_serial}  Get From Dictionary  ${sfp['details']['hardwareParameters']['serialNumber']}  source
        ${sfp_serial}  Strip String  ${sfp_serial}
        Continue For Loop If  "${sfp_serial_yaml}"!="${sfp_serial}"
        ${rmod_serial}  Set Variable  ${sfp['parent']['source']['parameters']['serialNumber']}
        Run Keyword If  '${CFG['RF_INFO']['${rmod_serial}']['scf_release_code']}'=='RRH-ORAN'
        ...  Logging With Timestamp  message=RRH is ORAN. File sfp_*.sffcap needed copy to logs.
        ...  ELSE
        ...  Run Keywords
        ...  Logging With Timestamp  message=RRH not ORAN. File sfp_*.sffcap not needed copy to logs.  AND
        ...  Continue For Loop
        ${remote_vm}  Set Variable If  "${CFG['NODES']['${BTS_ID}']['bts_alias_type']}"=="remote"
        ...  ${CFG['NODES']['${BTS_ID}']['vm_ip_LMP_address']}  None
        radio.Open Connection To Radio Module  ru_serial_number=${rmod_serial}  remote_host=${remote_vm}
        radio.Send Command  command=ls /run | grep sfp  delay=1
        ${output}  radio.Read Output  delay=1
        radio.Close SSH Connection
        ${left}  Fetch From Left  ${output}  sfp_
        ${right}  Fetch From Right  ${output}  sfp
        ${output}  Remove String  ${output}  \r
        ${cmd_output_splitted}  Split String  ${output}  \n
        @{file_list}  Create List
        FOR  ${cmd_line}  IN  @{cmd_output_splitted}
          ${sfp_line}  Run Keyword And Return Status  Should Match Regexp  ${cmd_line}  .sffcap
          Run Keyword If  ${sfp_line}  Append To List  ${file_list}  ${cmd_line}
        END
        Create Directory  ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${rmod_serial}
        FOR  ${file_name}  IN  @{file_list}
          ${copy_file_status}  Run Keyword And Return Status
          ...  SSH Get File From Radio Module
          ...  rmod_sn=${rmod_serial}
          ...  file_path=/run/${file_name}
          ...  destination_directory=${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${rmod_serial}
          ...  remote_host=${remote_vm}
          Run Keyword If  ${copy_file_status}
          ...  Logging With Timestamp  message=File ${file_name} succeeded copied to log path ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${rmod_serial}
          ...  ELSE
          ...  Run Keyword And Continue On Failure
          ...  FAIL  File ${file_name} NOT succeeded copied to log path ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${rmod_serial}
        END
        Exit For Loop If  "${sfp_serial_yaml}"=="${sfp_serial}"
      END
    END

Step 2: Check SFP Static Data Parameters
    [Documentation]
    ...  Description:
    ...  Checking if SFP static parameters are the same in WebEM and in file sfp.yaml
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com
    Logging With Timestamp
    ...  message=Step 2: Check SFP Static Data Parameters
    ...  style=STEP
    ...  frame=${TRUE}
    FOR  ${sfp_yaml_serial}  ${sfp_yaml_values}  IN ZIP  ${SFP_STATIC.keys()}  ${SFP_STATIC.values()}
      Logging With Timestamp  message=${\n}Checking: ${sfp_yaml_serial}${\n}
      ${sfp_serial_yaml}  Get From Dictionary  ${sfp_yaml_values}  serialNumber
      ${sfp_direction_yaml}  Get From Dictionary  ${sfp_yaml_values}  physicalPort
      ${direction_details}  Set Variable If  'RF' in '${sfp_direction_yaml}'  destination  source
      ${direction_maxtrans}  Set Variable If  'RF' in '${sfp_direction_yaml}'  0  2
      FOR  ${sfp}  IN  @{RF_LINKS}
        ${source_value}  Get From Dictionary  ${sfp['details']['hardwareParameters']['serialNumber']}  source
        ${source_value}  Strip String  ${source_value}
        ${destination_value}  Get From Dictionary  ${sfp['details']['hardwareParameters']['serialNumber']}  destination
        @{sn_list}  Create List  ${source_value}  ${destination_value}
        Continue For Loop If  '${sfp_serial_yaml}' not in ${sn_list}
        ${details}  Set Variable  ${sfp['details']}
        ${details}  Get Dictionary Values  ${details}
        ${details}  Evaluate  {k: v for d in ${details} for k, v in d.items()}
        ${max_transmission_distance}  Set Variable  ${sfp['details']['staticParameters']['maxTransmissionDistanceList']}
      END
      FOR  ${sfp_yaml_parameter}  ${sfp_yaml_value}  IN ZIP  ${sfp_yaml_values.keys()}  ${sfp_yaml_values.values()}
        Continue For Loop If  '${sfp_yaml_parameter}'=='maxTransmissionDistanceList'
        ${admin_value}  Get From Dictionary  ${details}  ${sfp_yaml_parameter}
        ${admin_value}  Get From Dictionary  ${admin_value}  ${direction_details}
        ${admin_value}  Evaluate  '${admin_value}'.strip()
        ${is_int}  Evaluate  isinstance($sfp_yaml_value, (int, float))
        ${status}  Run Keyword And Return Status  Run Keyword If  ${is_int}
        ...  Should Be Equal As Numbers  ${admin_value}  ${sfp_yaml_value}
        ...  ELSE
        ...  Should Be Equal As Strings  ${admin_value}  ${sfp_yaml_value}
        Run Keyword If  ${status}
        ...  Logging With Timestamp  message=${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value} -> OK !
        ...  ELSE
        ...  Run Keywords
        ...  Logging With Timestamp  message=${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value} -> NOK !
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${sfp_yaml_parameter} mismatch between SFP_STATIC_YAML and WebEM !
      END
      ${max_trans_yaml}  Get From Dictionary  ${sfp_yaml_values}  maxTransmissionDistanceList
      ${max_trans_yaml}  Evaluate  {k: v for d in ${max_trans_yaml} for k, v in d.items()}
      FOR  ${max_dict}  IN  @{max_transmission_distance}
        ${values}  Get Dictionary Values  ${max_dict}
        ${values}  Get Dictionary Values  ${values}[${direction_maxtrans}]
        ${yaml_length}  Get From Dictionary  ${max_trans_yaml}  ${values}[1]
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${values}[0]  ${yaml_length}
        Run Keyword If  ${status}
        ...  Logging With Timestamp  message=${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> OK !
        ...  ELSE
        ...  Run Keywords
        ...  Logging With Timestamp  message=${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> NOK !
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${values}[1] mismatch between SFP YAML and WebEM !
      END
    END