*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
Variables    tc_variables/sbts_sbts__state__bts1_bts2_rat_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3      # Number of RAT reset operations, default value 3
${BTS_LIST}                ALL    # BTS list on which BTS RAT reset operation will be performed. Possible values (by default ALL):
                                  # - ALL: action will be performed on all BTS (reset RAT for each BTS until last BTS from TL)
                                  # - list of selected BTS separated by comma labelized as BTSx (x is test_pc number in init.py) (ex. BTS1)
${NR_RESET_WRN_THR}        120    # Time from first cell down to last cell up defined in seconds for NR RAT. Defaults to 120.
${LTE_RESET_WRN_THR}       120    # Time from first cell down to last cell up defined in seconds for LTE RAT.
                                  # Defaults to 120. For ABIO/ABIN should modified to 270 seconds
${WCDMA_RESET_WRN_THR}     120    # Time from first cell down to last cell up defined in seconds for WCDMA RAT.
                                  # Defaults to 120 based on NCF_SRAN_MR6
${GSM_RESET_WRN_THR}       120    # Time from first cell down to last cell up defined in seconds for GSM RAT. Defaults to 120.
${MAX_WAIT_TIME}           900    # Maximum time for wait of RAT OnAir
${RAT_TECH}                ALL    # RAT that needs to be reset. Possible values: ALL (RATs will be reset one by one),
                                  # NR, LTE, WCMDA, GSM
${RESET_TYPE}              Soft   # Reset type: Soft or Hard; default value: Soft, Hard value supported only stating with CB008880 24R2
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22969
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for SBTS RAT reset, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get both BTS FHS and cells info
    ...  - get both BTS RAT info
    ...  - perform individual reset RAT operation on the BTS which is carrying FHS; then on the peer BTS
    ...  - check reset behavior on both BTS based on initial and final RESET info as follows:
    ...    - Master BTS site: reset number is 0
    ...    - Slave BTS site: reset number is 0
    ...  - check final state and alarms for both BTS
    ...  Pass criteria: SBTS Reset RAT operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 20.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22969 -
    ...  [5G][CB007636] New_RFS_SBTS_RF_Share_Individual_RAT_Reset_for_both_operators_with_FHS
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24195 - [5G][Reset Number ims2] Update SBTS-SBTS CM, STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 04.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24832 -
    ...  [5G][CB008693]Adapt SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM to work even if not FHS is configured
    ...  - 22.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25386 -
    ...  [5G] New implementation KPI7,8,9,10 measurement +TC verdict from ims2 for SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25594 - [5G] Same KPI value found in KPI file for automated RAT reset scenarios
    ...  - 07.08.2023 - [5G][CB009569] Add checks regarding DSS alarms - SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM
    ...  - 02.11.2023 - [5G] RAT Reset implementation: Check RMOd reset, Cells disabled according to mapping on Loki
    ...  - 04.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26477 - [5G][CB009193] SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM robot
    ...  need to be used on SBTS_NR for 2 BTSs - w TAT-26480
    ...  - 04.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26480 - [5G][CB009193] Add input parameter in
    ...  SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM robot to select which RAT should be reset (all, NR, LTE, WCDMA, GSM) - w TAT-26477
    ...  - 12.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26511 - [5G][CB009193] Additional alarms checks on peer BTS for
    ...  SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM robot - w01
    ...  - 17.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26630 - [5G][CB009182-C002270-RP003030]new NR_SBTS__STATE__RAT_Reset_from_WEBEM
    ...  TC which will run SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM In case of SBTS-NR configuration
    ...  - 27.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26923 - [5G] Except dedicated radios for
    ...  SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM on peer BTS
    ...  - 13.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27089 - [5G] [Part 1]SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM to take
    ...  into consideration CB008880 starting 24R2
    ...  - 29.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27006 - [5G] [Part 2] SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM to take
    ...  into consideration CB008880 starting 24R2
    ...  - 17.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27164 - [5G] [Part 2] SBTS__STATE__RAT_Reset_from_WEBEM to take into
    ...  consideration CB008880 starting 24R2 - after TAT-27006
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
	...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27941 -
    ...  [5G] Variable '${MASTER_EXPECTED_ALARMS_LTE_DSS}' not found
    ...  - 18.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28087 -
    ...  NR_NR__STATE__RAT_Reset_from_WEBEM BTS2 HARD RAT reset fails when RFs PLs are distributed between BTSs
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 01.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28134 - [5G] SBTS__STATE__RAT_Reset_from_WEBEM (soft) failed with
    ...  AdminApiProcedureTimeoutException
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22969_SBTS_SBTS__STATE__BTS1_BTS2_RAT_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-razvan.roman@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT

    TC Preconditions
    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Master alarms
    Step 4: Check initial BTS Slave alarms
    Step 5: Get both BTS FHS and cells info
    Step 6: Get both BTS RAT info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 7: Perform Reset RAT operation ${INDEX}
        Step 8: Check final BTS Master state
        Step 9: Check final BTS Slave state
        Step 10: Check final BTS Master alarms
        Step 11: Check final BTS Slave alarms
        Step 12: Check BTS reset behavior from IMS
        Step 13: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  ====================================================  console=True
    Log  BTS label list selected for RAT reset operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for RAT reset operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    FOR  ${alias}  IN  @{alias_list}
        Get BTS CELL list by RAT  ${alias}
        ${actRatResetEnhancement}=  Get actRatResetEnhancement from SCF  alias=${alias}
        Set Test Variable  ${${alias}_actRatResetEnhancement}  ${actRatResetEnhancement}
    END

    FOR  ${alias}  IN  @{BTS_alias_list}
        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_MODULE_TYPE]' != 'FSMF'
        ...  Run Keyword If  '${RESET_TYPE}' == 'Soft' and '${${alias}_actRatResetEnhancement}' != 'true'  Run Keywords
        ...  Log  Improper value for actRatResetEnhancement parameter!  level=ERROR
        ...  AND  Fail  actRatResetEnhancement parameter should be set on true for Soft reset type on BTS ${alias}!
    END

    ${Master_NR_CELL_count}=  Get Length  ${Master_NR_CELL_list}
    ${Master_LTE_CELL_count}=  Get Length  ${Master_LTE_CELL_list}
    ${Master_WCDMA_CELL_count}=  Get Length  ${Master_WCDMA_CELL_list}
    ${Master_GSM_CELL_count}=  Get Length  ${Master_GSM_CELL_list}
    ${Slave_NR_CELL_count}=  Get Length  ${Slave_NR_CELL_list}
    ${Slave_LTE_CELL_count}=  Get Length  ${Slave_LTE_CELL_list}
    ${Slave_WCDMA_CELL_count}=  Get Length  ${Slave_WCDMA_CELL_list}
    ${Slave_GSM_CELL_count}=  Get Length  ${Slave_GSM_CELL_list}

    Run Keyword If  ${Master_NR_CELL_count} == 0 and ${Slave_NR_CELL_count} == 0 and '${RAT_TECH}'=='NR'
    ...  Fail  Not configured cell(s) found for selected RAT: ${RAT_TECH}!
    ...  ELSE IF  ${Master_LTE_CELL_count} == 0 and ${Slave_LTE_CELL_count} == 0 and '${RAT_TECH}'=='LTE'
    ...  Fail  Not configured cell(s) found for selected RAT: ${RAT_TECH}!
    ...  ELSE IF  ${Master_WCDMA_CELL_count} == 0 and ${Slave_WCDMA_CELL_count} == 0 and '${RAT_TECH}'=='WCDMA'
    ...  Fail  Not configured cell(s) found for selected RAT: ${RAT_TECH}!
    ...  ELSE IF  ${Master_GSM_CELL_count} == 0 and ${Slave_GSM_CELL_count} == 0 and '${RAT_TECH}'=='GSM'
    ...  Fail  Not configured cell(s) found for selected RAT: ${RAT_TECH}!
    ...  ELSE  Log  Reset operation will be performed on ${RAT_TECH} RAT  console=True

