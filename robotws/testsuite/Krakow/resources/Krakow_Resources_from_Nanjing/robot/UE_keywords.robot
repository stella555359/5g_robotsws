*** Settings ***
Documentation
...    author: Adam Moszczynski
...    contact: adam.1.moszczynski@nokia.com
...    UE keywords


Library     taf.ue   WITH NAME   ue

*** Keywords ***

UE require
    [Arguments]  ${capabilities}=REAL_ANDROID_UE
    Require ue   UE_1   capabilities=${capabilities}

UE attach
    Attach Ue   UE_1
    Sleep   15s

UE detach
    Detach Ue   UE_1

Start and Verify Downlink UDP
    [Arguments]    ${duration}=300s    ${throughput}=30Mbits/sec    ${deviation}=10%
    Start Data Transfer  dt_name=DT_1  ue_alias=UE_1  direction=dl  duration=${duration}  throughput=${throughput}  protocol=udp
    Sleep   10s
    Check Data Transfer Is Alive   DT_1
    Await Data Transfer Finish   DT_1
    Verify Average Throughput With Deviation   DT_1   ${throughput}   ${deviation}

Start and Verify Uplink UDP
    [Arguments]    ${duration}=300s    ${throughput}=10Mbits/sec    ${deviation}=10%
    Start Data Transfer  dt_name=DT_1  ue_alias=UE_1  direction=ul  duration=${duration}  throughput=${throughput}  protocol=udp
    Sleep   10s
    Check Data Transfer Is Alive   DT_1
    Await Data Transfer Finish   DT_1
    Verify Average Throughput With Deviation   DT_1   ${throughput}   ${deviation}

Start and Verify Downlink TCP
    [Arguments]    ${duration}=300s    ${throughput}=30Mbits/sec    ${deviation}=10%
    Start Data Transfer  dt_name=DT_1  ue_alias=UE_1  direction=dl  duration=${duration}  throughput=${throughput}  protocol=tcp
    Sleep   10s
    Check Data Transfer Is Alive   DT_1
    Await Data Transfer Finish   DT_1
    Verify Average Throughput With Deviation   DT_1   ${throughput}   ${deviation}

Start and Verify Uplink TCP
    [Arguments]    ${duration}=300s    ${throughput}=10Mbits/sec    ${deviation}=10%
    Start Data Transfer  dt_name=DT_1  ue_alias=UE_1  direction=ul  duration=${duration}  throughput=${throughput}  protocol=tcp
    Sleep   10s
    Check Data Transfer Is Alive   DT_1
    Await Data Transfer Finish   DT_1
    Verify Average Throughput With Deviation   DT_1   ${throughput}   ${deviation}
