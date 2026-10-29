*** Settings ***
Documentation  Maintainers: przemyslaw.kempa@nokia.com

Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
Resource    resources/ca_BSRF_general.robot
#Resource    ../SiSo_L3_Call.robot

*** Variables ***
${SHORT_LINK_BREAK_MAX}  ${EMPTY}
${SISO_L3_CALL}          False
${COUNTER_CHECK}         True

*** Keywords ***
TC_SiSo_SM_RU_Primary_link_break
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-19083
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check correctness of CPRI link interruption handling between BBU and RU when recovery function
    ...  is activated and Classical BTS is used in dedicated operation mode. RU is connected with duallink
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
    ...  &{duallink_tested_cablinks}=   CABLINK-4=10.42.201.14_4.4.1  CABLINK-5=10.42.201.14_4.4.3
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


    Set Tags	CA-CM    AUTHOR-przemyslaw.kempa@nokia.com    MAINTAINER-przemyslaw.kempa@nokia.com
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB007437    FEATURE-CB007447
    Common Test Setup  tools_to_setup=ADMIN
    Logging With Timestamp
    ...  message=TC_SiSo_SM_RU_Primary_link_break will be executed
    ...  style=ONGOING
    Precondition For Primary Link Break
    FOR  ${rep_index}  IN  @{REPETITION_LIST}
      Step 1. Perform Primary Short Link Break  ${rep_index}
      Step 2. Checking Expected States After Primary Short Link Break  ${rep_index}
      Step 3. Perform Primary Long Link Break  ${rep_index}
      Step 4. Checking Expected States After Primary Long Link Break  ${rep_index}
    END
    Postcondition For Primary Link Break
    [Teardown]  Run Keywords
    ...  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Recovery For Primary Link Break  AND
    ...  Run Keyword And Ignore Error  Common Test Teardown


Precondition For Primary Link Break
    Log  === Precondition For Primary Link Break ===  console=${TRUE}
    Preparing Variables To Test Primary Link Break
    [Teardown]  Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS

Step 1. Perform Primary Short Link Break
    [Arguments]  ${rep_index}
    Log  \n||========================================================  console=${TRUE}
    Log  \n${TEST NAME} repetition no: ${rep_index} started  console=${TRUE}
    Log  \n=== Step 1. Perform Primary Short Link Break ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/short_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_short_break
    ${short_link_break_max_set}  Set Variable If  "${SHORT_LINK_BREAK_MAX}"!="${EMPTY}"  ${SHORT_LINK_BREAK_MAX}  0.8*${CPRI_SYNC_BREAK_TIME_VALUE}
    ${short_link_break_duration}=  Evaluate  random.randint(20,${short_link_break_max_set})  random
    ${all_cablinks_before_short}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_before_short}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink_before_short}  ${cablink_cfg}=&{all_cablinks_before_short['${cablink_cfg}']}
    END
    Set Test Variable  ${TESTED_CABLINK_BEFORE_SHORT}  ${tested_cablink_before_short}
    ${switch_ip_port}  Get Port Primary Link Flapping  ${TESTED_CABLINK_BEFORE_SHORT}  ${TESTED_CABLINKS_OS_PORT}
    Run Keyword If  '${switch_ip_port}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${switch_ip_port}  switch_link_break_time=${short_link_break_duration}  AND
    ...  Log  Short link break will last ${short_link_break_duration}ms  console=${TRUE}

