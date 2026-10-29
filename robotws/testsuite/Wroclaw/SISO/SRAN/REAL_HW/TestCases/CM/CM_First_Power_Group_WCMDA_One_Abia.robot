*** Settings ***
Documentation
  ...  AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
  ...  [CASE LINK]:
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  In Test Suite it is neccesasry to add variable ${BBMOD_SERIAL_NUMBERS}
  ...  List with all ABIA's that are taking part in test e.g. @{BBMOD_SERIAL_NUMBERS}  L1164500940
  ...  If call is needed to be performed on selected cells, please provide list of cells in variable ${SELECTED_CELLS}
  ...  and set variable ${SISO_L3_CALL} to True.
  ...  Purpose of the test is to verify support the parameter value '12:First power group WCDMA' for the allocCriterion
  ...  parameter, when LTE and WCDMA cells are on one ABIA.
  ...  Grouping of cells:
  ...  'NPSC' LTE cells (non-power saving cells):
  ...  1. LTE cells within a power saving group with flag lbpsLastCellSOEnabled set to false and with cell order
  ...  lbpsCellSOOrder set to 100.
  ...  2. LTE cells not belonging to a power saving group.
  ...  3. Cells with actOtdoa set to true and cells used for public safety purposes.
  ...  'PSC' LTE cells (power saving cells):
  ...  1. LTE cells within a power saving group which are not 'NPSC' cells.
  ...  ******************
  ...  Step 1 Preconditions For PG WCDMA One Abia.
  ...  Check if the following parameters are set correctly:
  ...  EQM/APEQM/CABINET/BBMOD/useFullCapacity shall be set to 'true' for baseband boards.
  ...  EQM/APEQM/CABINET/BBMOD/bbCardUsage shall be set to '2' for both baseband boards.
  ...  Manual allocation of cells to pools and/or baseband boards shall not be used (bbPoolAllocMode = automatic)
  ...  None of the cells shall be within an UL CoMP cell set list and UL CoMP shall not be activated (actCoMp = 'disabled')
  ...  For all the cells actOtdoa shall be set to 'false'.
  ...  eMBMS services including public safety bearers shall be neither configured nor activated (actMBMSPS = 'false' & actPubSafetyBearers = 'false')
  ...  bbPoolAllocPrioList shall brandom_allocPrioritye empty
  ...  actLBPowerSaving shall be set to 'true'
  ...  lbpsLastCellSOEnabled for all power saving groups shall be set to 'false'
  ...  actLBBbPowerSaving shall be set to 'true'
  ...  Power Saving Group is created: MRBTS-x/LNBTS-x/PSGRP-x
  ...  under PSGRP structure lbpsCellList is created
  ...  under lbpsCellList: lbpsCellSOOrder, lnCelId are set
  ...
  ...  Step 2 Perform Recommissioning For PG WCDMA One Abia
  ...  Perform delta recommisioning with following parameter change:
  ...  Under MRBTS-X/LNBTSX/ bbPoolAllocPrioList set :
  ...  allocCriterion to PSGRP priority
  ...  allocPriority set between 1 and 9
  ...  allocCriterion to First power group WCDMA
  ...  allocPriority set to 10
  ...  After changing parameters BTS is on air (BEFORE RESET!)
  ...
  ...  Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA Two Abias
  ...  After restart/reset the PSC cells (power saving) are within secondary power group. This can be checked in Configuration Managment Parameter
  ...  Editor. Cells are listed under:
  ...  MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOL-x2.
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList:
  ...  MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R-1/BBMOD_R-x/POWERGROUP_R-2
  ...  and the NPSC cell (non-power saving) is within the primary power group
  ...  Cells are listed under:
  ...  MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOL-x1. Under this BBPOOL object there should be parameter bbPwrGroupDNList:
  ...  MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R-1/BBMOD_R-x/POWERGROUP_R-1
  ...  For the WCDMA cell fault 1868 is reported (as the ABIA shall be configured for LTE only)
  ...  For baseband boards other than ABIA the cell allocation shall not be changed
  ...
  ...  Step 4 L3 Call For PG WCDMA One Abiaa on selected cells.
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 07.02.2025 - Initial creation


Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/SiSo_L3_call.robot
Resource  ./CM_PSGRP.resource

