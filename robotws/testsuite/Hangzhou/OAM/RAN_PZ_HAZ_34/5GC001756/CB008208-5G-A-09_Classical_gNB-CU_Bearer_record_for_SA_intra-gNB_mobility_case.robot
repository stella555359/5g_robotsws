# *** Settings ***
# Documentation
#  ...    author: jqu003
#  ...    this case will verify keyword for TA of CB008208
# 
# Library     ./Library/list_time_check.py
# Resource   ./Resource/Common.robot
# *** Variables ***
# ${base_xpath}    .//f1ap.F1AP_PDU/f1ap.successfulOutcome_element/f1ap.value_element/f1ap.UEContextModificationResponse_element/f1ap.protocolIEs
# ${c_rnti_xpath}    //f1ap.ProtocolIE_Field_element/f1ap.value_element/f1ap.C_RNTI
# 
# ${SA_ue_index}    0
# ${SA_INTRA_gNB_HO_FILE}   SA_INTRA_gNB_HO.pcap
# ${SA_INTRA_gNB_HO_PATH}   ${OUTPUT_DIR}/${SA_INTRA_gNB_HO_FILE}
# 
# *** Test Cases ***
# CB008208-5G-A-09_Classical_gNB-CU_Bearer_record_for_SA_intra-gNB_mobility
#     [Documentation]   Author: Jing.Qu@nokia-sbell.com
#     [Setup]   Case Setup for CB008208-5G-A-09
#     CB008208-5G-A-09_Classical_gNB-CU_Bearer_record_for_SA_intra-gNB_mobility
#     [Teardown]   Case Teardown for CB008208-5G-A-09
# 
# *** Keywords ***
# Case Setup for CB008208-5G-A-09
#     Log To Console   Case Setup: CB008208-5G-A-09
#     Common Setup 1756
#     Get HO Suite Variables
#     Remove And Add PCMD Object
#     Run Keyword And Ignore Error   COAM Logout
#     Trigger INTRA gNB HO   ${SA_ue_index}    ${SA_INTRA_gNB_HO_FILE}   SA
#     ${SA_INTRA_crnti_HO_list}   Get nrcti of HO    ${SA_INTRA_gNB_HO_PATH}
#     ...   nsetapx.CuVendorExtensionRecordDataType==14 && nsetapx.trigger==2
#     set test variable   ${SA_INTRA_crnti_HO_list}
#     Set CuBearRecord Xpath
# 
# Case Teardown for CB008208-5G-A-09
#     Log To Console   Case Teardown: CB008208-5G-A-09
#     Run Keyword If Test Failed   Save gNB Snapshot   host=${LOCAL_SSH_ADDR}   alias=master
#     Run Keyword If Test Passed   Run Keyword And Ignore Error   RUN   rm -rf ${SA_INTRA_gNB_HO_PATH}
#     Run Keyword And Ignore Error   Initialize PA
#     Run Keyword And Ignore Error   Common Teardown 1756
# 
# 
