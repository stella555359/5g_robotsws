*** Settings ***
Documentation
    ...  This TC is created to trigger fault 4383 on SBTS.
    ...  If initial value of restart counter is 0, the test will continue. If it's different, site reset will be performed for clear all counters.
    ...  Trigger fault 4383 for 3 times.
    ...  For each time, after crash was triggered, cells are verified to be failed, alarm (warning) to appear in SBTS and Netact,
    ...  SBTS to be in reset, SBTS to be onAir, alarm to disappear and value of restart counter to increase.
    ...  Trigger fault 4383 for 4th time
    ...  After crash was triggered, cells are verified to be failed, alarm (critical) to appear in SBTS and Netact, perform site reset,
    ...  SBTS to be onAir, alarm to disappear in SBTS and Netact.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  900  # Timeout for SBTS to recover after FHNET crash scenario
${STARTUP_TIMEOUT}  900  # Timeout for SBTS to recover after startup
${FAILED_TIMEOUT}  600  # Timeout for all cells to be failed
${EXPECTED_FAULT_ID}  4383  # Expected fault id that will be checked by test
${EXPECTED_FAULT_NAME}  BTS site autonomous reset as recovery action  # Expected fault name that will be checked by test
${EXPECTED_FAULT_NAME_SECOND}  Virtual node not responding  # Expected second fault name that will be checked by test
${EXPECTED_ALARM_ID}  7101  # Expected alarm id that will be checked by test
${EXPECTED_ALARM_ID_SECOND}  7116  # Expected second alarm id that will be checked by test
${EXPECTED_ALARM_NAME}  BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION  # Expected alarm name that will be checked by test
${EXPECTED_ALARM_NAME_SECOND}  BASE STATION SERVICE PROBLEM  # Expected second alarm name that will be checked by test
${SEVERITY}  Warning  # Expected severity that will be checked by test
${SEVERITY_SECOND}  Critical  # Expected second severity that will be checked by test


*** Keywords ***
TC__FM__FHNET_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24345
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24345 - Initial TAT creation
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  *******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS22

    Step1: Check All Required States
    Step2: Trigger 4383 For 3 Times
    Step3: Trigger 4383 For 4th Time


Step1: Check All Required States
    Log  \nStep1: Check All Required States  console=true
    ${bts_cores}  Run Keyword And Return Status
    ...  Query Infomodel  check //BTS_L-* is [storedRole=Single]
    Run Keyword If  ${bts_cores}
    ...  Get Single Core Domain Id
    ...  ELSE
    ...  Get Dual Core Domain Id
    ${reset_counter}  Get Value Of Restart Counter
    Log  Value of reset counter at test start: ${reset_counter}  console=true
    Run Keyword If  '${reset_counter}' != '0'
    ...  Perform Site Reset


