*** Settings ***
Documentation
  ...  The purpose of this Test Case is to verify the correct handling of fault 1932 (1408 in fault_history_log.txt file).
  ...  Author:        rafal.rokitowski@nokia.com
  ...  Maintainer:    rafal.rokitowski@nokia.com
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...
  ...  **Input Parameters:**
  ...
  ...  +-----------------------------+------+---------------------------------------------------------------------+
  ...  | Parameter                   | Man. | Description                                                         |
  ...  +=============================+======+=====================================================================+
  ...  | RMOD_SN                     | Yes  | Serial number of selected radio module                              |
  ...  +-----------------------------+------+---------------------------------------------------------------------+
  ...  | FAN_NAME                    | Yes  | Custom name of selected FAN listed in dictionary CUSTOM_PDU_CONFIG  |
  ...  +-----------------------------+------+---------------------------------------------------------------------+
  ...  | REVERSE_CONTROL_PDU_SWITCH  | No   | A switch enabling reverse control of PDU, default False             |
  ...  +-----------------------------+------+---------------------------------------------------------------------+
  ...
  ...   CUSTOM_PDU_CONFIG dictionary example in TS:
  ...   &{CUSTOM_PDU_CONFIG}=
  ...   FAN_AHFII=EPC,8221-1,10.44.167.139,12             # FAN_NAME=model, PDU version, IP address, port number
  ...   FAN_AHLOB=EPC,8221-1,10.44.167.142,12             # FAN_NAME=model, PDU version, IP address, port number
  ...
  ...  The purpose of this Test Case is to verify inactivity of fault 1932 after turning off FAN(s) from PDU.
  ...  Fault ID name according to NIDD: EFaultId_FrNoFansDetected.
  ...  File in FRMON is decoded to JSONS. (tcs_parameters.bin).
  ...  Decoded JSON tcs_parameters.json is downloaded to SMOD and edited.
  ...  Edited JSON tempest_inst1_default.json is sent to RMOD and coded to binary file.
  ...  After FID generate, fault 1932 should not be visible for tested RU on WebEm.
  ...  After turning off FAN(s) form PDU, fault EFaultId_FanBroken (1164) should be active with severity Critical
  ...  in fault_history_log.txt file.
  ...  FID 1933 or 1934 may appear during the test.
  ...
  ...  TC works with RU families: 6.2*, tested on AHFII, AHLOB, AHEGG.
  ...
  ...  *RU must be added to dictionaries in radio_variables.py.
  ...  *FAN(s) on RU must be connected to outside PDU port.
  ...
  ...  STEPS:
  ...  Step1: Precondition For Triggering Fault 1932
  ...  Collect and verify info about tested RMOD.
  ...  Check FAN state on PDU.
  ...  Perform a soft reset of RMOD to clear fault_history_log.txt.
  ...  Verify that all cells are on air after soft reset.
  ...
  ...  Step2: Generate Fault 1932
  ...  Generate FID 1932.
  ...  Check Fault 1932 status.
  ...  Add FID 10 to allowed alarms.
  ...  Turn off selected FAN.
  ...  Verify that EFaultId_FrFanBrokenEarlyNotifAl (1408) is logged in fault_history_log.txt file.
  ...  Turn on selected FAN.
  ...  Verify that EFaultId_FrFanBrokenEarlyNotifAl (1408) is inactive in fault_history_log.txt file.
  ...
  ...  Step3: Recover Fault 1932
  ...  Initiate recovery procedure for FID 1932.
  ...  Check Fault 1932 status.
  ...  Verify that all cells are on air after recovery.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  11.06.2025 - Initial creation - CASE: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-26604
  ...  18.11.2025 - Added verification of actRadioFanFailureEarlyNotif parameter

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/Robot/PDU.robot

*** Variables ***

${RMOD_SN}
${FAN_NAME}
${REVERSE_CONTROL_PDU_SWITCH}  False
${EXPECTED_ACT_RADIO_FAN_FAILURE_VALUE}   true

*** Keywords ***
TC__FM_Fan_Fault_1932_Triggering
    Set Tags    AUTHOR-rafal.rokitowski@nokia.com  MAINTAINER-rafal.rokitowski@nokia.com
    Common Test Setup
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Logging With Timestamp
    ...  message=FM_Fan_Fault_1932_Triggering.robot will be executed
    ...  style=ONGOING
    Step1: Precondition For Triggering Fault 1932  ${bts_id}
    Step2: Generate Fault 1932  ${bts_id}  True
    Step3: Recover Fault 1932  ${bts_id}
    [Teardown]  Common Test Teardown

