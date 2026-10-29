*** Settings ***
Library    taf.ue.tm500.rci    WITH NAME    rci
Library    ../rrm_fixture.py
Library    ./traffic.py
Resource   ../connections.robot

*** Variables ***
# Viavi data transfer reference values
${VIAVI UPLINK}=           4
${VIAVI DOWNLINK}=         18

${IPERF PATH COBHAM}=      C:\iperf\

${THROUGHPUT START}
${THROUGHPUT END}
${THROUGHPUT STATS}
${THROUGHPUT LOGS}

${IPERF UPLINK CMD}
${IPERF DOWNLINK CMD}


*** Keywords ***
Change throughput parameters
    [Arguments]   ${iperf_ul}=5
    ...           ${iperf_dl}=40
    ...           ${traffic_time}=60
    ...           ${viavi_down}=18
    ...           ${viavi_up}=4
   set global variable     ${TRAFFIC UL VALUE IN Mbps}   ${iperf_ul}
   set global variable     ${TRAFFIC DL VALUE IN Mbps}   ${iperf_dl}
   set global variable     ${THROUGHPUT TIME}            ${traffic_time}
   set global variable     ${VIAVI UPLINK}               ${viavi_up}
   set global variable     ${VIAVI DOWNLINK}             ${viavi_down}


Start traffic and check results
    Connect with ASIK and epcsim
    Start traffic          epcsim ssh alias=epcsim
    ...                    asik ssh alias=ASIK
    Sleep                  ${THROUGHPUT TIME}
    Stop traffic           epcsim ssh alias=epcsim
    ...                    asik ssh alias=ASIK

    ${THROUGHPUT STATS}=   rci.Send Command
    ...                    forw mte getstats [0] [0] [1]
    ${THROUGHPUT LOGS}=    Get Throughput Logs
    ...                    asik ssh alias=ASIK

    Log                    Throughput Stats:\n${THROUGHPUT STATS}
    String to File         ${test_name}_throughput_stats
    ...                    ${THROUGHPUT STATS}
    Log                    Journalctl throughput logs from ASIK:\n${THROUGHPUT LOGS}
    String to File         ${test_name}_throughput_journal_logs
    ...                    ${THROUGHPUT LOGS}

    Set Global Variable    ${THROUGHPUT STATS}
    Set Global Variable    ${THROUGHPUT LOGS}

    Throughput results analyse


Connect with ASIK and epcsim
    Connect to ASIK
    Connect to EPCsim
    rci.Connect To         ${tl.ues[0].tma_host.addr}
    ...                    ${tl.ues[0].tma_command_port}

Start traffic
    [Documentation]   Set up environment for throughput and start iperf processes
    [Arguments]              ${tm500 alias}=${None}
    ...                      ${epcsim ssh alias}=${None}
    ...                      ${asik ssh alias}=${None}
    ${IPERF UPLINK CMD}=     iperf_uplink_command     transmit_time_in_sec=${THROUGHPUT TIME}
    ${IPERF DOWNLINK CMD}=   iperf_downlink_command   transmit_time_in_sec=${THROUGHPUT TIME}
    Set Global Variable      ${IPERF DOWNLINK CMD}
    # Start PPPoE adapter
    rci.Send Command       SHELL (C:/windows/system32/cmd.exe /c "rasdial TM500") 1
    ...                    alias=${tm500 alias}

    rci.Send Command       SHELL (${IPERF PATH COBHAM}\\${IPERF UPLINK CMD})
    ...                    alias=${tm500 alias}
    ssh.Send Command       ${IPERF DOWNLINK CMD}
    ...                    connection=${epcsim ssh alias}
    # Let iperf warm up, so that the averages are correct
    # There is a period in logs where reported stats are lower than actual
    Sleep                  1
    ${THROUGHPUT START}=   Get current time
    ...                    ${asik ssh alias}
    Set Global Variable    ${THROUGHPUT START}

Stop traffic
    [Documentation]        Stop previously started iperf processes
    [Arguments]            ${tm500 alias}=${None}
    ...                    ${epcsim ssh alias}=${None}
    ...                    ${asik ssh alias}=${None}
    ${THROUGHPUT END}=     Get current time
    ...                    ${asik ssh alias}
    Set Global Variable    ${THROUGHPUT END}
    # Let iperf cool down, so that the averages are correct
    # There is a period in logs where reported stats are lower than actual
    Sleep                  1
    ssh.Execute            pkill -f "${IPERF DOWNLINK CMD}"
    ...                    connection=${epcsim ssh alias}

    rci.Send Command       SHELL (C:/windows/system32/cmd.exe /c taskkill /F /IM iperf.exe) 1
    ...                    alias=${tm500 alias}

Get throughput logs
    [Documentation]        Gather throughput statistics from gNB
    [Arguments]            ${asik ssh alias}=${None}
    ...                    ${start_time}=${THROUGHPUT START}
    ...                    ${stop_time}=${THROUGHPUT END}
    ${command}=            catenate  SEPARATOR=${SPACE}
    ...                    journalctl --since\="${start_time}" --until\="${stop_time}" --no-pager
    ...                    \| grep -e "-L2_LO_UL_0" -e "-L2_LO_TB_BUI0" -e "L-RLC numOfBearers"
    ${THROUGHPUT LOGS}=    ssh.Execute
    ...                    ${command}
    ...                    connection=${asik ssh alias}
    ...                    timeout=120s
    [Return]               ${THROUGHPUT LOGS}

