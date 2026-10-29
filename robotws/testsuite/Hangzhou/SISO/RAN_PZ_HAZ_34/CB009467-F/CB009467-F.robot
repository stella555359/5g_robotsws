# *** Settings ***
# Documentation
# ...    author: ruizzhan
# ...    contact: ruizhi.zhang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB009467
# 
# 
# Suite Setup       CB009467 Suite Setup
# Suite Teardown    CB009467 Suite Teardown
# 
# 
# Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009467-F/Resources/CB009467_common_keyword.robot
# 
# 
# *** Test Cases ***
# [1]CB009467_W_003_NSA_DL_UL_peak_Tput_FR2_NR_8CCDL_4CCUL
#     [Tags]  CRT_24R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     ATTACH SAM 1UE1RU AND CHECK THROUGHT     ue_index=${1}    ul_throughput=599    dl_throughput=1500
#     ...    cells=${cell_list_8CC[0:8]}     value=${3}    ENB_index=3    bts_host=${ENB_1_ip}    target_avg_percent_dl=${2.68}
#     [Teardown]    Run Keyword And Ignore Error    Case Teardown
# 
# 
# [1]CB009467_F_002_4A_FR2_with_24R1_N_CB009467_4a_configuration_Cell_lock_unlock_on_Extension_module_and_main_radio
#     [Tags]    CRT_24R1    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     commission extensionmode SCF
#     Check GNB on air
#     Log To Console    block/unblock lokia rmod cells
#     BLock or UnBlock Cell And Check Status      Cell_status=@{Cell_block_status}      block_cell_id_list=${block_cell_id_list1}
#     ...     block_flag=${True}
#     sleep  5
#     BLock or UnBlock Cell And Check Status      Cell_status=@{Cell_unblock_status}      unblock_cell_id_list=${unblock_cell_id_list1}
#     ...     block_flag=${False}
#     ATTACH SAM 1UE1RU AND CHECK THROUGHT     ue_index=${1}    ul_throughput=100   dl_throughput=500
#     ...    cells=${cell_4CC_RMOD[0:4]}     value=${3}    ENB_index=3    bts_host=${ENB_1_ip}
#     Log To Console    block/unblock extensionmode cells
#     BLock or UnBlock Cell And Check Status      Cell_status=@{Cell_block_status}       block_cell_id_list=${block_cell_id_list2}
#     ...      block_flag=${True}
#     sleep  5
#     BLock or UnBlock Cell And Check Status      Cell_status=@{Cell_unblock_status}      unblock_cell_id_list=${unblock_cell_id_list2}
#     ...     block_flag=${False}
#     ATTACH SAM 1UE1RU AND CHECK THROUGHT     ue_index=${1}    ul_throughput=100    dl_throughput=500
#     ...    cells=${cell_4CC_exten[0:4]}     value=${4}    ENB_index=3    bts_host=${ENB_1_ip}
#     Log To Console    block/unblock lokib rmod cells
#     BLock or UnBlock Cell And Check Status      Cell_status=@{Cell_block_status}      block_cell_id_list=${block_cell_id_list3}
#     ...      block_flag=${True}
#     sleep  5
#     BLock or UnBlock Cell And Check Status      Cell_status=@{Cell_unblock_status}      unblock_cell_id_list=${unblock_cell_id_list3}
#     ...      block_flag=${False}
#     ATTACH SAM 1UE1RU AND CHECK THROUGHT    ue_index=${0}    ul_throughput=${100}    dl_throughput=${500}
#     ...    cells=${cell_4CC_lokib[0:4]}     value=${2}    ENB_index=2    bts_host=${ENB_0_ip}    LNCEL_id=${1}
#     ...    ui_version=S21UI3.1     target_avg_percent_dl=${0.5}     target_avg_percent_ul=${0.5}
#     [Teardown]    Run Keyword And Ignore Error    Case Teardown
# 
# [1]CB009467_F_008_4E_FR2_with_24R1_N_CB009467_4e_configuration
#     [Tags]  CRT_24R1    CRT_TRUNK
#     [Setup]    robot_common_operations.Common case Setup
#     log to console   pass   
# #     Should Be Equal As Strings  ${PREV_TEST_STATUS}  PASS
#     [Teardown]    Run Keyword And Ignore Error    Case Teardown
# 
# *** Keywords ***
# BLock or UnBlock Cell And Check Status
#     [Arguments]    ${block_cell_id_list}=None    ${unblock_cell_id_list}=None    ${block_flag}=${True}    ${bts_host}=${gnb_ip}
#     ...      ${Cell_status}=None
#     @{allowed_cell_block_list}    create list    @{allowed_list}    ${49}
#     @{not_allowed_list}    create list   ${49}
#     ${operate_cell_id_list}    Set Variable If    ${block_flag}    ${block_cell_id_list}    ${unblock_cell_id_list}
#     Block or UnBlock Single Cell    cell_id_list=${operate_cell_id_list}    block_flag=${block_flag}    bts_host=${bts_host}
#     run keyword if  ${block_flag}    Check Alarm List on BTS    allowed_list=${allowed_cell_block_list}    bts_host=${bts_host}
#     ...    ELSE    Check Alarm List on BTS    allowed_list=${allowed_list}    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}
#     ${expect_item_status_dict}    create dictionary
#     FOR    ${cell_id}    IN    @{operate_cell_id_list}
#         Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_status}
#     END
#     Check All RU or Cell Status     expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}   bts_host=${bts_host}
# 
# Block or UnBlock Single Cell
#     [Arguments]  ${cell_id_list}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id_list}
#     ...    ELSE    Log To Console    UnBlock Cell-${cell_id_list}
#     Run keyword if    ${block_flag}==${True}    Block Mulite Cell    cell_id_list=${cell_id_list}    timeout=${timeout}    connection=${connection}
#     ...    ELSE    UnBlock Mulite Cell    cell_id_list=${cell_id_list}    timeout=${timeout}    connection=${connection}
#     sleep    20s
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Block Mulite Cell
#     [Arguments]    ${cell_id_list}    ${timeout}    ${connection}
#     FOR    ${cell_id}    IN    @{cell_id_list}
#         ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
#         coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
#     END
# 
# UnBlock Mulite Cell
#     [Arguments]    ${cell_id_list}    ${timeout}    ${connection}
#     FOR    ${cell_id}    IN    @{cell_id_list}
#         ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
#         coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
#     END
# 
# commission extensionmode SCF
#     [Arguments]   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
#     Adapt to ute cloud commission scf
#     Set extensionmode SCF    bts_host=${bts_host}
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}     timeout=${600}
#     [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
# Set extensionmode SCF
#     [Arguments]    ${bts_host}=${gNB_ip}   ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#     ${version}    coam.get_sw_version    connection=${connection}
#     ${version_list}    split string    ${version}    separator=_
#     ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00_extensionmodel_4cc
#     ...    ELSE   Set Variable     SBTS24R1_extensionmodel_4cc
#     ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
#     set suite variable    ${default_scf_path}
#     log to console   ${default_scf_path}
#     [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
# 