Step1: Precondition For Triggering Fault 1932
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Precondition For Triggering Fault On ${RMOD_SN}
    ...  style=STEP
    ...  frame=${TRUE}

    IF  '${RMOD_SN}'=='${EMPTY}'
        Logging With Timestamp
        ...  message=Variable RMOD_SN cannot be empty!
        ...  style=ERROR
        Fail  Variable RMOD_SN cannot be empty!
    END

    ${rmods_info}  admin.Get FRM  timeout=60  connection=${bts_id}

    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        Set Test Variable  ${RMOD_DISTNAME_ID}  ${rmod['id']['internal']}
    END

    IF  '${RMOD_DISTNAME_ID}'=='${NONE}'
        Logging With Timestamp
        ...  message=Serial Number ${RMOD_SN} not found in HW Configuration! Test set to Fail!
        ...  style=FAIL
        ...  Fail  Tested RMOD not found in HW Configuration! Test set to Fail!
    ELSE
        Logging With Timestamp
        ...  message=RMOD with SN ${RMOD_SN} found in configuration
    END

    ${pdu_state}  PDU Check Port State By Serial Number  ${FAN_NAME}
    IF  '${REVERSE_CONTROL_PDU_SWITCH}' == 'False'
        Logging With Timestamp
        ...  message=Verifying current FAN state on PDU
        IF  '${pdu_state}' == 'on'
            Logging With Timestamp
            ...  message=FAN is already ON
        ELSE
            Logging With Timestamp
            ...  message=FAN is OFF - initiating power ON
            PDU Power ON Port By Serial Number  ${FAN_NAME}
            Sleep  30 sec
        END
    ELSE
        Logging With Timestamp
        ...  message=Verifying current FAN state on PDU with reverse control
        IF  '${pdu_state}' == 'off'
            Logging With Timestamp
            ...  message=FAN is already ON
        ELSE
            Logging With Timestamp
            ...  message=FAN is OFF - initiating power ON
            PDU Power Off Port By Serial Number  ${FAN_NAME}
            Sleep  30 sec
        END
    END

    Logging With Timestamp
    ...  message=Soft resetting RU to clear fault_history_log.txt
    ...  style=ONGOING
    admin.Reset Unit  ${RMOD_DISTNAME_ID}  timeout=320  connection=${bts_id}

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    ...  bts_id=${bts_id}
    IF  '${onair_status}'=='True'
        Logging With Timestamp
        ...  message=All cells are onAir
    ELSE
        Logging With Timestamp
        ...  message=Cells are NOT onAir after resetting RU!
        Fail  Cells are NOT onAir after resetting RU!
    END

