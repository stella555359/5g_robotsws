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
5GC001354-C-PR669984_Check_Tput_Value_With_1354-C_Enabled
    Attach Ue With Sgnb    ue_id=${UE_ID}
    Start High Dl Data Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats    ue_id=${UE_ID}
    Verify Traffic Throughput on Scells
    Detach Ue    ue_id=${UE_ID}

Start High Dl Data Traffic
    Execute Egate Command    cmd=debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} id=2 dir=dl mbps=175 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=${UE_ID} id=2 dir=dl mbps=175 trf_id=2

Verify Traffic Throughput on Scells
    Expected Throughput For Ue Should Be Reached    ue_id=${UE_ID}    throughput=350    scells=8    margin=10
    ...    direction=dl    selection_type=average    layer=physical
