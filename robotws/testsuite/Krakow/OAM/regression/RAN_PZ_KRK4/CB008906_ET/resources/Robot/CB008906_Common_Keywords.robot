*** Settings ***
Documentation
...    Common keywords for regression testing of feature CB008906-SR.
...    Author: SHI Kun
...    Contact: I_NJ_SC_SYSTEM_VERF_GMS <I_NJ_SC_SYSTEM_VERF@internal.nsn.com>

Library    String
Library    OperatingSystem
Library    Collections

Library    taf.ul.sc.tl_config.TestLineConfiguration
Library    ta_emss                                                                      WITH NAME   EMSSIM
Library    ../Python/CB008906_Common_Keywords.py                                        WITH NAME   SBTS
Library    ../Python/helper.py                                                          WITH NAME   HELPER

Resource   taf/rfrl/bts/robot/logs_collecting.robot
Library    Telnet

*** Variables ***
${virtual_enable} =                     ${TRUE}
${emssim_running} =                     ${FALSE}
${enable_tls} =                         1
${emssim_port} =                        6443

# values to change before case start and after case end
&{new_values} =                         &{EMPTY}
&{old_values} =                         &{EMPTY}
&{new_asir_values} =                    &{EMPTY}
&{old_asir_values} =                    &{EMPTY}

${bts_id} =                             ${tl.gnbs[0].global_bts_id}
#${emssim_host} =                        ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]}
${emssim_host} =                        ${tl.test_pc.default_ssh_connection_details.addr}
#${emssim_host} =                        7-7-UTE5GCLOUDT4SK140.p04.ska-lab.nsn-rdnet.net
${emssim_server_port} =                 36${tl.gnbs[0].global_bts_id}
${emssim_json_port} =                   40${tl.gnbs[0].global_bts_id}
${emssim_user} =                        asir1

# Alarms
@{allowed_alarms}    SSH enabled
...                  R&D Service Port enabled
...                  LMP access via port 443
...                  Service account root access is enabled
...                  Ethernet port security is disabled
...                  LMP connectivity detected
...                  Sanity Check Error
...                  Diagnostic Files collected

*** Keywords ***
Test Suite Preparation
    HELPER.Change Log Settings    test_log_path=${OUTPUTDIR}
    Configure ASiR Parameters

Common Preconditions
    Prepare Devices And Log Setting

    # the below 2 check points will base on same bts info,
    # no need re-collect bts info to save time
    Log2    Check sHUB status
    SBTS.Verify All SHUBs Enabled
    Log2    Check RAT status
    SBTS.Verify All Rats Enabled
    Log2    Check Allowed alarms
    Verify Default Allowed Alarms On BTS

    BuiltIn.Sleep    30

Common Postconditions
    # need re-collect bts info to check bts status again
    Log1    Case finished. Start to do postcondition.

    Restore Old Values

    Run Keyword And Ignore Error    SBTS.Quit Asir Webem
    Run Keyword If Test Passed    SBTS.Verify All sHubs Enabled
    Run Keyword If Test Passed    SBTS.Verify All Rats Enabled
    Run Keyword If Test Passed    Verify Default Allowed Alarms On BTS
    Run Keyword If     ${emssim_running}    Stop EMSSIM Service And Collect EMSSIM Logs

    [Teardown]    Run Keyword If Test Failed
    ...           Collect Logs After Test Failed

Prepare Devices And Log Setting
    Log To Console    ${EMPTY}
    Log1    Start Preconditions
    # OUTPUTDIR will be used by Selenium as Download directory.
    Set Test Variable    ${OUTPUTDIR}    ${OUTPUTDIR}${/}${SUITE_NAME}${/}${TEST_NAME}
    Set Test Variable    ${LOG_PATH}                 ${OUTPUTDIR}
    Set Test Variable    ${TS_CASE_LOG_PATH}         ${OUTPUTDIR}
    HELPER.Change Log Settings    test_log_path=${OUTPUTDIR}

    @{tmp} =    Split String    ${CURDIR}    testsuite
    Set Test Variable    @{BASE_PATH}    ${tmp}[0]

    Wait Until Keyword Succeeds    5min    30sec    SBTS.Connect All Devices

    Collect Logs During Test

