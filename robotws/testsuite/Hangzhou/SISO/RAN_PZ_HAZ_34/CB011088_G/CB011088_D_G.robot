*** Settings ***
Documentation
...    author: xiaofeng Zhu
...    contact: xiaofeng.1.zhu@nokia-sbell.com
...    squad group: VRF3_SG04
...    feature : CB011088


Resource    ./Resources/CB011088_TL715_common_keywords.robot
Resource    ./Resources/Modify_SCF.robot
Library     ./Resources/CB011088_TL715_common_keywords.py
Variables   ./Resources/CB011088_TL715_modify_para.py


Suite Setup      CB011088 Suite Setup
Suite Teardown

*** Test Cases ***
[1]CB011088-F-siso-04-full-ASOG_3supercell_2subcells_add_RF_Plug_out_in
    [Tags]  CIT_TRUNK
    [Setup]    Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=10
    Modify Parameter And Check BTS Status    input_list=${para_NRREL}
    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:2]}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[2]    LCELNR__COPY_ID_2=${cell_id_list_6CC[3:4]}    if_supercell_2=${True}
    ...    LCELNR_ID_3=${cell_id_list_6CC}[4]    LCELNR__COPY_ID_3=${cell_id_list_6CC[5:6]}    if_supercell_3=${True}
    ...    node_index_1=${1}    node_index_2=${3}    node_index_3=${5}

    attach to supercell one by one
    RU5 and RU6 plug out or plug in    port_list=${gnb_para1_lock}    locked=True    check=True
    attach to supercell1 and supercell2
    RU5 and RU6 plug out or plug in    port_list=${gnb_para1_unlock}    locked=False    check=False
    AlarmWatchdog.remove_allow_alarms    fault_id=10
    attach to supercell3
    [Teardown]     Case Teardown    if_activate_scf=${True}

[1]CB011088-E-siso-02_2BB_cell_set_ASOG_1supercell_2_subcell_reconfiguation_2supercell_3+3_subcell
    [Tags]  CIT_TRUNK
    [Setup]    Case Setup

    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:2]}
    ...    if_supercell_2=${False}    if_supercell_3=${False}    node_index_1=${1}

    @{LCELNR__COPY_ID_1}    create list    ${3}
    @{LCELNR__COPY_ID_2}    create list    ${5}    ${0}
    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${LCELNR__COPY_ID_1}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[3]    LCELNR__COPY_ID_2=${LCELNR__COPY_ID_2}    if_supercell_2=${True}
    ...    if_supercell_3=${False}     node_index_1=${1}    node_index_2=${4}    start_id_1=${3}

    lock RU and attach to supercell    RU_index1=${2}    RU_index2=${3}    block_cellid=${4}
    ...    NR_cell_id_list=${NR_cell_id_list_nrtdd_1}
    lock RU and attach to supercell    RU_index1=${1}    RU_index2=${2}    block_cellid=${4}
    ...    NR_cell_id_list=${NR_cell_id_list_nrtdd_1}

    lock RU and attach to supercell    RU_index1=${5}    RU_index2=${6}    block_cellid=${1}
    ...    NR_cell_id_list=${NR_cell_id_list_nrtdd_4}
    lock RU and attach to supercell    RU_index1=${4}    RU_index2=${5}    block_cellid=${1}
    ...    NR_cell_id_list=${NR_cell_id_list_nrtdd_4}
    [Teardown]     Case Teardown    if_activate_scf=${True}
