*** Settings ***
Documentation
  ...  The purpose of this Test Case is to check the correct raise of fault 1933 to prevent overheat RF.
  ...  Author:        rafal.rokitowski@nokia.com
  ...  Maintainer:    rafal.rokitowski@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  **Input Parameters:**
  ...
  ...  +----------------------------------------+------+-------------------------------------------------------------------------------------------+
  ...  | Parameter                              | Man. | Description                                                                               |
  ...  +========================================+======+===========================================================================================+
  ...  | CUSTOM_RADIO_UNIT_LIST                 | Yes  | List of custom serial numbers radio units                                                 |
  ...  +----------------------------------------+------+-------------------------------------------------------------------------------------------+
  ...  | RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED  | No   | Enables test scenario with actRadioFanFailureEarlyNotification set to true. Default:True  |
  ...  +----------------------------------------+------+-------------------------------------------------------------------------------------------+
  ...  | RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED | No   | Enables test scenario with actRadioFanFailureEarlyNotification set to false. Default:True |
  ...  +----------------------------------------+------+-------------------------------------------------------------------------------------------+
  ...
  ...  The purpose of this Test Case is to check the correct raise of fault 1933 to prevent overheat RF
  ...  and verify of correct operation of fan(s).
  ...
  ...  For fault 1933 is possible to two scenario
  ...  RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED = True (default) - means that change in FID generate will be applied only for FAN object.
  ...  To skip this scenario, set flag to False.
  ...  RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED = True (default) - means that change in FID generate will be applied for FAN and temperature Offset.
  ...  To skip this scenario, set flag to False.
  ...
  ...  Fault ID name according to NIDD:
  ...  When actRadioFanFailureEarlyNotification = true: EFaultId_FrFanBrokenEarlyNotifAl
  ...  When actRadioFanFailureEarlyNotification = false: EFaultId_FanBroken
  ...
  ...  Detailed information about FaultGenerator (1933) both scenario:
  ...  1. Files in FRMON are decoded to JSONS. (tempest_inst1_default.bin and tcs.bin)
  ...  2. In tcs.json values: Nrmp_fail is modified (to 1) and RU reboot is performed.
  ...  3. Temperature of UNIT defined in variables.py is read from RU runtime logs.
  ...  4. Offset is calculated based on Tblock value in tcs.bin.
  ...  5. Decoded JSON tempest_inst1_default.json is downloaded to SMOD and edited (tempOffset value).
  ...  6. Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
  ...  7. Fan setpoint is modified to value: 0
  ...  8. Fault is trigger up to 960s, should be visible with severity Minor on WebEm and in fault_history_log.txt file
  ...     and in fault_history_log.txt file as EFaultId_FanBroken (1164) with severity critical.
  ...     With FID 1933 may be also visible FID 1937, 1932 or 1934.
  ...
  ...  TC works with RU: AHFII, AHLOB, AHEGG, AWHQN, AXEGHA.
  ...
  ...  Note:
  ...  1. Check before testing if your radio supports both fault generation scenario.
  ...  2. If you want to use only one of two scenarios, use flags RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED and RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED.
  ...  3. RU must be added to dictionaries in radio_variables.py.
  ...  4. For AWHQN and AXEGHA externaly FAN must be connected to RMOD before test.
  ...  5. For the AHWQN and AXEGHA flag 'rad-mpw 0x120040' is changed when generating instead of changing setpoint. The value is set to 0.
  ...
  ...  STEPS:
  ...  Step1: Prepare Preconditions for Fault 1933
  ...  Identify and verify RMOD under test using its serial number.
  ...  Ensure that appropriate test scenario flag is enabled (RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED or RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED).
  ...  Validate that both scenario flags are correctly set as boolean values.
  ...
  ...  Step2: Trigger Fault 1933
  ...  Ensure actRadioFanFailureEarlyNotif parameter is correctly set; reconfigure if needed.
  ...  Trigger Fault 1933 on target RMOD with selected early notification setting.
  ...  Add Fault IDs 10, 1932, 1933, and 1934 to list of allowed alarms (and 4773 if RF sharing is used).
  ...  Wait for Fault 1933 to be raised within expected timeout (based on early notification setting).
  ...  Verify that Fault 1933 is active on correct RMOD.
  ...  Check that corresponding fault entry (EFaultId_FrFanBrokenEarlyNotifAl or EFaultId_FanBroken) is logged in fault_history_log.txt.
  ...  If early notification is disabled, also check for presence of additional temperature-related faults (e.g., Fault 1937).
  ...
  ...  Step3: Recover Fault 1933
  ...  Initiate recovery procedure for Fault ID 1933 on target RMOD.
  ...  Wait for fault to clear and confirm that Fault 1933 is no longer active.
  ...  Verify that RMOD transitions through disabled and back to enabled operational states.
  ...  Ensure that all cells return to onAir state after recovery.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  30.05.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-26012 - Initial creation
  ...  12.07.2025 - Update for EFaultId_FrFanBrokenEarlyNotifAl fault check
  ...  22.07.2025 - Update for two FID1933 generation scenarios
  ...  08.10.2025 - Update for AWHQN alarms
  ...  04.11.2025 - Added verification of alarms presence in fault_history_log.txt for O-RAN RMODs
  ...  18.11.2025 - Implemented logic for SBTS26R3 and releases >26 to automatically assign correct fault name based on SW release
  ...  22.01.2026 - Update logic for new severity name on latest SW builds.

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***

