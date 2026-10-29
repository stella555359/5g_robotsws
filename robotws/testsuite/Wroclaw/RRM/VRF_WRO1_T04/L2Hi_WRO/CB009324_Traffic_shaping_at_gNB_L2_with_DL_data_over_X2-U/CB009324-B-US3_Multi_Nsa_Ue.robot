*** Settings ***
Resource    keywords_CB009324.robot
Resource    ../5GC001354/CB001354_keywords.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R2

*** Variables ***
${TRAFFIC_DURATION_SEC_B3}=   30s
${NUMBER_OF_SA_UES}=       4
${LAST_NSA_UE_ID}=         12

*** Keywords ***
CB009324-B-US3_Traffic_Shaping_For_DL_Split_Traffic_Over_X2-U_For_Multiple_UEs_PDCP_Fast_Retransmissions_And_Forwarded_Data_Over_X2-U
    Attach 4 Nsa Ues With Sgnb And Start Traffic
    Attach Multi Sa Ues And Start Traffic    ${NUMBER_OF_SA_UES}
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC_B3}
    Display Sa Ue Statistics    ${NUMBER_OF_SA_UES}
    Display Bearer Statistics
    Trigger Radio Link Outage Multiple Ues    last_nsa_ue_id=${LAST_NSA_UE_ID}
    Perform Sgnb Release
    Clear Bearer Statistics
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC_B3}
    Display Bearer Statistics
    Verify If Downlink PDCP Pdu QoS Grp 6 Pm Counters Were Incremented
    Verify Pdcp Pdu Packet Lost On X2-U
    Verify Packet Drops At Transport First Level Scheduler
    Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Treshold 1 Transmission Delay Bin Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin Pm Counters Were Incremented
