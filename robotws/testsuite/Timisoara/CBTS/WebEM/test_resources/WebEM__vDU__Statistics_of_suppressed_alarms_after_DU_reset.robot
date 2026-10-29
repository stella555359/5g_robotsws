*** Settings ***
Documentation
    ...  This TC checks the statistics of suppressed alarms before and after vDU reset.
    ...  Fault id 1401 with EAC-IN object is generated.
    ...  Verify if fault 1401 is visible in active alarms page.
    ...  Set actAlarmsSuppression to 'suppressAlarms' and suppressedFaultList with parameters alarmSeverity=MINOR_AND_WARNING and faultId=1401.
    ...  Activate the plan and verify if fault 1401 is not visible anymore in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if fault 1401 with alarm id 7103 is visible in suppressed alarms view.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed fault.
    ...  Perform vDU reset and wait for all cells to be onAir.
    ...  Verify fault 1401 to not be visible in active alarms view.
    ...  Click on Get Suppressed Alarms button and verify if the confirmation message is visible on page.
    ...  Verify if fault 1401 with alarm id 7103 is still visible in suppressed alarms view after reset.
    ...  Save the statistics file of suppressed alarms.
    ...  Verify the file to contain all specific titles and generic information about the suppressed fault.
    ...  Disable actAlarmsSuppression parameter and delete all instances.
    ...  Cancel fault id 1401 and verify if fault is cleared.
    ...  As recovery action, if test fail the last 2 steps with disabling the parameter and canceling fault 1401 will be perform.


Resource  ../../common_resources/vdu_frame.robot
Resource  ../resources/vdu_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29161
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  14.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29161 - Initial TAT creation
    ...  ******************

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-vDU25R3  FEATURE-CB010788

    Step1: Generate fault id 1401
    Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Step3: Log the statistics of suppressed alarms in the statistics file
    Step4: Perform vDU reset
    Step5: Verify if the statistics file persists after the BTS reset
    Step6: Disable actAlarmsSuppression Parameter And Delete Instances
    Step7: Cancel fault id 1401 and verify if fault is cleared


Step1: Generate fault id 1401
    Log  \nStep1: Generate fault id 1401  console=true
    Generate One Specific Fault Id With EAC  2  1
    Sleep  10s  Time for alarm to be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From WebEM
    List Should Contain Value  ${active_faults_id_list}  1401
    Log  Fault Id 1401 is visible on WebEM before suppression![OK]  console=true


