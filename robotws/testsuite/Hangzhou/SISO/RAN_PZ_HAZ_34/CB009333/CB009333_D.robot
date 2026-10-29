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
# [1]CB009333-D_01_01_drxSupportEnabled_when_drxOnDurationTimer_less_than_dtxMaxRetentionDelay_on_Classical_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Step 1 Activated legacy DRX feature where drxOnDurationTimer morethan dtxMaxRetentionDelay
#     Step 2 Online modify parameter to activate legacy feature 5GC000430 5GC000433 CB008238
#     Step 3 Online modify parameter to activate CB009333 on WebUI
#     Step 4 One UE attach and do DL traffic with low traffic tput
#     Step 5 Check TTI and PM counters
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# 
# *** Keywords ***
