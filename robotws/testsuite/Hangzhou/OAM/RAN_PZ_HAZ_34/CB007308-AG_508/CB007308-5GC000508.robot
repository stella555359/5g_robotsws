# *** Settings ***
# Documentation
# ...    Author: Fred.li
# ...    Contact: fred.li@nokia-sbell.com
# 
# Resource   ./Resource/Common.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup    Common Setup
# Suite Teardown   Common Teardown
# #Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASKEY_SA_ASOEB1_3xAZQJ
#     ...   SBTS00    CRT_UTE    PY36
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# ${BTS}   ${tl.gnbs[0].instance_id}
# ${LSS_Server_ip}   ${tl.test_pcs[0].default_ssh_connection_details.addr}
# ${LSS_Server_Username}   coam
# ${LSS_Server_Password}   zO&n1W*ktp7
# ${LSS_Server_Port_Num}   22
# #${Netact_Server_ip}    10.108.248.82
# ${Netact_Server_ip}    10.107.183.26
# ${Netact_Server_Username}    omc
# ${Netact_Server_Password}   Nokia126_
# ${distName}    "MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1"
# ${Wrong_LSS_Server_ip}   10.57.111.111
# ${parameter1}   [{"parameterName": "syslogSubstringTrigger","operation": "delete"}]
# 
# *** Test Cases ***
# [1]5GC000508-A_Syslog_substring_Trigger_activated
#     [Tags]   AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   30min
#     [Documentation]    The purpose of this test case is to check if defined substring
#     ...                in syslog stream can be activated
#     Case Setup
#     Wait for Cell Onair   10min   1
#     Case Teardown
#     [Teardown]
# 
# [1]5GC000508-A_Syslog_substring_Trigger_not_activated
#     [Tags]   AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   30min
#     [Documentation]    The purpose of this test case is to check if defined substring
#     ...                in syslog stream can be activated
#     Case Setup
#     COAM Perform Delta Recommission
#     ...   delta_file=[{"distName": ${distName},"operation": "update","parameters":${parameter1}}]
#     Wait for Cell Onair   10min   1
#     Case Teardown
#     [Teardown]
# 
# 
# [1]5GC000508-A_Snapshot_triggered_to_LSS
#     [Tags]   AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   1h
#     [Documentation]    The purpose of this test case is to check if defined substring
#     ...                in syslog stream will trigger snapshot collection and it is sent
#     ...                to remote destination: LSS server.
#     Case Setup
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Check Fault 4459 Raise Status
#     Sleep   10s
#     Check Snapshot Upload to LSS Status
#     Case Teardown
#     [Teardown]
# 
# [1]5GC000508-A_Snapshot_triggered_to_NetAct
#     [Tags]   AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   1h
#      Case Setup
# #    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
# #    Wait Until Keyword Succeeds   10m   1m   COAM Login
#     Config Netact Server on WebEM
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     sleep  15min
#     Check Fault 4459 Raise Status
#     Check Snapshot Upload to Netact
#     Remove Netact Snapshot
#     [Teardown]
# 
# [1]5GC000508-A_Snapshot_triggered_to_LSS_when_no_connection
#     [Tags]   AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   1h
# #    Wait Until Keyword Succeeds   10m   1m   COAM WEBUI Login
# #    Wait Until Keyword Succeeds   10m   1m   COAM Login
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Diagnostic Snapshot destination
#     ...                                new_value=lss
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Local symptoms server IP address
#     ...                                new_value=${Wrong_LSS_Server_ip}
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Local symptoms server IP port number
#     ...                                new_value=${LSS_Server_Port_Num}
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Syslog substring trigger
#     ...                                new_value=active 4459
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Check Fault 4459 Raise Status
#     Check Snapshot not Upload to LSS
#     [Teardown]
# 
# [1]5GC000508-A_Snapshot_triggered_to_LSS_ignored_15min
#     [Tags]   AUTHOR_fred.li@nokia-sbell.com
#     [Timeout]   1h
#     [Documentation]    The purpose of this test case is to check if defined substring
#     ...                in syslog stream will trigger snapshot collection and it is sent
#     ...                to remote destination: LSS server.
#     Case Setup
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Check Fault 4459 Raise Status
#     Sleep   5min
#     Check Snapshot Upload to LSS Status
#     Remove LSS Snapshot
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Sleep   15s
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=true
#     Run Keyword And Ignore Error   Validate and Activate Parameter
#     Check Fault 4459 Raise Status
#     sleep    1min
#     Check Snapshot not Upload to LSS
#     Sleep   10s
#     Case Teardown
#     [Teardown]
# 
# 5GC000508_Syslog_substring_triggered_automated_snapshot_collection
#     [Setup]    run keywords    Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     ...    AND      robot_common_operations.Common Case Setup
#     List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
#     [Teardown]   robot_common_operations.Common Case Teardown
# 
# *** Keyword ***
# Case Teardown
#     Modify Parameter enableDefaultPasswdAlarm   Active_Value=false
# 
# Modify Parameter enableDefaultPasswdAlarm
#     [Arguments]   ${Active_Value}
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/AMGR-1
#     ...                                filter_param=Enable default password alarm
#     ...                                new_value=${Active_Value}
# 
# Check Fault 4459 Clear Status
#     ${active_alarms}   taf_coam.COAM Get Active Alarms
#     :FOR   ${active_alarm}   IN   @{active_alarms}
#        Should Not Be Equal As Strings   ${active_alarm['faultId']}   4459
#     END
# 
# Check Fault 4459 Raise Status
#     ${active_alarms}   taf_coam.COAM Get Active Alarms
#     ${supplAlarmInfo}   Set Variable   NONE
#     :FOR   ${active_alarm}   IN   @{active_alarms}
#        ${supplAlarmInfo}   Set Variable If
#        ...   '${active_alarm['faultId']}'=='4459'   ${active_alarm['supplAlarmInfo']}
#        ...   '${active_alarm['faultId']}'!='4459'   ${supplAlarmInfo}
#        Exit For Loop If   '${active_alarm['faultId']}'=='4459'
#     END
#     Should Not Be Equal As Strings   ${supplAlarmInfo}   NONE
# 
# Remove LSS Snapshot
#     csn.connect to   hostname=${LSS_Server_ip}   username=${LSS_Server_Username}    password=${LSS_Server_Password}    alias=lss
#     csn.execute   command=cd /home/coam/;rm -rf Snapshot_MRBTS-${BTS}_*   connection=lss
#     csn.disconnect   connection=lss
# 
# Config LSS Server on WebEM
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Diagnostic Snapshot destination
#     ...                                new_value=lss
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Local symptoms server IP address
#     ...                                new_value=${LSS_Server_ip}
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Local symptoms server IP port number
#     ...                                new_value=${LSS_Server_Port_Num}
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Syslog substring trigger
#     ...                                new_value=active 4459
# 
# Check Snapshot Upload to LSS Status
#     csn.connect to    hostname=${LSS_Server_ip}   username=${LSS_Server_Username}   password=${LSS_Server_Password}    alias=lss
#     ${Snapshot_Output}   csn.execute   command=cd /home/coam/;ls -al | grep Snapshot_MRBTS-${BTS}_*   connection=lss
#     Should Not Be Empty   ${Snapshot_Output}
#     csn.disconnect    connection=lss
# 
# Check Snapshot not Upload to LSS
#     csn.connect to    hostname=${LSS_Server_ip}   username=${LSS_Server_Username}   password=${LSS_Server_Password}    alias=lss
#     ${Snapshot_Output}   csn.execute   command=cd /home/coam/;ls -al | grep Snapshot_MRBTS-${BTS}_*   connection=lss
#     Should Be Empty   ${Snapshot_Output}
#     csn.disconnect    connection=lss
# 
# Validate and Activate Parameter
#     selenium_coam.validate_plan
#     selenium_coam.activate_plan   activate_plan_despite_errors=True    timeout=120
# 
# Wait for Cell Onair
#     [Arguments]   ${wait_timer}   ${cell_index}
#     ${status}   run keyword and return status   wait until keyword succeeds   ${wait_timer}   20s
#     ...   COAM WEBUI Check Cell Status   cell_index=${cell_index}
#     run keyword unless   ${status}   selenium_coam.refresh_page
#     run keyword unless   ${status}   COAM WEBUI Check Cell Status   cell_index=${cell_index}
#     run keyword unless   ${status}   Log to Console   Found cell ${cell_index} status not refresh automatically
# 
# 
# Config Netact Server on WebEM
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Diagnostic Snapshot destination
#     ...                                new_value=netact
#     Run Keyword And Ignore Error   selenium_coam.set_parameter_value  dist_name=MRBTS-${BTS}/MNL-1/MNLENT-1/TRBLCADM-1
#     ...                                filter_param=Syslog substring trigger
#     ...                                new_value=active 4459
# 
# Remove Netact Snapshot
#     csn.connect to    hostname=${Netact_Server_ip}   username=${Netact_Server_Username}   password=${Netact_Server_Password}    alias=Netact
#     ${Snapshot_Output}   csn.execute   command=cd /d/oss/global/diagsnap/ne3sws;rm -rf Snapshot_MRBTS-${BTS}_*   connection=Netact
#     csn.disconnect    connection=Netact
# 
# Check Snapshot Upload to Netact
#     csn.connect to    hostname=${Netact_Server_ip}   username=${Netact_Server_Username}   password=${Netact_Server_Password}    alias=Netact
#     ${Snapshot_Output}   csn.execute   command=cd /d/oss/global/diagsnap/ne3sws;ls -al | grep "Snapshot_MRBTS-${BTS}_*"   connection=Netact
#     Should Not Be Empty   ${Snapshot_Output}
#     csn.disconnect    connection=Netact