Get current time
    [Arguments]            ${ssh alias}=${None}
    ${timestamp}=          ssh.execute
    ...                    date "+%G-%m-%e %H:%M:%S"
    ...                    connection=ASIK
    [Return]               ${timestamp.strip()}

Throughput results analyse
    ${averages}=           Get Average UL DL Throughput    ${THROUGHPUT LOGS}
    ${UL Mbits}=           Set variable                    ${averages[0]}
    ${DL Mbits}=           Set variable                    ${averages[1]}
    Log to console         Uplink:\t${UL Mbits} Mbit/s
    Log to console         Downlink:\t${DL Mbits} Mbit/s
    should be true         ${UL Mbits} >= ${VIAVI UPLINK}
    should be true         ${DL Mbits} >= ${VIAVI DOWNLINK}

Start DL traffic and check sum of throughput on 4G and 5G
    [Arguments]    ${TRAFFIC DL VALUE IN Mbps}=60
    ...            ${THROUGHPUT TIME}=120
    Set Global Variable    ${TRAFFIC DL VALUE IN Mbps}
    Set Global Variable    ${THROUGHPUT TIME}
    Connect to EPCsim
    rci.Send Command       forw mte ClearStats
    Start DL traffic       epcsim ssh alias=epcsim
    Sleep                  ${THROUGHPUT TIME}
    ${UE STATS 4G}=        rci.Send Command
    ...                    forw mte getstats [1] [0] [0]
    ${UE STATS 5G}=        rci.Send Command
    ...                    forw mte getstats [1] [0] [1]
    Stop DL traffic        epcsim ssh alias=epcsim
    Log                    Throughput Stats for 4G: ${UE STATS 4G}
    String to File         ${test_name}_throughput_stats_4G
    ...                    ${UE STATS 4G}
    Log                    Throughput Stats for 5G: ${UE STATS 5G}
    String to File         ${test_name}_throughput_stats_5G
    ...                    ${UE STATS 5G}
    Set Global Variable    ${UE STATS 4G}
    Set Global Variable    ${UE STATS 5G}
    ${throughput}=         get traffic values for 4g 5g   log4G=${UE STATS 4G}   log5G=${UE STATS 5G}
    ${throughput 4G}=      Set Variable   ${throughput[0]}
    ${throughput 5G}=      Set Variable   ${throughput[1]}
    ${throughput diff}=    Set Variable   ${throughput[2]}
    Log to console         DL sent: ${TRAFFIC DL VALUE IN Mbps} Mbps
    Log to console         DL received: 4G = ${throughput 4G} Mbps + 5G = ${throughput 5G} Mbps
    Should Be True         ${throughput diff}   Difference between sent and received traffic is bigger than 5%
    Log to console         Difference between sent and received traffic is less than 5%

Start DL traffic
    [Documentation]   Set up environment for throughput and start iperf process
    [Arguments]              ${tm500 alias}=${None}
    ...                      ${epcsim ssh alias}=${None}
    ${IPERF DOWNLINK CMD}=   iperf_downlink_command   transmit_time_in_sec=${THROUGHPUT TIME}
    Set Global Variable      ${IPERF DOWNLINK CMD}
    # Start PPPoE adapter
    rci.Send Command       SHELL (C:/windows/system32/cmd.exe /c "rasdial TM500") 1
    ...                    alias=${tm500 alias}

    ssh.Send Command       ${IPERF DOWNLINK CMD}
    ...                    connection=${epcsim ssh alias}

Stop DL traffic
    [Documentation]        Stop previously started iperf process
    [Arguments]            ${tm500 alias}=${None}
    ...                    ${epcsim ssh alias}=${None}
    ssh.Execute            pkill -f "${IPERF DOWNLINK CMD}"
    ...                    connection=${epcsim ssh alias}


Start traffic with tafUE
    Connect to ASIK
    ${epcsim_alias}=  Connect to EPCsim
    ${uepc_alias}=    Connect to UEPC
    ${IPERF UPLINK CMD}=     iperf_uplink_command     transmit_time_in_sec=${THROUGHPUT TIME}
	${IPERF DOWNLINK CMD}=   iperf_downlink_command   transmit_time_in_sec=${THROUGHPUT TIME}
    Set Global Variable      ${IPERF DOWNLINK CMD}
    ssh.Execute        command=rasdial TM500           connection=${uepc_alias}
    ssh.Send Command   command=${IPERF UPLINK CMD}     connection=${uepc_alias}
    ssh.Send Command   command=${IPERF DOWNLINK CMD}   connection=${epcsim_alias}
    # Let iperf warm up, so that the averages are correct
    # There is a period in logs where reported stats are lower than actual
    Sleep                  10s
    ${THROUGHPUT START}=   Get current time
    ...                    ASIK
    Set Global Variable    ${THROUGHPUT START}


Stop traffic with tafUE
    [Documentation]        Stop previously started iperf processes
    [Arguments]            ${ue alias}=UE_ALIAS
    ...                    ${epcsim ssh alias}=epcsim
    ...                    ${asik ssh alias}=ASIK
    ${THROUGHPUT END}=     Get current time
    ...                    ${asik ssh alias}
    Set Global Variable    ${THROUGHPUT END}
    # Let iperf cool down, so that the averages are correct
    # There is a period in logs where reported stats are lower than actual
    Sleep                  1
    ssh.Execute            pkill -f "${IPERF DOWNLINK CMD}"
    ...                    connection=${epcsim ssh alias}
    ssh.Execute            taskkill /F /IM iperf.exe
    ...                    connection=${ue alias}
