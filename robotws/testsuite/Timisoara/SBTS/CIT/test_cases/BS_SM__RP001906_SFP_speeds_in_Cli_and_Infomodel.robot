*** Settings ***
Documentation  This suite contains BS_SM__RP001906_SFP_speeds_in_Cli_and_Infomodel TC

Resource  ../test_resources/BS_SM__RP001906_SFP_speeds_in_Cli_and_Infomodel.robot


*** Test Cases ***
BS_SM__RP001906_SFP_speeds_in_Cli_and_Infomodel
    [Setup]  TC Setup
    TC__BS_SM__RP001906_SFP_speeds_in_Cli_and_Infomodel
    [Teardown]  TC Teardown
