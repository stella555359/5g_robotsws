*** Settings ***
Documentation
    ...  This test case was created to imitate WCDMA DSP crash RAT recovery reset scenario. Rioboot command will be used
    ...  with write option. Before crash file data.dat with value "OxFFFF" is created in /tmp. To perform DSP crash value 0x128FFFFF
    ...  needs to be put into created file inline with nodeID in hex format. Example rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x1335.
    ...  Fault 6707/6708/6709 appearance and WCDMA cells reset are being checked in two seperate threads.
    ...  At the end the correctness of recovery action is being check (fault presence, fault history and cells status).

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  360  # Timeout for SBTS to recover after rat reset.
${STARTUP_TIMEOUT}  660  # Timeout for SBTS recovery after site reset.
${ALARM_TIMEOUT}  660  # Timeout for alarm reporting in WebEM


*** Keywords ***
TC__FM__RAT_reset_actForceAutoReset_true_enabled_cells
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-14586
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.2.2019 - https://jira3.int.net.nokia.com/browse/TAT-14586 - Initial TAT creation
    ...  - 25.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19779 - Remove import of old nwi3 library from Settings
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 08.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24058 - RAT_reset_actForceAutoReset_true_enabled_cells fails
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  - 16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP002187

    Step1: TC Preconditions
    Step2: Trigged WCDMA DSP Crash
    Step3: Verify Success Of Recovery Action


Step1: TC Preconditions
    [Documentation]  In this step system module release will be check and required file will be created.

    Log  \nStep1: TC preconditions.  console=true
    ${act_force_auto_reset_ini}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${ACT_FORCE_AUTO_RESET_INI}
    Log  Value of actForceAutoReset is ${ACT_FORCE_AUTO_RESET_INI}  console=true
    ${status_act}  Run Keyword And Return Status  Should Contain  ${ACT_FORCEAUTORESETINI}  true
    IF  ${status_act}==${FALSE}  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${act_force_auto_reset_changed}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    IF  ${status_act}==${FALSE}  Log  Value of actForceAutoReset after change is ${act_force_auto_reset_changed}  console=true
    Check Commissioned Technologies  WCDMA
    Check If 2RAT
    Create data.Dat And Put 0xFFFF
    Checking RNCid And WBTSid From IM


Step2: Trigged WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep2: Trigger WCDMA DSP crash.  console=true
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Check Links Status  Available
    Choose DSP For Crash Test
    Log  DSPs stateInfo will be checked under specified pattern.  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=cellsChec
    ${fault_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=regex"6707|6708|6709",  alarmId=7101,
    ...  alarmName="BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION"
    Set Test Variable  ${FAULT_PARAMETERS}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ${cells_status}  Run Keyword In Background  Assert Every  class_name=WNCEL  parameters=operationalState=${DISABLED}  timeout=660
    ...  alias=cellsChec
    DSP Crash  ${NODE_ID}
    Log  \nWait 2 min for reset to occur.  console=true
    Sleep  120
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}
    IF  ${ping_loss_status}==${TRUE}
      Set Test Failed  Ping has been lost within timeout=${PING_TIMEOUT}
    ELSE
      Log  Ping is not lost. [OK]  console=true
    END
    ${recovery_reset}  Run Keyword And Return Status  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=240
    Log  Recovery indicator is ${recovery_reset}.  console=true
    ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=${ALARM_TIMEOUT}
    ${status_cells}  Run Keyword And Return Status  Collect Keyword Result  ${cells_status}  timeout=660
    IF  ${status_fault}
      Log  Fault 6709 with alarm "7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION" occured [OK]  console=true
    ELSE
      Set Test Restriction  Fault 6709 with alarm "7101 BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION" didn't occur [NOK]
    END
    IF  ${status_cells}
      Log  WCDMA cells were failed while fault 6707/6708/6709 occured. [OK]  console=true
    ELSE
      Set Test Restriction  WCDMA cells were not failed while fault 6707/6708/6790 occured. [NOK]
    END
    IF  ${recovery_reset}
      Log  Recovery Reset Indication was visible under FRI. [OK]  console=true
    ELSE
      Set Test Restriction  Recovery Reset Indication was not visible under FRI. [NOK]
    END


