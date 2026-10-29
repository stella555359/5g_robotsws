*** Settings ***
Documentation
    ...  AUTHOR-izabela.wencel@nokia.com  MAINTAINER-izabela.wencel@nokia.com
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/...
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...
    ...  PRECONDITIONS:
    ...  The test requires SCF prepared so that only recommissioning of activating parameters
    ...  is required from the test:
    ...  - for 5GC000431 actNrLBPowerSaving = True
    ...  - for CB007511 energySavingMode = DEEPSLEEP
    ...  To activate actNrLBPowerSaving parameter, the following steps are required
    ...  (the test only chacks if they were commissioned):
    ...  - creating at least one NRPGRP (MRBTS-xxxx/NRBTS-xxxx/NRPGRP-x)
    ...  - creating a Structure-x under lbpsCellPeriodList & lbpsPeriodList
    ...    for each cell on tested RMOD and day of the week when testing
    ...    - if testing should be possible 24/7 create seven structures,
    ...      for each choose different lbpsCellDayOfWeek "Mon" (Possible: Mon, Tue, Wed, Thu, Fri, Sat, Sun)
    ...      for each set llbpsCellDuration to "1440" min (=24h)
    ...      set lbpsCellSOMethod to "cell switch off"
    ...      lbpsCellStartTimeHour leave with "0" h
    ...      lbpsCellStartTimeMinute leave with "0" min
    ...      nrCellId must be set to the tested cell number
    ...  - creating Strucuture-x under Load-based power saving cell list (lbpsCellList)
    ...    for each cell on tested RMOD
    ...    - leave lbpsUseExtConfig to "false"
    ...    - nrCellId to cell number
    ...  - setting lbpsLastCellSOEnabled - change from "false" to "true"
    ...  - object MRBTS-${bts_id}/MNL-x/MNLENT-x/PMMNL-x should be created

Resource  ../../Resources/Robot/SM.robot
Resource  ../../Resources/Robot/variables_preparation.robot
Resource  ../../Resources/variables_custom.robot
Resource  ../../TestCases/PM/PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot
Resource  ../../TestCases/FM/FM_Temperature_Fault_1937.robot

