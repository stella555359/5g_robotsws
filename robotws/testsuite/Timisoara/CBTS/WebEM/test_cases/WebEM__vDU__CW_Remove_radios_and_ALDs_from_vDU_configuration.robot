*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Remove_radios_and_ALDs_from_vDU_configuration TC

Resource  ../test_resources/WebEM__vDU__CW_Remove_radios_and_ALDs_from_vDU_configuration.robot


*** Test Cases ***
WebEM__vDU__CW_Remove_radios_and_ALDs_from_vDU_configuration
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Remove_radios_and_ALDs_from_vDU_configuration
    [Teardown]  TC Teardown
