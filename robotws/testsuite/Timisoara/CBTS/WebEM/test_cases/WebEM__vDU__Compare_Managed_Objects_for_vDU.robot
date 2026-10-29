*** Settings ***
Documentation  This suite contains WebEM__vDU__Compare_Managed_Objects_for_vDU TC

Resource  ../test_resources/WebEM__vDU__Compare_Managed_Objects_for_vDU.robot


*** Test Cases ***
WebEM__vDU__Compare_Managed_Objects_for_vDU
    [Setup]  TC Setup
    TC__WebEM__vDU__Compare_Managed_Objects_for_vDU
    [Teardown]  TC Teardown
