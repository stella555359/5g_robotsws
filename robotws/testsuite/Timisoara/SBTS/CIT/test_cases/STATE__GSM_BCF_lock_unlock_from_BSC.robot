*** Settings ***
Documentation  This suite contains STATE__GSM_BCF_lock_unlock_from_BSC TC

Resource  ../test_resources/STATE__GSM_BCF_lock_unlock_from_BSC.robot


*** Test Cases ***
STATE__GSM_BCF_lock_unlock_from_BSC
    [Setup]  TC Setup
    TC__STATE__GSM_BCF_lock_unlock_from_BSC
    [Teardown]  TC Teardown
