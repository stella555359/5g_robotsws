*** Settings ***
Documentation
    ...  This TC checks the statistics of suppressed alarms using M2M interface.
    ...  Change parameter value of fault4592CancellationTimer to be 1800s.
    ...  Perform vCU reset and verify if fault 4592 is visible on vCU alarms active tab.
    ...  Set actAlarmsSuppression to 'suppressAlarms' and suppressedFaultList with parameters alarmSeverity=MINOR_AND_WARNING and faultId=4592.
    ...  Activate the plan and verify if fault 4592 is not visible anymore in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if fault 4592 with alarm id 7115 is visible in suppressed alarms view.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed fault.
    ...  Send the specific command for getting the statistics output using M2M interface.
    ...  Verify the output to contain all specific titles and generic information about the suppressed fault.
    ...  Disable actAlarmsSuppression parameter and delete all instances.
    ...  Set actAlarmsSuppression to 'suppressAlarms' and suppressedAlarmList with parameters alarmSeverity=MINOR_AND_WARNING and alarmId=7115.
    ...  Activate the plan and verify if alarm id 7115 is not visible anymore in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if fault 4592 with alarm id 7115 is visible in suppressed alarms view.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed fault.
    ...  Send the specific command for getting the statistics output using M2M interface.
    ...  Verify the output to contain all specific titles and generic information about the suppressed fault.
    ...  Disable actAlarmsSuppression parameter and delete all instances.
    ...  Cancel fault id 4592 and verify if fault is cleared.
    ...  As recovery action, if test fail the last 2 steps with disabling the parameter and canceling fault 4592 will be perform.


Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/vcu_WebEM_general.robot
Resource  ../../common_resources/M2M_Interface.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29159
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29159 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vCU25R3  FEATURE-CB010788

    Step1: Generate fault id 4592
    Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Step3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Step4: Get the local copy of statistics file using M2M REST API
    Step5: Verify the statistics file from M2M REST API
    Step6: Disable actAlarmsSuppression Parameter And Delete Instances
    Step7: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed alarm id
    Step8: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Step9: Get the local copy of statistics file using M2M REST API
    Step10: Verify the statistics file from M2M REST API
    Step11: Disable actAlarmsSuppression Parameter And Delete Instances
    Step12: Cancel fault id 4592 and verify if fault is cleared


