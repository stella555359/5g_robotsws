*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${CAPABILITIES}                         SAMSUNG3V
${REBOOT_UE}                            ${True}
${REBOOT_UE_TIMEOUT}                    100
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

${DURATION_TC02_UDP_DL}                 120s
${THROUGHPUT_TC02_UDP_DL}               1100 MBits/sec
${DEVIATION_TC02_UDP_DL}                10%
${PARAREL_STREAMS_TC02_UDP_DL}          4
${SIZE_PACKET_TC02_UDP_DL}              1400B
${BUFFER_CLIENT_TC02_UDP_DL}            ${None}
${BUFFER_SERVER_TC02_UDP_DL}            ${None}
${INTERVAL_TC02_UDP_DL}                 1
${QCI_TC02_UDP_DL}                      ${None}
${LINUX_CONGESTION_TC02_UDP_DL}         ${None}

${DURATION_TC02_UDP_UL}                 120s
${THROUGHPUT_TC02_UDP_UL}               80 MBits/sec
${DEVIATION_TC02_UDP_UL}                10%
${PARAREL_STREAMS_TC02_UDP_UL}          4
${SIZE_PACKET_TC02_UDP_UL}              1400B
${BUFFER_CLIENT_TC02_UDP_UL}            ${None}
${BUFFER_SERVER_TC02_UDP_UL}            ${None}
${INTERVAL_TC02_UDP_UL}                 1
${QCI_TC02_UDP_UL}                      ${None}
${LINUX_CONGESTION_TC02_UDP_UL}         ${None}

${DURATION_TC16_UDP_DL}                 120s
${THROUGHPUT_TC16_UDP_DL}               1100 MBits/sec
${DEVIATION_TC16_UDP_DL}                10%
${PARAREL_STREAMS_TC16_UDP_DL}          4
${SIZE_PACKET_TC16_UDP_DL}              1400B
${BUFFER_CLIENT_TC16_UDP_DL}            ${None}
${BUFFER_SERVER_TC16_UDP_DL}            ${None}
${INTERVAL_TC16_UDP_DL}                 1
${QCI_TC16_UDP_DL}                      ${None}
${LINUX_CONGESTION_TC16_UDP_DL}         ${None}

${DURATION_TC16_UDP_UL}                 120s
${THROUGHPUT_TC16_UDP_UL}               80 MBits/sec
${DEVIATION_TC16_UDP_UL}                10%
${PARAREL_STREAMS_TC16_UDP_UL}          4
${SIZE_PACKET_TC16_UDP_UL}              1400B
${BUFFER_CLIENT_TC16_UDP_UL}            ${None}
${BUFFER_SERVER_TC16_UDP_UL}            ${None}
${INTERVAL_TC16_UDP_UL}                 1
${QCI_TC16_UDP_UL}                      ${None}
${LINUX_CONGESTION_TC16_UDP_UL}         ${None}

*** Keywords ***
Prepare Ue
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=${CAPABILITIES}

Run One Way UDP DL TC02 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC02_UDP_DL}
    ...    tput=${THROUGHPUT_TC02_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC02_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC02_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC02_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC02_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC02_UDP_DL}
    ...    interval=${INTERVAL_TC02_UDP_DL}
    ...    qci=${QCI_TC02_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC02_UDP_DL}
    ...    alias=${CAPABILITIES}

Run One Way UDP UL TC02 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC02_UDP_UL}
    ...    tput=${THROUGHPUT_TC02_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC02_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC02_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC02_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC02_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC02_UDP_UL}
    ...    interval=${INTERVAL_TC02_UDP_UL}
    ...    qci=${QCI_TC02_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC02_UDP_UL}
    ...    alias=${CAPABILITIES}

Run One Way UDP DL TC16 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC16_UDP_DL}
    ...    tput=${THROUGHPUT_TC16_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC16_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC16_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC16_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC16_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC16_UDP_DL}
    ...    interval=${INTERVAL_TC16_UDP_DL}
    ...    qci=${QCI_TC16_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC16_UDP_DL}
    ...    alias=${CAPABILITIES}

Run One Way UDP UL TC16 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC16_UDP_UL}
    ...    tput=${THROUGHPUT_TC16_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC16_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC16_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC16_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC16_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC16_UDP_UL}
    ...    interval=${INTERVAL_TC16_UDP_UL}
    ...    qci=${QCI_TC16_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC16_UDP_UL}
    ...    alias=${CAPABILITIES}
