*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__BBMOD_LockUnlock_via_PLAN
Variables    tc_variables/sbts_sbts__state__bbmod_lockunlock_via_plan_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3    # Number of BBMOD Lock/Unlock operations on BTS, default value 3
${BTS_LIST}       ALL   # BTS list on which BBMOD Lock/Unlock operation will be performed. Possible values (by default ALL):
                        # - ALL: action will be performed on all BTS (Lock/Unlock BBMODs on each BTS until last BTS from TL)
                        # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS2)
                        # Leave default value for RFSplit
${BBMOD_SN_LIST}        # BBMOD type sn list for Lock/Unlock operation. Possible values (by default empty):
                        # - empty: action will be performed on all found BBMOD (found BBMOD Lock/Unlock on each BTS until last BTS from TL)
                        # - list of BBMOD SN for reset separated by comma labeled (ex. L1223402974, L1223402975)

*** Keywords ***
TC__SBTS_SBTS__STATE__BBMOD_LockUnlock_via_PLAN
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29966
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BBMOD lock/unlock via commissioning administrativestate operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get BBMOD list and cell info
    ...  - perform lock/unlock via commissioning administrativestate operations on each BBMOD checking BTS state and alarms
    ...  - check BTS reset behavior: reset number is 0
    ...  - check final BTS state and alarms
    ...  Pass criteria: BBMOD lock/unlock operations work as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29966 - TC Delivery
    ...

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get BBMOD list and cell info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform BBMOD Lock Unlock on all BTS via commissioning
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
        Step 8: Check all BTS reset behavior based on IMS info
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${all_BTS_BBMOD_check}=  Get all BTS BBMOD info

    Run Keyword If  not ${all_BTS_BBMOD_check}  Run Keywords
    ...  Log  TC Preconditions failed. No BBMOD found on any BTS. Test execution will be stopped!  level=ERROR
    ...  AND  Fail  TC Preconditions failed. No BBMOD found on any BTS. Test execution will be stopped!

    ${BBMOD_SN_LIST}=  Get BBMOD SN list
    Set Test Variable  ${BBMOD_SN_LIST}

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}

    ${alias_number}=  Get Length  ${BTS_alias_list}
    ${BTS_LIST}=  Set Variable If  ${alias_number} < 2 and '${BTS_LIST}' != 'ALL'
    ...  ALL  ${BTS_LIST}
    Set Test Variable  ${BTS_LIST}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  ====================================================  console=True
    Log  BTS label list selected for BBMOD Lock/Unlock operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for BBMOD Lock/Unlock operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    Set Test Variable  ${BBMOD_state_locked_check}  operationalState=${Enabled_}, administrativeState=${Locked_}
    Set Test Variable  ${BBMOD_state_locked}  operationalState=Enabled, administrativeState=Locked
    Set Test Variable  ${BBMOD_state_unlocked_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${BBMOD_state_unlocked}  operationalState=Enabled, administrativeState=Unlocked

    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}, availabilityStatus=${Dependency_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Dependency
    Set Test Variable  ${CELL_state_disabled_IOT_check}  operationalState=${Disabled_}, availabilityStatus=${Offline_}
   Set Test Variable   ${CELL_state_disabled_IOT}  operationalState=Disabled, availabilityStatus=Offline
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
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
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get BBMOD list and cell info
    [Documentation]
    ...  Get BBMOD list and cell info

    Log  Step ${index}: Get BBMOD list and cell info  console=True

    FOR  ${alias}  IN  @{alias_list}

        Get BBMOD id list  ${alias}

        Get BTS CELL list by RAT  ${alias}

        ${BBMOD_id_CELL_id_dict}  ${BBMOD_id_CELL_id_dict_scf_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  ${alias}
        Set Test Variable  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id_CELL_id_dict}

    END

    ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${BTS_DSS_LTE_NR_CELL_runtime_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_XP_localAlias_remoteAlias_dict}
    Set Test Variable  ${NRBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${LNBTS_DSS_alias_actLteNrDss_dict}
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_runtime_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_runtime_dict}

    ${NR_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm
    ${LTE_DSS_alarms_info}=  Create Long String  "EN DSS De-activated on partner side (6134)" or "EN DSS Keep Alive Procedure Time out (6132)" or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell (6129)" alarm

    Set Test Variable  ${NR_DSS_alarms_info}
    Set Test Variable  ${LTE_DSS_alarms_info}

Step ${index}: Perform BBMOD Lock Unlock on all BTS via commissioning
    Log  Step ${index}: Perform BBMOD Lock Unlock on all BTS via commissioning  console=True

    Get Current Date UTC info  start

    FOR  ${alias}  IN  @{BTS_alias_list}

        Perform BBMOD Lock Unlock on BTS via commissioning  ${alias}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS1: reset number is 0
    ...  - BTS2: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check all BTS reset behavior based on IMS info  console=True

    Get Current Date UTC info  end

    FOR  ${alias}  IN  @{alias_list}
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
        ...  remove_ims_file=False
    END

Get all BTS BBMOD info

    ${all_BTS_BBMOD_check}=  Set Variable  ${FALSE}

    FOR  ${alias}  IN  @{alias_list}

        ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
        Sort List  ${BBMOD_id_list}
        ${BBMOD_count}=  Get Length  ${BBMOD_id_list}

        ${all_BTS_BBMOD_check}=  Set Variable If  ${BBMOD_count} > 0  ${TRUE}  ${all_BTS_BBMOD_check}

        Set Test Variable  ${${alias}_BBMOD_id_list}  ${BBMOD_id_list}

    END

    [Return]  ${all_BTS_BBMOD_check}

Get BBMOD SN list
    ${BBMOD_SN_LIST_isEmpty}=  Set Variable If  '${BBMOD_SN_LIST}' == ''  ${TRUE}  ${FALSE}

    Return From Keyword If  ${BBMOD_SN_LIST_isEmpty}  @{EMPTY}

    ${BBMOD_SN_LIST_strip}=  Replace String  ${BBMOD_SN_LIST}  ${SPACE}  ${EMPTY}
    ${BBMOD_SN_LIST}=  Split String  ${BBMOD_SN_LIST_strip}  ,

    [Return]  ${BBMOD_SN_LIST}

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}
        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}
        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}
    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Get BBMOD id list
    [Documentation]
    ...  Get BBMOD id list

    [Arguments]  ${alias}
    ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
    Sort List  ${BBMOD_id_list}
    ${BBMOD_count}=  Get Length  ${BBMOD_id_list}
    Run Keyword If  ${BBMOD_count} > 0
    ...  Log  BTS ${alias} BBMOD found: ${BBMOD_id_list}  console=True
    ...  ELSE
    ...  Log  No BTS ${alias} BBMOD are present in runtime view configuration!  console=True

    Set Test Variable  ${${alias}_BBMOD_id_list}  ${BBMOD_id_list}
    Set Test Variable  ${${alias}_BBMOD_count}  ${BBMOD_count}

