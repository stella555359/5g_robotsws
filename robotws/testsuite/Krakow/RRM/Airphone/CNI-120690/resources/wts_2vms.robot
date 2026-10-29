*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Library      String
Library      OperatingSystem
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations     WITH NAME    ru
Library      taf.rfrl.bts.devices.du.du_operations.GenericDuOperations  bts_type=GNB     WITH NAME    bbu
Library      taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations     WITH NAME    cell
Library      taf.hw.pdu       WITH NAME    pdu
Library      ute_wtssim
Variables    status_regex.py


*** Variables ***
${EGATE_PORT}=         10000
${EDAEMON_PORT}=       22222
${WTS_DIR}             /opt/wts/latest
${DEFAULT_WTS_CFG}     /opt/wts/latest/basic_setup.cfg
${SSH_USERNAME}=       ute
${SSH_PASSWORD}=       UTE.debian12
${SSH_PORT}=           22
${SSH_PROMPT}=         \$${Empty}
${PDU_INFO}=           ${tl.ues[1].l1.common_units[0].pdu_port.pdu}

*** Keywords ***
Start and configure WTS
    [Arguments]    ${alias}    ${hostname}    ${wts_cfg_path}=${DEFAULT_WTS_CFG}
    Log To Console    -----Starting WTS configuration on ${alias}-----
    Run Keyword And Ignore Error    Setup edaemon with all arguments    alias=${alias}    hostname=${hostname}
    ute_wtssim.Start Edaemon Process    alias=${alias}
    Run Keyword And Ignore Error    Setup egate with all arguments    alias=${alias}    hostname=${hostname}
    ute_wtssim.Start Egate Process    alias=${alias}
    ute_wtssim.Execute Egate Command    cfg file\=${wts_cfg_path}    timeout=300    alias=${alias}
    ...    pass_regexp=SCTP proxy link
    Ensure Egate state    alias=${alias}

Stop Edaemon and Egate processes
    [Documentation]    Kill edaemon and egate if already running.
    [Arguments]    ${alias}
    Log To Console    -----Stopping Edaemon process if running on host ${alias}-----
    ${edaemon_pid}=    taf_ssh.execute  pgrep edaemon  connection=${alias}
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    taf_ssh.execute  sudo pkill -9 edaemon  connection=${alias}
    Log To Console    -----Stopping Egate process if running on host ${alias}-----
    ${egate_pid}=    taf_ssh.execute  pgrep egate  connection=${alias}
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    taf_ssh.execute  pkill -9 egate  connection=${alias}

Configure UTE ETH3 interface
    [Documentation]    Test Case to execute IP add commands via SSH for addresses from 131 to 137
    [Arguments]    ${alias}
    FOR    ${i}    IN RANGE    131    138
        ${ip_address}=    Set Variable    10.0.1.${i}/24
        ${command}=    Set Variable    sudo ip addr add ${ip_address} dev eth3
        taf_ssh.execute  ${command}  connection=${alias}
    END

Configure UTE ETH2 interface
    [Documentation]    Test Case to execute IP add commands via SSH for addresses from 141 to 147
    [Arguments]    ${alias}
    FOR    ${i}    IN RANGE    141    148
        ${ip_address}=    Set Variable    10.0.1.${i}/24
        ${command}=    Set Variable    sudo ip addr add ${ip_address} dev eth2
        taf_ssh.execute  ${command}  connection=${alias}
    END

Connect to virtual machine
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    [Arguments]    ${alias}    ${hostname}
    taf_ssh.Connect to     hostname=${hostname}
    ...                    username=${SSH_USERNAME}
    ...                    password=${SSH_PASSWORD}
    ...                    alias=${alias}
    [Return]    ${alias}

Setup egate with all arguments
    [Arguments]    ${alias}    ${hostname}
    Setup egate
    ...     egate_port=${EGATE_PORT}
    ...     host_ip=${hostname}
    ...     tool_dir=${WTS_DIR}
    ...     ssh_user=${SSH_USERNAME}
    ...     ssh_pass=${SSH_PASSWORD}
    ...     ssh_port=${SSH_PORT}
    ...     ssh_prompt=${SSH_PROMPT}
    ...     alias=${alias}

Setup edaemon with all arguments
    [Arguments]    ${alias}    ${hostname}
    Setup edaemon
    ...     edaemon_port=${EDAEMON_PORT}
    ...     host_ip=${hostname}
    ...     tool_dir=${WTS_DIR}
    ...     ssh_user=${SSH_USERNAME}
    ...     ssh_pass=${SSH_PASSWORD}
    ...     ssh_port=${SSH_PORT}
    ...     ssh_prompt=${SSH_PROMPT}
    ...     alias=${alias}

Check And Stop Egate And Edaemon Then Reboot If Necessary
    [Documentation]    Checks if egate or edaemon process is running. If any is running, stops both processes and reboots AirPhone.
    [Arguments]    ${alias}    ${PDU_PORT}
    ${egate_stdout}=    taf_ssh.execute    pgrep egate    connection=${alias}
    ${egate_stdout}=    Strip String    ${egate_stdout}
    ${is_egate_running}=    Set Variable If    '${egate_stdout}' != ''    ${True}    ${False}
    ${edaemon_stdout}=    taf_ssh.execute    pgrep edaemon    connection=${alias}
    ${edaemon_stdout}=    Strip String    ${edaemon_stdout}
    ${is_edaemon_running}=    Set Variable If    '${edaemon_stdout}' != ''    ${True}    ${False}
    ${any_process_running}=    Evaluate    ${is_egate_running} or ${is_edaemon_running}
    ${console_log}=    Set Variable If    ${any_process_running}
    ...    INF: Egate or Edaemon process is running on host ${alias}! Executing stop and reboot commands.
    ...    INF: Neither Egate nor Edaemon process is running on host ${alias}.
    Log To Console    ${console_log}
    Run Keyword If    ${any_process_running}    Run Keywords    Stop Edaemon and Egate processes    ${alias}
    ...    AND    Reset AP via PDU    ${PDU_PORT}    ${alias}
    [Return]    ${any_process_running}

