*** Settings ***
Documentation  This suite contains STATE__WCDMA_cell_block_unblock TC

Resource  ../test_resources/STATE__WCDMA_cell_block_unblock.robot


*** Test Cases ***
STATE__WCDMA_cell_block_unblock
    [Setup]  TC Setup
    TC__STATE__WCDMA_cell_block_unblock
    [Teardown]  TC Teardown
