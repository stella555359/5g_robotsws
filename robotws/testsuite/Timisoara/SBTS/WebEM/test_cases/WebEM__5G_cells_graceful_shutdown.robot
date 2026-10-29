*** Settings ***
Documentation  This suite contains WebEM__5G_cells_graceful_shutdown TC

Resource  ../test_resources/WebEM__5G_cells_graceful_shutdown.robot


*** Test Cases ***
WebEM__5G_cells_graceful_shutdown
    [Setup]  TC Setup
    TC__WebEM__5G_cells_graceful_shutdown
    [Teardown]  TC Teardown
