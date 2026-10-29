*** Settings ***
Documentation
    ...  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-22792
    ...
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case verifies the functionality of thermal counters monitoring and alarm triggering for radio modules.
    ...  It ensures that the thermal monitoring parameters are correctly configured, counters are reporting as expected,
    ...  and alarms are triggered based on predefined thresholds.
    ...
    ...  ******************
    ...  Steps description
    ...  ******************
    ...  Step 1: Preconditions For Thermal Monitoring Snapshot Triggering
    ...      - Retrieves BTS information, determines available equipment, and saves the initial SCF file.
    ...      - Makes a list of counters to check.
    ...
    ...  Step 2: Enable Parameters For Measurement And Activate Plan
    ...      - Configures the measurement interval for the selected counters.
    ...
    ...  Step 3: Verify Counters Reporting
    ...      - Waits for the next measurement interval and verifies that counters are reporting within the expected range.
    ...
    ...  Step 4: Activate Default Fault Snapshot Triggers And Activate Plan
    ...      - Configures fault snapshot triggers and ensures the required parameters are set correctly.
    ...
    ...  Step 5: Configure KPI Alarm Triggers And Activate Plan
    ...      - Configures KPI alarm triggers for specific parameters and ensures sufficient fault numbers are available.
    ...
    ...  Step 6: Change Parameter For KPI
    ...      - Updates the `actKpiAlarms` parameter to enable KPI alarms.
    ...
    ...  Step 7: Download The Snapshot History File
    ...      - Waits for a fault to be triggered, downloads the snapshot history file, and verifies its contents.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.05.2025 - Initial creation

Resource    ../../Resources/Robot/PM.robot
Resource    ../../Resources/Robot/SSH.robot
Library    ../../Resources/Python/helpers.py

*** Variables ***
# The following variable is mandatory - tester must give a list of parameter values,
# the values may be: disabled 5min 15min 30min 60min 360min 720min 1440min, respectively for
# mtSBTSRMODTemperature, mtSBTSASIRMODTemperature, mtSBTSCabiTempMonitoring, mtSBTSSMODTemperature, mtSBTSBBMODTemperature
@{RMOD_ASIR_CAB_SMOD_BBMOD}=  5min  disabled  disabled  disabled  disabled     # Mandatory
@{LSS_DATA}=                                                                   # Mandatory, list provided by the tester: ip  port  user  password
@{TEST_ALARM_LIST}=  4572  4573  4574  4575                                    # Optional
${MAX_NUM_SNAP}=  100                                                          # Optional, value provided by the tester: maxNumSnapByFaultTrigPerDay
# Mandatory, a dictionary provided by the tester:
&{THERMAL_VALUES}=  rmod=80  asirmod=80  smod=80  bbmod=80  cab_max=80  cab_min=40  cab_avg_max=80
@{TRIGGER_FAULT}=  7115 BASE STATION INFORMATION                               # Optional
${TIME_TO_TRIGGER_ALARM}=  1                                                   # Optional
${INTERVAL}=   5                                                               # Optional
${COUNTERS_MIN_RANGE}=  30                                                     # Mandatory
${COUNTERS_MAX_RANGE}=  80                                                     # Mandatory

*** Keywords ***
TC__PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Tags]  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    tc_setup_teardown.Common Test Setup
    Logging With Timestamp
    ...  message=Automated SiSo RU ... : @{CFG.active_bts_list} will be executed
    ...  style=ONGOING

    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Step 1 Preconditions For Thermal Monitoring Snapshot Triggering  ${bts_id}
    Step 2 Enable Parameters For Measurement And Activate Plan  ${bts_id}
    Step 3 Verify Counters Reporting   ${bts_id}
    Step 4 Activate Default Fault Snapshot Triggers And Activate Plan  ${bts_id}
    Step 5 Configure KPI Alarm Triggers And Activate Plan  ${bts_id}
    Step 6 Change Parameter For KPI  ${bts_id}
    Step 7 Download The Snapshot History File  ${bts_id}
    [Teardown]  Run Keywords
    ...  Run Keyword And Ignore Error  Recovery Action For Thermal Monitoring Snapshot Triggering
    ...  AND  tc_setup_teardown.Common Test Teardown

Step 1 Preconditions For Thermal Monitoring Snapshot Triggering
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Thermal Monitoring Snapshot Triggering
    ...  style=STEP
    ...  frame=${TRUE}
    Check Parameters For Thermal Monitoring Snapshot Triggering  ${bts_id}
    ${counters_to_check}=  Make A List Of Counters To Check
    Set Test Variable  ${COUNTERS_TO_CHECK}  ${counters_to_check}

    ${snap_history_result}=  admin.Get Snapshot History
    ...  output_file_name=${CFG.test_logs_path}/TestFiles/Snapshot_history_thermal_initial.txt
    ...  timeout=60
    ...  detailed_output=False
    ...  connection=${bts_id}

Step 2 Enable Parameters For Measurement And Activate Plan
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Enable Parameters For Measurement And Activate Plan
    ...  style=STEP
    ...  frame=${TRUE}
    Set The Measurement Interval For Chosen Counters  ${bts_id}

Step 3 Verify Counters Reporting
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 3 Verify Counters Reporting
    ...  style=STEP
    ...  frame=${TRUE}
    Verify Counters Reporting  ${bts_id}

