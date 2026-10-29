*** Settings ***
Documentation    TC__NRL__STATE__LTE_BBMOD_Reset_from_WEBEM_fALU_RMs
Variables    tc_variables/nrl__state__lte_bbmod_reset_from_webem_falu_rms_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}         3     # Number of LTE BBMOD reset operations, default value 3
${BTS_PRIMARY_LINK}             # BTS for primary link set before LTE BBMOD reset, possible values: empty (no set required),
                                # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_PROCEDURE}  LANE   # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${SET_PRIMARY_LINK_TIME}  720  # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${BBMOD_RESET_WRN_THR}    270   # Time from BBMOD Reset to last cell up. Default value: in accordance with KPI 5 specifications
${BBMOD_MAX_WAIT_TIME}    900   # Maximum time for wait of BTS OnAir (first cell up after reset). If this value is exceeded, test will fail
${RESET_BBMOD_TYPE_LIST}  ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ  # BBMOD type list on which Reset operation is valid. User may add/remove BBMOD type
                                                              # according with BBMOD Reset operation validity

*** Keywords ***
TC__NRL__STATE__LTE_BBMOD_Reset_from_WEBEM_fALU_RMs
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26173
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for LTE BBMOD reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - prepare LTE BBMOD list and related mapping info
    ...  - perform Reset operation on each LTE BBMOD checking state and alarms for both NR and LTE
    ...    technologies
    ...  - get and check KPI5 info from IMS file
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: reset operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26173 - [5G] New TC for fALU- NRL State LTE BBMOD Reset
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27205 - [5G] Check of DSS FID7509, 7511, 7513 to be included in
    ...  NRL__STATE__NR_BBMOD_Reset_from_WEBEM_fALU_RMs NRL__STATE__LTE_BBMOD_Reset_from_WEBEM_fALU_RMs
    ...  - 22.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27537 - Test adaptation following common test setup variable removal
    ...  - 11.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29834 - Update KW for BBMOD CELL mapping based on BBPOOL info
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26173_NRL__STATE__LTE_BBMOD_Reset_from_WEBEM_fALU_RMs.png

    Set Tags    CA-STATE    OWNER-alexandra.fratila@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS24R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get LTE BBMOD list
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Reset LTE BBMOD for iteration ${INDEX}
        Step 5: Check final number and state of Cells and RMs
    END
    Step 6: Check final all BTS state
    Step 7: Check final all BTS alarms

    [Teardown]  Particular Teardown

TC Preconditions
    ${RESET_BBMOD_TYPE_LIST_strip}=  Replace String  ${RESET_BBMOD_TYPE_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_BBMOD_TYPE_LIST}=  Split String  ${RESET_BBMOD_TYPE_LIST_strip}  ,
    Set Test Variable  ${RESET_BBMOD_TYPE_LIST}
    ${TL_BBMOD_reset_check}=  Set Variable  ${FALSE}

    Log  TC Preconditions verification started on LTE BTS  console=True
    ${LTE_BBMOD_reset_check}=  Check BBMOD type reset info  ${RESET_BBMOD_TYPE_LIST}
    Run Keyword If  ${LTE_BBMOD_reset_check}
    ...  Log Long String  TC Preconditions passed on LTE BTS. Reset operation will be performed on valid BBMOD(s) from:
    ...  ${RESET_BBMOD_TYPE_LIST}  console=True
    ...  ELSE
    ...  Log  TC Preconditions failed on LTE BTS. No BBMOD type valid for Reset operation found in: ${RESET_BBMOD_TYPE_LIST}  console=True
    Set Test Variable  ${LTE_BBMOD_reset_check}
     ${TL_BBMOD_reset_check}=  Set Variable If  ${LTE_BBMOD_reset_check}  ${TRUE}  ${TL_BBMOD_reset_check}

    Run Keyword If  not ${TL_BBMOD_reset_check}  Run Keywords
    ...  Log Long String  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on LTE BTS. Test execution will be stopped!
    ...  level=ERROR
    ...  AND  Fail  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on LTE BTS. Test execution will be stopped!

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

