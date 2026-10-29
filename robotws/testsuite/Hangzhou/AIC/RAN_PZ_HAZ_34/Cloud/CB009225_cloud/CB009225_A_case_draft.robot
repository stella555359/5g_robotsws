# *** Settings ***
# Documentation
# ...   author: Jing.Qu@nokia-sbell.com
# ...   contact: Jing.Qu@nokia-sbell.com
# ...   Description: This case is to verify intra_gNB inter_DU handover record of CB009225 on Cloud product
# 
# #Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009225_cloud/Common_resource/common_keyword.robot
# Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB009225_cloud/Common_resource/common_keyword.robot
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# Test Timeout   60 minutes
# 
# *** Variables ***
# ${Intra_gNB_Inter_DU_File_SA}    Intra_gNB_inter_DU_SA.pcap
# ${Intra_gNB_Inter_DU_File_NSA}    Intra_gNB_inter_DU_NSA.pcap
# ${dcap_server_ip}    ${tl.test_pcs[0].default_ssh_connection_details.addr}
# ${dcap_server_port}    ${tl.test_pcs[0].default_ssh_connection_details.port}
# 
# *** Test Cases ***
# [1]CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger
#     CB009225_A_03_e2e_B02_Successful_SA_intra_gNB_inter_DU_handover_A3_trigger_cloud
# 
# [1]CB009225_B_04_B02_e2e_gNB_CU_UeDuConectivity_PCMD_record_from_target_cell_during_intra_gNB_inter_DU_mobility_for_NSA_Cloud_gNB
#     CB009225_B_04_B02_e2e_gNB_CU_UeDuConectivity_PCMD_record_intra_gNB_inter_DU_mobility_for_NSA_Cloud_gNB.robot
# 
# CB008187_SR_D_Cloud_SA_05_RAN_UE_ID_Sent_by_gNB_CU_CP_during_Intra_gNB_Inter_DU_Handover
#     Run Keyword And Continue On Failure   Cloud Check PCMD RAN UE ID   pcmd_file_path=${OUTPUT_DIR}/${Intra_gNB_Inter_DU_File_SA}
#     Run Keyword And Continue On Failure   Cloud Check PCMD RAN UE ID   pcmd_file_path=${OUTPUT_DIR}/${Intra_gNB_Inter_DU_File_NSA}
# 
# 
# *** Keywords ***
# Check GNB Health and Reactivation PCMD
#     AiC Common Test Setup
#     OAM Precondition Cell Should Be Onair
#     Should Have Power On All RUs
#     Run Keyword And Ignore Error    Delete Object NRMTRACECU On CU
#     Disable Cell Trace Status On VCU
#     Disable PCMD Status On VCU
# 
# Case Test Teardown
#     [Teardown]  AiC Common Test Teardown
#     Run Keyword And Ignore Error    Delete Object NRMTRACECU On CU
#     Disable Cell Trace Status On VCU
#     Disable PCMD Status On VCU
#     OAM Postcondition Cell Should Be Onair
#     Should Have Power On All RUs
# 
# Common Suite Setup
# #    Check GNB Health and Reactivation PCMD
#     Download wireshark plugin For 1756
#     SA UE Preparation At Case Setup
#     NSA UE Preparation At Case Setup
# 
#     Run Keyword And Continue On Failure    Scenario: Intra-gNB Inter-DU Handover SA
#     Run Keyword And Continue On Failure    Scenario: Intra-gNB Inter-DU Handover NSA
# 
# 
# Common Suite Teardown
#     Log To Console    TearDown TBD...
# 
# Scenario: Intra-gNB Inter-DU Handover SA
#     Log To Console    Start to Cpature Tcpdump Of Intra-gNB Inter-DU Handover SA
#     Initialize PA For SA Call
#     Start Tcpdump On vCU
#     UE Attach And Perform Intra-gNB Inter-DU Handover    ue_index=0
#     [Teardown]  Get Tcpdump From vCU And Combine    local_file=${Intra_gNB_Inter_DU_File_SA}
# 
# Scenario: Intra-gNB Inter-DU Handover NSA
#     Log To Console    Start to Cpature Tcpdump Of Intra-gNB Inter-DU Handover NSA
#     Initialize PA For NSA Call
#     Start Tcpdump On vCU
#     UE Attach And Perform Intra-gNB Inter-DU Handover    ue_index=1
#     [Teardown]  Get Tcpdump From vCU And Combine    local_file=${Intra_gNB_Inter_DU_File_NSA}
# 
# 
# 
# 
