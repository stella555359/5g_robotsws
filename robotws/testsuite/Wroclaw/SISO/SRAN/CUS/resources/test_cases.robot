*** Settings ***
Documentation  Scenarios of CUS test cases
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.sw.reporting_portal    WITH NAME    rp
Library    ta_uexgate
Library    taf.ul.ue.sim.env_setup
Library    taf.ccs.aashell    WITH NAME    cli
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sw.syslog    WITH NAME    syslog

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    ./bts_verification.robot
Resource    ./admin.robot
Resource    ./egate_and_uexgate.robot
Resource    ./call_and_throughput.robot
Resource    ./common_keywords.robot
Resource    ./bts_actions.robot
Resource    ./info_model_actions.robot
Resource    ../../resources/Robot/faults.robot
Resource    ../../resources/Robot/admin.robot
Resource    ../../resources/Robot/common_kw.robot

*** Keywords ***
CUS Template Commissioning
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${stabilization_timeout}=1
    ...  ${log_steps}=True  ${invalid_scfc}=False  ${conf_env_detection}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) performs BTS commissioning.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  |  eNB hardware configuration.                                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | stabilization_timeout  |  No  | Time the BTS should be OnAir and no not allowed alarm should occur.        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_steps             |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  invalid_scfc          |  No  | Perform template commissioning with SCFC hardware error.                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  conf_env_detection    |  No  | Perform radios detection check during configure environment scenario       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: Template Commissioning   console=${log_steps}
    Log  ${dots_prefix_green}Testline preparing  console=${log_steps}
    Set Suite Variable  ${TEST_CASE_TEMPLATE_COMMISSIONING}  True
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    ${cancellation_timer}=  SCFC Get Object Parameter Value
    ...  scfc_file_path=${scfc_file_path}
    ...  dist_name=${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...  parameter_name=fault4592CancellationTimer
#   (BEGIN) Perform template commissioning with SCFC hardware error (test feature LTE4433)
    Run Keyword If  ${invalid_scfc}  Run Keywords
    ...  Log  ${dots_prefix_green}Perform template commissioning with SCFC hardware error  console=${log_steps}
    ...  AND
    ...  BTS Perform Commissioning With Hardware Error SCFC
    ...  bts_id=1  fail_scfc_file_path=${SCFC_FAIL_REFERENCE_FILE_PATH}  timeout=300  errors_number=2
    ...  error_description=difference between two cells from the same  log_prefix=${info_prefix}
    ...  AND
    ...  Log  ${ok_prefix_green}Perform template commissioningwith SCFC hardware error  console=${log_steps}
    Log  ${dots_prefix_green}Add eNB to configuration  console=${log_steps}
#   (END) Perform template commissioning with SCFC hardware error (test feature LTE4433)
    Run Keyword If  ${NUMBER_OF_SMOD_UNIT}==1  Add Enb Configuration  scfc=${scfc_file_path}
    ...  host_id=1  commissioning_timeout=${COMMISSIONING_TIMEOUT}
    Run Keyword If  ${NUMBER_OF_SMOD_UNIT}==2  Add Enb Configuration  scfc=${scfc_file_path}
    ...  host_id=1  primary=True  commissioning_timeout=${COMMISSIONING_TIMEOUT}
    Run Keyword If  ${NUMBER_OF_SMOD_UNIT}==2  Add Enb Configuration  host_id=2  secondary=True
#    BTS Perform Commissioning  bts_id=1  scfc_file_path=${scfc_file_path}
#    ...  timeout=${COMMISSIONING_TIMEOUT}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Add eNB to configuration  console=${log_steps}
    Log  ${dots_prefix_green}Add CUS to configuration  console=${log_steps}
    Add Simulator  sim_type=cus  config=${CUSINI_FILE_PATH}
    Log  ${ok_prefix_green}Add CUS to configuration  console=${log_steps}
    Log  ${dots_prefix_green}Perform template commissioning and CUS configuration  console=${log_steps}
    Configure Environment  rmod_detection=${conf_env_detection}  config_removal=SKIP
    Log  ${ok_prefix_green}Perform template commissioning and CUS configuration  console=${log_steps}
    Log  ${dots_prefix_green}Availability of BTS and CUS after configuration  console=${log_steps}
    BTS Is Available
    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}
    Log  ${ok_prefix_green}Availability of BTS and CUS after configuration  console=${log_steps}
    Admin Configure Netconf Accounts
    Log  ${dots_prefix_green}RMODs detection after template commissioning  console=${log_steps}
#    CUS RMODs Detection  ${list_of_cus_ips}  ${NUMBER_OF_SMOD_UNIT}  log_prefix=${info_prefix}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}RMODs detection after template commissioning  console=${log_steps}
    Log  ${dots_prefix_green}BTS OnAir procedure  console=${log_steps}
    BTS SCFC And Admin Cells Count Should Match  ${scfc_file_path}
    Admin Check Cells State Before BTS OnAir
#    Admin BTS Should Be Configured  log_prefix=${info_prefix}
    Setup Egate And Edaemon Services
    CUS Egate Should Reach OnAir  cfg_file_path=${EPCSIM_FILE_PATH}
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    BTS Verify Extra Configuration Setup  scfc_file_path=${scfc_file_path}
    Check And Remove No Connection To Unit Alarm
    ${hw_dict}=  BTS Get Hardware Information
    Set To Dictionary  dictionary=${CFG.NODES['${CFG.bts_id_list[0]}']}  &{hw_dict}
    Log  ${ok_prefix_green}BTS OnAir procedure  console=${log_steps}
    BTS Check ULCoMP Configuration  ${scfc_file_path}
# Check BTS Reset Cause alarm
    ${fault_exist}=  Run Keyword And Return Status
    ...  Check BTS Reset Cause Historical Alarm
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*commissioning change*
    ...  log_prefix=${info_prefix}
    IF  not ${fault_exist}
    ...  Check BTS Reset Cause Alarm
    ...  activation_timeout=300s
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*commissioning change*
    ...  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Checking BTS Reset Cause alarm  console=${log_steps}
# Check active alarms
    Admin Check Inactive FaultId Alarms  6202  6150
    Admin Get And Check Active Alarms   allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_steps}
    Run Keyword If  ${stabilization_timeout}>1  Run Keywords
    ...  Log  ${dots_prefix_green}BTS OnAir stabilization checking  console=${log_steps}
    ...  AND
    ...  BTS Check OnAir Stability  timeout=${stabilization_timeout}
    ...  allowed_alarms=${allowed_alarms}  log_prefix=${info_prefix}
    ...  AND
    ...  Log  ${ok_prefix_green}BTS OnAir stabilization checking  console=${log_steps}
    Log  ${done_prefix_green}Test Case: Template Commissioning\n  console=${log_steps}

