*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:xiaoxia.hao@nokia-sbell.com
...              Squard: HZ SG6
Resource     CB007737_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Tool/gnb_logs.robot


*** Variables ***
${gnb_log_version}    HEAD

*** Keywords ***
CB007737_A_02_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_without_CA_relationship_ABIO
    [Arguments]    ${pcell_index}
    run keyword and ignore error    Update PA Value For Tput
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    run keyword if     'SBTS23R2' in '${stream}'    Lock Cell    cell_id=2
    Make_L3_Call_And_Check_Tput    is_do_require_ue=${True}
    ...                            ul_data_transfer=50M
    ...                            dl_data_transfer=800M
    ...                            is_wireshark_log_capture=${True}
    ...                            check_scell_tput=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    [Teardown]    run keyword if    'SBTS23R2' in '${stream}'    Run Keyword And Ignore Error    Unlock Cell    cell_id=2

CB007737_A_06_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO
    [Arguments]    ${pcell_index}
    run keyword and ignore error    Update PA Value For Tput
    ${same_core_cellid_list}    Get Same Core Group List
    ${target_cell_id}    ${corce_id}    Get Same Core Id And Cell Id Except Pcell Group    same_core_cellid_list=${same_core_cellid_list}
    ...                                                                                    pcell_index=${pcell_index}
    Add NRREL Cell Infor On Gnb    pcell_index=${pcell_index}    target_cell_id=${target_cell_id}
    Set Test Variable    ${TARGET_CELL_ID}    ${target_cell_id}
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    ${pcell_index}    Convert To String    ${pcell_index}
    @{get_nrarfcnDlcellid_list}    copy list    ${target_cell_id}
    Append To List    ${get_nrarfcnDlcellid_list}     ${pcell_index}
    ${cellid_list}    Get Same nrarfcnDl Cell List    nrcell_list=${get_nrarfcnDlcellid_list}
    Set Test Variable    ${cellid_list}
    run keyword if     'SBTS23R2' in '${stream}'    Lock Cell    cell_id=2
    run keyword if     'SBTS00' in '${stream}'    Lock Cells    cells_list=${cellid_list}
    Make_L3_Call_And_Check_Tput    is_do_require_ue=${True}
    ...                            ul_data_transfer=75M
    ...                            dl_data_transfer=1000M
    ...                            check_scell_tput=${True}
    ...                            is_wireshark_log_capture=${True}
    ...                            select_scell_index=${target_cell_id}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${SCELL_MAPPING}
    ...                            min_DL_percent=0.3
    ...                            min_UL_percent=0.3
    ...                            start_traffic_duration=900
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]    run keywords    run keyword if    'SBTS23R2' in '${stream}'
    ...                                                                          Run Keyword And Ignore Error     Unlock Cell    cell_id=2    AND
    ...                           run keyword if    'SBTS00' in '${stream}'
    ...                                                         Run Keyword And Ignore Error     Unlock Cells    cells_list=${cellid_list}    AND
    ...                           run keyword and ignore error    Delete NRREL Cell Infor On Gnb    pcell_index=${pcell_index}

