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
# ...    Feature CB009333 in 5G23R2 program
# 
# Force Tags    5G_RAN_TDD
# 
# *** Variables ***
# 
# *** Test Cases ***
# [1]CB009333-A_01_03_drbDifferentiationEnabled_when_DRB_delay_profile_less_than_Cell_level_for_single_UE_with_single_non-GBR_on_Classical_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Step 2 Online modify parameter to activate legacy feature
#     Step 3 Online modify parameter to activate CB009333
#     Step 4 One single-UE make L3Call and attach to Cell
#     Step 5 Check CB008238 counters
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# *** Keywords ***