Step2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id
    Log  \nStep2: Set actAlarmsSuppression to 'suppressAlarms' and set suppressed fault id  console=true
    ${actAlarmsSuppression_parameter}  Create Dictionary  parameterName=actAlarmsSuppression  value=suppressAlarms  operation=update
    ${allowedAlarmList_parameter}  Create Dictionary  parameterName=allowedAlarmList  operation=delete
    ${allowedFaultList_parameter}  Create Dictionary  parameterName=allowedFaultList  operation=delete
    ${suppressedAlarmList_parameter}  Create Dictionary  parameterName=suppressedAlarmList  operation=delete
    ${suppressedFaultList_parameter}  Create Dictionary  parameterName=suppressedFaultList  operation=delete
    ${severity_faultid_dict}  Create Dictionary  alarmSeverity=MINOR_AND_WARNING  faultId=1401
    ${severity_faultid_list}  Create List  ${severity_faultid_dict}
    ${suppressedFaultList_parameter_created}  Create Dictionary  parameterName=suppressedFaultList  value=${severity_faultid_list}  operation=create
    ${parameters_change_list}  Create List  ${actAlarmsSuppression_parameter}  ${allowedAlarmList_parameter}  ${allowedFaultList_parameter}
    ...  ${suppressedAlarmList_parameter}  ${suppressedFaultList_parameter}  ${suppressedFaultList_parameter_created}
    ${actAlarmsSuppression_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1/ALARMSUPP-1
    ...  operation=update  parameters=${parameters_change_list}
    ${changed_parameters_list}  Create List  ${actAlarmsSuppression_changed_parameter}
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAlarmsSuppression was changed to suppressAlarms![OK]  console=true
    Log  Parameters allowedAlarmList, allowedFaultList, suppressedAlarmList and suppressedFaultList was deleted initially![OK]  console=true
    Log  Parameter suppressedFaultList was added with parameters alarmSeverity=MINOR_AND_WARNING and faultId=1401![OK]  console=true
    vdu.Perform Delta Recommissioning  ${changed_parameters_string}
    Log  Operation was done successfully!  console=true


Step3: Log the statistics of suppressed alarms in the statistics file
    Log  \nStep3: Log the statistics of suppressed alarms in the statistics file  console=true
    Sleep  10s  Time for alarm to not be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From WebEM
    List Should Not Contain Value  ${active_faults_id_list}  1401
    Log  Fault Id 1401 is not visible on active alarms after suppression![OK]  console=true
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  1401  7103
    Save Statictics File And Move It To Test Results Directory  before_reset
    ${suppressed_fault_list_content_before_reset}  OperatingSystem.Get File
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VDU_MRBTS_ID}_${VDU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_before_reset.txt
    Verify The Titles From The Statistics File With Suppressed Alarms  ${suppressed_fault_list_content_before_reset}
    Verify Generated EAC Fault Info From The Statistics File With Suppressed Alarms  ${suppressed_fault_list_content_before_reset}  1401


Step4: Perform vDU reset
    Log  \nStep4: Perform vDU reset  console=true
    vdu.Reset Vdu  timeout=120
    Log  Reset vDU is perform![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  Cells are Offline and Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}
    Log  Cells are Online and Enabled![OK]  console=true
    Log  Reset vDU was done successfully![OK]  console=true
    Close Start-up View From VDU WebEM


Step5: Verify if the statistics file persists after the BTS reset
    Log  \nStep5: Verify if the statistics file persists after the BTS reset  console=true
    ${active_faults_id_list}  Get List Of Active Fault Ids From WebEM
    List Should Not Contain Value  ${active_faults_id_list}  1401
    Log  Fault Id 1401 is not visible on active alarms after suppression![OK]  console=true
    Open Suppressed Alarms View And Verify If A Specific Fault Is Visible  1401  7103
    Save Statictics File And Move It To Test Results Directory  after_reset
    ${suppressed_fault_list_content_after_reset}  OperatingSystem.Get File
    ...  ${TEST_RESULTS_DIR}/MRBTS-${VDU_MRBTS_ID}_${VDU_MRBTS_NAME}_SuppressedAlarms_${DATE_FOR_TXT}_after_reset.txt
    Verify The Titles From The Statistics File With Suppressed Alarms  ${suppressed_fault_list_content_after_reset}
    Verify Generated EAC Fault Info From The Statistics File With Suppressed Alarms  ${suppressed_fault_list_content_after_reset}  1401


Step6: Disable actAlarmsSuppression Parameter And Delete Instances
    Log  \nStep6: Disable actAlarmsSuppression Parameter And Delete Instances  console=true
    Disable actAlarmsSuppression Parameter And Delete Instances
    Sleep  10s  Time for alarm to be visible
    ${active_faults_id_list}  Get List Of Active Fault Ids From WebEM
    List Should Contain Value  ${active_faults_id_list}  1401
    Log  Fault Id 1401 is visible on WebEM after actAlarmsSuppression is disabled![OK]  console=true


Step7: Cancel fault id 1401 and verify if fault is cleared
    Log  \nStep7: Cancel fault id 1401 and verify if fault is cleared  console=true
    Cancel One Specific Fault Id Generated With EAC And Verify If Fault Is Cleared  1  ${RECOVERY_TIMEOUT}  1401


TC Setup
    Common VDU Setup
    VDU WebEM Setup
    Modify Resource Search Order  WebEM__vDU__Statistics_of_suppressed_alarms_after_DU_reset


TC Teardown
    Run keyword if test failed  Run keywords  Disable actAlarmsSuppression Parameter And Delete Instances  AND
    ...  Cancel One Specific Fault Id Generated With EAC And Verify If Fault Is Cleared  1  ${RECOVERY_TIMEOUT}  1401
    VDU WebEM Teardown
    Common VDU Teardown
