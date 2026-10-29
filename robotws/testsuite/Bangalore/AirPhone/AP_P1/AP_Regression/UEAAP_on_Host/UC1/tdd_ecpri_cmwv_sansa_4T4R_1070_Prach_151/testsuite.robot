*** Settings ***
Documentation    This suite contains tdd_ecpri_cmwv_sansa_4T4R_1070_Prach_151 UEAPP On Host test cases

Library     Telnet
Library     Process
Library     String
Library     Collections
Library     OperatingSystem
Test Teardown    Flush egate logs


*** Variables ***
${CFG_FILE_PATH}    /home/macdit/wts/config/wts_config.lua
${EGATE_TIMEOUT}    240
${EGATE_PORT}    20000
${EGATE_LOGS_FILE_PATH}    /home/ute/egate.log
${GLOBAL_RETRY_AMOUNT}=    20x
${GLOBAL_RETRY_INTERVAL}=    90s

*** Test Cases ***
Start configuration
    [Documentation]    Init telnet connection & start configuration
    ${local_wts_container_ip} =      Get wts container ip from other docker
    Set Global Variable    ${wts_container_ip}   ${local_wts_container_ip}
    Telnet open new connection
    Telnet start cfg    ${CFG_FILE_PATH}

Check WTS Startup And NG Link
    Check Startup

Check MIB
    Check MIB

Check Cell Setup
    Check Cell setup completed

Check SIB
    Check SIB

Start X2 AP link
    Start X2 AP link

Register/attach UEs
    Register UE
    Attach UE

Start SA/NSA traffic and wait 60 sec
    Sleep    10s
    Start traffic SA
    Sleep    1s
    Start traffic NSA
    Sleep    60s

Stop SA/NSA traffic and wait 10s
    Stop traffic SA
    Stop traffic NSA
    Sleep    10s

Check SA/NSA traffic
    Check traffic stats until it match SA        1    1    dl
    Sleep    2s
    Check traffic stats until it match NSA       11    dl
    Sleep    2s
    Check traffic stats until it match SA        1    1    ul
    Sleep    2s
    Check traffic stats until it match NSA       11    ul

*** Keywords ***
Check Startup
    ${pass_green}=    Evaluate    "\\033[32mOK\\033[0m"
    ${WTS_START_PATTERN}    Set Variable    CHANGE STATE: ACTIVE - SimMode is ready now
    ${NG_LINK_PATTERN}    Set Variable    NG Link to gNB\=2 is now Active
    ${RESULT}=    Read Until Regexp    (${WTS_START_PATTERN}|${NG_LINK_PATTERN})
    IF    '${WTS_START_PATTERN}' in '''${RESULT}'''
        Log To Console    \nWTS Startup -> ${pass_green}
        Read Until    ${NG_LINK_PATTERN}
        Log To Console    NG link -> ${pass_green}
    ELSE
        Log To Console    \nNG link -> ${pass_green}
        Read Until    ${WTS_START_PATTERN}
        Log To Console    WTS Startup -> ${pass_green}
    END

Check wts startup
    ${old_timeout} =         Set Timeout        45 seconds
    ${out} =        Read Until Regexp       CHANGE STATE: ACTIVE - SimMode is ready now
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Set Timeout       ${old_timeout}

Check proxy to eNB connection
    ${out} =        Read Until Regexp       Airphone: Address Distribution is complete
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Check NG link
    ${out} =        Read Until Regexp       NG Link to gNB\=2 is now Active
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Check address distribution
    ${out} =        Read Until Regexp       Airphone: Address Distribution is complete
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Check Cell setup completed
    ${out} =        Read Until Regexp       Airphone: Cell Setup completed for \\[CELL_ID:1\\]
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Check MIB
    ${out} =        Read Until Regexp       eNB 2 cell 1: MasterInformationBlock-NR Updated
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Check SIB
    ${out} =        Read Until Regexp       eNB 2 cell 1: SystemInformationBlockType2-NR updated
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Start X2 AP link
    Write    enb_x2_link_up enb\=1 target\=2
    ${out} =    Read Until Regexp    X2AP Link with GNB-2 (.*?)* is up
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Register UE
    Telnet.Write    ue_register id\=1
    ${out} =    Read Until Regexp   Received REGISTRATION COMPLETE from UE
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Sleep    1s
    Telnet.Write    ue_pdu_session_setup pdu\=1 gw\=1 ue\=1 nwslice\=1
    ${out} =    Read Until Regexp    PDU SESSION (.*?)*1 setup/reestablishment complete
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Attach UE
    Telnet.Write    ue_attach id=11
    ${out} =    Read Until Regexp    UE IS ACTIVE
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    enb_ue_dc_start target_gnb\=2 target_cells\=1 ue\=11 bearer\=2 type\=split_scg
    ${out} =    Read Until Regexp       Proxy (.*?)* reported successful RA
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Start traffic NSA
    Telnet.Write    trf_data_start ue\=11 id\=2 dir\=dl kbps\=100
    Telnet.Write    trf_data_start ue\=11 id\=2 dir\=ul kbps\=100

