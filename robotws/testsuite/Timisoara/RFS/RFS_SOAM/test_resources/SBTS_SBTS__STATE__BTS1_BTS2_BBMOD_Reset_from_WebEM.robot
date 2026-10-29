*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
Variables    tc_variables/sbts_sbts__state__bts1_bts2_bbmod_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                    # Number of BBMOD Reset operations on both BTS, default value 3
${BTS_LIST}       ALL                   # BTS list on which BBMOD Reset operation will be performed. Possible values (by default ALL):
                                        # - ALL: action will be performed on all BTS (Reset BBMODs on each BTS until last BTS from TL)
                                        # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py)
                                        # (ex. BTS1, BTS2) Leave default value for RFSplit
${ACTIVATE_CB010846}    ${False}        # Set to ${True} will commission parameters for CB010846 on test line and restore initial values at the end
                                        # Set to ${False} will not touch any of the parameters of CB010846, and will do the checks according to how
                                        # the feature is setup on the test line
${cntrldResetMplaneBreakTime}  420      # Maximum time when Radio Unit tries to re-establish released M-plane connection to BTS after baseband HW
                                        # reset.
                                        # Should be in range: 220 - 600 (seconds), by default 420
${EXCEPTED_FROM_CB007447_RMOD_SN}       # In case CB007447 is activated on the Test Line, user should indicate here separated by commas all SN of
                                        # CPRI RMOD from the Test Line that do not support CB007447.
                                        # These RMOD states will be checked according to legacy CPRI behavior when switching primaryLink
${EXCEPTED_FROM_CB010846_RMOD_SN}       # In case CB010846 is activated on the Test Line, user should indicate here separated by commas all SN of
                                        # any RMOD from the Test Line that do not support CB010846, which do not have one of following SW Lines:
                                        # 'MRM6', '5MF5', 'FRC3', 'TDL3', '5GH4', '5LL3', '5GL3'
                                        # For the RMODs with SN given here, and by default for all RMODs with SW Line in above list, no 'Uptime'
                                        # check will be done after BBMOD Reset
${BBMOD_RESET_WRN_THR}  270             # In accordance with KPI5 (time in seconds measured from first cell down to last cell up).
                                        # Default value: 270
${BBMOD_MAX_WAIT_TIME}  900             # Maximum time to wait for all RAT cells up after BBMOD reset
${RESET_BBMOD_TYPE_LIST}  ABIA, ABIL, ABIN, ABIO, ABIP, ABIQ  # BBMOD type list on which Reset operation is valid. User may add/remove BBMOD type
                                                              # according with BBMOD Reset operation validity
${BTS_PRIMARY_LINK}                     # RMOD and shared FHS primary link for modules directly connected into BBMOD,
                                        # set before BBMOD reset, possible values: empty (no set required),
                                        # BTS1 (BTS1 set required) or BTS2 (BTS2 set required), default value: empty
                                        # Leave empty for RFSplit
${SET_PRIMARY_LINK_TIME}     720        # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${HISTORICAL_ALARMS_CHECK}   True       # Flag to enable/disable historical alarms check; Possible values: True, False

*** Keywords ***
TC__SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22670
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BBMOD reset one by one, - x times sequence.
    ...
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS BBMOD, RMOD and CELL mapping info
    ...  - perform BBMOD reset on all BTS checking states and alarms
    ...  - check final state and alarms for all BTS
    ...  - check reset behavior on all BTS based on ims info as follows:
    ...   - BTS1: reset number is 0
    ...   - BTS2: reset number is 0
    ...  - get and check KPI5 info from IMS file
    ...  Pass criteria: BBMOD reset operation work as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  - 09.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22670 -
    ...  [5G][CB007124] New automated test case of SBTS_SBTS_BBMOD_Reset_from_WebEm
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 -
    ...  [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 10.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24303 -
    ...  [5G] SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM failed because of missing expected alarms and not completed within 60 sec
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24618 - [5G][KPI5] Please update BBMOD Reset to use KPI#5 measurements from
    ...  ims - SBTS_SBTS
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24195 - [5G][Reset Number ims2] Update SBTS-SBTS CM, STATE, FM
    ...  scenarios to take reset number from ims2 - P2
    ...  - 14.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25471 - [5G][CB008129] SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM
    ...  doesn't support dedicated RM
    ...  - 28.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26037 - [5G][CB007437] Update
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot for feature CB007437
    ...  - 01.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25865 - [5G][CB009472][CB008129]
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM handling ABIO reset with shared AHFII RM having primary link - with TAT-26319
    ...  - 08.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26319 - [5G][CB006142_CB008977_CB008978]
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM robot should be enhanced to take into consideration DSS alarms - with TAT-25865
    ...  - 08.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26397 - [5G] Teardown Admin failed for
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM testcase
    ...  - 24.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26471 - [5G][CB009472][CB008129]
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM fails due to variable "SBTS_EXPECTED_ALARMS_DSS" not found
    ...  - 25.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26409 - [5G][CB006142_CB008977_CB008978]
    ...  SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM robot should be enhanced to cover all cases: losing DATA LINK, losing CONFIG+DATA LINK,
    ...  losing CONFIG + DATA+SYNC LINK.
    ...  - 20.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26475 - [5G][CB009193] SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM robot
    ...  need to be used on SBTS_NR for 2 BTSs
    ...  - 03.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26601 - [5G][CB010914] Update NR_NR__STATE__BBMOD_Reset_from_WEBEM testcase
    ...  - 11.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26681 - [5G] SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM handling BBMOD
    ...  ABIA reset when action is not supported
    ...  - 23.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26714 - [5G] Support Shared OBSAI RMOD on NRL__STATE__LTE_BBMOD_Reset_from_WEBEM
    ...  - 23.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26624 - [5G][CB009182-C002270-RP003030]newNR_SBTS__STATE__BBMOD_Reset_from_WEBEM
    ...  TC which will run SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM In case of SBTS-NR configuration
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26876 -
    ...  [5G] Enhance SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot to wait for transitory state before reading the status of WDCMA cells
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26367 - [5G][CB009210] Update SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset for MHA
    ...  checks
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27194 - [5G] Check of DSS FID7509, 7511, 7513 to be included in NRL TestCase
    ...  NRL__STATE__BBMOD_Reset_from_WEBEM / SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27803 -
    ...  [CNI-127210] [Part 1] DSS LTE EXPECTED alarms check removal SBTS_* TCs
    ...  - 21.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27884 -
    ...  Add eCPRI FID16 exception for SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM (same as TAT-27868)
    ...  - 01.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28032 -
    ...  Adapt Automated_RFS_SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM to shared FHS configurations
    ...  - 19.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28317 -
    ...  NRL, NR_SBTS to generic -> SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WEBEM - after TAT-28032
    ...  - 28.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28488 - BBMOD Generic test enhancements
    ...  - 11.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29302 - BBMOD Generic Test adaptation for latest behavior of 7447 and CB010846
    ...  - 10.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29456 -
    ...  Adapt generic SBTS_SBTS__STATE__BTS1_BTS2_BBMOD_Reset_from_WebEM.robot to latest 7447 activation params
    ...  - 14.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29661 - Running some TC multiple times,
    ...  using 'runs' variable from suite generator, results in 1 successful run and rest of the runs unsuccessful
    ...  - 27.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30221 - Remove ${actForceUnitAutoReset}' in tests and KWs related to CB007447
    ...  - 03.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30579 - Check basic TA KWs RF 8 AXEGHA ORAN-ECPRI impact
    ...

    Set Tags    CA-STATE    OWNER-hinsa.petru@nokia.com    AUTHOR-ana.tugui@nokia.com    PHASE-QT    SW-SBTS22R3

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check CB010846 CB007447 feature settings
    Step 4: Get all BTS BBMOD, RMOD and CELL mapping info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER} + 1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform BBMOD Reset on all BTS for iteration ${INDEX}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
        Step 8: Check all BTS reset behavior based on IMS info during BBMOD reset
        Step 9: Check Historic Alarms
    END

    [Teardown]  Particular Teardown

