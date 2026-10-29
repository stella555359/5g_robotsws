*** Settings ***
Documentation  This suite contains WebEM__vCU__Timezone_Update_info_on_WebEM TC

Resource  ../test_resources/WebEM__vCU__Timezone_Update_info_on_WebEM.robot


*** Test Cases ***
WebEM__vCU__Timezone_Update_info_on_WebEM
    [Setup]  TC Setup
    TC__WebEM__vCU__Timezone_Update_info_on_WebEM
    [Teardown]  TC Teardown
