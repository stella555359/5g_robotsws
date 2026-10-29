*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Verify the behavior of the ASOG system when enableInternalIQRouting is changed dynamically at runtime.
  ...
  ...  *** Test Variable For L3 Call ***
  ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
  ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 07.01.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${SISO_L3_CALL}          False
${CELLS_YAML_PATH}

*** Keywords ***
TC__CM_Runtime_Change_Of_enableInternalIQRouting
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=CM_Runtime_Change_Of_enableInternalIQRouting.robot will be executed
    ...  style=ONGOING
    Precondition For Change Parameter enableInternalIQRouting
    Step 1 Change Parameter enableInternalIQRouting to FALSE
    Step 2 Checking Expected Results After Disabling enableInternalIQRouting
    Step 3 Change Parameter enableInternalIQRouting to TRUE
    Step 4 Checking Expected Results After Enabling enableInternalIQRouting
    [Teardown]  Run Keywords  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keyword And Ignore Error
    ...  Recovery Runtime Change Of enableInternalIOQRouting  AND
    ...  Common Test Teardown

Precondition For Change Parameter enableInternalIQRouting
    Logging With Timestamp
    ...  message=Precondition For Change Parameter enableInternalIQRouting
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    Check If enableInternalIQRouting Is Activated  ${BTS_ID}
    ${used_fsm_port_with_cells}  BTS_INFO Create ASOG RF Ports With Cell List
    ${port12RATMode_value}  BTS_INFO Provide ASOG Port 12 Value  ${BTS_ID}
    Set Test Variable  ${port12RATMode_VALUE}  ${port12RATMode_value}
    Create Affected And Not Affected Cells List  ${used_fsm_port_with_cells}

Step 1 Change Parameter enableInternalIQRouting to FALSE
    Logging With Timestamp
    ...  message=Step 1 Change Parameter enableInternalIQRouting to FALSE
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Updating enableInternalIQRouting parameter to false ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  parameter=enableInternalIQRouting
    ...  operation=update
    ...  value=false
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Logging With Timestamp  message=Updating enableInternalIQRouting parameter to false ...
    ...  style=DONE

Step 2 Checking Expected Results After Disabling enableInternalIQRouting
    Logging With Timestamp
    ...  message=Step 2 Checking Expected States And Alarms After Disabling enableInternalIQRouting
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword And Continue On Failure  Assert Alarm Active  faultId=1868  timeout=600  connection=${BTS_ID}
    FOR  ${cell_id}  IN  @{AFFECTED_CELLS}
      FM Await For Fault
      ...  fault_attr=faultId=1868, severity=Critical, alarmingObjectIds[0].internal=${cell_id}
      ...  timeout=60
      ...  alarm_resource=${FAULT_1868}
      ...  node_id=${BTS_ID}
      ${class}=  Get Regexp Matches  ${cell_id}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      STATE Verify States For One
      ...  class=${class[0]}
      ...  object=${cell_id}
      ...  node_id=${BTS_ID}
      ...  states=availabilityStatus=regex"(?i)Failed",operationalState=regex"(?i)Disabled"
      ...  onair=${FALSE}
    END

Step 3 Change Parameter enableInternalIQRouting to TRUE
    Logging With Timestamp
    ...  message=Step 3 Change Parameter enableInternalIQRouting to TRUE
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Updating enableInternalIQRouting parameter to true ...
    ...  style=ONGOING
    admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  parameter=enableInternalIQRouting
    ...  operation=update
    ...  value=true
    ...  skip_parameter_relation_errors=False
    ...  connection=${BTS_ID}
    Logging With Timestamp  message=Updating enableInternalIQRouting parameter to true ...
    ...  style=DONE

