*** Settings ***
Documentation  This suite contains SWM__SW_update_for_new_RF_unit TC

Resource  ../test_resources/SWM__SW_update_for_new_RF_unit.robot


*** Test Cases ***
SWM__SW_update_for_new_RF_unit
    [Setup]  TC Setup
    TC__SWM__SW_update_for_new_RF_unit
    [Teardown]  TC Teardown
