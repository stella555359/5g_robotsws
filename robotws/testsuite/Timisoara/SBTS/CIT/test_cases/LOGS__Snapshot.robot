*** Settings ***
Documentation  This suite contains LOGS__Snapshot TC

Resource  ../test_resources/LOGS__Snapshot.robot


*** Test Cases ***
LOGS__Snapshot
    [Setup]  TC Setup
    TC__LOGS__Snapshot
    [Teardown]  TC Teardown
