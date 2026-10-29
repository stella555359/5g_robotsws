*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Resource    taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${CAPABILITIES}                REAL_UE
${REBOOT_UE}                   ${True}
${REBOOT_UE_TIMEOUT}           100

${DURATION_TCP_DL}             120s
${THROUGHPUT_TCP_DL}           900 MBits/sec
${DEVIATION_TCP_DL}            10%
${PARAREL_STREAMS_TCP_DL}      4
${SIZE_PACKET_TCP_DL}          1400B
${BUFFER_CLIENT_TCP_DL}        ${None}
${BUFFER_SERVER_TCP_DL}        ${None}
${INTERVAL_TCP_DL}             1
${QCI_TCP_DL}                  ${None}
${LINUX_CONGESTION_TCP_DL}     reno

${DURATION_TCP_UL}             120s
${THROUGHPUT_TCP_UL}           130 MBits/sec
${DEVIATION_TCP_UL}            10%
${PARAREL_STREAMS_TCP_UL}      2
${SIZE_PACKET_TCP_UL}          1400B
${BUFFER_CLIENT_TCP_UL}        ${None}
${BUFFER_SERVER_TCP_UL}        ${None}
${INTERVAL_TCP_UL}             1
${QCI_TCP_UL}                  ${None}
${LINUX_CONGESTION_TCP_UL}     reno

${COLLECT_LOGS_DURING_DATA_TRANSFER}  ${False}

*** Keywords ***
Prepare Ue
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}

Run One Way TCP DL Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_TCP_DL}
    ...    tput=${THROUGHPUT_TCP_DL}
    ...    protocol=tcp
    ...    deviation=${DEVIATION_TCP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_TCP_DL}
    ...    size_packet=${SIZE_PACKET_TCP_DL}
    ...    buffer_client=${BUFFER_CLIENT_TCP_DL}
    ...    buffer_server=${BUFFER_SERVER_TCP_DL}
    ...    interval=${INTERVAL_TCP_DL}
    ...    qci=${QCI_TCP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_TCP_DL}

Run One Way TCP UL Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_TCP_UL}
    ...    tput=${THROUGHPUT_TCP_UL}
    ...    protocol=tcp
    ...    deviation=${DEVIATION_TCP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_TCP_UL}
    ...    size_packet=${SIZE_PACKET_TCP_UL}
    ...    buffer_client=${BUFFER_CLIENT_TCP_UL}
    ...    buffer_server=${BUFFER_SERVER_TCP_UL}
    ...    interval=${INTERVAL_TCP_UL}
    ...    qci=${QCI_TCP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_TCP_UL}
