*** Settings ***
Documentation
  ...  AUTHOR-przemyslaw.kempa@nokia.com  MAINTAINER-przemyslaw.kempa@nokia.com
  ...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this test case is to check correctness of CPRI link interruption handling between BBU and RU when recovery function
  ...  is NOT activated and Classical BTS is used in dedicated operation mode.
  ...  To perform short link breaks test support optical switch Calient S320 (using TL1 commands)
  ...  CPRI Link Recovery activated: 'actCpriLinkRecovery' is set as FALSE state
  ...  The NIDD parameter 'cpriSyncBreakTime' is locked to its default value (200 ms) by BTS-system in CB007437 and is modiable in CB007447
  ...  Time of short link break is generated randomly with boundaries 20ms and cpriSyncBreakTime
  ...  Time of long link break is generated randomly with boundaries cpriSyncBreakTime+2500ms and cpriSyncBreakTime+5000ms
  ...  Mandatory variable in testsuite add as Set Test Variable
  ...  e.g.
  ...  TESTED_CABLINKS_OS_PORT=&{tested_cablinks}
  ...
  ...  &{tested_cablinks}=   CABLINK-4=10.42.201.14_4.4.1  CABLINK-5=10.42.201.14_4.4.3
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
  ...
Resource    ../tc_scenarios.robot
Resource    resources/ca_Recovery_link_break.robot
Resource    resources/ca_BSRF_general.robot
#Resource    ../SiSo_L3_Call.robot


*** Variables ***
${SISO_L3_CALL}  False

*** Keywords ***
TC_SiSo_SM_RU_Primary_link_break_without_recovery
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28801
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check correctness of CPRI link interruption handling between BBU and RU when recovery function
    ...  is NOT activated and Classical BTS is used in dedicated operation mode.
    ...  To perform short link breaks test support optical switch Calient S320 (using TL1 commands)
    ...  CPRI Link Recovery activated: 'actCpriLinkRecovery' is set as FALSE state
    ...  The NIDD parameter 'cpriSyncBreakTime' is locked to its default value (200 ms) by BTS-system in CB007437 and is modiable in CB007447
    ...  Time of short link break is generated randomly with boundaries 20ms and cpriSyncBreakTime
    ...  Time of long link break is generated randomly with boundaries cpriSyncBreakTime+2500ms and cpriSyncBreakTime+5000ms
    ...  Mandatory variable in testsuite add as Set Test Variable
    ...  e.g.
    ...  TESTED_CABLINKS_OS_PORT=&{tested_cablinks}
    ...
    ...  &{tested_cablinks}=   CABLINK-4=10.42.201.14_4.4.1  CABLINK-5=10.42.201.14_4.4.3
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
    ...		    GROUP_IN_CHARGE- MN RAN Pz 4 WRO 8     PHASE-CRT  FEATURE-CB007437    FEATURE-CB007447
    Common Test Setup  tools_to_setup=ADMIN
    Logging With Timestamp
    ...  message=TC_SiSo_SM_RU_Primary_link_break_without_recovery will be executed
    ...  style=ONGOING
    Precondition For Primary Link Break Without Recovery
    FOR  ${rep_index}  IN  @{REPETITION_LIST}
      Step 1. Perform Primary Short Link Break Without Recovery  ${rep_index}
      Step 2. Checking Expected States After Primary Short Link Break Without Recovery  ${rep_index}
      Step 3. Perform Primary Long Link Break Without Recovery  ${rep_index}
      Step 4. Checking Expected States After Primary Long Link Break Without Recovery  ${rep_index}
    END
    [Teardown]  Recovery For Primary Link Break Without Recovery


Precondition For Primary Link Break Without Recovery
    Log  === Precondition For Primary Link Break Without Recovery ===  console=${TRUE}
    Prepering Variables To Primary Link Break Without Recovery
    [Teardown]  Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS

Step 1. Perform Primary Short Link Break Without Recovery
    [Arguments]  ${rep_index}
    Log  \n||========================================================  console=${TRUE}
    Log  \n${TEST NAME} repetition no: ${rep_index} started  console=${TRUE}
    Log  \n=== Step 1. Perform Primary Short Link Break Without Recovery ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/short_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_short_break
    ${short_link_break_duration}  Evaluate  random.randint(20,${CPRI_SYNC_BREAK_TIME_VALUE})  random
    Set Test Variable  ${SHORT_LINK_BREAK_DURATION}  ${short_link_break_duration}
    ${all_cablinks_before_short}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_before_short}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink_before_short}  ${cablink_cfg}=&{all_cablinks_before_short['${cablink_cfg}']}
    END
    Set Test Variable  ${TESTED_CABLINK_BEFORE_SHORT}  ${tested_cablink_before_short}
    ${primary_cablink_dn}  Get Primary Cablink Runtime Distname  ${TESTED_CABLINK_BEFORE_SHORT}
    Set Test Variable  ${PRIMARY_CABLINK_DN_BEFORE_SHORT}  ${primary_cablink_dn}
    ${switch_ip_port}  Get Port Primary Link Flapping  ${TESTED_CABLINK_BEFORE_SHORT}  ${TESTED_CABLINKS_OS_PORT}
    Run Keyword If  '${switch_ip_port}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${switch_ip_port}  switch_link_break_time=${short_link_break_duration}  AND
    ...  Log  Short link break will last ${short_link_break_duration}ms  console=${TRUE}

Step 2. Checking Expected States After Primary Short Link Break Without Recovery
    [Arguments]  ${rep_index}
    Log  === Step 2. Checking Expected States After Primary Short Link Break Without Recovery ===  console=${TRUE}
    Run Keyword And Continue On Failure  Checking Expected Alarms For Short Link Break Without Recovery
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  6min  3min  Verify Multi BTS State  timeout=10
    Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Primary Break Without Recovery
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${TESTED_CELL_DN}  ${cfg['test_logs_path']}/${rep_index}/short_break_log
    ...  ELSE  Log  L3 Call skipped  console=${TRUE}
    [Teardown]  Run Keywords
    ...  Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/short_break_log  status=${KEYWORD STATUS}  AND
    ...  Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  AND
    ...  Checking availabilityStatus In Infomodel After Primary Link Break Without Recovery
    ...  ${cfg['test_logs_path']}/${rep_index}/short_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Step 3. Perform Primary Long Link Break Without Recovery
    [Arguments]  ${rep_index}
    Log  === Step 3. Perform Primary Long Link Break Without Recovery ===  console=${TRUE}
    Logging Multinode Start  ${cfg['test_logs_path']}/${rep_index}/long_break_log  tools_to_setup=IM_ADMIN
    Start Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  ${rep_index}_long_break
    ${long_link_break_duration}=  Evaluate  random.randint(20000,30000)  random
    ${all_cablinks_before_long}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_before_long}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink_before_long}  ${cablink_cfg}=&{all_cablinks_before_long['${cablink_cfg}']}
    END
    Set Test Variable  ${TESTED_CABLINK_BEFORE_LONG}  ${tested_cablink_before_long}
    ${primary_cablink_dn}  Get Primary Cablink Runtime Distname  ${TESTED_CABLINK_BEFORE_LONG}
    Set Test Variable  ${PRIMARY_CABLINK_DN_BEFORE_LONG}  ${primary_cablink_dn}
    ${switch_ip_port}  Get Port Primary Link Flapping  ${TESTED_CABLINK_BEFORE_LONG}  ${TESTED_CABLINKS_OS_PORT}
    Run Keyword If  '${switch_ip_port}'!='${EMPTY}'  Run Keywords
    ...  Set Optical Switch And Perform Break Link  switch_ip_port=${switch_ip_port}  switch_link_break_time=${long_link_break_duration}  AND
    ...  Log  Long link break will last ${long_link_break_duration}ms  console=${TRUE}

