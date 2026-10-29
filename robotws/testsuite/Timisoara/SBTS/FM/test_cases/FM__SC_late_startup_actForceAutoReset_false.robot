*** Settings ***
Documentation  This suite contains FM__SC_Late_Startup_actForce_False TC

Resource  ../test_resources/FM__SC_late_startup_actForceAutoReset_false.robot


*** Test Cases ***
FM__SC_Late_Startup_actForce_False
    [Setup]  TC Setup
    TC__FM__SC_Late_Startup_actForce_False
    [Teardown]  TC Teardown
