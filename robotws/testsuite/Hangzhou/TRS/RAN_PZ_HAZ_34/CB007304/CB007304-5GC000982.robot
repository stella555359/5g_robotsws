# *** Settings ***
# Documentation     author: Debbie Wang
# ...               contact: debbie.wang@nokia-sbell.com
# ...               squad group: mmw_SG_04
# Force Tags
# ...    PY36
# Resource       ../../../RRM/RAN_PZ_HAZ_34/MMW4_Common_Libs/get_set_TL_info.robot
# Resource       ../../../RRM/RAN_PZ_HAZ_34/MMW4_Common_Libs/UE_TP.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# 
# 
# *** Variables ***
# ${gNB_ip}      ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${ue_type}     ${tl.ues[0].capabilities[-1]}
# ${Enb_ip}      ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
# ${BTS_ID}       ${tl.gnbs[0].instance_id}
# ${ul_iperf_port}    ${tl.ues[0].iperf_details.ports[0]}
# ${dl_iperf_port}    ${tl.ues[0].iperf_details.ports[1]}
# ${default_scf}    ${CURDIR}/../../../commissionings/HGZ/${testline_name}/DU_SCF_0.400.xml
# @{cell_id_list}    11730945    11730946    11730947
# 
# *** Test Cases ***
# [1]CB007304-5GC000982-A_003_eCPRI_Transport_with_Switch_Network_with_EVC_serial_topology
#     [Documentation]    NSA TDD cloud mmw
#     ...   The purpose of this test is checking if switch network providing Ethernet Line Service works in EVC switch network.
#     [Tags]    CB007304-982    CRT_21B    CRT_22R2    CRT_TRUNK
#     [Setup]
# #    update default scf
#     wait until keyword succeeds    15min    30s     Check GNB ENB cell on air    gNB_ip=${gNB_ip}
#     FOR    ${item}    IN RANGE    ${3}
#         ${defaultLnRelGnbCellId_value}    evaluate    ${item}+${2}
#         modify enb defaultLnRelGnbCellId parameter    value=${defaultLnRelGnbCellId_value}
#         run keyword and continue on failure    start call and check TP    cell_index=${item}
#     END
#     [Teardown]    case teardown
# 
# 
# *** Keywords ***
# update default scf
#     [Arguments]    ${connection}=cOAM_admin
#     Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}    connection=${connection}
#     COAM Commission with scf file    scf_file_path=${default_scf}     is_pdl_checking_needed=${False}
#     [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
# 
# modify enb defaultLnRelGnbCellId parameter
#     [Arguments]     ${value}=${1}
#     Login BaseStation By Admin    hostname=${Enb_ip}    connection=ENB_conn
#     ${dict}    create dictionary    parameterName=defaultLnRelGnbCellId    operation=update    value=${value}
#     ${list}    create list    ${dict}
#     coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
#     ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
#     ...    connection=ENB_conn
#     wait until keyword succeeds    5min    10s  Check GNB ENB cell on air    gNB_ip=${Enb_ip}
#     [Teardown]    Logout BaseStation by Admin     connection=ENB_conn
# 
# start call and check TP
#     [Arguments]     ${cell_index}=${0}
#     power ue attach    ue_num=${1}    ue_type=${ue_type}
#     ${ul_iperf_port}    create list    ${ul_iperf_port}
#     ${dl_iperf_port}    create list    ${dl_iperf_port}
#     start power ue traffic ul and dl    ue_num=${1}    ul_throughput=30MKbits/sec    dl_throughput=100MKbits/sec   ue_type=${ue_type}
#     ...    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}    ul_duration=180    dl_duration=180
#     sleep    10s
#     ${cell_list}    create list    11730945    11730946    11730947
#     power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=10    cellid=${cell_list[${cell_index}]}
#     power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=50    cellid=${cell_list[${cell_index}]}
#     [Teardown]    UE teardown    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
# 
# get each cell TP and check
#     [Documentation]    Get ul and dl peak and ave throughput and return result
#     ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}
#     [Arguments]    ${cell_index}=${0}    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
#     ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
#     run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
#     ...    log_name=data_dl${cell_index}.txt
# #    ${cell_id_list}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}    log_name=data_dl${cell_index}.txt
# #    sort list     ${cell_id_list}
#     ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
#     ...    cell_id=${cell_id_list[${cell_index}]}    log_name=data_dl${cell_index}.txt
#     ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
#     ...    cell_numbers=${1}
#     ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
#     ...    cell_numbers=${1}
#     should be true    ${dl_average_tp}>50
#     should be true    ${ul_average_tp}>10
# 
# UE teardown
#     [Arguments]    ${ul_iperf_port}    ${dl_iperf_port}
#     run keyword and ignore error    stop power ue traffic ul and dl    ue_num=${1}    ue_type=${ue_type}
#     ...    ul_iperf_port=${ul_iperf_port}    dl_iperf_port=${dl_iperf_port}
#     run keyword and ignore error  detach power ue    ue_num=${1}    ue_type=${ue_type}
# 
# case teardown
#      run keyword and ignore error    CI_interface.Common Case Teardown