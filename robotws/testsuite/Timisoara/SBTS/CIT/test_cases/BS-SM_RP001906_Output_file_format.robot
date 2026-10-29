*** Settings ***
Documentation  This suite contains BS-SM RP001906 SFP data availability via BTS CLI TC

Resource  ../test_resources/BS-SM_RP001906_Output_file_format.robot


*** Test Cases ***
BS-SM RP001906 SFP data availability via BTS CLI
    [Setup]  TC Setup
    TC__BS-SM RP001906 SFP Data Availability Via BTS CLI
    [Teardown]  TC Teardown
