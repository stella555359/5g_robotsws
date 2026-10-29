# *** Settings ***
# Documentation   case target verify auto L1 event trigger snapshot capture which contain L1 \
# ...  IQ date.
# ...  author: Qu Jing
# ...  contact: jing.qu@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# 
# 
# Force Tags   SG_07   CA_5G_OAM   CRT
# ...    PY36
# 
# Suite Setup    Enviroment Prepare
# Suite Teardown    Enviroment Clean
# 
# *** Variables ***
# ${test_vm_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
# ${test_vm_user}   ${tl.test_pc.default_ssh_connection_details.username}
# ${test_vm_password}   ${tl.test_pc.default_ssh_connection_details.password}
# ${BTSID}   ${tl.gnbs[0].instance_id}
# ${system_version}    ${EMPTY}
# ${brand}    lge
# ${index}
# ${meta_data_file}    *metadata.txt
# ${lte_cell_list}    ${1}
# ${ue_index}    0
# 
# *** Test Cases ***
# [1]CNI65680_15_Automatically_triggered_snapshot_L1_UL_save_buffer_4G
#     [Tags]   CNI-65680     LTE     AutoTriggerSnapshot
#     [Setup]  Case Setup
#     Log To Console     Step1: Config Preparation
#     Config Preparation
#     Log To Console     Step2: Attach UE And Trigger Snapshot
#     Attach UE And Trigger Snapshot
#     Log To Console     Step3: Check Postcondition
#     Check Postcondition
#     [Timeout]   40min
#     [Teardown]   Case Teardown
# 
# *** Keyword ***
# Enviroment Prepare
#     Log To Console    suite_setup_prepare:BTSLOG
#     Start BTS Syslog Collection
# 
# Enviroment Clean
#     Stop BTS Syslog Collection
# 
# Case Setup
#     Run Keyword And Ignore Error   Check Extra Reset From Blackbox
#     COAM Login
#     Check Fault 8101 Clear Status
#     Remove LSS Snapshot for Special Test Line
#     L3CALL Precondition
#     Prepare Loki Journal Log Setup
# 
# Case Teardown
#     Loki Journal Log Teardown
#     COAM Logout
#     Check Extra Reset From Blackbox
#     Remove COAM Directory Snapshot
#     Internal Trace Deactivate
# 
# Config Preparation
#     [Documentation]    1. Fault to trigger auto snapshot collection, and Target storage.
#     ...                2. IQ capture config, include Cell ID, Event base capture
#     ...                3. R&D parameter include Feature activation internal and event type etc.
#     Config Base Fault ID And LSS Snapshot Trigger Parameter
#     Config IQ Capture 4G Via WebEM
#     Config LTE L1 UL Event Via Confmgmtbrowser
# 
# Attach UE And Trigger Snapshot
#     [Documentation]    1. Attach UE and Compare Event trigger times
# #    ${nr_event_num_bofore}    ${lte_event_num_bofore}    Query Event Triggered
# #    Log To Console    LTE_event_triggerd_time_before_call:${lte_event_num_bofore}
# #    ${lte_event_num_bofore}   Convert To String   ${lte_event_num_bofore}
# #    ${event_trigged}    Attach And Verify Event Trigger    lte_event_num_bofore=${lte_event_num_bofore}
# #    Log To Console    LTE_event_triggerd_times_after_call:${event_trigged}
#     Run Keyword And Ignore Error    Attach UE Only
#     sleep    15s
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${tl.ues[${ue_index}].capabilities[1]}
#     [Teardown]  Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${tl.ues[${ue_index}].capabilities[1]}
# 
# Check Postcondition
#     [Documentation]    1. Check Snapshot whether uploaded
#     ...                2. Check Fualt 8101 whether raise and cancel when event trigger and snapshot been collected
#     ...                3. check Snaopshot IQ data file size and metadata content
# #    Check Fault 8101 Raise Status
#     ${result}    Wait Until Keyword Succeeds    6x    5min    Check Whether Snapshot Upload to LSS
#     sleep    5min
# #    Check Fault 8101 Clear Status
#     ${result}    Check snapshot file list For 4G
#     Log To Console    File check:${result}
#     Check Metadata File Content
# 
# 