CUS BTS Reach Onair After Commissioning
    [Arguments]  ${scfc_file_path}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_steps}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) requires commissioned  BTS.
    ...  Keyword raises BTS to OnAir state.
    ...  *******************************************************************************************
    ...  PLEASE DO NOT USE "CUS Setup Test Set" KEYWORD.
    ...  "CUS Setup Test Set Without Reset Configuration" KEYWORD MUST BE USED WITH THIS KEYWORD.
    ...  *******************************************************************************************
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_steps             |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: BTS Reach Onair After Commissioning  console=${log_steps}
    BTS SCFC And Admin Cells Count Should Match  scfc_file_path=${scfc_file_path}
    Admin Check Cells State Before BTS OnAir
    Log  ${dots_prefix_green}BTS OnAir procedure  console=${log_steps}
    Setup Egate And Edaemon Services
    CUS Egate Should Reach OnAir  cfg_file_path=${EPCSIM_FILE_PATH}
    Sleep  60
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}BTS OnAir procedure  console=${log_steps}
    BTS Verify Extra Configuration Setup  scfc_file_path=${scfc_file_path}
    Check And Remove No Connection To Unit Alarm
    ${hw_dict}=  BTS Get Hardware Information
    Set To Dictionary  dictionary=${CFG.NODES['${CFG.bts_id_list[0]}']}  &{hw_dict}
    BTS Check ULCoMP Configuration  ${scfc_file_path}
    Admin Check Inactive FaultId Alarms  6202  6150
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_steps}
    Log  ${done_prefix_green}Test Case: BTS Reach Onair After Commissioning\n  console=${log_steps}

CUS Basic Call When Onair Reached
    [Arguments]  ${scfc_file_path}  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS}  ${log_steps}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) requires OnAir State before execution, so should
    ...  be used only after COMMISSIONING or RECOMMISSIONING test.
    ...  Test case performs call with throughput measurement to every cell.
    ...  The point of the test case is to check if L3 call succeed only, not if throughput rate matches
    ...  to specification requirements.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_steps             |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Basic Call When Onair Reached  console=${log_steps}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    Run Keyword And Continue On Failure  cli.Create Aashell Cli  name=aashell
    Run Keyword And Continue On Failure  cli.Setup  alias=aashell
    ${resources_usage_before}=  Run Keyword And Continue On Failure  Get Resources Usage  name=aashell
    CUS Call With Throughput Measurement  scfc_file_path=${scfc_file_path}
    ${resources_usage_after}=  Run Keyword And Continue On Failure  Get Resources Usage  name=aashell
    Run Keyword And Continue On Failure  Compare Resources Data Deepdiff
    ...  resources_usage1=${resources_usage_before}  resources_usage2=${resources_usage_after}
    Run Keyword And Continue On Failure  Should Be Equal As Resources
    ...  resources_usage1=${resources_usage_before}  resources_usage2=${resources_usage_after}
    ...  exclude=//bufferPoolFreeCount
    Admin Get And Check Active Alarms  ${allowed_alarms}
    Log  ${done_prefix_green}Test Case: CUS Basic Call When Onair Reached\n  console=${log_steps}
    [Teardown]  Run Keyword And Ignore Error  cli.Teardown  alias=aashell

CUS Cell Block Unblock And Call
    [Arguments]  ${scfc_file_path}  ${lcr_id_block_list}=ALL  ${basic_call}=True
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS}  ${log_steps}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) requires OnAir State before execution, so should be used
    ...  only after commissioning or recommissioning test.
    ...  Test case performs block/unblock procedure and call (or not) with throughput measurement
    ...  to every or selected cell.
    ...  The point of the test case is to check if L3 call succeed after block/unblock procedure,
    ...  not if throughput rate matches to specification requirements.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_block_list      | Yes  | The list of cells to block.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  basic_call            | Yes  | Call should be executed or not.                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_steps             |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Cell Block Unblock And Call  console=${log_steps}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    CUS Block Unblock And Call With Throughput Measurement  scfc_file_path=${scfc_file_path}
    ...  lcr_id_block_list=${lcr_id_block_list}  basic_call=${basic_call}
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${done_prefix_green}Test Case: CUS Cell Block Unblock And Call\n  console=${log_steps}

CUS Check And Perform Template Commissioning If Needed
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${log_steps}=True
    [Documentation]
    ...  Description:
    ...  Keyword performs "Template Commissioning" depending on the value of
    ...  the "TEST_CASE_TEMPLATE_COMMISSIONING" variable.
    ...  "TEST_CASE_TEMPLATE_COMMISSIONING" variable has the "True" value
    ...  if "Template Commissioning" test case has already been performed.
    ...  Otherwise "TEST_CASE_TEMPLATE_COMMISSIONING" variable has the "False" value
    ...  and "Template Commissioning" test case must be done.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  |  log_steps             |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Run Keyword If  ${TEST_CASE_TEMPLATE_COMMISSIONING}==False  Run Keywords
    ...  CUS Template Commissioning  scfc_file_path=${scfc_file_path}
    ...  list_of_cus_ips=${list_of_cus_ips}  log_steps=${log_steps}
    ...  AND
    ...  Set Suite Variable  ${SETUP_TEMPLATE_COMMISSIONING}  True
    ...  AND
    ...  Sleep  600  Wait for overhead messages on cells
    ...  ELSE IF  ${TEST_CASE_TEMPLATE_COMMISSIONING}==True
    ...  Set Suite Variable  ${SETUP_TEMPLATE_COMMISSIONING}  False
    # ${cell_list}=  Get Cell List
    # ${number_of_cells}=  Get Length  ${cell_list['cells']['lte']}
    # Run Keyword And Continue On Failure
    # ...  Run UEx Command  wait_for_ovhd  number_of_cells=${number_of_cells}  timeout=600

CUS Delta Recommissioning
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${json_delta_file}  ${recommissioning_timeout}=300
    ...  ${get_kpi}=False  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    [Documentation]  Keyword (test case) performs BTS delta recommissioning.
    ...  Description:
    ...  Keyword (test case) performs BTS delta recommissioning.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | json_delta_file        | Yes  | Delta JSON or path to JSON file.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | recommissioning_timeout|  No  | Delta recommissioning timeout.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi15 or not.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       | Yes  | eNB configuration.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed_alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    Log  \n${start_prefix_green}Test Case: Delta Recommissioning  console=${log_to_console}
    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path}
    ...  list_of_cus_ips=${list_of_cus_ips}  json_delta_file=${json_delta_file}
    ...  recommissioning_timeout=${recommissioning_timeout}  log_steps=${log_to_console}
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    ${kpi_list}=  Create List  kpi15
    ${kpi_dict}=  Run Keyword If  ${get_kpi}
    ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
    Run Keyword If  ${get_kpi}
    ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}Kpi15 value calculation has been disabled  console=${log_to_console}
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: Delta Recommissioning\n  console=${log_to_console}