*** Variables ***
${CELLS_YAML_PATH}
${SELECTED_CELLS}
&{WCDMA_DICT}  # Dictionary that for key uses value from RNC and for value cell id, xample   1=56212
${SINGLE_ABIA}  True
*** Keywords ***
TC__SiSo_CM_First_power_group_WCDMA_one_ABIA
    Set Tags     AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=SiSo_CM_First_power_group_WCDMA_one_ABIA.robot will be executed
    ...  style=ONGOING
    ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}  Step 1 Preconditions For PG WCDMA One Abia
    ${restore_conf}  Step 2 Perform Recommissioning For PG WCMDA One Abia  bts_id=${bts_id}
    Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA One Abia
    ...  bts_id=${bts_id}
    ...  npsc_cells_list=${npsc_cells_list}
    ...  psc_cells_list=${psc_cells_list}
    Step 4 L3 Call For PG WCDMA One Abia
    [Teardown]  Run Keywords  Restore config  ${bts_id}  ${restore_conf}  ${restore_delta}
    ...  AND  Common Test Teardown

Step 1 Preconditions For PG WCDMA One Abia
    [Documentation]
    ...  Description:
    ...  Perform precondition for PG WCDMA One Abia test with creating lists/dicts with cells necessary for TC.
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
    ...  message=Step 1 Preconditions For PG WCDMA One Abia
    ...  style=STEP
    ...  frame=${TRUE}
    Logging With Timestamp
    ...  message=Checking if parameters are correct before exucution of test. Please wait...
    ...  style=ONGOING
    ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}  Preconditions For Power Group
    Logging With Timestamp
    ...  message=Step 1 Preconditions For PG WCDMA One Abia
    ...  style=DONE
    [Return]  ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}

Step 2 Perform Recommissioning For PG WCMDA One Abia
    [Arguments]    ${bts_id}
    [Documentation]
    ...  Description:
    ...  Perform recommissioning with additional parameters added as stated in ${delta_string} variable.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  Return:
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | Return Value          | Description                                                                                        |
    ...  +=======================+====================================================================================================+
    ...  | restore_conf          | True if delta was already recommisioned in order to bring back base conf after test ends           |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Logging With Timestamp
    ...  message=Step 2 Perform Recommissioning For PG WCDMA One Abia
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
    ...  message=Step 2 Perform Recommissioning For PG WCDMA One Abia
    ...  style=DONE
    [Return]  ${restore_conf}

Step 3 Perform Reset Site and Check NPSC and PSC cells For PG WCDMA One Abia
    [Arguments]  ${bts_id}  ${npsc_cells_list}  ${psc_cells_list}  ${graceful}=False
    [Documentation]
    ...  Description:
    ...  Perform reset site and check if NPSC and PSC cells are allocated correctly. WCDMA cell should be with FID 1868 after site reset.
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
    ...  message=Step 3 Perform Reset Site and Check NPSC and PSC cells
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

    Wait Until Keyword Succeeds  10x  60  Check BTS States Except WCDMA  node_id=${bts_id}
    Check NPSC and PSC cells For PG WCDMA
    ...  bts_id=${bts_id}
    ...  npsc_cells_list=${npsc_cells_list}
    ...  psc_cells_list=${psc_cells_list}
    ...  single_abia=${SINGLE_ABIA}

Step 4 L3 Call For PG WCDMA One Abia
    [Documentation]
    ...  Description:
    ...  Perform L3 Call on selected cells For PG Wcdma One Abia.
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

