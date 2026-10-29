*** Settings ***
Documentation  Maintainers: przemyslaw.kempa@nokia.com

Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
Resource    resources/ca_BSRF_general.robot
#Resource    ../SiSo_L3_Call.robot


*** Variables ***
${SISO_L3_CALL}            False
${COUNTER_CHECK}           True

*** Keywords ***
TC_SiSo_SM_RU_Primary_link_break_in_chaining
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-19083
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check correctness of CPRI link interruption handling between BBU and RU
    ...  or between RU and RU in chaining when recovery function is activated and Classical BTS is used in dedicated
    ...  operation mode. RU is connected with duallink BTS working in dedicated mode (4G or 5G) with CPRI RU in CB007437 and all RATs in CB007447.
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
    ...  message=TC_SiSo_SM_RU_Primary_link_break_in_chaining will be executed
    ...  style=ONGOING
    Precondition. Primary Link Break In Chaining
    FOR  ${rep_index}  IN  @{REPETITION_LIST}
      Step 1. Perform Primary Short Link Break In Chaining  ${rep_index}
      Step 2. Checking Expected States After Primary Short Link Break In Chaining  ${rep_index}
      Step 3. Perform Primary Long Link Break In Chaining  ${rep_index}
      Step 4. Checking Expected States After Primary Long Link Break In Chaining  ${rep_index}
    END
	Postcondition For Primary Link Break In Chaining
    [Teardown]  Run Keywords
    ...  Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Log  Recovery For Primary Link Break In Chaining  AND
    ...  Run Keyword And Ignore Error  Verify BTS State  ${BTS_ID}  AND
    ...  Run Keyword And Ignore Error  Common Test Teardown

Precondition. Primary Link Break In Chaining
    Log  === Precondition. Primary Link Break In Chaining ===  console=${TRUE}
    Preparing Variables To Test Primary Link Break In Chaining
    [Teardown]  Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS

Step 1. Perform Primary Short Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  \n||========================================================  console=True
    Log  \n${TEST NAME} repetition no: ${rep_index} started  console=True
    Log  \n=== Step 1. Perform Primary Short Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/short_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_short_break
    ${short_link_break_duration}=  Evaluate  random.randint(20,0.8*${CPRI_SYNC_BREAK_TIME_VALUE})  random
    ${all_cablinks_before_short}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_before_short}  Create Dictionary
    Set To Dictionary  ${tested_cablink_before_short}  ${TESTED_CABLINK_CFG}=&{all_cablinks_before_short['${TESTED_CABLINK_CFG}']}
    Set Test Variable  ${TESTED_CABLINK_BEFORE_SHORT}  ${tested_cablink_before_short}
    ${primary_cablink_dn}  Get Primary Cablink Runtime Distname  ${TESTED_CABLINK_BEFORE_SHORT}
    Set Test Variable  ${PRIMARY_CABLINK_DN_BEFORE_SHORT}  ${primary_cablink_dn}
    ${switch_ip_port}  Get Port Primary Link Flapping  ${TESTED_CABLINK_BEFORE_SHORT}  ${TESTED_CABLINKS_OS_PORT}
    Run Keyword If  '${switch_ip_port}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${switch_ip_port}  switch_link_break_time=${short_link_break_duration}  AND
    ...  Log  Short link break will last ${short_link_break_duration}ms  console=${TRUE}

