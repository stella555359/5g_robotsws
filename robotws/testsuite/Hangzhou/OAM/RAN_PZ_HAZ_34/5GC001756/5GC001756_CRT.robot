# *** Settings ***
# Documentation
# ...  author: Chen Yin 4
# ...  contact: yin.4.chen@nokia-sbell.com   lei.nie@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# Resource   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# 
# Force Tags   SG_07   CA_5G_OAM   STATE_SW_UPDATED   RAN_5G   RAN_5G_TDD
# ...    PY36
# ...   CLOUD_5G_CLASSICAL_ANDROID_SA_ASIKL_ABILB1_AEQN_NETACT   SBTS00
# ...   AUTHOR_yin.4.chen@nokia-sbell.com
# 
# Test Timeout   4h
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# *** Variables ***
# ${ue_index}   ${0}
# 
# *** Test Cases ***
# #------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------
# 5GC001756_B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup: B_3
#     B_3_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_WebEM
#     [Teardown]   Case Teardown: B_3
# 
# 5GC001756_B_5_SA_ClassicalgNB_PCMD_Deactivation_From_WebEM
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup: B_5
#     B_5_SA_ClassicalgNB_PCMD_Deactivation_From_WebEM
#     [Teardown]   Case Teardown: B_5
# 
# 5GC001756_B_4_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup: B_4
#     B_4_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct
#     [Teardown]   Case Teardown: B_4
# 
# 5GC001756_B_6_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup: B_6
#     B_6_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct
#     [Teardown]   Case Teardown: B_6
# 
# # 5GC001756_B_9_SA_ClassicalgNB_No_PCMD_gNBDU_Uplane_Measurements_In_Case_Of_TCP_link_loss_with_TCE
# #    [Documentation]   Author: liangliang.heng@nokia-sbell.com
# #    Log To Console   //TODO:
# 
# 5GC001756_B_45_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct_Trace_Expert_for_5G_Radio_Cell_PCMD
#     [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#     [Setup]   Case Setup: B_45
#     B_45_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct_Trace_Expert_for_5G_Radio_Cell_PCMD
#     [Teardown]   Case Teardown: B_45
# 
# 5GC001756_B_46_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct_Trace_Expert_for_5G_Radio_Cell_PCMD
#     [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#     [Setup]   Case Setup: B_46
#     B_46_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct_Trace_Expert_for_5G_Radio_Cell_PCMD
#     [Teardown]   Case Teardown: B_46
# 
# 5GC001756_B_43_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct_Trace_Expert_for_5G_Radio_gNB-CU_PCMD
#     [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#     [Setup]   Case Setup: B_43
#     B_43_SA_ClassicalgNB_PCMD_Configuration_And_Activation_From_NetAct_Trace_Expert_for_5G_Radio_gNB-CU_PCMD
#     [Teardown]   Case Teardown: B_43
# 
# 5GC001756_B_44_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct_Trace_Expert_for_5G_Radio_gNB-CU_PCMD
#     [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#     [Setup]   Case Setup: B_44
#     B_44_SA_ClassicalgNB_PCMD_Deactivation_From_NetAct_Trace_Expert_for_5G_Radio_gNB-CU_PCMD
#     [Teardown]   Case Teardown: B_44
# 
# 5GC001756_B_47_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined_From_NetAct_Trace_Expert
#     [Documentation]   Author: shengyuan.jiang@nokia-sbell.com
#     [Setup]   Case Setup: B_47
#     B_47_SA_ClassicalgNB_Streaming_PCMD_Cell_Trace_combined_From_NetAct_Trace_Expert
#     [Teardown]   Case Teardown: B_47
# 
# #------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------
# # every case every call
# 5GC001756_D_10_SA_ClassicalgNB_Reset_After_PCMD_Activation
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup: D_10
#     D_10_SA_ClassicalgNB_Reset_After_PCMD_Activation
#     [Teardown]   Case Teardown: D_10
# 
# 5GC001756_D_32_SA_ClassicalgNB_PCMD_Report_after_cell_from_lock_to_unlock
#     [Documentation]   Author: yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: D_32
#     D_32_SA_ClassicalgNB_PCMD_Report_after_cell_from_lock_to_unlock
#     [Teardown]   Case Teardown: D_32
# 
# 5GC001756_D_33_SA_ClassicalgNB_PCMD_Report_after_RU_reset
#     [Documentation]   Author: yin.4.chen@nokia-sbell.com
#     [Setup]   Case Setup: D_33
#     D_33_SA_ClassicalgNB_PCMD_Report_after_RU_reset
#     [Teardown]   Case Teardown: D_33
# 
# #------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------
# #------------------------------------------------------------------------------------------------------------
# 
# *** Keywords ***
# Common Suite Setup
#     # Run Keyword And Ignore Error   Check Extra Reset From Blackbox
#     ${TEST_NAME}   Set Variable   Suite_Setup
#     Common Setup 1756
#     Get PCMD Value
#     ${Reset_Reason}   Get Last Reset from Blackbox
#     Set Suite Variable   ${RESET_REASON}
#     # Remove And Add PCMD Object
#     # Make L3CALL And Get ALL PCMD MSG
#     # ${all_pcmd_timestamp}   get_all_pcmd_timestamp   source_file=${TXT_FILE}
#     # Set Suite Variable   ${ALL_PCMD_TIMESTAMP}
# 
# Common Suite Teardown
#     Run Keyword And Ignore Error   COAM WEBUI Logout
#     Run Keyword And Ignore Error   Run Keyword If Any Tests Failed   Catch Snapshot COAM
#     Common Teardown 1756
