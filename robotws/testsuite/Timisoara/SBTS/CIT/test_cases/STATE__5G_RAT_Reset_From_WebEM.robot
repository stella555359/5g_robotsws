*** Settings ***
Documentation  This suite contains STATE__5G_RAT_Reset_From_WebEM TC

Resource  ../test_resources/STATE__5G_RAT_Reset_From_WebEM.robot


*** Test Cases ***
STATE__5G_RAT_Reset_From_WebEM
    [Setup]  TC Setup
    TC__STATE__5G_RAT_Reset_From_WebEM
    [Teardown]  TC Teardown
