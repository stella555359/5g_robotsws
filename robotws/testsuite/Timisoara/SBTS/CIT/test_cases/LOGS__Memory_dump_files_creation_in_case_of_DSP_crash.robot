*** Settings ***
Documentation  This suite contains LOGS__Memory_dump_files_creation_in_case_of_DSP_crash TC

Resource  ../test_resources/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot


*** Test Cases ***
LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Setup]  TC Setup
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Teardown]  TC Teardown
