# *** Settings ***
# Documentation
# ...   author: Jing.Qu@nokia-sbell.com
# ...   contact: Jing.Qu@nokia-sbell.com
# ...   Description: This case include verification of CB009444 parity CB008208 and CB009225 NSA call scenario
# #Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot
# 
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# #Test Timeout   60 minutes
# 
# *** Variables ***
# 
# ${dcap_server_port}     49148
# ${NSA_InterDU_HO_VCU_CPIF_file}    NSA_InterDU_HO_cpif.pcap
# ${NSA_InterDU_HO_VCU_OAMAGENT_file}    NSA_InterDU_HO_cuoamext.pcap
# ${NSA_InterDU_HO_VCU_merged_file}    NSA_InterDU_HO_megerd.pcap
# ${nsa_ue_index}        1
# ${source_cell_identity_filter}     00:0d:bc:00:10
# ${target_cell_identity_filter}     00:0d:bc:00:20
# ${cellIdentity}    14401538
# ${NSA_INTRA_gNB_HO_PATH}    ${OUTPUT_DIR}/${NSA_InterDU_HO_VCU_merged_file}
# 
# *** Test Cases ***
# [1]CB009444_Parity_CB008208_CB009225_NSA_regression
#     [Setup]    Run Keywords   robot_common_operations.Common Case Setup   AND   Set Crnti HO Variables
#     Log To Console    \n Check Trace Record For CB009444
#     CB008208_CB009225_for_NSA_intra_en_gNB_inter_DU_mobility_check
#     [Teardown]  robot_common_operations.Common Case Teardown
# 
# 
# *** Keywords ***
# CB008208_CB009225_for_NSA_intra_en_gNB_inter_DU_mobility_check
#     Run Keyword And Continue On Failure
#     ...   CB009444_CB008208_SgnbInitiatedSgNBModRecord_for_NSA_intra_en_gNB_inter_DU_mobility
#     Run Keyword And Continue On Failure
#     ...   CB009444_CB008208_MenbConnectivityRecord_for_NSA_intra_en_gNB_inter_DU_mobility
#     Run Keyword And Continue On Failure
#     ...   CB009444_CB008208_gNBCubearerRecord_for_NSA_intra_en_gNB_inter_DU_mobility
#     Run Keyword And Continue On Failure
#     ...   CB009444_CB008208_UeDuConectivityRecord_for_NSA_intra_en_gNB_inter_DU_mobility
# 
# Common Suite Setup
#     robot_common_operations.Common Suite Setup
#     Download wireshark plugin For 1756
#     NSA UE Preparation At Case Setup
#     Run Keyword And Continue On Failure    Scenario: Intra-gNB Inter-DU Handover NSA And Download Log
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
#     Log To Console    TearDown TBD...
# 
# Scenario: Intra-gNB Inter-DU Handover NSA And Download Log
#     ${pavalue_879cell1}   Create List   0   0   127   127   127   127   127   127   20   20   127   127   127   127   127   127
#     Modify All Attenuation Ports Value For Specific RU For Cloud     RU_id=0   value=${pavalue_879cell1}
#     Enable Tcpdump on vCU Container   pod_abbr=cpif   file_name=${NSA_InterDU_HO_VCU_CPIF_file}
#     Enable Tcpdump on vCU Container   pod_abbr=oamext   file_name=${NSA_InterDU_HO_VCU_OAMAGENT_file}
#     new_power_UE.UE Attach    ue_index=${nsa_ue_index}
#     Sleep    5s
#     Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=2   value=0
#     Sleep    5s
#     Run Keyword And Ignore Error    New Commercial UE detach    ue_index=${nsa_ue_index}
#     Modify All Attenuation Ports Value For Specific RU For Cloud   gnb_id=0   RU_id=0   value=127
#     Disable Tcpdump on vCU And Download The File    pod_abbr=cpif    file_name=${NSA_InterDU_HO_VCU_CPIF_file}
#     Disable Tcpdump on vCU And Download The File    pod_abbr=oamext    file_name=${NSA_InterDU_HO_VCU_OAMAGENT_file}
#     Combin Pcap File And Remove tempDump File
#     ...    local_file=${NSA_InterDU_HO_VCU_merged_file}    file1=${NSA_InterDU_HO_VCU_CPIF_file}    file2=${NSA_InterDU_HO_VCU_OAMAGENT_file}
# 
# Get eNB Variables
#     &{eNB_info}   Create Dictionary
#     Set To Dictionary   ${eNB_info}   globaleNBId   ${tl.enbs[0].global_bts_id}
#     Set To Dictionary   ${eNB_info}   ip   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
#     [Return]  &{eNB_info}
# 
# Set Crnti HO Variables
#     ${NSA_INTRA_target_crnti_HO_list}   ${NSA_INTRA_source_crnti_HO_list}   Get nrcti of Target and Source in NSA intra 
# ...HO   ${NSA_INTRA_gNB_HO_PATH}
#     set test variable   ${NSA_INTRA_target_crnti_HO_list}
#     set test variable   ${NSA_INTRA_source_crnti_HO_list}