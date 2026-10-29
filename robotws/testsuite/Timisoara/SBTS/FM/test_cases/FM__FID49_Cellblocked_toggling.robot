*** Settings ***
Documentation  This suite contains FM__FID49_Cellblocked_toggling TC

Resource  ../test_resources/FM__FID49_Cellblocked_toggling.robot


*** Test Cases ***
FM__FID49_Cellblocked_toggling
    [Setup]  TC Setup
    TC__FM__FID49_Cellblocked_toggling
    [Teardown]  TC Teardown
