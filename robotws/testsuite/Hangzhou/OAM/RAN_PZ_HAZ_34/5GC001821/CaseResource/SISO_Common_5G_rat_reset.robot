*** Settings ***
Documentation    Test_Case_OAM_KPI_5G_reset_rat
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library   taf.transport.ssh   WITH NAME   csn
Library   Collections

*** Variables ***

*** Keywords ***
Test_Case_OAM_KPI_5G_reset_rat
#    Set Common Test Tag   case_key=kpi_bts_reset

    Log To Console   BTS Site Reset Start ...
    FOR   ${index}    IN RANGE    ${reset_times}
       COAM WEBUI Whether Close Start Up View Window
       selenium_coam.reset_nr
       Sleep   5m
       Wait Until Keyword Succeeds   20m   1m   COAM Check All Cells Onair
       Log To Console   BTS Site Reset Number: ${index + 1}
    END
    Log To Console   BTS Site Reset Finish...


Case Setup: OAM_KPI_5G_reset_rat
    Case Setup

Case Teardown: OAM_KPI_5G_reset_rat
    Run Keyword And Ignore Error   robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    Run Keyword And Ignore Error   Catch Snapshot COAM
    Run Keyword And Ignore Error   SISO Common Teardown
