# *** Settings ***
# Documentation
# ...   author: Chen Yin 4
# ...   contact: yin.4.chen@nokia-sbell.com
# Resource   ./Resource/702.robot
# Resource   ./Resource/common.robot
# Force Tags   SG_07   CA_5G_Siso         CRT
# ...    PY36
# 
# *** Test Cases ***
# [1]General_SiSo_Commissioning_BTS_Template_Commissioning
#     [Tags]    AUTHOR_yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup Steps
# #    Set Common Test Tag   case_key=template_commission
# #    Commission Modify actFDMScheduling
# #    Check gNB restarted
#     Wait until keyword succeeds  10min   1min   COAM Check All Cells Onair
#     COAM Reset Configuration
#     [Teardown]   Case Teardown Steps
# 
# *** Keywords ***
# Case Setup Steps
#     Case Setup
#     COAM Backup SCF
# 
# Case Teardown Steps
#     Run Keyword And Ignore Error   COAM Logout
#     Wait Until Keyword Succeeds   20m   1m   COAM Login   bts_host=192.168.255.129
#     COAM SCF Commission
#     Case Teardown