@{CUSTOM_RADIO_UNIT_LIST}
${RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED}   True
${RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED}  True

*** Keywords ***
TC__FM_Fan_Fault_1933_Triggering
    Set Tags    AUTHOR-rafal.rokitowski@nokia.com  MAINTAINER-rafal.rokitowski@nokia.com
    Common Test Setup
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    ${is_not_empty}  Evaluate  len(${CUSTOM_RADIO_UNIT_LIST}) > 0
    IF  ${is_not_empty}
        ${rf_list}  Set Variable  ${CUSTOM_RADIO_UNIT_LIST}
    ELSE
        Fail  Variable {CUSTOM_RADIO_UNIT_LIST} is missing or empty! check mandatory parameters
    END

    FOR  ${rmod_sn}  IN  @{rf_list}
        Prepare Fault 1933 Preconditions  ${bts_id}  ${rmod_sn}
        IF  ${RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED}
            Trigger Fault 1933  ${bts_id}  ${rmod_sn}  True
            Recover Fault 1933  ${bts_id}  ${rmod_sn}
        END
        IF  ${RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED}
            Trigger Fault 1933  ${bts_id}  ${rmod_sn}  False
            Recover Fault 1933  ${bts_id}  ${rmod_sn}
        END
    END
    [Teardown]    Common Test Teardown

Prepare Fault 1933 Preconditions
    [Arguments]  ${bts_id}  ${rmod_sn}
    Logging With Timestamp
    ...  message=Prepare Fault 1933 Preconditions On ${rmod_sn}.
    ...  style=STEP
    ...  frame=${TRUE}

    ${rmods_info}  admin.Get FRM  timeout=60  connection=${bts_id}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${rmod_sn}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
        Set Test Variable  ${RMOD_DISTNAME_ID_CONF}  ${rmod['id']['configuration']}
    END

    IF  '${RMOD_DISTNAME_ID}' == '${NONE}'
        Logging With Timestamp
        ...  message=Serial Number ${rmod_sn} not found in HW Configuration! Test set to Fail!
        ...  style=FAIL
        Fail  Tested RMOD not found in HW Configuration! Test set to Fail!
    ELSE
        Logging With Timestamp
        ...  message=RMOD with SN ${rmod_sn} found in configuration.
    END

    IF  not ${RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED} and not ${RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED}
        Fail  Both RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED and RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED are False. At least one must be True.
    END

    IF  '${RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED}' not in ['True', 'False']
        Fail  RUN_SCENARIO_WITH_EARLY_NOTIF_ENABLED must be a boolean (True or False).
    END
    IF  '${RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED}' not in ['True', 'False']
        Fail  RUN_SCENARIO_WITH_EARLY_NOTIF_DISABLED must be a boolean (True or False).
    END

