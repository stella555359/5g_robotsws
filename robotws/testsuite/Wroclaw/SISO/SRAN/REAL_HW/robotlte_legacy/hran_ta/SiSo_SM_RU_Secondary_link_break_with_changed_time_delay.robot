*** Settings ***
Documentation  Maintainers: przemyslaw.kempa@nokia.com

Resource    ../tc_scenarios.robot
Resource    ../hran_ta/resources/ca_Recovery_link_break.robot
Resource    ../hran_ta/resources/ca_BSRF_general.robot
#Resource    ../SiSo_L3_Call.robot

*** Variables ***
${SISO_L3_CALL}   False
${COUNTER_CHECK}  True

*** Keywords ***
TC_SiSo_SM_RU_Secondary_link_break_with_changed_time_delay
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-19083
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this User Scenario is to verify that Secondary link recovers without radio reset and without impact to cell(s) associated
    ...  to Primary link. This User Scenario is relevant to all TDD radios and FDD radios supporting feature CB006911 Wide NR carrier bandwidth
    ...  on legacy FDD radios (AHGD, AHEGB and AHEGC).
    ...  This user scenario describes handling of the Nokia CPRI Secondary Link interruption between BBU and RU having multilink fronthaul
    ...  connection in case of recovery is activated and Classical BTS used in dedicated operation mode. During the link break the fiber length
    ...  length of the optical link is changed, so that time delay is out of tolerance: following calculation based on 1
    ...  1 UTU = 1/1.2288GHz ~ 0,8 ns (T12: +/- 44 UTU = 0,8 ns*44 = 35,2 ns and speed ~30 cm/ns ? 35,2*30 cm= 1056 cm= 10,56 m)
    ...  at least 11 m change in optical cable length.
    ...  To perform short link breaks test support optical switch Calient S320
    ...  CPRI Link Recovery activated: 'actCpriLinkRecovery' is set as TRUE state
    ...  'cpriSyncBreakTime' > 5000ms
    ...  'enabledCpriLongLinkBreakAlarm' is set TRUE state
    ...  actForceRFAutoReset is set as TRUE state
    ...  actFaultSignature is set as TRUE state
    ...  mtSbtsSfpBbmodLane or mtSbtsSfpSmodLane (ASOG) is set to 5min
    ...
    ...
    ...  Mandatory variable in testsuite add as Set Test Variable
    ...  e.g.
    ...  ${IP_SWITCH}    10.42.201.14
    ...  ${TESTED_CABLINKS_OS_PORT}  ${duallink_tested_cablinks}
    ...  ${LONG_FIBER}    5.3.5-5.4.8  (port_in-port_out of long link)
    ...
    ...  &{duallink_tested_cablinks}=  CABLINK-4=4.4.1  CABLINK-5=4.4.3
    ...  Config object name for Cablink -> CABLINK-4
    ...  Port in switch where cablink is connected -> 4.4.1
    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}       False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}           #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...
    ...  *****************
    ...  History of change
    ...  *****************

    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB007437
    Common Test Setup  tools_to_setup=ADMIN
    Logging With Timestamp
    ...  message=TC_SiSo_SM_RU_Secondary_link_break_with_changed_time_delay will be executed
    ...  style=ONGOING
    Precondition For Secondary Link Break With Changed Time Delay
    FOR  ${rep_index}  IN  @{REPETITION_LIST}
      Step 1. Perform Secondary Short Link Break With Changed Time Delay  ${rep_index}
      Step 2. Checking Expected States After Secondary Short Link Break With Changed Time Delay  ${rep_index}
      Step 3. Perform Secondary Long Link Break With Changed Time Delay  ${rep_index}
      Step 4. Checking Expected States After Secondary Long Link Break With Changed Time Delay  ${rep_index}
    END
    Postcondition For Secondary Link Break With Changed Time Delay
    [Teardown]  Run Keywords
    ...  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Recovery For Secondary Link Break With Changed Time Delay  AND
    ...  Common Test Teardown

Precondition For Secondary Link Break With Changed Time Delay
    Log  === Precondition For Secondary Link Break With Changed Time Delay ===  console=${TRUE}

    Prepering Variables To Test Secondary Link Break With Changed Time Delay
    [Teardown]  Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS

Step 1. Perform Secondary Short Link Break With Changed Time Delay
    [Arguments]  ${rep_index}
    Log  \n||========================================================  console=${TRUE}
    Log  \n${TEST NAME} repetition no: ${rep_index} started  console=${TRUE}
    Log  === Step 1. Perform Secondary Short Link Break With Changed Time Delay ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/short_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_short_break
    Change Optical Connection To Long Link For Secondary Link Break With Changed Time Delay

Step 2. Checking Expected States After Secondary Short Link Break With Changed Time Delay
    [Arguments]  ${rep_index}
    Log  === Step 2. Checking Expected States After Secondary Short Link Break ===  console=${TRUE}
    Sleep  10s
    Run Keyword And Continue On Failure  Checking Expected Alarms In Syslog After Link Break  ${SECONDARY_CABLINK_DICT}  4721
    Verify Multi BTS State
    Verify Alarms On All Nodes
    Run Keyword And Continue On Failure  Checking Historical Alarm After Secondary Short Break With Changed Time Delay
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${TESTED_CELL_DN}  ${cfg['test_logs_path']}/${rep_index}/short_break_log
    ...  ELSE  Log To Console  L3 Call skipped  console=${TRUE}
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/short_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Checking availabilityStatus In Infomodel After Secondary Link Break With Changed Time Delay
    ...  ${cfg['test_logs_path']}/${rep_index}/short_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Step 3. Perform Secondary Long Link Break With Changed Time Delay
    [Arguments]  ${rep_index}
    Log  === Step 3. Perform Secondary Long Link Break With Changed Time Delay ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/long_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_long_break
    ${long_link_break_duration}  Evaluate  random.randint(${CPRI_SYNC_BREAK_TIME_VALUE},${CPRI_SYNC_BREAK_TIME_VALUE}+10000)  random
    Change Optical Connection To Short Link For Secondary Link Break With Changed Time Delay  ${long_link_break_duration}

Step 4. Checking Expected States After Secondary Long Link Break With Changed Time Delay
    [Arguments]  ${rep_index}
    Log  === Step 4. Checking Expected States After Secondary Long Link Break With Changed Time Delay ===  console=${TRUE}
    Verify Multi BTS State
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Secondary Long Link Break With Changed Time Delay
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${TESTED_CELL_DN}  ${cfg['test_logs_path']}/${rep_index}/long_break_log
    ...  ELSE  Log To Console  L3 Call skipped  console=${TRUE}
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/long_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Checking availabilityStatus In Infomodel After Secondary Link Break With Changed Time Delay
    ...  ${cfg['test_logs_path']}/${rep_index}/long_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Postcondition For Secondary Link Break With Changed Time Delay
    Log  === Postcondition For Secondary Link Break With Changed Time Delay ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}  tools_to_setup=IM_ADMIN
    Verify Alarms On All Nodes
    Run Keyword If  ${COUNTER_CHECK}  Collecting And Checking Counters For Secondary Link Break With Changed Time Delay


