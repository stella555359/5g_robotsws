*** Settings ***
Documentation  This suite contains WebEM__Site_Report TC

Resource  ../test_resources/WebEM__Site_Report.robot


*** Test Cases ***
WebEM__Site_Report
    [Setup]  TC Setup
    TC__WebEM__Site_Report
    [Teardown]  TC Teardown
