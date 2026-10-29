*** Settings ***
Documentation
...    author: xiaofeng Zhu
...    contact: xiaofeng.1.zhu@nokia-sbell.com
...    squad group: VRF3_SG04
...    feature : CB011088


Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011088_G/Resources/CB011088_TL715_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011088_G/Resources/Modify_SCF.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011088_G/Resources/CB011088_TL715_common_keywords.py
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB011088_G/Resources/CB011088_TL715_modify_para.py


Suite Setup      CB011088 Suite Setup
Suite Teardown

*** Test Cases ***
[1]CB011088-F-rrm-01_full_ASOG_1supercell_4subcell_1supercell_2subcell_VONR
    [Tags]  CIT_TRUNK
    [Setup]    Case Setup
    Modify Parameter And Check BTS Status    input_list=${para_NRREL1}
    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:4]}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[4]    LCELNR__COPY_ID_2=${cell_id_list_6CC[5:6]}    if_supercell_2=${True}
    ...    node_index_1=${3}    node_index_2=${5}

    @{lock_ru_id_list1}    create list    ${1}    ${2}    ${3}    ${5}    ${6}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    ${dl_cell_list}    create list    1
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM_1    dl_cell_list=${dl_cell_list}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=1500   ul_list=${NR_cell_id_list_nrtdd_1}
    ...    dl_list=${NR_cell_id_list_nrtdd_1}    ue_index=${0}    log_time=300s
    ...    VONR_CALL=${True}    if_peak=${True}    expect_ul_tp=${expect_ul_tp}
    ...    expect_dl_tp=${expect_dl_tp}    ignore_time=60s    process_num=${10}

    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}    lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485

    [Teardown]     Case Teardown    if_activate_scf=${True}

[1]CB011088-E-rrm-01_2supercell_with_3subcells_CA
    [Tags]  CIT_TRUNK
    [Setup]    Case Setup

    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:3]}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[3]    LCELNR__COPY_ID_2=${cell_id_list_6CC[4:6]}    if_supercell_2=${True}
    ...    node_index_1=${2}    node_index_2=${5}

    configuration 2 supercell CA    gnb_para=${gnb_para1}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_CA_NRTDD}
    ...    dl_list=${NR_cell_id_list_CA_NRTDD}    ue_index=${0}    target_avg_percent=0.2    log_time=60s

    [Teardown]   Case Teardown    if_activate_scf=${True}

