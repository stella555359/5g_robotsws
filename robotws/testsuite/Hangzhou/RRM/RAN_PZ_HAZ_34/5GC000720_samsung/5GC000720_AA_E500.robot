# *** Settings ***
# Documentation
# ...    author: Wu Fangmin
# ...    contact: fangmin.wu@nokia-sbell.com
# ...    Description:Feature 5GC000720
# Force Tags    CRT_TRUNK    CRT_20B
# ...    PY36
# 
# Suite Setup          robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# 
# #Library           ../../../../resources/python_libs/check_csv_log.py
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
# Library           ./Resources/5GC000720_TTI_Trace_Analysis.py
# Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
# Resource          ./Resources/5GC000720_common_keyword.robot
# Variables         ./Resources/5GC000720_modify_para.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    coam
# 
# *** Variables ***
# ${CURDIR_path}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
# ${720_AA}    tcpdump_720_AA.pcap
# ${720_AA_02}    tcpdump_720_AA_02.pcap
# ${720_AA_03}    tcpdump_720_AA_03.pcap
# ${scellId_check_param}     nr-rrc.physCellId
# ${rnti_check_param}    nr-rrc.newUE-Identity
# ${720_AA_dl_tp_low}    2M
# ${720_AA_dl_tp_high}    800M
# ${720_AA_dl}       150M
# ${720_AA_ul_tp_low}    2M
# ${720_AA_ul_tp_high}    150M
# ${720_AA_ul_tp}     65M
# ${4G_IP}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${gNB_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${gNB_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TS_LOG_PATH_BASE}    /home/ute/Downloads/
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# ${gNB_ssh_name}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${gNB_ssh_pass}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${eNB_ip}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${BTS_ID}                ${tl.enbs[0].instance_id}
# 
# *** Test Cases ***
# [1]5GC000720_AA_CA_with_Multi-UE_support_in_mmW_band_up_to_2CC_buffer_based_activation_DL_and_UL_tput_mmWaves_2CC
#     [Tags]    CIT_TRUNK    CRT_20B    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2     CDRT_22R1
#     [Setup]    Case Setup ready
#     GNB ready and UE attach capture X2 log     ue_num=${1}     PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_AA_01}
#     power_ue.Start traffic    ue_index=${0}    direction=dl
#     ...    throughput=${720_AA_dl_tp_low}    duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{dl_power_port_list}[0]    process_num=${1}
#     sleep    10s
#     log    \n start check throughput    console=yes
#     power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=0    cellid=16385
#     run keyword and expect error    *    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=1   cellid=16386
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=dl    iperf_port=@{ul_power_port_list}[0]
#     sleep    10s
#     power_ue.Start traffic    ue_index=${0}    direction=dl
#     ...    throughput=${720_AA_dl_tp_high}    duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{dl_power_port_list}[0]    process_num=${1}
#     sleep    10s
#     log    \n start check throughput    console=yes
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=50    cellid=16385
#     power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=50    cellid=16386
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=dl    iperf_port=@{ul_power_port_list}[0]
#     [Teardown]    Run Keyword And Ignore Error    Recover the test ENV
# 
# [1]5GC000720_AA_Activation_CA_feature_when_one_UE_with_CA_support_is_attached_to_PCell_mmWavws_2CC
#     [Tags]    CRT_TRUNK    CRT_20B    CRT_21A    CRT_21B     CRT_22R1    CRT_22R2
#     [Setup]    Case Setup ready
#     GNB ready and UE attach capture X2 log     ue_num=${1}     PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_AA_03}
#     power_ue.Start traffic    ue_index=${0}    direction=dl
#     ...    throughput=300M   duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{dl_power_port_list}[0]    process_num=${1}
#     power_ue.Start traffic    ue_index=${0}    direction=ul
#     ...    throughput=100M    duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{ul_power_port_list}[0]    process_num=${1}
#     sleep    10s
#     log    \n start check throughput    console=yes
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=10    cellid=16385
#     run keyword and expect error    *    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=0.0   cellid=16386
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=dl    iperf_port=@{dl_power_port_list}[0]
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=ul    iperf_port=@{ul_power_port_list}[0]
#     detach multi power ue    ue_num=${1}
#     sleep    10s
#     GNB ready and UE attach capture X2 log     ue_num=${1}     PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_AA_03_true}
#     power_ue.Start traffic    ue_index=${0}    direction=dl
#     ...    throughput=300M   duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{dl_power_port_list}[0]    process_num=${1}
#     power_ue.Start traffic    ue_index=${0}    direction=ul
#     ...    throughput=100M    duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{ul_power_port_list}[0]    process_num=${1}
#     sleep    10s
#     log    \n start check throughput    console=yes
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=10    cellid=16385
#     power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=10
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=dl    iperf_port=@{dl_power_port_list}[0]
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=ul    iperf_port=@{ul_power_port_list}[0]
#     [Teardown]    Run Keyword And Ignore Error    Recover the test ENV
# 
# [1]5GC000720_CA_SCell_deactivation_due_to_SgNB_reconfiguration_2CC_DL_and_1CC_UL
#     [Documentation]
#     ...    due to now ENV is 4cc，so we need to lock 3/4 cell to confirm ENV only have 2cc,then test the lock
#     [Tags]  CRT_21B    CRT_TRUNK    CRT_20B     CRT_21A    CRT_22R1    CRT_22R2
#     [Setup]  Case Setup ready
#     GNB ready and UE attach capture X2 log     ue_num=${1}     PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_AA_05_1}
#     power_ue.Start traffic    ue_index=${0}    direction=dl
#     ...    throughput=600M   duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{dl_power_port_list}[0]    process_num=${1}
#     power_ue.Start traffic    ue_index=${0}    direction=ul
#     ...    throughput=100M    duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{ul_power_port_list}[0]    process_num=${1}
#     sleep    10s
#     log    \n start check throughput    console=yes
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=10    cellid=16385
#     power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=10   cellid=16386
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=dl    iperf_port=@{dl_power_port_list}[0]
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=ul    iperf_port=@{ul_power_port_list}[0]
#     detach multi power ue    ue_num=${1}
#     Perform cell lock via rest api     cell_idx=${2}
#     attach multi power ue    ue_num=${1}
#      power_ue.Start traffic    ue_index=${0}    direction=dl
#     ...    throughput=300M   duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{dl_power_port_list}[0]    process_num=${1}
#     power_ue.Start traffic    ue_index=${0}    direction=ul
#     ...    throughput=100M    duration=${180}    ue_type=samsung    iperf_type=via_command    protocol=udp
#     ...    iperf_port=@{ul_power_port_list}[0]    process_num=${1}
#     sleep    10s
#     log    \n start check throughput    console=yes
#     run keyword and continue on failure    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=10    cellid=16385
#     run keyword and expect error    *    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=0.0   cellid=16386
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=dl    iperf_port=@{dl_power_port_list}[0]
#     Run keyword and ignore error    power_ue.Stop traffic    ue_type=samsung    direction=ul    iperf_port=@{ul_power_port_list}[0]
#     [Teardown]    Run Keyword And Ignore Error    Recover the test ENV
# 
# *** Keywords ***
# GNB ready and UE attach capture X2 log
#     [Arguments]    ${ue_num}    ${wireshark_file_name}=${720_AA}    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_100MHz}    ${is_commission}=${True}
#     Log    \n GNB ready and UE attach capture X2 log    console=yes
#     run keyword if    ${is_commission}==${True}    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}
#     run keyword if    ${is_commission}==${True}    COAM Wait for gnb ready and cell setup
#     attach multi power ue    ue_num=${ue_num}
# 
# Modify SCF and GNB ready
#     [Arguments]    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_100MHz}    ${is_commission}=${True}
#     Log    \n Start modify scf    console=yes
#     run keyword if    ${is_commission}==${True}    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}
#     run keyword if    ${is_commission}==${True}    COAM Wait for gnb ready and cell setup
#     log to console  \n gNB is on air    console=yes
# 
# Start traffic and capture tti trace
#     [Arguments]    ${dl_throughput}    ${ul_throughput}
#     Log    \n Start traffic and capture tti trace     console=yes
#     start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#     sleep    10s
#     Start TTI trace log capturing
#     sleep     3s
#     Stop TTI trace log capturing
#     stop multi power ue traffic ul and dl    ue_num=${1}
#     &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${TS_CASE_LOG_PATH}
#     Set suite variable    ${CSV_PATH_UL}       ${dict_csv_file_path['UL']}
#     Set suite variable    ${CSV_PATH_DL}       ${dict_csv_file_path['DL']}
# 
# Start traffic and capture AAsys log
#     [Arguments]  ${dl_throughput}    ${ul_throughput}    ${file_name}=aasyslog_one_cell.txt
#     Log    \n Start traffic and capture tti trace     console=yes
#     start multi power ue traffic ul and dl    ue_num=${1}    dl_throughput=${dl_throughput}
#     sleep    10s
#     AAsys log captrue    gnb_index=${0}    du_index=${0}    log_name=${file_name}    filter=${EMPTY}
#     stop multi power ue traffic ul and dl    ue_num=${1}    if_ul=${False}
#     ${access_cell_id}    Get UL And DL Access Cells From Aaslog    file_name=${file_name}
#     [Return]   ${access_cell_id}
# 
# UE attach Start traffic and capture AAsys log
#     [Arguments]  ${ue_num}    ${dl_throughput}    ${ul_throughput}    ${file_name}=aasyslog_one_cell.txt
#     Start to Capture X2 Log on Asik    filename=720_new_file.pcap
#     attach multi power ue    ue_num=${ue_num}
#     Log    \n Start traffic and capture tti trace     console=yes
#     Stop and Download Log    filename=720_new_file.pcap
#     start multi power ue traffic ul and dl    ue_num=${ue_num}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#     sleep    10s
#     AAsys log captrue    gnb_index=${0}    du_index=${0}    log_name=${file_name}    filter=${EMPTY}
#     stop multi power ue traffic ul and dl    ue_num=${ue_num}
#     ${access_cell_id}    Get UL And DL Access Cells From Aaslog    file_name=${file_name}
#     [Return]   ${access_cell_id}
#     [Teardown]  run keyword and ignore error   detach multi power ue    ue_num=${ue_num}
# 
# 
# Get UL And DL Access Cells From Aaslog
#     [Arguments]    ${file_name}
#     @{cell_tp_list}    create list
#     ${cell_id}    Get nrcellid from aasys log    host=${gNB_ip}   username=${gNB_ssh_name}    password=${gNB_ssh_pass}   log_name=${file_name}
#     FOR    ${item}    IN    @{cell_id}
#         ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    host=${gNB_ip}   username=${gNB_ssh_name}
#         ...    password=${gNB_ssh_pass}    cell_id=${item}    log_name=${file_name}
#         ${peak_tp_dl}    ${average_tp_dl}    ${minimum_tp_dl}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
#         ${peak_tp_ul}    ${average_tp_ul}    ${minimum_tp_ul}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
#         ${tp_list}    create list    ${average_tp_ul}    ${average_tp_dl}
#         ${cell_tp_dic}    create dictionary    ${item}    ${tp_list}
#         Append to list    ${cell_tp_list}    ${cell_tp_dic}
#     END
#     ${access_cell_id}    Get_Access_Cell_Id    cell_tp_list=${cell_tp_list}
#     [Return]     ${access_cell_id}
# 
# Start traffic and capture tti trace for Multi UEs
#     [Arguments]    ${dl_throughput}    ${ul_throughput}
#     Log    \n Start traffic and capture tti trace     console=yes
#     Start TTI trace log capturing
#     sleep    3s
#     start multi power ue traffic ul and dl    ue_num=${2}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
#     ...    ul_duration=${180}    dl_duration=${180}
#     sleep     10s
#     Stop TTI trace log capturing
#     &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${TS_CASE_LOG_PATH}
#     ...    is_need_to_close_connection=${True}
#     Set suite variable    ${CSV_PATH_UL}       ${dict_csv_file_path['UL']}
#     Set suite variable    ${CSV_PATH_DL}       ${dict_csv_file_path['DL']}
# 
# Case Setup ready
#     robot_common_operations.Common Case Setup
#     change 4G configuration
#     COAM Create log directory
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     Run Keyword If  '${gNB_ip}'=='10.108.135.131'     Perform RU Lock And Check RU State    bts_host=${tl.gnbs[1].dus[0].f1_m_ip_addr}
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
# 
# Recover the test ENV
#     [Arguments]    ${ue_num}=${1}
#     stop multi power ue traffic ul and dl    ue_num=${ue_num}
#     detach multi power ue    ue_num=${ue_num}
#     COAM Teardown gnb connections
#     Run Keyword If  '${gNB_ip}'=='10.108.135.131'     Perform RU UnLock And Check RU State    bts_host=${tl.gnbs[1].dus[0].f1_m_ip_addr}
#     robot_common_operations.Common Case Teardown
#     CI_interface.Common Case Teardown
# 
# lock case recover the test ENV
#     [Arguments]    ${ue_num}=${1}
#     stop multi power ue traffic ul and dl    ue_num=${ue_num}
#     detach multi power ue    ue_num=${ue_num}
#     Perform cell unlock via rest api     cell_idx=${2}
# #    Perform cell unlock via rest api     cell_idx=${3}
# #    Perform cell unlock via rest api     cell_idx=${4}
#     COAM Teardown gnb connections
#     CI_interface.Common Case Teardown
# 
# Modify SCF File and Commissioning
#     [Arguments]   ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_100MHz}
# #    ${versiontitle}    Get Version
#     Set Default scf name
#     set suite variable    ${default_scf}
#     log to console   ${default_scf}
#     Create new SCF     scf_file_path=${default_scf}    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}
# 
# Set Default scf name
#     [Arguments]   ${connection}=GNB_OAM
#     Log To Console  Set Default scf name
#     Connect to gnb coam via ssl     connection=${connection}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     set suite variable    ${version_list}
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
# #    ${if_22R2_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R2
# #    ${if_23R3_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS23R3
#     ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00_523_720.xml  
#     ...     ${CURDIR_path}SCF_${version_list[0]}_523_720.xml
# #    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}${SBTS_scf_name}.xml
# #    ...    ${if_22R2_load}    ${CURDIR_path}${Branch_scf_name_22R2}.xml
# #    ...    ${if_23R3_load}    ${CURDIR_path}${Branch_scf_name_23R3}.xml
# #    ...    ${CURDIR_path}${Branch_scf_name_22R1}.xml
#     set suite variable    ${default_scf}
#     log to console   ${default_scf}
#     log to console   Set Default scf name successful
# 
# Create new SCF
#     [Arguments]     ${scf_file_path}     ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_100MHz}
#     ...    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}     connection=${connection}
#     ${new_scf_file}    COAM Modify scf file   scf_file_path=${scf_file_path}   scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
#     COAM Commission with scf file    scf_file_path=${new_scf_file}    timeout=600
#     [Teardown]    coam.Teardown  connection=${connection}
# 
# Get Version
#     [Arguments]     ${connection}=GNB_OAM
#     Log To Console    Get Version
#     Connect to gnb coam via ssl    bts_host=${gNB_ip}     connection=${connection}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     ${versiontitle}    set variable    ${version_list[0]}
#     [Return]    ${versiontitle}
#     [Teardown]    coam.Teardown  connection=${connection}
# 
# Analysis X2Log and Check Scell Selection in Messages
#     [Arguments]   ${source}   ${target}   ${filter}    ${element}   ${except_value}
#     Log    \n Analysis X2Log and Check Scell Selection in Messages     console=yes
#     ${return_value}    Analysis X2Log And Get Element Vlaue    source=${source}    target=${target}    filter=${filter}    element=${element}
#     ${list_length}    get length  ${return_value}
#     FOR    ${item}    IN RANGE    ${list_length}
#         should be true  @{return_value}[${item}]==@{except_value}[${item}]
#     END
# 
# Analysis X2Log And Get Element Vlaue
#     log to console  Analysis X2Log And Get Element Vlaue
#     [Arguments]  ${source}   ${target}   ${filter}    ${element}
#     Convert pcap file to txt    source=${source}    target=${target}   filter=${filter}
#     ${return_value}    Find_Element_In_Wireshark    file_path=${target}     element=${element}
#     should not be empty      ${return_value}
#     [Return]    ${return_value}
# 
# Analysis X2Log and Return Scell in Messages
#     [Arguments]  ${source}   ${target}   ${filter}    ${element}
#     Log    \n Analysis X2Log and Return Scell in Messages     console=yes
#     ${return_value}    Analysis X2Log And Get Element Vlaue    source=${source}    target=${target}    filter=${filter}    element=${element}
#     ${cell_list}    create list
#     FOR    ${item}    IN    @{return_value}
#         ${new_value}    convert to integer    ${item}
#         run keyword if       ${new_value}!=${50}    append to list    ${cell_list}  ${new_value}
#     END
#     [Return]   ${cell_list}
# 
# Check traffic is transfered on expected number of cells
#     [Arguments]    ${exp_num_of_cells}    ${actual_num_of_cells}
#     Log    \n Check traffic is transfered on expected number of cells     console=yes
#     ${dl_physCellId_list}    Get_Dl_Or_Ul_Access_Id    ul_dl_cell_list=${actual_num_of_cells}    cell_key=dl
#     ${number_of_dl_physCellId}    get length   ${dl_physCellId_list}
#     should be equal as numbers  ${number_of_dl_physCellId}    ${exp_num_of_cells}
#     [Return]   ${dl_physCellId_list}
# 
# 
# check 2UE tti trace element
#     [Arguments]    ${UL_DL_csv_file_path}    ${direction}   ${rnti}
#     Log    \n check 2UE tti trace element    console=yes
#     ${rnti_list}   ${ue_rnti_number}     get_multi_rntis_from_tti_trace    path=${UL_DL_csv_file_path}  direction=${direction}
#     run keyword and continue on failure    check_each_ue_schedule_ratio    ue_rnti_number=${ue_rnti_number}
#     ...     rnti_list=${rnti}    tolerance=0.1
#     ${cell_list}    ${ue_cell_number}    run keyword if   '${direction}'=='DL'
#     ...     get_multi_cell_from_tti_trace    rnti=@{rnti}[0]   path=${UL_DL_csv_file_path}  direction=${direction}
#     run keyword and continue on failure     run keyword if   '${direction}'=='DL'
#     ...     check_each_ue_schedule_ratio    ue_rnti_number=${ue_cell_number}    rnti_list=${cell_list}    tolerance=0.1
#     ${cell_list_1}    ${ue_cell_number_1}    run keyword if   '${direction}'=='DL'
#     ...     get_multi_cell_from_tti_trace    rnti=@{rnti}[1]  path=${UL_DL_csv_file_path}  direction=${direction}
#     run keyword if   '${direction}'=='DL'
#     ...     check_each_ue_schedule_ratio    ue_rnti_number=${ue_cell_number_1}    rnti_list=${cell_list_1}    tolerance=0.1
# 
# Check UE attach cell is not Locked cell
#     [Arguments]    ${file_name}=aasyslog_one_cell.txt
#     Log    \n Check UE attach cell is not Locked cell     console=yes
#     ${access_cell_id}    Get UL And DL Access Cells From Aaslog    file_name=${file_name}
#     ${dl_physCellId_list}    Get_Dl_Or_Ul_Access_Id    ul_dl_cell_list=${access_cell_id}    cell_key=dl
#     run keyword and expect error   *    list should contain sub list    ${dl_physCellId_list}   ['16385']
# 
# 
# Modify 720_SCF File and Commissioning
#     [Arguments]    ${PARAMS_TO_MODIFY_SCF}
#     ${new_scf_file}    COAM Modify scf file    scf_file_path=${480_L_default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
#     Connect to gnb coam via ssl
#     COAM Commission with scf file    scf_file_path=${new_scf_file}
# 
# recommission error scf
#     [Arguments]    ${PARAMS_TO_MODIFY_SCF}
#     ${new_scf_file}    COAM Modify scf file    scf_file_path=${480_L_default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
#     COAM Commission with scf file    scf_file_path=${new_scf_file}
# 
# Recover the test
#     run keyword and ignore error    selenium_coam.logout
#     COAM Teardown gnb connections
# 
# Login Page Via WebUI local 720
#     selenium_coam.enable_virtual_display
#     selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
#     selenium_coam.disable_message_box
#     selenium_coam.disable_screen_lock
# 
# attach the second UE
#     ${ue1_ip}    set variable    ${UE_IP}
#     Start to Capture X2 Log on Asik    filename=${720_AA_02}
#     5GC000720_common_keyword.Retry ue attach if failed    type=NSA    attach_script_path=${E500_720_AA}/NSA_5G_1UEattach_UE2.txt
#     ...    detach_script_path=${E500_720_AA}/NSA_5G_UEdetach.txt    e500_alias=${TMA_APP_ALIAS}
#     Stop and Download Log    filename=${720_AA_02}
#     ${ue2_ip}    set variable    ${UE_IP}
#     @{UE_IPs}    create list    ${ue1_ip}    ${ue2_ip}
# 
# Remove same item from list
#     [Arguments]     ${list}
#     ${new_list}    create list
#     FOR    ${item}    IN    @{list}
#         ${status}    run keyword and return status    list should contain value    ${new_list}    ${item}
#         run keyword unless   ${status}    append to list    ${new_list}    ${item}
#     END
#     [Return]    ${new_list}
# 
# Get cell idx from cell_list
#     Log    \n Get cell number from cell_list     console=yes
#     [Arguments]      ${cell_list}
#     ${cell}    create list
#     FOR    ${i}     IN    ${cell_list}
#          ${cell}    run keyword if     ${i}!=${50}      set variable  ${i}
#     END
#     ${cell_idx}    get_cell_idx     cell=${cell}
#     [return]    ${cell_idx}  ${cell}
# 
# Lock cell and capture Aaslog check ue tp
#     [Arguments]   ${cell_idx}    ${file_name}=aasyslog_one_cell.txt
#     Log    \n Lock cell2 and capture AAsyslog trace     console=yes
#     Perform Cell Lock     cell_idx=${cell_idx}
#     sleep   1min
#     AAsys log captrue    gnb_index=${0}    du_index=${0}    log_name=${file_name}    filter=${EMPTY}
#     Perform Cell Unlock    cell_idx=${cell_idx}
# 
# Perform RU Lock And Check RU State
#     [Documentation]   Auther: Stella.lin@nokia-sbell.com
#     [Arguments]    ${bts_host}    ${ru_index}=${1}   ${download_dir}=${output_dir}
#     ${ru_index}  Convert To Integer    ${ru_index}
#     COAM Navigate to login page via webUI    url=https://${bts_host}    download_dir=${download_dir}
#     selenium_coam.lock_ru  ru_index=${ru_index}
#     Sleep   30 sec
#     Check RU State    bts_host=${bts_host}    state=${1}    ru_index=${ru_index}
#     [Teardown]  COAM selenium logout
# 
# Perform RU UnLock And Check RU State
#     [Documentation]   Auther: Stella.lin@nokia-sbell.com
#     [Arguments]    ${bts_host}    ${ru_index}=${1}   ${download_dir}=${output_dir}
#     ${ru_index}  Convert To Integer    ${ru_index}
#     COAM Navigate to login page via webUI    url=https://${bts_host}    download_dir=${download_dir}
#     selenium_coam.unlock_ru  ru_index=${ru_index}
#     Sleep   30 sec
#     Check RU State    bts_host=${bts_host}    state=${0}    ru_index=${ru_index}
#     [Teardown]  COAM selenium logout
# 
# 
# Check RU State
#     [Arguments]  ${bts_host}    ${state}    ${ru_index}=${1}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
#     ...    connection=${connection}
#     Run Keyword If     '${state}'=='1'    RU Should Be Locked     ru_index=${ru_index}    connection=${connection}
#     Run Keyword If     '${state}'=='0'    RU Should Be Unlocked     ru_index=${ru_index}    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error   coam.Teardown  connection=${connection}
# 
# 
# 
# 
# 
