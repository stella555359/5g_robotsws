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
  ...  *****************
  ...  Purpose of the test is to verify support the parameter value '13:PSGRP priority' for the allocCriterion parameter, when
  ...  one AirScale subrack equipped with one ASIA common plug-in unit and at least one ABIA or ASIB (or newer) common
  ...  plug-in unit and at least one ABIA and one ABIO capacity unit and several LTE radio units. For this test there should
  ...  be max 6 power saving cells configured.
  ...  Grouping of cells:
  ...  'NPSC' LTE cells (non-power saving cells):
  ...  1. LTE cells within a power saving group with flag lbpsLastCellSOEnabled set to false and with cell order
  ...  lbpsCellSOOrder set to 100.
  ...  2. LTE cells not belonging to a power saving group.
  ...  3. Cells with actOtdoa set to true and cells used for public safety purposes.
  ...  'PSC' LTE cells (power saving cells):
  ...  1. LTE cells within a power saving group which are not 'NPSC' cells.
  ...  ******************
  ...  Step 1 Preconditions. Check if the following parameters are set correctly:
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
  ...  Step 2 Perform delta recommisioning with following parameter change:
  ...  Under MRBTS-X/LNBTSX/ bbPoolAllocPrioList set :
  ...  allocCriterion to PSGRP priority
  ...  allocPriority set between 1 and 10
  ...  After changing parameters BTS is on air (BEFORE RESET!)
  ...
  ...  Step 3 Check NPSC and PSC cells allocation
  ...  All cells which are allocated on ABIA and which are NPSC cells shall be within baseband pool #1 of
  ...  ABIA (which is the primary power group on ABIA). This can be checked in Configuration Managment
  ...  Parameter Editor. Cells are listed under:
  ...  MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOLx1
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList: MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R-1/BBMOD_R-x/POWERGROUP_R-1
  ...  All cells which are allocated on ABIA and which are PSC cells shall be allocated on baseband pool #2 of ABIA.
  ...  Cells are listed under: MRBTS-x/MNL-1/MNLENT-1/BBADM-1/BBPOOLx2
  ...  Under this BBPOOL object there should be parameter bbPwrGroupDNList: MRBTS-x/EQM_R-x/APEQM_R-1/CABINET_R1/BBMOD_R-x/POWERGROUP_R-2
  ...  For baseband boards other than ABIA the cell allocation shall not be changed
  ...
  ...  Step 4 Perform L3 Call on selected cells.
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 31.01.2025 - Initial creation

Resource  ./../../Resources/Setup/setup_and_teardown.robot
Resource  ./../../Resources/SiSo_L3_call.robot
Resource  ./CM_PSGRP.resource

*** Variables ***
${SELECTED_CELLS}     None       # runtime distnames of cells which are going to be tested,
                                 # example: /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1424/LNCEL_R-11
                                 # when using L3 call outside of RFRL TC, create variable "SELECTED_CELLS" as a List, default value is 'None'
							     # default value 'None' means that each cell commissioned on declared in init.py BTSes will be tested
${SISO_L3_CALL}  False  #default value for L3 call is False, set test variable as True to perform test with L3 call
${CELLS_YAML_PATH}  #mandatory path for ue_config.yaml if ${SISO_L3_CALL} is True
*** Keywords ***
TC__SiSo_CM_LTE_PSGRP_priority
    Set Tags     AUTHOR-szymon.przybylak@nokia.com  MAINTAINER-szymon.przybylak@nokia.com
    Common Test Setup
    Logging With Timestamp
    ...  message=SiSo_CM_LTE_PSGRP_priority.robot will be executed
    ...  style=ONGOING
    ${restore_conf}  Set Variable  ${False}
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    ${random_allocPriority}   Evaluate  random.randint(1, 10)
    ${restore_part1}  Set Variable  [{"distName":"MRBTS-${bts_id}/LNBTS-${bts_id}","operation":"update","parameters":
    ${restore_part2}  Set Variable    [{"parameterName":"bbPoolAllocPrioList","value":"","operation":"delete"}]}]
    ${restore_delta}  Set Variable    ${restore_part1}${restore_part2}
    ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}  Step 1 Preconditions For PSGRP Priority
    ${delta_part1}  Set Variable
    ...  [{"distName":"MRBTS-${bts_id}/LNBTS-${bts_id}","operation":"update","parameters":[{"parameterName":"bbPoolAllocPrioList",
    ${delta_part2}  Set Variable  "value":[{"allocCriterion":"PSGRP priority","allocPriority":"${random_allocPriority}"}],"operation":"update"}]}]
    ${delta_bbPoolAllocPrioList}  Set Variable  ${delta_part1}${delta_part2}
    ${restore_conf}  Step 2 Perform Recommissioning For PSGRP Priority  bts_id=${bts_id}  delta_string=${delta_bbPoolAllocPrioList}
    Step 3 Perform Reset Site and Check NPSC and PSC cells For PSGRP Priority
    ...  bts_id=${bts_id}
    ...  npsc_cells_list=${npsc_cells_list}
    ...  psc_cells_list=${psc_cells_list}
    Step 4 L3 Call For PSGRP Priority
    [Teardown]  Run Keywords  Restore config  ${bts_id}  ${restore_conf}  ${restore_delta}
    ...  AND  Common Test Teardown

Step 1 Preconditions For PSGRP Priority
    [Documentation]
    ...  Description:
    ...  Perform precondition for PSGRP priority test with creating lists/dicts with cells necessary for TC.
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
    ...  | npsc_cells_list       | List of cells which are NPSC cells e.g. ${npsc_cells_list} = [29901]                               |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | psc_cells_list        | List of cells which are PSC cells e.g. ${psc_cells_list} = [29904, 29910]                          |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...  | restore_delta         | string in json format with delta recommissioning info                                              |
    ...  +-----------------------+----------------------------------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}  Preconditions For Power Group
    [Return]  ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}

Step 2 Perform Recommissioning For PSGRP Priority
    [Arguments]    ${bts_id}  ${delta_string}
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
    ...  | delta_string           | Yes  | string with full delta.json to insert into scf                             |
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
    ...  message=Step 2 Perform Recommissioning For PSGRP Priority
    ...  style=STEP
    ...  frame=${TRUE}
    ${restore_conf}  Perform Recommissioning With Delta String  ${bts_id}  ${delta_string}
    Wait Until Keyword Succeeds  10x  60  STATE Verify BTS states  node_id=${bts_id}
    Logging With Timestamp
    ...  message=Step 2 Perform Recommissioning For PSGRP Priority
    ...  style=DONE
    [Return]  ${restore_conf}

Step 3 Perform Reset Site and Check NPSC and PSC cells For PSGRP Priority
    [Arguments]  ${bts_id}  ${npsc_cells_list}  ${psc_cells_list}  ${graceful}=${False}
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

    Logging With Timestamp
    ...  message=Step 3 Perform Reset Site and Check NPSC and PSC cells For PSGRP Priority
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
    Check NPSC and PSC cells For PSGRP Priority  bts_id=${bts_id}  npsc_cells_list=${npsc_cells_list}  psc_cells_list=${psc_cells_list}
    Logging With Timestamp
    ...  message=Step 3 Perform Reset Site and Check NPSC and PSC cells For PSGRP Priority
    ...  style=DONE

