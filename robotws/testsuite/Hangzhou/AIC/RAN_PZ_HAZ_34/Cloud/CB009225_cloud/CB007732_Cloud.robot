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
# ${target_version}   0.300.xxx
# ${testline_name}   7_5_UTE5G401T878
# ${dcap_server_ip}    ${tl.test_pcs[1].default_ssh_connection_details.addr}
# ${dcap_server_port}    ${tl.test_pcs[1].default_ssh_connection_details.port}
# 
# *** Test Cases ***
# CB007732-5G-A-02_Cloud_Activation_of_the_Subscriber_Trace_Content_with_Default_TCE_Defined
#     Initialize PA For SA Call
#     Start Tcpdump On vCU
#     UE Attach And Perform Intra-gNB Inter-DU Handover   ue_index=0
#     Get Tcpdump From vCU And Combine   local_file=${Intra_gNB_Inter_DU_File_SA}
#     Load Pcap File with Filter any Expression
#     ...   pcap_file=${OUTPUT_DIR}/${Intra_gNB_Inter_DU_File_SA}
#     ...   any_expression=nsetapx.traceActivationType==sba
#     ...   filter=tcp.dstport==${dcap_server_port}
#     @{seconds_list}   wireshark.get_field_value_by_xpath   xpath=.//nsetapx.TraceMessage
#     Should Not Be Empty   ${seconds_list}
# 
# *** Keywords ***
# Common Suite Setup
#     Log To Console   Common Suite Setup
#     robot_common_operations.Common Suite Setup
#     Get Cloud Release
#     Download wireshark plugin For 1756
#     SA UE Preparation At Case Setup
#     Setup Core Simulator
#     CU Full Commssion By Rest
#     ...   path_of_commission_file=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/gnbs_0/cu/SCF_${cu_release}_SBA.xml
#     ...   plan_name=sba_scf
#     Wait Until Keyword Succeeds   15m   1m   CU Verify All Cells Status Are Onair
# 
# Common Suite Teardown
#     Log To Console   Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
#     CU Full Commssion By Rest
#     ...   path_of_commission_file=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/gnbs_0/cu/SCF_${cu_release}.xml
#     ...   plan_name=normal_scf
#     Wait Until Keyword Succeeds   15m   1m   CU Verify All Cells Status Are Onair
# 
# Get Cloud Release
#     ${str_list}   Split String   ${target_version}   .
#     ${release}   Set Variable   ${str_list[0]}
#     Set Suite Variable   ${cu_release}   ${release}.250
#     Set Suite Variable   ${du_release}   ${release}.300
# 
# Case Setup
#     robot_common_operations.Common Case Setup
# 
# Case Teardown
#     robot_common_operations.Common Case Teardown