CUS BTS Power Reset
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${get_kpi}=False  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS}   ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) resets BTS (power reset - PDU off/on).
    ...  Additionally kpi3 parameter can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi3 or not.                                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: BTS Power Reset   console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    ${cancellation_timer}=  SCFC Get Object Parameter Value
    ...  scfc_file_path=${scfc_file_path}
    ...  dist_name=${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...  parameter_name=fault4592CancellationTimer
# Restart SMODs and wait for availability
    Log  ${dots_prefix_green}Restart SMODs and wait for availability  console=${log_to_console}
    PDU Restart SMODs  number_of_smod_units=${NUMBER_OF_SMOD_UNIT}
    ${power_start_timestamp}=  Get Current Date  time_zone=UTC
    Set Suite Variable  ${reset_time_stamp}  ${power_start_timestamp}
    BTS Is Unavailable
    BTS Is Available  retry_timeout=300
    CUS Is Available  list_of_cus_ips=${list_of_cus_ips}  retry_timeout=300
    Log  ${ok_prefix_green}Restart SMODs and wait for availability  console=${log_to_console}
# Radio modules detection after power reset
    ${big_config}=  Run Keyword And Return Status  Variable Should Exist  ${BIG_CONFIG_PATH}
    IF  ${big_config}
    ...  admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
    ...  timeout=120  leave_disconnect_logs=True
    Log  ${dots_prefix_green}RMODs Detection after power reset  console=${log_to_console}
    Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}RMODs Detection after power reset  console=${log_to_console}
# BTS should be OnAir
    Log  ${dots_prefix_green}BTS should be OnAir  console=${log_to_console}
    Admin BTS Should Be OnAir After Power Reset  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}BTS should be OnAir  console=${log_to_console}
# Get kpi value
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    IF  ${get_kpi}
      ${kpi_list}=  Create List  kpi3
      ${kpi3_param}=  Create Dictionary  start_point_timestamp=${power_start_timestamp}
      ${kpi_params}=  Create dictionary  kpi3=${kpi3_param}
      ${kpi_dict}=  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}
      ...  kpi_names=${kpi_list}  kpi_params=${kpi_params}
      Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ELSE
      Log  ${info_prefix}KPIs will not be calculated  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
# Check BTS Reset Cause alarm
    ${fault_exist}=  Run Keyword And Return Status
    ...  Check BTS Reset Cause Historical Alarm
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to power on*
    ...  log_prefix=${info_prefix}
    IF  not ${fault_exist}
    ...  Check BTS Reset Cause Alarm
    ...  activation_timeout=300s
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to power on*
    ...  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Checking BTS Reset Cause alarm  console=${log_to_console}
# Check active alarms
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Check active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: BTS Power Reset\n  console=${log_to_console}

CUS IQ Compression Recommissioning
    [Arguments]  ${scfc_file_path_list}  ${list_of_cus_ips}  ${json_delta_file_list}  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_steps}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) performs BTS IQ compression delta recommissioning.
    ...  Test case executes the following scenario:
    ...  1. Recommisioning which set up IQC only on one link + L3 call
    ...  2. Recommisioning which turn off IQC + L3 call
    ...  3. Recommisioning which turn on IQC on both links + L3 call
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path_list    | Yes  | List of path to the scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | json_delta_file_list   | Yes  | List of path to the delta JSON file.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       | Yes  | eNB configuration.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_steps              |  No  | Logs the given message to console.                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    Log  \n${start_prefix_green}Test Case: IQC Delta Recommissioning  console=${log_steps}
    ${cell_list}=  Get Cell List
    ${number_of_cells}=  Get Length  ${cell_list['cells']['lte']}
    Log  ${dots_prefix_green}Recommisioning which set up IQC only on one link  console=${log_steps}
    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path_list[0]}  list_of_cus_ips=${list_of_cus_ips}
    ...  json_delta_file=${json_delta_file_list[0]}  log_steps=${log_steps}
    Run UEx Command  wait_for_ovhd  number_of_cells=${number_of_cells}  timeout=300
    Log  ${ok_prefix_green}Recommisioning which set up IQC only on one link  console=${log_steps}
    CUS Call With Throughput Measurement  scfc_file_path=${scfc_file_path_list[0]}
    Run Keyword And Ignore Error
    ...  Move Directory  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach_1
    Log  ${dots_prefix_green}Recommisioning which turn off IQC  console=${log_steps}
    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path_list[1]}  list_of_cus_ips=${list_of_cus_ips}
    ...  json_delta_file=${json_delta_file_list[1]}  log_steps=${log_steps}
    Run UEx Command  wait_for_ovhd  number_of_cells=${number_of_cells}  timeout=300
    Log  ${ok_prefix_green}Recommisioning which turn off IQC  console=${log_steps}
    CUS Call With Throughput Measurement  scfc_file_path=${scfc_file_path_list[1]}
    Run Keyword And Ignore Error
    ...  Move Directory  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach_2
    Log  ${dots_prefix_green}Recommisioning which turn on IQC on both links  console=${log_steps}
    BTS Perform Delta Recommissioning  scfc_file_path=${scfc_file_path_list[2]}  list_of_cus_ips=${list_of_cus_ips}
    ...  json_delta_file=${json_delta_file_list[2]}  log_steps=${log_steps}
    Run UEx Command  wait_for_ovhd  number_of_cells=${number_of_cells}  timeout=300
    Log  ${ok_prefix_green}Recommisioning which turn on IQC on both links  console=${log_steps}
    CUS Call With Throughput Measurement  scfc_file_path=${scfc_file_path_list[2]}
    Run Keyword And Ignore Error
    ...  Move Directory  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/attach_3
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_steps}
    Log  ${done_prefix_green}Test Case: IQC Delta Reommissioning\n  console=${log_steps}