*** Variables ***
${TESTED_RMOD}=               # Mandatory, prvide one SN of an RMOD to be tested
${MTSBTSRFM_INTERVAL}=  5min  # Optional, possible values: disabled, 5min, 15min, 30min, 60min, 360min, 720min, 1440min
${INTERVAL}=  5
@{COUNTERS_LIST}=  M40003C2   # Optional
${MIN_COUNTER_VALUE}=  30     # Optional
${MAX_COUNTER_VALUE}=  100    # Optional
${LNCEL_sleep_states}=  administrativeState=regex"(?i)unlocked", operationalState=regex"(?i)disabled", blockingState=regex"(?i)Unblocked"
${NRCEL_sleep_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Disabled", blockingState=regex"(?i)Unblocked"

*** Keywords ***
TC__PM_Cell_Switchoff_For_Energy_Efficiency_Enhancement
    Common Test Setup
    Logging With Timestamp
    ...  message=Executing TC__PM_Cell_Switchoff_For_Energy_Efficiency_Enhancement
    ...  style=ONGOING
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Step 1 Preconditions For Cell Switchoff For Energy  ${bts_id}
    Step 2 Measure RU Power When Cells Enabled
    Step 3 Activate Parameters For EE  ${bts_id}
    Step 4 Wait For Switch Off  ${bts_id}
    Step 5 Measure RU Power When Cells Disabled
    Step 6 Deactivate Parameters For EE  ${bts_id}
    Step 7 Calculate Differences Of Power
    [Teardown]  Teardown_PM_Cell_Switchoff_For_Energy_Efficiency_Enhancement  tc_status=${KEYWORD_STATUS}

Step 1 Preconditions For Cell Switchoff For Energy
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 1 Preconditions For Cell Switchoff For Energy
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${TEARDOWN_RECOMMISSIONING}  ${False}

    ${rmod_dn}  ${rmod_name}  ${tested_rmod_dn_r}  ${deepsleep_support}=  Get Tested RMOD Details  ${bts_id}
    Set Test Variable  ${TESTED_RMOD_DN}  ${rmod_dn}
    Set Test Variable  ${TESTED_RMOD_NAME}  ${rmod_name}
    Set Test Variable  ${TESTED_RMOD_DN_R}  ${tested_rmod_dn_r}
    Set Test Variable  ${DEEPSLEEP_SUPPORT}  ${deepsleep_support}

    ${nrcell_list}  Get Ids For All  NRCEL  connection=${bts_id}
    ${nrcel_count}=  Get Length  ${nrcell_list}
    Set Test Variable  ${NRCEL_COUNT}  ${nrcel_count}

    ${tested_cells_dns}=  admin.Get Cell Mapping By Module ID
    ...  module_id=${tested_rmod_dn_r}
    ...  timeout=60
    ...  connection=${bts_id}
    Set Test Variable  ${TESTED_CELLS_DNS}  ${tested_cells_dns}

    IF  ${DEEPSLEEP_SUPPORT}==${True}
      Logging With Timestamp
      ...  message=RMOD in the DeepSleep supported list, checking whether Power state with DEEPSLEEP value.
      ...  style=ONGOING
      Check Whether Deepsleep Active  ${bts_id}  ${False}
    ELSE
      Logging With Timestamp
      ...  message=RMOD ${TESTED_RMOD_NAME} NOT in the DeepSleep supported list, skipping Power state status.
      ...  style=DONE
    END

    ${status_nr}=  Evaluate  ${NRCEL_COUNT} > 0
    IF  ${status_nr}==${True}
      Logging With Timestamp
      ...  message=NR present in the test line, checking whether actNrLBPowerSaving active.
      ...  style=ONGOING
      Check Whether actNrLBPowerSaving Active  ${bts_id}  ${False}
    ELSE
      Logging With Timestamp
      ...  message=NR NOT present in the test line, skipping actNrLBPowerSaving status.
      ...  style=DONE
    END

    Check Whether actPowerMeter Active  ${bts_id}
    Check Whether mtSBTSSmEnergyMonitoring Active  ${bts_id}

    STATE Verify States For One
    ...  class=RMOD
    ...  object=${TESTED_RMOD_DN_R}
    ...  node_id=${bts_id}
    ...  onair=${TRUE}
    ...  timeout=60

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      STATE Verify States For One
      ...  class=${class}
      ...  object=${tested_cell_dn}
      ...  node_id=${bts_id}
      ...  onair=${TRUE}
      ...  timeout=60
    END

    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}

    admin.Get Current Scf File
    ...  local_dir_path=${TEST_LOGS_PATH}BTSFiles/${bts_id}/
    ...  file_name=initial_scf.xml
    ...  timeout=30
    ...  connection=${bts_id}
    ...  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=None

    Logging With Timestamp
    ...  message=Step 1 Preconditions For Cell Switchoff For Energy
    ...  style=DONE

Step 2 Measure RU Power When Cells Enabled
    Logging With Timestamp
    ...  message=Step 3 Measure RU Power When Cells Enabled
    ...  style=STEP
    ...  frame=${TRUE}
    @{TESTED_RMOD_LIST}=  Create List  ${TESTED_RMOD}
    Logging With Timestamp
    ...  message=Measuring power of the carriers (method to be changed when counters implemented)
    ...  style=ONGOING
    ${initial_carriers_power}=  Verify Power Of The Carriers And Return Values  ${TESTED_RMOD_LIST}
    Set Test Variable  ${INITIAL_CARRIERS_POWER}  ${initial_carriers_power}
    Logging With Timestamp
    ...  message=Initial power of the carriers measured: ${initial_carriers_power}
    ...  style=DONE

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_verification}  ${counterLenght_lastTimestamp}  Run Keyword And Ignore Error  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_LIST}
    ...  min_range=${MIN_COUNTER_VALUE}
    ...  max_range=${MAX_COUNTER_VALUE}
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    Set Test Variable  ${PM_LENGTH_ENABLED}  ${counterLenght_lastTimestamp}[0]
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED}  ${counterLenght_lastTimestamp}[1]

