*** Settings ***
Documentation  Maintainers: przemyslaw.kempa@nokia.com

Resource    ../tc_scenarios.robot
Resource    ../hran_ta/resources/ca_Recovery_link_break.robot
Resource    ../hran_ta/resources/ca_BSRF_general.robot
#Resource    ../SiSo_L3_Call.robot


*** Variables ***
${SISO_L3_CALL}    False
${COUNTER_CHECK}   True

*** Keywords ***
TC_SiSo_SM_RU_Secondary_link_break_in_chaining
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-19083
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check correctness of CPRI link interruption handling between BBU and RU when recovery function
    ...  is activated and Classical BTS is used in dedicated operation mode. RU is connected with duallink. Break is performed for secondary link.
    ...  BTS working in dedicated mode (4G or 5G) with CPRI RU in CB007437 and all RATs in CB007447.
    ...  To perform short link breaks test support optical switch Calient S320 (using TL1 commands)
    ...  CPRI Link Recovery activated: 'actCpriLinkRecovery' is set as TRUE state
    ...  The NIDD parameter 'cpriSyncBreakTime' is locked to its default value (200 ms) by BTS-system in CB007437 and is modiable in CB007447
    ...  Time of short and long link break is generated randomly with dedicated boundaries.
    ...  Mandatory parameters for CB007447:
    ...  actForceRFAutoReset is set as TRUE state
    ...  actFaultSignature is set as TRUE state
    ...  mtSbtsSfpBbmodLane or mtSbtsSfpSmodLane (ASOG) is set to 5min
    ...
    ...  Mandatory variable in testsuite add as Set Test Variable
    ...  e.g.
    ...  TESTED_CABLINKS_OS_PORT=&{duallink_tested_cablinks}
    ...
    ...  &{duallink_tested_cablinks}   CABLINK-4=10.42.201.14_4.4.1  CABLINK-5=10.42.201.14_4.4.3
    ...  Config object name of cablink-> CABLINK-4
    ...  IP switch and Port where cablink is connected -> IPswitch_port    10.42.201.14_4.4.1

    ...
    ...  *** Test Variable For L3 Call ***
    ...  ${SISO_L3_CALL}             False  #default value for L3 call is False, set test variable as True to perform test with L3 call
    ...  ${CELLS_YAML_PATH}                 #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
    ...
    ...  *****************
    ...  History of change
    ...  *****************
    ...

    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB007437
    Common Test Setup  tools_to_setup=ADMIN
    Logging With Timestamp
    ...  message=TC_SiSo_SM_RU_Secondary_link_break_in_chaining will be executed
    ...  style=ONGOING
    Precondition. Secondary Link Break In Chaining
    FOR  ${rep_index}  IN  @{REPETITION_LIST}
        Step 1. Perform Secondary Short Link Break In Chaining  ${rep_index}
        Step 2. Checking Expected States After Secondary Short Link Break In Chaining  ${rep_index}
        Step 3. Perform Secondary Middle Link Break In Chaining  ${rep_index}
        Step 4. Checking Expected States After Secondary Middle Link Break In Chaining  ${rep_index}
        Step 5. Perform Secondary Long Link Break In Chaining  ${rep_index}
        Step 6. Checking Expected States After Secondary Long Link Break In Chaining  ${rep_index}
    END
    Postcondition For Secondary Link Break In Chaining
    [Teardown]  Run Keywords
    ...  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Recovery For Secondary Link Break In Chaining  AND
    ...  Run Keyword And Ignore Error  Common Test Teardown


Precondition. Secondary Link Break In Chaining
    Log  === Precondition. Secondary Link Break In Chaining ===  console=${TRUE}
    Preparing Variables To Test Secondary Link Break In Chaining
    [Teardown]  Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS

Step 1. Perform Secondary Short Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  \n||========================================================  console=True
    Log  \n${TEST NAME} repetition no: ${rep_index} started  console=True
    Log  === Step 1. Perform Secondary Short Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/short_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_short_break
    ${short_link_break_duration}  Evaluate  random.randint(20,${CPRI_SYNC_BREAK_TIME_VALUE})  random
    Run Keyword If  '${SECONDARY_SWITCH_PORT}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${SECONDARY_SWITCH_PORT}  switch_link_break_time=${short_link_break_duration}  AND
    ...  Log  Short link break will last ${short_link_break_duration}ms  console=${TRUE}

Step 2. Checking Expected States After Secondary Short Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  === Step 2. Checking Expected States After Secondary Short Link Break In Chaining ===  console=${TRUE}
    Sleep  30s
    Run Keyword And Continue On Failure  Checking Expected Alarms In Syslog After Link Break  ${SECONDARY_CABLINK_DICT}  4721
    ${recovery_needed}  Run Keyword If  not ${CB007447_ACTIVE}
    ...  Checking Acceptable Alarms And Perform Recovery For Secondary Link Break In Chain CB007437
    Run Keyword And Continue On Failure  Verify Multi BTS State
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Secondary Short/Middle Break In Chaining
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}/${rep_index}/short_break_log  ${BTS_ID}
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/short_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Run Keyword If  not ${recovery_needed}  Checking availabilityStatus In Infomodel After Secondary Link Break In Chaining
    ...  ${cfg['test_logs_path']}/${rep_index}/short_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Step 3. Perform Secondary Middle Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  === Step 3. Perform Secondary Middle Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/middle_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_middle_break
    ${middle_link_break_duration}=  Evaluate  random.randint(${CPRI_SYNC_BREAK_TIME_VALUE}+2500,${CPRI_SYNC_BREAK_TIME_VALUE}+5000)  random
    Run Keyword If  '${SECONDARY_SWITCH_PORT}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${SECONDARY_SWITCH_PORT}  switch_link_break_time=${middle_link_break_duration}
    ...  AND  Log  Middle link break will last ${middle_link_break_duration}ms  console=${TRUE}
    Sleep  ${middle_link_break_duration}ms

Step 4. Checking Expected States After Secondary Middle Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  === Step 4. Checking Expected States After Secondary Middle Link Break In Chaining ===  console=${TRUE}
    ${recovery_needed}  Run Keyword If  not ${CB007447_ACTIVE}
    ...  Checking Acceptable Alarms And Perform Recovery For Secondary Link Break In Chain CB007437
    Run Keyword And Continue On Failure  Run Keyword If  ${CB007447_ACTIVE}
    ...  Checking Expected Alarms For Secondary Link After Middle Break In Chaining CB007447
    Run Keyword And Continue On Failure  Verify Multi BTS State
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Secondary Short/Middle Break In Chaining
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}/${rep_index}/middle_break_log  ${BTS_ID}
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/middle_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Run Keyword If  not ${recovery_needed}  Checking availabilityStatus In Infomodel After Secondary Link Break In Chaining
    ...  ${cfg['test_logs_path']}/${rep_index}/middle_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Step 5. Perform Secondary Long Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  === Step 5. Perform Secondary Long Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/long_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_long_break
    ${long_link_break_duration}  Evaluate  random.randint(${CPRI_SYNC_BREAK_TIME_VALUE}+400000,${CPRI_SYNC_BREAK_TIME_VALUE}+420000)  random
    Run Keyword If  '${SECONDARY_SWITCH_PORT}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${SECONDARY_SWITCH_PORT}  switch_link_break_time=${long_link_break_duration}  AND
    ...  Log  Middle link break will last ${long_link_break_duration}ms  console=${TRUE}