One Carrier Over One FD-CPRI Link
    [Arguments]  ${scfc_file_path}  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}
    [Documentation]
    ...  Description:
    ...  During LTE4265/LTE4305 implementation it was found out that due to L1Low synchronization issues
    ...  all vAxC belonging to the same carrier must be transmitted via the same optical fiber link on FD-CPRI,
    ...  to eliminate possible time-differences between links.
    ...  All vAxC (aka "virtual antennas") of one carrier must be transmitted over the same FD-CPRI link.
    ...  Keyword (test case) checks that in case of dual-sector configuration
    ...  where two cells share the same carrier vAxCs share the same link.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       | Yes  | eNB configuration.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    Info Model Verify One Carrier Over One FD-CPRI Link  scfc_file_path=${scfc_file_path}
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}

CUS Cells Block Unblock
    [Arguments]  ${scfc_file_path}  ${lcr_id_block_list}=ALL  ${get_kpi}=False
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) requires OnAir State before execution, so should be used
    ...  only after commissioning or recommissioning test.
    ...  Test case performs block/unblock procedure to every or selected cell.
    ...  Additionally kpi17a and kpi17b parameters can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lcr_id_block_list      | Yes  | The list of cells to block.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi17a/kpi17b or not.                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         |  No  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Cell Block Unblock Kpi  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    BTS Cells Block Unblock And Check  scfc_file_path=${scfc_file_path}
    ...  lcr_id_block_list=${lcr_id_block_list}  get_kpi=${get_kpi}
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${done_prefix_green}Test Case: CUS Cell Block Unblock Kpi\n  console=${log_to_console}

CUS Reset Site
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${get_kpi}=False  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) performs BTS reset site.
    ...  Additionally kpi1a parameter can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi1a or not.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Reset Site  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    Save Search Start Timestamp
    ${cancellation_timer}=  SCFC Get Object Parameter Value
    ...  scfc_file_path=${scfc_file_path}
    ...  dist_name=${mrbts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...  parameter_name=fault4592CancellationTimer
    ${site_reset_timestamp}=  Get Current Date  time_zone=UTC
    Set Suite Variable  ${reset_time_stamp}  ${site_reset_timestamp}
# Reset site
    Log  ${dots_prefix_green}Perform reset site  console=${log_to_console}
    Reset Site  timeout=500
    Log  ${info_prefix}Reset site is being performed. Please wait ...  console=${log_to_console}
    ${big_config}=  Run Keyword And Return Status  Variable Should Exist  ${BIG_CONFIG_PATH}
    IF  ${big_config}
    ...  Collect Infomodel Log From Current Session
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
    ...  timeout=120  leave_disconnect_logs=True
# BTS should be OnAir
    BTS Detect Site Hardware And Get OnAir  scfc_file_path=${scfc_file_path}  list_of_cus_ips=${list_of_cus_ips}
    ...  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Perform reset site  console=${log_to_console}
# Get kpi value
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    IF  ${get_kpi}
      ${kpi_list}=  Create List  kpi1a
      ${kpi_dict}=  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
      Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ELSE
      Log  ${info_prefix}Kpi1a value calculation has been disabled  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
# Check BTS Reset Cause alarm
    ${fault_exist}=  Run Keyword And Return Status
    ...  Check BTS Reset Cause Historical Alarm
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to user request*
    ...  log_prefix=${info_prefix}
    Run Keyword If  not ${fault_exist}
    ...  Check BTS Reset Cause Alarm
    ...  activation_timeout=300s
    ...  cancellation_timeout=${cancellation_timer}
    ...  info_pattern=*due to user request*
    ...  log_prefix=${info_prefix}
    Log  ${ok_prefix_green}Checking BTS Reset Cause Alarm  console=${log_to_console}
# Check active alarms
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: CUS Reset Site\n  console=${log_to_console}

CUS Radio Module Reset
    [Arguments]  ${scfc_file_path}  ${rmod_sn_list}  ${get_kpi}=False  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) resets radio modules.
    ...  You can select an option defining which radio modules will be reset: ALL, RANDOM, SELECT
    ...  'ALL' option resets all radio modules:
    ...  Example: ${rmod_sn_list}=  ALL
    ...  'RANDOM' option resets randomly selected radio modules.
    ...  The number after 'RANDOM' determines the number of randomly selected radio modules.
    ...  Example: ${rmod_sn_list}=  RANDOM  2
    ...  'SELECT' option resets the radio modules given in the list ${rmod_sn_list}.
    ...  The serial numbers after 'SELECT' identify the selected radio modules.
    ...  Example: ${rmod_sn_list}=  SELECT  CUS001001C7  CUS001003C7  CUS0010008C7
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rmod_sn_list           | Yes  |  List of serial number of radio modules to reset.                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi51a or not.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  Yes | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Radio Module Reset  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    ${admin_rmod_sn_list}=  BTS Get Radio Module Serial Number List
	${rmod_serial_number_list}=  Run Keyword If  'ALL' in ${rmod_sn_list}
    ...  Create List  @{admin_rmod_sn_list}
    ...  ELSE IF  'RANDOM' in ${rmod_sn_list}
    ...  Get Random List Based On Input List  list=${admin_rmod_sn_list}  length=${rmod_sn_list[1]}
    ...  ELSE IF  'SELECT' in ${rmod_sn_list}
    ...  Create List  @{rmod_sn_list[1:None]}
    ${kpi_list}=  Create List  kpi51a
    FOR  ${rmod_serial_number}  IN  @{rmod_serial_number_list}
      Log  \n${dots_prefix_green}Radio module (serial number: ${rmod_serial_number}) reset and detection started
      ...  console=${log_to_console}
      BTS Radio Module Reset  scfc_file_path=${scfc_file_path}  rmod_serial_number=${rmod_serial_number}
      ...  log_prefix=${info_prefix}
      Log  ${ok_prefix_green}Radio module (serial number: ${rmod_serial_number}) reset and detection finished
      ...  console=${log_to_console}
      Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
      ${kpi_dict}=  Run Keyword If  ${get_kpi}
      ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
      Run Keyword If  ${get_kpi}
      ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
      ...  ELSE
      ...  Log  ${info_prefix}Kpi51a value calculation has been disabled  console=${log_to_console}
      Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    END
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: CUS Radio Module Reset\n  console=${log_to_console}