Step 3 Activate Parameters For EE
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Activate Parameters For EE
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${TEARDOWN_RECOMMISSIONING}  ${True}

    IF  ${DEEPSLEEP_SUPPORT}==${True}
      Logging With Timestamp
      ...  message=Activating parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
      ...  dist_name=${TESTED_RMOD_DN}
      ...  parameter=energySavingMode
      ...  operation=update
      ...  value=DEEPSLEEP
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
      Check Whether Deepsleep Active  ${bts_id}  ${True}
    ELSE
      Logging With Timestamp
      ...  message=DeepSleep not supported - parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 activation skipped.
      ...  style=WARNING
    END

    ${status_nr}=  Evaluate  ${NRCEL_COUNT} > 0
    IF  ${status_nr}==${True}
      Logging With Timestamp
      ...  message=Activating parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id}.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
      ...  parameter=actNrLBPowerSaving
      ...  operation=update
      ...  value=${True}
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
      Check Whether actNrLBPowerSaving Active  ${bts_id}  ${True}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} active.
      ...  style=DONE
    END

    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}

Step 4 Wait For Switch Off
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 4 Wait For Switch Off
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Waiting for cells and rmod to get into sleep mode.
    ...  style=ONGOING
    Sleep  305s  Waiting for cells and rmod to get into sleep mode.

    FOR  ${tested_cell_dn}  IN  @{tested_cells_dns}
      ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${tested_cell_dn}  separator=/  max_split=2
      ${class}=  Fetch From Left  ${cell_r_number}  marker=_
      ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
      STATE Verify States For One
      ...  class=${class}
      ...  object=${tested_cell_dn}
      ...  node_id=${bts_id}
      ...  states=${${class}_sleep_states}
      ...  onair=${FALSE}
      ...  timeout=310
    END

    STATE Verify States For One
    ...  class=RMOD
    ...  object=${TESTED_RMOD_DN_R}
    ...  node_id=${bts_id}
    ...  onair=${TRUE}
    ...  timeout=60

    Check usageState And powerState  ${bts_id}

Step 5 Measure RU Power When Cells Disabled
    Logging With Timestamp
    ...  message=Step 5 Measure RU Power When Cells Disabled
    ...  style=STEP
    ...  frame=${TRUE}
    @{TESTED_RMOD_LIST}=  Create List  ${TESTED_RMOD}
    Logging With Timestamp
    ...  message=Measuring power of the carriers (method to be changed when counters implemented)
    ...  style=ONGOING
    ${sleep_carriers_power}=  Verify Power Of The Carriers And Return Values  ${TESTED_RMOD_LIST}
    Set Test Variable  ${SLEEP_CARRIERS_POWER}  ${sleep_carriers_power}
    Logging With Timestamp
    ...  message=Power of the carriers when cells disabled: ${sleep_carriers_power}
    ...  style=DONE

    ${time_to_sleep}  ${time_to_verdict}  Time To Sleep  ${INTERVAL}
    Logging With Timestamp
    ...  message=Waiting for ${time_to_sleep} minutes for next measurement interval ! \nVerdict will be released at *${time_to_verdict}* !
    ...  style=ONGOING
    Sleep  ${time_to_sleep} minutes

    ${counter_verification}  ${counterLenght_lastTimestamp}  Run Keyword And Ignore Error  Verify Counter And Return Length
    ...  counters_name=${COUNTERS_LIST}
    ...  min_range=${MIN_COUNTER_VALUE}
    ...  max_range=${MAX_COUNTER_VALUE}
    ...  bts_id=${bts_id}
    ...  return_timestamp=${TRUE}

    Set Test Variable  ${PM_LENGTH_ENABLED2}  ${counterLenght_lastTimestamp}[0]
    Set Test Variable  ${LAST_TIMESTAMP_ENABLED2}  ${counterLenght_lastTimestamp}[1]

Step 6 Deactivate Parameters For EE
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Step 6 Deactivate Parameters For EE
    ...  style=STEP
    ...  frame=${TRUE}

    IF  ${DEEPSLEEP_SUPPORT}==${True}
      Logging With Timestamp
      ...  message=Deactivating parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
      ...  dist_name=${TESTED_RMOD_DN}
      ...  parameter=energySavingMode
      ...  operation=update
      ...  value=NORMAL
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
      Check Whether Deepsleep Active  ${bts_id}  ${False}
    ELSE
      Logging With Timestamp
      ...  message=DeepSleep not supported - parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 deactivation skipped.
      ...  style=WARNING
    END

    ${status_nr}=  Evaluate  ${NRCEL_COUNT} > 0
    IF  ${status_nr}==${True}
      Logging With Timestamp
      ...  message=Deactivating parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id}.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/NRBTS-${bts_id}
      ...  parameter=actNrLBPowerSaving
      ...  operation=update
      ...  value=${False}
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
      Check Whether actNrLBPowerSaving Active  ${bts_id}  ${False}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} inactive.
      ...  style=DONE
    END

    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}

