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
# Suite Setup    Common Suite Setup for COAM     swconfig_flag=${True}
# Suite Teardown   Run Keyword And Ignore Error    COAM Teardown gnb connections
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# 
# *** Test Cases ***
# [1]CB008847_A_02_hit_L1_sr_cap_of_L1_pool_by_DU_when_ps_att_with_diff_sr_csi_peri_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   F1SR=1
# #     Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_A_2}
#      Run keyword if   '${gnb_release}'=='SBTS23R1' or '${gnb_release}'=='SBTS23R2' or '${gnb_release}'=='SBTS23R3'
#      ...   Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_A_2_X}
#      ...   ELSE    Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_A_2}
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
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 32 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[7]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_A_03_hit_L1_csi_cap_of_L1_pool_by_DU_when_ps_att_with_diff_sr_csi_peri_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      log to console    pass
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
# #     #step1 env setup
# #     Modify Venfor file   F3PCSI=1
# #     Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_A_3}
# #     Wait Until Keyword Succeeds   7m   30s   COAM Check All Cells Onair
# #     Adjust the HBTE attenuation value   value_1=${127}   value_3=${127}   value_4=${127}
# #     ...   value_6=${127}   value_9=${127}   value_11=${127}   value_12=${127}   value_14=${127}
# #     #syslog start
# #     Syslog Capture Start
# #     #step2 mtu 0-2 attach ok
# #     Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
# #     MTU attach    ue_num=3
# #     Stop Capture Wireshark Logs on gNB   nglogname=asix.pcap
# #     #step5-6 xiaomi 1-2 attach to cell2 ok and detach
# #     Power UE Precondition
# #     Power UE Precondition   ue_index=${9}
# #     Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
# #     Power UE attach
# #     Power UE attach   ue_index=${9}
# #     Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
# #     Power UE detach
# #     Power UE detach   ue_index=${9}
# #     #step3-4 mtu 3 attach fail and detach
# #     Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
# #     Run keyword and ignore error   MTU attach    first_ue_index=3
# #     Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
# #     Run keyword and ignore error   MTU detach    first_ue_index=3
# #     Run keyword and ignore error   MTU detach    first_ue_index=3
# #     #step7 mtu 0-2 detach
# #     MTU detach   ue_num=3
# #     #syslog stop
# #     Syslog Capture Stop and Collect
# #     #syslog print
# #     ${message}   Run keyword and ignore error   Print BTSlog
# #     ...   message_name=capacityPool: 64 a
# #     ${message2}   Run keyword and ignore error   Print BTSlog
# #     ...   message_name=current number of NR Users
# #     ${message3}   Run keyword and ignore error   Print BTSlog
# #     ...   message_name=drb_count
# #     #step8-10 check cplane
# #     Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
# #     Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
# #     Check Wireshark no RRC Reject in DU   nglogname=asix3.pcap
# #     #step11 check counter
# #     ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
# #     ${8847_list}   Get 8847 Counters   countertime=${countertime}
# #     run keyword and ignore error   Should Not Be Equal   ${8847_list[8]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_B_01_hit_L2_rcu_cap_of_L2_pool_by_DU_when_ps_att_or_ps_ho_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=8
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
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 8 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[6]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_2_3_02_hit_L2_drb_cap_of_L2_pool_by_DU_when_vonr_start_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=8   maxNumOfDRBL2Pool=10
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_232}
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
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 10 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step8-10 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark have DRB Fail in DU   nglogname=asix2.pcap
#      Check Wireshark no DRB Fail in DU   nglogname=asix3.pcap
#      #step11 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[5]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_3_1_01_update_resource_by_DU_when_add_3rd_cell_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file   cellnum=2
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
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
#      #step2 xiaomi 1 attach to cell1 then start vonr or emer then hangup then detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition
#      Run keyword and ignore error   Power UE attach
#      Run keyword and ignore error   hold on an VONR
#      Run keyword and ignore error   Stop the VONR call
#      Run keyword and ignore error   Power UE detach
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
#      ${NRuser}   Print BTSlog   message_name=capacityPool: 40${comma} avalibleAreaCapacityPool: 37
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
# #     ${pcsi}   Print BTSlog   message_name=capacityPool: 320${comma} avalibleAreaCapacityPool: 296
#      ${SR}   Print BTSlog   message_name=capacityPool: 160${comma} avalibleAreaCapacityPool: 148
#      ${DRB}   Print BTSlog   message_name=capacityPool: 80${comma} avalibleAreaCapacityPool: 74
#      ${GBR}   Print BTSlog   message_name=capacityPool: 20${comma} avalibleAreaCapacityPool: 17
# 
#      Should Contain    ${NRuser}   occupiedCapacityPool: 3
# #     Should Contain    ${pcsi}   occupiedCapacityPool: 24
#      Should Contain    ${SR}   occupiedCapacityPool: 12
#      Should Contain    ${DRB}   occupiedCapacityPool: 6
#      Should Contain    ${GBR}   occupiedCapacityPool: 3
# 
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 1
# #     Should Contain    ${pcsi}   guaranteedCapacityCell: 8
#      Should Contain    ${SR}   guaranteedCapacityCell: 4
#      Should Contain    ${DRB}   guaranteedCapacityCell: 2
#      Should Contain    ${GBR}   guaranteedCapacityCell: 1
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_3_3_02_no_enough_L2_drb_resource_for_conB_by_DU_when_add_3th_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=10   maxNumOfDRBL2Pool=12   cellnum=2
#      #syslog start
#      Syslog Capture Start
#      #step2 mtu 0-2 attach ok
#      MTU attach    ue_num=3
#      #step3 add cell3-4 online and no cell degrade
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
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 12 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step9-12 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark no DRB Fail in DU   nglogname=asix2.pcap
#      Check Wireshark have DRB Fail in DU   nglogname=asix3.pcap
#      Check Wireshark no DRB Fail in DU   nglogname=asix4.pcap
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_4_2_01_resource_recycle_by_DU_after_add_cell_when_some_user_released_conA_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup
#      #step1 env setup
#      Modify Venfor file   maxNumOfUserL2Pool=9   maxNumOfDRBL2Pool=36   cellnum=2
# #     Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_421}
#      Run keyword if   '${gnb_release}'=='SBTS23R1' or '${gnb_release}'=='SBTS23R2' or '${gnb_release}'=='SBTS23R3'
#      ...   Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_421_X}
#      ...   ELSE    Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_421}
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
#      MTU detach   first_ue_index=${4}   ue_num=3
#      #step9 mtu 2 attach ok
#      Start Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      MTU attach   first_ue_index=${4}   ue_num=1
#      Stop Capture Wireshark Logs on gNB   nglogname=asix2.pcap
#      #step10 mtu 3 attach fail
#      Start Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      Run keyword and ignore error   MTU attach   first_ue_index=${5}   ue_num=1
#      Stop Capture Wireshark Logs on gNB   nglogname=asix3.pcap
#      #step11 mtu 0-3 detach
#      MTU detach   ue_num=6
#      #syslog stop
#      Syslog Capture Stop and Collect
#      #syslog print
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 9 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step12-14 check cplane
#      Check Wireshark no RRC Reject in DU   nglogname=asix.pcap
#      Check Wireshark no RRC Reject in DU   nglogname=asix2.pcap
#      Check Wireshark have RRC Reject in DU   nglogname=asix3.pcap
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_5_1_01_cap_decrease_by_DU_when_ca_start_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file   RatioPerCell=0
#      #step2 open CA and adjust PA
#      Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_511}
#      Adjust the HBTE attenuation value   value_3=${127}   value_4=${127}   value_5=${127}
#      ...   value_6=${127}   value_11=${127}   value_12=${127}   value_13=${127}   value_14=${127}
#      #syslog start
#      Syslog Capture Start
#      #step3 xiaomi 1 attach to cell1 or cell2 and scell added and detach
#      Start Capture Wireshark Logs on gNB   nglogname=asix.pcap
#      Power UE Precondition
#      Power UE attach
#      Power UE detach
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
#      ${NRuser}   Print BTSlog   
#      ...  message_name=capacityPool: 40${comma} avalibleAreaCapacityPool: 37${comma} realUsedCapacityPool: 1${comma} occupiedCapacityPool: 1
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
# #      ${pcsi}   Print BTSlog
# #      ...  message_name=capacityPool: 320${comma} avalibleAreaCapacityPool: 296${comma} realUsedCapacityPool: 8${comma} occupiedCapacityPool: 8
#      ${SR}   Print BTSlog
#      ...  message_name=capacityPool: 160${comma} avalibleAreaCapacityPool: 148${comma} realUsedCapacityPool: 4${comma} occupiedCapacityPool: 4
#      ${DRB}   Print BTSlog
#      ...  message_name=capacityPool: 80${comma} avalibleAreaCapacityPool: 74${comma} realUsedCapacityPool: 2${comma} occupiedCapacityPool: 2
#      Should Contain    ${NRuser}   realUsedCapacityCell: 0${comma} guaranteedCapacityCell: 0
# #      Should Contain    ${pcsi}   realUsedCapacityCell: 8${comma} guaranteedCapacityCell: 0
#      Should Not Contain    ${SR}   guaranteedCapacityCell: 0
#      Should Not Contain    ${DRB}   guaranteedCapacityCell: 0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_3_4_01_update_resource_by_DU_when_maxNumOfUsersNRCell_mod_for_conA_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file
#      Adjust the HBTE attenuation value   value_2=${127}   value_3=${127}   value_5=${127}
#      ...   value_6=${127}   value_10=${127}   value_11=${127}   value_13=${127}   value_14=${127}
#      #step2 change para online and no cell degrade
# #     Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_341}
#      Run keyword if   '${gnb_release}'=='SBTS23R1' or '${gnb_release}'=='SBTS23R2' or '${gnb_release}'=='SBTS23R3'
#      ...   Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_341_X}
#      ...   ELSE    Modify the COAM parameter with admin API    parameters=${PARAMS_TO_MODIFY_8847_C_341}
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
#      ${NRuser}   Print BTSlog   message_name=capacityPool: 40${comma} avalibleAreaCapacityPool: 39
# #     csiReportPeriodicity must be slots160 or slots320 due to PDL rule
# #     ${pcsi}   Print BTSlog   message_name=capacityPool: 320${comma} avalibleAreaCapacityPool: 312
#      ${SR}   Print BTSlog   message_name=capacityPool: 160${comma} avalibleAreaCapacityPool: 156
#      ${DRB}   Print BTSlog   message_name=capacityPool: 80${comma} avalibleAreaCapacityPool: 78
#      ${GBR}   Print BTSlog   message_name=capacityPool: 20${comma} avalibleAreaCapacityPool: 19
#      Should Contain    ${NRuser}   occupiedCapacityPool: 4
# #     Should Contain    ${pcsi}   occupiedCapacityPool: 32
#      Should Contain    ${SR}   occupiedCapacityPool: 16
#      Should Contain    ${DRB}   occupiedCapacityPool: 7
#      Should Contain    ${GBR}   occupiedCapacityPool: 3
#      Should Contain    ${NRuser}   guaranteedCapacityCell: 2
# #     Should Contain    ${pcsi}   guaranteedCapacityCell: 16
#      Should Contain    ${SR}   guaranteedCapacityCell: 8
#      Should Contain    ${DRB}   guaranteedCapacityCell: 3
#      Should Contain    ${GBR}   guaranteedCapacityCell: 1
# 
#      ${DRB_Emer}   Print BTSlog   message_name=capacityPool: 80${comma} avalibleAreaCapacityPool: 80
#      ${GBR_Emer}   Print BTSlog   message_name=capacityPool: 20${comma} avalibleAreaCapacityPool: 20
#      Should Contain    ${DRB_Emer}   guaranteedCapacityCell: 3
#      Should Contain    ${GBR_Emer}   guaranteedCapacityCell: 1
#      Should Contain    ${DRB_Emer}   numOfRadioResReservForEmergency: 1
#      Should Contain    ${GBR_Emer}   numOfRadioResReservForEmergency: 1
# 
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# [1]CB008847_C_1_1_04_emer_cap_decrease_by_DU_when_no_shared_res_when_emer_start_for_ABIO_TDD
#      [Tags]    CRT_TRUNK    CRT_23R1
#      [Timeout]    120 min
#      [Setup]     Run Keywords
#      ...    Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}    AND
#      ...    8847 Case Setup   open_spark=False
#      #step1 env setup
#      Modify Venfor file   maxNumOfGBRL2Pool=3   RatioPerCell=0
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
#      ${message}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=capacityPool: 3 a
#      ${message2}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=current number of NR Users
#      ${message3}   Run keyword and ignore error   Print BTSlog
#      ...   message_name=drb_count
#      #step4-5 check cplane
#      Check Wireshark no DRB Fail in DU   nglogname=asix.pcap
#      Check Wireshark have DRB Fail in DU   nglogname=asix2.pcap
#      #step6 check counter
#      ${countertime}   Get Rac Reject Time from Wireshark   nglogname=asix2.pcap
#      ${8847_list}   Get 8847 Counters   countertime=${countertime}
#      run keyword and ignore error   Should Not Be Equal   ${8847_list[4]}   0
#      [Teardown]    Run keyword and ignore error   Case Teardown and Call Recover
# 
# 
# [1]CB008847_ABC_ABIO_TDD
#     [Tags]    CRT_TRUNK    CRT_23R1
#     Append To List   ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     List Should Not Contain Value   ${ALL_TEST_STATUS}   FAIL
# 
# *** Keywords ***