CUS Software Update With Kpi Calculation
    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${target_software}  ${get_kpi}=True  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) performs BTS reset site.
    ...  Additionally kpi1a parameter can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | target_software        | Yes  | Target software version.                                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi1a or not.                                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Software Update With Kpi Calculation  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    ${sw_info}=  Get Software Info
    ${active_sw}=  Set Variable  ${sw_info['Active SW version']}
    Log  ${info_prefix}Active software: ${active_sw}  console=${log_to_console}
    Log  ${info_prefix}Target software: ${target_software}  console=${log_to_console}
    Log  ${dots_prefix_green}Perform uboot downgrade  console=${log_to_console}
    ${downgrade_uboot}=  Downgrade Uboot
    Run Keyword If  ${downgrade_uboot}  Run Keywords
    ...  Log  ${info_prefix}Reset site after uboot downgrade is being performed. Please wait ...  console=${log_to_console}
    ...  AND
    ...  Reset Site
    ...  AND
    ...  BTS Detect Site Hardware And Get OnAir  scfc_file_path=${scfc_file_path}
    ...  list_of_cus_ips=${list_of_cus_ips}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${info_prefix}Perform site reset after uboot downgrade is not needed  console=${log_to_console}
    Log  ${ok_prefix_green}Perform uboot downgrade  console=${log_to_console}
    Log  ${dots_prefix_green}Perform software update  console=${log_to_console}
    Get Firmware Version  before_update
    Log  ${info_prefix}Firmware versions before software update:  console=${log_to_console}
    ${firmware_version}=  Convert To String  ${FIRMWARE_BEFORE_UPDATE}
    ${firmware_version}=  Remove String  ${firmware_version}  {  }
    Log  ${below_info_prefix}${firmware_version}  console=${log_to_console}
    ${sw_dir_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}
    ${software_package_name}=  Get BTS Software  sw_dir_path=${sw_dir_path}  sw_version=${target_software}  log_prefix=${info_prefix}
    ${software_package_path}=  Set Variable  ${sw_dir_path}/${software_package_name}
    Log  ${info_prefix}Software update to package: ${software_package_name} in progress. Please wait...  console=${log_to_console}
    Update Software  sw_package=${software_package_path}  should_activate=True  timeout=8000
    Log  ${info_prefix}Software update to package: ${software_package_name} has finished  console=${log_to_console}
    BTS Is Unavailable  retry_timeout=240
    Log  ${info_prefix}Reset site after software update is being performed. Please wait ...  console=${log_to_console}
    BTS Detect Site Hardware And Get OnAir  scfc_file_path=${scfc_file_path}  list_of_cus_ips=${list_of_cus_ips}
    ...  bts_retry_timeout=240  log_prefix=${info_prefix}
    Get Firmware Version  after_update
    Log  ${info_prefix}Firmware versions after software update:  console=${log_to_console}
    ${firmware_version}=  Convert To String  ${FIRMWARE_AFTER_UPDATE}
    ${firmware_version}=  Remove String  ${firmware_version}  {  }
    Log  ${below_info_prefix}${firmware_version}  console=${log_to_console}
    ${updated_count}=  syslog.Count Syslog Messages  regexp=.*bin updated.*
    Set Update Type  active_sw=${active_sw}  target_sw=${target_software}
    Run Keyword If  ${INTER_RELEASE_UPDATE}
    ...  Log  ${info_prefix}Inter release update has been done  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}Intra release update has been done  console=${log_to_console}
    Log  ${ok_prefix_green}Perform software update  console=${log_to_console}
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    ${kpi_name}=  Get Kpi Name For Update
    ${kpi_list}=  Create List  ${kpi_name}
    ${kpi_dict}=  Run Keyword If  ${get_kpi}
    ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
    Run Keyword If  ${get_kpi}
    ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}${kpi_name} value calculation has been disabled  console=${log_to_console}
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    Admin Check Inactive FaultId Alarms  6202  6150
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: CUS Software Update With Kpi Calculation\n  console=${log_to_console}

CUS Baseband Module Reset
    [Arguments]  ${scfc_file_path}  ${bbmod_sn_list}  ${get_kpi}=False  ${hw_configuration}=${EMPTY}
    ...  ${allowed_alarms}=${ALLOWED_ALARMS}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) resets baseband modules.
    ...  You can select an option defining which baseband modules will be reset: ALL, RANDOM, SELECT
    ...  'ALL' option resets all baseband modules:
    ...  Example: @{bbmod_sn_list}=  ALL
    ...  'RANDOM' option resets randomly selected baseband modules.
    ...  The number after 'RANDOM' determines the number of randomly selected baseband modules.
    ...  Example: @{bbmod_sn_list}=  RANDOM  2
    ...  'SELECT' option resets the baseband modules given in the list ${bbmod_sn_list}.
    ...  The serial numbers after 'SELECT' identify the selected baseband modules.
    ...  Example: @{bbmod_sn_list}=  SELECT  L2212901560  L1442901568  L1212901569
    ...
    ...  Additionally kpi5 parameter can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_sn_list           | Yes  |  List of serial number of baseband modules to reset.                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi51a or not.                                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  Yes | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS Baseband Module Reset  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    ${admin_bbmod_sn_list}=  BTS Get Baseband Serial Number List
    ${bts_enabled_rat_list}=  BTS Get Enabled Rat List
	${bbmod_serial_number_list}=  Run Keyword If  'ALL' in ${bbmod_sn_list}
    ...  Create List  @{admin_bbmod_sn_list}
    ...  ELSE IF  'RANDOM' in ${bbmod_sn_list}
    ...  Get Random List Based On Input List  list=${admin_bbmod_sn_list}  length=${bbmod_sn_list[1]}
    ...  ELSE IF  'SELECT' in ${bbmod_sn_list}
    ...  Create List  @{bbmod_sn_list[1:None]}
    ${kpi_list}=  Create List  kpi5
    FOR  ${bbmod_serial_number}  IN  @{bbmod_serial_number_list}
      Log  ${dots_prefix_green}Baseband module (serial number: ${bbmod_serial_number}) reset
      ...  console=${log_to_console}
      Save Search Start Timestamp
      Log  ${info_prefix}Baseband module reset is being performed. Please wait ...  console=${log_to_console}
      ${reset_result}=  BTS Baseband Module Reset  bbmod_serial_number=${bbmod_serial_number}
      ${status}=  Set Variable  ${reset_result['requestStatus']}
      Log  ${info_prefix}Baseband module (serial number: ${bbmod_serial_number}) reset finished (status: ${status})
      ...  console=${log_to_console}
      Log  ${ok_prefix_green}Baseband module (serial number: ${bbmod_serial_number}) reset
      ...  console=${log_to_console}
      Log  ${dots_prefix_green}Hardware modules detection  console=${log_to_console}
      ${result_state}=  BTS Verify All Hardware Unit State  class_name=SMOD  state=operationalState
      ...  state_value=enabled  timeout=500
      Log  ${info_prefix}All SMODs operational state is ${result_state} now  console=${log_to_console}
      ${result_state}=  BTS Verify All Hardware Unit State  class_name=BBMOD  state=operationalState
      ...  state_value=enabled  timeout=500
      Log  ${info_prefix}All BBMODs operational state is ${result_state} now  console=${log_to_console}
      Radio Modules Detection  scfc_file_path=${scfc_file_path}  log_prefix=${info_prefix}
      BTS Wait For Expected Every Rat State  bts_rat_list=${bts_enabled_rat_list}
      ...  rat_state_value=ALL_ENABLED  timeout=500
      Log  ${info_prefix}All BTS RATs state is enabled now  console=${log_to_console}
      Admin BTS Should Be OnAir  log_prefix=${info_prefix}
      Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
      Log  ${ok_prefix_green}Hardware modules detection  console=${log_to_console}
      Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
      ${kpi_dict}=  Run Keyword If  ${get_kpi}
      ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
      Run Keyword If  ${get_kpi}
      ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
      ...  ELSE
      ...  Log  ${info_prefix}Kpi5 value calculation has been disabled  console=${log_to_console}
      Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    END
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: CUS Baseband Module Reset\n  console=${log_to_console}

