*** Settings ***
Documentation
...   author: Patryk Janas
...   contact: patryk.janas@nokia.com
...   This is the TESTSUITE file for feature CB006030

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB006030/resources/keywords_6030.robot

Force Tags      CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP

Suite Setup   testline_preparation.prepare_testline

*** Test Cases ***
[1][1.0] CB006030_A_Migration_via_NetAct
    [Setup]     Netact setup
    [1][1.0] CB006030_A_Migration_via_NetAct
    [Teardown]  Netact teardown

[1][1.0] CB006030_A_Runtime_SCF_Migration_Case#1
    [1][1.0] CB006030_A_Runtime_SCF_Migration_Case#1
