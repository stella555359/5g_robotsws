*** Settings ***
Documentation
    ...  The purpose of this test case is verify the statistics of suppressed minor and warning alarms using ADMIN CLI.
    ...  First, we need to run setup for admin cli and remove allowed and suppressed parameters.
    ...  Then, change parameters actAlarmsSuppression on suppressAlarms and add 4655 and 61524 fault ids in suppressedFaultList.
    ...  Sending getSuppressedAlarms command and save the output in BTSFiles directory.
    ...  Verify the output file to contains the generic titles and the specific faults ids and faults names.
    ...  Verify if the specific faults are not visible anymore in active alarms from WebEM.
    ...  Remove allowed and suppressed parameters.
    ...  Then, change parameters actAlarmsSuppression on suppressAlarms and alarm id 7220 to suppressedAlarmList.
    ...  Sending getSuppressedAlarms command and save the output in BTSFiles directory.
    ...  Verify the output file to contains the generic titles and the specific alarm id.
    ...  Verify if the specific faults with the specific alarm is are not visible anymore in active alarms from WebEM.
    ...  Remove allowed and suppressed parameters.
    ...  Then, change parameters actAlarmsSuppression on allowAlarms and add fault id 61524 to allowedFaultList.
    ...  Sending getSuppressedAlarms command and save the output in BTSFiles directory.
    ...  Verify the output file to contains the generic titles and the specific fault id to not be visible in the file.
    ...  Verify if the specific fault is the only one visible in active alarms from WebEM.
    ...  Remove allowed and suppressed parameters.
    ...  In case the test will be failed, the initial SCF will be loading.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  #Time for SBTS to recover.


*** Keywords ***
TC__WebEM__Statistics_of_suppressed_minor_warning_alarms_using_Admin_CLI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28905
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28905 - Initial TAT creation
    ...  - 07.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29659 - Change parameters via admin api instead of SCF

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS25R2  FEATURE-CB010788

    Step1: Setup Admin CLI And Remove Allowed And Suppressed Parameters
    Step2: Change Parameters actAlarmsSuppression On suppressAlarms And Add 4655 And 61524 Fault Ids In suppressedFaultList
    Step3: Sending getSuppressedAlarms Command Via ADMIN CLI
    Step4: Verify The Output From getSuppressedAlarms Command
    Step5: Change Parameters actAlarmsSuppression On suppressAlarms And Add Alarm Id 7220 To suppressedAlarmList
    Step6: Sending getSuppressedAlarms Command Via ADMIN CLI
    Step7: Verify The Output From getSuppressedAlarms Command
    Step8: Change Parameters actAlarmsSuppression On allowAlarms And Add Fault Id 61524 To allowedFaultList
    Step9: Sending getSuppressedAlarms Command Via ADMIN CLI
    Step10: Verify The Output From getSuppressedAlarms Command
    Step11: Remove Allowed And Suppressed Parameters


Step1: Setup Admin CLI And Remove Allowed And Suppressed Parameters
    Log  \nStep1: Setup Admin CLI And Remove Allowed And Suppressed Parameters  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Change ActCli Parameter  true


Step2: Change Parameters actAlarmsSuppression On suppressAlarms And Add 4655 And 61524 Fault Ids In suppressedFaultList
    Log  \nStep2: Change Parameters actAlarmsSuppression On suppressAlarms And Add 4655 And 61524 Fault Ids In suppressedFaultList  console=true
    ${suppress_fault_list}  Create List
    ${suppress_fault_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  faultId=4655,61524
    Append To List  ${suppress_fault_list}  ${suppress_fault_dict}
    Add Given Fault And Severity To SuppressedFaultList  ${suppress_fault_list}


Step3: Sending getSuppressedAlarms Command Via ADMIN CLI
    Log  \nStep3: Sending getSuppressedAlarms Command Via ADMIN CLI  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getSuppressedAlarms"}}
    Log  \nSending command via Admin CLI for getSuppressedAlarms with suppressed fault list...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/suppressed_fault_list.txt
    File Should Not Be Empty  ${BTS_FILES}/suppressed_fault_list.txt  msg='${BTS_FILES}/suppressed_fault_list.txt' is empty
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}. [OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}. [NOK]
    END


