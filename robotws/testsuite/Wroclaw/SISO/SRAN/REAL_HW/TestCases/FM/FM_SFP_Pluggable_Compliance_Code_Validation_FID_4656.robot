*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The transceiver validation part of the CB013212-F feature on the O-RU by verifying that the compliance code mechanism works as expected.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Library   ./../../Resources/Python/zip_helpers.py

*** Variables ***
${RMOD_SN}                    # Serial number of the radio


*** Keywords ***
TC__FM_SFP_Pluggable_Compliance_Code_Validation_FID_4656
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=FM_SFP_Pluggable_Compliance_Code_Validation_FID_4656 will be executed
    ...  style=ONGOING
    Step 1: Preparing Variables For Pluggable Compliance Code Validation FID 4656
    Step 2: Generate Fault 4656
    Step 3: Check Expected Result Fault 4656 active
    Step 4: Change sfpOperatorMode parameter to True
    Step 5: Recover sfpOperatorMode parameter to False
    Step 6: Recover Fault 4656
    Step 7: Check Expected Result Fault 4656 cleared
    [Teardown]  Common Test Teardown

Step 1: Preparing Variables For Pluggable Compliance Code Validation FID 4656
    [Documentation]
    ...  Description:
    ...  Preparing Variables to perform test.

    Logging With Timestamp
    ...  message=Step 1: Preparing Variables For Pluggable Compliance Code Validation FID 4656
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    ${remote_vm}  Set Variable If  "${CFG['NODES']['${BTS_ID}']['bts_alias_type']}"=="remote"
    ...  ${CFG['NODES']['${BTS_ID}']['vm_ip_LMP_address']}  None
    Set Test Variable  ${REMOTE_VM}  ${remote_vm}
    Check If Tested RMOD is ORAN And Has Supported SFP
    ${apeqm_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/EQM-1/APEQM-1  connection=${BTS_ID}
    ${sfpOperatorMode_value}  Get From Dictionary  ${apeqm_parameter[0]['parameters']}  sfpOperatorMode
    IF  "${sfpOperatorMode_value}"=="True"
      Change sfpOperatorMode Parameter Value  false
    ELSE IF  "${sfpOperatorMode_value}"=="False"
      Logging With Timestamp  message=Parameter sfpOperatorMode has expected value -> False
    END

Step 2: Generate Fault 4656
    [Documentation]
    ...  Description:
    ...  Genearating fault using FRMON by changing value basic_compliance_codes and extended_compliance_codes to 0 in file
    ...  localsfp_inst[0|1].bin for AWHQN and port_sfp[0|1].bin for RF8

    Logging With Timestamp
    ...  message=Step 2: Generate Fault 4656
    ...  style=STEP
    ...  frame=${TRUE}
    ${bts_timestamp_start}  SSH Get BTS timestamp  ${bts_id}
    Set Test Variable  ${BTS_TIMESTAMP_START}  ${bts_timestamp_start}
    Logging With Timestamp
    ...  message=Triggering FID4656 started...
    radio.Generate Fault
    ...  fault_id=4656
    ...  ru_serial_number=${RMOD_SN}
    ...  sfp_id=${TESTED_SFP_PORT_NUMBER}
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Triggering FID4656 finished...

Step 3: Check Expected Result Fault 4656 active
    [Documentation]
    ...  Description:
    ...  Checking if expexted faults appear and cell have expexted states

    Logging With Timestamp
    ...  message=Step 3: Check Expected Result Fault 4656 active
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Step 3: Check Expected Result Fault 4656 active
    ${fault_4656_status}  Run Keyword And Return Status  FM Await For Fault
    ...  fault_attr=faultId=4656, severity=regex"Major", alarmingObjectIds[0].internal=${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['sfp_DN']}
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_4656}
    ...  timeout=300
    IF  ${fault_4656_status} == ${TRUE}
      Logging With Timestamp
      ...  message=Fault 4656 active in WebEM!!!
      ...  style=PASS
    ELSE IF  ${fault_4656_status} == ${FALSE}
      Logging With Timestamp
      ...  message=Fault 4656 NOT active !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Fault 4656 NOT active !!!
    END
    Run Keyword And Continue On Failure  Assert
    ...  class_name=SFP
    ...  id=${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['sfp_DN']}
    ...  parameters=availabilityStatus=regex"(?i)Degraded"
    ...  timeout=60
    ...  connection=${BTS_ID}
    Checking Expected States After Fault 4656 Active
    ${fault_list}  Create List
    ...  faultId=10, severity=Critical, serialNo=${RMOD_SN}, ${BTS_ID}
    ...  faultId=4590, severity=Warning, serialNo=${RMOD_SN}, ${BTS_ID}
    Set Test Variable  ${FAULT_LIST}  ${fault_list}
    FM Find History Fault And Add To Allowed
    ...  history_fault_list=${FAULT_LIST}
    ...  timeslot_start=${BTS_TIMESTAMP_START}
    ...  bts_id=${BTS_ID}

