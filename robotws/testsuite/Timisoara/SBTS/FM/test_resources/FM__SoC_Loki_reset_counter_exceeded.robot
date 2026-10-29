*** Settings ***
Documentation
    ...  This test is created to perform failure on Loki SoC.
    ...  Parameter actForceUnitAutoReset is set to true in case BBMOD.
    ...  Site reset is performed to clear all recovery reset counters
    ...  bsh, ps aux and kill commands are used to perform the failure
    ...  SoC autonomous reset as recovery action is performed 3 times, and SBTS must be on air.
    ...  After SoC is crashed for the 4th time in case of:
    ...  1) ABIO, ABIN: faultId 2087, fault name Baseband card autonomous reset as recovery action must appear.
    ...  2) ASOE/ASOF:  faultId 4001, fault name BTS reset required must appear.
    ...  Site reset is triggered again and another crash for the SoC. Fault Name SoC autonomous reset as recovery action
    ...  must be seen.
    ...  Parameter actForceUnitAutoReset is set to false.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${BBMOD_TYPE}  ${EMPTY}  # Mandatory. Can be ABIO, ABIN, ASOE, ASOF.
${STARTUP_TIMEOUT}  300  # Time for SBTS to recover from reset.
${RECOVERY_TIMEOUT}  300  # Time for SBTS to recover from recovery action.
${OPEN_SC_CONNECTION}  ${FALSE}


*** Keywords ***
TC__FM__SoC_Loki_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24346
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  05.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24346 - Initial TAT creation
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  23.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25392 - Testcase fails for alarm timing reason
    ...  20.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26392 - Add ASOF option
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  11.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27261 - Alarm not found within timeout
    ...  ******************
    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22R2  FEATURE-CB007442

    Step0: Set Test Preconditions
    Step1: Perform Site Reset
    Step2: Perform 3 Loki Resets
    Step3: Perform 4th Loki Reset
    Step4: Perform Site Reset
    Step5: Perform Loki Reset After SBTS Reset


Step0: Set Test Preconditions
    Log  \nStep0: Set test preconditions  console=true
    Should Not Be Empty  ${BBMOD_TYPE}  BBMOD_TYPE must be specified.
    Log  Set test preconditions for ${BBMOD_TYPE}  console=true
    Run Keyword If  '${BBMOD_TYPE}' in ['ASOE', 'ASOF']
    ...  Set Preconditions For ASOE And ASOF
    ...  ELSE
    ...  Set Precondition For Random BBMOD


Step1: Perform Site Reset
    Log  \nStep1: Performing site reset  console=true
    Perform Site Reset


Step2: Perform 3 Loki Resets
    Log  \nStep2: Perform 3 Loki resets  console=true
    Open Connection To Primary Core
    Run Keyword If  ${OPEN_SC_CONNECTION}
    ...  Open Connection To Secondary Core
    FOR  ${loop}  IN RANGE  3
        Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=alarm_check
        ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
        ${alarm_webem}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=300  alias=alarm_check
        Log  Execute ${loop+1} Loki reset.  console=true
        Trigger Fault 2087
        Log  Check faultId 2087 and faultName SoC autonomous reset as recovery action.  console=true
        ${status}  Run Keyword And Return Status
        ...  Collect Keyword Result  ${alarm_webem}  timeout=300
        Run Keyword If  ${status}
        ...  Log  Fault 2087 with alarm 7101 'SoC autonomous reset as recovery action' is visible.  console=true
        ...  ELSE
        ...  Fail  Fault 2087 with alarm 7101 'SoC autonomous reset as recovery action' didn't occur.
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Check All Cells
        Run Keyword And Continue On Failure
        ...  Teardown Admin  alias=alarm_check
    END


Step3: Perform 4th Loki Reset
    Log  \nStep3: Perform 4th Loki reset  console=true
    Trigger Fault 2087
    Log  Check faultId ${4_TH_FAULT_DICT}[fault_id] and faultName ${4_TH_FAULT_DICT}[fault_name].  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${4_TH_FAULT_DICT}
    Assert Alarm Active  parameters=${alarm_parameters}  timeout=600
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


Step4: Perform Site Reset
    Log  \nStep4: Performing site reset  console=true
    Perform Site Reset