Step2: Trigger 4383 For 3 Times
    Log  \nStep2: Trigger 4383 for 3 times  console=true
    ${alarm_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},  faultName="${EXPECTED_FAULT_NAME}",
    ...  alarmId=${EXPECTED_ALARM_ID},  alarmName="${EXPECTED_ALARM_NAME}",  severity=${SEVERITY}
    FOR  ${index}  IN RANGE  1  4
        Log  Trigger fault 4383 for ${index} time!  console=true
        ${date}  Get Current Date  time_zone=UTC  result_format=datetime
        Trigger Fault 4383
        ${cells_failed}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${FAILED_TIMEOUT}  10
        ...  Check If All Cells Are Failed
        Run Keyword If  ${cells_failed}
        ...  Log  All cells are failed![OK]  console=true
        ...  ELSE
        ...  Fail  Not all cells are failed![NOK]
        ${status_fault}  Run Keyword And Return Status
        ...  Assert Alarm Active  parameters=${alarm_parameters}  timeout=300
        Run Keyword If  ${status_fault}
        ...  Log  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME}" and severity ${SEVERITY}, occured![OK]  console=true
        ...  ELSE
        ...  Fail  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME}" didn't occurr![NOK]
        Run Keyword If  ${NE3SADAPT}
        ...  Check Alarm Active And Cleared In NetAct  ${date}
        ...  ELSE
        ...  Log  SBTS is not connected to NetAct and fault 4383 can not be verified in NetAct!  console=true
        ${ping_loss}  Run Keyword And Return Status
        ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
        Run Keyword If  ${ping_loss}
        ...  Log  SBTS is in reset now![OK]  console=true
        ...  ELSE
        ...  Fail  SBTS did not reset![NOK]
        ${ping_status}  Run Keyword And Return Status
        ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=300
        Run Keyword If  ${ping_status}
        ...  Log  SBTS is reachable, wait for cells to be on air![OK]  console=true
        ...  ELSE
        ...  Fail  SBTS did not recoverd from reset![NOK]
        ${cells_status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Check All Cells
        Run Keyword If  ${cells_status}
        ...  Log  All cells are enabled![OK]  console=true
        ...  ELSE
        ...  Fail  SBTS did not recoverd from reset![NOK]
        ${alarm_recovery}  Run Keyword And Return Status
        ...  Assert Alarm Inactive  parameters=${alarm_parameters}
        Run Keyword If  ${alarm_recovery}
        ...  Log  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME}" is not visible after recovery action![OK]  console=true
        ...  ELSE
        ...  Fail  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME}" is visible after recovery action![NOK]
        ${reset_counter}  Get Value Of Restart Counter
        Run Keyword If  '${reset_counter}' == '${index}'
        ...  Log  Fault is triggered for ${index} time and value of reset counter is: ${reset_counter} [OK]  console=true
        ...  ELSE
        ...  Fail  Fault is triggered for ${index} time and value of reset counter is: ${reset_counter} [NOK]
    END


Step3: Trigger 4383 For 4th Time
    Log  \n Step3: Trigger 4383 for 4th time  console=true
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault 4383
    ${cells_failed}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FAILED_TIMEOUT}  10
    ...  Check If All Cells Are Failed
    Run Keyword If  ${cells_failed}
    ...  Log  All cells are failed![OK]  console=true
    ...  ELSE
    ...  Fail  Not all cells are failed![NOK]
    ${alarm_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=${EXPECTED_FAULT_ID},  faultName="${EXPECTED_FAULT_NAME_SECOND}",
    ...  alarmId=${EXPECTED_ALARM_ID_SECOND},  alarmName="${EXPECTED_ALARM_NAME_SECOND}",  severity=${SEVERITY_SECOND}
    ${status_fault}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${alarm_parameters}  timeout=660
    Run Keyword If  ${status_fault}
    ...  Log  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME_SECOND}" and severity ${SEVERITY_SECOND}, occured![OK]  console=true
    ...  ELSE
    ...  Fail  Fault Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME_SECOND}" didn't occurr![NOK]

    Run Keyword If  ${NE3SADAPT}
    ...  Check Alarm Active In NetAct
    ...  ELSE
    ...  Log  SBTS is not connected to NetAct and fault 4383 can not be verified in NetAct.  console=true
    Assert Alarm Inactive  parameters=faultName="${EXPECTED_FAULT_NAME}",  faultId=${EXPECTED_FAULT_ID},  alarmId=${EXPECTED_ALARM_ID},
    ...  alarmName="${EXPECTED_ALARM_NAME}",  severity=${SEVERITY}
    ${reset_counter}  Get Value Of Restart Counter
    Run Keyword If  '${reset_counter}' == '3'
    ...  Log  Fault is triggered for 4th time and value of reset counter is: ${reset_counter} [OK]  console=true
    ...  ELSE
    ...  Fail  Fault is triggered for 4th time and value of reset counter is: ${reset_counter} [NOK]
    Perform Site Reset
    ${status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=660
    Run Keyword If  ${status}
    ...  Log  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME_SECOND}" and severity ${SEVERITY_SECOND} is not visible![OK]  console=true
    ...  ELSE
    ...  Fail  Fault ${EXPECTED_FAULT_ID} with name "${EXPECTED_FAULT_NAME_SECOND}" is still visible after site reset![NOK]
    Run Keyword If  ${NE3SADAPT}
    ...  Check Alarm Inactive In NetAct
    ...  ELSE
    ...  Log  SBTS is not connected to NetAct and fault 4383 can not be verified in NetAct.  console=true


