*** Settings ***
Documentation
...    to make TA work, actInternalTrace=true, actCli=true
Resource    ./../common_setup_teardown.robot

*** Variables ***
${LOG}    syslog,tti,sherpa,bip,sosreport,apbip,
${LOG_PATH}    ${OUTPUT_DIR}/mylog/
${STOP_CASE_FILE}    /home/ute/delete_me_to_stop_case.txt
*** Test Cases ***
Small Case For Catch Gnb Wireshark Continuously
    [Tags]    case1
    Start Gnb Wireshark Log
    Wait Until User Manually Delete Stop Case File
    Stop Gnb Wireshark Log    ${OUTPUT_DIR}/wireshark/

Small Case For Catch Gnb Wireshark With Parameter Modify 2
    [Tags]    case2
    Start Gnb Wireshark Log
    #prachConfigurationIndex will make cell delete and onair again.
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    prachConfigurationIndex    98
    Sleep    10s
    Stop Gnb Wireshark Log    ${OUTPUT_DIR}/wireshark/prachConfigurationIndex/

Small Case For Catch Gnb Wireshark With Parameter Modify 3
    [Tags]    case3
    Start Gnb Wireshark Log
    #prachConfigurationIndex will make cell delete and onair again.
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELLGRP-0    ssBurstSetPeriod    98
    Sleep    10s
    Stop Gnb Wireshark Log    ${OUTPUT_DIR}/wireshark/ssBurstSetPeriod/

Small Case For Catch Gnb Wireshark With Parameter Modify 4
    [Tags]    case4
    Start Gnb Wireshark Log
    #CSIMeasBasedAllUe, PastTputBased
    Online Change One Para With Admin    MRBTS-1/NRBTS-1/NRCELL-1    actCsiMeasEthFlowControl    PastTputBased
    Sleep    10s
    Stop Gnb Wireshark Log    ${OUTPUT_DIR}/wireshark/ssBurstSetPeriod/

Small Case For Catch Gnb Wireshark With Parameter Modify 5
    [Tags]    case5
    Start Gnb Wireshark Log
    #ulVoipPacketAggrSinrThreshold, -80
    Online Change One Para With Admin    MRBTS-1/NRBTS-1    ulVoipPacketAggrSinrThreshold    -80
    Sleep    10s
    Stop Gnb Wireshark Log    ${OUTPUT_DIR}/wireshark/ssBurstSetPeriod/

*** Keywords ***