TC Preconditions
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
    ${BTS_PRIMARY_LINK}=  Set Variable If  ${alias_number} < 2
    ...  ${Empty}  ${BTS_PRIMARY_LINK}
    Set Test Variable  ${BTS_PRIMARY_LINK}

    IF  '${BTS_LIST}' != 'ALL'
        Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    END
    Log  ====================================================  console=True
    Log  BTS label list selected for BBMOD Reset operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for BBMOD Reset operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

    ${RESET_BBMOD_TYPE_LIST_strip}=  Replace String  ${RESET_BBMOD_TYPE_LIST}  ${SPACE}  ${EMPTY}
    ${RESET_BBMOD_TYPE_LIST_split}=  Split String  ${RESET_BBMOD_TYPE_LIST_strip}  ,
    Set Test Variable  ${RESET_BBMOD_TYPE_LIST_split}
    ${TL_BBMOD_reset_check}=  Set Variable  ${FALSE}
    FOR  ${alias}  IN  @{alias_list}
        ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Log  TC Preconditions verification started on ${BTS}  console=True
        ${BBMOD_reset_check}=  Check BBMOD type reset info  ${RESET_BBMOD_TYPE_LIST_split}  ${alias}
        IF  ${BBMOD_reset_check}
            Log Long String  TC Preconditions passed on ${BTS}. Reset operation will be performed on valid BBMOD(s) from:
            ...  ${RESET_BBMOD_TYPE_LIST_split}
            ...  console=True
        ELSE
            Log Long String  TC Preconditions failed on ${BTS}. No BBMOD type valid for Reset operation found in:
            ...  ${RESET_BBMOD_TYPE_LIST_split}
            ...  console=True
        END
        Set Test Variable  ${${alias}_BBMOD_reset_check}  ${BBMOD_reset_check}
        ${TL_BBMOD_reset_check}=  Set Variable If  ${BBMOD_reset_check}  ${TRUE}  ${TL_BBMOD_reset_check}
    END
    IF  not ${TL_BBMOD_reset_check}
        Log Long String  TC Preconditions failed on TL. No BBMOD type valid for Reset operation found on any BTS.
        ...  Test execution will be stopped!
        ...  level=ERROR
        Fail  TC Preconditions failed on TL. No BBMOD type valid for Reset found on any BTS. Test execution will be stopped!
    END

    Set Test Variable  ${BBMOD_state_disabled_check}
    ...   operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${BBMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${BBMOD_state_disabled}
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${BBMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked

    Set Test Variable  ${RMOD_state_disabled_check}
    ...   operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked

    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Check CB010846 CB007447 feature settings
    [Documentation]
    ...  Check CB010846 feature settings on BTS

    Log  Step ${index}: Check CB010846 feature settings  console=True

    IF  ${ACTIVATE_CB010846}
        Log  - CB010846 feature parameters will be checked, and commissioned if found different than expected.  console=True
    ELSE
        Log  - CB010846 feature parameters will be checked, but not commissioned if found different than expected  console=True
        Log  - If feature is deactivated, the CB010846 specific checks will be skipped  console=True
    END

    FOR  ${alias}  IN  @{alias_list}

        Log  Check CB010846 feature settings on BTS ${alias}  console=True

        ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB010846_feature_dict_initial}  ${BTS_CB010846_feature_dict}

        IF  ${ACTIVATE_CB010846}
            Set classical BTS CB010846 feature parameter  actRuResetResiliency  true  ${alias}
            Set classical BTS CB010846 feature parameter  cntrldResetMplaneBreakTime  ${cntrldResetMplaneBreakTime}  ${alias}
        END

        ${BTS_CB010846_feature_dict}=  Get BTS CB010846 feature parameters  BTS_SCF_path_file=${${alias.lower()}_scf_initial}  alias=${alias}

        Set Test Variable  ${${alias}_BTS_CB010846_feature_dict_current}  ${BTS_CB010846_feature_dict}

    END

    Log  Get CB007447 feature status  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  Get CB007447 feature status on BTS ${alias}  console=True

        ${actCpriLinkRecovery}  ${actSyncLinkSwitchover}  ${cpriSyncBreakTime}  ${stickToSyncSourcePeriod}=  Get feature CB007447 info  ${alias}

        IF  '${actCpriLinkRecovery}' == 'true' and '${actSyncLinkSwitchover}' == 'true'
            Log  BTS ${alias} CB007447 feature status: Enabled  console=True
            Set Test Variable  ${${alias}_CB007447_status}  ${TRUE}
        ELSE
            Log  BTS ${alias} CB007447 feature status: Disabled  console=True
            Set Test Variable  ${${alias}_CB007447_status}  ${FALSE}
        END

    END

    ${CB007447_EXCEPTIONS}=  Set RMOD PrimaryLink Switch Behavior Check For Excepted CPRI RMOD  rmod_sn_string=${EXCEPTED_FROM_CB007447_RMOD_SN}
    Set Test Variable  ${CB007447_EXCEPTIONS}
    ${CB010846_EXCEPTIONS}=  Create Dictionary  exception_for_CB010846_eligible=${EXCEPTED_FROM_CB010846_RMOD_SN}
    Set Test Variable  ${CB010846_EXCEPTIONS}

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  \nStep ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
        Get and Check ALD state info  alias=${alias}
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  \nStep ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS BBMOD, RMOD and CELL mapping info
    [Documentation]
    ...  Get all BTS BBMOD, RMOD and CELL mapping info

    Log  \nStep ${index}: Get all BTS BBMOD, RMOD and CELL mapping info  console=True

    FOR  ${alias}  IN  @{alias_list}

        ${BBMOD_id_list}=  Get BBMOD id list  ${alias}
        Set Test Variable  ${${alias}_BBMOD_id_list}  ${BBMOD_id_list}

        ${NR_CELL_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        Sort List  ${NR_CELL_id_list}
        Set Test Variable  ${${alias}_NR_CELL_id_list}  ${NR_CELL_id_list}

        ${LTE_CELL_id_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
        Sort List  ${LTE_CELL_id_list}
        Set Test Variable  ${${alias}_LTE_CELL_id_list}  ${LTE_CELL_id_list}

        ${WCDMA_CELL_id_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
        Sort List  ${WCDMA_CELL_id_list}
        Set Test Variable  ${${alias}_WCDMA_CELL_id_list}  ${WCDMA_CELL_id_list}

        ${GSM_CELL_id_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
        Sort List  ${GSM_CELL_id_list}
        Set Test Variable  ${${alias}_GSM_CELL_id_list}  ${GSM_CELL_id_list}

        ${BBMOD_id_CELL_id_dict}  ${BBMOD_id_CELL_id_dict_scf_dict}=  Get BBMOD CELL mapping based on BBPOOL info from SCF  ${alias}
        Set Test Variable  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id_CELL_id_dict}

        ${FHS_sn_id_dict}  ${FHS_id_sn_dict}=  Get FHS id sn info dict  ${alias}
        Set Test Variable  ${${alias}_FHS_sn_id_dict}  ${FHS_sn_id_dict}
        Set Test Variable  ${${alias}_FHS_id_sn_dict}  ${FHS_id_sn_dict}

        ${RMOD_sn_id_dict}  ${RMOD_id_sn_dict}=  Get RM id sn info dict  ${alias}
        Set Test Variable  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn_id_dict}
        Set Test Variable  ${${alias}_RMOD_id_sn_dict}  ${RMOD_id_sn_dict}

        ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
        Set Test Variable  ${${alias}_RM_L3Protocol_dict}  ${RM_L3Protocol_dict}

    END

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}

Step ${index}: Perform BBMOD Reset on all BTS for iteration ${CYCLE}
    Log  \nStep ${index}: Perform BBMOD Reset on all BTS  console=True

    Get Current Date UTC info  start

    FOR  ${alias}  IN  @{BTS_alias_list}

        Perform BBMOD Reset on BTS  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  \nStep ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Check all BTS reset behavior based on IMS info during BBMOD reset
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - BTS1: reset number is 0
    ...  - BTS2: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  \nStep ${index}: Check all BTS reset behavior based on IMS info  console=True

    Get Current Date UTC info  end

    FOR  ${alias}  IN  @{alias_list}

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
        ...  remove_ims_file=False

    END

Step ${index}: Check Historic Alarms
    [Documentation]
    ...  check historic alarms for BBMOD autoreset
    ...  no historic autoreset alarm expected
    ...  Otherwise, BBMOD reset behavior not as expected, then errors are added to report and failed

    IF  ${HISTORICAL_ALARMS_CHECK}==False
        Log  Historical Alarms Check will be skipped.  console=True
        RETURN
    END
    Log  \nStep ${index}: Check NR and LTE Historic alarms  console=True

    FOR  ${alias_item}  IN  @{alias_list}

        ${IGNORED_HISTORICAL_ALARMS}=  Combine Lists  ${test_alarms_list['${alias_item.upper()}_IGNORED_ALARMS']}
        ...  ${test_alarms_list['${alias_item.upper()}_IGNORED_ALARMS_DURING_RESET']}
        ...  ${test_alarms_list['${alias_item.upper()}_EXPECTED_ALARMS_10_1815']}
        ...  ${test_alarms_list['${alias_item.upper()}_EXPECTED_ALARMS_10']}
        ...  ${test_alarms_list['${alias_item.upper()}_EXPECTED_ALARMS_16']}

        Eval Historic Alarms  connection=Master    expected_alarms=@{EMPTY}  ignored_alarms=${IGNORED_HISTORICAL_ALARMS}
        ...  critical_alarms=${test_alarms_list['${alias_item.upper()}_CRITICAL_ALARMS']}  ignore_unexpected=False

    END

Set RMOD PrimaryLink Switch Behavior Check For Excepted CPRI RMOD
    [Arguments]    ${rmod_sn_string}

    IF    '${rmod_sn_string}'==''    RETURN    &{Empty}
    ${sharing_type_protocol} =  Create List  SHARED_DEDICATED  ('CPRI_no_CB007447',)
    ${excepted_CPRI_RMOD_from_CB007447}=  Create Dictionary  ${rmod_sn_string}  ${sharing_type_protocol}
    RETURN    ${excepted_CPRI_RMOD_from_CB007447}

Set shared CPRI eCPRI RMOD and FHS Primary Link before NR BBMOD Reset operation
    [Arguments]  ${BBMOD_id}  ${alias}

    [Documentation]
    ...  Set shared RMOD and shared FHS Primary Link if needed

    Log  Set shared RMOD and Shared FHS Primary Link before NR BBMOD Reset operation  console=True
    IF  '${BTS_PRIMARY_LINK}' == ''
        Log  ==================================================================================  console=True
        Log  ***** Test action will be performed with existing RMOD Primary Link configuration *****  console=True
        Log  ==================================================================================  console=True
        RETURN
    ELSE
        Log  ========================================================================================================
        ...  console=True
        Log  ***** Test action will be performed with Primary Link set for RMODS and FHS on ${BTS_PRIMARY_LINK} *****
        ...  console=True
        Log  ====================================================================================================
        ...  console=True
    END

    IF  '${BTS_PRIMARY_LINK}' in ['BTS1','BTS2']
        ${alias_primary_link}=    Get From Dictionary  ${BTS_label_alias_dict}  ${BTS_PRIMARY_LINK}
    END

    ${BBMOD_id_list}=  Create List  ${BBMOD_id}
    ${BBMOD_id_dict}=  Create Dictionary  Equipment_enabled=${BBMOD_id_list}
    ${BBMOD_equipment_dict}  ${BBMOD_detailed_equipment_dict}=
    ...  Get BTS equipment connected by Cablink
    ...  ${BBMOD_id_dict}
    ...  ${alias}
    ...  Max_equipment_level=${1}
    ...  Reset_dependency_rules=${Reset_dependency_rules}

    ${BBMOD_RMOD_SN_LIST}=  Get Combined List From dictionary
    ...  ${BBMOD_detailed_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_ECPRI_enabled_SN  SHARED_RMOD_ECPRI_NETCONF_enabled_SN
    ${FHS_SN_list}=  Get From dictionary
    ...  ${BBMOD_detailed_equipment_dict}
    ...  SHARED_FHS_CPRI_enabled_SN

    IF  '${BTS_PRIMARY_LINK}' not in ['BTS1','BTS2'] and '${BTS_PRIMARY_LINK}' != ''
        Log  Please set proper values for test argument \${BTS_PRIMARY_LINK}- Follow parameter description!  level=ERROR
        Fail  Improper value for argument!
    END
    IF  '${BTS_PRIMARY_LINK}' in ['BTS1','BTS2'] and @{BBMOD_RMOD_SN_list} != @{Empty}
        Set Primary Link status based on linkModeSynchronization  module_type=RMOD
        ...  procedure_for_Primary_Link_set=LANE  alias=${alias_primary_link}
        ...  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
        ...  module_SN_list=${BBMOD_RMOD_SN_list}
    END
    IF  '${BTS_PRIMARY_LINK}' in ['BTS1','BTS2'] and @{FHS_SN_list} != @{Empty}
        Set Primary Link status based on linkModeSynchronization  module_type=FHS
        ...  procedure_for_Primary_Link_set=LANE  alias=${alias_primary_link}
        ...  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}  module_SN_list=${FHS_SN_list}
    END


Check BBMOD type reset info
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${alias}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}
    ${BBMOD_param_list}=  Get Parameters For All  class_name=BBMOD  connection=${alias}

    FOR  ${item}  IN  @{BBMOD_param_list}

        ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST}  ${item.productName}
        IF  ${BBMOD_reset_check}    BREAK

    END

    RETURN  ${BBMOD_reset_check}