Trigger Fault 4383
    ssh.Connect To  ${SMOD1['TRS_IP']}  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]  alias=sbts
    ${send_command}  ssh.Execute  ps aux | grep FHNET  connection=sbts  timeout=60
    ${regex}  Get Regexp Matches  ${send_command}  root\\s+\\d+
    ${pid_list}  Create List
    FOR  ${item}  IN  @{regex}
        ${words}  Split String  ${item}
        ${pid}  Get From List  ${words}  1
        Append To List  ${pid_list}  ${pid}
    END
    Log  Processing FHNET VN crash..  console=true
    FOR  ${pid}  IN  @{pid_list}
        ${result}  ssh.Execute  kill -9 ${pid}  connection=sbts  timeout=60
    END
    ssh.Disconnect  connection=sbts


Check Alarm Active And Cleared In NetAct
    [Arguments]  ${time_from}

    ${fault_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  5
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  ${EXPECTED_FAULT_ID}
    ...  ${EXPECTED_FAULT_NAME}
    ...  ${EXPECTED_ALARM_ID}
    ...  ${EXPECTED_ALARM_NAME}
    ...  ${SEVERITY}
    ...  ${time_from}
    Run Keyword If  ${fault_na}
    ...  Log  Fault ${EXPECTED_FAULT_ID} with fault name "${EXPECTED_FAULT_NAME}" reported & cleared from NetAct [OK].  console=true
    ...  ELSE
    ...  Fail  Fault ${EXPECTED_FAULT_ID} with fault name "${EXPECTED_FAULT_NAME}" not reported & cleared from NetAct [NOK].


Check Alarm Active In NetAct
    ${fault_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  5
    ...  Check Additional Information For Given Alarm And Fault  ${EXPECTED_FAULT_ID}
    ...  ${EXPECTED_FAULT_NAME_SECOND}
    ...  ${EXPECTED_ALARM_ID_SECOND}
    ...  ${EXPECTED_ALARM_NAME_SECOND}
    ...  ${SEVERITY_SECOND}
    Run Keyword If  ${fault_na}
    ...  Log  Fault ${EXPECTED_FAULT_ID} with fault name "${EXPECTED_FAULT_NAME_SECOND}" is active in NetAct [OK].  console=true
    ...  ELSE
    ...  Fail  Fault ${EXPECTED_FAULT_ID} with fault name "${EXPECTED_FAULT_NAME_SECOND}" is not active in NetAct [NOK].


Check Alarm Inactive In NetAct
    ${fault_na}  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault  ${EXPECTED_FAULT_ID}
    ...  ${EXPECTED_FAULT_NAME_SECOND}
    ...  ${EXPECTED_ALARM_ID_SECOND}
    ...  ${EXPECTED_ALARM_NAME_SECOND}
    ...  ${SEVERITY_SECOND}
    Run Keyword If  ${fault_na} == ${FALSE}
    ...  Log  Fault ${EXPECTED_FAULT_ID} with fault name "${EXPECTED_FAULT_NAME_SECOND}" is inactive in NetAct.[OK]  console=true


Check If All Cells Are Failed
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  coam.Assert Every  WNCEL  availabilityStatus=${FAILED}  timeout=60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  coam.Assert Every  LNCEL  availabilityStatus=${FAILED}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  coam.Assert Every  GNCEL  availabilityStatus=${FAILED}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  coam.Assert Every  NRCEL  availabilityStatus=${FAILED}  timeout=60


TC Setup
    Common Test Setup
    ${NE3SADAPT}  Query Infomodel  check //NE3SADAPT-*  allow_negative_result=True
    Set Test Variable  ${NE3SADAPT}
    Run Keyword If  ${NE3SADAPT}
    ...  Setup NetAct


TC Teardown
    Run Keyword If  ${NE3SADAPT}
    ...  Teardown NetAct
    Run Keyword If Test Failed
    ...  Perform Site Reset
    Common Test Teardown
