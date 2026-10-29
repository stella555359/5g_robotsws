# *** Settings ***
# Documentation     author: Wang Lei
# ...               contact: lei.24.wang@nokia-sbell.com
# ...               squad group: SG_07
# ...               feature : CB009469 CB009799 CB009800 CB009801
# 
# Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009000/Resources/CB009000_common_keyword.robot
# Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009000/Resources/sherpa_common.robot
# Variables    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB009000/Resources/variables.py
# 
# 
# Suite Setup    Common Suite Setup for COAM for ASOF TDD
# Suite Teardown   COAM Suite Teardown for COAM for ASOF TDD
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# ${NEW_Askey_NRcall}   Yes
# ${AT_script_path}    C:tool
# ${COM_port}   6
# 
# 
# *** Test Cases ***
# [1]CB009799_CB008847_7114_DL_Sche_UE_per_slot_check_when_limited_L1pool_resource_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for CB007114
# 
#      #env setup
#      #cell1/cell2 on same L1Pool ; gua ScheUePdsch for cell1/2 = 1 ; share ScheUePdsch for L1Pool = 3-1-1 = 1
#      #before cell2 locked, 1(cell1 gua)+1(share)=2 UE per slot can be scheduled in cell1, 1(cell2 gua) cannot used by cell1
#      #after cell2 locked, 1(cell1 gua)+2(share)=3 UE per slot can be scheduled in cell1, 1(cell2 gua) switch to "shared"
#      #<p name="maxNumScheUePdschL1Pool">3</p> in vendor
#      Modify 2426 and 7114 Venfor for ASOF TDD    UePdschL1Pool=3
# 
# #Test1 : cell "1"/"2" onair, "3" UE on cell "1" with "dl", "maxNumPdschPerSlot" max <=2 avg >1.8 for cell "1"
#      #ue_index=${0}/${1}/${2} attach on cell "1" and start full buffer "dl" tput
#      Multi-UE L3CALL Start for CB007114    ue_list=${LIST_CB007114_UE}    direction=DL
# 
#      #start sherpa
#      Sherpa log Start Collect
# 
#      sleep    5s
# 
#      #stop sherpa
#      Sherpa log Stop Collect and Convert CSV
# 
#       #check maxNumPdschPerSlot in Sherpa_l1l2Trace.csv
#      #input for keywords: ${direction}=dl ${Global cell ID}=1 ${filter}=maxNumPdschPerSlot ${max}=2 ${avg}=1.8
#      Check L1L2 value from Sherpa Log    direction=DL   globlecellid=1   filter=maxNumPdschPerSlot
#      ...    max_value=2   ave_value=1.8
# 
#      #ue_index=${0}/${1}/${2} stop iperf dl stream on FTP server
#      Multi-UE L3CALL Stop traffic for CB007114    ue_list=${LIST_CB007114_UE}    direction=DL
# 
#      #ue_index=${0}/${1}/${2} detach
#      Multi-UE L3CALL Detach for CB007114    ue_list=${LIST_CB007114_UE}
# 
#      LOG to console    \n | Test1 passed! \n
# 
# 
# #Test2 : cell "1" onair, cell "2" locked, "3" UE on cell "1" with "dl", "maxNumPdschPerSlot" max <=3 avg >2.99 for cell "1"
#      #lock cell "2"
#      ADMIN Block NR cell and check status    cell_index=2
# 
#      #ue_index=${0}/${1}/${2} attach on cell "1" and start full buffer "dl" tput
#      Multi-UE L3CALL Start for CB007114    ue_list=${LIST_CB007114_UE}     direction=DL
# 
#      #start sherpa
#      Sherpa log Start Collect
# 
#      sleep    5s
# 
#      #stop sherpa
#      Sherpa log Stop Collect and Convert CSV
# 
#      #ue_index=${0}/${1}/${2} stop iperf dl stream on FTP server
#      Multi-UE L3CALL Stop traffic for CB007114    ue_list=${LIST_CB007114_UE}    direction=DL
# 
#      #ue_index=${0}/${1}/${2} detach
#      Multi-UE L3CALL Detach for CB007114    ue_list=${LIST_CB007114_UE}
# 
#      #unlock cell "2"
#      ADMIN UnBlock NR cell and check status    cell_index=2
# 
#      #check maxNumPdschPerSlot in Sherpa_l1l2Trace.csv
#      #input for keywords: ${direction}=dl ${Global cell ID}=1 ${filter}=maxNumPdschPerSlot ${max}=3 ${avg}=2.99
#      Check L1L2 value from Sherpa Log    direction=DL   globlecellid=1   filter=maxNumPdschPerSlot
#      ...    max_value=3   ave_value=2.99
# 
#      LOG to console    \n | Test2 passed! \n
# 
#      [Teardown]    Case Teardown for CB007114
# 
# [1]CB009799_CB008847_7114_UL_Sche_UE_per_slot_check_when_limited_L1subpool_resource_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for CB007114
# 
#      #env setup
#      #cell1/cell2 on different L1subpool ; gua ScheUePusch for cell1 = 1 ; share ScheUePusch for L1subpool = 2-1 = 1
#      #before cell2 locked, 1(cell1 gua)+1(share)=2 UE per slot can be scheduled in cell1
#      #after cell2 locked, 1(cell1 gua)+1(share)=2 UE per slot can be scheduled in cell1
#      #<p name="maxNumScheUePuschL1Sp">2</p> in vendor
#      Modify 2426 and 7114 Venfor for ASOF TDD    UePuschL1Sp=2
# 
# #Test1 : cell "1"/"2" onair, "3" UE on cell "1" with "ul", "maxNumPuschPerSlot" max <=2 avg >1.99 for cell "1"
#      #ue_index=${0}/${1}/${2} attach on cell "1" and start full buffer "ul" tput
#      Multi-UE L3CALL Start for CB007114    ue_list=${LIST_CB007114_UE}    direction=UL
# 
#      #start sherpa
#      Sherpa log Start Collect
# 
#      sleep    5s
# 
#      #stop sherpa
#      Sherpa log Stop Collect and Convert CSV
# 
#      #ue_index=${0}/${1}/${2} stop iperf ul stream on UE iperf
#      Multi-UE L3CALL Stop traffic for CB007114    ue_list=${LIST_CB007114_UE}    direction=UL
# 
#      #ue_index=${0}/${1}/${2} detach
#      Multi-UE L3CALL Detach for CB007114    ue_list=${LIST_CB007114_UE}
# 
#      #check maxNumPuschPerSlot in Sherpa_l1l2Trace.csv
#      #input for keywords: ${direction}=ul ${Global cell ID}=1 ${filter}=maxNumPuschPerSlot ${max}=2 ${avg}=1.99
#      Check L1L2 value from Sherpa Log    direction=UL   globlecellid=1   filter=maxNumPuschPerSlot
#      ...    max_value=2   ave_value=1.99
# 
#      LOG to console    \n | Test1 passed! \n
# 
# #Test2 : cell "1" onair, cell "2" locked, "3" UE on cell "1" with "ul", "maxNumPuschPerSlot" max <=2 avg >1.99 for cell "1"
#      #lock cell "2"
#      ADMIN Block NR cell and check status    cell_index=2
# 
#      #ue_index=${0}/${1}/${2} attach on cell "1" and start full buffer "ul" tput
#      Multi-UE L3CALL Start for CB007114    ue_list=${LIST_CB007114_UE}    direction=UL
# 
#      #start sherpa
#      Sherpa log Start Collect
# 
#      sleep    5s
# 
#      #stop sherpa
#      Sherpa log Stop Collect and Convert CSV
# 
#      #ue_index=${0}/${1}/${2} stop iperf ul stream on UE iperf
#      Multi-UE L3CALL Stop traffic for CB007114    ue_list=${LIST_CB007114_UE}    direction=UL
# 
#      #ue_index=${0}/${1}/${2} detach
#      Multi-UE L3CALL Detach for CB007114    ue_list=${LIST_CB007114_UE}
# 
#      #unlock cell "2"
#      ADMIN UnBlock NR cell and check status    cell_index=2
# 
#      #check maxNumPuschPerSlot in Sherpa_l1l2Trace.csv
#      #input for keywords: ${direction}=ul ${Global cell ID}=1 ${filter}=maxNumPuschPerSlot ${max}=2 ${avg}=1.99
#      Check L1L2 value from Sherpa Log    direction=UL   globlecellid=1   filter=maxNumPuschPerSlot
#      ...    max_value=2   ave_value=1.99
# 
#      LOG to console    \n | Test2 passed! \n
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown for CB007114
# 
# [1]CB009469_DL_UL_PEAK_with_1116_subframe_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for ASOF TDD
#      Use Default Vendor for ASOF TDD
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
# 
#      #1116_0_A2
#      NEW Modify parameter with admin API    parameters=${PARAMS_TO_MODIFY_1116_0_A2}
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      Set L3 CALL param CB009469    runame=AWHHF    framestruct=1116_0_A2
#      PEAK L3 CALL Process CB009469
# 
#      #1116_0_C2
#      NEW Modify parameter with admin API    parameters=${PARAMS_TO_MODIFY_1116_0_C2}
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      Set L3 CALL param CB009469    runame=AWHHF    framestruct=1116_0_C2
#      PEAK L3 CALL Process CB009469
# 
#      #1116_0_B4
#      NEW Modify parameter with admin API    parameters=${PARAMS_TO_MODIFY_1116_0_B4}
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      Set L3 CALL param CB009469    runame=AWHHF    framestruct=1116_0_B4
#      PEAK L3 CALL Process CB009469
# 
#      #1116_0_0
#      NEW Modify parameter with admin API    parameters=${PARAMS_TO_MODIFY_1116_0_0}
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      Set L3 CALL param CB009469    runame=AWHHF    framestruct=1116_0_0
#      PEAK L3 CALL Process CB009469
# 
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF TDD
# 
# [1]CB009469_DL_UL_PEAK_with_1208_subframe_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for ASOF TDD
#      Use Default Vendor for ASOF TDD
# 
#      #1208
#      NEW Modify parameter with admin API    parameters=${PARAMS_TO_MODIFY_1208}
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Set L3 CALL param CB009469    runame=AWHHF    framestruct=1208
#      PEAK L3 CALL Process CB009469
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
# 
#      #1070
#      NEW Modify parameter with admin API    parameters=${PARAMS_TO_MODIFY_1070}
#      Wait Until Keyword Succeeds   10m   30s   COAM Check All Cells Onair
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Set L3 CALL param CB009469    runame=AWHHF    framestruct=1070
#      PEAK L3 CALL Process CB009469
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF TDD
# 
# 
# [1]CB009799_CB008847_2426_7114_can_be_enabled_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for ASOF TDD
#      #syslog start
#      Syslog Capture Start
#      #env setup
#      Modify 2426 and 7114 Venfor for ASOF TDD
#      #Honor30s attach to cell1 then detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition   ue_type=huawei   ue_index=${0}
#      Power UE Precondition   ue_type=huawei   ue_index=${1}
#      Power UE Precondition   ue_type=huawei   ue_index=${2}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${1}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${2}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${1}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${2}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message0}   Print BTSlog    message_name=connRrcPoolingAllowed
#      ${message1}   Print BTSlog    message_name=scheUePoolingParameters
#      ${message2}   Print BTSlog    message_name=current number of NR Users
#      ${message3}   Print BTSlog    message_name=drb_count
#      #check 2426 7114
#      Should Contain    ${message0}   connRrcPoolingAllowed: boolean = true
#      Should Contain    ${message1}   scheUePoolingParameters: {"maxNumScheUePdschL1Sp"
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF TDD
# 
# [1]CB009799_CB008847_2426_resource_allocation_for_pool_emer_gua_and_share_part_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for ASOF TDD
#      #syslog start
#      Syslog Capture Start
#      #env setup
#      Modify 2426 and 7114 Venfor for ASOF TDD
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_2426_C311}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      #delete cell2 then add cell2 online and cell1 not degrade
#      Remove Cell 2
#      Recovery Cell for ASOF TDD   index=${2}
#      #Honor30s attach to cell1 then detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition   ue_type=huawei   ue_index=${0}
#      Power UE Precondition   ue_type=huawei   ue_index=${1}
#      Power UE Precondition   ue_type=huawei   ue_index=${2}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${1}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${2}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${1}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${2}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message0}   Print BTSlog    message_name=connRrcPoolingAllowed
#      ${message1}   Print BTSlog    message_name=scheUePoolingParameters
#      ${message2}   Print BTSlog    message_name=current number of NR Users
#      ${message3}   Print BTSlog    message_name=drb_count
#      #check reource for two cell per pool
#      ${NRuser}   Print BTSlog   message_name=Pool: 40${comma} avalibleAreaCapacityPool: 38
#      ${pcsi}   Print BTSlog   message_name=Pool: 320${comma} avalibleAreaCapacityPool: 318
#      ${SR}   Print BTSlog   message_name=Pool: 160${comma} avalibleAreaCapacityPool: 152
#      ${DRB}   Print BTSlog   message_name=Pool: 80${comma} avalibleAreaCapacityPool: 76
#      Should Contain    ${NRuser}   occupiedCapacityPool: 2
#      Should Contain    ${pcsi}   occupiedCapacityPool: 2
#      Should Contain    ${SR}   occupiedCapacityPool: 8
#      Should Contain    ${DRB}   occupiedCapacityPool: 4
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 1
#      Should Contain    ${pcsi}   guaranteedCapacityCell: 1
#      Should Contain    ${SR}   guaranteedCapacityCell: 4
#      Should Contain    ${DRB}   guaranteedCapacityCell: 2
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF TDD
# 
# [1]CB009799_CB008847_2426_hit_L1_pucch_cap_of_L1_pool_for_ASOF_TDD
#      [Tags]    CRT_TRUNK    CRT_24R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    Case Setup for ASOF TDD
#      #syslog start
#      Syslog Capture Start
#      #env setup
#      Modify 2426 and 7114 Venfor for ASOF TDD    F1SR=1
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_2426_A}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      #Honor30s 1 2 attach to cell1
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition   ue_type=huawei   ue_index=${0}
#      Power UE Precondition   ue_type=huawei   ue_index=${1}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${1}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      sleep    5s
#      #Honor30s 3 attach to cell1
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Power UE Precondition   ue_type=huawei   ue_index=${2}
#      Run keyword and ignore error   Power UE attach wo aasyslog   ue_type=huawei   ue_index=${2}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${0}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${1}
#      Run keyword and ignore error   Power UE detach   ue_type=huawei   ue_index=${2}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message0}   Print BTSlog    message_name=connRrcPoolingAllowed
#      ${message1}   Print BTSlog    message_name=scheUePoolingParameters
#      ${message2}   Print BTSlog    message_name=current number of NR Users
#      ${message3}   Print BTSlog    message_name=drb_count
#      #check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
#      #check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[7]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover for ASOF TDD
# 
# 
# [1]CB009XXX_ASOF_TDD_CRT
#     [Tags]    CRT_TRUNK    CRT_24R1
#     [Timeout]    60 min
#     [Setup]     robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# *** Keywords ***