*** Settings ***
Documentation   Suite description
Resource        ${CURDIR}/Abf_Cell_Setup.robot
Resource        ${CURDIR}/ABF_resources.robot

*** Keywords ***
Abf_Cell_Setup_and_SSB_Checks
    [Documentation]     This keyword activation analog beamforming and checks SSB cconfiguration patterns
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    Abf_Cell_Setup     ${beamset}

    Collect L1L2 gNB Trcaes    duration_time=10s

    SSB auto mapping     ${beamset}
