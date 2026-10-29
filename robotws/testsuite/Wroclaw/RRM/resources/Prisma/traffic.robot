*** Settings ***
Library    ./traffic.py
Resource   ../connections.robot
Library    ../rrm_fixture.py

*** Variables ***
${ABIL MASTER ALIAS}    MASTER
${EPCSIM ALIAS}         epcsim
${PRISMA ALIAS}         prisma

${IPERF PATH PRISMA}   C:\iperf\
${IPERF DOWNLINK CMD}

${DL JOURNAL PATTERN}   L2_LO_TB_BUI0
${UL JOURNAL PATTERN}   L2_LO_UL_0

${TRAFFIC DL VALUE IN Mbps}
${TRAFFIC UL VALUE IN Mbps}
${THROUGHPUT TIME}

${THROUGHPUT START}
${THROUGHPUT END}
${THROUGHPUT LOGS}

${UPLINK REFERENCE VALUE}
${DOWNLINK REFERENCE VALUE}

*** Keywords ***
Change throughput parameters
    [Arguments]   ${iperf_ul}=5
    ...           ${iperf_dl}=40
    ...           ${traffic_time}=60
    ...           ${prisma_down}=18
    ...           ${prisma_up}=4
   set global variable     ${TRAFFIC UL VALUE IN Mbps}   ${iperf_ul}
   set global variable     ${TRAFFIC DL VALUE IN Mbps}   ${iperf_dl}
   set global variable     ${THROUGHPUT TIME}            ${traffic_time}
   set global variable     ${UPLINK REFERENCE VALUE}     ${prisma_up}
   set global variable     ${DOWNLINK REFERENCE VALUE}   ${prisma_down}


Start traffic and check results
    Connect with ASIK and epcsim and Prisma
    Start traffic
    Sleep                 ${THROUGHPUT TIME}   reason=Waiting for end of througput time
    Stop traffic

    ${THROUGHPUT LOGS}=   Get Throughput Logs

    Log                   Journalctl throughput logs from ABIL MASTER:\n${THROUGHPUT LOGS}
    String to File        filename=${test_name}_throughput_journal_logs
    ...                   contents=${THROUGHPUT LOGS}

    Set Global Variable   ${THROUGHPUT LOGS}

    Throughput results analyse


Connect with ASIK and epcsim and Prisma
    Connect to ABIL MASTER
    Connect to EPCsim
    Connect to Prisma


Start traffic
    [Documentation]   Set up environment for throughput and start iperf processes
    [Arguments]              ${epcsim ssh alias}=${EPCSIM ALIAS}
    ...                      ${abil ssh alias}=${ABIL MASTER ALIAS}
    ...                      ${prisma ssh alias}=${PRISMA ALIAS}
    ${IPERF UPLINK CMD}=     iperf_uplink_command     transmit_time_is_sec=${THROUGHPUT TIME}
    ${IPERF DOWNLINK CMD}=   iperf_downlink_command   transmit_time_is_sec=${THROUGHPUT TIME}
    Set Global Variable      ${IPERF DOWNLINK CMD}

    ssh.Send Command         ${IPERF DOWNLINK CMD}
    ...                      connection=${epcsim ssh alias}
    ssh.Send Command         ${IPERF PATH PRISMA}\\${IPERF UPLINK CMD}
    ...                      connection=${prisma ssh alias}
    # Let iperf warm up, so that the averages are correct
    # There is a period in logs where reported stats are lower than actual
    Sleep                    5   reason=Let iperf warm up, so that the averages are correct
    ${THROUGHPUT START}=     Get current time
    ...                      ${abil ssh alias}
    Set Global Variable      ${THROUGHPUT START}


Stop traffic
    [Documentation]   Stop previously started iperf processes
    [Arguments]              ${epcsim ssh alias}=${EPCSIM ALIAS}
    ...                      ${abil ssh alias}=${ABIL MASTER ALIAS}
    ...                      ${prisma ssh alias}=${PRISMA ALIAS}
    ${THROUGHPUT END}=       Get current time
    ...                      ${abil ssh alias}
    Set Global Variable      ${THROUGHPUT END}
    # Let iperf cool down, so that the averages are correct
    # There is a period in logs where reported stats are lower than actual
    Sleep                    1
    ssh.Execute              pkill -f "${IPERF DOWNLINK CMD}"
    ...                      connection=${epcsim ssh alias}
    ssh.Execute              taskkill /F /IM iperf.exe
    ...                      connection=${prisma ssh alias}


Get throughput logs
    [Documentation]   Gather throughput statistics from gNB
    [Arguments]              ${abil master ssh alias}=${ABIL MASTER ALIAS}
    ...                      ${start_time}=${THROUGHPUT START}
    ...                      ${stop_time}=${THROUGHPUT END}
    ${command}=              catenate  SEPARATOR=${SPACE}
    ...                      journalctl --since\="${start_time}" --until\="${stop_time}" --no-pager
    ...                      \| grep -e "${DL JOURNAL PATTERN}" -e "${UL JOURNAL PATTERN}"
    ${THROUGHPUT LOGS}=      ssh.Execute
    ...                      ${command}
    ...                      connection=${abil master ssh alias}
    ...                      timeout=120s
    [Return]                 ${THROUGHPUT LOGS}


Throughput results analyse
    ${averages}=             Get Average UL DL Throughput   ${THROUGHPUT LOGS}
    ${UL Mbits}=             Set variable                   ${averages[0]}
    ${DL Mbits}=             Set variable                   ${averages[1]}
    Log to console           Uplink:\t${UL Mbits} Mbit/s
    Log to console           Downlink:\t${DL Mbits} Mbit/s
    should be true           ${UL Mbits} >= ${UPLINK REFERENCE VALUE}
    should be true           ${DL Mbits} >= ${DOWNLINK REFERENCE VALUE}


Get current time
    [Arguments]              ${ssh alias}=${ABIL MASTER ALIAS}
    ${timestamp}=            ssh.execute
    ...                      date "+%G-%m-%e %H:%M:%S"
    ...                      connection=${ssh alias}
    [Return]                 ${timestamp.strip()}


Connect to Prisma
    [Arguments]              ${alias}=${PRISMA ALIAS}
    ssh.Connect to           hostname=${tl.ues[0].airmosaic_ssh_connection_details.addr}
    ...                      username=${tl.ues[0].airmosaic_ssh_connection_details.username}
    ...                      password=${tl.ues[0].airmosaic_ssh_connection_details.password}
    ...                      alias=${alias}
