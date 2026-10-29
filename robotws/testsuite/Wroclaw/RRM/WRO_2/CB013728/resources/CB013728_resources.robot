*** Settings ***
Documentation
...    Common resources file

Library     ta_messaging
Library     ta_emss
Library     ute_wtssim
Library     ute_fsmaccess
Library     OperatingSystem
Library     ta5g_testline_management
Library     ta5g_commissioning
Resource    collectors.robot
Resource    CB013728_keywords.robot


*** Keywords ***
Collect TTI Traces during ${duration} seconds of traffic
    Log to console  Collect TTI Traces during ${duration} seconds
    Start TTI trace
    Start Data Traffic
    Sleep  ${duration}
    Log to console  Stop collecting TTI Traces
    Stop TTI trace

Set feature activation flag '${parameter}' on NRCell-1 to ${value}
    Perform Parameter Commissioning    parameter=${parameter}  value=${value}
    ...                                dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    Sleep  10s
    Log to console  The parameter 'NRCell-${parameter}' was changed to ${value}
