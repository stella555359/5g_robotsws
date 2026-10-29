*** Settings ***
Documentation   This is a keyword file for CB012121-B-B17 pcmd
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Resource        ../../../resources/Common/tshark.robot

*** Variables ***

${port_trace}                         49151
${ip_trace}                           10.0.1.1


*** Keywords ***

Start Netcat for tracing
    Log to console    Netcat started
    Run     sudo pkill -9 -f 'nc -l ${port_trace} -k'
    ${NC_PROC}=    Start Process  nc  -l  ${port_trace}  -k  stdout=/dev/null  stderr=/dev/null
    Sleep    5
    Run    ps -ef | grep nc
    Set Test Variable    ${NC_PROC}


Stop Netact for tracing
    Log to console    Netcat stopped
    Terminate Process  ${NC_PROC}


start pcmd trace
    [Documentation]    [PRIVATE]    start pcmd trace
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${collector}=pcmd_trace
    Log to console    pcmd trace started
    Start Tshark for Trace Session
    ...   interface=eth3
    ...   trace_port=${port_trace}
    ...   collector=${collector}
    sleep    1s   reason=wait for trace ready


stop pcmd trace
    [Documentation]    [PRIVATE]    stop pcmd trace
    ...       :Autor: Sylvia Schneider
    [Arguments]  ${collector}=pcmd_trace
    Log to console    pcmd trace stopped
    sleep    10s   reason=wait for all data collected
    Stop Tshark on Test PC
    ...   collector=${collector}
    ...   target_dir=${resultDir}


Create ip for pcmd
    [Documentation]    [PRIVATE]    Create ip for pcmd
    ...       :Autor: Sylvia Schneider
    Log to console    \nip for pcmd created ${ip_trace}
    Configure IP on VM    ip=${ip_trace}       interface=eth3
