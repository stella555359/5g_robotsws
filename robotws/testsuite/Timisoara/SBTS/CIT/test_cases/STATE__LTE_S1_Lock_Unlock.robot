*** Settings ***
Documentation  This suite contains STATE__LTE_S1_Lock_Unlock TC

Resource  ../test_resources/STATE__LTE_S1_Lock_Unlock.robot


*** Test Cases ***
STATE__LTE_S1_Lock_Unlock
    [Setup]  TC Setup
    TC__STATE__LTE_S1_Lock_Unlock
    [Teardown]  TC Teardown
