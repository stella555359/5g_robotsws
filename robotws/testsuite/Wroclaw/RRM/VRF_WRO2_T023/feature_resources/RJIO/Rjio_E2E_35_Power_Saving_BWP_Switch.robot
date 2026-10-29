*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     DateTime
Library     SSHLibrary
Library     ute_ue
Library     taf.ul.alarms_watchdog
Resource    ../../resources/ca_INTER_RAT.robot
Resource    ../../resources/ca_IWK.robot
Resource    ../../resources/attenuator.robot
Resource    resources/UTF_Logs_Collecting_For_BWP.robot


*** Variables ***
${NR_CELL_ID}                                   # ID of tested NR cell with power saving BWP profile
${POWER_SAVING_BWP_ID}                          # ID of BWP profile for power saving
${LOOPS_COUNT}                                  # Number of loops + 1 for steps 1-3
${NR_EXPECTED_DL_TPUT}                          # Expected NR DL tput in Mbps
${ADDITIONAL_UE_CAPABILITY}                     # Additional capability of UE (mainly for differentiating between android and iphone)
${APN_CONTAINS}                  n26wro         # Part of APN name that does not change. Default value: n26wro
${CELL_ALIAS}                                   # Alias set for tested cell in attenuator configuration file
${MAX_UTF_LOGS_DELAY}          300s             # Max time in seconds needed for change of UTF logs collecting status to 'running'
# Default value: 300s
${COUNTER_PERIOD}              5                # Counter collecting interval in minutes


*** Keywords ***
TC__Rjio_E2E_35_Power_Saving_BWP_Switch

    Set Tags    CA-RRM    AUTHOR-monika.ceglarek@nokia.com    MAINTAINER-marcel.behen@nokia.com
    ...         PHASE-CDRT   SW-SBTS24R1    GROUP_IN_CHARGE-Pz_2_WRO_2


    Preconditions
    Step 1: Wait For Next Counter Period
    Looped Steps
    Step 7: Check BTS State


Looped Steps
    FOR  ${loop}  IN RANGE  1  ${LOOPS_COUNT}
        Set Test Variable  ${LOOP}  ${loop}
        Log  \n--- LOOP${LOOP} START ---  console=True
        Step 2: Perform Data Transfer In Cell With UE Power Saving
        Step 3: Stop Data Transfer
        Step 4: Check If Print Appeared In Syslog
        Step 5: Check If Wait For Next Counter Period Is Needed
        Step 6: Collect And Verify Counters
        Log  --- LOOP${LOOP} END ---\n  console=True
    END


Preconditions
    Log  \n==== Preconditions ====  console=True

    Set Test Variable  ${CHECK_IN_TEARDOWN}  True
    Set Test Variable  ${ATTENUATOR_SET}  False
    Set Test Variable  ${PRINTS_EXIST}  False
    Set Test Variable  ${UTF_STARTED}  False
    ${global_nr_cell_id} =  Get NR Global Cell ID From NR Cell ID  ${NR_CELL_ID}
    Set Test Variable  ${NR_CALL_CELL_ID}  ${global_nr_cell_id}
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}
    ${counter_conditions_dict} =  Create Dictionary  M55351C00001===1  M55351C00002===0  M55351C01001===1
    ...  M55351C01002===0
    Set Test Variable  ${COUNTERS_CONDITIONS_DICT}  ${counter_conditions_dict}
    Check If UE Power Saving Is Enabled

    _choose ue type helper
    ${ue_capabilities} =  Create List  NR_LOCKED_POWER_SAVING  ${ADDITIONAL_UE_CAPABILITY}
    Require UE  NR_UE  ${ue_capabilities}
    Set Test Variable  ${ATTENUATOR_SET}  True
    Set Attenuation For All Cells  100%
    Set Attenuation  ${CELL_ALIAS}  ${0}

    Run Keyword If  '${UE_TYPE}' == 'iphone'  Remove Baseband Logs  NR_UE


