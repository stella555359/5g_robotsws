*** Settings ***
Documentation
    ...  This TC is created to trigger fault 243 on FSP. FSP recovery reset is performed as recovery action.
    ...  The purpose is to detect ethernet link issues on connections between common modules and capacity modules.
    ...  A random FSP in configuration will be chosen and sender, receiver, node id will be set for fault triggering.
    ...	 Fault 243 is sent on FSP and alarm with alarmid 7101 should appear. Cells on FSP and BBMOD states are checked.
    ...  Recovery is verified: fault cancelation, cells on FSP, unit states are checked and expected to be online after.
    ...  Second fault is triggered and recovery is verified.
    ...  Third fault is triggered and recovery is not performed as recovery counter is exceeded.
    ...  Fault 243 is permanent and cells, unit remain faulty. Alarm presence is checked in Netact.
    ...  Site Reset will be performed to recover services and clear recovery counters.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.
${RECOVERY_TIMEOUT}  300  # [in seconds] Timeout for SBTS to recover after test scenario.
${SLEEP_BEFORE_RESET}  10  # [in seconds] Timeout to wait after the fault is raised in order to reset the site.


*** Keywords ***
TC__FM__FSP_recovery_fault_243
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23482
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 11.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23482 - Initial TAT creation
    ...  - 01.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24716 - Changing alarm appearance, cells and bbmod states
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27106 - Add severity to alarm dictionary
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28938 - Move keyword to resource
    ...  - 13.03.20262 - https://jiradc.ext.net.nokia.com/browse/TAT-30585 - Enhancement due to EDA – 05419072.
    ...  *******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22

    Step 1: Get FSP To Crash
    Step 2: Set Sender And Receiver
    Step 3: Perform Site Reset
    Step 4: Send Fault And Verify State
    Step 5: Perform Site Reset


Step 1: Get FSP To Crash
    Log  Step 1: Get FSP to crash.  console=true
    Log  Available BBMODs in configuration will be checked.  console=true
    ${all_bbmods}  coam.Get Parameters For All  BBMOD
    ${bbmods_list}  Create List
    FOR  ${bbmod}  IN  @{all_bbmods}
        ${string}  Run Keyword And Return Status  Should Not Be Equal As Strings  ${bbmod.productName}  ABIA AirScale Capacity
        IF  ${string}  Append To List  ${bbmods_list}  ${bbmod}
    END
    ${list_status}  Run Keyword And Return Status  Should Not Be Empty  ${bbmods_list}
    IF  ${list_status} == ${FALSE}  Fail  msg=No suitable BBMOD found in configuration.
    ${list_length}  Get Length  ${bbmods_list}
    ${index}  Evaluate  random.randint(0, ${list_length}-1)  modules=random
    Log  Chosen index from available BBMODs list is: ${index}.  console=true
    ${bbmod_obj}  Set Variable  ${bbmods_list}[${index}]
    Log  BBMOD for test is: ${bbmod_obj}  console=true
    Set Test Variable  ${BBMOD_DN}  ${bbmod_obj.id}
    Set Cells Mapped On FSP


Step 2: Set Sender And Receiver
    Log  Step 2: Set sender and receiver.  console=true
    ${bbmod_r}  coam.Get Parameters  ${BBMOD_DN}
    ${position}  ${slot}  Set Variable  ${bbmod_r}[horizontalPosition]  ${bbmod_r}[verticalPosition]
    ${sender}  Set Variable If  '${position}'=='1'  269550773  537986229
    ${receiver}  Set Variable If  '${position}'=='1'  269554178  537989634
    Set Test Variable  ${SENDER}  ${sender}
    Set Test Variable  ${RECEIVER}  ${receiver}
    Log  Sender set to: ${SENDER}.  console=true
    Log  Receiver set to: ${RECEIVER}.  console=true
    ${node_hex}  Set Variable  0X${position}${slot}4D
    ${result}  Convert To Integer  ${node_hex}
    Set Test Variable  ${NODE_VALUE}  ${result}
    Log  Node id chosen: ${NODE_VALUE}.  console=true


