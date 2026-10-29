*** Settings ***
Documentation    TC__SBTS_SBTS__CM__NR_Cell_power_validation_CB008992
Variables    tc_variables/sbts_sbts__cm__nr_cell_power_validation_CB008992_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}             3     # Number of operations cycles to check feature CB008992, default value 3
${NR_globalCellId_info_list}        # List of NR global cell ids separated by comma.
${NR_pMax_dBm_info_list}            # List of pMax values (dBm) separated by comma. For each selected NR global cell id, user should specify a pMax
                                    # value (dBm) to check feature CB008992
${BTS_SCF_VALIDATION}         True  # Validate BTS SCF; can be True or False

*** Keywords ***
TC__SBTS_SBTS__CM__NR_Cell_power_validation_CB008992
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29570
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for feature CB008992 - cell power exceeded case, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check test argument values validity
    ...  - check initial state and alarms for all BTS
    ...  - perform pMax parameter recommissioning on associated NR cell
    ...  - check feature CB008992 behaviour: FID1900 -> Supplementary alarm information contains "Power exceeded"
    ...  - recover initial parameter pMax value
    ...  Pass criteria: feature CB008992 behaviour as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-25843 - Generate SBTS-SBTS test for NRL__CM__NR_Cell_power_validation_CB008992
    ...

    Set Tags    CA-STATE    OWNER-alexandru-eugen.miron@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Check feature CB008992 behaviour based on NR cell pMax recommissioning
        Step 4: Check final all BTS state
        Step 5: Check final all BTS alarms
        Step 6: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    Get all BTS NR cells info
    Check NR global cell id info list
    Check NR pMax info list

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check feature CB008992 behaviour based on NR cell pMax recommissioning
    Log  Step ${index}: Check feature CB008992 behaviour based on NR cell pMax recommissioning  console=True

    FOR  ${index}  ${NR_globalCellId}  IN ENUMERATE  @{NR_globalCellId_list}

        ${NR_globalCellId}=  Convert To Integer  ${NR_globalCellId}
        ${alias}=  Get From Dictionary  ${all_NR_globalCellId_bts_alias_dict}  ${NR_globalCellId}
        ${NR_cell_dn}=  Get From Dictionary  ${${alias}_NR_globalCellId_cell_dn_dict}  ${NR_globalCellId}
        ${NR_cell_id}=  Get From Dictionary  ${${alias}_NR_globalCellId_cell_id_dict}  ${NR_globalCellId}
        ${NR_pMax_dBm}=  Get From List  ${NR_pMax_dBm_list}  ${index}
        ${NR_pMax}=  Evaluate  ${NR_pMax_dBm} * 10
        ${NR_pMax_initial}=  Get From Dictionary  ${${alias}_NR_globalCellId_pMax_dict_initial}  ${NR_globalCellId}
        ${NR_pMax_dBm_initial}=  Evaluate  ${NR_pMax_initial} / 10

        Log  ***** Perform BTS ${alias} operations to check feature CB008992 behaviour on NR cell with globalCellId ${NR_globalCellId} *****
        ...  console=True

        Perform NR cell pMax parameter recommissioning  ${NR_globalCellId}  ${NR_pMax_dBm}  ${NR_pMax}  ${alias}

        Check feature CB008992 behaviour  ${alias}

        Perform NR cell pMax parameter recommissioning  ${NR_globalCellId}  ${NR_pMax_dBm_initial}  ${NR_pMax_initial}  ${alias}

        Run Keyword If  ${BTS_SCF_VALIDATION}  Check BTS SCF Validation On Demand  alias=${alias}

        Log  Check BTS ${alias} NR cell with globalCellId ${NR_globalCellId} status:  console=True
        Assert  class_name=NRCEL  id=${NR_cell_id}  parameters=operationalState=${Enabled_}, blockingState=${Unblocked_}  timeout=300
        ...  connection=${alias}
        Log  - operationalState=Enabled, blockingState=Unblocked  console=True

        Log  Check BTS ${alias} alarms:  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get all BTS NR cells info
    [Documentation]
    ...  Get all BTS NR cells info:
    ...  - cells globalCellId, runtime id and configuration id info
    ...  - cells pMax info

    ${all_NR_globalCellId_bts_alias_dict}=  Create Dictionary
    Set Test Variable  ${all_NR_globalCellId_bts_alias_dict}

    FOR  ${alias}  IN  @{alias_list}

        ${NR_globalCellId_bts_alias_dict}  ${NR_globalCellId_cell_dn_dict}  ${NR_globalCellId_cell_id_dict}=  Get BTS NR cells id info  ${alias}
        Set Test Variable  ${${alias}_NR_globalCellId_cell_dn_dict}  ${NR_globalCellId_cell_dn_dict}
        Set Test Variable  ${${alias}_NR_globalCellId_cell_id_dict}  ${NR_globalCellId_cell_id_dict}

        ${NR_globalCellId_pMax_dict}=  Get BTS NR cells pMax info  ${alias}
        Set Test Variable  ${${alias}_NR_globalCellId_pMax_dict_initial}  ${NR_globalCellId_pMax_dict}

        ${all_NR_globalCellId_bts_alias_dict}=  Add dictionary items to target dictionary  ${NR_globalCellId_bts_alias_dict}
        ...  ${all_NR_globalCellId_bts_alias_dict}

    END

