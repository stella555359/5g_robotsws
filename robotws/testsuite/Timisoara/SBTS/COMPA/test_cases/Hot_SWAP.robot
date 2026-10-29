*** Settings ***
Documentation  This suite contains Hot_SWAP_Slave_SBTS TC

Resource  ../test_resources/Hot_SWAP.robot


*** Test Cases ***
Hot_SWAP_Slave_SBTS
    [Setup]  TC Setup
    TC__Hot_SWAP_Slave_SBTS
    [Teardown]  TC Teardown
