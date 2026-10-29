# *** Settings ***
# Force Tags    PY36
# Documentation     author: Debbie Wang
# ...               contact: debbie.wang@nokia-sbell.com
# ...               squad group: mmw_SG_04
# 
# Suite Setup          robot_common_operations.Common Suite Setup
# Suite Teardown       robot_common_operations.Common Suite Teardown
# 
# Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# Resource          ./resources/5GC001913_YA_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
# Resource          ../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
# 
# *** Variables ***
# ${ul_throughput}     50M
# ${Expected_ul_Tput}    20
# ${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# 
# 
# *** Test Cases ***
# [1]5GC000959_A_NSA_L3 call with UL data traffic with TCP_above 37GHz RU - AEWE
#     [Tags]       CIT_TRUNK    CRT_22R2
#     [Setup]    case_setup
#     COAM Check GNB_DU cell on air
#     attach multi power ue    ue_num=${1}
#     start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=${ul_throughput}    if_dl=${False}    protocol=tcp
#     ...    ul_duration=120
#     sleep    10s
#     log    \n start check throughput    console=yes
#     ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=100s    ignore_time=10s
#     ${cell_list}    create list    16389
#     power_ue.Check Tput    ue_type=samsung    direction=ul    log=${log_path}     cells=${cell_list}    target_throughput=${Expected_ul_Tput}
#     ...    min_percent=0.0    target_avg_percent=0.8
# #    power_ue.Check throughput    ue_type=samsung    direction=ul    throughput=${Expected_ul_Tput}
#     power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=samsung   iperf_type=via_command    protocol=tcp
#     [Teardown]    Case Teardown
# 
# 
# *** Keywords ***
# case_setup
#     [Arguments]
#     robot_common_operations.Common Case Setup
#     ${default_scf}    suite setup to prepare default scf
#     Commission Default SCF    default_scf=${default_scf}
#     Adjust Enb    index=12   dist_name=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
# 
# Adjust Enb
#     [Arguments]    ${index}=locked  ${alias}=enblte    ${dist_name}=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].global_bts_id}/LNADJGNB-1
#     ...    ${parameter}=administrativeState
#     Connect and Modify the parameter on enblte  ${dist_name}    ${parameter}     ${index}
# 
# suite setup to prepare default scf
#     [Arguments]
#     Log To Console    Set Default Scf
#     Conect to DU COAM
#     ${version}    admin_cli.get_sw_version    connection=COAM
#     ${version_list}    split string    ${version}    _
#     ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
#     ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}/SCF_SBTS00.xml
#     ...    ${CURDIR_path}/SCF_${version_list[0]}.xml
#     log to console   ${default_scf}
#     [Teardown]    Run keyword and ignore error    admin_cli.teardown      connection=COAM
#     [Return]    ${default_scf}
# 
# Commission Default SCF
#     [Arguments]    ${default_scf}
#     Log To Console    Commission Default SCF
#     Conect to DU COAM
#     COAM Commission with scf file    scf_file_path=${default_scf}    connection=COAM    is_pdl_checking_needed=${False}
#     wait until keyword succeeds    15 min    30sec    COAM Check GNB_DU cell on air
#     sleep    20s
# #    Check if Unexpected History Alarm Exist
#     [Teardown]    Run keyword and ignore error    admin_cli.Teardown   connection=COAM
# 
# Conect to DU COAM
#     [Arguments]    ${connection}=COAM
#     admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#                   ...      username=${WEBUI_USER}
#                   ...      password=${WEBUI_PASSWORD}
#                   ...      name=${connection}
# 
# COAM Check GNB_DU cell on air
#     [Documentation]  Author:
#     ...              Description: Check if GNB is in cell on air status
#     [Arguments]    ${connection}=COAM
#     Conect to DU COAM
#     COAM Check All Cells Onair
#     [Teardown]   admin_cli.teardown    connection=${connection}
# 
# Recover the test ENV
#     [Arguments]    ${ue_num}=${1}
#     detach multi power ue    ue_num=${ue_num}
#     COAM Teardown gnb connections
# 
# Get ul and dl peak and ave throughput and return result
#     [Documentation]    Get ul and dl peak and ave throughput and return result.
#     ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
#     [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
#     ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
#     run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
#     ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
#     ...    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
#     ...    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
#     ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
#     ...    cell_numbers=${cell_number}
#     [Return]    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}
# 
# Case Teardown
#     Run Keyword And Ignore Error    Recover the test ENV
#     robot_common_operations.Common Case Teardown
#     CI_interface.Common Case Teardown
