*** Settings ***
Documentation  This suite contains COMPA__FDSW_Snapshot TC

Resource  ../test_resources/COMPA__FDSW_snapshot.robot


*** Test Cases ***
COMPA__FDSW_Snapshot
    [Setup]  TC Setup
    TC__COMPA__FDSW_Snapshot
    [Teardown]  TC Teardown
