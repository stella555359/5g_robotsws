*** Settings ***
Documentation  This suite contains STATE__LTE_cell_block_unblock_from_ADMIN TC

Resource  ../test_resources/STATE__LTE_cell_block_unblock_from_ADMIN.robot


*** Test Cases ***
STATE__LTE_cell_block_unblock_from_ADMIN
    [Setup]  TC Setup
    TC__STATE__LTE_cell_block_unblock_from_ADMIN
    [Teardown]  TC Teardown