Step 4. Checking Expected States After Primary Long Link Break Without Recovery
    [Arguments]  ${rep_index}
    Log  === Step 4. Checking Expected States After Primary Long Link Break Without Recovery ===  console=${TRUE}
    Run Keyword And Continue On Failure  Checking Expected Alarms For Long Link Break Without Recovery
    Run Keyword And Continue On Failure  Wait Until Keyword Succeeds  6min  3min  Verify Multi BTS State  timeout=10
    Wait Until Keyword Succeeds  2min  15s  Checking Active Alarms  alias=${BTS_ID}
    Run Keyword And Continue On Failure  Checking Historical Alarm After Primary Break Without Recovery
    Run Keyword If  ${SISO_L3_CALL}  Perform L3 Call For Provided Cells  ${TESTED_CELL_DN}  ${cfg['test_logs_path']}/${rep_index}/long_break_log
    ...  ELSE  Log  L3 Call skipped  console=${TRUE}
    [Teardown]  Run Keywords
    ...  Logging Multinode Stop  ${cfg['test_logs_path']}/${rep_index}/long_break_log  status=${KEYWORD STATUS}  AND
    ...  Stop Taf Syslog Session  ${BTS_ID}  ${BTS_ID}  AND
    ...  Checking availabilityStatus In Infomodel After Primary Link Break Without Recovery
    ...  ${cfg['test_logs_path']}/${rep_index}/long_break_log/BTSFiles/${BTS_ID}/${BTS_ID}_infomodel.ims2

Prepering Variables To Primary Link Break Without Recovery
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${BTS_ID}
    ${CpriLinkRecovery_activated}  Run Keyword And Return Status
    ...  Should Be True  "${featcadm_parameter[0]['parameters']['actCpriLinkRecovery']}"=="True"
    Set Test Variable  ${CPRILINKRECOVERY_ACTIVATED}  ${CpriLinkRecovery_activated}
    Run Keyword If  ${CPRILINKRECOVERY_ACTIVATED}
    ...  Log  Mandatory parameter actCpriLinkRecovery is activated, needed recommissionig and deactivate.  console=${TRUE}
    ...  ELSE  Log  Parameter actCpriLinkRecovery not activated.  console=${TRUE}
    Run Keyword If  ${CPRILINKRECOVERY_ACTIVATED}  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter=actCpriLinkRecovery
    ...  operation=update
    ...  value=false
    ...  connection=${BTS_ID}
    ${mnlent_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1  connection=${BTS_ID}
    ${cpriSyncBreakTime_value}  Get From Dictionary  ${mnlent_parameter[0]['parameters']}  cpriSyncBreakTime
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
    ${tested_cell_dn}  admin.Get Cell Mapping By Module Id  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    Set Test Variable  ${TESTED_CELL_DN}  ${tested_cell_dn}
    ${not_affected_cells_dn}  Create List  @{ALL_CELLS_DISTNAME}
    Remove Values From List  ${not_affected_cells_dn}  @{TESTED_CELL_DN}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN}  ${not_affected_cells_dn}
    ${1815_severity}  Set Variable If  "WNCEL" in "${TESTED_CELL_DN}"  regex"Minor|Major"  Major
    Set Test Variable  ${1815_SEVERITY}  ${1815_severity}

