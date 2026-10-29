*** Settings ***
Documentation  This suite contains WebEM__vDU__configurable_identifiers_in_WebEM_vDU TC

Resource  ../test_resources/WebEM__vDU__configurable_identifiers_in_WebEM_vDU.robot


*** Test Cases ***
WebEM__vDU__configurable_identifiers_in_WebEM_vDU
    [Setup]  TC Setup
    TC__WebEM__vDU__configurable_identifiers_in_WebEM_vDU
    [Teardown]  TC Teardown
