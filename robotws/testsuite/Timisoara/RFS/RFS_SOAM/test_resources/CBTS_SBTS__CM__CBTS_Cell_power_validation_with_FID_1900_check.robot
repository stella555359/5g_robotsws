*** Settings ***
Documentation    TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
Variables    tc_variables/cbts_sbts__cm__cbts_cell_power_validation_with_fid_1900_check_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}      3        # Number of cycles to check power validation feature, default value 3
${RMOD_SERIAL_NUMBER}           # Select RM serial number for power validation feature check
${pMax_value}          46       # dBm value for parameter pMax, default 46(dBm)

*** Keywords ***
TC__CBTS_SBTS__CM__CBTS_Cell_power_validation_with_FID_1900_check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28242
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS_SBTS test case for power validation feature - cell power exceeded case, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check test argument values validity
    ...  - perform pMax parameter recommissioning on CBTS
    ...  - check power validation feature behaviour: FID1900 -> Supplementary alarm information contains "Power exceeded"
    ...  - recover initial parameter pMax value
    ...  Pass criteria: power validation feature behaviour as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 28.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28242 - TC Creation
    ...  - 09.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28569 -
    ...  [CBTS] [CB012840] Unified WebEM on RAN Verification automation - CBTS Part - 28.01
    ...

    Set Tags    CA-STATE    OWNER-cristian.croitoru@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform CBTS pMax parameter recommissioning to requested value
        Step 4: Check power validation feature behaviour
        Step 5: Perform pMax parameter recommissioning to initial value
        Step 6: Check final all BTS states
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    Log  Check test argument values validity:  console=True
    Get and check RM info precondition
    Get and check NR CELL info precondition
    Get and check pMax parameter info precondition

Step ${index}: Check ${when} all BTS states
    [Documentation]
    ...  BTS states is checked as follows:
    ...  - CBTS CU - Operational State: Enabled
    ...  - CBTS VDUs - Operational State: OnAir
    ...  - SBTS RAT - Procedural State: OnAir
    ...  - SBTS BTS - Procedural State: OnAir, Blocking State: Unblocked

    Log  Step ${index}: Check ${when} all BTS states  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} state *****  console=True
        ...  AND  Check CBTS CU VDU Operational State  alias=${alias}  timeout=600
        ...  AND  Log  ${alias} BTS site - CU Operational State: Enabled, VDUs Operational State: OnAir  console=True
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} state *****  console=True
        ...  AND  Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        ...  AND  Admin Check BTS Procedural and Blocking states  exp_pro_state=${OnAir_}  exp_blk_state=${Unblocked_}  timeout=600  alias=${alias}
        ...  AND  Log  ${alias} BTS site - Procedural State: OnAir, Blocking State: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms CBTS  alias=${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Perform CBTS pMax parameter recommissioning to requested value
    [Documentation]
    ...  Perform pMax parameter recommissioning.

    Log  Step ${index}: Perform pMax parameter recommissioning to requested value  console=True
    Perform pMax recommissioning  NR_CELL_scf_dns=${NR_CELL_scf_dns}  pMax_dBm=${pMax_value}  vdu_alias=${VDU_alias}

Perform pMax recommissioning
    [Documentation]
    ...  Perform pMax recommissioning

    [Arguments]  ${NR_CELL_scf_dns}  ${pMax_dBm}  ${vdu_alias}

    ${pMax_value_scf}=  Evaluate  ${pMax_dBm} * 10

    ${VDU_parameter_value_dict}=  Create Dictionary  pMax=${pMax_value_scf}
    ${VDU_parameter_operation_dict}=  Create Dictionary  pMax=update
    ${VDU_mo_parameters_info_list}=  Create List  update  ${VDU_parameter_value_dict}  ${VDU_parameter_operation_dict}

    ${NR_CELL_scf_dn_to_be_changed}=  Create Dictionary

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    FOR  ${NR_CELL_scf_dn}  IN  @{NR_CELL_scf_dns}

        ${pMax_current_scf}  ${pMax_current_dBm}=  Get pMax parameter value  ${NR_CELL_scf_dn}  ${vdu_alias}  ${VDU_SCF_path_file_info}

        Run Keyword If  ${pMax_current_scf} != ${pMax_value_scf}
        ...  Set To Dictionary  ${NR_CELL_scf_dn_to_be_changed}  ${NR_CELL_scf_dn}=${VDU_mo_parameters_info_list}

    END

    ${NR_CELL_scf_dn_to_be_changed_len}=  Get Length  ${NR_CELL_scf_dn_to_be_changed}
    Run Keyword If  ${NR_CELL_scf_dn_to_be_changed_len}==0  Run Keywords
    ...  Log  Current pMax parameter value: ${pMax_current_dBm} dBm already set on all NR cell, no action needed!
    ...  AND  Return From Keyword

    Log  Perform pMax recommissioning: ${pMax_current_dBm} dBm -> ${pMax_dBm} dBm  console=True
    Change CBTS VDU MOs parameters by Delta JSON file  mos_parameters_info_dict=&{NR_CELL_scf_dn_to_be_changed}  vdu_connection=${vdu_alias}

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}
    FOR  ${NR_CELL_scf_dn}  IN  @{NR_CELL_scf_dns}

        ${pMax_new_scf}  ${pMax_new_dBm}=  Get pMax parameter value  ${NR_CELL_scf_dn}  ${vdu_alias}  ${VDU_SCF_path_file_info}

        Log  New pMax parameter value: ${pMax_new_dBm} dBm for ${NR_CELL_scf_dn}  console=True
        Run Keyword If  ${pMax_new_scf} == ${pMax_value_scf}
        ...  Log  Recommissioning operation successfully performed  console=True
        ...  ELSE  Run Keywords
        ...  Log  Recommissioning operation failed  level=ERROR
        ...  AND  Fail  Recommissioning operation failed

    END