Step ${index}: Check ${when} BTS ${alias} state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS ${alias} alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} alarms  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get both BTS FHS and cells info
    Log  Step ${index}: Get both BTS FHS and cells info  console=True

    Get FHS info on both BTS

    FOR  ${alias}  IN  @{alias_list}
        Get BTS CELL list by RAT  ${alias}
        Check if DSS is configured  ${alias}
    END

Step ${index}: Get both BTS RAT info
    Log  Step ${index}: Get both BTS RAT info  console=True

    FOR  ${alias}  IN  @{alias_list}
        Get BTS RAT info  ${alias}
    END

Step ${index}: Perform Reset RAT operation ${CYCLE}

    Run Keyword If  ${Master_dedicated_FHS_list} and '${RAT_TECH}' == 'ALL' and '${BTS_LIST}' == 'ALL'  Run Keywords
    ...  Log  Step ${index}: Perform Reset RAT operation on ${RAT_TECH} BTS RATs  console=True
    ...  AND  Perform Reset RAT on BTS  Master  ${CYCLE}
    ...  AND  Perform Reset RAT on BTS  Slave  ${CYCLE}
    ...  AND  Return From Keyword
    ...  ELSE IF  ${Master_dedicated_FHS_list} and '${RAT_TECH}' != 'ALL' and '${BTS_LIST}' == 'ALL'  Run Keywords
    ...  Log  Step ${index}: Perform Reset RAT operation on ${RAT_TECH} BTS RATs  console=True
    ...  AND  Perform Reset on specific RAT  Master  ${CYCLE}
    ...  AND  Perform Reset on specific RAT  Slave  ${CYCLE}
    ...  AND  Return From Keyword

    Run Keyword If  ${Slave_dedicated_FHS_list} and '${RAT_TECH}' == 'ALL' and '${BTS_LIST}' == 'ALL'  Run Keywords
    ...  Log  Step ${index}: Perform Reset RAT operation on ${RAT_TECH} BTS RATs  console=True
    ...  AND  Perform Reset RAT on BTS  Slave  ${CYCLE}
    ...  AND  Perform Reset RAT on BTS  Master  ${CYCLE}
    ...  AND  Return From Keyword
    ...  ELSE IF  ${Slave_dedicated_FHS_list} and '${RAT_TECH}' != 'ALL' and '${BTS_LIST}' == 'ALL'  Run Keywords
    ...  Log  Step ${index}: Perform Reset RAT operation on ${RAT_TECH} BTS RATs  console=True
    ...  AND  Perform Reset on specific RAT  Slave  ${CYCLE}
    ...  AND  Perform Reset on specific RAT  Master  ${CYCLE}
    ...  AND  Return From Keyword

    FOR  ${alias}  IN  @{BTS_alias_list}
        Run Keyword If  '${RAT_TECH}' == 'ALL'  Run Keywords
        ...  Log  Step ${index}: Perform Reset RAT operation on ${RAT_TECH} BTS RATs  console=True
        ...  AND  Perform Reset RAT on BTS  ${alias}  ${CYCLE}
        ...  ELSE IF  '${RAT_TECH}' != 'ALL'  Run Keywords
        ...  Log  Step ${index}: Perform Reset RAT operation on ${RAT_TECH} BTS RATs  console=True
        ...  AND  Perform Reset on specific RAT  ${alias}  ${CYCLE}
    END

