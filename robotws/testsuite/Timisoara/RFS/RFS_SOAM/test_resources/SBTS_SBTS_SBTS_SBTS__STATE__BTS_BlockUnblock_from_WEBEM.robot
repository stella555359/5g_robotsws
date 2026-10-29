*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
Variables    tc_variables/sbts_sbts_sbts_sbts__state__bts_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}      3    # Number of BTS block/unblock operations, default value 3
${BTS_LIST}            ALL  # BTS list on which block/unblock operation will be performed. Possible values (by default ALL):
                            # - ALL: action will be performed on all BTS (block/unblock each BTS until last BTS from TL)
                            # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py)
${BTS1_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS1; default value: in accordance with KPI1a
                            # specifications
${BTS2_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS2; default value: in accordance with KPI1a
                            # specifications
${BTS3_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS3; default value: in accordance with KPI1a
                            # specifications
${BTS4_RESET_WRN_THR}  600  # Time (secs) spent between first cell down to last cell up on BTS4; default value: in accordance with KPI1a
                            # specifications
${BTS_MAX_WAIT_TIME}   900  # Maximum time to wait for BTS OnAir after unblock (due to reset)

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23738
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for BTS block/unblock, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info
    ...  - perform BTS block/unblock operations checking alarms and state
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: BTS block/unblock operation works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 19.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23738 -
    ...  [5G][CB007588]SBTS_SBTS_SBTS_Startup_4G_BTS_Block_from_WEBEM_5G_primaryLink_ASOE
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23834 - [5G] Common part fails for SBTS_SBTS_SBTS configuration
    ...  - 28.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24040 -
    ...  [5G] KPI1a measurement +TC verdict for SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    ...  - 12.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24336 -
    ...  [5G] Update KW 'Get and check BTS RESET info from IMS file' and 4 TCs
    ...  - 13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24683 - [5G] Ignore alarm FID7107, AID7114 from SBTS_SBTS_SBTS tests
    ...  - 02.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25784 - [5G][CB007437] Adapt SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    ...  to CB007437
    ...  - 11.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26222 - [5G] FID 4401 should be ignored in test
    ...  SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 16.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26626 - [5G][CB009182-C002270-RP003030]new
    ...  NR_SBTS__STATE__BTS_BlockUnblock_from_WEBEM TC which will run SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM In case of
    ...  SBTS-NR configuration
    ...  - 18.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27212 -
    ...  [5G][DSS alarms]Add wait_for_alarm_clear because DSS alarms are not cleared in current timer - 4xSBTS
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
    ...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28311 - Link 3 x SBTS Block Unblock to 4 x SBTS Block Unblock
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23738_SBTS_SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-adrian.ierulescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS23R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform BTS Block Unblock for iteration ${CYCLE}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list
    Log  ====================================================  console=True
    Log  BTS label list selected for block/unblock operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for block/unblock operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

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
    ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS info
    [Documentation]
    ...  Get all BTS info

    Log  Step ${index}: Get all BTS info  console=True
    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${RM_sn_bts-alias_dict}
    Set Test Variable  ${shared_RM_sn_list}

    FOR  ${alias}  IN  @{alias_list}
        Get BTS CELL list by RAT  ${alias}
        ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
        Set Test Variable  ${${alias}_RM_L3Protocol_dict}  ${RM_L3Protocol_dict}
        Check if DSS is configured  ${alias}

        ${BTS_RM_alias_connection_dict}  ${BTS_shared_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}  ${BTS_shared_RM_sn_id_dict}
        ...  ${BTS_dedicated_RM_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  RMOD  ${alias}

        ${BTS_FHS_alias_connection_dict}  ${BTS_shared_FHS_id_sn_dict}  ${BTS_dedicated_FHS_id_sn_dict}  ${BTS_shared_FHS_sn_id_dict}
        ...  ${BTS_dedicated_FHS_sn_id_dict}=  Admin Get shared and dedicated module info for BTS  FHS  ${alias}

        Set Test Variable  ${${alias}_RM_alias_connection_dict}  ${BTS_RM_alias_connection_dict}
        Set Test Variable  ${${alias}_shared_RM_id_sn_dict}  ${BTS_shared_RM_id_sn_dict}
        Set Test Variable  ${${alias}_dedicated_RM_id_sn_dict}  ${BTS_dedicated_RM_id_sn_dict}
        Set Test Variable  ${${alias}_shared_RM_sn_id_dict}  ${BTS_shared_RM_sn_id_dict}
        Set Test Variable  ${${alias}_dedicated_RM_sn_id_dict}  ${BTS_dedicated_RM_sn_id_dict}

        Set Test Variable  ${${alias}_FHS_alias_connection_dict}  ${BTS_FHS_alias_connection_dict}
        Set Test Variable  ${${alias}_shared_FHS_id_sn_dict}  ${BTS_shared_FHS_id_sn_dict}
        Set Test Variable  ${${alias}_dedicated_FHS_id_sn_dict}  ${BTS_dedicated_FHS_id_sn_dict}
        Set Test Variable  ${${alias}_shared_FHS_sn_id_dict}  ${BTS_shared_FHS_sn_id_dict}
        Set Test Variable  ${${alias}_dedicated_FHS_sn_id_dict}  ${BTS_dedicated_FHS_sn_id_dict}
    END

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Get shared RM info  ${RM_sn}  ${RM_bts-alias_list}
    END

Step ${index}: Perform BTS Block Unblock for iteration ${CYCLE}
    [Documentation]
    ...  Perform BTS Block Unblock

    Log  Step ${index}: Perform BTS Block Unblock for iteration ${CYCLE}  console=True
    Set Test Variable  ${CYCLE}
    FOR  ${alias}  IN  @{BTS_alias_list}
        ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${label}
        Log  Perform ${label} Block Unblock   console=True
        Get PL shared RM impact on other BTS  ${alias}
        Get RESET timestamp info  start
        Perform BTS Block  ${alias}
        Perform BTS Unblock  ${alias}
        Get RESET timestamp info  end
        Check all BTS reset behavior based on IMS info  ${alias}
        Get and check KPI1a info from IMS file  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS list
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

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}

Get shared RM info
    [Arguments]   ${RM_sn}  ${RM_bts-alias_list}
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${NR_RM_CELL_dict}=  Create Dictionary
        ${LTE_RM_CELL_dict}=  Create Dictionary
        ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}=
        ...  Get shared RM all cells from specific RAT  ${RM_id}  ${alias}
        Set To Dictionary  ${NR_RM_CELL_dict}  ${RM_id}  ${NR_CELL_RM_list}
        Set To Dictionary  ${LTE_RM_CELL_dict}  ${RM_id}  ${LTE_CELL_RM_list}
        Set Test Variable  ${${alias}_NR_${RM_id}_CELL_dict}  ${NR_RM_CELL_dict}
        Set Test Variable  ${${alias}_LTE_${RM_id}_CELL_dict}  ${LTE_RM_CELL_dict}
    END

Get shared RM all cells from specific RAT
    [Arguments]  ${RM_id}  ${alias}
    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{${alias}_CELL_list}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_NR_CELL_list}  Append To List  ${NR_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_LTE_CELL_list}  Append To List  ${LTE_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_GSM_CELL_list}  Append To List  ${GSM_CELL_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_RM_list}
    Sort List  ${LTE_CELL_RM_list}
    Sort List  ${WCDMA_CELL_RM_list}
    Sort List  ${GSM_CELL_RM_list}

    [Return]  ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}

Check if DSS is configured
    [Arguments]  ${alias}

    Log  Check if DSS is configured on BTS ${alias}  console=True
     ${all_BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${all_BTS_DSS_NR_LTE_CELL_dict}  ${all_BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${all_BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${all_BTS_DSS_LTE_NR_CELL_dict}

    ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
    ${BTS_DSS_peer}=  Get From Dictionary  ${all_BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    Set Test Variable  ${${alias}_BTS_DSS_peer}  ${BTS_DSS_peer}

    Run Keyword If  not ${BTS_DSS_configured}  Run Keywords
    ...  Set Test Variable  ${${alias}_DSS_configured}  ${BTS_DSS_configured}
    ...  AND  Return From Keyword

    ${BTS_DSS_peer_status}=  Run Keyword And Return Status  Should Not Be Empty  ${BTS_DSS_peer}
    Run Keyword If  not ${BTS_DSS_peer_status}  Run Keywords
    ...  Set Test Variable  ${${alias}_DSS_configured}  False
    ...  AND  Return From Keyword

    FOR  ${other_alias}  IN  @{BTS_DSS_peer}
        ${other_BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${other_alias}
        ${other_BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${other_alias}

        ${other_BTS_DSS_configured}=  Set Variable If
        ...  '${other_BTS_actLteNrDss_NR}' == 'True' or '${other_BTS_actLteNrDss_LTE}' == 'True'  True  False
        Run Keyword If  not ${other_BTS_DSS_configured}  Run Keywords
        ...  Set Test Variable  ${${alias}_DSS_configured}  ${other_BTS_DSS_configured}
        ...  AND  Return From Keyword
    END

    Set Test Variable  ${${alias}_DSS_configured}  True
    Run Keyword If  ${${alias}_DSS_configured}
    ...  Log  DSS is configured between BTS ${alias} and ${${alias}_BTS_DSS_peer}. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured on BTS ${alias}. DSS alarms check will be skipped!  console=True

Get PL shared RM impact on other BTS
    [Arguments]  ${alias}

    Log  Get PL shared RM impact on other BTS  console=True
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}
    ${BTS_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_sn_list
    ${BTS_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_sn_list
    ${BTS_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_sn_list

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'

        ${other_BTS_RMOD_OBSAI_FHS_impacted_sn_list}  ${other_BTS_RMOD_CPRI_FHS_impacted_sn_list}  ${other_BTS_RMOD_ECPRI_FHS_impacted_sn_list}
        ...  ${other_BTS_shared_FHS_impacted_count}=  Get shared FHS impact  ${alias}  ${other_alias}

        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        ${other_BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${other_alias}
        ${other_BTS_non_PL_CPRI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_sn_list
        ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_sn_list
        ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}=  Get From Dictionary  ${other_BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_sn_list

        ${other_BTS_CPRI_shared_alarm_count}  ${other_BTS_CPRI_dedicated_alarm_count}=
        ...  Calculate other BTS alarms count  ${BTS_PL_CPRI_shared_RM_sn_list}  ${other_BTS_non_PL_CPRI_shared_RM_sn_list}
        ...  ${other_BTS_RMOD_CPRI_FHS_impacted_sn_list}  ${other_alias}
        ${other_BTS_ECPRI_shared_alarm_count}  ${other_BTS_ECPRI_dedicated_alarm_count}=
        ...  Calculate other BTS alarms count  ${BTS_PL_ECPRI_shared_RM_sn_list}  ${other_BTS_non_PL_ECPRI_shared_RM_sn_list}
        ...  ${other_BTS_RMOD_ECPRI_FHS_impacted_sn_list}  ${other_alias}
        ${other_BTS_OBSAI_shared_alarm_count}  ${other_BTS_OBSAI_dedicated_alarm_count}=
        ...  Calculate other BTS alarms count  ${BTS_PL_OBSAI_shared_RM_sn_list}  ${other_BTS_non_PL_OBSAI_shared_RM_sn_list}
        ...  ${other_BTS_RMOD_OBSAI_FHS_impacted_sn_list}  ${other_alias}

        Log  ${other_label} impacted CPRI shared RM count: ${other_BTS_CPRI_shared_alarm_count}   console=True
        Log  ${other_label} impacted ECPRI shared RM count: ${other_BTS_ECPRI_shared_alarm_count}   console=True
        Log  ${other_label} impacted OBSAI shared RM count: ${other_BTS_OBSAI_shared_alarm_count}   console=True
        Log  ${other_label} impacted shared FHS count: ${other_BTS_shared_FHS_impacted_count}   console=True

        ${FID10_alarm_count}=  Evaluate
        ...  ${other_BTS_OBSAI_shared_alarm_count} + ${other_BTS_shared_FHS_impacted_count} + ${other_BTS_OBSAI_dedicated_alarm_count}
        ${FID10_1815_alarm_count}=  Evaluate  ${other_BTS_CPRI_shared_alarm_count} + ${other_BTS_CPRI_dedicated_alarm_count}
        ${FID16_alarm_count}=  Evaluate  ${other_BTS_ECPRI_shared_alarm_count} + ${other_BTS_ECPRI_dedicated_alarm_count}
        Set Test Variable  ${${other_alias}_FID10_alarm_count}  ${FID10_alarm_count}
        Set Test Variable  ${${other_alias}_FID10_1815_alarm_count}  ${FID10_1815_alarm_count}
        Set Test Variable  ${${other_alias}_FID16_alarm_count}  ${FID16_alarm_count}

        ${EXPECTED_ALARMS}=  Create List
        ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_10}
        ...  ${FID10_alarm_count}
        ${EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_10_1815}
        ...  ${FID10_1815_alarm_count}
        ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_16}  ${FID16_alarm_count}
        ${EXPECTED_ALARMS_10_1815_16_full}=  Combine Lists  ${EXPECTED_ALARMS_10_full}  ${EXPECTED_ALARMS_10_1815_full}
        ...  ${EXPECTED_ALARMS_16_full}
        ${EXPECTED_ALARMS_full}=  Set Variable If  ${FID10_alarm_count} == 0 and ${FID10_1815_alarm_count} == 0 and ${FID16_alarm_count} == 0
        ...  ${EXPECTED_ALARMS}  ${EXPECTED_ALARMS_10_1815_16_full}
        Set Test Variable  ${${other_alias}_EXPECTED_ALARMS_full}   ${EXPECTED_ALARMS_full}
    END

Get shared FHS impact
    [Arguments]  ${alias}  ${other_alias}

    ${BTS_shared_FHS_PL_list}=  Check shared FHS PL  ${alias}

    ${peer_shared_FHS_impacted_id_list}  ${peer_shared_FHS_impacted_sn_list}=  Get peer BTS shared module impact
    ...  ${BTS_shared_FHS_PL_list}  ${alias}  ${other_alias}

    ${peer_shared_FHS_impacted_count}=  Get Length  ${peer_shared_FHS_impacted_id_list}

    ${peer_RMOD_CPRI_impacted_sn_list}=  Create List
    ${peer_RMOD_OBSAI_impacted_sn_list}=  Create List
    ${peer_RMOD_ECPRI_impacted_sn_list}=  Create List

    ${peer_RMOD_OBSAI_impacted_sn_list}  ${peer_RMOD_CPRI_impacted_sn_list}  ${peer_RMOD_ECPRI_impacted_sn_list}=  Get RMODs connected to FHS list
    ...  ${peer_shared_FHS_impacted_id_list}  ${other_alias}

    [Return]  ${peer_RMOD_OBSAI_impacted_sn_list}  ${peer_RMOD_CPRI_impacted_sn_list}  ${peer_RMOD_ECPRI_impacted_sn_list}
    ...  ${peer_shared_FHS_impacted_count}

Check shared FHS PL
    [Arguments]  ${alias}

    ${BBMOD_list}=  Get Ids For All  BBMOD  alias=${alias}
    ${BBMOD_PL_FHS_RM_dict}=  Get PL info for RMOD FHS on all BBMOD  ${alias}

    ${BTS_FHS_PL_list}=  Create List
    ${BTS_shared_FHS_PL_list}=  Create List

    FOR  ${BBMOD_id}  IN  @{BBMOD_list}
        ${BBMOD_PL_info}=  Get From Dictionary  ${BBMOD_PL_FHS_RM_dict}  ${BBMOD_id}
        ${BBMOD_PL_FHS_list}=  Get From Dictionary  ${BBMOD_PL_info}  BBMOD_PL_FHS_list
        ${BTS_FHS_PL_list}=  Combine Lists  ${BTS_FHS_PL_list}  ${BBMOD_PL_FHS_list}
    END

    ${BTS_shared_FHS_id_list}=  Get Dictionary Keys  ${${alias}_shared_FHS_id_sn_dict}

    FOR  ${FHS_id}  IN  @{BTS_FHS_PL_list}
        Run Keyword If  '${FHS_id}' in ${BTS_shared_FHS_id_list}
        ...  Append To List  ${BTS_shared_FHS_PL_list}  ${FHS_id}
    END

    [Return]  ${BTS_shared_FHS_PL_list}

Get peer BTS shared module impact
    [Arguments]  ${BTS_shared_FHS_id_list}  ${BTS}  ${other_BTS}

    ${peer_BTS_FHS_impacted_id_list}=  Create List
    ${peer_BTS_FHS_impacted_sn_list}=  Create List

    FOR  ${module_id}  IN  @{BTS_shared_FHS_id_list}
        ${module_sn}=  Get From Dictionary  ${${BTS}_shared_FHS_id_sn_dict}  ${module_id}
        ${module_shared_BTS_list}=  Get From Dictionary  ${${BTS}_FHS_alias_connection_dict}  ${module_sn}
        Run Keyword If  '${other_BTS}' in ${module_shared_BTS_list}
        ...  Append To List  ${peer_BTS_FHS_impacted_sn_list}  ${module_sn}
    END

    FOR  ${module_sn}  IN  @{peer_BTS_FHS_impacted_sn_list}
        ${peer_module_id}=  Get From Dictionary  ${${other_BTS}_shared_FHS_sn_id_dict}  ${module_sn}
        Append To List  ${peer_BTS_FHS_impacted_id_list}  ${peer_module_id}
    END

    [Return]  ${peer_BTS_FHS_impacted_id_list}  ${peer_BTS_FHS_impacted_sn_list}

Get RMODs connected to FHS list
    [Arguments]  ${FHS_list}  ${alias}
    ${RMOD_id_list}=  Get RMOD Mapping on FHS list  ${FHS_list}  ${alias}
    ${RMOD_CPRI_sn_list}=  Create List
    ${RMOD_OBSAI_sn_list}=  Create List
    ${RMOD_ECPRI_sn_list}=  Create List
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${RMOD_sn}=  Get From Dictionary  ${${alias}_shared_RM_id_sn_dict}  ${RMOD_id}
        ${RM_L3Protocol}=  Get From Dictionary  ${${alias}_RM_L3Protocol_dict}  ${RMOD_id}
        Run Keyword If  '${RM_L3Protocol}' == 'RP301_RP1'
        ...  Append To List  ${RMOD_OBSAI_sn_list}  ${RMOD_sn}
        Run Keyword If  '${RM_L3Protocol}' == 'CPRI_RP1'
        ...  Append To List  ${RMOD_CPRI_sn_list}  ${RMOD_sn}
        Run Keyword If  '${RM_L3Protocol}' == 'ECPRI_MPLANE'
        ...  Append To List  ${RMOD_ECPRI_sn_list}  ${RMOD_sn}
    END

    [Return]  ${RMOD_OBSAI_sn_list}  ${RMOD_CPRI_sn_list}  ${RMOD_ECPRI_sn_list}

Calculate other BTS alarms count
    [Arguments]  ${BTS_PL_shared_RM_sn_list}  ${other_BTS_non_PL_shared_RM_sn_list}  ${other_BTS_RMOD_impacted_sn_list}  ${other_BTS}
    ${other_BTS_shared_alarm_count}=  Set Variable  0
    ${other_BTS_dedicated_alarm_count}=  Set Variable  0

    ${other_BTS_shared_RMOD_sn}=  Get Dictionary Keys  ${${other_BTS}_shared_RM_sn_id_dict}
    ${other_BTS_dedicated_RMOD_sn}=  Get Dictionary Keys  ${${other_BTS}_dedicated_RM_sn_id_dict}
    ${other_BTS_FHS_RMOD_sn}=  Get all RMODs connected to shared FHS  ${other_BTS}

    ${other_BTS_shared_RMOD_impacted}=  Create List
    ${other_BTS_dedicated_RMOD_impacted}=  Create List

    FOR  ${item}  IN  @{other_BTS_RMOD_impacted_sn_list}
        Run Keyword If  "${item}" in ${other_BTS_shared_RMOD_sn}
        ...  Append To List  ${other_BTS_shared_RMOD_impacted}  ${item}
        Run Keyword If  "${item}" in ${other_BTS_dedicated_RMOD_sn}
        ...  Append To List  ${other_BTS_dedicated_RMOD_impacted}  ${item}
    END

    FOR  ${item}  IN  @{other_BTS_FHS_RMOD_sn}
        Run Keyword If  "${item}" in ${BTS_PL_shared_RM_sn_list}
        ...  Remove Values From List  ${BTS_PL_shared_RM_sn_list}  ${item}
    END

    ${other_BTS_dedicated_alarm_count}=  Get Length  ${other_BTS_dedicated_RMOD_impacted}

    FOR  ${item}  IN  @{BTS_PL_shared_RM_sn_list}
        ${other_BTS_shared_alarm_count}=  Run Keyword If  '${item}' in ${other_BTS_non_PL_shared_RM_sn_list}
        ...  Evaluate  ${other_BTS_shared_alarm_count} + 1
        ...  ELSE
        ...  Evaluate  ${other_BTS_shared_alarm_count} + 0
    END

    ${other_BTS_shared_RMOD_impacted_count}=  Get Length  ${other_BTS_shared_RMOD_impacted}
    ${other_BTS_shared_alarm_count}=  Evaluate  ${other_BTS_shared_alarm_count} + ${other_BTS_shared_RMOD_impacted_count}

    [Return]  ${other_BTS_shared_alarm_count}  ${other_BTS_dedicated_alarm_count}

Get all RMODs connected to shared FHS
    [Arguments]  ${alias}

    ${BTS_shared_FHS_list}=  Get Dictionary Keys  ${${alias}_shared_FHS_id_sn_dict}
    ${BTS_shared_RMOD_list}=  Get Dictionary Keys  ${${alias}_shared_RM_id_sn_dict}
    ${BTS_dedicated_RMOD_list}=  Get Dictionary Keys  ${${alias}_dedicated_RM_id_sn_dict}

    ${FHS_RMOD_id_list}=  Get RMOD Mapping on FHS list  ${BTS_shared_FHS_list}  ${alias}
    ${FHS_RMOD_sn_list}=  Create List
    FOR  ${module_id}  IN  @{FHS_RMOD_id_list}
        ${module_sn}=  Run Keyword If  '${module_id}' in ${BTS_shared_RMOD_list}  Get From Dictionary  ${${alias}_shared_RM_id_sn_dict}  ${module_id}
        ...  ELSE IF  '${module_id}' in ${BTS_dedicated_RMOD_list}  Get From Dictionary  ${${alias}_dedicated_RM_id_sn_dict}  ${module_id}
        Append To List  ${FHS_RMOD_sn_list}  ${module_sn}
    END

    [Return]  ${FHS_RMOD_sn_list}

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS ${alias} site: 1
    ...  - other BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    END

Get and check KPI1a info from IMS file
    [Documentation]
    ...  Get and check KPI1a info from IMS file.
    [Arguments]  ${alias}

    Log  Get and check KPI1a info from IMS file  console=True
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi1a  kpi_thresholds=${${label}_RESET_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1a

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${label}  action_1=BTS_Unblock  kpi_reported_1=KPI_1a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Perform BTS Block
    [Arguments]  ${alias}

    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, blockingState=${Blocked_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, blockingState=Blocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    Run Keyword If  ${${alias}_DSS_configured}  Get DSS impact on other BTS after Block Site  ${alias}

    Log  Perform "Block Site" operation on ${label} from Admin  console=True
    Get Current Time  bts_block
    coam.Block  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}

    Log  ***** Check ${label} status after "Block Site" operation on ${label} *****  console=True
    Log  Check ${label} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_block}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_Configured_}  ${Blocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${label} site - proceduralState: IntegratedToRAN|Configured, blockingState: Blocked, as expected!  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_block}  ${BTS_MAX_WAIT_TIME}
    Admin Check all BTS cells expected states  ${CELL_state_disabled_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${label} cell(s) status:\n - ${CELL_state_disabled}  console=True

    Log  Check ${label} alarms:  console=True
    Log  ${label} "BTS blocked (50)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_50}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${label} "BTS blocked (50)" alarm, found number: 1, as expected!  console=True
    Log  ${label} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check the other BTS(s) status after "Block Site" operation on ${label} *****  console=True
    Check other BTS states and alarms after Block Site  ${alias}

Perform BTS Unblock
    [Arguments]  ${alias}

    Log  Perform "Unblock Site" operation on ${label} from Admin  console=True
    Get Current Time  bts_unblock
    coam.Unblock  timeout=${BTS_MAX_WAIT_TIME}  alias=${alias}  wait_for_reconnection=False

    ${BTS_LMP_IP_address}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Wait For Target To Be Not Reachable TAF  hostname=${BTS_LMP_IP_address}  remote_host=${remote_host_ip}  timeout=${remained_MAX_WAIT_TIME}

    Log  ***** Check the other BTS(s) alarms during "Unblock Site" operation on ${label} *****  console=True
    Check other BTS states and alarms during Unblock Site  ${alias}

    Log  ***** Check ${label} status and alarms after "Unblock Site" operation on ${label} *****  console=True
    Log  Check ${label} status:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_unblock}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${label} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${label} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${label} site - expected, ignored and critical alarms checked  console=True

    Log  ***** Check the other BTS(s) status and alarms after "Unblock Site" operation on ${label} *****  console=True
    Check other BTS states and alarms after Unblock Site  ${alias}

Get DSS impact on other BTS after Block Site
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        Continue For Loop If  '${other_alias}' not in ${${alias}_BTS_DSS_peer}

        ${other_BTS_DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${all_BTS_DSS_NR_LTE_CELL_dict}  ${other_alias}
        ${other_BTS_DSS_LTE_NR_CELL_dict}=  Get From Dictionary  ${all_BTS_DSS_LTE_NR_CELL_dict}  ${other_alias}

        ${FID7513_alarm_count}=  Get Length  ${other_BTS_DSS_NR_LTE_CELL_dict}
        ${FID6134_alarm_count}=  Get Length  ${other_BTS_DSS_LTE_NR_CELL_dict}

        ${DSS_EXPECTED_ALARMS_7513_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_NR_DSS}  ${FID7513_alarm_count}
        ${DSS_EXPECTED_ALARMS_6134_full}=  Prepare expected alarms list  ${${other_alias.upper()}_EXPECTED_ALARMS_LTE_DSS}  ${FID6134_alarm_count}
        ${DSS_EXPECTED_ALARMS_7513_6134_full}=  Combine Lists  ${DSS_EXPECTED_ALARMS_7513_full}  ${DSS_EXPECTED_ALARMS_6134_full}

        Set Test Variable  ${${other_alias}_FID7513_alarm_count}  ${FID7513_alarm_count}
        Set Test Variable  ${${other_alias}_FID6134_alarm_count}  ${FID6134_alarm_count}
        Set Test Variable  ${${other_alias}_DSS_EXPECTED_ALARMS_7513_6134_full}  ${DSS_EXPECTED_ALARMS_7513_6134_full}
    END

Check other BTS states and alarms during Unblock Site
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}
        ${BTS_all_RM_L3Protocol}=  Get Dictionary Items  ${${other_alias}_RM_L3Protocol_dict}
        ${IGNORED_ALARMS_FULL}=  Combine Lists  ${${other_alias.upper()}_IGNORED_ALARMS}  ${IGNORED_ALARMS_DURING_UNBLOCK}

        Log  Check ${other_label} alarms:  console=True
        Run Keyword If  ${${other_alias}_FID10_alarm_count} > 0
        ...  Log  ${other_label} "No connection to Unit (10)" alarm, expected number: ${${other_alias}_FID10_alarm_count}  console=True
         Run Keyword If  ${${other_alias}_FID10_1815_alarm_count} > 0
        ...  Log Long String  ${other_label} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
        ...  expected number: ${${other_alias}_FID10_1815_alarm_count}  console=True
        Run Keyword If  ${${other_alias}_FID16_alarm_count} > 0
        ...  Log  ${other_label} "Unit synchronization failed (16)" alarm, expected number: ${${other_alias}_FID16_alarm_count}  console=True

        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=${${other_alias}_EXPECTED_ALARMS_full}
        ...  ignored_alarms=${IGNORED_ALARMS_FULL}  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}

        Run Keyword If  ${${other_alias}_FID10_alarm_count} > 0
        ...  Log  ${other_label} "No connection to Unit (10)" alarm, found number: ${${other_alias}_FID10_alarm_count}, as expected!
        ...  console=True
        Run Keyword If  ${${other_alias}_FID10_1815_alarm_count} > 0
        ...  Log Long String  ${other_label} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815)" alarm,
        ...  found number: ${${other_alias}_FID10_1815_alarm_count}, as expected!  console=True
        Run Keyword If  ${${other_alias}_FID16_alarm_count} > 0
        ...  Log  ${other_label} "Unit synchronization failed (16)" alarm, found number: ${${other_alias}_FID16_alarm_count}, as expected!
        ...  console=True
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Check other BTS states and alarms after Block Site
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        Log  Check ${other_label} status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_bts_block}  ${BTS_MAX_WAIT_TIME}
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${other_alias}
        Log  ${other_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

        Log  Check ${other_label} alarms:  console=True
        Run Keyword If  ${${alias}_DSS_configured} and '${other_alias}' in ${${alias}_BTS_DSS_peer}  Run Keywords
        ...  Log Long String  ${other_label} "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" or
        ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm alarm, expected number:
        ...  ${${other_alias}_FID7513_alarm_count}  console=True
        ...  AND  Log Long String  ${other_label} "EN DSS De-activated on partner side (6134)" or "EN DSS Keep Alive Procedure Time out (6132)" or
        ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell (6129)" alarm, expected number:
        ...  ${${other_alias}_FID6134_alarm_count}  console=True

        Run Keyword If  ${${alias}_DSS_configured} and '${other_alias}' in ${${alias}_BTS_DSS_peer}
        ...  Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=${${other_alias}_DSS_EXPECTED_ALARMS_7513_6134_full}
        ...  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}
        ...  ELSE
        ...  Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}

        Run Keyword If  ${${alias}_DSS_configured} and '${other_alias}' in ${${alias}_BTS_DSS_peer}  Run Keywords
        ...  Log Long String  ${other_label} "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)" or
        ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm alarm, found number:
        ...  ${${other_alias}_FID7513_alarm_count}, as expected!  console=True
        ...  AND  Log Long String  ${other_label} "EN DSS De-activated on partner side (6134)" or "EN DSS Keep Alive Procedure Time out (6132)" or
        ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No DSS Partner Cell (6129)" alarm, found number:
        ...  ${${other_alias}_FID6134_alarm_count}, as expected!  console=True
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Check other BTS states and alarms after Unblock Site
    [Arguments]  ${alias}

    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${alias}'
        ${other_label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${other_alias}

        Log  Check ${other_label} status:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${BTS_MAX_WAIT_TIME}  ${other_alias}
        Log  ${other_label} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

        Check cells availability status online  ${other_alias}  ${BTS_MAX_WAIT_TIME}
        Log  All ${other_label} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Log  Check ${other_label} alarms:  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${other_alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=15 min
        Log  ${other_label} site - expected, ignored and critical alarms checked  console=True
    END

Particular Teardown
    FOR  ${alias}  IN  @{BTS_alias_list}
        Admin Check if BTS is unblocked  ${alias}
    END
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
