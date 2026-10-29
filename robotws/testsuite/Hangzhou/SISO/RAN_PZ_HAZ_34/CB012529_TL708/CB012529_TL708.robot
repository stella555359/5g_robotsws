*** Settings ***
Documentation
...    author: Kaijia Chen
...    contact: kaijia.chen@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB012529

Resource    ./Resources/CB012529_common_keywords.robot

Suite Setup       CB012529 Suite Setup
Suite Teardown

*** Test Cases ***
[1]CB012529-SR-B_018_TDD_FDD_RAT_reset
    [Tags]  CRT_TRUNK
    [Setup]    CB012529 Case Setup    scf_name=_CB012529    if_activate_scf=${True}
    log to console    Start to reset NR RAT 5 times
    FOR    ${ID}    IN RANGE    0    5
        Reset RAT
    END
    block cell and start traffic    cell_list_1=${cell_list_1}    cell_list_2=${cell_list_2}    ue1_ul_tp=50    ue1_dl_tp=220
    ...    ue2_ul_tp=50    ue2_dl_tp=1000    target_avg_percent=0.3    min_percent=0.1    log_time=60s
    [Teardown]    CB012529 Case Teardown

[1]CB012529-SR-B_014_TDD_FDD_RU_lock_unlock_scenario
    [Tags]  CRT_TRUNK
    [Setup]    CB012529 Case Setup    scf_name=_CB012529    if_activate_scf=${True}
    Lock and Unlock TL708 ALL RU
    [Teardown]    CB012529 Case Teardown

[1]CB012529-SR-B_015_TDD_FDD_Cell_block_and_unblock_scenario
    [Tags]  CRT_TRUNK
    [Setup]    CB012529 Case Setup    scf_name=_CB012529    if_activate_scf=${True}
    bLock and Unblock TL708 ALL cell
    [Teardown]    CB012529 Case Teardown

[1]CB012529-SR-B_001_TDD_FDD_L3_call_on_all_cells_of_concurrent_mode_NRFDD_NRTDD_supercell
    [Tags]  CRT_TRUNK
    [Setup]    CB012529 Case Setup    scf_name=_CB012529    if_activate_scf=${True}
    block cell and start traffic    cell_list_1=${cell_list_1}    cell_list_2=${cell_list_2}
    [Teardown]    CB012529 Case Teardown

[1]CB012529-SR-B_003_TDD_FDD_L3_call_on_concurrent_mode_NRFDD_NRTDD_normal_cell_with_no_beamforming
    [Tags]  CRT_TRUNK
    [Setup]    CB012529 Case Setup    scf_name=_CB012529    if_activate_scf=${True}
    Config supercell to normal cell    add_object_cell_num=${2}    start_cell_id=${19}    NRCELLGRP_id=${17}    cell_id=17
    ...    copy_cell_id=${17}    node_index_Diff=${19}
    block cell and start traffic    cell_list_1=${cell_list_1}    cell_list_2=${cell_list_2}
    [Teardown]    CB012529 Case Teardown