Step 6. Checking Expected States After Secondary Long Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  === Step 6. Checking Expected States After Secondary Long Link Break In Chaining ===  console=${TRUE}
    ${recovery_needed}  Run Keyword If  not ${CB007447_ACTIVE}
    ...  Checking Acceptable Alarms And Perform Recovery For Secondary Link Break In Chain CB007437
    Run Keyword And Continue On Failure  Checking Expected Alarms For Secondary Link Break In Chain After Long Break
    Run Keyword And Continue On Failure  Verify Multi BTS State
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Secondary Long Break In Chaining
    Run Keyword If  ${CB007447_ACTIVE}  Run Keyword And Continue On Failure
    ...  Checking Expected Alarms In Syslog After Link Break  ${SECONDARY_CABLINK_DICT}  4760
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}/${rep_index}/long_break_log  ${BTS_ID}
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/long_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Run Keyword If  not ${recovery_needed}  Checking availabilityStatus In Infomodel After Secondary Link Break In Chaining
    ...  ${cfg['test_logs_path']}/${rep_index}/long_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2


Postcondition For Secondary Link Break In Chaining
    Log  === Postcondition For Secondary Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}  tools_to_setup=IM_ADMIN
    Verify Alarms On All Nodes
    Run Keyword If  ${CB007447_ACTIVE} and ${COUNTER_CHECK}  Collecting And Checking Counters For Secondary Link Break In Chaining

Preparing Variables To Test Secondary Link Break In Chaining
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    ${bts_parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}  connection=${BTS_ID}
    Set Test Variable  ${BTS_NAME}  ${bts_parameter[0]['parameters']['btsName']}
    ${CB007447_active}  Check If Current Build Is Newer Than  SBTS24R3_ENB_9999_240508_000004  alias=${BTS_ID}
    Set Test Variable  ${CB007447_ACTIVE}  ${CB007447_active}
    Checking Parameters For Link Break  ${CB007447_ACTIVE}
    ${mnlent_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1  connection=${BTS_ID}
    ${cpriSyncBreakTime_value}  Get From Dictionary  ${mnlent_parameter[0]['parameters']}  cpriSyncBreakTime
    Set Test Variable  ${CPRI_SYNC_BREAK_TIME_VALUE}  ${cpriSyncBreakTime_value}
    Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${tested_cablinks_os_port}
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
    ${sfp_secondary_dn}  Get Destination Sfp Distname For Cablink  ${SECONDARY_CABLINK_INTERNAL_DN}
    Set Test Variable  ${SFP_SECONDARY_DN}  ${sfp_secondary_dn}
    ${tested_cell_dn}  Get From Dictionary  ${cablinks_with_affected_cells_dict}  ${SECONDARY_CABLINK_INTERNAL_DN}
    Set Test Variable  ${TESTED_CELL_DN}  ${tested_cell_dn}
    ${not_affected_cells_dn}  Create List  @{ALL_CELLS_DISTNAME}
    Remove Values From List  ${not_affected_cells_dn}  @{TESTED_CELL_DN}
    Log List  ${not_affected_cells_dn}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN}  ${not_affected_cells_dn}
    ${secondary_switch_port}  Get Port Secondary Link Flapping  ${TESTED_CABLINK}  ${TESTED_CABLINKS_OS_PORT}
    Set Test Variable  ${SECONDARY_SWITCH_PORT}  ${secondary_switch_port}
    Run Keyword If  ${CB007447_ACTIVE} and ${COUNTER_CHECK}  Preparing Counters Variables For Secondary Link Break In Chaining

Preparing Counters Variables For Secondary Link Break In Chaining
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

Checking Acceptable Alarms And Perform Recovery For Secondary Link Break In Chain CB007437
    ${4685_status}  Run Keyword And Return Status  Assert Alarm Active  faultId=4685, severity=Critical  timeout=15  connection=${BTS_ID}
    ${4606_status}  Run Keyword And Return Status  Assert Alarm Active  faultId=4606, severity=Critical  timeout=15  connection=${BTS_ID}
    Run Keyword If  ${4685_status}  Log To Console  Acceptable fault 4685 appears
    Run Keyword If  ${4606_status}  Log To Console  Acceptable fault 4606 appears
    ${recovery_status}=  Run Keyword And Return Status  Should Be True  ${4685_status}==${True} or ${4606_status}==${True}
    Run Keyword If  ${recovery_status}  Reset Site  alias=${BTS_ID}
    Verify Multi BTS State
    [Return]  ${recovery_status}