Step ${index}: Check power validation feature behaviour
    [Documentation]
    ...  Check power validation feature behaviour:
    ...  - FID1900 with field "Supplementary alarm information" info: "Power exceeded"

    Log  Step ${index}: Check power validation feature behaviour  console=True

    Log  Check "RF Module configuring failed (1900)" alarm:  console=True
    Log  - expected number: 1  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=${${VDU_alias.upper()}_EXPECTED_ALARMS}
    ...  ignored_alarms=${${VDU_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${VDU_alias.upper()}_CRITICAL_ALARMS}
    Log  Check "RF Module configuring failed (1900)" alarm passed:  console=True
    Log  - found number: 1  console=True

    Log  - expected specific field "Supplementary alarm information" info: "Power exceeded"  console=True
    Check Power exceeded Supplimentary Alarm Info  ${vdu_alias}
    Log  - found specific field "Supplementary alarm information" info: "Power exceeded"  console=True

Step ${index}: Perform pMax parameter recommissioning to initial value
    [Documentation]
    ...  Perform pMax parameter recommissioning.

    Log  Step ${index}: Perform pMax parameter recommissioning to initial value  console=True

    Recover initial pMax parameter value

    Log  Check CBTS alarms after recommissioning to initial value  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}   expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${VDU_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${VDU_alias.upper()}_CRITICAL_ALARMS}
    Log  CBTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get and check RM info precondition
    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${alias}  VDU
        Continue For Loop If  not ${is_vdu_alias}
        ${RM_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ${RM_found}=  Set Variable If  ('${RMOD_SERIAL_NUMBER}' in ${RM_sn_list}) and ('${RMOD_SERIAL_NUMBER}' in ${shared_RMOD_sn_list})
        ...  ${TRUE}  ${FALSE}
        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=
        ...  VDU Get RMOD sn id pn interface info  ${alias}
        ${RM_id}=  Get From Dictionary  ${VDU_RMOD_sn_id_dict}  ${RMOD_SERIAL_NUMBER}
        Set Test Variable  ${RM_id}
        Set Test Variable  ${VDU_alias}  ${alias}
        Exit For Loop If  ${RM_found}
    END

    Run Keyword If  not ${RM_found}  Run Keywords
    ...  Log Long String  Selected value ${RMOD_SERIAL_NUMBER} for test argument \${RMOD_SERIAL_NUMBER} is not valid. Please select a valid value for
    ...  test argument \${RMOD_SERIAL_NUMBER}  level=ERROR
    ...  AND  Fail  Improper value for argument!

Get and check NR CELL info precondition
    ${VDU_RMOD_id_NR_CELL_ids_dict}  ${VDU_RMOD_id_LTE_CELL_ids_dict}  ${VDU_RMOD_id_WCDMA_CELL_ids_dict}  ${VDU_RMOD_id_GSM_CELL_ids_dict}=
    ...  VDU Get Cells Mapped On RMOD    vdu_connection=${VDU_alias}
    ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${VDU_alias}
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${VDU_RMOD_id_NR_CELL_ids_dict}  ${RM_id}
    ${NR_CELL_RM_count}=  Get Length  ${RMOD_NR_CELL_ids_list}
    Run Keyword If  ${NR_CELL_RM_count} == 0  Run Keywords
    ...  Log  No CBTS NR Cell found! TC Cannot be performed.  level=ERROR
    ...  AND  Fail  No CBTS NR Cell found! TC Cannot be performed.

    Set Test Variable  ${NR_CELL_ids}  ${RMOD_NR_CELL_ids_list}
    ${NR_CELL_scf_dns}=  Create List
    FOR  ${NR_CELL_id}  IN  @{NR_CELL_ids}
        ${NR_CELL_scf_dn}=  Get From Dictionary  ${VDU_CELL_id_config_dn_dict}  ${NR_CELL_id}
        Append To List  ${NR_CELL_scf_dns}  ${NR_CELL_scf_dn}
    END
    Set Test Variable  ${NR_CELL_scf_dns}

Get and check pMax parameter info precondition

    ${pMax_value_scf}=  Evaluate  ${pMax_value} * 10

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${VDU_alias}

    ${pMax_initial_scf_dict}=  Create Dictionary

    FOR  ${NR_CELL_scf_dn}  IN  @{NR_CELL_scf_dns}

        ${pMax_initial_scf}  ${pMax_initial_dBm}=  Get pMax parameter value  ${NR_CELL_scf_dn}  ${VDU_alias}  ${VDU_SCF_path_file_info}

        Run Keyword If  ${pMax_initial_scf} == ${pMax_value_scf}  Run Keywords
        ...  Log Long String  Selected value ${pMax_value} dBm for test argument \${pMax_value} dBm is already set in current BTS SCF for
        ...  ${NR_CELL_scf_dn}. Please select a valid value for test argument \${pMax_value} dBm  level=ERROR
        ...  AND  Fail  Improper value for argument!

        Set To Dictionary  ${pMax_initial_scf_dict}  ${NR_CELL_scf_dn}=${pMax_initial_scf}

    END

    Set Test Variable  ${pMax_initial_scf_dict}

Get pMax parameter value
    [Documentation]
    ...  Get info related to pMax parameter value from scf.

    [Arguments]  ${NR_CELL_scf_dn}  ${vdu_alias}  ${scf_path}

    ${pMax_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${scf_path}  dist_name=${NR_CELL_scf_dn}  p_name=pMax
    ${pMax_count}=  Get Length  ${pMax_info_dict}
    ${pMax_scf}=  Run Keyword If  ${pMax_count} > 0
    ...  Get From Dictionary  ${pMax_info_dict}  pMax
    ...  ELSE
    ...  Fail  No pMax info available in BTS ${vdu_alias} SCF!

    ${pMax_dBm}=  Evaluate  ${pMax_scf} / 10

    [Return]  ${pMax_scf}  ${pMax_dBm}

Check Power exceeded Supplimentary Alarm Info
    [Arguments]  ${vdu_alias}
    ${active_alarms_dict}=  vdu.Vdu Get Active Alarms  vdu_connection=${vdu_alias}
    ${active_alarms}=  Get From Dictionary  ${active_alarms_dict}  alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${fault_id}=  Get From Dictionary  ${alarm}  fault_id
        Continue For Loop If  ${fault_id}!=1900
        ${additional_info}=  Get From Dictionary  ${alarm}  additional_info
        ${power_exceeded_status}  ${return}=  Run Keyword And Ignore Error  Should Contain  ${additional_info}  supplAlarmInfo=Power exceeded
        Run Keyword If  '${power_exceeded_status}'=='PASS'
        ...  Run Keywords
        ...  Log  Supplimentary Alarm Info Power exceeded succesfully checked: FID: ${fault_id}, additional_info: ${additional_info}  console=True
        ...  AND  Return From Keyword
    END
    Fail  Supplimentary Alarm Info Power exceeded not found!

Recover initial pMax parameter value
    [Documentation]
    ...  Recover initial pMax parameter value

    Log  Recover initial pMax parameter value  console=True

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}

    ${NR_CELL_scf_dn_params_dict}=  Create Dictionary

    FOR  ${NR_CELL_scf_dn}  IN  @{NR_CELL_scf_dns}

        ${pMax_final_scf}  ${pMax_final_dBm}=  Get pMax parameter value  ${NR_CELL_scf_dn}  ${vdu_alias}  ${VDU_SCF_path_file_info}
        ${pMax_initial_scf}=  Get From Dictionary  ${pMax_initial_scf_dict}  ${NR_CELL_scf_dn}

        Run Keyword If  ${pMax_final_scf} == ${pMax_initial_scf}  Run Keywords
        ...  Log  Final pMax parameter value: ${pMax_final_dBm} dBm, no recover action needed  console=True
        ...  AND  Continue For Loop

        ${VDU_parameter_value_dict}=  Create Dictionary  pMax=${pMax_initial_scf}
        ${VDU_parameter_operation_dict}=  Create Dictionary  pMax=update
        ${VDU_mo_parameters_info_list}=  Create List  update  ${VDU_parameter_value_dict}  ${VDU_parameter_operation_dict}

        Set To Dictionary  ${NR_CELL_scf_dn_params_dict}  ${NR_CELL_scf_dn}=${VDU_mo_parameters_info_list}

    END

    Return From Keyword If  not ${NR_CELL_scf_dn_params_dict}

    Change CBTS VDU MOs parameters by Delta JSON file  mos_parameters_info_dict=&{NR_CELL_scf_dn_params_dict}  vdu_connection=${vdu_alias}

    ${VDU_SCF_path_file_info}=  VDU Get Current Plan File  vdu_connection=${vdu_alias}

    FOR  ${NR_CELL_scf_dn}  IN  @{NR_CELL_scf_dns}

        ${pMax_new_scf}  ${pMax_new_dBm}=  Get pMax parameter value  ${NR_CELL_scf_dn}  ${vdu_alias}  ${VDU_SCF_path_file_info}

        Log  New pMax parameter value: ${pMax_new_dBm} dBm for ${NR_CELL_scf_dn}  console=True
        Run Keyword If  ${pMax_new_scf} == ${pMax_initial_scf}
        ...  Log  Recommissioning operation successfully performed  console=True
        ...  ELSE  Run Keywords
        ...  Log  Recommissioning operation failed  level=ERROR
        ...  AND  Fail  Recommissioning operation failed

    END

Particular Teardown
    Run Keyword And Continue On Failure  Recover initial pMax parameter value

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown