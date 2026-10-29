*** Settings ***
Documentation
  ...  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/

Library    BuiltIn
Library    OperatingSystem
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library     ../../../resources/radio_operations/RadioOperations.py  WITH NAME  radio

*** Variables ***
${SFP_YAML_PATH}

*** Keywords ***
TC__Cloud_PM_SFP_Static_data_collection_and_display
    [Arguments]  ${vdu_scfc_file_path}  ${vdu_connection}=default  ${log_to_console}=True
    [Documentation]
    ...
    ...  Purpose of this test is to verify that SFP static parameters are correctly reported in vDU Webem.
    ...  SFP parameters are predefined in sfp.yaml file
    ...  TC compares values from sfp.yaml and WebEM, values must be the same.
    ...
    ...  Tester needs to create sfp.yaml fire (variable ${SFP_YAML_PATH}) before test execution. All SFPs
    ...  that are connected to the RMODs must be described in this file.
    ...  The structure of sfp.yaml file is like below:
    ...  SFP_STATIC:
    ...    SFP_FR241010202:
    ...    vendor_name                      :    WTD
    ...    vendor_part_number               :    RTXM228-554-C20A
    ...    vendor_revision                  :    1.0
    ...    serial_number                    :    FR241010202
    ...    connector_type                   :    LC
    ...    sfp_wavelength                   :    850
    ...    sfp_nominal_signaling_rate       :    10300
    ...    compliance_code                  :    SFF_8472_REV_12_3
    ...    transceiver_compliance_code      :    10GBASE_SR
    ...    manufacturing_date               :    240313
    ...    cooled_transceiver_declaration   :    AOP
    ...    nokia_part_number                :    "-"
    ...    physical_port                    :    OPT_IF1
    ...    transceiver_identifier           :    SFP_SFP_PLUS_SFP28_AND_LATER
    ...    product_code                     :    475336A
    ...    tx_power_high_alarm_threshold    :    2
    ...    tx_power_low_alarm_threshold     :    -7
    ...    tx_power_high_warn_threshold     :    -1
    ...    tx_power_low_warn_threshold      :    -4
    ...    rx_power_high_alarm_threshold    :    2
    ...    rx_power_low_alarm_threshold     :    -14
    ...    rx_power_high_warn_threshold     :    -1
    ...    rx_power_low_warn_threshold      :    -11
    ...    temperature_high_alarm_threshold :    88
    ...    temperature_low_alarm_threshold  :    -43
    ...    max_transmission_distance      :
    ...    - Length (SMF,km): "-"
    ...    - Length (SMF): "-"
    ...    - Length (50um): 8
    ...    - Length (62.5um): 3
    ...    - Length (OM4 or copper cable): "-"
    ...    - Length (OM3): 30
    ...
    ...  Test Steps:
    ...  Step 1: Precondition For SFP Static data collection and display
    ...  Step 2: Collects Static Data
    ...  Step 3: Check SFP Static Data Parameters
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
    Log  ${start_prefix_green}Test Case: Cloud_PM_SFP_Static_data_collection_and_display  console=${log_to_console}

    Step 1: Precondition For SFP Static data collection and display
    Step 2: Collects Static Data
    Step 3: Check SFP Static Data Parameters
    Log  ${done_prefix_green}Test Case: Cloud_PM_SFP_Static_data_collection_and_display  console=${log_to_console}


Step 1: Precondition For SFP Static data collection and display
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test. Check if mandatory file sfp.yaml exist and then imports variables from it
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Log    ${start_prefix_blue}Step 1: Precondition For SFP Static data collection and display    console=${log_to_console}
    vDU Rest Login  vdu_connection=${vdu_connection}
    ${mrbts_id}  vDU Get MRBTS Id  vdu_connection=${vdu_connection}
    Set Test Variable  ${MRBTS_ID}  ${mrbts_id}
    ${vdu_k8s_connection_params}  Get vDU K8s Master Node Connection Parameters From Init File
    Set Test Variable  ${CLOUD_SERVER_IP}  ${vdu_k8s_connection_params['ip_addr']}
    ${file_exists}  Run Keyword And Return Status
    ...  OperatingSystem.file should exist  ${SFP_YAML_PATH}
    Run Keyword If  '${file_exists}'!='True'
    ...  Fail  SFP.yaml doesn't exists, please create file first !
    ...  ELSE
    ...  Log  ${info_prefix}File SFP.yaml found in path:${\n}${SFP_YAML_PATH} !${\n}  console=${log_to_console}
    Import Variables  ${SFP_YAML_PATH}
    ${rf_links}  vdu.Get Diagnostic Info From Sfp Connections  vdu_connection=${vdu_connection}
    FOR  ${item}  IN  @{rf_links}
      Log  ${item}
    END
    Set Test Variable  ${rf_links}
    Log   ${done_prefix_blue}Step 1: Precondition For SFP Static data collection and display    console=${log_to_console}