Get BTS NR cells id info
    [Arguments]  ${alias}

    ${NR_globalCellId_bts_alias_dict}=  Create Dictionary
    ${NR_globalCellId_cell_dn_dict}=  Create Dictionary
    ${NR_globalCellId_cell_id_dict}=  Create Dictionary

    ${NR_cells_info}=  Get Cells Info  cell_type=nr  timeout=10  connection=${alias}

    FOR  ${item}  IN  @{NR_cells_info}

        ${NR_globalCellId_info}=  Get From Dictionary  ${item}  globalCellId
        ${NR_id_info}=  Get From Dictionary  ${item}  id
        ${NR_cell_dn}=  Get From Dictionary  ${NR_id_info}  configuration
        ${NR_cell_id}=  Get From Dictionary  ${NR_id_info}  internal

        Set To Dictionary  ${NR_globalCellId_bts_alias_dict}  ${NR_globalCellId_info}  ${alias}
        Set To Dictionary  ${NR_globalCellId_cell_dn_dict}  ${NR_globalCellId_info}  ${NR_cell_dn}
        Set To Dictionary  ${NR_globalCellId_cell_id_dict}  ${NR_globalCellId_info}  ${NR_cell_id}

    END

    [Return]  ${NR_globalCellId_bts_alias_dict}  ${NR_globalCellId_cell_dn_dict}  ${NR_globalCellId_cell_id_dict}

Get BTS NR cells pMax info
    [Arguments]  ${alias}

    ${NR_globalCellId_pMax_dict}=  Create Dictionary

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects

    FOR  ${NR_globalCellId}  ${NR_cell_dn}  IN  &{${alias}_NR_globalCellId_cell_dn_dict}

        ${pMax_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NR_cell_dn}  p_name=pMax
        ${pMax_count}=  Get Length  ${pMax_info_dict}
        ${pMax_info}=  Run Keyword If  ${pMax_count} > 0
        ...  Get From Dictionary  ${pMax_info_dict}  pMax
        ...  ELSE
        ...  Set Variable  NA

        Set To Dictionary  ${NR_globalCellId_pMax_dict}  ${NR_globalCellId}  ${pMax_info}

    END

    [Return]  ${NR_globalCellId_pMax_dict}

