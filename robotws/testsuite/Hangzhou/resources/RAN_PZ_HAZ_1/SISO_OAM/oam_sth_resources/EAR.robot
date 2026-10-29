*** Settings ***
Documentation     [PURPOSE] General keywords for EAR case setup teardown
Resource          hran_frame_sbts.robot
Resource          Mrat_resource_new.robot
Resource          Convert_variables.robot
Library           lib/verdict.py
*** Variables ***
${has_passed}    ${FALSE}
*** Keyword ***
Iteration Precondition
    [arguments]    ${x}
    Iteration Test Create dirs for logs    ${x}
    Run keyword and ignore error    Stop Watching Alarms
    Run keyword and ignore error    Teardown infomodel    #
    Run keyword And ignore error    Collect syslog
    Run Keyword And ignore error    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    Start Admin    bts_host=${SMOD1['TRS_IP']}
    Run Keyword And Continue On Failure    Start Infomodel
    Run Keyword And Continue On Failure    Start syslog   smod=SMOD1
    Run Keyword And Continue On Failure    Start syslog   smod=SMOD2  host_ip=${PC_IP2}
    Run keyword and ignore error    Setup Test Line Watchdog
    Log    End of iteration ${x} Setup    level=INFO    console=${TRUE}

Iteration Test Create dirs for logs
    [arguments]    ${x}
    Create 'loop${x}' in '${Test Results Dir}' And Set Test Variable
    Create 'BTSFiles' in '${loop${x}}' And Set Test Variable
    Create 'TestFiles' in '${loop${x}}' And Set Test Variable
    Create 'UDPLogs' in '${loop${x}}' And Set Test Variable
    Create 'Snapshot' in '${loop${x}}' And Set Test Variable