Get BTS CELL list by RAT
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=
    ...  Admin Get LTE HOST and IOT Cell(s) Id list  ${LTE_CELL_list}  alias=${alias}
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_dict}  ${LTE_cell_IOT_mapping_dict}
    Set Test Variable  ${${alias}_LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}
    Set Test Variable  ${${alias}_LTE_HOST_CELL_ID_LIST}  ${LTE_HOST_CELL_ID_LIST}

Perform BBMOD Lock Unlock on BTS via commissioning
    [Arguments]  ${alias}

    ${BBMOD_count}=  Get Length  ${${alias}_BBMOD_id_list}
    Run Keyword If  ${BBMOD_count} == 0  Run Keywords
    ...  Log  Test execution will be skipped on BTS ${alias} due to no configured BBMODs on it!  console=True
    ...  AND  Return From Keyword

    FOR  ${BBMOD_id}  IN  @{${alias}_BBMOD_id_list}

        ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${BBMOD_id}  connection=${alias}
        Set Test Variable  ${BBMOD_prodName}  ${BBMOD_param['productName']}
        Set Test Variable  ${BBMOD_sn}  ${BBMOD_param['serialNumber']}

        ${BBMOD_lock_unlock_check}=  Check BBMOD Lock Unlock validity
        Continue For Loop If  not ${BBMOD_lock_unlock_check}

        Lock BBMOD via commissioning  ${BBMOD_id}  ${alias}
        Unlock BBMOD via commissioning  ${BBMOD_id}  ${alias}

    END

