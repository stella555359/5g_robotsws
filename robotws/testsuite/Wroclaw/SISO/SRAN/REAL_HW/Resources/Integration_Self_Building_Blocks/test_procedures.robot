*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Library with basic keywords responsible for creating admin and syslog session

Library  Collections
Library  DateTime
Library  String

Resource  ../Setup/setup_and_teardown.robot
Resource  ../../Resources/Integration_Self_Building_Blocks/test_scripts.robot


*** Variables ***
${LNCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${WNCEL_onair_states}=  operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked", usageState=regex"(?i)Active"
${NRCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked"
${GNCEL_onair_states}=  administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled", blockingState=regex"(?i)Unblocked",
...  usageState=regex"(?i)Active"


*** Keywords ***
Get Active Alarms On BTS
  [Arguments]  &{kwargs}
  [Documentation]
  ...  Description:
  ...  Get active alarms to console and txt report file.
  ...  Arguments:
  ...  timeout= time for Admin API wait
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Set Test Variable
  ...  ${test_name}  Get Active Alarms On BTS
  Logging With Timestamp
  ...  message=${test_name} - Procedure started.
  ...  style=ONGOING
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Get Active Alarms On BTS Procedure  ${index}  &{MAIN_DICT}
  END

Get Active Alarms On BTS Procedure
  [Arguments]  ${index}  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Check Active Alarms On BTS Iteration
  ${procedure_result}=  Run Keyword And Continue On Failure  admin.get active alarms
  ...  connection=${BTS_ID}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

Check BTS STATE IS OnAir
  [Arguments]  &{kwargs}
  [Documentation]
  ...  Description:
  ...  Get active alarms to console and txt report file.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Set Test Variable
  ...  ${test_name}  Check BTS STATE IS OnAir
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Check BTS STATE IS OnAir Procedure  ${index}  &{MAIN_DICT}
  END

Check BTS STATE IS OnAir Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Check Active Alarms On BTS Iteration
  ${procedure_result}=  STATE.STATE Verify BTS states
  ...  node_id=${BTS_ID}
  ...  expected_BTS_status=OnAir  HW_check=${False}  cells_check=${TRUE}  scf_check=${TRUE}  timeout=${kwargs.timeout}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

Check If All Cells Are OnAir
  [Arguments]  &{kwargs}
  [Documentation]
  ...  Description:
  ...  Get active alarms to console and txt report file.
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Set Test Variable
  ...  ${test_name}  Check If All Cells Are OnAir
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Check BTS STATE IS OnAir Procedure  ${index}  &{MAIN_DICT}
  END

Check If All Cells Are OnAir Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Check Active Alarms On BTS Iteration
  ${procedure_result}=  STATE.STATE Check If All Cells Are OnAir
  ...  bts_id=${BTS_ID}
  ...  timeout=60
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

Check If Cell Is In Requested State
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Check If Cell Is In Requested State
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Check If Cell Is In Requested State Procedure  ${index}  &{MAIN_DICT}
  END

Check If Cell Is In Requested State Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Check If Cell Is In Requested State
  ${dict_key}=  Set Variable  ${cfg.NODES['${BTS_ID}']['${kwargs['class']}']['${kwargs.cell}']}
  ${dist_name}=  Get From Dictionary  ${dict_key}  scf_dist_name
  ${dist_name}=  Convert To String  ${dist_name}
  ${rat_type}=  Set Variable If  '${kwargs['class']}' == 'LNCEL'  LTE
  ...  '${kwargs['class']}' == 'GNCEL'  GSM
  ...  '${kwargs['class']}' == 'WNCEL'  WCDMA
  ...  '${kwargs['class']}' == 'NRCEL'  NR
  ${cell_id}=  Run Keyword And Continue On Failure
  ...  admin.Get Cell Id By Configuration Id
  ...  ${rat_type}
  ...  configuration_id=${kwargs.cell}
  ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
  ...  connection=${BTS_ID}
  ${procedure_result}=  STATE.STATE Verify States For One
  ...  node_id=${BTS_ID}
  ...  states=${kwargs.states}
  ...  onair=${kwargs.onair}
  ...  timeout=${kwargs.timeout}
  ...  object=${cell_id}
  ...  class=${kwargs['class']}
  [Teardown]  ISBB Teardown  &{kwargs}

############### OPERATIONS ######################

Block Cell
  [Documentation]    class=NRCELL, LNCEL

  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Block Cell
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Block Cell Procedure  ${index}  &{MAIN_DICT}
  END

Block Cell Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Block Cell
  ${lte_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.lte_cell_list}
  ${nr_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.nr_cell_list}
  ${wcdma_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.wcdma_cell_list}
  ${gsm_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.gsm_cell_list}
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
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
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
  [Teardown]  ISBB Teardown  &{kwargs}

Block One Cell Procedure
  [Arguments]    ${cell}  ${technology}  &{kwargs}
  ${dict_key}=  Set Variable  ${cfg.NODES['${BTS_ID}']['${technology}']['${cell}']}
  ${dist_name}=  Get From Dictionary  ${dict_key}  scf_dist_name
  ${dist_name}=  Convert To String  ${dist_name}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  ${cell_id}=  admin.Get Cell Id By Configuration Id
  ...  ${rat_type}
  ...  configuration_id=${cell}
  ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
  ...  connection=${BTS_ID}
  ${procedure_result}=  Run Keyword And Continue On Failure
  ...  admin.Block Cell  dist_name=${cell_id}  timeout=${kwargs.timeout}  connection=${BTS_ID}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}


Unblock Cell
  [Documentation]    class=NRCELL, LNCEL

  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Unblock Cell
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Unblock Cell Procedure  ${index}  &{MAIN_DICT}
  END

Unblock Cell Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Unblock Cell
    ${lte_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.lte_cell_list}
  ${nr_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.nr_cell_list}
  ${wcdma_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.wcdma_cell_list}
  ${gsm_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.gsm_cell_list}
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
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
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

Unblock One Cell Procedure
  [Arguments]    ${cell}  ${technology}  &{kwargs}
  ${dict_key}=  Set Variable  ${cfg.NODES['${BTS_ID}']['${technology}']['${cell}']}
  ${dist_name}=  Get From Dictionary  ${dict_key}  scf_dist_name
  ${dist_name}=  Convert To String  ${dist_name}
  ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
  ...  '${technology}' == 'GNCEL'  GSM
  ...  '${technology}' == 'WNCEL'  WCDMA
  ...  '${technology}' == 'NRCEL'  NR
  ${cell_id}=  admin.Get Cell Id By Configuration Id
  ...  ${rat_type}
  ...  configuration_id=${cell}
  ...  timeout=${BASIC_ADMIN_PROCEDURES_TIMEOUT}
  ...  connection=${BTS_ID}
  ${procedure_result}=  Run Keyword And Continue On Failure
  ...  admin.Unblock Cell  dist_name=${cell_id}  timeout=${timeout}  connection=${BTS_ID}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}

