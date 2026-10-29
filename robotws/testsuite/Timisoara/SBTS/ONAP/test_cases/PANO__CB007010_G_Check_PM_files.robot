*** Settings ***
Documentation  This suite contains PANO__CB007010_G_Check_PM_files TC

Resource  ../test_resources/PANO__CB007010_G_Check_PM_files.robot

*** Test Cases ***
PANO__CB007010_G_Check_PM_files
    [Setup]  TC Setup
    [Teardown]  TC Teardown
    TC__PANO__CB007010_G_Check_PM_files