Step 4 Activate Default Fault Snapshot Triggers And Activate Plan
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4 Activate Default Fault Snapshot Triggers And Activate Plan
    ...  style=STEP
    ...  frame=${TRUE}
    Configure Snapshot Triggers  ${bts_id}

Step 5 Configure KPI Alarm Triggers And Activate Plan
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 5 Configure KPI Alarm Triggers And Activate Plan
    ...  style=STEP
    ...  frame=${TRUE}
    Configure KPI Alarm Triggers  ${bts_id}

Step 6 Change Parameter For KPI
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 6 Change Parameter For KPI
    ...  style=STEP
    ...  frame=${TRUE}
    Change The Parameter For KPI  ${bts_id}

Step 7 Download The Snapshot History File
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 7 Download The Snapshot History File
    ...  style=STEP
    ...  frame=${TRUE}
    Download The Snapshot History File  ${bts_id}

Check Parameters For Thermal Monitoring Snapshot Triggering
    [Arguments]  ${bts_id}
    [Documentation]  This keyword checks the parameters required for thermal monitoring snapshot triggering for the given BTS ID.
    ...
    ...  It retrieves BTS information, determines the available equipment, and saves the initial SCF file for further use.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the parameters are being checked.             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves BTS information using the `admin.Get Bts Info` keyword.
    ...  - Extracts the keys from the BTS information dictionary.
    ...  - Determines the available equipment and maps it to specific parameters using the `Get Available Equipment From Bts Info` keyword.
    ...  - Saves the initial SCF file for commissioning purposes.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    &{bts_info}=  admin.Get Bts Info  timeout=60  connection=${bts_id}
    ${info_keys}=  Get Dictionary Keys  ${bts_info}
    ${parameter_dict}=  Get Available Equipment From Bts Info  ${bts_info}  ${info_keys}
    Set Test Variable  ${PARAMETER_DICT}  ${parameter_dict}
    admin.Get Current Scf File
    ...  local_dir_path=${CFG.test_logs_path}/TestFiles/
    ...  file_name=initial_scf.xml
    ...  timeout=30
    ...  connection=${bts_id}
    ...  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=None

Get Available Equipment From Bts Info
    [Arguments]  ${bts_info}  ${info_keys}
    [Documentation]  This keyword retrieves available equipment information from the BTS info and maps it to specific parameters.
    ...
    ...  It iterates through the provided BTS info keys, checks their availability, and assigns corresponding parameter values based
    ...  on the equipment type.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_info               | Yes  | A dictionary containing BTS information.                           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | info_keys              | Yes  | A list of keys to check in the BTS info.                           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Iterates through the keys in the BTS info.
    ...  - Checks if the key is not empty and matches specific equipment types.
    ...  - Maps the equipment type to its corresponding parameter and value.
    ...  - Logs the resulting parameter dictionary.
    ...
    ...  Returns:
    ...  - A dictionary of parameters mapped to their corresponding equipment.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    &{parameter_dict}=  Create Dictionary
    FOR  ${info_key}  IN  @{info_keys}
      ${empty_status}=  Run Keyword And Return Status  Should Not Be Empty  ${bts_info['${info_key}']}
      IF  '${info_key}'=='radioModules' and ${empty_status}==True
        ${empty_asirmod_status}=  Run Keyword And Return Status  Should Not Be Empty  ${bts_info.${info_key}.rmod}
        IF  ${empty_asirmod_status}==True
          Set To Dictionary  ${parameter_dict}  mtSBTSRMODTemperature=${RMOD_ASIR_CAB_SMOD_BBMOD[0]}
        ${empty_asirmod_status}=  Run Keyword And Return Status  Should Not Be Empty  ${bts_info.${info_key}.asirmod}
        ELSE IF  ${empty_asirmod_status}==True
          Set To Dictionary  ${parameter_dict}  mtSBTSASIRMODTemperature=${RMOD_ASIR_CAB_SMOD_BBMOD[1]}
        END
      ELSE IF  '${info_key}'=='cabinets' and ${empty_status}==True
        ${amid_amoe}=  Run Keyword And Return Status  Should Match Regexp  ${bts_info.cabinets[0]['productName']}  ^(AMID|AMOE)\s.*$
        Run Keyword If  ${amid_amoe}==True
        ...  Set To Dictionary  ${parameter_dict}  mtSBTSCabiTempMonitoring=${RMOD_ASIR_CAB_SMOD_BBMOD[2]}
      ELSE IF  '${info_key}'=='systemModules' and ${empty_status}==True
        Set To Dictionary  ${parameter_dict}  mtSBTSSMODTemperature=${RMOD_ASIR_CAB_SMOD_BBMOD[3]}
      ELSE IF  '${info_key}'=='basebandModules' and ${empty_status}==True
        Set To Dictionary  ${parameter_dict}  mtSBTSBBMODTemperature=${RMOD_ASIR_CAB_SMOD_BBMOD[4]}
      END
    END
    Run Keyword And Ignore Error  Log Dictionary  ${parameter_dict}
    [Return]  ${parameter_dict}