Check BBMOD reset validity
    [Arguments]  ${RESET_BBMOD_TYPE_LIST}  ${productName}
    ${BBMOD_reset_check}=  Set Variable  ${FALSE}

    FOR  ${item}  IN  @{RESET_BBMOD_TYPE_LIST}

        ${BBMOD_reset_check}=  Set Variable If  '${item}' in '${productName}'  ${TRUE}  ${BBMOD_reset_check}
        IF  '${item}' in '${productName}'    BREAK

    END

    RETURN  ${BBMOD_reset_check}

Perform BBMOD Reset on BTS
    [Arguments]  ${alias}  ${CYCLE}

    ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    IF  not ${${alias}_BBMOD_reset_check}
        Log  Test execution will be skipped on ${BTS} due to TC Preconditions check!  console=True
        RETURN
    END

    FOR  ${item}  IN  @{${alias}_BBMOD_id_list}

        ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
        Set Test Variable  ${BTS}

        ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${item}  connection=${alias}
        Set Test Variable  ${BBMOD_prodName}  ${BBMOD_param['productName']}
        Set Test Variable  ${BBMOD_sn}  ${BBMOD_param['serialNumber']}

        Log  \nPerform "Reset" operation on BBMOD with SN ${BBMOD_sn} from ${BTS}:  console=True

        ${BBMOD_reset_check}=  Check BBMOD reset validity  ${RESET_BBMOD_TYPE_LIST_split}  ${BBMOD_prodName}
        IF  not ${BBMOD_reset_check}
            Log  "Reset" operation on BBMOD with SN ${BBMOD_sn} from ${BTS} will be skipped: BBMOD productName not allowed!  console=True
            CONTINUE
        END

        ${BBMOD_CELL_list_BBPOOL}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${item}
        IF  'ABIA' in '${BBMOD_prodName}'
            ${BBMOD_ABIA_reset_allowed}=    Check BBMOD ABIA Reset  ${item}  ${BBMOD_CELL_list_BBPOOL}  ${alias}
        ELSE
            ${BBMOD_ABIA_reset_allowed}=    Set Variable  True
        END
        IF  not ${BBMOD_ABIA_reset_allowed}
            Log  "Reset" operation on BBMOD ${BBMOD_sn} from ${BTS} will be skipped: BBMOD ABIA processing multiple RAT cells!  console=True
            CONTINUE
        END

        Reset BBMOD  ${item}  ${alias}  ${BTS}  ${CYCLE}

        Check peer BTS CPRI shared RMODs status with CB007447 feature activated
        ...  ${date_timestamp_start_resetBBMOD_UTC}  ${date_timestamp_end_resetBBMOD_UTC}  ${peer_aliases}

        Check all BTS requested RMOD reset behavior based on Uptime info  ${alias}  ${peer_aliases}

        Get and check KPI5 info from IMS file  ${item}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    END

Reset BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${BTS}  ${CYCLE}

    Set shared CPRI eCPRI RMOD and FHS Primary Link before NR BBMOD Reset operation
    ...  ${BBMOD_id}  ${alias}

    Log  Reset BBMOD during cycle ${CYCLE}  console=True

    ${local_CB007447_status}=  Set Variable  ${${alias}_CB007447_status}

    Get BTSs impact info due to reset BBMOD  BBMOD_id=${BBMOD_id}  alias=${alias}  cb007447_status=${local_CB007447_status}
    ...  CB007447_EXCEPTIONS=${CB007447_EXCEPTIONS}  CB010846_EXCEPTIONS=${CB010846_EXCEPTIONS}

    IF  ${own_BBMOD_shared_CPRI_RMOD_sn_list_10846} and ${${alias}_CB007447_status}
        Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared CPRI RMODs eligible for CB010846:  console=True
        Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${own_BBMOD_shared_CPRI_RMOD_sn_list_10846}
    END
    IF  ${own_BBMOD_shared_ECPRI_RMOD_sn_list_10846}
        Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared ECPRI RMODs eligible for CB010846:  console=True
        Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${own_BBMOD_shared_ECPRI_RMOD_sn_list_10846}
    END
    IF  ${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}
        Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared ECPRI NETCONF RMODs eligible for CB010846:  console=True
        Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}
    END

    ${BTS_alias_RMOD_sn_Uptime_dict_initial}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_initial}

    ${new_alias}=  Set Variable  resetBBMOD
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}
    Get Current Time  initial
    Get Current Date UTC info  start_resetBBMOD
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${BBMOD_id}  reset_type=Warm  timeout=${BBMOD_MAX_WAIT_TIME}
    ...  connection=${new_alias}

    Check BTS status and alarms during reset BBMOD  ${BBMOD_id}  ${alias}  ${BTS}
    Check peer BTS status and alarms during reset BBMOD  ${peer_aliases}  ${peer_btses}

    Collect Keyword Result  ${reset_info}  timeout=${BBMOD_MAX_WAIT_TIME}

    Check BTS status and alarms after reset BBMOD  ${BBMOD_id}  ${alias}  ${BTS}
    Check peer BTS status and alarms after reset BBMOD  ${peer_aliases}  ${peer_btses}

    Sleep  60s  reason=Allow RMOD uptime update in BTS after BBMOD reset
    Get Current Date UTC info  end_resetBBMOD

    [Teardown]  Teardown Admin  alias=${new_alias}

Check BTS status and alarms during reset BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${BTS}

    Log  \nCheck ${BTS} state and alarms during reset BBMOD with SN ${BBMOD_sn} from ${BTS}:  console=True
    Sleep  time_=10s  reason=Avoid items transitory states
    Log  - Check ${BTS} BBMOD with SN ${BBMOD_sn} status:  console=True
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_disabled_check}  timeout=${BBMOD_MAX_WAIT_TIME}  connection=${alias}
    Log  - BBMOD ${BBMOD_id} status:\n - ${BBMOD_state_disabled} as expected  console=True

    Check BTS status during reset BBMOD impact on connected FHSs
    ...  ${expected_own_BTS_enabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_disabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_FHS_id_list}  ${alias}

    Check BTS status during reset BBMOD impact on connected RMODs
    ...  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${alias}

    Check BTS status during reset BBMOD impact on BBMOD cells   ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}
    ...  ${BBMOD_GSM_CELL_id_list}  ${alias}

    Check BTS status during reset BBMOD impact on connected RMODs cells  ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}
    ...  ${BBMOD_impacted_WCDMA_CELL_id_list}  ${BBMOD_impacted_GSM_CELL_id_list}  ${alias}

    Log  - Check ${BTS} alarms:  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{Empty}
    ...  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS_DURING_RESET']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}

    Log  - ${BTS} site - expected, ignored and critical alarms checked  console=True

Check peer BTS status and alarms during reset BBMOD
    [Arguments]  ${peer_aliases}  ${peer_btses}

    FOR  ${peer_alias}  ${peer_bts}  IN ZIP  ${peer_aliases}  ${peer_btses}

        Log  Check ${peer_BTS} state and alarms during reset BBMOD with SN ${BBMOD_sn} from ${BTS}:  console=True
        Check peer BTS status during reset BBMOD impact on connected FHSs
        ...  ${expected_${peer_alias}_enabled_shared_FHS_id_list}
        ...  ${expected_${peer_alias}_disabled_shared_FHS_id_list}  ${peer_alias}

        Check peer BTS status during reset BBMOD impact on connected RMODs
        ...  ${expected_${peer_alias}_enabled_shared_RMOD_id_list}
        ...  ${expected_${peer_alias}_disabled_shared_RMOD_id_list}
        ...  ${expected_${peer_alias}_enabled_dedicated_RMOD_id_list}
        ...  ${expected_${peer_alias}_disabled_dedicated_RMOD_id_list}  ${peer_alias}  ${peer_bts}

        Log  Check ${peer_bts} alarms:  console=True
        IF  ${${peer_alias}_OBSAI_FID10_alarm_count} > 0
            Log  ${peer_bts} "No connection to Unit (10)" alarm, expected number: ${${peer_alias}_OBSAI_FID10_alarm_count}  console=True
        END
        IF  ${${peer_alias}_CPRI_FID10_1815_alarm_count} > 0
            Log Long String  ${peer_BTS} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, expected number:
            ...  ${${peer_alias}_CPRI_FID10_1815_alarm_count}  console=True
        END
        IF  ${${peer_alias}_ECPRI_FID16_alarm_count} > 0
            Log  ${peer_bts} "Unit synchronization failed (16)" alarm, expected number: ${${peer_alias}_ECPRI_FID16_alarm_count}  console=True
        END

        Get and Check Alarms SOAM  alias=${peer_alias}  poll_interval=5  expected_alarms=${${peer_alias}_EXPECTED_ALARMS_10_1815_16}
        ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS_DURING_RESET']}
        ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
        IF  ${${peer_alias}_OBSAI_FID10_alarm_count} > 0
            Log  ${peer_bts} "No connection to Unit (10)" alarm, found number: ${${peer_alias}_OBSAI_FID10_alarm_count}, as expected!
            ...  console=True
        END
        IF  ${${peer_alias}_CPRI_FID10_1815_alarm_count} > 0
            Log Long String  ${peer_bts} "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm, found number:
            ...  ${${peer_alias}_CPRI_FID10_1815_alarm_count}, as expected!  console=True
        END
        IF  ${${peer_alias}_ECPRI_FID16_alarm_count} > 0
            Log  ${peer_bts} "Unit synchronization failed (16)" alarm, found number: ${${peer_alias}_ECPRI_FID16_alarm_count}, as expected!
            ...  console=True
        END

    END

