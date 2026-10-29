# *** Settings ***
# Documentation     author: Debbie Wang
# ...               contact: debbie.wang@nokia-sbell.com
# ...               squad group: mmw_SG_04
# Force Tags        5G_RRM    5GC000523    CRT_19B    CRT_TRUNK    CRT_20B        
# ...    PY36
# Suite Setup       suite setup to prepare default scf
# Suite Teardown       robot_common_operations.Common Suite Teardown
# 
# Library           OperatingSystem
# Library           Collections
# Library           BuiltIn
# Library           String
# Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
# #Library           ../../../../resources/python_libs/check_csv_log.py
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
# Library           ./Resources/523_TTI_Trace_Analysis.py
# Resource          ./Resources/5GC000523_common_keyword.robot
# Library           taf.transport.ssh    WITH NAME    csn
# Library    taf.analyzer.pcap    WITH NAME    cap
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${4G_IP}               ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${gNB_ip}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# ${gNB_username}        ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}        ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TS_LOG_PATH_BASE}    /home/ute/robotws5g/testsuite/RRM/Hangzhou/5GC000523/log
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# ${BTS_ID}                ${tl.enbs[0].instance_id}
# 
# 
# 
# *** Test Cases ***
# [1]5GC000523_L_CSI-IM_periodic_CSI_Configuration_for_1UE_No_Data_aBF
#     [Tags]    5GC000523   CIT_TRUNK     CIT_21B    CRT_22R1    CRT_22R2    CDRT_22R1
#     [Setup]    523 Case Setup
#     GNB ready and UE attach capture asik X2 log    ue_num=${1}
#     Analysis X2Log And Get Element Vlaue    source=${output_dir}/${523_X2}    target=${output_dir}/S1-X2AP_523.txt
#     ...    element_list=${element_parameter}    exp_element_dic=${exp_element_dic}    element_parameter=${element_parameter1}
#     [Teardown]     case teardown
# 
# *** Keywords ***
# 523 Case Setup
#     robot_common_operations.Common Case Setup
#     change 4G configuration
#     COAM Create log directory
# 
# change 4G configuration
#     Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${gNB_username}    password=${gNB_password}    connection=4G_admin
#     perform muti Parameter recommissioning
#     ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=1
#     ...    operation=update
#     ...    connection=4G_admin
#     coam.teardown     connection=4G_admin
# 
# perform muti Parameter recommissioning
#     [Arguments]   ${dist_name}    ${parameter}   ${value}     ${operation}=create    ${connection}=cOAM_admin
#     ...    ${skip_parameter_relation_errors}=${True}     ${should_activate}=${True}
#     coam.Perform Parameter Recommissioning
#     ...    dist_name=${dist_name}
#     ...    parameter=${parameter}
#     ...    value=${value}
#     ...    operation=${operation}
#     ...    skip_parameter_relation_errors=${skip_parameter_relation_errors}
#     ...    should_activate=${should_activate}
#     ...    connection=${connection}
# 
# Analysis X2Log And Get Element Vlaue
#     [Arguments]  ${source}    ${target}    ${element_list}    ${exp_element_dic}    ${element_parameter}    ${filter}=${EMPTY}
#     Convert pcap file to txt    source=${source}    target=${target}   filter=${filter}
#     ${element_dict}    Get_X2log_Element_Value_From_List    element_list=${element_list}     txt_file=${target}
#     ${element_keys}   get dictionary keys  ${element_dict}
#     FOR    ${item}   IN   @{exp_element_dic}
#         ${element_value_list}    get from dictionary  ${element_dict}    ${item}
#         ${exp_element_value}    get from dictionary    ${exp_element_dic}    ${item}
#         run keyword and continue on failure    list should contain value    ${element_value_list}    ${exp_element_value}
#     END
#     ${symbolLocation-p1_value}    get from dictionary    ${element_dict}    symbolLocation-p1
#     ${check_parameter2_value_list}    Check_symbolLocation_p1_Value    txt_file=${target}   check_parameter1=@{element_parameter2}[0]
#     ...    check_parameter2=@{element_parameter2}[1]
#     run keyword and continue on failure    should be equal as strings  @{symbolLocation-p1_value}[0]    @{check_parameter2_value_list}[0]
#     FOR    ${item1}  IN    @{element_parameter}
#         ${value}    Get_txt_content_By_Linecache    txt_file=${target}     element=@{item1}[0]     check_element=@{item1}[1]
#         run keyword and continue on failure    should be equal as numbers  ${value}    0
#     END
# 
# case teardown
#     run keyword and continue on failure    detach multi power ue    ue_num=${1}
#     run keyword and continue on failure    COAM Teardown gnb connections
#     robot_common_operations.Common Case Teardown
#     CI_interface.Common Case Teardown
# 
# Start to Capture X2 Log on Asik any port
#     [Arguments]    ${filename}    ${connection}=ASIK Master
#     Connect to Common Unit Master
#     csn.send command    command=killall tcpdump    connection=${connection}
#     csn.send command    command=tcpdump sctp -i any -w ${gnb_tmp_log_dir}/${filename} &>/dev/null &
#     ...    connection=${connection}
#     sleep    3s
# 
# GNB ready and UE attach capture asik X2 log
#     [Arguments]    ${ue_num}
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     COAM Commission with scf file    scf_file_path=${default_scf}
#     Wait until keyword succeeds    15 min    20 sec    COAM Wait for gnb ready and cell setup
#     log    \n start capture x2    console=yes
#     Start to Capture X2 Log on Asik any port   filename=${523_X2}
#     log    \n start attach    console=yes
#     attach multi power ue    ue_num=${ue_num}
#     Stop and Download Log    filename=${523_X2}
# 
# Stop and Download Log
#     [Arguments]    ${filename}    ${asik}=ASIK Master
#     Connect to Common Unit Master
#     ${PID}  csn.Execute  command=ps -ef |grep tcpdump|awk '{{print $2}}'|head -n 1
#     ...    connection=${asik}
#     ${PID}    strip_string    ${PID}
#     csn.Execute    command=kill -2 ${PID}    connection=${asik}
#     csn.download_file    remote_path=${gnb_tmp_log_dir}/${filename}    local_path=${output_dir}/${filename}
#     ...    connection=${asik}
#     sleep    2s
#     csn.execute    command=rm ${gnb_tmp_log_dir}/${filename}    connection=${asik}
#     Csn.Disconnect	connection=${asik}
# 
# Read Wireshark Log
#     [Arguments]    ${filename}    ${filter}=${None}
#     cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}
# 
# Get PARAM Value from Wireshark Log
#     [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
#     ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
#     ...    default_value=${default_value}    condition_expression=${condition_expression}
#     [Return]    ${value}
# 
# #check tti trace csiSrReportData
# #    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}=DL
# #    ${path}    get from dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
# #    ${ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
# #    ${rnti_list}    ${ue_rnti_number}   get_multi_rntis_from_tti_trace_19b    path=${ul_path}
# #    ${sfn_list}    ${sfn_diff_list}    get_csisrreportdata_sfn_by_rnti_19b    file_path=${path}    rnti=${rnti_list[-1]}
# #    check csi report periodically    sfn_diff_list=${sfn_diff_list}
# #
# #check csi report periodically
# #    [Arguments]    ${sfn_diff_list}
# #    ${sfn_diff_4_num}    evaluate  ${sfn_diff_list}.count(4)
# #    log    ${sfn_diff_4_num}
# #    ${sfn_diff_length}    get length    ${sfn_diff_list}
# #    ${ratio}    evaluate    float(${sfn_diff_4_num})/float(${sfn_diff_length})
# #    should be true    ${ratio}>=0.95
