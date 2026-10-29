*** Settings ***
Documentation  This suite contains SWM__SW_update_for_new_RF_unit_uncommissioned TC

Resource  ../test_resources/SWM__SW_update_for_new_RF_unit_uncommissioned.robot


*** Test Cases ***
SWM__SW_update_for_new_RF_unit_uncommissioned
    [Setup]  TC Setup
    TC__SWM__SW_update_for_new_RF_unit_uncommissioned
    [Teardown]  TC Teardown