Step ${index}: Check BTS reset behavior from IMS
    [Documentation]
    ...  Final RESET info is compared with initial RESET info for both BTS
    ...  Reset behavior as expected in following conditions:
    ...  - BTS1: reset number is 0
    ...  - BTS2: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    Log  Step ${index}: Check BTS reset behavior from IMS from IMS  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

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

Get FHS info on both BTS
    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Sort List  ${Master_shared_FHS_list}
    Sort List  ${Slave_shared_FHS_list}
    Sort List  ${Master_dedicated_FHS_list}
    Sort List  ${Slave_dedicated_FHS_list}
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    Set Test Variable  ${Master_dedicated_FHS_list}
    Set Test Variable  ${Slave_dedicated_FHS_list}

    Get FHS ID SN dict  Master
    Get FHS ID SN dict  Slave

    Set Test Variable  ${Master_FHS_SN_ID_dict}   ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_FHS_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_FHS_SN_ID_dict}   ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_FHS_ID_SN_dict}  ${Slave_module_ID_SN_dict}

    Run Keyword If  ${Master_shared_FHS_list}
    ...  Get shared FHS info
    Run Keyword If  ${Master_dedicated_FHS_list}
    ...  Get dedicated FHS info  Master
    Run Keyword If  ${Slave_dedicated_FHS_list}
    ...  Get dedicated FHS info  Slave

    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RM_list}
    Set Test Variable  ${Slave_shared_RM_list}
    Get RMOD ID SN dict  Master
    Set Test Variable  ${Master_RM_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_RM_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Get RMOD ID SN dict  Slave
    Set Test Variable  ${Slave_RM_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_RM_ID_SN_dict}  ${Slave_module_ID_SN_dict}

Get shared FHS info
    FOR  ${Master_FHS_id}  IN  @{Master_shared_FHS_list}
        ${FHS_sn}=  Get From Dictionary  ${Master_FHS_ID_SN_dict}  ${Master_FHS_id}
        ${Slave_FHS_id}=  Get From Dictionary  ${Slave_FHS_SN_ID_dict}  ${FHS_sn}
        Log  Shared FHS with SN ${FHS_sn}:  console=True
        Log  - BTS1 FHS id: ${Master_FHS_id}  console=True
        Log  - BTS2 FHS id: ${Slave_FHS_id}  console=True
    END

Get dedicated FHS info
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    FOR  ${FHS_id}  IN  @{${alias}_dedicated_FHS_list}
        ${FHS_sn}=  Get From Dictionary  ${${alias}_FHS_ID_SN_dict}  ${FHS_id}
        Log  Dedicated FHS with SN ${FHS_sn}:  console=True
        Log  - ${BTS} FHS id: ${FHS_id}  console=True
    END

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

Check if DSS is configured
    [Arguments]  ${alias}

    Log  Check if DSS is configured on BTS ${alias}  console=True
     ${BTS_XP_localAlias_remoteAlias_dict}  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${LNBTS_DSS_alias_actLteNrDss_dict}
    ...  ${BTS_DSS_NR_LTE_CELL_scf_dict}  ${BTS_DSS_LTE_NR_CELL_scf_dict}  ${BTS_DSS_NR_LTE_CELL_dict}  ${BTS_DSS_LTE_NR_CELL_dict}=
    ...  Get all BTS DSS feature info
    Set Test Variable  ${BTS_DSS_NR_LTE_CELL_dict}
    Set Test Variable  ${BTS_DSS_LTE_NR_CELL_dict}

    ${BTS_actLteNrDss_NR}=  Get From Dictionary  ${NRBTS_DSS_alias_actLteNrDss_dict}  ${alias}
    ${BTS_actLteNrDss_LTE}=  Get From Dictionary  ${LNBTS_DSS_alias_actLteNrDss_dict}  ${alias}

    ${BTS_DSS_configured}=  Set Variable If  '${BTS_actLteNrDss_NR}' == 'True' or '${BTS_actLteNrDss_LTE}' == 'True'  True  False
    ${BTS_DSS_peer}=  Get From Dictionary  ${BTS_XP_localAlias_remoteAlias_dict}  ${alias}
    Set Test Variable  ${${alias}_BTS_DSS_peer}  ${BTS_DSS_peer}

    ${BTS_DSS_peer_status}=  Run Keyword And Return Status  Should Not Be Empty  ${BTS_DSS_peer}
    Run Keyword If  not ${BTS_DSS_peer_status}
    ...  Set Test Variable  ${${alias}_DSS_configured}  False
    ...  ELSE  Set Test Variable  ${${alias}_DSS_configured}  True

    Run Keyword If  ${${alias}_DSS_configured}
    ...  Log  DSS is configured between BTS ${alias} and ${${alias}_BTS_DSS_peer}. DSS alarms check will be performed!  console=True
    ...  ELSE  Log  DSS is not configured on BTS ${alias}. DSS alarms check will be skipped!  console=True

Get BTS RAT info
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    ${RAT_list}=  Create List
    Run Keyword If  ${${alias}_NR_CELL_list}
    ...  Append To List  ${RAT_list}  NR
    Run Keyword If  ${${alias}_LTE_CELL_list}
    ...  Append To List  ${RAT_list}  LTE
    Run Keyword If  ${${alias}_WCDMA_CELL_list}
    ...  Append To List  ${RAT_list}  WCDMA
    Run Keyword If  ${${alias}_GSM_CELL_list}
    ...  Append To List  ${RAT_list}  GSM
    Set Test Variable  ${${alias}_RAT_list}  ${RAT_list}
    Log  ${BTS} RAT found: ${${alias}_RAT_list}  console=True

Perform Reset RAT on BTS
    [Arguments]  ${alias}  ${CYCLE}

    FOR  ${item}  IN  @{${alias}_RAT_list}
        Perform Reset RAT  ${item}  ${alias}  ${CYCLE}
    END

Perform Reset on specific RAT
    [Arguments]  ${alias}  ${CYCLE}

    FOR  ${item}  IN  @{${alias}_RAT_list}
        Continue For Loop If  '${item}' != '${RAT_TECH}'
        Perform Reset RAT  ${item}  ${alias}  ${CYCLE}
    END

Perform Reset RAT
    [Arguments]  ${RAT_tech}  ${alias}  ${CYCLE}
    ${new_alias}=  Set Variable  resetRAT
    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    ${peer_BTS}=  Set Variable If  '${alias}' == 'Master'  BTS2  BTS1
    ${CELL_class_name}=  Set Variable If
    ...  '${RAT_tech}'=='NR'  NRCEL  '${RAT_tech}'=='LTE'  LNCEL  '${RAT_tech}'=='WCDMA'  WNCEL  '${RAT_tech}'=='GSM'  GNCEL
    ${RESET_WRN_THR}=  Set Variable  ${${RAT_tech}_RESET_WRN_THR}
    Set Test Variable  ${BTS}
    Set Test Variable  ${peer_BTS}
    Set Test Variable  ${RMOD_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  Perform "Reset ${RAT_tech} RAT" operation on ${BTS} from Admin  console=True

    Get shared RMOD Primary Link Info

    Get BTS and peer BTS RAT reset impact  ${RAT_tech}  ${alias}  ${peer_alias}
    Run Keyword If  ${${alias}_DSS_configured} and '${RAT_tech}' in ['NR','LTE']
    ...  Get BTS and peer BTS DSS impact  ${RAT_tech}  ${alias}  ${peer_alias}

    Get Current Date UTC info  start_resetRAT
    Get Current Time  initial

    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    ${reset_info}=  RFS RAT Reset  rat_type=${RAT_tech}  timeout=${MAX_WAIT_TIME}  connection=${new_alias}  alias=${alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}  reset_type=${RESET_TYPE}
    Sleep  3s

    Log  Check ${BTS} and ${peer_BTS} state and alarms during ${BTS} ${RAT_tech} RAT reset:  console=True

    Log  Check ${BTS} state and alarms during ${BTS} ${RAT_tech} RAT reset:  console=True
    Check BTS state and alarms during RAT reset  ${RAT_tech}  ${CELL_class_name}  ${alias}
    Log  Check ${peer_BTS} state and alarms during ${BTS} ${RAT_tech} RAT reset:  console=True
    Check peer BTS state and alarms during RAT reset  ${RAT_tech}  ${alias}  ${peer_alias}

    Log  Check ${BTS} and ${peer_BTS} state and alarms after ${BTS} ${RAT_tech} RAT reset:  console=True

    Log  Check ${BTS} states and alarms after ${BTS} ${RAT_tech} RAT reset:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  All ${BTS} RMODs status:\n ${RMOD_state_enabled}  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    Log  All ${BTS} cells states:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

    Collect Keyword Result  ${reset_info}  timeout=${MAX_WAIT_TIME}

    Log  Check ${peer_BTS} states and alarms after ${BTS} ${RAT_tech} RAT reset:  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${peer_alias}
    Log  All ${peer_BTS} cells states:\n - ${CELL_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  ${peer_BTS} site - expected, ignored and critical alarms checked  console=True

    Log  ${BTS} "Reset ${RAT_tech} RAT" operation successfully finished  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Get Current Date UTC info  end_resetRAT
    Sleep  5s
    Get and check KPI from IMS file  ${alias}  ${RAT_tech}  ${CYCLE}

    [Teardown]  Teardown Admin  alias=${new_alias}

Get shared RMOD Primary Link Info
    [Documentation]
    ...  Get shared RMOD Primary Link Info

    Log  Get shared RMOD Primary Link Info  console=True
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}

        ${BTS_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_id_list
        ${BTS_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_id_list
        ${BTS_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_id_list

        ${BTS_non_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_id_list
        ${BTS_non_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list
        ${BTS_non_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_id_list

        ${BTS_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_CPRI_shared_RMOD_list}
        ${BTS_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_ECPRI_shared_RMOD_list}
        ${BTS_PL_OBSAI_shared_RMOD_count}=  Get Length  ${BTS_PL_OBSAI_shared_RMOD_list}

        Log  CPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_CPRI_shared_RMOD_count}  console=True
        Log  ECPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_ECPRI_shared_RMOD_count}  console=True
        Log  OBSAI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_OBSAI_shared_RMOD_count}  console=True

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_list}  ${BTS_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_list}  ${BTS_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_list}  ${BTS_PL_OBSAI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_CPRI_shared_RMOD_list}  ${BTS_non_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_ECPRI_shared_RMOD_list}  ${BTS_non_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_OBSAI_shared_RMOD_list}  ${BTS_non_PL_OBSAI_shared_RMOD_list}

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_count}  ${BTS_PL_CPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_count}  ${BTS_PL_ECPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_count}  ${BTS_PL_OBSAI_shared_RMOD_count}

        ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_list}=
        ...  Get excepted and not excepted RMOD lists  ${BTS_non_PL_ECPRI_shared_RMOD_list}  ${RMOD_ECPRI_fid16_exceptions}  ${alias}
        ${BTS_non_PL_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_list}
        ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_not_excepted_ECPRI_shared_RMOD_list}  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_excepted_ECPRI_shared_RMOD_list}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_not_excepted_ECPRI_shared_RMOD_count}  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_non_PL_excepted_ECPRI_shared_RMOD_count}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_count}
    END

