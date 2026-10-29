# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: Debbie Wang
# # #...               contact: debbie.wang@nokia-sbell.com
# # #...               squad group: mmw_SG_04
# # #
# # #Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# # #Resource          ./resources/5GC001913_YA_common_keyword.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
# # #Resource          ../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #
# # #*** Variables ***
# # #${ul_throughput}     50M
# # #${Expected_ul_Tput}    20
# # #${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #
# # #
# # #*** Test Cases ***
# # #[1]5GC001913-YA-5GC000959_A_NSA_L3 call with UL data traffic with TCP_above 37GHz RU - AEWE
# # #    [Tags]    5G_TRS    5GC001913    CRT_20B    CIT_TRUNK  CRT_21B  5GC000856     5GC000959    5GC001591
# # #    [Setup]
# # #    COAM Check GNB_DU cell on air
# # #    attach multi power ue    ue_num=${1}
# # #    start multi power ue traffic ul and dl    ue_num=${1}    ul_throughput=${ul_throughput}    if_dl=${False}    protocol=tcp
# # #    ...    ul_duration=120
# # #    sleep    10s
# # #    log    \n start check throughput    console=yes
# # #    ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=100s    ignore_time=10s
# # #    ${cell_list}    create list    98305
# # #    power_ue.Check Tput    ue_type=samsung    direction=ul    log=${log_path}     cells=${cell_list}    target_throughput=${Expected_ul_Tput}
# # #    ...    min_percent=0.0    target_avg_percent=0.8
# # ##    power_ue.Check throughput    ue_type=samsung    direction=ul    throughput=${Expected_ul_Tput}
# # #    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=samsung   iperf_type=via_command    protocol=tcp
# # #    [Teardown]    Case Teardown
# # #
# # #
# # #*** Keywords ***
# # #Conect to DU COAM
# # #    [Arguments]    ${connection}=COAM
# # #    admin_cli.connect to   bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #                  ...      username=${WEBUI_USER}
# # #                  ...      password=${WEBUI_PASSWORD}
# # #                  ...      name=${connection}
# # #
# # #COAM Check GNB_DU cell on air
# # #    [Documentation]  Author:
# # #    ...              Description: Check if GNB is in cell on air status
# # #    [Arguments]    ${connection}=COAM
# # #    Conect to DU COAM
# # #    COAM Check All Cells Onair
# # #    [Teardown]   admin_cli.teardown    connection=${connection}
# # #
# # #Recover the test ENV
# # #    [Arguments]    ${ue_num}=${1}
# # #    detach multi power ue    ue_num=${ue_num}
# # #    COAM Teardown gnb connections
# # #
# # #Get ul and dl peak and ave throughput and return result
# # #    [Documentation]    Get ul and dl peak and ave throughput and return result.
# # #    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
# # #    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
# # #    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
# # #    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
# # #    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
# # #    ...    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
# # #    ...    host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
# # #    ...    cell_numbers=${cell_number}
# # #    [Return]    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}
# # #
# # #Case Teardown
# # #    Run Keyword And Ignore Error    Recover the test ENV
# # #    CI_interface.Common Case Teardown