Check BTS status and alarms after reset BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${BTS}

    Log  Check ${BTS} state and alarms after reset BBMOD with SN ${BBMOD_sn} from ${BTS}:  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Log  Check ${BTS} BBMOD with SN ${BBMOD_sn} status:  console=True
    Assert  class_name=BBMOD  id=${BBMOD_id}  parameters=${BBMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BBMOD ${BBMOD_id} status:\n - ${BBMOD_state_enabled} as expected  console=True

    Check BTS status after reset BBMOD impact on connected FHSs
    ...  ${expected_own_BTS_enabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_disabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_FHS_id_list}  ${alias}

    Check BTS status after reset BBMOD impact on connected RMODs
    ...  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${alias}

    Log  Check ${BTS} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All ${BTS} cells status:\n - ${CELL_state_enabled}  console=True

    Log  Check ${BTS} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
    ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True

    Log  Check ${BTS} ALDs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Get and Check ALD state info  alias=${alias}  timeout=${remained_MAX_WAIT_TIME}
    Log  All ${BTS} ALDs status:\n  console=True

Check peer BTS status and alarms after reset BBMOD
    [Arguments]  ${peer_aliases}  ${peer_btses}

    FOR  ${peer_alias}  ${peer_bts}  IN ZIP  ${peer_aliases}  ${peer_btses}

        Log  Check ${peer_bts} state and alarms after reset BBMOD with SN ${BBMOD_sn} from ${BTS}:  console=True

        Check peer BTS status after reset BBMOD impact on connected FHSs
        ...  ${expected_${peer_alias}_enabled_shared_FHS_id_list}
        ...  ${expected_${peer_alias}_disabled_shared_FHS_id_list}  ${peer_alias}

        Check peer BTS status after reset BBMOD impact on connected RMODs
        ...  ${expected_${peer_alias}_enabled_shared_RMOD_id_list}
        ...  ${expected_${peer_alias}_disabled_shared_RMOD_id_list}
        ...  ${expected_${peer_alias}_enabled_dedicated_RMOD_id_list}
        ...  ${expected_${peer_alias}_disabled_dedicated_RMOD_id_list}  ${peer_alias}  ${peer_bts}

        Log  Check ${peer_bts} cells status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
        Check cells availability status online  ${peer_alias}  ${remained_MAX_WAIT_TIME}
        Log  All ${peer_bts} cells status:\n - ${CELL_state_enabled}  console=True

        Log  Check ${peer_bts} alarms:  console=True
        Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${test_alarms_list['${peer_alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${peer_alias.upper()}_CRITICAL_ALARMS']}
        Log  ${peer_bts} site - expected, ignored and critical alarms checked  console=True

    END

Select dependency rule and exceptions based on cb007447 status
    [Arguments]    ${cb007447_status}  ${CB007447_EXCEPTIONS}

    ${dependency_rules_dict_name}=  Set Variable If  ${cb007447_status}  Reset_dependency_rules_CB007447  Reset_dependency_rules
    ${dependency_rules_dict}=  Get Variable Value  ${${dependency_rules_dict_name}}

    ${exceptions}=  Set Variable If  ${cb007447_status}  ${CB007447_EXCEPTIONS}  &{Empty}
    RETURN    ${dependency_rules_dict}  ${exceptions}

Get BTSs impact info due to reset BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}  ${cb007447_status}  ${CB007447_EXCEPTIONS}=&{Empty}  ${CB010846_EXCEPTIONS}=&{Empty}

    ${dependency_rules_dict}  ${exceptions_dict}=  Select dependency rule and exceptions based on cb007447 status
    ...  ${cb007447_status}  ${CB007447_EXCEPTIONS}

    ${BBMOD_id_list}=  Create List  ${BBMOD_id}
    ${BBMOD_id_dict}=  Create Dictionary  Equipment_reset=${BBMOD_id_list}
    ${TL_detailed_equipment_dict}=  Get Testline equipment connected by Cablink
    ...  ${BBMOD_id_dict}
    ...  ${alias}
    ...  ${alias_list}
    ...  Reset_dependency_rules=${dependency_rules_dict}
    ...  CPRI_SN_EXCEPTIONS=${exceptions_dict}
    ...  ECPRI_SN_EXCEPTIONS=&{Empty}
    ...  ECPRI_NETCONF_SN_EXCEPTIONS=&{Empty}
    ...  OBSAI_SN_EXCEPTIONS=&{Empty}
    ...  CB010846_EXCEPTIONS=${CB010846_EXCEPTIONS}
    ${detailed_dependent_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${alias}

    ${peer_aliases}=  Get Dictionary Keys  ${TL_detailed_equipment_dict}
    Remove Values From List  ${peer_aliases}  ${alias}
    Set Test Variable  ${peer_aliases}

    ${peer_btses}=  Create List

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${peer_bts}=  Get From Dictionary  ${BTS_alias_label_dict}  ${peer_alias}
        Append To List  ${peer_btses}  ${peer_bts}

    END

    Set Test Variable  ${peer_btses}

    Get BBMOD Reset impact on BTS  detailed_dependent_equipment_dict=${detailed_dependent_equipment_dict}
    Get BBMOD Reset impact on BTS cells
    ...  alias=${alias}
    ...  BBMOD_id=${BBMOD_id}
    ...  expected_own_BTS_disabled_shared_RMOD_id_list=${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  expected_own_BTS_disabled_dedicated_RMOD_id_list=${expected_own_BTS_disabled_dedicated_RMOD_id_list}

    Get BBMOD Reset impact on peer BTS  peer_aliases=${peer_aliases}  TL_detailed_equipment_dict=${TL_detailed_equipment_dict}
    Get BBMOD Reset impact on peer BTS cells
    ...  peer_aliases=${peer_aliases}
    Get alarms during BBMOD Reset on peer BTS  peer_aliases=${peer_aliases}
    ...  TL_detailed_equipment_dict=${TL_detailed_equipment_dict}

Get BBMOD Reset impact on BTS
    [Arguments]    ${detailed_dependent_equipment_dict}

    ${expected_own_BTS_enabled_shared_FHS_id_list}=
    ...  Get From Dictionary  ${detailed_dependent_equipment_dict}  SHARED_FHS_CPRI_enabled
    ${expected_own_BTS_disabled_shared_FHS_id_list}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_FHS_CPRI_disabled
    ${expected_own_BTS_enabled_dedicated_FHS_id_list}=
    ...  Get From Dictionary  ${detailed_dependent_equipment_dict}  DEDICATED_FHS_CPRI_enabled
    ${expected_own_BTS_disabled_dedicated_FHS_id_list}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_FHS_CPRI_disabled

    ${expected_own_BTS_enabled_shared_RMOD_id_list}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled  SHARED_RMOD_ECPRI_enabled  SHARED_RMOD_ECPRI_NETCONF_enabled  SHARED_RMOD_OBSAI_enabled
    ${expected_own_BTS_disabled_shared_RMOD_id_list}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_disabled  SHARED_RMOD_ECPRI_disabled  SHARED_RMOD_ECPRI_NETCONF_disabled  SHARED_RMOD_OBSAI_disabled
    ${expected_own_BTS_enabled_dedicated_RMOD_id_list}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled  DEDICATED_RMOD_ECPRI_enabled  DEDICATED_RMOD_ECPRI_NETCONF_enabled  DEDICATED_RMOD_OBSAI_enabled
    ${expected_own_BTS_disabled_dedicated_RMOD_id_list}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_disabled  DEDICATED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_OBSAI_disabled

    ${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_CPRI_disabled_SN
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_CB010846_eligible  SHARED_RMOD_CPRI_disabled_CB010846_eligible
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_CPRI_enabled_connected_in  SHARED_RMOD_CPRI_disabled_connected_in
    ${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_connected_in}]

    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_sn}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_enabled_SN  SHARED_RMOD_ECPRI_disabled_SN
    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_eligible}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_enabled_CB010846_eligible  SHARED_RMOD_ECPRI_disabled_CB010846_eligible
    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_connected_in}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_enabled_connected_in  SHARED_RMOD_ECPRI_disabled_connected_in
    ${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_connected_in}]

    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_sn}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_NETCONF_enabled_SN  SHARED_RMOD_ECPRI_NETCONF_disabled_SN
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_eligible}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_NETCONF_enabled_CB010846_eligible  SHARED_RMOD_ECPRI_NETCONF_disabled_CB010846_eligible
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  SHARED_RMOD_ECPRI_NETCONF_enabled_connected_in  SHARED_RMOD_ECPRI_NETCONF_disabled_connected_in
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}]

    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled_SN  DEDICATED_RMOD_CPRI_disabled_SN
    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled_CB010846_eligible  DEDICATED_RMOD_CPRI_disabled_CB010846_eligible
    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_CPRI_enabled_connected_in  DEDICATED_RMOD_CPRI_disabled_connected_in
    ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_connected_in}]

    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_enabled_SN  DEDICATED_RMOD_ECPRI_disabled_SN
    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_enabled_CB010846_eligible  DEDICATED_RMOD_ECPRI_disabled_CB010846_eligible
    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_enabled_connected_in  DEDICATED_RMOD_ECPRI_disabled_connected_in
    ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_connected_in}]

    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_sn}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_SN  DEDICATED_RMOD_ECPRI_NETCONF_disabled_SN
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_eligible}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_CB010846_eligible  DEDICATED_RMOD_ECPRI_NETCONF_disabled_CB010846_eligible
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}=
    ...  Get Combined List From Dictionary  ${detailed_dependent_equipment_dict}
    ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_connected_in  DEDICATED_RMOD_ECPRI_NETCONF_disabled_connected_in
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}=
    ...  Evaluate  [x!='FHS' for x in ${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_connected_in}]

    ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_CPRI_RMOD_for_CB010846_not_connected_in_fhs}
    ${expected_own_BTS_dedicated_CPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_CPRI_RMOD_for_CB010846_not_connected_in_fhs}
    ${expected_own_BTS_shared_ECPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}
    ${expected_own_BTS_dedicated_ECPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}
    ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}
    ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
    ...  elements_to_be_filtered=${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_sn}
    ...  list1_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_eligible}
    ...  list2_containing_filtering_criteria_flags=${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}

    Set Test Variable  ${expected_own_BTS_enabled_shared_FHS_id_list}
    Set Test Variable  ${expected_own_BTS_disabled_shared_FHS_id_list}
    Set Test Variable  ${expected_own_BTS_enabled_dedicated_FHS_id_list}
    Set Test Variable  ${expected_own_BTS_disabled_dedicated_FHS_id_list}
    Set Test Variable  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    Set Test Variable  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    Set Test Variable  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    Set Test Variable  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}

    Set Test Variable  ${own_BBMOD_shared_CPRI_RMOD_sn_list_10846}  ${expected_own_BTS_shared_CPRI_RMOD_supporting_CB010846_sn}
    Set Test Variable  ${own_BBMOD_dedicated_CPRI_RMOD_sn_list_10846}  ${expected_own_BTS_dedicated_CPRI_RMOD_supporting_CB010846_sn}
    Set Test Variable  ${own_BBMOD_shared_ECPRI_RMOD_sn_list_10846}  ${expected_own_BTS_shared_ECPRI_RMOD_supporting_CB010846_sn}
    Set Test Variable  ${own_BBMOD_dedicated_ECPRI_RMOD_sn_list_10846}  ${expected_own_BTS_dedicated_ECPRI_RMOD_supporting_CB010846_sn}
    Set Test Variable  ${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}  ${expected_own_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}
    Set Test Variable  ${own_BBMOD_dedicated_ECPRI_NETCONF_RMOD_sn_list_10846}
    ...  ${expected_own_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}

