*** Settings ***
Documentation  This suite contains CIT__TDS TC

Resource  ../test_resources/CIT__TDS.robot


*** Test Cases ***
CIT__TDS
    [Setup]  TC Setup
    TC__CIT__TDS
    [Teardown]  TC Teardown
