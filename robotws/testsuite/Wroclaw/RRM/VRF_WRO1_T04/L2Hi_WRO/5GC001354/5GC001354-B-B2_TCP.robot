*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${UE_DC_ID}=    14
${SCG_BEARER_ID}=    2

*** Keywords ***
5GC001354-B-B2_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_During_Intra_Du_Tcp
    Add Nr Cappa
    Attach Ue With Sgnb    ue_id=${UE_DC_ID}
    Start Dl Data Traffic    ue_id=${UE_DC_ID}    mbps=5mbps    protocol=tcp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 09 Were Incremented
    Trigger Handover To Second Cell
    Check For Ddds Messages Existence Due To Periodic Duplicate Transmission
    Sleep    ${TRAFFIC_DURATION_SEC}
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 09 Were Incremented
    Detach Ue    ue_id=${UE_DC_ID}
