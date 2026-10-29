*** Settings ***
Documentation
...    author: xiaofeng zhu
...    contact: xiaofeng.1.zhu@nokia-sbell.com
...    squad group: VRF3_SG04
...    feature : CB011092


Resource    ./Resources/CB011092_TL715_common_keywords.robot
#Resource    ./Resources/Modify_SCF.robot
Library     ./Resources/CB011092_TL715_common_keywords.py
Variables   ./Resources/CB011092_TL715_modify_para.py


Suite Setup      CB011092 Suite Setup
Suite Teardown

*** Test Cases ***
[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    TRUNK
    [Setup]    Case Setup
    Config 6subcell to 2supercell
    Get BTS Software Version
    FOR    ${i}    IN RANGE    ${test_iteration}
        Log To Console    round ${i} Reset start..
        ${result}    Run Keyword And Return Status    Stability Reset with HWF test
        run keyword if    '${result}'!='${True}'    run keyword and continue on failure    Save Snapshot Log
        run keyword and continue on failure    Should Be True    ${result}
    END
    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Tags]    TRUNK
    [Setup]    Case Setup
    log to console    E2E_TL_pass
    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_C_siso_08_full_3supercell_2subcells_add_RF_power_off_on
    [Tags]    TRUNK
    [Setup]    Case Setup
    config 6normal cell to 3supercell
    AlarmWatchdog.add_allow_alarms    fault_id=10
    power off RMOD and attach supercell
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    [Teardown]   Case Teardown1    if_activate_scf=${True}

[1]CB011092_C_siso_03_2BB_cell_set_1supercell_6sucbell_4D4U_3supercell_2subcell_4D4U_reconifguration
    [Tags]    TRUNK
    [Setup]    Case Setup
    config 5normal cell to 2supercell
    attach to subcell in two supercells
    config 2supercell to 6subcell in 1supercell
    attach to two subcells on RMOD1 and RMOD5

    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_C_siso_02_3supercell_2_subcell_reconfiguation_2supercell_3+3_subcell
    [Tags]    TRUNK
    [Setup]    Case Setup
    config 6normal cell to 3supercell
    config 3supercell to 2supercell
    lock RMOD and attach to supercell    RMOD_ID1=${1}    RMOD_ID2=${3}    Block_CELL_ID=${0}    ul_list=${NR_cell_id_nrtdd_1}
    ...    dl_list=${NR_cell_id_nrtdd_1}
    lock RMOD and attach to supercell    RMOD_ID1=${4}    RMOD_ID2=${5}    Block_CELL_ID=${1}    ul_list=${NR_cell_id_nrtdd_0}
    ...    dl_list=${NR_cell_id_nrtdd_0}

    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_C_siso_01_half_1_supercell_max_3_3subcell_active_deactive
    [Tags]    TRUNK
    [Setup]    Case Setup
    block normal cell and attach    ul_list=${NR_cell_id_nrtdd_2}    dl_list=${NR_cell_id_nrtdd_2}
    config 3 normalcell to 1supercell and attach to subcell1    ul_list=${NR_cell_id_nrtdd_1}    dl_list=${NR_cell_id_nrtdd_1}
    config 1 supercell to 3 normalcell and attach to cell3    ul_list=${NR_cell_id_nrtdd_3}    dl_list=${NR_cell_id_nrtdd_3}

    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_A_09_25R1_N_CB011092_1_full_6_cells_up_to_100M_4T4R_online_addcell_deletecell
    [Tags]    TRUNK
    [Setup]    Case Setup
    remove 3 normalcell and attach to other cell
    Add 3 normalcell and attach cell one by one
    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_A_08_25R1_N_CB011092_1_full_6_cells_up_to_100M_4T4R_RU_power_off_on
    [Tags]    TRUNK
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=4590
    All normal cell config to 60m and power reset site
    attach to cell4    if_peak=${True}
    AlarmWatchdog.remove_allow_alarms    fault_id=4590
    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_A_07_25R1_N_CB011092_1_full_8_cells_up_to_100M_2T4R_site_reset
    [Tags]    TRUNK
    [Setup]    Case Setup
    config full 8 cell
    block cell and attach    attach_cell_id=${1}    attach_list=${NR_cell_id_nrtdd_1}    block_cell_list=${block_cell_list_1}
    block cell and attach    attach_cell_id=${4}    attach_list=${NR_cell_id_nrtdd_4}    block_cell_list=${block_cell_list_1}
    Reset BTS And Wait Until On Air
    block cell and attach    attach_cell_id=${2}    attach_list=${NR_cell_id_nrtdd_2}    block_cell_list=${block_cell_list_1}
    block cell and attach    attach_cell_id=${5}    attach_list=${NR_cell_id_nrtdd_5}    block_cell_list=${block_cell_list_1}
    [Teardown]     Case Teardown1    if_activate_scf=${True}

[1]CB011092_A_06_25R1_N_CB011092_7_full_8_cells_up_to_100M_4T4R_RU_lock_unlock
    [Tags]    TRUNK
    [Setup]    Case Setup
    A_05_config full 8 cell
    @{lock_ru_id_list}    create list    ${1}    ${3}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
    Check the GNB on air
    ###check alarm###
    block cell and attach    attach_cell_id=${1}    attach_list=${NR_cell_id_nrtdd_1}    block_cell_list=${block_cell_list_2}
    block cell and attach    attach_cell_id=${3}    attach_list=${NR_cell_id_nrtdd_3}    block_cell_list=${block_cell_list_2}

    [Teardown]    Case Teardown1    if_activate_scf=${True}

[1]CB011092_A_02_25R1_N_CB011092_3_half_4_cells_up_to_100M_2T2R
    [Tags]    TRUNK
    [Setup]    Case Setup
    Remove 2NRCELL and config 4NRCELL to 2T2R
    Modify Parameter And Check BTS Status    input_list=${para_smodtype}
    block all cell and unblock
    [Teardown]    Case Teardown1    if_activate_scf=${True}

[1]CB011092_A_05_25R1_N_CB011092_3_full_4_cells_up_to_100M_2T2R_cell_block_unblock
    [Tags]    TRUNK
    [Setup]    Case Setup
    Should Be Equal As Strings   ${PREV_TEST_STATUS}   PASS
    [Teardown]    Case Teardown1    if_activate_scf=${False}