Step 2. Checking Expected States After Primary Short Link Break
    [Arguments]  ${rep_index}
    Log  === Step 2. Checking Expected States After Primary Short Link Break ===  console=${TRUE}
    Sleep  30s
    Run Keyword And Continue On Failure  Checking Expected Alarms In Syslog After Link Break  ${TESTED_CABLINK_BEFORE_SHORT}  4721
    Run Keyword If  not ${CB007447_ACTIVE}  Checking Acceptable Alarms After Short Link Break
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  6min  3min  Verify Multi BTS State  timeout=10
    Verify Alarms On All Nodes
    Run Keyword And Continue On Failure  Checking Historical Alarm After Primary Short Break
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${TESTED_CELL_DN}  ${cfg['test_logs_path']}/${rep_index}/short_break_log
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    [Teardown]  Run Keywords
    ...  Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/short_break_log  status=${KEYWORD STATUS}  AND
    ...  Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  AND
    ...  Checking availabilityStatus In Infomodel After Primary Link Break
    ...  ${cfg['test_logs_path']}/${rep_index}/short_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Step 3. Perform Primary Long Link Break
    [Arguments]  ${rep_index}
    Log  === Step 3. Perform Primary Long Link Break ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/long_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_long_break
    ${long_link_break_duration}  Evaluate  random.randint(20000,30000)  random
    ${all_cablinks_before_long}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_before_long}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
     Set To Dictionary  ${tested_cablink_before_long}  ${cablink_cfg}=&{all_cablinks_before_long['${cablink_cfg}']}
    END
    Set Test Variable  ${TESTED_CABLINK_BEFORE_LONG}  ${tested_cablink_before_long}
    ${switch_ip_port}  Get Port Primary Link Flapping  ${TESTED_CABLINK_BEFORE_LONG}  ${TESTED_CABLINKS_OS_PORT}
    Run Keyword If  '${switch_ip_port}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${switch_ip_port}  switch_link_break_time=${long_link_break_duration}  AND
    ...  Log  Long link break will last ${long_link_break_duration}ms  console=${TRUE}

Step 4. Checking Expected States After Primary Long Link Break
    [Arguments]  ${rep_index}
    Log  === Step 4. Checking Expected States After Primary Long Link Break ===  console=${TRUE}
    Run Keyword And Continue On Failure  Run Keyword If  ${CB007447_ACTIVE}  Checking Expected Alarms For Long Link Break CB007447
    ...  ELSE  Checking Expected Alarms For Long Link Break CB007437
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  6min  3min  Verify Multi BTS State  timeout=10
    Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Run Keyword If  ${CB007447_ACTIVE}  Checking Historical Alarm After Primary Long Break CB007447
    ...  ELSE  Checking Historical Alarm After Primary Long Break CB007437
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${TESTED_CELL_DN}  ${cfg['test_logs_path']}/${rep_index}/long_break_log
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    [Teardown]  Run Keywords
    ...  Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/long_break_log  status=${KEYWORD STATUS}  AND
    ...  Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  AND
    ...  Checking availabilityStatus In Infomodel After Primary Link Break
    ...  ${cfg['test_logs_path']}/${rep_index}/long_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Postcondition For Primary Link Break
    Log  === Postcondition For Primary Link Break ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/Postcondition  tools_to_setup=IM_ADMIN
    Verify Alarms On All Nodes
    Run Keyword If  ${CB007447_ACTIVE} and ${COUNTER_CHECK}  Collecting And Checking Counters For Primary Link Break CB007447

