*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=    30s
${UE_ID}=                   12

*** Keywords ***
5GC001354-C-PR666688_Lack_Of_Autonomous_Reset_Occurrence_After_Set_Dlmaxretx_Threshold_To_T1_And_Dltpollretr_To_Ms5_On_Tdd_Cell
    Attach Ue With Sgnb    ue_id=${UE_ID}
    Start Dl Data Traffic    ue_id=${UE_ID}    mbps=2mbps
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats    ue_id=${UE_ID}
    Detach Ue    ue_id=${UE_ID}
    Sleep    60s
    Set Dlmaxretx Threshold To T1 And Dltpollretr To Ms5
    Attach Ue With Sgnb    ue_id=${UE_ID}
    Start Dl Data Traffic    ue_id=${UE_ID}    mbps=2mbps
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats        ue_id=${UE_ID}
    Detach Ue    ue_id=${UE_ID}