Step 2: Collects Static Data
    [Documentation]
    ...  Description:
    ...  If RRH is ORAN files from RRH (sfp_*.sffcap) are copied to logs
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Log  ${start_prefix_blue}Step 2: Collects Static Data    console=${log_to_console}
    ${sfps_yaml}  Get Dictionary Keys  ${SFP_STATIC}
    ${rmod_status}    Get Rmods Status    vdu_connection=${vdu_connection}
    FOR  ${sfp_yaml}  IN  @{sfps_yaml}
      ${sfp_serial_yaml}  Get From Dictionary  ${SFP_STATIC['${sfp_yaml}']}  serial_number
      Log  ${SFP_STATIC['${sfp_yaml}']['serial_number']}
      FOR  ${sfp}  IN  @{RF_LINKS}
        ${sfp_found}    Set Variable    ${False}
        Log  ${sfp}
        ${sfp_serial}  Get From Dictionary  ${sfp}  serial_number
        ${sfp_serial}  Strip String  ${sfp_serial}
        Continue For Loop If  "${sfp_serial_yaml}"!="${sfp_serial}"
        ${sfp_dn_config}  Set Variable  ${sfp['dist_names']['config']}
        IF  '${sfp_dn_config}' == 'None'
           Continue For Loop
        END
        FOR    ${rmod}    IN    @{rmod_status}
          ${rmod_dn_config}    Set Variable    ${rmod['dist_names']['config']}
          ${dn_ok}    Evaluate    "${rmod_dn_config}" in "${sfp_dn_config}"
          Continue For Loop If  not ${dn_ok}
          ${sfp_found}    Set Variable    ${True}
          Exit For Loop
        END
        IF    not ${sfp_found}
          Fail    SFP with serial number ${sfp_serial} not found in RMOD status list !
        END
        FOR    ${rmod}    IN    @{rmod_status}
          ${rmod_dn_config}    Set Variable    ${rmod['dist_names']['config']}
          ${dn_ok}    Evaluate    "${rmod_dn_config}" in "${sfp_dn_config}"
          Continue For Loop If  not ${dn_ok}
          Run Keyword If  '${rmod['hardware_release']}'=='RRH-ORAN'
          ...  Log  ${info_prefix}RRH is ORAN. File sfp_*.sffcap needs to be copied to logs.  console=${log_to_console}
          ...  ELSE
          ...  Run Keywords
          ...  Log  ${info_prefix}RRH not ORAN. File sfp_*.sffcap does not need to be copied to logs.  console=${log_to_console}
          ...  AND  Continue For Loop
          radio.Open Connection To Radio Module  ru_serial_number=${rmod['serial_number']}  cloud_server_ip=${CLOUD_SERVER_IP}
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
          Create Directory  ${SUITE_LOGS_DIR_PATH}/${rmod['serial_number']}_sffcap_files
          FOR  ${file_name}  IN  @{file_list}
              Wait Until Keyword Succeeds   60  5  radio.Send File Via SCP
              ...  ru_serial_number=${rmod['serial_number']}
              ...  direction=to_container
              ...  file_path=/run/${file_name}
              ...  destination_directory=/tmp
              ...  cloud_server_ip=${cloud_server_ip}
              Log  ${info_prefix}Downloading ${file_name}  console=${log_to_console}
              tafssh.Connect To  hostname=${cloud_server_ip}
              ...  username=core
              ...  password=system123
              ...  alias=primary
              tafssh.Send Command  kubectl cp -n cran1 ${VDU_POD_NAME}-oamfh-0:"/tmp/${file_name}" -c ctr-oamfh "/tmp/${file_name}"
              ...  connection=primary
              tafssh.Read Output  connection=primary
              tafssh.Download File  remote_path=/tmp/${file_name}
              ...  local_path=${SUITE_LOGS_DIR_PATH}/${rmod_serial}_sffcap_files/${file_name}
              ...  connection=primary
              ${file_exists}  tafssh.File Exists ${SUITE_LOGS_DIR_PATH}/${rmod_serial}_sffcap_files/${file_name}  connection=primary
              Should Be True  ${file_exists}
              Log  ${info_prefix}File ${file_name} downloaded to ${SUITE_LOGS_DIR_PATH}/${rmod_serial}_sffcap_files/  console=${log_to_console}
              tafssh.Send Command  rm /tmp/${file_name}  connection=primary
              radio.Close SSH Connection
          END
        END
      END
    END
    Log   ${done_prefix_blue}Step 2: Collects Static Data    console=${log_to_console}

