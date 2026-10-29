*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com

Resource       taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource       taf/rfrl/ue/robot/REAL_UE.robot
*** Variables ***
${CAPABILITIES}                     REAL_UE
${REBOOT_UE}                        ${True}
${REBOOT_UE_TIMEOUT}                100

${DURATION_UDP_DL}                  300s
${THROUGHPUT_UDP_DL}                1200 Mbits/sec
${DEVIATION_UDP_DL}                 2.5%
${PARAREL_STREAMS_UDP_DL}           4
${SIZE_PACKET_UDP_DL}               1400B
${BUFFER_CLIENT_UDP_DL}             ${None}
${BUFFER_SERVER_UDP_DL}             ${None}
${INTERVAL_UDP_DL}                  1
${QCI_UDP_DL}                       ${None}
${LINUX_CONGESTION_UDP_DL}          reno

${DURATION_UDP_UL}                  300s
${THROUGHPUT_UDP_UL}                60 Mbits/sec
${DEVIATION_UDP_UL}                 2.5%
${PARAREL_STREAMS_UDP_UL}           2
${SIZE_PACKET_UDP_UL}               1400B
${BUFFER_CLIENT_UDP_UL}             ${None}
${BUFFER_SERVER_UDP_UL}             ${None}
${INTERVAL_UDP_UL}                  1
${QCI_UDP_UL}                       ${None}
${LINUX_CONGESTION_UDP_UL}          reno

*** Keywords ***
Set Allowed Alarms
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled

Set Allowed Alarms With Diagnostic Files
    Set Test Variable    @{allowed_alarms}      SSH enabled
    ...                                         R&D Service Port enabled
    ...                                         Service account root access is enabled
    ...                                         Ethernet port security is disabled
    ...                                         Radio Diagnostic Files collected

Prepare CR1900 Ue
    Prepare Ue for L3 Call
    ...    capabilities=${CAPABILITIES}
    ...    reboot_ue=${REBOOT_UE}
    ...    timeout_reboot_ue=${REBOOT_UE_TIMEOUT}
    ...    alias=CR1900_UE

Run One Way UDP DL Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=DL
    ...    duration=${DURATION_UDP_DL}
    ...    tput=${THROUGHPUT_UDP_DL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_UDP_DL}
    ...    parallel_streams=${PARAREL_STREAMS_UDP_DL}
    ...    size_packet=${SIZE_PACKET_UDP_DL}
    ...    buffer_client=${BUFFER_CLIENT_UDP_DL}
    ...    buffer_server=${BUFFER_SERVER_UDP_DL}
    ...    interval=${INTERVAL_UDP_DL}
    ...    qci=${QCI_UDP_DL}
    ...    linux_congestion=${LINUX_CONGESTION_UDP_DL}
    ...    alias=CR1900_UE

Run One Way UDP UL Data Transfer
    Run Keyword And Continue On Failure    Verify L3 Call One Way Data Transfer
    ...    direction=UL
    ...    duration=${DURATION_UDP_UL}
    ...    tput=${THROUGHPUT_UDP_UL}
    ...    protocol=udp
    ...    deviation=${DEVIATION_UDP_UL}
    ...    parallel_streams=${PARAREL_STREAMS_UDP_UL}
    ...    size_packet=${SIZE_PACKET_UDP_UL}
    ...    buffer_client=${BUFFER_CLIENT_UDP_UL}
    ...    buffer_server=${BUFFER_SERVER_UDP_UL}
    ...    interval=${INTERVAL_UDP_UL}
    ...    qci=${QCI_UDP_UL}
    ...    linux_congestion=${LINUX_CONGESTION_UDP_UL}
    ...    alias=CR1900_UE