Step4: Verify The Output From getSuppressedAlarms Command
    Log  \nStep4: Verify The Output From getSuppressedAlarms Command  console=true
    ${suppressed_fault_list_content}  OperatingSystem.Get File  ${BTS_FILES}/suppressed_fault_list.txt
    Verify The Titles From The Specific File  ${suppressed_fault_list_content}
    Should Contain  ${suppressed_fault_list_content}  minor  The file doesn't contain minor![NOK]
    Log  The saved file contains minor![OK]  console=true
    Should Contain  ${suppressed_fault_list_content}  (4655)EFaultId_EnabledServiceAccountRootAccessAl
    ...  The file doesn't contain (4655)EFaultId_EnabledServiceAccountRootAccessAl![NOK]
    Log  The saved file contains (4655)EFaultId_EnabledServiceAccountRootAccessAl![OK]  console=true
    Should Contain  ${suppressed_fault_list_content}  Service account root access is enabled
    ...  The file doesn't contain Service account root access is enabled![NOK]
    Log  The saved file contains Service account root access is enabled![OK]  console=true
    Should Contain  ${suppressed_fault_list_content}  (61524)EFaultId_SshEnabled
    ...  The file doesn't contain (61524)EFaultId_SshEnabled![NOK]
    Log  The saved file contains (61524)EFaultId_SshEnabled![OK]  console=true
    Should Contain  ${suppressed_fault_list_content}  SSH enabled  The file doesn't contain SSH enabled![NOK]
    Log  The saved file contains SSH enabled![OK]  console=true
    ${active_alarms}  coam.Get active alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Should Not Be Equal  ${alarm}[faultId]  4655  Fault ID 4655 is still visible in active alarms![NOK]
        Should Not Be Equal  ${alarm}[faultName]  Service account root access is enabled
        ...  Fault name Service account root access is enabled is still visible in active alarms![NOK]
        Should Not Be Equal  ${alarm}[faultId]  61524  Fault ID 61524 is still visible in active alarms![NOK]
        Should Not Be Equal  ${alarm}[faultName]  SSH enabled  Fault name SSH enabled is still visible in active alarms![NOK]
    END
    Log  Faults 4655 and 61524 are not visible anymore in WebEM active alarms![OK]  console=true


Step5: Change Parameters actAlarmsSuppression On suppressAlarms And Add Alarm Id 7220 To suppressedAlarmList
    Log  \nStep5: Change Parameters actAlarmsSuppression On suppressAlarms And Add Alarm Id 7220 To suppressedAlarmList  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${suppress_alarm_list}  Create List
    ${suppress_alarm_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  alarmId=7220
    Append To List  ${suppress_alarm_list}  ${suppress_alarm_dict}
    Add Given Alarm And Severity To SuppressedAlarmList  ${suppress_alarm_list}


Step6: Sending getSuppressedAlarms Command Via ADMIN CLI
    Log  \nStep6: Sending getSuppressedAlarms Command Via ADMIN CLI  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getSuppressedAlarms"}}
    Log  \nSending command via Admin CLI for getSuppressedAlarms with suppressed alarm list...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/suppressed_alarm_list.txt
    File Should Not Be Empty  ${BTS_FILES}/suppressed_alarm_list.txt  msg='${BTS_FILES}/suppressed_alarm_list.txt' is empty
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}. [OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}. [NOK]
    END


