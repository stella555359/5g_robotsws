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
# [1]CB009333-B_01_02_multiCellSyncEnabled_when_dtxRoundingOffset_equal_to_0_for_multiple_UE_with_multiple_Cell_connected_the_same_PA_on_Classical_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Step 2 Online modify parameter to activate legacy feature
#     Step 3 Activate CB009333-B Multiple cells synchronization for both cells
#     Step 4 Two UE attach to both cells and do DL traffic with low traffic tput
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# 
# *** Keywords ***