Check If UE Power Saving Is Enabled
    ${_}  ${scf_gnb} =  Save And Parse SCF  SCF_gNB_changed  alias=gNB
    Log  Checking if NRCELL-${NR_CELL_ID} has actPowerSavingBWP=true...  console=True
    Check Element In SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}  /p[@name='actPowerSavingBWP']
    ...  <p name="actPowerSavingBWP">true</p>  dist_name_substring=True

    Log  Checking if BWP_PROFILE-${POWER_SAVING_BWP_ID} has bwpType=powerSaving...  console=True
    Check Element In SCF  ${scf_gnb}  BWP_PROFILE  BWP_PROFILE-${POWER_SAVING_BWP_ID}  /p[@name='bwpType']
    ...  <p name="bwpType">powerSaving</p>  dist_name_substring=True

    Log  Checking if NRCELL-${NR_CELL_ID} has bwpDN=MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${POWER_SAVING_BWP_ID}...  console=True
    Check If Element Exists In SCF  ${scf_gnb}  NRCELL  NRCELL-${NR_CELL_ID}
    ...  /list[@name='cellBwpList']/item/p[@name='bwpDN'][.='MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-${POWER_SAVING_BWP_ID}']
    ...  dist_name_substring=True


Step ${index}: Check If Wait For Next Counter Period Is Needed
    Log  \n==== Step ${index}: Check If Wait For Next Counter Period Is Needed====  console=True

    ${stop_time} =  Get Time From BTS
    ${difference} =  Subtract Date From Date  ${stop_time}  ${start_time}
    ...  date1_format=%d.%m %H:%M:%S  date2_format=%d.%m %H:%M:%S
    IF  ${difference} > ${NEXT_COUNTER_PERIOD}
        Log  Wait For Next Counter Period is not needed.  console=True
    ELSE
        Step ${index}: Wait For Next Counter Period
    END


Step ${index}: Wait For Next Counter Period
    Log  \n==== Step ${index}: Wait For Next Counter Period ====  console=True

    ${waiting_time} =  Count Measurement Period  ${GNB_OAM_IP}  ${COUNTER_PERIOD}  delta=0
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}

    Log To Console  Wait ${waiting_time}s till new period of counters is started
    Sleep  ${waiting_time}s  reason=Wait till new period of counter is started.


Step 2: Perform Data Transfer In Cell With UE Power Saving
    Log  \n==== Step 2: Perform Data Transfer In Cell With UE Power Saving ====  console=True

    ${start_time} =  Get Time From BTS
    Set Test Variable  ${START_TIME}  ${start_time}
    ${next_counter_period} =  Count Measurement Period  ${GNB_OAM_IP}  ${COUNTER_PERIOD}  delta=0
    ...  user=${tl.gnbs[0].cu.oam_ssh_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_ssh_connection_details.password}
    Set Test Variable  ${NEXT_COUNTER_PERIOD}  ${next_counter_period}

    Run Keyword And Ignore Error  Start Collecting Logs With UTF  cell_id=${NR_CELL_ID}
    ...  bts_id=${NRBTS_ID}
    Prepare UE For Data Transfer  NR_UE  ${NR_CALL_CELL_ID}  connection=gNB  apn=${APN_CONTAINS}  ue_type=${UE_TYPE}
    ...  lte_cell=False
    ${apn} =  Get Full APN Name For UE  ${APN_CONTAINS}  ue_alias=NR_UE
    Log  \nUE attached to cell ${NR_CALL_CELL_ID}.  console=True
    Start Data Transfer  NR_DL  NR_UE  dl  throughput=400 Mbits/sec  duration=1800s
    ...  protocol=udp  packet=1400  parallel_streams=4  buffer=32M  apn=${apn}
    Sleep  30s


Step 3: Stop Data Transfer
    Log  \n==== Step 3: Stop Data Transfer ====  console=True

    Get UE Info  NR_UE  ALL
    Check Data Transfer Is Alive  NR_DL
    ${nr_dl_tput} =  Get Average Throughput  NR_DL
    ${nr_dl_tput} =  Evaluate  ${nr_dl_tput}/1000.0
    Log  \nDL:${nr_dl_tput} Mbps  console=True

    Run Keyword And Continue On Failure  Should Be True  ${nr_dl_tput} >= ${NR_EXPECTED_DL_TPUT}
    ...  msg=DL tput (${nr_dl_tput} Mbps) is lower than expected (${NR_EXPECTED_DL_TPUT} Mbps)
    ${tput_verdict} =  Run Keyword And Return Status  Run Keyword And Continue On Failure  Should Be True
    ...  ${nr_dl_tput} >= ${NR_EXPECTED_DL_TPUT}

    [Teardown]  Run Keywords  Get UE Info  NR_UE  ALL
    ...  AND  Stop Data Transfer  NR_DL
    ...  AND  Sleep  30s
    ...  AND  Detach UE  NR_UE
    ...  AND  Run Keyword If  ${UTF_STARTED}  Run Keyword And Ignore Error  Stop UTF Traces and Download Logs
    ...  trace_id=${TRACE_ID}  bts_id=${NRBTS_ID}  loop=${LOOP}