Get BBMOD Reset impact on peer BTS
    [Arguments]    ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}
        ${expected_peer_BTS_enabled_shared_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled  SHARED_RMOD_ECPRI_enabled  SHARED_RMOD_ECPRI_NETCONF_enabled  SHARED_RMOD_OBSAI_enabled
        ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled  DEDICATED_RMOD_ECPRI_enabled  DEDICATED_RMOD_ECPRI_NETCONF_enabled  DEDICATED_RMOD_OBSAI_enabled

        ${expected_peer_BTS_disabled_shared_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_disabled  SHARED_RMOD_ECPRI_disabled  SHARED_RMOD_ECPRI_NETCONF_disabled  SHARED_RMOD_OBSAI_disabled
        ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_disabled  DEDICATED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_OBSAI_disabled

        ${expected_peer_BTS_disabled_RMOD_id_list}=  Combine Lists
        ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
        ...  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}

        ${expected_peer_BTS_enabled_shared_FHS_id_list}=  Get From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_FHS_CPRI_enabled
        ${expected_peer_BTS_disabled_shared_FHS_id_list}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_FHS_CPRI_disabled

        ${expected_peer_BTS_RMOD_CPRI_for_7447_check}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled

        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_SN  SHARED_RMOD_CPRI_disabled_SN
        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_CB010846_eligible  SHARED_RMOD_CPRI_disabled_CB010846_eligible
        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_CPRI_enabled_connected_in  SHARED_RMOD_CPRI_disabled_connected_in
        ${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_connected_in}]

        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_enabled_SN  SHARED_RMOD_ECPRI_disabled_SN
        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_enabled_CB010846_eligible  SHARED_RMOD_ECPRI_disabled_CB010846_eligible
        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_enabled_connected_in  SHARED_RMOD_ECPRI_disabled_connected_in
        ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_connected_in}]

        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_NETCONF_enabled_SN  SHARED_RMOD_ECPRI_NETCONF_disabled_SN
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_NETCONF_enabled_CB010846_eligible  SHARED_RMOD_ECPRI_NETCONF_disabled_CB010846_eligible
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  SHARED_RMOD_ECPRI_NETCONF_enabled_connected_in  SHARED_RMOD_ECPRI_NETCONF_disabled_connected_in
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}]

        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled_SN  DEDICATED_RMOD_CPRI_disabled_SN
        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled_CB010846_eligible  DEDICATED_RMOD_CPRI_disabled_CB010846_eligible
        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_CPRI_enabled_connected_in  DEDICATED_RMOD_CPRI_disabled_connected_in
        ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_connected_in}]

        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_enabled_SN  DEDICATED_RMOD_ECPRI_disabled_SN
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_enabled_CB010846_eligible  DEDICATED_RMOD_ECPRI_disabled_CB010846_eligible
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_enabled_connected_in  DEDICATED_RMOD_ECPRI_disabled_connected_in
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_connected_in}]

        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_sn}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_SN  DEDICATED_RMOD_ECPRI_NETCONF_disabled_SN
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_eligible}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_CB010846_eligible  DEDICATED_RMOD_ECPRI_NETCONF_disabled_CB010846_eligible
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}=  Get Combined List From Dictionary
        ...  ${detailed_dependent_peer_equipment_dict}
        ...  DEDICATED_RMOD_ECPRI_NETCONF_enabled_connected_in  DEDICATED_RMOD_ECPRI_NETCONF_disabled_connected_in
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}=
        ...  Evaluate  [x!='FHS' for x in ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_connected_in}]

        ${expected_peer_BTS_shared_CPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_shared_CPRI_RMOD_for_CB010846_not_connected_in_fhs}
        ${expected_peer_BTS_shared_ECPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}
        ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}
        ${expected_peer_BTS_dedicated_CPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_CPRI_RMOD_for_CB010846_not_connected_in_fhs}
        ${expected_peer_BTS_dedicated_ECPRI_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_RMOD_for_CB010846_not_connected_in_fhs}
        ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}=  Filter RMOD depending on feature
        ...  elements_to_be_filtered=${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_sn}
        ...  list1_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_eligible}
        ...  list2_containing_filtering_criteria_flags=${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_for_CB010846_not_connected_in_fhs}

        Set Test Variable  ${expected_${peer_alias}_enabled_shared_RMOD_id_list}  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_shared_RMOD_id_list}  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_RMOD_id_list}  ${expected_peer_BTS_disabled_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_enabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
        Set Test Variable  ${expected_${peer_alias}_enabled_shared_FHS_id_list}  ${expected_peer_BTS_enabled_shared_FHS_id_list}
        Set Test Variable  ${expected_${peer_alias}_disabled_shared_FHS_id_list}  ${expected_peer_BTS_disabled_shared_FHS_id_list}

        Set Test Variable  ${${peer_alias}_enabled_shared_CPRI_RMOD_id_list_7447}  ${expected_peer_BTS_RMOD_CPRI_for_7447_check}
        Set Test Variable  ${${peer_alias}_BBMOD_shared_CPRI_RMOD_sn_list_10846}  ${expected_peer_BTS_shared_CPRI_RMOD_supporting_CB010846_sn}
        Set Test Variable  ${${peer_alias}_dedicated_CPRI_RMOD_sn_list_10846}  ${expected_peer_BTS_dedicated_CPRI_RMOD_supporting_CB010846_sn}
        Set Test Variable  ${${peer_alias}_BBMOD_shared_ECPRI_RMOD_sn_list_10846}  ${expected_peer_BTS_shared_ECPRI_RMOD_supporting_CB010846_sn}
        Set Test Variable  ${${peer_alias}_dedicated_ECPRI_RMOD_sn_list_10846}  ${expected_peer_BTS_dedicated_ECPRI_RMOD_supporting_CB010846_sn}
        Set Test Variable  ${${peer_alias}_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}
        ...  ${expected_peer_BTS_shared_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}
        Set Test Variable  ${${peer_alias}_dedicated_ECPRI_NETCONF_RMOD_sn_list_10846}
        ...  ${expected_peer_BTS_dedicated_ECPRI_NETCONF_RMOD_supporting_CB010846_sn}

    END

Get alarms during BBMOD Reset on peer BTS
    [Arguments]    ${peer_aliases}  ${TL_detailed_equipment_dict}

    FOR  ${peer_alias}  IN  @{peer_aliases}

        ${detailed_dependent_peer_equipment_dict}=  Get From Dictionary  ${TL_detailed_equipment_dict}  ${peer_alias}
        ${peer_BTS_OBSAI_FID10_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}=
        ...  Get peer BTS alarms
        ...  ${detailed_dependent_peer_equipment_dict}  ${peer_alias}

        ${peer_SBTS_EXPECTED_ALARMS_10}=  Prepare expected alarms list
        ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10']}
        ...  ${peer_BTS_OBSAI_FID10_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_10_1815}=  Prepare expected alarms list
        ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_10_1815']}
        ...  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_16}=  Prepare expected alarms list
        ...  ${test_alarms_list['${peer_alias.upper()}_EXPECTED_ALARMS_16']}
        ...  ${peer_BTS_ECPRI_FID16_alarm_count}
        ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}=  Combine Lists
        ...  ${peer_SBTS_EXPECTED_ALARMS_10}  ${peer_SBTS_EXPECTED_ALARMS_10_1815}
        ...  ${peer_SBTS_EXPECTED_ALARMS_16}
        Set Test Variable  ${${peer_alias}_OBSAI_FID10_alarm_count}  ${peer_BTS_OBSAI_FID10_alarm_count}
        Set Test Variable  ${${peer_alias}_CPRI_FID10_1815_alarm_count}  ${peer_BTS_CPRI_FID10_1815_alarm_count}
        Set Test Variable  ${${peer_alias}_ECPRI_FID16_alarm_count}  ${peer_BTS_ECPRI_FID16_alarm_count}
        Set Test Variable  ${${peer_alias}_EXPECTED_ALARMS_10_1815_16}  ${peer_SBTS_EXPECTED_ALARMS_10_1815_16}

    END

Get BBMOD Reset impact on BTS cells
    [Arguments]    ${alias}  ${BBMOD_id}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}

    ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}  ${BBMOD_GSM_CELL_id_list}=
    ...  Get BTS cells mapped on BBMOD
    ...  ${BBMOD_id}  ${alias}
    Set Test Variable  ${BBMOD_NR_CELL_id_list}
    Set Test Variable  ${BBMOD_LTE_CELL_id_list}
    Set Test Variable  ${BBMOD_WCDMA_CELL_id_list}
    Set Test Variable  ${BBMOD_GSM_CELL_id_list}

    ${BBMOD_disabled_RMOD_id_list}=  Combine Lists  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  ${BBMOD_impacted_GSM_CELL_id_list}=  Get BTS cells mapped on RMOD impact due to reset BBMOD
    ...  ${BBMOD_id}  ${BBMOD_disabled_RMOD_id_list}
    ...  ${alias}
    Set Test Variable  ${BBMOD_impacted_NR_CELL_id_list}
    Set Test Variable  ${BBMOD_impacted_LTE_CELL_id_list}
    Set Test Variable  ${BBMOD_impacted_WCDMA_CELL_id_list}
    Set Test Variable  ${BBMOD_impacted_GSM_CELL_id_list}

Get BBMOD Reset impact on peer BTS cells
    [Arguments]    ${peer_aliases}

    FOR  ${peer_alias}  IN  @{peer_aliases}

         ${peer_BTS_impacted_NR_CELL_id_list}  ${peer_BTS_impacted_LTE_CELL_id_list}  ${peer_BTS_impacted_WCDMA_CELL_id_list}
        ...  ${peer_BTS_impacted_GSM_CELL_id_list}=  Get peer BTS cells mapped on RMOD impact due to reset BBMOD
        ...  ${expected_${peer_alias}_disabled_RMOD_id_list}  ${peer_alias}
        Set Test Variable  ${${peer_alias}_impacted_NR_CELL_id_list}  ${peer_BTS_impacted_NR_CELL_id_list}
        Set Test Variable  ${${peer_alias}_impacted_LTE_CELL_id_list}  ${peer_BTS_impacted_LTE_CELL_id_list}
        Set Test Variable  ${${peer_alias}_impacted_WCDMA_CELL_id_list}  ${peer_BTS_impacted_WCDMA_CELL_id_list}
        Set Test Variable  ${${peer_alias}_impacted_WCDMA_CELL_id_list}  ${peer_BTS_impacted_WCDMA_CELL_id_list}

    END

Get and check KPI5 info from IMS file
    [Documentation]
    ...  Get and check KPI5 info from IMS file.

    [Arguments]  ${BBMOD_id}  ${BBMOD_sn}  ${BBMOD_prodName}  ${CYCLE}  ${alias}

    Log  Get and check KPI5 info from IMS file on BTS ${alias} for iteration ${CYCLE}  console=True

    ${BBMOD_CELL_id_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}
    ${BBMOD_CELL_id_count}=  Get Length  ${BBMOD_CELL_id_list}
    IF  ${BBMOD_CELL_id_count} == 0
        Log  KPI5 calculation and reporting will be skipped because BBMOD with SN ${BBMOD_sn} does not process any cells
        ...  console=True
        RETURN
    END

    ${kpi_name_delta_dict_kpi5}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi5  kpi_thresholds=${BBMOD_RESET_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetBBMOD_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetBBMOD_UTC}
    ${kpi_delta_list_kpi5}=  Get From Dictionary  ${kpi_name_delta_dict_kpi5}  kpi5
    Export KPI Results to File  alias=${alias}  obj_info=BBMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${BBMOD_prodName}_${BBMOD_sn}  obj_id=${alias}  action_1=BBMOD_Reset  kpi_reported_1=KPI_5
    ...  event_value_1=${kpi_delta_list_kpi5[0]}  cycle=${CYCLE}  source_info=ims

