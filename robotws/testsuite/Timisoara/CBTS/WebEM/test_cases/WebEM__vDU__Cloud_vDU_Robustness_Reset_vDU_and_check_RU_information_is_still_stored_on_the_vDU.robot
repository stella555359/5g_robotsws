*** Settings ***
Documentation  This suite contains WebEM__vDU__Cloud_vDU_Robustness_Reset_vDU_and_check_RU_information_is_still_stored_on_the_vDU TC

Resource  ../test_resources/WebEM__vDU__Cloud_vDU_Robustness_Reset_vDU_and_check_RU_information_is_still_stored_on_the_vDU.robot


*** Test Cases ***
WebEM__vDU__Cloud_vDU_Robustness_Reset_vDU_and_check_RU_information_is_still_stored_on_the_vDU
    [Setup]  TC Setup
    TC__WebEM__vDU__Cloud_vDU_Robustness_Reset_vDU_and_check_RU_information_is_still_stored_on_the_vDU
    [Teardown]  TC Teardown
