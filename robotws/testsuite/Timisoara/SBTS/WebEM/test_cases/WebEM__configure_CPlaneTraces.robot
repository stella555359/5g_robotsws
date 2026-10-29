*** Settings ***
Documentation  This suite contains WebEM__configure_CPlaneTraces TC

Resource  ../test_resources/WebEM__configure_CPlaneTraces.robot


*** Test Cases ***
WebEM__configure_CPlaneTraces
    [Setup]  TC Setup
    TC__WebEM__configure_CPlaneTraces
    [Teardown]  TC Teardown
