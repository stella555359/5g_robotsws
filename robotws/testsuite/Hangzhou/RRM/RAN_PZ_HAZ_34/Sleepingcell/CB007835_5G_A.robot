# *** Settings ***
# Suite Setup          SISO Coam Suite Setup
# Suite Teardown       SISO Coam Suite Teardown
# Test Timeout         2000 min
# 
# Documentation
# ...    Author: tingting zhong
# ...    Contact: tingting.zhong@nokia-sbell.com
# ...    squad group:SG_04
# ...    Feature Sleeping cell
# 
# Force Tags            5G_RAN_TDD    STATE_GNB_COMMISSIONED
# ...    PY36
# 
# Resource    ./Resource/sleepingcell_cases.robot
# *** Variables ***
# ${if_commissioning}                   False
# ${if_teardown_commissioning}          False
# ${upgrade_total_times}                ${3}
# ${reset_total_times}                  ${3}
# ${lock_total_times}                   ${3}
# ${block_total_times}                  ${3}
# ${Filber_total_times}                 ${3}
# ${call_time}                          1h                             #h/m/s
# ${timeout}                            1800
# 
# *** Test Cases ***
# [1]CB007835-5G-A_03_Separately_CELL_RU_BTS reset_then L3call
#     log to console    \ntotal times:${reset_total_times}
#     FOR    ${itime}    IN RANGE    1    ${reset_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${reset_total_times}
#         ${status}    run keyword and return status    Separately_CELL_RU_BTS reset_then L3call
#         run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#         ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}/${itime}    timeout=${timeout}
#         should be true    ${status}
#     END
# 
# [1]CB007835-5G-A_02_Separately_CELL_RU_BTS lock_unlock via NetAct_then L3call
#     log to console    \ntotal times:${lock_total_times}
#     FOR    ${itime}    IN RANGE    1    ${lock_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${lock_total_times}
#         ${status}    run keyword and return status    Separately_CELL_RU_BTS lock_unlock via NetAct_then L3call
#         run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#         ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}/${itime}    timeout=${timeout}
#         should be true    ${status}
#     END
# 
# [1]CB007835-5G-A_06_Separately_hold_long_time_UE_L3call
#     log to console    \ntotal time:${call_time}
#     ${call_time}    Calculate Loop Time    total_time=${call_time}
#     ${status}    run keyword and return status    Separately_hold_long_time_UE_L3call    total_time=${call_time}
#     run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#     ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}     timeout=${timeout}
#     should be true    ${status}
# 
# [1]CB007835-5G-A_07_Separately_CELL_block_unblocked_then L3call
#     log to console    \ntotal times:${block_total_times}
#     FOR    ${itime}    IN RANGE    1    ${block_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${block_total_times}
#         ${status}    run keyword and return status    Separately_CELL_block_unblock_then_L3call
#         run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#         ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}/${itime}    timeout=${timeout}
#         should be true    ${status}
#     END
#     FOR    ${itime}    IN RANGE    1    ${block_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${block_total_times}
#         ${status}    run keyword and return status    Separately_site_block_unblock_then_L3call
#         run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#         ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}/${itime}    timeout=${timeout}
#         should be true    ${status}
#     END
# 
# [1]CB007835-5G-A_01_Separately sw download and activation gNB via NetAct_then L3call
#     log to console    \ntotal times:${upgrade_total_times}
# 	Connect to gnb coam via ssl
# 	${ru_index_list}     Get All RU Index    connection=GNB_OAM
#     ${ru_new_list}     create list     @{ru_index_list}[1]
#     ${cell_id_list}    Get All Cell Id    ru_index=@{ru_new_list}[0]    connection=GNB_OAM
#     ${physicalCellId_list}    Get All Cell physicalCellId     ru_index=@{ru_new_list}[0]    connection=GNB_OAM
#     ${modify_physicalCellId}    Set Variable    @{physicalCellId_list}[0]
#     ${modify_cell_id}    Set Variable    @{cell_id_list}[0]
#     Set Test Variable     ${modify_physicalCellId}
#     Set Test Variable     ${modify_cell_id}
#     Set Test Variable     ${ru_index_list}
# 	${active_package}    ${passive_package}    get_all_sw_package
#     ${active_package_path}    download_package_and_check_sha256    sw_version=${active_package}    save_path=${SAVE LOG DIRECTORY}
# 	${rm_active_package}    Catenate    rm -rf ${active_package_path}
# 	${flag}    get_active_higher_than_passive_flag
# 	${passive_package_path}    run keyword if    not ${flag}   
# 	...    download_package_and_check_sha256    sw_version=${passive_package}    save_path=${SAVE LOG DIRECTORY}
#     ${rm_passive_package}    run keyword if    not ${flag}    Catenate    rm -rf ${passive_package_path}  
#     FOR    ${itime}    IN RANGE    1    ${upgrade_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${upgrade_total_times}
#         ${status}    run keyword and return status    Separately sw download and activation gNB via NetAct_then L3call
# 		...    active_package=${active_package}    passive_package=${passive_package}        any_value=${800}
# 		...    active_package_path=${active_package_path}    passive_package_path=${passive_package_path} 
#         run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#         ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}/${itime}    timeout=${timeout} 
#         should be true    ${status}
#     END
# 	[Teardown]  run keywords    Run Process     ${rm_active_package}      timeout=5min    shell=True    AND        
# 	...    run keyword if    not ${flag}    Run Process     ${rm_passive_package}      timeout=5min    shell=True
# 
# [1]CB007835-5G-A_08_Separately_Capture_snapshot_during gNB upgrade and carrier reconfigration via WebGUI_then L3call
#     log to console    \ntotal times:${upgrade_total_times}
#     Connect to gnb coam via ssl    connection=GNB_OAM
#     ${ru_index_list}     Get All RU Index    connection=GNB_OAM
#     ${ru_new_list}     create list     @{ru_index_list}[1]
#     ${cell_id_list}    Get All Cell Id    ru_index=@{ru_new_list}[0]    connection=GNB_OAM
#     ${physicalCellId_list}    Get All Cell physicalCellId     ru_index=@{ru_new_list}[0]    connection=GNB_OAM
#     ${modify_physicalCellId}    Set Variable    @{physicalCellId_list}[0]
#     ${modify_cell_id}    Set Variable    @{cell_id_list}[0]
#     Set Test Variable     ${modify_physicalCellId}
#     Set Test Variable     ${modify_cell_id}
#     Set Test Variable     ${ru_new_list}
#     COAM Teardown gnb connections     connection=GNB_OAM
#     Set Test Variable     ${cell_list}
#     FOR    ${itime}    IN RANGE    1    ${upgrade_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${upgrade_total_times}
#         ${status}    run keyword and return status    Separately modify parameter and activation gNB_then L3call    any_value=${800}
#         run keyword if     ${status}    OperatingSystem.Run    rm -rf ${OUTPUT_DIR}/snapshot*.zip
#     END
#     [Teardown]      Change physCellId parameter value    physCellId_value=${modify_physicalCellId}    globalCellId=${modify_cell_id}
# 
# 
# [1]CB007835-5G-A_10_Separately_Filber_ break_then L3call
#     Connect to gnb coam via ssl     connection=GNB_OAM
#     ${ru_index_list}     Get All RU Index     connection=GNB_OAM
#     ${ru_list}     create list     @{ru_index_list}[0]
#     COAM Teardown gnb connections     connection=GNB_OAM
#     Set Test Variable     ${ru_list}
#     FOR    ${itime}    IN RANGE    1    ${Filber_total_times}+1
#         Log to console    \n---------------------\nexecute process: ${itime}/${Filber_total_times}
#         ${status}    run keyword and return status    Separately Filber break then L3call
#         run keyword if    not ${status}    run keywords    Connect to gnb coam via ssl    AND
#         ...    Save Coam Snapshot    target_dir=${SAVE LOG DIRECTORY}/${itime}    timeout=${timeout}
#         should be true    ${status}
#     END
# 
# *** Keywords ***