Get BTS cells mapped on BBMOD
    [Arguments]  ${BBMOD_id}  ${alias}

    ${BBMOD_CELL_id_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}

    ${BBMOD_NR_CELL_id_list}=  Create List
    ${BBMOD_LTE_CELL_id_list}=  Create List
    ${BBMOD_WCDMA_CELL_id_list}=  Create List
    ${BBMOD_GSM_CELL_id_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_CELL_id_list}

        IF  '${item}' in ${${alias}_NR_CELL_id_list}
            Append To List  ${BBMOD_NR_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_LTE_CELL_id_list}
            Append To List  ${BBMOD_LTE_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_WCDMA_CELL_id_list}
            Append To List  ${BBMOD_WCDMA_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_GSM_CELL_id_list}
            Append To List  ${BBMOD_GSM_CELL_id_list}  ${item}
        END

    END

    RETURN  ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}  ${BBMOD_WCDMA_CELL_id_list}  ${BBMOD_GSM_CELL_id_list}

Get BTS cells mapped on RMOD impact due to reset BBMOD
    [Arguments]  ${BBMOD_id}  ${BBMOD_disabled_RMOD_id_list}  ${alias}

    ${BBMOD_CELL_id_list}=  Get From Dictionary  ${${alias}_BBMOD_id_CELL_id_dict}  ${BBMOD_id}

    ${BBMOD_disabled_RMOD_CELL_id_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_disabled_RMOD_id_list}

        ${CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${BBMOD_disabled_RMOD_CELL_id_list}  @{CELL_id_list}

    END

    ${BBMOD_disabled_RMOD_CELL_id_list}=  Remove Duplicates  ${BBMOD_disabled_RMOD_CELL_id_list}
    Sort List  ${BBMOD_disabled_RMOD_CELL_id_list}

    ${BBMOD_impacted_NR_CELL_id_list}=  Create List
    ${BBMOD_impacted_LTE_CELL_id_list}=  Create List
    ${BBMOD_impacted_WCDMA_CELL_id_list}=  Create List
    ${BBMOD_impacted_GSM_CELL_id_list}=  Create List

    FOR  ${item}  IN  @{BBMOD_disabled_RMOD_CELL_id_list}

        IF  '${item}' in ${${alias}_NR_CELL_id_list} and '${item}' not in ${BBMOD_CELL_id_list}
            Append To List  ${BBMOD_impacted_NR_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_LTE_CELL_id_list} and '${item}' not in ${BBMOD_CELL_id_list}
            Append To List  ${BBMOD_impacted_LTE_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_WCDMA_CELL_id_list} and '${item}' not in ${BBMOD_CELL_id_list}
            Append To List  ${BBMOD_impacted_WCDMA_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_GSM_CELL_id_list} and '${item}' not in ${BBMOD_CELL_id_list}
            Append To List  ${BBMOD_impacted_GSM_CELL_id_list}  ${item}
        END

    END

    RETURN  ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  ${BBMOD_impacted_GSM_CELL_id_list}

Get peer BTS cells mapped on RMOD impact due to reset BBMOD
    [Arguments]  ${peer_BTS_disabled_RMOD_id_list}  ${alias}

    ${peer_BTS_impacted_CELL_id_list}=  Create List

    FOR  ${peer_RMOD_id}  IN  @{peer_BTS_disabled_RMOD_id_list}

        ${CELL_id_list}=  Get Cell Mapping By Module Id  module_id=${peer_RMOD_id}  connection=${alias}
        Append To List  ${peer_BTS_impacted_CELL_id_list}  @{CELL_id_list}

    END

    ${peer_BTS_impacted_CELL_id_list}=  Remove Duplicates  ${peer_BTS_impacted_CELL_id_list}
    Sort List  ${peer_BTS_impacted_CELL_id_list}

    ${peer_BTS_impacted_NR_CELL_id_list}=  Create List
    ${peer_BTS_impacted_LTE_CELL_id_list}=  Create List
    ${peer_BTS_impacted_WCDMA_CELL_id_list}=  Create List
    ${peer_BTS_impacted_GSM_CELL_id_list}=  Create List

    FOR  ${item}  IN  @{peer_BTS_impacted_CELL_id_list}

        IF  '${item}' in ${${alias}_NR_CELL_id_list}
            Append To List  ${peer_BTS_impacted_NR_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_LTE_CELL_id_list}
            Append To List  ${peer_BTS_impacted_LTE_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_WCDMA_CELL_id_list}
            Append To List  ${peer_BTS_impacted_WCDMA_CELL_id_list}  ${item}
        ELSE IF  '${item}' in ${${alias}_GSM_CELL_id_list}
            Append To List  ${peer_BTS_impacted_GSM_CELL_id_list}  ${item}
        END

    END

    RETURN  ${peer_BTS_impacted_NR_CELL_id_list}  ${peer_BTS_impacted_LTE_CELL_id_list}  ${peer_BTS_impacted_WCDMA_CELL_id_list}
    ...  ${peer_BTS_impacted_GSM_CELL_id_list}

Check all BTS state and alarm after BBMOD reset
    [Documentation]
    ...  Check state of BTS equipment after BBMOD Reset

    FOR  ${alias}  IN  @{alias_list}

        Log  Check ${BTS} state and alarms after reset BBMOD with SN ${BBMOD_sn} from ${BTS}:  console=True

        Log  Check BBMOD(s) status on ${BTS}  console=True
        Assert Every  class_name=BBMOD  parameters=${BBMOD_state_enabled_check}  timeout=300  connection=${alias}
        Log  All ${BTS} BBMOD(s) status:\n - ${BBMOD_state_enabled}  console=True

        Log  Check RMOD(s) status on ${BTS}  console=True
        Assert Every  class_name=BBMOD  parameters=${RMOD_state_enabled_check}  timeout=300  connection=${alias}
        Log  All ${BTS} RMOD(s) status:\n - ${RMOD_state_enabled}  console=True

        Log  Check CELL(s) status on ${BTS}  console=True
        IF  '${alias}' == '${current_alias}'
            Check cells state  ${alias}
            Log  All ${BTS} cell(s) status:\n - ${CELL_state_enabled}  console=True
        ELSE
            Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
            Log  All ${BTS} cell(s) status:\n - ${CELL_state_enabled}  console=True
        END

        Log  Check alarms on ${BTS}  console=True
        Get and Check Alarms SOAM
        ...  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${test_alarms_list['${alias.upper()}_IGNORED_ALARMS']}
        ...  critical_alarms=${test_alarms_list['${alias.upper()}_CRITICAL_ALARMS']}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END
    Get Current Date UTC info  cells_onair

Get BBMOD id list
    [Documentation]
    ...  Get BBMOD id list

    [Arguments]  ${alias}
    ${BTS}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${BBMOD_id_list}=  Get Ids For All  class_name=BBMOD  connection=${alias}
    Sort List  ${BBMOD_id_list}
    ${BBMOD_count}=  Get Length  ${BBMOD_id_list}
    IF  ${BBMOD_count} > 0
        Log  ${BTS} BBMOD found: ${BBMOD_id_list}  console=True
    ELSE
        Log  No ${BTS} BBMOD are present in runtime view configuration!  console=True
    END

    RETURN  ${BBMOD_id_list}

Get peer BTS alarms
    [Arguments]  ${detailed_dependent_peer_equipment_dict}  ${alias}

    ${RMOD_OBSAI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_OBSAI_disabled  DEDICATED_RMOD_OBSAI_disabled
    ${RMOD_FHS_CPRI_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_CPRI_disabled  DEDICATED_RMOD_CPRI_disabled
    ...  SHARED_FHS_CPRI_disabled
    ${RMOD_ECPRI_ECPRI_NETCONF_list}=  Get Combined List From Dictionary  ${detailed_dependent_peer_equipment_dict}
    ...  SHARED_RMOD_ECPRI_disabled  DEDICATED_RMOD_ECPRI_disabled
    ...  SHARED_RMOD_ECPRI_NETCONF_disabled  DEDICATED_RMOD_ECPRI_NETCONF_disabled

    ${OBSAI_FID10_alarm_count}=  Get Length  ${RMOD_OBSAI_list}
    ${CPRI_FID10_1815_alarm_count}=  Get Length  ${RMOD_FHS_CPRI_list}
    ${ECPRI_FID16_alarm_count}=  Get Length  ${RMOD_ECPRI_ECPRI_NETCONF_list}

    FOR  ${item}  IN  @{RMOD_ECPRI_ECPRI_NETCONF_list}
        ${RMOD_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias}
        IF  not('${RMOD_param['productName']}' in ${RMOD_ECPRI_fid16_exceptions})  CONTINUE
        ${ECPRI_FID16_alarm_count}=  Evaluate  ${ECPRI_FID16_alarm_count} - ${1}
    END

    RETURN  ${OBSAI_FID10_alarm_count}  ${CPRI_FID10_1815_alarm_count}  ${ECPRI_FID16_alarm_count}

Get peer BTS shared MODULE id list
    [Arguments]  ${MOD_class_name}  ${MOD_sn_list}  ${alias}

    ${MOD_id_list}=  Create List

    FOR  ${item}  IN  @{MOD_sn_list}

        ${MOD_id}=  Get From Dictionary  ${${alias}_${MOD_class_name}_sn_id_dict}  ${item}
        Append To List  ${MOD_id_list}  ${MOD_id}

    END
    Sort List  ${MOD_id_list}

    RETURN  ${MOD_id_list}

Check BTS status during reset BBMOD impact on connected FHSs
    [Arguments]  ${expected_own_BTS_enabled_shared_FHS_id_list}  ${expected_own_BTS_disabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}  ${expected_own_BTS_disabled_dedicated_FHS_id_list}  ${alias}

    Check FHS State  ${alias}  ${BTS}  ${BBMOD_sn}  shared  through no sync link
    ...  ${expected_own_BTS_enabled_shared_FHS_id_list}  ${Enabled_}  Enabled  ${Online_}
    ...  Online|None  ${Unlocked_}  Unlocked  5 sec

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check FHS State  ${alias}  ${BTS}  ${BBMOD_sn}  shared  through sync link
    ...  ${expected_own_BTS_disabled_shared_FHS_id_list}  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  ${remained_MAX_WAIT_TIME}

    Check FHS State  ${alias}  ${BTS}  ${BBMOD_sn}  dedicated  through no sync link
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}  ${Enabled_}
    ...  Enabled  ${Online_}  Online|None  ${Unlocked_}  Unlocked  5 sec

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check FHS State  ${alias}  ${BTS}  ${BBMOD_sn}  dedicated  through sync link
    ...  ${expected_own_BTS_disabled_dedicated_FHS_id_list}
    ...  ${Disabled_}  Disabled  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  ${remained_MAX_WAIT_TIME}

Check BTS status during reset BBMOD impact on connected RMODs
    [Arguments]  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${alias}

    Check BTS Item State  ${BTS}  shared, not losing sync or conf link  RMOD  directly and through FHS
    ...  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${BTS}  shared, losing sync or conf link  RMOD  directly and through FHS
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Check BTS Item State  ${BTS}  dedicated, not losing sync or conf link  RMOD  directly and through FHS
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${BTS}  dedicated, losing sync or conf link  RMOD  directly and through FHS
    ...  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ...  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}

Check BTS status during reset BBMOD impact on BBMOD cells
    [Arguments]  ${BBMOD_NR_CELL_id_list}  ${BBMOD_LTE_CELL_id_list}
    ...  ${BBMOD_WCDMA_CELL_id_list}  ${BBMOD_GSM_CELL_id_list}
    ...  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${BTS}  ${Empty}  NRCEL  ${Empty}  ${BBMOD_NR_CELL_id_list}
    ...  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${BTS}  ${Empty}  LNCEL  ${Empty}  ${BBMOD_LTE_CELL_id_list}
    ...  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${BTS}  ${Empty}  WNCEL  ${Empty}  ${BBMOD_WCDMA_CELL_id_list}
    ...  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${BTS}  ${Empty}  GNCEL  ${Empty}  ${BBMOD_GSM_CELL_id_list}
    ...  ${CELL_state_disabled_check}  ${CELL_state_disabled}
    ...  ${remained_MAX_WAIT_TIME}  ${alias}

Check BTS status during reset BBMOD impact on connected RMODs cells
    [Arguments]  ${BBMOD_impacted_NR_CELL_id_list}  ${BBMOD_impacted_LTE_CELL_id_list}
    ...  ${BBMOD_impacted_WCDMA_CELL_id_list}
    ...  ${BBMOD_impacted_GSM_CELL_id_list}  ${alias}

    Log  \nCheck ${BTS} cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status:
    ...  console=True

    Set Test Variable  ${BTS_ALARM_COUNT_MIMO}  0

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    IF  not ${BBMOD_impacted_NR_CELL_id_list}
        Log  - No ${BTS} NR cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status
        ...  console=True
    END
    IF  ${BBMOD_impacted_NR_CELL_id_list}
        ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=    Check NR cells state and MIMO alarm
        ...  cell_list=${BBMOD_impacted_NR_CELL_id_list}  alias=${alias}
    END
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    IF  not ${BBMOD_impacted_LTE_CELL_id_list}
        Log  - No ${BTS} LTE cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status
        ...  console=True
    END
    IF  ${BBMOD_impacted_LTE_CELL_id_list}
        ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=    Check LTE cells state and MIMO alarm
        ...  cell_list=${BBMOD_impacted_LTE_CELL_id_list}  alias=${alias}
    END
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    IF  not ${BBMOD_impacted_WCDMA_CELL_id_list}
        Log  - No ${BTS} WCDMA cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status
        ...  console=True
    END
    IF  ${BBMOD_impacted_WCDMA_CELL_id_list}
        ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=    Check WCDMA cells state and MIMO alarm
        ...  cell_list=${BBMOD_impacted_WCDMA_CELL_id_list}  alias=${alias}
    END
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${ALARM_COUNT_MIMO}  0
    IF  not ${BBMOD_impacted_GSM_CELL_id_list}
        Log  - No ${BTS} GSM cells mapped on RMODs connected to BBMOD with SN ${BBMOD_sn} with impact status
        ...  console=True
    END
    IF  ${BBMOD_impacted_GSM_CELL_id_list}
        ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=    Check GSM cells state and MIMO alarm
        ...  cell_list=${BBMOD_impacted_GSM_CELL_id_list}  alias=${alias}
    END
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

Check peer BTS status during reset BBMOD impact on connected FHSs
    [Arguments]  ${expected_peer_BTS_enabled_shared_FHS_id_list}  ${expected_peer_BTS_disabled_shared_FHS_id_list}
    ...  ${alias}

    Check FHS state  ${alias}  ${BTS}  ${BBMOD_sn}  shared  through no sync link  ${expected_peer_BTS_enabled_shared_FHS_id_list}
    ...  ${Enabled_}  Enabled  ${Online_}  Online|None  ${Unlocked_}  Unlocked  5 sec

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check FHS state  ${alias}  ${BTS}  ${BBMOD_sn}  shared  through sync link  ${expected_peer_BTS_disabled_shared_FHS_id_list}
    ...  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  ${remained_MAX_WAIT_TIME}

Check peer BTS status during reset BBMOD impact on connected RMODs
    [Arguments]    ${expected_peer_BTS_enabled_shared_RMOD_id_list}  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
    ...  ${alias}  ${peer_bts}

    Check BTS Item State  ${peer_bts}  shared, not losing sync or conf link  RMOD  directly and through FHS
    ...  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
    ...  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${peer_bts}  shared, losing sync or conf link  RMOD  directly and through FHS
    ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
    ...  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    Check BTS Item State  ${peer_bts}  dedicated, not losing sync or conf link  RMOD  indirectly(through FHS)
    ...  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${peer_BTS}  dedicated, losing sync or conf link  RMOD  indirectly(through FHS)
    ...  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
    ...  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  ${remained_MAX_WAIT_TIME}  ${alias}

Check BTS status after reset BBMOD impact on connected FHSs
    [Arguments]  ${expected_own_BTS_enabled_shared_FHS_id_list}  ${expected_own_BTS_disabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}  ${expected_own_BTS_disabled_dedicated_FHS_id_list}  ${alias}

    ${BBMOD_FHS_id_list}=  Combine Lists
    ...  ${expected_own_BTS_enabled_shared_FHS_id_list}  ${expected_own_BTS_disabled_shared_FHS_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_FHS_id_list}  ${expected_own_BTS_disabled_dedicated_FHS_id_list}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check FHS state  ${alias}  ${BTS}  ${BBMOD_sn}  shared and dedicated  through any kind of link  ${BBMOD_FHS_id_list}
    ...  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  ${remained_MAX_WAIT_TIME}

Check BTS status after reset BBMOD impact on connected RMODs
    [Arguments]  ${expected_own_BTS_enabled_shared_RMOD_id_list}  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}  ${alias}

    ${BBMOD_RMOD_id_list}=  Combine Lists
    ...  ${expected_own_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_own_BTS_enabled_dedicated_RMOD_id_list}  ${expected_own_BTS_disabled_dedicated_RMOD_id_list}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}

    Check BTS Item State  ${BTS}  shared and dedicated  RMOD  directly and through FHS
    ...  ${BBMOD_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

Check peer BTS status after reset BBMOD impact on connected FHSs
    [Arguments]  ${expected_peer_BTS_enabled_shared_FHS_id_list}  ${expected_peer_BTS_disabled_shared_FHS_id_list}  ${alias}

    ${peer_BTS_FHS_id_list}=  Combine Lists
    ...  ${expected_peer_BTS_enabled_shared_FHS_id_list}
    ...  ${expected_peer_BTS_disabled_shared_FHS_id_list}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check FHS state  ${alias}  ${BTS}  ${BBMOD_sn}  shared  through no sync link
    ...  ${peer_BTS_FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  ${remained_MAX_WAIT_TIME}

Check peer BTS status after reset BBMOD impact on connected RMODs
    [Arguments]  ${expected_peer_BTS_enabled_shared_RMOD_id_list}  ${expected_peer_BTS_disabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
    ...  ${alias}  ${peer_bts}

    ${peer_BTS_RMOD_id_list}=  Combine Lists
    ...  ${expected_peer_BTS_enabled_shared_RMOD_id_list}
    ...  ${expected_peer_BTS_disabled_shared_RMOD_id_list}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}
    Check BTS Item State  ${peer_BTS}  shared  RMOD  directly and through FHS
    ...  ${peer_BTS_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

    ${peer_BTS_RMOD_id_list}=  Combine Lists
    ...  ${expected_peer_BTS_enabled_dedicated_RMOD_id_list}
    ...  ${expected_peer_BTS_disabled_dedicated_RMOD_id_list}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BBMOD_MAX_WAIT_TIME}

    Check BTS Item State  ${peer_BTS}  dedicated  RMOD  indirectly (through FHS)
    ...  ${peer_BTS_RMOD_id_list}  ${RMOD_state_enabled_check}
    ...  ${RMOD_state_enabled}  ${remained_MAX_WAIT_TIME}  ${alias}

Check FHS state
    [Arguments]    ${alias}  ${BTS}  ${BBMOD_sn}  ${sharing}  ${comment}=${Empty}  ${FHS_id_list}=@{Empty}
    ...  ${expected_fhs_opstate_check}=${Empty}  ${expected_fhs_opstate}=${Empty}
    ...  ${expected_fhs_avstatus_check}=${Empty}  ${expected_fhs_avstatus}=${Empty}
    ...  ${expected_fhs_adstate_check}=${Empty}  ${expected_fhs_adstate}=${Empty}
    ...  ${time_total}=5 sec  ${time_wait_between}=1 sec

    ${particle}=  Set Variable If  'enabled' in '${expected_FHS_opstate.lower()}'  without  with
    IF  '${comment} '!=' '
        ${comment}=    Catenate  SEPARATOR=  ${SPACE}  ${comment}  ${SPACE}
    ELSE
        ${comment}=    Set Variable  ${Empty}
    END
    Log  \nCheck ${BTS} ${sharing} FHSs connected to BBMOD with SN ${BBMOD_sn}${comment}${particle} impact status:
    ...  console=True
    IF  ${FHS_id_list}
        Wait Until Keyword Succeeds  ${time_total}  ${time_wait_between}
        ...  Admin Check FHS list state  ${FHS_id_list}
        ...  ${expected_fhs_opstate_check}  ${expected_fhs_opstate}
        ...  ${expected_fhs_avstatus_check}  ${expected_fhs_avstatus}
        ...  ${expected_fhs_adstate_check}  ${expected_fhs_adstate}
        ...  alias=${alias}
        Log  - All ${BTS} ${sharing} FHSs connected to BBMOD with SN ${BBMOD_sn}${comment}${particle} impact status as expected
        ...  console=True
    ELSE
        Log  - No ${BTS} ${sharing} FHSs connected to BBMOD with SN ${BBMOD_sn}${comment}${particle} status
        ...  console=True
    END

Check BTS Item State
   [Arguments]   ${BTS}  ${sharing}  ${BTS_item_class}  ${comment}  ${BTS_item_list}
   ...  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}

    ${particle}=  Set Variable If  'enabled' in '${BTS_item_state.lower()}'  without  with
    ${log_part}=  Set Variable If  '${sharing} '!=' '  ${sharing} ${BTS_item_class}s  ${BTS_item_class}s
    ${log_part}=  Set Variable If  '${comment} '!=' '  ${log_part} ${comment}  ${log_part}
    Log  \nCheck ${BTS} ${log_part} connected to BBMOD SN ${BBMOD_sn} ${particle} impact:  console=True
    IF  ${BTS_item_list}
        FOR  ${item}  IN  @{BTS_item_list}
            Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}
            ...  timeout=${timeout}  connection=${alias}
            Log  ${BTS} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
        END
        Log  - All ${BTS} ${log_part} connected to BBMOD with SN ${BBMOD_sn} status as expected
        ...  console=True
    ELSE
        Log  - No ${BTS} ${log_part} connected to BBMOD with SN ${BBMOD_sn}
        ...  console=True
    END

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
        IF  '${item}' not in ${BTS_label_list}
            Append To List  ${BTS_invalid_label_list}  ${item}
        ELSE
            Append To List  ${BTS_request_label_list}  ${item}
        END
    END

    IF  '${BTS_check}' == 'False'
        Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}.
        ...  Please select values for test argument \${BTS_LIST} from
        ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
        Fail  Improper value for argument!
    END

    FOR  ${item}  IN  @{BTS_request_label_list}
        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}
    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Check all BTS requested RMOD reset behavior based on Uptime info
    [Documentation]
    ...  Shared and dedicated RMOD RESET behavior is checked based on Uptime info get from BTS.
    ...  RMOD reset behavior as expected if:
    ...  - RMOD on all BTS: no reset if RU is eligible for CB010846 feature
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}  ${peer_aliases}

    ${local_CB010846_actRuResiliency}=  Set Variable
    ...  '${${alias}_BTS_CB010846_feature_dict_current['actRuResetResiliency']}' != 'true'

    IF  ${local_CB010846_actRuResiliency}
        Log  Feature CB010846 not activated on BTS ${alias}. Skipping checks  console=True
        RETURN
    END

    Log  \nCheck all BTS requested RMOD reset behavior based on Uptime info  console=True

    ${BTS_alias_RMOD_sn_Uptime_dict_final}=  Get all BTS RMOD Uptime info
    Set Test Variable  ${BTS_alias_RMOD_sn_Uptime_dict_final}

    Check RMOD reset behavior on BTS  shared  CPRI
    ...  RMOD_sn_list=${own_BBMOD_shared_CPRI_RMOD_sn_list_10846}  alias=${alias}

    Check RMOD reset behavior on BTS  shared  ECPRI
    ...  RMOD_sn_list=${own_BBMOD_shared_ECPRI_RMOD_sn_list_10846}  alias=${alias}

    Check RMOD reset behavior on BTS  shared  ECPRI_NETCONF
    ...  RMOD_sn_list=${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}  alias=${alias}

    Check RMOD reset behavior on BTS  dedicated  CPRI
    ...  RMOD_sn_list=${own_BBMOD_dedicated_CPRI_RMOD_sn_list_10846}  alias=${alias}

    Check RMOD reset behavior on BTS  dedicated  ECPRI
    ...  RMOD_sn_list=${own_BBMOD_dedicated_ECPRI_RMOD_sn_list_10846}  alias=${alias}

    Check RMOD reset behavior on BTS  dedicated  ECPRI_NETCONF
    ...  RMOD_sn_list=${own_BBMOD_dedicated_ECPRI_NETCONF_RMOD_sn_list_10846}  alias=${alias}

    FOR  ${other_alias}  IN  @{peer_aliases}

        Check RMOD reset behavior on BTS  shared  CPRI
        ...  RMOD_sn_list=${${other_alias}_BBMOD_shared_CPRI_RMOD_sn_list_10846}  alias=${other_alias}

        Check RMOD reset behavior on BTS  shared  ECPRI
        ...  RMOD_sn_list=${${other_alias}_BBMOD_shared_ECPRI_RMOD_sn_list_10846}  alias=${other_alias}

        Check RMOD reset behavior on BTS  shared  ECPRI_NETCONF
        ...  RMOD_sn_list=${${other_alias}_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}
        ...  alias=${other_alias}

        Check RMOD reset behavior on BTS  dedicated  CPRI
        ...  RMOD_sn_list=${${other_alias}_dedicated_CPRI_RMOD_sn_list_10846}  alias=${other_alias}

        Check RMOD reset behavior on BTS  dedicated  ECPRI
        ...  RMOD_sn_list=${${other_alias}_dedicated_ECPRI_RMOD_sn_list_10846}  alias=${other_alias}

        Check RMOD reset behavior on BTS  dedicated  ECPRI_NETCONF
        ...  RMOD_sn_list=${${other_alias}_dedicated_ECPRI_NETCONF_RMOD_sn_list_10846}
        ...  alias=${other_alias}

    END

    IF  ${own_BBMOD_shared_CPRI_RMOD_sn_list_10846} and ${${alias}_CB007447_status}
        Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared CPRI RMODs eligible for CB010846:
        ...  console=True
        Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${own_BBMOD_shared_CPRI_RMOD_sn_list_10846}
    END
    IF  ${own_BBMOD_shared_ECPRI_RMOD_sn_list_10846}
        Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared ECPRI RMODs eligible for CB010846:
        ...  console=True
        Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${own_BBMOD_shared_ECPRI_RMOD_sn_list_10846}
    END
    IF  ${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}
        Log  Get Primary Link status (linkModeSynchronization) for BBMOD shared ECPRI_NETCONF RMODs eligible for CB010846:
        ...  console=True
        Get shared RMOD synchronisation info on both BTS  shared_RMOD_sn_list=${own_BBMOD_shared_ECPRI_NETCONF_RMOD_sn_list_10846}
    END

