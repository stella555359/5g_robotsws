*** Settings ***
Documentation  This suite contains WebEM__vDU__Status_and_Detail_info_Check TC

Resource  ../test_resources/WebEM__vDU__Status_and_Detail_info_Check.robot


*** Test Cases ***
WebEM__vDU__Status_and_Detail_info_Check
    [Setup]  TC Setup
    TC__WebEM__vDU__Status_and_Detail_info_Check
    [Teardown]  TC Teardown
