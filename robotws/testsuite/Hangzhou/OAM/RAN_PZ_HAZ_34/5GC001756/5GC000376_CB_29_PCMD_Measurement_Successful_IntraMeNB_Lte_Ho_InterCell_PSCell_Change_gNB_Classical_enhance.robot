# *** Settings ***
# Documentation
# ...   Author: shengyuan.jiang@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# *** Variables ***
# ${eNB_ue_index}   1
# ${INTRA_MeNB_HO_gNB_FILE}   INTRA_MeNB_HO_gNB.pcap
# ${INTRA_MeNB_HO_gNB_PATH}   ${OUTPUT_DIR}/${INTRA_MeNB_HO_gNB_FILE}
# 
# *** Test Cases ***
# [1]5GC000376_CB_29_PCMD_Measurement_Successful_IntraMeNB_Lte_Ho_InterCell_PSCell_Change_gNB_Classical
#     [Documentation]   Author: liangliang.heng@nokia-sbell.com
#     [Setup]   Case Setup for 5GC000376_CB_29
#     5GC000376_CB_29_PCMD_Measurement_Successful_IntraMeNB_Lte_Ho_InterCell_PSCell_Change_gNB_Classical_enhance
#     [Teardown]   Case Teardown for 5GC000376_CB_29
# 
# *** Keyword ***
# Case Setup for 5GC000376_CB_29
#     Log To Console   Case Setup: 5GC000376_CB_29
#     Common Setup 1756
#     Get HO Suite Variables
#     Remove And Add PCMD Object
#     Run Keyword And Ignore Error   COAM Logout
#     ${source_cell_identity_filter}   Get CellIdentity and Convert it to Filter   ${TL_cellid['${MRBTS_ID}']['source_cellid']}
#     set test variable   ${source_cell_identity_filter}
#     Trigger INTRA eNB HO   ${eNB_ue_index}    ${INTRA_MeNB_HO_gNB_FILE}
#     ${INTRA_MeNB_crnti_HO_list}   Get nrcti of HO   ${INTRA_MeNB_HO_gNB_PATH}   nsetapx.CuVendorExtensionRecordDataType == 7
#     set test variable   ${INTRA_MeNB_crnti_HO_list}
# 
# Case Teardown for 5GC000376_CB_29
#     Log To Console   Case Teardown: 5GC000376_CB_29
#     Run Keyword If Test Failed   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
#     Run Keyword If Test Passed   Run Keyword And Ignore Error   RUN   rm -rf ${INTRA_MeNB_HO_gNB_PATH}
#     Run Keyword And Ignore Error   Initialize PA
#     Run Keyword And Ignore Error   Common Teardown 1756
