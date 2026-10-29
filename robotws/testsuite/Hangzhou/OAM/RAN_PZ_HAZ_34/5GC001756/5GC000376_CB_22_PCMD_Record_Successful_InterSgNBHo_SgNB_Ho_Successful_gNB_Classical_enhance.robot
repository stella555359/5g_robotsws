# *** Settings ***
# Documentation
# ...   Author: shengyuan.jiang@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# *** Variables ***
# ${NSA_ue_index}   1
# ${NSA_INTER_gNB_HO_TARGET_FILE}   NSA_INTER_gNB_HO_TARGET.pcap
# ${NSA_INTER_gNB_HO_SOURCE_FILE}   NSA_INTER_gNB_HO_SOURCE.pcap
# ${NSA_INTER_gNB_HO_TARGET_PATH}   ${OUTPUT_DIR}/${NSA_INTER_gNB_HO_TARGET_FILE}
# ${NSA_INTER_gNB_HO_SOURCE_PATH}   ${OUTPUT_DIR}/${NSA_INTER_gNB_HO_SOURCE_FILE}
# 
# *** Test Cases ***
# [1]5GC000376_CB_22_PCMD_Record_Successful_InterSgNBHo_SgNB_Ho_Successful_gNB_Classical
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup for 5GC000376_CB_22
#     5GC000376_CB_22_PCMD_Record_Successful_InterSgNBHo_SgNB_Ho_Successful_gNB_Classical_enhance
#     [Teardown]   Case Teardown for 5GC000376_CB_22
# 
# *** Keyword ***
# Case Setup for 5GC000376_CB_22
#     Log To Console   Case Setup: 5GC000376_CB_22
#     Common Setup 1756
#     Get HO Suite Variables
#     Remove And Add PCMD Object
#     Run Keyword And Ignore Error   COAM Logout
#     Read Freqency
#     Get Physical Cell ID from Target gnb
#     ${source_cell_identity_filter}   Get CellIdentity and Convert it to Filter   ${TL_cellid['${MRBTS_ID}']['source_cellid']}
#     set test variable   ${source_cell_identity_filter}
#     Trigger INTER gNB HO   ${NSA_ue_index}    ${NSA_INTER_gNB_HO_TARGET_FILE}   ${NSA_INTER_gNB_HO_SOURCE_FILE}   NSA
#     ${NSA_INTER_target_crnti_HO_list}   Get nrcti of HO    ${NSA_INTER_gNB_HO_TARGET_PATH}
#     ...   nsetapx.CuVendorExtensionRecordDataType == 9
#     set test variable   ${NSA_INTER_target_crnti_HO_list}
#     ${NSA_INTER_source_crnti_HO_list}   Get nrcti of HO   ${NSA_INTER_gNB_HO_SOURCE_PATH}
#     ...   nsetapx.CuVendorExtensionRecordDataType == 8
#     set test variable   ${NSA_INTER_source_crnti_HO_list}
# 
# Case Teardown for 5GC000376_CB_22
#     log to console   Case Teardown for 5GC000376_CB_22
#     Run Keyword If Test Failed   run keywords   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
#     ...   AND   Save gNB Snapshot   host=${PEER_SSH_ADDR}   alias=PEER
#     Run Keyword If Test Passed   Run Keyword And Ignore Error   run keywords   RUN   rm -rf ${NSA_INTER_gNB_HO_SOURCE_PATH}
#     ...   AND   rm -rf ${NSA_INTER_source_crnti_HO_list}
#     Run Keyword And Ignore Error   Initialize PA
#     Run Keyword And Ignore Error   Common Teardown 1756
# 