Get BTS and peer BTS RAT reset impact
    [Arguments]  ${RAT_tech}  ${alias}  ${peer_alias}

    Return From Keyword If  '${${alias}_actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'

    Get BTS RAT reset impact on FRONTHAUL modules and cells  ${RAT_tech}  ${alias}
    Get peer RMOD and cells impacted by RAT reset  ${RAT_tech}  ${alias}  ${peer_alias}
    Log  Impacted ${BTS} FHS list by ${RAT_tech} RAT reset: \n ${${alias}_${RAT_tech}_RAT_reset_FHS_id_list}  console=True
    Log  Impacted ${BTS} RMOD list by ${RAT_tech} RAT reset: \n ${${alias}_${RAT_tech}_RAT_reset_RMOD_id_list}  console=True

Get BTS RAT reset impact on FRONTHAUL modules and cells
    [Arguments]  ${RAT_tech}  ${alias}

    ${RAT_reset_FHS_id_list}  ${RAT_reset_RMOD_id_list}  ${RAT_reset_NRCEL_id_list}  ${RAT_reset_LNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    ...  ${RAT_reset_GNCEL_id_list}=  Get RAT reset impact on FRONTHAUL modules and cells  ${RAT_tech}  ${alias}

    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_FHS_id_list}  ${RAT_reset_FHS_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_RMOD_id_list}  ${RAT_reset_RMOD_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_NRCEL_id_list}  ${RAT_reset_NRCEL_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_LNCEL_id_list}  ${RAT_reset_LNCEL_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_WNCEL_id_list}  ${RAT_reset_WNCEL_id_list}
    Set Test Variable  ${${alias}_${RAT_tech}_RAT_reset_GNCEL_id_list}  ${RAT_reset_GNCEL_id_list}

