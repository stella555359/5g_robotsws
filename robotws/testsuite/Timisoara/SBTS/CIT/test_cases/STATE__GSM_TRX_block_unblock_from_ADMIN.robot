*** Settings ***
Documentation  This suite contains STATE__GSM_TRX_block_unblock_from_ADMIN TC

Resource  ../test_resources/STATE__GSM_TRX_block_unblock_from_ADMIN.robot


*** Test Cases ***
STATE__GSM_TRX_block_unblock_from_ADMIN
    [Setup]  TC Setup
    TC__STATE__GSM_TRX_block_unblock_from_ADMIN
    [Teardown]  TC Teardown