Step1: Generate fault id 4592
    Log  \nStep1: Generate fault id 4592  console=true
    Generate Fault Id 4592 On vCU And Verify If Fault Is Visible In Active Alarms  ${RECOVERY_TIMEOUT}


Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Log  \nStep2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id  console=true
    ${actAlarmsSuppression_parameter}  Create Dictionary  parameterName=actAlarmsSuppression  value=suppressAlarms  operation=update
    ${allowedAlarmList_parameter}  Create Dictionary  parameterName=allowedAlarmList  operation=delete
    ${allowedFaultList_parameter}  Create Dictionary  parameterName=allowedFaultList  operation=delete
    ${suppressedAlarmList_parameter}  Create Dictionary  parameterName=suppressedAlarmList  operation=delete
    ${suppressedFaultList_parameter}  Create Dictionary  parameterName=suppressedFaultList  operation=delete
    ${severity_faultid_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  faultId=4592
    ${severity_faultid_list}  Create List  ${severity_faultid_dict}
    ${suppressedFaultList_parameter_created}  Create Dictionary  parameterName=suppressedFaultList  value=${severity_faultid_list}  operation=create
    ${parameters_change_list}  Create List  ${actAlarmsSuppression_parameter}  ${allowedAlarmList_parameter}  ${allowedFaultList_parameter}
    ...  ${suppressedAlarmList_parameter}  ${suppressedFaultList_parameter}  ${suppressedFaultList_parameter_created}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAlarmsSuppression was changed to suppressAlarms![OK]  console=true
    Log  Parameters allowedAlarmList, allowedFaultList, suppressedAlarmList and suppressedFaultList was deleted initially![OK]  console=true
    Log  Parameter suppressedFaultList was added with parameters alarmSeverity=MINOR_AND_WARNING and faultId=4592![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true


Step${index}: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Log  \nStep${index}: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM  console=true
    Sleep  10s  Time for alarm to not be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Not Contain Value  ${active_faults_id_list}  4592
    Log  Fault Id 4592 is not visible on active alarms after suppression![OK]  console=true
    IF  ${index}==8
        ${active_alarms_id_list}  Get List Of Active Alarm Ids From vCU WebEM
        List Should Not Contain Value  ${active_alarms_id_list}  7115
        Log  Alarm Id 7115 is not visible on active alarms after suppression![OK]  console=true
    END
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  4592  7115
    Save Statictics File And Move It To Test Results Directory For vCU  WebEM_step${index}
    ${suppressed_content}  OperatingSystem.Get File
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_WebEM_step${index}.txt
    Verify The Titles From The Statistics File With Suppressed Alarms  ${suppressed_content}
    Verify Generated Fault Info From The Statistics File With Suppressed Alarms For vCU  ${suppressed_content}  7115  BASE STATION INFORMATION  4592
    ...  BTS Reset Cause


Step${index}: Get the local copy of statistics file using M2M REST API
    Log  \nStep${index}: Get the local copy of statistics file using M2M REST API  console=true
    Login Using M2M Interface  ${VCU_OAM_IP}
    ${ALARM_SUPPRESSED_OUTPUT}  Run M2M Command  GET
    ...  https://${VCU_OAM_IP}/api/licensed/v2/alarms/suppressed  Bearer  ${TOKEN}
    Set Test Variable  ${ALARM_SUPPRESSED_OUTPUT}

    [Teardown]  Logout Using M2M Interface  ${VCU_OAM_IP}


Step${index}: Verify the statistics file from M2M REST API
    Log  \nStep${index}: Verify the statistics file from M2M REST API  console=true
    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${items_list}  Create List  "alarmId" : "7115"  "alarmName" : "BASE STATION INFORMATION"  "alarmSeverity" : "minor"
    ...  alarmingObject  all  current10s  currentDay  currentHour  currentMin  "faultId" : "4592"  "faultName" : "BTS Reset Cause"
    ...  last10s  lastDay  lastHour  lastMin  timeStamp  total  ${date}T
    FOR  ${item}  IN  @{items_list}
        Should Contain  ${ALARM_SUPPRESSED_OUTPUT}  ${item}  The output doesn't contain ${item} item![NOK]
        Log  The output contains ${item} item![OK]  console=true
    END


Step${index}: Disable actAlarmsSuppression Parameter And Delete Instances
    Log  \nStep${index}: Disable actAlarmsSuppression Parameter And Delete Instances  console=true
    Disable actAlarmsSuppression Parameter And Delete Instances For vCU
    Sleep  10s  Time for alarm to be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    ${active_alarms_id_list}  Get List Of Active Alarm Ids From vCU WebEM
    List Should Contain Value  ${active_faults_id_list}  4592
    List Should Contain Value  ${active_alarms_id_list}  7115
    Log  Fault Id 4592 with alarm id 7115 is visible on WebEM in active alarms after actAlarmsSuppression is disabled![OK]  console=true


Step7: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed alarm id
    Log  \nStep7: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed alarm id  console=true
    ${actAlarmsSuppression_parameter}  Create Dictionary  parameterName=actAlarmsSuppression  value=suppressAlarms  operation=update
    ${severity_alarmid_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  alarmId=7115
    ${severity_alarmid_list}  Create List  ${severity_alarmid_dict}
    ${suppressedAlarmList_parameter_created}  Create Dictionary  parameterName=suppressedAlarmList  value=${severity_alarmid_list}  operation=create
    ${parameters_change_list}  Create List  ${actAlarmsSuppression_parameter}  ${suppressedAlarmList_parameter_created}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VCU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAlarmsSuppression was changed to suppressAlarms![OK]  console=true
    Log  Parameter suppressedAlarmList was added with parameters alarmSeverity=MINOR_AND_WARNING and alarmId=7115![OK]  console=true
    vcu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true


Step12: Cancel fault id 4592 and verify if fault is cleared
    Log  \nStep12: Cancel fault id 4592 and verify if fault is cleared  console=true
    Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s  ${RECOVERY_TIMEOUT}


TC Setup
    Common VCU Setup
    VCU WebEM Setup
    Modify Resource Search Order  WebEM__vCU__Statistics_of_suppressed_minor_warning_alarms_using_M2M_rest_API


TC Teardown
    Run keyword if test failed  Run keywords  Disable actAlarmsSuppression Parameter And Delete Instances For vCU  AND
    ...  Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s  ${RECOVERY_TIMEOUT}
    VCU WebEM Teardown
    Common VCU Teardown
