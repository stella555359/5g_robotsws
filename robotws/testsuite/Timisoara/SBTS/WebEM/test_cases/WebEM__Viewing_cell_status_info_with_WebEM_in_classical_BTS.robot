*** Settings ***
Documentation  This suite contains WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS TC

Resource  ../test_resources/WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS.robot


*** Test Cases ***
WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    [Setup]  TC Setup
    TC__WebEM__Viewing_cell_status_info_with_WebEM_in_classical_BTS
    [Teardown]  TC Teardown
