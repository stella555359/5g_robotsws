*** Settings ***
Documentation  This suite contains STATE__SBTS_block_unblock TC

Resource  ../test_resources/STATE__sbts_block_unblock.robot


*** Test Cases ***
STATE__SBTS_block_unblock
    [Setup]  TC Setup
    TC__STATE__SBTS_block_unblock
    [Teardown]  TC Teardown
