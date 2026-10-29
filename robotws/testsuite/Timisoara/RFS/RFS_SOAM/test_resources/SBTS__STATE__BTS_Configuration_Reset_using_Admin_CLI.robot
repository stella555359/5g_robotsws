*** Settings ***
Documentation    TC__SBTS__STATE__BTS_Configuration_Reset_using_Admin_CLI
Variables   tc_variables/sbts__state__bts_configuration_reset_using_admin_cli_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${CONFIG_RESET_KPI}   600  # Max allowed duration for Configuration Reset KPI, in seconds
${BTS_MAX_WAIT_TIME}  900  # Max wait time for BTS to reach OnAir state after PnP start, in seconds

*** Keywords ***
TC__SBTS__STATE__BTS_Configuration_Reset_using_Admin_CLI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30304
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for BTS Configuration Reset using Admin CLI
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - perform BTS Configuration Reset using Admin CLI
    ...    - send command via Admin CLI for Configuration Reset
    ...    - wait for BTS to become unreachable and reachable again
    ...    - establish connection to BTS after Configuration Reset
    ...    - activate primary partition on BTS after Configuration Reset
    ...    - wait for BTS to become unreachable and reachable again
    ...    - check BTS state and alarms after SW Activation completed
    ...    - check KPI for Configuration Reset on BTS
    ...  - check final BTS state and alarms
    ...  - check final number and state of Cells and RMs
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30304 - [CB007500] Execute shell script to trigger
    ...  configuration reset (using admin cli)
    ...

    Set Tags    CA-STATE    OWNER-ancuta.muresan@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-CRT    SW-SBTS26R2

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Perform BTS Configuration Reset using Admin CLI
    Step 4: Check final BTS state
    Step 5: Check final BTS alarms
    Step 6: Check final number and state of Cells and RMs

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    Log  Step ${index}: Check ${when} BTS state  console=True
    rfs_admin.Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    rfs_admin.Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get from Admin

    Log  Step ${index}: Check ${when} BTS alarms  console=True
    rfs_frame_rfs_common.Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias_local.upper()}_CRITICAL_ALARMS']}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Perform BTS Configuration Reset using Admin CLI
    [Documentation]
    ...  Perform BTS Configuration Reset using Admin CLI

    Log  Step ${index}: Perform BTS Configuration Reset using Admin CLI  console=True

    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${hostname_ip}=  Set Variable  ${${alias_local.upper()}}[${alias_local.upper()}_TECH_IP_ADDRESS]

    ${BTS_mplane_ip}=  Get BTS M-Plane IP
    rfs_admin.Admin Get BTS SW Version  ${alias_local}

    Log  Check and set actCli parameter to true on BTS ${alias_local} before Configuration Reset  console=True
    ${actCli_initial}=  rfs_general.Get actCli parameter value  ${alias_local}
    Run Keyword If  '${actCli_initial}' == 'false'
    ...  rfs_general.Set actCli parameter value  true  ${alias_local}
    Set Test Variable  ${ACTCLI_INITIAL}  ${actCli_initial}

    admin_cli.Setup Admin CLI  ${${alias_local} active SW}  ${BTS_mplane_ip}

    Get RESET timestamp info  when=start_config_reset

    Log  Sending command via Admin CLI for BTS Configuration Reset  console=True
    ${request}=  Create Long String  {"requestId":100,"parameters":{"name":"configurationReset","parameters":
    ...  {"resetType":"ConfigurationWithDiagnosticAndRecoverySw"}}}
    ${request_status}  ${error_code}  ${request_message}=  Admin CLI Send Request  ${request}
    Run Keyword If  '${request_status}' == 'completed'
    ...  Log  Command sent with status: ${request_status}  console=True
    ...  ELSE
    ...  Fail  Command sent with status: ${request_status} and error code: ${error_code}

    Get RESET timestamp info  when=end_config_reset

    rfs_general.Wait For Target To Be Not Reachable TAF  hostname=${BTS_mplane_ip}  timeout=300  remote_host=None
    rfs_general.Wait For Target To Be Reachable TAF  hostname=${BTS_mplane_ip}  timeout=600  remote_host=None

    Log  Establish connection to BTS ${alias_local} after Configuration Reset  console=True
    ${result}=  Run Keyword And Return Status  rc.Connect To  ip_address=${hostname_ip}  port=443  username=Nemuadmin  password=nemuuser
    ...  auto_discover=True  secure=True  name=default
    Run Keyword If  ${result}
    ...  Log  Connection to BTS ${alias_local} successfully established!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Could not establish connection to BTS ${alias_local} after Reset Configuration.  level=ERROR
    ...  AND  Fail  Could not establish connection to BTS ${alias_local} after Reset Configuration.
    Set Test Variable  ${RC_CONNECTION}  True

    Log  Activate primary partition on BTS ${alias_local} after Configuration Reset  console=True
    ${slot_id}=  rc.Get Active SW Partition  connection=default
    @{reset_options}=  rc.Get Available Reset Options  slot_id=${slot_id}  connection=default
    rc.Software Rollback  sw_slot_id=${slot_id}  connection=default

    rfs_general.Wait For Target To Be Not Reachable TAF  hostname=${BTS_mplane_ip}  timeout=300  remote_host=None
    rfs_general.Wait For Target To Be Reachable TAF  hostname=${BTS_mplane_ip}  timeout=600  remote_host=None

    Wait Until Keyword Succeeds  3x  60s  Admin reset and Infomodel reconnect sessions  reset_req=True  alias=${alias_local}  infomodel_reset=False
    Set Test Variable  ${RC_CONNECTION}  False

    Log  Check BTS ${alias_local} state and alarms after SW Activation completed  console=True
    rfs_admin.Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${alias_local}
    Log  BTS ${alias_local} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    rfs_admin.Check cells availability status online  ${alias_local}  ${BTS_MAX_WAIT_TIME}
    Log  All cells states:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${alias_local} alarms:  console=True
    rfs_frame_rfs_common.Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${test_alarms_list['${alias_local.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias_local.upper()}_CRITICAL_ALARMS']}
    Log  BTS ${alias_local} site - expected, ignored and critical alarms checked  console=True

    Log  Check KPI for Configuration Reset on BTS ${alias_local}  console=True
    Check BTS KPI  start_time=${date_timestamp_start_config_reset_UTC}  end_time=${date_timestamp_end_config_reset_UTC}
    ...  operation_description=Configuration Reset  expected_value=${CONFIG_RESET_KPI}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    rfs_frame_rfs_soam_taf.RFS Test Case Final Checks