Step2: Generate Fault 1932
    [Arguments]  ${bts_id}  ${early_notif}
    Logging With Timestamp
    ...  message=Generate Fault 1932
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
        ...  Perform actRadioFanFailureEarlyNotif Recommissioning FID1932  bts_id=${bts_id}  value=${early_notif_str}
        IF  not ${reconf_status}
            Fail  Recommissioning failed for actRadioFanFailureEarlyNotif.
        END
    ELSE
        Logging With Timestamp
        ...  message=Value of actRadioFanFailureEarlyNotif is correct -> ${original_value}.
    END

    Logging With Timestamp
    ...  message=Waiting for generate fault
    ...  style=ONGOING
    radio.Generate Fault  fault_id=1932  ru_serial_number=${RMOD_SN}  reboot_timeout=320

    ${ru_bts_ids}=  Create List
    ...  ${CFG['RF_INFO']['${RMOD_SN}']['scf_btsid_primary']}
    ...  @{CFG['RF_INFO']['${RMOD_SN}']['scf_btsid_secondary']}
    ${secondary_bts_ids}=  Create List  @{CFG['RF_INFO']['${RMOD_SN}']['scf_btsid_secondary']}
    ${rfsharing_enabled}=  Evaluate  ${CFG['RF_INFO']['${RMOD_SN}']['scf_rfsharing']} == True
    FOR  ${ru_bts_id}  IN  @{ru_bts_ids}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=10  severity=Critical  serialNo=${RMOD_SN}  connection=${ru_bts_id}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1933  connection=${ru_bts_id}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1937  connection=${ru_bts_id}
        Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=1934  connection=${ru_bts_id}
        IF  ${rfsharing_enabled}
            FOR  ${secondary_bts_id}  IN  @{secondary_bts_ids}
                Run Keyword And Ignore Error  admin.Add Allowed Alarm  faultId=4773  serialNo=${RMOD_SN}  connection=${ru_bts_id}
            END
        END
    END

    Logging With Timestamp
    ...  message=Checking the status of FaultID 1932 on ${RMOD_SN}
    ...  style=ONGOING
    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive
    ...    faultId=1932  timeout=300  connection=${bts_id}
    IF  '${alarm_status}'=='True'
        Logging With Timestamp
        ...  message=FaultID 1932 was not raised as expected
    ELSE
        Logging With Timestamp
        ...  message=Fail, FaultID 1932 is visible in the list  of inactive faults. Check logs!
        ...  style=ERROR
        radio.Recover Fault  fault_id=1932  ru_serial_number=${RMOD_SN}
        Fail  Fail, FaultID 1932 is visible in the list  of inactive faults. Check logs!
    END

    Turn off selected FAN

    Logging With Timestamp
    ...  message=Checking if EFaultId_FrFanBrokenEarlyNotifAl (1408) is active in fault_history_log.txt file
    ${1408_active}  Run Keyword And Return Status  radio.Assert Active Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1408
    ...  severity=critical
    IF  '${1408_active}'=='True'
        Logging With Timestamp
        ...  message=EFaultId_FrFanBrokenEarlyNotifAl (1408) is active in fault_history_log.txt file
    ELSE
        Logging With Timestamp
        ...  message=EFaultId_FrFanBrokenEarlyNotifAl (1408) is not visible in fault_history_log.txt file!
        ...  style=ERROR
        Turn on selected FAN
        radio.Recover Fault  fault_id=1932  ru_serial_number=${RMOD_SN}
        Fail  Fault EFaultId_FrFanBrokenEarlyNotifAl (1408) not found, please check fault_history_log.txt file!
    END

    Turn on selected FAN

    Logging With Timestamp
    ...  message=Checking if EFaultId_FrFanBrokenEarlyNotifAl is inactive in fault_history_log.txt file
    ${1408_inactive}  Run Keyword And Return Status  radio.Assert Inactive Fault In Fault History Log File
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=1408
    ...  severity=critical
    IF  '${1408_inactive}'=='True'
        Logging With Timestamp
        ...  message=EFaultId_FrFanBrokenEarlyNotifAl (1408) is inactive in fault_history_log.txt file
    ELSE
        Logging With Timestamp
        ...  message=EFaultId_FrFanBrokenEarlyNotifAl (1408) is not inactive in fault_history_log.txt file!
        ...  style=ERROR
        radio.Recover Fault  fault_id=1932  ru_serial_number=${RMOD_SN}
        Fail  Fault EFaultId_FrFanBrokenEarlyNotifAl (1408) is not inactive, please check fault_history_log.txt file
    END

Step3: Recover Fault 1932
    [Arguments]  ${bts_id}
    Logging With Timestamp
    ...  message=Recover Fault 1932 on ${RMOD_SN}
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp
    ...  message=Waiting for recover of Fault on ${RMOD_SN}
    ...  style=ONGOING
    radio.Recover Fault  fault_id=1932  ru_serial_number=${RMOD_SN}

    ${alarm_status}  Run Keyword And Return Status  admin.Assert Alarm Inactive
    ...    faultId=1932  timeout=300  connection=${bts_id}
    IF  '${alarm_status}'=='True'
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
        ...  message=RMOD ${RMOD_SN} has correct state
    END

    ${onair_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    ...  bts_id=${bts_id}
    IF  '${onair_status}'=='True'
        Logging With Timestamp
        ...  message=All cells are onAir
    ELSE
        Logging With Timestamp
        ...  message=Cells are NOT onAir!
        ...  style=ERROR
        Fail  Cells are NOT onAir!
    END

    IF  '${original_value}' != '${expected_value}'
        Logging With Timestamp
        ...  message=Restoring original value of actRadioFanFailureEarlyNotif: ${original_value}.
        ...  style=SUCCESS
        ${reconf_status}    Run Keyword And Return Status
        ...  Perform actRadioFanFailureEarlyNotif Recommissioning FID1932  bts_id=${bts_id}  value=${original_value}
        IF  not ${reconf_status}
            Fail  Failed to restore original value of actRadioFanFailureEarlyNotif.
        END
    END

Turn off selected FAN
    Logging With Timestamp
    ...  message=Turn off selected FAN
    IF  '${REVERSE_CONTROL_PDU_SWITCH}' == 'False'
        PDU Power Off Port By Serial Number  ${FAN_NAME}
        Sleep  120 sec
    ELSE
        PDU Power ON Port By Serial Number  ${FAN_NAME}
        Sleep  120 sec
    END

Turn on selected FAN
    Logging With Timestamp
    ...  message=Turn on selected FAN
    IF  '${REVERSE_CONTROL_PDU_SWITCH}' == 'False'
        PDU Power ON Port By Serial Number  ${FAN_NAME}
        Sleep  120 sec
    ELSE
        PDU Power Off Port By Serial Number  ${FAN_NAME}
        Sleep  120 sec
    END

Perform actRadioFanFailureEarlyNotif Recommissioning FID1932
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