*** Settings ***
Documentation   Suite description
Resource        ${CURDIR}/Abf_Cell_Setup.robot
Resource        ${CURDIR}/ABF_resources.robot

*** Keywords ***
Abf_SSB_programmation_through_eCPRI
    [Documentation]     The purpose of this test case is to check in message BIP message "DlData_PatternConfigReq"
    ...             that the pattercongig is aligned with SSB burst and the SFN Slot
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    Abf_Cell_Setup     ${beamset}

    Collect L1L2 gNB Trcaes    duration_time=10s

    pRACH Auto Mapping    ${beamset}
