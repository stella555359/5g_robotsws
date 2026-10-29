*** Settings ***
Documentation  This suite contains WebEM__vDU__Robustness_Reset_one_RU_and_check_second_RU_upgrade_is_finished_ok TC

Resource  ../test_resources/WebEM__vDU__Robustness_Reset_one_RU_and_check_second_RU_upgrade_is_finished_ok.robot


*** Test Cases ***
WebEM__vDU__Robustness_Reset_one_RU_and_check_second_RU_upgrade_is_finished_ok
    [Setup]  TC Setup
    TC__WebEM__vDU__Robustness_Reset_one_RU_and_check_second_RU_upgrade_is_finished_ok
    [Teardown]  TC Teardown
