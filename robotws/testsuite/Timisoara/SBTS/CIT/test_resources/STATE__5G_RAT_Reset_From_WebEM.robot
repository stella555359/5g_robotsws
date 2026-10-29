*** Settings ***
Documentation
    ...  TC for NR RAT reset from Web EM. At first NR RAT reset is performed (whole operation from sending trigger
    ...  request to NR reaching On Air again). Time between first NR cell down and last NR cell up is measured and it is added
    ...  in the console and .json file from Delta_results. After NR RAT reset, all cells from other technologies are checked
    ...  and they must be on Air.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${NR_RAT_RESET_TIMEOUT}  600
${TIMEOUT}  700


*** Keywords ***
TC__STATE__5G_RAT_Reset_From_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21233
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21233 - Test creation
    ...  - 10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23933 - Fixed for configuration with only 5G cells
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-STATE  OWNER-bogdan.boldurean@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  SW-SBTS21

    Step 0: Check If NR Cell Exists
    Step 1: Perform NR RAT Reset
    Step 2: Save Infomodel Log For TC Checks
    Step 3: Check If NR Cells Were Degraded
    Step 4: Check If Cells On Other RATs Are OnAir
    Step 5: Check If NR Cells Are OnAir


Step 0: Check If NR Cell Exists
    Log  Step 0: Check if NR cell exists  console=true
    Run Keyword If  ${SCF_COUNT_NR} == 0
    ...  Fail  NR cell does not exist!


Check NR Cells
    [Arguments]  ${usage_state}  ${operational_state}  ${availability_state}

    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every  NRCEL  usageState=${usage_state}, operationalState=${operational_state}, availabilityStatus=${availability_state}  timeout=160


Step 1: Perform NR RAT Reset
    [Timeout]  15 min

    Log  Step 1: Perform NR RAT reset  console=True
    ${result}  coam.Reset_rat  rat_type=NR  timeout=${NR_RAT_RESET_TIMEOUT}  connection=default
    Log  Reset NR RAT was performed  console=true


Step 3: Check If NR Cells Were Degraded
    [Timeout]  15 min

    Log  Step 3: Check if NR cells were degraded  console=True
    ${nr_cells_objects}  Query Infomodel  get list ${DIST_NR_CELL}
    FOR  ${cell_object}  IN  @{nr_cells_objects}
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.operationalState: ${ENABLED} -> ${DISABLED}]
        Validate Ims2
        Log  ${cell_object.dist_name} states changed: operationalState: Enabled -> Disabled  console=True
        Initialize Ims2 Validator  ${IM_LOG_PATH}
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.administrativeState]
        Add Expected Ims2 Event  change ${cell_object.dist_name} [stateInfo.blockingState]
        Run Keyword And Expect Error  InfoModelIms2ValidationException:*
        ...  Validate Ims2
        Log  ${cell_object.dist_name} administrativeState and blockingState remained unchanged  console=True
    END


Step 2: Save Infomodel Log For TC Checks
    [Timeout]  15 min

    Log  Step 2: Save Infomodel log for TC checks  console=True
    Sleep  120s  Wait for DSPs states save inside IM
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_LTE_RAT_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_LTE_RAT_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}  console=True


Step 4: Check If Cells On Other RATs Are OnAir
    [Timeout]  15 min

    Log  Step 4: Check if cells on other RATs were operational  console=True
    Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${IM_LOG_PATH}
    Infomodel Check If Cells In RAT Were Operational According To IM Log  LTE  ${IM_LOG_PATH}


Step 5: Check If NR Cells Are OnAir
    [Timeout]  15 min

    Log  Step 5: Check if NR cells are operational  console=True
    Wait Until Keyword Succeeds  ${TIMEOUT}s  10s
    ...  Check NR Cells States


Check NR Cells States
    ${are_lncels_online}  Verify NR Cells States
    Should Be True  ${are_lncels_online}  Not all NR cells are online after NR RAT reset


TC Setup
    Common Test Setup  tc_name=STATE__5G_RAT_Reset_From_WebEM


TC Teardown
    Common Test Teardown