Step 4 Checking Expected Results After Enabling enableInternalIQRouting
    Logging With Timestamp
    ...  message=Step 4 Checking Expected Results After Enabling enableInternalIQRouting
    ...  style=STEP
    ...  frame=${TRUE}
    Wait Until Keyword Succeeds  4x  60  STATE Verify BTS states  ${BTS_ID}
    FOR  ${cell_id}  IN  @{AFFECTED_CELLS}
      FM Await For Fault Cleared
      ...  fault_attr=faultId=1868, severity=Critical, alarmingObjectIds[0].internal=${cell_id}
      ...  node_id=${BTS_ID}
    END
    admin.Collect Infomodel Log From Current Session
      ...  target_file_name=${CFG.test_logs_path}/BTSFiles/${bts_id}/ims_${bts_id}_InternalIQRouting.ims2
      ...  connection=${bts_id}
    Logging With Timestamp  message=Check If Not Affected cells State Remained Unchanged In History
    STATE Check If State Remained Unchanged In History
      ...  ims2_log_path=${CFG.test_logs_path}/BTSFiles/${bts_id}/ims_${bts_id}_InternalIQRouting.ims2
      ...  runtime_dn_list=${NOT_AFFECTED_CELLS}
      ...  exp_state_name=availabilityStatus
    Run Keyword If  ${SISO_L3_CALL}  Run Keywords
    ...  Logging With Timestamp
    ...  message=L3 call for affected cells will be executed.  AND
    ...  SiSo L3 Call  cells_input=${AFFECTED_CELLS}
    ...  ELSE
    ...  Logging With Timestamp  message=L3 call skipped.

Create Affected And Not Affected Cells List
    [Arguments]  ${used_fsm_port_with_cells}
    ${rf_ports_new}  Get Dictionary Keys  ${used_fsm_port_with_cells}
    @{affected_cells}  Create List
    @{not_affected_cells}  Create List
    FOR  ${port}  IN  @{rf_ports_new}
      ${port_number}  Remove String  ${port}  RF
      ${cell_list}  Get From Dictionary  ${used_fsm_port_with_cells}  ${port}
      ${technology_port}  Set Variable  ${EMPTY}
      ${technology_port}  Run Keyword If  1 <= ${port_number} <= 9  Set Variable  4G5G
      ...  ELSE IF  13 <= ${port_number} <= 15  Set Variable  2G3G
      ...  ELSE  Set Variable  ${port12RATMode_VALUE}
      FOR  ${cell}  IN  @{cell_list}
        ${nrltecell}  Run Keyword And Return Status  Should Match Regexp  ${cell}  (?i)LNCEL|NRCEL
        ${wgcell}  Run Keyword And Return Status  Should Match Regexp  ${cell}  (?i)WNCEL|GNCEL
        Run Keyword If  "${technology_port}"=="2G3G" and ${wgcell} or "${technology_port}"=="4G5G" and ${nrltecell}
        ...  Append To List  ${not_affected_cells}  ${cell}
        Run Keyword If  "${technology_port}"=="4G5G" and ${wgcell} or "${technology_port}"=="2G3G" and ${nrltecell}
        ...  Append To List  ${affected_cells}  ${cell}
      END
    END
    Set Test Variable  ${AFFECTED_CELLS}  ${affected_cells}
    Set Test Variable  ${NOT_AFFECTED_CELLS}  ${not_affected_cells}

Check If enableInternalIQRouting Is Activated
    [Arguments]  ${connection}=${BTS_ID}
    ${smod_parameter}  admin.Get Parameter By Distname  MRBTS-${connection}/EQM-1/APEQM-1/CABINET-1/SMOD-1  connection=${connection}
    ${enableInternalIQRouting_value}  Get From Dictionary  ${smod_parameter[0]['parameters']}  enableInternalIQRouting
    Run Keyword If  ${enableInternalIQRouting_value}  Logging With Timestamp  message=Parameter enableInternalIQRouting Activated.
    ...  ELSE  Logging With Timestamp  message=Parameter enableInternalIQRouting NOT Activated!!! Please change to True to perform test.
    ...  style=FAIL
    [Return]  ${enableInternalIQRouting_value}

Recovery Runtime Change Of enableInternalIOQRouting
    ${smod_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1  connection=${BTS_ID}
    ${enableInternalIQRouting_value}  Get From Dictionary  ${smod_parameter[0]['parameters']}  enableInternalIQRouting
    Run Keyword If  ${enableInternalIQRouting_value}  Logging With Timestamp  message=Parameter enableInternalIQRouting Activated.
    ...  ELSE  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1
    ...  parameter=enableInternalIQRouting
    ...  operation=update
    ...  value=true
    ...  skip_parameter_relation_errors=True
    ...  connection=${BTS_ID}