Ensure Egate state
    [Arguments]    ${alias}
    Wait Until Keyword Succeeds
    ...    120sec
    ...    15sec
    ...    Execute Egate Command    state_sim_disp    pass_regexp=The state is ACTIVE   timeout=15   alias=${alias}

Ensure NG Link is Up
    [Arguments]    ${alias}    ${amf_id}=1    ${gnb_id}=2    ${type}=link_info
    Wait Until Keyword Succeeds    360s    60s    Execute Egate Command and wait for data
    ...    cmd=amf_disp id=${amf_id} type=${type} gnb=${gnb_id}
    ...    timeout=60s    pass_regexp=NG primary peer address.*up   alias=${alias}

Wait for gNB To Be Ready
    Wait Until Keyword Succeeds     15min     30sec     bbu.verify_bts_states    procedural_state=${bts_up_state}
    Wait Until Keyword Succeeds     15min     30sec     ru.verify_all_radio_units_are_online
    Wait Until Keyword Succeeds     15min     30sec     cell.verify_all_cells_statuses    procedural_status=${cell_state}

Validate given expression in egate_console
    [Arguments]    ${alias}    ${pass_regexp}=Pass
    Log    Checking given "${pass_regexp}" expression in egate_console.log on host ${alias}...
    Wait Until Keyword Succeeds    5min    30s    taf_ssh.execute
    ...    cmd=grep "${pass_regexp}" /opt/wts/latest/egate_console.log
    ...    connection=${alias}

Validate WTS regexp
    [Arguments]    ${reg_list}    ${alias}
    Log To Console    -----Data validation in egate_console.log for ${alias} ongoing-----
    FOR    ${regexp}    IN    @{reg_list}
        Validate given expression in egate_console    pass_regexp=${regexp}    alias=${alias}
    END

Check AP Ping is Reachable
    [Documentation]    Check if AP is available
    [Arguments]    ${alias}
    ${stdout}=    taf_ssh.execute    ping -c 3 192.168.200.1    connection=${alias}
    ${received_lines}=         Get Regexp Matches    ${stdout}    packets transmitted, +(\\d+)    1
    ${received_packets}=    Evaluate    1 if int(${received_lines}[0]) == 3 else 0
    ${console_log}=    Set Variable If    ${received_packets}==1    INF:AP ${alias} is reachable!    WRN:VM ping AP NOK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    ${received_packets}==1    ${True}    ${False}
    Should Be True    ${received_packets}==1
    [Return]    ${status}

Check AP Ping is Not Reachable
    [Documentation]    Check if AP is NOT available
    [Arguments]    ${alias}
    ${stdout}=    taf_ssh.execute    ping -c 3 192.168.200.1  connection=${alias}
    ${received_lines}=         Get Regexp Matches    ${stdout}    packets transmitted, +(\\d+)    1
    ${received_packets}=    Evaluate    1 if int(${received_lines}[0]) > 0 else 0
    ${console_log}=    Set Variable If    ${received_packets}==0    INF:AP ${alias} is NOT reachable! Reboot ongoing...
    ...    WRN:VM ping AP OK!
    Log To Console    ${console_log}
    ${status}=    Set Variable If    ${received_packets}==0    ${False}    ${True}
    Should Be True    ${received_packets}==0
    [Return]    ${status}

Check And Kill admin API Process
    [Documentation]    This keyword is used to check status of admin api process and kill the process if it is still running
    ${rc}    ${op}    Run And Return Rc And Output     ps -aef | grep -i admin | grep -v grep
    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${op}
    Run Keyword If    ${status}     Run And Return Rc And Output    sudo pkill node

Power Off Hardware
    [Arguments]    ${PDU_PORT}    ${model}
    Log To Console    -----Power Off Start-----
    pdu.Setup Pdu    model=${model}
    pdu.Power Off    port=${PDU_PORT}
    ${port_status}    pdu.Get Port Status    port=${PDU_PORT}
    Sleep    5s
    should be equal    ${port_status}    off

Power On Hardware
    [Arguments]    ${PDU_PORT}    ${model}
    Log To Console    -----Power On Start-----
    pdu.Setup Pdu    model=${model}
    pdu.Power On    port=${PDU_PORT}
    ${port_status}    pdu.Get Port Status    port=${PDU_PORT}
    sleep    5s
    should be equal    ${port_status}    on

Reset AP via PDU
    [Arguments]    ${PDU_PORT}    ${alias}    ${model}=${PDU_INFO}
    Power Off Hardware    model=${model}    PDU_PORT=${PDU_PORT}
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping is Not Reachable    alias=${alias}
    sleep    30s
    Power On Hardware    model=${model}    PDU_PORT=${PDU_PORT}
    Wait Until Keyword Succeeds    120s    5s    Check AP Ping is Reachable    alias=${alias}
