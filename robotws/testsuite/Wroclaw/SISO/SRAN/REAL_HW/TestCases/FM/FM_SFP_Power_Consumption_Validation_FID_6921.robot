*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  This test case verifies the O-RU's ability to validate SFP power consumption levels and raise appropriate alarms for incompatible power level.
  ...  The test ensures compliance with power management requirements and alarm handling as specified in 5G_RAN_USR_COM_24227
  ...
  ...  SFP to be used: Use an SFP that explicitly declares Power Level 2 (PL2) in its EEPROM or vendor datasheet.
  ...  NOKIA LOGBOOK of released (Q)SFPs should be checked.
  ...  SFP with PL1 cannot be used to trigger the fault with FRMON.
  ...
  ...
  ...  How to Check SFP Power Level
  ...  The actual Power Level (PL) of an SFP is declared within its EEPROM or specified in its vendor datasheet.
  ...  - Vendor Datasheet: Consult the official datasheet provided by the SFP manufacturer for the specific part number.
  ...    This is the most reliable source for declared power levels.
  ...  - Reading SFP EEPROM: The SFP's Power Level declaration is typically found at byte64 (0x40) within the A0 page of the SFP's EEPROM.
  ...  Tools for Reading EEPROM:
  ...  i2cdump: On the radio unit, you can often use the i2cdump command (with sudo). For example:
  ...  - dump for SFP0
  ...  i2cdump -y -f 6 0x50
  ...  - dump for SFP1
  ...  i2cdump -y -f 7 0x50
  ...  This command reads the EEPROM content, and you would then need to interpret the byte at address 0x40 (byte 64).
  ...  Refer to the SFF-8472-R12.4.pdf specification for detailed interpretation of EEPROM bytes.
  ...
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 14.10.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library   ./../../Resources/Python/zip_helpers.py

*** Variables ***
${RMOD_SN}                    # Serial number of the radio


*** Keywords ***
TC__FM_SFP_Power_Consumption_Validation_FID_6921
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=FM_SFP_Power_Consumption_Validation_FID_6921 will be executed
    ...  style=ONGOING
    Step 1: Preparing Variables For SFP Power Consumption Validation FID 6921
    Step 2: Generate Fault 6921
    Step 3: Check Expected Result Fault 6921 active
    Step 4: Recover Fault 6921
    Step 5: Check Expected Result Fault 6921 cleared

    [Teardown]  Common Test Teardown

Step 1: Preparing Variables For SFP Power Consumption Validation FID 6921
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test.
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 1: Preparing Variables For SFP Power Consumption Validation FID 6921
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    ${remote_vm}  Set Variable If  "${CFG['NODES']['${BTS_ID}']['bts_alias_type']}"=="remote"
    ...  ${CFG['NODES']['${BTS_ID}']['vm_ip_LMP_address']}  None
    Set Test Variable  ${REMOTE_VM}  ${remote_vm}
    Check RMOD And SFP Are Valid

Step 2: Generate Fault 6921
    [Documentation]
    ...  Description:
    ...  Genearating fault using FRMON by changing value max_power_milliwatts to 500 in file localsfp_inst[0|1].bin
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 2: Generate Fault 6921
    ...  style=STEP
    ...  frame=${TRUE}
    ${bts_timestamp_start}  SSH Get BTS timestamp  ${bts_id}
    Set Test Variable  ${BTS_TIMESTAMP_START}  ${bts_timestamp_start}
    Logging With Timestamp
    ...  message=Triggering FID6921 started...
    radio.Generate Fault
    ...  fault_id=6921
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${TESTED_SFP_PORT_NUMBER}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID6921 finished...

