*** Settings ***
Documentation
...   author: Chen Yin 4
...   contact: yin.4.chen@nokia-sbell.com
Resource   ../Resource/702.robot
Resource   ../Resource/common.robot

*** Variables ***

*** Keywords ***
Test_Case_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#    Set Common Test Tag   case_key=rfsw_log_fromsnapshot
    ${status}   Run Keyword And Return Status   Verify RFSW Log Include In Snapshot
    Run Keyword If   not ${status}   Log To Console   [Warning] Should Check RFSW Logs IN Snapshot.

Case Setup: Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    Case Setup
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP

Case Teardown: Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    Run Keyword And Ignore Error   COAM Teardown GNB Connections
    Run Keyword And Ignore Error   csn.Disconnect   connection=RU
    Run Keyword And Ignore Error   csn.Disconnect   connection=ASIK Master
    Case Teardown
