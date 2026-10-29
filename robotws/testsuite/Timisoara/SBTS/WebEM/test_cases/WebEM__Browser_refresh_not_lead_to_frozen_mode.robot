*** Settings ***
Documentation  This suite contains WebEM__Browser_refresh_not_lead_to_frozen_mode TC

Resource  ../test_resources/WebEM__Browser_refresh_not_lead_to_frozen_mode.robot


*** Test Cases ***
WebEM__Browser_refresh_not_lead_to_frozen_mode
    [Setup]  TC Setup
    TC__WebEM__Browser_refresh_not_lead_to_frozen_mode
    [Teardown]  TC Teardown
