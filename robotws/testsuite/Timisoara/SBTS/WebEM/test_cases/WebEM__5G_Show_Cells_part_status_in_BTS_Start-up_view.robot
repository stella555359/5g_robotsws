*** Settings ***
Documentation  This suite contains WebEM__5G_Show_Cells_part_status_in_BTS_Start TC

Resource  ../test_resources/WebEM__5G_Show_Cells_part_status_in_BTS_Start-up_view.robot


*** Test Cases ***
WebEM__5G_Show_Cells_part_status_in_BTS_Start-up_view
    [Setup]  TC Setup
    TC__WebEM__5G_Show_Cells_part_status_in_BTS_Start-up_view
    [Teardown]  TC Teardown
