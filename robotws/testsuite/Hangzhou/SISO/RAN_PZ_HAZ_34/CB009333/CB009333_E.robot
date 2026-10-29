# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# #Test Setup           SISO Coam Test Setup
# #Test Teardown        SISO Coam Test Teardown
# Test Timeout         60 min
# 
# Resource    ./resource/CB009333_Common_KW.robot
# 
# Documentation
# ...    Author: Zhang Xuewen
# ...    Contact: xuewen.zhang@nokia-sbell.com
# ...    squad group:SG_05
# ...    Feature CB009333 in 5G23R3 program
# 
# Force Tags    5G_RAN_TDD
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009333-E_01_01_EnhDtxOptimizedScheduler_interaction_with_SliceAwareScheduler_when_multiple_UE_with_single_non-GBR_on_Classical_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK    1S-2CC-4D-4U_9333-E
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Step 1 Activated legacy Slice Aware Scheduler feature
#     Step 2 Online modify parameter to activate legacy feature 5GC000430 5GC000433
#     Step 3 Online modify parameter to activate CB008238 and CB009333 on WebUI
#     Step 4 Two UEs attach and do DL traffic with low traffic tput
#     Step 5 CB009333-E Check TTI and PM counters
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# 
# *** Keywords ***
