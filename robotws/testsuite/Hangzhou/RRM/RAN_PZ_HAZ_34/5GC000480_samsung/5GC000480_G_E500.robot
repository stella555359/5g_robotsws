# *** Settings ***
# Suite Setup    robot_common_operations.Common Suite Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# Documentation
# ...    author: Wu Fangmin
# ...    contact: fangmin.wu@nokia-sbell.com
# ...    Description:Feature 5GC000480
# Force Tags    CRT_19B    CRT_TRUNK    CRT_20B
# ...    PY36
# Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
# Resource          taf/rfrl/common_resources/robot/TTI_Trace.robot
# Resource          ./Resources/5GC000480_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Variables         ./Resources/5GC000480_modify_para.py
# #Library           ../../../../resources/python_libs/check_csv_log.py
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
# Library           ../5GC000720_samsung/Resources/5GC000720_TTI_Trace_Analysis.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# 
# *** Variables ***
# ${CURDIR_path}          ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/
# ${E500_480}    ${CURDIR}/Resources/E500_scripts_480_UE0
# ${gNB_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${gNB_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${gNB_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${TS_LOG_PATH_BASE}    /home/ute/Downloads/
# ${rnti_check_param}    nr-rrc.newUE-Identity
# ${480_G_tcpdump_X2}    tcpdump_attach.pcap
# ${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
# ${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
# ${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
# ${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark
# ${gNB_ssh_name}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${gNB_ssh_pass}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${ul_power_port_list}    ${tl.ues[0].iperf_details.ports[0:4]}
# ${dl_power_port_list}    ${tl.ues[0].iperf_details.ports[4:8]}
# ${480_G_X2}    tcpdump_attach_4UE_select_scell.pcap
# ${eNB_ip}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${4G_IP}     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${WEBUI_USER}     ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PWD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${BTS_ID}                ${tl.enbs[0].instance_id}
# 
# *** Test Cases ***
# [1]5GC000480_G_5G-CP-CELL_select_the_SCells_for_Carrier_Aggregation
#     [Tags]    CRT_TRUNK    CRT_22R3     CRT_22R2      CRT_22R4
#     [Setup]    Case Setup ready
#     GNB ready and UE attach  ue_num=${4}
#     Wait for counter to be gathered after guard peroid   interval=15
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00021    expected_value=0
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00022    expected_value=4
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00023    expected_value=0
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00024    expected_value=0
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00025    expected_value=0
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00026    expected_value=0
#     run keyword and continue on failure    Check if counters value is correct    counter_id=M55114C00027    expected_value=0
#     detach multi power ue    ue_num=${4}
#     update scell parameters
#     sleep     60s
#     COAM Wait for gnb ready and cell setup
#     attach multi power ue    ue_num=${4}
#     Wait for counter to be gathered after guard peroid   interval=15
#     Check if counters value is correct    counter_id=M55114C00035    expected_value=4
#     [Teardown]    Run Keyword And Ignore Error    Recover the test ENV
# 
# #5GC000480_G_CP-CELL_select_the_UL_SCells_from_the_selected_SCell_set
# #    [Tags]    CRT_19B    CRT_20B
# #    [Setup]    Case Setup ready
# #    Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_G_02}
# #    COAM Wait for gnb ready and cell setup
# #    ${all_cell_id_list}    create list
# #    :FOR    ${item}    IN RANGE    ${4}
# #    \    ${cell_id}    get UE attach X2log and cellid    filename=480_G_ue${item}.pcap     ue_num=${item}
# #    \    sort list    ${cell_id}
# #    \    append to list    ${all_cell_id_list}    ${cell_id}
# #    run keyword and expect error    *    lists should be equal    @{all_cell_id_list}[0]     @{all_cell_id_list}[1]
# #    run keyword and expect error    *    lists should be equal    @{all_cell_id_list}[0]     @{all_cell_id_list}[2]
# #    run keyword and expect error    *    lists should be equal    @{all_cell_id_list}[1]     @{all_cell_id_list}[2]
# #    ${status1}    run keyword and return status    lists should be equal    @{all_cell_id_list}[0]    @{all_cell_id_list}[3]
# #    ${status2}    run keyword and return status    lists should be equal    @{all_cell_id_list}[1]    @{all_cell_id_list}[3]
# #    ${status3}    run keyword and return status    lists should be equal    @{all_cell_id_list}[2]    @{all_cell_id_list}[3]
# #    should be true    '${status1}'=='True' or '${status2}'=='True' or '${status3}'=='True'
# #    [Teardown]    Run Keyword And Ignore Error    Recover the test ENV
# 
# *** Keywords ***
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
# change 4G configuration
#     Connect to gnb coam via ssl    bts_host=${4G_IP}    username=${WEBUI_USER}    password=${WEBUI_PWD}    connection=4G_admin
#     perform muti Parameter recommissioning
#     ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
#     ...    value=1
#     ...    operation=update
#     ...    connection=4G_admin
#     coam.teardown     connection=4G_admin
# 
# GNB ready and UE attach capture X2 log
#     [Arguments]    ${ue_num}    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_L_01}    ${filename}=${480_G_X2}
#     Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}
#     COAM Wait for gnb ready and cell setup
#     Start to Capture X2 Log on Asik    filename=${filename}
#     attach multi power ue    ue_num=${ue_num}
#     Stop and Download Log    filename=${filename}
# 
# GNB ready and UE attach
#     [Arguments]    ${ue_num}    ${PARAMS_TO_MODIFY_SCF}=${PARAMS_TO_MODIFY_G_01}
#     Modify SCF File and Commissioning    PARAMS_TO_MODIFY_SCF=${PARAMS_TO_MODIFY_SCF}
#     COAM Wait for gnb ready and cell setup
#     attach multi power ue    ue_num=${ue_num}
# 
# Case Setup ready
#     COAM Create log directory
#     set suite variable    ${resultDir}    ${LOG_PATH}
# #    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
#     change 4G configuration
# 
# Recover the test ENV
#     detach multi power ue    ue_num=${4}
#     COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRCELL-2    parameter=maxNumOfSCellAlloc     value=200
#     sleep    5s
#     COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRCELL-3    parameter=maxNumOfSCellAlloc     value=200
#     sleep    5s
#     COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRCELL-4    parameter=maxNumOfSCellAlloc     value=200
#     sleep    5s
#     COAM Teardown gnb connections
#     CI_interface.Common Case Teardown
# 
# 
# Modify SCF File and Commissioning
#     [Arguments]    ${PARAMS_TO_MODIFY_SCF}
#     Set Default scf name
#     ${new_scf_file}    COAM Modify scf file    scf_file_path=${default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
#     COAM Commission with scf file    scf_file_path=${new_scf_file}
# 
# Set Default scf name
#     [Arguments]     ${connection}=GNB_OAM
#     Log To Console  Set Default scf name
#     Connect to gnb coam via ssl     connection=${connection}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    _
#     set suite variable    ${version_list}
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
#     ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00_480.xml
#     ...    ${CURDIR_path}SCF_${version_list[0]}_480.xml
#     set suite variable    ${default_scf}
#     log to console   ${default_scf}
#     log to console   Set Default scf name successful
# 
# update scell parameters
#     COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRCELL-2    parameter=maxNumOfSCellAlloc     value=0
#     sleep    5s
#     COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRCELL-3    parameter=maxNumOfSCellAlloc     value=0
#     sleep    5s
#     COAM Update Parameter    dist_name=MRBTS-${mrbtsid}/NRBTS-${nrbtsID}/NRCELL-4    parameter=maxNumOfSCellAlloc     value=0
#     sleep    5s
# 
# attach one ue and traffic
#     [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${ul_iperf_port}=@{ul_power_port_list}[0]
#     ...    ${dl_iperf_port}=@{dl_power_port_list}[1]
#     power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
#     ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
#     power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
#     power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=600
#     ...    ue_type=samsung    iperf_type=via_command    protocol=udp    iperf_port=${ul_iperf_port}
#     sleep    1s
#     power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=600
#     ...    ue_type=samsung    protocol=udp    iperf_port=${dl_iperf_port}
# 
# start tti trace
#     [Arguments]  ${hw_slot}=${1}    ${connection_for_abil}=${None}
#     Create default connection    hw_slot=${hw_slot}
#     Start TTI trace log capturing    hw_slot=${hw_slot}    connection_for_abil=${connection_for_abil}
# 
# Analysis X2Log and get rnti list
#     [Arguments]    ${filename}    ${numofresource}=${4}
#     Read Wireshark Log    filename=${filename}
#     ${rnti}    set variable     ${None}
#     FOR    ${i}    IN RANGE    ${numofresource}
#         ${rnti}    Get PARAM Value from Wireshark Log    check_param=${rnti_check_param}   element_idx=${0}
#             ...    condition_expression=x2ap.protocolIEs == 4
#     END
#     [Return]    ${rnti}
# 
# 
# Start traffic and capture AAsys log
#     [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${file_name}    ${ul_iperf_port}    ${dl_iperf_port}
#     Log    \n Start traffic and capture AAslog     console=yes
#     ${status1}    run keyword and return status     attach one ue and traffic    ue_index=${ue_index}    ul_throughput=${ul_throughput}
#     ...    dl_throughput=${dl_throughput}    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
#     run keyword unless     ${status1}     attach one ue and traffic    ue_index=${ue_index}    ul_throughput=${ul_throughput}
#     ...    dl_throughput=${dl_throughput}    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
#     Sleep    10s
#     AAsys log captrue    gnb_index=${0}    du_index=${0}    log_name=${file_name}    filter=${EMPTY}
#     ${access_cell_id}    Get UL And DL Access Cells From Aaslog    file_name=${file_name}
#     [Return]     ${access_cell_id}
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
# Check traffic is transfered equal to expect cell
#     [Arguments]    ${actual_cells}    ${exp_cells}
#     Log    \n Check traffic is transfered on expected number of cells     console=yes
#     ${ul_physCellId_list}    Get_Dl_Or_Ul_Access_Id    ul_dl_cell_list=${actual_cells}    cell_key=ul
#     ${dl_physCellId_list}    Get_Dl_Or_Ul_Access_Id    ul_dl_cell_list=${actual_cells}    cell_key=dl
#     log to console   ${dl_physCellId_list}
#     sort list    ${ul_physCellId_list}
#     run keyword and continue on failure    lists should be equal    ${ul_physCellId_list}    ${exp_cells}
# 
# Analysis X2Log And Get Element Vlaue
#     log to console  Analysis X2Log And Get Element Vlaue
#     [Arguments]  ${source}   ${target}   ${filter}    ${element}
#     Convert pcap file to txt    source=${source}    target=${target}   filter=${filter}
#     ${return_value}    5GC000720_TTI_Trace_Analysis.Find_Element_In_Wireshark    file_path=${target}     element=${element}
#     should not be empty      ${return_value}
#     [Return]    ${return_value}
# 
# get UE attach X2log and cellid
#     [Arguments]    ${filename}    ${ue_num}
#     Start to Capture X2 Log on Asik    filename=${filename}
#     ${status}    run keyword and return status    power ue attach again    ${ue_num}
#     run keyword unless    ${status}    power ue attach again    ${ue_num}
#     sleep    5s
#     Stop and Download Log    filename=${filename}
#     ${cell_id_list}    Analysis X2Log And Get Element Vlaue    source=${output_dir}/${filename}   target=${output_dir}/480_G_UE${ue_num}.txt
#     ...    filter=x2ap.protocolIEs == 4    element=physCellId
#     [Return]    ${cell_id_list}
#     [Teardown]     remove file    ${output_dir}/480_G_UE${ue_num}.txt
# 
# 
# 
# 