Check NR global cell id info list
    Run Keyword If  '${NR_globalCellId_info_list}' == ''  Run Keywords
    ...  Log Long String  No selected NR global cell id to check feature CB008992. Please select values for test argument
    ...  \${NR_globalCellId_info_list} from configured NR global cell id on any BTS  console=True
    ...  AND  Fail  Improper value for argument!

    ${NR_globalCellId_list_stripped}=  Replace String  ${NR_globalCellId_info_list}  ${SPACE}  ${EMPTY}
    ${NR_globalCellId_list}=  Split String  ${NR_globalCellId_list_stripped}  ,

    ${all_BTS_NR_globalCellId_list}=  Get Dictionary Keys  ${all_NR_globalCellId_bts_alias_dict}

    ${NR_globalCellId_check}=  Set Variable  True
    ${NR_globalCellId_invalid_list}=  Create List
    ${NR_globalCellId_request_list}=  Create List

    FOR  ${NR_globalCellId}  IN  @{NR_globalCellId_list}
        ${NR_globalCellId}=  Convert To Integer  ${NR_globalCellId}
        ${NR_globalCellId_check}=  Set Variable If  ${NR_globalCellId} not in ${all_BTS_NR_globalCellId_list}  False  ${NR_globalCellId_check}

        Run Keyword If  ${NR_globalCellId} in ${all_BTS_NR_globalCellId_list}
        ...  Append To List  ${NR_globalCellId_request_list}  ${NR_globalCellId}
        ...  ELSE
        ...  Append To List  ${NR_globalCellId_invalid_list}  ${NR_globalCellId}
    END

    Run Keyword If  '${NR_globalCellId_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected values for test argument \${NR_globalCellId_info_list} are not valid: ${NR_globalCellId_invalid_list}.
    ...  Please select values from configured BTS cells: ${all_BTS_NR_globalCellId_list}  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${NR_globalCellId_list}