Get peer RMOD and cells impacted by RAT reset
    [Arguments]  ${RAT_tech}  ${alias}  ${peer_alias}
    ${peer_CPRI_impacted_RMOD_list}=  Create List
    ${peer_ECPRI_impacted_RMOD_list}=  Create List
    ${peer_OBSAI_impacted_RMOD_list}=  Create List
    ${peer_not_impacted_RMOD_list}=  Create List
    FOR  ${item}  IN  @{${alias}_${RAT_tech}_RAT_reset_RMOD_id_list}
        Continue For Loop If  '${item}' not in ${${alias}_shared_RM_list}
        ${RMOD_sn}=  Get From Dictionary  ${${alias}_RM_ID_SN_dict}  ${item}
        ${peer_RMOD_id}=  Get From Dictionary  ${${peer_alias}_RM_SN_ID_dict}  ${RMOD_sn}
        Run Keyword If  '${peer_RMOD_id}' in @{${peer_alias}_non_PL_not_excepted_ECPRI_shared_RMOD_list}
        ...  Append To List  ${peer_ECPRI_impacted_RMOD_list}  ${peer_RMOD_id}
        ...  ELSE IF  '${peer_RMOD_id}' in @{${peer_alias}_non_PL_OBSAI_shared_RMOD_list}
        ...  Append To List  ${peer_OBSAI_impacted_RMOD_list}  ${peer_RMOD_id}
        ...  ELSE IF  '${peer_RMOD_id}' in @{${peer_alias}_non_PL_CPRI_shared_RMOD_list}
        ...  Append To List  ${peer_CPRI_impacted_RMOD_list}  ${peer_RMOD_id}
        ...  ELSE  Append To List  ${peer_not_impacted_RMOD_list}  ${peer_RMOD_id}
    END

    ${peer_non_impacted_RMOD_list_full}=  Combine Lists  ${${peer_alias}_PL_ECPRI_shared_RMOD_list}  ${${peer_alias}_PL_CPRI_shared_RMOD_list}
    ...  ${${peer_alias}_PL_OBSAI_shared_RMOD_list}  ${peer_not_impacted_RMOD_list}
    ${peer_non_impacted_RMOD_list_full}=  Remove Duplicates  ${peer_non_impacted_RMOD_list_full}

    Set Test Variable  ${peer_CPRI_impacted_RMOD_list}
    Set Test Variable  ${peer_ECPRI_impacted_RMOD_list}
    Set Test Variable  ${peer_OBSAI_impacted_RMOD_list}
    Set Test Variable  ${peer_non_impacted_RMOD_list_full}