Checking Historical Alarm After Secondary Short/Middle Break In Chaining
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Run Keyword If  not ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=4685, severity=Critical  connection=${BTS_ID}
    Run Keyword If  not ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=4606, severity=Critical  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking availabilityStatus In Infomodel After Secondary Link Break In Chaining
    [Arguments]  ${im_log_path}
    ${affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${TESTED_CELL_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${affected_cells_status}  FAIL
    Run Keyword If  not ${final_affected_cells_status}  Log  Affected Cells don't changed availabilityStatus after link break.  console=${TRUE}
    ${not_affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${NOT_AFFECTED_CELLS_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_not_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${not_affected_cells_status}  PASS
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_not_affected_cells_status}
    ...  Fail  FAIL!!! Not affected Cells changed availabilityStatus after link break.

Checking Expected Alarms For Secondary Link After Middle Break In Chaining CB007447
    Wait Until Keyword Succeeds  1min  5s  Checking Expected Alarms In Syslog After Link Break  ${SECONDARY_CABLINK_DICT}  4760

Checking Historical Alarm After Secondary Long Break In Chaining
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Run Keyword If  not ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=4685, severity=Critical  connection=${BTS_ID}
    Run Keyword If  not ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=4606, severity=Critical  connection=${BTS_ID}
    Run Keyword If  not ${CB007447_ACTIVE}
    ...  Add Allowed Alarm  faultId=1815, severity=Major, alarmingObjectIds[0].runtime=${SECONDARY_CABLINK_RUNTIME_DN}  connection=${BTS_ID}
    Add Allowed Alarm  faultId=2002, severity=Critical, alarmingObjectIds[0].internal=${SFP_SECONDARY_DN}/LANE_R-1  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking Expected Alarms For Secondary Link Break In Chain After Long Break
    ${fault_2002_secondary_link_status}  Run Keyword And Return Status  Assert Alarm Active  timeout=400
    ...  faultId=2002, severity=Critical, alarmingResource=${SFP_SECONDARY_DN}/LANE_R-1  connection=${BTS_ID}
    Run Keyword If  ${fault_2002_secondary_link_status}  Log  Expected fault 2002 for ${SFP_SECONDARY_DN}/LANE_R-1 appeared.  console=${TRUE}
    Run Keyword If  not ${fault_2002_secondary_link_status}  Run Keyword And Continue On Failure
    ...  Fail  Expected fault 2002 for ${SFP_SECONDARY_DN}/LANE_R-1 NOT appeared!!! test failed.

Collecting And Checking Counters For Secondary Link Break In Chaining
    Sleep  5min  msg=Wait to collect counter
    Log  Start collecting counter for short and long break  console=True
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
      ${long_counter_status}  Run Keyword And Return Status  Should Be True  2*${REPETITION_LIST[-1]} <= ${long_counter}
      Run Keyword If  ${short_counter_status}
      ...  Log  Proper counter value -> ${short_counter} of short link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${short_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${short_counter} of short link break for ${sfp}
      Run Keyword If  ${long_counter_status}  Log  Proper counter value -> ${long_counter} of long link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${long_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${long_counter} of long link break for ${sfp}
    END

Recovery For Secondary Link Break In Chaining
    Run Keyword And Ignore Error  Collect Snapshot  target_file_name=${cfg['test_logs_path']}/Snapshot.zip  connection=${BTS_ID}
    Run Keyword And Ignore Error  Reset Site  alias=${BTS_ID}
    Run Keyword And Ignore Error  Verify Multi BTS State