Prepering Variables To Test Secondary Link Break With Changed Time Delay
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    ${bts_parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}  connection=${BTS_ID}
    Set Test Variable  ${BTS_NAME}  ${bts_parameter[0]['parameters']['btsName']}
    Checking Parameters For Link Break  ${TRUE}
    ${mnlent_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1  connection=${BTS_ID}
    ${cpriSyncBreakTime_value}  Get From Dictionary  ${mnlent_parameter[0]['parameters']}  cpriSyncBreakTime
    Run Keyword If  ${cpriSyncBreakTime_value}<5000  FAIL  cpriSyncBreakTime value is to small to perform test
    Set Test Variable  ${CPRI_SYNC_BREAK_TIME_VALUE}  ${cpriSyncBreakTime_value}
    Log Dictionary  ${TESTED_CABLINKS_OS_PORT}
    ${cablink_cfg_list}  Get Dictionary Keys  ${TESTED_CABLINKS_OS_PORT}
    Set Test Variable  ${CABLINK_CFG_LIST}  ${cablink_cfg_list}
    ${all_cells_distname}  Create All Cells Distname
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    ${tested_rmod_dn}  Get From Dictionary  ${all_cablinks['${CABLINK_CFG_LIST[0]}']}  rmod
    Set Test Variable  ${TESTED_RMOD_DN}  ${tested_rmod_dn}
    ${tested_radio_parameters}  admin.Get Parameters For  RMOD  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    ${tested_rmod_sn}  Get From Dictionary  ${tested_radio_parameters}  serialNumber
    Set Test Variable  ${TESTED_RMOD_SN}  ${tested_rmod_sn}
    ${cablinks_with_affected_cells_dict}  Create Cablinks Dictionary With Affected Cells Lists
    &{tested_cablink}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink}  ${cablink_cfg}=&{all_cablinks['${cablink_cfg}']}
    END
    Set Test Variable  ${TESTED_CABLINK}  ${tested_cablink}
    ${secondary_cablink_cfg}  Get Secondary Cablink Config Object Name  ${TESTED_CABLINK}
    ${secondary_cablink_internal_dn}  Get From Dictionary  ${TESTED_CABLINK['${secondary_cablink_cfg}']}  internal
    ${secondary_cablink_runtime_dn}  Get From Dictionary  ${TESTED_CABLINK['${secondary_cablink_cfg}']}  runtime
    &{secondary_cablink_dict}  Create Dictionary
    Set To Dictionary  ${secondary_cablink_dict}  ${secondary_cablink_cfg}=${TESTED_CABLINK['${secondary_cablink_cfg}']}
    Set Test Variable  ${SECONDARY_CABLINK_DICT}  ${secondary_cablink_dict}
    Set Test Variable  ${SECONDARY_CABLINK_INTERNAL_DN}  ${secondary_cablink_internal_dn}
    Set Test Variable  ${SECONDARY_CABLINK_RUNTIME_DN}  ${secondary_cablink_runtime_dn}
    ${tested_cell_dn}  Get From Dictionary  ${cablinks_with_affected_cells_dict}  ${SECONDARY_CABLINK_INTERNAL_DN}
    Set Test Variable  ${TESTED_CELL_DN}  ${tested_cell_dn}
    ${not_affected_cells_dn}  Create List  @{ALL_CELLS_DISTNAME}
    Remove Values From List  ${not_affected_cells_dn}  @{TESTED_CELL_DN}
    Log List  ${not_affected_cells_dn}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN}  ${not_affected_cells_dn}
    ${sec_port_in}  Get Port Secondary Link Flapping  ${TESTED_CABLINK}  ${TESTED_CABLINKS_OS_PORT}
    Set Test Variable  ${SEC_PORT_IN}  ${sec_port_in}
    Run Keyword If  ${COUNTER_CHECK}  Preparing Counters Variables For Secondary Link Break With Changed Time Delay