CUS BTS Rat Reset
    [Arguments]  ${scfc_file_path}  ${rat_type}  ${rat_reset_timeout}=900  ${get_kpi}=False  ${verify_changes}=True
    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_ONAIR}  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) performs BTS RAT reset.
    ...  Rat reset type is selected by "rat_type" variable.
    ...  At first RAT reset is performed.
    ...  Next InfoModel log gathered from RAT reset is saved and then checked in order
    ...  to find all DSPs and cells states changes.
    ...  IMPORTANT:
    ...  User needs to investigate impact of SOC reset on ABIO/ABIN/ABIP/ABIQ/ASOE/ASOF and provide impacted cells
    ...  or RAT in separate variable "RAT_IMPACT".
    ...  If variable "RAT_IMPACT" not set, no impact for other rats.
    ...  Possible values for RAT_IMPACT - CB008880:
    ...  'NR' - if only whole NR RAT impacted
    ...  '<cell_id>,<cell_id>,<cell_id>' - impacted cell ids separated by comma
    ...  'ALL' if everything is impacted
    ...  Example:
    ...  RAT_IMPACT    1,3,7
    ...  RAT_IMPACT    LTE
    ...  RAT_IMPACT    ALL
    ...  RAT_IMPACT    NONE
    ...  Additionally kpi7a and kpi7b (LTE) or kpi10a and kpi10b (NR) parameters can be calculated.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rat_type               | Yes  | RAT name - NR, LTE, WCDMA or GSM.                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | rat_reset_timeout      | Yes  | Timeout for the RAT reset operation.                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | get_kpi                |  No  | Get kpi7a/kpi7b or not.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | verify_changes         |  No  | Verify and print impacted and no impacted objects after rat reset.         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com
    ...  Last update: jakub.pachana@nokia.com

    Log  \n\n${start_prefix_green}Test Case: CUS ${rat_type} Rat Reset  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    ${bts_enabled_rat_list}=  BTS Get Enabled Rat List
    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
    BTS Verify Hardware  scfc_file_path=${scfc_file_path}  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
    Log  ${dots_prefix_green}Perform BTS parameter recommissioning  console=${log_to_console}
    ${actRatResetEnhancement}  Create Dictionary  parameterName  actRatResetEnhancement
    ...  operation  update  value  true
    ${actBbReconfigImprovement}  Create Dictionary  parameterName  actBbReconfigImprovement
    ...  operation  update  value  true
    ${actL1ReconfigImprovement}  Create Dictionary  parameterName  actL1ReconfigImprovement
    ...  operation  update  value  true
    ${actL2L3ReconfigImprovement}  Create Dictionary  parameterName  actL2L3ReconfigImprovement
    ...  operation  update  value  true
    @{param_list}  Create List  ${actRatResetEnhancement}  ${actBbReconfigImprovement}
	...  ${actL1ReconfigImprovement}  ${actL2L3ReconfigImprovement}
    ${parameter_value}=  Run Keyword And Return Status  Perform Object Recommissioning  dist_name=${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter=@{param_list}  operation=update  timeout=600
    Run Keyword If  "${parameter_value}"=="True"
    ...  Log  ${info_prefix}Parameter "actRatResetEnhancement" successfully set to true  console=${log_to_console}
    ...  ELSE  Fail  Parameter actRatResetEnhancement=${parameter_value} - test failed !!!
    Log  ${ok_prefix_green}Perform BTS parameter recommissioning  console=${log_to_console}
    admin.Reset Admin
    Save Search Start Timestamp
    Log  ${dots_prefix_green}Perform soft ${rat_type} RAT reset (actRatResetEnhancement=true)  console=${log_to_console}
    ${ims_file_name}=  Set Variable  InfoModel_soft_true_${rat_type}_RAT_reset.ims2
    ${ims_log_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/${ims_file_name}
    ${impacted_objects}  ${not_impacted_objects}=  BTS Perform Rat Reset  act_rat_reset_enhancement=true
    ...  rat_type=${rat_type}  reset_type=Soft  ims_log_path=${ims_log_path}  timeout=${rat_reset_timeout}
    Log  ${info_prefix}${rat_type} RAT reset is being performed. Please wait ...  console=${log_to_console}
    Log  ${ok_prefix_green}Perform soft ${rat_type} RAT reset (actRatResetEnhancement=true)  console=${log_to_console}
    ${big_config}=  Run Keyword And Return Status  Variable Should Exist  ${BIG_CONFIG_PATH}
    Run Keyword If  ${big_config}
    ...  Collect Infomodel Log From Current Session
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
    ...  timeout=120  leave_disconnect_logs=True
    Log  ${dots_prefix_green}Ims file checking  console=${log_to_console}
    Run Keyword If  "${verify_changes}"=="True"
    ...  Verify Ims File Changes  ims_log_path=${ims_log_path}  impacted_objects=${impacted_objects}
    ...  not_impacted_objects=${not_impacted_objects}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${info_prefix}Skipping Ims file checking on user demand  console=${log_to_console}
    Log  ${ok_prefix_green}Ims file checking  console=${log_to_console}
    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
    BTS Verify Hardware  scfc_file_path=${scfc_file_path}  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    ${kpi_list}=  Run Keyword If  '${rat_type}'=='LTE'  Create List  kpi7a
    ...  ELSE IF  '${rat_type}'=='NR'  Create List  kpi10a
    ...  ELSE IF  '${rat_type}'=='WCDMA'  Create List  kpi8
    ...  ELSE IF  '${rat_type}'=='GSM'  Create List  kpi9
    ${kpi_dict}=  Run Keyword If  ${get_kpi}
    ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
    Run Keyword If  ${get_kpi}
    ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}Soft RAT reset kpi value calculation has been disabled  console=${log_to_console}
    admin.Reset Admin
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    Run Keyword If  '${rat_type}'=='GSM' or '${rat_type}'=='WCDMA'
    ...  Run Keywords  Teardown GSM/WCDMA Rat Reset  rat_type=${rat_type}  log_to_console=${log_to_console}
    ...  AND  Return From Keyword
    Save Search Start Timestamp
    Log  ${dots_prefix_green}Perform hard ${rat_type} RAT reset (actRatResetEnhancement=true)  console=${log_to_console}
    ${ims_file_name}=  Set Variable  InfoModel_hard_true_${rat_type}_RAT_reset.ims2
    ${ims_log_path}=  Set Variable  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}/${ims_file_name}
    ${impacted_objects}  ${not_impacted_objects}=  BTS Perform Rat Reset  act_rat_reset_enhancement=true
    ...  rat_type=${rat_type}  reset_type=Hard  ims_log_path=${ims_log_path}  timeout=${rat_reset_timeout}
    Log  ${info_prefix}${rat_type} RAT reset is being performed. Please wait ...  console=${log_to_console}
    Log  ${ok_prefix_green}Perform hard ${rat_type} RAT reset (actRatResetEnhancement=true)  console=${log_to_console}
    Run Keyword If  ${big_config}
    ...  Collect Infomodel Log From Current Session
    ...  target_file_name=${SUITE_LOGS_DIR_PATH}/${TEST NAME}/IM_infomodel_kpi_pre.ims2
    ...  timeout=120  leave_disconnect_logs=True
    Log  ${dots_prefix_green}Ims file checking  console=${log_to_console}
    Run Keyword If  "${verify_changes}"=="True"
    ...  Verify Ims File Changes  ims_log_path=${ims_log_path}  impacted_objects=${impacted_objects}
    ...  not_impacted_objects=${not_impacted_objects}  log_prefix=${info_prefix}
    ...  ELSE
    ...  Log  ${info_prefix}Skipping Ims file checking on user demand  console=${log_to_console}
    Log  ${ok_prefix_green}Ims file checking  console=${log_to_console}
    Log  ${dots_prefix_green}Hardware modules checking  console=${log_to_console}
    BTS Verify Hardware  scfc_file_path=${scfc_file_path}  bts_rat_list=${bts_enabled_rat_list}  log_prefix=${info_prefix}
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
    Log  ${ok_prefix_green}Hardware modules checking  console=${log_to_console}
    Log  ${dots_prefix_green}Get kpi value  console=${log_to_console}
    ${kpi_list}=  Run Keyword If  '${rat_type}'=='LTE'  Create List  kpi7b
    ...  ELSE IF  '${rat_type}'=='NR'  Create List  kpi10b
    ${kpi_dict}=  Run Keyword If  ${get_kpi}
    ...  Get Kpi Values  logs_dir_path=${SUITE_LOGS_DIR_PATH}  kpi_names=${kpi_list}
    Run Keyword If  ${get_kpi}
    ...  Log  ${info_prefix}KPI values: ${kpi_dict}  console=${log_to_console}
    ...  ELSE
    ...  Log  ${info_prefix}Hard RAT reset kpi value calculation has been disabled  console=${log_to_console}
    admin.Reset Admin
    Log  ${ok_prefix_green}Get kpi value  console=${log_to_console}
    Admin Check Inactive FaultId Alarms  6202  6150
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: CUS ${rat_type} Rat Reset\n  console=${log_to_console}

