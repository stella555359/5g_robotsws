*** Settings ***
Documentation
  ...  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...  [CASE LINK]:
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  In Test Suite it is neccesasry to add variable ${BBMOD_SERIAL_NUMBERS}
  ...  List with all ABIA's that are taking part in test e.g. @{BBMOD_SERIAL_NUMBERS}  L1164500940  L1164505613
  ...  If call is needed to be performed on selected cells, please provide list of cells in variable ${SELECTED_CELLS}
  ...  and set variable ${SISO_L3_CALL} to True.
  ...  Purpose of the test is to verify support the parameter value '12:First power group WCDMA' for the allocCriterion
  ...  parameter, when one AirScale subrack equipped with one ASIA (or newer) common plug-in unit and at two ABIA
  ...  capacity units and several LTE radio units and one WCDMA radio unit.
  ...  Grouping of cells:
  ...  'NPSC' LTE cells (non-power saving cells):
  ...  1. LTE cells within a power saving group with flag lbpsLastCellSOEnabled set to false and with cell order
  ...  lbpsCellSOOrder set to 100.
  ...  2. LTE cells not belonging to a power saving group.
  ...  3. Cells with actOtdoa set to true and cells used for public safety purposes.
  ...  'PSC' LTE cells (power saving cells):
  ...  1. LTE cells within a power saving group which are not 'NPSC' cells.
  ...  ******************
  ...  Step 1 Preconditions For PG WCDMA Two Abias.
  ...  Check if the following parameters are set correctly:
  ...  EQM/APEQM/CABINET/BBMOD/useFullCapacity shall be set to 'true' for baseband boards.
  ...  EQM/APEQM/CABINET/BBMOD/bbCardUsage shall be set to '2' for both baseband boards.
  ...  Manual allocation of cells to pools and/or baseband boards shall not be used (bbPoolAllocMode = automatic)
  ...  None of the cells shall be within an UL CoMP cell set list and UL CoMP shall not be activated (actCoMp = 'disabled')
  ...  For all the cells actOtdoa shall be set to 'false'.
  ...  eMBMS services including public safety bearers shall be neither configured nor activated (actMBMSPS = 'false' & actPubSafetyBearers = 'false')
  ...  bbPoolAllocPrioList shall be empty
  ...  actLBPowerSaving shall be set to 'true'
  ...  lbpsLastCellSOEnabled for all power saving groups shall be set to 'false'
  ...  actLBBbPowerSaving shall be set to 'true'
  ...  Power Saving Group is created: MRBTS-x/LNBTS-x/PSGRP-x
  ...  under PSGRP structure lbpsCellList is created
  ...  under lbpsCellList: lbpsCellSOOrder, lnCelId are set
  ...
  ...  Step 2 Perform Recommissioning For PG WCDMA Two Abias
  ...  Perform delta recommisioning with following parameter change:
  ...  Under MRBTS-X/LNBTSX/ bbPoolAllocPrioList set :
  ...  allocCriterion to PSGRP priority
  ...  allocPriority set between 1 and 9
  ...  allocCriterion to First power group WCDMA
  ...  allocPriority set to 10
  ...  After changing parameters BTS is on air (BEFORE RESET!)
  ...
  ...  Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA Two Abias
  ...  All cells which are allocated on ABIA #1 and which are NPSC cells shall be within baseband pool #1 of
  ...  ABIA #1 (which is the primary power group on ABIA). This can be checked in Configuration Managment
  ...  Parameter Editor. Cells are listed under:
  ...  MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOLx1
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList: MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R-1/BBMOD_R-x/POWERGROUP_R-1
  ...  All cells which are allocated on ABIA #2 and which are PSC cells shall be allocated on baseband pool #2 of ABIA #2.
  ...  Cells are listed under: MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOLx2
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList: MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R1/BBMOD_R-x/POWERGROUP_R-2
  ...  On ABIA #2 for WCDMA cell are allocated on baseband pool #1 of ABIA #2. Cells are listed under: MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOLx1
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList: MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R-1/BBMOD_R-x/POWERGROUP_R-1
  ...  LTE cells are allocated on baseband pool #2 of ABIA #2. Cells are listed under: MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOLx2
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList: MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R-1/BBMOD_R-x/POWERGROUP_R-2
  ...  For baseband boards other than ABIA the cell allocation shall not be changed
  ...
  ...  Step 4 L3 Call For PG WCDMA Two Abias on selected cells.
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 07.02.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/SiSo_L3_call.robot
Resource  ./CM_PSGRP.resource
*** Variables ***
${SELECTED_CELLS}
&{WCDMA_DICT}  # Dictionary that for key uses value from RNC and for value cell id, xample   1=56212
${SISO_L3_CALL}  False  #default value for L3 call is False, set test variable as True to perform test with L3 call
${CELLS_YAML_PATH}  #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
*** Keywords ***
TC__SiSo_CM_First_power_group_WCDMA_two_ABIAs
    Set Tags     AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=SiSo_CM_First_power_group_WCDMA_two_ABIAs.robot will be executed
    ...  style=ONGOING
    ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}  Step 1 Preconditions For PG WCDMA Two Abias
    ${restore_conf}  Step 2 Perform Recommissioning For PG WCDMA Two Abias  ${bts_id}
    Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA Two Abias
    ...  bts_id=${bts_id}
    ...  npsc_cells_list=${npsc_cells_list}
    ...  psc_cells_list=${psc_cells_list}
    Step 4 L3 Call For PG WCDMA Two Abias
    [Teardown]  Run Keywords  Restore config  ${bts_id}  ${restore_conf}  ${restore_delta}
    ...  AND  Common Test Teardown

