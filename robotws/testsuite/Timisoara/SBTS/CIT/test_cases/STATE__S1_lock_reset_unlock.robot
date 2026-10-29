*** Settings ***
Documentation  This suite contains STATE__S1_Lock_Reset_Unlock TC

Resource  ../test_resources/STATE__S1_lock_reset_unlock.robot


*** Test Cases ***
STATE__S1_Lock_Reset_Unlock
    [Setup]  TC Setup
    TC__STATE__S1_Lock_Reset_Unlock
    [Teardown]  TC Teardown
