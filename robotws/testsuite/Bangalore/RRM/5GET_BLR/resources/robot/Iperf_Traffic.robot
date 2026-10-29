*** Settings ***
Documentation		IPERF Data Traffic keywords
...			author: Ragunath Seenan
...			contact: ragunath.seenan@nokia.com
...			in case of changes please contact author,
...			do not modify without permission

*** Variables ***
${TRAFFIC_DL_RATE}             5
${TRAFFIC_UL_RATE}             2
${TRAFFIC_DURATION}            1
${ymlUteLinuxTrimCrLf}         tr -d '\r\n'

*** Keywords ***

Verify Traffic Data
    [Arguments]    ${direction}    ${throughput}
    [Documentation]    Checks Throughput and Duration of traffic
    ${result}                  Return Grep Match    /tmp/iperf_${direction}.txt    " Mbits/sec"
    ${actualLines}             Get Line Count    ${result}
    ${actualTime}              Evaluate    ${actualLines} / 60
    ${expectedLines}           Evaluate    ${TRAFFIC_DURATION} * 60 - 5
    ${errMsg}                  Catenate    ${direction} Traffic duration: ${actualTime} mins
    ...                        | Expected Duration ${TRAFFIC_DURATION} mins
    Should Match Regexp        ${result}    ([^\n]+Mbits/sec[^\n]+\n){${expectedLines}}    msg=${errMsg}
    Should Not Match Regexp    ${result}    ([^${throughput}]|\d{2,})\.\d+ Mbits/sec
    ...                        msg=${direction} Traffic is less than ${throughput} Mbits/sec

Kill Processes with PID
    [Arguments]    ${process}    ${pgrepArgs}=${EMPTY}
    ...            ${sudo}=${EMPTY}    ${killArgs}=${EMPTY}
    [Documentation]    Use "kill" to stop a proccess by its process ID (PID) from a host machine
    ...                If process does not exist return from this keyword.
    ...                String: "[sudo] password for ute: " will be removed in case of sudo prompt.
    ...                Parameters:
    ...                1. processes - list of processes to kill
    ...                2. pgrepArgs - additional pgrep arguments
    ...                3. killArgs - additional kill arguments
    ...                4. sudo - put "sudo" if desired to run with sudo rights

    ${type}                           Evaluate    type(${process}).__name__
    ${pattern}                        Run Keyword If    "${type}" == "list"    Evaluate    "|".join(${process})
    ...                               ELSE    Remove String    ${process}
    ${result}                         Get Pgrep Process ID    ${pattern}    ${pgrepArgs}    sudo=${sudo}
    ${pid}                            Remove String    ${result}    [sudo] password for ute:${SPACE}
    Return From Keyword if            "${pid}" == "${EMPTY}"    "Processes do not exist"
    ${command}                        Catenate    ${sudo} kill -9 ${killArgs} ${pid}
    Run                               ${command}
	Sleep                             3 sec
    Pgrep Process Should Not Exist    ${pattern}

Iperf in Linux
    [Arguments]    ${args}=${EMPTY}    ${pipeArgs}=${EMPTY}
    ${result}    Run Keyword    Start Process    iperf ${args} ${pipeArgs}    shell=${TRUE}
    [Return]    ${result}

Return Grep Match
    [Arguments]    ${file}    ${pattern}    ${postPipe}=${EMPTY}
    ${result}    Run    grep ${pattern} ${file} ${postPipe}

    [Return]    ${result}

Pgrep Process Should Not Exist
    [Arguments]    ${pattern}    ${sudo}=${EMPTY}    ${args}=-c
    ${command}    Catenate    ${sudo} pgrep ${args} "${pattern}" | ${ymlUteLinuxTrimCrLf}
    ${result}     Run    ${command}
    Should Be Equal    "${result}"    "0"    msg=${pattern} is still running!

