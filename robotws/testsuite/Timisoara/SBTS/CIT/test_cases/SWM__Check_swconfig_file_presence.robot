*** Settings ***
Documentation  This suite contains SWM__Check_swconfig_file_presence TC

Resource  ../test_resources/SWM__Check_swconfig_file_presence.robot


*** Test Cases ***
SWM__Check_swconfig_file_presence
    [Setup]  TC Setup
    TC__SWM__Check_swconfig_file_presence
    [Teardown]  TC Teardown
