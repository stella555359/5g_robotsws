*** Settings ***
Documentation
...   author: Kancham Reddy Madhuri Reddy
...   contact: kancham.reddy_madhuri_reddy@nokia.com

Library    BuiltIn
Library    Collections
Library    String
Library    OperatingSystem
Library    SSHLibrary
Library    SeleniumLibrary
Library    DateTime
Library    RequestsLibrary
Library    taf.sbts.oam.coam.admin    WITH NAME    CoamAdmin
Library    taf.selenium.sbts    WITH NAME    seleLib
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ul.alarms_watchdog
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.fdsw.rc     WITH NAME    rc
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    taf.sw.scout    WITH NAME    scout

Test Setup      Admin_setup
Test Teardown   Admin_teardown

*** Variables ***
${VM_IP}                10.58.238.122
${VM_usn}               ute
${VM_pwd}               BT5l@bus3rl0g1n
${DURATION}             300
@{key_msg1}             aes128-ctr    aes256-gcm@openssh.com    aes128-gcm@openssh.com    aes256-ctr    aes192-ctr
@{key_msg2}             ecdh-sha2-nistp256    ecdh-sha2-nistp384    ecdh-sha2-nistp521    ecdsa-sha2-nistp384    ecdsa-sha2-nistp256
@{key_msg3}             curve25519-sha256    diffie-hellman-group-exchange-sha256    ecdsa-sha2-nistp521
@{key_msg4}             hmac-sha2-256    hmac-sha2-512    hmac-sha2-256-etm@openssh.com    hmac-sha2-512-etm@openssh.com
@{UE_alias}=            UE_1
@{capabilities}=        Legacy_1
@{timeout}=             100
${dt_name_dl}=          iperf_dl_test_1
${dl_name}=             iperf_dl_test_1
@{deviation_dl}=        100
@{throughput_dl}=       1000
@{direction_dl}=        dl
@{CALL_type}            UDP
&{BTS_INFO}                 host=${mplane_ip}	port=443
${mplane_ip}                10.58.239.61
${tcpdump_file}    ${OUTPUT_DIR}/CB012780/CB012780_To_Verify_ORU_reset_and_SSH_key_authentication/tcpdump/tcpdump.pcap

*** Test Cases ***
CB012780_To_Verify_ORU_reset_and_SSH_key_authentication
    Log to console   \n--TC Started--
    Check BTS is OnAir
    Get TcpdumpLogs from container using lxc-attach
    RMOD_Reset
    RAE State should be enabled
    Wait Until Keyword Succeeds    10min    10s    Check BTS is OnAir
    Stop TcpdumpLogs
    ${file_content}    Convert pcap file    ssh
    validate wireshark logs    ${file_content}    Server: Key Exchange Init     ${key_msg1}
    validate wireshark logs    ${file_content}    Server: Key Exchange Init     ${key_msg2}
    validate wireshark logs    ${file_content}    Client: Protocol (SSH-2.0-libssh_0.10.6), Key Exchange Init     ${key_msg3}
    validate wireshark logs    ${file_content}    Server: Key Exchange Init     ${key_msg4}
    validate wireshark logs    ${file_content}    Server: Elliptic Curve Diffie-Hellman Key Exchange Init    0
    validate wireshark logs    ${file_content}    Client: Elliptic Curve Diffie-Hellman Key Exchange Reply    0
    Attach UE and start throughput   ${UE_alias}   ${direction_dl}   ${timeout}

*** Keywords ***
Admin_setup
    Log To Console    connecting to BTS
    CoamAdmin.Teardown All Aliases For Admin
    CoamAdmin.Setup_Admin    bts_host=192.168.255.129    password=Nokia@123!    alias=oam
    Log To Console    BTS is Connected
    ${pre}    set variable    ${OUTPUT_DIR}/pre/
    set test variable    ${pre}
    create directory     ${pre}
    Check BTS is OnAir
    Download SCF    ${pre}
    Collect Snapshot    ${pre}
    ${allowed_alarms}=    Expected_alarm

Admin_teardown
    ${post}    set variable    ${OUTPUT_DIR}/post/
    set test variable    ${post}
    create directory     ${post}
    CoamAdmin.collect_raw_alarm_history_file
    ...    target_file_name=${post}alarm.txt
    ...    timeout=120
    ...    connection=oam
    Check BTS is OnAir
    Download SCF    ${post}
    Collect Snapshot    ${post}
    CoamAdmin.teardown    oam
    Log To Console    BTS IS Disconnected

Check BTS is OnAir
    [Documentation]  ... checking BTS status
    [Arguments]  ${connection}=oam
    ${bts_status}=  CoamAdmin.get_bts_statuses  connection=${connection}
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    BTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Download SCF
    [Documentation]    ... Downloading SCF
    [Arguments]    ${path}
    ${timestamp}    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S
    ${filename}    SET VARIABLE    ${path}${timestamp}_scf.xml
    CoamAdmin.get_current_scf_file    connection=oam    file_name=${filename}    timeout=60    local_dir_path=${path}
    OperatingSystem.File Should Exist    ${filename}
    Log To Console    SCF Downloaded
    Log To Console    SCF file name is ${filename}
    [Return]    ${filename}

Collect Snapshot
    [Arguments]    ${path}
    ${snapshot_file_path}    set variable    ${path}Snapshot.zip
    CoamAdmin.collect_snapshot
    ...    target_file_name=${snapshot_file_path}
    ...    coverage=Full
    ...    detailed_output=True
    ...    timeout=300
    ...    connection=oam
	Log To Console    Snapshot collected and saved on path ${snapshot_file_path}

