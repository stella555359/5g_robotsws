*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../core_checker.robot

*** Keywords ***
Check operationalState enabled SBTS00
    [Arguments]  ${states}
    Check Status Value    ${states}    operationalState    enabled

Check operationalState enabled Branch
    [Arguments]  ${states}
    Check Status Value    ${states}    operationalState    Enabled

Check operationalState disabled
    [Arguments]  ${states}
    Check Status Value    ${states}    operationalState    disabled