Iteration Postcondition
    [arguments]    ${x}    ${collect_snapshot}=${COLLECT_SNAPSHOT_FLAG}
    ${collect_snapshot}=    Set Variable If    '${COLLECT_SNAPSHOT_FLAG}' != 'failed_verdict'
    ...  ${COLLECT_SNAPSHOT_FLAG}    ${collect_snapshot}
    Log    Iteration ${x} Postcondition    level=INFO    console=${TRUE}
    Run Keyword If    '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...  Set Test Blocked
    ...  Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state
    Log verdict messages
    ${test_verdict}=    Get test verdict
    ${collect_snapshot_condition_1}=    Evaluate
    ...  '${collect_snapshot}'=='always' and '${test_verdict}'!='norun'

    ${snapshot_condition_3}=       Evaluate
    ...  ('${test_verdict}'=='failed') or ('${test_verdict}'=='blocked')
    ${collect_snapshot_condition_2}=        Evaluate
    ...  '${collect_snapshot}'=='failed_verdict' and ${snapshot_condition_3}
    ${snapshot_condition_4}=        Evaluate
    ...  ${snapshot_condition_3} or '${test_verdict}'=='passed_with_restriction'
    ${snapshot_condition_5}=         Evaluate
    ...  '${collect_snapshot}'=='passed_with_restriction' and ${snapshot_condition_4}
    ${snap_con_6}    set variable if    ${x}==1    ${TRUE}    ${FALSE}
    ${snapshot_condition_total}=      Evaluate
    ...  ${collect_snapshot_condition_1} or ${collect_snapshot_condition_2} or ${snapshot_condition_5} or ${snap_con_6}
    set test variable  ${snapshot_condition_total}

    Run keyword if    ${DSC}    Remote Test Line Teardown    alias=DSC    verify_states_stability=${True}
    FOR    ${remote_line_alias}    IN    @{REMOTE_TESTLINES_LIST}
        Remote Test Line Teardown    alias=${remote_line_alias}
    END
    #Run Keyword If    ${infomodel_started}    Collect Infomodel
    Run Keyword If    ${admin_started}
    ...  Admin Print Active Alarms    output_file=${Test Results Dir}/teardown_active_alarms.json
    ${res}    ${unexpected_alarms}    Run keyword and ignore error    watchalarm.get detected alarms
    ${empty_list}=   Create List
    ${watch_alarm_not_started}=     Run keyword And Return Status
    ...     Should Contain  ${unexpected_alarms}    WatchdogNotStarted
    ${unexpected_alarms}=   Set Variable If     ${watch_alarm_not_started}==${TRUE}
    ...     ${empty_list}   ${unexpected_alarms}
    set test variable    ${4352_exists}    FALSE
    FOR   ${item}    IN    @{unexpected_alarms}
    Run keyword if    '4352' in str("""${item}""")
    ...    Run keywords
    ...    set test variable    ${4352_exists}    TRUE
    ...    AND    Exit For LOOP
    END
    set test variable    ${6450_exists}    FALSE
    FOR   ${item}    IN    @{unexpected_alarms}
    Run keyword if    '6450' in str("""${item}""")
    ...    Run keywords
    ...    set test variable    ${6450_exists}    TRUE
    ...    AND    Exit For LOOP
    END
    ${num_unexp_alarm}    get length    ${unexpected_alarms}
    set test variable  ${num_unexp_alarm}
    set test variable  ${res}
    set test variable  ${unexpected_alarms}
    Run keyword and ignore error    Stop Watching Alarms
    Teardown All Aliases For Infomodel  imstimeout=300
    Run Keyword If      'DCAP' not in @{TEST TAGS}     Collect Syslog
    Run keyword If    ${scf_parser_started}    Teardown scf Parser
    Collect Swconfigs
    Collect RawAlarmHistory
    #Change parameter to enable Netact snapshot collection
    Log    Move directory ssh_forwarder_log to ${BTS Files}
    Run Keyword And Ignore Error    Move Directory    ${EXECDIR}/ssh_forwarder_log    ${BTS Files}
    hran_general.Hran_ta Postconditions
    Align Verdicts
    Run keyword and ignore error    interface.Common step trigger
    Get_QCID
    ${QCID_NUM}  fetch from right  ${QC_ID}  _
    Run keyword if  'passed' in '${TEST VERDICT}'
    ...  Run keyword and ignore error
    ...  Send ReP With Scf Id  ${QCID_NUM}  bts_id=${TESTLINE_NAME}  sw=${ENB_Trunk_Version}
    ${status}  ${SCF_ID}=    Run keyword and ignore error    wait until keyword succeeds
    ...  5min     5s      Get Configuration Id From Scout
    Run keyword If       ${dcap_started}==${TRUE}             Run Keywords
    ...    Stop trace by Dcap      ${SMOD2_exists}     ${dcap_status}
    ...     AND     Sleep     15s
    ...     AND     getsyslog_from_result      ${loop${x}}/
    Run keyword if     '${target_release}'=='SBTS00' or '${target_release}'=='SBTS00_FSM3'
    ...     detect and collect crash
    ...     ELSE IF     ${snapshot_condition_total} == True     Run keywords    Admin Get Snapshot
    ...     AND    Run keyword if    '${SMOD2_exists}' == 'True' and '${4352_exists}' == 'TRUE'    Admin Get Snapshot for ESM
    Remove log if not the first pass     ${X}
    taf.sbts.oam.coam.admin.Teardown All Aliases For Admin
    #upload snapshot to remote

Remove log if not the first pass
    [arguments]    ${x}
    set test variable    ${del_command}    rm -rf ${loop${x}}
    ${con1}   Evaluate     '${test_verdict}'=='passed' or '${test_verdict}'=='passed_with_restriction'
    ${con2}   Evaluate     '${has_passed}'=='${True}' and '${unexp_alarm_sta}'=='NO'
    ${flag_rem}    Evaluate    ${con1} and ${con2}
    Run keyword if    ${flag_rem}    Execute Local Command    ${del_command}
    Run keyword if    '${test_verdict}'=='passed' or '${test_verdict}'=='passed_with_restriction'
    ...    set test variable    ${has_passed}    ${True}

