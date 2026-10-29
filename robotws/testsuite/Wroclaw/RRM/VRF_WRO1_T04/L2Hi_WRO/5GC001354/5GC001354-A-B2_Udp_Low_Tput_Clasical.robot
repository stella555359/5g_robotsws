*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Michal Brychcy (michal.brychcy@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
5GC001354-A-B2_Nsa_Non_Gbr_Drb_Retransmission_of_lost_Pdcp_Pdus_Over_X2u_Interface_Udp_Low_Tput_Clasical
    Attach Ue With Sgnb
    Start Dl Data Traffic    mbps=5mbps    protocol=udp
    Force Packet Losts On X2-U
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If 1354-A X2 Retx Grp6 Counters Were Incremented
    Detach Ue    ue_id=11
