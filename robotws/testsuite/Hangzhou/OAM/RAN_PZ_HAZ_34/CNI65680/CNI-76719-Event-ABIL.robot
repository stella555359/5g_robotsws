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
# ${BBMOD}   BBMOD_R-1(ABIL)
# ${ue_index}   0
# 
# *** Test Cases ***
# [1]CNI_76719_07_Automatically_triggered_snapshot_L1_UL_save_buffer_ABIL
#     [Setup]   Run Keywords   robot_common_operations.Common Case Setup   AND   Start Collect Log
#     ${release}   Get gnb release   host=${WEBUI_ADDR}
# #    ${domain_name}   Set Variable If   '${release}'>'SBTS22R4'   LonerNrTrbl   l1sw_trbl
# #    Set Test Variable   ${domain_name}
#     Trigger L1 Event for ABIL   release=${release}
#     Wait Until Keyword Succeeds    15x    1min   Check Whether Snapshot Upload to LSS
#     sleep    3min
#     Wait Until Keyword Succeeds    10x    1min   Check Metadata File   trigger_type_match=6450 - On fault detection
#     [Teardown]   Case Teardown for L1 event ABIL   release=${release}
# 
# 
# #
# #[1]CNI-76719-L2-Event-ABIL
# #      [Setup]   Case Setup for L2 Event
# #      Attach UE for Loki-A
# #      log to console   modify attenuation
# #      Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=100
# #      Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=127
# #      [Teardown]   Case Teardown for L2 Event
# 
# *** Keyword ***
# Common Suite Setup
#     [Timeout]   2h
#     robot_common_operations.Common Suite Setup
#     Case Setup
# 
# Common Suite Teardown
#     Case Teardown
# 
# Case Teardown
#     robot_common_operations.Common Suite Teardown
#     Run Keyword And Ignore Error   COAM Logout
#     Run Keyword And Ignore Error   Stop BTS Syslog Collection
#     Run Keyword And Ignore Error   Stop Collect Journal Logs For Coam
#     Run Keyword And Ignore Error   Dettach UE for Loner
#     Run Keyword And Ignore Error   CI_interface.Common Case Teardown
# 
# Start Collect Log
#     Start BTS Syslog Collection
#     Start Collect Journal Logs For Coam   loki_index=2
# 
# Stop Collect Log
#    Stop BTS Syslog Collection
#    run keyword and ignore error   Stop Collect Journal Logs For Coam
# 
# Case Teardown for L1 event ABIL
#     [Arguments]  ${release}
#     robot_common_operations.Common Case Teardown
#     ${domain_name}   Set Variable If   '${release}'>'SBTS22R4'   LonerNrTrbl   l1sw_trbl
#     Stop L1 Event Detection   domain_name=${domain_name}
#     ${catch_log_time_ABIL}   Stop BTS Syslog Collection
#     ${catch_journal_time_ABIL}   Stop Collect Journal Logs For Coam
#     Analyze Real Time Journal Log for ABIL   curr_str=${catch_journal_time_ABIL}   grep_info=event_trigger_src*
#     Analyze SYSLOG for Event Trigger   date_str=${catch_log_time_ABIL}
#     Run Keyword If Test Failed   Catch Snapshot COAM   local_file_path=${OUTPUT_DIR}
# 
# Case Setup
#     COAM Login
#     run keyword and ignore error  COAM Reset Site
#     Wait Until Keyword Succeeds   20m   1m   COAM Check BTS OnAir   connection=COAM
#     COAM Update Parameter   dist_name=MRBTS-${BTSID}/MNL-1/MNLENT-1/TRBLCADM-1    parameter=snapshotUploadDestinationForFault6450     value=lss
#     Remove LSS Snapshot for Special Test Line
#     Attach UE for Loner
# 
# Case Setup for L2 Event
#    Start BTS Syslog Collection
# 
# Case Teardown for L2 Event
#    Modify All Attenuation Ports Value For Specific RU   gnb_id=0   RU_id=0   value=0
#    Run Keyword And Ignore Error   Dettach UE for Loki-A
#    Stop BTS Syslog Collection
# 
# Attach UE for Loner
#    log to console   Attach UE${ue_index}
#    L3CALL Precondition   ue_index=${ue_index}
#    Attach UE Only   ue_index=${ue_index}
# 
# Trigger L1 Event for ABIL
#     [Arguments]   ${subcell_id}=0   ${loner_select}=2   ${cell_num}=1   ${release}=SBTS22R2
# #    ${release}   Get gnb release   host=${WEBUI_ADDR}
#     ${domain_name}   Set Variable If   '${release}'>'SBTS22R4'   LonerNrTrbl   l1sw_trbl
#     taf_coam.COAM WEBUI LOGIN   version=${release}
#     ${physCellId}  COAM Get Parameter Value   dist_name=MRBTS-${BTSID}/NRBTS-${BTSID}/NRCELL-${cell_num}  parameter=physCellId
#     ${ul}=    Run Keyword If   '${release}'<='SBTS22R4'   Create List    [PCI: ${physCellId}]NRCELL_R-${cell_num}: Subcell ${subcell_id}
#     ...   ELSE IF   '${release}'=='SBTS23R1'   Create List   [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
#     ...   ELSE   Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
#     ${dl}=    Run Keyword If   '${release}'<='SBTS22R4'   Create List    [PCI: ${physCellId}]NRCELL_R-${cell_num}: Subcell ${subcell_id}
#     ...   ELSE IF   '${release}'=='SBTS23R1'   Create List    [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
#     ...   ELSE   Create List    [BBMOD_R-1(ABIL)] [PCI: ${physCellId}]NRCELL-${cell_num}: Subcell ${subcell_id}
#      Run Keyword And Ignore Error   Run Keyword If   '${release}'<='SBTS23R1'
#      ...   selenium_coam.configure_iq_capture  bbmod=${BBMOD}   ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}
#      ...   enable_capture_on_event=${True}
#      ...   ELSE   selenium_coam.configure_iq_capture   ul_subcell_index_list=${ul}   dl_subcell_index_list=${dl}   enable_capture_on_event=${True}
#     csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     ${snapshot_trigger}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write ${domain_name} rejection_time${SPACE}10
#     ...   connection=gnb
#     ${snapshot_trigger_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} rejection_time
#     ...   connection=gnb
#     ${mine_trigger}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write ${domain_name} prach_preamble_detection_enabled${SPACE}1
#     ...   connection=gnb
#     ${mine_trigger_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} prach_preamble_detection_enabled
#     ...   connection=gnb
#     ${modify_event_number}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write ${domain_name} prach_peak_metric${SPACE}1.0
#     ...   connection=gnb
#     ${event_number_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} prach_peak_metric
#     ...   connection=gnb
#     ${modify_event_number}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write ${domain_name} trigger_delay${SPACE}20
#     ...   connection=gnb
#     ${event_number_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} trigger_delay
#     ...   connection=gnb
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# 
# #    [Teardown]   Run Keywords   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# #    ...   AND   Run Keyword And Ignore Error  COAM WEBUI Logout
# 
# Stop L1 Event Detection
#     [Arguments]   ${loner_select}=2   ${domain_name}=LonerNrTrbl
#     csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     ${mine_trigger}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser write ${domain_name} prach_preamble_detection_enabled${SPACE}0
#     ...   connection=gnb
#     ${mine_trigger_check}   csn.execute   command=bsh 1:${loner_select} confmgmtbrowser read ${domain_name} prach_preamble_detection_enabled
#     ...   connection=gnb
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# 
# 
# Catch Journal Log and Analyze
#     [Arguments]   ${log_name}=ABIL1
#     wait until keyword succeeds    5 min    30 s
#     ...   csn.Connect to   hostname=${asik_addr}   username=${asik_username}   password=${asik_password}    alias=gnb
#     csn.execute     command=bsh 1:2 journalctl -b >> ${log_name}.log   connection=gnb
#     sleep   10s
#     csn.execute     command=cd /user/toor4nsn;cat ${log_name}.log | grep "UTU BCN"   connection=gnb
#     ${return_event_info}   csn.execute     command=cd /user/toor4nsn;cat ${log_name}.log | grep "event_trigger_src*"   connection=gnb
#     sleep  30s
# #    csn.Download File    remote_path=/user/toor4nsn/${log_name}.log
# #    ...    local_path=${OUTPUT_DIR}/${log_name}.log   connection=gnb
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=gnb
# 
# Analyze Real Time Journal Log for ABIL
#     [Arguments]   ${curr_str}=1   ${grep_info}=event_trigger_src*
#     csn.Connect To   hostname=${test_vm_ip}   username=${test_vm_user}   password=${test_vm_password}   alias=TestVM
#     ${event_info}   csn.Execute
#     ...   command=cd ${OUTPUT_DIR};cat journal_${curr_str}.log | grep "${grep_info}"
#     ...   connection=TestVM
#     log to console   ${event_info}
#     Should Not Be Empty   ${event_info}
#     [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=TestVM
# 
# Dettach UE for Loner
#    log to console   Dettach UE${ue_index}
#    L3CALL Precondition   ue_index=${ue_index}