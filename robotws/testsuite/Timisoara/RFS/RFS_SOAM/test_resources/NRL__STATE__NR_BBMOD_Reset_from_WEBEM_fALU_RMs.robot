*** Settings ***
Documentation    TC__NRL__STATE__NR_BBMOD_Reset_from_WEBEM_fALU_RMs
Variables    tc_variables/nrl__state__nr_bbmod_reset_from_webem_falu_rms_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}            3     # Number of NR BBMOD reset operations, default value 3
${BTS_PRIMARY_LINK}                # BTS for primary link set before NR BBMOD reset, possible values: empty (no set required),
                                   # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_PROCEDURE}  LANE   # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${SET_PRIMARY_LINK_TIME}     720   # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${CELLS_CHECK_DURING_RESET}  True  # Flag to enable/disable cells check during BBMOD reset; Possible values: True, False
                                   # In case of many RXs and TXs it is recommended to choose False value in order to skip the check and avoid failure
${HISTORICAL_ALARMS_CHECK}   True  # Flag to enable/disable historical alarms check; Possible values: True, False
${BBMOD_RESET_WRN_THR}       270   # Time from BBMOD Reset to last cell up. Default value: in accordance with KPI 5 specifications
${BBMOD_MAX_WAIT_TIME}       900   # Maximum time for wait of BTS OnAir (last cell up after reset). If this value is exceeded, test will fail
${RESET_BBMOD_TYPE_LIST}     ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ  # BBMOD type list on which Reset operation is valid. User may add/remove BBMOD type
                                                                 # according with BBMOD Reset operation validity
*** Keywords ***
TC__NRL__STATE__NR_BBMOD_Reset_from_WEBEM_fALU_RMs
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26236
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR BBMOD reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - prepare NR BBMOD list and related mapping info
    ...  - perform Reset operation on each NR BBMOD checking state and alarms for both NR and LTE
    ...    technologies
    ...  - check reset behavior on NR and LTE based on IMS info as follows:
    ...    - NR site: reset number is 0
    ...    - LTE site: reset number is 0
    ...  - get and check KPI5 info from IMS file
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: reset operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.11.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-26236 - [5G] New TC for fALU-NRL State NR BBMOD Reset
    ...  - 14.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27032 - [5G] In test NRL__STATE__NR_BBMOD_Reset_from_WEBEM_fALU_RMs radio module
    ...  list should be updated
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27205 - [5G] Check of DSS FID7509, 7511, 7513 to be included in
    ...  NRL__STATE__NR_BBMOD_Reset_from_WEBEM_fALU_RMs NRL__STATE__LTE_BBMOD_Reset_from_WEBEM_fALU_RMs
    ...  - 22.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27537 - Test adaptation following common test setup variable removal
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26236_NRL__STATE__NR_BBMOD_Reset_from_WEBEM_fALU_RMs.png

     Set Tags    CA-STATE    OWNER-alexandra.fratila@nokia.com    AUTHOR-ana.tugui@nokia.com    PHASE-QT    SW-SBTS24R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get NR BBMOD list
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log     ==============================================================================  console=True
        Log     Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log     ==============================================================================  console=True
        Step 4: Reset NR BBMOD for iteration ${INDEX}
        Step 5: Check NR and LTE reset behavior based on IMS info
        Step 6: Check Historic Alarms
        Step 7: Check final number and state of Cells and RMs
    END
    Step 8: Check final all BTS state
    Step 9: Check final all BTS alarms

    [Teardown]  Particular Teardown

TC Preconditions
    ${RESET_BBMOD_TYPE_LIST_strip}=  Replace String  ${RESET_BBMOD_TYPE_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_BBMOD_TYPE_LIST}=  Split String  ${RESET_BBMOD_TYPE_LIST_strip}  ,
    Set Test Variable  ${RESET_BBMOD_TYPE_LIST}
    ${TL_BBMOD_reset_check}=  Set Variable  ${FALSE}

    Log  TC Preconditions verification started on NR BTS  console=True
    ${NR_BBMOD_reset_check}=  Check BBMOD type reset info  ${RESET_BBMOD_TYPE_LIST}
    Run Keyword If  ${NR_BBMOD_reset_check}
    ...  Log Long String  TC Preconditions passed on NR BTS. Reset operation will be performed on valid BBMOD(s) from:
    ...  ${RESET_BBMOD_TYPE_LIST}  console=True
    ...  ELSE
    ...  Log  TC Preconditions failed on NR BTS. No BBMOD type valid for Reset operation found in: ${RESET_BBMOD_TYPE_LIST}  console=True
    Set Test Variable  ${NR_BBMOD_reset_check}
     ${TL_BBMOD_reset_check}=  Set Variable If  ${NR_BBMOD_reset_check}  ${TRUE}  ${TL_BBMOD_reset_check}

    Run Keyword If  not ${TL_BBMOD_reset_check}  Run Keywords
    ...  Log Long String  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on NR BTS. Test execution will be stopped!
    ...  level=ERROR
    ...  AND  Fail  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on NR BTS. Test execution will be stopped!

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

Step ${index}: Check Historic Alarms
    [Documentation]
    ...  check historic alarms for BBMOD autoreset
    ...  no historic autoreset alarm expected
    ...  Otherwise, BBMOD reset behavior not as expected, then errors are added to report and failed

    Run Keyword If  ${HISTORICAL_ALARMS_CHECK}==False  Run Keywords
    ...  Log  Historical Alarms Check will be skipped.  console=True
    ...  AND  Return From Keyword
    Log  Step ${index}: Check NR and LTE Historic alarms  console=True

    ${MASTER_IGNORED_HISTORICAL_ALARMS}=  Combine Lists  ${MASTER_IGNORED_ALARMS}  ${MASTER_EXPECTED_ALARMS_7300}  ${MASTER_EXPECTED_ALARMS_7319}
    ...  ${MASTER_EXPECTED_ALARMS_10_1815}
    ${SLAVE_IGNORED_HISTORICAL_ALARMS}=  Combine Lists  ${SLAVE_IGNORED_ALARMS}  ${SLAVE_EXPECTED_ALARMS_16}  ${SLAVE_EXPECTED_ALARMS_10_1815}
    ...  ${SLAVE_IGNORED_ALARMS_DSS}
    Eval Historic Alarms  connection=Master    expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_HISTORICAL_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  ignore_unexpected=True
    Eval Historic Alarms  connection=Slave    expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_HISTORICAL_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}  ignore_unexpected=True

Step ${index}: Get NR BBMOD list
    [Documentation]
    ...  NR BBMOD list from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get NR BBMOD list  console=True
    ${NR_BBMOD_list}=  Get Ids For All  BBMOD  alias=Master
    Sort List  ${NR_BBMOD_list}
    ${NR_BBMOD_count}=  Get Length  ${NR_BBMOD_list}
    Run Keyword If  ${NR_BBMOD_count} > 0
    ...  Log  NR BBMOD found: ${NR_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No NR BBMOD are present in runtime view configuration!
    Set Test Variable  ${NR_BBMOD_list}
    Set Test Variable  ${NR_BBMOD_count}

    ${NR_RMOD_list}=  Get Ids For All  RMOD  alias=Master
    Sort List  ${NR_RMOD_list}
    Set Test Variable  ${NR_RMOD_list}
    ${LTE_RMOD_list}=  Get Ids For All  RMOD  alias=Slave
    Sort List  ${LTE_RMOD_list}
    Set Test Variable  ${LTE_RMOD_list}
    ${Master_RMOD_L3Protocol_dict}=  Get RMOD L3 Protocol  Master
    Set Test Variable  ${Master_RMOD_L3Protocol_dict}

    Get RMOD SN dict  NR  Master
    Get RMOD SN dict  LTE  Slave
    Get NR BBMOD INFO Dict

    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RM_list}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=Master
    Set Test Variable  ${NR_CELL_list}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=Slave
    Set Test Variable  ${LTE_CELL_list}
    ${NR_CELL_count}=  Get Length  ${NR_CELL_list}
    ${LTE_CELL_count}=  Get Length  ${LTE_CELL_list}
    Set Test Variable  ${NR_CELL_count}
    Set Test Variable  ${LTE_CELL_count}

    ${NR_CELL_list}=  Get Ids For All  NRCEL  alias=Master
    ${NR_SA_cell_list}  ${NR_NSA_cell_list}=  Get NR Cell Deployment Type list  ${NR_CELL_list}  Master
    ${NR_NSA_cell_count}=  Get Length  ${NR_NSA_cell_list}
    Set Test Variable  ${NR_CELL_list}
    Set Test Variable  ${NR_NSA_cell_list}
    Set Test Variable  ${NR_NSA_cell_count}

