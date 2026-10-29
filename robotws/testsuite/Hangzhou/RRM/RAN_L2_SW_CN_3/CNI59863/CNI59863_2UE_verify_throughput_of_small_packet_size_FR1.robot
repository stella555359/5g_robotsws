# *** Settings ***
# Documentation    Author: lin.6.wang@nokia-sbell.com
# ...    QC case full name: CNI59863_2UE_verify_throughput_of_normal_packet_size_FR1
# ...    QC case full name: CNI59863_2UE_verify_throughput_of_small_packet_size_FR1
# ...    1)Preconditions
# ...    BTS state is configured and RRU is online
# ...    Releated parameters is set correctly：
# ...    rdMaxSdusPerSlot：cmwave: 1920
# ...    RdMaxSdusPerUE：cmwave：192
# ...    Cell is up
# ...    2)Postconditions
# ...    UE will not be crashed and release by sending 300 byte packet DL data.
# ...    UE throughput is normal by sending 1400 byte packet DL data.
# 
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_KL_AP_SA_L1B_CMWV        5G_RAN_TDD
# ...               FR1        5G00    QCD_MN_5G    QCP_5G    CDRT
# Library           ute_fsmaccess
# Resource          ../resources/KISS/robot/common_resource.robot
# 
# *** Variables ***
# ${SCF_DIR_PATH}         ${CURDIR}/config
# ${UE_ID1}            1
# ${UE_ID2}            2
# ${PDU_ID1}           1
# ${PDU_ID2}           2
# ${GW_ID1}            1
# ${GW_ID2}            2
# ${SLICE_ID}          1
# ${PROFILE_ID}       1
# ${GNB_ID}           2
# ${CELL_ID}          1
# ${BEARER_ID}        2
# ${DL_LOG}                /tmp/dl_server.log
# ${DL_PORT}               7070
# ${DL_IPERF_SERVER1}       1.2.4.2
# ${DL_IPERF_SERVER2}       1.2.4.3
# ${DL_BAND_WIDTH}         100
# ${MAX_REBOOT_TL_TIME}    1
# ${BIND_HOST}             10.0.2.1
# @{LOG_NAME_LIST}    btslog    ap_syslog       tshark    bip    ap_bip    egatelog
# 
# *** Test Cases ***
# CNI59863_2UE_verify_throughput_of_normal_packet_size_FR1
#     [Tags]
#     BTS state is configured and RRU is online
#     Cell is up
#     UE1 can attach successfully to 5G cell
#     UE2 can attach successfully to 5G cell
#     DL and UL data is normal
#     Detach UE1 and UE2
# 
# 
# CNI59863_2UE_verify_throughput_of_small_packet_size_FR1
#     [Tags]
#     BTS state is configured and RRU is online
#     Cell is up
#     UE1 can attach successfully to 5G cell
#     UE2 can attach successfully to 5G cell
#     DL and UL data is normal and gnb status is statble
#     Detach UE1 and UE2
# 
# *** Keywords ***
# 
# BTS state is configured and RRU is online
#     Reboot TestLine And Make Sure GNB is Configured
# 
# Detach UE1 and UE2
#     Airphone SA Detach  ${UE_ID1}  300
#     Airphone SA Detach  ${UE_ID2}  300
# 
# Cell is up
#     Modify TL VM And AP SCTP Configuration
#     Start Wts And Wait Bts Until Onair    ${SCF_DIR_PATH}${/}${SW_BRANCH}${/}WTS${/}basic_wts.cfg    3000
# 
# UE1 can attach successfully to 5G cell
#     Airphone SA Attach    ${UE_ID1}    300
#     Airphone Pdu Session Setup     ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}   ${GW_ID1}
# 
# UE2 can attach successfully to 5G cell
#     Airphone SA Attach    ${UE_ID2}    300
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}   ${GW_ID2}
# 
# DL and UL data is normal
#     ${pc_info}    Create List    127.0.0.1    ute    ute    22
#     Start Udp Iperf Client    ${pc_info}    ${DL_IPERF_SERVER1}    ${DL_PORT}    ${DL_BAND_WIDTH}  packet_size=1400  alias=dl_client1
#     Start Udp Iperf Server    ${pc_info}    ${DL_PORT}    /tmp/dl_server1.log   bind_host=${BIND_HOST}    alias=dl_server1
#     Start Udp Iperf Client    ${pc_info}    ${DL_IPERF_SERVER2}    ${DL_PORT}    ${DL_BAND_WIDTH}  packet_size=1400  alias=dl_client2
#     Start Udp Iperf Server    ${pc_info}    ${DL_PORT}    /tmp/dl_server2.log   bind_host=${BIND_HOST}    alias=dl_server2
#     Wait Throughput Timer    15
#     ${sa_dl_tput1}=    Get Iperf Throughput    /tmp/dl_server1.log
#     ${sa_dl_tput2}=    Get Iperf Throughput    /tmp/dl_server2.log
#     Stop Iperf Client     ${DL_IPERF_SERVER1}    ${DL_PORT}    alias=dl_client1
#     Stop Iperf Server     ${DL_PORT}    alias=dl_server1
#     Stop Iperf Client     ${DL_IPERF_SERVER2}    ${DL_PORT}    alias=dl_client2
#     Stop Iperf Server     ${DL_PORT}    alias=dl_server2
#     ${dl_assert_status}=    Evaluate    200<int(${sa_dl_tput1})+int(${sa_dl_tput2})
#     Should Be True    ${dl_assert_status}
# 
# 
# DL and UL data is normal and gnb status is statble
#     ${pc_info}    Create List    127.0.0.1    ute    ute    22
#     Start Udp Iperf Client    ${pc_info}    ${DL_IPERF_SERVER1}    ${DL_PORT}    ${DL_BAND_WIDTH}  packet_size=300  alias=dl_client1
#     Start Udp Iperf Server    ${pc_info}    ${DL_PORT}    /tmp/dl_server1.log   bind_host=${BIND_HOST}    alias=dl_server1
#     Start Udp Iperf Client    ${pc_info}    ${DL_IPERF_SERVER2}    ${DL_PORT}    ${DL_BAND_WIDTH}  packet_size=300  alias=dl_client2
#     Start Udp Iperf Server    ${pc_info}    ${DL_PORT}    /tmp/dl_server2.log   bind_host=${BIND_HOST}    alias=dl_server2
#     Wait Throughput Timer    15
#     ${sa_dl_tput1}=    Get Iperf Throughput    /tmp/dl_server1.log
#     ${sa_dl_tput2}=    Get Iperf Throughput    /tmp/dl_server2.log
#     Stop Iperf Client     ${DL_IPERF_SERVER1}    ${DL_PORT}    alias=dl_client1
#     Stop Iperf Server     ${DL_PORT}    alias=dl_server1
#     Stop Iperf Client     ${DL_IPERF_SERVER2}    ${DL_PORT}    alias=dl_client2
#     Stop Iperf Server     ${DL_PORT}    alias=dl_server2
#     ${dl_assert_status}=    Evaluate    0<int(${sa_dl_tput1})+int(${sa_dl_tput2})
#     Should Be True    ${dl_assert_status}
# 
# 
