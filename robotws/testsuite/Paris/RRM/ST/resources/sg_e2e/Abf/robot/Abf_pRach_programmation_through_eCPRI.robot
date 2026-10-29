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

Resource        ${CURDIR}/../../configuration.robot
Resource        ${CURDIR}/../../logs.robot
Resource        ${CURDIR}/../../gnbStatus.robot
Resource        ${CURDIR}/ABF_resources.robot

*** Keywords ***
Abf_pRach_programmation_through_eCPRI
    [Arguments]     ${beamset}
    [Teardown]      Run keyword and ignore error      configuration.Close Connections SSH

    Collect L1L2 gNB Trcaes    duration_time=10s

    pRACH Auto Mapping    ${beamset}
