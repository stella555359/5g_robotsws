*** Settings ***
Documentation   Suite description
Library         OperatingSystem
Library         Process
Library         Collections
Library         String
Library         DateTime
Library         taf.gnb.oam.commissioning                   WITH NAME   cm
Library         taf.transport.ssh                           WITH NAME   ssh
Library         taf.gnb.oam.megazone_client                 WITH NAME   mz

Resource        ${CURDIR}/ABF_resources.robot
Resource        ${CURDIR}/Abf_Cell_Setup_C_OAM.robot

*** Keywords ***
Abf_OAM_Configuration
    [Documentation]     This keyword activation analog beamforming vs OAM mode and checks SSB cconfiguration patterns
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    Abf_Cell_Setup_C_OAM    ${beamset}

    ABF_resources.Collect L1L2 gNB Trcaes    duration_time=10s

    ABF_resources.SSB auto mapping     ${beamset}

    ABF_resources.pRACH Auto Mapping     ${beamset}