Make A List Of Counters To Check
    [Documentation]  This keyword makes a list of counters for the given BTS ID and collects inital Snapshot history.
    ...
    ...  It determines the counters to check based on the available equipment and collects inital Snapshot history.
    ...
    ...  Behavior:
    ...  - Determines the counters to check based on the keys in the `PARAMETER_DICT` dictionary.
    ...  - Maps specific parameters to their corresponding counter IDs.
    ...
    ...  Returns:
    ...  - A list of counters to check.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${parameters_eqm}=  Get Dictionary Keys  ${PARAMETER_DICT}
    @{counters_to_check}=  Create List
    FOR  ${parameter}  IN  @{parameters_eqm}
      IF  '${parameter}'=='mtSBTSRMODTemperature'
        Append To List  ${counters_to_check}  M40008C1
      ELSE IF  '${parameter}'=='mtSBTSASIRMODTemperature'
        Append To List  ${counters_to_check}  M40018C0
      ELSE IF  '${parameter}'=='mtSBTSSMODTemperature'
        Append To List  ${counters_to_check}  M40009C0
      ELSE IF  '${parameter}'=='mtSBTSBBMODTemperature'
        Append To List  ${counters_to_check}  M40010C0
      ELSE IF  '${parameter}'=='mtSBTSCabiTempMonitoring'
        Append To List  ${counters_to_check}  M40019C0  M40019C1  M400192
      END
    END
    [Return]  ${counters_to_check}