Get BTS and peer BTS DSS impact
    [Arguments]  ${RAT_tech}  ${alias}  ${peer_alias}

    Run Keyword If  '${${alias}_actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'
    ...  Get BTS and peer BTS DSS alarms without LOKI impact  ${RAT_tech}  ${alias}  ${peer_alias}

Get BTS and peer BTS DSS alarms without LOKI impact
    [Arguments]  ${RAT_tech}  ${alias}  ${peer_alias}

    Run Keyword If  '${alias}' in ${${alias}_BTS_DSS_peer}  Get DSS alarms without LOKI impact  ${RAT_tech}  ${alias}
    Run Keyword If  '${peer_alias}' in ${${alias}_BTS_DSS_peer}  Get DSS alarms without LOKI impact  ${RAT_tech}  ${peer_alias}

Get DSS alarms without LOKI impact
    [Arguments]  ${RAT_tech}  ${alias}

    ${DSS_NR_LTE_CELL_dict}=  Get From Dictionary  ${BTS_DSS_NR_LTE_CELL_dict}  ${alias}
    ${DSS_alarm_count}=  Get Length  ${DSS_NR_LTE_CELL_dict}

    ${EXPECTED_ALARMS_DSS}=  Run Keyword If  '${RAT_tech}' == 'NR'
    ...  Create List
    ...  ELSE IF  '${RAT_tech}' == 'LTE'
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_NR_DSS}  ${DSS_alarm_count}

    Set Test Variable  ${${alias}_DSS_alarm_count}  ${DSS_alarm_count}
    Set Test Variable  ${${alias}_EXPECTED_ALARMS_DSS}  ${EXPECTED_ALARMS_DSS}

Check BTS state and alarms during RAT reset
    [Arguments]  ${RAT_tech}  ${CELL_class_name}  ${alias}

    Run Keyword If  '${${alias}_actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'
    ...  Check BTS state and alarms without LOKI impact  ${RAT_tech}  ${CELL_class_name}  ${alias}
    ...  ELSE
    ...  Check BTS state and alarms with LOKI impact  ${RAT_tech}  ${CELL_class_name}  ${alias}

