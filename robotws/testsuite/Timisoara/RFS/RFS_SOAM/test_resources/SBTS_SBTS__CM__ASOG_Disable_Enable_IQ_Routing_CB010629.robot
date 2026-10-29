*** Settings ***
Documentation    TC__SBTS_SBTS__CM__ASOG_Disable_Enable_IQ_Routing_CB010629
Variables    tc_variables/sbts_sbts__cm__asog_disable_enable_iq_routing_cb010629_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                 3    # Number of BTS ASOG Disable/Enable IQ Routing operations, default value 3
${BTS}                                 # BTS ASOG on which Disable/Enable IQ Routing operations will be performed. Should be labeled as BTSx (x is
                                       # test_pc number in init.py)
${IQ_ROUTING_NR_CELL_ID_LIST}          # NR global cell ID list impacted by BTS ASOG Disable/Enable IQ Routing operations (separated by comma)
${IQ_ROUTING_LTE_CELL_ID_LIST}         # LTE global cell ID list impacted by BTS ASOG Disable/Enable IQ Routing operations (separated by comma)
${IQ_ROUTING_WCDMA_CELL_ID_LIST}       # WCDMA cell ID list impacted by BTS ASOG Disable/Enable IQ Routing operations (separated by comma)
${IQ_ROUTING_GSM_CELL_ID_LIST}         # GSM sector ID list impacted by BTS ASOG Disable/Enable IQ Routing operations (separated by comma)
${BTS_MAX_WAIT_TIME}              900  # Maximum time to wait for BTS ASOG Disable/Enable IQ Routing operations, by default 900