Preparing Variables To Test Primary Link Break
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    ${bts_parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}  connection=${BTS_ID}
    Set Test Variable  ${BTS_NAME}  ${bts_parameter[0]['parameters']['btsName']}
    ${CB007447_active}  Check If Current Build Is Newer Than  SBTS24R3_ENB_9999_240508_000004  alias=${BTS_ID}
    Set Test Variable  ${CB007447_ACTIVE}  ${CB007447_active}
    Checking Parameters For Link Break  ${CB007447_ACTIVE}
    ${mnlent_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1  connection=${BTS_ID}
    ${cpriSyncBreakTime_value}  Get From Dictionary  ${mnlent_parameter[0]['parameters']}  cpriSyncBreakTime
    Set Test Variable  ${CPRI_SYNC_BREAK_TIME_VALUE}  ${cpriSyncBreakTime_value}
    Log Dictionary  ${TESTED_CABLINKS_OS_PORT}
    ${cablink_cfg_list}  Get Dictionary Keys  ${TESTED_CABLINKS_OS_PORT}
    Set Test Variable  ${CABLINK_CFG_LIST}  ${cablink_cfg_list}
    ${cablink_value}  Get Length  ${CABLINK_CFG_LIST}
    ${secondary_cablink_exit}  Set Variable If  ${cablink_value}>=2  True  False
    Set Test Variable  ${SECONDARY_CABLINK_EXIST}  ${secondary_cablink_exit}
    ${all_cells_distname}  Create All Cells Distname
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    ${tested_rmod_dn}  Get From Dictionary  ${all_cablinks['${CABLINK_CFG_LIST[0]}']}  rmod
    Set Test Variable  ${TESTED_RMOD_DN}  ${tested_rmod_dn}
    ${tested_radio_parameters}  admin.Get Parameters For  RMOD  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    ${tested_rmod_sn}  Get From Dictionary  ${tested_radio_parameters}  serialNumber
    Set Test Variable  ${TESTED_RMOD_SN}  ${tested_rmod_sn}
    ${tested_cell_dn}  admin.Get Cell Mapping By Module Id  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    Set Test Variable  ${TESTED_CELL_DN}  ${tested_cell_dn}
    ${not_affected_cells_dn}  Create List  @{ALL_CELLS_DISTNAME}
    Remove Values From List  ${not_affected_cells_dn}  @{TESTED_CELL_DN}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN}  ${not_affected_cells_dn}
    Log List  ${TESTED_CELL_DN}
    Log List  ${ALL_CELLS_DISTNAME}
    Log List  ${NOT_AFFECTED_CELLS_DN}
    Run Keyword If  ${CB007447_ACTIVE} and ${COUNTER_CHECK}  Preparing Counters Variables For Primary Link Break CB007447

Preparing Counters Variables For Primary Link Break CB007447
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
    FOR  ${cablink}  IN  @{cablink_list}
      Run Keyword If  "${cablink['id']['configuration']}"=="MRBTS-${BTS_ID}/EQM-1/HWTOP-1/${CABLINK_CFG_LIST[0]}"  Append To List
      ...  ${firstpoint_tested_list}  ${cablink['firstEndPointId']['configuration']}
      Continue For Loop If  not ${SECONDARY_CABLINK_EXIST}
      Run Keyword If  "${cablink['id']['configuration']}"=="MRBTS-${BTS_ID}/EQM-1/HWTOP-1/${CABLINK_CFG_LIST[1]}"  Append To List
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

