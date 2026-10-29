*** Settings ***
Documentation
...    author: Na Li
...    contact: na.li@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB010588


Suite Setup       CB0010588 Suite Setup
Suite Teardown    Run keyword and ignore error    CB0010588 Suite Teardown


Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010588/Resources/CB010588_common_keyword.robot
Library     ./Resources/CB010588_common_keywords.py


*** Test Cases ***
##4nom-8nom
CB010588-A-SISO-05_Full_ABIQ_reset_RU
    [Tags]  CRT_24R1    CRT_TRUNK
    [Setup]    Case setup
    configuration 4nom to 8nom
    sleep    120s
    Attach And Check Throughput    block_cell_list=${cell_id_list_8cc[1:8]}
    UnBlock mutil Cell    unblock_cell_list=${cell_id_list_8cc[1:8]}    block_flag=${false}
    Reset MUtiRF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
#    Attach And Check Throughput    block_cell_list=${cell_id_list_8cc[0:7]}    unblock_cell_id=${12}
#    ...    cells=${cell_list_8CC[7:8]}
    [Teardown]    Run Keyword And Ignore Error    Case Teardown


##4nom-super1(2sub)-super1(2sub)+super2(2sub)-no nom
CB010588-C-SISO-02_Full_ABIP_supercell_Reconfiguration_from_3_to_6_with_L3call
    [Tags]    CRT_24R1    CRT_TRUNK
    [Setup]  Case setup
    configuration 4nom to 1super2sub
    sleep    120s
    Attach MTK90 power UE and check throughput    ue_index=${0}    ul_throughput=${200}
    ...    dl_throughput=${1500}    cells=${cell_list_8CC[0:1]}
    configuration 1super2sub to 2super2sub
    BLock or UnBlock Cell And Check Status    block_cell_id=${cell_id_list_4CC}[0]    unblock_cell_id=${cell_id_list_4CC}[2]    block_flag=${True}
    Attach MTK90 power UE and check throughput    ue_index=${0}    ul_throughput=${200}
    ...    dl_throughput=${1500}    cells=${cell_list_8CC[4:5]}
    [Teardown]    Run Keyword And Ignore Error    Case Teardown


#CB010588-C-SISO-04_Full_ABIP_supercell_reconfiguration_from_6_to_2_with_L3call
#    [Tags]  CRT_24R1    CRT_TRUNK
#    [Setup]    Case setup
#    configuration 4nom to 1super4sub
#    Attach xiaomi power UE and check throughput    ue_index=${0}    ul_throughput=${200}
#    ...    dl_throughput=${1500}    cells=${cell_list_8CC[0:1]}
#    configuration 1super4sub to 1super2sub
#    Attach xiaomi power UE and check throughput    ue_index=${0}    ul_throughput=${200}
#    ...    dl_throughput=${1500}    cells=${cell_list_8CC[0:1]}
#    [Teardown]  Run Keyword And Ignore Error    Case Teardown
#
#
#CB010588-C-SISO-06_Full_ABIP_supercell_lock_unlock_with_L3call
#    [Tags]  CRT_24R1    CRT_TRUNK
#    [Setup]    Case setup
#    configuration 4nom to 2super2sub
#    Lock or Unlock RU And Check Status    lock_RU_id_list=${RU_Id_list[0:4]}   lock_flag=${True}
#    Lock or Unlock RU And Check Status    unlock_RU_id_list=${RU_Id_list[0:4]}   lock_flag=${false}
#    BLock or UnBlock Cell And Check Status    block_cell_id=${cell_id_list_4CC}[0]    unblock_cell_id=${cell_id_list_4CC}[2]    block_flag=${True}
#    Attach xiaomi power UE and check throughput    ue_index=${0}    ul_throughput=${200}
#    ...    dl_throughput=${1500}    cells=${cell_list_8CC[4:5]}
#    [Teardown]  Run Keyword And Ignore Error    Case Teardown
