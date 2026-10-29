*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${CAPABILITIES_TC15}                        SAMSUNGKB
${CAPABILITIES_TC17}                        SAMSUNG3V
${REBOOT_UE}                                ${True}
${REBOOT_UE_TIMEOUT}                        100
${COLLECT_LOGS_DURING_DATA_TRANSFER}        ${False}

${DURATION_TC17_Subcase2_UDP_DL}            120s
${THROUGHPUT_TC17_Subcase2_UDP_DL}          1100 MBits/sec
${DEVIATION_TC17_Subcase2_UDP_DL}           10%
${PARAREL_STREAMS_TC17_Subcase2_UDP_DL}     4
${SIZE_PACKET_TC17_Subcase2_UDP_DL}         1400B
${BUFFER_CLIENT_TC17_Subcase2_UDP_DL}       ${None}
${BUFFER_SERVER_TC17_Subcase2_UDP_DL}       ${None}
${INTERVAL_TC17_Subcase2_UDP_DL}            1
${QCI_TC17_Subcase2_UDP_DL}                 ${None}
${LINUX_CONGESTION_TC17_Subcase2_UDP_DL}    ${None}

${DURATION_TC17_Subcase2_UDP_UL}            120s
${THROUGHPUT_TC17_Subcase2_UDP_UL}          80 MBits/sec
${DEVIATION_TC17_Subcase2_UDP_UL}           10%
${PARAREL_STREAMS_TC17_Subcase2_UDP_UL}     1
${SIZE_PACKET_TC17_Subcase2_UDP_UL}         1400B
${BUFFER_CLIENT_TC17_Subcase2_UDP_UL}       ${None}
${BUFFER_SERVER_TC17_Subcase2_UDP_UL}       ${None}
${INTERVAL_TC17_Subcase2_UDP_UL}            1
${QCI_TC17_Subcase2_UDP_UL}                 ${None}
${LINUX_CONGESTION_TC17_Subcase2_UDP_UL}    ${None}

${DURATION_TC17_UDP_DL}                     120s
${THROUGHPUT_TC17_UDP_DL}                   1100 MBits/sec
${DEVIATION_TC17_UDP_DL}                    10%
${PARAREL_STREAMS_TC17_UDP_DL}              4
${SIZE_PACKET_TC17_UDP_DL}                  1400B
${BUFFER_CLIENT_TC17_UDP_DL}                ${None}
${BUFFER_SERVER_TC17_UDP_DL}                ${None}
${INTERVAL_TC17_UDP_DL}                     1
${QCI_TC17_UDP_DL}                          ${None}
${LINUX_CONGESTION_TC17_UDP_DL}             ${None}

${DURATION_TC17_UDP_UL}                     120s
${THROUGHPUT_TC17_UDP_UL}                   80 MBits/sec
${DEVIATION_TC17_UDP_UL}                    10%
${PARAREL_STREAMS_TC17_UDP_UL}              1
${SIZE_PACKET_TC17_UDP_UL}                  1400B
${BUFFER_CLIENT_TC17_UDP_UL}                ${None}
${BUFFER_SERVER_TC17_UDP_UL}                ${None}
${INTERVAL_TC17_UDP_UL}                     1
${QCI_TC17_UDP_UL}                          ${None}
${LINUX_CONGESTION_TC17_UDP_UL}             ${None}

${DURATION_TC15_UDP_DL}                     120s
${THROUGHPUT_TC15_UDP_DL}                   135 MBits/sec
${DEVIATION_TC15_UDP_DL}                    10%
${PARAREL_STREAMS_TC15_UDP_DL}              1
${SIZE_PACKET_TC15_UDP_DL}                  1400B
${BUFFER_CLIENT_TC15_UDP_DL}                ${None}
${BUFFER_SERVER_TC15_UDP_DL}                ${None}
${INTERVAL_TC15_UDP_DL}                     1
${QCI_TC15_UDP_DL}                          ${None}
${LINUX_CONGESTION_TC15_UDP_DL}             ${None}

${DURATION_TC15_UDP_UL}                     120s
${THROUGHPUT_TC15_UDP_UL}                   12 MBits/sec
${DEVIATION_TC15_UDP_UL}                    10%
${PARAREL_STREAMS_TC15_UDP_UL}              1
${SIZE_PACKET_TC15_UDP_UL}                  1400B
${BUFFER_CLIENT_TC15_UDP_UL}                ${None}
${BUFFER_SERVER_TC15_UDP_UL}                ${None}
${INTERVAL_TC15_UDP_UL}                     1
${QCI_TC15_UDP_UL}                          ${None}
${LINUX_CONGESTION_TC15_UDP_UL}             ${None}

*** Keywords ***
Prepare Ue For TC17
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES_TC17}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=${CAPABILITIES_TC17}

Prepare Ue For TC15
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES_TC15}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=${CAPABILITIES_TC15}

Run One Way UDP DL TC17 Subcase2 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC17_Subcase2_UDP_DL}
    ...    tput=${THROUGHPUT_TC17_Subcase2_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC17_Subcase2_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC17_Subcase2_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC17_Subcase2_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC17_Subcase2_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC17_Subcase2_UDP_DL}
    ...    interval=${INTERVAL_TC17_Subcase2_UDP_DL}
    ...    qci=${QCI_TC17_Subcase2_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC17_Subcase2_UDP_DL}
    ...    alias=${CAPABILITIES_TC17}

Run One Way UDP UL TC17 Subcase2 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC17_Subcase2_UDP_UL}
    ...    tput=${THROUGHPUT_TC17_Subcase2_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC17_Subcase2_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC17_Subcase2_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC17_Subcase2_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC17_Subcase2_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC17_Subcase2_UDP_UL}
    ...    interval=${INTERVAL_TC17_Subcase2_UDP_UL}
    ...    qci=${QCI_TC17_Subcase2_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC17_Subcase2_UDP_UL}
    ...    alias=${CAPABILITIES_TC17}

Run One Way UDP DL TC17 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC17_UDP_DL}
    ...    tput=${THROUGHPUT_TC17_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC17_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC17_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC17_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC17_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC17_UDP_DL}
    ...    interval=${INTERVAL_TC17_UDP_DL}
    ...    qci=${QCI_TC17_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC17_UDP_DL}
    ...    alias=${CAPABILITIES_TC17}

Run One Way UDP UL TC17 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC17_UDP_UL}
    ...    tput=${THROUGHPUT_TC17_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC17_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC17_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC17_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC17_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC17_UDP_UL}
    ...    interval=${INTERVAL_TC17_UDP_UL}
    ...    qci=${QCI_TC17_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC17_UDP_UL}
    ...    alias=${CAPABILITIES_TC17}

Run One Way UDP DL TC15 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC15_UDP_DL}
    ...    tput=${THROUGHPUT_TC15_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC15_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC15_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC15_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC15_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC15_UDP_DL}
    ...    interval=${INTERVAL_TC15_UDP_DL}
    ...    qci=${QCI_TC15_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC15_UDP_DL}
    ...    alias=${CAPABILITIES_TC15}

Run One Way UDP UL TC15 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC15_UDP_UL}
    ...    tput=${THROUGHPUT_TC15_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC15_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC15_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC15_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC15_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC15_UDP_UL}
    ...    interval=${INTERVAL_TC15_UDP_UL}
    ...    qci=${QCI_TC15_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC15_UDP_UL}
    ...    alias=${CAPABILITIES_TC15}
