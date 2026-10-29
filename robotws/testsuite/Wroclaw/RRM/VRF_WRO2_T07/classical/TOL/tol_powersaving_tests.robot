*** Settings ***
Documentation
...   maintainer: Filip Jozefczak
...   contact: filip.jozefczal@nokia.com
...   TOL powersaving tests


Resource         ./resources/tol_keywords.robot

*** Keywords ***
Set up powersaving
    [Arguments]    ${powersaving_cell}  ${NRPGRP}   ${ru_attenuator_ports}    ${ue_capabilities}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    ${average_tput_before}=   Collect Average Data Transfer
    Set power saving period entrance    ${powersaving_cell}   ${NRPGRP}
    Log to console    Sleep 8 minutes awaiting energysaving is on
    Sleep    480
    ${is_energysaving}  is cell saving energy    ${powersaving_cell}
    should be true    ${is_energysaving}
    Log to console    Energysaving is on
    Log to console    Sleep 4 minutes awaiting energysaving is off
    Sleep    240
    ${is_energysaving}  is cell saving energy    ${powersaving_cell}
    Log to console    Energysaving is off
    should not be true    ${is_energysaving}
    Log to console     Check if tput decreased
    ${average_tput_after}=    Collect Average Data Transfer
    ${reduced_tput_before}=    Evaluate    ${average_tput_before} * 0.95
    Should Be True    ${reduced_tput_before} <= ${average_tput_after}
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports
