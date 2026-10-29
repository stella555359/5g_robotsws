*** Settings ***
Resource     keywords_5GC001354_AiC.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R1


*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Keywords ***
5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_High_Tput_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start Data Traffic With Tcp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Trigger Radio Link Outage
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Statistics On MCG And SCG
    Wait For Next PM counters Interval
    Verify If 1354-C Threshld 1 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 09
