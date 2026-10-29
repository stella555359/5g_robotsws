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
# [1]CB009333-W_01_04_Single-UE_EnhDtxOptimizedScheduler_E2E_scheduled_ping_latency_for_TDD_FR1_5GC001208_on_Classical_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     General_gnb_can_be_on_air_with_Given_Information    band=100   frame_structure=1208_GP1_A1   dl_ul_layer=4DL4UL
# 	...    prach_index=${92}
#     Selenium Login And Disable Screen Lock
#     Step 1 Online modify parameter to activate legacy feature 5GC000430 CB008238
#     Step 2 Online modify CB009333 on WebUI
#     Step 3 Online modify Scheduled ping latency
#     Step 4 UE attach and check ping latency
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# 
# *** Keywords ***