CUS BTS IQRouting Runtime Change
    [Arguments]  ${scfc_file_path}  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS_IQR}
    ...  ${connection}=default  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  Keyword (test case) checks ASOG behavior after changing parameter "enableInternalIQRouting" in runtime.
    ...  The purpose of this test case is to verify whether FID:1868 is visible after changing parameter to false on
    ...  particular cells. After disabling IQR, Basic call is performed on not affected cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | connection             |  No  | Name of admin connection object.                                           |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Log text to console.                                                       |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: jakub.pachana@nokia.com
    ...  Maintainer: jakub.pachana@nokia.com

    Log  \n\n${start_prefix_green}Test Case: Runtime change of parameter enableInternalIQRouting  console=${log_to_console}
    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Log  ${info_prefix}All cells are onAir now  console=${log_to_console}
    Log  ${dots_prefix_green}Perform BTS parameter recommissioning  console=${log_to_console}
    ${parameter_change}=  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning
    ...  dist_name=${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  parameter=enableInternalIQRouting
    ...  operation=update
    ...  value=false
    ...  connection=${connection}
    Run Keyword If  "${parameter_change}"=="True"
    ...  Log  ${info_prefix}Parameter "enableInternalIQRouting" successfully set to false  console=${log_to_console}
    ...  ELSE  Fail  Parameter enableInternalIQRouting=true - test failed !!!
    Log  ${ok_prefix_green}Perform BTS parameter recommissioning  console=${log_to_console}
    ${cells_to_rmod}=  Admin Get Cells To Radio Mapping
    ${rmod_to_rf}=  Admin Get Rmods To RF Ports Mapping
    ${cells_to_rf}=  Admin Get Cells To RF Ports Mapping  cells_to_rmods=${cells_to_rmod}  rmod_to_rf=${rmod_to_rf}
    ${affected}  ${not_affected}=  Verify IQRouting Change Impact  cells_to_rf=${cells_to_rf}
    Log  ${dots_prefix_green}Cells check after recommissioning  console=${log_to_console}
    Assert Alarm Active  faultId=1868  timeout=900  connection=${connection}
    Sleep  60  Wait for 1868 appears on every intedned cell
    ${1868_cells_info}=  Get Alarms
    Log  ${dots_prefix_green}FID: 1868 visible on BTS, checking impacted cells..  console=${log_to_console}
    ${1868_cells_list}=  Get Cells With Fault 1868  @{1868_cells_info}
    Lists Should Be Equal  ${affected}  ${1868_cells_list}  ignore_order=True
    Log  ${dots_prefix_green}Following cells were properly impacted:  console=${log_to_console}
    FOR  ${cell}  IN  @{affected}
      Log  ${info_prefix}${red}${cell}${nc}  console=${log_to_console}
    END
    Log  ${dots_prefix_green}Checking not impacted cells..  console=${log_to_console}
    ${cell_list}=  admin.Get Cell List  timeout=120
    ${enabled_cells}=  Get Enabled Cells List  cell_list=${cell_list}
    Lists Should Be Equal  ${not_affected}  ${enabled_cells}  ignore_order=True
    Log  ${dots_prefix_green}Following cells were not impacted as intended:  console=${log_to_console}
    FOR  ${cell}  IN  @{not_affected}
      Log  ${info_prefix}${green}${cell}${nc}  console=${log_to_console}
    END
    Log  ${ok_prefix_green}Cells check after recommissioning  console=${log_to_console}
    Log  ${dots_prefix_green}Checking whether call can be performed to not impacted cells  console=${log_to_console}
    ${lcr_id_list}=  Create List
    FOR  ${cell}  IN  @{not_affected}
      ${is_lte}=  Run Keyword And Return Status  Should Contain  ${cell}  LNCEL
      IF  ${is_lte}
        ${id}=  Fetch From Right  string=${cell}  marker=-
        Append To List  ${lcr_id_list}  ${id}
      END
    END
    IF  ${lcr_id_list}
      Log  ${info_prefix}Performing Call with Tput Measurement on following cells ${lcr_id_list}\n  console=${log_to_console}
      CUS Call With Throughput Measurement
      ...  scfc_file_path=${scfc_file_path}
      ...  lcr_id_list=${lcr_id_list}
    ELSE
      Log  ${info_prefix}There is no valid cell to perform basic call.  console=${log_to_console}
    END
    Log  ${dots_prefix_green}Perform BTS parameter recommissioning  console=${log_to_console}
    ${parameter_change}=  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning
    ...  dist_name=${MRBTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  parameter=enableInternalIQRouting
    ...  operation=update
    ...  value=true
    ...  connection=${connection}
    Run Keyword If  "${parameter_change}"=="True"
    ...  Log  ${info_prefix}Parameter "enableInternalIQRouting" successfully set to true  console=${log_to_console}
    ...  ELSE  Fail  Parameter enableInternalIQRouting=false - test failed !!!
    Log  ${ok_prefix_green}Perform BTS parameter recommissioning  console=${log_to_console}
    Log  ${dots_prefix_green}Check whether FID:1868 is cleared  console=${log_to_console}
    Assert Alarm Inactive  faultId=1868  timeout=300  connection=${connection}
    Log  ${ok_prefix_green}FID:1868 is cleared successfully!  console=${log_to_console}
    Admin BTS Should Be OnAir  log_prefix=${info_prefix}
    Admin Get And Check Active Alarms  allowed_alarms=${allowed_alarms}
    Log  ${ok_prefix_green}Checking active alarms  console=${log_to_console}
    Log  ${done_prefix_green}Test Case: Runtime change of parameter enableInternalIQRouting  console=${log_to_console}
# NOT USED
#CUS Power Reset
#    [Arguments]  ${scfc_file_path}  ${list_of_cus_ips}  ${power_reset_count}
#    ...  ${hw_configuration}=${EMPTY}  ${allowed_alarms}=${ALLOWED_ALARMS}
#    ...  ${single_loop_logs}=True  ${log_steps}=True  ${get_kpi}=False
#    [Documentation]
#    ...  Description:
#    ...  Keyword (test case) resets BTS (power reset - PDU off/on).
#    ...  The number of reset loop is defined by variable ${power_reset_count}.
#    ...  Additionally kpi3 parameter can be calculated.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | scfc_file_path         | Yes  | Path to the scfc file.                                                     |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | list_of_cus_ips        | Yes  | List of CUS IP.                                                            |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | power_reset_count      | Yes  | Number of power resets.                                                    |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | get_kpi                |  No  | Get kpi3 or not.                                                           |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | hw_configuration       |  No  | eNB hardware configuration.                                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | allowed_alarms         | Yes  | List of allowed alarms.                                                    |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | single_loop_logs       | Yes  | Collect logs from a single loop or do not collect.                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  |  log_steps             |  No  | Logs the given message to console.                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    Log  \n\n${start_prefix_green}Test Case: Power Reset   console=${log_steps}
#    rp.Report Enb Hardware Configuration  configuration=${hw_configuration}
#    ${power_reset_count}=  Convert To Integer  item=${power_reset_count}
#    Set Suite Variable  ${SAVEPOINT_ENB_RESET}  ${SAVEPOINT_ENB}
#    Set Suite Variable  ${SAVEPOINT_CUS_RESET}  ${SAVEPOINT_CUS}
#    Create Directory  ${SUITE_LOGS_DIR_PATH}/${TEST NAME}
#    FOR  ${reset_index}  IN RANGE  ${power_reset_count}
#      Log  \n${dots_prefix_green}Power reset is ongoing - number ${reset_index+1}/${power_reset_count}
#      ...  console=${log_steps}
#      Run Keyword And Continue On Failure  BTS Power Reset
#      ...  scfc_file_path=${scfc_file_path}
#      ...  list_of_cus_ips=${list_of_cus_ips}
#      ...  reset_index=${reset_index}
#      ...  single_loop_logs=${single_loop_logs}
#      ...  allowed_alarms=${allowed_alarms}
#      ...  get_kpi=${get_kpi}
#      Log  ${ok_prefix_green}Power reset number ${reset_index+1}/${power_reset_count} done\n
#      ...  console=${log_steps}
#    END
#    Log  ${done_prefix_green}Test Case: Power Reset\n  console=${log_steps}

#Handover
#    [Arguments]    ${scfc_file_path}    ${wts_file_pathes}    ${hw_configuration}=${EMPTY}
#    ...    ${allowed_alarms}=${ALLOWED_ALARMS}
#    [Documentation]   Keyword (test case) performs handover loops from every to every cell.
#    ...    Number of loops can be specified as a parameter in HO Execute Handover Loops keyword.
#    ...    During HO procedure throughput measurement is performed.
#    ...    Value of expected throughput is constant 10Mbps for ul and 17Mbps for dl.
#    ...    Acceptable throughput rate is 70% of specified value.
#    ...    Test case  checks mainly if HO succeed not if throughput rate was close to maximum.
#    ...    Please remember that HO requires especially prepared SCFC!
#    ...    Maintainer: slawomir.jastrzebski@nokia.com
#    rp.Report Enb Hardware Configuration    ${hw_configuration}
#   # TTI Trace Collect Prints
#    IPHY HO Execute Handover Loops    1    ${scfc_file_path}
#    IPHY Admin Get And Check Active Alarms   ${allowed_alarms}
#    # TTI Trace Collect Prints and the keyword are not obligatory
#    # run    sudo killall ttiStreaming && cp ${EGATE_PATH}iphy.dat* ${OUTPUT DIR}
