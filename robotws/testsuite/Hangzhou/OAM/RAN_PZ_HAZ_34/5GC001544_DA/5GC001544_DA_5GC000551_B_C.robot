# *** Settings ***
# Documentation
# ...         author: Mansour Medini
# ...         contact: mansour.medini@nokia.com
# ...         5GC001544 Ability to Transfer Troubleshooting logs from 5GNB to NMS
# ...         [1]5GC000551-A_TC_A#1_Generate snapshots on WEBUI
# ...         [1]5GC000551-B_TC_B#1_Generate snapshots on WEBUI
# ...         [1]5GC000551-B_TC_B#3_Transfer from WEBUI to Netact
# ...         [1]5GC000551-B_TC_B#4_Retrieve Snapshot in Netact
# ...         [1]5GC000551-B_TC_B#6_Generate and Transfer from WEBUI to Netact
# ...         [1]5GC000551-C_TC_C#1_Configure Alarms triggering Snapshot
# ...         [1]5GC000551-C_TC_C#2_Generate alarms triggering snapshot
# 
# 
# 
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Run Keywords    CI_interface.Common Suite Setup
# ...    AND     robot_common_operations.Common Suite Setup
# Suite Teardown   robot_common_operations.Common Suite Teardown
# Test Setup       robot_common_operations.Common Case Setup
# Test Teardown    robot_common_operations.Common Case Teardown
# 
# 
# 
# 
# Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# Resource    keywords.robot
# Library     BuiltIn
# Force Tags    RAN_5G    RAN_5G_TDD    CRT_UTE
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_ANDROID_ASIKR_ABILB4_AZHA_ENB_NETACT    STATE_SW_UPLOADED    SBTS00    CRT_21B    CRT_21A 
# 
# 
# 
# 
# *** Test Cases ***
# [1][2.0]5GC000551-B_TC_B#1_Generate snapshots on WEBUI
# 	Create a File
#     Save Snapshot for cOAM to Local    coverage=Full
#     sleep    60s
#     Save Snapshot for cOAM to Local    coverage=Minor
#     sleep    60s
#   
# 
#    
# [1][2.0]5GC000551-A_TC_A#1_Generate snapshots on WEBUI
#     Save Snapshot for cOAM to Local    coverage=Full
#     sleep    60s
#     Save Snapshot for cOAM to Local    coverage=Minor
#     sleep    60s
#     
#    
# [1][2.0]5GC000551-B_TC_B#3_Transfer from WEBUI to Netact
#    Save Snapshot for cOAM to Netact    coverage=Full
#    Run Keyword If    '${Snapshot_status}'=='PASS'    Run Keywords    Connect to Netact server Snapshot
#    sleep    60s
#    Save Snapshot for cOAM to Netact    coverage=Minor
#    Run Keyword If    '${Snapshot_status}'=='PASS'    Run Keywords    Connect to Netact server Snapshot
# 
#   
# [1][2.0]5GC000551-B_TC_B#4_Retrieve Snapshot in Netact
#     Retrieve Snapshot in Netact
# 
#  
# [1][2.0]5GC000551-B_TC_B#6_Generate and Transfer from WEBUI to Netact
#     Save Snapshot for cOAM to Netact    coverage=Full
#     Run Keyword If    '${Snapshot_status}'=='PASS'    Run Keywords    Connect to Netact server Snapshot
#     Save Snapshot for cOAM to Netact    coverage=Minor
#    Run Keyword If    '${Snapshot_status}'=='PASS'    Run Keywords    Connect to Netact server Snapshot    
#     Retrieve Snapshot in Netact
#     Copy Log Files
# 
# 	
# [1][2.0]5GC000551-C_TC_C#1_Configure Alarms triggering Snapshot
#     [Documentation]    Description: Creat TRBLCADM with parameter diagSnapDestination netact and Fault 61649
#     5GC000551_CLASSICAL Setup
#     Log to console    Creat TRBLCADM with parameter diagSnapDestination netact and Fault 61649
#     wait until keyword succeeds     5min    30s
# 	...      coam.connect to   bts_host=${WEBUI_URL}   name=coam_admin
#     login to WEBEM selenium coam
#     Set mrbtsId variable
#     Fault snapshot triggers parameter creation
#     Reload webpage and logout
#     coam.teardown  connection=coam_admin
# 
# 
# [1]5GC000551-C_TC_C#2_Generate alarms triggering snapshot
#     [Documentation]    Description: Generate Fault 61649 triggering snapshot
#     [Teardown]     5GC000551_CLASSICAL Teardown
#     Log to console    Generate Fault 61649 triggering snapshot
#     Get SW version
#     Check number of snapshot on NetAct
#     ${TARGET}  Evaluate  ${TEST_STEP.split("\r\n")[0]} + 1
#     ${snapshot_TARGET}=    set variable    ${TARGET}
#     Set Global Variable    ${snapshot_TARGET}
#     Run keyword and continue on failure  coam.connect_to  bts_host=${ASIK_IP_LMP}  bts_port=${COAM_ADMIN_PORT}  username=${COAM_ADMIN_username}
#     ...  password=${COAM_ADMIN_password}  use_ssl=True  update_interval=5000  name=coam_admin_lmp
#     wait until keyword succeeds     5min    30s
#     ...      coam.connect to   bts_host=${WEBUI_URL}   name=coam_admin
#     Run keyword and continue on failure  Wait For Fault to appear in WebEM    FaultID=${FaultLMP}
#     Run keyword and continue on failure  coam.teardown  connection=coam_admin_lmp
#     Run keyword and continue on failure  Wait For Fault to disappear in WebEM    FaultID=${FaultLMP}
#     Sleep  400s
#     Wait until Keyword Succeeds    900s    60s    Check if Snapshot is colleted
# 
# 
