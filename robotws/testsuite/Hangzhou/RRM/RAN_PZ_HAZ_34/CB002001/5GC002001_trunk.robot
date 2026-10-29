# *** Settings ***
# Documentation
# ...    author: meng yan
# ...    contact: meng.yan@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_2_SG
# ...    Feature CB007539_5GC002001
# 
# Suite Setup          Suite_Setup_5GC002001
# Suite Teardown       Suite_Teardown_5GC002001
# Force Tags                5G_RAN    5G_RAN_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASOE_2xAEWD_ENB    master_pDU
# ...   PY39
# 
# Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB002001/resources/common_2001.robot
# Library    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB002001/resources/bip_beams_validation1.py
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# *** Variables ***
# ${du_scf_name}    2001_scf.xml
# ${ultp}    60M
# ${dltp}    300M
# ${exp_ul}    0
# ${exp_dl}    0
# ${beamsMuted_1}    536870912
# ${beamsMuted_11}    4294934526
# ${beamsMuted_19}    4250925759
# ${ue_index}    1
# ${bip_log_path}    /home/ute/ym/Genericl1l2bip/tcpdump.pcap
# ${target_dir}    /home/ute/ym
# ${ue_type}    ${tl.ues[0].capabilities[1]}
# 
# *** Test Cases ***
# [1][1.0] 5GC002001_A_11_SSB_exclusion_on_the_cell_with_predefined_beamset_and_GoB_on_Air_SS_PBCH_Scheduling_FR2
#     [Setup]    robot_common_operations.Common Case Setup
#     single_cell_block
#     Set mute beams    beamsMuted=${beamsMuted_11}
#     step1: Prepare UE    ue_index=${ue_index}
#     Step2: UE Attach    ue_index=${ue_index}
#     Collect BIP on ASOE    target_dir=${target_dir}
#     TL159 Validate Ssb Exclusion1
#     Run Keyword And Ignore Error    single_cell_unblock
#     [Teardown]    case_Teardown_5GC002001
# 
# [2][1.0] 5GC002001_A_19_UE_operates_in_the_cell_with_excluded_SSB_Data_Transmission_check_single_cell_FR2
#     [Setup]    robot_common_operations.Common Case Setup
#     single_cell_block
#     ${list_of_cell_ids}    Create List   2605057
#     Set mute beams    beamsMuted=${beamsMuted_19}
#     Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    2001_Check all cells status
#     step1: Prepare UE    ue_index=${ue_index}
#     Step2: UE Attach    ue_index=${ue_index}
#     Step3: Start traffic    ul_throughput=${ultp}    dl_throughput=${dltp}    ue_index=${ue_index}
#     Collect BIP on ASOE    target_dir=${target_dir}
#     ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
#     ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}
#     ...    ultarget_throughput=${exp_ul}    dltarget_throughput=${exp_dl}
#     ...    target_avg_percent=1
#     Set Test Variable    ${all_tp}    ${all_tp}
#     Run keyword and continue on failure    should be true    ${all_tp[1][0]['average']}>=${exp_dl}
#     Run keyword and continue on failure    should be true    ${all_tp[0][0]['average']}>=${exp_ul}
#     Run keyword and continue on failure    Step6: Stop traffic    ${ue_index}
#     #TL159 Validate dldata pdschsendreq muted beams    muted_beams=${beamsMuted_19}
#     TL159 Validate dldata pdcchsendreq muted beams    muted_beams=${beamsMuted_19}
#     #TL159 Validate uldata pucchreceivereq muted beams    muted_beams=${beamsMuted_19}
#     #TL159 Validate uldata puschreceivereq muted beams    muted_beams=${beamsMuted_19}
#     Run Keyword And Ignore Error    single_cell_unblock
#     [Teardown]    case_Teardown_5GC002001
# 
# *** Keywords ***
# single_cell_block
#     [Arguments]    ${operate_list}=${11}    ${check_alarm}=${False}
#     ${block_id}    create list    ${operate_list}
#     Get X2 link shutdown waiting time
#     Selenium Login And Disable Screen Lock
#     Block cells and check status   block_list=${block_id}    check_alarm=${check_alarm}
#     [Teardown]   Selenium Logout And Close Browser
# 
# single_cell_unblock
#     [Arguments]    ${operate_list}=${11}    ${check_alarm}=${False}
#     ${block_id}    create list    ${operate_list}
#     Get X2 link shutdown waiting time
#     Selenium Login And Disable Screen Lock
#     UnBlock Cells and check status   block_list=${block_id}   check_alarm=${check_alarm}
#     [Teardown]   Selenium Logout And Close Browser
# 