*** Keywords ***
TC__SBTS_SBTS__CM__ASOG_Disable_Enable_IQ_Routing_CB010629
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28680
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS ASOG Disable/Enable IQ Routing operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - check BTS ASOG IQ Routing should be enabled before run test scenario: enableInternalIQRouting is true on BTS
    ...  - disable BTS ASOG IQ Routing by recommissioning parameter enableInternalIQRouting true -> false checking states and alarms on BTS
    ...  - enable BTS ASOG IQ Routing by recommissioning parameter enableInternalIQRouting false -> true checking states and alarms on BTS
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: BTS ASOG Disable/Enable IQ Routing operations works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28680 - CB010629 new TC: enableInternalIQRouting online parameter change

    Set Tags    CA-CM    OWNER-dan.popescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS25R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Disable IQ routing on BTS
        Step 4: Enable IQ routing on BTS
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
        Step 8: Check all BTS reset behavior based on IMS info
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False

    Run Keyword If  '${BTS}' == ''  Run Keywords
    ...  Log  Test argument \${BTS} not valued. Please select a value from configured BTS: ${BTS_label_list}  console=True
    ...  AND  Fail  Improper value for argument!
    ...  ELSE IF  '${BTS}' not in ${BTS_label_list}  Run Keywords
    ...  Log  Selected value ${BTS} for test argument \${BTS} is not valid. Please select a value from configured BTS: ${BTS_label_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!

    ${BTS_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${BTS}
    Set Test Variable  ${BTS_alias}

    Log  ============================================================  console=True
    Log  BTS label selected for Disable/Enable IQ Routing operations: ${BTS}  console=True
    Log  BTS alias selected for Disable/Enable IQ Routing operations: ${BTS_alias}  console=True
    Log  ============================================================  console=True

    ${BTS_ASOG_check}=  Admin Check BTS HW product name info  class_name=SMOD  product_name=ASOG  alias=${BTS_alias}
    Run Keyword If  '${BTS_ASOG_check}' == 'False'  Run Keywords
    ...  Log  No HW ASOG found on selected ${BTS}. Testcase run will be skipped!  console=True
    ...  AND  Fail  No HW ASOG found on selected ${BTS}. Testcase run will be skipped!

    ${BTS_enableInternalIQRouting_info}=  Get BTS enableInternalIQRouting parameter info  alias=${BTS_alias}
    Run Keyword If  '${BTS_enableInternalIQRouting_info}' != 'true'  Run Keywords
    ...  Log  IQ routing is not enabled on selected ${BTS}. Testcase run will be skipped!  console=True
    ...  AND  Fail  IQ routing is not enabled on selected ${BTS}. Testcase run will be skipped!
    Set Test Variable  ${${BTS_alias}_enableInternalIQRouting_info_initial}  ${BTS_enableInternalIQRouting_info}

    Check IQ routing cell list

    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled

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

Step ${index}: Disable IQ routing on BTS
    [Documentation]
    ...  Disable IQ routing by recommissioning parameter enableInternalIQRouting=false on required BTS

    Log  Step ${index}: Disable IQ routing on BTS  console=True

    Get Current Date UTC info  start
    Change IQ routing parameter on BTS  enableInternalIQRouting_value=false  alias=${BTS_alias}
    Check BTS states and alarms with IQ routing disabled  alias=${BTS_alias}

Step ${index}: Enable IQ routing on BTS
    [Documentation]
    ...  Enable IQ routing by recommissioning parameter enableInternalIQRouting=true on required BTS

    Log  Step ${index}: Enable IQ routing on BTS  console=True

    Change IQ routing parameter on BTS  enableInternalIQRouting_value=true  alias=${BTS_alias}
    Check BTS states and alarms with IQ routing enabled  alias=${BTS_alias}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  RESET info is check from IMS file: reset behavior as expected if no BTS reset occurs, otherwise reset behavior not as expected

    Log  Step ${index}: Check all BTS reset behavior based on IMS info  console=True

    Get Current Date UTC info  end

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${BTS_alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${BTS_alias}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get BTS enableInternalIQRouting parameter info
    [Arguments]  ${BTS_SCF_path_file}=None  ${alias}=None

    ${BTS_SCF_path_file_info}=  Set Variable If  '${BTS_SCF_path_file}' == 'None'  ${${alias.lower()}_scf_initial}  ${BTS_SCF_path_file}
    ${BTS_SCF_SMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/SMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_SMOD_dn}=  Get From List  ${BTS_SCF_SMOD_list}  0

    ${enableInternalIQRouting_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${BTS_SCF_SMOD_dn}  p_name=enableInternalIQRouting

    ${enableInternalIQRouting_count}=  Get Length  ${enableInternalIQRouting_info_dict}
    ${enableInternalIQRouting_info}=  Run Keyword If   ${enableInternalIQRouting_count} > 0
    ...  Get From Dictionary  ${enableInternalIQRouting_info_dict}  enableInternalIQRouting
    ...  ELSE
    ...  Set Variable  NA

    [Return]  ${enableInternalIQRouting_info}

Check IQ routing cell list
    ${IQ_routing_NR_cell_dn_list}=  Get BTS cell dn list  cell_id_list=${IQ_ROUTING_NR_CELL_ID_LIST}  cell_type=nr  alias=${BTS_alias}
    ${IQ_routing_LTE_cell_dn_list}=  Get BTS cell dn list  cell_id_list=${IQ_ROUTING_LTE_CELL_ID_LIST}  cell_type=lte  alias=${BTS_alias}
    ${IQ_routing_WCDMA_cell_dn_list}=  Get BTS cell dn list  cell_id_list=${IQ_ROUTING_WCDMA_CELL_ID_LIST}  cell_type=wcdma  alias=${BTS_alias}
    ${IQ_routing_GSM_cell_dn_list}=  Get BTS cell dn list  cell_id_list=${IQ_ROUTING_GSM_CELL_ID_LIST}  cell_type=gsm  alias=${BTS_alias}
    Set Test Variable  ${IQ_routing_NR_cell_dn_list}
    Set Test Variable  ${IQ_routing_LTE_cell_dn_list}
    Set Test Variable  ${IQ_routing_WCDMA_cell_dn_list}
    Set Test Variable  ${IQ_routing_GSM_cell_dn_list}

Get BTS cell dn list
    [Arguments]  ${cell_id_list}  ${cell_type}  ${alias}

    ${cell_dn_list}=  Create List

    Return From Keyword If  '${cell_id_list}' == ''  ${cell_dn_list}

    ${cell_id_list_strip}=  Replace String  ${cell_id_list}  ${SPACE}  ${EMPTY}
    ${cell_id_list}=  Split String  ${cell_id_list_strip}  ,
    ${cell_check}=  Set Variable  True
    ${cell_invalid_id_list}=  Create List
    ${cell_request_id_list}=  Create List
    ${cell_configured_id_list}=  Create List

    ${cell_param}=  Set Variable If  '${cell_type}' in ['nr', 'lte']  globalCellId  '${cell_type}' == 'wcdma'  cellId
    ...  '${cell_type}' == 'gsm'  gsmSectorID

    ${cells_info}=  Get Cells Info  cell_type=${cell_type}  timeout=10  connection=${alias}

    FOR  ${item}  IN  @{cells_info}

        ${cell_id}=  Get From Dictionary  ${item}  ${cell_param}
        Append To List  ${cell_configured_id_list}  ${cell_id}

    END

    Sort List  ${cell_configured_id_list}

    FOR  ${item}  IN  @{cell_id_list}

        ${cell_check}=  Set Variable If  ${item} not in ${cell_configured_id_list}  False  ${cell_check}
        Run Keyword If  ${item} not in ${cell_configured_id_list}
        ...  Append To List  ${cell_invalid_id_list}  ${item}
        ...  ELSE
        ...  Append To List  ${cell_request_id_list}  ${item}

    END

    Sort List  ${cell_invalid_id_list}
    Sort List  ${cell_request_id_list}

    Run Keyword If  '${cell_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected values for test argument \${IQ_ROUTING_${cell_type.upper()}_CELL_ID_LIST} are not valid:
    ...  ${cell_invalid_id_list}. Please select values from configured BTS cells: ${cell_configured_id_list}  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{cells_info}

        ${cell_id}=  Get From Dictionary  ${item}  ${cell_param}
        Continue For Loop If  '${cell_id}' not in ${cell_request_id_list}

        ${id_info}=  Get From Dictionary  ${item}  id

        ${cell_dn}=  Get From Dictionary  ${id_info}  internal

        Append To List  ${cell_dn_list}  ${cell_dn}

    END

    Sort List  ${cell_dn_list}

    [Return]  ${cell_dn_list}

Change IQ routing parameter on BTS
    [Documentation]
    ...  Change IQ routing parameter on BTS

    [Arguments]  ${enableInternalIQRouting_value}  ${alias}

    Log  Change IQ routing on BTS ${alias} by recommissioning parameter enableInternalIQRouting: ${enableInternalIQRouting_value}  console=True

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${enableInternalIQRouting_info}=  Get BTS enableInternalIQRouting parameter info  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    Run Keyword If  '${enableInternalIQRouting_info}' == '${enableInternalIQRouting_value}'  Run Keywords
    ...  Log  Parameter enableInternalIQRouting already set on BTS ${alias}: ${enableInternalIQRouting_info}, commissioning not needed!  console=True
    ...  AND  Return From Keyword

    ${BTS_SCF_SMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/SMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${alias}
    ${BTS_SCF_SMOD_dn}=  Get From List  ${BTS_SCF_SMOD_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_SMOD_dn}  parameter=enableInternalIQRouting  operation=update
    ...  value=${enableInternalIQRouting_value}  skip_parameter_relation_errors=False  should_activate=True  alias=${alias}

    Sleep  5s

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${enableInternalIQRouting_info}=  Get BTS enableInternalIQRouting parameter info  BTS_SCF_path_file=${BTS_SCF_path_file_info}  alias=${alias}
    Run Keyword If  '${enableInternalIQRouting_info}' == '${enableInternalIQRouting_value}'
    ...  Log  Parameter enableInternalIQRouting set on BTS ${alias}: ${enableInternalIQRouting_info}, successfully commissioning!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  Parameter enableInternalIQRouting not properly set on BTS ${alias}! (expected/found value:
    ...  ${enableInternalIQRouting_value}/${enableInternalIQRouting_info})  console=True
    ...  AND  Fail  Parameter enableInternalIQRouting not properly set on BTS ${alias}!

Check BTS states and alarms with IQ routing disabled
    [Arguments]  ${alias}

    Log  Check BTS ${alias} cells status with IQ routing disabled on BTS ${alias}:   console=True
    ${NR_cell_count}=  Get Length  ${IQ_routing_NR_cell_dn_list}
    Run Keyword If  ${NR_cell_count} > 0
    ...  Check IQ routing cells status  NRCEL  ${IQ_routing_NR_cell_dn_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    ${LTE_cell_count}=  Get Length  ${IQ_routing_LTE_cell_dn_list}
    Run Keyword If  ${LTE_cell_count} > 0
    ...  Check IQ routing cells status  LNCEL  ${IQ_routing_LTE_cell_dn_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    ${WCDMA_cell_count}=  Get Length  ${IQ_routing_WCDMA_cell_dn_list}
    Run Keyword If  ${WCDMA_cell_count} > 0
    ...  Check IQ routing cells status  WNCEL  ${IQ_routing_WCDMA_cell_dn_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    ${GSM_cell_count}=  Get Length  ${IQ_routing_GSM_cell_dn_list}
    Run Keyword If  ${GSM_cell_count} > 0
    ...  Check IQ routing cells status  GNCEL  ${IQ_routing_GSM_cell_dn_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    Log  Check BTS ${alias} alarms with IQ routing disabled on BTS ${alias}  console=True
    ${FID1868_count}=  Evaluate  ${NR_cell_count} + ${LTE_cell_count} + ${WCDMA_cell_count} + ${GSM_cell_count}
    ${BTS_EXPECTED_ALARMS_1868_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_1868}  ${FID1868_count}
    ${BTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DURING_ACTION}

    Log  BTS ${alias} "BTS configuration error (not enough HW for LCR) (1868)" alarm, expected number: ${FID1868_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  time=10 min  expected_alarms=${BTS_EXPECTED_ALARMS_1868_full}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_FULL}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "BTS configuration error (not enough HW for LCR) (1868)" alarm, found number: ${FID1868_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check BTS states and alarms with IQ routing enabled
    [Arguments]  ${alias}

    Log  Check BTS ${alias} cells status with IQ routing enabled on BTS ${alias}:   console=True
    ${NR_cell_count}=  Get Length  ${IQ_routing_NR_cell_dn_list}
    Run Keyword If  ${NR_cell_count} > 0
    ...  Check IQ routing cells status  NRCEL  ${IQ_routing_NR_cell_dn_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    ${LTE_cell_count}=  Get Length  ${IQ_routing_LTE_cell_dn_list}
    Run Keyword If  ${LTE_cell_count} > 0
    ...  Check IQ routing cells status  LNCEL  ${IQ_routing_LTE_cell_dn_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    ${WCDMA_cell_count}=  Get Length  ${IQ_routing_WCDMA_cell_dn_list}
    Run Keyword If  ${WCDMA_cell_count} > 0
    ...  Check IQ routing cells status  WNCEL  ${IQ_routing_WCDMA_cell_dn_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    ${GSM_cell_count}=  Get Length  ${IQ_routing_GSM_cell_dn_list}
    Run Keyword If  ${GSM_cell_count} > 0
    ...  Check IQ routing cells status  GNCEL  ${IQ_routing_GSM_cell_dn_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${alias}

    Log  Check BTS ${alias} alarms with IQ routing enabled on BTS ${alias}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Check cells availability status online  ${alias}  ${BTS_MAX_WAIT_TIME}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} cells status with IQ routing enabled on BTS ${alias}:  console=True
        Check cells availability status online  ${other_alias}  ${BTS_MAX_WAIT_TIME}
        Log  BTS ${other_alias} cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

        Log  Check BTS ${other_alias} alarms with IQ routing enabled on BTS ${alias}  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${other_alias} site - expected, ignored and critical alarms checked  console=True

    END

Check IQ routing cells status
    [Arguments]  ${class_name}  ${cell_dn_list}  ${cell_status_check}  ${cell_status}  ${timeout}  ${alias}

    FOR  ${cell_dn}  IN  @{cell_dn_list}

        Assert  class_name=${class_name}  id=${cell_dn}  parameters=${cell_status_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${class_name} ${cell_dn} status:\n - ${cell_status}  console=True

    END

Particular Teardown
    ${enableInternalIQRouting_status}=  Run Keyword And Return Status  Variable Should Exist  ${${BTS_alias}_enableInternalIQRouting_info_initial}
    Return From Keyword If  not ${enableInternalIQRouting_status}

    ${BTS_SCF_path_file_info}=  Admin Collect scf.xml with timestamp TAF  alias=${BTS_alias}
    ${BTS_enableInternalIQRouting_info}=  Get BTS enableInternalIQRouting parameter info  BTS_SCF_path_file=${BTS_SCF_path_file_info}
    ...  alias=${BTS_alias}

    Return From Keyword If  '${BTS_enableInternalIQRouting_info}' == '${${BTS_alias}_enableInternalIQRouting_info_initial}'

    ${BTS_SCF_SMOD_list}=  Get All Dist Names By Pattern from SCF  pattern=/SMOD-[\\d]+$  scf_path=${BTS_SCF_path_file_info}  alias=${BTS_alias}
    ${BTS_SCF_SMOD_dn}=  Get From List  ${BTS_SCF_SMOD_list}  0
    coam.Perform Parameter Recommissioning  dist_name=${BTS_SCF_SMOD_dn}  parameter=enableInternalIQRouting  operation=update
    ...  value=${${BTS_alias}_enableInternalIQRouting_info_initial}  skip_parameter_relation_errors=False  should_activate=True  alias=${BTS_alias}

    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown