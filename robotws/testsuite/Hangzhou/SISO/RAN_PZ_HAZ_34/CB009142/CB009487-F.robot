# *** Settings ***
# Documentation
# ...    author: Li Na
# ...    contact: na.li@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB009487_supercell_common
# 
# Resource    ./Resources/CB009142_common_keyword.robot
# Library     ./Resources/CB009142_common_keywords.py
# Variables   ./Resources/CB009142_modify_para.py
# 
# 
# Suite Setup       Robot Suite Setup 9487
# Suite Teardown    CB009142 Suite Teardown 
# 
# *** Test Cases ***
# [1][1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
#     [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     Check Cells info    expect_cell_info=${supercell_for_3nom3sub}
#     Power Off BTS And Wait Until On Air
#     @{allowed_list1}    create list    ${4655}    ${61524}    ${4654}    ${16}    ${61649}    ${4681}    ${61652}    ${61011}    ${61618}
#     Check Alarm List on BTS    allowed_list=${allowed_list1}
#     @{lock_ru_id_list1}    create list    ${1}    ${3}
#     @{unlock_ru_id_list1}    create list    ${2}
#     @{cell_list}    create list    ${11361}    ${11364}    ${11367}    ${11366}    ${11369}
#     Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}    unlock_RU_id_list=${unlock_ru_id_list1}    lock_flag=${True}
#     SAM PEAK Start Traffic and check ULDL Tp    ue_index=${0}    ul_throughput=10    dl_throughput=167    cells=${cell_list[0:1]}
#     ...    target_avg_percent=0.6
#     Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}    lock_flag=${False}
#     @{lock_ru_id_list2}    create list    ${4}    ${5}
#     @{unlock_ru_id_list2}    create list    ${6}
#     Lock or Unlock RU     lock_RU_id_list=${lock_ru_id_list2}    unlock_RU_id_list=${unlock_ru_id_list2}    lock_flag=${True}
#     Xiaomi Start Traffic and Check TP 2 nomal cell    ue_index=${1}    ul_throughput=30    
#     ...    dl_throughput=400    cells=${cell_list[3:4]}    cells_1=${cell_list[4:5]}    target_avg_percent=0.2
#     Lock or Unlock RU     unlock_RU_id_list=${lock_ru_id_list2}    lock_flag=${False}
#     [Teardown]  Run Keyword And Ignore Error    Case Teardown1
# 
# 
# 
# *** Keywords ***
# Robot Suite Setup 9487
#     [Arguments]    ${flag}=3nom3sub   ${feature}=9487
#     CI_interface.Common Suite Setup
#     robot_common_operations.Common Suite Setup
#     Adapt to ute cloud commission scf
#     Set default SCF    flag=${flag}    feature=${feature}
#     Setup Commission SCF    flag=${flag}    feature=${feature}
#     Get all xiaomi12 pointer variable
#     Check GNB on air
#     @{allowed_list1}    create list    ${4655}    ${61524}    ${4654}    ${16}    ${61649}    ${4681}    ${61652}    ${61011}    ${61618}
#     Check Alarm List on BTS    allowed_list=${allowed_list1}
# 
# Xiaomi Start Traffic and Check TP 2 nomal cell
#     [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${cells_1}    ${target_avg_percent}=0.06
#     @{ue_index_list}    create list    ${ue_index}
#     UE attach by Spark    ue_index_list=${ue_index_list}
#     Xiaomi start power ue traffic ul and dl    ue_index=${ue_index}    ul_throughput=${ul_throughput}M    
#     ...    dl_throughput=${dl_throughput}M    hostname=${tl.ues[1].ssh_connection_details.addr}
#     sleep   10s
#     ${status1}    Run Keyword And Return Status    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}   
# ...  ul_tp=${ul_throughput}    
#     ...    dl_tp=${dl_throughput}    target_avg_percent=${target_avg_percent}
#     ${status2}    Run Keyword And Return Status    Check Throught From Asslog    ul_list=${cells_1}    dl_list=${cells_1}   
#     ...    ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    target_avg_percent=${target_avg_percent}
#     Run Keyword if    ${status1}==${False}    should be equal    ${status2}    ${True}
#     stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
#     [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}
# 
# SAM PEAK Start Traffic and check ULDL Tp
#     [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent}=0.95
#     @{ue_index_list}    create list    ${ue_index}
#     UE attach by Spark    ue_index_list=${ue_index_list}
#     Single UE start traffic ul and dl 9487    ue_index=${ue_index}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
#     sleep   10s
#     Check Throught From Asslog ULDL    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
#     ...    target_avg_percent_DL=${target_avg_percent}
#     stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
#     [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}
# 
# Check Throught From Asslog ULDL
#     [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${100}    ${dl_tp}=${1500}    ${if_ul}=${True}    ${if_dl}=${True}
#     ...    ${target_avg_percent_UL}=0.5   ${ue_type}=samsung   ${log_time}=60s    ${target_avg_percent_DL}=0.73
#     ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
#     run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
#     ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent_UL}
#     ...    actCarrierAggregation=${True}    min_percent=0
#     run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
#     ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent_DL}
#     ...    actCarrierAggregation=${True}    min_percent=0
