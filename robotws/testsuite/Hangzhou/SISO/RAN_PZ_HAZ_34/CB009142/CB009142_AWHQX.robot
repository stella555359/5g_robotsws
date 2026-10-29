*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009142

Resource    ./Resources/CB009142_common_keyword.robot
Library     ./Resources/CB009142_common_keywords.py
Variables   ./Resources/CB009142_modify_para.py


Suite Setup       CB009142 Suite Setup
Suite Teardown    CB009142 Suite Teardown


*** Test Cases ***
[1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]    Case setup
    configuration 1super6sub to 6nom
    configuration 6nom to 1super6sub
    @{lock_ru_id_list1}    create list    ${11}    ${12}    ${13}    ${15}    ${16}
    @{unlock_ru_id_list1}    create list    ${14}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}    unlock_RU_id_list=${unlock_ru_id_list1}    lock_flag=${True}
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}    lock_flag=${False}
    @{lock_ru_id_list2}    create list    ${11}    ${13}    ${14}    ${15}    ${16}
    @{unlock_ru_id_list2}    create list    ${12}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list2}    unlock_RU_id_list=${unlock_ru_id_list2}    lock_flag=${True}
    Xiaomi Start Traffic and Check TP    ue_index=${3}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[0:1]}
    ...    target_avg_percent=0.2
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list2}    lock_flag=${False}
    Reset site
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]   Run Keyword And Ignore Error    Case Teardown1

[1][1.0] General_SiSo_SuperCell_activation_deactivation
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=7316
     Log To Console    [1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Teardown]  Run Keyword And Ignore Error    Case Teardown1

[1]CB009487-C-B1-002_reset_site_by_WEBEM_with_L3_call
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]  robot_common_operations.Common case Setup
    Log To Console    [1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Teardown]   Run Keyword And Ignore Error    Case Teardown1

[1][1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=7316
    configuration 1super6sub to 3super6sub    physCellId_list=${physCellId_list1[1:3]}    add_object_cell_num=${2}    start_cell_id=${12}
    Check Cells info    expect_cell_info=${supercell_for_3super6sub}
    Power Off BTS And Wait Until On Air
    Adjust Single RU PA    port=${2}    single_ru_PA=${0}    mutil_ru_PA=${127}
    Configure 2+2+2 Three UE Start Traffic
    [Teardown]   Run Keyword And Ignore Error    Case Teardown1

[1][3.0] General_SiSo_Pre_Cabling_configuration
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=7316
     Log To Console    [1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Teardown]  Run Keyword And Ignore Error    Case Teardown1
#    [Setup]    robot_common_operations.Common case Setup
#    Case setup    flag=super
#    @{lock_ru_id_list1}    create list    ${1}    ${2}    ${3}    ${5}    ${6}
#    @{unlock_ru_id_list1}    create list    ${4}
#    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}    unlock_RU_id_list=${unlock_ru_id_list1}    lock_flag=${True}
##    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${super_cell_list[0:1]}
##    ...    target_avg_percent=0.6
#    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}    lock_flag=${False}
#
#    @{lock_ru_id_list2}    create list    ${1}    ${3}    ${4}    ${5}    ${6}
#    @{unlock_ru_id_list2}    create list    ${2}
#    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list2}    unlock_RU_id_list=${unlock_ru_id_list2}    lock_flag=${True}
#    Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[0:1]}
#    ...    target_avg_percent=0.2
#    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list2}    lock_flag=${False}
#    [Teardown]   Run Keyword And Ignore Error    Case Teardown1

[2][1.0] General_SiSo_Auto_Cell_block_and_unblock_with_L3call
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=7316
     Log To Console    [1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Teardown]    Run Keyword And Ignore Error    Case Teardown1
#    [Setup]  robot_common_operations.Common case Setup
#    Case setup    flag=super
##    configuration 1super6sub to 3super6sub    physCellId_list=${physCellId_list1[0:1]}    add_object_cell_num=${1}    start_cell_id=${2}
##    Check Cells info    expect_cell_info=${supercell_for_2super6sub}
##    BLock or UnBlock Cell And Check Status    block_cell_id=${1}    unblock_cell_id=${2}    block_flag=${True}
##    Xiaomi Start Traffic and Check TP    ue_index=${1}    ul_throughput=200    dl_throughput=1500    cells=${super_cell_list[1:2]}
##    ...    target_avg_percent=0.6
##    BLock or UnBlock Cell And Check Status    unblock_cell_id=${1}    block_flag=${False}
#
##    Adjust Single RU PA    port=${0}
##    BLock or UnBlock Cell And Check Status    block_cell_id=${2}    unblock_cell_id=${1}    block_flag=${True}
##   Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[0:1]}
##    ...    target_avg_percent=0.2
##    BLock or UnBlock Cell And Check Status    unblock_cell_id=${2}    block_flag=${False}
#    [Teardown]  Run Keyword And Ignore Error    Case Teardown1



[1][1.0] General_SiSo_SuperCell_Reconfiguration
    [Tags]  CRT_23R4    CRT_24R1    CRT_TRUNK
    [Setup]    robot_common_operations.Common case Setup    allowed_faults_ids=7316
     Log To Console    [1][2.0] General_SiSo_Auto_RF_lock_unlock_with_L3call
    [Teardown]  Run Keyword And Ignore Error    Case Teardown1
#    [Setup]  robot_common_operations.Common case Setup
#    Case setup    flag=normal
##   configuration normal to 1super3sub
##    Check Cells info    expect_cell_info=${supercell_for_1super3sub}
##   Samsung UE Start Traffic and Check TP
##    configuration 1super3sub to 1super6sub
##    Check Cells info    expect_cell_info=${supercell_for_1super6sub}
##    Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${super_cell_list[0:1]}
##    ...    target_avg_percent=0.2
##   configuration 1super6sub to 3super6sub    physCellId_list=${physCellId_list1}    add_object_cell_num=${2}    start_cell_id=${2}
##   Check Cells info    expect_cell_info=${supercell_for_3super6sub}
##    Adjust Single RU PA    port=${3}    single_ru_PA=${0}    mutil_ru_PA=${127}
##   Configure 2+2+2 Three UE Start Traffic
#    [Teardown]    Run Keyword And Ignore Error    Case Teardown1