Trigger Fault 1933
    [Arguments]  ${bts_id}  ${rmod_sn}  ${early_notif}

    Logging With Timestamp
    ...  message=Trigger Fault 1933 (EarlyNotif=${early_notif}) On ${rmod_sn}.
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Verify value of actRadioFanFailureEarlyNotif.

    ${scf_node_file}  admin.Get Current Scf File
    ...  local_dir_path=${CFG.test_logs_path}/TestFiles/${bts_id}/
    ...  file_name=step_1_scf_${bts_id}_commissioning.xml
    ...  export_type=configuration
    ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
    ...  connection=${bts_id}

    ${scf_parameter_status}  Run Keyword And Ignore Error
    ...  Get Element Text
    ...  ${CFG.test_logs_path}/TestFiles/${bts_id}/step_1_scf_${bts_id}_commissioning.xml
    ...  xpath=//managedObject[contains (@class,'FMCADM')]/p[@name="actRadioFanFailureEarlyNotif"]

    ${early_notif_str}  Set Variable If  ${early_notif}  true  false
    Set Test Variable  ${original_value}  ${scf_parameter_status[1]}
    Set Test Variable  ${expected_value}  ${early_notif_str}

    IF  '${original_value}' != '${expected_value}'
        Logging With Timestamp
        ...  message=actRadioFanFailureEarlyNotif parameter has incorrect value (${original_value}). Trying to change it to ${expected_value}.
        ${reconf_status}    Run Keyword And Return Status
        ...  Perform actRadioFanFailureEarlyNotif Recommissioning  bts_id=${bts_id}  value=${early_notif_str}
        IF  not ${reconf_status}
            Fail  Recommissioning failed for actRadioFanFailureEarlyNotif.
        END
    ELSE
        Logging With Timestamp
        ...  message=Value of actRadioFanFailureEarlyNotif is correct -> ${original_value}.
    END

    Logging With Timestamp
    ...  message=Generate Fault 1933 on ${rmod_sn}.
    ...  style=ONGOING

    radio.Generate Fault  fault_id=1933  ru_serial_number=${rmod_sn}  fan_early_notif=${early_notif}  reboot_timeout=320

    ${ru_bts_ids}  Create List
    ...  ${CFG['RF_INFO']['${rmod_sn}']['scf_btsid_primary']}
    ...  @{CFG['RF_INFO']['${rmod_sn}']['scf_btsid_secondary']}
    ${secondary_bts_ids}  Create List  @{CFG['RF_INFO']['${rmod_sn}']['scf_btsid_secondary']}
    ${rfsharing_enabled}  Evaluate  ${CFG['RF_INFO']['${rmod_sn}']['scf_rfsharing']} == True

    FOR  ${ru_bts_id}  IN  @{ru_bts_ids}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  severity=Critical  serialNo=${rmod_sn}  connection=${ru_bts_id}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1933  connection=${ru_bts_id}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1932  connection=${ru_bts_id}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1934  connection=${ru_bts_id}
        IF  ${rfsharing_enabled}
            FOR  ${secondary_bts_id}  IN  @{secondary_bts_ids}
                Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=4773  serialNo=${rmod_sn}  connection=${ru_bts_id}
            END
        END
    END

    Logging With Timestamp
    ...  message=Waiting for raise of FaultID 1933 on ${rmod_sn}.
    ...  style=ONGOING

    ${alarm_timeout}  Set Variable If  ${early_notif}  120  960

    ${release}  admin.Get Sw Release Name  connection=${bts_id}
    ${release_major}  Evaluate  int('${release}'.replace('SBTS','').split('R')[0])

    ${proper_sw}  Is Proper SW  ${release}  ${release_major}  ${bts_id}
    ${fault_name}  Set Variable If  ${proper_sw}  "Fan not rotating"  "Cooling fan broken"

    ${proper_severity}  Is Proper Severity  ${early_notif}  ${release}  ${release_major}  ${bts_id}
    ${severity}  Set Variable If  ${proper_severity}  "Warning"  "Minor"

    IF  ${early_notif} == True
        ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active
        ...  faultId=1933
        ...  severity=${severity}
        ...  faultName=${fault_name}
        ...  alarmId=7115
        ...  alarmName="BASE STATION INFORMATION"
        ...  timeout=${alarm_timeout}
        ...  connection=${bts_id}
    ELSE
        ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Active
        ...  faultId=1933
        ...  severity="Minor"
        ...  faultName=${fault_name}
        ...  alarmId=7115
        ...  alarmName="BASE STATION INFORMATION"
        ...  timeout=${alarm_timeout}
        ...  connection=${bts_id}
    END

    IF  ${alarm_status}
        Logging With Timestamp
        ...  message=FaultID 1933 RAISED!
    ELSE
        Logging With Timestamp
        ...  message=Fail, FaultID 1933 NOT raised!
        ...  style=ERROR
        radio.Recover Fault  fault_id=1933  ru_serial_number=${rmod_sn}
        Fail  FaultID 1933 NOT raised!
    END

    ${scf_protocol_value}  Run Keyword And Ignore Error
    ...  Get Element Text
    ...  ${CFG.test_logs_path}/TestFiles/${bts_id}/step_1_scf_${bts_id}_commissioning.xml
    ...  xpath=//managedObject[contains(@class, "RMOD") and @distName="${RMOD_DISTNAME_ID_CONF}"]/p[@name="protocol"]

    IF  ${early_notif}
        ${fault_id}  Set Variable  1408
        ${fault_name}  Set Variable  EFaultId_FrFanBrokenEarlyNotifAl
    ELSE
        ${fault_id}  Set Variable  1164
        ${fault_name}  Set Variable  EFaultId_FanBroken
    END

    IF  "${scf_protocol_value[1]}"=="O-RAN"
        IF  ${early_notif}
            ${alarm_id}  Set Variable  2925
            ${alarm_name}  Set Variable  CoolingFanBrokenEarlyNotification
        ELSE
            ${alarm_id}  Set Variable  5
            ${alarm_name}  Set Variable  CoolingFanBroken
        END

        Logging With Timestamp
        ...  message=Checking ${fault_name} (${fault_id}) in fault_history_log.txt file.
        ${fault_active}  Run Keyword And Return Status
        ...  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${rmod_sn}  fault_id=${fault_id}  fault_name=${fault_name}

        Logging With Timestamp
        ...  message=Checking ${alarm_name} (${alarm_id}) in fault_history_log.txt file.
        ${alarm_active}  Run Keyword And Return Status
        ...  radio.Assert Active Alarm In Fault History Log File  ru_serial_number=${rmod_sn}  alarm_id=${alarm_id}  alarm_name=${alarm_name}

        ${both_active}  Evaluate  ${fault_active} and ${alarm_active}
        IF  ${both_active}
            Logging With Timestamp
            ...  message=As expected ${fault_id} and ${alarm_id} is active in fault_history_log.txt file.
        ELSE
            Logging With Timestamp
            ...  message= ${fault_id} or ${alarm_id} is not visible in fault_history_log.txt file, check logs!
            ...  style=ERROR
            radio.Recover Fault  fault_id=1933  ru_serial_number=${rmod_sn}
            Fail  Fault ${fault_id} or ${alarm_id} not found, please check fault_history_log.txt file.
        END
    ELSE
        Logging With Timestamp
        ...  message=Checking ${fault_name} (${fault_id}) in fault_history_log.txt file.
        ${fault_active}  Run Keyword And Return Status
        ...  radio.Assert Active Fault In Fault History Log File  ru_serial_number=${rmod_sn}  fault_id=${fault_id}  fault_name=${fault_name}

        IF  ${fault_active}
            Logging With Timestamp
            ...  message=As expected ${fault_name} (${fault_id}) is active in fault_history_log.txt file.
        ELSE
            Logging With Timestamp
            ...  message= ${fault_name} (${fault_id}) is not visible in fault_history_log.txt file, check logs!
            ...  style=ERROR
            radio.Recover Fault  fault_id=1933  ru_serial_number=${rmod_sn}
            Fail  Fault ${fault_name} (${fault_id}) not found, please check fault_history_log.txt file.
        END
    END

    Logging With Timestamp
    ...  message=Checking for presence of other temperature faults.
    ...  style=ONGOING

    ${1937_status}  Run Keyword And Return Status
    ...  admin.Assert Alarm Active  faultId=1937  severity=Critical  timeout=180  connection=${bts_id}

    IF  ${1937_status}
        Logging With Timestamp
        ...  message=An additional fault (1937) is present.
        FOR  ${ru_bts_id}  IN  @{ru_bts_ids}
            Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1937  serialNo=${rmod_sn}  connection=${ru_bts_id}
        END
    ELSE
        Logging With Timestamp
        ...  message=No other visible allowed faults are present.
    END

