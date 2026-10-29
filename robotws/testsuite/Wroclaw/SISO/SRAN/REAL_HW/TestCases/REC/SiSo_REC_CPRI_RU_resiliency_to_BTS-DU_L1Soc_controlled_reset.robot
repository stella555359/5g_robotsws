*** Settings ***
Documentation
...  AUTHOR-piotr.korczynski@nokia.com  MAINTAINER-piotr.korczynskia@nokia.com
...  [CASE LINK]: https://rep-portal.ext.net.nokia.com/details/qc-case/3658906/
...
...  *****************
...  Basic information
...  *****************
...
...
...  Step 1: Check Uptime For Specific Radio Unit
...  Checking the uptime for the specified radio unit.
...
...  Step 2: L3 Call
...  Performing L3 call.
...
...  Step 3: Activate CPRI RU reset resiliency
...  Activating the CPRI RU reset resiliency.
...
...  Step 4: Verify value of cntrldResetMplaneBreakTime
...  Verifying the value of cntrldResetMplaneBreakTime.
...
...  Step 5: Trigger RAT Reset And Verify Result
...  Triggering RAT reset and verifying the result.
...
...  Step 6: Verify RU State After Reset Recovery
...  Verifying the RU state after reset recovery.
...
...  Step 7: L3 Call
...  Performing L3 call.
...
...  Step 8: Deactivate CPRI RU reset resiliency
...  Deactivating the CPRI RU reset resiliency.
...
...  ******************
...  History of changes
...  ******************
...  - 04.10.2024 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_Capacity_Unit_controlled_reset.robot


*** Variables ***
${CUSTOM_KPI_CALCULATION}=  ${TRUE}
${prompt}=  >|$


*** Keywords ***
SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset
  [Documentation]
  ...  Description:
  ...  Executes the resiliency test for CPRI RU to BTS-DU with controlled reset.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Common Test Setup  tools_to_setup=syslog_ADMIN
  Logging With Timestamp
  ...  message=SiSo_REC_CPRI_RU_resiliency_to_BTS-DU_L1Soc_controlled_reset will be executed
  ...  style=ONGOING
  ${ru_uptime}=  Create Dictionary  &{EMPTY}
  Set Test Variable  ${RU_UPTIME}
  FOR  ${radio_unit}  IN  @{CUSTOM_RADIO_UNIT_LIST}
    ${bts_id}=  Precondition For RU Resiliency Test  ${radio_unit}
    Step 1 Check Uptime For Specific Radio Unit  ${bts_id}  ${radio_unit}
    Step 2 L3 Call
    Step 3 Activate CPRI RU reset resiliency  ${bts_id}
    Step 4 Verify value of cntrldResetMplaneBreakTime  ${bts_id}
    Step 5 Trigger RAT Reset And Verify Result  ${bts_id}  ${radio_unit}
    Step 6 Verify RU State After Reset Recovery
    Step 7 L3 Call
    Step 8 Deactivate CPRI RU reset resiliency
  END
  [Teardown]  Common Test Teardown

Step 5 Trigger RAT Reset And Verify Result
  [Arguments]  ${bts_id}  ${radio_unit}
  [Documentation]
  ...  Description:
  ...  Triggers RAT reset and verifies the result.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS identifier                                                             |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | radio_unit             | yes  | Radio unit identifier                                                      |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Step 5 Trigger RAT Reset And Verify Result
  ...  style=STEP
  ...  frame=${TRUE}
  ${lte_cell_number}=  Get From Dictionary  ${CFG.RF_INFO['${radio_unit}']['LNCEL']}  scf_cell_count_primary
  ${nr_cell_number}=  Get From Dictionary  ${CFG.RF_INFO['${radio_unit}']['NRCEL']}  scf_cell_count_primary
  Run Keyword If  '${lte_cell_number}' > '0'
  ...  Reset RAT And Verify State  ${bts_id}  LTE
  Run Keyword If  '${nr_cell_number}' > '0'
  ...  Reset RAT And Verify State  ${bts_id}  5G
  Run Keyword And Continue On Failure  FM Check Unexpected And Historical Faults  node_id=${bts_id}

Reset RAT And Verify State
  [Arguments]  ${bts_id}  ${RAT_type}
  [Documentation]
  ...  Description:
  ...  Resets RAT and verifies the state.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | bts_id                 | yes  | BTS identifier                                                             |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | RAT_type               | yes  | RAT type (e.g., LTE, 5G)                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Reset RAT And Verify State
  ${state_rat}=  Set Variable If  '${RAT_type}'=='LTE'  LTE  NR
  Run Keyword And Continue On Failure  admin.Rat Reset  rat_type=${state_rat}  reset_type=Hard  timeout=600  connection=${bts_id}
  Logging With Timestamp
  ...  message=Reset RAT - ${RAT_type} - for BTS-${bts_id} finished. Please wait for BTS state verification...
  Wait Until Keyword Succeeds  600  20
  ...  STATE Check If All Cells For RAT Are OnAir  rat=${state_rat}  timeout=10  bts_id=${bts_id}
  Run Keyword And Continue On Failure  STATE Verify BTS states
  ...  node_id=${bts_id}
  ...  expected_BTS_status=OnAir
  ...  HW_check=${TRUE}
  ...  cells_check=${TRUE}
  ...  scf_check=${FALSE}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
