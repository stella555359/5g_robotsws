*** Settings ***
Documentation  This suite contains COMPA__SSH_snapshot TC

Resource  ../test_resources/COMPA__SSH_snapshot.robot


*** Test Cases ***
COMPA__SSH_snapshot
    [Setup]  TC Setup
    TC__COMPA__SSH_snapshot
    [Teardown]  TC Teardown
