# *** Settings ***
# Documentation
# ...  author: Lei Nie
# ...  contact: lei.nie@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
# ...   SBTS00
# ...   AUTHOR_lei.nie@nokia-sbell.com
# 
# Test Timeout   1h
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# *** Variables ***
# 
# 
# *** Test Cases ***
# [1]CB008538_AEQN_001_Radio_Reset_To_Check_Radio_Startup_Time
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     [Setup]   Case Setup: A_1
#     A_1_Radio_Reset_To_Check_Radio_Startup_Time
#     [Teardown]   Case Teardown: A_1
# 
# [1]CB008538_AEQN_002_Site_Reset_To_Check_Radio_Startup_Time
#     [Documentation]   Author: lei.nie@nokia-sbell.com
#     [Setup]   Case Setup: A_2
#     A_2_Site_Reset_To_Check_Radio_Startup_Time
#     [Teardown]   Case Teardown: A_2
# 
# #CB008538_A_6_Radio_Reset_Multi_Times_To_Check_Radio_Startup_Time
# #    [Documentation]   Author: lei.nie@nokia-sbell.com
# #    [Setup]   Case Setup: A_6
# #    A_6_Radio_Reset_Multi_Times_To_Check_Radio_Startup_Time
# #    [Teardown]   Case Teardown: A_6
# 
# 
# *** Keywords ***
# Common Suite Setup
#     Common Setup CB008538 AEQN
# 
# Common Suite Teardown
#     Run Keyword And Ignore Error   COAM WEBUI Logout
#     #Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
#     Common Teardown CB008538 AEQN
