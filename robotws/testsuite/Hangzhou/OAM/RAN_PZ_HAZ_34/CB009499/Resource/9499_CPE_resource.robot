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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG7/rrm_common.robot


#*** Variables ***
#${cpc_ip}   ${tl.ues[${ue_index}].ssh_connection_details.addr}
#${cpc_usrname}   ${tl.ues[${ue_index}].ssh_connection_details.username}
#${cpc_passwd}   ${tl.ues[${ue_index}].ssh_connection_details.password}
#${ue_2_required}   ${false}
#${ue_3_required}   ${false}
#${ue_4_required}   ${false}
#${BTS_ID}    ${tl.gnbs[0].global_bts_id}

*** Keywords ***
CPE Check L3call Status after Cell Lock Unlock
    [Arguments]   ${bip_enable}=${false}    ${traffic_stop}=${false}    ${duration}=3000   ${direction}=BOTH
    LOG    ${bip_enable}    ${traffic_stop}    ${duration}    ${direction}
    # Start NR DL traffic #
    Run keyword if   ${NR_L3call_need}==${true}    NR CPE Cell Lock UNLock L3CALL Process    duration=${duration}
    # Start LTE DL/UL traffic #
    Run keyword if   ${LTE_L3call_need}==${true}   LTE CPE Cell Lock UNLock L3CALL Process    duration=${duration}
    [Teardown]   CPE L3CALL Cell Lock Unlock L3CALL Teardown

NR CPE Cell Lock UNLock L3CALL Process
    [Arguments]   ${duration}
    @{lock_case_NRcells}   Create List
    Test_Case_ASOF_Data_Transfer_Conducted
    ...   traffic_stop=${False}   direction=both   duration=${duration}   4G_call_celllock=${false}
    ...   Lock_peak=${Lockcell_L3call_peak_needed}
    ${NRCellId}   Get Attached Cell Indentity
    Append To List    ${lock_case_NRcells}   ${NRCellId}
    # Check NR DL tput not impact by unlock cell#
    Check Bi Tput l3call CPE    ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}   cells=${lock_case_NRcells}
    ...   Expect_Tput_DL=${5Gtput_expect_DL}    Expect_Tput_UL=${5Gtput_expect_UL}   min_percent=${5G_min_percent}
    log to console    \n| check Tput successful with all cell unlocked!\n
    # Lock NR NoL3CALL Cells ALL Onetime #
    Block Cell for L3call  5G_call=${true}  5G_operation=Locked   4G_operation=locked
    # Check NR DL tput not impact by lock cell #
    Check Bi Tput l3call CPE    ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}   cells=${lock_case_NRcells}
    ...   Expect_Tput_DL=${5Gtput_expect_DL}    Expect_Tput_UL=${5Gtput_expect_UL}   min_percent=${5G_min_percent}
    log to console    \n| check Tput successful with all cell locked but cell-${nrcall_cell_index} !\n
    Block Cell for L3call   5G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked
    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
    log to console   \n| NR CPE Cell Lock UNLock L3CALL Process successful!\n
    [Teardown]  run keywords   power_ue.Stop traffic    direction=dl   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    ...   AND   power_ue.Stop traffic   direction=ul   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    ...   AND   power_ue.UE Detach   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}

LTE CPE Cell Lock UNLock L3CALL Process
    [Arguments]   ${duration}
    @{lock_case_LTEcells}   Create List
    Test_Case_ASOF_Data_Transfer_Conducted
    ...   traffic_stop=${False}   direction=both   duration=${duration}   5G_call_celllock=${false}
    ...   Lock_peak=${Lockcell_L3call_peak_needed}
#    ${NRCellId}   Get Attached Cell Indentity
#    Append To List    ${lock_case_NRcells}   ${NRCellId}
    # Lock NR NoL3CALL Cells ALL Onetime #
#    Block Cell for L3call   4G_call=${true}  5G_operation=Locked   4G_operation=locked
#    # Check NR DL tput not impact by lock cell #
#    Test_Case_ASOF_Data_Transfer_Conducted
#    ...   traffic_stop=${True}   direction=both   duration=${duration}   5G_call_celllock=${false}
#    ...   Lock_peak=${Lockcell_L3call_peak_needed}
#    Block Cell for L3call   4G_call=${true}  5G_operation=Unlocked   4G_operation=unlocked
#    Wait until keyword succeeds  10min   1min   COAM Check all cells should be onair
#    power_ue.Stop traffic    direction=dl   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
#    power_ue.Stop traffic   direction=ul   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
#    power_ue.UE Detach   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    log to console   \n| LTE CPE Cell Lock UNLock L3CALL Process successful!\n

CPE L3CALL Cell Lock Unlock L3CALL Teardown
    run keyword and ignore error    power_ue.Stop traffic    direction=dl   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    run keyword and ignore error    power_ue.Stop traffic   direction=ul   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    run keyword and ignore error    power_ue.UE Detach   ue_index=${NR_L3call_UE}   ue_type=${ue_${NR_L3call_UE}_type}
    run keyword and ignore error    power_ue.Stop traffic    direction=dl   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    run keyword and ignore error    power_ue.Stop traffic   direction=ul   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}
    run keyword and ignore error    power_ue.UE Detach   ue_index=${LTE_L3call_UE}   ue_type=${ue_${LTE_L3call_UE}_type}


Get NR and LTE L3CALL Cell info
    ${nrpci}    ${nrarfcn}   run keyword if   ${NR_L3call_need}
    ...   Get physCellId and ARFCN by Cellid    gloablecellid=${nrcall_cell_index}    Technology=NR
    ${ltepci}    ${ltearfcn}   run keyword if   ${LTE_L3call_need}
    ...   Get physCellId and ARFCN by Cellid    gloablecellid=${ltecall_cell_index}    Technology=LTE
    ${nrband}    run keyword if   ${NR_L3call_need}
    ...   Get Cell Band by Cellid    gloablecellid=${nrcall_cell_index}    Technology=NR
    ${lteband}    run keyword if   ${LTE_L3call_need}
    ...   Get Cell Band by Cellid    gloablecellid=${ltecall_cell_index}    Technology=LTE
    ${nrCellIdentity}    Get cellid by Globlecellid    gloablecellid=${nrcall_cell_index}
    Set Suite Variable    ${nrpci}
    Set Suite Variable    ${nrarfcn}
    Set Suite Variable    ${ltepci}
    Set Suite Variable    ${ltearfcn}
    Set Suite Variable    ${nrband}
    Set Suite Variable    ${lteband}
    Set Suite Variable    ${nrCellIdentity}