Step5: Perform Loki Reset After SBTS Reset
    Log  \nStep5: Perform Loki reset after SBTS reset console=true
    Open Connection To Primary Core
    Run Keyword If  ${OPEN_SC_CONNECTION}
    ...  Open Connection To Secondary Core
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=alarm_check
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    ${alarm_webem}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=300  alias=alarm_check
    Trigger Fault 2087
    Log  Check faultId 2087 and faultName SoC autonomous reset as recovery action.  console=true
    ${status}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${alarm_webem}  timeout=300
    Run Keyword If  ${status}
    ...  Log  Fault 2087 with alarm 7101 'SoC autonomous reset as recovery action' is visible.  console=true
    ...  ELSE
    ...  Fail  Fault 2087 with alarm 7101 'SoC autonomous reset as recovery action' didn't occur.
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Run Keyword And Continue On Failure
    ...  Teardown Admin  alias=alarm_check


Set Preconditions For ASOE And ASOF
    Set Position For ASOE And ASOF
    Set Random Loki
    ${4th_fault_dict}  Set Variable If  '${ENB_BRANCH}' < 'SBTS24R2'  ${FAULT_4001_BTS_RST_REQ}  ${FAULT_2087_SOC_AUTO_RST}
    Set Test Variable  ${4_TH_FAULT_DICT}


Set Precondition For Random BBMOD
    Set Position For Random BBMOD
    Set Random Loki
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
    Check If SC Connection Is Neeeded
    Set Test Variable  ${4_TH_FAULT_DICT}  ${FAULT_2087_BB_AUTO_RST}


Set Position For ASOE And ASOF
    Set Test Variable  ${BBMOD_VERTICAL_POSITION}  0
    Set Test Variable  ${BBMOD_HORIZONTAL_POSITION}  ${NONE}


Set Position For Random BBMOD
    @{bbmods}  Get IDs For All  BBMOD
    ${bbmod_list}  Create List
    FOR  ${bbmods_dn}  IN  @{bbmods}
        ${parameters}  coam.Get Parameters  ${bbmods_dn}
        Run Keyword If  '${BBMOD_TYPE}' in '${parameters}[productName]'
        ...  Append To List  ${bbmod_list}  ${parameters}
    END
    ${bbmod}  Evaluate  random.choice(${bbmod_list})  random
    Log  Loki reset will be performed on ${BBMOD_TYPE} with SN: ${bbmod}[serialNumber]  console=True
    ${vertical_position}  Set Variable  ${bbmod}[verticalPosition]
    Set Test Variable  ${BBMOD_VERTICAL_POSITION}  ${vertical_position-1}
    Set Test Variable  ${BBMOD_HORIZONTAL_POSITION}  ${bbmod}[horizontalPosition]


Set Random Loki
    ${loki}  Run Keyword If  '${BBMOD_TYPE}' != 'ABIN'
    ...  Evaluate  random.randint(1,2)  random
    ...  ELSE
    ...  Set Variable  1
    Log  Loki ${loki} will be crashed.  console=true
    Set Test Variable  ${LOKI}


Trigger Fault 2087
    Open Connection To SOC  ${BBMOD_VERTICAL_POSITION}  ${LOKI}
    Kill Pid


Kill Pid
    SSHLibrary.Set Client Configuration  timeout=120s
    SSHLibrary.Write  ps aux | grep l1
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output_ps}  application_
    ${split}  Split String  ${lines}
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -11 ${pid}
    SSHLibrary.Read Until  Broken pipe
    SSHLibrary.Read Until Prompt


Check If SC Connection Is Neeeded
    ${smods}  Get Fsm Info
    ${bbmod_horizontal}  Create Dictionary  '1'=LeftSide  '2'=RightSide
    FOR  ${smod}  IN  @{smods}
        Exit For Loop If  "${smod}[positionInSubrack]" == "${bbmod_horizontal}['${BBMOD_HORIZONTAL_POSITION}']"
    END
    ${open_sc_connection}  Set Variable If  "${smod}[activeRole]" == "Secondary"  ${TRUE}  ${FALSE}
    Set Test Variable  ${OPEN_SC_CONNECTION}


TC Setup
    Common Test Setup  tc_name=FM__SoC_Loki_reset_counter_exceeded


TC Teardown
    Run Keyword If  '${BBMOD_TYPE}' not in ['ASOE', 'ASOF']
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Common Test Teardown