Preparing Counters Variables For Secondary Link Break With Changed Time Delay
    ${fsm_info}  Get Fsm Info  connection=${BTS_ID}
    ${product_name}  Get From Dictionary  ${fsm_info[0]}  productName
    ${airscale_core}  Run Keyword And Return Status  Should Match Regexp  ${product_name}  AirScale Core
    ${short_counter_nr}  Set Variable If  ${airscale_core}  M40014C10  M40015C10
    Set Test Variable  ${SHORT_COUNTER_NR}  ${short_counter_nr}
    ${long_counter_nr}  Set Variable If  ${airscale_core}  M40014C11  M40015C11
    Set Test Variable  ${LONG_COUNTER_NR}  ${long_counter_nr}
    ${short_counter_before_break}  Get PM Counter For Link Break  ${BTS_ID}  ${SHORT_COUNTER_NR}  alias=${BTS_ID}
    Set Test Variable  ${SHORT_COUNTER_BEFORE_BREAK}  ${short_counter_before_break}
    ${long_counter_before_break}  Get PM Counter For Link Break  ${BTS_ID}  ${LONG_COUNTER_NR}  alias=${BTS_ID}
    Set Test Variable  ${LONG_COUNTER_BEFORE_BREAK}  ${long_counter_before_break}
    ${bts_info}  Get Bts Info  connection=${BTS_ID}
    ${cablink_list}  Get From Dictionary  ${bts_info}  cables
    ${bbmod_list}  Get From Dictionary  ${bts_info}  basebandModules
    ${smod_list}  Get From Dictionary  ${bts_info}  systemModules
    ${hwmod_list}  Set Variable If  ${airscale_core}  ${smod_list}  ${bbmod_list}
    ${firstpoint_tested_list}  Create List
    ${secondary_cablink_config_name}  Get Secondary Cablink Config Object Name  ${TESTED_CABLINK}
    FOR  ${cablink}  IN  @{cablink_list}
      Run Keyword If  "${cablink['id']['configuration']}"=="MRBTS-${BTS_ID}/EQM-1/HWTOP-1/${secondary_cablink_config_name}"  Append To List
      ...  ${firstpoint_tested_list}  ${cablink['firstEndPointId']['configuration']}
    END
    Log  ${firstpoint_tested_list}
    FOR  ${firstpoint}  IN  @{firstpoint_tested_list}
      ${index}  Get Index From List  ${firstpoint_tested_list}  ${firstpoint}
      ${sfp_runtime}  ${tested_hwmod}  Get SFP Runtime Distname For Tested HW Port  ${hwmod_list}  ${firstpoint}
      ${hwmod_runtime}  ${sfp_runtime}  Split String From Right  ${sfp_runtime}  /  1
      ${sfp_runtime}  Remove String  ${sfp_runtime}  _R
      ${tested_hwmod}  Fetch From Right  ${tested_hwmod}  APEQM-1/
      ${sfp_cfg}  Set Variable  ${tested_hwmod}/${sfp_runtime}
      Set List Value  ${firstpoint_tested_list}  ${index}  ${sfp_cfg}
    END
    Log  ${firstpoint_tested_list}
    Set Test Variable  ${SFP_TESTED_LIST}  ${firstpoint_tested_list}

