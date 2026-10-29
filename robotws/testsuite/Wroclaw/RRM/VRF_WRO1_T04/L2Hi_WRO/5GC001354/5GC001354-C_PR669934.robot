*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   30s

*** Keywords ***
5GC001354-C-PR669934_Check_Ue_Activity_After_Setting_Dlmaxretx_Threshold_To_T1_And_Dltpollretr_To_Ms5_On_Fdd_Cell
    Set Dlmaxretx Threshold To T1 And Dltpollretr To Ms5
    Attach Ue With Sgnb
    Start Dl Data Traffic    mbps=150mbps    protocol=udp
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Detach Ue    ue_id=11
