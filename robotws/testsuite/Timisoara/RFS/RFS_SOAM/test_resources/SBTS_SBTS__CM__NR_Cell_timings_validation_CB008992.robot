*** Settings ***
Documentation    TC__SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
Variables    tc_variables/sbts_sbts__cm__nr_cell_timings_validation_CB008992_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of cycles to check feature CB008992, default value 3
${BTS}  BTS1  # Select BTS for feature CB008992 check: BTS1 or BTS2, default value: BTS1
${RMOD_SERIAL_NUMBER}  # Select RM serial number for feature CB008992 check
${NR_CELL_INDEX}  1  # Select index of NR cell mapped on selected RMOD for feature CB008992 check: 1 - first cell, 2 - second cell, 3 - third cell etc
                     # according to cell name displayed in WebEM 'Details' Tab; by default 1
${timingAdvanceOffset_value}  n39936  # NR cell parameter timingAdvanceOffset value; by default n39936
${BTS_SCF_VALIDATION}     True     # Validate SCF; can be True or False

*** Keywords ***
TC__SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25804
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB008992 - Timing misaligned case, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check test argument values validity
    ...  - perform timingAdvanceOffset parameter recommissioning
    ...  - check feature CB008992 behaviour: FID1900 -> Supplementary alarm information contains "Timing misaligned"
    ...  - recover initial parameter timingAdvanceOffset value
    ...  Pass criteria: feature CB008992 behaviour as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25804 - [5G][CB008992] New TC SBTS_TDD_RFS_CB008992_Cell_timings_validation_BTS
    ...  - 21.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27665 -
    ...  [5G] [SCF check] - P1 - SBTS - Include SCF validation with hardware check in CM Tests
    ...  - 01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29003 -
    ...  Detect SBTS-SBTS instead off LTE-LTE for SBTS_SBTS__STATE__SharedRM_Power_Off_On
    ...  - 12.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29677 -
    ...  Please increase FID1900 check time for SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30145  - [5G]Enhancement to
    ...  Automated_RFS_SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992 for additional FID4602
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25804_SBTS_SBTS__CM__NR_Cell_timings_validation_CB008992.png

    Set Tags    CA-STATE    OWNER-violeta.zanfirescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS23R4

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform timingAdvanceOffset parameter recommissioning to requested value
        Step 4: Check feature CB008992 behaviour
        Step 5: Perform timingAdvanceOffset parameter recommissioning to initial value
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    Log  Check test argument values validity:  console=True
    Get and check BTS info precondition
    Get and check RM info precondition
    Get and check NR CELL info precondition
    Get and check timingAdvanceOffset parameter info precondition

    Log  All argument values are valid. Feature CB008992 check will be performed based on following requests:  console=True
    Log  - BTS: ${BTS} (${alias})  console=True
    Log  - RM sn: ${RMOD_SERIAL_NUMBER} (${RM_productName})  console=True
    Log  - NR_CELL index: ${NR_CELL_INDEX} (NR_CELL id: ${NR_CELL_id})  console=True
    Log  - timingAdvanceOffset value: ${timingAdvanceOffset_value}  console=True

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  wait_for_alarm_clear=15 min  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['SBTS_${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['SBTS_${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Perform timingAdvanceOffset parameter recommissioning to requested value
    [Documentation]
    ...  Perform timingAdvanceOffset parameter recommissioning.

    Log  Step ${index}: Perform timingAdvanceOffset parameter recommissioning to requested value  console=True

    Perform timingAdvanceOffset parameter recommissioning  ${NR_CELL_dn}  ${timingAdvanceOffset_value}  ${alias}

Step ${index}: Check feature CB008992 behaviour
    [Documentation]
    ...  Check feature CB008992 behaviour:
    ...  - FID1900 with field "Supplementary alarm information" info: "Timing misaligned"

    Log  Step ${index}: Check feature CB008992 behaviour  console=True

    Log  Check ${BTS} "RF Module configuring failed (1900)" alarm:  console=True
    Log  - expected number: 1  console=True
    Log  - expected specific field "Supplementary alarm information" info: "Timing misaligned"  console=True
    Assert Alarm Active  parameters=faultId=1900, supplAlarmInfo="Timing misaligned"  timeout=600  alias=${alias}
    Log  Check ${BTS} "RF Module configuring failed (1900)" alarm passed:  console=True
    Log  - found number: 1  console=True
    Log  - found specific field "Supplementary alarm information" info: "Timing misaligned"  console=True

    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${test_alarms_list['SBTS_${alias.upper()}_IGNORED_ALARMS']}
    ...  ${test_alarms_list['SBTS_${alias.upper()}_IGNORED_ALARMS_CUSTOM']}

    Get and Check Alarms SOAM  alias=${alias}
    ...  expected_alarms=${test_alarms_list['SBTS_${alias.upper()}_EXPECTED_ALARMS_1900']}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_full}
    ...  critical_alarms=${test_alarms_list['SBTS_${alias.upper()}_CRITICAL_ALARMS']}

Step ${index}: Perform timingAdvanceOffset parameter recommissioning to initial value
    [Documentation]
    ...  Perform timingAdvanceOffset parameter recommissioning.

    Log  Step ${index}: Perform timingAdvanceOffset parameter recommissioning to initial value  console=True

    Perform timingAdvanceOffset parameter recommissioning  ${NR_CELL_dn}  ${timingAdvanceOffset_initial}  ${alias}

    Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get and check BTS info precondition
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_label_list}=  Get Dictionary Keys  ${BTS_label_alias_dict}
    Run Keyword If  '${BTS}' not in ${BTS_label_list}  Run Keywords
    ...  Log Long String  Selected value ${BTS} for test argument \${BTS} is not valid. Please select values for test argument \${BTS} from valid
    ...  values: ${BTS_label_list} or let default value: BTS1  level=ERROR
    ...  AND  Fail  Improper value for argument!

    ${alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS}

    Set Test Variable  ${alias}