Checking Expected Alarms For Long Link Break CB007447
    ${fault_10_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  timeout=120s  connection=${BTS_ID}
    Run Keyword If  ${fault_10_status}  Log  Expected fault 10 for RMOD-${TESTED_RMOD_SN} appeared.  console=${TRUE}
    Run Keyword If  not ${fault_10_status}  Run Keyword And Continue On Failure
    ...  Fail  Expected fault 10 for RMOD-${TESTED_RMOD_SN} NOT appeared!!! test failed.
    ${fault_4590_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=4590, severity=Warning, serialNo=${TESTED_RMOD_SN}  timeout=180s  connection=${BTS_ID}
    Run Keyword If  ${fault_4590_status}  Log  Expected fault 4590 for RMOD-${TESTED_RMOD_SN} appeared.  console=${TRUE}
    Checking Expected Alarms In Syslog After Link Break  ${TESTED_CABLINK_BEFORE_SHORT}  4760

Checking Expected Alarms For Long Link Break CB007437
    ${fault_1815_primary_link_status}  Run Keyword And Return Status  Assert Alarm Active  timeout=10  connection=${BTS_ID}
    ...  faultId=1815, severity=Major, alarmingResource=${PRIMARY_CABLINK_DN_BEFORE_LONG}
    Run Keyword If  ${fault_1815_primary_link_status}  Log  Expected fault 1815 for ${PRIMARY_CABLINK_DN_BEFORE_LONG} appeared.  console=${TRUE}
    ${fault_10_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  timeout=120s  connection=${BTS_ID}
    Run Keyword If  ${fault_10_status}  Log  Expected fault 10 for RMOD-${TESTED_RMOD_SN} appeared.  console=${TRUE}
    ${recovery_status}=  Run Keyword And Return Status  Should Be True  ${fault_1815_primary_link_status} or ${fault_10_status}
    Run Keyword If  ${recovery_status}  Log  Expected Recovery Radio Reset Performed  console=${TRUE}
    Run Keyword If  not ${recovery_status}  Run Keyword And Continue On Failure
    ...  Fail  Expected fault 1815 for ${PRIMARY_CABLINK_DN_BEFORE_LONG} or fault 10 for RMOD-${TESTED_RMOD_SN} NOT appeared!!! test failed.

Checking Acceptable Alarms After Short Link Break
    ${fault_1815_primary_link_status}  Run Keyword And Return Status  Assert Alarm Active  timeout=10  connection=${BTS_ID}
    ...  faultId=1815, severity=Major, alarmingResource=${PRIMARY_CABLINK_DN_BEFORE_SHORT}
    ${fault_10_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  timeout=10s  connection=${BTS_ID}
    ${recovery_status}=  Run Keyword And Return Status  Should Be True  ${fault_1815_primary_link_status} or ${fault_10_status}
    Run Keyword If  ${recovery_status}  Log  Expected Recovery Radio Reset Performed  console=${TRUE}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  6min  3min  Verify Multi BTS State  timeout=10

Checking Historical Alarm After Primary Short Break
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Run Keyword If  ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=10, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    Run Keyword If  ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=4590, severity=Warning, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    Run Keyword If  ${CB007447_ACTIVE}  Add Allowed Alarm  faultId=1815, severity=Major  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking Historical Alarm After Primary Long Break CB007437
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Add Allowed Alarm  faultId=1815, severity=Major  connection=${BTS_ID}
    Add Allowed Alarm  faultId=10, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking Historical Alarm After Primary Long Break CB007447
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Add Allowed Alarm  faultId=10, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    Add Allowed Alarm  faultId=4590, severity=Warning, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking availabilityStatus In Infomodel After Primary Link Break
    [Arguments]  ${im_log_path}
    ${affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${TESTED_CELL_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${affected_cells_status}  FAIL
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_affected_cells_status}
    ...  Log  Affected Cells don't changed availabilityStatus after primary link break.  console=${TRUE}
    ${not_affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${NOT_AFFECTED_CELLS_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_not_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${not_affected_cells_status}  PASS
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_not_affected_cells_status}
    ...  Fail  FAIL!!! Not affected Cells changed availabilityStatus after primary link break.

Collecting And Checking Counters For Primary Link Break CB007447
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
      ${short_counter_status}  Run Keyword And Return Status  Should Be True  ${REPETITION_LIST[-1]} <= 3*${short_counter}
      ${long_counter_status}  Run Keyword And Return Status  Should Be True  ${REPETITION_LIST[-1]} <= 3*${long_counter}
      Run Keyword If  ${short_counter_status}
      ...  Log  Proper counter value -> ${short_counter} of short link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${short_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${short_counter} of short link break for ${sfp}
      Run Keyword If  ${long_counter_status}  Log  Proper counter value -> ${long_counter} of long link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${long_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${long_counter} of long link break for ${sfp}
    END

Recovery For Primary Link Break
    Run Keyword And Ignore Error  Collect Snapshot  target_file_name=${cfg['test_logs_path']}/Snapshot.zip  connection=${BTS_ID}
    Run Keyword And Ignore Error  Reset Site  alias=${BTS_ID}
    Run Keyword And Ignore Error  Verify BTS State  ${BTS_ID}
