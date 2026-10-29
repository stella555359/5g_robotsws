*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  Purpose of this test case is to verify recorver from L1SoC reset triggered on ASOG.
  ...
  ...  *** Test Variable For L3 Call ***
  ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
  ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 27.01.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${prompt}  ':~#|>|$|@'
${L1soc_unit_crash_command_singlecore}    pkill  -6  l1_application_
${SISO_L3_CALL}          False
${CELLS_YAML_PATH}

*** Keywords ***
TC__REC_L1SoC_Reset
    Set Tags  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
    Common Test Setup  tools_to_setup=syslog_ADMIN
    Logging With Timestamp
    ...  message=REC_L1SoC_Reset.robot will be executed
    ...  style=ONGOING
    Precondition For L1SoC reset
    Step 1 Trigger L1SoC Reset
    Step 2 Checking Expected Results After L1SoC Reset
    [Teardown]  Run Keywords  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Recovery After L1SoC reset  AND
    ...  Common Test Teardown

Precondition For L1SoC reset
    Logging With Timestamp
    ...  message=Precondition For L1SoC reset
    ...  style=STEP
    ...  frame=${TRUE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    ${smod_parameter}  admin.Get Parameter By Distname  MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1  connection=${BTS_ID}
    ${enableInternalIQRouting_value}  Get From Dictionary  ${smod_parameter[0]['parameters']}  enableInternalIQRouting
    Run Keyword If  ${enableInternalIQRouting_value}  Logging With Timestamp  message=Parameter enableInternalIQRouting Activated.
    ...  ELSE  Logging With Timestamp  message=Parameter enableInternalIQRouting NOT Activated!!! Please change to True to perform test.
    ...  style=FAIL
    ${used_fsm_port_with_cells}  BTS_INFO Create ASOG RF Ports With Cell List
    ${port12RATMode_value}  BTS_INFO Provide ASOG Port 12 Value  ${BTS_ID}
    Set Test Variable  ${port12RATMode_VALUE}  ${port12RATMode_value}
    Create Affected And Not Affected Cells List For L1SoC Reset  ${used_fsm_port_with_cells}

Step 1 Trigger L1SoC Reset
    Logging With Timestamp
    ...  message=Step 1 Trigger L1SoC Reset
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp  message=Capacity Unit crash is being made, please wait to recovery.
    ...  style=ONGOING
    ${serial_number}  Get From Dictionary  ${cfg['NODES']['${BTS_ID}']}  primary_sm
    SSH Send Command On Specific BBMOD
    ...  bts_id=${BTS_ID}
    ...  command=${L1soc_unit_crash_command_singlecore}
    ...  bbmod_serial_number=${serial_number}
    ...  platform_type=singlecore
    Logging With Timestamp  message=Capacity Unit crash is being made, please wait to recovery.
    ...  style=DONE

Step 2 Checking Expected Results After L1SoC Reset
    Logging With Timestamp
    ...  message=Step 2 Checking Expected Results After L1SoC Reset
    ...  style=STEP
    ...  frame=${TRUE}
    FM Await For Fault
    ...  fault_attr=faultId=2087, severity=Warning
    ...  timeout=60
    ...  alarm_resource=${FAULT_2087}
    ...  node_id=${BTS_ID}
    FM Await For Fault Cleared
    ...  fault_attr=faultId=2087, severity=Warning
    ...  timeout=120
    ...  node_id=${BTS_ID}
    Run keyword And Continue On Failure  Wait Until Keyword Succeeds  8min  1min  STATE Verify BTS states  ${BTS_ID}
    admin.Collect Infomodel Log From Current Session
    ...  target_file_name=${CFG.test_logs_path}/BTSFiles/${BTS_ID}/ims_${BTS_ID}_L1SoC_reset.ims2
    ...  connection=${BTS_ID}
    Logging With Timestamp  message=Check If Not Affected cells State Remained Unchanged In History
    STATE Check If State Remained Unchanged In History
    ...  ims2_log_path=${CFG.test_logs_path}/BTSFiles/${BTS_ID}/ims_${BTS_ID}_L1SoC_reset.ims2
    ...  runtime_dn_list=${NOT_AFFECTED_CELLS}
    ...  exp_state_name=availabilityStatus
    STATE Check State And Value In History
    ...  ims2_log_path=${CFG.test_logs_path}/BTSFiles/${BTS_ID}/ims_${BTS_ID}_L1SoC_reset.ims2
    ...  runtime_dn_list=${AFFECTED_CELLS}
    ...  exp_state_name=availabilityStatus
    ...  exp_state_value=failed
    Run Keyword If  ${SISO_L3_CALL}  Run Keywords
    ...  Logging With Timestamp
    ...  message=L3 call for affected cells will be executed.  AND
    ...  SiSo L3 Call  cells_input=${AFFECTED_CELLS}
    ...  ELSE
    ...  Logging With Timestamp  message=L3 call skipped.

Create Affected And Not Affected Cells List For L1SoC Reset
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
        Run Keyword If  "${technology_port}"=="4G5G"  Append To List  ${affected_cells}  ${cell}
        Run Keyword If  "${technology_port}"=="2G3G" and ${nrltecell}  Append To List  ${affected_cells}  ${cell}
        Run Keyword If  "${technology_port}"=="2G3G" and ${wgcell}  Append To List  ${not_affected_cells}  ${cell}
      END
    END
    Set Test Variable  ${AFFECTED_CELLS}  ${affected_cells}
    Set Test Variable  ${NOT_AFFECTED_CELLS}  ${not_affected_cells}

Recovery After L1SoC reset
    Run Keyword And Ignore Error  admin.Reset Site  connection=${BTS_ID}
    Run Keyword And Ignore Error  Wait Until Keyword Succeeds  8min  1min  STATE Verify BTS states  ${BTS_ID}

