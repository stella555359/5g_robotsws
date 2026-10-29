*** Settings ***
Documentation
...    = Author =
...    aleksandra.chudzik@nokia.com
...    piotr.lukaszewicz@nokia.com
...    = Maintainer =
...    piotr.lukaszewicz@nokia.com
...    = Reviewer =
...    bartosz.betka@nokia.com
...    justyna.durak@nokia.com
...    katarzyna.kadziela@nokia.com
...    lukasz.lechowicz@nokia.com
...    karol.sadowski@nokia.com
...    = Summary =
...    Purpose: Verify if CBSD will keep grant as long as GrantExpireTimer is not expired.


*** Keywords ***
CBRS_CB005900_FeVe_02_CBRS_startup_from_site_reset_when_grant_timer_not_expired
    [Documentation]    Requirement: OM_GEN_SFS_CBRS.386

    ${enb_id}  Set Variable  ${testlines.${testline_id}.enb_id}
    ${pdu_ip}  Set Variable  ${testlines.${testline_id}.pdu_1.ip_addr}
    ${pdu_port}  Set Variable  ${testlines.${testline_id}.pdu_1.port_for_azqc_1}
    ${pdu_type}  Set Variable  ${testlines.${testline_id}.pdu_1.pdu_type}
    ${pdu_version}  Set Variable If  '${pdu_type}'!='APC'  ${testlines.${testline_id}.pdu_1.pdu_version}
    &{expected_alarm_1}  Create Dictionary  fault_id=6823  fault_name=SAS Grant Termination Revocation Failure  severity=Critical
    &{expected_alarm_2}  Create Dictionary  fault_id=6832  fault_name=SAS Server Communication Failure  severity=Critical
    &{expected_alarm_3}  Create Dictionary  fault_id=6825  fault_name=SAS Grant Suspension Failure  severity=Critical
    &{expected_alarm_4}  Create Dictionary  fault_id=4589  fault_name=Unit power reset  severity=Warning
    ${expected_alarms_list}  Create List  ${expected_alarm_1}  ${expected_alarm_2}  ${expected_alarm_3}  ${expected_alarm_4}
    ${expected_alarms_objects}  Create Watchdog Alarm List  ${expected_alarms_list}

    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Check If Cells Are Disabled  ${enb_id}

    Replace Variables In File  ${CURDIR}/Data/cbrs_parameter_update.json  ${OUTPUT_DIR}/cbrs_parameter_update.json  enb_id=${enb_id}

    Replace Variables In File  ${CURDIR}/Data/postcondition.json  ${OUTPUT_DIR}/postcondition.json  enb_id=${enb_id}

    Log To Console  ${\n}Step 1 - all counters expired during site reset
    Enable CBRS Feature On eNB
    ${sas_pid}  ${sas_log}  Start SAS Process  config=${CURDIR}/Data/SAS_Sim_all_timers_expired_during_site_reset.conf
    Wait Until Keyword Succeeds  2x  10s  Required CBSD Status Should Be Reached  expected_status=Registered  enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    Start Watchdog Alarm Detection  expected_alarms=${expected_alarms_objects}
    ${site_reset_start}  Get Time
    #shifted timestamp is needed to avoid collecting CBSD<>SAS communication logged before site reset
    ${shifted_site_reset_start}  Add Time To Date  ${site_reset_start}  00:00:02  exclude_millis=True
    Log To Console  Starting site reset...
    Wait Until Keyword Succeeds  4x  5s  taf.sbts.oam.coam.admin.Reset  alias=RAT_1ST
    Wait For All Cells To Be OnAir
    ${site_reset_end}  Get Time
    ${log_file}  Parse Sas Log File  log_file_name=${sas_log}
    ...  date_start=${shifted_site_reset_start}
    ...  date_stop=${site_reset_end}
    ${log_file}  Convert To String  ${log_file}
    Should Not Contain  ${log_file}  registrationRequest
    Should Contain  ${log_file}  spectrumInquiryRequest
    Should Contain  ${log_file}  grantRequest
    Should Contain  ${log_file}  heartbeatRequest
    Disable CBRS Feature On eNB
    Kill All SAS Processes
    Run  cp -r /home/ute/SASSim/default/SAS_Sim.log ${TEST_LOGS_DIR_PATH}/SAS_Sim_step_1.log
    Wait Until Keyword Succeeds  2x  30s  Required CBSD Status Should Be Reached  expected_status=Unregistered  enb_id=${enb_id}
    Wait Until Keyword Succeeds  2x  60s  Check If Cells Are Disabled  ${enb_id}

    Log To Console  ${\n}Step 2 - grant timer not expired during site reset
    Enable CBRS Feature On eNB
    ${sas_pid}  ${sas_log}   Start SAS Process  config=${CURDIR}/Data/SAS_Sim_grant_timer_not_expired_during_site_reset.conf
    Wait Until Keyword Succeeds  2x  5s  Required CBSD Status Should Be Reached  expected_status=Registered  enb_id=${enb_id}
    Wait For All Cells To Be OnAir
    ${grantId_list_before_reset}  List Values of GrantId For All Cells  enb_id=${enb_id}
    ${site_reset_start}  Get Time
    #shifted timestamp is needed to avoid collecting CBSD<>SAS communication logged before site reset
    ${shifted_site_reset_start}  Add Time To Date  ${site_reset_start}  00:00:02  exclude_millis=True
    Log To Console  Starting site reset...
    Wait Until Keyword Succeeds  4x  5s  taf.sbts.oam.coam.admin.Reset  alias=RAT_1ST
    Power Off Unit Using Pdu  pdu_ip_address=${pdu_ip}  pdu_port_for_unit=${pdu_port}  pdu_version=${pdu_version}  pdu_type=${pdu_type}
    Wait Until Keyword Succeeds  5x  90s  taf.sbts.oam.coam.admin.Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/cbrs_parameter_update.json  connection=RAT_1ST
    Power On Unit Using Pdu  pdu_ip_address=${pdu_ip}  pdu_port_for_unit=${pdu_port}  pdu_version=${pdu_version}  pdu_type=${pdu_type}
    Wait For All Cells To Be OnAir
    ${site_reset_end}  Get Time
    ${log_file}  Parse Sas Log File  log_file_name=${sas_log}
    ...  date_start=${shifted_site_reset_start}
    ...  date_stop=${site_reset_end}
    ${log_file}  Convert To String  ${log_file}
    Should Not Contain  ${log_file}  registrationRequest
    Should Not Contain  ${log_file}  spectrumInquiryRequest
    Should Not Contain  ${log_file}  grantRequest
    Should Contain  ${log_file}  heartbeatRequest
    ${grantId_list_after_reset}  List Values of GrantId For All Cells  enb_id=${enb_id}
    List Should Contain Sub List  ${grantId_list_before_reset}  ${grantId_list_after_reset}
    Run  cp -r /home/ute/SASSim/default/SAS_Sim.log ${TEST_LOGS_DIR_PATH}/SAS_Sim_step_2.log

    [Teardown]  Run Keywords  Get SAS Logs To Logs Dir  alias=default  AND
    ...  Wait Until Keyword Succeeds  5x  90s  Perform Delta Recommissioning
    ...  ${OUTPUT_DIR}/postcondition.json  connection=RAT_1ST  AND
    ...  Disable CBRS Feature On eNB  AND
    ...  Stop Watchdog Alarm Detection And Check For Failures  AND
    ...  Kill All SAS Processes


