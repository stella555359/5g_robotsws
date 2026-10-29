# *** Settings ***
# Documentation
# ...   author: Chen Yin 4
# ...   contact: yin.4.chen@nokia-sbell.com
# Resource   ./Resource/702.robot
# Resource   ./Resource/common.robot
# Force Tags   SG_08   CA_5G_Siso         CRT   AUTHOR_yin.4.chen@nokia-sbell.com
# ...    PY36
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Setup]   Case Setup Steps
# #    Set Common Test Tag   case_key=rfsw_log_fromsnapshot
#     ${status}   Run Keyword And Return Status   Verify RFSW Log Include In Snapshot
#     Run Keyword If   not ${status}   Log To Console   [Warning] Should Check RFSW Logs IN Snapshot.
#     [Teardown]   Case Teardown Steps
# 
# *** Keywords ***
# Case Setup Steps
#     Case Setup
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master
#     Connect to RU With Allocated IP
# 
# Case Teardown Steps
#     Run Keyword And Ignore Error   COAM Teardown GNB Connections
#     Run Keyword And Ignore Error   csn.Disconnect   connection=RU
#     Run Keyword And Ignore Error   csn.Disconnect   connection=ASIK Master
#     Case Teardown
