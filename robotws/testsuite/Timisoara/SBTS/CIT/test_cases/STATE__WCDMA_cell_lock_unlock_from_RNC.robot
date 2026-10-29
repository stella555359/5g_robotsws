*** Settings ***
Documentation  This suite contains STATE__WCDMA_cell_lock_unlock_from_RNC TC

Resource  ../test_resources/STATE__WCDMA_cell_lock_unlock_from_RNC.robot


*** Test Cases ***
STATE__WCDMA_cell_lock_unlock_from_RNC
    [Setup]  TC Setup
    TC__STATE__WCDMA_cell_lock_unlock_from_RNC
    [Teardown]  TC Teardown
