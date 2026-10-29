*** Settings ***
Documentation  This suite contains WebEM__SFP_Monitoring_Mobile TC

Resource  ../test_resources/WebEM__SFP_Monitoring_Mobile.robot


*** Test Cases ***
WebEM__SFP_Monitoring_Mobile
    [Setup]  TC Setup
    TC__WebEM__SFP_Monitoring_Mobile
    [Teardown]  TC Teardown
