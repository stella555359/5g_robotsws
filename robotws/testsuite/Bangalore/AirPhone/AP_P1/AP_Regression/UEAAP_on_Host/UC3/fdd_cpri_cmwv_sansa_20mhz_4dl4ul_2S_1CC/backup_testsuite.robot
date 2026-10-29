*** Settings ***
Documentation      This is a backup suite which contains fdd_cpri_cmwv_sansa_20mhz_4dl4ul_2S_1CC test cases

Library             Telnet
Library             Process
Library             String
Library             Collections
Library             OperatingSystem

Test Teardown       Flush egate logs


*** Variables ***
${CFG_FILE_PATH}            /home/macdit/wts/config/wts_config.cfg
${EGATE_TIMEOUT}            240
${EGATE_PORT}               20000
${EGATE_LOGS_FILE_PATH}     /home/ute/egate.log
${GLOBAL_RETRY_AMOUNT}      20x
${GLOBAL_RETRY_INTERVAL}    90s
${Total_Timeout}            300
${Retry_Timeout}            10


*** Test Cases ***
Start configuration
    [Documentation]    Init telnet connection & start configuration
    ${local_wts_container_ip} =    Get wts container ip from other docker
    Set Global Variable    ${wts_container_ip}    ${local_wts_container_ip}
    Telnet open new connection
    Telnet start cfg    ${CFG_FILE_PATH}

Check WTS Startup
    Check wts startup

Check NG Link
    Check NG link

Check MIB
    Check MIB Cell 1
    Check MIB Cell 2

Check Cell Setup
    Check Cell setup completed Cell 1
    Check Cell setup completed Cell 2

Check SIB
    Check SIB Cell 1
    Check SIB Cell 2

Start X2 AP link
    Start X2 AP link

Register/attach UEs
    Register UE Cell 1
    Register UE Cell 2
    Attach UE Cell 1
    Attach UE Cell 2

Start SA/NSA traffic and wait 60 sec
    Sleep    10s
    Start traffic SA Cell 1
    Sleep    1s
    Start traffic NSA Cell 1
    Sleep    10s
    Start traffic SA Cell 2
    Sleep    1s
    Start traffic NSA Cell 2
    Sleep    60s

Stop SA/NSA traffic and wait 10s
    Stop traffic SA Cell 1
    Stop traffic NSA Cell 1
    Stop traffic SA Cell 2
    Stop traffic NSA Cell 2
    Sleep    10s

Check SA/NSA traffic
    Check traffic stats until it match SA    1    1    dl
    Sleep    2s
    Check traffic stats until it match NSA    11    dl
    Sleep    2s
    Check traffic stats until it match SA    1    1    ul
    Sleep    2s
    Check traffic stats until it match NSA    11    ul
    Sleep    2s
    Check traffic stats until it match SA    21    1    dl
    Sleep    2s
    Check traffic stats until it match NSA    31    dl
    Sleep    2s
    Check traffic stats until it match SA    21    1    ul
    Sleep    2s
    Check traffic stats until it match NSA    31    ul


*** Keywords ***
Check wts startup
    ${old_timeout} =    Set Timeout    45 seconds
    ${out} =    Read Until Regexp    CHANGE STATE: ACTIVE - SimMode is ready now
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Set Timeout    ${old_timeout}

Check proxy to eNB connection
    ${out} =    Read Until Regexp    Airphone: Address Distribution is complete
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Collect logs to check
    ${out} =    Read
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Check NG link
    Check Pattern in Log    NG Link to gNB=2 is now Active    NG Link to gNB=2 is now Active

Check Cell setup completed Cell 1
    Check Pattern in Log
    ...    Airphone: Cell Setup completed for \\[CELL_ID:1\\]
    ...    Airphone: Cell Setup completed for [CELL_ID:1]

Check MIB Cell 1
    Check Pattern in Log
    ...    eNB 2 cell 1: MasterInformationBlock-NR Updated
    ...    eNB 2 cell 1: MasterInformationBlock-NR Updated

Check SIB Cell 1
    Check Pattern in Log
    ...    eNB 2 cell 1: SystemInformationBlockType2-NR updated
    ...    eNB 2 cell 1: SystemInformationBlockType2-NR updated

Check Cell setup completed Cell 2
    Check Pattern in Log
    ...    Airphone: Cell Setup completed for \\[CELL_ID:2\\]
    ...    Airphone: Cell Setup completed for [CELL_ID:2]