Check BBMOD Lock Unlock validity
    ${BBMOD_lock_unlock_check}=  Set Variable  ${TRUE}

    ${BBMOD_SN_LIST_isEmpty}=  Run Keyword And Return Status  Should Be Empty  ${BBMOD_SN_LIST}

    Return From Keyword If  ${BBMOD_SN_LIST_isEmpty}  ${BBMOD_lock_unlock_check}

    FOR  ${item}  IN  @{BBMOD_SN_LIST}

        ${BBMOD_lock_unlock_check}=  Set Variable If  '${item}' in '${BBMOD_sn}'  ${TRUE}  ${FALSE}
        Exit For Loop If  '${item}' in '${BBMOD_sn}'

    END

    [Return]  ${BBMOD_lock_unlock_check}

Lock BBMOD via commissioning
    [Arguments]  ${BBMOD_id}  ${alias}

    Get BBMOD mapping cells info  ${BBMOD_id}  ${alias}

    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ${NRBTS_actLteNrDss}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    Run Keyword If  ${LNBTS_actLteNrDss} or ${NRBTS_actLteNrDss}  Get SBTS DSS alarms  ${alias}

    Log  Perform "Lock" operation from BTS ${alias} on BBMOD ${BBMOD_id} with SN ${BBMOD_sn}:  console=True


    ${BBMOD_SCF_DN}=  Get BBMOD SCF distinguished name  ${BBMOD_id}  ${alias}
    Perform Administrative State Recommissioning  obj_scf_dn=${BBMOD_SCF_DN}  administrativeState=Locked  alias=${alias}
    ...  timeout=60
    Sleep  5s

    Check BTS state and alarms after lock BBMOD  ${BBMOD_id}  ${alias}
    Check peer BTS state and alarms after lock BBMOD  ${alias}

Unlock BBMOD via commissioning
    [Arguments]  ${BBMOD_id}  ${alias}

    Log  Perform "Unlock" operation from BTS ${alias} on BBMOD ${BBMOD_id} with SN ${BBMOD_sn}:  console=True

    ${BBMOD_SCF_DN}=  Get BBMOD SCF distinguished name  ${BBMOD_id}  ${alias}
    Perform Administrative State Recommissioning  obj_scf_dn=${BBMOD_SCF_DN}  administrativeState=Unlocked  alias=${alias}
    ...  timeout=60
    Sleep  5s

    Check BTS state and alarms after unlock BBMOD  ${BBMOD_id}  ${alias}
    Check peer BTS state and alarms after unlock BBMOD  ${alias}

