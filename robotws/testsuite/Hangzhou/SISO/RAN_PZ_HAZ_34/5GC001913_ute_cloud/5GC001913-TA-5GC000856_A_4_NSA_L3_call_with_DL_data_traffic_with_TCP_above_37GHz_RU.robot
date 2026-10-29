# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: fengyi Liu
# # #...               contact: feng.y.liu@nokia-sbell.com
# # #...               squad group: mmw_SG_04
# # #
# # #Library           taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# # #Library           ./resources/5GC001913_common_KW.py
# # #Resource          ./resources/5GC001913_YA_common_keyword.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
# # #Resource          ../../../OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
# # #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #
# # #*** Variables ***
# # #${dl_throughput}     200M
# # #${Expected_dl_Tput}    100
# # #${DU_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# # #${WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# # #${WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# # #${1913_default_scf}    ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_0.400_DU.xml
# # #${CURDIR_path}            ${CURDIR}/../../../../../commissionings/HGZ/${testline_name}
# # #
# # #
# # #*** Test Cases ***
# # #[1] 5GC001913-TA-5GC000856_A_4_NSA L3 call with DL data traffic with TCP_above 37GHz RU
# # #    [Tags]    5GC001913    CRT_20B  CRT_21B    CIT_TRUNK    5GC000856     5GC000959    5GC001591
# # #    [Setup]
# # #    Input need scf for DL
# # #    COAM Check GNB_DU cell on air
# # #    attach multi power ue    ue_num=${1}
# # #    start multi power ue traffic ul and dl    ue_num=${1}    dl_throughput=${dl_throughput}    if_ul=${False}    protocol=tcp
# # #    ...    ul_duration=120
# # #    sleep    10s
# # #    log    \n start check throughput    console=yes
# # #    ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=100s    ignore_time=10s
# # #    ${cell_list}    create list    98305
# # #    power_ue.Check Tput    ue_type=samsung    direction=dl    log=${log_path}     cells=${cell_list}    target_throughput=${Expected_dl_Tput}
# # ##    power_ue.Check throughput    ue_type=samsung    direction=dl    throughput=${Expected_dl_Tput}
# # #    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=samsung   iperf_type=via_command    protocol=tcp
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
# # #Get peak and ave throughput and return result
# # #    [Documentation]    Get ul and dl peak and ave throughput and return result.
# # #    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
# # #    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}
# # #    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
# # #    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
# # #    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}   host=${DU_IP}
# # #    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
# # #    ...     host=${DU_IP}
# # #    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
# # #    ...    cell_numbers=${cell_number}
# # #    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}
# # #
# # #Input need scf for DL
# # #    [Timeout]  20 min
# # #    [Arguments]    ${timeout}=10 min
# # #    ${conn}    Connect to DU
# # #    BuiltIn.Log    \n Input need scf for DL \n    console=yes
# # #    ${default_scf}    Get BTS Version And Perare SCF    CURDIR_path=${CURDIR_path}
# # #    Connect to gnb coam via ssl    bts_host=${DU_IP}    username=${WEBUI_USER}   password=${WEBUI_PASSWORD}
# # #    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
# # #    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
# # #    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
# # #    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
# # #    [Teardown]    Disconnect from DU
# # #
# # #Get BTS Version And Perare SCF
# # #    [Arguments]    ${CURDIR_path}
# # #    ${connection}    admin_cli.connect_to    bts_host=${DU_IP}     name=GNB_OAM
# # #    ${version}    admin_cli.get_sw_version    connection=${connection}
# # #    ${scf_name}    5GC001913_common_KW.Covert_BTS_Version    version=${version}
# # #    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
# # #    log to console   ${default_scf}
# # #    [Return]  ${default_scf}
# # #    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
# # #
# # #Connect to DU
# # #    [Arguments]    ${alias}=cOAM_admin
# # #    ${conn}=    admin_cli.connect_to
# # #    ...    bts_host=${DU_IP}
# # #    ...    username=${WEBUI_USER}
# # #    ...    password=${WEBUI_PASSWORD}
# # #    ...    name=${alias}
# # #    [Return]    ${conn}
# # #
# # #Disconnect from DU
# # #    [Arguments]    ${alias}=cOAM_admin
# # #    admin_cli.teardown     connection=${alias}
# # #
# # #Case Teardown
# # #    Run Keyword And Ignore Error    Recover the test ENV
# # #    CI_interface.Common Case Teardown