Collecting And Checking Counters For Secondary Link Break With Changed Time Delay
    Sleep  5min  msg=Wait to collect counter
    Log  Start collecting counter for short and long break  console=${TRUE}
    ${short_counter_after_break}  Get PM Counter For Link Break  ${BTS_ID}  ${SHORT_COUNTER_NR}  alias=${BTS_ID}
    ${long_counter_after_break}  Get PM Counter For Link Break  ${BTS_ID}  ${LONG_COUNTER_NR}  alias=${BTS_ID}
    FOR  ${sfp_dn}  IN  @{SFP_TESTED_LIST}
      ${cabinet}  ${hwmod}  ${sfp}  Split String  ${sfp_dn}  /
      ${short_before}  Get From Dictionary  ${SHORT_COUNTER_BEFORE_BREAK['${cabinet}']['${hwmod}']}  ${sfp}
      ${long_before}  Get From Dictionary  ${LONG_COUNTER_BEFORE_BREAK['${cabinet}']['${hwmod}']}  ${sfp}
      ${short_after}  Get From Dictionary  ${short_counter_after_break['${cabinet}']['${hwmod}']}  ${sfp}
      ${long_after}  Get From Dictionary  ${long_counter_after_break['${cabinet}']['${hwmod}']}  ${sfp}
      ${short_counter}  Evaluate  ${short_after} - ${short_before}
      ${long_counter}  Evaluate  ${long_after} - ${long_before}
      ${short_counter_status}  Run Keyword And Return Status  Should Be True  ${REPETITION_LIST[-1]} <= ${short_counter}
      ${long_counter_status}  Run Keyword And Return Status  Should Be True  ${REPETITION_LIST[-1]} <= ${long_counter}
      Run Keyword If  ${short_counter_status}
      ...  Log  Proper counter value -> ${short_counter} of short link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${short_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${short_counter} of short link break for ${sfp}
      Run Keyword If  ${long_counter_status}  Log  Proper counter value -> ${long_counter} of long link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${long_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${long_counters} of long link break for ${sfp}
    END

Change Optical Connection To Long Link For Secondary Link Break With Changed Time Delay
    Optical Switch Setup  switch_ip=${IP_SWITCH}
    ${all_calient_ports}  Get Optical Switch Channels
    ${sec_port_out}  Get From Dictionary  ${all_calient_ports}  ${SEC_PORT_IN}
    Set Test Variable  ${SEC_PORT_OUT}  ${sec_port_out}
    &{new_connections_long_BB}  Create Dictionary
    &{new_connections_long_RF}  Create Dictionary
    ${long_port_in}  ${long_port_out}  Split String  ${LONG_FIBER}  -
    Set Test Variable  ${LONG_PORT_IN}  ${long_port_in}
    Set Test Variable  ${LONG_PORT_OUT}  ${long_port_out}
    Set To Dictionary  ${new_connections_long_BB}  in=${SEC_PORT_IN}
    Set To Dictionary  ${new_connections_long_BB}  out=${LONG_PORT_OUT}
    Set To Dictionary  ${new_connections_long_BB}  dir=uni
    Set To Dictionary  ${new_connections_long_RF}  in=${LONG_PORT_IN}
    Set To Dictionary  ${new_connections_long_RF}  out=${SEC_PORT_OUT}
    Set To Dictionary  ${new_connections_long_RF}  dir=uni
    ${in_port_list}  Create List  ${SEC_PORT_IN}
    Remove Optical Switch connections  in_ports=${in_port_list}
    Set Optical Switch Channel  settings=${new_connections_long_BB}
    Set Optical Switch Channel  settings=${new_connections_long_RF}
    [Teardown]  Teardown Optical Switch

Change Optical Connection To Short Link For Secondary Link Break With Changed Time Delay
    [Arguments]  ${long_link_break_duration}
    Optical Switch Setup  switch_ip=${IP_SWITCH}
    &{new_connections_basic}  Create Dictionary
    Set To Dictionary  ${new_connections_basic}  in=${SEC_PORT_IN}
    Set To Dictionary  ${new_connections_basic}  out=${SEC_PORT_OUT}
    Set To Dictionary  ${new_connections_basic}  dir=uni
    ${in_port_list}  Create List  ${SEC_PORT_IN}  ${LONG_PORT_IN}
    Remove Optical Switch connections  in_ports=${in_port_list}
    Sleep  ${long_link_break_duration}ms
    Set Optical Switch Channel  settings=${new_connections_basic}
    Run Keyword If  ${long_link_break_duration}>0  Run Keyword And Continue On Failure
    ...  Checking Expected Alarms For Long Secondary Link Break With Changed Time Delay
    [Teardown]  Teardown Optical Switch

Checking Expected Alarms For Long Secondary Link Break With Changed Time Delay
    Wait Until Keyword Succeeds  3min  5s  Checking Expected Alarms In Syslog After Link Break  ${SECONDARY_CABLINK_DICT}  4760

Checking Historical Alarm After Secondary Short Break With Changed Time Delay
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking Historical Alarm After Secondary Long Link Break With Changed Time Delay
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking availabilityStatus In Infomodel After Secondary Link Break With Changed Time Delay
    [Arguments]  ${im_log_path}
    ${affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${TESTED_CELL_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${affected_cells_status}  FAIL
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_affected_cells_status}
    ...  Log  Affected Cells don't changed availabilityStatus after link break.  console=${TRUE}
    ${not_affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${NOT_AFFECTED_CELLS_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_not_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${not_affected_cells_status}  PASS
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_not_affected_cells_status}
    ...  Fail  FAIL!!! Not affected Cells changed availabilityStatus after link break.

Recovery For Secondary Link Break With Changed Time Delay
    Run Keyword And Ignore Error  Change Optical Connection To Short Link For Secondary Link Break With Changed Time Delay  0
    Run Keyword And Ignore Error  Collect Snapshot  target_file_name=${cfg['test_logs_path']}/Snapshot.zip  connection=${BTS_ID}
    Run Keyword And Ignore Error  Reset Site  alias=${BTS_ID}
    Run Keyword And Ignore Error  Verify BTS State  ${BTS_ID}