Start traffic SA
    Telnet.Write    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl kbps\=100
    ${out} =    Read Until Regexp       Started Downlink Internal traffic
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul kbps\=100
    ${out} =    Read Until Regexp       Started Uplink Internal traffic
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}

Stop traffic NSA
    Telnet.Write    trf_data_stop ue\=11 id\=2 dir\=dl
    ${out} =    Read Until Regexp       Traffic was stopped

    Telnet.Write    trf_data_stop ue\=11 id\=2 dir\=ul
    ${out} =    Read Until Regexp       Traffic was stopped

Stop traffic SA
    Telnet.Write    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=dl
    ${out} =    Read Until Regexp       Stopped Downlink Internal traffic

    Telnet.Write    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=ul
    ${out} =    Read Until Regexp       Stopping Uplink Internal traffic

Check traffic stats
    [Arguments]     ${traffic_stats}
    ${bytes_sent} =     Should Match Regexp    ${traffic_stats}    Bytes sent \\s*\\d*     flags=MULTILINE
    ${o}=    Fetch From Right    ${bytes_sent}     Bytes sent
    ${sent}=    Strip String    ${o}
    ${bytes_received} =     Should Match Regexp    ${traffic_stats}    Bytes received \\s*\\d*    flags=MULTILINE
    ${o}=    Fetch From Right    ${bytes_received}     Bytes received
    ${received}=    Strip String    ${o}
    Log    "received ${received}"
    Log    "sent ${sent}"
    Check stats    ${sent}    ${received}

Check stats
    [Arguments]     ${sent}     ${rec}
    ${sent}=    Convert To Number  ${sent}
    ${rec}=    Convert To Number  ${rec}
    ${div}=    Evaluate    ${rec} / ${sent}
    ${traffic_per}=    Evaluate    ${div} * 100
    Log    "traffic received at ${traffic_per} %"
    Should Be True    ${traffic_per} >= ${95.0}

Check traffic stats NSA
    [Arguments]     ${ue}   ${dir}
    #Empty the read buffer
    ${out} =    Telnet.Read
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    bearer_stats ue\=${ue} id\=2 dir\=${dir} type\=l3 format\=short
    ${out} =    Read Until Regexp       Average packet interval
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Check traffic stats    ${out}

Check traffic stats SA
    [Arguments]     ${ue}   ${pdu}   ${dir}
    #Empty the read buffer
    ${out} =    Telnet.Read
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Telnet.Write    bearer_stats ue\=${ue} pdu\=${pdu} qfi\=1 dir\=${dir}
    ${out} =    Read Until Regexp       Average packet interval
    Append To File    ${EGATE_LOGS_FILE_PATH}    ${out}
    Check traffic stats    ${out}

Check traffic stats until it match SA
    [Arguments]      ${ue}   ${pdu}   ${dir}
    Wait Until Keyword Succeeds
    ...    ${GLOBAL_RETRY_AMOUNT}
    ...    ${GLOBAL_RETRY_INTERVAL}
    ...    Check traffic stats SA     ${ue}   ${pdu}   ${dir}

Check traffic stats until it match NSA
    [Arguments]      ${ue}   ${dir}
    Wait Until Keyword Succeeds
    ...    ${GLOBAL_RETRY_AMOUNT}
    ...    ${GLOBAL_RETRY_INTERVAL}
    ...    Check traffic stats NSA     ${ue}   ${dir}


Flush egate logs
    Telnet.write    sim_log_set flush

Telnet open new connection
    ${session_id}    Telnet.Open Connection
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
    [Arguments]     ${CFG_FILE_PATH}
    Telnet.write    cfg file=${CFG_FILE_PATH}

Get wts container ip from other docker
    [Documentation]     Use dig (from dnsutils on debian) to find the ip address of wts container
    ${container_prefix} =        Get Environment Variable       COMPOSE_PROJECT_NAME
    ${wts_container_name} =     Catenate        SEPARATOR=      ${container_prefix}     _wts
    ${wts_ip} =     Run Process    dig      ${wts_container_name}       +short
    [Return]        ${wts_ip.stdout}