Step 2. Checking Expected States After Primary Short Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  \n=== Step 2. Checking Expected States After Primary Short Link Break In Chaining ===  console=${TRUE}
    Run Keyword If  not ${RF_POSSITION_NOT_IN_CHAIN}  Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  10s
    ...  Checking Alarm After Primary Break In Chaining
    Sleep  30s
    Run Keyword If  ${RF_POSSITION_NOT_IN_CHAIN}  Run Keyword And Continue on Failure
    ...  Checking Expected Alarms In Syslog After Link Break  ${TESTED_CABLINK_BEFORE_SHORT}  4721
    Verify Multi BTS State
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Primary Break In Chaining
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}/${rep_index}/short_break_log  ${BTS_ID}
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/short_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Checking availabilityStatus In Infomodel After Primary Link Break In Chaining
    ...  ${cfg['test_logs_path']}/${rep_index}/short_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Step 3. Perform Primary Long Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  \n=== Step 3. Perform Primary Long Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/long_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_long_break
    ${long_link_break_duration}  Evaluate  random.randint(${CPRI_SYNC_BREAK_TIME_VALUE}+2500,${CPRI_SYNC_BREAK_TIME_VALUE}+5000)  random
    ${all_cablinks_before_long}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_before_long}  Create Dictionary
    Set To Dictionary  ${tested_cablink_before_long}  ${TESTED_CABLINK_CFG}=&{all_cablinks_before_long['${TESTED_CABLINK_CFG}']}
    Set Test Variable  ${TESTED_CABLINK_BEFORE_LONG}  ${tested_cablink_before_long}
    ${primary_cablink_dn}  Get Primary Cablink Runtime Distname  ${TESTED_CABLINK_BEFORE_LONG}
    Set Test Variable  ${PRIMARY_CABLINK_DN_BEFORE_LONG}  ${primary_cablink_dn}
    ${secondary_cablink_dn}  Get Secondary Cablink Runtime Distname  ${TESTED_CABLINK_BEFORE_LONG}
    Set Test Variable  ${SECONDARY_CABLINK_DN_BEFORE_LONG}  ${secondary_cablink_dn}
    ${switch_ip_port}  Get Port Primary Link Flapping  ${TESTED_CABLINK_BEFORE_LONG}  ${TESTED_CABLINKS_OS_PORT}
    Run Keyword If  '${switch_ip_port}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${switch_ip_port}  switch_link_break_time=${long_link_break_duration}  AND
    ...  Log  Long link break will last ${long_link_break_duration}ms  console=${TRUE}

Step 4. Checking Expected States After Primary Long Link Break In Chaining
    [Arguments]  ${rep_index}
    Log  \n=== Step 4. Checking Expected States After Primary Long Link Break In Chaining ===  console=${TRUE}
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  5s  Checking Alarm After Primary Break In Chaining
    Sleep  30s
    Verify Multi BTS State
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword If  ${RF_POSSITION_NOT_IN_CHAIN} and ${CB007447_ACTIVE}  Run Keyword And Continue on Failure
    ...  Checking Expected Alarms In Syslog After Link Break  ${TESTED_CABLINK_BEFORE_LONG}  4760
    Run Keyword And Continue On Failure  Run Keyword If  ${CB007447_ACTIVE}  Checking Historical Alarm After Primary Long Break In Chaining CB007447
    ...  ELSE  Checking Historical Alarm After Primary Long Break In Chaining CB007437
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For All Cells  ${cfg['test_logs_path']}/${rep_index}/long_break_log  ${BTS_ID}
    ...  ELSE  Log To Console  L3 Call skipped  console=True
    Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/long_break_log  status=PASS
    Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}
    Checking availabilityStatus In Infomodel After Primary Link Break In Chaining
    ...  ${cfg['test_logs_path']}/${rep_index}/long_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Postcondition For Primary Link Break In Chaining
    Log  === Postcondition For Primary Link Break In Chaining ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}  tools_to_setup=IM_ADMIN
    Verify Alarms On All Nodes
    Run Keyword If  ${CB007447_ACTIVE} and ${COUNTER_CHECK} and ${RF_POSSITION_NOT_IN_CHAIN}
    ...  Collecting And Checking Counters For Primary Link Break In Chaining CB007447

Preparing Variables To Test Primary Link Break In Chaining
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
    ${randomised_cablink}  Evaluate  __import__("random").choice(@{TESTED_CABLINKS_OS_PORT.keys()})
    Set Test Variable  ${TESTED_CABLINK_CFG}  ${randomised_cablink}
    Log  ${TESTED_CABLINK_CFG} was selected from the set @{TESTED_CABLINKS_OS_PORT.keys()} as the link to be tested  console=yes
    ${all_cells_distname}  Create All Cells Distname
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}
    Preparing Afected And Not Affected List Of Cells And Rmods
    Run Keyword If  ${CB007447_ACTIVE} and ${COUNTER_CHECK} and ${RF_POSSITION_NOT_IN_CHAIN}
    ...  Preparing Counters Variables For Primary Link Break CB007447 In Chaining

