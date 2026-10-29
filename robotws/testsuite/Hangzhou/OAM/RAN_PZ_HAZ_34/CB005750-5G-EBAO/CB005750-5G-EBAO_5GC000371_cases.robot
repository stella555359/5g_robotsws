# *** Settings ***
# Suite Setup           robot_common_operations.Common Suite Setup
# Suite Teardown        robot_common_operations.Common Suite Teardown
# Test Setup            Run Keywords    robot_common_operations.Common Case Setup    AND    Case preparation
# Test Teardown         robot_common_operations.Common Case Teardown
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...    author: fangmin.wu
# ...    contact: fangmin.wu@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature: CB5750-EBAO
# 
# Resource    ./Resources/CB005750-5G-EBAO_Common_Keywords.robot
# Library     BuiltIn
# 
# Force Tags    CRT_TRUNK    CRT_21A           CRT_21B
# ...    PY36
# 
# *** Variables ***
# ${TS_LOG_PATH_BASE}    /home/ute/Downloads/
# ${delta_file_path}         robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/CB005750-5G-EBAO/Resources                     
# ${delta_LSS_10_onFaultDet_activate}=        Delta_LSS_10_onFaultDet_activate.json
# ${delta_LSS_10_onAlarmSend_activate}=       Delta_LSS_10_onAlarmSend_activate.json
# ${delta_LSS_6450_onFaultDet_activate}=      Delta_LSS_6450_onFaultDet_activate.json
# ${delta_LSS_deactivate}=                    Delta_LSS_deactivate.json
# ${delta_precondition}=                      Delta_Precondition.json
# 
# *** Test Cases ***
# [1]backup_CB005750-5G-EBAO_5GC000371_001_Check_RU_restart_indication_fault4527_is_sent_to_OAM
#     [Setup]
#     Connect to RU and generate Fault 4527
#     Wait until cell is on air status
#     Collect snapshot and check ru specific log
#     [Teardown]
# 
# [1]backup_CB005750-5G-EBAO_5GC000371_002_RAU_collection_of_its_own_RAU_logs
#     [Setup]    Case preparation
#     Connect to and restart ABIO
#     Wait until cell is on air status
#     Check specific log in the snapshot    specific_file=BTS${tl.gnbs[0].global_bts_id}_123D_pm_1_syslog.zip
#     ...    key_string=Error    case_type=rau
#     [Teardown]    Case teardown
# 
# [1]CB005750-5G-EBAO_5GC000371_003_CU_collection_of_its_own_CU_full_restart_logs
#     [Setup]
#     Connect to and restart ASIL
#     Wait until cell is on air status
#     Check specific log in the snapshot     specific_file=BTS${tl.gnbs[0].global_bts_id}_1011_blackbox.xz
#     ...    key_string=crash    case_type=cu
#     [Teardown]    Case teardown
# 
# [1]CB005750-5G-EBAO_5GC000371_001_Check_RU_restart_indication_fault4527_is_sent_to_OAM
#     ADMIN Perform Delta Recommissioning    delta_file=${delta_file_path}/${delta_precondition}    skip_parameter_relation_errors=True
#     run keyword and ignore error  Remove Snapshot from LSS server
#     ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_path}/${delta_LSS_10_onAlarmSend_activate}
#     ...                                                 skip_parameter_relation_errors=True
#     Sleep  30s
#     Trigger Fault 10 by radio reboot
#     Wait For Fault with Alarm to appear    FaultID=10   AlarmID=7116
#     Wait For Fault with Alarm to disappear    FaultID=10   AlarmID=7116
#     log to console  check if snapshot exist on LSS
#     wait until keyword succeeds  900  60  Check if Snapshot is collected on LSS
#     wait until keyword succeeds  300  30   Check if BTS_metadata.txt exists
#     ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_path}/${delta_LSS_deactivate}
#     ...                                                 skip_parameter_relation_errors=True
#     run keyword and ignore error  Remove Snapshot from LSS server
# 
# [1]CB005750-5G-EBAO_5GC000371_002_RAU_collection_of_its_own_RAU_logs
#     ADMIN Perform Delta Recommissioning    delta_file=${delta_file_path}/${delta_precondition}    skip_parameter_relation_errors=True
#     run keyword and ignore error  Remove Snapshot from LSS server
#     ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_path}/${delta_LSS_6450_onFaultDet_activate}
#     ...                                                 skip_parameter_relation_errors=True
#     Sleep  30s
#     Connect to and restart ASIL
#     Wait For Fault with Alarm to appear    FaultID=6450   AlarmID=7115
#     Wait until cell is on air status
#     #Wait For Fault with Alarm to disappear    FaultID=6450   AlarmID=7115
#     log to console  check if snapshot exist on LSS
#     wait until keyword succeeds  900  60  Check if Snapshot is collected on LSS
#     wait until keyword succeeds  300  30   Check if BTS_metadata.txt exists
#     ADMIN Perform Delta Recommissioning                 delta_file=${delta_file_path}/${delta_LSS_deactivate}
#     ...                                                 skip_parameter_relation_errors=True
#     run keyword and ignore error  Remove Snapshot from LSS server
# 
# 
# 
# *** Keywords ***
# 
# Case preparation
#     COAM Create log directory
#     Connect to gnb coam via ssl
#     PREPOST Get Bts Name
#     Wait until cell is on air status    timeout=1 min
# 
# Wait until cell is on air status
#     [Documentation]  Author: Jin Journey
#     [Arguments]  ${timeout}=15 min    ${connection}=GNB_OAM
#     log    ${timeout}
#     Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
#     Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
#     Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair
# 
# Case teardown
#     COAM Teardown gnb connections