Check MIB Cell 2
    Check Pattern in Log
    ...    eNB 2 cell 2: MasterInformationBlock-NR Updated
    ...    eNB 2 cell 2: MasterInformationBlock-NR Updated

Check SIB Cell 2
    Check Pattern in Log
    ...    eNB 2 cell 2: SystemInformationBlockType2-NR updated
    ...    eNB 2 cell 2: SystemInformationBlockType2-NR updated

Start X2 AP link
    Write    enb_x2_link_up enb\=1 target\=2
    ${out} =    Read Until Regexp    X2AP Link with GNB-2 (.*?)* is up
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Register UE Cell 1
    Telnet.Write    ue_register id\=1
    ${out} =    Read Until Regexp    Received REGISTRATION COMPLETE from UE
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Sleep    1s
    Telnet.Write    ue_pdu_session_setup pdu\=1 gw\=1 ue\=1 nwslice\=1
    ${out} =    Read Until Regexp    PDU SESSION (.*?)*1 setup/reestablishment complete
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Register UE Cell 2
    Telnet.Write    ue_register id\=21
    ${out} =    Read Until Regexp    Received REGISTRATION COMPLETE from UE
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Sleep    1s
    Telnet.Write    ue_pdu_session_setup pdu\=1 gw\=1 ue\=21 nwslice\=1
    ${out} =    Read Until Regexp    PDU SESSION (.*?)*1 setup/reestablishment complete
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Attach UE Cell 1
    Telnet.Write    ue_attach id=11
    ${out} =    Read Until Regexp    UE IS ACTIVE
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    enb_ue_dc_start target_gnb\=2 target_cells\=1 ue\=11 bearer\=2 type\=split_scg
    ${out} =    Read Until Regexp    Proxy (.*?)* reported successful RA
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Attach UE Cell 2
    Telnet.Write    ue_attach id=31
    ${out} =    Read Until Regexp    UE IS ACTIVE
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    enb_ue_dc_start target_gnb\=2 target_cells\=2 ue\=31 bearer\=2 type\=split_scg
    ${out} =    Read Until Regexp    Proxy (.*?)* reported successful RA
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Start traffic NSA Cell 1
    Telnet.Write    trf_data_start ue\=11 id\=2 dir\=dl kbps\=100
    Telnet.Write    trf_data_start ue\=11 id\=2 dir\=ul kbps\=100

Start traffic NSA Cell 2
    Telnet.Write    trf_data_start ue\=31 id\=2 dir\=dl kbps\=100
    Telnet.Write    trf_data_start ue\=31 id\=2 dir\=ul kbps\=100

Start traffic SA Cell 1
    Telnet.Write    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl kbps\=100
    ${out} =    Read Until Regexp    Started Downlink Internal traffic
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul kbps\=100
    ${out} =    Read Until Regexp    Started Uplink Internal traffic
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Start traffic SA Cell 2
    Telnet.Write    trf_data_start ue\=21 pdu\=1 qfi\=1 dir\=dl kbps\=100
    ${out} =    Read Until Regexp    Started Downlink Internal traffic
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    trf_data_start ue\=21 pdu\=1 qfi\=1 dir\=ul kbps\=100
    ${out} =    Read Until Regexp    Started Uplink Internal traffic
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Stop traffic NSA Cell 1
    Telnet.Write    trf_data_stop ue\=11 id\=2 dir\=dl
    ${out} =    Read Until Regexp    Traffic was stopped

    Telnet.Write    trf_data_stop ue\=11 id\=2 dir\=ul
    ${out} =    Read Until Regexp    Traffic was stopped

Stop traffic NSA Cell 2
    Telnet.Write    trf_data_stop ue\=31 id\=2 dir\=dl
    ${out} =    Read Until Regexp    Traffic was stopped

    Telnet.Write    trf_data_stop ue\=31 id\=2 dir\=ul
    ${out} =    Read Until Regexp    Traffic was stopped

Stop traffic SA Cell 1
    Telnet.Write    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=dl
    ${out} =    Read Until Regexp    Stopped Downlink Internal traffic

    Telnet.Write    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=ul
    ${out} =    Read Until Regexp    Stopping Uplink Internal traffic

Stop traffic SA Cell 2
    Telnet.Write    trf_data_stop ue\=21 pdu\=1 qfi\=1 dir\=dl
    ${out} =    Read Until Regexp    Stopped Downlink Internal traffic

    Telnet.Write    trf_data_stop ue\=21 pdu\=1 qfi\=1 dir\=ul
    ${out} =    Read Until Regexp    Stopping Uplink Internal traffic