Preparing Afected And Not Affected List Of Cells And Rmods
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    ${cablinks_with_affected_cells_dict}  Create Cablinks Dictionary With Affected Cells Lists
    ${tested_cablink}  Get From Dictionary  ${all_cablinks}  ${TESTED_CABLINK_CFG}
    ${tested_rmod_dn}  Get From Dictionary  ${tested_cablink}  rmod
    Set Test Variable  ${TESTED_RMOD_DN}  ${tested_rmod_dn}
    ${tested_cablink_internal_dn}  Get From Dictionary  ${tested_cablink}  internal
    Set Test Variable  ${TESTED_CABLINK_INTERNAL_DN}  ${tested_cablink_internal_dn}
    ${tested_radio_parameters}  admin.Get Parameters For  RMOD  ${tested_rmod_dn}  connection=${BTS_ID}
    ${tested_rmod_sn}  Get From Dictionary  ${tested_radio_parameters}  serialNumber
    ${affected_rmods_sn}  Get From Dictionary  ${cfg['RF_INFO']['${tested_rmod_sn}']}  scf_chain_fr_affected_list
    ${condition1}=  Set Variable  contains(@class, 'CABLINK') and not(contains(@class, '_R'))
    ${condition2}=  Set Variable  (p[@name='secondEndpointDN']='${cfg['RF_INFO']['${tested_rmod_sn}']['scf_dist_name_primary']}')
    ${ru_first_end_points}=  Evaluate Xpath
    ...  ${cfg.NODES['${BTS_ID}']['parsed_scf']}
    ...  .//managedObject[${condition1} and ${condition2}]/p[@name='firstEndpointDN']/text()
    ${rf_possition_not_in_chain}=  Set Variable If  "RMOD" not in "${ru_first_end_points}"  ${TRUE}  ${FALSE}
    Set Test Variable  ${RF_POSSITION_NOT_IN_CHAIN}  ${rf_possition_not_in_chain}
    ${tested_cell_dn}  Get From Dictionary  ${cablinks_with_affected_cells_dict}  ${TESTED_CABLINK_INTERNAL_DN}
    ${cells_on_tested_rmod}  Get DN Cells List From RMOD  ${tested_rmod_dn}
    Run Keyword If  not ${RF_POSSITION_NOT_IN_CHAIN}  Run Keywords
    ...  Append To List  ${affected_rmods_sn}  ${tested_rmod_sn}  AND
    ...  Set Test Variable  ${AFFECTED_RMODS_SN}  ${affected_rmods_sn}  AND
    ...  Set Test Variable  ${TESTED_CELL_DN}  ${tested_cell_dn}  AND
    ...  Set Test Variable  ${NOT_AFFECTED_CELLS}  ${ALL_CELLS_DISTNAME}  AND
    ...  Remove Values From List  ${NOT_AFFECTED_CELLS}  @{TESTED_CELL_DN}  AND
    ...  Log List  ${NOT_AFFECTED_CELLS}
    Run Keyword If  ${RF_POSSITION_NOT_IN_CHAIN}  Run Keywords
    ...  Set Test Variable  ${AFFECTED_RMODS_SN}  ${affected_rmods_sn}  AND
    ...  Set Test Variable  ${TESTED_RMOD_SN}  ${tested_rmod_sn}  AND
    ...  Set Test Variable  ${TESTED_CELL_DN}  ${tested_cell_dn}  AND
    ...  Set Test Variable  ${NOT_AFFECTED_CELLS}  ${ALL_CELLS_DISTNAME}  AND
    ...  Remove Values From List  ${NOT_AFFECTED_CELLS}  @{TESTED_CELL_DN}  AND
    ...  Remove Values From List  ${TESTED_CELL_DN}  @{cells_on_tested_rmod}  AND
    ...  Set Test Variable  ${CELLS_ON_TESTED_RMOD}  ${cells_on_tested_rmod}

Preparing Counters Variables For Primary Link Break CB007447 In Chaining
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

Get DN Cells List From RMOD
    [Arguments]  ${rmod_dn}
    ${nr_cells}  Get Cells Mapping By RMOD Id  NR  ${rmod_dn}  alias=${BTS_ID}
    ${lte_cells}  Get Cells Mapping By RMOD Id  LTE  ${rmod_dn}  alias=${BTS_ID}
    ${wcdma_cells}  Get Cells Mapping By RMOD Id  WCDMA  ${rmod_dn}  alias=${BTS_ID}
    ${gsm_cells}  Get Cells Mapping By RMOD Id  GSM  ${rmod_dn}  alias=${BTS_ID}
    ${cells_dn_list}  Create List  @{nr_cells}  @{lte_cells}  @{wcdma_cells}  @{gsm_cells}
    [Return]  @{cells_dn_list}

Checking Alarm After Primary Break In Chaining
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    FOR  ${rmod}  IN  @{AFFECTED_RMODS_SN}
      ${alarm_unexpected_status}  Run Keyword And Return Status  Assert Alarm Active
      ...  faultId=10, severity=Critical, serialNo=${rmod}  timeout=1s  connection=${BTS_ID}
      Run Keyword If  ${alarm_unexpected_status}  Log To Console  Expected Faults 10 For RMOD-${rmod} Visible
      Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Expected Faults 10 For RMOD-${rmod} NOT Visible
      Run Keyword If  not ${alarm_unexpected_status}  Fail  Expected Faults 10 For RMOD-${rmod} NOT Visible
    END

Checking Historical Alarm After Primary Break In Chaining
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    FOR  ${rmod}  IN  @{AFFECTED_RMODS_SN}
      Add Allowed Alarm  faultId=10, severity=Critical, serialNo=${rmod}  connection=${BTS_ID}
    END
    Run Keyword If  ${RF_POSSITION_NOT_IN_CHAIN}  Add Allowed Alarm  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}
    ...  connection=${BTS_ID}
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking availabilityStatus In Infomodel After Primary Link Break In Chaining
    [Arguments]  ${im_log_path}
    ${affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${TESTED_CELL_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${affected_cells_status}  FAIL
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_affected_cells_status}
    ...  Log  Affected Cells don't changed availabilityStatus after primary link break.  console=${TRUE}
    ${not_affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${NOT_AFFECTED_CELLS}
    ...  ims2_log_path=${im_log_path}
    ${final_not_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${not_affected_cells_status}  PASS
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_not_affected_cells_status}
    ...  Fail  FAIL!!! Not affected Cells changed availabilityStatus after primary link break.

Collecting And Checking Counters For Primary Link Break In Chaining CB007447
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
      ${short_counter_status}  Run Keyword And Return Status  Should Be True  ${REPETITION_LIST[-1]} <= ${short_counter} <= 3*${REPETITION_LIST[-1]}
      ${long_counter_status}  Run Keyword And Return Status  Should Be True  ${REPETITION_LIST[-1]} <= ${long_counter} <= 3*${REPETITION_LIST[-1]}
      Run Keyword If  ${short_counter_status}
      ...  Log  Proper counter value -> ${short_counter} of short link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${short_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${short_counter} of short link break for ${sfp}
      Run Keyword If  ${long_counter_status}  Log  Proper counter value -> ${long_counter} of long link break for ${sfp_dn}  console=${TRUE}
      Run Keyword If  not ${long_counter_status}  Run Keyword And Continue On Failure
      ...  FAIL  WRONG counter value -> ${long_counter} of long link break for ${sfp}
    END

Checking Historical Alarm After Primary Long Break In Chaining CB007437
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Add Allowed Alarm  faultId=1815, severity=Major  connection=${BTS_ID}
    FOR  ${rmod_sn}  IN  ${AFFECTED_RMODS_SN}
      Add Allowed Alarm  faultId=10, serialNo=${rmod_sn}  connection=${BTS_ID}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking Historical Alarm After Primary Long Break In Chaining CB007447
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    FOR  ${rmod_sn}  IN  ${AFFECTED_RMODS_SN}
      Add Allowed Alarm  faultId=10, serialNo=${rmod_sn}  connection=${BTS_ID}
      Add Allowed Alarm  faultId=4590, severity=Warning, serialNo=${rmod_sn}  connection=${BTS_ID}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Historical Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Recovery For Primary Link Break In Chaining
    Run Keyword And Ignore Error  Collect Snapshot  target_file_name=${cfg['test_logs_path']}/Snapshot.zip  connection=${BTS_ID}
    Run Keyword And Ignore Error  Reset Site  alias=${BTS_ID}
    Run Keyword And Ignore Error  Verify Multi BTS State