Check NR pMax info list
    Run Keyword If  '${NR_pMax_dBm_info_list}' == ''  Run Keywords
    ...  Log Long String  No selected NR cell pMax values to check feature CB008992. Please select values for test argument \${NR_pMax_dBm_info_list}
    ...  according to selected NR global cell id list  console=True
    ...  AND  Fail  Improper value for argument!

    ${NR_pMax_dBm_list_stripped}=  Replace String  ${NR_pMax_dBm_info_list}  ${SPACE}  ${EMPTY}
    ${NR_pMax_dBm_list}=  Split String  ${NR_pMax_dBm_list_stripped}  ,

    ${NR_pMax_count}=  Get Length  ${NR_pMax_dBm_list}
    ${NR_globalCellId_count}=  Get Length  ${NR_globalCellId_list}

    Run Keyword If  ${NR_pMax_count} != ${NR_globalCellId_count}  Run Keywords
    ...  Log Long String  Number of selected NR cell pMax values should be equal with number of selected NR global cell id to check feature CB008992.
    ...  Please select values for test argument \${NR_pMax_dBm_info_list} according to selected NR global cell id list  console=True
    ...  AND  Fail  Improper value for argument!

    ${all_BTS_NR_globalCellId_pMax_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${all_BTS_NR_globalCellId_pMax_dict}=  Add dictionary items to target dictionary  ${${alias}_NR_globalCellId_pMax_dict_initial}
        ...  ${all_BTS_NR_globalCellId_pMax_dict}

    END

    ${NR_pMax_check}=  Set Variable  True
    ${NR_globalCellId_pMax_dBm_invalid_dict}=  Create Dictionary
    ${NR_globalCellId_pMax_dBm_request_dict}=  Create Dictionary

    FOR  ${NR_globalCellId}  ${NR_pMax_dBm}  IN ZIP  ${NR_globalCellId_list}  ${NR_pMax_dBm_list}

        ${NR_globalCellId}=  Convert To Integer  ${NR_globalCellId}
        ${NR_pMax}=  Evaluate  ${NR_pMax_dBm} * 10
        ${BTS_NR_pMax}=  Get From Dictionary  ${all_BTS_NR_globalCellId_pMax_dict}  ${NR_globalCellId}
        ${NR_pMax_check}=  Set Variable If  ${NR_pMax} == ${BTS_NR_pMax}  False  ${NR_pMax_check}

        Run Keyword If  ${NR_pMax} == ${BTS_NR_pMax}
        ...  Set To Dictionary  ${NR_globalCellId_pMax_invalid_dict}  ${NR_globalCellId}  ${NR_pMax_dBm}
        ...  ELSE
        ...  Set To Dictionary  ${NR_globalCellId_pMax_dBm_request_dict}  ${NR_globalCellId}  ${NR_pMax_dBm}

    END

    Run Keyword If  '${NR_pMax_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected values for test argument \${NR_pMax_dBm_info_list} are not valid:
    ...  ${NR_globalCellId_pMax_dBm_invalid_dict}. Please update them accordingly.  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${NR_pMax_dBm_list}

Add dictionary items to target dictionary
    [Arguments]  ${dict}  ${target_dict}

    FOR  ${key}  ${value}  IN  &{dict}
        Set To Dictionary  ${target_dict}  ${key}  ${value}
    END

    [Return]  ${target_dict}

Perform NR cell pMax parameter recommissioning
    [Arguments]  ${NR_globalCellId}  ${NR_pMax_dBm}  ${NR_pMax}  ${alias}

    ${NR_cell_dn}=  Get From Dictionary  ${${alias}_NR_globalCellId_cell_dn_dict}  ${NR_globalCellId}

    Log  Perform BTS ${alias} NR cell with globalCellId ${NR_globalCellId} recommissioning with pMax ${NR_pMax_dBm} dBm  console=True

    ${NR_pMax_current}=  Get BTS NR cell pMax info  ${NR_cell_dn}  ${alias}

    Run Keyword If  ${NR_pMax_current} == ${NR_pMax}  Run Keywords
    ...  Log  - pMax ${NR_pMax_dBm} dBm already set, no action needed!  console=True
    ...  AND  Return From Keyword

    coam.Perform Parameter Recommissioning  dist_name=${NR_cell_dn}  parameter=pMax  operation=update  value=${NR_pMax}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=600  connection=${alias}
    Sleep  10s  Wait for refresh pMax

    ${NR_pMax_current}=  Get BTS NR cell pMax info  ${NR_cell_dn}  ${alias}

    Run Keyword If  ${NR_pMax_current} == ${NR_pMax}
    ...  Log  - pMax ${NR_pMax_dBm} dBm successfully set!  console=True
    ...  ELSE  Run Keywords
    ...  Log  Recommissioning operation failed  level=ERROR
    ...  AND  Fail  Recommissioning operation failed

Get BTS NR cell pMax info
    [Arguments]  ${NR_cell_dn}  ${alias}

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects

    ${pMax_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${NR_cell_dn}  p_name=pMax
    ${pMax_count}=  Get Length  ${pMax_info_dict}
    ${pMax_info}=  Run Keyword If  ${pMax_count} > 0
    ...  Get From Dictionary  ${pMax_info_dict}  pMax
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${pMax_info}

Check feature CB008992 behaviour
    [Arguments]  ${alias}

    Log  Check BTS ${alias} feature CB008992 behaviour:  console=True

    ${alarm_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=1900, supplAlarmInfo=regex"Power exceeded.*"
    ...  timeout=300  connection=${alias}

    Run Keyword If  ${alarm_status}
    ...  Log Long String  - passed -> found "RF Module configuring failed (1900)" alarm with specific field "Supplementary alarm information" info:
    ...  "Power exceeded", as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  - failed -> not found "RF Module configuring failed (1900)" alarm with specific field "Supplementary alarm information"
    ...  info: "Power exceeded"  level=ERROR
    ...  AND  Fail  BTS ${alias} check feature CB008992 behavior failed!

    ${BTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_1900}  ignored_alarms=${BTS_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

Recover initial NR cells pMax settings
    [Documentation]
    ...  Recover initial NR cells pMax settings

    Log  Recover initial NR cells pMax settings:  console=True

    FOR  ${NR_globalCellId}  ${NR_pMax_dBm}  IN ZIP  ${NR_globalCellId_list}  ${NR_pMax_dBm_list}

        ${NR_globalCellId}=  Convert To Integer  ${NR_globalCellId}
        ${alias}=  Get From Dictionary  ${all_NR_globalCellId_bts_alias_dict}  ${NR_globalCellId}
        ${NR_cell_dn}=  Get From Dictionary  ${${alias}_NR_globalCellId_cell_dn_dict}  ${NR_globalCellId}

        ${NR_pMax_initial}=  Get From Dictionary  ${${alias}_NR_globalCellId_pMax_dict_initial}  ${NR_globalCellId}
        ${NR_pMax_dBm_initial}=  Evaluate  ${NR_pMax_initial} / 10
        Perform NR cell pMax parameter recommissioning  ${NR_globalCellId}  ${NR_pMax_dBm_initial}  ${NR_pMax_initial}  ${alias}

    END

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial NR cells pMax settings

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown