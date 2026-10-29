# *** Settings ***
# Force Tags    PY36
# Documentation     author: jiang johnny
# ...                 contact: johnny.1.jiang@nokia-sbell.com
# ...                 squad group: SG_07
# ...                 feature : 5GC002426
# 
# Resource     Resources/5GC002426_common_keyword.robot
# Variables    Resources/variables.py
# Resource     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_log.robot
# 
# Suite Setup    run keywords    Common Suite Setup for COAM
# Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]5GC002426_L_1_4_01_hit_high_thres_of_sr_pool_when_ue_from_1_to_x_with_2271_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=1   cellnum=2
#      #step2 2271 para change
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_L_141}
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
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step6-7 get ueid and check srperiodicity
#      ${UE_ID}   Get UE_ID in Wireshark   nglogname=asix.pcap
#      ${UE_ID2}   Get UE_ID in Wireshark   nglogname=asix2.pcap
# 
#      ${periodicity_log1_UE1}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log1_UE2}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE1}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log2_UE2}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE3}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID2[0]}
#      set suite variable    ${periodicity_log1_UE1}
#      set suite variable    ${periodicity_log1_UE2}
#      set suite variable    ${periodicity_log2_UE1}
#      set suite variable    ${periodicity_log2_UE2}
#      set suite variable    ${periodicity_log2_UE3}
# 
#      ${status}    run keyword and return status    L141 result1 check
#      run keyword unless    ${status}    L141 result2 check
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_L_1_4_03_hit_low_thres_of_sr_slot_when_ue_from_x_to_1_with_2271_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=1   cellnum=2
#      #step2 2271 para change
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_L_143}
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
#      MTU detach    first_ue_index=2
#      sleep   10s
#      MTU detach    first_ue_index=1
#      MTU detach    first_ue_index=1
#      sleep   10s
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step5 mtu 0 detach
#      MTU detach
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step6-7 get ueid and check srperiodicity
#      ${UE_ID}   Get UE_ID in Wireshark   nglogname=asix.pcap
#      ${periodicity_log1_UE1}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log1_UE2}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log1_UE3}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[2]}
#      ${periodicity_log2_UE1}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log2_UE2}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[1]}
#      set suite variable    ${periodicity_log1_UE1}
#      set suite variable    ${periodicity_log1_UE2}
#      set suite variable    ${periodicity_log1_UE3}
#      set suite variable    ${periodicity_log2_UE1}
#      set suite variable    ${periodicity_log2_UE2}
# 
#      ${status}    run keyword and return status    L143 result1 check
#      run keyword unless    ${status}    L143 result2 check
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_L_1_4_02_hit_high_thres_of_sr_slot_when_ue_from_1_to_x_with_2271_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=1   cellnum=2
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #step2 2271 para change
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_L_142}
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
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step6-7 get ueid and check srperiodicity
#      ${UE_ID}   Get UE_ID in Wireshark   nglogname=asix.pcap
#      ${UE_ID2}   Get UE_ID in Wireshark   nglogname=asix2.pcap
#      ${periodicity_log1_UE1}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log1_UE2}   Get Periodicity and Offset   nglogname=asix.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE1}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[0]}
#      ${periodicity_log2_UE2}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID[1]}
#      ${periodicity_log2_UE3}   Get Periodicity and Offset   nglogname=asix2.pcap   UE_ID=${UE_ID2[0]}
#      Should Be Equal   ${periodicity_log1_UE1[0]}   5
#      Should Be Equal   ${periodicity_log1_UE1[1]}   5
#      Should Be Equal   ${periodicity_log1_UE2[0]}   5
#      Should Be Equal   ${periodicity_log1_UE2[1]}   5
#      Should Be Equal   ${periodicity_log1_UE2[2]}   9
#      Should Be Equal   ${periodicity_log2_UE1[0]}   7
#      Should Be Empty   ${periodicity_log2_UE2}
#      Should Be Equal   ${periodicity_log2_UE3[0]}   5
#      Should Be Equal   ${periodicity_log2_UE3[1]}   7
#      Should Be Equal   ${periodicity_log2_UE3[2]}   7
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_A_02_hit_L1_sr_cap_of_L1_pool_by_DU_when_ps_att_with_diff_sr_csi_peri_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=1
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_A_2}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step5-6 xiaomi 1-2 attach to cell2 ok and detach
#      Power UE Precondition
#      Power UE Precondition   ue_index=${9}
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE attach
#      Power UE attach   ue_index=${9}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE detach
#      Power UE detach   ue_index=${9}
#      #step3-4 mtu 3 attach fail and detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU attach    first_ue_index=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      #step7 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 160 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${2426_list}   Get 2426 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${2426_list[7]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_A_03_hit_L1_csi_cap_of_L1_pool_by_DU_when_ps_att_with_diff_sr_csi_peri_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   F3PCSI=1   F1SR=3
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_A_3}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step5-6 xiaomi 1-2 attach to cell2 ok and detach
#      Power UE Precondition
#      Power UE Precondition   ue_index=${9}
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE attach
#      Power UE attach   ue_index=${9}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE detach
#      Power UE detach   ue_index=${9}
#      #step3-4 mtu 3 attach fail and detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU attach    first_ue_index=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      #step7 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 320 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 320 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${2426_list}   Get 2426 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${2426_list[8]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_C_01_hit_L2_RCU_cap_of_L2_pool_by_DU_when_ps_att_or_ps_ho_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=14
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step5-6 xiaomi 1 attach to cell2 ok and detach
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE attach
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE detach
#      #step3-4 mtu 3 attach fail and detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU attach    first_ue_index=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      #step7 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 14 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 14 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${2426_list}   Get 2426 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${2426_list[6]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_D_2_3_02_hit_L2_drb_cap_of_L2_pool_by_DU_when_vonr_start_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=14   maxNumOfDRBL2Pool=16
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_D_232}
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      MTU attach    ue_num=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step5-6 xiaomi 1 attach to cell2 ok and detach
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE attach
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Power UE detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step3-4 mtu 3 attach fail and detach
#      Run keyword and ignore error   MTU attach    first_ue_index=3
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      Run keyword and ignore error   MTU detach    first_ue_index=3
#      #step7 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 16 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 16 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark have DRB Fail in DU   nglogname=asix2.pcap
#      Check Wireshark no DRB Fail in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${2426_list}   Get 2426 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${2426_list[5]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_D_3_1_01_update_resource_by_DU_when_add_3rd_cell_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file   cellnum=2
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #step2 add cell3-4 online and no cell degrade
#      COAM WEBUI Login
#      Remove Cells   index=${2}
#      selenium_coam.validate_plan
#      COAM WEBUI Whether Close Start Up View Window
#      selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#      sleep  2m
#      COAM Check Cell Status
#      Add Cells   index=${2}
#      Add Cell Groups   index=${2}
#      Add Cells   index=${3}
#      Add Cell Groups   index=${3}
#      Add Cells   index=${4}
#      Add Cell Groups   index=${4}
#      selenium_coam.validate_plan
#      COAM WEBUI Whether Close Start Up View Window
#      selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#      COAM Check Cell Status
#      Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
#      COAM WEBUI Logout
# #     #syslog start
# #     Syslog Capture Start
# #     #step2 xiaomi 1 attach to cell1 then start vonr or emer then hangup then detach
# #     Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
# #     Power UE Precondition
# #     Run keyword and ignore error   Power UE attach
# #     Run keyword and ignore error   hold on an VONR
# #     Run keyword and ignore error   Stop the VONR call
# #     Run keyword and ignore error   Power UE detach
# #     Run keyword and ignore error   Power UE attach
# #     Run keyword and ignore error   hold on an VONR
# #     Run keyword and ignore error   Stop the VONR call
# #     Run keyword and ignore error   Power UE detach
# ##     Run keyword and ignore error   Power UE attach
# ##     Run keyword and ignore error   Start a emergency call
# ##     Run keyword and ignore error   Stop the emergency call
# ##     Run keyword and ignore error   Power UE detach
# #     Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
# #     #syslog stop
# #     Syslog Capture Stop and Collect
# #     #syslog print
# #     ${message}   Run keyword and ignore error   Print Message
# #     ${message2}   Run keyword and ignore error   Print Message
# #     ...   message_name=current number of NR Users
# #     ${message3}   Run keyword and ignore error   Print Message
# #     ...   message_name=drb_count
# #     #step4 check reource
# #     ${nameOfpool}    Return name of pool in syslog
# #     ${NRuser}   Print Message   message_name=capacityPool: 40 ${nameOfpool}AreaCapacityPool: 36
# #     ${pcsi}   Print Message   message_name=capacityPool: 640 ${nameOfpool}AreaCapacityPool: 576
# #     ${SR}   Print Message   message_name=capacityPool: 320 ${nameOfpool}AreaCapacityPool: 288
# #     ${DRB}   Print Message   message_name=capacityPool: 80 ${nameOfpool}AreaCapacityPool: 72
# #     ${GBR}   Print Message   message_name=capacityPool: 20 ${nameOfpool}AreaCapacityPool: 16
# #
# #     Should Contain    ${NRuser}   occupiedCapacityPool: 4
# #     Should Contain    ${pcsi}   occupiedCapacityPool: 64
# #     Should Contain    ${SR}   occupiedCapacityPool: 32
# #     Should Contain    ${DRB}   occupiedCapacityPool: 8
# #     Should Contain    ${GBR}   occupiedCapacityPool: 4
# #
# #     Should Contain    ${NRuser}   guaranteedCapacityCell: 1
# #     Should Contain    ${pcsi}   guaranteedCapacityCell: 16
# #     Should Contain    ${SR}   guaranteedCapacityCell: 8
# #     Should Contain    ${DRB}   guaranteedCapacityCell: 2
# #     Should Contain    ${GBR}   guaranteedCapacityCell: 1
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_D_3_3_02_no_enough_L2_drb_resource_for_conB_by_DU_when_add_3th_4th_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=14   maxNumOfDRBL2Pool=16   cellnum=2
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      MTU attach    ue_num=3
#      #step3 add cell3-4 online and no cell degrade
#      COAM WEBUI Login
#      Add Cells   index=${3}
#      Add Cell Groups   index=${3}
#      Add Cells   index=${4}
#      Add Cell Groups   index=${4}
#      selenium_coam.validate_plan
#      COAM WEBUI Whether Close Start Up View Window
#      selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#      COAM Check Cell Status
#      COAM Check Cell Status   cell_index=1
#      Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
#      COAM WEBUI Logout
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_5=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_13=${127}
#      #step4 xiaomi 1 attach to cell2 ok and detach
#      Power UE Precondition
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE attach
#      Power UE detach
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step5 xiaomi 2 attach to cell3 ok and detach
#      Power UE Precondition   ue_index=${9}
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      Power UE attach   ue_index=${9}
#      Power UE detach   ue_index=${9}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step6 xiaomi 2 attach to cell3 ok then start vonr fail then hangup then detach for 2 times
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      :FOR   ${index}    IN RANGE    2
#          Power UE attach   ue_index=${9}
#          Run keyword and ignore error   hold on an VONR   ue_index=${9}
#          Run keyword and ignore error   Stop the VONR call   ue_index=${9}
#          Power UE detach   ue_index=${9}
#      END
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      #step7 xiaomi 2 attach to cell3 ok then start emer ok then hangup then detach for 2 times
#      Start Capture Wireshark Logs on gNB   nglogname=asix4.pcap
#      :FOR   ${index}    IN RANGE    2
#          Power UE attach   ue_index=${9}
#          Start a emergency call   ue_index=${9}
#          Stop the emergency call   ue_index=${9}
#          Power UE detach   ue_index=${9}
#      END
#      Stop Capture Wireshark Logs on gNB   nglogname=asix4.pcap
#      #step8 mtu 0-2 detach
#      MTU detach   ue_num=3
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 16 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 16 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step9-12 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark no DRB Fail in DU   nglogname=asix2.pcap
#      Check Wireshark have DRB Fail in DU   nglogname=asix3.pcap
#      Check Wireshark no DRB Fail in DU   nglogname=asix4.pcap
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_D_4_2_01_resource_recycle_by_DU_after_add_cell_when_some_user_released_conA_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=9   maxNumOfDRBL2Pool=36   cellnum=2
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_D_421}
#      COAM Check Cell Status
#      COAM Check Cell Status   cell_index=1
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-6 attach ok
#      MTU attach    ue_num=7
#      #step3 xiaomi 1-2 attach to cell2 ok
#      Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
#      ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
#      Power UE Precondition
#      Power UE Precondition   ue_index=${9}
#      Power UE attach
#      Power UE attach   ue_index=${9}
#      #step4 add cell3-4 online and no cell degrade
#      COAM WEBUI Login
#      Add Cells   index=${3}
#      Add Cell Groups   index=${3}
#      Add Cells   index=${4}
#      Add Cell Groups   index=${4}
#      selenium_coam.validate_plan
#      COAM WEBUI Whether Close Start Up View Window
#      selenium_coam.activate_plan   activate_plan_despite_errors=${True}
#      COAM Check Cell Status
#      COAM Check Cell Status   cell_index=1
#      Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
#      COAM WEBUI Logout
#      #step5 xiaomi 1-2 detach
#      Power UE detach
#      Power UE detach   ue_index=${9}
#      #step6 xiaomi 1-2 attach to cell3 ok
#      Adjust the HBTE attenuation value   value_1=${127}   value_2=${127}   value_4=${127}
#      ...   value_5=${127}   value_9=${127}   value_10=${127}   value_12=${127}   value_13=${127}
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE attach
#      Power UE attach   ue_index=${9}
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step7 xiaomi 1-2 detach
#      Power UE detach
#      Power UE detach   ue_index=${9}
#      #step8 mtu 2-6 detach
#      MTU detach   first_ue_index=${2}   ue_num=5
#      #step9 mtu 2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      MTU attach   first_ue_index=${2}   ue_num=1
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step10 mtu 3 attach fail
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Run keyword and ignore error   MTU attach   first_ue_index=${3}   ue_num=1
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      #step11 mtu 0-3 detach
#      MTU detach   ue_num=4
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 9 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 9 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step12-14 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix3.pcap
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_D_3_4_01_update_resource_by_DU_when_maxNumOfUsersNRCell_mod_for_conA_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #step2 change para online and no cell degrade
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_2426_D_341}
#      COAM Check All Cells Onair
#      #syslog start
#      Syslog Capture Start
#      #step3 xiaomi 1 attach to cell1 then start vonr or emer then hangup then detach
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
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   Start a emergency call
#      Run keyword and ignore error   Stop the emergency call
#      Run keyword and ignore error   Power UE detach
#      sleep    5s
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   hold on an VONR
#      Run keyword and ignore error   Stop the VONR call
#      Run keyword and ignore error   Power UE detach
# 
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step4 check reource
#      ${nameOfpool}    Return name of pool in syslog
#      ${NRuser}   Print Message   message_name=capacityPool: 40 ${nameOfpool}AreaCapacityPool: 36
#      ${pcsi}   Print Message   message_name=capacityPool: 640 ${nameOfpool}AreaCapacityPool: 576
#      ${SR}   Print Message   message_name=capacityPool: 320 ${nameOfpool}AreaCapacityPool: 288
#      ${DRB}   Print Message   message_name=capacityPool: 80 ${nameOfpool}AreaCapacityPool: 72
#      ${GBR}   Print Message   message_name=capacityPool: 20 ${nameOfpool}AreaCapacityPool: 16
#      Should Contain    ${NRuser}   occupiedCapacityPool: 7
#      Should Contain    ${pcsi}   occupiedCapacityPool: 112
#      Should Contain    ${SR}   occupiedCapacityPool: 56
#      Should Contain    ${DRB}   occupiedCapacityPool: 13
#      Should Contain    ${GBR}   occupiedCapacityPool: 6
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 2
#      Should Contain    ${pcsi}   guaranteedCapacityCell: 32
#      Should Contain    ${SR}   guaranteedCapacityCell: 16
#      Should Contain    ${DRB}   guaranteedCapacityCell: 3
#      Should Contain    ${GBR}   guaranteedCapacityCell: 1
# 
#      ${DRB_Emer}   Print Message   message_name=capacityPool: 80
#      ${GBR_Emer}   Print Message   message_name=capacityPool: 20
#      Should Contain    ${DRB_Emer}   guaranteedCapacityCell: 3
#      Should Contain    ${GBR_Emer}   guaranteedCapacityCell: 1
#      Should Contain    ${DRB_Emer}   numOfRadioResReservForEmergency: 1
# #     Should Contain    ${GBR_Emer}   numOfRadioResReservForEmergency: 1
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_D_1_1_04_emer_cap_decrease_by_DU_when_no_shared_res_when_emer_start_for_ABIO_FDD
#      [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    2426 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file   maxNumOfGBRL2Pool=6   RatioPerCell=0
#      Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
#      Adjust the HBTE attenuation value   value_1=${127}   value_2=${127}   value_4=${127}
#      ...   value_5=${127}   value_9=${127}   value_10=${127}   value_12=${127}   value_13=${127}
#      #syslog start
#      Syslog Capture Start
#      #step2 xiaomi 1-2 attach to cell3 ok then start emer ok then hangup then detach for 2 times
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      :FOR   ${index}    IN RANGE    2
#          Power UE Precondition
#          Power UE Precondition   ue_index=${9}
#          Power UE attach
#          Power UE attach   ue_index=${9}
#          Start a emergency call
#          Start a emergency call   ue_index=${9}
#          Stop the emergency call
#          Stop the emergency call   ue_index=${9}
#          Power UE detach
#          Power UE detach   ue_index=${9}
#      END
#      Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      #step3 xiaomi 1 attach to cell3 ok then start vonr fail then hangup then detach for 2 times
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      :FOR   ${index}    IN RANGE    2
#          Power UE Precondition
#          Power UE attach
#          Run keyword and ignore error   hold on an VONR
#          Run keyword and ignore error   Stop the VONR call
#          Power UE detach
#      END
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 6 c
#      ${message}   Run keyword and ignore error   Print Message
#      ...   message_name=capacityPool: 6 a
#      ${message2}   Run keyword and ignore error   Print Message
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print Message
#      ...   message_name=drb_count
#      #step4-5 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark have DRB Fail in DU   nglogname=asix2.pcap
#      #step6 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${2426_list}   Get 2426 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${2426_list[4]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]5GC002426_ACDL
#     [Tags]    CRT_21A   CRT_21B    10.1800    CRT_TRUNK    CRT_22R1
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
# 
# 
# *** Keywords ***