*** Settings ***
Resource    ../test_resources/FM__5G_cell_graceful_shutdown_before_recovery_BTS_reset.robot

*** Test Cases ***
FM__5G_cell_graceful_shutdown_before_recovery_BTS_reset
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__5G_cell_graceful_shutdown_before_recovery_BTS_reset

