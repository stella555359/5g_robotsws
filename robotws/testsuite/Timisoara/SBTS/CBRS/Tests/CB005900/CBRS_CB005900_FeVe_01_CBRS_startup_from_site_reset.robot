*** Settings ***
Documentation
...    = Author =
...    marek.kot@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    piotr.lukaszewicz@nokia.com
...    = Summary =
...    Purpose: Verify if eNB restore CBRS persistence storage parameters after
...    reset when grant state is Authorized/Granted/Idle and grantExpireTime is not expired.


*** Keywords ***
CBRS_CB005900_FeVe_01_CBRS_startup_from_site_reset
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.386

    ${enb_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    &{expected_alarm_1}  Create Dictionary  fault_id=6832  fault_name=SAS Server Communication Failure  severity=Critical
    &{expected_alarm_2}  Create Dictionary  fault_id=6829  fault_name=SAS Heartbeat Failure  severity=Critical
    &{expected_alarm_3}  Create Dictionary  fault_id=6825  fault_name=SAS Grant Suspension Failure  severity=Critical
    &{expected_alarm_4}  Create Dictionary  fault_id=6827  fault_name=SAS Spectrum Inquiry Failure  severity=Critical
    ${expected_alarms_list}  Create List  ${expected_alarm_1}  ${expected_alarm_2}  ${expected_alarm_3}  ${expected_alarm_4}
    ${expected_alarms_objects}  Create Watchdog Alarm List  ${expected_alarms_list}

    Kill All SAS Processes
    Check If Cells Are Disabled  ${enb_id}

    Log To Console  ${\n}Step 1
    # Site Reset after grantState=Authorized cbsdState=Register
    # We are excpecting that there are no new grantRequests after site reset
    Enable CBRS Feature On eNB
    ${sas_pid}  ${sas_log}  Start SAS Process  config=${CURDIR}/Data/SAS_Sim_Step_1.conf
    Wait For All Cells To Be OnAir
    Wait Until Keyword Succeeds  2x  10s  Required CBSD Status Should Be Reached  expected_status=Registered  enb_id=${enb_id}
    Start Watchdog Alarm Detection  expected_alarms=${expected_alarms_objects}
    ${site_reset_start}  Get Time
    #shifted timestamp is needed to avoid collecting CBSD<>SAS communication logged before site reset
    ${shifted_site_reset_start}  Add Time To Date  ${site_reset_start}  00:00:02  exclude_millis=True
    Wait Until BTS Is Not Busy  wait_time=120s
    taf.sbts.oam.coam.admin.Reset  alias=RAT_1ST
    Wait For All Cells To Be OnAir
    ${site_reset_end}  Get Time
    ${log_file}  Parse Sas Log File  log_file_name=${sas_log}  date_start=${shifted_site_reset_start}  date_stop=${site_reset_end}
    ${log_file}  Convert To String  ${log_file}
    Should Not Contain  ${log_file}  grantRequest
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Run  cp -r /home/ute/SASSim/default/SAS_Sim.log ${TEST_LOGS_DIR_PATH}/SAS_Sim_step_1.log
    Wait Until Keyword Succeeds  2x  30s  Required CBSD Status Should Be Reached  expected_status=Unregistered  enb_id=${enb_id}
    Wait Until Keyword Succeeds  2x  60s  Check If Cells Are Disabled  ${enb_id}

    Log To Console  ${\n}Step 2
    # Site Reset after grantState=Granted cbsdState=Register
    # We are excpecting that there are no new grantRequests after site reset
    Enable CBRS Feature On eNB
    ${sas_pid}  ${sas_log}  Start SAS Process  config=${CURDIR}/Data/SAS_Sim_Step_2.conf
    Wait Until Keyword Succeeds  2x  5s  Required CBSD Status Should Be Reached  expected_status=Registered  enb_id=${enb_id}
    Wait Until Keyword Succeeds  8x  5s  Required Grant State Should Be Reached  expected_status=Granted  enb_id=${enb_id}
    ${site_reset_start}  Get Time
    #shifted timestamp is needed to avoid collecting CBSD<>SAS communication logged before site reset
    ${shifted_site_reset_start}   Add Time To Date  ${site_reset_start}  00:00:08  exclude_millis=True
    # Site Reset must be done when CBSD is in Granted state (time limit set as force_response_data in SAS_Sim_Step_2.conf)
    Wait Until BTS Is Not Busy  wait_time=120s
    taf.sbts.oam.coam.admin.Reset  alias=RAT_1ST
    Wait For All Cells To Be OnAir
    ${site_reset_end}   Get Time
    ${log_file}   Parse Sas Log File  log_file_name=${sas_log}
    ...  date_start=${shifted_site_reset_start}  date_stop=${site_reset_end}
    ${log_file}  Convert To String  ${log_file}
    Should Not Contain  ${log_file}  grantRequest
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Run    cp -r /home/ute/SASSim/default/SAS_Sim.log ${TEST_LOGS_DIR_PATH}/SAS_Sim_step_2.log
    Wait Until Keyword Succeeds  2x  30s  Required CBSD Status Should Be Reached  expected_status=Unregistered  enb_id=${enb_id}
    Wait Until Keyword Succeeds  2x  60s  Check If Cells Are Disabled  ${enb_id}

    Log To Console  ${\n}Step 3
    # Site Reset after grantState=Idle cbsdState=Register
    # We are excpecting that there are no new registrationRequest after site reset
    Enable CBRS Feature On eNB
    ${sas_pid}  ${sas_log}  Start SAS Process  config=${CURDIR}/Data/SAS_Sim_Step_3.conf
    Wait Until Keyword Succeeds  2x  5s  Required CBSD Status Should Be Reached  expected_status=Registered  enb_id=${enb_id}
    Wait Until Keyword Succeeds  8x  5s  Required Grant State Should Be Reached  expected_status=Idle  enb_id=${enb_id}
    ${site_reset_start}  Get Time
    #shifted timestamp is needed to avoid collecting CBSD<>SAS communication logged before site reset
    ${shifted_site_reset_start}  Add Time To Date  ${site_reset_start}  00:00:08  exclude_millis=True
    # Site Reset must be done when CBSD is in Idle state (time limit set as force_response_data in SAS_Sim_Step_3.conf)
    Wait Until BTS Is Not Busy  wait_time=120s
    taf.sbts.oam.coam.admin.Reset  alias=RAT_1ST
    Wait For All Cells To Be OnAir
    ${site_reset_end}  Get Time
    ${log_file}   Parse Sas Log File  log_file_name=${sas_log}
    ...  date_start=${shifted_site_reset_start}
    ...  date_stop=${site_reset_end}
    ${log_file}  Convert To String  ${log_file}
    Should Not Contain  ${log_file}  registrationRequest
    Run  cp -r /home/ute/SASSim/default/SAS_Sim.log ${TEST_LOGS_DIR_PATH}/SAS_Sim_step_3.log

    [Teardown]  Run Keywords  Get SAS Logs To Logs Dir  alias=default  AND
    ...  Disable CBRS Feature On eNB  AND
    ...  Stop Watchdog Alarm Detection And Check For Failures  AND
    ...  Kill All SAS Processes


Required Grant State Should Be Reached
    [Arguments]  ${expected_status}  ${enb_id}  ${alias}=RAT_1ST
    [Timeout]  120s

    ${status}  ute_admin_infomodel.Query Infomodel  timeout=120s  alias=${alias}
    ...  query=/MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-${enb_id}/LNCEL_R-*/CBSDCEL_R-* is [grantOperationState=${expected_status}]
    Log To Console  Is status reached: ${status}

    RETURN    ${status}
