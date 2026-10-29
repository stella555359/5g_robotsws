*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...

Library  Collections
Library  DateTime
Library  String

Resource  ../Setup/setup_and_teardown.robot
Resource  ../../Resources/Integration_Self_Building_Blocks/test_scripts.robot
Resource  ../../TestCases/STARTUP/SiSo_STARTUP_Site_Reset.robot


*** Variables ***
${LNCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${WNCEL_onair_states}=  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${NRCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${GNCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...  usageState=regex"(?i)Active"


*** Keywords ***
Block Unblock Cell TG
  [Documentation]    class=NRCELL, LNCEL

  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Block Unblock Cell TG
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Block Unblock Cell Test Group  ${index}  &{MAIN_DICT}
  END

Block Unblock Cell Test Group
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Block Cell TG
  ${lte_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.lte_cell_list}
  ${nr_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.nr_cell_list}
  ${wcdma_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.wcdma_cell_list}
  ${gsm_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.gsm_cell_list}
  ${time}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.time}
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  ${lte_cell_list_status}
    @{lte_cell_list}=  Split String    ${kwargs.lte_cell_list}  ,
  ELSE
    @{lte_cell_list}=  Create List
  END
  IF  ${nr_cell_list_status}
    @{nr_cell_list}=  Split String    ${kwargs.nr_cell_list}  ,
  ELSE
    @{nr_cell_list}=  Create List
  END
  IF  ${wcdma_cell_list_status}
    @{wcdma_cell_list}=  Split String    ${kwargs.wcdma_cell_list}  ,
  ELSE
    @{wcdma_cell_list}=  Create List
  END
  IF  ${gsm_cell_list_status}
    @{gsm_cell_list}=  Split String    ${kwargs.gsm_cell_list}  ,
  ELSE
    @{gsm_cell_list}=  Create List
  END
  IF  not ${time}
    Set Test Variable  ${time}  20
  ELSE
    Set Test Variable  ${time}  ${kwargs.time}
  END
  IF  not ${timeout}
    Set Test Variable  ${timeout}  240
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  FOR  ${cell}  IN  @{lte_cell_list}
    Block One Cell Procedure  cell=${cell}  technology=LNCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{nr_cell_list}
    Block One Cell Procedure  cell=${cell}  technology=NRCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{wcdma_cell_list}
    Block One Cell Procedure  cell=${cell}  technology=WNCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{gsm_cell_list}
    Block One Cell Procedure  cell=${cell}  technology=GNCEL  &{kwargs}
  END
  Logging With Timestamp  message=Iteration ${index} - procedure - Wait Specified Time:${time}.
  sleep  ${time}
  Logging With Timestamp  message=Iteration ${index} - procedure - Unblock Cell
  FOR  ${cell}  IN  @{lte_cell_list}
    Unblock One Cell Procedure  cell=${cell}  technology=LNCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{nr_cell_list}
    Unblock One Cell Procedure  cell=${cell}  technology=NRCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{wcdma_cell_list}
    Unblock One Cell Procedure  cell=${cell}  technology=WNCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{gsm_cell_list}
    Unblock One Cell Procedure  cell=${cell}  technology=GNCEL  &{kwargs}
  END
  [Teardown]  ISBB Teardown  &{kwargs}


BTS Site Reset TG
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  BTS Site Reset TG
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  BTS Site Reset Test Group  ${index}  &{MAIN_DICT}
  END

BTS Site Reset Test Group
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  ${graceful}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.graceful}
  ${expected_BTS_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.expected_BTS_status}
  ${HW_check}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.HW_check}
  ${cells_check}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.cells_check}
  IF  not ${graceful}
    Set Test Variable  ${graceful}  ${FALSE}
  ELSE
    Set Test Variable  ${graceful}  ${kwargs.graceful}
  END
  IF  not ${expected_BTS_status}
    Set Test Variable  ${expected_BTS_status}  OnAir
  ELSE
    Set Test Variable  ${expected_BTS_status}  ${kwargs.expected_BTS_status}
  END
  IF  not ${HW_check}
    Set Test Variable  ${HW_check}  ${False}
  ELSE
    Set Test Variable  ${HW_check}  ${kwargs.HW_check}
  END
  IF  not ${cells_check}
    Set Test Variable  ${cells_check}  ${True}
  ELSE
    Set Test Variable  ${cells_check}  ${kwargs.cells_check}
  END
  Logging With Timestamp  message=Iteration ${index} - procedure - BTS Site Reset Test Group
  Logging With Timestamp
    ...  message=Site Reset for BTS-${BTS_ID} will be executed. Graceful Shutdown is ${graceful}. Please wait...
    ${reset_response}=  Run Keyword And Continue On Failure    admin.Reset Site
    ...  connection=${BTS_ID}
    ...  wait_for_reconnection=True
    ...  detailed_output=True
    ...  graceful_cell_shutdown=${graceful}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  CM BTS Admin Not Available
    ...  node=${BTS_ID}
    ...  timeout=120
  ${procedure_result}=  STATE.STATE Verify BTS states
  ...  node_id=${BTS_ID}
  ...  expected_BTS_status=${expected_BTS_status}
  ...  HW_check=${HW_check}
  ...  cells_check=${cells_check}
  ...  scf_check=${FALSE}
  ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}
