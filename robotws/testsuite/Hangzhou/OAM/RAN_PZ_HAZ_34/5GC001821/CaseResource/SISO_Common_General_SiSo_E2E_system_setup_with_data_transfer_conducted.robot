*** Settings ***
Documentation    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Library   taf.transport.ssh   WITH NAME   csn
Library   Collections

*** Variables ***

*** Keywords ***
Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    Set Common Test Tag   case_key=simple_call
    Wait Until Keyword Succeeds   3x   10s   Data Transfer Conducted

Case Setup: E2E_system_setup_with_data_transfer_conducted
    Case Setup

Case Teardown: E2E_system_setup_with_data_transfer_conducted
    Run Keyword And Ignore Error   Case Teardown