Step 1 Preconditions For PG WCDMA Two Abias
    [Documentation]
    ...  Description:
    ...  Perform precondition for PG WCDMA Two Abias test with creating lists/dicts with cells necessary for TC.
    ...
    ...  Return:
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                                        |
    ...  +=======================+====================================================================================================+
    ...  | npsc_cells_list       | List of cells which are NPSC cells e.g. ${npsc_cells_list} = [29901]                               |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | psc_cells_list        | List of cells which are PSC cells e.g. ${psc_cells_list} = [29904, 29910]                          |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | restore_delta         | string in json format with delta recommissioning info                                              |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 1 Preconditions For PG WCDMA Two Abias
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Checking if parameters are correct before exucution of test. Please wait...
    ...  style=ONGOING
    ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}  Preconditions For Power Group
    Logging With Timestamp
    ...  message=Step 1 Preconditions For PG WCDMA Two Abias
    ...  style=DONE
    [Return]  ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}

Step 2 Perform Recommissioning For PG WCDMA Two Abias
    [Arguments]    ${bts_id}
    [Documentation]
    ...  Description:
    ...  Perform recommissioning with additional parameters added as stated in ${delta_string} variable
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Return:
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                                        |
    ...  +=======================+====================================================================================================+
    ...  | restore_conf          | True if delta was already recommisioned in order to bring back base conf after test ends           |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 2 Perform Recommissioning For PG WCDMA Two Abias
    ...  style=STEP
    ...  frame=${TRUE}
    ${delta_part1}  Set Variable
    ...  [{"distName":"MRBTS-${bts_id}/LNBTS-${bts_id}","operation":"update","parameters":[{"parameterName":"bbPoolAllocPrioList",
    ${delta_part2}  Set Variable
    ...  "value":[{"allocCriterion":"PSGRP priority","allocPriority":"${random_allocPriority}"},{"allocCriterion":"First power group WCDMA",
    ${delta_string}  Set Variable  ${delta_part1}${delta_part2}"allocPriority":"10"}],"operation":"update"}]}]
    ${restore_conf}  Perform Recommissioning With Delta String  ${bts_id}  ${delta_string}
    Wait Until Keyword Succeeds  10x  60  STATE Verify BTS states  node_id=${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Perform Recommissioning For PG WCDMA Two Abias
    ...  style=DONE
    [Return]  ${restore_conf}

Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA Two Abias
    [Arguments]  ${bts_id}  ${npsc_cells_list}  ${psc_cells_list}  ${graceful}=False
    [Documentation]
    ...  Description:
    ...  Perform reset site and check if NPSC and PSC cells are allocated correctly
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | npsc_cells_list        | Yes  | List of cells which are NPSC cells                                         |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...  | psc_cells_list         | Yes  | List of cells which are PSC cells                                          |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...  | graceful               |  No  | If graceful cell shutdown is necessary. Default value False                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA Two Abias
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts_id} will be executed. Graceful Shutdown is ${graceful}. Please wait...
    ...  style=ONGOING`
    ${reset_response}=  Run Keyword And Continue On Failure    admin.Reset Site
    ...  connection=${bts_id}
    ...  wait_for_reconnection=True
    ...  detailed_output=True
    ...  graceful_cell_shutdown=${graceful}
    ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
    Logging With Timestamp
    ...  message=Site Reset for BTS-${bts_id} finished.
    ...  style=DONE
    Wait Until Keyword Succeeds  10x  60  STATE Verify BTS states  node_id=${bts_id}
    Check NPSC and PSC cells For PG WCDMA  bts_id=${bts_id}  npsc_cells_list=${npsc_cells_list}  psc_cells_list=${psc_cells_list}

Step 4 L3 Call For PG WCDMA Two Abias
    [Documentation]
    ...  Description:
    ...  Perform L3 Call on selected cells For PG Wcdma Two ABIAs test.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 4 Perform L3 Call For PG WCDMA Two Abias
    ...  style=STEP
    ...  frame=${TRUE}
    IF  ${SISO_L3_CALL}
#      SiSo L3 Call  cells_input=${SELECTED_CELLS}
      Logging With Timestamp
      ...  message=Step 4 Perform L3 Call For PG WCDMA Two Abias
      ...  style=DONE
    ELSE
      Logging With Timestamp
      ...  message=Step 4 skipped.
      ...  style=DONE
    END