CB007737_A_07_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO_after_lock_unlock_cell
    [Arguments]    ${pcell_index}
    run keyword and ignore error    Update PA Value For Tput
    ${same_core_cellid_list}    Get Same Core Group List
    ${target_cell_id}    ${corce_id}    Get Same Core Id And Cell Id Except Pcell Group    same_core_cellid_list=${same_core_cellid_list}
    ...                                                                                    pcell_index=${pcell_index}
    ${target_cell_id_same_as_Pcell}    ${corce_id_same_as_Pcell}
    ...                                              Get Pcell Same Core Id And Cell Id    same_core_cellid_list=${same_core_cellid_list}
    ...                                                                                    pcell_index=${pcell_index}
    Add NRREL Cell Infor On Gnb    pcell_index=${pcell_index}    target_cell_id=${target_cell_id}
    Set Test Variable    ${TARGET_CELL_ID}    ${target_cell_id}
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    ${pcell_index}    Convert To String    ${pcell_index}
    ${target_cells}    create list    ${pcell_index}    ${target_cell_id_same_as_Pcell}[0]
    @{get_nrarfcnDlcellid_list}    copy list    ${target_cell_id}
    ${get_nrarfcnDlcellid_list}    Combine Lists    ${get_nrarfcnDlcellid_list}    ${target_cells}
    ${cellid_list}    Get Same nrarfcnDl Cell List    nrcell_list=${get_nrarfcnDlcellid_list}
    Set Test Variable    ${cellid_list}
    run keyword if     'SBTS00' in '${stream}' or 'SBTS24R3' in '${stream}' or 'SBTS25R2' in '${stream}'    Lock Cells    cells_list=${cellid_list}
    Make_L3_Call_And_Check_Tput     is_do_require_ue=${True}
    ...                            ul_data_transfer=75M
    ...                            dl_data_transfer=1000M
    ...                            check_scell_tput=${True}
    ...                            is_wireshark_log_capture=${True}
    ...                            select_scell_index=${target_cell_id}
    ...                            is_need_stop_traffic=${False}
    ...                            start_traffic_duration=3000
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${SCELL_MAPPING}
    ...                            min_DL_percent=0.3
    ...                            min_UL_percent=0.3
    Get X2 link shutdown waiting time
    Get gNb Cu Type Value
    FOR    ${index}    IN RANGE    5
        Lock Cell    cell_id=${target_cell_id_same_as_Pcell}[0]
        Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${target_cell_id_same_as_Pcell}[0]
        Sleep    10sec
        Unlock Cell    cell_id=${target_cell_id_same_as_Pcell}[0]
        Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${target_cell_id_same_as_Pcell}[0]
    END
    Sleep    120sec
    Check Tput For CA Group    ue_type=${ue_type}
    ...                        addition_scell_index_list=${target_cell_id}
    ...                        check_pcell_tput=${True}
    ...                        check_scell_tput=${True}
    ...                        scell_mapping=${SCELL_MAPPING}
    ...                        min_DL_percent=0.3
    ...                        min_UL_percent=0.3
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]     run keywords    Run Keyword And Ignore Error    Stop Traffic With Power UE    AND
    ...            run keyword if     'SBTS23R2' in '${stream}'
    ...                                                                           Run Keyword And Ignore Error    Unlock Cell    cell_id=2    AND
    ...            run keyword if    'SBTS00' in '${stream}'    Run Keyword And Ignore Error     Unlock Cells    cells_list=${cellid_list}    AND
    ...            run keyword and ignore error    Delete NRREL Cell Infor On Gnb    pcell_index=${pcell_index}

CB007737_A_10_mix intra_core_and_inter_core_CA_relationship_on_ABIO
    [Arguments]    ${pcell_index}
    run keyword and ignore error    Update PA Value For Tput
    ${same_core_cellid_list}    Get Same Core Group List
    ${target_cell_id_eccept_pcell}    ${corce_id}    Get Same Core Id And Cell Id Except Pcell Group
    ...                                                                                    same_core_cellid_list=${same_core_cellid_list}
    ...                                                                                    pcell_index=${pcell_index}
    ${target_cell_id_same_as_Pcell}    ${corce_id_same_as_Pcell}
    ...                                              Get Pcell Same Core Id And Cell Id    same_core_cellid_list=${same_core_cellid_list}
    ...                                                                                    pcell_index=${pcell_index}
    ${target_cell_id}    create list    ${target_cell_id_eccept_pcell}[0]    ${target_cell_id_same_as_Pcell}[0]
    Set Test Variable    ${TARGET_CELL_ID}    ${target_cell_id}
    Add NRREL Cell Infor On Gnb    pcell_index=${pcell_index}    target_cell_id=${target_cell_id}
    Generate Pcell And Scell Mapping Info    pcell_index=${pcell_index}
    ${pcell_index}    Convert To String    ${pcell_index}
    @{get_nrarfcnDlcellid_list}    copy list    ${target_cell_id}
    Append To List    ${get_nrarfcnDlcellid_list}     ${pcell_index}
    ${cellid_list}    Get Same nrarfcnDl Cell List    nrcell_list=${get_nrarfcnDlcellid_list}
    Set Test Variable    ${cellid_list}
    run keyword if     'SBTS23R2' in '${stream}'    Lock Cell    cell_id=2
    run keyword if     'SBTS00' in '${stream}'   Lock Cells    cells_list=${cellid_list}
    Make_L3_Call_And_Check_Tput     is_do_require_ue=${True}
    ...                            ul_data_transfer=90M
    ...                            dl_data_transfer=1500M
    ...                            check_scell_tput=${True}
    ...                            is_wireshark_log_capture=${True}
    ...                            select_scell_index=${target_cell_id}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${SCELL_MAPPING}
    ...                            start_traffic_duration=900
    ...                            min_DL_percent=0.3
    ...                            min_UL_percent=0.3
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]    run keywords    run keyword if    'SBTS23R2' in '${stream}'
    ...                                                                           Run Keyword And Ignore Error    Unlock Cell    cell_id=2    AND
    ...           run keyword if    'SBTS00' in '${stream}'    Run Keyword And Ignore Error     Unlock Cells    cells_list=${cellid_list}    AND
    ...           run keyword and ignore error    Delete NRREL Cell Infor On Gnb    pcell_index=${pcell_index}

