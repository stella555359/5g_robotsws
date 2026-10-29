*** Settings ***
Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library   taf.transport.ssh   WITH NAME   csn
Library   Collections

*** Variables ***

*** Keywords ***
Test_Case_OAM_KPI_61a_SiSo_Auto_BTS_site_reset_with_L3Call
#    Set Common Test Tag   case_key=kpi_bts_reset

    Log To Console   BTS Site Reset Start ...
    FOR   ${index}    IN RANGE    ${reset_times}
       COAM WEBUI Whether Close Start Up View Window
       selenium_coam.reset_site
       Sleep   5m
       Wait Until Keyword Succeeds   20m   1m   COAM Check All Cells Onair
       Log To Console   BTS Site Reset Number: ${index + 1}
    END
    Log To Console   BTS Site Reset Finish ...
    Log To Console   Start L3Call  Data Transfer Conducted ...
    Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted
    ...   cell_index=${L3CALL_cellid}   tput_expect_DL=50   tput_expect_uL=30

Case Setup: Auto_BTS_site_reset_with_L3Call
    Case Setup

Case Teardown: Auto_BTS_site_reset_with_L3Call
    Run Keyword And Ignore Error   robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error   COAM Logout
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   10m   1m   COAM Login
    Run Keyword And Ignore Error   Wait Until Keyword Succeeds   15m   1m   COAM Check BTS OnAir
    Run Keyword And Ignore Error   Catch Snapshot COAM
    Run Keyword And Ignore Error   SISO Common Teardown