Get BTS M-Plane IP
    [Documentation]  Returns the BTS M-Plane IP

    ${ip}=  Get Variable Value  ${${alias_local.upper()}}[${alias_local.upper()}_OAM_IP_ADDRESS]
    ${stripped_ip}=  String.Strip String  ${ip}

    [Return]  ${stripped_ip}

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Admin CLI Send Request
    [Documentation]  Send command via Admin CLI, and return request status, error code and request message.
    [Arguments]  ${cli_message}  ${output_file}=${None}  ${return_value}=${None}  ${input_file}=${None}

    ${response}=  admin_cli.Send Admin CLI Request  ${cli_message}  output_file=${output_file}  return_value=${return_value}  input_file=${input_file}
    ${request_status}=  Get From Dictionary  ${response}  requestStatus
    ${error_code}=  Get From Dictionary  ${response}  errorCode
    ${request_message}=  Get From Dictionary  ${response}  requestMessage

    [Return]  ${request_status}  ${error_code}  ${request_message}

Check BTS KPI
    [Arguments]  ${start_time}  ${end_time}  ${operation_description}  ${expected_value}=default

    ${actual_value}=  DateTime.Subtract Date From Date  ${end_time}  ${start_time}  number
    Log  ${operation_description} KPI is: ${actual_value} seconds  console=True

    Run Keyword If  ${actual_value} > ${expected_value}  Run Keywords
    ...  Log Long String  ${operation_description} KPI check failed! Expected maximum: ${expected_value} seconds, but actual is: ${actual_value}
    ...  seconds.  level=WARN
    ...  AND  Run Keyword And Continue On Failure
    ...  Fail  ${operation_description} KPI check failed! Expected maximum: ${expected_value} seconds, but actual is: ${actual_value} seconds.
    ...  ELSE
    ...  Log Long String  ${operation_description} KPI check passed! Expected maximum: ${expected_value} seconds, actual is: ${actual_value}
    ...  seconds.  console=True

Recover initial settings for actCli parameter
    [Documentation]
    ...  Keyword used to recover initial settings for actCli parameter on BTS

    ${actCli_final}=  rfs_general.Get actCli parameter value  ${alias_local}
    Run Keyword If  '${actCli_final}' != '${ACTCLI_INITIAL}'  Run Keywords
    ...  Log  Recover initial settings for actCli parameter on BTS ${alias_local}  console=True
    ...  AND  rfs_general.Set actCli parameter value  ${ACTCLI_INITIAL}  ${alias_local}

Particular Teardown
    Recover initial settings for actCli parameter
    Run Keyword If  '${RC_CONNECTION}' == 'True'
    ...  rc.Teardown  connection=default

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
