*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${CAPABILITIES_07}                      SAMSUNGKB
${CAPABILITIES_03}                      NOKIA
${REBOOT_UE}                            ${False}
${REBOOT_UE_TIMEOUT}                    100
${COLLECT_LOGS_DURING_DATA_TRANSFER}    ${False}

${DURATION_TC07_UDP_DL}                 120s
${THROUGHPUT_TC07_UDP_DL}               380 MBits/sec
${DEVIATION_TC07_UDP_DL}                10%
${PARAREL_STREAMS_TC07_UDP_DL}          1
${SIZE_PACKET_TC07_UDP_DL}              1400B
${BUFFER_CLIENT_TC07_UDP_DL}            ${None}
${BUFFER_SERVER_TC07_UDP_DL}            ${None}
${INTERVAL_TC07_UDP_DL}                 1
${QCI_TC07_UDP_DL}                      ${None}
${LINUX_CONGESTION_TC07_UDP_DL}         ${None}

${DURATION_TC07_UDP_UL}                 120s
${THROUGHPUT_TC07_UDP_UL}               70 MBits/sec
${DEVIATION_TC07_UDP_UL}                10%
${PARAREL_STREAMS_TC07_UDP_UL}          1
${SIZE_PACKET_TC07_UDP_UL}              1400B
${BUFFER_CLIENT_TC07_UDP_UL}            ${None}
${BUFFER_SERVER_TC07_UDP_UL}            ${None}
${INTERVAL_TC07_UDP_UL}                 1
${QCI_TC07_UDP_UL}                      ${None}
${LINUX_CONGESTION_TC07_UDP_UL}         ${None}

${DURATION_TC03_UDP_DL}                 120s
${THROUGHPUT_TC03_UDP_DL}               190 MBits/sec
${DEVIATION_TC03_UDP_DL}                10%
${PARAREL_STREAMS_TC03_UDP_DL}          1
${SIZE_PACKET_TC03_UDP_DL}              1400B
${BUFFER_CLIENT_TC03_UDP_DL}            ${None}
${BUFFER_SERVER_TC03_UDP_DL}            ${None}
${INTERVAL_TC03_UDP_DL}                 1
${QCI_TC03_UDP_DL}                      ${None}
${LINUX_CONGESTION_TC03_UDP_DL}         ${None}

${DURATION_TC03_UDP_UL}                 120s
${THROUGHPUT_TC03_UDP_UL}               70 MBits/sec
${DEVIATION_TC03_UDP_UL}                10%
${PARAREL_STREAMS_TC03_UDP_UL}          1
${SIZE_PACKET_TC03_UDP_UL}              1400B
${BUFFER_CLIENT_TC03_UDP_UL}            ${None}
${BUFFER_SERVER_TC03_UDP_UL}            ${None}
${INTERVAL_TC03_UDP_UL}                 1
${QCI_TC03_UDP_UL}                      ${None}
${LINUX_CONGESTION_TC03_UDP_UL}         ${None}

*** Keywords ***
Prepare Ue For TC07
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES_07}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=${CAPABILITIES_07}

Prepare Ue For TC03
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES_03}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=${CAPABILITIES_03}

Run One Way UDP DL TC07 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC07_UDP_DL}
    ...    tput=${THROUGHPUT_TC07_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC07_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC07_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC07_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC07_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC07_UDP_DL}
    ...    interval=${INTERVAL_TC07_UDP_DL}
    ...    qci=${QCI_TC07_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC07_UDP_DL}
    ...    alias=${CAPABILITIES_07}

Run One Way UDP UL TC07 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC07_UDP_UL}
    ...    tput=${THROUGHPUT_TC07_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC07_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC07_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC07_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC07_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC07_UDP_UL}
    ...    interval=${INTERVAL_TC07_UDP_UL}
    ...    qci=${QCI_TC07_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC07_UDP_UL}
    ...    alias=${CAPABILITIES_07}

Run One Way UDP DL TC03 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TC03_UDP_DL}
    ...    tput=${THROUGHPUT_TC03_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC03_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TC03_UDP_DL}
    ...    size_packet=${SIZE_PACKET_TC03_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TC03_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_TC03_UDP_DL}
    ...    interval=${INTERVAL_TC03_UDP_DL}
    ...    qci=${QCI_TC03_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TC03_UDP_DL}
    ...    alias=${CAPABILITIES_03}

Run One Way UDP UL TC03 Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TC03_UDP_UL}
    ...    tput=${THROUGHPUT_TC03_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_TC03_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TC03_UDP_UL}
    ...    size_packet=${SIZE_PACKET_TC03_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TC03_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_TC03_UDP_UL}
    ...    interval=${INTERVAL_TC03_UDP_UL}
    ...    qci=${QCI_TC03_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TC03_UDP_UL}
    ...    alias=${CAPABILITIES_03}
