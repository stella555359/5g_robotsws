*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    testsuite/Krakow/resources/DL_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/UL_Throughput_1-DRB_OTA/procedure.robot
Resource    testsuite/Krakow/resources/Bi-Directional_Throughput_1-DRB_OTA/procedure.robot

*** Keywords ***

# CIT SECTION

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_4CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=2242 Mbits/sec
    ...    parallel_streams_dl=4
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_4CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=2242 Mbits/sec
    ...    parallel_streams_dl=4
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_4CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=2242 Mbits/sec
    ...    parallel_streams=4
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_4CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions


Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_8CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=1200s    protocol=udp    deviation=13%
    ...    tput_dl=4149 Mbits/sec
    ...    parallel_streams_dl=8
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_8CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=1200s    protocol=tcp    deviation=13%
    ...    tput_dl=4149 Mbits/sec
    ...    parallel_streams_dl=4
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_8CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=tcp    deviation=13%
    ...    tput=4149 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_8CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_8CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=udp    deviation=13%
    ...    tput=4149 Mbits/sec
    ...    parallel_streams=8
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_8CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

# CRT CONTIGUOUS SECTION

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_2CC_contiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=1127 Mbits/sec
    ...    parallel_streams_dl=2
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_2CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=1127 Mbits/sec
    ...    parallel_streams_dl=2
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_2CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=1127 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_2CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_2CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=1127 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_2CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_3CC_contiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=1679 Mbits/sec
    ...    parallel_streams_dl=3
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_3CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=1679 Mbits/sec
    ...    parallel_streams_dl=2
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_3CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=1679 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_3CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_3CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=1679 Mbits/sec
    ...    parallel_streams=3
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_3CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_4CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=2242 Mbits/sec
    ...    parallel_streams=4
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_4CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_5CC_contiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=2805 Mbits/sec
    ...    parallel_streams_dl=5
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_5CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=2805 Mbits/sec
    ...    parallel_streams_dl=2
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_5CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=2805 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_5CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_5CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=2805 Mbits/sec
    ...    parallel_streams=5
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_5CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_6CC_contiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=3368 Mbits/sec
    ...    parallel_streams_dl=6
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_6CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=3368 Mbits/sec
    ...    parallel_streams_dl=2
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_6CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=3368 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_6CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_6CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=3368 Mbits/sec
    ...    parallel_streams=6
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_6CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_7CC_contiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=3920 Mbits/sec
    ...    parallel_streams_dl=7
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_7CC_contiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=3920 Mbits/sec
    ...    parallel_streams_dl=3
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_7CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=3920 Mbits/sec
    ...    parallel_streams=3
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_7CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_7CC_contiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=3920 Mbits/sec
    ...    parallel_streams=7
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_7CC_contiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

# CRT NONCONTIGUOUS SECTION

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_5CC_noncontiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=2805 Mbits/sec
    ...    parallel_streams_dl=5
    ...    tput_ul=138 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_5CC_noncontiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=2805 Mbits/sec
    ...    parallel_streams_dl=2
    ...    tput_ul=138 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_5CC_noncontiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=2805 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_5CC_noncontiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=138 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_5CC_noncontiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=2805 Mbits/sec
    ...    parallel_streams=5
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_5CC_noncontiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=138 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_7CC_noncontiguous
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput_dl=3920 Mbits/sec
    ...    parallel_streams_dl=7
    ...    tput_ul=138 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_7CC_noncontiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput_dl=3920 Mbits/sec
    ...    parallel_streams_dl=3
    ...    tput_ul=138 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_7CC_noncontiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=3920 Mbits/sec
    ...    parallel_streams=3
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_7CC_noncontiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=tcp    deviation=13%
    ...    tput=138 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_7CC_noncontiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=3920 Mbits/sec
    ...    parallel_streams=7
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_7CC_noncontiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=300s    protocol=udp    deviation=13%
    ...    tput=138 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_8CC_noncontiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=1200s    protocol=udp    deviation=13%
    ...    tput_dl=4149 Mbits/sec
    ...    parallel_streams_dl=8
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${ul_size_packet}
    ...    size_packet_ul=${ul_size_packet}
    ...    buffer_client_dl=${buffer_client_dl}
    ...    buffer_server_dl=${buffer_server_dl}
    ...    buffer_client_ul=${buffer_client_ul}
    ...    buffer_server_ul=${buffer_server_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

Bi-Directional_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_8CC_noncontiguous
    Throughput_Preconditions
    Bi-Directional_Throughput_1-DRB_OTA    capabilities=${capabilities_ue}    duration=1200s    protocol=tcp    deviation=13%
    ...    tput_dl=4149 Mbits/sec
    ...    parallel_streams_dl=4
    ...    tput_ul=253 Mbits/sec
    ...    parallel_streams_ul=2
    ...    size_packet_dl=${size_packet}
    ...    size_packet_ul=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_8CC_noncontiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=tcp    deviation=13%
    ...    tput=4149 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_TCP_1-DRB_OTA_AEUB_eLoner_8CC_noncontiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=tcp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${size_packet}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

DL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_8CC_noncontiguous
    Throughput_Preconditions
    DL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=udp    deviation=13%
    ...    tput=4149 Mbits/sec
    ...    parallel_streams=8
    ...    size_packet=${dl_size_packet}
    ...    buffer_server=${buffer_server_dl}
    ...    buffer_client=${buffer_client_dl}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

UL_Throughput_UDP_1-DRB_OTA_AEUB_eLoner_8CC_noncontiguous
    Throughput_Preconditions
    UL_Throughput_1-DRB_OTA   capabilities=${capabilities_ue}    duration=1200s    protocol=udp    deviation=13%
    ...    tput=253 Mbits/sec
    ...    parallel_streams=2
    ...    size_packet=${ul_size_packet}
    ...    buffer_server=${buffer_server_ul}
    ...    buffer_client=${buffer_client_ul}
    ...    interval=${interval}
    ...    reboot_ue=True
    Throughput_Postconditions

# Throughput_Preconditions & Throughput_Postconditions

Throughput_Preconditions
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}

Throughput_Postconditions
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}

# COMMISSIONING SECTION

Perform_${CC}_contiguous_commissioning
    Perform Full Commissioning on Cloud gNB    prefix_tag=${CC}
    Wait For Site To Be Onair

Perform_${TAG}_contiguous_commissioning_classical
    Perform Full Commissioning on Classical gNB    prefix_tag=${TAG}
    Wait until keyword succeeds    30min    30 sec    Verify gNB is onAir

# LOGS COLLECTION

Try to Collect logs during test
    Run Keyword And Ignore Error     Collect logs during test
