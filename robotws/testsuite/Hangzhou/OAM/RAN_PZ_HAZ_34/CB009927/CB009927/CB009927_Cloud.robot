# *** Settings ***
# Resource   ../Resource/Common.robot
# 
# Suite Setup   Common Suite Setup
# Suite Teardown   Common Suite Teardown
# 
# 
# *** Variables ***
# # &{bts_vcu}   host=10.57.179.4   username=Nemuadmin   password=Nokia@123   port=443
# # &{bts_vdu}   host=10.64.163.250   username=Nemuadmin   password=Nokia@123   port=443
# # &{bts_vcu}
# # ...   host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
# # ...   username=${tl.gnbs[0].cu.oam_http_connection_details.username}
# # ...   password=${tl.gnbs[0].cu.oam_http_connection_details.password}
# # ...   port=443
# # &{bts_vdu}
# # ...   host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
# # ...   username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
# # ...   password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
# # ...   port=443
# # @{bts_cloud}   ${bts_vcu}   ${bts_vdu}
# 
# 
# ${TESTLINE_TYPE}   CLOUD
# ${ue_index}   ${1}
# ${emil_host}   ${tl.ues[${ue_index}].ssh_connection_details.addr}
# ${emil_user}   ${tl.ues[${ue_index}].ssh_connection_details.username}
# ${emil_password}   ${tl.ues[${ue_index}].ssh_connection_details.password}
# 
# 
# *** Test Cases ***
# CB009927_CR_A_Inclusion_of_data_decoders_into_BTS_build
#     Log To Console   ${EMPTY}
# 
#     ${result_id}   Start Trace On DCAP Basic WEB   bts_dict=${BTS_CLOUD}
#     Sleep   10s
# 
#     # L3 CALL
#     # Modify All Attenuation Ports Value For Specific RU   RU_id=0   value=0
#     # Modify All Attenuation Ports Value For Specific RU   RU_id=1   value=127
#     # Modify All Attenuation Ports Value For Specific RU   RU_id=2   value=127
#     # Modify All Attenuation Ports Value For Specific RU   RU_id=3   value=127
#     # Modify All Attenuation Ports Value For Specific RU   RU_id=4   value=127
# 
#     Run Keyword And Ignore Error   CB009927 L3 Call
# 
# 
#     ${downloaded_emil_file_path}   Stop Trace On DCAP Basic WEB   result_id=${result_id}
#     ${emil_log_file_list}   ${sack_file_list}   Exact Dcap log   downloaded_emil_file_path=${downloaded_emil_file_path}
# 
#     Upload IDA File To EMIL Server
#     ...   sack_file_list=${sack_file_list}
#     ...   emil_host=${emil_host}
#     ...   emil_user=${emil_user}
#     ...   emil_password=${emil_password}
# 
#     ${emil_txt_file}   Covert Emil Logs to TXT
#     ...   file_list=${emil_log_file_list}
#     ...   emil_host=${emil_host}
#     ...   emil_user=${emil_user}
#     ...   emil_password=${emil_password}
# 
#     ${output}   OperatingSystem.Run   cat ${emil_txt_file} | grep TRACE_CONTROLLER_NR_APP
#     Should Contain   ${output}   TRACE_CONTROLLER_NR_APP
# 
# 
# *** Keywords ***
# Common Suite Setup
#     Log To Console   Common Suite Setup
# 
#     Connect To DCAP Basic WEB
# 
#     @{BTS_CLOUD}   Create List
#     &{bts_vcu}   Create Dictionary
#     ...   host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
#     ...   username=${tl.gnbs[0].cu.oam_http_connection_details.username}
#     ...   password=${tl.gnbs[0].cu.oam_http_connection_details.password}
#     ...   port=443
# 
#     Append To List   ${BTS_CLOUD}   ${bts_vcu}
# 
#     :FOR   ${tl_vdu}   IN   @{tl.gnbs[0].dus}
#         &{bts_vdu}   Create Dictionary
#         ...   host=${tl_vdu.oam_http_connection_details.addr}
#         ...   username=${tl_vdu.oam_http_connection_details.username}
#         ...   password=${tl_vdu.oam_http_connection_details.password}
#         ...   port=443
#         ${isBtsVduConnect}   Run Keyword And Return Status   Create BTS On DCAP Basic WEB   bts_dict=${bts_vdu}
#         Run Keyword If   ${isBtsVduConnect}   Append To List   ${BTS_CLOUD}   ${bts_vdu}
#     END
#     Set Suite Variable   ${BTS_CLOUD}
# 
# 
# Common Suite Teardown
#     Log To Console   Common Suite Teardown
# 