Choose DSP For Crash Test
    [Documentation]  This keyword is created to draw a desired DSP which will be crashed during testcase.

    ${selected_core}  Evaluate  random.randint(1,8)  random
    Log  Selected core which was choosen after draw: ${selected_core}  console=true
    ${wcdma_ds_ps}  Get List Of DSP For Given Technology Inline With NodeId  WCDMA
    Log  List of all WCDMA DSPs: \n ${wcdma_ds_ps}  console=true
    ${list_lengt}  Get Length  ${wcdma_ds_ps}
    ${selected_position_of_ds_pin_array}  Evaluate  random.randint(1,${list_lengt}-1)  random
    ${selected_dsp}  Get From List  ${wcdma_ds_ps}  ${selected_position_of_ds_pin_array}
    Log  Selected DSP: \n ${selected_dsp}  console=true
    Set Test Variable  ${SELECTED_DSP}
    ${key}  Get Dictionary Keys  ${SELECTED_DSP}
    ${node_id}  Evaluate  ${SELECTED_DSP["${key[0]}"]}+${selected_core}
    Log  NodeId which will be crashed is: ${node_id}  console=true
    Set Test Variable  ${NODE_ID}


DSP Crash
    [Documentation]  This keyword is created to crash selected DSP.
    [Arguments]  ${node_id}

    Log  DSP of nodeID: ${node_id} will be crashed.  console=true
    ssh.Connect To  ${OAM_BTS_IP}  toor4nsn  oZPS0POrRieRtu
    ssh.Execute  rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x${node_id}


Step3: Verify Success Of Recovery Action
    [Documentation]  In this step verification of recovery action will be checked

    Log  \nStep3: Verify success of recovery action after WCDMA DSP crash.  console=true
    ${alarm7101_recovery_status}  Run Keyword And Return Status  Assert Alarm Inactive  parameters=${FAULT_PARAMETERS}
    IF  ${alarm7101_recovery_status}
      Log  Alarm id 7101 is inactive after recovery action [OK]  console=true
    ELSE
      Log  Alarm id 7101 is visible after recovery action [NOK]  console=true
    END
    Log  Checking Historical Alarms for presence of 7101 Autonomous Rat Reset notification..  console=true
    ${historical_alarms}  Get Historic Alarms  severity=warning
    FOR  ${element}  IN  @{historical_alarms}
        Log  Alarm history is ${element}  console=true
        ${status7101}  Run Keyword And Return Status  Should Contain  ${element}  alarmId  7101
        IF  ${status7101}
          Log  "7101 RAT autonomous reset as recovery action" is visible in historical alarms. [OK]  console=true
          BREAK
        END
    END
    IF  ${status7101}==${FALSE}  Fail  msg=Alarm "7101 RAT autonomous reset as recovery action" is not visible in historical alarms. [NOK]
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec  Check All Cells
    Check Links Status  Available
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}


Change Parameter To False And Reset
    [Documentation]  Change parameter actForceAutoReset to default False and reset BTS to clear counters

    Log  \nChange parameter to false and reset.  console=true
    ${act_force_auto_reset_ini}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${ACT_FORCE_AUTO_RESET_INI}
    Log  Value of actForceAutoReset is ${ACT_FORCE_AUTO_RESET_INI}  console=true
    ${status_act}  Run Keyword And Return Status  Should Contain  ${ACT_FORCEAUTORESETINI}  false
    IF  ${status_act}==${FALSE}  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    ${act_force_auto_reset_changed}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    IF  ${status_act}==${FALSE}  Log  Value of actForceAutoReset after change is ${act_force_auto_reset_changed}.  console=true
    Perform Site Reset
    Log  Site reset has been performed. [OK]  console=true


TC Setup
    Common Test Setup


TC Teardown
    Change Parameter To False And Reset
    Common Test Teardown