Lock Radio
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Lock Radio
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Lock Radio Procedure  ${index}  &{MAIN_DICT}
  END

Lock Radio Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Lock Radio
  @{radio_unit_list}=  Split String    ${kwargs.ru_sn}  ,
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  FOR  ${ru}  IN  @{radio_unit_list}
    ${ru_bts_id}  ${ru_dist_name}=  SITE Get RU Node Data  ${ru}
    ${ru_dist_name}=  Convert To String  ${ru_dist_name}
    ${procedure_result}=  Run Keyword And Continue On Failure
    ...  admin.Lock
    ...  dist_name=${ru_dist_name}
    ...  timeout=${timeout}
    ...  connection=${BTS_ID}
  END
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

Unlock Radio
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Unlock Radio
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Unlock Radio Procedure  ${index}  &{MAIN_DICT}
  END

Unlock Radio Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Unlock Radio
  @{radio_unit_list}=  Split String    ${kwargs.ru_sn}  ,
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  FOR  ${ru}  IN  @{radio_unit_list}
    ${ru_bts_id}  ${ru_dist_name}=  SITE Get RU Node Data  ${ru}
    ${ru_dist_name}=  Convert To String  ${ru_dist_name}
    ${procedure_result}=  Run Keyword And Continue On Failure
    ...  admin.Unlock
    ...  dist_name=${ru_dist_name}
    ...  timeout=${timeout}
    ...  connection=${BTS_ID}
  END
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

Reset Radio
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Reset Radio
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Reset Radio Procedure  ${index}  &{MAIN_DICT}
  END

Reset Radio Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Reset Radio
  @{radio_unit_list}=  Split String    ${kwargs.ru_sn}  ,
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  FOR  ${ru}  IN  @{radio_unit_list}
    ${ru_bts_id}  ${ru_dist_name}=  SITE Get RU Node Data  ${ru}
    ${ru_dist_name}=  Convert To String  ${ru_dist_name}
    ${procedure_result}=  Run Keyword And Continue On Failure
    ...  admin.Reset Unit
    ...  dist_name=${ru_dist_name}
    ...  timeout=${timeout}
    ...  connection=${BTS_ID}
  END
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

BTS Block
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  BTS Block
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  BTS Block Procedure  ${index}  &{MAIN_DICT}
  END

BTS Block Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - BTS Block
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  ${procedure_result}=  Run Keyword And Continue On Failure
  ...  admin.block
  ...  timeout=${timeout}
  ...  connection=${BTS_ID}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

BTS Unblock
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  BTS Unblock
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  BTS Unblock Procedure  ${index}  &{MAIN_DICT}
  END

BTS Unblock Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - BTS Unblock
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  ${procedure_result}=  Run Keyword And Continue On Failure
  ...  admin.unblock
  ...  timeout=${kwargs.timeout}
  ...  connection=${BTS_ID}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}
  [Teardown]  ISBB Teardown  &{kwargs}

BTS Reset
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  BTS Reset
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  BTS Reset Procedure  ${index}  &{MAIN_DICT}
  END

BTS Reset Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - BTS Reset
  ${graceful}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.graceful}
  ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${graceful}
    Set Test Variable  ${graceful}  ${FALSE}
  ELSE
    Set Test Variable  ${graceful}  ${kwargs.graceful}
  END
  IF  not ${timeout}
    Set Test Variable  ${timeout}  600
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  Logging With Timestamp
  ...  message=Site Reset for BTS-${BTS_ID} will be executed. Graceful Shutdown is ${graceful}. Please wait...
  ...  style=ONGOING
  ${procedure_result}=  Run Keyword And Continue On Failure    admin.Reset Site
  ...  connection=${BTS_ID}
  ...  wait_for_reconnection=True
  ...  detailed_output=True
  ...  graceful_cell_shutdown=${graceful}
  ...  timeout=${timeout}
  Logging With Timestamp
  ...  message=Site Reset for BTS-${BTS_ID} finished. Graceful Shutdown is ${graceful}. Response from API: ${procedure_result}
  ...  style=DONE
  [Teardown]  ISBB Teardown  &{kwargs}

Power Off Unit
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Power Off Unit
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Power Off Unit Procedure  ${index}  &{MAIN_DICT}
  END

Power Off Unit Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Power Off Unit: ${kwargs.device_sn}
  PDU.PDU Power Off Port By Serial Number  ${kwargs.device_sn}
  [Teardown]  ISBB Teardown  &{kwargs}

PDU check port Unit
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  PDU check port
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    PDU check port Procedure  ${index}  &{MAIN_DICT}
  END

PDU check port Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - PDU check port Unit: ${kwargs.device_sn}
  PDU.PDU Check Port State By Serial Number    ${kwargs.device_sn}
  [Teardown]  ISBB Teardown  &{kwargs}

Power On Unit
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Power On Unit
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Power On Unit Procedure  ${index}  &{MAIN_DICT}
  END

Power On Unit Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Power On Unit: ${kwargs.device_sn}
  PDU.PDU Power ON Port By Serial Number  ${kwargs.device_sn}
  [Teardown]  ISBB Teardown  &{kwargs}

Power Reset Unit
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Power Reset Unit
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Power Reset Unit Procedure  ${index}  &{MAIN_DICT}
  END

Power Reset Unit Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Power Reset Unit: ${kwargs.device_sn}
  ${time}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.time}
  IF  not ${time}
    Set Test Variable  ${time}  20
  ELSE
    Set Test Variable  ${time}  ${kwargs.time}
  END
  PDU.PDU Reset Port By Serial Number  ${kwargs.device_sn}  time_interval=${time}
  [Teardown]  ISBB Teardown  &{kwargs}

Power Reset BTS
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Power Reset BTS
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Power Reset BTS Procedure  ${index}  &{MAIN_DICT}
  END

Power Reset BTS Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Power Reset BTS: ${BTS_ID}
  PDU.PDU Start Power Reset On Node  ${BTS_ID}
  [Teardown]  ISBB Teardown  &{kwargs}

FHS Reset
  [Documentation]    under development !!!
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  FHS Reset
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  FHS Reset Procedure  ${index}  &{MAIN_DICT}
  END