Step 7 Calculate Differences Of Power
    Logging With Timestamp
    ...  message=Step 7 Calculate Differences Of Power
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Step 7 Calculate Differences Of Power will be introduced when power measurement for AWHQN is implemented.
    ...  style=WARNING
    Logging With Timestamp
    ...  message=Power measurements are: initial - ${INITIAL_CARRIERS_POWER}, sleep - ${SLEEP_CARRIERS_POWER}
    ...  style=WARNING

# TODO: Left for enhancement which is planned with introduction of counters for AWHQN in next fb
#    ${tx_initial_values}=  Get Dictionary Values  ${INITIAL_CARRIERS_POWER['${TESTED_RMOD}_TX']}
#    ${rx_initial_values}=  Get Dictionary Values  ${INITIAL_CARRIERS_POWER['${TESTED_RMOD}_RX']}
#    ${initial_tx_power_sum}=  Evaluate  0
#    FOR  ${ant}  IN  @{INITIAL_CARRIERS_POWER['${TESTED_RMOD}_TX']}
#      FOR  ${value}  IN  @{INITIAL_CARRIERS_POWER['${TESTED_RMOD}_TX']['${ant}']}
#        ${initial_tx_power_sum}=  Evaluate  ${initial_tx_power_sum}+${value}
#      END
#    END
#    FOR  ${value}  IN  @{tx_initial_values}
#      ${value_int}=   Get Dictionary Values  ${value}
#      ${initial_tx_power_sum}=  Evaluate  ${initial_tx_power_sum}+${value_int}
#    END
#    Log To Console  ${FINAL_CARRIERS_POWER}

Get Tested RMOD Details
    [Arguments]  ${bts_id}
    [Documentation]  This keyword retrieves details of the tested RMOD based on its serial number.
    ...
    ...  It verifies if the RMOD is present in the configuration, retrieves its details, and checks if it supports DeepSleep.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the RMOD is connected.               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Checks if the tested RMOD is present in the configuration.
    ...  - Retrieves the RMOD's distinguished name (DN) and variant name.
    ...  - Identifies the RMOD's distribution name for testing.
    ...  - Verifies if the RMOD supports DeepSleep.
    ...
    ...  Returns:
    ...  - The RMOD's distinguished name (DN).
    ...  - The RMOD's variant name.
    ...  - The RMOD's distribution name for testing.
    ...  - A boolean indicating whether the RMOD supports DeepSleep.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${rmods_sns}=  Get Dictionary Keys  ${CFG.RF_INFO}
    ${chosen_rmod_in_tl_status}=  Run Keyword And Return Status  List Should Contain Value  ${rmods_sns}  ${TESTED_RMOD}

    IF  ${chosen_rmod_in_tl_status}==${False}
      Logging With Timestamp
      ...  message=Tested RMOD ${TESTED_RMOD} NOT found in CFG. Check SN and configuration files!
      ...  style=ERROR
      Fail  Tested RMOD ${TESTED_RMOD} NOT found in CFG. Check SN and configuration files!
    ELSE
      Logging With Timestamp
      ...  message=Tested RMOD ${TESTED_RMOD} found in CFG. Continue testing.
      ...  style=DONE
    END

    ${rmod_dn}=  Get From Dictionary  ${CFG.RF_INFO['${TESTED_RMOD}']}  scf_dist_name_primary
    ${rmod_name}=  Get From Dictionary  ${CFG.RF_INFO['${TESTED_RMOD}']}  scf_variant
    &{sfp_links}=  admin.Get Sfp Links  connection=${bts_id}
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${TESTED_RMOD}'!='${link['parent']['source']['parameters']['serialNumber']}'
      ${tested_rmod_dn_r}=  Set Variable  ${link['parent']['source']['distName']}
      Exit For Loop
    END

    ${deepsleep_list_exist}=  Run Keyword And Return Status  Variable Should Exist  ${RMODS_SUPPORTING_DEEP_SLEEP}
    IF  ${deepsleep_list_exist}==${True}
      ${deepsleep_support}=  Run Keyword And Return Status  List Should Contain Value  ${RMODS_SUPPORTING_DEEP_SLEEP}  ${rmod_name}
    ELSE
      Logging With Timestamp
      ...  message=List ${RMODS_SUPPORTING_DEEP_SLEEP} does not exist. Check resources!
      ...  style=ERROR
      Fail  List ${RMODS_SUPPORTING_DEEP_SLEEP} does not exist. Check resources!
    END

    [Return]  ${rmod_dn}  ${rmod_name}  ${tested_rmod_dn_r}  ${deepsleep_support}

