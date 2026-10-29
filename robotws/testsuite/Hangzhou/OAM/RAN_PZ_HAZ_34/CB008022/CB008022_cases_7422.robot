# *** Settings ***
# Documentation
# ...   author: chun.tian@nokia-sbell.com
# ...   contact: chun.tian@nokia-sbell.com
# ...   SISO
# Force Tags     STATE_SW_UPLOADED
# 
# Suite Setup    Input default SCF
# 
# Resource    ./resource/CB008022_common_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# 
# 
# *** Variables ***
# ${cell_info_1}    ${1}
# ${connection}    du_conn
# ${parameter}     administrativeState
# ${value}      Shutting Down
# ${dist_name}       MRBTS-${btsname_id}/NRBTS-1/NRCELL-2
# 
# ${Operational_status1}       enabled
# ${Administrative_status1}     Shutting Down
# ${Usage_status1}     Active
# ${procedural_status1}       configured
# 
# ${Operational_status2}       disabled
# ${Administrative_status2}     Locked
# ${Usage_status2}     Idle
# ${procedural_status2}     initialization required
# ${cell_id}      16385
# ${ru_7422}      [TL7422_ASIB+ABIO+AWEUA*2] MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-2
# ${server_port_ul_sam}       ${tl.ues[0].iperf_details.ports[0]}
# ${server_port_dl_sam}       ${tl.ues[0].iperf_details.ports[1]}
# 
# @{ue_index_list}           ${2}
# ${exp_ul}                  ${10}
# ${exp_dl}                  ${10}
# ${nr_cell_list1}           16385
# ${enb_ip}                  ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
# ${enb_bts_id}              ${tl.enbs[1].instance_id}
# ${ul_throughput}           50M
# ${dl_throughput}           100M
# ${duration}                6000
# ${ru_index}             2
# 
# *** Test Cases ***
# [2]CB008022-5G_01_RMOD_reduction_with_disconnecting_first
#     [Tags]    CRT_22R3
#    Modify Parameter Value On ENB    bts_host=${enb_ip}    value=5
#    Samsung attach and start traffic    if_ul=${True}    if_dl=${True}    ul_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
#    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
#    ${RU_SN}    Set Variable    ${ru_info['serialNumber']}
#    set suite variable    ${RU_SN}
#    ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
#    ...       value=${value}    connection=${connection}
#    wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
#     ...    operational_status=${Operational_status2}    usage_status=${Usage_status2}
#     ...     administrative_status=${Administrative_status2}     cell_index=${2}
#    ${conn}     Rest Login DU
#    Lock Ru and check ru and cell Status     ru_idx=${2}     cell_index=${2}    connection=${conn}
#    Power Off RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
#    Wait until keyword succeeds  5min  30s       check fault 10 with alarm 7116      ru_index=${ru_7422}
#    ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
#    Delete RMOD-7422 Relevant Object and get cell number
#    Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail    j=${all_ru_list[0]}
#    ${i}    Get TL7422 BBMOD distname
#    ${ii}    Get TL7422 BBMOD RF1 SFP_R     i=${i}
#    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
#    ...     Get Availability status and operational State for SFP in TL7422      i=${i}     ii=${ii}
#    Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
#        ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
#    Samsung attach and start traffic    if_ul=${True}    if_dl=${True}    ul_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
#    [Teardown]   Case Teardown     expected_RU=${RU_SN}
# 
# [1]CB008022-5G_02_RMOD_reduction_with_de-commissioning_first
#    [Tags]    CRT_22R3      CRT_22R4    CRT_Trunk
#    Modify Parameter Value On ENB    bts_host=${enb_ip}    value=5
#    Samsung attach and start traffic    if_ul=${True}    if_dl=${True}    ul_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
#     &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
#     ${RU_SN}    Set Variable    ${ru_info['serialNumber']}
#     set suite variable    ${RU_SN}
#    ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
#    ...       value=${value}    connection=${connection}
#    wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
#     ...    operational_status=${Operational_status2}    usage_status=${Usage_status2}
#     ...     administrative_status=${Administrative_status2}     cell_index=${2}
#    ${conn}     Rest Login DU
#    Lock Ru and check ru and cell Status     ru_idx=${2}     cell_index=${2}     connection=${conn}
#    ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
#    Delete RMOD-7422 Relevant Object and get cell number
#    Power Off RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
#    Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail    j=${all_ru_list[0]}
#    ${i}    Get TL7422 BBMOD distname
#    ${ii}    Get TL7422 BBMOD RF1 SFP_R     i=${i}
#    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
#    ...     Get Availability status and operational State for SFP in TL7422      i=${i}     ii=${ii}
#    Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
#        ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
#     check throughput and stop traffic    if_ul=${True}    if_dl=${True}
#    [Teardown]   Case Teardown     expected_RU=${RU_SN}
# 
# #[1]CB008022-5G_07_RMOD_reduction_with_disconnecting_first_in_exceptional_scenarios
# #   [Tags]    CRT_22R3
# #   run keyword and ignore error    Askey attach and start traffic
# #   Lock Ru and check ru and cell Status     ru_idx=${2}     cell_index=${2}
# #   Power Off RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
# #   Wait until keyword succeeds  5min  30s       check fault 10 with alarm 7116      ru_index=${ru_7422}
# #   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
# #   Delete RMOD-7422 Relevant Object and get cell number
# #   Run Keyword And Expect Error    *No such a distName*       Check Web RMOD Detail    j=${all_ru_list[0]}
# #   ${i}    Get TL7422 BBMOD distname
# #   ${ii}    Get TL7422 BBMOD RF1 SFP_R     i=${i}
# #   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
# #   ...     Get Availability status and operational State for SFP in TL7422      i=${i}     ii=${ii}
# #   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
# #       ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
# #   run keyword and ignore error    Check Throughput Only
# #   [Teardown]   Case Teardown
# 
# 
# *** Keywords ***
# COAM get ru detial info by ru index
#     [Documentation]  Author: Ding Binmei
#     ...              Description: Get RU detail info by ru index
#     ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
#     [Arguments]    ${ru_index}=1    ${connection}=GNB_OAM
#     Rest Login DU    alias=${connection}
#     ${ru_index}    Convert to string    ${ru_index}
#     &{hw_info}    coam.get_detected_hw_info    connection=${connection}
#     @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
#     ${count_RUs}    Get length    ${list_RUs}
#     Should be true    ${count_RUs}>=1    msg=No RU found
#     &{dict_RUs_detail_info}   Create dictionary
#     FOR    ${RU}    IN    @{list_RUs}
#         ${status}    Run Keyword And Return Status    Should Contain   '${RU}'   RMOD-${ru_index}/
#         Run keyword if   '${status}'=='True'    Set to dictionary    ${dict_RUs_detail_info}    ${ru_index}    ${RU}
#     END
#     Run Keyword And Ignore Error   Logout DU via admin    alias=${connection}
#     [Return]  ${dict_RUs_detail_info['${ru_index}']}
#     
# Modify Parameter Value On ENB
#     [Arguments]    ${bts_host}    ${value}    ${cell_id}=1    ${connection}=coam_admin
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     coam.Perform parameter recommissioning    dist_name=MRBTS-${enb_bts_id}/LNBTS-${enb_bts_id}/LNCEL-${cell_id}
#     ...                                       parameter=defaultLnRelGnbCellId
#     ...                                       operation=update
#     ...                                       value=${value}
#     ...                                       skip_parameter_relation_errors=${True}
#     ...                                       should_activate=${True}
#     ...                                       connection=${connection}
#      Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
#      [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Samsung attach and start traffic
#     [Arguments]  ${if_ul}    ${if_dl}    ${ul_list}    ${dl_list}    ${ue_index_list}=${ue_index_list}    ${exp_ul_tp}=${exp_ul}
#     ...    ${exp_dl_tp}=${exp_dl}    ${log_time}=3m    ${ue_type}=samsung
#     attach multi power ue    ue_index_list=${ue_index_list}
#     UE start traffic sam       ue_index=${2}    tp_direction=both    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}    ue_type=samsung
#     ...    iperf_port_ul=${server_port_ul_sam}    iperf_port_dl=${server_port_dl_sam}
#     sleep    15s
#     ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=60s    ignore_time=5s
#     ${cell_list}    create list    ${16385}
#     run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=ul    log=${log_path}
#     ...    cells=${cell_list}    target_throughput=${exp_ul}
#     run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=dl    log=${log_path}
#     ...    cells=${cell_list}    target_throughput=${exp_dl}
# #     run keyword and continue on failure    power_ue.Check throughput
# #    ...    ue_type=samsung    direction=dl    throughput=${exp_dl}     cellid=16385
# #    run keyword and continue on failure    power_ue.Check throughput
# #    ...    ue_type=samsung    direction=ul    throughput=${exp_ul}     cellid=16385
# #    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    protocol=tcp    if_ul=${if_ul}    if_dl=${if_dl}
# #    [Teardown]  Run keyword and ignore error    detach multi power ue    ue_index_list=${ue_index_list}
# 
# check throughput and stop traffic
#     [Arguments]  ${if_ul}    ${if_dl}
#     ${log_path}    power_ue.Collect Tput    ue_type=samsung    duration=60s    ignore_time=5s
#     ${cell_list}    create list    ${16385}
#     run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=ul    log=${log_path}
#     ...    cells=${cell_list}    target_throughput=${exp_ul}
#     run keyword and continue on failure    power_ue.Check Tput    ue_type=samsung    direction=dl    log=${log_path}
#     ...    cells=${cell_list}    target_throughput=${exp_dl}
#     stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    protocol=tcp    if_ul=${if_ul}    if_dl=${if_dl}
#     [Teardown]  Run keyword and ignore error    detach multi power ue    ue_index_list=${ue_index_list}
# 
# attach multi power ue
#     [Arguments]    ${ue_index_list}
#     log to console       Prepare UE
#     FOR    ${item}    IN    @{ue_index_list}
#         power_ue.Prepare UE    ue_index=${item}    ue_type=samsung    ui_version=S21UI3.1
#         ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=samsung    log_type=Aasyslog
#         power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False
#     END
# 
# start multi power ue traffic ul and dl
#     [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
#     ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
#     log to console      Start traffic    console=yes
#     FOR    ${item}    IN    @{ue_index_list}
#         run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
#         ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
#         ...    iperf_port=@{ul_power_port_list}[${item}]
#         sleep    1s
#         run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
#         ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
#         ...    iperf_port=@{dl_power_port_list}[${item}]
#     END
# 
# stop multi power ue traffic ul and dl
#     [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
#     log to console     Stop traffic    console=yes
#     FOR    ${item}    IN    @{ue_index_list}
#         run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
#         ...    protocol=${protocol}    iperf_port=@{ul_power_port_list}[${item}]
#         run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
#         ...    iperf_port=@{dl_power_port_list}[${item}]
#     END
# 
# detach multi power ue
#     [Arguments]    ${ue_index_list}
#     log to console      UE Detach    console=yes
#     FOR    ${item}    IN    @{ue_index_list}
#          power_ue.UE Detach    ue_index=${item}    ue_type=samsung
#     END
# 
# check fault 10 with alarm 7116
#    [Arguments]      ${ru_index}
#    Rest Login DU
#    ${alarmId_id_list}    ${fault_id_list}       ${object_list}    CB008022_common_keywords.Get Alarm and fault Info     timeout=5
#    list should contain value     ${fault_id_list}     ${10}
#    list should contain value     ${alarmId_id_list}     ${7116}
#    list should contain value        ${object_list}     ${ru_index}
#    [Teardown]   CB008022_common_keywords.Disconnect from DU
# 
# Delete RMOD-7422 Relevant Object and get cell number
#     Log To Console    Delete RMOD And Relevant Object
#     WEBUI Login
#     selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-1/NRCELL-2
#     selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-1/NRCELLGRP-1
#     selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-2
#     selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/HWTOP-1/CABLINK-4
#     selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2
#     selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/NRBTS-1/NRDU-1
#     ...    filter_param=Reference to cell group    node_index=${1}    abbr=refNrCellGroup
#     selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/SYNC-2
#     ...    filter_param=List of Distinguished Names    node_index=${1}    abbr=targetDNList
#     ${error}    selenium_coam.validate_plan
#     Log To Console    ${error}
#     Log To Console    Activate plan
#     selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}
#     log to console      get current cell number
#     sleep    30s
#     ${total_cell_number}    selenium_coam.get_number_of_cells
#     should be equal      ${total_cell_number}     ${1}
#     [Teardown]    Run Keyword And Ignore Error    WEBUI Logout
# 
# COAM get ru index
#     [Documentation]  Author: shenrao
#     ...              Description: Get RU detail info by ru index
#     ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
#     [Arguments]    ${SN}    ${ru_index}=1    ${connection}=GNB_OAM
#     Rest Login DU    alias=${connection}
#     &{hw_info}    coam.get_detected_hw_info    connection=${connection}
#     @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
#     ${count_RUs}    Get length    ${list_RUs}
#     ${all_ru_list}      Create List
#     Run Keyword And Ignore Error    Should be true    ${count_RUs}>=1    msg=No RU found
#     FOR    ${RMOD}    IN    @{list_RUs}
#         run keyword if    '${RMOD['serialNumber']}'=='${SN}'    Append To List    ${all_ru_list}    ${RMOD['id']['internal'].split('RMOD_R-')[1]}
#     END
#     [Teardown]   Run Keyword And Ignore Error   Logout DU via admin    alias=${connection}
#     [Return]  ${all_ru_list[0]}
# 
# Get TL7422 BBMOD distname
#      ${conn}    Rest Login DU
#      FOR     ${i}    IN RANGE    ${1}    ${20}
#         ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}
#         ...              connection=${conn}
#         ${label}    get from dictionary    ${Connector_status}     serialNumber
#         ${if_BBMOD}     run keyword and return status    should be equal     ${label}    DH233144286
#         Exit For Loop If    '${if_BBMOD}'=='${True}'
#     END
#     [Return]    ${i}
#     [Teardown]     CB008022_common_keywords.Disconnect from DU
# 
# Get TL7422 BBMOD RF1 SFP_R
#     [Arguments]    ${i}
#      ${conn}    Rest Login DU
#      FOR     ${ii}    IN RANGE    ${1}    ${20}
#         ${physicalPort}    coam.get_parameters
#         ...              dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
#         ...              connection=${conn}
#         ${label}    get from dictionary    ${physicalPort}     physicalPort
#         ${if_RF_port}     run keyword and return status    should be equal     ${label}    RF1
#         Exit For Loop If    '${if_RF_port}'=='${True}'
#     END
#     [Return]    ${ii}
#     [Teardown]     CB008022_common_keywords.Disconnect from DU
# 
# Get Availability status and operational State for SFP in TL7422
#     [Arguments]    ${i}    ${ii}
#     ${conn}    Rest Login DU
#     ${RF_port_status}    coam.get_parameters
#     ...       dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
#     ...       pattern=availabilityStatus    connection=${conn}
#     ${RF_port_SFP_Astatus}         get from dictionary    ${RF_port_status}    availabilityStatus
#     ${RF_port_status}    coam.get_parameters
#     ...       dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
#     ...       pattern=operationalState    connection=${conn}
#     ${RF_port_SFP_Ostatus}         get from dictionary    ${RF_port_status}     operationalState
#     [Return]    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
#     [Teardown]    CB008022_common_keywords.Disconnect from DU
# 
# Check SFP availability status and operational State
#     [Arguments]      ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
#     Run keyword and continue on failure    should be equal    ${RF_port_SFP_Astatus}     dependency
#     Run keyword and continue on failure    should be equal    ${RF_port_SFP_Ostatus}     disabled
# 
# Check Web RMOD Detail
#     [Arguments]    ${j}
#     Log To Console    Check Web RMOD Detail
#     Rest Login DU
#     ${RMONDlistinfo}   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-${j}
#     [Return]     ${RMONDlistinfo}
#     [Teardown]    Run Keyword And Ignore Error    WEBUI Logout
# 
# Power On RU_2_HBTE
#     [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
#     Power On RU    model=HBTE    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}
# 
# Power On RU
#     [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
#     Log To Console    Power On RU
#     pdu.Setup Pdu    model=HBTE    host=${RU_PDU_IP}    alias=pdu_alias
#     pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu_alias
#     pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
#     sleep    3s
# 
# Power Off RU_2_HBTE
#     [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
#     Power Off    model=HBTE    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}
# 
# Case Teardown
#    [Arguments]    ${expected_RU}
#    Power On RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
#    Input default SCF
#    CI_interface.Common Case Teardown