CB009531_A1_02_DRX_Retransmission_timer_support_in_DL_and_UL_for_non_VoNR_TDD_HarqRtt
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${pcell_index}
#    Clone Gnblogs Tool    gnb_log_version=${gnb_log_version}
    Keep only Pcell notbarred for CA testing    pcell_index=${pcell_index}
    ${scell_list}    Create List    1     2     3    4
    Delete NRREL Cell Infor On Gnb    pcell_index=${pcell_index}    scell_list=${scell_list}
    run keyword and ignore error    Update PA Value For Tput
    ${dl_data_transfer}    set variable if     'SBTS00' in '${stream}'    10M    30M
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    Make_L3_Call_And_Check_Tput    is_do_require_ue=${True}
    ...                            ul_data_transfer=5K
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            is_wireshark_log_capture=${True}
    ...                            whether_collect_tput=${False}
    ...                            check_pcell_tput=${False}
    ...                            check_scell_tput=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            is_need_stop_traffic=${False}
    ...                            start_traffic_duration=900
    ...                            dl_process_num=1
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    ${PA_value}    set variable if     'SBTS00' in '${stream}'    45    25
    ${target_PA_Value}    set variable if    'SBTS00' in '${stream}'    ${65}    'SBTS24R2' in '${stream}'    ${42}    ${45}
    Cycle UPdate PA Value    cell_index=${pcell_index}    PA_value=${PA_value}    target_PA_Value=${target_PA_Value}
    Sleep    30sec
    Check NONDTX And Txnumber on TTI
    [Teardown]    run keyword and ignore error   Stop Traffic With Power UE

CB009531_A2_09_DRX_Retransmission_timer_support_in_DL_and_UL_for_VoNR_TDD
    [Documentation]    M55300C12001	DL 5QI1 SDUs not received by UE after maximum HARQ retransmissions
    ...                M55302C10001	UL 5QI1 SDUs not received by gNB after maximum HARQ retransmissions
    ...                M55308C11002	Number of slots when UE is in DRX sleep time
    ...                M55308C11001	Number of slots when UE is in DRX active time.
    [Arguments]    ${pcell_index}=3
#    ${para_modify}    Catenate    {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1',
#    ...                            'parameter': 'miNrUlHarq',
#    ...                            'value': '5min'},
#    ...                           {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1',
#    ...                            'parameter': 'miNrDlHarq',
#    ...                            'value': '5min'},
#    ...                           {'dist_name': 'MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1',
#    ...                            'parameter': 'miNrCellUtilization',
#    ...                            'value': '5min'}
#    ${performance_cycle_modify}    Evaluate    [${para_modify}]
#    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${performance_cycle_modify}    timeout=900
#    Clone Gnblogs Tool    gnb_log_version=${gnb_log_version}
    run keyword and ignore error    Update PA Value For Tput
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    ${cpif_log_path}    Start UE Attach With Power UE    4G_check=${False}
    Make Vonr Call For Qualcomm
    Sleep    10sec
    ${PA_value}    set variable    25
    ${target_PA_Value}    set variable    ${33}
    Cycle UPdate PA Value    cell_index=${pcell_index}    PA_value=${PA_value}    target_PA_Value=${target_PA_Value}
    Sleep    30sec
    Wait Until Next Counter Update
    Sleep    60sec
