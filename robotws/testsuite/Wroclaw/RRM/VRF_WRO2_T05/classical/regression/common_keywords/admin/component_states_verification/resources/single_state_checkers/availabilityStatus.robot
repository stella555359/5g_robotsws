*** Settings ***
Documentation
...    Author: damian.muszynski@nokia.com
...    Maintainer: damian.muszynski@nokia.com
...    Team in charge: I_EXT_5G_IV_WRO_OAM3_GMS

Resource  ../core_checker.robot

*** Keywords ***
Check availabilityStatus online
    [Arguments]  ${states}
    Check Status Value    ${states}    availabilityStatus    Online

Check availabilityStatus offline
    [Arguments]  ${states}
    Check Status Value    ${states}    availabilityStatus    Offline

Check availabilityStatus dependency
    [Arguments]  ${states}
    Check Status Value    ${states}    availabilityStatus    Dependency

Check availabilityStatus degraded
    [Arguments]  ${states}
    Check Status Value    ${states}    availabilityStatus    Degraded

Check availabilityStatus failed
    [Arguments]  ${states}
    Check Status Value    ${states}    availabilityStatus    Failed

Check availabilityStatus notinstalled
    [Arguments]  ${states}
    Check Status Value    ${states}    availabilityStatus    NotInstalled
