*** Settings ***
Documentation  This suite contains FM__L1_SoC_reset_CB005832_CB007442_interaction TC

Resource  ../test_resources/FM__L1_SoC_reset_CB005832_CB007442_interaction.robot


*** Test Cases ***
FM__L1_SoC_reset_CB005832_CB007442_interaction
    [Setup]  TC Setup
    TC__FM__L1_SoC_reset_CB005832_CB007442_interaction
    [Teardown]  TC Teardown