Verify Default Allowed Alarms on BTS
    ${additional_allowed_alarms}   Get Variable Value  ${additional_allowed_alarms}
    Run Keyword If  ${additional_allowed_alarms}    Append To List    ${allowed_alarms}    @{additional_allowed_alarms}
    Verify Allowed Alarms On GNB    allowed_alarms=@{allowed_alarms}

Collect Logs After Test Failed
    SBTS.Collect Screenshot of Asir Webem    output_dir=${OUTPUTDIR}
    Collect Logs After Test Finished

# ----------------------------------------------------------------------------------------------------------------------
# specific keywords of case
# ----------------------------------------------------------------------------------------------------------------------
Configure COAM Parameters
    Log2    Change oamTls and set btsMaxFailedLoginAttempts to default value 5
    Run Keyword If    ${enable_tls} == 0     Set To Dictionary    ${new_values}    oamTls=off
    ...    ELSE    Set To Dictionary    ${new_values}    oamTls=forced
    Set To Dictionary    ${new_values}    btsMaxFailedLoginAttempts=5
    Set Test Variable    ${FAILED_LOGIN_ATTEMPTS}    5
    Set New Values

Configure ASiR Parameters
    Log2    Disable feature CB007213
    Set To Dictionary    ${new_asir_values}    actParallelUserSessions=false
    Set To Dictionary    ${new_asir_values}    webEMSessionLogoutTimer=600
    Set To Dictionary    ${new_asir_values}    maxParallelUserSessions=1
    Set To Dictionary    ${new_asir_values}    actEMAccessPriority=false
    Set New ASiR Values

Change OamTLS
    Run Keyword If    ${enable_tls} == 0     Set To Dictionary    ${new_values}    oamTls=off
    ...    ELSE    Set To Dictionary    ${new_values}    oamTls=forced
    Set New Values

Set New Values
    &{old_values} =    SBTS.Set Values    values=&{new_values}
    Set Test Variable    ${old_values}

Set New ASiR Values
    &{old_asir_values} =    SBTS.Set ASiR Values    values=&{new_asir_values}
    Set Suite Variable    ${old_asir_values}

Restore Old Values
    Run Keyword If    &{old_values}    SBTS.Set Values    values=&{old_values}
    Run Keyword If    &{old_asir_values}    SBTS.Set ASiR Values    values=&{old_asir_values}

Active NE3S Interface And Set Proxy Events Format As Full

    Log2    Start EMSSim service
    Start EMSSIM Service
    Log2    Active NE3S Interface
    Active NE3S Interface
    Log2    Set proxy_events_format as full
    Set Proxy Events Format As Full

Start EMSSIM Service
#    Run    sudo /opt/emssim/util/add_user.pl -u ${emssim_user} -ip ${emssim_host}
#    Sleep    5s
#    Run    cd /home/asir${bts_id}
#    Telnet.Open Connection    host=0    port=8061
#    Telnet.Set Prompt     FBOX>
#    Telnet.Set Timeout    3 seconds
#    Telnet.Write          reload
#    Telnet.Close Connection

#    Run    sudo iptables -I INPUT --proto tcp --match multiport --dport 3601 -j ACCEPT
    Set Test Variable    ${emssim_running}    ${TRUE}
    EMSSIM.Setup Emss    bts_id=${bts_id}    user=${emssim_user}
    ...                  wait_connected=${False}    wait_discovered=${False}    logging=${False}
    ...                  alias=et_emssim
