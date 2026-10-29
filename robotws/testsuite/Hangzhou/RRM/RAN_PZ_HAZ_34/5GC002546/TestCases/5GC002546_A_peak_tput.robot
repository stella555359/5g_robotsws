# *** Settings ***
# Resource    ../../CB007873/Resources/CB007873_keywords.robot
# 
# Documentation    Suite description
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC002546_A
# 
# Force Tags    5G_RRM
# ...    PY36
# Suite Setup     Tput Suite preparation
# Suite Teardown  run keyword and ignore error    Tput CA Suite teardown
# 
# *** Variables ***
# ${PCELL_DL_EXP_TPUT_20M}    205
# ${PCELL_UL_EXP_TPUT_20M}    73
# ${SCELL_DL_EXP_TPUT_100M}    1433
# ${PERCENT}    0.95      # Percent of peak TPUT
# ${TPUT_DURATION}    5m
# 
# *** Test Cases ***
# 5GC002546_A_20M_100M_1116_0ms_bufferbased_UDP_FlexibleCAMode_SA
#     [Tags]    CRT_21B    CIT_TRUNK    CIT_22R1    CIT_22R2    CRT_22R1    CDRT_22R2    CIT_22R4    CDRT_22R3
#     [Documentation]    Author: Wang Yixiang
#     ...    Description: This case is to verify peak tput of Pcell:20M Scell:100M
#     ...    Frame structure 1116, beamset_2, Scell activation:bufferbase, UDP
#     ...    NIDD:MODIFY_SCF_DEFAULT_20M_100M_1116_FLEXIBLECAMODE
#     [Setup]    Common case setup
#     ...    is_enb_status_check_needed=${False}    is_x2_check_from_enb_needed=${False}
#     set test variable    ${DL_TPUT}    1800M
#     CA_L3_call_tput    data_transfer_direction=dl     dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#     ...    protocol=udp    cell_id=${PCELL_ID},${SCELL_ID}
#     ...    exp_dl=${PCELL_DL_EXP_TPUT_20M},${SCELL_DL_EXP_TPUT_100M}
#     ...    exp_ul=-1,-1
#     ...    tput_duration=${TPUT_DURATION}    target_avg_percent=${PERCENT}
#     ...    ignore_time=2min
# 
#     run keyword and ignore error    Stop data transfer and detach UE    data_transfer_direction=dl
# 
#     CA_L3_call_tput    data_transfer_direction=both     dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
#     ...    protocol=udp    cell_id=${PCELL_ID},${SCELL_ID}
#     ...    exp_dl=${PCELL_DL_EXP_TPUT_20M},${SCELL_DL_EXP_TPUT_100M}
#     ...    exp_ul=${PCELL_UL_EXP_TPUT_20M},-1
#     ...    tput_duration=${TPUT_DURATION}    target_avg_percent=${PERCENT}
#     ...    ignore_time=2min
#     [Teardown]    run keyword and ignore error    Common case teardown    detach_ue=${True}
# 
# *** Keywords ***
# Tput Suite preparation
#     set suite variable     ${dpa_enable}     True
#     Import NIDD variables
#     set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT_20M_100M_1116_FLEXIBLECAMODE}
# 
#     CA Suite preparation    prepare_ue=${True}
#     ${PCELL_ID_1}   set variable if  '${PROGRAM}'=='21B'    ${PCELL_LIST[1]['nrCellId']}   ${-1}
#     ${PCELL_ID_2}   set variable if  '${PROGRAM}'=='21B'    ${PCELL_LIST[2]['nrCellId']}   ${-1}
#     set suite variable   ${PCELL_ID_1}
#     set suite variable   ${PCELL_ID_2}
#     run keyword if    ${PCELL_ID_1}>=0    Block attenuator for specified RU    gnb_index=${0}    ru_index=${2}
#     run keyword if    ${PCELL_ID_2}>=0    Block attenuator for specified RU    gnb_index=${0}    ru_index=${3}
#     Block adjacent gNB RUs
# 
# Tput CA Suite teardown
#     run keyword if    ${PCELL_ID_1}>=0    Initialize attenuator for specified RU    gnb_index=${0}    ru_index=${2}
#     run keyword if    ${PCELL_ID_2}>=0    Initialize attenuator for specified RU    gnb_index=${0}    ru_index=${3}
#     Initialize PA ports of adjacent gNB RUs
#     CA Suite teardown