Check BTS state and alarms without LOKI impact
    [Arguments]  ${RAT_tech}  ${CELL_class_name}  ${alias}

    Log  Check ${BTS} ${RAT_tech} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${BTS} ${RAT_tech} cells status:\n - ${CELL_state_disabled}  console=True

    Log  Check ${BTS} alarms:  console=True
    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_full}=  Set Variable If
    ...  ${${alias}_DSS_configured} and '${alias}' in ${${alias}_BTS_DSS_peer} and '${RAT_tech}'=='LTE'
    ...  ${${alias}_EXPECTED_ALARMS_DSS}  ${EXPECTED_ALARMS}
    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${alias.upper()}_IGNORED_ALARMS}

    Run Keyword If  ${${alias}_DSS_configured} and '${alias}' in ${${alias}_BTS_DSS_peer} and '${RAT_tech}' == 'LTE'
    ...  Log Long String  ${BTS} NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  expected number: ${${alias}_DSS_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS_full}  poll_interval=10 sec
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${alias}_DSS_configured} and '${alias}' in ${${alias}_BTS_DSS_peer} and '${RAT_tech}' == 'LTE'
    ...  Log Long String  ${BTS} NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, found number: ${${alias}_DSS_alarm_count},
    ...  as expected!  console=True

Check BTS state and alarms with LOKI impact
    [Arguments]  ${RAT_tech}  ${CELL_class_name}  ${alias}

    Log  Check ${BTS} ${RAT_tech} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${MAX_WAIT_TIME}
    Assert Every  class_name=${CELL_class_name}  parameters=${CELL_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${BTS} ${RAT_tech} cells status:\n - ${CELL_state_disabled}  console=True

    Check BTS FRONTHAUL modules and cells status impacted by RAT reset  ${RAT_tech}  ${alias}

Check BTS FRONTHAUL modules and cells status impacted by RAT reset
    [Arguments]  ${RAT_tech}  ${alias}
    ${MOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}
    ${MOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline

    Log  Check ${BTS} FRONTHAUL modules (FHS/RMOD) status impacted by ${RAT_tech} RAT reset:  console=True

    FOR  ${item}  IN  @{${alias}_${RAT_tech}_RAT_reset_FHS_id_list}
        Assert  class_name=FHS  id=${item}  parameters=${MOD_state_disabled_check}  timeout=180  connection=${alias}
        Log  ${BTS} FHS ${item} status:\n - ${MOD_state_disabled}  console=True
    END

    FOR  ${item}  IN  @{${alias}_${RAT_tech}_RAT_reset_RMOD_id_list}
        Assert  class_name=RMOD  id=${item}  parameters=${MOD_state_disabled_check}  timeout=180  connection=${alias}
        Log  ${BTS} RMOD ${item} status:\n - ${MOD_state_disabled}  console=True
    END

    Log  Check ${BTS} other RAT cells status impacted by ${RAT_tech} RAT reset:  console=True

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_NRCEL_id_list} and '${RAT_tech}' != 'NR'
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_NRCEL_id_list}  alias=${alias}

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_LNCEL_id_list} and '${RAT_tech}' != 'LTE'
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_LNCEL_id_list}  alias=${alias}

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_WNCEL_id_list} and '${RAT_tech}' != 'WCDMA'
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_WNCEL_id_list}  alias=${alias}

    Run Keyword If  ${${alias}_${RAT_tech}_RAT_reset_GNCEL_id_list} and '${RAT_tech}' != 'GSM'
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_${RAT_tech}_RAT_reset_GNCEL_id_list}  alias=${alias}

Check peer BTS state and alarms during RAT reset
    [Arguments]  ${RAT_tech}  ${alias}  ${peer_alias}

    Run Keyword If  '${${alias}_actRatResetEnhancement}' == 'true' and '${RESET_TYPE}' == 'Soft'
    ...  Check peer BTS state and alarms without LOKI impact  ${RAT_tech}  ${alias}  ${peer_alias}
    ...  ELSE
    ...  Check peer BTS state and alarms with LOKI impact  ${peer_alias}

Check peer BTS state and alarms without LOKI impact
    [Arguments]  ${RAT_tech}  ${alias}  ${peer_alias}

    ${peer_EXPECTED_ALARMS}=  Create List
    ${peer_EXPECTED_ALARMS_full}=  Set Variable If
    ...  ${${alias}_DSS_configured} and '${peer_alias}' in ${${alias}_BTS_DSS_peer} and '${RAT_tech}'=='LTE'
    ...  ${${peer_alias}_EXPECTED_ALARMS_DSS}  ${peer_EXPECTED_ALARMS}
    ${peer_IGNORED_ALARMS_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${peer_alias.upper()}_IGNORED_ALARMS}

    Run Keyword If  ${${alias}_DSS_configured} and '${peer_alias}' in ${${alias}_BTS_DSS_peer} and '${RAT_tech}' == 'LTE'
    ...  Log Long String  ${peer_BTS} NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm,
    ...  expected number: ${${peer_alias}_DSS_alarm_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_EXPECTED_ALARMS_full}  poll_interval=10 sec
    ...  ignored_alarms=${peer_IGNORED_ALARMS_full}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${alias}_DSS_configured} and '${peer_alias}' in ${${alias}_BTS_DSS_peer} and '${RAT_tech}' == 'LTE'
    ...  Log Long String  ${peer_BTS} NR RAT "EN DSS De-activated on partner side (7513)" or "EN DSS Keep Alive Procedure Time out (7511)", or
    ...  "EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM (7509)" alarm, found number:
    ...  ${${peer_alias}_DSS_alarm_count}, as expected!  console=True