Step ${index}: Get LTE BBMOD list
    [Documentation]
    ...  LTE BBMOD list from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get LTE BBMOD list  console=True
    ${LTE_BBMOD_list}=  Get Ids For All  BBMOD  alias=Slave
    Sort List  ${LTE_BBMOD_list}
    ${LTE_BBMOD_count}=  Get Length  ${LTE_BBMOD_list}
    Run Keyword If  ${LTE_BBMOD_count} > 0
    ...  Log  LTE BBMOD found: ${LTE_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No LTE BBMOD are present in runtime view configuration!
    Set Test Variable  ${LTE_BBMOD_list}

    ${LTE_CELL_BBMOD_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  Slave
    Set Test Variable  ${LTE_CELL_BBMOD_dict}

    ${NR_RMOD_list}=  Get Ids For All  RMOD  alias=Master
    Sort List  ${NR_RMOD_list}
    Set Test Variable  ${NR_RMOD_list}
    ${LTE_RMOD_list}=  Get Ids For All  RMOD  alias=Slave
    Sort List  ${LTE_RMOD_list}
    Set Test Variable  ${LTE_RMOD_list}
    Check RMOD L3 Protocol  Master
    Check RMOD L3 Protocol  Slave

    Get RMOD SN dict  NR  Master
    Get RMOD SN dict  LTE  Slave

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=Master
    Set Test Variable  ${NR_CELL_list}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=Slave
    Set Test Variable  ${LTE_CELL_list}

    Check if DSS is configured

Set shared RMOD Primary Link before LTE BBMOD Reset operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Log  ==================================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing Primary Link configuration *****  console=True
    ...  AND  Log  ==================================================================================  console=True
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Step ${index}: Reset LTE BBMOD for iteration ${CYCLE}
    Log  Step ${index}: Reset LTE BBMOD  console=True

    Run Keyword If  not ${LTE_BBMOD_reset_check}  Run Keywords
    ...  Log  Test execution will be skipped on LTE BTS due to TC Preconditions check!  console=True
    ...  AND  Return From Keyword
    FOR  ${item}  IN  @{LTE_BBMOD_list}
        Set shared RMOD Primary Link before LTE BBMOD Reset operation
        Reset LTE BBMOD  ${item}  ${CYCLE}
    END

Step ${index}: LTE Eval Historic Alarms
    [Documentation]
    ...  check historic alarms for BBMOD autoreset
    ...  no historic autoreset alarm expected
    ...  Otherwise, BBMOD reset behavior not as expected, then errors are added to report and failed
    Log  Step ${index}: Eval Historic Alarms  console=True
    Eval Historic Alarms  connection=Slave    expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    ...  ignore_unexpected=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BBMOD type reset info
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}

    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    ${BBMOD_param_list}=  Get Parameters For All  class_name=BBMOD  connection=Slave
    FOR  ${item}  IN  @{BBMOD_param_list}
        ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${item.productName}
        Exit For Loop If  ${BBMOD_reset_check}
    END

    [Return]  ${BBMOD_reset_check}

Check BBMOD reset validity
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${productName}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    FOR  ${item}  IN  @{RESET_BBMOD_TYPE_LIST}
        ${BBMOD_reset_check}=  Set Variable If  '${item}' in '${productName}'  ${TRUE}  ${BBMOD_reset_check}
        Exit For Loop If  '${item}' in '${productName}'
    END

    [Return]  ${BBMOD_reset_check}

Get RMOD SN dict
    [Arguments]  ${tech}  ${alias}
    ${RMOD_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${tech}_RMOD_list}
        ${RM_PARAM_list}=  Get Parameters For  RMOD  ${item}  alias=${alias}
        Run Keyword If  '${tech}' == 'LTE'
        ...  Set To Dictionary  ${RMOD_SN_dict}  ${RM_PARAM_list['id']}  ${RM_PARAM_list['serialNumber']}
        ...  ELSE IF  '${tech}' == 'NR'
        ...  Set To Dictionary  ${RMOD_SN_dict}  ${RM_PARAM_list['serialNumber']}  ${RM_PARAM_list['id']}
    END
    Set Test Variable  ${${tech}_RMOD_SN_dict}  ${RMOD_SN_dict}

Get BBMOD parameters
    [Arguments]  ${BBMOD_id}

    ${BBMOD_param_list}=  Get Parameters For  BBMOD  ${BBMOD_id}  alias=Slave
    [Return]  ${BBMOD_param_list['serialNumber']}  ${BBMOD_param_list['productName']}

Reset LTE BBMOD
    [Arguments]  ${LTE_BBMOD_id}  ${CYCLE}
    ${BBMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}, administrativeState=${Unlocked_}
    ${BBMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${BBMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline, administrativeState=Unlocked
    ${BBMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${BBMOD_sn}  ${BBMOD_prodName}=  Get BBMOD parameters  ${LTE_BBMOD_id}
    ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${BBMOD_prodName}
    Run Keyword If  not ${BBMOD_reset_check}  Run Keywords
    ...  Log  "Reset" operation on LTE BTS for BBMOD with SN ${BBMOD_sn} will be skipped as not valid!  console=True
    ...  AND  Return From Keyword

    ${BBMOD_CELL_list_BBPOOL}=  Get From Dictionary  ${LTE_CELL_BBMOD_dict}  ${LTE_BBMOD_id}
    ${BBMOD_ABIA_reset_allowed}=  Run Keyword If  'ABIA' in '${BBMOD_prodName}'
    ...  Check BBMOD ABIA Reset  ${LTE_BBMOD_id}  ${BBMOD_CELL_list_BBPOOL}  Slave
    ...  ELSE  Set Variable  True
    Run Keyword If  not ${BBMOD_ABIA_reset_allowed}  Run Keywords
    ...  Log  "Reset" operation on BBMOD with SN ${BBMOD_sn} from ${BTS} will be skipped: BBMOD ABIA processing multiple RAT cells!  console=True
    ...  AND  Return From Keyword

    ${LTE_BBMOD_id_list}=  Create List
    Append To List  ${LTE_BBMOD_id_list}  ${LTE_BBMOD_id}
    ${LTE_BBMOD_RMOD_list}=  Get RMOD Mapping By BBMOD Id  ${LTE_BBMOD_id}  Slave
    ${LTE_not_BBMOD_RMOD_list}=  Copy List  ${LTE_RMOD_list}
    FOR  ${item}  IN  @{LTE_BBMOD_RMOD_list}
        Remove Values From List  ${LTE_not_BBMOD_RMOD_list}  ${item}
    END
    ${NR_LTE_BBMOD_RMOD_list}=  Get NR LTE RMOD Mapping Info  ${LTE_BBMOD_RMOD_list}
    Set Test Variable  ${NR_LTE_BBMOD_RMOD_list}
    ${NR_LTE_BBMOD_RMOD_count}=  Get Length  ${NR_LTE_BBMOD_RMOD_list}
    ${NR_LTE_not_BBMOD_RMOD_list}=  Copy List  ${NR_RMOD_list}
    ${CPRI_RMOD_list}=  Create List
    ${CPRI_ALU_RMOD_list}=  Create List
    FOR  ${item}  IN  @{NR_LTE_BBMOD_RMOD_list}
        Remove Values From List  ${NR_LTE_not_BBMOD_RMOD_list}  ${item}
        ${RMOD_SN}=  Get From Dictionary  ${NR_RMOD_ID_SN_dict}  ${item}
        ${LTE_RMOD_id}=  Get From Dictionary  ${LTE_RMOD_SN_ID_dict}  ${RMOD_SN}
        ${RMOD_L3_Protocol}=  Get From Dictionary  ${Master_RMOD_L3Protocol_dict}  ${item}
        Run Keyword If  '${RMOD_L3_Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${CPRI_RMOD_list}  ${item}
        ...  ELSE IF  '${RMOD_L3_Protocol}' == 'CPRI_ALU'
        ...  Append To List  ${CPRI_ALU_RMOD_list}  ${item}
    END
    Set Test Variable  ${CPRI_RMOD_list}
    Set Test Variable  ${CPRI_ALU_RMOD_list}
    ${CPRI_RMOD_count}=  Get Length  ${CPRI_RMOD_list}
    Set Test Variable  ${CPRI_RMOD_count}

    ${LTE_BBMOD_CELL_list}=  Get From Dictionary  ${LTE_CELL_BBMOD_dict}  ${LTE_BBMOD_id}
    ${LTE_BBMOD_CELL_count}=  Get Length  ${LTE_BBMOD_CELL_list}
    Set Test Variable  ${LTE_BBMOD_CELL_list}
    Set Test Variable  ${LTE_BBMOD_CELL_count}

    Run Keyword If  ${Slave_DSS_configured} and '${BTS_PRIMARY_LINK}' == 'Master'  Get NR DSS alarms
    ...  ELSE  Set Test Variable  ${NR_DSS_alarm_count}  0

    Log  Perform "Reset" operation on LTE BBMOD with SN ${BBMOD_sn} from WebEM  console=True

    ${new_alias}=  Set Variable  resetBBMOD
    Start new ADMIN instance  alias=Slave  new_alias=${new_alias}  connection_type=${connection_type_Slave}
    Get Current Time  lte_initial
    Get Current Date UTC info  bbmod_reset
    ${reset_info}=  Run Keyword In Background   Reset Unit  dist_name=${LTE_BBMOD_id}  reset_type=Warm  timeout=${BBMOD_MAX_WAIT_TIME}
    ...  connection=${new_alias}
    Sleep  10s

    Log  Check LTE and NR state and alarms during reset LTE BBMOD with SN ${BBMOD_sn}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  LTE  BBMOD  ${LTE_BBMOD_id_list}  ${BBMOD_state_disabled_check}  ${BBMOD_state_disabled}   ${remained_MAX_WAIT_TIME}  Slave
    Log  LTE BBMOD status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${LTE_not_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  LTE  RMOD  ${LTE_not_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}
    ...  Slave  AND  Log  All LTE RMOD(s) not connected to LTE BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${LTE_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  LTE  RMOD  ${LTE_BBMOD_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}
    ...  Slave  AND  Log  All LTE RMOD(s) connected to LTE BBMOD with SN ${BBMOD_sn} status as expected  console=True
    Check LTE cells state and MIMO alarm  alias=Slave
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE site - expected, ignored and critical alarms checked  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${NR_LTE_not_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  NR  RMOD  ${NR_LTE_not_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}
    ...  Master
    ...  AND  Log  All NR RMOD(s) not impacted by reset LTE BBMOD with SN ${BBMOD_sn} status as expected  console=True

    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master', 'Slave']
    ...  Check peer alarms
    Log  NR site - expected, ignored and critical alarms checked  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Collect Keyword Result  ${reset_info}  timeout=${remained_MAX_WAIT_TIME}

    Log  Check LTE and NR state and alarms after reset LTE BBMOD with SN ${BBMOD_sn}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  LTE  BBMOD  ${LTE_BBMOD_list}  ${BBMOD_state_enabled_check}  ${BBMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  Slave
    Log  All LTE BBMOD(s) status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  LTE  RMOD  ${LTE_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  Slave
    Log  All LTE RMOD(s) status as expected  console=True

    Get Current Time  bbmod_start_check_first_cell_up
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_bbmod_start_check_first_cell_up}  ${time_lte_initial}  number
    ${bbmod_first_cell_up_time}=  BuiltIn.Evaluate  ${BBMOD_MAX_WAIT_TIME} - ${elapsed_time}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${bbmod_first_cell_up_time}  Slave

    Get Current Time  bbmod_start_check_last_cell_up
    ${elapsed_time}=  DateTime.Subtract Date from Date  ${time_bbmod_start_check_last_cell_up}  ${time_lte_initial}  number
    ${bbmod_last_cell_up_time}=  BuiltIn.Evaluate  ${BBMOD_MAX_WAIT_TIME} - ${elapsed_time}
    Assert Every  LNCEL  ${CELL_state_enabled_check}  timeout=${bbmod_last_cell_up_time}  alias=Slave

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  NR  RMOD  ${NR_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  Master
    Log  All NR RMOD(s) status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_lte_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  NR  NRCEL  ${NR_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  Master
    Log  All NR CELL(s) status as expected  console=True

    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    Get Current Date UTC info  cells_onair
    Get and check KPI5 info from IMS file  ${LTE_BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}

    [Teardown]  Teardown Admin  alias=${new_alias}

Get and check KPI5 info from IMS file
    [Documentation]
    ...  Get and check KPI5 info from IMS file.

    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}

    Log  Get and check KPI5 info from IMS file for iteration ${CYCLE}  console=True

    Run Keyword If  ${LTE_BBMOD_CELL_count} == 0  Run Keywords
    ...  Log  KPI calculation and reporting will be skipped because BBMOD does not process any cells  console=True
    ...  AND  Return From Keyword

    ${kpi_name_delta_dict_kpi5}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi5  kpi_thresholds=${BBMOD_RESET_WRN_THR}  alias=Slave  start_point_timestamp_UTC=${date_timestamp_bbmod_reset_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_cells_onair_UTC}
    ${kpi_delta_list_kpi5}=  Get From Dictionary  ${kpi_name_delta_dict_kpi5}  kpi5
    Export KPI Results to File  alias=Slave  obj=BBMOD  obj_type=${BBMOD_prodName}_${BBMOD_sn}  obj_id=${BBMOD_id}  action_1=BBMOD_Reset
    ...  kpi_reported_1=KPI_5  event_value_1=${kpi_delta_list_kpi5[0]}  cycle=${CYCLE}  source_info=ims

Check RMOD L3 Protocol
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_L3Protocol}  None
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    Set Test Variable  ${${alias}_RMOD_L3Protocol_dict}  ${RMOD_L3Protocol_dict}

Get RMOD Mapping By BBMOD Id
    [Arguments]   ${BBMOD_id}  ${alias}
    ${BBMOD_RMOD_list}=  Create List
    ${CABLINK_LIST}=  Get Parameters For All  CABLINK  alias=${alias}
    FOR  ${item}  IN  @{CABLINK_LIST}
        Run Keyword If  '${item.firstEndpointDN}' == '${BBMOD_id}'
        ...  Append To List  ${BBMOD_RMOD_list}  ${item.secondEndpointDN}
    END
    Sort List  ${BBMOD_RMOD_list}
    ${BBMOD_RMOD_list}=  Remove Duplicates  ${BBMOD_RMOD_list}
    [Return]  ${BBMOD_RMOD_list}

Get NR LTE RMOD Mapping Info
    [Arguments]  ${RMOD_list}
    ${NR_LTE_BBMOD_RMOD_list}=  Create List
    ${NR_RMOD_ID_SN_dict}=  Create Dictionary
    ${LTE_RMOD_SN_ID_dict}=  Create Dictionary
    Set Test Variable  ${NR_RMOD_ID_SN_dict}
    Set Test Variable  ${LTE_RMOD_SN_ID_dict}
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_SN}=  Get From Dictionary  ${LTE_RMOD_SN_dict}  ${item}
        ${sharedRMOD}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${NR_RMOD_SN_dict}  ${RMOD_SN}
        Continue For Loop If  not ${sharedRMOD}
        ${NR_RMOD_id}=  Get From Dictionary  ${NR_RMOD_SN_dict}  ${RMOD_SN}
        Append To List  ${NR_LTE_BBMOD_RMOD_list}  ${NR_RMOD_id}
        Set To Dictionary  ${NR_RMOD_ID_SN_dict}  ${NR_RMOD_id}  ${RMOD_SN}
        Set To Dictionary  ${LTE_RMOD_SN_ID_dict}  ${RMOD_SN}  ${item}
    END
    [Return]  ${NR_LTE_BBMOD_RMOD_list}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  ${BTS_item_class}  ${item}  ${BTS_item_state_check}  timeout=${timeout}  alias=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Check peer alarms
    ${MASTER_EXPECTED_ALARMS_10_full}=  Prepare Expected Alarms List  ${MASTER_EXPECTED_ALARMS_10}  ${CPRI_RMOD_count}

    ${MASTER_EXPECTED_ALARMS}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master' and ${NR_DSS_alarm_count}>0  Set Variable  ${NR_ALARMS_DSS_FULL}
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' == 'Slave'  Set Variable  ${MASTER_EXPECTED_ALARMS_10_full}
    ...  ELSE  Create List

    ${MASTER_IGNORED_ALARMS_full}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave'
    ...  Combine Lists  ${MASTER_IGNORED_ALARMS}  ${MASTER_IGNORED_ALARMS_4764}
    ...  ELSE
    ...  Set Variable  ${MASTER_IGNORED_ALARMS}

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave' and ${CPRI_RMOD_count} > 0
    ...  Log  "No connection to Unit (10)" alarm, expected number: ${CPRI_RMOD_count}  console=True
    Run Keyword If  ${Slave_DSS_configured} and '${BTS_PRIMARY_LINK}' == 'Master' and ${NR_DSS_alarm_count} > 0
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, expected number:
    ...  ${NR_DSS_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS}  ignored_alarms=${MASTER_IGNORED_ALARMS_full}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  poll_interval=10 sec
    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Slave' and ${CPRI_RMOD_count} > 0
    ...  Log  "No connection to Unit (10)" alarm, found number: ${CPRI_RMOD_count}, as expected!  console=True
    Run Keyword If  ${Slave_DSS_configured} and '${BTS_PRIMARY_LINK}' == 'Master' and ${NR_DSS_alarm_count} > 0
    ...  Log Long String  NR "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, found number: ${NR_DSS_alarm_count},
    ...  as expected!  console=True

Get NR DSS alarms

    ${DSS_LTE_NR_CELL_runtime_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  Slave
    ${LTE_CELL_DSS_list}=  Get Dictionary Keys  ${DSS_LTE_NR_CELL_runtime_dict}
    ${LTE_CELL_DSS_BBMOD_list}=  Create List
    ${impacted_NR_CELL_list}=  Create List

    FOR  ${item}  IN  @{LTE_BBMOD_CELL_list}
        Run Keyword If  '${item}' in ${LTE_CELL_DSS_list}
        ...  Append To List  ${LTE_CELL_DSS_BBMOD_list}  ${item}
    END

    ${LTE_CELL_DSS_BBMOD_count}=  Get Length  ${LTE_CELL_DSS_BBMOD_list}
    Set Test Variable  ${LTE_CELL_DSS_BBMOD_count}

    Run Keyword If  ${LTE_CELL_DSS_BBMOD_count} == 0  Run Keywords
    ...  Set Test Variable  ${NR_DSS_alarm_count}  0
    ...  AND  Return From Keyword

    ${NR_DSS_alarm_count}=  Get Length  ${LTE_CELL_DSS_BBMOD_list}
    Set Test Variable  ${NR_DSS_alarm_count}
    ${NR_ALARMS_DSS_FULL}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_DSS}  ${NR_DSS_alarm_count}
    Set Test Variable  ${NR_ALARMS_DSS_FULL}

Check if DSS is configured
    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${BTS_DSS_NR_LTE_CELL_scf_dict}
    ...  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}
    FOR  ${alias}  IN  @{alias_list}
        ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
        ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
        ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

        ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
        ${BTS_DSS_peer}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
        Run Keyword If  '${peer_alias}' not in ${BTS_DSS_peer}
        ...  Set Test Variable  ${BTS_DSS_configured}  False

        Set Test Variable  ${${alias}_DSS_configured}  ${BTS_DSS_configured}
    END

    Run Keyword If  ${Master_DSS_configured} and ${Slave_DSS_configured}
    ...  Log  DSS is configured between NR and LTE BTS. DSS alarms check will be performed!  console=True
    ...  ELSE
    ...  Log  DSS is not configured between NR and LTE BTS. DSS alarms check will be skipped!  console=True

Particular Teardown
    Export KPI Results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown