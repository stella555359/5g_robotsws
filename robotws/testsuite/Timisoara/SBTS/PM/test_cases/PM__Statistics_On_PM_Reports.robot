*** Settings ***
Documentation  This suite contains PM__Statistics_On_PM_Reports TC

Resource  ../test_resources/PM__Statistics_On_PM_Reports.robot


*** Test Cases ***
PM__Statistics_On_PM_Reports
    [Setup]  TC Setup
    TC__PM__Statistics_On_PM_Reports
    [Teardown]  TC Teardown