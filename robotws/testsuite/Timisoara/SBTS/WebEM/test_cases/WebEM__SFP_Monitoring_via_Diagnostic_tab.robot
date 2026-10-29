*** Settings ***
Documentation  This suite contains WebEM__SFP_Monitoring_via_Diagnostic_tab TC

Resource  ../test_resources/WebEM__SFP_Monitoring_via_Diagnostic_tab.robot


*** Test Cases ***
WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Setup]  TC Setup
    TC__WebEM__SFP_Monitoring_via_Diagnostic_tab
    [Teardown]  TC Teardown