Step 3: Check Expected Result Fault 6921 active
    [Documentation]
    ...  Description:
    ...  Checking if expexted faults appear and cell have expexted states
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 3: Check Expected Result Fault 6921 active
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Step 3: Check Expected Result Fault 6921 active
    ${fault_6921_status}  Run Keyword And Return Status  FM Await For Fault
    ...  fault_attr=faultId=6921, severity=regex"Minor|Critical", alarmingObjectIds[0].internal=${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['sfp_DN']}
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_6921}
    ...  timeout=300
    IF  ${fault_6921_status} == ${TRUE}
      Logging With Timestamp
      ...  message=Fault 6921 active in WebEM!!!
      ...  style=PASS
    ELSE IF  ${fault_6921_status} == ${FALSE}
      Logging With Timestamp
      ...  message=Fault 6921 NOT active !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Fault 6921 NOT active !!!
    END
    Run Keyword And Continue On Failure  Assert
    ...  class_name=SFP
    ...  id=${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['sfp_DN']}
    ...  parameters=operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)Failed"
    ...  timeout=30
    ...  connection=${BTS_ID}
    Checking Expected States After Fault 6921 Active
    ${fault_list}  Create List
    ...  faultId=10, severity=Critical, serialNo=${RMOD_SN}, ${BTS_ID}
    ...  faultId=4590, severity=Warning, serialNo=${RMOD_SN}, ${BTS_ID}
    Set Test Variable  ${FAULT_LIST}  ${fault_list}
    Run Keyword And Continue On Failure  FM Find History Fault And Add To Allowed
    ...  history_fault_list=${FAULT_LIST}
    ...  timeslot_start=${BTS_TIMESTAMP_START}
    ...  bts_id=${BTS_ID}