Collect UTF logs
    Run Keyword And Ignore Error  Start Collecting Logs With UTF  cell_id=${NR_CELL_ID}
    ...  bts_id=${NRBTS_ID}
    Sleep  30s
    Run Keyword If  ${UTF_STARTED}  Run Keyword And Ignore Error  Stop UTF Traces and Download Logs
    ...  trace_id=${TRACE_ID}  bts_id=${NRBTS_ID}  loop=${LOOP}


Step 4: Check If Print Appeared In Syslog
    Log  \n==== Step 4: Check If Print Appeared In Syslog ====  console=True

    ${status}  ${msg} =  Run Keyword And Ignore Error  Analyze Syslog Prints For UE Power Saving
    IF  '${status}' == 'FAIL'
        Log  There was an issue with finding 'switched to bwpType=POWER_SAVING.*' prints in syslog: ${msg}
        ...  console=True  level=WARN
    END


Step 6: Collect And Verify Counters
    Log  \n==== Step 6: Collect And Verify Counters ====  console=True

    Collect And Verify Last Counter Values  ${COUNTERS_CONDITIONS_DICT}  loop=${LOOP}  for_last=5min


Step 7: Check BTS State
    Log  \n==== Step 7: Check BTS State ====  console=True

    _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    Set Test Variable  ${CHECK_IN_TEARDOWN}  False
    taf.ul.alarms_watchdog.Check Detected Alarms


Analyze Syslog Prints For UE Power Saving
    ${syslog_msg} =  Run Keyword And Continue On Failure  syslog.Wait For Message In Syslog File
    ...  regexp=switched to bwpType=POWER_SAVING.*  timeout=10s  alias=gNB

    ${syslog_list} =  Split To Lines  ${syslog_msg}
    ${all_prints} =  Get Length  ${syslog_list}
    Should Be True  ${all_prints} > 0  msg=There were no prints found in syslog.
    Log  Prints containing 'switched to bwpType=POWER_SAVING.*' exist.  console=True

    ${current_line_time} =  Get Regexp Matches  ${syslog_list[-1]}
    ...  ^\\d+:([0-9]{2}\\.[0-9]{2}\\s[0-2][0-9]:[0-5][0-9]:[0-5][0-9]\\.[0-9]{6})  1
    ${current_time} =  Convert Date  ${current_line_time[0]}  date_format=%d.%m %H:%M:%S.%f  result_format=%d.%m %H:%M:%S
    ${difference} =  Subtract Date From Date  ${current_time}  ${START_TIME}
    ...  date1_format=%d.%m %H:%M:%S  date2_format=%d.%m %H:%M:%S
    Should Be True  ${difference} > 0  msg=Found prints are not new. Last found print appeared before data transfer was started.
    Log  Prints verified as new.  console=True


_choose ue type helper
    IF  '${ADDITIONAL_UE_CAPABILITY}' == 'REAL_IPHONE_UE'
        Set Test Variable  ${UE_TYPE}  iphone
    ELSE
        Set Test Variable  ${UE_TYPE}  android
    END


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True  gnb_ignored_alarms=${IGNORED_ALARMS}
    Alarm Watchdog Setup  ${PS_ALLOWED_FAULT_IDS}


TC Teardown
    [Timeout]  30 min
    Log  \n === TC Teardown ===   console=True
    Run Keyword And Ignore Error  Stop Data Transfer  NR_DL
    Detach UE  NR_UE
    Run Keyword If  ${ATTENUATOR_SET}  Set Attenuation For All Cells  100%
    Run Keyword If  '${UE_TYPE}' == 'iphone'  Collect And Save Baseband Logs For Iphone  NR_UE
    Run Keyword If  ${UTF_STARTED}  Run Keyword And Ignore Error  Stop UTF Traces and Download Logs
    ...  trace_id=${TRACE_ID}  bts_id=${NRBTS_ID}  loop=${LOOP}
    Alarm Watchdog Teardown  ${CHECK_IN_TEARDOWN}
    IWK Test Teardown  delta_exists=False  local_enb_connection=False  single_bts=True
