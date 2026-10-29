*** Settings ***
Documentation  This suite contains WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome TC

Resource  ../test_resources/WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome.robot


*** Test Cases ***
WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Setup]  TC Setup
    TC__WebEM__Get_Tuning_History_Report_with_Mozilla_and_Chrome
    [Teardown]  TC Teardown
