*** Settings ***
Documentation  This suite contains WebEM__Change_of_MPlane_address_and_commissioning_report TC

Resource  ../test_resources/WebEM__Change_of_MPlane_address_and_commissioning_report.robot


*** Test Cases ***
WebEM__Change_of_MPlane_address_and_commissioning_report
    [Setup]  TC Setup
    TC__WebEM__Change_of_MPlane_address_and_commissioning_report
    [Teardown]  TC Teardown
