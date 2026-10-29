*** Settings ***
Documentation
    ...  This test case was created to imitate WCDMA DSP crash RAT recovery reset scenario. Rioboot command will be used
    ...  with write option. Before crash file data.dat with value "OxFFFF" is created in /tmp. To perform DSP crash value 0x128FFFFF
    ...  needs to be put into created file inline with nodeID in hex format. Example rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x1335.
    ...  Fault 6707/6708/6709 appearance and WCDMA cells reset are being checked in two seperate threads.
    ...  In meantime also Recovery Reset Indication appearance
    ...  is checked under FRI. At the end the correctness of recovery action is being check (fault presence, fault history and cells status).

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  660  # Timeout for alarm reporting in WebEM
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact


*** Keywords ***
TC__FM__WCDMA_DSP_crash_RAT_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8791
    ...
    ...  ******************
    ...  History of changes
    ...  - 13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  - 15.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  - 19.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29381 - Changes to send crash on Flexi DSP
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step1: Check All Required States
    Step2: Trigged WCDMA DSP Crash
    Step3: Verify Success Of Recovery Action


Step1: Check All Required States
    [Documentation]  In this step user input and specific states of links will be checked.

    Log  \nStep1: Perform site reset and check all required states.  console=true
    Check Commissioned Technologies  WCDMA
    Perform Site Reset
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_before_IM_restart.ims2
    Save The Log And Restart Infomodel  ${ims_path}
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${act_force_auto_reset_ini}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${ACT_FORCE_AUTO_RESET_INI}
    Log  Value of actForceAutoReset is ${ACT_FORCE_AUTO_RESET_INI}.  console=true
    ${status_act}  Run Keyword And Return Status  Should Contain  ${ACT_FORCE_AUTO_RESET_INI}  true
    IF  ${status_act}==${FALSE}  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${act_force_auto_reset_changed}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    IF  ${status_act}==${FALSE}  Log  Value of actForceAutoReset after change is ${act_force_auto_reset_changed}.  console=true
    Set Test Variable  ${STATUS_ACT}
    Check Links Status  Available
    Checking RNCid And WBTSid From IM
    ${wcdma_cells_state}  Create List
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    IF  ${wcdma_cells_status}
      Log  All of WCells are in WORKING state om RNC, test will continue. [OK]  console=true
    ELSE
      Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed.
    END
    Choose DSP For Crash  WCDMA
    Set Fault Signature Variables For WCDMA DSP Crash
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded


Step2: Trigged WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep2: Trigger WCDMA DSP crash.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=cellsCheck
    ${cells_status}  Run Keyword In Background  Assert Every  WNCEL  parameters=operationalState=${DISABLED}  timeout=660  alias=cellsCheck
    Verify SMOD Type And Trigger DSP Crash
    ${fault_rat_auto_rst}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_rat_auto_rst}  fault_id=regex"6707|6708|6709"
    ${fault_rat_auto_rst_params}  Get String With Alarm Parameters  ${fault_rat_auto_rst}
    Assert Alarm Active  parameters=${fault_rat_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 6707/6708/6709 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" occured.  console=true
    ${recovery_reset}  Run Keyword And Return Status  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=360
    ${status_cells}  Run Keyword And Return Status  Collect Keyword Result  ${cells_status}  timeout=660
    Run Keyword And Continue On Failure  Teardown Admin  alias=cellsCheck
    IF  ${status_cells}
      Log  WCDMA cells were failed while fault 6707/6708/6790 occured. [OK]  console=true
    ELSE
      Set Test Restriction  WCDMA cells were not failed while fault 6707/6708/6790 occured. [NOK]
    END
    IF  ${recovery_reset}
      Log  Recovery Reset Indication was visible under FRI. [OK]  console=true
    ELSE
      Set Test Restriction  Recovery Reset Indication was not visible under FRI. [NOK]
    END


Step3: Verify Success Of Recovery Action
    [Documentation]  In this step user WCDMA DSP crash will be performed.

    Log  \nStep3: Verify success of recovery action after WCDMA DSP crash.  console=true
    ${fault_rat_auto_rst}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_rat_auto_rst}  fault_id=regex"6707|6708|6709"
    ${fault_rat_auto_rst_params}  Get String With Alarm Parameters  ${fault_rat_auto_rst}
    Assert Alarm Inactive  parameters=${fault_rat_auto_rst_params}
    Log  Fault "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is not visible after recovery action.  console=true
    Log  Checking Historical Alarms for presence of 7101 Autonomous Rat Reset notification.  console=true
    ${historical_alarms}  Get_historic_alarms  severity=warning
    FOR  ${element}  IN  @{historical_alarms}
        ${status7101}  Run Keyword And Return Status  Should Be Equal As Integers  ${element}[alarmId]  7101
        IF  ${status7101}  BREAK
    END
    Should Be True  ${status7101}  Alarm 7101 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is not visible in historical alarms.
    Log  Alarm 7101 "${FAULT_6707_RAT_AUTO_RST}[fault_name]" is visible in historical alarms.  console=true
    ${all_cells_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  360  10  Check All Cells
    IF  ${all_cells_status}
      Log  All cells are on air after recovery - recovery succedeed. [OK]  console=true
    ELSE
      Set Test Failed  message=Some cells statuses are not as expected after recovery - recovery filed. [NOK]
    END
    Save Infomodel Log For TC Checks
    IF  ${SCF_COUNT_LTE}  Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${IM_LOG_PATH}
    IF  ${SCF_COUNT_GSM}  Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${IM_LOG_PATH}
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded
    ${wcdma_cells_state}  Create List
    ${wcdma_cells_state}  Check If WCDMA Cells Are In Working State From RNC PoV  ${RNC_ID}  ${WBTS_ID}  ${RNC["OMS_IP"]}
    ${wcdma_cells_status}  Run Keyword And Return Status  List Should Not Contain Value  ${wcdma_cells_state}  ${False}
    IF  ${wcdma_cells_status}
      Log  All of WCells are in WORKING state om RNC, test will continue. [OK]  console=true
    ELSE
      Fail  msg=Some of WCells are not in WORKING state on RNC, test will be set to failed.
    END
    Check Links Status  Available
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    IF  ${STATUS_ACT}==${FALSE}  Change Parameter ActForce(Unit)AutoReset  ${ACT_FORCE_AUTO_RESET_INI}  actForceAutoReset
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_6707_RAT_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_6707_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_6707_RAT_AUTO_RST} found in Netact.  console=true
    Log  Verify fault signature of fault in WebEM.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Log  Verify fault signature of fault in Netact.  console=true
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Save Infomodel Log For TC Checks
    [Documentation]
    ...  The purpose of this KW is to collect .ims2 log file
    [Timeout]  5 min

    Log  Save Infomodel log for TC checks.  console=true
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_recovery_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_recovery_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}.  console=true


TC Setup
    Common Test Setup  tc_name=FM__WCDMA_DSP_crash_RAT_recovery_reset
    Setup NetAct


TC Teardown
    Run Keyword And Continue On Failure  Change Parameter ActForce(Unit)AutoReset To False
    Teardown NetAct
    Common Test Teardown