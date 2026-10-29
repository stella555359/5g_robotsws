*** Settings ***
Documentation
...                 Keywords Purpose:
...                 keywords relative to UE and traffic
...
...                 AUTHOR:
...                 David Jollivet    david.jollivet@nokia.com

Library             OperatingSystem
Library             DateTime
Library             taf.collectors.core    WITH NAME    core
Library             taf.collectors.btslog    WITH NAME    btslog


*** Keywords ***
Android UE Attach
    [Documentation]    Attach UE
    [Arguments]    ${ue_alias}
    Run Keyword And Continue on failure    Attach Ue    ue_alias=${ue_alias}    success_ratio=100%
    Log To Console    UE attached

Android DL Traffic
    [Documentation]    Do DL Traffic with UE
    [Arguments]
    ...    ${ue_alias}
    ...    ${duration}
    ...    ${dl_throughput}
    ...    ${protocol}=udp
    ...    ${packet}=1000B
    ...    ${dl_port}=34018
    Run Keyword And Continue on failure    Start Data Transfer
    ...    ue_alias=${ue_alias}    dt_name=DT_DL    direction=dl    duration=${duration}    throughput=${dl_throughput}
    ...    protocol=${protocol}    packet=${packet}    port=${dl_port}

    Log To Console    DL Data transfer started
    Sleep    10s
    Run Keyword And Continue on failure    Await Data Transfer Finish    dt_name=DT_DL

    ${dl_thput}=    Run Keyword And Continue on failure    Get Average Throughput    DT_DL
    ${str_dl_thput}=    Convert To String    ${dl_thput}

    Log To Console    ------------
    Log To Console    Requested DL throughput = ${dl_throughput}
    Log To Console    Obtained DL throughput = ${str_dl_thput}
    Log To Console    ------------
    Log To Console    DL Data transfer finish

    Run Keyword And Continue on failure    Stop Data Transfer    DT_DL

    [Return]    ${dl_thput}
    RETURN    ${dl_thput}

Android UL Traffic
    [Documentation]    Do UL Traffic with UE
    [Arguments]
    ...    ${ue_alias}
    ...    ${duration}
    ...    ${ul_throughput}
    ...    ${protocol}=udp
    ...    ${packet}=1000B
    ...    ${ul_port}=34019
    Run Keyword And Continue on failure    Start Data Transfer
    ...    ue_alias=${ue_alias}    dt_name=DT_UL    direction=ul    duration=${duration}    throughput=${ul_throughput}
    ...    protocol=${protocol}    packet=${packet}    port=${ul_port}

    Log To Console    UL Data transfer started
    Sleep    10s
    Run Keyword And Continue on failure    Await Data Transfer Finish    dt_name=DT_UL

    ${ul_thput}=    Run Keyword And Continue on failure    Get Average Throughput    DT_UL
    ${str_ul_thput}=    Convert To String    ${ul_thput}

    Log To Console    ------------
    Log To Console    Requested UL throughput = ${ul_throughput}
    Log To Console    Obtained UL throughput = ${str_ul_thput}
    Log To Console    ------------
    Log To Console    UL Data transfer finish

    Run Keyword And Continue on failure    Stop Data Transfer    DT_UL

    [Return]    ${ul_thput}
    RETURN    ${ul_thput}

Android UE Detach
    [Documentation]    Detach UE
    [Arguments]    ${ue_alias}
    Run keyword and ignore error    Detach Ue    ${ue_alias}
    Log To Console    UE detached