Check BTS States Except WCDMA
    [Arguments]  ${node_id}  ${expected_BTS_status}=OnAir  ${HW_check}=${TRUE}  ${cells_check}=${TRUE}  ${scf_check}=${TRUE}  ${timeout}=60
    [Documentation]  KW for checking Onair states for desired bts without WCDMA Cells. HW_check disable/enadle HW states check
    ...    SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|SFP|CABLINK. cells_check disable/enadle cells states GNCEL|WNCEL|LNCEL|NRCEL|CARRIERGROUPC.
    ...    scf_check disable/enable scf object counting for SMOD|BBMOD|RMOD|ASIRMOD|FHS|ALD|GNCEL|WNCEL|LNCEL|NRCEL and Prod Code Veryfication.
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument              | Man.  | Description                                                                                   |
    ...    +=======================+=======+===============================================================================================+
    ...    | node_id               | Yes   | current bts id                                                                                |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | expected_BTS_status   | No    | mrbts state to check, default OnAir                                                           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | HW_check              | No    | HW check switch, default ${TRUE}                                                              |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | cells_check           | No    | cells check switch, default ${TRUE}                                                           |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | scf_check             | No    | scf check switch, default ${TRUE}                                                             |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | timeout               | No    | timoeut to wait for onair after sw update                                                     |
    ...    +-----------------------+-------+-----------------------------------------------------------------------------------------------+

    ...  Author: daniel.bartkowiak@nokia.com
    ...  Maintainer: daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=:::::::::: Initial state management check on BTS-${node_id} :::::::::::
    ...  logs_dir=${CFG.suite_logs_path}
    Run Keyword If  not ${HW_check}  Logging With Timestamp
    ...  message=HW check is skipped on user demand
    ...  logs_dir=${CFG.suite_logs_path}
    ${SMODs_working}=  Run Keyword If  ${HW_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=SMOD  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
    ${BBMODs_working}=  Run Keyword If  ${HW_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=BBMOD  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
    ${RMODs_working}=   Run Keyword If  ${HW_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=RMOD  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
	${ASIR_modules_working}=   Run Keyword If  ${HW_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=ASIRMOD  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
	${FHS_modules_working}=   Run Keyword If  ${HW_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=FHS  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
	${ALDs_working}=  Run Keyword If  ${HW_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=ALD  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
    ${CABLINKs_working}    Set Variable    ${TRUE}
    ${SFPs_working}    Set Variable    ${TRUE}
    ${GSM_TRX_onair}    Set Variable    ${TRUE}
    Run Keyword If  not ${cells_check}  Logging With Timestamp
    ...  message=Cells check is skipped on user demand
    ...  logs_dir=${CFG.suite_logs_path}
    ${cells_GSM_onair}=  Run Keyword If  ${cells_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=GNCEL  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
    ${cells_LTE_onair}=  Run Keyword If  ${cells_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=LNCEL  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
    ${cells_NR_onair}=  Run Keyword If  ${cells_check}  Run Keyword And Return Status
	...  STATE Check Class States  class=NRCEL  node_id=${node_id}  scf_check=${scf_check}  timeout=${timeout}
    ...  ELSE  Set Variable  ${TRUE}
    ${BTS_status}=  Run Keyword If  ${HW_check}  Run Keyword And Return Status  STATE Verify BTS Procedural State  ${expected_BTS_status}  ${node_id}
	...  ELSE  Set Variable  ${TRUE}
    ${statuses_dictionary}=  Create Dictionary  BTS_status=${BTS_status}  SMODs_working=${SMODs_working}
	...  BBMODs_working=${BBMODs_working}  RMODs_working=${RMODs_working}  ASIR_modules_working=${ASIR_modules_working}
	...  FHS_modules_working=${FHS_modules_working}  ALDs_working=${ALDs_working}  CABLINKs_working=${CABLINKs_working}
	...  SFPs_working=${SFPs_working}  cells_GSM_onair=${cells_GSM_onair}  cells_GSM_TRX_onair=${GSM_TRX_onair}
    ...  cells_LTE_onair=${cells_LTE_onair}  cells_NR_onair=${cells_NR_onair}
    ${pretty_statuses}=  Evaluate  pprint.pformat(${statuses_dictionary}, indent=4)  modules=pprint

    [Teardown]
    ${all_cells_onair}  Evaluate
	...  ${cells_GSM_onair} and ${cells_LTE_onair} and ${cells_NR_onair} and ${GSM_TRX_onair}
    ${hw_modules_working}  Evaluate
	...  ${SMODs_working} and ${BBMODs_working} and ${RMODs_working} and ${ASIR_modules_working} and ${FHS_modules_working} and ${ALDs_working}
    Run Keyword If  not (${BTS_status} and ${hw_modules_working} and ${all_cells_onair} and ${CABLINKs_working} and ${SFPs_working})
    ...  Fail  Test failed due to failure of BTS initial check:${\n}${pretty_statuses}.${\n}Skip to teardown!