Get BBMOD mapping cells info
    [Arguments]  ${BBMOD_id}  ${alias}

    ${CELL_BBMOD_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}
    FOR  ${cell_id}  IN  @{CELL_BBMOD_list}
        ${cell_IOT_id}=  Run Keyword If  '${cell_id}' in ${${alias}_LTE_HOST_CELL_ID_LIST}
        ...  Get From Dictionary  ${${alias}_LTE_cell_IOT_dict}  ${cell_id}
        ...  ELSE  Set Variable  None
        Run Keyword If  '${cell_IOT_id}' != 'None'  Append To List  ${CELL_BBMOD_list}  ${cell_IOT_id}
    END

    ${NR_CELL_BBMOD_list}=  Create List
    ${LTE_CELL_BBMOD_list}=  Create List
    ${WCDMA_CELL_BBMOD_list}=  Create List
    ${GSM_CELL_BBMOD_list}=  Create List
    ${NR_CELL_not_BBMOD_list}=  Create List
    ${LTE_CELL_not_BBMOD_list}=  Create List
    ${WCDMA_CELL_not_BBMOD_list}=  Create List
    ${GSM_CELL_not_BBMOD_list}=  Create List

    FOR  ${item}  IN  @{${alias}_CELL_list}
        Run Keyword If  '${item}' in ${CELL_BBMOD_list} and '${item}' in ${${alias}_NR_CELL_list}
        ...  Append To List  ${NR_CELL_BBMOD_list}  ${item}
        ...  ELSE IF  '${item}' not in ${CELL_BBMOD_list} and '${item}' in ${${alias}_NR_CELL_list}
        ...  Append To List  ${NR_CELL_not_BBMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_BBMOD_list} and '${item}' in ${${alias}_LTE_CELL_list}
        ...  Append To List  ${LTE_CELL_BBMOD_list}  ${item}
        ...  ELSE IF  '${item}' not in ${CELL_BBMOD_list} and '${item}' in ${${alias}_LTE_CELL_list}
        ...  Append To List  ${LTE_CELL_not_BBMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_BBMOD_list} and '${item}' in ${${alias}_WCDMA_CELL_list}
        ...  Append To List  ${WCDMA_CELL_BBMOD_list}  ${item}
        ...  ELSE IF  '${item}' not in ${CELL_BBMOD_list} and '${item}' in ${${alias}_WCDMA_CELL_list}
        ...  Append To List  ${WCDMA_CELL_not_BBMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_BBMOD_list} and '${item}' in ${${alias}_GSM_CELL_list}
        ...  Append To List  ${GSM_CELL_BBMOD_list}  ${item}
        ...  ELSE IF  '${item}' not in ${CELL_BBMOD_list} and '${item}' in ${${alias}_GSM_CELL_list}
        ...  Append To List  ${GSM_CELL_not_BBMOD_list}  ${item}
    END

    Sort List  ${NR_CELL_BBMOD_list}
    Sort List  ${LTE_CELL_BBMOD_list}
    Sort List  ${WCDMA_CELL_BBMOD_list}
    Sort List  ${GSM_CELL_BBMOD_list}
    Sort List  ${NR_CELL_not_BBMOD_list}
    Sort List  ${LTE_CELL_not_BBMOD_list}
    Sort List  ${WCDMA_CELL_not_BBMOD_list}
    Sort List  ${GSM_CELL_not_BBMOD_list}
    Set Test Variable  ${${alias}_NR_CELL_BBMOD_list}  ${NR_CELL_BBMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_BBMOD_list}  ${LTE_CELL_BBMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_BBMOD_list}  ${WCDMA_CELL_BBMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_BBMOD_list}  ${GSM_CELL_BBMOD_list}
    Set Test Variable  ${${alias}_NR_CELL_not_BBMOD_list}  ${NR_CELL_not_BBMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_BBMOD_list}  ${LTE_CELL_not_BBMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_BBMOD_list}  ${WCDMA_CELL_not_BBMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_BBMOD_list}  ${GSM_CELL_not_BBMOD_list}

    Log  BTS ${alias} cells mapped on BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_BBMOD_list}  Log  - NRCEL: ${${alias}_NR_CELL_BBMOD_list}  console=True
    Run Keyword If  ${${alias}_LTE_CELL_BBMOD_list}  Log  - LNCEL: ${${alias}_LTE_CELL_BBMOD_list}  console=True
    Run Keyword If  ${${alias}_WCDMA_CELL_BBMOD_list}  Log  - WNCEL: ${${alias}_WCDMA_CELL_BBMOD_list}  console=True
    Run Keyword If  ${${alias}_GSM_CELL_BBMOD_list}  Log  - GNCEL: ${${alias}_GSM_CELL_BBMOD_list}  console=True

    Log  BTS ${alias} cells not mapped on BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_not_BBMOD_list}  Log  - NRCEL: ${${alias}_NR_CELL_not_BBMOD_list}  console=True
    Run Keyword If  ${${alias}_LTE_CELL_not_BBMOD_list}  Log  - LNCEL: ${${alias}_LTE_CELL_not_BBMOD_list}  console=True
    Run Keyword If  ${${alias}_WCDMA_CELL_not_BBMOD_list}  Log  - WNCEL: ${${alias}_WCDMA_CELL_not_BBMOD_list}  console=True
    Run Keyword If  ${${alias}_GSM_CELL_not_BBMOD_list}  Log  - GNCEL: ${${alias}_GSM_CELL_not_BBMOD_list}  console=True