FHS Reset Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - FHS Reset: ${BTS_ID}
    ${timeout}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.timeout}
  IF  not ${timeout}
    Set Test Variable  ${timeout}  20
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
    ${fhs_list}=  admin.Get FHS List  timeout=1200  connection=${BTS_ID}
    ${fhs_items}=  admin.Get IDs For All  FHS  connection=${BTS_ID}
  FOR  ${fhs_under_test}  IN  @{fhs_list}
    Set Test Variable  ${FHS_SN}  ${fhs_under_test}
    Run Keyword If  '${FHS_SN}'!='${fhs['serialNumber']}'  Continue For Loop
    Remove Values From List  ${fhs_sns_temp}  ${fhs_under_test}
    ${fhs_in_the_list}=  Set Variable  True
  END
  ${procedure_result}=  Run Keyword And Continue On Failure    admin.reset unit
  ...  connection=${BTS_ID}
  ...  detailed_output=True
  ...  dist_name=${dist_name}
  ...  timeout=${timeout}
  Logging With Timestamp
  ...  message=FHS Reset finished. Response from API: ${procedure_result}
  ...  style=DONE
  [Teardown]  ISBB Teardown  &{kwargs}
############### Time #####################

Wait Specified Time
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Wait Specified Time
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Wait Specified Time Procedure  ${index}  &{MAIN_DICT}
  END

Wait Specified Time Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Wait Specified Time:${kwargs.time}.
  sleep  ${kwargs.time}
  [Teardown]  ISBB Teardown  &{kwargs}


Cell Administrative State Change
  [Documentation]    class=NRCELL, LNCEL

  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Cell Administrative State Change
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Run Keyword And Continue On Failure  Cell Administrative State Change Procedure  ${index}  &{MAIN_DICT}
  END

Cell Administrative State Change Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Cell Administrative State Change to: ${kwargs.value}
  ${lte_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.lte_cell_list}
  ${nr_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.nr_cell_list}
  ${wcdma_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.wcdma_cell_list}
  ${gsm_cell_list_status}=  Run Keyword And Return Status  Variable Should Exist  ${kwargs.gsm_cell_list}
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
  IF  not ${timeout}
    Set Test Variable  ${timeout}  40
  ELSE
    Set Test Variable  ${timeout}  ${kwargs.timeout}
  END
  FOR  ${cell}  IN  @{lte_cell_list}
    Cell Administrative State Change Basic Procedure  cell=${cell}  technology=LNCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{nr_cell_list}
    Cell Administrative State Change Basic Procedure  cell=${cell}  technology=NRCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{wcdma_cell_list}
    Cell Administrative State Change Basic Procedure  cell=${cell}  technology=WNCEL  &{kwargs}
  END
  FOR  ${cell}  IN  @{gsm_cell_list}
    Cell Administrative State Change Basic Procedure  cell=${cell}  technology=GNCEL  &{kwargs}
  END
  [Teardown]  ISBB Teardown  &{kwargs}

Cell Administrative State Change Basic Procedure
  [Arguments]    ${cell}  ${technology}  &{kwargs}
  ${dict_key}=  Set Variable  ${cfg.NODES['${BTS_ID}']['${technology}']['${cell}']}
  ${dist_name}=  Get From Dictionary  ${dict_key}  scf_dist_name
  ${dist_name}=  Convert To String  ${dist_name}
  Logging With Timestamp  message=Cell Administrative State Change Basic Procedure started for cel id : ${cell} and technology: ${technology}
  ${procedure_result}=  Run Keyword And Continue On Failure
  ...  admin.Perform Parameter Recommissioning
  ...  dist_name=${dist_name}
  ...  parameter=administrativeState
  ...  operation=update
  ...  value=${kwargs.value}
  ...  timeout=${timeout}
  ...  connection=${BTS_ID}
  Logging With Timestamp  message=Procedure result:${\n}${procedure_result}


################### LOGS ########################

Save BTS Snapshot
  [Arguments]  &{kwargs}
  Set Test Variable
  ...  ${test_name}  Save BTS Snapshot
  Prepare Iteration Repetition Loop Variables  &{kwargs}
  FOR  ${index}  IN  @{procedure_iteration_list}
    Save BTS Snapshot Procedure  ${index}  &{MAIN_DICT}
  END

Save BTS Snapshot Procedure
  [Arguments]  ${index}=1  &{kwargs}
  ISBB Setup  ${index}  &{kwargs}
  Logging With Timestamp  message=Iteration ${index} - procedure - Power Reset BTS: ${BTS_ID}
  Run Keyword And Continue On Failure  Logging Session Save Snapshot  logs_dir_path=${PROCEDURE_TEST_LOGS_PATH}  connection=${BTS_ID}
  Set Test Variable  ${CUSTOM_SWITCH_PERFORM_SNAPSHOT}  ${None}
  [Teardown]  ISBB Teardown  &{kwargs}