Check traffic stats
    [Arguments]    ${traffic_stats}
    ${bytes_sent} =    Should Match Regexp    ${traffic_stats}    Bytes sent \\s*\\d*    flags=MULTILINE
    ${o} =    Fetch From Right    ${bytes_sent}    Bytes sent
    ${sent} =    Strip String    ${o}
    ${bytes_received} =    Should Match Regexp    ${traffic_stats}    Bytes received \\s*\\d*    flags=MULTILINE
    ${o} =    Fetch From Right    ${bytes_received}    Bytes received
    ${received} =    Strip String    ${o}
    Log    "received ${received}"
    Log    "sent ${sent}"
    Check stats    ${sent}    ${received}

Check stats
    [Arguments]    ${sent}    ${rec}
    ${sent} =    Convert To Number    ${sent}
    ${rec} =    Convert To Number    ${rec}
    ${div} =    Evaluate    ${rec} / ${sent}
    ${traffic_per} =    Evaluate    ${div} * 100
    Log    "traffic received at ${traffic_per} %"
    Should Be True    ${traffic_per} >= ${95.0}

Check traffic stats NSA
    [Arguments]    ${ue}    ${dir}
    # Empty the read buffer
    ${out} =    Telnet.Read
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    bearer_stats ue\=${ue} id\=2 dir\=${dir} type\=l3 format\=short
    ${out} =    Read Until Regexp    Average packet interval
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Check traffic stats    ${out}

Check traffic stats SA
    [Arguments]    ${ue}    ${pdu}    ${dir}
    # Empty the read buffer
    ${out} =    Telnet.Read
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    bearer_stats ue\=${ue} pdu\=${pdu} qfi\=1 dir\=${dir}
    ${out} =    Read Until Regexp    Average packet interval
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Check traffic stats    ${out}

Check traffic stats until it match SA
    [Arguments]    ${ue}    ${pdu}    ${dir}
    Wait Until Keyword Succeeds
    ...    ${GLOBAL_RETRY_AMOUNT}
    ...    ${GLOBAL_RETRY_INTERVAL}
    ...    Check traffic stats SA    ${ue}    ${pdu}    ${dir}

Check traffic stats until it match NSA
    [Arguments]    ${ue}    ${dir}
    Wait Until Keyword Succeeds
    ...    ${GLOBAL_RETRY_AMOUNT}
    ...    ${GLOBAL_RETRY_INTERVAL}
    ...    Check traffic stats NSA    ${ue}    ${dir}

Check Pattern in Log
    [Documentation]    This keyword checks if the ${pattern} is present in log.
    ...    Modified Date: 17-Aug-2023
    ...    Last Modified by: ramya.2.k@nokia.com
    [Arguments]    ${pattern}    ${pattern1}
    Wait Until Keyword Succeeds    ${Total_Timeout}    ${Retry_Timeout}    Search grep pattern should Exists
    ...    ${EGATE_LOGS_FILE_PATH}    ${pattern}    ${pattern1}

Search grep pattern should Exists
    [Arguments]    ${file}    ${pattern}    ${pattern1}    ${grepArgs}=grep -i
    Collect logs to check
    ${command} =    Catenate    ${grepArgs} '${pattern}' ${file}
    ${result} =    Run    ${command}
    Log    ${result}
    Should Contain    """${result}"""    ${pattern1}    ignore_case=${TRUE}

Flush egate logs
    Telnet.write    sim_log_set flush

Telnet open new connection
    ${session_id} =    Telnet.Open Connection
    ...    ${wts_container_ip}
    ...    port=${EGATE_PORT}
    ...    prompt=EGATE>
    ...    timeout=${EGATE_TIMEOUT}
    ...    terminal_emulation=True
    ...    terminal_type=vt100
    ...    window_size=400x200
    Telnet.Write    echo dummy0 for init
    ${out} =    Read Until    State INIT
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Log    ${out}

Telnet start cfg
    [Arguments]    ${CFG_FILE_PATH}
    Telnet.write    cfg file=${CFG_FILE_PATH}

Get wts container ip from other docker
    [Documentation]    Use dig (from dnsutils on debian) to find the ip address of wts container
    ${container_prefix} =    Get Environment Variable    COMPOSE_PROJECT_NAME
    ${wts_container_name} =    Catenate    SEPARATOR=    ${container_prefix}    _wts
    ${wts_ip} =    Run Process    dig    ${wts_container_name}    +short
    RETURN    ${wts_ip.stdout}
