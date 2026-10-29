# *** Settings ***
# Force Tags    PY36
# Documentation     author: jiang johnny
# ...               contact: johnny.1.jiang@nokia-sbell.com
# ...               squad group: SG_07
# ...               feature : CB008847
# 
# Resource     Resources/CB008847_common_keyword.robot
# Variables    Resources/variables.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Common Suite Setup for COAM     swconfig_flag=${True}
# Suite Teardown   run keywords    Run Keyword And Ignore Error    COAM Teardown gnb connections
# ...   AND    robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]CB008847_F_1_4_01_hit_high_thres_of_sr_pool_when_ue_from_1_to_x_with_2271_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=2   cellnum=2
#      #step2 2271 para change
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_F_141}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      #syslog start
#      Syslog Capture Start
#      #step3 mtu 0-1 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach
#      MTU attach   first_ue_index=1
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step4 mtu 2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      MTU attach    first_ue_index=2
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step5 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 64 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step6-7 get ueid and check srperiodicity
#      ${UE_ID}   Get UE_ID in Wireshark   nglogname=asix.pcap
#      ${UE_ID2}   Get UE_ID in Wireshark   nglogname=asix2.pcap
#      ${periodicity_log1_UE1}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log1_UE2}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE1}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log2_UE2}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE3}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID2[0]}
# 
#      set suite variable    ${periodicity_log1_UE1}
#      set suite variable    ${periodicity_log1_UE2}
#      set suite variable    ${periodicity_log2_UE1}
#      set suite variable    ${periodicity_log2_UE2}
#      set suite variable    ${periodicity_log2_UE3}
# 
#      ${status}    run keyword and return status    F141 result1 check
#      run keyword unless    ${status}    F141 result2 check
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_F_1_4_03_hit_low_thres_of_sr_slot_when_ue_from_x_to_1_with_2271_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=2   cellnum=2
#      #step2 2271 para change
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_F_143}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      #syslog start
#      Syslog Capture Start
#      #step3 mtu 0-2 attach ok one by one
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach
#      MTU attach   first_ue_index=1
#      MTU attach   first_ue_index=2
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step4 mtu 2 detach then mtu 1 detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      MTU detach    first_ue_index=2
#      sleep   10s
#      MTU detach    first_ue_index=1
#      sleep   10s
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step5 mtu 0 detach
#      MTU detach
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 64 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step6-7 get ueid and check srperiodicity
#      ${UE_ID}   Get UE_ID in Wireshark   nglogname=asix.pcap
#      ${periodicity_log1_UE1}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log1_UE2}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log1_UE3}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[2]}
#      ${periodicity_log2_UE1}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log2_UE2}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[1]}
# 
#      set suite variable    ${periodicity_log1_UE1}
#      set suite variable    ${periodicity_log1_UE2}
#      set suite variable    ${periodicity_log1_UE3}
#      set suite variable    ${periodicity_log2_UE1}
#      set suite variable    ${periodicity_log2_UE2}
# 
#      ${status}    run keyword and return status    F143 result1 check
#      run keyword unless    ${status}    F143 result2 check
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_F_1_4_02_hit_high_thres_of_sr_slot_when_ue_from_1_to_x_with_2271_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=2   cellnum=2
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #step2 2271 para change
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_F_142}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Power UE attach
#      hold on an VONR
#      Stop the VONR call
#      Power UE detach
#      #syslog start
#      Syslog Capture Start
#      #step3 mtu 0 attach ok and xiaomi 1 attach to cell1 ok then start vonr ok
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach
#      Power UE attach
#      hold on an VONR
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step4 mtu 1 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      MTU attach   first_ue_index=1
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step5 xiaomi 1 hangup and detach and mtu 0-1 detach
#      Stop the VONR call
#      Power UE detach
#      MTU detach   ue_num=2
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 64 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step6-7 get ueid and check srperiodicity
#      ${UE_ID}   Get UE_ID in Wireshark   nglogname=asix.pcap
#      ${UE_ID2}   Get UE_ID in Wireshark   nglogname=asix2.pcap
#      ${periodicity_log1_UE1}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log1_UE2}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE1}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log2_UE2}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE3}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID2[0]}
#      Should Be Equal   ${periodicity_log1_UE1[0]}   7
#      Should Be Equal   ${periodicity_log1_UE1[1]}   7
#      Should Be Equal   ${periodicity_log1_UE2[0]}   7
#      Should Be Equal   ${periodicity_log1_UE2[1]}   7
#      Should Be Equal   ${periodicity_log1_UE2[2]}   10
#      Should Be Equal   ${periodicity_log2_UE1[0]}   9
#      Should Be Empty   ${periodicity_log2_UE2}
#      Should Be Equal   ${periodicity_log2_UE3[0]}   7
#      Should Be Equal   ${periodicity_log2_UE3[1]}   9
#      Should Be Equal   ${periodicity_log2_UE3[2]}   9
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_J_1_2_preempt_with_tempuse_pool_not_fully_used_when_reach_sr_cap
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=1   cellnum=2
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_J_12}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step3 xiaomi 1 attach to cell 1 ok
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Power UE attach
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step4 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #step5 xiaomi 1 detach
#      Power UE detach
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #add preempt fail US
#      Start Capture Wireshark Logs on gNB   nglogname=asix5.pcap
#      MTU attach    ue_num=4
#      Stop Capture Wireshark Logs on gNB   nglogname=asix5.pcap
#      MTU detach   ue_num=4
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 32 a
#      ${message_p}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=preempt
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step6-7 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark no Preemption in DU   nglogname=asix.pcap
#      Check Wireshark have Preemption in DU   nglogname=asix2.pcap
#      #add counter check when preempt fail
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix5.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[7]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_J_1_4_preempt_with_tempuse_pool_not_fully_used_when_reach_drb_cap
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=10   maxNumOfDRBL2Pool=14   RatioPerCell=0   cellnum=2
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_J_14}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step3 xiaomi 1 attach to cell 2 ok
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Power UE attach
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step4 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #step5 xiaomi 1 detach
#      Power UE detach
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #add preempt fail US
#      Start Capture Wireshark Logs on gNB   nglogname=asix5.pcap
#      MTU attach    ue_num=4
#      Stop Capture Wireshark Logs on gNB   nglogname=asix5.pcap
#      MTU detach   ue_num=4
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 14 a
#      ${message_p}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=preempt
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step6-7 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark no Preemption in DU   nglogname=asix.pcap
#      Check Wireshark have Preemption in DU   nglogname=asix2.pcap
#      #add counter check when preempt fail
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix5.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[5]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_J_1_6_preempt_with_only_emer_pool_can_be_used_for_tempuse_when_reach_rcu_cap
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=6   cellnum=2
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_J_16}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step3 xiaomi 1 attach to cell 1 ok
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Power UE attach
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step4 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #step5 xiaomi 1 detach
#      Power UE detach
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #add preempt fail US
#      Start Capture Wireshark Logs on gNB   nglogname=asix5.pcap
#      MTU attach    ue_num=4
#      Stop Capture Wireshark Logs on gNB   nglogname=asix5.pcap
#      MTU detach   ue_num=4
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 6 a
#      ${message_p}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=preempt
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step6-7 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark no Preemption in DU   nglogname=asix.pcap
#      Check Wireshark have Preemption in DU   nglogname=asix2.pcap
#      #add counter check when preempt fail
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix5.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[6]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_J_1_1_preempt_with_tempuse_pool_not_fully_used_when_reach_rcu_cap
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   cellnum=2
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #step2 change para online and no cell degrade
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_J_11}
#      COAM Check All Cells Onair
#      #syslog start
#      Syslog Capture Start
#      #step3 xiaomi 1 attach to cell1 then start vonr or emer then hangup then detach for 2 times
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   Start a emergency call
#      Run keyword and ignore error   Stop the emergency call
#      Run keyword and ignore error   Power UE detach
#      sleep    5s
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   hold on an VONR
#      Run keyword and ignore error   Stop the VONR call
#      Run keyword and ignore error   Power UE detach
#      sleep    5s
#      Power UE Precondition
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   Start a emergency call
#      Run keyword and ignore error   Stop the emergency call
#      Run keyword and ignore error   Power UE detach
#      sleep    5s
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   hold on an VONR
#      Run keyword and ignore error   Stop the VONR call
#      Run keyword and ignore error   Power UE detach
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
#      ${NRuser}   Print BTSlog   message_name=capacityPool: 40${comma} avalibleAreaCapacityPool: 38
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
# #     ${pcsi}   Print BTSlog   message_name=capacityPool: 320${comma} avalibleAreaCapacityPool: 304
#      ${SR}   Print BTSlog   message_name=capacityPool: 160${comma} avalibleAreaCapacityPool: 152
# #     5G_CP_ARC_ALG_3875 step1 drb rac with reservePoolAvailableFlag = true , step1 skiped when step2 pass
# #     ${DRB}   Print BTSlog   message_name=capacityPool: 80 avalibleAreaCapacityPool: 76
# #     ${GBR}   Print BTSlog   message_name=capacityPool: 20 avalibleAreaCapacityPool: 18
# #     5G_CP_ARC_ALG_3875 step2 drb rac with reservePoolAvailableFlag = false
#      ${DRB}   Print BTSlog   message_name=capacityPool: 80${comma} avalibleAreaCapacityPool: 72
#      ${GBR}   Print BTSlog   message_name=capacityPool: 20${comma} avalibleAreaCapacityPool: 16
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 1
# #     Should Contain    ${pcsi}   guaranteedCapacityCell: 8
#      Should Contain    ${SR}   guaranteedCapacityCell: 4
#      Should Contain    ${DRB}   guaranteedCapacityCell: 2
#      Should Contain    ${GBR}   guaranteedCapacityCell: 1
# 
# #     5G_CP_ARC_ALG_3875 step1 drb rac with reservePoolAvailableFlag = true , step1 skiped when step2 pass
# #     ${DRB}   Print BTSlog   message_name=capacityPool: 80 avalibleAreaCapacityPool: 76
# #     ${GBR}   Print BTSlog   message_name=capacityPool: 20 avalibleAreaCapacityPool: 18
# #     5G_CP_ARC_ALG_3875 step2 drb rac with reservePoolAvailableFlag = false
#      ${DRB_Emer}   Print BTSlog   message_name=capacityPool: 80${comma} avalibleAreaCapacityPool: 72
#      ${GBR_Emer}   Print BTSlog   message_name=capacityPool: 20${comma} avalibleAreaCapacityPool: 16
#      Should Contain    ${DRB_Emer}   guaranteedCapacityCell: 2
#      Should Contain    ${GBR_Emer}   guaranteedCapacityCell: 1
#      Should Contain    ${DRB_Emer}   numOfRadioResReservForEmergency: 1
#      Should Contain    ${GBR_Emer}   numOfRadioResReservForEmergency: 1
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_FJK_ABIO_TDD
#     [Tags]    CRT_TRUNK    CRT_23R1
#     [Setup]    robot_common_operations.Common Case Setup
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# *** Keywords ***
