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
# [1]CB009333-F_01_01_rlcStatusPduSupportEnabled_for_DL_RLC_ACK_NACK_status_PDU_for_UL_packet_when_single_UE_with_single_non-GBR_on_Classical_SA
#     [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK
#     [Setup]    SISO Coam Test Setup
#     Selenium Login And Disable Screen Lock
#     Step 1 Online modify parameter to activate legacy feature CB008238
#     Step 2 Online modify CB009333 rlcStatusPduSupportEnabled on WebUI
#     Step 3 UE attach and do UL traffic
#     Step 4 Check highestClassPriority17 not in TTI log
#     Step 5 UE attach and do DL traffic
#     Step 6 Check highestClassPriority17 in TTI log
#     [Teardown]    Run keywords     Selenium Logout And Close Browser
#     ...    AND   SISO Coam Test Teardown
# 
# *** Keywords ***