Step 3: Check SFP Static Data Parameters
    [Documentation]
    ...  Description:
    ...  Checking if SFP static parameters are the same in vDU WebEM and in file sfp.yaml
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Log  ${start_prefix_blue}Step 3: Check SFP Static Data Parameters    console=${log_to_console}
    FOR  ${sfp_yaml_serial}  ${sfp_yaml_values}  IN ZIP  ${SFP_STATIC.keys()}  ${SFP_STATIC.values()}
      ${sfp_serial_yaml}  Get From Dictionary  ${sfp_yaml_values}  serial_number
      ${sfp_direction_yaml}  Get From Dictionary  ${sfp_yaml_values}  physical_port
      ${direction_details}  Set Variable If  'RF' in '${sfp_direction_yaml}'  destination  source
      ${direction_maxtrans}  Set Variable If  'RF' in '${sfp_direction_yaml}'  0  2
      FOR  ${sfp}  IN  @{RF_LINKS}
        ${sfp_serial}  Get From Dictionary  ${sfp}  serial_number
        ${sfp_serial}  Strip String  ${sfp_serial}
        Continue For Loop If  "${sfp_serial_yaml}"!="${sfp_serial}"
        ${max_transmission_distance}  Set Variable  ${sfp['max_transmission_distance']}
          FOR  ${sfp_yaml_parameter}  ${sfp_yaml_value}  IN ZIP  ${sfp_yaml_values.keys()}  ${sfp_yaml_values.values()}
            Log  ${sfp_yaml_parameter} : ${sfp_yaml_value}
            Continue For Loop If  '${sfp_yaml_parameter}'=='max_transmission_distance'
            ${admin_value}  Get From Dictionary  ${sfp}  ${sfp_yaml_parameter}
            ${admin_value}  Evaluate  '${admin_value}'.strip()
            ${is_int}  Evaluate  isinstance($sfp_yaml_value, (int, float))
            ${status}  Run Keyword And Return Status  Run Keyword If  ${is_int}
            ...  Should Be Equal As Numbers  ${admin_value}  ${sfp_yaml_value}
            ...  ELSE
            ...  Should Be Equal As Strings  ${admin_value}  ${sfp_yaml_value}
            Run Keyword If  ${status}
            ...  Log  ${info_prefix}${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value} -> OK !  console=${log_to_console}
            ...  ELSE
            ...  Run Keywords
            ...  Log  ${info_prefix}${sfp_yaml_parameter} -> SFP_YAML: ${sfp_yaml_value} | WebEM: ${admin_value} -> NOK !  console=${log_to_console}
            ...  AND  Run Keyword And Continue On Failure
            ...  Fail  Parameter ${sfp_yaml_parameter} mismatch between SFP_STATIC_YAML and WebEM !
          END
        END
      ${max_trans_yaml}  Get From Dictionary  ${sfp_yaml_values}  max_transmission_distance
      ${max_trans_yaml}  Evaluate  {k: v for d in ${max_trans_yaml} for k, v in d.items()}
      FOR  ${max_dict}  IN  @{max_transmission_distance}
        ${values}  Get Dictionary Values  ${max_dict}
        ${yaml_length}  Get From Dictionary  ${max_trans_yaml}  ${values}[1]
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${values}[0]  ${yaml_length}
        Run Keyword If  ${status}
        ...  Log  ${info_prefix}${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> OK !  console=${log_to_console}
        ...  ELSE
        ...  Run Keywords
        ...  Log  ${info_prefix}${values}[1] -> SFP_YAML: ${yaml_length} | WebEM: ${values}[0] -> NOK !  console=${log_to_console}
        ...  AND  Run Keyword And Continue On Failure
        ...  Fail  Parameter ${values}[1] mismatch between SFP YAML and WebEM !
      END
    END
    Log  ${done_prefix_blue}Step 3: Check SFP Static Data Parameters    console=${log_to_console}
