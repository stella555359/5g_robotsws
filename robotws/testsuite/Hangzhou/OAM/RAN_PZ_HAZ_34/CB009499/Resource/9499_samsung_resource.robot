*** Settings ***
Documentation     author: Han Ruiyu
...               contact: ruiyu.han@nokia-sbell.com
...               squad group: SG_07
...               feature : CB009499

Library           OperatingSystem
Library           Collections
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF/Resource/common.robot


*** Variables ***
#${cpc_ip}   ${tl.ues[${ue_index}].ssh_connection_details.addr}
#${cpc_usrname}   ${tl.ues[${ue_index}].ssh_connection_details.username}
#${cpc_passwd}   ${tl.ues[${ue_index}].ssh_connection_details.password}
#${ue_2_required}   ${false}
#${ue_3_required}   ${false}
#${ue_4_required}   ${false}
#${BTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
Samsung Check L3call Status after Cell Lock Unlock
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${false}    ${duration}=3000   ${direction}=BOTH
    # Start NR DL traffic #
    Run keyword if   ${NR_L3call_need}==${true}    NR Samsung Cell Lock UNLock L3CALL Process    duration=${duration}
    # Start LTE DL/UL traffic #
    Run keyword if   ${LTE_L3call_need}==${true}   LTE Samsung Cell Lock UNLock L3CALL Process    duration=${duration}
    [Teardown]   Samsung L3CALL Cell Lock Unlock L3CALL Teardown

NR Samsung Cell Lock UNLock L3CALL Process
    [Arguments]   ${duration}
    @{lock_case_NRcells}   Create List
    Test_Case_ASOF_Data_Transfer_Conducted
    ...   traffic_stop=${False}   direction=both   duration=${duration}   4G_call_celllock=${false}
    ...   Lock_peak=${Lockcell_L3call_peak_needed}
    ${NRCellId}   Get Attached Cell Indentity
    Append To List    ${lock_case_NRcells}   ${NRCellId}
    # Check NR DL tput not impact by unlock cell#
    Check Bi Tput l3call CPE    ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}   cells=${lock_case_NRcells}
    ...   Expect_Tput_DL=${5Gtput_expect_DL}    Expect_Tput_UL=${5Gtput_expect_UL}    target_avg_percent=${5G_DL_tput_deviation}
    log to console    \n| check Tput successful with all cell unlocked!\n
    # Lock NR NoL3CALL Cells ALL Onetime #
    Block Cell for L3call  5G_call=${true}  5G_operation=Locked   4G_operation=locked
    # Check NR DL tput not impact by lock cell #
    Check Bi Tput l3call CPE    ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}   cells=${lock_case_NRcells}
    ...   Expect_Tput_DL=${5Gtput_expect_DL}    Expect_Tput_UL=${5Gtput_expect_UL}    target_avg_percent=${5G_DL_tput_deviation}
    ...   min_percent=${5G_min_percent}
    log to console    \n| check Tput successful with all cell locked but cell-${nrcall_cell_index} !\n
    Block Cell for L3call   5G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    log to console   \n| NR Samsung Cell Lock UNLock L3CALL Process successful!\n
    [Teardown]  run keywords   power_ue.Stop traffic    direction=dl   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    ...   AND   power_ue.Stop traffic   direction=ul   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    ...   AND   power_ue.UE Detach   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}

LTE Samsung Cell Lock UNLock L3CALL Process
    [Arguments]   ${duration}
    @{lock_case_LTEcells}   Create List
    Test_Case_ASOF_Data_Transfer_Conducted
    ...   traffic_stop=${False}   direction=both   duration=${duration}   5G_call_celllock=${false}
    ...   Lock_peak=${Lockcell_L3call_peak_needed}
    ${NRCellId}   Get Attached Cell Indentity
    Append To List    ${lock_case_LTEcells}   ${NRCellId}

    # Check NR DL tput not impact by unlock cell #
    Check Bi Tput l3call CPE    ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}   cells=${lock_case_LTEcells}
    ...   Expect_Tput_DL=${4Gtput_expect_DL}    Expect_Tput_UL=${4Gtput_expect_UL}    target_avg_percent=${4G_DL_tput_deviation}
    ...   min_percent=${4G_min_percent}
    log to console    \n| check Tput successful with all cell unlocked!\n
    # Lock NR NoL3CALL Cells ALL Onetime #
    Block Cell for L3call   4G_call=${true}  5G_operation=Locked   4G_operation=locked
    # Check NR DL tput not impact by lock cell #
    Check Bi Tput l3call CPE    ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}   cells=${lock_case_LTEcells}
    ...   Expect_Tput_DL=${4Gtput_expect_DL}    Expect_Tput_UL=${4Gtput_expect_UL}    target_avg_percent=${4G_DL_tput_deviation}
    ...   min_percent=${4G_min_percent}
    log to console    \n| check Tput successful with all cell locked but cell-${ltecall_cell_index} !\n

    #unlock all cells
    Block Cell for L3call   4G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked

    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    log to console   \n| LTE Samsung Cell Lock UNLock L3CALL Process successful!\n
    [Teardown]  run keywords   power_ue.Stop traffic    direction=dl   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    ...   AND   power_ue.Stop traffic   direction=ul   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    ...   AND   power_ue.UE Detach   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}


Samsung L3CALL Cell Lock Unlock L3CALL Teardown
    run keyword and ignore error    power_ue.Stop traffic    direction=dl   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    run keyword and ignore error    power_ue.Stop traffic   direction=ul   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    run keyword and ignore error    power_ue.UE Detach   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    run keyword and ignore error    power_ue.Stop traffic   direction=ul   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    run keyword and ignore error    power_ue.UE Detach   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}


