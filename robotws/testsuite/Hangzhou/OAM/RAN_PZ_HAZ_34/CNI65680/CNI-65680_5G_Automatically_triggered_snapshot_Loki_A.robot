# *** Settings ***
# Documentation
# ...  author: Li Xiaofei
# ...  contact: xiaofei.li@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# Force Tags   SG_07   CA_5G_OAM   CRT
# ...    PY36
# 
# Suite Setup   Common Suite Setup
# Suite Teardown    Common Suite Teardown
# 
# *** Variables ***
# ${test_vm_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
# ${test_vm_user}   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_vm_password}   ${tl.test_pc.default_ssh_connection_details.password}
# ${BBMOD}   BBMOD_R-1(ABIO)
# ${ue_index}   0
# 
# *** Test Cases ***
# [1]CNI-65680_2_Automatically_triggered_snapshot_L1_UL_save_buffer
#      [Setup]   Start Collect Journal Logs For Coam   loki_index=1
#      log to console   [1]CNI-65680_2_Automatically_triggered_snapshot_L1_UL_save_buffer
#      Trigger L1 Event for Loki-A
#      [Teardown]  Run Keywords
#       ...   run keyword and ignore error   Stop Collect Journal Logs For Coam
#       ...  AND   run keyword and ignore error  COAM Reset Site
#       ...  AND   Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir   connection=COAM
# 
# [1]CNI-65680_1_Automatically_triggered_snapshot_L2_continuous_buffer_sent_to_LSS
#      [Setup]   Start Collect Journal Logs For Coam   loki_index=1
#      log to console   [1]CNI-65680_1_Automatically_triggered_snapshot_L2_continuous_buffer_sent_to_LSS
#      Trigger L2 Event for Loki-A
#      [Teardown]  Run Keywords
#       ...   run keyword and ignore error   Stop Collect Journal Logs For Coam
#       ...  AND   run keyword and ignore error  COAM Reset Site
#       ...  AND   Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir   connection=COAM
# 
# #[1]CNI-65680_13_Automatically_triggered_snapshot_same_fault_from_different_Loki
# #     log to console   [1]CNI-65680_13_Automatically_triggered_snapshot_same_fault_from_different_Loki
# 
# *** Keyword ***
# Common Suite Setup
#     [Timeout]   2h
#     Case Setup
# 
# Common Suite Teardown
#     Case Teardown
# 
# Case Setup
#     Start BTS Syslog Collection
#     COAM Login
#     Check Fault 8101 Clear Status
#     Remove LSS Snapshot for Special Test Line
#     Attach UE for Loki-A
# #    Call Setup and check tput   tput=0   traffic_stop=${false}
# 
# Trigger L1 Event for Loki-A
#     Trigger L1 or L2 Event   subcell_id=0   event_name=EPhyEvent_PuschSnapshotVerification   loki_select=1   cell_num=1
# #    Check Fault 8101 Raise Status From History
#     IQ Collection Relative Check for Loki-A
#     Pause L1 or L2 Event   loki_select=1
# #    sleep  3min
# 
# Trigger L2 Event for Loki-A
#     Remove LSS Snapshot for Special Test Line
#     Trigger L1 or L2 Event   subcell_id=0   event_name=EPhyEvent_L2EventVerification   loki_select=1   cell_num=1
#     IQ Collection Relative Check for Loki-A   iq_file_name=BTS${BTSID}_124D_ContIqSnapshotBuffer.xz   iq_file_content=124D_ContIqSnapshotBuffer
#     Pause L1 or L2 Event   loki_select=1
# 
# Trigger L2 Event
#     [Arguments]   ${subcell_id}=1   ${event_name}=EPhyEvent_PuschSnapshotVerification   ${loki_select}=2   ${cell_num}=2
#     csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     ${L1_event_query_ori}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query   connection=gnb
#     ${group_ori}   Get Regexp Matches   ${L1_event_query_ori}   till now, (.+?) LTE Events & (.+?) NR Events
#     log to console   ${group_ori}
#     ${L1_event_trigger}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --nrevent ${event_name}
#     ...   connection=gnb
#     ${L1_event_query}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query    connection=gnb
#     ${group}   Get Regexp Matches   ${L1_event_query}   till now, (.+?) LTE Events & (.+?) NR Events
#     log to console   ${group}
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# 
# Case Teardown
#     Run Keyword And Ignore Error   COAM Logout
#     Stop BTS Syslog Collection
#     Run Keyword And Ignore Error   Dettach UE for Loki-A
#     Run Keyword And Ignore Error   CI_interface.Common Case Teardown
# 
# Attach UE for Loki-A
#        log to console   Attach UE${ue_index}
#        L3CALL Precondition   ue_index=${ue_index}
#        Attach UE Only   ue_index=${ue_index}
# 
# Dettach UE for Loki-A
#        log to console   Dettach UE${ue_index}
#        L3CALL Precondition   ue_index=${ue_index}
# 
# IQ Collection Relative Check for Loki-A
#     [Arguments]   ${iq_file_name}=BTS${BTSID}_124D_IqSnapshotBuffer.xz   ${iq_file_content}=124D_IqSnapshotBuffer
#     Wait Until Keyword Succeeds    10x    1min   Check Whether Snapshot Upload to LSS
#     sleep    5min
#     Check Metadata File   trigger_type_match=8101 - On alarm sending
#     ${result}    Check snapshot file list   local_file_path=${local_file_path}  iq_file_name=${iq_file_name}   iq_file_content=${iq_file_content}
# #    Check Metadata File Content
# #    ${result}    Check snapshot file list
