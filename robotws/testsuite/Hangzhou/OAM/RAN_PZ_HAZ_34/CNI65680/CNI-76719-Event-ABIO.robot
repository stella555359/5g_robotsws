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
# #Suite Setup   Common Suite Setup
# Suite Teardown    Common Suite Teardown
# 
# *** Variables ***
# ${test_vm_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
# ${test_vm_user}   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_vm_password}   ${tl.test_pc.default_ssh_connection_details.password}
# ${BBMOD}   BBMOD_R-1(ABIO)
# ${ue_index}   0
# ${catch_log_time}   2022630_174
# 
# *** Test Cases ***
# [1]CNI_76719_01_Automatically_triggered_snapshot_L1_UL_save_buffer_ABIO
#     [Setup]   Case Setup for L1 Event
#     Start BTS Syslog Collection
#     Start Collect Journal Logs For Coam   loki_index=1   journal_command=loggerctl
#     Trigger L1 or L2 Event   subcell_id=0   event_name=EPhyEvent_PuschSnapshotVerification   loki_select=1   cell_num=1
#     IQ Collection Relative Check
#     [Teardown]   Case Teardown for L1 Event
# 
# #[1]CNI_76719_03_Automatically_triggered_snapshot_L2_continuous_buffer
# #      [Setup]   Case Setup for L2 Event
# #      Start BTS Syslog Collection
# #      Start Collect Journal Logs For Coam   loki_index=1   journal_command=loggerctl
# #      log to console   modify attenuation
# #      Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=100
# #      Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=127
# #      Check L2 Event Trigger Status
# #      IQ Collection Relative Check   iq_file_name=BTS${BTSID}_124D_ContIqSnapshotBuffer.xz   iq_file_content=124D_ContIqSnapshotBuffer
# #      ${catch_log_time}   Stop BTS Syslog Collection
# #      ${catch_journal_time}   Stop Collect Journal Logs For Coam   journal_command=loggerctl
# #      Analyze SYSLOG for Event Trigger   date_str=${catch_log_time}
# #      Analyze Real Time Journal Log for ABIO   curr_str=${catch_journal_time}   grep_info=Send fastAntennaSnapshotResp to L2 successfully
# #      [Teardown]   Case Teardown for L2 Event
# 
# *** Keyword ***
# Common Suite Setup
#     [Timeout]   2h
#     robot_common_operations.Common Suite Setup
#     Case Setup
# 
# Common Suite Teardown
#     robot_common_operations.Common Suite Teardown
#     Case Teardown
# 
# Case Teardown
#     Run Keyword And Ignore Error   Stop BTS Syslog Collection
#     Run Keyword And Ignore Error   Stop Collect Journal Logs For Coam
#     Run Keyword And Ignore Error   CI_interface.Common Case Teardown
# 
# Case Setup
#     COAM Login
#     Check Fault 8101 Clear Status
#     Remove LSS Snapshot for Special Test Line
# 
# Case Setup for L1 Event
#     robot_common_operations.Common Case Setup
#     COAM Login
#     Check Fault 8101 Clear Status
#     Remove LSS Snapshot for Special Test Line
#     Attach UE for Loki-A
# 
# Case Teardown for L1 Event
#     robot_common_operations.Common Case Teardown
#     Pause L1 or L2 Event   loki_select=1
#     ${catch_log_time_L1}   Stop BTS Syslog Collection
#     ${catch_journal_time_L1}   Stop Collect Journal Logs For Coam   journal_command=loggerctl
#     Analyze Real Time Journal Log for ABIO   curr_str=${catch_journal_time_L1}   grep_info=NR UL snapshot event record successfully
#     Analyze SYSLOG for Event Trigger   date_str=${catch_log_time_L1}
#     Run Keyword And Ignore Error   Dettach UE for Loki-A
# #   run keyword and ignore error  COAM Reset Site
# #   Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir   connection=COAM
#     Run Keyword And Ignore Error   COAM Logout
#     Run Keyword If Test Failed   Catch Snapshot COAM   local_file_path=${OUTPUT_DIR}
# 
# Case Setup for L2 Event
# #   Start BTS Syslog Collection
#     COAM Login
#     Check Fault 8101 Clear Status
#     Remove LSS Snapshot for Special Test Line
#     Config IQ Capture for Event Trigger   subcell_id=0   loki_select=1   cell_num=1
#     Attach UE for Loki-A
# 
# Case Teardown for L2 Event
#    Run Keyword And Ignore Error   COAM Logout
#    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=0
#    Run Keyword And Ignore Error   Dettach UE for Loki-A
# #   Stop BTS Syslog Collection
# 
# Attach UE for Loki-A
#    log to console   Attach UE${ue_index}
#    L3CALL Precondition   ue_index=${ue_index}
#    Attach UE Only   ue_index=${ue_index}
# 
# Dettach UE for Loki-A
#    log to console   Dettach UE${ue_index}
#    L3CALL Precondition   ue_index=${ue_index}
# 
# Catch Journal Log and Analyze for ABIO
#     [Arguments]   ${log_name}=ABIL   ${grep_info}=NR Events have been triggered*
#     wait until keyword succeeds    5 min    30 s
#     ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     csn.execute     command=bsh 1:1 journalctl -b >> ${log_name}.log   connection=gnb
#     sleep   10s
# #    csn.execute     command=cd /user/toor4nsn;cat ${log_name}.log | grep "UTU BCN"   connection=gnb
#     ${return_event_info}   csn.execute     command=cd /user/toor4nsn;cat ${log_name}.log | grep "${grep_info}"   connection=gnb
#     sleep  30s
#     csn.Download File    remote_path=/user/toor4nsn/${log_name}.log
#     ...    local_path=${OUTPUT_DIR}/${log_name}.log   connection=gnb
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# 
# Analyze Real Time Journal Log for ABIO
#     [Arguments]   ${curr_str}=1   ${grep_info}=NR Events have been triggered*
#     csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
#     ${event_info}   csn.Execute
#     ...   command=cd ${OUTPUT_DIR};cat journal_${curr_str}.log | grep "${grep_info}"
#     ...   connection=TestVM
#     log to console   ${event_info}
#     Should Not Be Empty   ${event_info}
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM
# 
# IQ Collection Relative Check
#     [Arguments]   ${iq_file_name}=BTS${BTSID}_124D_IqSnapshotBuffer.xz   ${iq_file_content}=124D_IqSnapshotBuffer
#     Wait Until Keyword Succeeds    10x    1min   Check Whether Snapshot Upload to LSS
#     sleep    3min
#     Wait Until Keyword Succeeds    10x    2min   Check Metadata File   trigger_type_match=8101 - On alarm sending
#     ${result}    Check snapshot file list   local_file_path=${local_file_path}  iq_file_name=${iq_file_name}   iq_file_content=${iq_file_content}
# 
# Config IQ Capture for Event Trigger
#     [Arguments]   ${subcell_id}=1   ${loki_select}=2   ${cell_num}=2
#     taf_coam.COAM WEBUI LOGIN   version=SBTS22R2
#     ${physCellId}  COAM Get Parameter Value   dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}/NRCELL-${cell_num}  parameter=physCellId
#     ${ul}=    Run Keyword If   '${release}'<='SBTS22R4'   Create List    [PCI: ${physCellId}]NRCELL_R-${cell_num}: Subcell ${subcell_id}
#     ...   ELSE   Create List    [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
#     ${dl}=    Run Keyword If   '${release}'<='SBTS22R4'   Create List    [PCI: ${physCellId}]NRCELL_R-${cell_num}: Subcell ${subcell_id}
#     ...   ELSE   [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
#      Run Keyword And Ignore Error   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}
#     ...   enable_capture_on_event=${True}
#     csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     ${L1_event_query_ori}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query   connection=gnb
#     ${group_ori}   Get Regexp Matches   ${L1_event_query_ori}   till now, (.+?) LTE Events & (.+?) NR Events
#     log to console   ${group_ori}
#     ${snapshot_trigger}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser write CommonPhy enableAutoSnapshot${SPACE}${SPACE}1
#     ...   connection=gnb
#     ${snapshot_trigger_check}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser read CommonPhy enableAutoSnapshot
#     ...   connection=gnb
#     ${mine_trigger}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser write CommonPhy minutesToTrigAutoBTSSnapshot${SPACE}${SPACE}5
#     ...   connection=gnb
#     ${mine_trigger_check}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser read CommonPhy minutesToTrigAutoBTSSnapshot
#     ...   connection=gnb
#     ${modify_event_number}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser write CommonPhy nbOfEventsToTrigAutoBTSSnapshot${SPACE}1
#     ...   connection=gnb
#     ${event_number_check}   csn.execute   command=bsh 1:${loki_select} confmgmtbrowser read CommonPhy nbOfEventsToTrigAutoBTSSnapshot
#     ...   connection=gnb
# #    ${L1_event_query}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query    connection=gnb
# #    ${group}   Get Regexp Matches   ${L1_event_query}   till now, (.+?) LTE Events & (.+?) NR Events
# #    log to console   ${group}
#     [Teardown]   Run Keywords   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
#     ...   AND   Run Keyword And Ignore Error  COAM WEBUI Logout
# 
# Check L2 Event Trigger Status
#     [Arguments]   ${loki_select}=1
#     csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     ${L1_event_query}   csn.execute   command=bsh 1:${loki_select} /usr/lib64/python/antenna_snapshot_config.py --query    connection=gnb
#     ${group}   Get Regexp Matches   ${L1_event_query}   till now, (.+?) LTE Events & (.+?) NR Events
#     log to console   ${group}
#     [Teardown]  Run Keyword And Ignore Error   csn.Disconnect   connection=gnb