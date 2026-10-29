# *** Settings ***
# Suite Setup     Suite Setup for 729
# Suite Teardown    Suite Teardown for 729
# 
# Documentation
# ...   author: shanshan.zhang@nokia-sbell.com
# ...   contact: shanshan.zhang@nokia-sbell.com
# ...   PM Operability
# 
# Resource    resources/comm_keyword.robot
# Resource    resources/comm_case_keyword.robot
# Resource    ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Variables   ../5GC001937_OTA/resources/5GC001937_mmw4_modify_para.py
# Variables    resources/modify_para.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
# 
# *** Variables ***
# ${duration}         ${1800}
# ${ul_tput_udp}          20M
# ${dl_tput_udp}          20M
# ${log_time}             1m
# ${exp_ul}               ${204}
# ${exp_dl}               ${2020}
# ${exp_ul_dmrs}          ${195}
# ${exp_dl_dmrs}          ${1950}
# ${cmw_exp_ul}           ${5}
# ${cmw_exp_dl}           ${5}
# ${deviation}            3%
# ${total_count}          ${600}
# ${enb_mrbts}            5531
# ${enb_lnbts}            5531
# @{dlcell_list}        186089473    186089474    186089475    186089476
# @{ulcell_list}        186089473    186089474
# @{cmw_ulcell_list}    186089703
# @{cmw_dlcell_list}    186089703
# 
# @{SMOD_list}            ${1}
# @{BBMOD_list}           ${1}
# @{RMOD_list}            ${1}
# ${ENB_MRBTS_ID}              ${tl.enbs[0].instance_id}
# ${ENB_NRBTS_ID}              ${tl.enbs[0].global_bts_id}
# ${release_enb}          SBTS00
# @{ENB_CELL_ID}           ${1}   ${2}
# @{729_row_list}          NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PHY Thr. DL [Mbps]    NR PHY Thr. UL [Mbps]
# 
# *** Test Cases ***
# [1]General_SiSo_eNB_State_Management-eNB_reset_with_L3_call
#     [Tags]    CRT_TRUNK    CRT_CDRT
#     [Setup]   run keywords   Check BTS Should Be Normal    AND
#     ...    Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} 4G site reset
#         ${result}    Run Keyword And Return Status    4G site reset
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    ENB L3 call    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#         ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#         run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
#     END
# 
# [1]General_SiSo_eNB_State_Management-RU_lock_and_unlock_with_L3_call
#     [Tags]    CRT_TRUNK    CRT_CDRT
#     [Setup]   run keywords   Check BTS Should Be Normal    AND
#     ...    Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} 4G RU Lock Unlock then L3call
#         ${result}    Run Keyword And Return Status    4G RU Lock Unlock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#         ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
#     END
# 
# [1]E2E_TL_Cell_Bock_Unblock_LTE_with_sleeping_cell_check
#     [Documentation]
#     ...    [1]General_SiSo_eNB_State_Management-Cell_lock_and_unlock_with_L3_call
#     [Tags]    CRT_TRUNK    CRT_CDRT
#     [Setup]   run keywords   Check BTS Should Be Normal    AND
#     ...    Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} 4G CELL block unblock then L3call
#         ${result}    Run Keyword And Return Status    4G CELL block unblock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#         ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log     ip_address=${eNB_DU_OAM_IP}
#     END
# 
# [1]General_SiSo_eNB_State_Management-RU_reset_with_L3_call
#     [Tags]    CRT_TRUNK    CRT_CDRT
#     [Setup]   run keywords   Check BTS Should Be Normal    AND
#     ...    Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} ENB Reset RU And Wait Until On Air
#         ${result}    Run Keyword And Return Status    ENB Reset RU And Wait Until On Air
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if   ${result}    run keyword and continue on failure      ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#         ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...     run keyword and continue on failure    Save Snapshot Log     ip_address=${eNB_DU_OAM_IP}
#     END
# 
# [1]General_SiSo_eNB_State_Management-BBMOD_lock_and_unlock_with_L3_call
#     [Tags]    CRT_TRUNK    CRT_CDRT
#     [Setup]   run keywords   Check BTS Should Be Normal    AND
#     ...    Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} ENB Lock and unlock BBMOD
#         ${result}    Run Keyword And Return Status    ENB Lock and unlock BBMOD
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword if   ${result}    run keyword and continue on failure      ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#         ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...     run keyword and continue on failure    Save Snapshot Log      ip_address=${eNB_DU_OAM_IP}
#     END
# 
# [1]E2E_TL_Cell_Lock_Unlock_LTE_with_sleeping_cell_check
#     [Tags]    CRT_TRUNK    CRT_CDRT
#     [Documentation]
#     ...    -02.06.2023,pengliang.wu@nokia-sbell.com,case draft
#     [Setup]   run keywords   Check BTS Should Be Normal    AND
#     ...    Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}     cell_type=lte    connection=enb
#     Get BTS Software Version
#     FOR    ${i}    IN RANGE    ${3}
#         Log To Console    round ${i} 4G CELL Lock Unlock then L3call
#         ${result}    Run Keyword And Return Status    4G CELL Lock Unlock then L3call
#         run keyword and continue on failure    Should Be True    ${result}
#         run keyword and continue on failure    run keyword if   ${result}     ENB L3 call
#         ...    protocol=udp    log_time=2m    ul_enable=${True}    dl_enable=${True}
#         ...    total_count=${4200}    exp_ul_tp=${cmw_exp_ul}    exp_dl_tp=${cmw_exp_dl}    ue_index=${1}
#         ...    ul_list=@{cmw_ulcell_list}    dl_list=@{cmw_ulcell_list}
#         run keyword if    '${result}'!='${True}'
#         ...    run keyword and continue on failure    Save Snapshot Log    ip_address=${eNB_DU_OAM_IP}
#     END
# 
# *** Keywords ***
# Suite Setup for 729
#     [Arguments]  ${connection}=GNB_OAM
#     Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
#     Modify Common parameter via Coam      input_list=${MODIFY_Parameter_729}    connection=${connection}
#     robot_common_operations.Common Suite Setup
#     [Teardown]  COAM Teardown gnb connections    connection=${connection}
# 
# Suite Teardown for 729
#     [Arguments]  ${connection}=GNB_OAM
#     Connect to gnb coam via ssl     bts_host=${DU_OAM_IP}      connection=${connection}
#     Modify Common parameter via Coam      input_list=${Reconver_Parameter_729}     connection=${connection}
#     robot_common_operations.Common Suite Teardown
#     [Teardown]  COAM Teardown gnb connections    connection=${connection}
# 
# ENB RU Lock Unlock And Wait Until On Air
#     [Arguments]    ${RMOD_idx}=${1}    ${connection}=ENB
#     Log To Console    RU Lock/Unlock And Wait Until On Air
#     Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
#     ...    connection=${connection}
#     sleep    2s
#     Log To Console    Lock RU
#     coam.lock    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${120}    connection=${connection}
#     sleep    3s
#     Log To Console    Ulock RU
#     coam.unlock    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_idx}    timeout=${120}    connection=${connection}
#     Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}    cell_type=lte    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}
# 
# 4G RU Lock Unlock then L3call
#     Log To Console    4G RU Lock Unlock
#     [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${4G_pcmd}=${True}
#     ${fault_id_list_1}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#     ENB RU Lock Unlock And Wait Until On Air
#     sleep    30s
#     Check BTS Should Be Normal
#     ${fault_id_list_2}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#     run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
#     Check Alarm after OAM opraetion
# 
# Block and UnBlock Cells
#     [Arguments]  ${block_list}
#     Block cells and check status    block_list=${block_list}   check_alarm=${True}
#     UnBlock Cells and check status   block_list=${block_list}   check_alarm=${True}
# 
# Block cells and check status
#     [Arguments]  ${block_list}   ${check_alarm}=${True}   ${connection}=ENB_OAM
#     connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    connection=${connection}
#     log to console  \n***Block cells and check status***
#     FOR    ${idx}  IN  @{block_list}
#         selenium_coam.block_cell    cell_idx=${idx}    timeout=120    technology=LTE
#         Wait For Expect Fault Present    faultId=49    timeout=30    connection=${connection}    is_need_to_setup_gnb_connection=${False}
#     END
#     Wait Until Keyword Succeeds   3 min  10 sec   ENB Cell Should Be Blocked or UNBlocked    connection=${connection}
#     [Teardown]    COAM Teardown gnb connections    connection=${connection}
# 
# UnBlock Cells and check status
#     [Arguments]  ${block_list}  ${check_alarm}=${True}  ${connection}=ENB_OAM
#     connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    connection=${connection}
#     log to console  \n***UnLock cells and check status***
#     FOR    ${idx}  IN  @{block_list}
#         selenium_coam.unblock_cell    cell_idx=${idx}    timeout=120    technology=LTE
#     END
#     Wait Until Keyword Succeeds   3 min  10 sec   ENB Cell Should Be Blocked or UNBlocked    if_lock=${False}    connection=${connection}
#     Wait For Expect Fault To Disappear  faultId=49    timeout=60    connection=${connection}    is_need_to_setup_gnb_connection=${False}
#     [Teardown]    COAM Teardown gnb connections    connection=${connection}
# 
# 4G CELL block unblock then L3call
#     [Arguments]    ${ue_index}=0    ${pcmd}=${False}    ${connection}=ENB_OAM
#     [Documentation]    Owner_shanshan.zhang@nokia-sbell.com
#     ${fault_id_list_1}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#     Selenium Login And Disable Screen Lock    url=https://${eNB_DU_OAM_IP}    version=${release_enb}
#     ${status}    run keyword and return status    Block and UnBlock Cells    block_list=${ENB_CELL_ID}
#     run keyword if    not ${status}    Run Keyword And Ignore Error    UnBlock Cells and check status    block_list=${ENB_CELL_ID}
#     should be true    ${status}
#     ${fault_id_list_2}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#     run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
#     Check Alarm after OAM opraetion
#     [Teardown]     run keywords    selenium logout and close browser     AND
#     ...    run keyword and ignore error     COAM Teardown gnb connections    connection=${connection}
# 
# ENB Cell Should Be Blocked or UNBlocked
#     [Documentation]   Author: lanwen.cai@nokia-sbell.com
#     [Arguments]    ${if_lock}=${True}    ${cell_type}=lte    ${connection}=ENB_OAM
#     ${disabled}    Set Variable If    ${if_lock}    disabled    enabled
#     ${iflocked}    Set Variable If    ${if_lock}    Blocked    Unblocked
#     ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=20    connection=${connection}
#     FOR    ${cell}    IN    @{cells_info}
#         Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}     ${disabled}
#         Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['blockingState']}     ${iflocked}
#     END
# 
# ENB Reset RU And Wait Until On Air
#     [Arguments]    ${RU_index_list}=${RMOD_list}    ${connection}=ENB_OAM
#     Log To Console    Reset RU And Wait Until On Air
#     Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
#     ...    connection=${connection}
#     sleep    2s
#     FOR    ${RU_index}    IN    @{RU_index_list}
#         coam.reset_unit    dist_name=MRBTS-${ENB_MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}    timeout=${300}
#         ...    connection=${connection}
#     END
#     Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}    cell_type=lte    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}
# 
# ENB Lock and unlock BBMOD
#     [Arguments]    ${list}=${BBMOD_list}    ${connection}=ENB_OAM
#     Log To Console    Lock and unlock BBMOD
#     Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
#     ...    connection=${connection}
#     FOR    ${i}    IN    @{list}
#         coam.lock    dist_name=MRBTS-${eNB_BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${connection}
#         sleep    20s
#         coam.unlock    dist_name=MRBTS-${eNB_BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${i}    timeout=600s    connection=${connection}
#         Log To Console    wait until bts should be normal
#         Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}    cell_type=lte    connection=${connection}
#     END
#     [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}
# 
# ENB L3 call
#     [Arguments]    ${protocol}=udp    ${log_time}=${log_time}    ${ul_enable}=${True}    ${dl_enable}=${True}    ${total_count}=${total_count}
#     ...    ${exp_ul_tp}=${exp_ul}    ${exp_dl_tp}=${exp_dl}    ${ue_index}=0    ${ul_list}=@{ulcell_list}    ${dl_list}=@{dlcell_list}
#     ...    ${4G_pcmd}=${False}    ${buffer_size}=1400B    ${buffer_size_ul}=1300B    ${process_num}=${5}
#     Log To Console    start L3 call
#     ${total_result_dict}    set variable   ${total_tp_orge}
#     UE attach by Spark by Index    ue_index=${ue_index}
#     ${log_path}    Start UE data traffic and Record TP Log and Aasys Log
#     ...    ue_index=${ue_index}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}
#     ...    ul_duration=${duration}    dl_duration=${duration}     process_num=${process_num}
#     ...    protocol=${protocol}    if_ul=${ul_enable}    if_dl=${dl_enable}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
#     ...    buffer_size=${buffer_size}    buffer_size_ul=${buffer_size_ul}
#     run keyword and continue on failure    Stop UE traffic and Stop Record TP Log in spark    ue_index=${ue_index}    if_ul=${ul_enable}
#     ...    if_dl=${dl_enable}    protocol=${protocol}    spark_log_name=spark_ul_dl_udp
#     sleep    10s
#     ${total_result_list}    Get Each UE TP From Spark    ue_num=${1}    spark_log_name=spark_ul_dl_udp
#     ...    list_length=${total_count}    row_list=${729_row_list}
#     ${total_result_dict}    set variable    @{total_result_list}[-1]
#     #NR PHY Thr. DL [Mbps]
#     run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
#     ...    should be true    ${total_result_dict[0]['DL_bler'][0]} < 1.0
#     #NR PDCP Thr. DL [Mbps]
#     run keyword and continue on failure    run keyword if    ${dl_enable}==${True}
#     ...    should be true    ${total_result_dict[0]['DL_tp'][0]} > ${exp_dl_tp}
#     #NR PHY Thr. UL [Mbps]
#     run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
#     ...    should be true    ${total_result_dict[0]['UL_bler'][0]} < 1.0
#     #NR PDCP Thr. UL [Mbps]
#     run keyword and continue on failure    run keyword if    ${ul_enable}==${True}
#     ...    should be true    ${total_result_dict[0]['UL_tp'][0]} > ${exp_ul_tp}
#     [Return]    ${total_result_dict}
# 
# ENB CELL Lock Unlock And Wait Until On Air
#     [Arguments]    ${CELL_idx}=${1}    ${connection}=ENB
#     Log To Console    CELL Lock/Unlock And Wait Until On Air
#     Connect to gnb coam via ssl    bts_host=${eNB_DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
#     ...    connection=${connection}
#     sleep    2s
#     Log To Console    Lock CELL
#     coam.lock    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_NRBTS_ID}/LNCEL-${CELL_idx}    timeout=${120}    connection=${connection}
#     sleep    3s
#     Log To Console    Ulock CELL
#     coam.unlock    dist_name=MRBTS-${ENB_MRBTS_ID}/LNBTS-${ENB_NRBTS_ID}/LNCEL-${CELL_idx}    timeout=${120}    connection=${connection}
#     Check BTS Should Be Normal    bts_host=${eNB_DU_OAM_IP}    cell_type=lte    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}
# 
# 4G CELL Lock Unlock then L3call
#     Log To Console    4G CELL Lock Unlock
#     [Arguments]  ${ue_index}=0    ${pcmd}=${False}    ${4G_pcmd}=${False}
#     ${fault_id_list_1}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#     ENB CELL Lock Unlock And Wait Until On Air
#     sleep    30s
#     Check BTS Should Be Normal
#     ${fault_id_list_2}    Get BTS Alarm FaultID    bts_host=${eNB_DU_OAM_IP}
#     run keyword and continue on failure    lists should be equal    ${fault_id_list_1}    ${fault_id_list_2}
