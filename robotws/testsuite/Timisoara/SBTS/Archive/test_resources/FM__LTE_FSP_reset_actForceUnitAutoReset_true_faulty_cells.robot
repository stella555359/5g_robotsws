*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${STARTUP_TIMEOUT}  900
${RECOVERY_TIMEOUT}  600
${TIME_BBMOD_STATE}  120s
${TIME_SMOD_STATE}  120s
${TIME_APPEAR_ALARM}  180
${TIME_DISAPPEAR_ALARM}  180

*** Keywords ***
TC__FM__LTE_FSP_reset_actForceUnitAutoReset_true_faulty_cells
       [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21642
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This TC is created to trigger fault 476 on 1st DSP of FSP processing LTE only.
    ...  The parameter actForceUnitAutoReset is changed to TRUE.
    ...  The 1st FSP will be chosen and also cells deployed on him will be collected.
    ...  The fault 476 is sent on FSP and the alarm should appear, those cells on FSP, BBMOD and SMOD states are checked.
    ...  FSP recovery reset is performed, the state and the alarm should dissapear,
    ...  those cells on FSP, BBMOD and SMOD are checked and expected to be online.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21642 - Fault to be triggered: 476 on 1st DSP of FSP processing LTE only
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22361 - Check bbmod KW used RMOD in assert and modify to BBMOD
    ...  - 22.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23331 - Suitable FSP not found in configuration
    ...  - 22.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23301 - Change fault sending method from FM TCs
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-cosmina.rebenciuc@nokia.com
    ...    MAINTAINER-cosmina.rebenciuc@nokia.com    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS21A
    ...    FEATURE-RP001621_1

    Step0: Get FSP to crash
    Step1: Check All Required States
    Step2: Get cells on FSP
    Step3: Set sender and receiver
    Step4: Send fault 476
    Step5: Verify SBTS fault
    Step6: Verify SBTS after recovery

Step0: Get FSP to crash
    Log  Step0: Get FSP to crash  console=true
    ${all_bbmod}=  Query Infomodel  get list //BTS_L-*/EQM_L-1/CABINET_L-1/BBMOD_L-*
    ${list_soc_LTE}=  Create List
    Set Test Variable  ${LIST_SOC_LTE}  ${list_soc_LTE}
    FOR  ${bbmod}  IN  @{all_bbmod}
      ${bbmod_soc_list}=  Query Infomodel  get list ${bbmod.dist_name}/BBU_L-1/POWER_GROUP_L-*/SOC_L-*
      ${soc_list}  Get LTE SOC from BBMOD  ${bbmod_soc_list}
      Run Keyword If  ${soc_list}
      ...  Run keywords  Append to list  ${LIST_SOC_LTE}  @{soc_list}  AND
      ...  Exit for loop
    END
    Run Keyword Unless  ${LIST_SOC_LTE}
    ...  Fail  msg=No suitable BBMOD found.
    FOR  ${soc}  IN  @{LIST_SOC_LTE}
      ${status}=  Run keyword and Return status  Should Contain  ${soc.dist_name}  POWER_GROUP_L-1/SOC_L-1
      Run keyword If  ${status}
      ...  Run Keywords  Set Test Variable  ${DIST_NAME_FIRST_FSP}  ${soc.dist_name}  AND
      ...  Exit for loop
    END
    Log  First FSP found: ${DIST_NAME_FIRST_FSP}  console=true
    ${dsp}=  Query Infomodel  get object ${DIST_NAME_FIRST_FSP}/DSP_L-1/CORE_L-1
    Set Test Variable  ${NODE_VALUE}  ${dsp.nodeId}

Get LTE SOC from BBMOD
    [Arguments]  ${bbmod_soc_list}
    ${soc_temp_list}=  Create List
    FOR  ${soc}  IN  @{bbmod_soc_list}
      ${rat}  Get RAT as string  ${soc.rat}
      ${status}  Run keyword and return status  Should be Equal  ${rat}  LTE
      Run keyword if  ${status}
      ...  Append to list  ${soc_temp_list}  ${soc}
      ...  ELSE
      ...  Return from keyword
    END
    [Return]  ${soc_temp_list}

Step1: Check All Required States
    Log  Step1: Check All Required States  console=true
    Log  Performing a Site Reset to clear the counters  console=true
    coam.Reset site
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Log  SBTS is on air.  console=true
    Log  Check actForceUnitAutoReset and change for TRUE if needed  console=${TRUE}
    ${INITIAL_VALUE}=    Get actForce(Unit)AutoReset value from infomodel   actForceUnitAutoReset
    ${status}=   Run Keyword And Return Status   Change parameter actForce(Unit)AutoReset  true  actForceUnitAutoReset
    ${parameter_after_change}=   Get actForce(Unit)AutoReset value from infomodel   actForceUnitAutoReset
    Run Keyword if   ${status}
    ...   should be equal  ${parameter_after_change}  true
    ${parameters}  Catenate  SEPARATOR=${SPACE}  faultId=476,
    ...                                          faultName="Baseband card autonomous reset as recovery action",
    ...                                          alarmId=7101
    Set Test Variable  ${PARAMETERS}

Step2: Get cells on FSP
    Log  Step2: Get cells on FSP  level=INFO  console=true
    ${bbmod_l}=  Fetch From Left  ${DIST_NAME_FIRST_FSP}  /BBU
    Set Test Variable  ${BBMOD_L}  ${bbmod_l}
    ${bbmod_object}=  Query Infomodel  get object ${BBMOD_L}/BBU_L-*
    Log  BBMOD which contains the first FSP found: ${BBMOD_L}  console=true
    ${cells_found}=  Infomodel Get Cells Deployed On FSP  ${bbmod_object}
    ${list_cells}=  Create List
    FOR  ${cell}  IN  @{cells_found}
      Append to list  ${list_cells}  ${cell.dist_name}
    END
    Set Test Variable  ${LIST_CELLS_ON_FSP}  ${list_cells}
    Log  Cells on FSP: ${LIST_CELLS_ON_FSP}  console=true

Get BBMOD position
    [Arguments]  ${DIST_NAME_FIRST_FSP}
    ${bbmod}=  Query Infomodel  get list ${BBMOD_L}
    ${bbmod_r}  Query Infomodel  get object //BBMOD_R-* is [serialNumber=${bbmod[0].serialNumber}]
    Set Test Variable  ${BBMOD_R}  ${bbmod_r}
    [Return]  ${bbmod_r.horizontalPosition}  ${bbmod_r.verticalPosition}

Get SMOD position
    [Arguments]  ${DIST_NAME_FIRST_FSP}
    ${bbmod_mapping}=  Fetch From Left  ${DIST_NAME_FIRST_FSP}  /EQM_L-1
    ${bbmod_position}=  Fetch From Right  ${bbmod_mapping}  /BTS_L-
    ${smod_list} =  Query Infomodel  get list //SMOD_L-*
    FOR  ${item}  IN  @{smod_list}
      ${dist_name_smod}=  Get From Dictionary  ${item}  dist_name
      ${smod_mapping}=  Fetch From Left  ${dist_name_smod}  /EQM_L-1
      ${smod_position}=  Fetch From Right  ${smod_mapping}  /BTS_L-
      ${status}  Run Keyword And Return Status  Should be equal  ${smod_position}  ${bbmod_position}
      Run Keyword If  ${status}
      ...  Set Test Variable  ${SMOD_OBJECT}  ${item}
      ${smod_r}  Query Infomodel  get object //SMOD_R-* is [serialNumber=${item.serialNumber}]
      Set Test Variable  ${SMOD_R}  ${smod_r}
    END

Step3: Set sender and receiver
    Log  Step3: Set sender and receiver  console=true
    Get SMOD position  ${DIST_NAME_FIRST_FSP}
    ${core}  ${id_bbmod}  Get BBMOD position  ${DIST_NAME_FIRST_FSP}
    set test variable  ${CORE}  ${core}
    set test variable  ${ID_BBMOD}  ${id_bbmod}
    ${RECEIVER}  Run keyword if  '${CORE}'=='1'
    ...  Set variable  0x10110009
    ...  ELSE
    ...  Set variable  0x20110009
    ${node_value_hex}  Convert to Hex  ${NODE_VALUE}
    ${SENDER}  Set variable  0X${node_value_hex}0000
    ${SENDER_DECI}  Convert To Integer  0X${node_value_hex}0000
    ${RECEIVER_DECI}  Convert To Integer  ${RECEIVER}
    Set Test Variable  ${SENDER}
    Set Test Variable  ${RECEIVER}
    Log  Sender: ${SENDER}  console=true
    Log  Receiver: ${RECEIVER}  console=true

Step4: Send fault 476
    [Documentation]  This step provdes triger fault 476 on 1st DSP of FSP processing LTE only.
    Log  Step4: Send fault 476  console=${TRUE}
    ${faultParams}=  Create List  0  0  0  0  0  0  0  0  0  0  0  0  0  0
    ${send_fault}=  Run keyword and return status  send_fault_ind_msg  ${SENDER}  ${RECEIVER}  476  1  fault_params=@{faultParams}
    Run keyword if  ${send_fault}
    ...  Log  Fault 476 was sent. [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Fault 476 was not sent. [NOK]

Verify deployed cells status
    [Arguments]  ${cells}  ${availability_status}  ${operational_status}
    ${availability}  Run Keyword And Return Status  Should Be Equal  ${cells.stateInfo}[availabilityStatus]  ${availability_status}
    ${operational}  Run Keyword And Return Status  Should Be Equal  ${cells.stateInfo}[operationalState]  ${operational_status}
    Run Keyword If  ${availability} and ${operational}
    ...  Log  Cell ${cells.dist_name} is in expected status  console=true
    ...  ELSE
    ...  Log  Cell ${cells.dist_name} is in unexpected status: availability=${availability} and operational=${operational}  level=WARN  console=true

Step5: Verify SBTS fault
    Log  Step5: Verify SBTS fault  console=${TRUE}
    ${bbmod_status}  Wait Until Keyword Succeeds  ${TIME_BBMOD_STATE}  10s  Check bbmod  ${Degraded_}
    Run keyword if  ${bbmod_status}
    ...  Log  BBMOD was degraded [OK].  console=true
    ...  ELSE
    ...  Set test restriction  msg=BBMOD was not degraded.
    ${smod_status}  Wait Until Keyword Succeeds  ${TIME_SMOD_STATE}  10s  Check smod  ${Degraded_}
    Run keyword if  ${smod_status}
    ...  Log  SMOD was degraded [OK].  console=true
    ...  ELSE
    ...  Set test restriction  msg=SMOD was not degraded.

    ${alarm_status}=  Wait Until Keyword Succeeds  ${TIME_APPEAR_ALARM}  10s  Assert Alarm Active  parameters=${PARAMETERS}  timeout=360
    Run Keyword if  ${alarm_status}
    ...  Log  Fault 476 with alarm "7101 Baseband card autonomous reset as recovery action" occured [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Fault 476 with alarm "7101 Baseband card autonomous reset as recovery action" didn't occur [NOK]
    Wait Until Keyword Succeeds  120s  10s  Checking cells on the given FSP  ${LIST_CELLS_ON_FSP}

Checking cells on the given FSP
    [Arguments]  ${LIST_CELLS_ON_FSP}
    Log  Cells on FSP were found and will be checked  console=true
    FOR  ${cell}  IN  @{LIST_CELLS_ON_FSP}
      ${cell_obj}=  Query Infomodel  get object ${cell}
      Wait Until Keyword Succeeds  180s  10s  Verify deployed cells status  ${cell_obj}  Failed  Disabled
    END

Step6: Verify SBTS after recovery
    Log  Step6: Verify SBTS after recovery   console=${TRUE}
    ${alarm_cleared}=  Wait Until Keyword Succeeds  ${TIME_DISAPPEAR_ALARM}  10s  Assert Alarm Inactive  parameters=${PARAMETERS}  timeout=360
    Run Keyword If  ${alarm_cleared}
    ...  Log  Fault 476 with alarm "7101 Baseband card autonomous reset as recovery action" dissapeared [OK]  console=${TRUE}
    ...  ELSE
    ...  Set Test Failed  Fault 476 with alarm "7101 Baseband card autonomous reset as recovery action" is still visible after recovery action [NOK]
    ${bbmod_status}  Wait Until Keyword Succeeds  ${TIME_BBMOD_STATE}  10s  Assert Every  BBMOD  operationalState=${Enabled_}  timeout=60
    Run keyword if  ${bbmod_status}
    ...  Log  BBMOD is enabled [OK].  console=true
    ...  ELSE
    ...  Set test restriction  msg=BBMOD is not enabled.
    ${smod_status}  Wait Until Keyword Succeeds  ${TIME_SMOD_STATE}  10s  Assert Every  SMOD  operationalState=${Enabled_}  timeout=60
    Run keyword if  ${smod_status}
    ...  Log  SMOD is enabled [OK].  console=true
    ...  ELSE
    ...  Set test restriction  msg=SMOD is not enabled.
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}

Check bbmod
    [Arguments]  ${availability_status}
    ${result}  Wait until keyword succeeds  20s  1s  Assert Any  BBMOD  availabilityStatus=${availability_status}  timeout=60
    [Return]  ${result}

Check smod
    [Arguments]  ${availability_status}
    ${result}  Wait until keyword succeeds  20s  1s  Assert Any  SMOD  availabilityStatus=${availability_status}  timeout=60
    [Return]  ${result}

TC Setup
    Common test setup

TC Teardown
    Change parameter actForce(Unit)AutoReset  false  actForceUnitAutoReset
    Common Test Teardown
