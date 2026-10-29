*** Settings ***
Force Tags    PY27
Documentation
...             reuse of Abderrahmane NEZROUK code  to run TL commissioning in TS setup

Suite Setup     Actions Setup
#Suite Teardown  Test Suite Teardown

#Variables       ${CURDIR}/config.yaml

Library         taf.transport.ssh       WITH NAME  ssh
Library         taf.collectors.core     WITH NAME  core
Library         taf.collectors.btslog   WITH NAME  btslog
Library         taf.gnb.oam.coam.admin  WITH NAME  coam
Library         taf.pdu                 WITH NAME  pdu
Library         OperatingSystem
Library         Telnet
Library         BuiltIn
Library         DateTime
Library         Collections
Library         String
#Library         ute_reporting_portal

#Resource        ${CURDIR}/../resources/custom_commissioning.robot
Resource        ${CURDIR}/custom_commissioning.robot

#Force Tags      CA_5G_IVPS   QCD_MN_5G    QCP_5G

*** Variable ***

*** Test Cases ***
Test_Commissioning_in_TS_Setup
    Log to console     Commissioning_in_TS_Setup

*** Keywords ***
Actions Setup
    Full Commissioning Upgrade and OnAir Check
