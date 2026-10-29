*** Settings ***
Documentation
...    author:  Adam Kropiwnicki
...    contact: adam.kropiwnicki@nokia.com


Library         taf.ue

Variables      ./test_constants.py


*** Keywords ***
Attach UE With Data Transfer
    [Arguments]  ${duration}   ${ue_alias}   ${throughput}=1000 Mbits/sec   ${direction}=DL
    Log To Console    Attaching ${ue_alias}...
    Attach UE    ${ue_alias}
    Log to Console    Starting ${direction} data transfer on ${ue_alias}...
    Start Data Transfer
    ...   dt_name=${ue_alias}_DT_${direction}
    ...   ue_alias=${ue_alias}
    ...   throughput=${throughput}
    ...   direction=${direction}
    ...   duration=${duration}
    ...   protocol=udp


Attach UE With Bi Directional Data Transfer
    [Arguments]  ${duration}   ${ue_alias}   ${ul_throughput}=100 Mbits/sec   ${dl_throughput}=200 Mbits/sec
    Log To Console    Attaching ${ue_alias}...
    Attach UE    ${ue_alias}
    Log to Console    Starting bi-directional data transfer on ${ue_alias}...
    Start Data Transfer
    ...   dt_name=${ue_alias}_DT_DL
    ...   ue_alias=${ue_alias}
    ...   throughput=${dl_throughput}
    ...   direction=DL
    ...   duration=${duration}
    ...   protocol=udp
    Start Data Transfer
    ...   dt_name=${ue_alias}_DT_UL
    ...   ue_alias=${ue_alias}
    ...   throughput=${ul_throughput}
    ...   direction=UL
    ...   duration=${duration}
    ...   protocol=udp


Await Data Transfer And Detach UE
    [Arguments]  ${ue_alias}   ${direction}=DL
    Stop Data Transfer   ${ue_alias}_DT_${direction}
    Log to Console   ${direction} data transfer stopped!
    Log To Console   Detaching UE ${ue_alias}...
    [Teardown]   Detach UE   ${ue_alias}


Await Bi Directional Data Transfer And Detach UE
    [Arguments]  ${ue_alias}
    Stop Data Transfer   ${ue_alias}_DT_DL
    Stop Data Transfer   ${ue_alias}_DT_UL
    Log to Console   Bi-directional data transfer stopped!
    Log To Console   Detaching UE ${ue_alias}...
    [Teardown]   Detach UE   ${ue_alias}