Get and check RM info precondition
    ${RM_param}=  Get Parameters For All  class_name=RMOD  connection=${alias}
    FOR  ${item}  IN  @{RM_param}
        ${RM_id}=  Set Variable  ${item['id']}
        ${RM_productName}=  Set Variable  ${item['productName']}
        ${RM_found}=  Set Variable If  '${item['serialNumber']}' == '${RMOD_SERIAL_NUMBER}'  ${TRUE}  ${FALSE}
        Exit For Loop If  ${RM_found}
    END

    Run Keyword If  not ${RM_found}  Run Keywords
    ...  Log Long String  Selected value ${RMOD_SERIAL_NUMBER} for test argument \${RMOD_SERIAL_NUMBER} is not valid. Please select a valid value for
    ...  test argument \${RMOD_SERIAL_NUMBER}  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${RM_id}
    Set Test Variable  ${RM_productName}

Get and check NR CELL info precondition
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}
    ${NR_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{CELL_RM_list}
        Run Keyword If  '${item}' in ${NR_CELL_list}
        ...  Append To List  ${NR_CELL_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_RM_list}
    ${NR_CELL_RM_count}=  Get Length  ${NR_CELL_RM_list}

    Run Keyword If  ${NR_CELL_INDEX} > ${NR_CELL_RM_count}  Run Keywords
    ...  Log Long String  Selected value ${NR_CELL_INDEX} for test argument \${NR_CELL_INDEX} is not valid. Please select a valid value for test
    ...  argument \${NR_CELL_INDEX} <=${CELL_RM_count}  level=ERROR
    ...  AND  Fail  Improper value for argument!

    ${NR_CELL_INDEX}=  Evaluate  ${NR_CELL_INDEX} - 1

    Set Test Variable  ${NR_CELL_id}  ${NR_CELL_RM_list}[${NR_CELL_INDEX}]

    ${NR_CELL_dn}=  Get CELL SCF runtime distinguished name  ${NR_CELL_id}  ${alias}

    Set Test Variable  ${NR_CELL_dn}

Get and check timingAdvanceOffset parameter info precondition
    ${timingAdvanceOffset_initial}=  Get timingAdvanceOffset parameter value  ${NR_CELL_dn}  ${alias}

    Run Keyword If  '${timingAdvanceOffset_initial}' == '${timingAdvanceOffset_value}'  Run Keywords
    ...  Log Long String  Selected value ${timingAdvanceOffset_value} for test argument \${timingAdvanceOffset_value} is not valid or already set in
    ...  current BTS configuration. Please select a valid value for test argument \${timingAdvanceOffset_value}  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${timingAdvanceOffset_initial}

Get timingAdvanceOffset parameter value
    [Documentation]
    ...  Get info related to timingAdvanceOffset parameter value from scf.

    [Arguments]  ${NR_CELL_dn}  ${alias}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${timingAdvanceOffset}=  Check Parameter value from SCF  item_dist_name=${NR_CELL_dn}  parameter_to_check=timingAdvanceOffset  scf_path=${BTS_scf}

    [Return]  ${timingAdvanceOffset}

Perform timingAdvanceOffset parameter recommissioning
    [Documentation]
    ...  Perform timingAdvanceOffset parameter recommissioning

    [Arguments]  ${NR_CELL_dn}  ${timingAdvanceOffset}  ${alias}

    ${timingAdvanceOffset_current}=  Get timingAdvanceOffset parameter value  ${NR_CELL_dn}  ${alias}
    Run Keyword If  '${timingAdvanceOffset_current}' == '${timingAdvanceOffset}'  Run Keywords
    ...  Log  Current timingAdvanceOffset parameter value: ${timingAdvanceOffset_current} already set, no action needed!  console=True
    ...  AND  Return From Keyword

    Log  Perform timingAdvanceOffset parameter recommissioning: ${timingAdvanceOffset_current} -> ${timingAdvanceOffset}  console=True

    coam.Perform Parameter Recommissioning  dist_name=${NR_CELL_dn}  parameter=timingAdvanceOffset  operation=update  value=${timingAdvanceOffset}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=600  connection=${alias}
    Sleep  10s

    ${timingAdvanceOffset_new}=  Get timingAdvanceOffset parameter value  ${NR_CELL_dn}  ${alias}

    Log  New timingAdvanceOffset parameter value: ${timingAdvanceOffset_new}  console=True
    Run Keyword If  '${timingAdvanceOffset_new}' == '${timingAdvanceOffset}'
    ...  Log  Recommissioning operation successfuly performed  console=True
    ...  ELSE  Run Keywords
    ...  Log  Recommissioning operation failed  level=ERROR
    ...  AND  Fail  Recommissioning operation failed

Recover initial timingAdvanceOffset parameter value
    [Documentation]
    ...  Recover initial timingAdvanceOffset parameter value

    Log  Recover initial timingAdvanceOffset parameter value  console=True
    ${timingAdvanceOffset_final}=  Get timingAdvanceOffset parameter value  ${NR_CELL_dn}  ${alias}
    Run Keyword If  '${timingAdvanceOffset_final}' == '${timingAdvanceOffset_initial}'
    ...  Log  Final timingAdvanceOffset parameter value: ${timingAdvanceOffset_final}, no recover action needed  console=True
    ...  ELSE  Run Keywords
    ...  coam.Perform Parameter Recommissioning  dist_name=${NR_CELL_dn}  parameter=timingAdvanceOffset  operation=update
    ...  value=${timingAdvanceOffset_initial}  skip_parameter_relation_errors=True  should_activate=True  timeout=600  connection=${alias}
    ...  AND  Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias}

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial timingAdvanceOffset parameter value

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${FALSE}  infomodelSetup=${FALSE}
    ...  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