RMOD_Reset
    [Arguments]    ${dur}=${DURATION}
    Log To Console    resetting RMOD
    ${dist}    CoamAdmin.get_ids_for all   RMOD    connection=oam
    FOR    ${dis}    IN    @{dist}
        ${opt}    CoamAdmin.reset_unit    dist_name=${dis}    timeout=${dur}    connection=oam
        ${optt}    get from list    ${opt}    1
		Run keyword if    '${optt['resultNode']['parameters']['status']}'=='Succeeded'
		...    Log to console    RMOD reset is Done
		...    ELSE    fail
	END

Get TcpdumpLogs from container using lxc-attach
    ${executor}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=toor4nsn
    ...  password=Nokia@789!
    tcpdump.create_lxc_tcpdump_collector
    ...    name=tcpdump
    ...    options=-i any
    ...    executor=${executor}
    ...    container=CPIF
    core.setup_collectors    names=tcpdump
    core.set_suite_alias	tcpdump
    core.start_collectors    names=tcpdump

Stop TcpdumpLogs
    core.stop_collectors    names=tcpdump
    core.collect_collectors    names=tcpdump
    core.teardown_collectors    names=tcpdump

RAE State should be enabled
    Wait Until Keyword succeeds     6min    30s    Verify Coam RAE is Online

Verify Coam RAE is Online
    ${bts_hw_info}                CoamAdmin.Get Bts Info    connection=oam
    ${rae_state}                Set Variable
    ...                           ${bts_hw_info['alds'][0]['status']['operationalState']}
    Log to Console    \n [INFO] RAE STATE : ${rae_state}
    Should Be Equal As Strings    ${rae_state}    enabled    ignore_case=${TRUE}

Convert pcap file
    [Arguments]    ${filter}
    SSH_connection    ${VM_IP}    ute    BT5l@bus3rl0g1n
    SSHLibrary.write    cd /home/ute
    ${command}=    set variable    tshark -r ${tcpdump_file} -Y "${filter}" > ${OUTPUT_DIR}/tcpdump.txt
    SSHLibrary.write    ${command}
    sleep    60s
    ${filepath}    set variable    ${OUTPUT_DIR}/tcpdump.txt
    ${file}=    OperatingSystem.Get file    ${filepath}
    SSH_teardown
    [Return]    ${file}

validate wireshark logs
    [Documentation]    this keyword is used to validate wireshark logs
    [Arguments]    ${logs}    ${message}    ${content}
    @{log}    Split to lines    ${logs}
    FOR    ${a}    IN    @{log}
         ${status}    run keyword and return status    should contain    ${a}    ${message}
         run keyword if    '''${status}'''=='''True''' and '''${content}'''=='''0'''    exit for loop
         ${status}    run keyword if    '''${status}'''=='''True'''    For loop for wireshark validation    ${a}    ${content}
         ${status}    run keyword if    '''${status}'''=='''True'''    exit for loop
    END
    Run Keyword if    '''${status}'''=='''True'''    Log to console    ${message} message is found in wireshark log
    ...    ELSE    Log to console     ${message} message is not found in wireshark log
    Run Keyword if    '''${status}'''!='''True'''    fail

For loop for wireshark validation
    [Arguments]    ${log}    ${message}
    ${list_length}    Get Length    ${message}
    ${count}=    Evaluate    0
    FOR    ${a}    IN    @{message}
        ${status}    run keyword and return status    should contain    ${log}    ${a}
        ${count}    run keyword if    '''${status}'''=='''True'''     Evaluate    ${count} + 1
        run keyword if    '''${count}'''=='''${list_length}'''    exit for loop
    END
    [Return]    ${status}

Prepare UE
    [Arguments]     ${UE_alias}     ${capabilities}
    ${a}=     ta_ultracaller.Require UE   ue_alias=${UE_alias}   capabilities=${capabilities}
    log	  ${a}
    Log To Console    \nUE preparation completed

Attach UE and start throughput
    [Arguments]     ${UE_alias}   ${direction}   ${timeout}
    Prepare UE    ${UE_alias}     ${capabilities}
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}
    Sleep    30
    ta_ultracaller.Attach UE     ue_alias=${UE_alias}
    Sleep    30
    Log To Console    \nUE Attach Successful and starting data transfer\n
    ta_ultracaller.start_datatransfer  ${UE_alias}  ${CALL_type}  direction=${direction}
    log to console    \nStop data transfer\n
    ta_ultracaller.await_data_transfer_finish    ${UE_alias}    ${direction}    ${timeout}
    Log To Console    \nUE Data Transfer Successful\n
    ta_ultracaller.Detach UE     ue_alias=${UE_alias}

Expected_alarm
    ${allowed_alarm_1}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61524
    ...                    fault_name=SSH enabled

    ${allowed_alarm_2}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4654
    ...                    fault_name=Ethernet port security is disabled

    ${allowed_alarm_3}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61649
    ...                    fault_name=LMP access via port 443

    ${allowed_alarm_4}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=4655
    ...                    fault_name=Service account root access is enabled

    ${allowed_alarm_5}=    Create alarm
    ...                    alarm_id=7220
    ...                    fault_id=61652
    ...                    fault_name=R&D Service Port enabled


    ${allowed_alarms}=     Create list
    ...                    ${allowed_alarm_1}
    ...                    ${allowed_alarm_2}
    ...                    ${allowed_alarm_3}
    ...                    ${allowed_alarm_4}
    ...                    ${allowed_alarm_5}

    [Return]    ${allowed_alarms}

SSH_connection
    [Arguments]    ${IP}    ${username}    ${pwd}
    SSHLibrary.Open Connection    ${IP}    port=22
    SSHLibrary.Login    ${username}    ${pwd}

SSH_teardown
    SSHLibrary.close connection