Check NPSC and PSC cells For PSGRP Priority
    [Arguments]  ${bts_id}  ${npsc_cells_list}  ${psc_cells_list}
    [Documentation]
    ...  Description:
    ...  Keyword that checks if all cells are properly allocated to bbpoolx1 and bbpoolx2 and
    ...  if bbPwrGroupDNList has proper value.  If not, it will fail the test. KW checks only LTE as needed for PSGRP Priority.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | npsc_cells_list        | Yes  | List of cells that are non power saving                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | psc_cells_list         | Yes  | List of cells that are power saving                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    ${npsc_cells_list_check}  Create List
    ${psc_cells_list_check}  Create List
    ${npsc_cells_list_check}  Set Variable  ${npsc_cells_list}
    ${psc_cells_list_check}  Set Variable  ${psc_cells_list}
    FOR  ${value}  IN  @{BBMOD_DN}
      ${last_character} =  Get Substring  ${value}  -1
      ${bbmod_value}  Get Substring  ${value}  -10
      ${bbpool_x1}  ${bbpool_x2}  Get Parameters From x1 and x2 Bbmod Bbpool  bts_id=${bts_id}  bbpool=${last_character}
      ${bbpoolcellslistx1}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolCellsList']}
      ${bbpoolcellslistx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
      ${techx1}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolTech']}
      ${techx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolTech']}
      ${bbPwrGroupDNList_bbpool_x1_value}  Get From Dictionary  ${bbpool_x1[0]['parameters']}  bbPwrGroupDNList
      ${bbPwrGroupDNList_bbpool_x2_value}  Get From Dictionary  ${bbpool_x2[0]['parameters']}  bbPwrGroupDNList
      IF  "['${value}/POWERGROUP_R-1']" != "${bbPwrGroupDNList_bbpool_x1_value}"  Fail
      ...  msg=['${value}/POWERGROUP_R-1'] is different than ${bbPwrGroupDNList_bbpool_x1_value}
      IF  "['${value}/POWERGROUP_R-2']" != "${bbPwrGroupDNList_bbpool_x2_value}"  Fail
      ...  msg=['${value}/POWERGROUP_R-2'] is different than ${bbPwrGroupDNList_bbpool_x2_value}
      FOR  ${bbmod_int_dn}  IN  @{BBMOD_INTERNAL_DN}
        Log  ${bbmod_value} ${bbmod_int_dn}
        IF  '${bbmod_value}' in '${bbmod_int_dn}'
          ${bbmod_cells}  Get Cell Mapping By Module Id
          ...  module_id=${bbmod_int_dn}
          ...  timeout=60
          ...  connection=${bts_id}
        ELSE
          Continue For Loop
        END
      END
      Log  ${bbpool_x1[0]['parameters']['bbPoolTech']}
      FOR  ${cell}  IN  @{npsc_cells_list}
        FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
          Log  ${cell} ${key} ${value}
          ${index}  Get Index From List  ${npsc_cells_list_check}  ${cell}
          IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx1}' and '${techx1}' == 'LTE'
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
            END
          ELSE
            Continue For Loop
          END
        END
      END
      Log  ${npsc_cells_list_check}

      FOR  ${cell}  IN  @{psc_cells_list}
        FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
          Log  ${cell} ${key} ${value}
          ${bbpoolcellslistx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
          ${tech}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolTech']}
          IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${tech}' == 'LTE'
            Log  ${bbmod_cells} ${cell}
            ${cell_from_correct_bbpool}  Evaluate  any(str(${cell}) in element for element in ${bbmod_cells})
            IF  ${cell_from_correct_bbpool}
              ${index}  Get Index From List  ${psc_cells_list_check}  ${cell}
              Remove From List  ${psc_cells_list_check}  ${index}
              Exit For Loop
            ELSE
              Continue For Loop
            END
          ELSE
            Continue For Loop
          END
        END
      END
        Log  ${psc_cells_list_check}
    END
    ${npsc_cells_list_length}  Get Length  ${npsc_cells_list_check}
    ${psc_cells_list_length}  Get Length  ${psc_cells_list_check}
    IF  ${npsc_cells_list_length} > 0  Fail
    ...  msg=Not all NPSC cells are properly allocated in bbppoolx1. Check configuration to find out where cells from ${npsc_cells_list_check} are.
    IF  ${psc_cells_list_length} > 0  Fail
    ...  msg=Not all PSC cells are properly allocated in bbppoolx2. Check configuration to find out where cells from ${psc_cells_list_check} are.

Step 4 L3 Call For PSGRP Priority
    [Documentation]
    ...  Description:
    ...  Perform L3 Call on selected cells For PSGRP Priority test.
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Step 4 Perform L3 Call For PSGRP Priority
    ...  style=STEP
    ...  frame=${TRUE}
    IF  ${SISO_L3_CALL}
#      SiSo_L3_call.SiSo L3 Call  cells_input=${SELECTED_CELLS}
      Logging With Timestamp
      ...  message=Step 4 Perform L3 Call For PSGRP Priority
      ...  style=DONE
    ELSE
      Logging With Timestamp
      ...  message=Step 4 skipped.
      ...  style=DONE
    END