Check RMOD reset behavior on BTS
    [Arguments]  ${sharing}  ${protocol}  ${RMOD_sn_list}  ${alias}

    ${RMOD_sn_Uptime_dict_initial}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_initial}  ${alias}
    ${RMOD_sn_Uptime_dict_final}=  Get From Dictionary  ${BTS_alias_RMOD_sn_Uptime_dict_final}  ${alias}

    Log  - Check BTS ${alias} BBMOD ${sharing} ${protocol} RMOD eligible for CB010846 feature reset behavior based on Uptime info
    ...  console=True
    IF  ${RMOD_sn_list} and ${${alias}_CB007447_status}
        Check RMODs RESET behavior based on Uptime info on BTS  RMOD_sn_list=${RMOD_sn_list}
        ...  RMOD_sn_Uptime_dict_initial=${RMOD_sn_Uptime_dict_initial}  RMOD_sn_Uptime_dict_final=${RMOD_sn_Uptime_dict_final}
        ...  alias=${alias}
    ELSE
        Log  - No BBMOD ${sharing} ${protocol} RMODs eligible for CB010846 feature on BTS ${alias}  console=True
    END

Check peer BTS CPRI shared RMODs status with CB007447 feature activated
    [Arguments]  ${date_timestamp_start_UTC}  ${date_timestamp_end_UTC}  ${peer_aliases}

    FOR  ${peer_alias}  IN  @{peer_aliases}
        IF  not ${${peer_alias}_CB007447_status}    CONTINUE

        Log  \nCheck BTS ${peer_alias} CPRI shared RMODs status with CB007447 feature activated:  console=True
        ${RMOD_status_dict}=  Create Dictionary  operationalState=enabled
        ${ims_file_path}=  Admin Collect IMS file with timestamp  folder_path=${Test Results Dir}/IMS/${peer_alias}
        ...  alias=${peer_alias}

        Check CPRI shared RMODs status with CB007447 feature activated
        ...  CPRI_shared_RMOD_id_list=${${peer_alias}_enabled_shared_CPRI_RMOD_id_list_7447}  ims_file_path=${ims_file_path}
        ...  RMOD_status_dict=${RMOD_status_dict}  start_time=${date_timestamp_start_UTC}  end_time=${date_timestamp_end_UTC}

        Log  - BTS ${peer_alias} CPRI shared RMODs status with CB007447 feature activated as expected  console=True
    END

