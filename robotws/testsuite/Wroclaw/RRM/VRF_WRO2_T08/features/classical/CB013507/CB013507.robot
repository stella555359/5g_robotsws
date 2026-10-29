*** Settings ***
Documentation
...   author: Adam Kropiwnicki
...   contact: adam.kropiwnicki@nokia.com

Library    taf.ue
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T08.features.classical.CB013507.resources.CB013507.CB013507   WITH NAME    ECID_TEST

Suite Setup   ECID_TEST.Suite Setup
Suite Teardown   ECID_TEST.Suite Teardown

*** Test Cases ***
CB013507_W_P&C
    [Setup]   ECID_TEST.Test Setup
    ECID_TEST.Run
    [Teardown]   ECID_TEST.Test Teardown
