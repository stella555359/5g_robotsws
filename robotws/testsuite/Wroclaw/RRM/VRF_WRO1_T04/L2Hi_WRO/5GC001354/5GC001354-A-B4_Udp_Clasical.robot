*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
5GC001354-A-B4_Nsa_Non_Gbr_Drb_Retransmission_Of_Lost_Duplicated_PDU_X2_Udp_Classical
    Attach Ue With Sgnb
    Start Dl Data Traffic    mbps=120mbps    protocol=udp
    Force Packet Losts On X2-U
    Check For Ddds Messages Existence Due To Periodic Duplicate Transmission
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 06 Were Incremented
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    Verify If 1354-A Counters For Qos Group 06 Were Incremented
    Detach Ue    ue_id=11
