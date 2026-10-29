*** Settings ***
Documentation  This suite contains WebEM__vDU__Timezone_Update_info_on_WebEM TC

Resource  ../test_resources/WebEM__vDU__Timezone_Update_info_on_WebEM.robot


*** Test Cases ***
WebEM__vDU__Timezone_Update_info_on_WebEM
    [Setup]  TC Setup
    TC__WebEM__vDU__Timezone_Update_info_on_WebEM
    [Teardown]  TC Teardown
