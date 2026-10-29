*** Settings ***
Documentation
    ...  The purpose of this test case is verify the disable suppression of minor warning alarms using ADMIN CLI.
    ...  First, we need to run setup for admin cli and remove allowed and suppressed parameters.
    ...  Then, change parameters actAlarmsSuppression on suppressAlarms and add 4655 and 61524 fault ids in suppressedFaultList.
    ...  Sending getSuppressedAlarms command and save the output in BTSFiles directory.
    ...  Verify the output file to contains the generic titles and the specific faults ids and faults names.
    ...  Verify if the specific faults are not visible anymore in active alarms from WebEM.
    ...  Change parameter actAlarmsSuppression on disabled and wait until all cells are onAir.
    ...  Sending getSuppressedAlarms command and save the output in BTSFiles directory.
    ...  Verify the output file to contains only the generic titles and nothing more.
    ...  Verify if the initial faults are still visible in active alarms from WebEM.
    ...  In case the test will be failed, the initial SCF will be loading.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  #Time for SBTS to recover.


*** Keywords ***
TC__WebEM__Disable_suppression_of_minor_warning_alarms
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28904
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 25.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28904 - Initial TAT creation
    ...  - 07.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29660 - Change parameters via admin api instead of SCF

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS25R2  FEATURE-CB010788

    Step1: Setup Admin CLI And Remove Allowed And Suppressed Parameters
    Step2: Change Parameters actAlarmsSuppression On suppressAlarms And Add 4655 And 61524 Fault Ids In suppressedFaultList
    Step3: Sending getSuppressedAlarms Command Via ADMIN CLI
    Step4: Verify The Output From getSuppressedAlarms Command
    Step5: Change Parameters actAlarmsSuppression On Disabled
    Step6: Sending getSuppressedAlarms Command Via ADMIN CLI
    Step7: Verify The Output From getSuppressedAlarms Command


Step1: Setup Admin CLI And Remove Allowed And Suppressed Parameters
    Log  \nStep1: Setup Admin CLI And Remove Allowed And Suppressed Parameters  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Change ActCli Parameter  true
    ${active_alarms}  coam.Get active alarms
    ${ACTIVE_FAULT_IDS_LIST}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        Append To List  ${ACTIVE_FAULT_IDS_LIST}  ${alarm}[faultId]
    END
    Sort List  ${ACTIVE_FAULT_IDS_LIST}
    Set Test Variable  ${ACTIVE_FAULT_IDS_LIST}


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
    ${string_content_list}  Create List  minor  (4655)EFaultId_EnabledServiceAccountRootAccessAl  Service account root access is enabled
    ...  (61524)EFaultId_SshEnabled  SSH enabled
    FOR  ${string}  IN  @{string_content_list}
        Should Contain  ${suppressed_fault_list_content}  ${string}  The file doesn't contain ${string}![NOK]
        Log  The saved file contains ${string}![OK]  console=true
    END
    ${active_alarms}  coam.Get active alarms
    FOR  ${alarm}  IN  @{active_alarms}
        Should Not Be Equal  ${alarm}[faultId]  4655  Fault ID 4655 is still visible in active alarms![NOK]
        Should Not Be Equal  ${alarm}[faultName]  Service account root access is enabled
        ...  Fault name Service account root access is enabled is still visible in active alarms![NOK]
        Should Not Be Equal  ${alarm}[faultId]  61524  Fault ID 61524 is still visible in active alarms![NOK]
        Should Not Be Equal  ${alarm}[faultName]  SSH enabled  Fault name SSH enabled is still visible in active alarms![NOK]
    END
    Log  Faults 4655 and 61524 are not visible anymore in WebEM active alarms![OK]  console=true


Step5: Change Parameters actAlarmsSuppression On Disabled
    Log  \nStep5: Change Parameters actAlarmsSuppression On Disabled  console=true
    Remove Allowed And Suppressed Parameters From ALARMSUPP


Step6: Sending getSuppressedAlarms Command Via ADMIN CLI
    Log  \nStep6: Sending getSuppressedAlarms Command Via ADMIN CLI  console=true
    ${request}  Set Variable  {"requestId":1,"parameters":{"name":"getSuppressedAlarms"}}
    Log  \nSending command via Admin CLI for getSuppressedAlarms with disabled value...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  ${request}  output_file=${BTS_FILES}/disabled_value.txt
    File Should Not Be Empty  ${BTS_FILES}/disabled_value.txt  msg='${BTS_FILES}/disabled_value.txt' is empty
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}. [OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}. [NOK]
    END


Step7: Verify The Output From getSuppressedAlarms Command
    Log  \nStep7: Verify The Output From getSuppressedAlarms Command  console=true
    ${disabled_value_content}  OperatingSystem.Get File  ${BTS_FILES}/disabled_value.txt
    Verify The Titles From The Specific File  ${disabled_value_content}
    Should Not Contain Any  ${disabled_value_content}  minor  major  4654  61649  61652  61524  4655  msg=File contains faults![NOK]
    Log  In file content are visible only the titles![OK]  console=true
    ${active_alarms}  coam.Get active alarms
    ${fault_ids_list}  Create List
    FOR  ${alarm}  IN  @{active_alarms}
        Append To List  ${fault_ids_list}  ${alarm}[faultId]
    END
    Sort List  ${fault_ids_list}
    Lists Should Be Equal  ${ACTIVE_FAULT_IDS_LIST}  ${fault_ids_list}
    Log  No initial fault id was suppressed when actAlarmsSuppression has 'disabled' value.[OK]  console=true


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword If Test Failed  Load A Specific SCF  ${COMMISSIONING_PATH}
    Common Test Teardown