Step 4: Recover Fault 6921
    [Documentation]
    ...  Description:
    ...  Recovering by removing RMOD runtime configs sudo rm -r /mnt/runtime/configs/*
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 4: Recover Fault 6921
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID6921...
    ${bts_timestamp_start2}  SSH Get BTS timestamp  ${bts_id}
    Set Test Variable  ${BTS_TIMESTAMP_START2}  ${bts_timestamp_start2}
    radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=6921
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...

Step 5: Check Expected Result Fault 6921 cleared
    [Documentation]
    ...  Description:
    ...  Checking after states after recover, checking power level state
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com

    Logging With Timestamp
    ...  message=Step 5: Check Expected Result Fault 6921 cleared
    ...  style=STEP
    ...  frame=${TRUE}
    FM Await For Fault Cleared
    ...  fault_attr=faultId=6921
    ...  timeout=120
    ...  node_id=${BTS_ID}
    Wait Until Keyword Succeeds  5x  60  STATE Verify BTS states  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  Assert
    ...  class_name=SFP
    ...  id=${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['sfp_DN']}
    ...  parameters=operationalState=regex"(?i)Enabled"
    ...  timeout=30
    ...  connection=${BTS_ID}
    FM Find History Fault And Add To Allowed
    ...  history_fault_list=${FAULT_LIST}
    ...  timeslot_start=${BTS_TIMESTAMP_START2}
    ...  bts_id=${BTS_ID}
    @{additional_faults}  Create List
    FOR  ${cell_dn}  IN  @{AFFECTED_CELLS_LIST}
      Append To List  ${additional_faults}  faultId=4003, severity=Minor, impactedCellsList[0]=${cell_dn}, ${BTS_ID}
    END
    FM Find History Fault And Add To Allowed
    ...  history_fault_list=${additional_faults}
    ...  timeslot_start=${BTS_TIMESTAMP_START}
    ...  bts_id=${BTS_ID}

Check RMOD And SFP Are Valid
    [Documentation]
    ...  Description:
    ...  Chacking If RMOD has valid SFP
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com
    IF  '${RMOD_SN}'=='${EMPTY}'
      Logging With Timestamp
      ...  message=Variable RMOD_SN cannot be empty!
      ...  style=ERROR
      Fail  Variable RMOD_SN cannot be empty!
    ELSE IF  '${RMOD_SN}' in @{CFG['NODES']['${BTS_ID}']['scf_hw_fr_list']}
      IF  '${CFG['RF_INFO']['${RMOD_SN}']['scf_release_code']}'=='RRH-ORAN'
        Logging With Timestamp
        ...  message=RMOD -> ${RMOD_SN} is ORAN.
      ELSE
        Logging With Timestamp
        ...  message=RMOD -> ${RMOD_SN} is NOT ORAN!
        ...  style=ERROR
        Fail  RMOD -> ${RMOD_SN} is NOT ORAN!
      END
    ELSE
      Logging With Timestamp
      ...  message=RMOD -> ${RMOD_SN} is NOT on BTS. Please check correct SN !!!
      ...  style=ERROR
      Fail  RMOD -> ${RMOD_SN} is NOT on BTS. Please check correct SN !!!
    END
    ${tested_sfps_rmod}  BTS_INFO Check If RMOD Has Supported SFP vendorPartNumber And Return Details  sn_rmod=${RMOD_SN}  connection=${BTS_ID}
    Set Test Variable  ${TESTED_SFPS_RMOD}  ${tested_sfps_rmod}
    Create Directory  ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/Precondition
    SSH Get File From Radio Module
      ...  rmod_sn=${RMOD_SN}
      ...  file_path=/var/log/startup.log.gz
      ...  destination_directory=${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/Precondition
      ...  remote_host=${REMOTE_VM}
    ${tested_sfp_port}  Get Dictionary Keys  ${TESTED_SFPS_RMOD}
    FOR  ${sfp}  IN  @{tested_sfp_port}
      ${sfp_port_number}  Remove String  ${sfp}  OPT_IF
      ${sfp_port_number}  Evaluate  ${sfp_port_number} - 1
      ${power_level_status}  Run Keyword And Return Status
      ...  Check Power Level Version  ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/Precondition/startup.log.gz  ${sfp_port_number}
      IF  "${power_level_status}"=="${True}"
        Set Test Variable  ${TESTED_SFP_PORT_NUMBER}  ${sfp_port_number}
        Set Test Variable  ${TESTED_SFP_KEY}  ${sfp}
        Exit For Loop
      END
    END
    Variable Should Exist  ${TESTED_SFP_PORT_NUMBER}  message=NO proper SFP to perform test
    Check Power Level State  ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/Precondition/startup.log.gz  ${TESTED_SFP_PORT_NUMBER}

Checking Expected States After Fault 6921 Active
    [Documentation]
    ...  Description:
    ...  Checking cell states when fault is active
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com
    ${cablink_cell}  BTS_INFO Create Cablinks Dictionary With Affected Cells Lists
    ${affected_cells_list}  Get From Dictionary  ${cablink_cell}  ${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['cablink_DN']}
    Set Test Variable  ${AFFECTED_CELLS_LIST}  ${affected_cells_list}
    ${all_cells_list}  Create List
    FOR  ${cablink_dn}  ${cells_list}  IN  &{cablink_cell}
        Append To List  ${all_cells_list}  @{cells_list}
    END
    @{not_affected_cells_list}  Create List  @{all_cells_list}
    Remove Values From List  ${not_affected_cells_list}  @{affected_cells_list}
    Set Test Variable  ${NOT_AFFECTED_CELLS_LIST}  ${not_affected_cells_list}
    FOR  ${cell}  IN  @{not_affected_cells_list}
      ${class}  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${cell_status}  Run Keyword And Return Status  STATE Verify States For One
      ...  class=${class[0]}
      ...  object=${cell}
      ...  node_id=${BTS_ID}
      Run Keyword If  not ${cell_status}  Run Keyword And Continue On Failure  Fail  ${cell} is not onAir
    END
    FOR  ${cell}  IN  @{affected_cells_list}
      ${class}  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${cell_status}  Run Keyword And Return Status  admin.Assert
      ...  class_name=${class[0]}
      ...  id=${cell}
      ...  parameters=availabilityStatus=regex"(?i)Failed|(?i)Degraded"
      ...  connection=${BTS_ID}
      IF  not ${cell_status}  Run Keyword And Continue On Failure  Fail  ${cell} is onAir but should be failed or degraded !!!
    END

Check Power Level State
    [Arguments]  ${file_path}  ${sfp_port_number}
    ${find_lines}  Search Gz File For Regex
    ...  file_path=${file_path}
    ...  regex_pattern=port=${sfp_port_number}.*isSignalDetected=YES.*powerLevelCompatibility.*state=Ready
    ${line_number}  Get Length  ${find_lines}
    IF  ${line_number} == 0
      ${message}  Set Variable  Power Level Compatibility State NOT visible in RMOD ${RMOD_SN} startup logs.
      ...  Please check logs ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/startup.log.gz
      Logging With Timestamp
      ...  message=${message}
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  ${message}
    ELSE IF  ${line_number} > 1
      ${message}  Set Variable  Too many entries for Power Level Compatibility State in RMOD ${RMOD_SN} startup logs.
      ...  Please check logs ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/startup.log.gz
      Logging With Timestamp
      ...  message=${message}
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  ${message}
    ELSE IF  ${line_number} == 1
      ${matches}  Get Regexp Matches  ${find_lines[0]}  powerLevelCompatibility[^,]*
      ${powerLevelCompatibility}  Remove String  ${matches[0]}  powerLevelCompatibility=
      ${powerLevelCompatibility}  Strip String  ${powerLevelCompatibility}
      ${powerLevelCompatibility}  Convert To Upper Case  ${powerLevelCompatibility}
      IF  "${powerLevelCompatibility}" == "COMPATIBLE"
        Logging With Timestamp
        ...  message=power level state: COMPATIBLE - transceive'r power consumtpion in operation is compatible with radio module's capabilities
        ...  level=INFO
        ...  style=PASS
      ELSE IF  "${powerLevelCompatibility}" == "NOT_SUPPORTED"
        Logging With Timestamp
        ...  message=power level state: NOT_SUPPORTED: Module Agent doesn't support detection of power consumption for transceiver
        ...  message_2=or the transceiver not present
        ...  level=WARN
        ...  style=WARNING
      ELSE IF  "${powerLevelCompatibility}" == "INCOMPATIBLE"
        Logging With Timestamp
        ...  message=power level state: INCOMPATIBLE: transceiver's power consumption in operation is not compatible with radio module's capabilities
        ...  level=INFO
      END
    END

Check Power Level Version
    [Arguments]  ${file_path}  ${sfp_port_number}
    ${find_lines}  Search Gz File For Regex
    ...  file_path=${file_path}
    ...  regex_pattern=(?:port::${sfp_port_number} INF/coco/PortControl, |p${sfp_port_number}::)SFP::getRequiredSfpPowerLevelInMilliwatts:
    ${line_number}  Get Length  ${find_lines}
    IF  ${line_number} == 0
      ${message}  Set Variable  getRequiredSfpPowerLevelInMilliwatts NOT visible in RMOD ${RMOD_SN} startup logs.
      ...  Please check logs ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/startup.log.gz
      Logging With Timestamp
      ...  message=${message}
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  ${message}
    ELSE IF  ${line_number} > 1
      ${message}  Set Variable  Too many entries for getRequiredSfpPowerLevelInMilliwatts in RMOD ${RMOD_SN} startup logs.
      ...  Please check logs ${TEST_LOGS_PATH}BTSFiles/${BTS_ID}/${RMOD_SN}/startup.log.gz
      Logging With Timestamp
      ...  message=${message}
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  ${message}
    ELSE IF  ${line_number} == 1
      ${matches}  Get Regexp Matches  ${find_lines[0]}  getRequiredSfpPowerLevelInMilliwatts[^,]*
      ${powerLevel}  Remove String  ${matches[0]}  getRequiredSfpPowerLevelInMilliwatts:
      ${powerLevel}  Strip String  ${powerLevel}
      ${powerLevel}  Convert To Lower Case  ${powerLevel}
      IF  "${powerLevel}" == "power level 2 detected"
        Logging With Timestamp
        ...  message=Power level 2 detected for sfp port number ${sfp_port_number}
        ...  level=INFO
        ...  style=PASS
      ELSE IF  "${powerLevel}" == "power level 3 detected"
        Logging With Timestamp
        ...  message=Power level 3 detected for sfp port number ${sfp_port_number}
        ...  level=INFO
        ...  style=PASS
      ELSE IF  "${powerLevel}" == "power level 4 detected"
        Logging With Timestamp
        ...  message=Power level 4 detected for sfp port number ${sfp_port_number}
        ...  level=INFO
        ...  style=PASS
      ELSE IF  "${powerLevel}" == "power level 1 detected"
        Logging With Timestamp
        ...  message=Power level 1 detected for sfp port number ${sfp_port_number}, generating 6921 fault not supported
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Power level 1 detected for sfp port number ${sfp_port_number}, generating 6921 fault not supported
      ELSE
        Logging With Timestamp
        ...  message=Power level version not found in RMOD startup logs
        ...  style=ERROR
        Run Keyword And Continue On Failure  Fail  Power level version not found in RMOD startup logs
      END
    END