# *** Settings ***
# Documentation
# ...  author: Wang Dali
# ...  contact: dali.wang@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Common.Common Setup
# Suite Teardown   Common.Common Teardown
# #Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASKEY_SA_ASOEB1_3xAZQJ    SBTS00    CRT_UTE    PY36
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# ${BTS}   ${tl.gnbs[0].instance_id}
# #${LSS_Server_ip}   ${tl.test_pc.default_ssh_connection_details.addr}
# ${LSS_Server_ip}   ${tl.test_pcs[0].default_ssh_connection_details.addr}
# ${LSS_Server_Username}   coam
# ${LSS_Server_Password}   zO&n1W*ktp7
# ${LSS_Server_Port_Num}   22
# ${NETACT_NAME}    HAN
# #${Netact_Server_ip}    10.108.248.82
# ${Netact_Server_ip}    10.107.183.26
# ${Netact_Server_Username}    omc
# ${Netact_Server_Password}   Nokia126_
# ${distName}    "MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1"
# ${value1}     {"faultNumber": "61699","triggerType": "onFaultCancellation"}
# ${value2}     {"faultNumber": "4459","triggerType": "onFaultDetection"}
# ${parameter1}   [{"parameterName": "faultSnapshotTriggers","operation": "update","value": [${value1},${value2}]}]
# *** Test Cases ***
# 
# 5GC000507_11_Automatically_triggered_snapshot_counter_reset
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   5h
#     Case Setup  onFaultDetection    4459    2
#     COAM Backup SCF    file_name=507_11_beforereset.xml
#     COAM Reset Site
#     Run Keyword And Ignore Error   COAM WEBUI Logout
#     Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
#     Wait for Cell Onair    10min   cell_index=1
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     : FOR    ${i}    IN RANGE    2
#      Trigger snapshot by fault4459
#     END
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Check Fault Raise Status    4459
#     sleep  1min
#     Check Snapshot NOT collected to LSS
#     Remove LSS Snapshot
#     Trigger snapshot by fault61524
#     [Teardown]
# 
# 5GC000507_15_Automatically_triggered_snapshot_sent_to_LSS_on_fault_detection
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     Case Setup  onFaultDetection    4459
#     Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
#     Wait Until Keyword Succeeds   10m   1m   COAM Login
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     Sleep   10s
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Check Fault Raise Status    4459
#     sleep  1min
#     Check Snapshot Upload to LSS Status
#     [Teardown]
# 
# 5GC000507_14_Automatically_triggered_snapshot_sent_to_LSS_on_fault_clear
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     Case Setup  onFaultCancellation    4459
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Sleep   10s
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     sleep  1min
#     Check Snapshot Upload to LSS Status
#     [Teardown]
# 
# 5GC000507_16_Configuration_of_automatic_snapshot_collection_via_NetAct
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     Config Netact Server on WebEM    onFaultDetection
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     sleep  1min
#     Check Snapshot Upload to Netact
#     Remove Netact Snapshot
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     [Teardown]
# 
# 
# 5GC000507_12_Automatically_triggered_snapshot_reconfiguration
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     Case Setup  onAlarmSend    10
#     COAM Perform Delta Recommission
#         ...   delta_file=[{"distName": ${distName},"operation": "update","parameters": ${parameter1}}]
#     [Teardown]
# 
# 
# 5GC000507_13_Automatically_triggered_snapshot_sent_to_LSS_on_alarm_raise
#     [Tags]   AUTHOR_dali.wang@nokia-sbell.com
#     [Timeout]   1h
#     [Setup]   Case Setup  onAlarmSend    4459
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     Sleep   10s
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Check Fault Raise Status    4459
#     Sleep   10s
#     Check Snapshot Upload to LSS Status
#     run keyword and ignore error     selenium_coam.delete_parameter     dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...    filter_param=Fault snapshot triggers
#     sleep    2s
#     Validate and Activate Parameter
#     [Teardown]
# 
# 5GC000507_Fault_triggered_snapshot
#     [Setup]    run keywords    Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     ...    AND      robot_common_operations.Common Case Setup
#    List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
#    [Teardown]   robot_common_operations.Common Case Teardown
