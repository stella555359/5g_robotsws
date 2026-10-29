*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check.robot

*** Test Cases ***
[1]NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__NRL__STATE__LTE_Site_Reset_from_WEBEM_with_Fid_7107_Check