Power Off Unit Using Pdu
    [Arguments]  ${pdu_ip_address}  ${pdu_port_for_unit}  ${pdu_version}  ${pdu_type}=EPC
    [Documentation]  Power off selected HW device on PDU

    IF  '${pdu_type}'=='APC'
        taf.hw.pdu.Setup Pdu  host=${pdu_ip_address}  model=${pdu_type}
    ELSE
        taf.hw.pdu.Setup Pdu  host=${pdu_ip_address}  model=${pdu_type}  version=${pdu_version}
    END
    taf.hw.pdu.Power On  port=${pdu_port_for_unit}
    ${pdu_status}  Wait Until Keyword Succeeds  3x  10s  Get Port Status  port=${pdu_port_for_unit}
    Should Be Equal  ${pdu_status}  on
    Log To Console  Unit under PDU ${pdu_ip_address} port ${pdu_port_for_unit} has been powered off


Power On Unit Using Pdu
    [Arguments]  ${pdu_ip_address}  ${pdu_port_for_unit}  ${pdu_version}  ${pdu_type}=EPC
    [Documentation]  Power on selected HW device on PDU

    IF  '${pdu_type}'=='APC'
        taf.hw.pdu.Setup Pdu  host=${pdu_ip_address}  model=${pdu_type}
    ELSE
        taf.hw.pdu.Setup Pdu  host=${pdu_ip_address}  model=${pdu_type}  version=${pdu_version}
    END
    taf.hw.pdu.Power Off  port=${pdu_port_for_unit}
    ${pdu_status}  Wait Until Keyword Succeeds  3x  10s  Get Port Status  port=${pdu_port_for_unit}
    Should Be Equal  ${pdu_status}  off
    Log To Console  Unit under PDU ${pdu_ip_address} port ${pdu_port_for_unit} has been powered on
