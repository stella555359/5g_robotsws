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
Resource        ${CURDIR}/../../mirroringScripts/gnbMirroring.robot
Resource        ${CURDIR}/../../gnbStatus.robot
Resource        ${CURDIR}/ABF_resources.robot

*** Keywords ***
Abf_L1-L2_Pattern_check
    [Arguments]     ${beamset}
    ##Take L1L2 logs
    ABF_resources.Collect L1L2 gNB Trcaes    duration_time=10s

    ABF_resources.SSB auto mapping     ${beamset}