Get shared RMOD synchronisation info on both BTS
    [Arguments]  ${shared_RMOD_sn_list}

    ${shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

     FOR  ${RMOD_sn}  IN  @{shared_RMOD_sn_list}
        ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}=  Get shared RMOD synchronisation info  ${RMOD_sn}
     END

    RETURN  ${shared_RMOD_sn_BTS_alias_linkModeSynchronization_info_dict}

Get shared RMOD synchronisation info
    [Arguments]  ${RMOD_sn}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}
    ${BTS_alias_linkModeSynchronization_info_dict}=  Create Dictionary

    Log  RMOD_${RMOD_sn} linkModeSynchronization info:  console=True

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        ${RMOD_linkModeSynchronization}  ${RMOD_interface}=  Get classical BTS RMOD synchronisation info from SCF  ${RMOD_sn}
        ...  ${alias}
        Log  - BTS ${alias} (${RMOD_interface}): ${RMOD_linkModeSynchronization}  console=True

        Set To Dictionary  ${BTS_alias_linkModeSynchronization_info_dict}  ${alias}  ${RMOD_linkModeSynchronization}

    END

    RETURN  ${BTS_alias_linkModeSynchronization_info_dict}  ${RMOD_interface}

Check CPRI shared RMODs status with CB007447 feature activated
    [Arguments]    ${CPRI_shared_RMOD_id_list}  ${ims_file_path}  ${RMOD_status_dict}  ${start_time}  ${end_time}

    FOR  ${RMOD_id}  IN  @{CPRI_shared_RMOD_id_list}

        Check object parameters values are not changed from IMS file  ${ims_file_path}  ${RMOD_id}  ${RMOD_status_dict}
        ...  ${start_time}
        ...  ${end_time}  ${True}  ${True}

    END

Recover initial settings for CB010846 feature
    [Documentation]
    ...  Keyword used to recover initial settings for CB010846 feature

    [Arguments]  ${alias}

    IF  '${ACTIVATE_CB010846}' != '${True}'
        Log  \nCB010846 feature settings were not changed. No recover needed.  console=True
        RETURN
    ELSE
        Log  \nRecovering initial CB010846 feature settings for BTS ${alias}.  console=True
    END

    ${actRuResetResiliency_initial}=  Get From Dictionary  ${${alias}_BTS_CB010846_feature_dict_initial}  actRuResetResiliency
    Set classical BTS CB010846 feature parameter  actRuResetResiliency  ${actRuResetResiliency_initial}  ${alias}
    ${cntrldResetMplaneBreakTime_initial}=  Get From Dictionary  ${${alias}_BTS_CB010846_feature_dict_initial}
    ...  cntrldResetMplaneBreakTime
    Set classical BTS CB010846 feature parameter  cntrldResetMplaneBreakTime  ${cntrldResetMplaneBreakTime_initial}  ${alias}

Particular Teardown

    FOR  ${alias}  IN  @{alias_list}
        Recover initial settings for CB010846 feature  ${alias}
    END

    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}  newAlarmsFormat=${TRUE}

TC Teardown
    Common Test Teardown
