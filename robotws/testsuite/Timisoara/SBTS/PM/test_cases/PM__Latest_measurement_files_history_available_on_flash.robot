*** Settings ***
Documentation  This suite contains PM__Latest_measurement_files_history_available_on_flash TC

Resource  ../test_resources/PM__Latest_measurement_files_history_available_on_flash.robot


*** Test Cases ***
PM__Latest_measurement_files_history_available_on_flash
    [Setup]  TC Setup
    TC__PM__Latest_measurement_files_history_available_on_flash
    [Teardown]  TC Teardown