Verify Power Of The Carriers And Return Values
    [Arguments]  ${rmods_to_be_tested}
    [Documentation]  This keyword retrieves and logs the power values of carriers for specified RMODs in both TX and RX directions.
    ...
    ...  It iterates through the provided RMODs and retrieves the power values for each direction (TX/RX).
    ...  The power values are stored in a dictionary and logged for verification.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | rmods_to_be_tested     | Yes  | A list of RMODs for which the power values are retrieved.|
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Iterates through the provided RMODs and directions (TX/RX).
    ...  - Retrieves the carrier power values using the `radio.Get Carriers Power` keyword.
    ...  - Logs the retrieved power values for each RMOD and direction.
    ...  - Stores the power values in a dictionary for further use.
    ...
    ...  Returns:
    ...  - A dictionary containing the power values for each RMOD and direction.
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    @{tx_rx}=  Create List  TX  RX
    &{carriers_power_dict}=  Create Dictionary
    FOR  ${rmod}  IN  @{rmods_to_be_tested}
      FOR  ${dir}  IN  @{tx_rx}
        ${carriers_power}=  radio.Get Carriers Power
        ...  ru_serial_number=${rmod}
        ...  direction=${dir}
        ...  print_table=${True}
        ...  print_table=${True}
        ...  return_antennas=${True}
        Set To Dictionary  ${carriers_power_dict}  ${rmod}_${dir}=${carriers_power}
        ${carriers_power_values}  Get Dictionary Values  ${carriers_power}
        ${power_values_list}  Get Power Values For RU  ${carriers_power_values}
        Logging With Timestamp
        ...  message=Carriers power: ${power_values_list}
      END
    END

    [Return]  ${carriers_power_dict}

Check Whether Deepsleep Active
    [Arguments]  ${bts_id}  ${is_active}=${False}
    [Documentation]  This keyword verifies whether the DeepSleep mode is active for the tested RMOD.
    ...
    ...  It retrieves the `energySavingMode` parameter for the RMOD and compares it with the expected state.
    ...  If the parameter value does not match the expected state, the test fails with an appropriate error message.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the RMOD is connected.               |
    ...  | is_active              | No   | Expected state of the DeepSleep mode (default: False).   |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `energySavingMode` parameter for the tested RMOD.
    ...  - Compares the parameter value with the expected state (`is_active`).
    ...  - Logs whether the parameter value matches the expected state.
    ...  - Fails the test if the parameter value does not match the expected state.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${parameter1}  admin.Get Parameter By Distname  ${TESTED_RMOD_DN}  connection=${bts_id}
    ${energy_saving_param}=  Get From Dictionary  ${parameter1[0]['parameters']}  energySavingMode
    IF  ${is_active}==${False}
      IF  '${energy_saving_param}'=='DEEPSLEEP'
        Logging With Timestamp
        ...  message=Parameter energySavingMode for ${TESTED_RMOD} is set to DEEPSLEEP - not ${is_active} - unexpected value: ${energy_saving_param}
        ...  style=ERROR
        Fail  Parameter energySavingMode for ${TESTED_RMOD} is set to DEEPSLEEP - not ${is_active}: unexpected value: ${energy_saving_param}
      ELSE
        Logging With Timestamp
        ...  message=Parameter energySavingMode for ${TESTED_RMOD} is set to DEEPSLEEP - ${is_active}: expected value: ${energy_saving_param}. OK.
        ...  style=DONE
      END
    ELSE
      IF  '${energy_saving_param}'!='DEEPSLEEP'
        Logging With Timestamp
        ...  message=Parameter energySavingMode for ${TESTED_RMOD} is set to DEEPSLEEP - not ${is_active} - unexpected value: ${energy_saving_param}
        ...  style=ERROR
        Fail  Parameter energySavingMode for ${TESTED_RMOD} is set to DEEPSLEEP - not ${is_active}: unexpected value: ${energy_saving_param}
      ELSE
        Logging With Timestamp
        ...  message=Parameter energySavingMode for ${TESTED_RMOD} is set to DEEPSLEEP - ${is_active}: expected value: ${energy_saving_param}. OK.
        ...  style=DONE
      END
    END