Recover Fault 1933
    [Arguments]  ${bts_id}  ${rmod_sn}
    Logging With Timestamp
    ...  message=Recover Fault 1933 on ${rmod_sn}.
    ...  style=STEP
    ...  frame=${TRUE}

    radio.Recover Fault  fault_id=1933  ru_serial_number=${rmod_sn}

    Logging With Timestamp
    ...  message=Waiting for clear of FaultID 1933 on ${rmod_sn}
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive
    ...  faultId=1933  timeout=300  connection=${bts_id}
    IF  ${alarm_status}
        Logging With Timestamp
        ...  message=Waiting for RMOD status disabled...
        admin.Assert  RMOD  ${RMOD_DISTNAME_ID}
        ...  operationalState=regex"(?i)disabled"
        ...  timeout=300
        ...  connection=${bts_id}
        Logging With Timestamp
        ...  message=Waiting for RMOD status enabled...
        admin.Assert  RMOD  ${RMOD_DISTNAME_ID}
        ...  operationalState=regex"(?i)enabled"
        ...  timeout=300
        ...  connection=${bts_id}
        Logging With Timestamp
        ...  message=RMOD ${rmod_sn} has correct state
        Logging With Timestamp
        ...  message=FaultID 1933 CLEARED!
    ELSE
        Logging With Timestamp
        ...  message=Fault 1933 NOT cleared, check logs!
        ...  style=ERROR
        Fail  Fault 1933 NOT cleared, check logs!
    END

    Assert All Cells Are OnAir  ${bts_id}

    IF  '${original_value}' != '${expected_value}'
        Logging With Timestamp
        ...  message=Restoring original value of actRadioFanFailureEarlyNotif: ${original_value}.
        ...  style=SUCCESS
        ${reconf_status}    Run Keyword And Return Status
        ...  Perform actRadioFanFailureEarlyNotif Recommissioning  bts_id=${bts_id}  value=${original_value}
        IF  not ${reconf_status}
            Fail  Failed to restore original value of actRadioFanFailureEarlyNotif.
        END
    END

