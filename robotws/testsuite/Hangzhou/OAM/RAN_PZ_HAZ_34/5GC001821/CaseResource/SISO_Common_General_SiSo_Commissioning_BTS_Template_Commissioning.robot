*** Settings ***
Documentation
...   author: Chen Yin 4
...   contact: yin.4.chen@nokia-sbell.com
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot

*** Variables ***

*** Keywords ***
Test_Case_General_SiSo_Commissioning_BTS_Template_Commissioning
#    Set Common Test Tag   case_key=template_commission
#    Commission Modify actFDMScheduling
#    Check gNB restarted
    Wait until keyword succeeds  10min   1min   COAM Check All Cells Onair
    COAM Reset Configuration

Case Setup: Commissioning_BTS_Template_Commissioning
    Case Setup
    COAM Backup SCF

Case Teardown: Commissioning_BTS_Template_Commissioning
    Run Keyword And Ignore Error   COAM Logout
    Wait Until Keyword Succeeds   20m   1m   COAM Login   bts_host=192.168.255.129
    COAM SCF Commission
    Case Teardown