Step ${index}: Reset NR BBMOD for iteration ${CYCLE}
    Log  Step ${index}: Reset NR BBMOD  console=True

    Run Keyword If  not ${NR_BBMOD_reset_check}  Run Keywords
    ...  Log  Test execution will be skipped on NR BTS due to TC Preconditions check!  console=True
    ...  AND  Return From Keyword
    Get Current Date UTC info  start
    FOR  ${item}  IN  @{NR_BBMOD_list}
        Set shared RMOD Primary Link before NR BBMOD Reset operation
        Reset NR BBMOD  ${item}  ${CYCLE}
    END
    Get Current Date UTC info  end

Set shared RMOD Primary Link before NR BBMOD Reset operation
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

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

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
    ${BBMOD_param_list}=  Get Parameters For All  class_name=BBMOD  connection=Master
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
        Run Keyword If  '${tech}' == 'NR'
        ...  Set To Dictionary  ${RMOD_SN_dict}  ${RM_PARAM_list['id']}  ${RM_PARAM_list['serialNumber']}
        ...  ELSE IF  '${tech}' == 'LTE'
        ...  Set To Dictionary  ${RMOD_SN_dict}  ${RM_PARAM_list['serialNumber']}  ${RM_PARAM_list['id']}
    END
    Set Test Variable  ${${tech}_RMOD_SN_dict}  ${RMOD_SN_dict}

Get NR BBMOD INFO Dict
    ${NR_BBMOD_INFO_dict}=  Create Dictionary
    FOR  ${item}  IN  @{NR_BBMOD_list}
        ${BBMOD_param}=  Get Parameters For  BBMOD  id_num=${item}  alias=Master
        Set To Dictionary  ${NR_BBMOD_INFO_dict}  ${item}  ${BBMOD_param.productName}_${BBMOD_param.serialNumber}
    END
    Set Test Variable  ${NR_BBMOD_INFO_dict}

Get BBMOD parameters
    [Arguments]  ${BBMOD_id}

    ${BBMOD_param_list}=  Get Parameters For  BBMOD  ${BBMOD_id}  alias=Master
    [Return]  ${BBMOD_param_list['serialNumber']}  ${BBMOD_param_list['productName']}

