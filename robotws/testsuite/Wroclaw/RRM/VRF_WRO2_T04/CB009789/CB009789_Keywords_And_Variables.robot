*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_enb
Library    ta5g_pm_counters
Library    ta5g_delta

*** Keywords ***
Wait For Full Counter Sample
    Sleep    2    reason=waiting for full counter sample
