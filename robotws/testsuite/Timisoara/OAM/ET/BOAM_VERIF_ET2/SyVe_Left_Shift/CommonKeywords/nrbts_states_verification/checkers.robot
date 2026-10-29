*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  getters.robot

*** Keywords ***
Check NRBTS OnAir
    [Documentation]
    ...    to check if current NRBTS Operational State == OnAir
    ${operationalState}=    Get NRBTS status    operationalState
    Should Be Equal    ${operationalState}      onAir    ignore_case=true

Check NRBTS Configured
    [Documentation]
    ...    to check if current NRBTS Operational State == Configured
    ${operationalState}=    Get NRBTS status    operationalState
    Should Be Equal    ${operationalState}      Configured    ignore_case=true

Check NRBTS NotCommissioned
    ${operationalState}=    Get NRBTS status    operationalState
    Should Be Equal    ${operationalState}      NotCommissioned    ignore_case=true