Step 4: Change sfpOperatorMode parameter to True
    [Documentation]
    ...  Description:
    ...  Checking if expexted faults disappear after change sfpOperatorMode parameter to True

    Logging With Timestamp
    ...  message=Step 4: Change sfpOperatorMode parameter to True
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword And Continue On Failure  Change sfpOperatorMode Parameter Value  true
    Run Keyword And Continue On Failure  FM Await For Fault Cleared
    ...  fault_attr=faultId=4656
    ...  timeout=120
    ...  node_id=${BTS_ID}
    Run Keyword And Continue On Failure  STATE Verify BTS states  node_id=${BTS_ID}

Step 5: Recover sfpOperatorMode parameter to False
    [Documentation]
    ...  Description:
    ...  Checking if expexted faults appear after change sfpOperatorMode parameter to True

    Logging With Timestamp
    ...  message=Step 5: Recover sfpOperatorMode parameter to False
    ...  style=STEP
    ...  frame=${TRUE}
    Change sfpOperatorMode Parameter Value  false
    ${fault_4656_status}  Run Keyword And Return Status  FM Await For Fault
    ...  fault_attr=faultId=4656, severity=regex"Major", alarmingObjectIds[0].internal=${TESTED_SFPS_RMOD['${TESTED_SFP_KEY}']['sfp_DN']}
    ...  node_id=${BTS_ID}
    ...  alarm_resource=${FAULT_4656}
    ...  timeout=300
    IF  ${fault_4656_status} == ${TRUE}
      Logging With Timestamp
      ...  message=Fault 4656 active in WebEM!!!
      ...  style=PASS
    ELSE IF  ${fault_4656_status} == ${FALSE}
      Logging With Timestamp
      ...  message=Fault 4656 NOT active !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Fault 4656 NOT active !!!
    END
    Checking Expected States After Fault 4656 Active

Step 6: Recover Fault 4656
    [Documentation]
    ...  Description:
    ...  Recovering by removing RMOD runtime configs sudo rm -r /mnt/runtime/configs/*

    Logging With Timestamp
    ...  message=Step 6: Recover Fault 4656
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Recovering FID4656...
    ${bts_timestamp_start2}  SSH Get BTS timestamp  ${bts_id}
    Set Test Variable  ${BTS_TIMESTAMP_START2}  ${bts_timestamp_start2}
    radio.Recover Fault
    ...  ru_serial_number=${RMOD_SN}
    ...  fault_id=4656
    ...  remote_host=${REMOTE_VM}
    Logging With Timestamp
    ...  message=Waiting for recover radio...

Step 7: Check Expected Result Fault 4656 cleared
    [Documentation]
    ...  Description:
    ...  Checking states after recover.

    Logging With Timestamp
    ...  message=Step 7: Check Expected Result Fault 4656 cleared
    ...  style=STEP
    ...  frame=${TRUE}
    FM Await For Fault Cleared
    ...  fault_attr=faultId=4656
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


Check If Tested RMOD is ORAN And Has Supported SFP
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
    ${tested_sfp_port}  Get Dictionary Keys  ${TESTED_SFPS_RMOD}
    ${sfp_port_number}  Remove String  ${tested_sfp_port[0]}  OPT_IF
    ${sfp_port_number}  Evaluate  ${sfp_port_number} - 1
    Set Test Variable  ${TESTED_SFP_PORT_NUMBER}  ${sfp_port_number}
    Set Test Variable  ${TESTED_SFP_KEY}  ${tested_sfp_port[0]}

Checking Expected States After Fault 4656 Active
    [Documentation]
    ...  Description:
    ...  Checking cell states when fault is active
    ...
    ...  Author: przemyslaw.kempa@nokia.com
    ...  Maintainer: przemyslaw.kempa@nokia.com
    Logging With Timestamp
      ...  message=Checking Expected States After Fault 4656 Active
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
    Sleep  1min  Wait for reset RMOD
    Wait Until Keyword Succeeds  10min  60  Check Affected Cells State After Fault 4656 Active


Check Affected Cells State After Fault 4656 Active
    FOR  ${cell}  IN  @{AFFECTED_CELLS_LIST}
      ${class}  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${cell_status}  Run Keyword And Return Status  admin.Assert
      ...  class_name=${class[0]}
      ...  id=${cell}
      ...  parameters=availabilityStatus=regex"(?i)Degraded"
      ...  timeout=5
      ...  connection=${BTS_ID}
      IF  not ${cell_status}  Run Keyword And Continue On Failure  Fail  ${cell} is onAir but should degraded !!!
    END

Change sfpOperatorMode Parameter Value
    [Arguments]  ${parameter_value}
    Logging With Timestamp
    ...  message=Change sfpOperatorMode Parameter Value to ${parameter_value}
    ...  style=ONGOING
    ${recommissionig_status}  Run Keyword And Return Status  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1
    ...  parameter=sfpOperatorMode
    ...  operation=update
    ...  value=${parameter_value}
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    IF  ${recommissionig_status}
      Logging With Timestamp
      ...  message=Change sfpOperatorMode Parameter Value to ${parameter_value} finished succesfully !
      ...  style=DONE
    ELSE
      Logging With Timestamp
      ...  message=Change sfpOperatorMode Parameter Value to ${parameter_value} finished ERROR !!!
      ...  style=ERROR
      Run Keyword And Continue On Failure  Fail  Change sfpOperatorMode Parameter Value to ${parameter_value} finished ERROR !!!
    END