# *** Settings ***
# Force Tags    PY36
# Documentation     author: jiang johnny
# ...               contact: johnny.1.jiang@nokia-sbell.com
# ...               squad group: SG_07
# ...               feature : CB008847
# 
# Resource     Resources/CB008847_common_keyword.robot
# Variables    Resources/variables.py
# 
# Suite Setup    Common Suite Setup for COAM for ABIN     swconfig_flag=${True}
# Suite Teardown   run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections
# ...   AND    robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]CB008847_G_05_C_3_1_01_update_resource_by_DU_when_add_3rd_cell_for_ABIN_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup for ABIN
#      #step1 env setup
#      Modify Venfor file for ABIN   cellnum=2
#      #step2 add cell3-4 online and no cell degrade
#      COAM WEBUI Login
#      Add Cells   index=${3}
#      Add Cell Groups   index=${3}
#      selenium_coam.validate_plan
#      COAM WEBUI Whether Close Start Up View Window
#      selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#      COAM Check Cell Status
#      COAM Check Cell Status   cell_index=1
#      Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
#      COAM WEBUI Logout
#      #syslog start
#      Syslog Capture Start
#      #step3 Honor30s attach to cell2 then detach
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
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
#      ${NRuser}   Print BTSlog   message_name=Pool: 40${comma} ${nameOfpool}AreaCapacityPool: 37
#      ${pcsi}   Print BTSlog   message_name=Pool: 320${comma} ${nameOfpool}AreaCapacityPool: 314
#      ${SR}   Print BTSlog   message_name=Pool: 160${comma} ${nameOfpool}AreaCapacityPool: 148
#      ${DRB}   Print BTSlog   message_name=Pool: 80${comma} ${nameOfpool}AreaCapacityPool: 74
# 
#      Should Contain    ${NRuser}   occupiedCapacityPool: 3
#      Should Contain    ${pcsi}   occupiedCapacityPool: 6
#      Should Contain    ${SR}   occupiedCapacityPool: 12
#      Should Contain    ${DRB}   occupiedCapacityPool: 6
# 
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 1
#      Should Contain    ${pcsi}   guaranteedCapacityCell: 2
#      Should Contain    ${SR}   guaranteedCapacityCell: 4
#      Should Contain    ${DRB}   guaranteedCapacityCell: 2
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ABIN
# 
# [1]CB008847_G_06_C_3_4_01_update_resource_by_DU_when_maxNumOfUsersNRCell_mod_for_conA_for_ABIN_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup for ABIN
#      #step1 env setup
#      Modify Venfor file for ABIN
#      #step2 change para online and no cell degrade
# #     Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_G_341}
#      Run keyword if   '${gnb_release}'=='SBTS23R1' or '${gnb_release}'=='SBTS23R2' or '${gnb_release}'=='SBTS23R3'
#      ...   Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_G_341_X}
#      ...   ELSE    Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_G_341}
#      COAM Check All Cells Onair
#      #syslog start
#      Syslog Capture Start
#      #step3 Honor30s attach to cell2 then detach
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
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
#      ${NRuser}   Print BTSlog   message_name=Pool: 40${comma} ${nameOfpool}AreaCapacityPool: 39
#      ${pcsi}   Print BTSlog   message_name=Pool: 320${comma} ${nameOfpool}AreaCapacityPool: 318
#      ${SR}   Print BTSlog   message_name=Pool: 160${comma} ${nameOfpool}AreaCapacityPool: 156
#      ${DRB}   Print BTSlog   message_name=Pool: 80${comma} ${nameOfpool}AreaCapacityPool: 78
# 
#      Should Contain    ${NRuser}   occupiedCapacityPool: 4
#      Should Contain    ${pcsi}   occupiedCapacityPool: 8
#      Should Contain    ${SR}   occupiedCapacityPool: 16
#      Should Contain    ${DRB}   occupiedCapacityPool: 7
# 
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 2
#      Should Contain    ${pcsi}   guaranteedCapacityCell: 4
#      Should Contain    ${SR}   guaranteedCapacityCell: 8
#      Should Contain    ${DRB}   guaranteedCapacityCell: 3
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ABIN
# 
# [1]CB008847_G_ABIN_TDD
#     [Tags]    CRT_TRUNK    CRT_23R1
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1]CB008847_ABC_ABIO_TDD
#     [Tags]    CRT_TRUNK    CRT_23R1
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# [1]CB008847_FJK_ABIO_TDD
#     [Tags]    CRT_TRUNK    CRT_23R1
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# *** Keywords ***