Step7: Verify The Output From getSuppressedAlarms Command
    Log  \nStep7: Verify The Output From getSuppressedAlarms Command  console=true
    ${suppressed_alarm_list_content}  OperatingSystem.Get File  ${BTS_FILES}/suppressed_alarm_list.txt
    Verify The Titles From The Specific File  ${suppressed_alarm_list_content}
    Should Contain  ${suppressed_alarm_list_content}  minor  The file doesn't contain minor![NOK]
    Log  The saved file contains minor![OK]  console=true
    Should Contain  ${suppressed_alarm_list_content}  7220  The file doesn't contain 7220![NOK]
    Log  The saved file contains 7220![OK]  console=true
    Should Contain  ${suppressed_alarm_list_content}  BASE STATION SECURITY PROBLEM
    ...  The file doesn't contain BASE STATION SECURITY PROBLEM![NOK]
    Log  The saved file contains BASE STATION SECURITY PROBLEM![OK]  console=true
    ${active_alarms}  coam.Get active alarms
    ${length}  Get Length  ${active_alarms}
    IF  ${length} == 0
        Log  Faults with alarm id 7220 are not visible anymore in WebEM active alarms![OK]  console=true
        RETURN
    END
    FOR  ${alarm}  IN  @{active_alarms}
        Should Not Be Equal  ${alarm}[alarmId]  7220  Alarm ID 7220 is still visible in active alarms![NOK]
    END
    Log  Faults with alarm id 7220 are not visible anymore in WebEM active alarms![OK]  console=true


Step8: Change Parameters actAlarmsSuppression On allowAlarms And Add Fault Id 61524 To allowedFaultList
    Log  \nStep8: Change Parameters actAlarmsSuppression On allowAlarms And Add Fault Id 61524 To allowedFaultList  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    ${allowed_fault_list}  Create List
    ${allowed_fault_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  faultId=61524
    Append To List  ${allowed_fault_list}  ${allowed_fault_dict}
    Add Given Fault And Severity To AllowedFaultList  ${allowed_fault_list}


Step9: Sending getSuppressedAlarms Command Via ADMIN CLI
    Log  \nStep9: Sending getSuppressedAlarms Command Via ADMIN CLI  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getSuppressedAlarms"}}
    Log  \nSending command via Admin CLI for getSuppressedAlarms with allowed fault list...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/allowed_fault_list.txt
    File Should Not Be Empty  ${BTS_FILES}/allowed_fault_list.txt  msg='${BTS_FILES}/allowed_fault_list.txt' is empty
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}. [OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}. [NOK]
    END


Step10: Verify The Output From getSuppressedAlarms Command
    Log  \nStep10: Verify The Output From getSuppressedAlarms Command  console=true
    ${allowed_fault_list_content}  OperatingSystem.Get File  ${BTS_FILES}/allowed_fault_list.txt
    Verify The Titles From The Specific File  ${allowed_fault_list_content}
    Should Contain  ${allowed_fault_list_content}  minor  The file doesn't contain minor![NOK]
    Log  The saved file contains minor![OK]  console=true
    Should Contain  ${allowed_fault_list_content}  7220  The file doesn't contain 7220![NOK]
    Log  The saved file contains 7220![OK]  console=true
    Should Contain  ${allowed_fault_list_content}  BASE STATION SECURITY PROBLEM
    ...  The file doesn't contain BASE STATION SECURITY PROBLEM![NOK]
    Log  The saved file contains BASE STATION SECURITY PROBLEM![OK]  console=true
    Should Not Contain  ${allowed_fault_list_content}  61524
    ...  The file contains 61524![NOK]
    Log  The saved file doesn't contain 61524![OK]  console=true
    Should Not Contain  ${allowed_fault_list_content}  SSH enabled
    ...  The file contains SSH enabled![NOK]
    Log  The saved file doesn't contain SSH enabled![OK]  console=true
    ${active_alarms}  coam.Get active alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Should Be Equal  ${alarm}[faultId]  ${61524}  Fault ID 61524 is not visible in active alarms![NOK]
    END
    Log  Fault ID 61524 is the only fault visible in WebEM active alarms![OK]  console=true


Step11: Remove Allowed And Suppressed Parameters
    Log  \nStep11: Remove Allowed And Suppressed Parameters  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword If Test Failed  Load A Specific SCF  ${COMMISSIONING_PATH}
    Common Test Teardown
