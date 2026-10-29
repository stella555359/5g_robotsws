# *** Settings ***
# Force Tags    PY36
# Documentation  Suite description
# ...            author Tian Chun
# ...            chun.tian@nokia-sbell.com
# ...            squad group: mmw_04
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library     taf.transport.ssh            WITH NAME    csn
# Library    taf.analyzer.pcap    WITH NAME    cap
# 
# Library     ./Resources/5GC002238_RA_common.py
# 
# *** Variables ***
# ${dscp_value}                 ${10}
# ${DU_username}                ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${DU_password}                ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${DU_URL}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${NRBTS}                      ${tl.gnbs[0].global_bts_id}
# ${MRBTS}                      ${tl.gnbs[0].instance_id}
# ${CU_OAM_IP}                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${CU_SSH_USERNAME}            ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${CU_OAM_SSH_PASSWORD}        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${cu_fronthaul_ip_value}      ${tl.gnbs[0].cu.f1u.v4}
# ${du_ip_value}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${DSCP_CASE_LOG_PATH}         ${output_dir}
# ${test_ute}                   ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}              ${tl.test_pc.default_ssh_connection_details.password}
# ${F1_U}                       ${tl.gnbs[0].cu.f1u.v4}
# ${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
# ${luashark_path}              /opt/ute/luashark/luashark_script/generated_luashark
# ${DST_FOR_FRM}                MRBTS-${MRBTS}/NRBTS-${NRBTS}/NRDRB-7
# ${ul_throughput}              5M
# ${filename}                   attach_tcp.pcap
# ${connection}                 cu_conn
# ${listen_port}                fronthaul
# ${log_dir}                    /tmp
# ${tl_name}                    tl${MRBTS}
# ${ver_value}                  4
# 
# *** Test Cases ***
# #[1] 5GC001187_A_5GC000309_B_1_GTP PDU sending in UL over IPv4
# #    [Tags]     CRT_21B    CRT_22R2
# #    [Setup]   Set test variable   ${LOG_PATH}      ${DSCP_CASE_LOG_PATH}
# #    Step1: Case Setup ready
# #    Step2: attach multi power ue    ue_num=${1}
# #    Step3: Start to Capture wireshark Log     listen_port=${listen_port}     log_dir=${log_dir}    filename=attach_tcp.pcap
# #    ...   connection=${connection}
# #    Convert pcap to text And Get txt Content    pacp_filename=${filename}   txt_filename=attach_tcp.txt
# #     ...    except_ver_value=4    except_DU_URL=${DU_URL}    except_F1_U=${F1_U}
# #    [Teardown]   Case Teardown
# 
# *** Keywords ***
# Step1: Case Setup ready
#     Du login page via webUI
#     selenium_coam.set parameter value    dist_name=${DST_FOR_FRM}    filter_param=DSCP   new_value=${dscp_value}
#     Active New Parameter Value
#     [Teardown]    DU COAM selenium logout
# 
# Du login page via webUI
#     [Documentation]  Author: Tian Chun
#     ...              Description: If case failed, the snapshot from webUI will be stored in the ${download_dir} folder
#     selenium_coam.enable_virtual_display
#     selenium_coam.login    url=https://${DU_URL}
#     ...                    username=${DU_username}
#     ...                    password=${DU_password}
#     selenium_coam.disable_message_box
# 
# Step3: Start to Capture wireshark Log
#     [Arguments]    ${listen_port}    ${log_dir}    ${filename}     ${connection}
#     csn.connect_to   hostname=${CU_OAM_IP}  username=${CU_SSH_USERNAME}   password=${CU_OAM_SSH_PASSWORD}    alias=${connection}
#     csn.send command    command=ssh mmw-${tl_name}-1-upue-000.local -- timeout 3 sudo tcpdump -i ${listen_port} -w ${log_dir}/${filename} -Z root
#     ...     connection=${connection}
#     sleep    2s
#     Stop and Download Log     filename=${filename}
#     stop multi power ue traffic ul    ue_num=${1}
# 
# Step2: attach multi power ue
#     [Arguments]    ${ue_num}
#     log to console       Prepare UE
#     FOR    ${item}    IN RANGE    ${ue_num}
#          ${status}    run keyword and return status    power ue attach again    ${item}
#          run keyword unless    ${status}    power ue attach again    ${item}
#     END
#     start multi power ue traffic ul  ue_num=${1}    ul_throughput=${ul_throughput}
# 
# power ue attach again
#     [Arguments]    ${ue_index}
#     power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
#     power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
# 
# start multi power ue traffic ul
#     [Arguments]    ${ue_num}    ${ul_throughput}=${None}        ${ul_duration}=6000    ${protocol}=udp
#     log to console      Start traffic    console=yes
#     FOR    ${item}    IN RANGE    ${ue_num}
#          power_ue.Start traffic    ue_index=${item}    direction=ul
#          ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
#           sleep    1s
#     END
# 
# Active New Parameter Value
#     selenium_coam.validate plan
#     ${activate_result}    selenium_coam.activate plan    activate_plan_despite_errors=True    timeout=720
# 
# stop multi power ue traffic ul
#     [Arguments]    ${ue_num}    ${protocol}=tcp    ${if_ul}=${True}
#     log to console     Stop traffic    console=yes
#     FOR    ${item}    IN RANGE    ${ue_num}
#          run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
#          ...    protocol=${protocol}
#     END
# 
# Stop To Capture Wireshark Log
#      [Arguments]    ${tmpfile_pcap}
#      [Teardown]  run keyword and ignore error  issh.Disconnect
#      ${local_pcap}    Stop Wireshark X2 Log On CU   tmpfile_pcap=${tmpfile_pcap}
#      SET Test VARIABLE   ${local_pcap}
# 
# Stop and Download Log
#     [Arguments]    ${filename}
#     csn.Execute    command=ssh mmw-${tl_name}-1-upue-000.local -- sudo killall tcpdump    connection=${connection}
#     csn.send command    command=ssh mmw-tl721-1-upue-000.local -- scp ${log_dir}/${filename} mmw-${tl_name}-1-oam-000.local:${log_dir}
#     ...  connection=${connection}
#     sleep    10s
#     csn.connect_to    hostname=${test_ute}    username=${ute_name}    password=${test_password}    alias=connection_ute
#     csn.send command   command=sudo ssh-keygen -f "/root/.ssh/known_hosts" -R "${CU_OAM_IP}"     connection=connection_ute
#     csn.send command   command=sudo sshpass -p rastre1 scp robot@${CU_OAM_IP}:${log_dir}/${filename} ${DSCP_CASE_LOG_PATH}
#     ...     connection=connection_ute
#     sleep    10s
#     csn.Disconnect    connection=connection_ute
#     log to console  Download Log successful
# 
# Convert pcap to text
#     [Arguments]  ${source}   ${target}   ${filter}   ${connection}
#     ssh.send_command
#     ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y ${filter}
#     ...  connection=${connection}
#     ssh.await execution end  connection=${connection}  timeout=30min
# 
# Convert pcap to text And Get txt Content
#     [Arguments]      ${pacp_filename}  ${txt_filename}    ${except_ver_value}    ${except_DU_URL}    ${except_F1_U}
#     Connect to TestPc
#     Convert pcap to text    source=${LOG_PATH}/${pacp_filename}
#     ...  target=${LOG_PATH}/${txt_filename}   filter=" "  connection=TestPc
#     ${dscp_list}  ${version_number}  ${du_ip}  ${F1_U_ip}      get_DSCP_by_txt_file    file_path=${LOG_PATH}/${txt_filename}    message=DSCP: AF11
#     Run keyword And Continue on Failure     list should contain value      ${dscp_list}   ${dscp_value}
#     Run keyword And Continue on Failure     Should be equal as integers    ${version_number}   ${except_ver_value}
#     Run keyword And Continue on Failure     Should Be Equal As Strings     ${du_ip}   ${except_DU_URL}
#     Run keyword And Continue on Failure     Should Be Equal As Strings     ${F1_U_ip}   ${except_F1_U}
#     [Teardown]  Run keyword and ignore error    csn.Disconnect	connection=TestPc
# 
# 
# Get PARAM Value from Wireshark Log
#     [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
#     ${value}     cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
#     ...    default_value=${default_value}    condition_expression=${condition_expression}
#     log to console  Get PARAM Value from Wireshark Log successful
#     [Return]    ${value}
# 
# Case Teardown
#     csn.Disconnect    connection=${connection}
#     CI_interface.Common Case Teardown
