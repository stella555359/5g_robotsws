# *** Settings ***
# Documentation
# ...    author: Jiang Hongyu
# ...    contact: hongyu.jiang@nokia-sbell.com
# ...    squad group: MMW_SG_04
# ...    feature : CB009102-SR-A
# 
# Resource    ./Resources/CB009826_common_keyword.robot
# 
# 
# Suite Setup       CB009826 Suit Setup
# Suite Teardown    robot_common_operations.Common Suite Teardown
# 
# 
# *** Test Cases ***
# [1]CB009826_SR_A_27_SW_upgrade_via_WebEM_SBTS1
#     [Tags]  CRT_24R2    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     Check GNB on air    BBMOD_list=${all_BBMOD}    check_BBMOD_status=${False}
#     Check Alarm List on BTS    bts_host=${gnb_ip}
#     [Teardown]  Case1 Teardown
# 
# [1]CB009826_SR_A_7_BTS_Power_Reset_on_secondary_SBTS2
#     [Tags]  CRT_24R2    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     Power Off Hardware    model=HBTE    PDU_IP=${Secondary_PDU_ip}    PDU_PORT=${Secondary_PDU_port}
#     sleep  2min
#     Power On Hardware     model=HBTE    PDU_IP=${Secondary_PDU_ip}    PDU_PORT=${Secondary_PDU_port}
#     Check GNB on air    BBMOD_list=${secondary_BBMOD}    check_BBMOD_status=${True}
#     Operate LTE Cell And Check status    operation=${False}    if_lock=${False}
#     Check Alarm List on BTS    bts_host=${gnb_ip}
#     Operate LTE Cell And Check status    operation=${True}    if_lock=${True}
#     Operate NR Cell And Check status    if_lock=${True}    cell_id_list=${NR_cell_list1}
#     UE Start Traffic And Check TP
#     [Teardown]  Case Teardown
# 
# [1]CB009826_SR_A_11_BTS_Site_Reset_SBTS1
#     [Tags]  CRT_24R2    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     FOR  ${i}  IN RANGE  ${3}
#         Reset Site And Waite Until on Air    bts_host=${gNB_ip}
#         Operate LTE Cell And Check status    operation=${False}    if_lock=${False}
#         sleep   1min
#     END
#     Operate LTE Cell And Check status    operation=${True}    if_lock=${True}
#     Operate NR Cell And Check status    if_lock=${True}    cell_id_list=${NR_cell_list1}
#     UE Start Traffic And Check TP
#     [Teardown]  Case Teardown
# 
# [1]CB009826_SR_A_17_Cell_Lock_Unlock_SBTS1
#     [Tags]  CRT_24R2    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     Lock And Unlock cellgroup multiple times    cellgroup_list=${cellgrp_list1}
#     Operate LTE Cell And Check status    operation=${True}    if_lock=${True}
#     Operate NR Cell And Check status    if_lock=${True}    cell_id_list=${NR_cell_list1}
#     UE Start Traffic And Check TP
#     [Teardown]  Case Teardown
# 
# [1]CB009826_SR_A_21_RF_lock_unlock_with_call_SBTS1
#     [Tags]  CRT_24R2    CRT_TRUNK
#     [Setup]  robot_common_operations.Common case Setup
#     Lock And Unlock RU multiple times    RU_id_list=${RU_id_list}
#     Operate LTE Cell And Check status    operation=${True}    if_lock=${True}
#     Operate NR Cell And Check status    if_lock=${True}    cell_id_list=${NR_cell_list1}
#     UE Start Traffic And Check TP
#     [Teardown]  Case Teardown