Set The Measurement Interval For Chosen Counters
    [Arguments]  ${bts_id}
    [Documentation]  This keyword sets the measurement interval for the chosen counters in the PMMNL managed object for the given BTS ID.
    ...
    ...  It checks if the PMMNL managed object exists. If it does not exist, it creates the object. If it exists, it updates the object.
    ...  The keyword ensures that the parameters are correctly set for the measurement interval.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the measurement interval is being set.        |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Checks if the PMMNL managed object exists.
    ...  - If the object does not exist, creates it and verifies its creation.
    ...  - If the object exists, updates it with the provided parameters.
    ...  - Logs an error and fails the test if the object creation or update fails.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${pmmnl_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
    ${pmmnl_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${pmmnl_parameter}
    ${parameter_items}=  Get Dictionary Keys  ${PARAMETER_DICT}
    IF  ${pmmnl_exist}==False
      Logging With Timestamp
      ...  message=Object PMMNL-1 does not exist. Creating the object...
      ...  style=ONGOING
      Create Or Update PMMNL Managed Object  ${bts_id}  ${PARAMETER_DICT}  ${parameter_items}  create
      ${pmmnl_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
      ${pmmnl_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${pmmnl_parameter}
      IF  ${pmmnl_exist}==False
        Logging With Timestamp
        ...  message=Object PMMNL-1 does not exist. Creating the object failed.
        ...  style=ERROR
        Fail  Object PMMNL-1 does not exist. Creating the object failed.
      ELSE
        Logging With Timestamp
        ...  message=Object PMMNL-1 created successfully.
        ...  style=DONE
      END
    ELSE
      Logging With Timestamp
      ...  message=Object PMMNL-1 exists. Updating the object...
      ...  style=ONGOING
      Create Or Update PMMNL Managed Object  ${bts_id}  ${PARAMETER_DICT}  ${parameter_items}  update
      ${pmmnl_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
      ${pmmnl_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${pmmnl_parameter}
      # TODO: Check if values changed?
      IF  ${pmmnl_exist}==False
        Logging With Timestamp
        ...  message=Object PMMNL-1 does not exist. Creating the object failed.
        ...  style=ERROR
        Fail  Object PMMNL-1 does not exist. Creating the object failed.
      ELSE
        Logging With Timestamp
        ...  message=Object PMMNL-1 created successfully.
        ...  style=DONE
      END
    END

Create Or Update PMMNL Managed Object
    [Arguments]  ${bts_id}  ${parameter_dict}  ${parameter_items}  ${operation}
    [Documentation]  This keyword creates or updates the PMMNL managed object for the given BTS ID.
    ...
    ...  It iterates through the provided parameters and prepares a list of activation dictionaries for the operation.
    ...  The operation can either be `create` or `update`, depending on the requirement.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the PMMNL managed object is created/updated.  |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | parameter_dict         | Yes  | A dictionary of parameters and their values.                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | parameter_items        | Yes  | A list of parameter names to be processed.                        |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | operation              | Yes  | The operation to perform: `create` or `update`.                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Iterates through the parameter items and retrieves their values from the parameter dictionary.
    ...  - Creates a list of activation dictionaries for the parameters.
    ...  - Calls the `Perform Object Recommissioning` keyword to apply the changes.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    @{parameter_list}=  Create List
    FOR  ${parameter_item}  IN  @{parameter_items}
      ${value}=  Get From Dictionary  ${parameter_dict}  ${parameter_item}
      &{activation_dictionary}=  Create Dictionary
      ...  parameterName=${parameter_item}
      ...  value=${parameter_dict['${parameter_item}']}
      ...  operation=update
      Append To List  ${parameter_list}  ${activation_dictionary}
    END
    Perform Object Recommissioning
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1
    ...  parameter=${parameter_list}
    ...  operation=${operation}
    ...  connection=${bts_id}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True

Verify Counters Reporting
    [Arguments]  ${bts_id}
    [Documentation]  This keyword verifies that the counters are reporting correctly for the given BTS ID.
    ...
    ...  It waits for the next measurement interval, retrieves the counters, and checks if their values fall within the expected range.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the counters are being verified.              |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Calculates the time to sleep based on the measurement interval.
    ...  - Waits for the duration of the measurement interval.
    ...  - Retrieves the counters for the specified BTS ID.
    ...  - Verifies that the counter values are within the expected range (30 to 80).
    ...  - Logs a warning if the counters are not reporting as expected.
    ...  - Logs a success message if the counters are reporting correctly.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_verification}  ${counter_length_enabled}  Run Keyword And Ignore Error  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_TO_CHECK}
    ...  min_range=${COUNTERS_MIN_RANGE}
    ...  max_range=${COUNTERS_MAX_RANGE}
    ...  bts_id=${bts_id}
    ...  return_timestamp=${FALSE}

    IF  '${counter_verification}'=='FAIL'
      Logging With Timestamp
      ...  message=Counter verification failed for ${COUNTERS_TO_CHECK} on BTS ${bts_id}!
      ...  style=WARN
    ELSE
      Logging With Timestamp
      ...  message=Counter verification passed for ${COUNTERS_TO_CHECK} on BTS ${bts_id}.
      ...  style=DONE
    END

Configure Snapshot Triggers
    [Arguments]  ${bts_id}
    [Documentation]  This keyword configures snapshot triggers for the given BTS ID.
    ...
    ...  It ensures that the required parameters are set correctly for snapshot triggering, including fault snapshot triggers,
    ...  LSS configuration, and other related parameters. If any parameter is not set as expected, it updates the configuration.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the snapshot triggers are configured.         |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Verifies and updates the `actRemoteSyslogTransmission`, `actDefaultFaultSnapTriggers`, and `diagSnapDestination` parameters.
    ...  - Configures the LSS account and updates the `lssConfig` parameter.
    ...  - Sets the maximum number of snapshots per day using the `maxNumSnapByFaultTrigPerDay` parameter.
    ...  - Ensures that fault snapshot triggers are configured with available fault numbers.
    ...  - Creates and applies a delta configuration for the updated parameters.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${trblcadm_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1  connection=${bts_id}

    ${actremotesyslog_status}=  Run Keyword And Return Status
    ...  Should Be Equal  '${trblcadm_parameter[0]['parameters']['actRemoteSyslogTransmission']}'  'False'
    IF  ${actremotesyslog_status}==False
      Logging With Timestamp
      ...  message=Changing the parameter actRemoteSyslogTransmission to False
      ...  style=ONGOING
      Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
      ...  parameter=actRemoteSyslogTransmission
      ...  operation=update
      ...  value=false
      ...  skip_parameter_relation_errors=skip
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actRemoteSyslogTransmission already set to False
      ...  style=DONE
    END

    ${actdefaultfault_status}=  Run Keyword And Return Status
    ...  Should Be Equal  '${trblcadm_parameter[0]['parameters']['actDefaultFaultSnapTriggers']}'  'True'
    IF  ${actdefaultfault_status}==False
      Logging With Timestamp
      ...  message=Changing the parameter actDefaultFaultSnapTriggers to True
      ...  style=ONGOING
      Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
      ...  parameter=actDefaultFaultSnapTriggers
      ...  operation=update
      ...  value=true
      ...  skip_parameter_relation_errors=skip
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actDefaultFaultSnapTriggers already set to True
      ...  style=DONE
    END

    ${diagsnapdestination_status}=  Run Keyword And Return Status
    ...  Should Be Equal  ${trblcadm_parameter[0]['parameters']['diagSnapDestination']}  lss
    IF  ${diagsnapdestination_status}==False
      Logging With Timestamp
      ...  message=Changing the parameter diagSnapDestination to lss
      ...  style=ONGOING
      Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
      ...  parameter=diagSnapDestination
      ...  operation=update
      ...  value=lss
      ...  skip_parameter_relation_errors=skip
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Parameter diagSnapDestination already set to lss
      ...  style=DONE
    END

    ${lssconfig_exist}=  Run Keyword And Return Status  Variable Should Exist  ${trblcadm_parameter[0]['parameters']['lssConfig']}
    ${parameters}=  Get Parameter By Distname
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  include_children=${TRUE}
    ...  timeout=60
    ...  detailed_output=False
    ...  connection=${bts_id}

    ${lss_port}=  Convert To Integer  ${LSS_DATA[1]}
    &{list_param_to_change}=  Create Dictionary
    ...  lssIPaddress=${LSS_DATA[0]}  lssPortNo=${lss_port}
    @{list}=  Create List  ${list_param_to_change}
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  parameter=lssConfig
    ...  operation=update
    ...  value=@{list}
    ...  skip_parameter_relation_errors=skip
    ...  connection=${bts_id}

    admin.Configure Lss Account
    ...  lss_username=${LSS_DATA[2]}
    ...  lss_password=${LSS_DATA[3]}
    ...  timeout=60
    ...  detailed_output=False
    ...  connection=${bts_id}

    ${max_num_snap_int}=  Convert To Integer  ${MAX_NUM_SNAP}
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  parameter=maxNumSnapByFaultTrigPerDay
    ...  operation=update
    ...  value=${max_num_snap_int}
    ...  skip_parameter_relation_errors=skip
    ...  connection=${bts_id}

    ${trblcadm_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1  connection=${bts_id}
    ${kpi_alarm_exist}  Run Keyword And Return Status  Variable Should Exist  ${trblcadm_parameter[0]['parameters']['kpiAlarmTriggers']}

    ${fault_numbers}=  Set Variable  ${trblcadm_parameter[0]['parameters']['faultSnapshotTriggers']}
    @{fault_numbers_list}=  Create List
    FOR  ${fault_number}  IN   @{fault_numbers}
      Append To List  ${fault_numbers_list}  ${fault_number['faultNumber']}
    END
    ${fault_numbers_list}=  Remove Duplicates  ${fault_numbers_list}
    @{available_fault_numbers}=  Create List
    FOR  ${test_alarm_number}  IN  @{TEST_ALARM_LIST}
    ${status}=  Run Keyword And Return Status  List Should Not Contain Value  ${fault_numbers_list}  ${test_alarm_number}
      IF  ${status}==False
        Logging With Timestamp
        ...  message=Fault number ${test_alarm_number} is in the list of fault numbers. This alarm cannot be used.
        ...  style=WARN
      ELSE
        Append To List  ${available_fault_numbers}  ${test_alarm_number}
      END
    END
    Set Test Variable  ${AVAILABLE_FAULT_NUMBERS}  ${available_fault_numbers}
    ${available_fault_numbers_length}=  Get Length  ${available_fault_numbers}
    ${parameter_items}=  Get Dictionary Keys  ${parameter_dict}
    ${parameter_items_length}=  Get Length  ${parameter_items}
    ${length_status}=  Evaluate  ${available_fault_numbers_length}>=${parameter_items_length}

    @{fault_trigger}  Create List
    IF  ${length_status}==False
      Logging With Timestamp
      ...  message=There are not enough fault numbers available to be set for each parameter.
      ...  style=ERROR
      Fail  There are not enough fault numbers available to be set for each parameter. Check variables.
    ELSE
      FOR  ${available_fault_number}  IN  @{available_fault_numbers}
        ${available_fault_number_int}=  Convert To Integer  ${available_fault_number}
        &{snap_triggers}  Create Dictionary
        ...  faultNumber=${available_fault_number_int}  snapshotCoverageLevel=Full  triggerType=onFaultDetection
        Append To List  ${fault_trigger}  ${snap_triggers}
      END
    END

    admin.Create Delta
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  parameter=faultSnapshotTriggers
    ...  value=${fault_trigger}
    admin.Save Delta  target_file_name=${CFG.test_logs_path}/TestFiles/delta.json
    admin.Perform Delta Recommissioning
    ...  delta_file=${CFG.test_logs_path}/TestFiles/delta.json
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  connection=${bts_id}
    admin.Remove Delta

Change The Parameter For KPI
    [Arguments]  ${bts_id}
    [Documentation]  This keyword changes the `actKpiAlarms` parameter to `True` for the given BTS ID.
    ...
    ...  It verifies the current value of the parameter and updates it if necessary. If the parameter is already set to `True`, the keyword fails.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the parameter is being changed.               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the current value of the `actKpiAlarms` parameter.
    ...  - If the parameter is not `True`, updates it to `True` and verifies the change.
    ...  - Logs an error and fails the test if the parameter is already `True` or if the update fails.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${bts_id}
    ${status}=  Run Keyword And Return Status  Should Be Equal  '${featcadm_parameter[0]['parameters']['actKpiAlarms']}'  True
    IF  ${status}==False
      Logging With Timestamp
      ...  message=Changing the parameter actKpiAlarms to True
      ...  style=ONGOING
      ${bts_timestamp}=  SSH Get Bts timestamp  ${bts_id}
      Set Test Variable  ${BTS_TIMESTAMP}  ${bts_timestamp}
      Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actKpiAlarms
      ...  operation=update
      ...  value=true
      ...  skip_parameter_relation_errors=True
      ...  should_activate=True
      ...  timeout=300
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actKpiAlarms had been True before. Changing parameter failed.
      ...  style=ERROR
      Fail  Parameter actKpiAlarms had been True before. Changing parameter failed.
    END

    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${bts_id}
    ${status}=  Run Keyword And Return Status  Should Be Equal  '${featcadm_parameter[0]['parameters']['actKpiAlarms']}'  True
    IF  ${status}==True
      Logging With Timestamp
      ...  message=Parameter actKpiAlarms hasn't changed to True. Changing parameter failed.
      ...  style=ERROR
      Fail  Parameter actKpiAlarms hasn't changed to True. Changing parameter failed.
    ELSE
      Logging With Timestamp
      ...  message=Parameter actKpiAlarms changed to True. Changing parameter succeeded.
      ...  style=DONE
    END

Configure KPI Alarm Triggers
    [Arguments]  ${bts_id}  ${parameter_dict}=${PARAMETER_DICT}
    [Documentation]  This keyword configures KPI alarm triggers for specific parameters by creating fault trigger formulas.
    ...
    ...  It ensures that there are enough fault numbers available for each parameter and updates the configuration accordingly.
    ...  If the conditions are not met, it logs an error and fails the test.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================================+
    ...  | Argument               | Man. | Description                                                              |
    ...  +========================+======+==========================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the KPI alarm triggers are configured.              |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...  | parameter_dict         | No   | A dictionary of parameters and their values. Defaults to PARAMETER_DICT. |
    ...  +------------------------+------+--------------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Checks if the `kpiAlarmTriggers` parameter exists in the BTS configuration.
    ...  - Verifies that there are enough available fault numbers for the parameters.
    ...  - Creates fault trigger formulas for each parameter based on predefined thermal values.
    ...  - Updates the BTS configuration with the new KPI alarm triggers.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${trblcadm_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/TRBLCADM-1  connection=${bts_id}
    ${kpi_alarm_exist}  Run Keyword And Return Status  Variable Should Exist  ${trblcadm_parameter[0]['parameters']['kpiAlarmTriggers']}

    ${available_fault_numbers_length}=  Get Length  ${AVAILABLE_FAULT_NUMBERS}
    ${parameter_items}=  Get Dictionary Keys  ${parameter_dict}
    ${parameter_items_length}=  Get Length  ${parameter_items}
    ${length_status}=  Evaluate  ${available_fault_numbers_length}>=${parameter_items_length}

    @{fault_trigger}=  Create List
    IF  ${length_status}==False
      Logging With Timestamp
      ...  message=There are not enough fault numbers available to be set for each parameter.
      ...  style=ERROR
      Fail  There are not enough fault numbers available to be set for each parameter. Check variables.
    ELSE
        FOR  ${parameter_item}  IN  @{parameter_items}

          IF  '${parameter_item}'=='mtSBTSRMODTemperature'
              ${thermal_value_rmod}=  Set Variable  ${THERMAL_VALUES.rmod}
              &{rmod_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[0]}
              ...  formulaDescription=error_rmod
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_RM_MAX_TEMPERATURE < ${thermal_value_rmod}
              Append To List  ${fault_trigger}  ${rmod_formula}
          ELSE IF  '${parameter_item}'=='mtSBTSASIRMODTemperature'
              ${thermal_value_asirmod}=  Set Variable  ${THERMAL_VALUES.asirmod}
              &{asirmod_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[1]}
              ...  formulaDescription=error_asirmod
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_ASIR_MAX_AMBI_TEMPERATURE < ${thermal_value_asirmod}
              Append To List  ${fault_trigger}  ${asirmod_formula}
          ELSE IF  '${parameter_item}'=='mtSBTSSMODTemperature'
              ${thermal_value_smod}=  Set Variable  ${THERMAL_VALUES.smod}
              &{smod_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[2]}
              ...  formulaDescription=error_smod
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_SM_MAX_TEMPERATURE < ${thermal_value_smod}
              Append To List  ${fault_trigger}  ${smod_formula}
          ELSE IF  '${parameter_item}'=='mtSBTSBBMODTemperature'
              ${thermal_value_bbmod}=  Set Variable  ${THERMAL_VALUES.bbmod}
              &{bbmod_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[3]}
              ...  formulaDescription=error_bbmod
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_BM_MAX_TEMPERATURE < ${thermal_value_bbmod}
              Append To List  ${fault_trigger}  ${bbmod_formula}

          ELSE IF  '${parameter_item}'=='mtSBTSCabiTempMonitoring'
              ${thermal_value_cab_max}=  Set Variable  ${THERMAL_VALUES.cab_max}
              &{cab_max_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[4]}
              ...  formulaDescription=error_cab_max
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_CAB_MAX_TEMPERATURE < ${thermal_value_cab_max}
              Append To List  ${fault_trigger}  ${cab_max_formula}
              ${thermal_value_cab_min}=  Set Variable  ${THERMAL_VALUES.cab_min}
              &{cab_min_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[5]}
              ...  formulaDescription=error_cab_min
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_CAB_MIN_TEMPERATURE < ${thermal_value_cab_min}
              Append To List  ${fault_trigger}  ${cab_min_formula}
              ${thermal_value_cab_avg_max}=  Set Variable  ${THERMAL_VALUES.cab_avg_max}
              &{cab_avg_max_formula}  Create Dictionary
              ...  faultID=${AVAILABLE_FAULT_NUMBERS[6]}
              ...  formulaDescription=error_cab_avg_max
              ...  timeToTrigger=${TIME_TO_TRIGGER_ALARM}
              ...  triggeringFormula=SBTS_CAB_MIN_TEMPERATURE < ${thermal_value_cab_avg_max}
              Append To List  ${fault_trigger}  ${cab_avg_max_formula}
          END
        END
      END
    admin.Create Delta
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...  parameter=kpiAlarmTriggers
    ...  value=${fault_trigger}
    admin.Save Delta  target_file_name=${CFG.test_logs_path}/TestFiles/delta.json
    Logging With Timestamp
    ...  message=Performing Delta Recommissioning of formulas.
    ...  style=ONGOING
    admin.Perform Delta Recommissioning
   ...  delta_file=${CFG.test_logs_path}/TestFiles/delta.json
    ...  connection=${bts_id}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    admin.Remove Delta

Download The Snapshot History File
    [Arguments]  ${bts_id}
    [Documentation]  This keyword downloads the snapshot history file for the given BTS ID and verifies its contents.
    ...
    ...  It waits for a specific fault to be triggered, retrieves the snapshot history file, and performs checks to ensure the snapshot is valid.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the snapshot history file is downloaded.      |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Waits for the fault specified in `AVAILABLE_FAULT_NUMBERS` to be triggered.
    ...  - Downloads the snapshot history file and saves it locally.
    ...  - Verifies the snapshot on the FTP server.
    ...  - Compares the length of the initial and final snapshot history files.
    ...  - Checks timestamps in the log file to ensure they are newer than the reference timestamp.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${timeout}=  Evaluate  ${TIME_TO_TRIGGER_ALARM}*60+180
    FM Await For Fault
    ...  fault_attr=faultId=${AVAILABLE_FAULT_NUMBERS[0]}, severity=Minor
    ...  timeout=${timeout}
    ...  alarm_resource=${TRIGGER_FAULT}
    ...  node_id=${bts_id}
    Sleep  300s
    ${snap_history_result}=  admin.Get Snapshot History
    ...  output_file_name=${CFG.test_logs_path}/TestFiles/Snapshot_history_thermal_final.txt
    ...  timeout=60
    ...  detailed_output=False
    ...  connection=${bts_id}

    Check Whether Snapshot On Ftp Server  ${bts_id}
    ${lines_final}=  Compare Initial And Final Snapshot Files
    Check Timestamp In Log File
    ...  lines=${lines_final}

Check Whether Snapshot On Ftp Server
    [Arguments]  ${bts_id}
    [Documentation]  This keyword checks whether a snapshot exists on the FTP server for the given BTS ID.
    ...
    ...  It connects to the FTP server, lists the available snapshot directories, and compares their timestamps with a reference timestamp.
    ...  If a snapshot is older than the reference timestamp, it is removed. If a fresh snapshot is found, it is kept.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | The BTS ID for which the snapshot is being checked.                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Connects to the FTP server using the provided credentials.
    ...  - Lists all snapshot directories matching the pattern `^Snapshot_MRBTS-${bts_id}_.*$`.
    ...  - Compares the timestamp of each snapshot with the reference timestamp (`BTS_TIMESTAMP`).
    ...  - Removes snapshots older than the reference timestamp.
    ...  - Keeps the first fresh snapshot found and exits the loop.
    ...
    ...  Returns:
    ...  - The name of the fresh snapshot directory if found.
    ...  - None if no fresh snapshot is found.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    SSHLibrary.Open Connection  host=${LSS_DATA[0]}  port=${LSS_DATA[1]}
    SSHLibrary.Login  username=${LSS_DATA[2]}  password=${LSS_DATA[3]}
    SSHLibrary.Write  cd home/syslab
    ${output}=  SSHLibrary.Read
    SSHLibrary.Start Command  ls -la
    ${output}=  SSHLibrary.Read Command Output
    @{directories_lines}=  Split To Lines  ${output}
    ${snapshot_pattern}=  Set Variable  ^Snapshot_MRBTS-${bts_id}_.*$
    ${matched_dir}=  Set Variable  None
    ${local_timestamp}=  Evaluate
    ...  datetime.datetime.strptime('${BTS_TIMESTAMP}', '%Y%m%d%H%M%S').strftime('%Y%m%d%H%M%S')
    ...  modules=datetime

    FOR  ${line}  IN  @{directories_lines}
        @{parts}=  Split String  ${line}
        ${name}=  Get From List  ${parts}  -1
        ${is_match}=  Evaluate  re.match(r"${snapshot_pattern}", """${name}""") is not None  modules=re
        IF  ${is_match}
            ${ftp_snap_timestamp}=  Fetch From Right  ${name}  _
            ${is_fresh}=  Compare Ftp And Set Timestamps  ${local_timestamp}  ${ftp_snap_timestamp}
            IF  not ${is_fresh}
                Logging With Timestamp
                ...  message=Snapshot ${name} is older than the reference timestamp. Removing it.
                ...  style=ONGOING
                SSHLibrary.Write  rm -rf ${name}
                ${output}=  SSHLibrary.Read
                Logging With Timestamp
                ...  message=Old snapshot ${name} removed successfully.
                ...  style=DONE
            ELSE
                Logging With Timestamp
                ...  message=Snapshot ${name} is fresh enough. Keeping it.
                ...  style=DONE
                ${matched_dir}=  Set Variable  ${name}
                Exit For Loop
            END
        END
    END

Compare Ftp And Set Timestamps
    [Arguments]  ${local_timestamp}  ${ftp_snap_timestamp}
    [Documentation]  This keyword compares two timestamps: a local reference timestamp and a timestamp from an FTP snapshot.
    ...
    ...  The comparison determines whether the FTP snapshot timestamp is newer than or equal to the local reference timestamp.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | local_timestamp        | Yes  | The reference timestamp in the format '%Y%m%d%H%M%S'.              |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ftp_snap_timestamp     | Yes  | The FTP snapshot timestamp in the format '%Y%m%d-%H%M'.            |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Returns:
    ...  - True if the FTP snapshot timestamp is newer than or equal to the local reference timestamp.
    ...  - False otherwise.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${ftp_snap_ts}=  Evaluate
    ...  datetime.datetime.strptime('${ftp_snap_timestamp}', '%Y%m%d-%H%M').strftime('%Y%m%d%H%M%S')
    ...  modules=datetime
    ${ftp_snap_ts_int}=  Convert To Integer  ${ftp_snap_ts}
    ${local_timestamp_int}=  Convert To Integer  ${local_timestamp}
    [Return]  ${ftp_snap_ts_int} >= ${local_timestamp_int}


Compare Initial And Final Snapshot Files
    [Documentation]  This keyword compares the content of the initial and final snapshot history files.
    ...
    ...  It ensures that the final snapshot history file content is different from the initial one, indicating that a new snapshot has been added.
    ...
    ...  Behavior:
    ...  - Reads the initial and final snapshot history files.
    ...  - Compares their content as strings.
    ...  - Logs an error and fails the test if the content is identical.
    ...  - Logs a success message if the content is different.
    ...
    ...  Returns:
    ...  - A list of lines from the final snapshot history file.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${initial_file}=  Set Variable  ${CFG.test_logs_path}/TestFiles/Snapshot_history_thermal_initial.txt
    ${final_file}=  Set Variable  ${CFG.test_logs_path}/TestFiles/Snapshot_history_thermal_final.txt
    ${result}=  Process.Run Process  python3  ${EXECDIR}/custom-config/compare_snapshot_files.py  ${initial_file}
    ...  ${final_file}  shell=True  stdout=TRUE  stderr=TRUE
    ${rc}=  Set Variable  ${result.rc}
    ${stdout}=  Set Variable  ${result.stdout}
    ${stderr}=  Set Variable  ${result.stderr}
    Logging With Timestamp
    ...  message=Compared files: ${initial_file} and ${final_file}
    ...  style=INFO
    Logging With Timestamp
    ...  message=Comparison result:\n${stdout}
    ...  style=INFO
    IF  ${rc} == 1
      Fail  Snapshot history file content did not change. Investigate if snapshot saved on ftp server.
    ELSE IF  ${rc} == 0
      Logging With Timestamp
      ...  message=Snapshot history file content has changed. Snapshot has been sent to ftp server. Checking server side.
    END
    ${lines_final}=  OperatingSystem.Get File  ${final_file}
    @{lines_final}=  Split To Lines  ${lines_final}
    [Return]  ${lines_final}

Check Timestamp In Log File
    [Arguments]  ${lines}
    [Documentation]  This keyword checks if any timestamp in the provided log lines is newer than or equal to a reference timestamp.
    ...
    ...  The reference timestamp is derived from the `BTS_TIMESTAMP` variable, converted to UTC format.
    ...  Each log line is processed to extract timestamps, which are then compared against the reference timestamp.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | lines                  | Yes  | A list of log lines to check for timestamps.                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Converts the `BTS_TIMESTAMP` to UTC format.
    ...  - Iterates through the provided log lines and extracts timestamps using the `Get Timestamp From Line` keyword.
    ...  - Compares each extracted timestamp with the reference timestamp.
    ...  - Logs whether the timestamp is newer or older than the reference timestamp.
    ...  - Fails the test if no matching timestamp is found.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${part1}=  Set Variable  datetime.datetime.strptime('${BTS_TIMESTAMP}', '%Y%m%d%H%M%S')
    ${part2}=  Set Variable  .replace(tzinfo=datetime.timezone(datetime.timedelta(hours=2)))
    ${part3}=  Set Variable  .astimezone(datetime.timezone.utc).strftime('%Y%m%d%H%M%S')
    ${utc_timestamp}=  Evaluate  ${part1}${part2}${part3}  modules=datetime
    ${found}=  Set Variable  False
    FOR  ${line}  IN  @{lines}
      ${log_time}=  Get Timestamp From Line  ${line}
      IF  '${log_time[0]}'=='None'
        Continue For Loop
      ELSE
        ${ts_compact}=    Evaluate
        ...  int(datetime.datetime.strptime('${log_time[0]}'.replace('Z',''), '%Y-%m-%dT%H:%M:%S.%f').strftime('%Y%m%d%H%M%S'))
        ...  modules=datetime
        IF  ${ts_compact} >= ${utc_timestamp}
          Log To Console  Snapshot hitory timestamp is newer ${ts_compact} than the reference point ${utc_timestamp}
          ${found}=  Set Variable  True
          Exit For Loop
        ELSE
          Log To Console  Snapshot hitory timestamp is older ${ts_compact} than the reference point ${utc_timestamp}
        END
      END
    END
    IF  '${found}'=='False'
      Logging With Timestamp
      ...  message=No matching timestamp found after the reference point ${utc_timestamp}
      ...  style=ERROR
      Fail  No matching timestamp found after the reference point ${utc_timestamp}
    ELSE
      Logging With Timestamp
      ...  message=Match found after the reference point ${utc_timestamp}
      ...  style=DONE
    END

Get Timestamp From Line
    [Arguments]  ${line}
    [Documentation]  This keyword extracts a timestamp from a given log line using a regular expression.
    ...
    ...  The extracted timestamp is expected to match the format `YYYY-MM-DDTHH:MM:SS.sssZ`.
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | line                   | Yes  | The log line from which the timestamp will be extracted.           |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  Returns:
    ...  - A list of timestamps matching the specified format found in the log line.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${REGEX}  Set Variable  "start_time\":\"(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d{3}Z)"
    ${timestamps}=  Evaluate  __import__('re').findall(r'''${REGEX}''', """${line}""")
    [Return]  ${timestamps}

Recovery Action For Thermal Monitoring Snapshot Triggering
    [Documentation]  This keyword performs recovery actions for thermal monitoring snapshot triggering.
    ...
    ...  It ensures that the commissioning process is performed and verifies the availability status of various components.
    ...  If any component is offline, not installed, failed, or degraded, the keyword continues execution while logging the failure.
    ...
    ...  Behavior:
    ...  - Performs commissioning using the initial SCF file.
    ...  - Verifies the availability status of RMOD, LNCEL, NRCEL, WNCEL, and GNCEL components.
    ...  - Logs any failures and continues execution.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com
    Perform Commissioning
    ...  bts_id=${CFG.active_bts_list[0]}  scf_file=${CFG.test_logs_path}/TestFiles/initial_scf.xml
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300  connection=${CFG.active_bts_list[0]}
    Run Keyword And Continue On Failure
    ...  admin.Assert Any  RMOD
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=180
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  RMOD
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=300
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  LNCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  search_for_iot_cells=${True}
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  NRCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  WNCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  GNCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
