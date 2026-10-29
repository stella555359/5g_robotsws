*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R2

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${UE_ID_TDD}=    11
${UE_ID_FDD}=    15
${CELL_ID_FDD}=   3

*** Keywords ***
5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Udp_TDD
    Attach Ue With Sgnb    ue_id=${UE_ID_TDD}
    Start Dl Data Traffic    ue_id=${UE_ID_TDD}    mbps=5mbps    protocol=udp
    Check For Ddds Messages Existence Due To Periodic Duplicate Transmission
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 06 Were Incremented
    Detach Ue    ue_id=${UE_ID_TDD}

5GC001354-B-B1_Nsa_Non_Gbr_Drb_Periodic_Duplicate_Transmission_Of_Pdcp_Pdu_Over_X2_U_Interface_Udp_FDD
    Attach Ue With Sgnb    ue_id=${UE_ID_FDD}    target_cells=${CELL_ID_FDD}
    Start Dl Data Traffic    ue_id=${UE_ID_FDD}    mbps=5mbps    protocol=tcp
    Check For Ddds Messages Existence Due To Periodic Duplicate Transmission
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 06 Were Incremented
    Detach Ue    ue_id=${UE_ID_FDD}