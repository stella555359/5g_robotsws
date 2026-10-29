*** Settings ***
Documentation  This suite contains KPI__Compare_KPI TC

Resource  ../test_resources/KPI__Compare_KPI.robot


*** Test Cases ***
Compare delta files
    [Setup]  TC Setup
    TC__Compare Delta Files
    [Teardown]  TC Teardown
