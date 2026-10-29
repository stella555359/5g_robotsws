*** Settings ***
Documentation
...   maintainer: Bartosz Kozlowski
...   contact: bartosz.1.kozlowski@nokia.com
...   TOL tput tests


Resource         ./resources/tol_keywords.robot

*** Keywords ***
BTS_Block_Unblock_Attach_Tput
    [Arguments]    ${ru_attenuator_ports}    ${ue_capabilities}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    ${average_tput_before}=   Collect Average Data Transfer
    Block And Unblock Site
    ${average_tput_after}=    Collect Average Data Transfer
    ${reduced_tput_before}=    Evaluate    ${average_tput_before} * 0.95
    Should Be True    ${reduced_tput_before} <= ${average_tput_after}
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports

RAT_Block_Unblock_Attach_Tput
    [Arguments]    ${ru_attenuator_ports}    ${ue_capabilities}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    ${average_tput_before}=   Collect Average Data Transfer
    Block And Unblock Rat
    ${average_tput_after}=    Collect Average Data Transfer
    ${reduced_tput_before}=    Evaluate    ${average_tput_before} * 0.95
    Should Be True    ${reduced_tput_before} <= ${average_tput_after}
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports

BBMOD_Lock_Unlock_Attach_Tput
    [Arguments]    ${ru_attenuator_ports}    ${ue_capabilities}    ${bbmod}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    ${average_tput_before}=   Collect Average Data Transfer
    Lock And Unlock BBMOD    ${bbmod}
    ${average_tput_after}=    Collect Average Data Transfer
    ${reduced_tput_before}=    Evaluate    ${average_tput_before} * 0.95
    Should Be True    ${reduced_tput_before} <= ${average_tput_after}
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports

RMOD_Lock_Unlock_Attach_Tput
    [Arguments]    ${ru_attenuator_ports}    ${ue_capabilities}    ${rmod}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    ${average_tput_before}=   Collect Average Data Transfer
    Lock And Unlock Rmod    ${rmod}
    ${average_tput_after}=    Collect Average Data Transfer
    ${reduced_tput_before}=    Evaluate    ${average_tput_before} * 0.95
    Should Be True    ${reduced_tput_before} <= ${average_tput_after}
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports

RMOD_Reset_Attach_Tput
    [Arguments]    ${ru_attenuator_ports}    ${ue_capabilities}    ${rmod}
    Prepare Attenuator For Test    ${ru_attenuator_ports}
    Require UE    UE_1   capabilities=${ue_capabilities}
    ${average_tput_before}=   Collect Average Data Transfer
    Reset Rmod    ${rmod}
    ${average_tput_after}=    Collect Average Data Transfer
    ${reduced_tput_before}=    Evaluate    ${average_tput_before} * 0.95
    Should Be True    ${reduced_tput_before} <= ${average_tput_after}
    [Teardown]   Run Keywords
    ...    Detach Ue    UE_1     AND
    ...    Attenuate All Ports