Check Whether actNrLBPowerSaving Active
    [Arguments]  ${bts_id}  ${is_active}=${False}
    [Documentation]  This keyword verifies whether the `actNrLBPowerSaving` parameter is active for the specified BTS.
    ...
    ...  It retrieves the `actNrLBPowerSaving` parameter value and compares it with the expected state.
    ...  If the parameter value does not match the expected state, the test fails with an appropriate error message.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the parameter belongs.               |
    ...  | is_active              | No   | Expected state of the `actNrLBPowerSaving` parameter.    |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `actNrLBPowerSaving` parameter value for the specified BTS.
    ...  - Compares the parameter value with the expected state (`is_active`).
    ...  - Logs whether the parameter value matches the expected state.
    ...  - Fails the test if the parameter value does not match the expected state.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${nrbts_info}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/NRBTS-${bts_id}  connection=${bts_id}
    ${act_nr_lb_power_param}=  Get From Dictionary  ${nrbts_info[0]['parameters']}  actNrLBPowerSaving
    IF  ${is_active}==${False}
      IF  ${act_nr_lb_power_param}==${True}
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} activated. Check SCF!
        ...  style=ERROR
        Fail  Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} activated. Check SCF!
      ELSE
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} NOT activated. Expected value.
        ...  style=DONE
      END
    ELSE
      IF  ${act_nr_lb_power_param}==${False}
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} NOT activated. Unexpected value!
        ...  style=ERROR
        Fail  Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} NOT activated. Unexpected value!
      ELSE
        Logging With Timestamp
        ...  message=Parameter actNrLBPowerSaving for MRBTS-${bts_id}/NRBTS-${bts_id} activated. Expected value.
        ...  style=DONE
      END
    END

Check Whether actPowerMeter Active
    [Arguments]  ${bts_id}
    [Documentation]  This keyword verifies whether the `actPowerMeter` parameter is active for the specified BTS.
    ...
    ...  It retrieves the `actPowerMeter` parameter value and checks if it is activated.
    ...  If the parameter is not activated, the test fails and attempts to activate it.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the parameter belongs.               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `actPowerMeter` parameter value for the specified BTS.
    ...  - Logs whether the parameter is activated or not.
    ...  - Fails the test if the parameter is not activated and attempts to activate it.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${bts_id}
    ${act_power_meter_value}  Get From Dictionary  ${featcadm_parameter[0]['parameters']}  actPowerMeter
    IF  ${act_power_meter_value}==${False}
      Logging With Timestamp
      ...  message=Parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 NOT activated. Check SCF!
      ...  style=WARNING
      Fail  Parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 NOT activated. Check SCF!
      admin.Perform Parameter Recommissioning
      ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1
      ...  parameter=actPowerMeter
      ...  operation=update
      ...  value=${TRUE}
      ...  skip_parameter_relation_errors=${True}
      ...  timeout=60
      ...  connection=${bts_id}
    ELSE
      Logging With Timestamp
      ...  message=Parameter actPowerMeter for MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1 activated.
      ...  style=DONE
    END

Check Whether mtSBTSSmEnergyMonitoring Active
    [Arguments]  ${bts_id}
    [Documentation]  This keyword verifies whether the `mtSBTSSmEnergyMonitoring` parameter is active for the specified BTS.
    ...
    ...  It retrieves the `mtSBTSSmEnergyMonitoring` parameter value and updates it if necessary.
    ...  If the parameter is not found or has an unexpected value, the test fails with an appropriate error message.
    ...
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the parameter belongs.               |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the `mtSBTSSmEnergyMonitoring` parameter value for the specified BTS.
    ...  - Updates the parameter value if it does not match the expected value.
    ...  - Logs whether the parameter value matches the expected value.
    ...  - Fails the test if the parameter is not found or has an unexpected value.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${pmmnl_parameter}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
    ${status}  ${mtSBTSSmEnergyMonitoring_value}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${pmmnl_parameter[0]['parameters']}  mtSBTSSmEnergyMonitoring
    IF  '${status}'=='FAIL'
      Logging With Timestamp
      ...  message=Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 NOT found. Check SCF!
      ...  style=ERROR
      Fail  Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 NOT found. Check SCF!
    ELSE
      Logging With Timestamp
      ...  message=Updating parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1.
      ...  style=ONGOING
      admin.Perform Parameter Recommissioning
        ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1
        ...  parameter=mtSBTSSmEnergyMonitoring
        ...  operation=update
        ...  value=${MTSBTSRFM_INTERVAL}
        ...  skip_parameter_relation_errors=${True}
    #    ...  should_activate (bool)  Should automatically activate plan
        ...  timeout=60
        ...  connection=${bts_id}
      ${pmmnl_parameter2}=  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${bts_id}
      ${mtSBTSSmEnergyMonitoring_value2}=  Get From Dictionary  ${pmmnl_parameter2[0]['parameters']}  mtSBTSSmEnergyMonitoring
      ${mtSBTSSmEnergyMonitoring_status2}=  Run Keyword And Return Status  Should Be Equal  ${mtSBTSSmEnergyMonitoring_value2}  ${MTSBTSRFM_INTERVAL}
      IF  ${mtSBTSSmEnergyMonitoring_status2}==${False}
        Logging With Timestamp
        ...  message=Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 with UNexpected value! Please investigate!
        ...  style=ERROR
        Fail  Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 with UNexpected value! Please investigate!
      ELSE
        Logging With Timestamp
        ...  message=Parameter mtSBTSSmEnergyMonitoring for MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1 with expected value ${MTSBTSRFM_INTERVAL}.
        ...  style=DONE
      END
    END

Check usageState And powerState
    [Arguments]  ${bts_id}
    [Documentation]  This keyword retrieves and logs the `usageState` and `powerState` of the tested RMOD.
    ...
    ...  It also retrieves the `energySavingMode` parameter for the RMOD and logs all the values.
    ...
    ...  Arguments:
    ...  +========================+======+===============================================+
    ...  | Argument               | Man. | Description                                   |
    ...  +========================+======+===============================================+
    ...  | bts_id                 | Yes  | The BTS ID to which the RMOD is connected.    |
    ...  +------------------------+------+-----------------------------------------------+
    ...
    ...  Behavior:
    ...  - Retrieves the RMOD information using the `admin.Get Frm` keyword.
    ...  - Extracts the `energySavingMode`, `usageState`, and `powerState` values.
    ...  - Logs the retrieved values for verification.
    ...
    ...  Returns:
    ...  - None
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${rmods_info}=  admin.Get Frm  connection=${bts_id}  timeout=60
    FOR  ${rmod_info}  IN  @{rmods_info}
      IF  "${rmod_info['id']['configuration']}"=="${TESTED_RMOD_DN}"
        ${ru_energy_mode_parameter}=  Create List  energySavingMode
        ${param_value}=  admin.Get Parameter By Distname
        ...  dist_name=${rmod_info['id']['configuration']}
        ...  parameter_list=${ru_energy_mode_parameter}  connection=${bts_id}
        ${energy_mode}=  Set Variable  "${param_value[0]['parameters']['energySavingMode']}"
        ${usage_state}=  Set Variable  "${rmod_info['status']['usageState']}"
        ${power_state}=  Set Variable  "${rmod_info['status']['powerState']}"
        Logging With Timestamp
        ...  message=For tested RMOD ${TESTED_RMOD} energySavingMode is ${energy_mode}, usageState is ${usage_state} and powerState is ${power_state}
        ...  style=DONE
      END
    END

Teardown_PM_Cell_Switchoff_For_Energy_Efficiency_Enhancement
    [Arguments]  ${tc_status}
    [Documentation]  Teardown procedures
    ...  Arguments:
    ...  +========================+======+==========================================================+
    ...  | Argument               | Man. | Description                                              |
    ...  +========================+======+==========================================================+
    ...  | tc_status              | Yes  | TC status                                                |
    ...  +------------------------+------+----------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com
    Logging With Timestamp
    ...  message=PM_Cell_Switchoff_For_Energy_Efficiency_Enhancement teardown started
    IF  "${tc_status}"=="FAIL" and ${TEARDOWN_RECOMMISSIONING}==${True}
      Run Keyword And Continue On Failure  admin.Perform Commissioning
      ...  bts_id=${CFG.active_bts_list[0]}  scf_file=${TEST_LOGS_PATH}BTSFiles/${CFG.active_bts_list[0]}/initial_scf.xml
      ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300  connection=${CFG.active_bts_list[0]}
      Run Keyword And Continue On Failure
      ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20  STATE Verify Multi Node State  scf_check=${FALSE}
    END
    Common Test Teardown