#    ...                  port=${emssim_json_port}     server_port=${emssim_server_port}
    # Turn off firewall for SOAM BTS
    EMSSIM.Run Emssim Command    command=soam_firewall_off    get_full_data=${TRUE}    alias=et_emssim

    # get the path of UPLOADS, then clear the path
    @{result} =    EMSSIM.Run Emssim Command    command=env -bts   get_full_data=${TRUE}    alias=et_emssim
    &{tmp} =    Set Variable    ${result}[0]
    Set Test Variable    ${STATS_DIR}    /home/${tmp.env.BTS.STATS_DIR}
    Log2    Clear the directory of '${STATS_DIR}'
    RUN    sudo rm -rf ${STATS_DIR}/*

Active NE3S Interface
    EMSSIM.Run Emssim Command    command=ne3s_activate -port ${emssim_port} -tls ${enable_tls}   get_full_data=${TRUE}    alias=et_emssim

Set Proxy Events Format As ${format}
    [Documentation]    Set proxy events format: short, full, hex, off
    ...  short (default):
    ...    - print only event type and short list of event params if available
    ...  full:
    ...    - print full decoded message in plain text if possible, binary representation otherwise
    ...  hex:
    ...    - print full raw message in hex
    ...  off:
    ...    - turn off proxy events
    ${format} =    Convert To Lowercase    ${format}
    EMSSIM.Run Emssim Command    command=proxy_events_format ${format}   get_full_data=${TRUE}    alias=et_emssim

Upload Audit Trail Log To EMSSIM
    EMSSIM.Run Emssim Command    command=ne3s_upload_atl -time 1    get_full_data=${TRUE}    alias=et_emssim

Upload Audit Trail Log Of ${operation_type} To EMSSIM
    EMSSIM.Run Emssim Command    command=ne3s_upload_atl -time 1    get_full_data=${TRUE}    alias=et_emssim    timeout=600
    ${operation_type} =    Replace String    ${operation_type}    ${SPACE}    _
    ${operation_type} =    Convert To Lowercase    ${operation_type}
    Create Directory    ${OUTPUTDIR}/${operation_type}
    Run    sudo mv ${STATS_DIR}/ATL/ne3s_atl_*.tar ${OUTPUTDIR}/${operation_type}

Check Scenario Of Audit Trail Log For Wrong Password
    @{param} =    Get Param To Check ATL
    ...    wrong_password    ${SESSION_START_TIME_WRONG_PASSWORD}    ${SESSION_END_TIME_WRONG_PASSWORD}
    ...    backoff_time=3
    ${atl_report_param} =    Create Dictionary    login=@{param}
    Log2    Check ATL for the scenario of "wrong password" login
    ${more_than_max} =    Evaluate    ${REPEAT_TIMES_WRONG_PASSWORD} >= ${FAILED_LOGIN_ATTEMPTS}
    ${expected_repeat_times} =    Set Variable If
    ...    ${more_than_max} == ${TRUE}     ${FAILED_LOGIN_ATTEMPTS}
    ...    ${more_than_max} == ${FALSE}    ${REPEAT_TIMES_WRONG_PASSWORD}
    SBTS.Check Scenario Of Audit Trail Log    atl_path=${OUTPUTDIR}/wrong_password
    ...    emssim_log_start_time=${EMSSIM_LOG_START_TIME_WRONG_PASSWORD}
    ...    emssim_log_end_time=${EMSSIM_LOG_END_TIME_WRONG_PASSWORD}
    ...    atl_report_param=&{ATL_REPORT_PARAM}
    ...    expected_repeat_times=${expected_repeat_times}

    Run Keyword If    ${more_than_max}    Check Scenario of Audit Trail Log For Account Disabled

Check Scenario of Audit Trail Log For Account Disabled
    Log2    Check ATL for the scenario of "account disabled"
    ${expected_repeat_times} =    Evaluate   ${REPEAT_TIMES_WRONG_PASSWORD} - ${FAILED_LOGIN_ATTEMPTS}
    @{param} =    Get Param To Check ATL
    ...    account_disabled    ${SESSION_START_TIME_WRONG_PASSWORD}    ${SESSION_END_TIME_WRONG_PASSWORD}
    ...    backoff_time=3
    ${atl_report_param} =    Create Dictionary    login=@{param}
    SBTS.Check Scenario Of Audit Trail Log
    ...    atl_path=${OUTPUTDIR}/wrong_password
    ...    emssim_log_start_time=${EMSSIM_LOG_START_TIME_WRONG_PASSWORD}
    ...    emssim_log_end_time=${EMSSIM_LOG_END_TIME_WRONG_PASSWORD}
    ...    atl_report_param=&{ATL_REPORT_PARAM}
    ...    expected_repeat_times=${expected_repeat_times}

Check Scenario Of Audit Trail Log For Normal Login and Logout
    @{login_param} =    Get Param To Check ATL
    ...    normal_login    ${SESSION_START_TIME_NORMAL_LOGIN_AND_LOGOUT}    ${SESSION_END_TIME_NORMAL_LOGIN_AND_LOGOUT}
    ...    backoff_time=3
    @{logout_param} =    Get Param To Check ATL
    ...    normal_logout    ${SESSION_START_TIME_NORMAL_LOGIN_AND_LOGOUT}    ${SESSION_END_TIME_NORMAL_LOGIN_AND_LOGOUT}
    ...    backoff_time=3
    ${atl_report_param} =    Create Dictionary    login=@{login_param}    logout=@{logout_param}
    Set Suite Variable    ${ATL_REPORT_PARAM}
    Log2    Check ATL for the scenario of "normal login and logout"
    ${expected_repeat_times} =    Evaluate    int(${REPEAT_TIMES_NORMAL_LOGIN_AND_LOGOUT}) * 2
    SBTS.Check Scenario Of Audit Trail Log    atl_path=${OUTPUTDIR}/normal_login_and_logout
    ...    emssim_log_start_time=${EMSSIM_LOG_START_TIME_NORMAL_LOGIN_AND_LOGOUT}
    ...    emssim_log_end_time=${EMSSIM_LOG_END_TIME_NORMAL_LOGIN_AND_LOGOUT}
    ...    atl_report_param=&{atl_report_param}
    ...    expected_repeat_times=${expected_repeat_times}

Check Scenario Of Audit Trail Log For Two Instances
    @{param} =    Get Param To Check ATL
    ...    two_instances    ${SESSION_START_TIME_TWO_INSTANCES}    ${SESSION_END_TIME_TWO_INSTANCES}
    ...    backoff_time=3
    ${atl_report_param} =    Create Dictionary    login=@{param}
    Log2    Check ATL for the scenario of "two instance" login
    SBTS.Check Scenario Of Audit Trail Log    atl_path=${OUTPUTDIR}/two_instances
    ...    emssim_log_start_time=${EMSSIM_LOG_START_TIME_TWO_INSTANCES}
    ...    emssim_log_end_time=${EMSSIM_LOG_END_TIME_TWO_INSTANCES}
    ...    atl_report_param=&{atl_report_param}

Check Scenario Of Audit Trail Log For Block And Unblock
    SBTS.Check Scenario Of Audit Trail Log    stats_path=${STATS_DIR}    test_log_path=${OUTPUTDIR}
    ...    emssim_log_start_time=${EMSSIM_LOG_START_TIME}    emssim_log_end_time=${EMSSIM_LOG_END_TIME}
    ...    atl_report_param=&{ATL_REPORT_PARAM}

Stop EMSSIM Service And Collect EMSSIM Logs
    EMSSIM.Teardown Emss    alias=et_emssim

Check Locked Account Is Released
    Wait Until Keyword Succeeds    35 min    60 sec    SBTS.Login And Logout ASiR Webem
    BuiltIn.Sleep    5

Login And Logout ASiR WebEM ${repeat_times} Times
    Set Suite Variable    ${REPEAT_TIMES_NORMAL_LOGIN_AND_LOGOUT}    ${repeat_times}

    Log2    Start logging EMSSIM Session
    Run    sudo rm -rf /var/log/emssim/*
    EMSSIM.Logging Start    alias=et_emssim

    ${EMSSIM_LOG_START_TIME_NORMAL_LOGIN_AND_LOGOUT} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_START_TIME_NORMAL_LOGIN_AND_LOGOUT}

    ${SESSION_START_TIME_NORMAL_LOGIN_AND_LOGOUT} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_NORMAL_LOGIN_AND_LOGOUT}

    Log2    Start login ASiR WebEM

    BuiltIn.Sleep    3

    Repeat Keyword    ${repeat_times} times    SBTS.Login And Logout Asir Webem

    BuiltIn.Sleep    3

    ${SESSION_END_TIME_NORMAL_LOGIN_AND_LOGOUT} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_NORMAL_LOGIN_AND_LOGOUT}

    ${EMSSIM_LOG_END_TIME_NORMAL_LOGIN_AND_LOGOUT} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_END_TIME_NORMAL_LOGIN_AND_LOGOUT}

    Log2    Stop logging EMSSIM Session
    EMSSIM.Logging Stop    output_dir=${OUTPUTDIR}/normal_login_and_logout    alias=et_emssim

Login ASiR WebEM With Wrong User ${repeat_times} Times
    Set Suite Variable    ${REPEAT_TIMES_WRONG_USER}    ${repeat_times}
    ${SESSION_START_TIME_WRONG_USER} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_WRONG_USER}
    BuiltIn.Sleep    3
    Repeat Keyword    ${repeat_times} times    SBTS.Login Asir Webem With Wrong User
    BuiltIn.Sleep    3
    ${SESSION_END_TIME_WRONG_USER} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_WRONG_USER}

Login ASiR WebEM With Wrong Password ${repeat_times} Times
    Set Suite Variable    ${REPEAT_TIMES_WRONG_PASSWORD}    ${repeat_times}

    Log2    Start logging EMSSIM Session
    Run    sudo rm -rf /var/log/emssim/*
    EMSSIM.Logging Start    alias=et_emssim

    ${EMSSIM_LOG_START_TIME_WRONG_PASSWORD} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_START_TIME_WRONG_PASSWORD}

    ${SESSION_START_TIME_WRONG_PASSWORD} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_WRONG_PASSWORD}

    BuiltIn.Sleep    3

    Repeat Keyword    ${repeat_times} times    SBTS.Login Asir Webem With Wrong Password    output_dir=${OUTPUTDIR}

    BuiltIn.Sleep    3

    ${SESSION_END_TIME_WRONG_PASSWORD} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_WRONG_PASSWORD}

    ${EMSSIM_LOG_END_TIME_WRONG_PASSWORD} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_END_TIME_WRONG_PASSWORD}

    Log2    Stop logging EMSSIM Session
    EMSSIM.Logging Stop    output_dir=${OUTPUTDIR}/wrong_password    alias=et_emssim

Login Account Should Be Locked
    Log2    "Account is disabled" should present on the ASiR WebEM and Login should be failed
    Check Failure Login Information In Asir Webem

Login Different ASiR WebEM Instance
    Log2    Start logging EMSSIM Session
    Run    sudo rm -rf /var/log/emssim/*
    EMSSIM.Logging Start    alias=et_emssim

    ${EMSSIM_LOG_START_TIME_TWO_INSTANCES} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_START_TIME_TWO_INSTANCES}

    ${SESSION_START_TIME_TWO_INSTANCES} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_TWO_INSTANCES}

    BuiltIn.Sleep    3

    SBTS.Login Asir Webem
    SBTS.Login Asir Webem With Another Instance    output_dir=${OUTPUTDIR}

    BuiltIn.Sleep    3

    ${SESSION_END_TIME_TWO_INSTANCES} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_TWO_INSTANCES}

    ${EMSSIM_LOG_END_TIME_TWO_INSTANCES} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_END_TIME_TWO_INSTANCES}

    Log2    Stop logging EMSSIM Session
    EMSSIM.Logging Stop    output_dir=${OUTPUTDIR}/two_instances    alias=et_emssim

    [Teardown]    SBTS.Logout Asir Webem

SSH Login And Logout ASiR SHUB From WS ${repeat_times} Times
    Set Suite Variable    ${REPEAT_TIMES_WS}    ${repeat_times}
    ${SESSION_START_TIME_WS} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_WS}
    BuiltIn.Sleep    3
    Repeat Keyword    ${repeat_times} times    SBTS.SSH Login And Logout SHUB From WS    raise_exception=${TRUE}
    BuiltIn.Sleep    3
    ${SESSION_END_TIME_WS} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_WS}

SSH Login And Logout ASiR SHUB From FHNET ${repeat_times} Times
    ${shub_ip} =          Get Shub IP In BBU
    Set Suite Variable    ${REPEAT_TIMES_FHNET}    ${repeat_times}
    ${SESSION_START_TIME_FHNET} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_FHNET}
    BuiltIn.Sleep    3
    Repeat Keyword    ${repeat_times} times    SBTS.SSH Login And Logout SHUB From FHNET    shub_ip=${shub_ip}
    ...    raise_exception=${TRUE}
    BuiltIn.Sleep    3
    ${SESSION_END_TIME_FHNET} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_FHNET}

SSH Login ASiR SHUB From WS With Wrong User ${repeat_times} Times
    Set Suite Variable    ${REPEAT_TIMES_WRONG_USER}    ${repeat_times}
    ${SESSION_START_TIME_WRONG_USER} =    Get Current Time In Shub
    Set Suite Variable    ${SESSION_START_TIME_WRONG_USER}
    BuiltIn.Sleep    3
    Repeat Keyword    ${repeat_times} times    SBTS.SSH Login SHUB From WS With Wrong User
    BuiltIn.Sleep    3
    ${SESSION_END_TIME_WRONG_USER} =      Get Current Time In Shub
    Set Suite Variable    ${SESSION_END_TIME_WRONG_USER}

SSH Login ASiR SHUB From WS With Wrong Password ${repeat_times} Times
    Set Suite Variable     ${REPEAT_TIMES_WRONG_PASSWORD}    ${repeat_times}
    ${SESSION_START_TIME_WRONG_PASSWORD} =    Get Current Time In Shub
    Set Suite Variable     ${SESSION_START_TIME_WRONG_PASSWORD}
    BuiltIn.Sleep    3
    Repeat Keyword    ${repeat_times} times    SBTS.SSH Login SHUB From WS With Wrong Password
    BuiltIn.Sleep    3
    ${SESSION_END_TIME_WRONG_PASSWORD} =      Get Current Time In Shub
    Set Suite Variable     ${SESSION_END_TIME_WRONG_PASSWORD}

Block and Unblock pRRH from ASiR WebEM
    Log2    Start logging EMSSIM Session
    EMSSIM.Logging Start    alias=et_emssim

    ${EMSSIM_LOG_START_TIME} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_START_TIME}

    ${ATL_REPORT_START_TIME_BLOCK} =    Get Current Time In Shub
    Set Suite Variable     ${ATL_REPORT_START_TIME_BLOCK}

    Log2    Block pRRH from ASiR WebEM
    Wait Until Keyword Succeeds    3x    5s    SBTS.Block PRRH From ASiR WebEM

    ${ATL_REPORT_END_TIME_BLOCK} =    Get Current Time In Shub
    Set Suite Variable     ${ATL_REPORT_END_TIME_BLOCK}

    BuiltIn.Sleep  10

    ${ATL_REPORT_START_TIME_UNBLOCK} =    Get Current Time In Shub
    Set Suite Variable     ${ATL_REPORT_START_TIME_UNBLOCK}

    Log2    Unblock pRRH from ASiR WebEM
    Wait Until Keyword Succeeds    3x    5s    SBTS.Unblock PRRH From ASiR WebEM

    ${ATL_REPORT_END_TIME_UNBLOCK} =    Get Current Time In Shub
    Set Suite Variable     ${ATL_REPORT_END_TIME_UNBLOCK}

    ${EMSSIM_LOG_END_TIME} =    Get Time
    Set Suite Variable    ${EMSSIM_LOG_END_TIME}

    Log2    Stop logging EMSSIM Session
    EMSSIM.Logging Stop    output_dir=${OUTPUTDIR}    alias=et_emssim

    @{block_param} =    Get Param To Check ATL
    ...    block      ${ATL_REPORT_START_TIME_BLOCK}    ${ATL_REPORT_END_TIME_BLOCK}
    @{unblock_param} =  Get Param To Check ATL
    ...    unblock    ${ATL_REPORT_START_TIME_UNBLOCK}    ${ATL_REPORT_END_TIME_UNBLOCK}
    ${ATL_REPORT_PARAM} =    Create Dictionary    unitBlock=@{block_param}    unitUnblock=@{unblock_param}
    Set Suite Variable    ${ATL_REPORT_PARAM}

Collect Snapshot In ASiR SHUB
    Wait Until Keyword Succeeds    20 min    30 sec    SBTS.Collect Snapshot In ASiR SHUB    ${OUTPUTDIR}

Check Successful SSH Session From ${host_type} In Snapshot
    SBTS.Check SSH Session In Snapshot    snapshot_file=${OUTPUTDIR}/rfsw_snapshot.zip
    ...    host_type=${host_type}
    ...    expected_session_times=${REPEAT_TIMES_${host_type}}
    ...    session_start_time=${SESSION_START_TIME_${host_type}}
    ...    session_end_time=${SESSION_END_TIME_${host_type}}
    ...    login_failure_type=0

Check SSH Session Of Wrong User In Snapshot
    SBTS.Check SSH Session In Snapshot    snapshot_file=${OUTPUTDIR}/rfsw_snapshot.zip
    ...    expected_session_times=${REPEAT_TIMES_WRONG_USER}
    ...    session_start_time=${SESSION_START_TIME_WRONG_USER}
    ...    session_end_time=${SESSION_END_TIME_WRONG_USER}
    ...    login_failure_type=1

Check SSH Session Of Wrong Password In Snapshot
    SBTS.Check SSH Session In Snapshot    snapshot_file=${OUTPUTDIR}/rfsw_snapshot.zip
    ...    expected_session_times=${REPEAT_TIMES_WRONG_PASSWORD}
    ...    session_start_time=${SESSION_START_TIME_WRONG_PASSWORD}
    ...    session_end_time=${SESSION_END_TIME_WRONG_PASSWORD}
    ...    login_failure_type=2

Reboot ASiR Hub by ASiR WebEM And Wait For SBTS Enabled
    SBTS.Reboot SHUB By ASiR Webem
    Wait Until Keyword Succeeds    5 min    10 sec    SBTS.Verify All SHUBs Enabled
    BuiltIn.Sleep    120 sec
    Wait Until Keyword Succeeds    10 min    10 sec    SBTS.Verify All Rats Enabled

Check userEventTempBufOverwriting And userEventTempBufThreshold Should Be Default Value
    # managedObject class="com.nokia.asi:SECPRM" distName="ASI-1/SECPRM-1"
    ${parameters} =    Create Dictionary    userEventTempBufOverwriting=true    userEventTempBufThreshold=100
    ${default_value} =    SBTS.Check If Parameter Has Default Value
    ...                 managed_object=ASI-1/SECPRM-1    parameters=&{parameters}
    Should Be True    ${default_value}
    ...            userEventTempBufOverwriting And userEventTempBufThreshold are not Default Value!!

Change Password Of System Administrator to New Password
    ${new_password}    ${last_changed_time} =    SBTS.Change Password Of Admin In ASiR WebEM
    SBTS.SSH Login sHUB With New Password    new_password=${new_password}
    Log2    Check 'Last changed time' for New Password
    SBTS.Check Last Changed Time    ${last_changed_time}

Reset Password Of System Administrator to Default Password
    ${last_changed_time} =    SBTS.Reset Password Of Admin In ASiR WebEM To Default Password
    SBTS.SSH Login And Logout Shub From WS
    Log2    Check 'Last changed time' for Default Password
    SBTS.Check Last Changed Time    ${last_changed_time}
