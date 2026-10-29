*** Settings ***
Documentation  This suite contains WebEM__OAM_Basic_Site_Commission_for_LTE TC

Resource  ../test_resources/WebEM__OAM_Basic_Site_Commission_for_LTE.robot


*** Test Cases ***
WebEM__OAM_Basic_Site_Commission_for_LTE
    [Setup]  TC Setup
    TC__WebEM__OAM_Basic_Site_Commission_for_LTE
    [Teardown]  TC Teardown