Check peer BTS state and alarms with LOKI impact
    [Arguments]  ${peer_alias}

    Run Keyword If  ${peer_ECPRI_impacted_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${peer_ECPRI_impacted_RMOD_list}  ${RMOD_state_disabled_check}  300  ${peer_alias}
    ...  AND  Log  All ${peer_BTS} ECPRI Shared RMOD with Primary Link configured on ${BTS} status:\n - ${RMOD_state_disabled}  console=True
    Run Keyword If  ${peer_OBSAI_impacted_RMOD_list}  Run Keywords
    ...  Check BTS Item State  RMOD  ${peer_OBSAI_impacted_RMOD_list}  ${RMOD_state_disabled_check}  300  ${peer_alias}
    ...  AND  Log  All ${peer_BTS} OBSAI Shared RMOD with Primary Link configured on ${BTS} status:\n - ${RMOD_state_disabled}  console=True
    Run Keyword If  ${peer_non_impacted_RMOD_list_full}  Run Keywords
    ...  Check BTS Item State  RMOD  ${peer_non_impacted_RMOD_list_full}  ${RMOD_state_enabled_check}  5  ${peer_alias}
    ...  AND  Log  ${peer_BTS} Shared RMOD not impacted by on ${peer_BTS} status:\n - ${RMOD_state_enabled}  console=True

    ${peer_alarm_10_count}=  Get Length  ${peer_OBSAI_impacted_RMOD_list}
    ${peer_alarm_10_1815_count}=  Get Length  ${peer_CPRI_impacted_RMOD_list}
    ${peer_alarm_16_count}=  Get Length  ${peer_ECPRI_impacted_RMOD_list}
    ${peer_EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}  ${peer_alarm_10_count}
    ${EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}  ${peer_alarm_10_1815_count}
    ${EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_alias.upper()}_EXPECTED_ALARMS_16}  ${peer_alarm_16_count}
    ${EXPECTED_ALARMS_10_1815_16_full}=  Combine Lists  ${EXPECTED_ALARMS_10_full}  ${EXPECTED_ALARMS_10_1815_full}
    ...  ${EXPECTED_ALARMS_16_full}
    ${peer_EXPECTED_ALARMS_full}=  Set Variable If
    ...  (${peer_alarm_10_1815_count} == 0 and ${peer_alarm_16_count} == 0)  ${peer_EXPECTED_ALARMS}
    ...  ${EXPECTED_ALARMS_10_1815_16_full}
    ${peer_IGNORED_ALARMS_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET}  ${${peer_alias.upper()}_IGNORED_ALARMS_DSS}
    ...  ${${peer_alias.upper()}_IGNORED_ALARMS}

    Run Keyword If  ${peer_alarm_10_count} > 0
    ...  Log  ${peer_BTS} "No connection to unit (10)" alarm, expected number: ${peer_alarm_10_count}  console=True
    Run Keyword If  ${peer_alarm_10_1815_count} > 0
    ...  Log Long String  ${peer_BTS} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  expected number: ${peer_alarm_10_1815_count}  console=True
    Run Keyword If  ${peer_alarm_16_count} > 0
    ...  Log  ${peer_BTS} "Unit synchronization failed (16)" alarm, expected number: ${peer_alarm_16_count}  console=True

    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${peer_EXPECTED_ALARMS_full}
    ...  poll_interval=10 sec
    ...  ignored_alarms=${peer_IGNORED_ALARMS_full}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${peer_alarm_10_count} > 0
    ...  Log  ${peer_BTS} "No connection to unit (10)" alarm, found number: ${peer_alarm_10_count}, as expected!  console=True
    Run Keyword If  ${peer_alarm_10_1815_count} > 0
    ...  Log Long String  ${peer_BTS} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  found number: ${peer_alarm_10_1815_count}, as expected!  console=True
    Run Keyword If  ${peer_alarm_16_count} > 0
    ...  Log  ${peer_BTS} "Unit synchronization failed (16)" alarm, found number: ${peer_alarm_16_count}, as expected!  console=True

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
    END

Get and check KPI from IMS file
    [Arguments]  ${alias}  ${tech}  ${CYCLE}
    ${tech_kpi}=  Set Variable If  '${tech}'=='NR'  kpi10  '${tech}'=='LTE'  kpi7  '${tech}'=='WCDMA'  kpi8  '${tech}'=='GSM'  kpi9

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=${tech_kpi}  kpi_thresholds=${${tech}_RESET_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRAT_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRAT_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  ${tech_kpi}

    Export KPI Results to File  alias=${alias}  obj_info=RAT  obj=BTS KPI measurement
    ...  obj_type=${tech}  obj_id=${alias}
    ...  action_1=RAT_Reset  kpi_reported_1=${tech_kpi}  event_value_1=${kpi_delta_list[0]}
    ...  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=RAT_Reset action  add_info_value=${alias}

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Teardown
    Common Test Teardown