Checking Expected Alarms For Short Link Break Without Recovery
    ${alarm1815_status}  Run Keyword If  ${SHORT_LINK_BREAK_DURATION}>1700  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=1815, severity=${1815_severity}, treeNotifier=${PRIMARY_CABLINK_DN_BEFORE_SHORT}  timeout=60s  connection=${BTS_ID}
    Run Keyword If  ${alarm1815_status}  Log  Fault 1815 for ${PRIMARY_CABLINK_DN_BEFORE_SHORT} appeared.  console=${TRUE}
    ${alarm10_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  timeout=120s  connection=${BTS_ID}
    Run Keyword If  ${alarm10_status}  Log  Fault 10 for ${TESTED_RMOD_SN} appeared.  console=${TRUE}
    Run Keyword If  not ${alarm10_status}  Fail  Fault 10 for ${TESTED_RMOD_SN} NOT appeared!!! test failed.

Checking Expected Alarms For Long Link Break Without Recovery
    ${alarm1815_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=1815, severity=${1815_severity}, treeNotifier=${PRIMARY_CABLINK_DN_BEFORE_LONG}  timeout=60s  connection=${BTS_ID}
    Run Keyword If  ${alarm1815_status}  Log  Fault 1815 for ${PRIMARY_CABLINK_DN_BEFORE_LONG} appeared.  console=${TRUE}
    Run Keyword If  not ${alarm1815_status}  Log  Fault 1815 for ${PRIMARY_CABLINK_DN_BEFORE_LONG} NOT appeared!!!  console=${TRUE}
    ${alarm10_status}  Run Keyword And Return Status  Assert Alarm Active
    ...  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  timeout=120s  connection=${BTS_ID}
    Run Keyword If  ${alarm10_status}  Log  Fault 10 for ${TESTED_RMOD_SN} appeared.  console=${TRUE}
    Run Keyword If  not ${alarm10_status}  Log  Fault 10 for ${TESTED_RMOD_SN} NOT appeared!!! test failed.  console=${TRUE}
    Run Keyword If  not ${alarm1815_status}  Fail  Fault 1815 for ${PRIMARY_CABLINK_DN_BEFORE_LONG} NOT appeared!!! test failed.
    Run Keyword If  not ${alarm10_status}  Fail  Fault 10 for ${TESTED_RMOD_SN} NOT appeared!!! test failed.

Checking Historical Alarm After Primary Break Without Recovery
    Clear Allowed Alarms List  connection=${BTS_ID}
    FOR  ${alarm}  IN  @{GLO_ADMIN_ALLOWED_ALARMS}
      Add Allowed Alarm  ${alarm}  connection=${BTS_ID}
    END
    Add Allowed Alarm  faultId=10, severity=Critical, serialNo=${TESTED_RMOD_SN}  connection=${BTS_ID}
    FOR  ${cablink}  IN  @{TESTED_CABLINK_BEFORE_SHORT}
      Add Allowed Alarm
      ...  faultId=1815, severity=${1815_severity}, alarmingObjectIds[0].runtime=${TESTED_CABLINK_BEFORE_SHORT['${cablink}']['runtime']}
      ...  connection=${BTS_ID}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Historical Alarms  connection=${BTS_ID}
    Run Keyword If  ${alarm_unexpected_status}  Log  No Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Log  Unexpected Historical Alarms Visible  console=${TRUE}
    Run Keyword If  not ${alarm_unexpected_status}  Fail  Unexpected Historical Alarms Visible

Checking availabilityStatus In Infomodel After Primary Link Break Without Recovery
    [Arguments]  ${im_log_path}
    ${affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${TESTED_CELL_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${affected_cells_status}  FAIL
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_affected_cells_status}
    ...  Fail  FAIL!!! Affected Cells don't changed availabilityStatus after link break.
    ${not_affected_cells_status}  Checking If availabilityStatus Change For Provided Cells In ims2  ${NOT_AFFECTED_CELLS_DN}
    ...  ims2_log_path=${im_log_path}
    ${final_not_affected_cells_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${not_affected_cells_status}  PASS
    Run Keyword And Continue On Failure  Run Keyword If  not ${final_not_affected_cells_status}
    ...  Fail  FAIL!!! Not affected Cells changed availabilityStatus after link break.

Recovery For Primary Link Break Without Recovery
    Run Keyword And Ignore Error  Logging Multinode Start  ${cfg['test_logs_path']}  tools_to_setup=IM_ADMIN
    Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keyword And Ignore Error
    ...  Collect Snapshot  target_file_name=${cfg['test_logs_path']}/Snapshot.zip  connection=${BTS_ID}
    Run Keyword If  ${CPRILINKRECOVERY_ACTIVATED}  Run Keyword And Ignore Error  admin.Perform Parameter Recommissioning
    ...  dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...  parameter=actCpriLinkRecovery
    ...  operation=update
    ...  value=true
    ...  connection=${BTS_ID}
    Run Keyword If  "${KEYWORD STATUS}"=="FAIL"  Run Keyword And Ignore Error  Reset Site  alias=${BTS_ID}
    Run Keyword And Ignore Error  Verify BTS State  ${BTS_ID}
    Run Keyword And Ignore Error  Verify Alarms On All Nodes
    Run Keyword And Ignore Error  Logging Multinode Stop  ${cfg['test_logs_path']}  status=PASS