Get SBTS DSS alarms
    [Arguments]  ${alias}
    ${DSS_alias}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    Set Test Variable  ${DSS_alias}

    ${NR_DSS_impacted_cells}=  Create List
    ${LTE_DSS_impacted_cells}=  Create List
    FOR  ${item}  IN  @{${alias}_NR_CELL_BBMOD_list}
        ${NR_LTE_DSS_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_runtime_dict}  ${alias}
        ${NRCEL_DSS_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${NR_LTE_DSS_dict}  ${item}
        ${LTE_DSS_pair_cell}=  Run Keyword If  ${NRCEL_DSS_status}  Get From Dictionary  ${NR_LTE_DSS_dict}  ${item}
        ...  ELSE  Set Variable  None
        Run Keyword If  '${LTE_DSS_pair_cell}' != 'None' and '${alias}' in @{DSS_alias}
        ...  Run Keyword If  '${LTE_DSS_pair_cell}' not in ${${alias}_LTE_CELL_BBMOD_list}
        ...  Append To List  ${LTE_DSS_impacted_cells}  ${LTE_DSS_pair_cell}
        Run Keyword If  '${LTE_DSS_pair_cell}' != 'None' and '${alias}' not in @{DSS_alias}
        ...  Append To List  ${LTE_DSS_impacted_cells}  ${LTE_DSS_pair_cell}
    END

    FOR  ${item}  IN  @{${alias}_LTE_CELL_BBMOD_list}
        ${LTE_NR_DSS_dict}=  Get From Dictionary  ${BTS_DSS_LTE_NR_CELL_runtime_dict}  ${alias}
        ${LNCEL_DSS_status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${LTE_NR_DSS_dict}  ${item}
        ${NR_DSS_pair_cell}=  Run Keyword If  ${LNCEL_DSS_status}  Get From Dictionary  ${LTE_NR_DSS_dict}  ${item}
        ...  ELSE  Set Variable  None
        Run Keyword If  '${NR_DSS_pair_cell}' != 'None' and '${alias}' in @{DSS_alias}
        ...  Run Keyword If  '${NR_DSS_pair_cell}' not in ${${alias}_NR_CELL_BBMOD_list}
        ...  Append To List  ${NR_DSS_impacted_cells}  ${NR_DSS_pair_cell}
        Run Keyword If  '${NR_DSS_pair_cell}' != 'None' and '${alias}' not in @{DSS_alias}
        ...  Append To List  ${NR_DSS_impacted_cells}  ${NR_DSS_pair_cell}
    END

    ${NR_DSS_alarms_count}=  Get Length  ${NR_DSS_impacted_cells}
    ${LTE_DSS_alarms_count}=  Get Length  ${LTE_DSS_impacted_cells}

    Set Test Variable  ${NR_DSS_alarms_count}
    Set Test Variable  ${LTE_DSS_alarms_count}

    ${NR_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_NR_DSS}  ${NR_DSS_alarms_count}
    ${LTE_DSS_EXPECTED_ALARMS_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_LTE_DSS}  ${LTE_DSS_alarms_count}

    ${BTS_EXPECTED_ALARMS_DSS}=  Combine Lists  ${NR_DSS_EXPECTED_ALARMS_full}  ${LTE_DSS_EXPECTED_ALARMS_full}
    Set Test Variable  ${BTS_EXPECTED_ALARMS_DSS}

Check BTS state and alarms after lock BBMOD
    [Arguments]    ${BBMOD_id}  ${alias}

    Log  Check BTS ${alias} state and alarms after "Lock" operation on BBMOD with SN ${BBMOD_sn} from BTS ${alias}:  console=True

    Log  Check BTS ${alias} BBMOD with SN ${BBMOD_sn} status:
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_locked_check}  timeout=30  connection=${alias}
    Log  BTS ${alias} BBMOD with SN ${BBMOD_sn} status:\n - ${BBMOD_state_locked}  console=True

    Log  Check BTS ${alias} cell(s) state not mapped on BBMOD with SN ${BBMOD_sn}:  console=True
    Check BTS cell state not mapped on BBMOD  ${alias}

    Log  Check BTS ${alias} cell(s) state mapped on BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_BBMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_BBMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_BBMOD_list}
    ...  Check BBMOD LTE HOST and IOT cells  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_BBMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_BBMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_BBMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_BBMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  30  ${alias}

    Check BTS alarms after lock BBMOD  ${alias}

Check peer BTS state and alarms after lock BBMOD
    [Arguments]    ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} state and alarms after "Lock" operation on BBMOD with SN ${BBMOD_sn} from BTS ${alias}:  console=True

        Run Keyword If  ${${other_alias}_BBMOD_count} > 0  Run Keywords
        ...  Assert Every  class_name=BBMOD  parameters=${BBMOD_state_unlocked_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All BTS ${other_alias} BBMOD status:\n - ${BBMOD_state_unlocked}  console=True

        Run Keyword If  ${${other_alias}_BBMOD_count} > 0  Run Keywords
        ...  Assert Every  class_name=BBMOD  parameters=${BBMOD_state_unlocked_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All BTS ${other_alias} BBMOD status:\n - ${BBMOD_state_unlocked}  console=True
        Run Keyword If  ${${other_alias}_NR_CELL_list}  Run Keywords
        ...  Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All NR ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Run Keyword If  ${${other_alias}_LTE_CELL_list}  Run Keywords
        ...  Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All LTE ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Run Keyword If  ${${other_alias}_WCDMA_CELL_list}  Run Keywords
        ...  Assert Every  class_name=WNCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All WCDMA ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Run Keyword If  ${${other_alias}_GSM_CELL_list}  Run Keywords
        ...  Assert Every  class_name=GNCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All GSM ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Check BTS alarms after lock BBMOD  ${other_alias}
    END

Check BTS state and alarms after unlock BBMOD
    [Arguments]    ${BBMOD_id}  ${alias}

    Log  Check BTS ${alias} state and alarms after "Unlock" operation on BBMOD with SN ${BBMOD_sn} from BTS ${alias}:  console=True

    Log  Check BTS ${alias} BBMOD with SN ${BBMOD_sn} status:
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_unlocked_check}  timeout=30  connection=${alias}
    Log  BTS ${alias} BBMOD with SN ${BBMOD_sn} status:\n - ${BBMOD_state_unlocked}  console=True

    Log  Check BTS ${alias} cell(s) state not mapped on BBMOD with SN ${BBMOD_sn}:  console=True
    Check BTS cell state not mapped on BBMOD  ${alias}

    Log  Check BTS ${alias} cell(s) state mapped on BBMOD with SN ${BBMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_BBMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  360  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_BBMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  360  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_BBMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  360  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_BBMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  360  ${alias}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check peer BTS state and alarms after unlock BBMOD
    [Arguments]    ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'

        Log  Check BTS ${other_alias} state and alarms after "Unlock" operation on BBMOD with SN ${BBMOD_sn} from BTS ${alias}:  console=True

        Run Keyword If  ${${other_alias}_BBMOD_count} > 0  Run Keywords
        ...  Assert Every  class_name=BBMOD  parameters=${BBMOD_state_unlocked_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All BTS ${other_alias} BBMOD status:\n - ${BBMOD_state_unlocked}  console=True

        Run Keyword If  ${${other_alias}_BBMOD_count} > 0  Run Keywords
        ...  Assert Every  class_name=BBMOD  parameters=${BBMOD_state_unlocked_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All BTS ${other_alias} BBMOD status:\n - ${BBMOD_state_unlocked}  console=True
        Run Keyword If  ${${other_alias}_NR_CELL_list}  Run Keywords
        ...  Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All NR ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Run Keyword If  ${${other_alias}_LTE_CELL_list}  Run Keywords
        ...  Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All LTE ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Run Keyword If  ${${other_alias}_WCDMA_CELL_list}  Run Keywords
        ...  Assert Every  class_name=WNCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All WCDMA ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
        Run Keyword If  ${${other_alias}_GSM_CELL_list}  Run Keywords
        ...  Assert Every  class_name=GNCEL  parameters=${CELL_state_enabled_check}  timeout=5  connection=${other_alias}
        ...  AND  Log  All GSM ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}
        Log  SBTS ${other_alias} site - expected, ignored and critical alarms checked  console=True
    END

Check BTS cell state not mapped on BBMOD
    [Arguments]   ${alias}

    Run Keyword If  ${${alias}_NR_CELL_not_BBMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_BBMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_BBMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_BBMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}

Check BTS alarms after lock BBMOD
    [Arguments]    ${alias}

    ${LNBTS_actLteNrDss}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ${NRBTS_actLteNrDss}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    Log  Check BTS ${alias} alarms:  console=True

    Run Keyword If   ${NRBTS_actLteNrDss}
    ...  Run Keyword If  ${NR_DSS_alarms_count} > 0 and '${alias}' in @{DSS_alias}
    ...  Log  BTS ${alias} ${NR_DSS_alarms_info}, expected number: ${NR_DSS_alarms_count}  console=True
    Run Keyword If  ${LNBTS_actLteNrDss}
    ...  Run Keyword If  ${LTE_DSS_alarms_count} > 0 and '${alias}' in @{DSS_alias}
    ...  Log  BTS ${alias} ${LTE_DSS_alarms_info}, expected number: ${LTE_DSS_alarms_count}  console=True

    ${BTS_EXPECTED_ALARMS}=  Create List
    ${BTS_EXPECTED_ALARMS}=   Run Keyword If  (${LNBTS_actLteNrDss} or ${NRBTS_actLteNrDss})
    ...  Set Variable If  '${alias}' in @{DSS_alias}  ${BTS_EXPECTED_ALARMS_DSS}  ${BTS_EXPECTED_ALARMS}
    ...  ELSE  Set Variable  ${BTS_EXPECTED_ALARMS}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${BTS_EXPECTED_ALARMS}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If   ${NRBTS_actLteNrDss}
    ...  Run Keyword If  ${NR_DSS_alarms_count} > 0 and '${alias}' in @{DSS_alias}
    ...  Log  BTS ${alias} ${NR_DSS_alarms_info}, found number: ${NR_DSS_alarms_count}, as expected!  console=True
    Run Keyword If  ${LNBTS_actLteNrDss}
    ...  Run Keyword If  ${LTE_DSS_alarms_count} > 0 and '${alias}' in @{DSS_alias}
    ...  Log  BTS ${alias} ${LTE_DSS_alarms_info}, found number: ${LTE_DSS_alarms_count}, as expected!  console=True

    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}

    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check BBMOD LTE HOST and IOT cells
    [Arguments]  ${alias}

    FOR  ${item}  IN  @{${alias}_LTE_CELL_BBMOD_list}
        Run Keyword If  '${item}' in ${${alias}_LTE_IOT_CELL_ID_LIST}  Run Keywords
        ...  Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_disabled_IOT_check}  timeout=30  connection=${alias}
        ...  AND  Log  LNCEL ${item} status:\n - ${CELL_state_disabled_IOT}  console=True
        ...  ELSE  Run Keywords
        ...  Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_disabled_check}  timeout=30  connection=${alias}
        ...  AND  Log  LNCEL ${item} status:\n - ${CELL_state_disabled}  console=True
    END

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Admin Check If BTS Objects Are Unlocked  class_name=BBMOD  timeout=60  recover_timeout=60  connection=${alias}
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
