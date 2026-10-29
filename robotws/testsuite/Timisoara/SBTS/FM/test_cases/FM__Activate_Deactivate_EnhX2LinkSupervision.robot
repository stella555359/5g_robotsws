*** Settings ***
Documentation  This suite contains FM__Activate_Deactivate_EnhX2LinkSupervision TC

Resource  ../test_resources/FM__Activate_Deactivate_EnhX2LinkSupervision.robot


*** Test Cases ***
FM__Activate_Deactivate_EnhX2LinkSupervision
    [Setup]  TC Setup
    TC__FM__Activate_Deactivate_EnhX2LinkSupervision
    [Teardown]  TC Teardown
