*** Settings ***
Documentation    Author: lily.l.xu@nokia-sbell.com
...              \n SA L3 call example case for RAN HZ L2 SW3.

Suite Setup        Common Suite Setup
Test Setup         Common Test Setup
Test Teardown      Common Test Teardown
Suite Teardown     Common Suite Teardown

Resource                 ../resources/KISS/robot/common_resource.robot
Force Tags               CLOUD_5G_I_KL_AP_KL_SA_L1B_CPRI_CMWV_TDD    Owner_lilxu

*** Variables ***
${SCF_DIR_PATH}         ${CURDIR}/config
${UE_ID}                 1
${PDU_ID}                1
${GW_ID}                 1
${SLICE_ID}              1
${DL_PORT}               7070
${DL_IPERF_SERVER}       1.2.4.2
${DL_BAND_WIDTH}         20
${UL_PORT}               7071
${UL_IPERF_SERVER}       72.23.0.1
${UL_BAND_WIDTH}         10
${BIND_HOST}             10.0.2.1

*** Test Cases ***
5G_L3_Call_SA_Example_Case_With_External_Data
    BTS state is configured and RRU is online
    Cell is up
    Start GNB Ttitrace download
    UE can attach successfully to 5G cell
    External DL and UL data is normal
    Stop and Decode Ttitrace
    UE can detach successfully to 5G cell

5G_L3_Call_SA_Example_Case_With_Internal_Data
    #Reset sim state
    #BTS state is configured and RRU is online
    #Cell is up
    Cell is up without reload cfg file
    Set traffic type to internal
    UE can attach successfully to 5G cell
    Internal DL and UL data is normal
    UE can detach successfully to 5G cell


*** Keywords ***
BTS state is configured and RRU is online
    Reboot TestLine And Make Sure GNB is Configured
    Backup Scf    ${TEST_LOG_DIRECTORY()}    after_commission_scf.xml
    Download All Common Config Files From Golden Server
    Find Match WTS CFG Files And Copy To WorkSpace    scfc_file=${TEST_LOG_DIRECTORY()}/after_commission_scf.xml

Cell is up
    Modify TL VM And AP SCTP Configuration
    Start WTS And Wait BTS Until Onair

Cell is up without reload cfg file
    Modify TL VM And AP SCTP Configuration
    Start WTS And Wait BTS Until Onair    reload=${False}

Set traffic type to internal
    Airphone Set Traffic Type    ${UE_ID}    ${PDU_ID}    internal

Reset sim state
    Airphone Execute Egate Command    reset

UE can attach successfully to 5G cell
    Airphone SA Attach    ${UE_ID}    300
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}   ${GW_ID}

UE can detach successfully to 5G cell
    Airphone SA Detach    ${UE_ID}

External DL and UL data is normal
    ${pc_info}    Create List    127.0.0.1    ute    ute    22
    Start Udp Iperf Client    ${pc_info}    ${DL_IPERF_SERVER}    ${DL_PORT}    ${DL_BAND_WIDTH}    alias=dl_client
    Start Udp Iperf Server    ${pc_info}    ${DL_PORT}    /tmp/dl_server.log   bind_host=${BIND_HOST}    alias=dl_server
    Start Udp Iperf Client    ${pc_info}    ${UL_IPERF_SERVER}    ${UL_PORT}    ${UL_BAND_WIDTH}    alias=ul_client
    Start Udp Iperf Server    ${pc_info}     ${UL_PORT}    /tmp/ul_server.log    bind_host=${BIND_HOST}    alias=ul_server
    Wait Throughput Timer    15
    ${sa_dl_tput}=    Get Iperf Throughput    /tmp/dl_server.log
    ${sa_ul_tput}=    Get Iperf Throughput    /tmp/ul_server.log
    Stop Iperf Client     ${DL_IPERF_SERVER}    ${DL_PORT}    alias=dl_client
    Stop Iperf Server     ${DL_PORT}    alias=dl_server
    Stop Iperf Client     ${UL_IPERF_SERVER}    ${UL_PORT}    alias=ul_client
    Stop Iperf Server     ${UL_PORT}    alias=ul_server
    ${dl_assert_status}=    Evaluate    20*0.5<int(${sa_dl_tput})
    ${ul_assert_status}=    Evaluate    10*0.5<int(${sa_ul_tput})
    Should Be True    ${dl_assert_status}
    Should Be True    ${ul_assert_status}

Internal DL and UL data is normal
    Airphone SA Start Data Traffic    ${UE_ID}     DL    100M    pdu_id=${PDU_ID}
    Airphone SA Start Data Traffic    ${UE_ID}     UL    50M     pdu_id=${PDU_ID}
    Wait Throughput Timer    10s
    ${sa_dl_tput}=    Airphone SA Get Throughput        ${UE_ID}     DL    ${PDU_ID}
    ${sa_ul_tput}=    Airphone SA Get Throughput        ${UE_ID}     UL    ${PDU_ID}
    Airphone SA Stop Data Traffic     ${UE_ID}     BI    ${PDU_ID}
    ${dl_assert_status}=    Evaluate    100*1000*0.5<int(${sa_dl_tput})
    ${ul_assert_status}=    Evaluate    50*1000*0.5<int(${sa_ul_tput})
    Should Be True    ${dl_assert_status}
    Should Be True    ${ul_assert_status}

Start GNB Ttitrace download
    Start GNB Ttitrace With Streaming Mode
    
Stop and Decode Ttitrace
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}${/}first_attach_ttitrace
    # log will save: ../log/L3_Call_20210508091215/5G_L3_Call_SA_Example_Case_With_External_Data/first_attach_ttitrace/l2stream3/tcpdump/tcpdump.pcap
    Download Ttitrace Decode Tool
    Decoder Tttirace From Pcap To Csv       pcap_path=${pacp}      output_path_with_tag=${TEST_LOG_DIRECTORY()}${/}decode_file_tag
    # Decode file will be 2 files:
    #         1. ../log/L3_Call_20210508091215/5G_L3_Call_SA_Example_Case_With_External_Data/decode_file_tag_dl.csv
    #         2. ../log/L3_Call_20210508091215/5G_L3_Call_SA_Example_Case_With_External_Data/decode_file_tag_ul.csv