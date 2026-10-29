*** Settings ***
Documentation
    ...  This TC checks the statistics of suppressed alarms before and after vCU reset.
    ...  Change parameter value of fault4592CancellationTimer to be 1800s.
    ...  Perform vCU reset and verify if fault 4592 is visible on vCU alarms active tab.
    ...  Set actAlarmsSuppression to 'suppressAlarms' and suppressedFaultList with parameters alarmSeverity=MINOR_AND_WARNING and faultId=4592.
    ...  Activate the plan and verify if fault 4592 is not visible anymore in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if fault 4592 with alarm id 7115 is visible in suppressed alarms view.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed fault.
    ...  Perform vCU reset and wait for all cells to be onAir.
    ...  Verify fault 4592 to not be visible in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if fault 4592 with alarm id 7115 is still visible in suppressed alarms view after reset.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed fault.
    ...  Disable actAlarmsSuppression parameter and delete all instances.
    ...  Cancel fault id 4592 and verify if fault is cleared.
    ...  As recovery action, if test fail the last 2 steps with disabling the parameter and canceling fault 4592 will be perform.


Resource  ../../common_resources/vcu_frame.robot
Resource  ../resources/vcu_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29158
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29158 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vCU25R3  FEATURE-CB010788

    Step1: Generate fault id 4592
    Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Step3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Step4: Perform vCU reset
    Step5: Verify if the statistics file persists after the BTS reset
    Step6: Disable actAlarmsSuppression Parameter And Delete Instances
    Step7: Cancel fault id 4592 and verify if fault is cleared


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


Step3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM
    Log  \nStep3: Log the statistics of suppressed alarms in the statistics file and verify the file saved from WebEM  console=true
    Sleep  10s  Time for alarm to not be visible anymore
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Not Contain Value  ${active_faults_id_list}  4592
    Log  Fault Id 4592 is not visible on active alarms after suppression![OK]  console=true
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  4592  7115
    Save Statictics File And Move It To Test Results Directory For vCU  before_reset
    ${suppressed_content}  OperatingSystem.Get File
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_before_reset.txt
    Verify The Titles From The Statistics File With Suppressed Alarms  ${suppressed_content}
    Verify Generated Fault Info From The Statistics File With Suppressed Alarms For vCU  ${suppressed_content}  7115  BASE STATION INFORMATION  4592
    ...  BTS Reset Cause


Step4: Perform vCU reset
    Log  \nStep4: Perform vCU reset  console=true
    vcu.Reset Cu
    ${ip_adresses}  Create List  ${VCU_OAM_IP}
    ${ping_lost_status}  Run Keyword And Return Status
    ...  ping.Wait For No Ping  ip_addresses=${ip_adresses}  timeout=120s
    Run Keyword If  ${ping_lost_status} == ${FALSE}
    ...  Fail  Ping not lost after vCU reset. [NOK]
    ${ping_regained_status}  Run Keyword And Return Status
    ...  ping.Wait For Ping  ip_addresses=${ip_adresses}  timeout=300s
    Run Keyword If  ${ping_regained_status} == ${FALSE}
    ...  Fail  Ping not regained after vCU reset. [NOK]
    Log  vCU reset is performed![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check VDU To Be OnAir
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Verify CU X2 Links States  ${AVAILABLE}  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check Cells On VDU To Be OnAir
    Log  vDU, cells and X2 Links are back on air! [OK]  console=true


Step5: Verify if the statistics file persists after the BTS reset
    Log  \nStep5: Verify if the statistics file persists after the BTS reset  console=true
    Sleep  10s  Time for alarm to not be visible anymore
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    List Should Not Contain Value  ${active_faults_id_list}  4592
    Log  Fault Id 4592 is not visible on active alarms after reset![OK]  console=true
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  4592  7115
    Save Statictics File And Move It To Test Results Directory For vCU  after_reset
    ${suppressed_content}  OperatingSystem.Get File
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VCU_MRBTS_ID}_${VCU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_after_reset.txt
    Verify The Titles From The Statistics File With Suppressed Alarms  ${suppressed_content}
    Verify Generated Fault Info From The Statistics File With Suppressed Alarms For vCU  ${suppressed_content}  7115  BASE STATION INFORMATION  4592
    ...  BTS Reset Cause


Step6: Disable actAlarmsSuppression Parameter And Delete Instances
    Log  \nStep6: Disable actAlarmsSuppression Parameter And Delete Instances  console=true
    Disable actAlarmsSuppression Parameter And Delete Instances For vCU
    Sleep  10s  Time for alarm to be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From vCU WebEM
    ${active_alarms_id_list}  Get List Of Active Alarm Ids From vCU WebEM
    List Should Contain Value  ${active_faults_id_list}  4592
    List Should Contain Value  ${active_alarms_id_list}  7115
    Log  Fault Id 4592 with alarm id 7115 is visible on WebEM in active alarms after actAlarmsSuppression is disabled![OK]  console=true


Step7: Cancel fault id 4592 and verify if fault is cleared
    Log  \nStep7: Cancel fault id 4592 and verify if fault is cleared  console=true
    Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s  ${RECOVERY_TIMEOUT}


TC Setup
    Common VCU Setup
    VCU WebEM Setup
    Modify Resource Search Order  WebEM__vCU__Statistics_of_suppressed_alarms_after_CU_reset


TC Teardown
    Run keyword if test failed  Run keywords  Disable actAlarmsSuppression Parameter And Delete Instances For vCU  AND
    ...  Cancel Fault 4592 And Change fault4592CancellationTimer To Be 30s  ${RECOVERY_TIMEOUT}
    VCU WebEM Teardown
    Common VCU Teardown