#    ${M55302C10001_full_path_SBTS24R1}    set variable    CELLS/NRCELL-${pcell_index}/NULHQ/UL_MAC_SDU_5QI1_HARQ_MAX_RTX
#    ${M55300C12001_full_path_SBTS24R1}    set variable    CELLS/NRCELL-${pcell_index}/NDLHQ/DL_MAC_SDU_5QI1_HARQ_MAX_RTX
#    ${M55308C11001_full_path_SBTS24R1}    set variable    CELLS/NRCELL-${pcell_index}/NCELA/SLOTS_UE_DRX_ACTIVE
#    ${M55308C11002_full_path_SBTS24R1}    set variable    CELLS/NRCELL-${pcell_index}/NCELA/SLOTS_UE_DRX_SLEEP
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${M55302C10001_full_path}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NULHQ/UL_MAC_SDU_5QI1_HARQ_MAX_RTX
    ${M55300C12001_full_path}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NDLHQ/DL_MAC_SDU_5QI1_HARQ_MAX_RTX
    ${M55308C11001_full_path}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NCELA/SLOTS_UE_DRX_ACTIVE
    ${M55308C11002_full_path}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NCELA/SLOTS_UE_DRX_SLEEP
#    ${M55302C10001_full_path_SBTS24R2}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NULHQ/UL_MAC_SDU_5QI1_HARQ_MAX_RTX
#    ${M55300C12001_full_path_SBTS24R2}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NDLHQ/DL_MAC_SDU_5QI1_HARQ_MAX_RTX
#    ${M55308C11001_full_path_SBTS24R2}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NCELA/SLOTS_UE_DRX_ACTIVE
#    ${M55308C11002_full_path_SBTS24R2}    set variable    ${dis_name_dir}/NRCELL-${pcell_index}/NCELA/SLOTS_UE_DRX_SLEEP
    ${M55302C10001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55302C10001
    ...                                                  counter_full_path=${M55302C10001_full_path}
    ${M55302C10001_value}    convert to integer     ${M55302C10001_value}
    run keyword and continue on failure    should be true    ${M55302C10001_value}<5
    ${M55300C12001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55300C12001
    ...                                                  counter_full_path=${M55300C12001_full_path}
    ${M55300C12001_value}    convert to integer     ${M55300C12001_value}
    run keyword and continue on failure    should be true    ${M55300C12001_value}<5
    ${M55308C11001_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55308C11001
    ...                                                  counter_full_path=${M55308C11001_full_path}
    ${M55308C11001_value}    convert to integer     ${M55308C11001_value}
    ${M55308C11002_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55308C11002
    ...                                                  counter_full_path=${M55308C11002_full_path}
    ${M55308C11002_value}    convert to integer     ${M55308C11002_value}
    run keyword and continue on failure    should be true    ${M55308C11001_value}+${M55308C11002_value}==600000
    Check UL NONDTX And Txnumber on TTI
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]    run keywords    run keyword and ignore error    Hang Up Vonr Call For Qualcomm    AND
    ...                           run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

CB009531_PDL_Removel_csiReportPeriodicity_Out_of_OndurationTime
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${pcell_index}
#    Clone Gnblogs Tool    gnb_log_version=${gnb_log_version}
    Keep only Pcell notbarred for CA testing    pcell_index=${pcell_index}
    run keyword and ignore error    Update PA Value For Tput
#    ${dl_data_transfer}    set variable if     'SBTS00' in '${stream}'    10M    30M
    Generate Pcell Mapping Info    pcell_index=${pcell_index}
    Make_L3_Call_And_Check_Tput    is_do_require_ue=${True}
    ...                            ul_data_transfer=135M
    ...                            dl_data_transfer=1000M
    ...                            is_wireshark_log_capture=${True}
    ...                            check_scell_tput=${False}
    ...                            get_attach_cell_index_needed=${False}
    ...                            scell_mapping=${None}
    ...                            is_need_stop_traffic=${False}
    ...                            start_traffic_duration=900
    ...                            dl_process_num=1
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    [Teardown]    run keyword and ignore error   Stop Traffic With Power UE
