# *** Settings ***
# Documentation     author: jiang johnny
# ...               contact: johnny.1.jiang@nokia-sbell.com
# ...               squad group: SG_07
# ...               feature : CB008847
# 
# Resource     Resources/CB008847_common_keyword.robot
# Variables    Resources/variables.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Common Suite Setup for COAM for ABIP     swconfig_flag=${True}
# Suite Teardown   run keywords    robot_common_operations.Common Suite Teardown
# ...   AND    Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]CB008847_C_3_1_01_update_resource_by_DU_when_add_3rd_cell_for_ABIP_TDD
#      [Tags]    CRT_TRUNK    CRT_23R3
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup for ABIP
#      #step1 env setup
#      Modify Venfor file for ABIP   cellnum=2
#      #step2 delete cell2 then add cell2 online and cell1 not degrade
#      Remove Cell 2
#      Recovery Cell for multiBB   index=${2}
#      #syslog start
#      Syslog Capture Start
#      #step3 Honor30s attach to cell1 then detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE attach   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${0}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step4 check reource
#      #two cell per pool
# #     ${NRuser}   Print BTSlog   message_name=Pool: 40${comma} avalibleAreaCapacityPool: 38
# #     ${pcsi}   Print BTSlog   message_name=Pool: 320${comma} avalibleAreaCapacityPool: 316
# #     ${SR}   Print BTSlog   message_name=Pool: 160${comma} avalibleAreaCapacityPool: 152
# #     ${DRB}   Print BTSlog   message_name=Pool: 80${comma} avalibleAreaCapacityPool: 76
# #
# #     Should Contain    ${NRuser}   occupiedCapacityPool: 2
# #     Should Contain    ${pcsi}   occupiedCapacityPool: 4
# #     Should Contain    ${SR}   occupiedCapacityPool: 8
# #     Should Contain    ${DRB}   occupiedCapacityPool: 4
# #
# #     Should Contain    ${NRuser}   guaranteedCapacityCell: 1
# #     Should Contain    ${pcsi}   guaranteedCapacityCell: 2
# #     Should Contain    ${SR}   guaranteedCapacityCell: 4
# #     Should Contain    ${DRB}   guaranteedCapacityCell: 2
# 
#      #one cell per pool
#      ${NRuser}   Print BTSlog   message_name=Pool: 40${comma} avalibleAreaCapacityPool: 39
#      ${pcsi}   Print BTSlog   message_name=Pool: 320${comma} avalibleAreaCapacityPool: 318
#      ${SR}   Print BTSlog   message_name=Pool: 160${comma} avalibleAreaCapacityPool: 156
#      ${DRB}   Print BTSlog   message_name=Pool: 80${comma} avalibleAreaCapacityPool: 78
# 
#      Should Contain    ${NRuser}   occupiedCapacityPool: 1
#      Should Contain    ${pcsi}   occupiedCapacityPool: 2
#      Should Contain    ${SR}   occupiedCapacityPool: 4
#      Should Contain    ${DRB}   occupiedCapacityPool: 2
# 
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 1
#      Should Contain    ${pcsi}   guaranteedCapacityCell: 2
#      Should Contain    ${SR}   guaranteedCapacityCell: 4
#      Should Contain    ${DRB}   guaranteedCapacityCell: 2
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ABIP
# 
# [1]CB009028_CB008847_ABIP_CRT
#     [Tags]    CRT_TRUNK    CRT_23R3
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
# 
# *** Keywords ***