Assert All Cells Are OnAir
    [Arguments]  ${bts_id}  ${timeout}=${CONFIGURATION_STARTUP_TIMEOUT}
    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir
    ...  timeout=${timeout}
    ...  bts_id=${bts_id}
    IF  ${onair_status}
        Logging With Timestamp
        ...  message=All cells are onAir.
    ELSE
        Logging With Timestamp
        ...  message=Cells are NOT onAir!
        ...  style=ERROR
        Fail  Cells are NOT onAir!
    END

Perform actRadioFanFailureEarlyNotif Recommissioning
    [Arguments]  ${bts_id}  ${value}
    [Documentation]  KW for recommissioning parameter EFaultId_FrFanBrokenEarlyNotifAl.
    ${status}  ${msg}  Run Keyword And Ignore Error  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FMCADM-1
    ...  parameter=actRadioFanFailureEarlyNotif
    ...  operation=update
    ...  value=${value}
    ...  connection=${bts_id}
    IF  "${status}"=="PASS"
        Logging With Timestamp
        ...  message=Parameter actRadioFanFailureEarlyNotif has been successfully set to ${value}.
    ELSE
        Logging With Timestamp
        ...  message=Parameter actRadioFanFailureEarlyNotif=${value} recommissioning failed.
        Log  Recommissioning output:\n${msg}    level=ERROR
    END

Is Proper SW
    [Arguments]  ${release}  ${release_major}  ${bts_id}
    IF  ${release_major} > 26 or "${release}" == "SBTS26R3"
        RETURN  ${True}
    END
    ${ok}=  Set Variable  ${False}
    IF  "${release}" == "SBTS26R2"
        ${ok}=  SWM Check If Current SW Build Is Newer Than
        ...  SBTS26R2_ENB_9999_251117_000007
        ...  bts_id=${bts_id}
    ELSE IF  "${release}" == "SBTS26R1"
        ${ok}=  SWM Check If Current SW Build Is Newer Than
        ...  SBTS26R1_ENB_0000_000175_000000
        ...  bts_id=${bts_id}
    END
    RETURN  ${ok}

Is Proper Severity
    [Arguments]  ${early_notif}  ${release}  ${release_major}  ${bts_id}
    IF  not ${early_notif}
        RETURN  ${False}
    END
    IF  ${release_major} > 26 or "${release}" == "SBTS26R3"
        RETURN  ${True}
    END
    IF  "${release}" == "SBTS26R2"
        ${result}=  SWM Check If Current SW Build Is Newer Than
        ...  SBTS26R2_ENB_9999_251203_000004
        ...  bts_id=${bts_id}
        RETURN  ${result}
    ELSE IF  "${release}" == "SBTS26R1"
        ${result}=  SWM Check If Current SW Build Is Newer Than
        ...  SBTS26R1_ENB_0000_000364_000000
        ...  bts_id=${bts_id}
        RETURN  ${result}
    END