# # # @Time    : 2021/10/25 14:53
# # # @Author  : Jian.1.Chen
# # # @Email   : jian.1.chen@nokia-sbell.com
# # # @File    : Globe_Lab_Specific_SRAN_LTE.robot
# # # @Software: PyCharm
# # # @Doc     : Globe Lab LTE Test Case
# # *** Settings ***
# # Force Tags    PY36    CRT_TRUNK
# # #Resource    Resources/Globe_Lab_LTE_Keywords.robot
# # #Resource    Resources/Globe_Lab_LTE_Precondition.robot
# # #Suite Setup    Globe Common Suite Setup
# # 
# # *** Variables ***
# # #----------Static Variables----------
# # ${UE_INDEX}             0
# # ${ATTACH_EXEC_COUNT}    1
# # ${PING_COUNT}           5
# # ${HANDOVER_EXEC_COUNT}  1
# # ${DL_DURATION}          120
# # ${DL_PORT}              3456
# # ${UL_DURATION}          120
# # ${UL_PORT}              4567
# # ${LOW_PACKET_SIZE}      32
# # ${MIDDLE_PACKET_SIZE}   1000
# # ${HIGH_PACKET_SIZE}     1400
# # ${pi_id_1}              M8012C187
# # ${pi_id_2}              M8012C191
# # ${pi_id_3}              M8012C188
# # ${pi_id_4}              M8012C192
# # ${MOC_CELL_12}          LNCEL-12
# # ${MOC_CELL_13}          LNCEL-13
# # #----------Dynamic Variables----------
# # ${CONTROL PC ADDR}          ${tl.ues[${UE_INDEX}].ssh_connection_details.addr}
# # ${ENB0 DIST}                MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
# # ${ENB0 DIST CELL11}         ${ENB0 DIST}/LNCEL-11
# # ${ENB0 DIST CELL12}         ${ENB0 DIST}/LNCEL-12
# # ${ENB0 DIST CELL12 RESEL}   ${ENB0 DIST}/LNCEL-12/SIB-0
# # ${ENB0 DIST CELL13}         ${ENB0 DIST}/LNCEL-13
# # ${ENB0 DIST MME0}           ${ENB0 DIST}/LNMME-0
# # ${ENB0 DIST MME1}           ${ENB0 DIST}/LNMME-1
# # ${ENB0 LNADJ ID NUM}        /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${tl.enbs[0].global_bts_id}/LNADJ_R-255
# # ${ENB1 DIST}                MRBTS-${tl.enbs[1].instance_id}/LNBTS-${tl.enbs[1].global_bts_id}
# # ${ENB1 DIST CELL1}          ${ENB1 DIST}/LNCEL-1
# # ${ENB1 DIST CELL2}          ${ENB1 DIST}/LNCEL-2
# # ${ENB1 DIST CELL2 RESEL}    ${ENB1 DIST}/LNCEL-2/SIB-0
# # ${ENB1 DIST CELL3}          ${ENB1 DIST}/LNCEL-3
# # ${ENB1 DIFT MME0}           ${ENB1 DIST}/LNMME-0
# # ${ENB1 DIFT MME1}           ${ENB1 DIST}/LNMME-1
# # ${ENB1 DIST CELL8}          ${ENB1 DIST}/LNCEL-8
# # ${ENB1 DIST CELL8 RESEL}    ${ENB1 DIST}/LNCEL-8/SIB-0
# # ${ENB1 LNADJ ID NUM}        /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${tl.enbs[1].global_bts_id}/LNADJ_R-255
# # 
# # #*** Test Cases ***
# # #UE Attach
# # #    [Documentation]    To verify UE Attach procedure
# # #    [Tags]    case-BFT-1-1  basic
# # #    [Setup]    Case BFT 1-1 Precondition
# # #    Start Capture Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    Repeat Keyword    ${ATTACH_EXEC_COUNT}    UE Attach And Detach
# # #    Collect Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    Verify UE Attach By Wireshark Log    file_name=${TC NAME}.pcap
# # #
# # #UE Detach
# # #    [Documentation]    To verify UE Detach procedure
# # #    [Tags]    case-BFT-1-2    basic
# # #    [Setup]    Case BFT 1-2 Precondition
# # #    Start Capture Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    Repeat Keyword    ${ATTACH_EXEC_COUNT}    UE Attach And Detach
# # #    Collect Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    Verify UE Attach By Wireshark Log    file_name=${TC NAME}.pcap
# # #
# # #UE Idle To Active
# # #    [Documentation]    To verify UE Idle to Active procedure
# # #    [Tags]    case-BFT-1-3
# # #    [Setup]    Case BFT 1-3 Precondition
# # #    UE Attach And Verify 4G
# # #    Stop Capture Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    sleep  30
# # #    ${ping_result}    UE Ping Ftp Server    ftp_server_ip=${CONTROL PC ADDR}
# # #    Collect Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    Verify UE Idle By Wireshark Log     file_name=${TC NAME}.pcap
# # #    [Teardown]  UE UE detach
# # #
# # #Round Trip Delay
# # #    [Documentation]    Measure latency by ping command with 32, 1000 & 1400 Bytes packet size
# # #    [Tags]    case-BFT-2-1    basic
# # #    UE Attach And Verify 4G
# # #    ${ping_result}    UE Ping Ftp Server
# # #    ...     ftp_server_ip=${CONTROL PC ADDR}    packet_size=${LOW_PACKET_SIZE}      ping_times=${PING_COUNT}
# # #    Verify Ping Result No Packet Loss     ping_result=${ping_result}
# # #    ${ping_result}    UE Ping Ftp Server
# # #    ...     ftp_server_ip=${CONTROL PC ADDR}    packet_size=${MIDDLE_PACKET_SIZE}    ping_times=${PING_COUNT}
# # #    Verify Ping Result No Packet Loss     ping_result=${ping_result}
# # #    ${ping_result}    UE Ping Ftp Server
# # #    ...     ftp_server_ip=${CONTROL PC ADDR}    packet_size=${HIGH_PACKET_SIZE}    ping_times=${PING_COUNT}
# # #    Verify Ping Result No Packet Loss     ping_result=${ping_result}
# # #    [Teardown]    UE UE detach
# # #
# # #Intra eNodeB Handover
# # #    [Documentation]    To verify intra eNodeB Handover
# # #    [Tags]    case-BFT-3-1
# # #    [Setup]    Case BFT 3-1 Precondition
# # #    UE Attach And Verify 4G
# # #    UE Start DL Traffic    throughput=100M
# # #    Verify Enb1 Support Handover To Enb2
# # #    Verify Enb2 Support Handover To Enb1
# # #    [Teardown]    Run Keywords    Close the iperf process on APPserver    port=${DL_PORT}    AND    UE UE detach
# # #
# # #Inter eNodeB Handover
# # #    [Documentation]    To verify inter eNodeB Handover
# # #    [Tags]    case-BFT-3-2    basic
# # #    [Setup]    Case BFT 3-2 Precondition
# # #    Verify enbs support handover multiple times     exec_num=${HANDOVER_EXEC_COUNT}
# # #    [Teardown]    UE UE detach
# # #
# # #Single UE Downlink Throughput
# # #    [Documentation]    Measure single UE downlink MIMO TCP throughput in one sector.
# # #    ...                Observe and record the average/peak throughput
# # #    [Tags]    case-BFT-5-1    basic
# # #    [Setup]    Case BFT 5-1 Precondition
# # #    Keep Enb1 Single Cell12 Unlock
# # #    UE Start DL Traffic    throughput=100M
# # #    ${counter}    Collect Download PM Counter    pi_id_1=${pi_id_1}    pi_id_2=${pi_id_2}    moc=${MOC_CELL_12}    wait_time=${DL_DURATION}
# # #    Should Be True    ${counter}>90
# # #    Keep Enb1 Single Cell13 Unlock
# # #    UE Start DL Traffic    throughput=100M
# # #    ${counter}    Collect Download PM Counter    pi_id_1=${pi_id_1}    pi_id_2=${pi_id_2}    moc=${MOC_CELL_13}    wait_time=${DL_DURATION}
# # #    Keep Enb1 Cell12 And Cell13 Unlock
# # #    UE Start DL Traffic    throughput=100M
# # #    Collect Download PM Counter    pi_id_1=${pi_id_3}    pi_id_2=${pi_id_4}    moc=${MOC_CELL_13}    wait_time=${DL_DURATION}
# # #
# # #
# # #Single UE Uplink Throughput
# # #    [Documentation]    Measure single UE uplink TCP throughput in one sector.
# # #    ...                Observe and record the average/peak throughput
# # #    [Tags]    case-BFT-5-2    basic
# # #    [Setup]    Case BFT 5-2 Precondition
# # #    Keep Enb1 Single Cell12 Unlock
# # #    Collect Upload PM Counter    pi_id=${pi_id_1}    moc=${MOC_CELL_12}    wait_time=${UL_DURATION}
# # #    Keep Enb1 Single Cell13 Unlock
# # #    Collect Upload PM Counter    pi_id=${pi_id_1}    moc=${MOC_CELL_13}    wait_time=${UL_DURATION}
# # #
# # #eNodeB Initialization
# # #    [Documentation]    To verify all equipped units can be recovered and return to service after eNodeB reset
# # #    [Setup]    Case BFT 6-1 Precondition
# # #    [Tags]    case-BFT-6-1
# # #    UE Attach And Verify 4G
# # #    ${ping_result}    UE Ping Ftp Server    ftp_server_ip=${CONTROL PC ADDR}
# # #    ${start_time}    Get Time    epoch
# # #    Connect to eNB via ssl
# # #    enblte.reset_site    timeout=10min    connection=enblte    wait_for_reconnection=TRUE
# # #    Wait Until Keyword Succeeds    10min    5s    Check enb status is in cell on air status
# # #    ${end_time}    Get Time    epoch
# # #    ${reset_duration}    Evaluate    ${end_time}-${start_time}
# # #    Should Be True    ${reset_duration}<600
# # #    UE Attach And Verify 4G
# # #    ${ping_result}    UE Ping Ftp Server    ftp_server_ip=${CONTROL PC ADDR}
# # #    [Teardown]    Run Keywords    Enblte close down    AND    UE UE detach
# # #
# # #No Ciphering and Integrity protection using AES algorithm
# # #    [Documentation]    Verify No Ciphering + Integrity protection using AES algorithm works normal
# # #    [Tags]    case-PDFT-1-1
# # #    No Operation
# # #
# # #Ciphering and Integrity protection using AES algorithm
# # #    [Documentation]    Verify Ciphering + Integrity protection using AES algorithm works normal
# # #    [Tags]    case-PDFT-1-2
# # #    No Operation
# # #
# # #S1 Establishment
# # #    [Documentation]    To validate 2 S1 links between eNB and MMEs
# # #    [Tags]    case-PDFT-2-1
# # #    [Setup]    Case PDFT 2-1 Precondition
# # #    Verify S1 Link Established After Reboot ENB    file_name=${TC NAME}_REBOOT_ENB.pcap
# # #    UE Attach And Verify 4G
# # #    UE Start DL Traffic    throughput=100M
# # #    [Teardown]    UE UE detach
# # #
# # #S1 Setup Release Restart
# # #    [Documentation]    To validate S1 SETUP Release/Restart procedure with S1-flex configuration
# # #    [Tags]    case-PDFT-2-2
# # #    [Setup]    Case PDFT 2-2 Precondition
# # #    Verify S1 Link Established After Reboot MME    file_name=${TC NAME}_REBOOT_MME.pcap
# # #    UE Attach And Verify 4G
# # #    UE Start DL Traffic    throughput=100M
# # #    [Teardown]    UE UE detach
# # #
# # #Inter-MME Idle Mode
# # #    [Documentation]    To validate Inter-MME mobility
# # #    [Tags]    case-PDFT-3-1
# # #    [Setup]    Case PDFT 3-1 Precondition
# # #    UE Attach And Verify 4G
# # #    Close UE 4G Data
# # #    ${old_cell_tac}    Get UE Cell Tac
# # #    Verify Enb1 Support Handover To Enb2
# # #    Verify Enb2 Support Handover To Enb1
# # #    ${latest_cell_tac}    Get UE Cell Tac
# # #    Should Be Equal    ${old_cell_tac}    ${latest_cell_tac}
# # #    [Teardown]    Run Keywords    Open UE 4G Data    AND    UE UE detach
# # #
# # #Inter-MME Connected Mode
# # #    [Documentation]    To validate Inter-MME mobility
# # #    [Tags]    case-PDFT-3-2
# # #    [Setup]    Case PDFT 3-2 Precondition
# # #    UE Attach And Verify 4G
# # #    UE Ping In Background    ftp_server_ip=${CONTROL PC ADDR}
# # #    ${old_cell_tac}    Get UE Cell Tac
# # #    Verify Enb1 Support Handover To Enb2
# # #    Verify Enb2 Support Handover To Enb1
# # #    ${latest_cell_tac}    Get UE Cell Tac
# # #    Should Be Equal    ${old_cell_tac}    ${latest_cell_tac}
# # #    [Teardown]    UE UE detach
# # #
# # #Intra-LTE Intra-Freq Mobility Reselection
# # #    [Documentation]    Verify the intra-LTE intra-frequency reselection
# # #    [Tags]    case-PDFT-4-1   basic
# # #    [Setup]    Case PDFT 4-1 Precondition
# # #    UE Attach And Verify 4G
# # #    Close UE 4G Data
# # #    ${old_cell_tac}    Get UE Cell Tac
# # #    Verify Enb1 Support Handover To Enb2
# # #    Verify Enb2 Support Handover To Enb1
# # #    ${latest_cell_tac}    Get UE Cell Tac
# # #    Should Be Equal    ${old_cell_tac}    ${latest_cell_tac}
# # #    [Teardown]    Run Keywords    Open UE 4G Data    AND    UE UE detach
# # #
# # #Intra-LTE Intra-Freq Mobility Handover
# # #    [Documentation]    Verify the intra-LTE intra-frequency handover
# # #    [Tags]    case-PDFT-4-2   basic
# # #    [Setup]    Case PDFT 4-2 Precondition
# # #    UE Attach And Verify 4G
# # #    UE Ping In Background    ftp_server_ip=${CONTROL PC ADDR}
# # #    ${old_cell_tac}    Get UE Cell Tac
# # #    Verify Enb1 Support Handover To Enb2
# # #    Verify Enb2 Support Handover To Enb1
# # #    ${latest_cell_tac}    Get UE Cell Tac
# # #    Should Be Equal    ${old_cell_tac}    ${latest_cell_tac}
# # #    [Teardown]    UE UE detach
# # #
# # #Intra-LTE Inter-Freq Cell Reselection to Higher Priority Cell
# # #    [Documentation]    Verify the inter-frequency cell reselection priority
# # #    [Tags]    case-PDFT-5-1    basic
# # #    [Setup]    Case PDFT 5-1 Precondition
# # #    UE Attach And Verify 4G
# # #    Close UE 4G Data
# # #    Verify Enb1 Support Handover To Enb2
# # #    [Teardown]    Run Keywords    Open UE 4G Data    AND    UE UE detach
# # #
# # #Intra-LTE Inter-Freq Cell Reselection to Lower Priority Cell
# # #    [Documentation]    Verify the inter-frequency cell reselection priority
# # #    [Tags]    case-PDFT-5-2    basic
# # #    [Setup]    Case PDFT 5-2 Precondition
# # #    UE Attach And Verify 4G
# # #    Close UE 4G Data
# # #    Verify Enb1 Support Handover To Enb2
# # #    [Teardown]    Run Keywords    Open UE 4G Data    AND    UE UE detach
# # #
# # #Intra Frequency ANR
# # #    [Documentation]    Check that new neighbour relation and X2 link can be created by ANR.
# # #    ...                X2 handover is successful after creating X2 link
# # #    [Tags]    case-PDFT-6-1
# # #    [Setup]    Case PDFT 6-1 Precondition
# # #    No Operation
# # #
# # #Inter Frequency ANR
# # #    [Documentation]    Check that new neighbour relation and X2 link can be created by ANR.
# # #    ...                X2 handover is successful after creating X2 link
# # #    [Tags]    case-PDFT-6-2
# # #    [Setup]    Case PDFT 6-2 Precondition
# # #    UE Attach And Verify 4G
# # #    Start Capture Wireshark Log On BTS    file_name=${TC NAME}.pcap
# # #    UE Ping In Background    ftp_server_ip=${CONTROL PC ADDR}    packet_size=10000    ping_times=100
# # #    Set PA Make Enb1 Signal Stronger Slowly
# # #    Verify X2 Link Available    enb_index=0    id_num=${ENB0 LNADJ ID NUM}
# # #    Verify X2 Link Available    enb_index=1    id_num=${ENB1 LNADJ ID NUM}
# # #    Collect Wireshark Log On BTS    file_name=${TC NAME}.pcap