Reset NR BBMOD
    [Arguments]  ${NR_BBMOD_id}  ${CYCLE}
    ${BBMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}, administrativeState=${Unlocked_}
    ${BBMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    ${CELL_state_enabled_check}=  Set Variable
    ...  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${BBMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${BBMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${BBMOD_sn}  ${BBMOD_prodName}=  Get BBMOD parameters  ${NR_BBMOD_id}
    ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${BBMOD_prodName}
    Run Keyword If  not ${BBMOD_reset_check}  Run Keywords
    ...  Log  "Reset" operation on NR BTS for BBMOD with SN ${BBMOD_sn} will be skipped as not valid!  console=True
    ...  AND  Return From Keyword

    ${NR_BBMOD_id_list}=  Create List
    Append To List  ${NR_BBMOD_id_list}  ${NR_BBMOD_id}
    ${NR_BBMOD_INFO}=  Get from Dictionary  ${NR_BBMOD_INFO_dict}  ${NR_BBMOD_id}
    ${NR_BBMOD_shared_RMOD_list}  ${NR_BBMOD_dedicated_RMOD_list}=  Get RMOD Mapping on specific BBMOD  ${NR_BBMOD_id}  Master
    ${NR_BBMOD_all_RMOD_list}=  Combine Lists  ${NR_BBMOD_shared_RMOD_list}  ${NR_BBMOD_dedicated_RMOD_list}
    ${NR_BBMOD_RMOD_count}=  Get Length  ${NR_BBMOD_all_RMOD_list}
    ${NR_not_BBMOD_RMOD_list}=  Copy List  ${NR_RMOD_list}
    FOR  ${item}  IN  @{NR_BBMOD_all_RMOD_list}
        Remove Values From List  ${NR_not_BBMOD_RMOD_list}  ${item}
    END
    ${NR_BBMOD_all_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{NR_BBMOD_all_RMOD_list}
        Run Keyword If  '${item}' in @{Master_shared_RM_list}
        ...  Append To List  ${NR_BBMOD_all_shared_RMOD_list}  ${item}
    END
    ${LTE_NR_BBMOD_RMOD_list}=  Get LTE NR RMOD Mapping Info  ${NR_BBMOD_all_shared_RMOD_list}
    Set Test Variable  ${LTE_NR_BBMOD_RMOD_list}
    ${LTE_NR_BBMOD_RMOD_count}=  Get Length  ${LTE_NR_BBMOD_RMOD_list}
    ${LTE_NR_not_BBMOD_RMOD_list}=  Copy List  ${LTE_RMOD_list}
    ${CPRI_RMOD_list}=  Create List
    ${CPRI_ALU_RMOD_list}=  Create List
    FOR  ${item}  IN  @{LTE_NR_BBMOD_RMOD_list}
        Remove Values From List  ${LTE_NR_not_BBMOD_RMOD_list}  ${item}
        ${RMOD_SN}=  Get From Dictionary  ${LTE_RMOD_ID_SN_dict}  ${item}
        ${NR_RMOD_id}=  Get From Dictionary  ${NR_RMOD_SN_ID_dict}  ${RMOD_SN}
        ${RMOD_L3_Protocol}=  Get From Dictionary  ${Master_RMOD_L3Protocol_dict}  ${NR_RMOD_id}
        Run Keyword If  '${RMOD_L3_Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${CPRI_RMOD_list}  ${item}
        ...  ELSE IF  '${RMOD_L3_Protocol}' == 'CPRI_ALU'
        ...  Append To List  ${CPRI_ALU_RMOD_list}  ${item}
    END
    Set Test Variable  ${CPRI_RMOD_list}
    Set Test Variable  ${CPRI_ALU_RMOD_list}
    ${CPRI_RMOD_count}=  Get Length  ${CPRI_RMOD_list}
    Set Test Variable  ${CPRI_RMOD_count}

    ${NR_CELL_BBMOD_list}=  Get Cell Mapping By Module Id  module_id=${NR_BBMOD_id}  alias=Master
    Set Test Variable  ${NR_CELL_BBMOD_list}
    ${NR_CELL_BBMOD_count}=  Get Length  ${NR_CELL_BBMOD_list}

    ${BBMOD_SA_cell_list}  ${BBMOD_NSA_cell_list}=  Get NR Cell Deployment Type list  ${NR_CELL_BBMOD_list}  Master
    ${BBMOD_NSA_cell_count}=  Get Length  ${BBMOD_NSA_cell_list}

    Log  Perform "Reset" operation on NR BBMOD with SN ${BBMOD_sn} from Admin  console=True

    ${new_alias}=  Set Variable  resetBBMOD
    Start new ADMIN instance  alias=Master  new_alias=${new_alias}  connection_type=${connection_type_Master}
    Get Current Date UTC info  bbmod_reset
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${NR_BBMOD_id}  reset_type=Warm  timeout=${BBMOD_MAX_WAIT_TIME}
    ...  connection=${new_alias}
    Get Current Time  initial
    Sleep  10s

    Log  Check NR and LTE state during reset NR BBMOD with SN ${BBMOD_sn}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  NR  BBMOD  ${NR_BBMOD_id_list}  ${BBMOD_state_disabled_check}  ${BBMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  Master
    Log  NR BBMOD status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  NR  NRCEL  ${NR_CELL_BBMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  ${remained_MAX_WAIT_TIME}  Master
    Log  All NR cell{s} impacted by reset NR BBMOD status as expected  console=True
    Run Keyword If  ${NR_not_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  NR  RMOD  ${NR_not_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  Master
    ...  AND  Log  All NR RMOD(s) not connected to NR BBMOD with SN ${BBMOD_sn} status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Run Keyword If  ${NR_BBMOD_RMOD_count} > 0  Run Keywords
    ...  Check BTS Item State  NR  RMOD  ${NR_BBMOD_all_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}
    ...  Master
    ...  AND  Log  All NR RMOD(s) connected to NR BBMOD with SN ${BBMOD_sn} status as expected  console=True
    Run Keyword If  ${CELLS_CHECK_DURING_RESET}  Check NR cells state and MIMO alarm  alias=Master

    Run Keyword If  ${LTE_NR_not_BBMOD_RMOD_list}  Run Keywords
    ...  Check BTS Item State  LTE  RMOD  ${LTE_NR_not_BBMOD_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  Slave
    ...  AND  Log  All LTE RMOD(s) not impacted by reset NR BBMOD with SN ${BBMOD_sn} status as expected  console=True

    Log  Check NR and LTE alarms during reset NR BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master', 'Slave']  Run Keywords
    ...  Check peer alarms
    ...  AND  Log  LTE site - expected, ignored and critical alarms checked  console=True

    ${MASTER_EXPECTED_ALARMS_FULL}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_7300}  ${MASTER_EXPECTED_ALARMS_7319}
    Run Keyword If  ${BBMOD_NSA_cell_count} > 0 and ${BBMOD_NSA_cell_count} == ${NR_NSA_cell_count}  Run Keywords
    ...  Log  NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    ...  AND  Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_FULL}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log  NR "No X2 link available (7300)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1, as expected!  console=True
    ...  ELSE
    ...  Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Collect Keyword Result  ${reset_info}  timeout=${remained_MAX_WAIT_TIME}

    Log  Check NR and LTE state after reset NR BBMOD with SN ${BBMOD_sn}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  NR  BBMOD  ${NR_BBMOD_list}  ${BBMOD_state_enabled_check}  ${BBMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  Master
    Log  All NR BBMOD(s) status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  NR  RMOD  ${NR_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  Master
    Log  All NR RMOD(s) status as expected  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  Master
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Assert Every  NRCEL  ${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  alias=Master
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check cells availability status online  Master  ${remained_MAX_WAIT_TIME}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  LTE  RMOD  ${LTE_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  Slave
    Log  All LTE RMOD(s) status as expected  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  LTE  LNCEL  ${LTE_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  Slave
    Log  All LTE CELL(s) status as expected  console=True

    Log  Check NR and LTE alarms after reset NR BBMOD with SN ${BBMOD_sn}:  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE site - expected, ignored and critical alarms checked  console=True

    Get Current Date UTC info  cells_onair
    Get and check KPI5 info from IMS file  ${NR_BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}

    [Teardown]  Run Keyword If  ${BBMOD_reset_check}  Teardown Admin  alias=${new_alias}

Check peer alarms
    ${SLAVE_EXPECTED_ALARMS_10_1815_full}=  Prepare Expected Alarms List  ${SLAVE_EXPECTED_ALARMS_10_1815}  ${CPRI_RMOD_count}

    ${SLAVE_EXPECTED_ALARMS}=  Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master'  Set Variable  ${SLAVE_EXPECTED_ALARMS_10_1815_full}
    ...  ELSE  Create List
    ${SLAVE_IGNORED_ALARMS_full}=  Combine Lists  ${SLAVE_IGNORED_ALARMS}  ${SLAVE_IGNORED_ALARMS_DSS}

    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master' and ${CPRI_RMOD_count} > 0
    ...  Log  LTE "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, expected number: ${CPRI_RMOD_count}
    ...  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS}  ignored_alarms=${SLAVE_IGNORED_ALARMS_full}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}  poll_interval=10 sec
    Run Keyword If  '${BTS_PRIMARY_LINK}' == 'Master' and ${CPRI_RMOD_count} > 0
    ...  Log  LTE "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, found number: ${CPRI_RMOD_count}, as expected!
    ...  console=True

Get RMOD L3 Protocol
    [Arguments]  ${alias}
    Set Test Variable  ${RMOD_L3Protocol}  None
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    Set Test Variable  ${${alias}_RMOD_L3Protocol_dict}  ${RMOD_L3Protocol_dict}
    [Return]  ${${alias}_RMOD_L3Protocol_dict}

Get LTE NR RMOD Mapping Info
    [Arguments]  ${RMOD_list}
    ${LTE_NR_BBMOD_RMOD_list}=  Create List
    ${LTE_RMOD_ID_SN_dict}=  Create Dictionary
    ${NR_RMOD_SN_ID_dict}=  Create Dictionary
    Set Test Variable  ${LTE_RMOD_ID_SN_dict}
    Set Test Variable  ${NR_RMOD_SN_ID_dict}
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_SN}=  Get From Dictionary  ${NR_RMOD_SN_dict}  ${item}
        ${sharedRMOD}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${LTE_RMOD_SN_dict}  ${RMOD_SN}
        Continue For Loop If  not ${sharedRMOD}
        ${LTE_RMOD_id}=  Get From Dictionary  ${LTE_RMOD_SN_dict}  ${RMOD_SN}
        Append To List  ${LTE_NR_BBMOD_RMOD_list}  ${LTE_RMOD_id}
        Set To Dictionary  ${LTE_RMOD_ID_SN_dict}  ${LTE_RMOD_id}  ${RMOD_SN}
        Set To Dictionary  ${NR_RMOD_SN_ID_dict}  ${RMOD_SN}  ${item}
    END
    [Return]  ${LTE_NR_BBMOD_RMOD_list}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  ${BTS_item_class}  ${item}  ${BTS_item_state_check}  timeout=${timeout}  alias=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Get CELL Mapping By RMOD list
    [Arguments]   ${RMOD_list}  ${alias}
    ${CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${CELL_list}  @{RMOD_CELL_list}
    END
    ${CELL_list}=  Remove Duplicates  ${CELL_list}
    [Return]  ${CELL_list}

Get and check KPI5 info from IMS file
    [Documentation]
    ...  Get and check KPI5 info from IMS file.

    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}

    Log  Get and check KPI5 info from IMS file for iteration ${CYCLE}  console=True

    Run Keyword If  not ${NR_CELL_BBMOD_list}  Run Keywords
    ...  Log  KPI calculation and reporting will be skipped because BBMOD does not process any cells  console=True
    ...  AND  Return From Keyword

    ${kpi_name_delta_dict_kpi5}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi5  kpi_thresholds=${BBMOD_RESET_WRN_THR}  alias=Master  start_point_timestamp_UTC=${date_timestamp_bbmod_reset_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_cells_onair_UTC}
    ${kpi_delta_list_kpi5}=  Get From Dictionary  ${kpi_name_delta_dict_kpi5}  kpi5
    Export KPI Results to File  alias=Master  obj=BBMOD  obj_type=${BBMOD_prodName}_${BBMOD_sn}  obj_id=${BBMOD_id}  action_1=BBMOD_Reset
    ...  kpi_reported_1=KPI_5  event_value_1=${kpi_delta_list_kpi5[0]}  cycle=${CYCLE}  source_info=ims

Particular Teardown
    Export KPI Results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown