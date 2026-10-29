*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s

*** Keywords ***
5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Long_Drx_Cycle_Classical
    Attach Ue With Sgnb
    Start Dl Data Traffic    mbps=150mbps
    Trigger Egate Command For Max Attenuation
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin Pm Counters Were Incremented
    Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 06
    Detach Ue    ue_id=11