Step 4: Send Fault And Verify State
    Log  Step 4: Send fault and verify state.  console=true
    ${fault_params}  Create List  0  2
    ${send_fault}  Run Keyword And Return Status
    ...  Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  243  ${NODE_VALUE}  fault_params=@{fault_params}  timeout=360
    IF  ${send_fault}
      Log  Fault was sent. [OK]  console=true
    ELSE
      Fail  msg=Fault was not sent. [NOK]
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${CELLS_LIST_ON_FSP}
    IF  ${status}
      Check Alarm Appeareance  Major
      Check Mapped Cells And Bbmod Status  ${DEGRADED}  ${ENABLED}
    ELSE
      Check Alarm Appeareance  Minor
      Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells
    END


Check Alarm Appeareance
    [Arguments]  ${severity}

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_243}
    ${alarm_parameters}  Catenate  ${alarm_parameters},  severity=${severity}
    Log  Check alarm appeareance in WebEM.  console=true
    ${alarm_status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=360
    Should Be True  ${alarm_status}  Fault ${FAULT_243} was not active in WebEm.
    Log  Fault ${FAULT_243} is active in WebEM.  console=true
    ${alarm_parameters_dict}  Set To Dictionary  ${FAULT_243}  severity=${severity}
    Log  Check alarm appeareance in Netact.  console=true
    ${check_fault_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{alarm_parameters_dict}  additional_fault_id=${alarm_parameters_dict}[fault_id]
    Should Be True  ${check_fault_netact}  Fault ${FAULT_243} was not reported in Netact.
    Log  Fault ${FAULT_243} was reported and cleared in Netact.  console=true


Check Mapped Cells And Bbmod Status
    [Arguments]  ${availability_status}  ${operational_state}

    ${bbmod_status}  Run Keyword And Return Status  Check Bbmod  ${availability_status}  ${operational_state}
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${CELLS_LIST_ON_FSP}  ${availability_status}  ${operational_state}
    IF  ${bbmod_status}
      Log  BBMOD was failed. [OK]  console=true
    ELSE
      Set Test Restriction  msg=BBMOD was not failed.
    END

Step ${index}: Perform Site Reset
    Log  Step ${index}: Perform site reset.  console=true
    IF  ${index}==5  Sleep  ${SLEEP_BEFORE_RESET}s  Timeout to wait after the fault is raised in order to reset the site.
    Perform Site Reset
    ${fault_7300_params}  Get String With Alarm Parameters  ${FAULT_7300}
    ${fault_7319_params}  Get String With Alarm Parameters  ${FAULT_7319}
    Assert Alarm Inactive  parameters=${fault_7300_params}  timeout=${STARTUP_TIMEOUT}
    Assert Alarm Inactive  parameters=${fault_7319_params}  timeout=${STARTUP_TIMEOUT}
    Admin Check Active Alarms Taf
    Log  SBTS is on air.  console=true


Check Bbmod
    [Arguments]  ${availability}  ${operational}

    Wait Until Keyword Succeeds  120s  10s  Assert Any  BBMOD  availabilityStatus=${availability},operationalState=${operational}  timeout=60


Check Unit States
    [Arguments]  ${operational}

    Wait Until Keyword Succeeds  180  10  Assert Any  SMOD  operationalState=${operational}  timeout=60
    Wait Until Keyword Succeeds  180  10  Assert Any  BBMOD  operationalState=${operational}  timeout=60
    Wait Until Keyword Succeeds  180  10  Assert Any  RMOD  operationalState=${operational}  timeout=60


TC Setup
    Common Test Setup  tc_name=FM__FSP_recovery_fault_243
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Perform Site Reset
    Teardown NetAct
    Common Test Teardown