Get Pgrep Process ID
    [Arguments]    ${pattern}    ${args}=${EMPTY}    ${sudo}=sudo
    [Documentation]    Use "pgrep" to get the proccess ID (PID) of a process name from a host machine
    ...                Parameters:
    ...                1. pattern - pattern used by pgrep to match a running process
    ...                2. args - additional pgrep arguments
    ...                3. sudo - put "sudo" if desired to run with sudo rights
    ...                Returns: Process ID (PID) if pattern has a match, else returns EMPTY

    ${command}    Catenate    sudo pgrep ${args} "${pattern}" | ${ymlUteLinuxTrimCrLf}
    ${result}     Run    ${command}
    [Return]    ${result}

Verify UDP Downlink Traffic Data Rate
    [Documentation]    Run DL Traffic and Verify Throughput
    Set Suite Variable                 ${g_TrafficDlStatus}    ${FALSE}
    Iperf in Linux             args=-c 1.2.4.2 -u -p 7070 -l 1300 -b ${TRAFFIC_DL_RATE}M -i 1 -t 1200
    Iperf in Linux             args=-s -u -p 7070 -i 1 -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_DL.txt
    Log to Console                     Running DL Traffic for ${TRAFFIC_DURATION} minutes
    Sleep                              ${TRAFFIC_DURATION} minutes
    Kill Processes with PID    "iperf"    pgrepArgs=-d ' '
    ...                                sudo=sudo -S
    Verify Traffic Data                DL    5
    Set Suite Variable                 ${g_TrafficDlStatus}    ${TRUE}

Verify UDP Uplink Traffic Data Rate
    [Documentation]    Run UL Traffic and Verify Throughput
    Set Suite Variable                 ${g_TrafficUlStatus}    ${FALSE}
    Iperf in Linux             args=-c 72.23.0.1 -u -p 7070 -l 1300 -b ${TRAFFIC_UL_RATE}M -i 1 -t 1200
    Iperf in Linux             args=-s -u -p 7070 -i 1 -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_UL.txt
    Log to console                     Running UL Traffic for ${TRAFFIC_DURATION} minutes
    Sleep                              ${TRAFFIC_DURATION} minutes
    Kill Processes with PID    "iperf"    pgrepArgs=-d ' '
    ...                                sudo=sudo -S
    Verify Traffic Data                UL    2
    Set Suite Variable                 ${g_TrafficUlStatus}    ${TRUE}

Start TCP Downlink Iperf Data
    [Arguments]    ${dl_ue_ip}    ${dl_port}    ${option}
    [Documentation]    Run TCP DL Iperf Data Traffic
    Iperf in Linux             args=-s -p ${dl_port} -i 1 -B 10.0.2.1
    Iperf in Linux             args=-c ${dl_ue_ip} -p ${dl_port} -l 1400 -i 1 ${option} -B 10.0.2.1 
    ...                                pipeArgs=| tee /tmp/iperf_DL.txt
    Log to Console                     Running TCP DL Traffic

Start TCP Uplink Iperf Data
    [Arguments]    ${ul_ue_ip}    ${ul_port}    ${option}
    [Documentation]    Run TCP UL Iperf Data Traffic
    Iperf in Linux             args=-s -p ${ul_port} -i 1 -B 10.0.2.1
    Iperf in Linux             args=-c ${ul_ue_ip} -p ${ul_port} -l 1400 -i 1 ${option} -B 10.0.2.1
    ...                                pipeArgs=| tee /tmp/iperf_UL.txt
    Log to console                     Running TCP UL Traffic

Stop Iperf Traffic
    [Documentation]    Stop Iperf Traffic
    Kill Processes with PID    "iperf"    pgrepArgs=-d ' '
    ...                                sudo=sudo -S

Verify Traffic
    [Documentation]    Verify Traffic
    ${traffic}        Catenate    ${g_TrafficDlStatus} and ${g_TrafficUlStatus}
    Should Be True    ${traffic}    msg=Traffic Failed!
